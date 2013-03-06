{
  Главная форма "Расписание экзаменов"
  v0.2.2  (29/09/06)
}

unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ExtCtrls, ToolWin, ActnMan, ActnCtrls, ComCtrls,
  ActnList, StdActns, ImgList, StdCtrls,
  Modules, BrowseForm, XMOptions, STypes;

type
  TfrmMain = class(TForm)
    BrowserPanel: TPanel;
    Splitter: TSplitter;
    ActionList: TActionList;
    actProjectExit: TFileExit;
    actViewBrowser: TAction;
    MainMenu: TMainMenu;
    mnuProject: TMenuItem;
    mnuProjectExit: TMenuItem;
    mnuView: TMenuItem;
    mnuViewBrowser: TMenuItem;
    actViewUpdate: TAction;
    mnuViewUpdate: TMenuItem;
    N1: TMenuItem;
    ToolBar: TToolBar;
    btnViewBrowser: TToolButton;
    actProjectConnect: TAction;
    actProjectDisconnect: TAction;
    mnuProjectConnect: TMenuItem;
    mnuProjectDisconnect: TMenuItem;
    actProjectEditLink: TAction;
    mnuProjectEditLink: TMenuItem;
    N3: TMenuItem;
    TabControl: TTabControl;
    ModulePanel: TPanel;
    actProjectFirstSem: TAction;
    actProjectSecondSem: TAction;
    SemMenu: TPopupMenu;
    mnuFirstSem: TMenuItem;
    mnuSecondSem: TMenuItem;
    btnSem: TToolButton;
    ToolButton4: TToolButton;
    actViewSem: TAction;
    MainImageList: TImageList;
    CaptionLabel: TLabel;
    mnuHelp: TMenuItem;
    StatusBar: TStatusBar;
    actProjectYear: TAction;
    mnuProjectYear: TMenuItem;
    N4: TMenuItem;
    actViewExams: TAction;
    mnuViewExams: TMenuItem;
    N5: TMenuItem;
    btnViewExams: TToolButton;
    actViewExamList: TAction;
    mnuViewExamList: TMenuItem;
    btnViewExamList: TToolButton;
    actHelpTopics: TAction;
    actHelpModule: TAction;
    mnuHelpTopics: TMenuItem;
    mnuHelpModule: TMenuItem;
    actViewExamKaf: TAction;
    btnViewExamKaf: TToolButton;
    mnuViewExamKaf: TMenuItem;
    actViewLoadAud: TAction;
    btnViewLoadAud: TToolButton;
    mnuViewLoadAud: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ViewActionExecute(Sender: TObject);
    procedure ViewActionUpdate(Sender: TObject);
    procedure ProjectActionExecute(Sender: TObject);
    procedure ProjectActionUpdate(Sender: TObject);
    procedure TabControlChange(Sender: TObject);
    procedure SemActionExecute(Sender: TObject);
    procedure SemActionUpdate(Sender: TObject);
    procedure HelpActionExecute(Sender: TObject);
    procedure StatusBarResize(Sender: TObject);
    procedure HelpActionUpdate(Sender: TObject);
  private
    FOptions: TXMOptions;

    procedure OnBrowseChange(Sender: TObject; const Entity: TEntityData);
    procedure OnChangeTime(Sender: TObject; Flags: WORD);

    procedure OnCreateModule(Sender: TObject);
    procedure OnDestroyModule(Sender: TObject);
    procedure OnChangeModule(Sender: TObject);

    procedure ShowBrowser(AVisible: boolean);
    procedure ShowContainer(AVisible: boolean);
    procedure ShowPeriod;
    procedure LinkDB(AConnect: boolean);
  private
    { Private declarations }
    FBrowser: TfrmBrowser;

    FModuleManager: TModuleManager;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses
  ConnectEdit,
  ExamModule,
  SConsts, SStrings, SUtils, SCategory, SHelp,
  CustomOptions, StringListDlg,
  ExamForm, ExamListForm, ExamKafForm, ExamAuditoryForm;

{$R *.dfm}

procedure TfrmMain.FormCreate(Sender: TObject);
var
  category: TClientCategory;
