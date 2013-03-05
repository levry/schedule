{
  Главная форма "Рабочий план"
  v0.2.6  (25/01/10)
}                   
unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ExtCtrls, BrowseForm, ToolWin, ActnMan, ActnCtrls,
  ActnMenus, ActnList, StdActns, 
  Modules, ComCtrls, WorkModule, ImgList, StdCtrls, WOptions;

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
    N2: TMenuItem;
    ToolBar: TToolBar;
    btnViewBrowser: TToolButton;
    btnViewGroups: TToolButton;
    actViewGroups: TAction;
    mnuViewGroup: TMenuItem;
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
    actProjectFirstPSem: TAction;
    actProjectSecondPSem: TAction;
    SemMenu: TPopupMenu;
    mnuFirstSem: TMenuItem;
    mnuSecondSem: TMenuItem;
    PSemMenu: TPopupMenu;
    mnuFirstPSem: TMenuItem;
    mnuSecondPSem: TMenuItem;
    btnSem: TToolButton;
    btnPSem: TToolButton;
    ToolButton4: TToolButton;
    actViewSem: TAction;
    actViewPSem: TAction;
    MainImageList: TImageList;
    CaptionLabel: TLabel;
    mnuHelp: TMenuItem;
    StatusBar: TStatusBar;
    actProjectYear: TAction;
    mnuProjectYear: TMenuItem;
    N4: TMenuItem;
    actHelpModule: TAction;
    mnuHelpModule: TMenuItem;
    actHelpTopics: TAction;
    mnuHelpTopics: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ViewActionExecute(Sender: TObject);
    procedure ViewActionUpdate(Sender: TObject);
    procedure ProjectActionExecute(Sender: TObject);
    procedure ProjectActionUpdate(Sender: TObject);
    procedure TabControlChange(Sender: TObject);
    procedure SemActionExecute(Sender: TObject);
    procedure SemActionUpdate(Sender: TObject);
    procedure HelpActionsExecute(Sender: TObject);
    procedure StatusBarResize(Sender: TObject);
    procedure HelpActionsUpdate(Sender: TObject);
  private
    FOptions: TWOptions;

    procedure OnKafedraSelect(Sender: TObject; id: int64; name: string);
    procedure OnGroupSelect(Sender: TObject; id: int64; name: string);
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
    frmBrowser: TfrmBrowser;

    FModuleManager: TModuleManager;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses
  SConsts, SStrings, SUtils, STypes, SHelp,
  GroupForm, WorkplanForm, ConnectEdit,
  SCategory, CustomOptions;

{$R *.dfm}

procedure TfrmMain.FormCreate(Sender: TObject);
var
  category: TClientCategory;
begin
  StatusBar.Panels[1].Text:=SConsts.WPM_VERSION;

  MainImageList.ResourceLoad(rtBitmap, 'MAIN', clFuchsia);

  FOptions:=TWOptions.Create(REG_ROOT, REG_WPM);
  FOptions.LoadSettings;
  category:=FOptions[CAT_WPM] as TClientCategory;
  bDebugMode:=category.Debug;
  Application.HelpFile:=BuildFullName(FOptions.Root.HelpFile);
  dmWork.Sem:=FOptions.Root.Sem;
  dmWork.PSem:=FOptions.Root.PSem;

  frmBrowser:=TfrmBrowser.Create(Self,BrowserPanel);
  frmBrowser.OnKafedraChange:=OnKafedraSelect;
  frmBrowser.OnGroupChange:=OnGroupSelect;
  frmBrowser.Show;

  FModuleManager:=TModuleManager.Create(ModulePanel, FOptions);
  FModuleManager.OnCreateModule:=OnCreateModule;
  FModuleManager.OnDestroyModule:=OnDestroyModule;
  FModuleManager.OnChangeModule:=OnChangeModule;

  Top:=category.Top;
  Left:=category.Left;
  Width:=category.Width;
  Height:=category.Height;

  LinkDB(category.AutoConn);

  dmWork.OnChangeTime:=OnChangeTime;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
