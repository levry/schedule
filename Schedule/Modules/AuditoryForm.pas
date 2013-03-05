{
  Модуль управления аудиториями
  v0.0.5 (11/08/06)
}

unit AuditoryForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ToolWin, Grids, DBGrids, StdCtrls, DB, Modules,
  ADODB;

type
  TfrmAuditory = class(TModuleForm)
    DBGrid: TDBGrid;
    ToolBar: TToolBar;
    btnPreferAudit: TToolButton;
    cbFaculty: TComboBox;
    Label1: TLabel;
    ToolButton1: TToolButton;
    btnDelAud: TToolButton;
    btnUpdate: TToolButton;
    AuditorySet: TADODataSet;
    DataSource: TDataSource;
    AuditorySetaid: TLargeintField;
    AuditorySetaName: TStringField;
    AuditorySetkid: TLargeintField;
    AuditorySetCapacity: TIntegerField;
    AuditorySetfid: TIntegerField;
    procedure OnBtnsClick(Sender: TObject);
    procedure cbFacultyDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure cbFacultyChange(Sender: TObject);
    procedure AuditorySetkidGetText(Sender: TField; var Text: String;
      DisplayText: Boolean);
    procedure DBGridEditButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure AuditorySetNewRecord(DataSet: TDataSet);
  private
    { Private declarations }
    FKafedraList: TStringList;

    function Get_fid: integer;
    function Get_fName: string;
    function Get_faculty: string;
    procedure Set_faculty(Value: string);

    procedure LoadData;
  protected
    function GetModuleName: string; override;

  public
    { Public declarations }
    property fid: integer read Get_fid;
    property fName: string read Get_fName;
    property faculty: string read Get_faculty write Set_faculty;

    procedure UpdateModule; override;
  end;

implementation

uses
  TimeModule,
  PreferDlg, SUtils, SStrings, StringListDlg, SDBUtils;

{$R *.dfm}

procedure TfrmAuditory.FormCreate(Sender: TObject);
begin
  FKafedraList:=TStringList.Create;

  cbFaculty.Items.AddStrings(dmMain.FacultyList);
  if cbFaculty.Items.Count>0 then cbFaculty.ItemIndex:=0
    else cbFaculty.Enabled:=false;

  if bDebugMode then
    with DBGrid.Columns.Insert(0) as TColumn do
    begin
      FieldName:='aid';
      ReadOnly:=true;
      Width:=50;
    end;
end;

procedure TfrmAuditory.FormDestroy(Sender: TObject);
begin
  FKafedraList.Free;
  FKafedraList:=nil;
end;

function TfrmAuditory.Get_fid: integer;
var
  i: integer;
begin
  i:=cbFaculty.ItemIndex;
  if i>=0 then Result:=GetID(cbFaculty.Items[i]) else Result:=0;
end;

function TfrmAuditory.Get_fName: string;
var
  i: integer;
begin
  i:=cbFaculty.ItemIndex;
  if i>=0 then Result:=SUtils.GetValue(cbFaculty.Items[i]) else Result:='';
end;

function TfrmAuditory.Get_faculty: string;
var
  i: integer;
begin
  i:=cbFaculty.ItemIndex;
  if i>0 then Result:=cbFaculty.Items[i] else Result:='';
end;

procedure TfrmAuditory.Set_faculty(Value: string);
begin
  Assert(Value<>'',
    'A0CFE753-6B8E-4857-8183-955926CC67AF'#13'Set_faculty: Value is empty string'#13);

  if faculty<>Value then
  begin
    cbFaculty.ItemIndex:=cbFaculty.Items.IndexOf(Value);
    LoadData;
  end;
end;

procedure TfrmAuditory.LoadData;
begin
  if fid>0 then
  begin
    dmMain.GetKafedraList(fid,FKafedraList);
    FKafedraList.Insert(0,'=');
    GetRecordset(dmMain.adr_Get_f(fid), AuditorySet);
  end;
end;

// обновление модуля
procedure TfrmAuditory.UpdateModule;
begin
  if cbFaculty.Enabled then LoadData;
end;

function TfrmAuditory.GetModuleName: string;
begin
  Result:='Аудитории';
end;

procedure TfrmAuditory.OnBtnsClick(Sender: TObject);
var
  PreferSet: TADODataSet;
begin

  if (DBGrid.DataSource<>nil) and (DBGrid.DataSource.State<>dsInactive) then
    with DBGrid.DataSource.DataSet do
      case (Sender as TToolButton).Tag of

      1:
        if Active and CanModify and not (EOF and BOF) then
          if MessageDlg('Удалить аудиторию "'+FieldByName('aName').AsString+'"',
            mtConfirmation, mbOKCancel, 0)<>idCancel then Delete;

      2: // редактирование огр-ний
        if not FieldByName('aid').IsNull then
        begin
          PreferSet:=TADODataSet.Create(Self);
          try
            PreferSet.Connection:=dmMain.Connection;
            GetRecordset(dmMain.adr_GetPrefer(FieldByName('aid').AsString), PreferSet);
            ShowPreferDlg(FieldByName('aid').AsString, 'aid', 'Ограничения',
              FieldByName('aName').AsString, PreferSet);
          finally
            PreferSet.Close;
            PreferSet.Free;
          end;
        end;
//          if dmMain.SelectAudPrefer(FieldByName('aid').AsString) then
//          begin
//            ShowPreferDlg(FieldByName('aid').AsString, 'aid', 'Ограничения',
//                FieldByName('aName').AsString, dmMain.spPrefMgm);
//            dmMain.spPrefMgm.Close;
//          end;

      3: // обновление
        UpdateModule;

      end; // case

end;

procedure TfrmAuditory.cbFacultyDrawItem(Control: TWinControl;
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

procedure TfrmAuditory.cbFacultyChange(Sender: TObject);
begin
  if TComboBox(Sender).Text<>'' then LoadData;
end;

procedure TfrmAuditory.AuditorySetkidGetText(Sender: TField; var Text: String;
  DisplayText: Boolean);
var
  i: integer;
begin
  if (not Sender.IsNull) then
  begin
    i:=FKafedraList.IndexOfName(Sender.AsString);
    if i>=0 then
    begin
      if bDebugMode then Text:=FKafedraList[i]
        else Text:=FKafedraList.ValueFromIndex[i]
    end else Text:='Неизвестная кафедра';
  end
  else Text:=rsNull;
end;

procedure TfrmAuditory.DBGridEditButtonClick(Sender: TObject);
var
  Field: TField;
  id: int64;
  s: string;
begin
  if Sender is TDBGrid then
  begin
    Field:=TDBGrid(Sender).SelectedField;
    if Assigned(Field) then
      if AnsiCompareText(Field.FieldName,'kid')=0 then
      begin
        s:=Format('Кафедры (%s)', [fName]);
        if GetIdFromList(s, Field.AsString, id, FKafedraList) then
          if (id>=0) and (Field.Value<>id) then
          begin
            if not (Field.DataSet.State=dsEdit) then Field.DataSet.Edit;
            if id=0 then Field.Clear else Field.Value:=id;
            //if not (Field.DataSet.State=dsInsert) then Field.DataSet.Post;
          end;
      end;
  end;
end;

procedure TfrmAuditory.AuditorySetNewRecord(DataSet: TDataSet);
begin
  if DataSet.State=dsInsert then
    if DataSet.FieldByName('fid').IsNull then
      DataSet.FieldByName('fid').Value:=fid;
end;

end.
