{
  Главная форма "WImport"
  v0.0.4  (25/01/10)
}
unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, WIOptions, ComCtrls, Menus, ActnList, StdActns, DB, kbmMemTable,
  ExtCtrls, Grids, DBGrids, DBGridEh, Tabs, ImgList, ToolWin, GridsEh;

type
  TfrmMain = class(TForm)
    StatusBar: TStatusBar;
    MainMenu: TMainMenu;
    ActionList: TActionList;
    actProjectConnect: TAction;
    actProjectDisconnect: TAction;
    actProjectEditLink: TAction;
    actProjectExit: TFileExit;
    mnuProject: TMenuItem;
    mnuProjectConnect: TMenuItem;
    mnuProjectDisconnect: TMenuItem;
    mnuProjectEditLink: TMenuItem;
    mnuProjectDivider: TMenuItem;
    mnuProjectExit: TMenuItem;
    mnuHelp: TMenuItem;
    actProcessLoad: TAction;
    actProcessCheck: TAction;
    actProcessImport: TAction;
    mnuProcess: TMenuItem;
    mnuProcessOpen: TMenuItem;
    mnuProcessCheck: TMenuItem;
    mnuProcessImport: TMenuItem;
    VerticalSplitter: TSplitter;
    GroupGrid: TDBGridEh;
    WorkplanGrid: TDBGridEh;
    GroupPanel: TPanel;
    WorkplanPanel: TPanel;
    SemTabSet: TTabSet;
    LogPanel: TPanel;
    LogGrid: TDBGridEh;
    HorizontalSplitter: TSplitter;
    ImageList: TImageList;
    ToolBar: TToolBar;
    btnProjectConnect: TToolButton;
    btnProjectDisconnect: TToolButton;
    ToolButton3: TToolButton;
    btnProcessLoad: TToolButton;
    btnProcessCheck: TToolButton;
    btnProcessImport: TToolButton;
    LogImageList: TImageList;
    actProcessClear: TAction;
    ToolButton1: TToolButton;
    btnProcessClear: TToolButton;
    mnuProcessDivider: TMenuItem;
    mnuProcessClear: TMenuItem;
    actHelpTopics: TAction;
    N2: TMenuItem;
    actProcessSchema: TAction;
    mnuProcessSchema: TMenuItem;
    procedure ProjectExecute(Sender: TObject);
    procedure ProjectUpdate(Sender: TObject);
    procedure StatusBarResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure HelpExecute(Sender: TObject);
    procedure ProcessExecute(Sender: TObject);
    procedure SemTabSetChange(Sender: TObject; NewTab: Integer;
      var AllowChange: Boolean);
    procedure ProcessUpdate(Sender: TObject);
    procedure GroupGridEditButtonClick(Sender: TObject);
    procedure WorkplanGridEditButtonClick(Sender: TObject);
    procedure GridGetCellParams(Sender: TObject; Column: TColumnEh;
      AFont: TFont; var Background: TColor; State: TGridDrawState);
    procedure LogGridDblClick(Sender: TObject);
    procedure HelpUpdate(Sender: TObject);
  private
    { Private declarations }
    FOptions: TWIOptions;
    FNullColor: TColor;
    FErrorColor: TColor;

    procedure LinkDB(AConnect: boolean);

  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses
  ImportModule, SConsts, SCategory, SUtils, SStrings, SHelp,
  ConnectEdit, DataSchemaDlg;

{$R *.dfm}

{ TfrmMain }

procedure TfrmMain.FormCreate(Sender: TObject);

  procedure VisibleAllFields(AVisible: boolean);
  var
    i: integer;
  begin
    if AVisible then
    begin
      for i:=0 to GroupGrid.Columns.Count-1 do
        GroupGrid.Columns[i].Visible:=true;
      for i:=0 to WorkplanGrid.Columns.Count-1 do
        WorkplanGrid.Columns[i].Visible:=true;
      for i:=0 to LogGrid.Columns.Count-1 do
        LogGrid.Columns[i].Visible:=true;
    end;
  end;

var
  category: TWindowCategory;

begin
  StatusBar.Panels[1].Text:=SConsts.WIM_VERSION;

  FOptions:=TWIOptions.Create(REG_ROOT, REG_WIMPORT);
  FOptions.LoadSettings;
  category:=FOptions[CAT_WIMPORT] as TWindowCategory;
  bDebugMode:=category.Debug;
  Application.HelpFile:=BuildFullName(FOptions.Root.HelpFile);

  with FOptions[CAT_COLORS] as TColorCategory do
  begin
    FNullColor:=NullColor;
    FErrorColor:=ErrorColor;
  end;

  VisibleAllFields(bDebugMode);

  Left:=category.Left;
  Top:=category.Top;
  Height:=category.Height;
  Width:=category.Width;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
var
  category: TWindowCategory;
begin
  category:=FOptions[CAT_WIMPORT] as TWindowCategory;
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
    errno:=dmImport.Connect(FOptions.Root.ConnStr);
    if errno=ERROR_CON_VERSION then
      ShowMessage('Неизвестная версия базы.') else
      if errno=ERROR_CON_FAILED then ShowMessage('Ошибка при соединении с базой');
  end
  else dmImport.Connection.Close;

//  ShowBrowser(dmAdmin.Connection.Connected);
//  ShowContainer(dmAdmin.Connection.Connected);
  if not dmImport.Connection.Connected then
  begin
    StatusBar.Panels[2].Text:='';
    //FModuleManager.CloseAll;
  end
  else
    StatusBar.Panels[2].Text:=dmImport.DBName+' ('+dmImport.VersionAsString+')';
