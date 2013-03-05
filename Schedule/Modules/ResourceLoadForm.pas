{
  Модуль загрузки ресурсов (преп-ли, аудитории)
  v0.2.0  (6/10/06)
}
unit ResourceLoadForm;

// TODO: Экспорт в excel

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Modules, ExtCtrls, ToolWin, ComCtrls, StdCtrls,
  CheckLst, CustomOptions, Grids, DBGridEh, DB, kbmMemTable, ActnList;

type

  TfrmResLoad = class(TModuleForm)
    ToolBar: TToolBar;
    ListPanel: TPanel;
    cbKafedra: TComboBox;
    lbResList: TCheckListBox;
    Splitter: TSplitter;
    DBGridEh: TDBGridEh;
    DataSet: TkbmMemTable;
    DataSource: TDataSource;
    DataSet_ResID: TLargeintField;
    DataSet_ResName: TStringField;
    DataSet_Division: TStringField;
    DataSet_Hours: TIntegerField;
    ActionList: TActionList;
    actLoadDelete: TAction;
    actLoadDeleteAll: TAction;
    btnLoadDelete: TToolButton;
    btnLoadDeleteAll: TToolButton;
    SaveDialog: TSaveDialog;
    actLoadExport: TAction;
    btnLoadExport: TToolButton;
    procedure cbKafedraDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure lbResListDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure cbKafedraChange(Sender: TObject);
    procedure ResListClickCheck(Sender: TObject);
    procedure ActionsExecute(Sender: TObject);
    procedure ActionsUpdate(Sender: TObject);
    procedure lbResListKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    fkid: int64;

    procedure PrepareCreate;
    procedure Set_kid(value: int64);
    function LoadKafedraList: boolean;
    function LoadResourceList: boolean;
    function ExistsResource(ResID: int64): boolean;
    procedure DoExportTable;

//    procedure ShowResourceList(AVisible: boolean);

  protected
    { Protected declarations }

    procedure ModuleHandler(var Msg: TMessage); override;

    function GetResName: string; virtual; abstract;
    function DoLoadKafedraList: boolean; virtual; abstract;
    function DoLoadResourceList: boolean; virtual; abstract;
    function DoLoadRecord(ResID: int64): boolean; virtual; abstract; // загрузка записи

    function AddRecord(ResID: int64): boolean;        // добавление
    function UpdateCurrentRecord: boolean;            // обновление текущей
    function DeleteRecord(ResID: int64): boolean;     // удаление
    procedure UpdateDataSet;


  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    constructor CreateModule(AOwner: TComponent; AOptions: TCustomOptions); override;

    procedure UpdateModule; override;

  end;

  TfrmAuditoryLoad = class(TfrmResLoad)
  protected
    { Protected declarations }
    function GetModuleName: string; override;
    function GetHelpTopic: string; override;

    function DoLoadKafedraList: boolean; override;
    function DoLoadResourceList: boolean; override;
    function DoLoadRecord(ResID: int64): boolean; override;
    function GetResName: string; override;

  end;

implementation

uses
  ADOInt, Math, Types,
  TimeModule,
  SUtils, STypes, SStrings, SHelp,
  XReport;

{$R *.dfm}


procedure TfrmResLoad.PrepareCreate;
begin
  if not bDebugMode then DBGridEh.Columns[0].Visible:=false;

  DataSet.Open;
  Caption:=GetModuleName();
end;

constructor TfrmResLoad.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  PrepareCreate;
end;

constructor TfrmResLoad.CreateModule(AOwner: TComponent;
    AOptions: TCustomOptions);
begin
  inherited CreateModule(AOwner,AOptions);
  PrepareCreate;
end;

procedure TfrmResLoad.cbKafedraDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  FCanvas: TCanvas;
  s: string;
begin
  if Control is TComboBox then
  begin
    FCanvas:=(Control as TComboBox).Canvas;
    TControlCanvas(FCanvas).UpdateTextFlags;
    s:=(Control as TComboBox).Items[Index];
    if not bDebugMode then s:=GetValue(s);
//{$IF RTLVersion>=15.0}
//    s:=(Control as TComboBox).Items.ValueFromIndex[Index];
//{$ELSE}
//    s:=GetValue((Control as TComboBox).Items[Index]);
//{$IFEND}

    FCanvas.FillRect(Rect);
    FCanvas.TextOut(Rect.Left + 2, Rect.Top, s);
  end;
end;

// загрузка списка кафедр  (6/10/06)
function TfrmResLoad.LoadKafedraList: boolean;
begin
  cbKafedra.Items.BeginUpdate;
  try
    Result:=DoLoadKafedraList();
  finally
    cbKafedra.Items.EndUpdate;
  end;