begin
  StatusBar.Panels[2].Text:=SConsts.XMT_VERSION;

  MainImageList.ResourceLoad(rtBitmap, 'MAIN', clFuchsia);

  FOptions:=TXMOptions.Create(REG_ROOT, REG_XMTABLE);
  FOptions.LoadSettings;
  category:=FOptions[CAT_XMTABLE] as TClientCategory;
  bDebugMode:=category.Debug;
  Application.HelpFile:=BuildFullName(FOptions.Root.HelpFile);
  dmExam.Sem:=FOptions.Root.Sem;
  dmExam.PSem:=FOptions.Root.PSem;

  FBrowser:=TfrmBrowser.Create(Self,BrowserPanel,dmExam);
  FBrowser.OnEntityChange:=OnBrowseChange;
  FBrowser.Show;

  FModuleManager:=TModuleManager.Create(ModulePanel, FOptions);
  FModuleManager.OnCreateModule:=OnCreateModule;
  FModuleManager.OnDestroyModule:=OnDestroyModule;
  FModuleManager.OnChangeModule:=OnChangeModule;

  Top:=category.Top;
  Left:=category.Left;
  Width:=category.Width;
  Height:=category.Height;

  LinkDB(category.AutoConn);

  dmExam.OnChangeTime:=OnChangeTime;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
var
  category: TClientCategory;
begin
  FModuleManager.Free;
  FModuleManager:=nil;
  FBrowser.Free;
  FBrowser:=nil;

  category:=FOptions[CAT_XMTABLE] as TClientCategory;
  category.Top:=Top;
  category.Left:=Left;
  category.Width:=Width;
  category.Height:=Height;

  FOptions.Root.Sem:=dmExam.Sem;
  FOptions.Root.PSem:=dmExam.PSem;

  FOptions.SaveSettings;
  FOptions.Free;
  FOptions:=nil;
end;


procedure TfrmMain.LinkDB(AConnect: boolean);
var
  errno: integer;
begin
  if AConnect then
  begin
    errno:=dmExam.Connect(FOptions.Root.ConnStr);
    if errno=ERROR_CON_VERSION then
      ShowMessage('Неизвестная версия базы.') else
      if errno=ERROR_CON_FAILED then ShowMessage('Ошибка при соединении с базой');
  end
  else dmExam.Connection.Close;

  ShowBrowser(dmExam.Connection.Connected);
  ShowContainer(dmExam.Connection.Connected);
  ShowPeriod;
  if not dmExam.Connection.Connected then
  begin
    //CaptionLabel.Caption:='';
    StatusBar.Panels[1].Text:='';
    StatusBar.Panels[3].Text:='';
    FBrowser.Clear;
    FModuleManager.CloseAll;
  end
  else
  begin
    StatusBar.Panels[1].Text:=dmExam.FacultyName;
    StatusBar.Panels[3].Text:=dmExam.DBName+' ('+dmExam.VersionAsString+')';
  end;
end;

procedure TfrmMain.ShowBrowser(AVisible: boolean);
begin
  LockWindowUpdate(Handle);
  BrowserPanel.Visible:=AVisible;
  if AVisible then
    Splitter.Left:=BrowserPanel.Left+BrowserPanel.Width;
  Splitter.Visible:=AVisible;
  LockWindowUpdate(0);
end;

procedure TfrmMain.ShowContainer(AVisible: boolean);
begin
  ModulePanel.Visible:=AVisible;
end;

procedure TfrmMain.ShowPeriod;
begin
  if dmExam.Connection.Connected then
    Caption:=Format(rsXMTable+' [%d] [%s] [%s - %s]',
        [dmExam.Year,csSemester[dmExam.Sem],
        DateTimeToStr(dmExam.Period.dbegin),
        DateTimeToStr(dmExam.Period.dend)])
  else Caption:=rsXMTable;
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

procedure TfrmMain.ViewActionExecute(Sender: TObject);
var
  btn: TToolButton;
begin
  case (Sender as TAction).Tag of
    -2:
      begin
        if TAction(Sender).ActionComponent is TToolButton then
        begin
          btn:=TToolButton(TAction(Sender).ActionComponent);
          if Assigned(btn.DropdownMenu) then btn.CheckMenuDropdown;
        end;
      end;

    -1: // update active module
      if Assigned(FModuleManager.ActiveModule) then
        FModuleManager.ActiveModule.UpdateModule;

    1:  // show/hide browser
      ShowBrowser(not BrowserPanel.Visible);

    2:  // exams
      FModuleManager.Show(TfrmExamTable, true);

    3:  // faculty exams
      FModuleManager.Show(TfrmExamList, true);

    4:  // kafedra exans
      FModuleManager.Show(TfrmExamKafedra, true);

    5:  // load auditory
      FModuleManager.Show(TfrmExamAuditory, true);

    else
      raise Exception.CreateFmt('Unknown action (Tag=%d)', [TAction(Sender).Tag]);

  end;
