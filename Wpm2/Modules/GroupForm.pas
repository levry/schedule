{
  Модуль упр-ния группами
  v0.2.3  (14/09/06)
}

unit GroupForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Modules, ToolWin, ComCtrls, Grids, DBGrids, DB, ADODB, StdCtrls;

type
  TfrmGroups = class(TModuleForm)
    DBGrid: TDBGrid;
    ToolBar: TToolBar;
    GroupSet: TADODataSet;
    DataSource: TDataSource;
    Label1: TLabel;
    cbKafedra: TComboBox;
    GroupSet_grid: TLargeintField;
    GroupSet_kid: TLargeintField;
    GroupSet_grName: TStringField;
    GroupSet_studs: TSmallintField;
    GroupSet_course: TWordField;
    GroupSet_ynum: TSmallintField;
    procedure OnDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure ComboChange(Sender: TObject);
    procedure GroupSetkidGetText(Sender: TField; var Text: String;
      DisplayText: Boolean);
    procedure DBGridEditButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure GroupSetNewRecord(DataSet: TDataSet);
  private
    { Private declarations }
    fkid: int64;

    procedure Set_kid(Value: int64);
    function LoadKafedrs: boolean;

  protected
    function GetModuleName: string; override;
    procedure ModuleHandler(var Msg: TMessage); override;
    function GetHelpTopic: string; override;

  public
    { Public declarations }
    procedure UpdateModule; override;

    property kid: int64 read fkid write Set_kid;
  end;

implementation

uses
  ADOInt,
  WorkModule, SDBUtils, SUtils, STypes, SHelp, StringListDlg;

{$R *.dfm}

procedure TfrmGroups.FormCreate(Sender: TObject);
begin
  if bDebugMode then
    with DBGrid.Columns.Insert(0) as TColumn do
    begin
      FieldName:='grid';
      ReadOnly:=true;
      Width:=50;
    end;  // with
end;

function TfrmGroups.GetModuleName: string;
begin
  Result:='Группы';
end;

procedure TfrmGroups.ModuleHandler(var Msg: TMessage);
begin
  case Msg.Msg of
    SM_CHANGETIME:  // смена п/сем,сем,года
      if (TSMChangeTime(Msg).Flags and CT_YEAR)=CT_YEAR then
        TSMChangeTime(Msg).Result:=MRES_DESTROY;
  end;
end;

function TfrmGroups.GetHelpTopic: string;
begin
  Result:=HELP_WORKPLAN_GROUP;
end;

procedure TfrmGroups.Set_kid(Value: int64);
var
  i: integer;
begin
  Assert(Value>0,
    '2621A568-0067-425F-A7B7-884124C7A0FE'#13'TfrmGroup.SetKid: Value is invalid'#13);

  if fkid<>Value then
  begin
    if not (cbKafedra.Items.Count>0) then LoadKafedrs;
    fkid:=Value;
    i:=cbKafedra.Items.IndexOfName(IntToStr(fkid));
    cbKafedra.ItemIndex:=i;
    Caption:='Группы: '+cbKafedra.Items.ValueFromIndex[i];
    GetRecordset(dmWork.grp_Get_k(fkid), GroupSet);
  end;
end;

// загрузка кафедр
function TfrmGroups.LoadKafedrs: boolean;
var
  s: string;
  rs: _Recordset;
begin
  Result:=false;

//  rs:=dmMain.dbv_GetKaf;
  rs:=dmWork.dbv_GetFacultyKaf(dmWork.FacultyID);
  try
    if (rs.State and adStateOpen)=1 then
      if rs.RecordCount>0 then
      begin
        cbKafedra.Clear;
        while not rs.EOF do
        begin
          s:=string(rs.Fields.Item['kid'].Value)+'='+string(rs.Fields.Item['kName'].Value);
          cbKafedra.Items.Add(s);
          rs.MoveNext;
        end; // while
        Result:=(cbKafedra.Items.Count>0);
      end
  finally
    if Assigned(rs) then
    begin
      rs.Close;
      rs:=nil;
    end;
  end;
  cbKafedra.Enabled:=Result;
end;

procedure TfrmGroups.UpdateModule;
var
  i: integer;
begin
  if LoadKafedrs then
  begin
    if not (fkid>0) then fkid:=StrToInt(cbKafedra.Items.Names[0]);
    i:=cbKafedra.Items.IndexOfName(IntToStr(fkid));
    cbKafedra.ItemIndex:=i;
    Caption:='Группы: '+cbKafedra.Items.ValueFromIndex[i];
    GetRecordset(dmWork.grp_Get_k(fkid), GroupSet);
  end;
end;

procedure TfrmGroups.OnDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  FCanvas: TCanvas;
  s: string;
begin
  if Control is TComboBox then
  begin
    FCanvas:=(Control as TComboBox).Canvas;
    TControlCanvas(FCanvas).UpdateTextFlags;
    s:=TComboBox(Control).Items[Index];
    if not bDebugMode then s:=SUtils.GetValue(s);
//{$IF RTLVersion>=15.0}
//    s:=(Control as TComboBox).Items.ValueFromIndex[Index];
//{$ELSE}
//    s:=GetValue((Control as TComboBox).Items[Index]);
//{$IFEND}

    FCanvas.FillRect(Rect);
    FCanvas.TextOut(Rect.Left + 2, Rect.Top, s);
  end;
end;

procedure TfrmGroups.ComboChange(Sender: TObject);
var
  n: int64;
begin
  if TComboBox(Sender).Text<>'' then
  begin
    n:=GetID(TComboBox(Sender).Text);
    if n>0 then Set_kid(n);
  end;
end;

procedure TfrmGroups.GroupSetkidGetText(Sender: TField; var Text: String;
  DisplayText: Boolean);
var
  i: integer;
begin
  if Assigned(Sender) and (not Sender.IsNull) then
  begin
    i:=cbKafedra.Items.IndexOfName(Sender.AsString);
    if i>=0 then
    begin
      if bDebugMode then Text:=cbKafedra.Items[i]
        else Text:=cbKafedra.Items.ValueFromIndex[i]
    end  else Text:='Неизвестная кафедра';
  end;
end;

procedure TfrmGroups.DBGridEditButtonClick(Sender: TObject);
var
  Field: TField;
  kid: int64;
  s: string;
begin
  if Sender is TDBGrid then
  begin
    Field:=TDBGrid(Sender).SelectedField;
    if Assigned(Field) then
      if AnsiCompareText(Field.FieldName,'kid')=0 then
      begin
        if Field.IsNull then s:=SUtils.GetName(cbKafedra.Text)
          else s:=Field.AsString;

        if GetIdFromList('Кафедра',s,kid,cbKafedra.Items) then
          if (kid>0) and (Field.Value<>kid) then
          begin
            if not (Field.DataSet.State=dsEdit) then Field.DataSet.Edit;
            Field.Value:=kid;
            if not (Field.DataSet.State=dsInsert) then Field.DataSet.Post;
          end;

      end;
  end;
end;

procedure TfrmGroups.GroupSetNewRecord(DataSet: TDataSet);
begin
  if (DataSet.Active) and (DataSet.State=dsInsert) then
  begin
    if DataSet.FieldByName('ynum').IsNull then
      DataSet.FieldByName('ynum').Value:=dmWork.Year;
  end;
end;

end.