end;

procedure TfrmMain.ProjectExecute(Sender: TObject);
begin
  case (Sender as TAction).Tag of
    1:  // connect
      LinkDB(true);
    2:  // disconnect
      LinkDB(false);
    3:  // edit link
      if not dmImport.Connection.Connected then
      begin
        if EditConnection(FOptions.Root) then
          dmImport.Connection.ConnectionString:=FOptions.Root.ConnStr;
      end
      else raise Exception.Create('Открыто соединение с БД');

    else
      raise Exception.CreateFmt('Unknown action (Tag=%d)', [TAction(Sender).Tag]);
  end;  // case(Tag)
end;

procedure TfrmMain.ProjectUpdate(Sender: TObject);
begin
  case (Sender as TAction).Tag of
    1:  // connect
      TAction(Sender).Enabled:=not dmImport.Connection.Connected;

    2:  // disconnect
      TAction(Sender).Enabled:=dmImport.Connection.Connected;

    3:  // edit link
      TAction(Sender).Enabled:=not dmImport.Connection.Connected;

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

procedure TfrmMain.HelpExecute(Sender: TObject);
begin
  case (Sender as TAction).Tag of
    1:  // help topics
      DisplayTopic(HELP_WORKPLAN_IMPORT);

    else
      raise Exception.CreateFmt('Unknown action (Tag=%d)', [TAction(Sender).Tag]);
  end;  // case(Tag)
end;

procedure TfrmMain.HelpUpdate(Sender: TObject);
begin
  case (Sender as TAction).Tag of
    1:  // help topics
      TAction(Sender).Visible:=(Application.HelpFile<>'');
  end;
end;

procedure TfrmMain.ProcessExecute(Sender: TObject);
begin
  case (Sender as TAction).Tag of
    1:  // open file
      dmImport.DoLoadData(FOptions[CAT_WIMPORT] as TImportCategory);

    2:  // check data
      dmImport.DoCheckData;

    3:  // import data
      dmImport.DoImportData;

    4:  // clear data
      dmImport.DoClearData;

    5:  // edit data schema
      EditXLSchema(FOptions[CAT_WIMPORT] as TImportCategory);
      
    else
      raise Exception.CreateFmt('Unknown action (Tag=%d)', [TAction(Sender).Tag]);
  end;  // case
end;

procedure TfrmMain.ProcessUpdate(Sender: TObject);
begin
  case (Sender as TAction).Tag of

    2:  // check data
      TAction(Sender).Enabled:=(dmImport.Connection.Connected and not dmImport.GroupTable.IsEmpty);

    3:  // import data
      TAction(Sender).Enabled:=dmImport.IsChecked;

    4:  // clear data
      TAction(Sender).Enabled:=not dmImport.GroupTable.IsEmpty;

    else
      raise Exception.CreateFmt('Unknown action (Tag=%d)', [TAction(Sender).Tag]);
  end;
end;

procedure TfrmMain.SemTabSetChange(Sender: TObject; NewTab: Integer;
  var AllowChange: Boolean);
begin
  dmImport.Sem:=NewTab+1;
  AllowChange:=(dmImport.Sem=(NewTab+1));
end;

procedure TfrmMain.GroupGridEditButtonClick(Sender: TObject);
var
  Field: TField;
begin
  if dmImport.Connection.Connected then
  begin
    Field:=TDBGridEh(Sender).SelectedField;
    if not Field.DataSet.FieldByName('grName').IsNull then
      if AnsiCompareText(TDBGridEh(Sender).SelectedField.FieldName,'kName')=0 then
        dmImport.ChangeKafedra(TDBGridEh(Sender).SelectedField.DataSet);
  end;
end;

procedure TfrmMain.WorkplanGridEditButtonClick(Sender: TObject);
var
  Field: TField;
begin
  if dmImport.Connection.Connected then
  begin
    Field:=TDBGridEh(Sender).SelectedField;
    if not Field.DataSet.FieldByName('grName').IsNull then
      if AnsiCompareText(Field.FieldName,'kName')=0 then dmImport.ChangeKafedra(Field.DataSet) else
        if AnsiCompareText(Field.FieldName,'sbName')=0 then dmImport.ChangeSubject(Field.DataSet);
  end;
end;

procedure TfrmMain.GridGetCellParams(Sender: TObject;
  Column: TColumnEh; AFont: TFont; var Background: TColor;
  State: TGridDrawState);
var
  ds: TDataSet;
  field: TField;
begin
  field:=nil;
  ds:=Column.Field.DataSet;

  if AnsiCompareText(Column.FieldName,'kName')=0 then field:=ds.FieldByName('kid') else
    if AnsiCompareText(Column.FieldName,'sbName')=0 then field:=ds.FieldByName('sbid') else
    if AnsiCompareText(Column.FieldName,'grName')=0 then
    begin
      field:=ds.FieldByName('grid');
      if field.IsNull then Background:=FNullColor else
        if field.AsInteger>0 then Background:=FErrorColor;
      field:=nil;
    end else
    if AnsiCompareText(Column.FieldName,'ynum')=0 then field:=ds.FieldByName('chkyear');

  if Assigned(field) then
    if field.IsNull then Background:=FNullColor else
      if integer(field.Value)=0 then Background:=FErrorColor;
end;

procedure TfrmMain.LogGridDblClick(Sender: TObject);
begin
  dmImport.DoLocateLog;
  SemTabSet.TabIndex:=dmImport.Sem-1;
end;

end.