end;

procedure TfrmMain.ViewActionUpdate(Sender: TObject);

begin
  case (Sender as TAction).Tag of

    -2: // view sem
      begin
        TAction(Sender).Enabled:=dmExam.Connection.Connected;
        if dmExam.Sem=1 then
        begin
          TAction(Sender).ImageIndex:=actProjectFirstSem.ImageIndex;
          TAction(Sender).Hint:='Осенний семестр';
        end else
          if dmExam.Sem=2 then
          begin
            TAction(Sender).ImageIndex:=actProjectSecondSem.ImageIndex;
            TAction(Sender).Hint:='Весенний семестр';
          end else TAction(Sender).ImageIndex:=-1;
      end;

    -1: // update active module
      TAction(Sender).Visible:=Assigned(FModuleManager.ActiveModule);

    1: // show/hide browser
      begin
        TAction(Sender).Checked:=BrowserPanel.Visible;
        TAction(Sender).Enabled:=dmExam.Connection.Connected;
      end;

    2,3,4,5:
      TAction(Sender).Enabled:=dmExam.Connection.Connected;

  end
end;

// событие при выделении группы
procedure TfrmMain.OnBrowseChange(Sender: TObject; const Entity: TEntityData);
begin
end;

// событие при смене сем. или п/сем.
procedure TfrmMain.OnChangeTime(Sender: TObject; Flags: WORD);
var
  Msg: TSMChangeTime;
begin
  ShowPeriod;

  ZeroMemory(@Msg, sizeof(TSMChangeTime));

  Msg.Msg:=SM_CHANGETIME;
  Msg.Flags:=Flags;              // признаки изм-ния
  Msg.Year:=dmExam.Year;         // зн-ние года
  Msg.Sem:=dmExam.Sem;           // зн-ние семестра
  Msg.PSem:=dmExam.PSem;         // зн-ние п/семестра

  FBrowser.Dispatch(TMessage(Msg));
  FModuleManager.Broadcast(TMessage(Msg));
end;

procedure TfrmMain.ProjectActionExecute(Sender: TObject);
begin
  case (Sender as TAction).Tag of

    1:  // connect to Database
      LinkDB(true);

    2:  // disconnect from Database
      LinkDB(false);

    3:  // edit link to Database
      if not dmExam.Connection.Connected then
      begin
        if EditConnection(FOptions.Root) then
          dmExam.Connection.ConnectionString:=FOptions.Root.ConnStr;
      end
      else raise Exception.Create('Открыто соединение с БД');

    8:  // change year
      dmExam.ChangeYear;

    else raise Exception.CreateFmt('Unknown action (Tag=%d)', [TAction(Sender).Tag]);
  end;
end;

procedure TfrmMain.ProjectActionUpdate(Sender: TObject);
begin
  case (Sender as TAction).Tag of

    1,  // connect to Database
    3:  // edit link
      TAction(Sender).Enabled:=not dmExam.Connection.Connected;

    2,  // disconnect from Database
    8:  // change year
      TAction(Sender).Enabled:=dmExam.Connection.Connected;

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
  end;
end;

procedure TfrmMain.SemActionExecute(Sender: TObject);
begin
  if not TAction(Sender).Checked then
  begin
    case TAction(Sender).Tag of
      4:  // 1 sem
        dmExam.Sem:=1;
      5:  // 2 sem
        dmExam.Sem:=2;
      else
        raise Exception.CreateFmt('Unknown action (Tag=%d)', [TAction(Sender).Tag]);
    end;
  end;
end;

// обновление эл-тов семестра
procedure TfrmMain.SemActionUpdate(Sender: TObject);
begin
  case (Sender as TAction).Tag of
    4:  // 1 sem
      TAction(Sender).Checked:=(dmExam.Sem=1);
    5:  // 2 sem
      TAction(Sender).Checked:=(dmExam.Sem=2);
    else
      raise Exception.CreateFmt('Unknown action (Tag=%d)', [TAction(Sender).Tag]);
  end; // case
end;

procedure TfrmMain.HelpActionExecute(Sender: TObject);
begin
  case (Sender as TAction).Tag of
    1:  // help topics
      DisplayTopic(HELP_EXAMTABLE);

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
  end;  // procedure DoUpdateHelpModule

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