var
  category: TClientCategory;
begin
  FModuleManager.Free;
  FModuleManager:=nil;
  frmBrowser.Free;
  frmBrowser:=nil;

  category:=FOptions[CAT_WPM] as TClientCategory;
  category.Top:=Top;
  category.Left:=Left;
  category.Width:=Width;
  category.Height:=Height;

  FOptions.Root.Sem:=dmWork.Sem;
  FOptions.Root.PSem:=dmWork.PSem;

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
    errno:=dmWork.Connect(FOptions.Root.ConnStr);
    if errno=ERROR_CON_VERSION then
      ShowMessage('Неизвестная версия базы.') else
      if errno=ERROR_CON_FAILED then ShowMessage('Ошибка при соединении с базой');
  end
  else dmWork.Connection.Close;

  ShowBrowser(dmWork.Connection.Connected);
  ShowContainer(dmWork.Connection.Connected);
  ShowPeriod;
  if not dmWork.Connection.Connected then
  begin
    //CaptionLabel.Caption:='';
    StatusBar.Panels[2].Text:='';
    frmBrowser.Clear;
    FModuleManager.CloseAll;
  end
  else
    StatusBar.Panels[2].Text:=dmWork.DBName + ' (' + dmWork.VersionAsString + ')';
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
  if dmWork.Connection.Connected then
    Caption:=Format(rsWorkplan+' [%d] [%s] [%d п/семестр]',
        [dmWork.Year,csSemester[dmWork.Sem],dmWork.PSem])
  else Caption:=rsWorkplan;
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
    -2,-3:
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
      //if BrowserPanel.Visible then
      //begin
      //  BrowserPanel.Hide;
      //  Splitter.Hide;
      //end
      //  else
      //  begin
      //    BrowserPanel.Show;
      //    Splitter.Left:=BrowserPanel.Left+BrowserPanel.Width;
      //    Splitter.Show;
      //  end;

    2:  // show module "groups"
      FModuleManager.Show(TfrmGroups, true);
  end;
end;

procedure TfrmMain.ViewActionUpdate(Sender: TObject);

begin
  case (Sender as TAction).Tag of

    -3: // view psem
      begin
        TAction(Sender).Enabled:=dmWork.Connection.Connected;
        if dmWork.PSem=1 then
        begin
          TAction(Sender).ImageIndex:=actProjectFirstPSem.ImageIndex;
          TAction(Sender).Hint:='1 п/семестр';
        end else
          if dmWork.PSem=2 then
          begin
            TAction(Sender).ImageIndex:=actProjectSecondPSem.ImageIndex;
            TAction(Sender).Hint:='2 п/семестр';
          end else TAction(Sender).ImageIndex:=-1;
      end;

    -2: // view sem
      begin
        TAction(Sender).Enabled:=dmWork.Connection.Connected;
        if dmWork.Sem=1 then
        begin
          TAction(Sender).ImageIndex:=actProjectFirstSem.ImageIndex;
          TAction(Sender).Hint:='Осенний семестр';
        end else
          if dmWork.Sem=2 then
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
        TAction(Sender).Enabled:=dmWork.Connection.Connected;
      end;

    2:  // module "groups"
      TAction(Sender).Enabled:=dmWork.Connection.Connected;

  end
end;

// событие при выделении кафедры
procedure TfrmMain.OnKafedraSelect(Sender: TObject; id: int64; name: string);
var
  frmModule: TfrmGroups;