end;

// проверка на существование ресурса в MemDataSet`е
function TfrmResLoad.ExistsResource(ResID: int64): boolean;
begin
  Result:=(not VarIsNull(DataSet.Lookup('ResID',ResID,'ResID')));
end;

// загрузка списка ресурсов  (6/10/06)
function TfrmResLoad.LoadResourceList: boolean;
var
  i: integer;
begin
  Result:=DoLoadResourceList();
  //Result:=dmMain.GetTeacherList(fkid,lbResList.Items);

  if Result then
  begin
    lbResList.OnClickCheck:=nil;
    for i:=0 to lbResList.Count-1 do
      lbResList.Checked[i]:=(ExistsResource(GetID(lbResList.Items[i])));
    lbResList.OnClickCheck:=ResListClickCheck;
  end;
end;

procedure TfrmResLoad.Set_kid(value: int64);
begin
  if fkid<>Value then
  begin
    fkid:=Value;
    LoadResourceList();
  end;
end;

procedure TfrmResLoad.lbResListDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  FCanvas: TCanvas;
  s: string;
begin
  if Control is TCustomListBox then
  begin
    FCanvas:=(Control as TCustomListBox).Canvas;
    TControlCanvas(FCanvas).UpdateTextFlags;
    s:=(Control as TCustomListBox).Items[Index];
    if not bDebugMode then s:=GetValue(s);
//{$IF RTLVersion>=15.0}
//    s:=(Control as TComboBox).Items.ValueFromIndex[Index];
//{$ELSE}
//    s:=GetValue((Control as TComboBox).Items[Index]);
//{$IFEND}

    FCanvas.FillRect(Rect);
    FCanvas.TextOut(Rect.Left + 2, Rect.Top, s);
  end;
end;

procedure TfrmResLoad.cbKafedraChange(Sender: TObject);
begin
  if TComboBox(Sender).Text<>'' then
    Set_Kid(GetID(TComboBox(Sender).Text));
end;

procedure TfrmResLoad.ModuleHandler(var Msg: TMessage);
begin
  case Msg.Msg of
    SM_CHANGETIME:
      if (TSMChangeTime(Msg).Flags and CT_YEAR)=CT_YEAR then   // изм-ние года
        TSMChangeTime(Msg).Result:=MRES_DESTROY
      else
      begin
        UpdateModule;
        TSMChangeTime(Msg).Result:=MRES_UPDATE;
      end;
  end;  // case
end;

procedure TfrmResLoad.UpdateModule;
begin
  cbKafedra.Enabled:=LoadKafedraList();
  if cbKafedra.Enabled then
  begin
    if fkid<=0 then fkid:=GetID(cbKafedra.Items[0]);
    cbKafedra.ItemIndex:=cbKafedra.Items.IndexOfName(IntToStr(fkid));
    LoadResourceList();
    UpdateDataSet();
  end;
end;

// добавление загрузки в MemDataSet  (06/10/06)
function TfrmResLoad.AddRecord(ResID: int64): boolean;
begin
  DataSet.Append;
  Result:=DoLoadRecord(ResID);
  if Result then DataSet.Post else DataSet.Cancel;
end;

// обновление тек. записи в MemDataSet`е  (06/10/06)
function TfrmResLoad.UpdateCurrentRecord: boolean;
var
  ResID: int64;
begin
  ResID:=DataSet.FieldByName('ResID').Value;

  DataSet.Edit;
  Result:=DoLoadRecord(ResID);
  if Result then DataSet.Post else DataSet.Cancel;
end;

// удаление заргухки в MemDataSet`e
function TfrmResLoad.DeleteRecord(ResID: int64): boolean;
begin
  Result:=DataSet.Locate('ResID',VarArrayOf([ResID]),[loCaseInsensitive]);
  if Result then DataSet.Delete;
end;

{
procedure TfrmResLoad.ShowResourceList(AVisible: boolean);
begin
  LockWindowUpdate(Handle);
  ListPanel.Visible:=AVisible;
  if AVisible then
    Splitter.Left:=ListPanel.Left-Splitter.Width;
  Splitter.Visible:=AVisible;
  LockWindowUpdate(0);
end;
}

procedure TfrmResLoad.ResListClickCheck(Sender: TObject);
var
  ResID: int64;
  s: string;
  index: integer;
begin
  index:=TCustomListBox(Sender).ItemIndex;

  if index>=0 then
  begin
    s:=TCustomListBox(Sender).Items[index];
    ResID:=GetID(s);
    if ExistsResource(ResID) then DeleteRecord(ResID)
      else AddRecord(ResID);
  end;
