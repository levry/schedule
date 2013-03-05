{
  Главная форма "Расписание"
  v0.2.3 (25/01/10)
}

unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ActnList, ActnMan, ComCtrls, StdCtrls, ExtCtrls,
  Grids, DBGrids, ToolWin, DBCtrls, ImgList, DOptions,
{$IF RTLVersion>=15.0}
  XPStyleActnCtrls,
{$IFEND}
  Buttons, SClasses, Modules, BrowserForm, TimeModule;

type
  TfrmMain = class(TForm)
    MainMenu: TMainMenu;
    mnuService: TMenuItem;
    mnuServiceExport: TMenuItem;
    mnuProject: TMenuItem;
    mnuProjectClose: TMenuItem;
    Splitter: TSplitter;
    StatusBar: TStatusBar;
    ContainerPanel: TPanel;
    ActionList: TActionList;
    actProjectFirstSem: TAction;
    actProjectSecondSem: TAction;
    actProjectFirstPSem: TAction;
    actProjectSecondPSem: TAction;
    ToolBar: TToolBar;
    btnSem: TToolButton;
    btnPSem: TToolButton;
    SemMenu: TPopupMenu;
    PSemMenu: TPopupMenu;
    mnuFirstSem: TMenuItem;
    mnuSecondSem: TMenuItem;
    mnuFirstPSem: TMenuItem;
    mnuSecondPSem: TMenuItem;
    BrowserPanel: TPanel;
    ToolButton1: TToolButton;
    btnViewAuditory: TToolButton;
    btnViewTeachers: TToolButton;
    btnViewSchedule: TToolButton;
    actViewAuditory: TAction;
    actViewTeacher: TAction;
    actViewSchedule: TAction;
    TabControl: TTabControl;
    CaptionLabel: TLabel;
    actServiceExport: TAction;
    actProjectExit: TAction;
    actProjectConnect: TAction;
    actProjectDisconect: TAction;
    actProjectEditLink: TAction;
    mnuProjectConnect: TMenuItem;
    mnuProjectDisconnect: TMenuItem;
    mnuProjectEditLink: TMenuItem;
    N4: TMenuItem;
    actViewUpdate: TAction;
    mnuView: TMenuItem;
    mnuViewAuditory: TMenuItem;
    mnuViewTeachers: TMenuItem;
    mnuViewSchedule: TMenuItem;
    N5: TMenuItem;
    mnuViewUpdate: TMenuItem;
    MainImageList: TImageList;
    actViewSem: TAction;
    actViewPSem: TAction;
    mnuHelp: TMenuItem;
    actProjectYear: TAction;
    mnuProjectYear: TMenuItem;
    N2: TMenuItem;
    actViewTeacherTime: TAction;
    mnuViewTeacherTime: TMenuItem;
    btnViewTeacherTime: TToolButton;
    actViewAuditoryTime: TAction;
    btnViewAuditoryTime: TToolButton;
    mnuViewAuditoryTime: TMenuItem;
    actHelpTopics: TAction;
    actHelpModule: TAction;
    mnuHelpTopics: TMenuItem;
    mnuHelpModule: TMenuItem;
    actViewAuditoryLoad: TAction;
    mnuViewAuditoryLoad: TMenuItem;
    btnViewAuditoryLoad: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SemActionExecute(Sender: TObject);
    procedure SemActionUpdate(Sender: TObject);
    procedure ViewActionsExecute(Sender: TObject);
    procedure TabControlChange(Sender: TObject);
    procedure ServiceActionsExecute(Sender: TObject);
    procedure ServiceActionsUpdate(Sender: TObject);
    procedure ProjectActionsExecute(Sender: TObject);
    procedure ProjectActionsUpdate(Sender: TObject);
    procedure ViewActionsUpdate(Sender: TObject);
    procedure HelpActionExecute(Sender: TObject);
    procedure StatusBarResize(Sender: TObject);
    procedure HelpActionUpdate(Sender: TObject);
  private
    { Private declarations }
    FOptions: TDOptions;
    FBrowser: TfmBrowser;
    FModuleManager: TModuleManager;

    procedure ShowPeriod;
    procedure ShowHint(Sender: TObject);
    procedure ShowBrowser(AVisible: boolean);
    procedure ShowContainer(AVisible: boolean);
    procedure LinkDB(AConnect: boolean);
  private
    { Events }
    procedure OnChangeBrowse(Sender: TObject);
    procedure OnChangeTime(Sender: TObject; Flags: WORD);
    procedure OnCreateModule(Sender: TObject);
    procedure OnDestroyModule(Sender: TObject);
    procedure OnChangeModule(Sender: TObject);

  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses
  Registry, ADOConEd, DB, ADODB,
  SUtils, SIntf, SConsts, SStrings, SCategory, STypes, SHelp,
  ExportDeclare, ConnectEdit,  // dialogs
  TeacherForm, AuditoryForm, DeclareForm, WorkViewForm, StreamsForm,
  ScheduleForm, ResourceTimeForm, ResourceLoadForm;  // modules