begin
  Assert(id>0,
    '809ABF6E-1558-4FE2-AC11-59A5C957140E'#13'OnKafedraSelect: invalid id'#13);

  frmModule:=FModuleManager.Show(TfrmGroups) as TfrmGroups;
  if Assigned(frmModule) then
  begin
    frmModule.kid:=id;
    OnChangeModule(frmModule);
  end;
//  frmModule:=FModuleManager.FindByClass(TfrmGroups) as TfrmGroups;
//  if not Assigned(frmModule) then
//  begin
//    frmModule:=TfrmGroups.CreateModule(TabControl);
//    frmModule.Parent:=TabControl;
//  end;
//  frmModule.kid:=id;
//  frmModule.Show;
end;

// событие при выделении группы
procedure TfrmMain.OnGroupSelect(Sender: TObject; id: int64; name: string);
var
  frmModule: TfrmWorkplan;
begin
  Assert(id>0,
    'F0A846CA-EB30-4D10-88C1-88A78AF444D2'#13'OnGroupSelect: invalid id'#13);

  frmModule:=FModuleManager.Show(TfrmWorkplan) as TfrmWorkplan;
  if Assigned(frmModule) then
  begin
    frmModule.Open(Format('%d=%s',[id,name]),dmWork.Sem,dmWork.PSem);
    frmModule.Caption:='Рабочий план: '+name;
    OnChangeModule(frmModule);                  // а надо ли ?
  end;
//  frmModule:=FModuleManager.FindByClass(TfrmWorkplan) as TfrmWorkplan;
//  if not Assigned(frmModule) then
//  begin
//    frmModule:=TfrmWorkplan.CreateModule(Application);
//    frmModule.Parent:=TabControl;
//  end;
//  frmModule.grid:=id;
//  frmModule.Caption:='Рабочий план: '+name;
//  frmModule.Show;
end;

// событие при смене сем. или п/сем.
procedure TfrmMain.OnChangeTime(Sender: TObject; Flags: WORD);
var
  Msg: TSMChangeTime;
begin
  ShowPeriod;

  if (Flags and CT_YEAR)=CT_YEAR then frmBrowser.Clear;

  ZeroMemory(@Msg, sizeof(TSMChangeTime));

  Msg.Msg:=SM_CHANGETIME;
  Msg.Flags:=Flags;              // признаки изм-ния
  Msg.Year:=dmWork.Year;         // зн-ние года
  Msg.Sem:=dmWork.Sem;           // зн-ние семестра
  Msg.PSem:=dmWork.PSem;         // зн-ние п/семестра

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
      if not dmWork.Connection.Connected then
      begin
        if EditConnection(FOptions.Root) then
          dmWork.Connection.ConnectionString:=FOptions.Root.ConnStr;
      end
      else raise Exception.Create('Открыто соединение с БД');

    8:  // change year
      dmWork.ChangeYear;

    else raise Exception.CreateFmt('Unknown action (Tag=%d)', [TAction(Sender).Tag]);
  end;
end;

procedure TfrmMain.ProjectActionUpdate(Sender: TObject);
begin
  case (Sender as TAction).Tag of

    1,  // connect to Database
    3:  // edit link
      TAction(Sender).Enabled:=not dmWork.Connection.Connected;

    2,  // disconnect from Database
    8:  // change year
      TAction(Sender).Enabled:=dmWork.Connection.Connected;

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
        dmWork.Sem:=1;
      5:  // 2 sem
        dmWork.Sem:=2;
      6:  // 1 psem
        dmWork.PSem:=1;
      7:  // 2 psem
        dmWork.PSem:=2;
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
      TAction(Sender).Checked:=(dmWork.Sem=1);
    5:  // 2 sem
      TAction(Sender).Checked:=(dmWork.Sem=2);
    6:  // 1 psem
      TAction(Sender).Checked:=(dmWork.PSem=1);
    7:  // 2 psem
      TAction(Sender).Checked:=(dmWork.PSem=2);
    else
      raise Exception.CreateFmt('Unknown action (Tag=%d)', [TAction(Sender).Tag]);
  end; // case
end;

procedure TfrmMain.HelpActionsExecute(Sender: TObject);
begin
  case (Sender as TAction).Tag of
    1:  // help topics
      DisplayTopic(HELP_WORKPLAN);

    2:  // help of module
      if Assigned(FModuleManager.ActiveModule) then
        FModuleManager.ActiveModule.DoHelp;

    else
      raise Exception.CreateFmt('Unknown action (Tag=%d)', [TAction(Sender).Tag]);
  end;  // case
end;

procedure TfrmMain.HelpActionsUpdate(Sender: TObject);

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
  end;

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
