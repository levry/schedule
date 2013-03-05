{
  Главная форма "DBAdmin"
  v0.0.1  (03.04.06)
}
unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ActnList, ComCtrls, Modules, ExtCtrls, StdCtrls, Menus, StdActns,
  ToolWin, AOptions, ImgList;

type
  TfrmMain = class(TForm)
    ActionList: TActionList;
    StatusBar: TStatusBar;
    actProjectConnect: TAction;
    actProjectDisconnect: TAction;
    actProjectEditLink: TAction;
    ModulePanel: TPanel;
    TabControl: TTabControl;
    CaptionLabel: TLabel;
    MainMenu: TMainMenu;
    ProjectMnu: TMenuItem;
    mnuProjectConnect: TMenuItem;
    mnuProjectDisconnect: TMenuItem;
    mnuProjectEditLink: TMenuItem;
    actProjectExit: TFileExit;
    N1: TMenuItem;
    mnuProjectExit: TMenuItem;
    actViewPosts: TAction;
    mnuBooks: TMenuItem;
    mnuBookPosts: TMenuItem;
    mnuHelp: TMenuItem;
    actViewUpdate: TAction;
    ToolBar: TToolBar;
    btnProjectConnect: TToolButton;
    btnProjectDisconect: TToolButton;
    btnProjectEditLink: TToolButton;
    ToolButton4: TToolButton;
    btnViewPosts: TToolButton;
    btnViewUpdate: TToolButton;
    actViewFaculty: TAction;
    mnuBookFaculty: TMenuItem;
    btnViewFaculty: TToolButton;
    actServiceImportSchema: TAction;
    mnuService: TMenuItem;
    actServiceImportSchema1: TMenuItem;
    actViewKafedra: TAction;
    mnuBookKafedra: TMenuItem;
    btnViewKafedra: TToolButton;
    actViewYears: TAction;
    mnuServiceYears: TMenuItem;
    actViewSubject: TAction;
    mnuBookSubject: TMenuItem;
    btnViewSubject: TToolButton;
    ImageList: TImageList;
    procedure ProjectExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ProjectUpdate(Sender: TObject);
    procedure StatusBarResize(Sender: TObject);
    procedure ViewExecute(Sender: TObject);
    procedure ViewUpdate(Sender: TObject);
    procedure TabControlChange(Sender: TObject);
    //procedure HelpExecute(Sender: TObject);
    procedure ServiceExecute(Sender: TObject);
    procedure ServiceUpdate(Sender: TObject);
  private
    { Private declarations }
    FOptions: TAOptions;
    FModuleManager: TModuleManager;

    procedure LinkDB(AConnect: boolean);
    procedure ShowContainer(AVisible: boolean);

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
  AdminModule, SConsts, SStrings, SUtils, SCategory, ConnectEdit,
  PostForm, FacultyForm, KafedraForm, YearsForm, SubjectForm,
  ImportSchema;

const
  CONNECTION_STRING = 'FILE NAME=link.udl';

{$R *.dfm}

procedure TfrmMain.FormCreate(Sender: TObject);
var
  category: TWindowCategory;
begin
  StatusBar.Panels[1].Text:=SConsts.DBA_VERSION;

  FOptions:=TAOptions.Create(REG_ROOT, REG_DBADMIN);
  FOptions.LoadSettings;
  category:=FOptions[CAT_DBADMIN] as TWindowCategory;
  bDebugMode:=category.Debug;

  Left:=category.Left;
  Top:=category.Top;
  Height:=category.Height;
  Width:=category.Width;

  FModuleManager:=TModuleManager.Create(ModulePanel, FOptions);
  FModuleManager.OnCreateModule:=OnCreateModule;
  FModuleManager.OnDestroyModule:=OnDestroyModule;
  FModuleManager.OnChangeModule:=OnChangeModule;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
var
  category: TWindowCategory;