//type
//  TNodeKind = (nkKafedra,nkGroup,nkDeclare,nkSubject);

{$R *.dfm}

procedure TfrmMain.FormCreate(Sender: TObject);
var
  category: TClientCategory;
begin
  StatusBar.Panels[2].Text:=SConsts.SCH_VERSION;

  MainImageList.ResourceLoad(rtBitmap, 'MAIN', clFuchsia);

  FOptions:=TDOptions.Create(REG_ROOT, REG_DTABLE);
  FOptions.LoadSettings;
  category:=FOptions[CAT_DTABLE] as TClientCategory;
  bDebugMode:=category.Debug;
  Application.HelpFile:=BuildFullName(FOptions.Root.HelpFile);
  dmMain.Sem:=FOptions.Root.Sem;
  dmMain.PSem:=FOptions.Root.PSem;

  FBrowser:=TfmBrowser.Create(Self, BrowserPanel, category.BrowseMode);
  FBrowser.OnChange:=OnChangeBrowse;
  FBrowser.Show;

  FModuleManager:=TModuleManager.Create(ContainerPanel, FOptions);
  FModuleManager.OnCreateModule:=OnCreateModule;
  FModuleManager.OnDestroyModule:=OnDestroyModule;
  FModuleManager.OnChangeModule:=OnChangeModule;

  Left:=category.Left;
  Top:=category.Top;
  Height:=category.Height;
  Width:=category.Width;
  Application.OnHint:=ShowHint;

  LinkDB(category.AutoConn);

  dmMain.OnChangeTime:=OnChangeTime;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
var
  category: TClientCategory;
begin
  FModuleManager.Free;
  FModuleManager:=nil;

  category:=FOptions[CAT_DTABLE] as TClientCategory;
  category.Top:=Top;
  category.Left:=Left;
  category.Height:=Height;
  category.Width:=Width;

  FOptions.Root.Sem:=dmMain.Sem;
  FOptions.Root.PSem:=dmMain.PSem;

  FOptions.SaveSettings;
  FOptions.Free;
end;

// вывод тек. периода (семестр, п/сем)
procedure TfrmMain.ShowPeriod;
begin
  if dmMain.Connection.Connected then
    Caption:=Format(rsSchedule+' [%d] [%s] [%d п/семестр]',
        [dmMain.Year,csSemester[dmMain.Sem],dmMain.PSem])
  else Caption:=rsSchedule;
end;

procedure TfrmMain.LinkDB(AConnect: boolean);
var
  errno: integer;
begin
  if AConnect then
  begin
    errno:=dmMain.Connect(FOptions.Root.ConnStr);
    if errno=ERROR_CON_VERSION then
      ShowMessage('Неизвестная версия базы.') else
      if errno=ERROR_CON_FAILED then ShowMessage('Ошибка при соединении с базой');
  end
  else dmMain.Connection.Close;

  ShowBrowser(dmMain.Connection.Connected);
  ShowContainer(dmMain.Connection.Connected);
  ShowPeriod;
  if not dmMain.Connection.Connected then
  begin
    //CaptionLabel.Caption:='';
    StatusBar.Panels[1].Text:='';
    StatusBar.Panels[3].Text:='';
    FBrowser.Clear;
    FModuleManager.CloseAll;
  end
  else
  begin
    StatusBar.Panels[1].Text:=dmMain.FacultyName;
    StatusBar.Panels[3].Text:=dmMain.DBName + ' (' + dmMain.VersionAsString + ')';
  end;
end;

procedure TfrmMain.ShowHint(Sender: TObject);
begin
  StatusBar.Panels[0].Text:=Application.Hint;
end;

procedure TfrmMain.OnChangeTime(Sender: TObject; Flags: WORD);
var
  Msg: TSMChangeTime;
