{
  Модуль упр-ния кафедрами (DBADMIN)
  v0.0.2a  (09.04.06)
}
unit KafedraForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Modules, DB, ADODB, Grids, DBGrids, ToolWin, ComCtrls, StdCtrls;

type
  TfrmKafedrs = class(TModuleForm)
    DataSource: TDataSource;
    DBGrid: TDBGrid;
    DataSet: TADODataSet;
    DataSetkid: TLargeintField;
    DataSetfid: TIntegerField;
    DataSetkName: TStringField;
    ToolBar: TToolBar;
    cbFaculty: TComboBox;
    lFaculty: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure cbFacultyDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure DataSetfidGetText(Sender: TField; var Text: String;
      DisplayText: Boolean);
    procedure cbFacultyChange(Sender: TObject);
    procedure DBGridEditButtonClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FQuery: string;
    FFacultyList: TStringList; // список факультетов
    fid: integer;              // фильтр
    procedure LoadFaculty;

  protected
    function GetModuleName: string; override;

  public
    { Public declarations }
    procedure UpdateModule; override;

  end;

implementation

uses
  AdminModule, SUtils, SConsts, SDBUtils, StringListDlg;

{$R *.dfm}

{ TfrmKafedrs }

procedure TfrmKafedrs.FormCreate(Sender: TObject);
begin
  FQuery:=SELECT_KAFEDRA;
  FFacultyList:=TStringList.Create;
  fid:=0;
end;

procedure TfrmKafedrs.FormDestroy(Sender: TObject);
begin
  FFacultyList.Free;
  FFacultyList:=nil;
end;

function TfrmKafedrs.GetModuleName: string;
begin
  Result:='Кафедры';
end;

procedure TfrmKafedrs.UpdateModule;
begin
  DataSet.DisableControls;
  try
    DataSet.Filtered:=false;
    LoadFaculty;
    GetRecordset(dmAdmin.OpenQuery(FQuery), DataSet);
    if DataSet.Filter<>'' then DataSet.Filtered:=true;
  finally
    DataSet.EnableControls;
  end;
end;

procedure TfrmKafedrs.cbFacultyDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  FCanvas: TCanvas;
  s: string;
begin
  if Control is TComboBox then
  begin
    FCanvas:=(Control as TComboBox).Canvas;
    TControlCanvas(FCanvas).UpdateTextFlags;
    FCanvas.FillRect(Rect);
    s:=TComboBox(Control).Items[Index];
    if not bDebugMode then s:=GetValue(s);
    FCanvas.TextOut(Rect.Left + 2, Rect.Top, s);
  end;
end;

// загрузка факультетов
procedure TfrmKafedrs.LoadFaculty;
var
  rs: _Recordset;
  s: string;
begin
  FFacultyList.Clear;
  
  rs:=dmAdmin.OpenQuery(SELECT_FACULTY);
  if Assigned(rs) then
  try
    rs.Sort:='fName ASC';
    while not rs.EOF do
    begin
      s:=VarToStr(rs.Fields.Item['fid'].Value)+'='+VarToStr(rs.Fields.Item['fName'].Value);
      FFacultyList.Add(s);
      rs.MoveNext;
    end;
  finally
    rs.Close;
    rs:=nil;
  end;

  cbFaculty.Clear;
  cbFaculty.AddItem('=*',nil);
  cbFaculty.Items.AddStrings(FFacultyList);
  if fid>0 then cbFaculty.ItemIndex:=cbFaculty.Items.IndexOfName(IntToStr(fid))
    else cbFaculty.ItemIndex:=0;
end;

procedure TfrmKafedrs.DataSetfidGetText(Sender: TField; var Text: String;
  DisplayText: Boolean);
var
  i: integer;
begin
  if (not Sender.IsNull) then
  begin
    i:=FFacultyList.IndexOfName(Sender.AsString);
    if i>=0 then
    begin
      if bDebugMode then Text:=FFacultyList[i] else Text:=GetValue(FFacultyList[i])
    end else Text:=Sender.AsString;
  end
  else Text:='(Факультет)';
end;

procedure TfrmKafedrs.cbFacultyChange(Sender: TObject);
var
  id: integer;
begin
  id:=GetID(TComboBox(Sender).Text);
  if id<>fid then
  begin
    fid:=id;
    DataSet.Filtered:=false;
    if fid>0 then
    begin
      DataSet.Filter:=Format('fid=%d',[fid]);
      DataSet.Filtered:=true;
    end else DataSet.Filter:='';
  end;
end;

procedure TfrmKafedrs.DBGridEditButtonClick(Sender: TObject);
var
  Field: TField;
  id: integer;
begin
  if Sender is TDBGrid then
  begin
    Field:=TDBGrid(Sender).SelectedField;
    if Assigned(Field) then
      if AnsiCompareText(Field.FieldName,'fid')=0 then
      begin
        if GetIdFromList(Field.DisplayLabel, Field.AsString, id,
            FFacultyList) then
          if (id>=0) and (Field.Value<>id) then
          begin
            if not (Field.DataSet.State=dsEdit) then Field.DataSet.Edit;
            if id=0 then Field.Clear else Field.Value:=id;
            //if not (Field.DataSet.State=dsInsert) then Field.DataSet.Post;
          end;
      end;
  end;
end;

end.