begin
  FModuleManager.Free;
  FModuleManager:=nil;

  category:=FOptions[CAT_DBADMIN] as TWindowCategory;
  category.Top:=Top;
  category.Left:=Left;
  category.Height:=Height;
  category.Width:=Width;

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
    errno:=dmAdmin.Connect(FOptions.Root.ConnStr);
    if errno=ERROR_CON_VERSION then
      ShowMessage('Неизвестная версия базы.') else
      if errno=ERROR_CON_FAILED then ShowMessage('Ошибка при соединении с базой');
  end
  else dmAdmin.Connection.Close;

//  ShowBrowser(dmAdmin.Connection.Connected);
  ShowContainer(dmAdmin.Connection.Connected);
  if not dmAdmin.Connection.Connected then
  begin
    //CaptionLabel.Caption:='';
    StatusBar.Panels[2].Text:='';
    FModuleManager.CloseAll;
  end
  else
    StatusBar.Panels[2].Text:=dmAdmin.DBName+' ('+dmAdmin.VersionAsString+')';
end;


procedure TfrmMain.ProjectExecute(Sender: TObject);
begin
  case (Sender as TAction).Tag of
    1:  // connect
      LinkDB(true);
    2:  // disconnect
      LinkDB(false);
    3:  // edit link
      if not dmAdmin.Connection.Connected then
      begin
        if EditConnection(FOptions.Root) then
          dmAdmin.Connection.ConnectionString:=FOptions.Root.ConnStr;
      end
      else raise Exception.Create('Открыто соединение с БД');

    else
      raise Exception.CreateFmt('Unknown action (Tag=%d)', [TAction(Sender).Tag]);
  end;  // case(Tag)
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

procedure TfrmMain.ShowContainer(AVisible: boolean);
begin
  ModulePanel.Visible:=AVisible;
end;

procedure TfrmMain.ProjectUpdate(Sender: TObject);
begin
  case (Sender as TAction).Tag of

    1:  // connect
      TAction(Sender).Enabled:=not dmAdmin.Connection.Connected;

    2:  // disconnect
      TAction(Sender).Enabled:=dmAdmin.Connection.Connected;

    3:  // edit link
      TAction(Sender).Enabled:=not dmAdmin.Connection.Connected;

    else
      raise Exception.CreateFmt('Unknown action (Tag=%d)', [TAction(Sender).Tag]);
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

procedure TfrmMain.ViewExecute(Sender: TObject);
begin
  case (Sender as TAction).Tag of

    -1: // update module
      if Assigned(FModuleManager.ActiveModule) then
        FModuleManager.ActiveModule.UpdateModule;

    1:  // posts
      FModuleManager.Show(TfrmPosts, true);

    2:  // faculties
      FModuleManager.Show(TfrmFaculty, true);

    3:  // kafedries
      FModuleManager.Show(TfrmKafedrs, true);

    4:  // years
      FModuleManager.Show(TfrmYears, true);

    5:  // subjects
      FModuleManager.Show(TfrmSubjects, true);

    else
      raise Exception.CreateFmt('Unknown action (Tag=%d)', [TAction(Sender).Tag]);
  end;  // case(Tag)
end;

procedure TfrmMain.ViewUpdate(Sender: TObject);
begin
  case (Sender as TAction).Tag of

    -1: // update module
      TAction(Sender).Enabled:=Assigned(FModuleManager.ActiveModule);

    else
      TAction(Sender).Enabled:=dmAdmin.Connection.Connected;

  end;  // case(Tag)
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

//procedure TfrmMain.HelpExecute(Sender: TObject);
//begin
//  case (Sender as TAction).Tag of
//
//
//    else
//      raise Exception.CreateFmt('Unknown action (Tag=%d)', [TAction(Sender).Tag]);
//  end;  // case(Tag)
//end;

procedure TfrmMain.ServiceExecute(Sender: TObject);
begin
  case (Sender as TAction).Tag of

    1:  // import schema
      ShowImportSchemaDlg();

    else
      raise Exception.CreateFmt('Unknown action (Tag=%d)', [TAction(Sender).Tag]);

  end;  // case(Tag)
end;

procedure TfrmMain.ServiceUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled:=dmAdmin.Connection.Connected;
end;

end.