begin
  ShowPeriod;

  ZeroMemory(@Msg, sizeof(TSMChangeTime));

  Msg.Msg:=SM_CHANGETIME;
  Msg.Flags:=Flags;              // признаки изм-ния
  Msg.Year:=dmMain.Year;         // зн-ние года
  Msg.Sem:=dmMain.Sem;           // зн-ние семестра
  Msg.PSem:=dmMain.PSem;         // зн-ние п/семестра

  FModuleManager.Broadcast(TMessage(Msg));

  FBrowser.Dispatch(TMessage(Msg));

{
  if ckPSem in Change then
  begin
    Msg.Msg:=WM_CHANGESEM;
    Msg.WParam:=integer(bsem);
    Msg.LParam:=integer(bpsem);
    FModuleManager.Broadcast(Msg);
    //ContainerPanel.Broadcast(Msg);
  end
  else
  begin
    CaptionLabel.Caption:='';
    for i:=0 to ContainerPanel.ControlCount-1 do
    begin
      if ContainerPanel.Controls[i] is TForm then
        TForm(ContainerPanel.Controls[i]).Close;
    end;
  end;
}
end;

// изм-ние семестра (номер и полусеместр)
procedure TfrmMain.SemActionExecute(Sender: TObject);
begin
  if not TAction(Sender).Checked then
  begin
    case TAction(Sender).Tag of
      1:  // 1 sem
        dmMain.Sem:=1;
      2:  // 2 sem
        dmMain.Sem:=2;
      3:  // 1 psem
        dmMain.PSem:=1;
      4:  // 2 psem
        dmMain.PSem:=2;
      else
        raise Exception.CreateFmt('Unknown action (Tag=%d)', [TAction(Sender).Tag]);
    end;
  end;
end;

// обновление эл-тов семестра
procedure TfrmMain.SemActionUpdate(Sender: TObject);
begin
  case (Sender as TAction).Tag of
    1:  // 1 sem
      TAction(Sender).Checked:=(dmMain.Sem=1);
    2:  // 2 sem
      TAction(Sender).Checked:=(dmMain.Sem=2);
    3:  // 1 psem
      TAction(Sender).Checked:=(dmMain.PSem=1);
    4:  // 2 psem
      TAction(Sender).Checked:=(dmMain.PSem=2);
    else
      raise Exception.CreateFmt('Unknown action (Tag=%d)', [TAction(Sender).Tag]);
  end; // case
end;

procedure TfrmMain.ViewActionsExecute(Sender: TObject);
var
  btn: TToolButton;
begin
  case (Sender as TAction).Tag of
    -2,-3: // view sem
      begin
        if TAction(Sender).ActionComponent is TToolButton then
        begin
          btn:=TToolButton(TAction(Sender).ActionComponent);
          if Assigned(btn.DropdownMenu) then btn.CheckMenuDropdown;
        end;
      end;
    -1: // update module
      if Assigned(FModuleManager.ActiveModule) then
        FModuleManager.ActiveModule.UpdateModule;
    1:  // auditories
      FModuleManager.Show(TfrmAuditory, true);
    2:  // teachers
      FModuleManager.Show(TfrmTeachers, true);
    3:  // schedule
      FModuleManager.Show(TfrmSchedule, true);
    4:  // teacher time
      FModuleManager.Show(TfrmTeacherTime, true);
    5:  // auditory time
      FModuleManager.Show(TfrmAuditoryTime, true);
    6:  // auditory load
      FModuleManager.Show(TfrmAuditoryLoad, true);

    else
      raise Exception.CreateFmt('Unknown action (Tag=%d)', [TAction(Sender).Tag]);
  end;
end;

procedure TfrmMain.ViewActionsUpdate(Sender: TObject);
begin
  case (Sender as TAction).Tag of

    -3: // view psem
      begin
        TAction(Sender).Enabled:=dmMain.Connection.Connected;
        if dmMain.PSem=1 then
        begin
          TAction(Sender).ImageIndex:=actProjectFirstPSem.ImageIndex;
          TAction(Sender).Hint:='1 п/семестр';
        end else
          if dmMain.PSem=2 then
          begin
            TAction(Sender).ImageIndex:=actProjectSecondPSem.ImageIndex;
            TAction(Sender).Hint:='2 п/семестр';
          end else TAction(Sender).ImageIndex:=-1;
      end;

    -2: // view sem
      begin
        TAction(Sender).Enabled:=dmMain.Connection.Connected;
        if dmMain.Sem=1 then
        begin
          TAction(Sender).ImageIndex:=actProjectFirstSem.ImageIndex;
          TAction(Sender).Hint:='Осенний семестр';
        end else
          if dmMain.Sem=2 then
          begin
            TAction(Sender).ImageIndex:=actProjectSecondSem.ImageIndex;
            TAction(Sender).Hint:='Весенний семестр';
          end else TAction(Sender).ImageIndex:=-1;
      end;

    -1: // update module
      TAction(Sender).Visible:=Assigned(FModuleManager.ActiveModule);

    else
      TAction(Sender).Enabled:=dmMain.Connection.Connected;

  end;
