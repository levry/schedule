{
  ƒиалог просморта данных
  v0.0.1  (26/09/06)
}
unit RecordsetDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, DBGridEh, DB, ADODB, GridsEh;

type
  TfrmRecordsetDlg = class(TForm)
    DBGridEh: TDBGridEh;
    DataSet: TADODataSet;
    DataSource: TDataSource;
  private
    { Private declarations }
    procedure SetRecordset(Value: _Recordset);
    procedure SetColumns(FieldNames, FieldCaptions: array of string);

  public
    { Public declarations }
  end;

procedure ShowRecordsetDlg(const Caption: string; Recordset: _Recordset;
    FieldNames, FieldCaptions: array of string);

implementation

uses
  SDBUtils;

{$R *.dfm}

procedure ShowRecordsetDlg(const Caption: string; Recordset: _Recordset;
    FieldNames, FieldCaptions: array of string);
var
  frmDlg: TfrmRecordsetDlg;
begin
  Assert(Assigned(Recordset),
    'BF1BE667-9FF5-4787-A683-ABE05844B9FE'#13'ShowRecordsetDlg: Recordset is nil'#13);
  Assert(Length(FieldNames)=Length(FieldCaptions),
    '15C48663-A92C-48A6-BF69-5DCC02B8BF59'#13'ShowRecordsetDlg: FieldNames<>FieldCaptions'#13);


  frmDlg:=TfrmRecordsetDlg.Create(Application);
  try
    frmDlg.Caption:=Caption;
    frmDlg.SetColumns(FieldNames,FieldCaptions);
    frmDlg.SetRecordset(Recordset);
    frmDlg.ShowModal;
  finally
    frmDlg.Free;
  end;
end;  // procedure ShowRecordsetDlg

{ TfrmRecordsetDlg }

// установка колонок дл€ грида  (26/09/06)
procedure TfrmRecordsetDlg.SetColumns(FieldNames,
  FieldCaptions: array of string);
var
  szNames, szCaptions: integer;
  i: integer;
  Column: TColumnEh;
begin
  szNames:=Length(FieldNames);
  szCaptions:=Length(FieldCaptions);
  if szNames=szCaptions then
  begin
    if szNames>0 then
    begin
      DBGridEh.Columns.BeginUpdate;
      try
        DBGridEh.Columns.Clear;
        for i:=0 to szNames-1 do
        begin
          Column:=DBGridEh.Columns.Add;
          Column.FieldName:=FieldNames[i];
          Column.Title.Caption:=FieldCaptions[i];
          Column.AutoFitColWidth:=true;
        end;
      finally
        DBGridEh.Columns.EndUpdate;
      end;
    end;
  end
  else raise Exception.Create('–азмеры массивов дл€ колонок различны');
end;

procedure TfrmRecordsetDlg.SetRecordset(Value: _Recordset);
begin
  GetRecordset(Value,DataSet);
end;

end.