end;

// обновление MemDataSet`a  (06/10/06)
procedure TfrmResLoad.UpdateDataSet;
begin
  DataSet.DisableControls;
  try
    DataSet.First;
    while not DataSet.Eof do
    begin
      UpdateCurrentRecord;
      DataSet.Next;
    end;
  finally
    DataSet.EnableControls;
  end;
end;

// экспорт таблицы загрузок в формат Excel (6/10/06)
procedure TfrmResLoad.DoExportTable;
begin
  SaveDialog.FileName:=cbKafedra.Items.ValueFromIndex[cbKafedra.ItemIndex];
  if SaveDialog.Execute then
    DoExportDataSet('reports.xlt',SaveDialog.FileName,'loadresource',
      GetModuleName,GetPeriodTitle(dmMain.Sem, dmMain.PSem, dmMain.Year),
      DataSet,['ResName','Division','Hours']);
end;

{ TfrmAuditoryLoad }

function TfrmAuditoryLoad.DoLoadRecord(ResID: int64): boolean;
var
  rs: _Recordset;
begin
  Result:=false;

  rs:=dmMain.sdl_GetLoad_a(ResID);
  if Assigned(rs) then
  try

    Result:=(not rs.EOF);
    if Result then
    begin
      DataSet.FieldByName('ResID').Value:=rs.Fields['aid'].Value;
      DataSet.FieldByName('ResName').Value:=rs.Fields['aName'].Value;
      DataSet.FieldByName('Division').Value:=VarToStrDef(rs.Fields['kName'].Value,
          'Общекафедральная');
      DataSet.FieldByName('Hours').Value:=rs.Fields['hours'].Value;
    end;

  finally
    rs.Close;
    rs:=nil;
  end;
end;

function TfrmAuditoryLoad.DoLoadKafedraList: boolean;
begin
  Result:=dmMain.GetKafedraList(dmMain.FacultyID, cbKafedra.Items);
  cbKafedra.Items.Insert(0,'0=Факультет');
end;

function TfrmAuditoryLoad.DoLoadResourceList: boolean;
begin
  Result:=dmMain.GetAuditoryList(fkid,lbResList.Items);
end;

function TfrmAuditoryLoad.GetModuleName: string;
begin
  Result:='Загрузка аудиторий';
end;

function TfrmAuditoryLoad.GetHelpTopic: string;
begin
  Result:=HELP_TIMETABLE_AUDITORYLOAD;
end;

function TfrmAuditoryLoad.GetResName: string;
begin
  Result:='Аудитория';
end;

procedure TfrmResLoad.ActionsExecute(Sender: TObject);

  procedure DoDeleteItem;
  var
    ResID: string;
    i: integer;
  begin
    ResID:=DataSet.FieldByName('ResID').AsString;
    DataSet.Delete;
    i:=lbResList.Items.IndexOfName(ResID);
    if i>=0 then
    begin
      lbResList.OnClickCheck:=nil;
      lbResList.Checked[i]:=false;
      lbResList.OnClickCheck:=ResListClickCheck;
    end;
  end;

  procedure DoDeleteAll;
  var
    i: integer;
  begin
    LockWindowUpdate(Handle);

    DataSet.EmptyTable;
    lbResList.OnClickCheck:=nil;
    for i:=0 to lbResList.Count-1 do lbResList.Checked[i]:=false;
    lbResList.OnClickCheck:=ResListClickCheck;

    LockWindowUpdate(0);
  end;  // DoDeleteAll


begin
  case (Sender as TAction).Tag of
    1:  // delete
      DoDeleteItem;

    2:  // delete all
      DoDeleteAll;

    3:  // export
      DoExportTable;

    else
      raise Exception.CreateFmt('Unknown action (Tag=%d)', [TAction(Sender).Tag]);
  end;
end;

procedure TfrmResLoad.ActionsUpdate(Sender: TObject);
begin
  case (Sender as TAction).Tag of
    1,  // delete
    2:  // delete all
      with DataSet do
        TAction(Sender).Enabled:=Active and CanModify and not (Bof and Eof);
    3:  // export table
      TAction(Sender).Enabled:=(DataSet.RecordCount>0);
  end;
end;

procedure TfrmResLoad.lbResListKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  i: integer;
  ResID: int64;
begin
  if ((Key=Ord('a')) or (Key=Ord('A'))) and (ssCtrl in Shift) then
    for i:=0 to lbResList.Count-1 do
    begin
      ResID:=GetID(lbResList.Items[i]);
      if not lbResList.Checked[i] then
      begin
        lbResList.Checked[i]:=true;
        AddRecord(ResID);
      end;
    end;
end;

end.