end;

// событие при создании модуля
procedure TfrmMain.OnCreateModule(Sender: TObject);
var
  i: integer;
begin
  if Sender is TModuleClass then
  begin
    i:=TabControl.Tabs.AddObject(TModuleForm(Sender).ModuleName,Sender);
    TabControl.TabIndex:=i;
  end
  else raise Exception.CreateFmt('OnModuleCreate: Sender is "%s"', [Sender.ClassName]);
end;

// событие при уничтожении модуля
procedure TfrmMain.OnDestroyModule(Sender: TObject);
var
  i: integer;
begin
  if Sender is TModuleClass then
  begin
    i:=TabControl.Tabs.IndexOfObject(Sender);
    TabControl.Tabs.Objects[i]:=nil;
    if i>=0 then TabControl.Tabs.Delete(i);
    if FModuleManager.Count=1 then CaptionLabel.Caption:='';
  end
  else raise Exception.CreateFmt('OnModuleDestroy: Sender is "%s"', [Sender.ClassName]);
end;

// событие при смене актив. модуля
procedure TfrmMain.OnChangeModule(Sender: TObject);
var
  i: integer;
begin
  if Sender is TModuleForm then
  begin
    i:=TabControl.Tabs.IndexOfObject(Sender);
    if i>=0 then
    begin
      if i<>TabControl.TabIndex then
        TabControl.TabIndex:=i;
      CaptionLabel.Caption:=' '+TModuleForm(Sender).Caption;
    end;
  end;
end;

procedure TfrmMain.TabControlChange(Sender: TObject);
var
  ModuleForm: TModuleForm;
begin
  if Sender is TTabControl then
  begin
    ModuleForm:=TTabControl(Sender).Tabs.Objects[TTabControl(Sender).TabIndex] as TModuleForm;
    FModuleManager.Show(TModuleClass(ModuleForm.ClassType), false);
//    if Assigned(ModuleForm) then
//    begin
//      ModuleForm.Show;
//      ModuleForm.BringToFront;
//    end;
  end;
end;

// событие при выборе в Browser`е
procedure TfrmMain.OnChangeBrowse(Sender: TObject);
var
  Module: TModuleForm;
  obj: TBrowseObject;
begin
  Assert(Assigned(Sender),
    'B1ECCE15-9968-4AC7-B020-F37F4D622C43'#13'OnChangeBrowse: Sender is nil'#13);
  Assert(Sender is TBrowseObject,
    'B7D026FB-7A53-47B1-8422-D7719F790953'#13'OnChangeBrowse: Sender is not TBrowseObject'#13);

  if Sender is TBrowseObject then
  begin
    obj:=TBrowseObject(Sender);
    case obj.Kind of
      okGroup:     // просмотр раб. плана группы
        if obj.Parent.Kind=okGroups then
        begin
          Module:=FModuleManager.Show(TfrmWorkView, false);
          TfrmWorkView(Module).Open(obj.Text);
        end else
          if obj.Parent.Kind=okDeclare then
          begin
            Module:=FModuleManager.Show(TfrmStreams, false);
            TfrmStreams(Module).OpenGroup(obj.Id, obj.Parent.Text);
          end
          else Module:=nil;

      okDeclares:  // просмотр заявок по всем дисциплинам
        begin
          Module:=FModuleManager.Show(TfrmDeclare, false);
          TfrmDeclare(Module).Open(obj.Parent.Text);
        end;

      okDeclare:   // просмотр потоков
        if obj.Parent.Kind=okDeclares then
        begin
          Module:=FModuleManager.Show(TfrmStreams, false);
          TfrmStreams(Module).Open(obj.Parent.Text,
              TBrowseObject(Sender).Text);
        end
        else Module:=nil;

      okSubject:   // просмотр потоков для дисциплны группы
        begin
          Module:=FModuleManager.Show(TfrmStreams, false);
          TfrmStreams(Module).OpenGroup(obj.Parent.Id,obj.Text);
        end;

      else
        Module:=nil;
    end;  // case

    if Assigned(Module) then CaptionLabel.Caption:=' '+Module.Caption;
  end;
end;

procedure TfrmMain.ShowBrowser(AVisible: boolean);
begin
  BrowserPanel.Visible:=AVisible;
  if AVisible then
    Splitter.Left:=BrowserPanel.Left+BrowserPanel.Width;
  Splitter.Visible:=AVisible;
end;

procedure TfrmMain.ShowContainer(AVisible: boolean);
begin
  ContainerPanel.Visible:=AVisible;
end;

procedure TfrmMain.ServiceActionsExecute(Sender: TObject);

  // экспорт заявок
  procedure ExportDeclares;
  var
    module: TModuleForm;
    skafedra: string;     // kid=kName;
  begin
    skafedra:='';

    module:=FModuleManager.ActiveModule;
    if Assigned(module) then
      if module is TfrmDeclare then skafedra:=TfrmDeclare(module).kafedra else
        if module is TfrmStreams then skafedra:=TfrmStreams(module).kafedra;

    if skafedra<>'' then DoExportDeclare(skafedra)
      else DoExportDeclare();
  end;  // procedure ExportDeclares

begin
  case (Sender as TAction).Tag of

    2:  // export declares
      ExportDeclares;

    else
      raise Exception.CreateFmt('Unknown action (Tag=%d)', [TAction(Sender).Tag]);
  end;
end;

procedure TfrmMain.ServiceActionsUpdate(Sender: TObject);
begin
  case (Sender as TAction).Tag of

    2:  // export declares
      TAction(Sender).Enabled:=dmMain.Connection.Connected;

    else
      raise Exception.CreateFmt('Unknown action (Tag=%d)', [TAction(Sender).Tag]);

  end;  // case
end;

procedure TfrmMain.ProjectActionsExecute(Sender: TObject);
begin
  case (Sender as TAction).Tag of
    -1:  // exit
      Close;
    5:  // connect
      LinkDB(true);

    6:  // disconnect
      LinkDB(false);

    7:  // edit link
      if not dmMain.Connection.Connected then
      begin
        if EditConnection(FOptions.Root) then
          dmMain.Connection.ConnectionString:=FOptions.Root.ConnStr;
      end
      else raise Exception.Create('Открыто соединение с БД');

    8:  // change year
      dmMain.ChangeYear;

    else
      raise Exception.CreateFmt('Unknown action (Tag=%d)', [TAction(Sender).Tag]);
  end;
end;

procedure TfrmMain.ProjectActionsUpdate(Sender: TObject);
begin
  case (Sender as TAction).Tag of

    5,  // connect
    7:  // edit link
      TAction(Sender).Enabled:=not dmMain.Connection.Connected;

    6,  // disconnect
    8:  // change year
      TAction(Sender).Enabled:=dmMain.Connection.Connected;

    else
      raise Exception.CreateFmt('Unknown action (Tag=%d)', [TAction(Sender).Tag]);
  end;
end;

procedure TfrmMain.HelpActionExecute(Sender: TObject);

begin
  case (Sender as TAction).Tag of
    1:  // help topics
      DisplayTopic(HELP_TIMETABLE);

    2:  // help of module
      if Assigned(FModuleManager.ActiveModule) then
        FModuleManager.ActiveModule.DoHelp;

    else
      raise Exception.CreateFmt('Unknown action (Tag=%d)', [TAction(Sender).Tag]);
  end;  // case
end;

procedure TfrmMain.HelpActionUpdate(Sender: TObject);

  procedure DoUpdateHelpModule;
  var
    Module: TModuleForm;
  begin
    Module:=FModuleManager.ActiveModule;
    if Assigned(Module) then
    begin
      TAction(Sender).Visible:=true;
      TAction(Sender).Enabled:=Module.CanHelp;
      TAction(Sender).Caption:=Format('%s: %s',[rsHelp, Module.ModuleName]);
    end
    else TAction(Sender).Visible:=false;
  end;  // DoUpdateHelpModule

begin
  case (Sender as TAction).Tag of

    1:  // help topics
        TAction(Sender).Visible:=(Application.HelpFile<>'');

    2:  // help of module
      DoUpdateHelpModule;

  end;
end;

procedure TfrmMain.StatusBarResize(Sender: TObject);
var
  n: integer;
  i: integer;
begin
  n:=0;
  for i:=1 to TStatusBar(Sender).Panels.Count-1 do
    inc(n,TStatusBar(Sender).Panels[i].Width);
  TStatusBar(Sender).Panels[0].Width:=TStatusBar(Sender).Width-n;
end;

end.
