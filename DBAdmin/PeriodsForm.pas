{
  ќкно просмотра уч.произв. плана (периодов)
  v0.0.1  (17.04.06)
}
unit PeriodsForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, dbcgrids, DB, ADODB, ToolWin, ComCtrls, DBCtrls, StdCtrls, Mask,
  Grids, DBGrids, Tabs;

type
  TfrmPeriods = class(TForm)
    ToolBar: TToolBar;
    DataSet: TADODataSet;
    DataSource: TDataSource;
    DBGrid: TDBGrid;
    DataSetprid: TAutoIncField;
    DataSetynum: TSmallintField;
    DataSetsem: TWordField;
    DataSetptype: TWordField;
    DataSetp_start: TDateTimeField;
    DataSetp_end: TDateTimeField;
    TabSet: TTabSet;
    procedure DBGridEditButtonClick(Sender: TObject);
    procedure DataSetNewRecord(DataSet: TDataSet);
    procedure DataSetGetText(Sender: TField; var Text: String;
      DisplayText: Boolean);
    procedure TabSetChange(Sender: TObject; NewTab: Integer;
      var AllowChange: Boolean);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FYear: smallint;
    FSem: byte;

    procedure Set_Sem(Value: byte);
    procedure Set_Year(Value: smallint);
    procedure LoadData;
  public
    { Public declarations }

    property Year: smallint read FYear write Set_Year;
  end;

implementation

uses
  AdminModule, SStrings, SUtils, SDBUtils,
  StringListDlg;

{$R *.dfm}

{ TfmSemester }

procedure TfrmPeriods.FormCreate(Sender: TObject);
begin
  FYear:=0;
  FSem:=0;
  with DBGrid do
  begin
    Columns[0].Visible:=SUtils.bDebugMode;
    Columns[1].Visible:=SUtils.bDebugMode;
    Columns[2].Visible:=SUtils.bDebugMode;
  end;
end;

// загрузка данных
procedure TfrmPeriods.LoadData;
begin
  GetRecordset(dmAdmin.prd_Get_y(FYear), DataSet);
end;

procedure TfrmPeriods.Set_Sem(Value: byte);
begin
  Assert(Value in [1,2],
    '5AA1583E-1D6F-4332-BB34-F5B99AD5DE7C'#13'Set_Sem: invalid value'#13);
  Assert(DataSet.State=dsBrowse,
    '6F8945B7-F592-4385-B058-FB2236C2A26A'#13'Set_Sem: DataSet in not browse mode'#13);

  if FSem<>Value then
  begin
    FSem:=Value;

    DataSet.DisableControls;
    try
      DataSet.Filtered:=false;
      DataSet.Filter:=Format('sem=%d',[FSem]);
      DataSet.Filtered:=true;
    finally
      DataSet.EnableControls;
    end;
  end;
end;

procedure TfrmPeriods.Set_Year(Value: smallint);
begin
  Assert(Value>0,
    '2955393E-2ED3-4B92-AB88-5D469EC77537'#13'Set_Year: invalid value'#13);

  if FYear<>Value then
  begin
    FYear:=Value;
    FSem:=1;
    TabSet.TabIndex:=0;
    Caption:=Format('ѕлан (%d)',[FYear]);
    LoadData;

    DataSet.DisableControls;
    try
      DataSet.Filtered:=false;
      DataSet.Filter:=Format('sem=%d',[FSem]);
      DataSet.Filtered:=true;
    finally
      DataSet.EnableControls;
    end;
  end;
end;

procedure TfrmPeriods.DBGridEditButtonClick(Sender: TObject);
const
  SEMESTERS = '1=осенний,2=весенний';
  PERIODS = '"1=1 п/семестр","2=2 п/семестр","3=Ёкз. сесси€"';
var
  Field: TField;
  i: integer;
begin
  if Sender is TDBGrid then
  begin
    Field:=TDBGrid(Sender).SelectedField;
    if Assigned(Field) then
      if (Field.IsNull) or (Field.DataSet.State=dsInsert) then
        if AnsiCompareText(Field.FieldName,'sem')=0 then
        begin
          if GetIdFromString(Field.DisplayLabel, '', i, SEMESTERS) then
            if (i>0) and (Field.Value<>i) then
            begin
              if not (Field.DataSet.State=dsEdit) then Field.DataSet.Edit;
              Field.Value:=i;
              //if not (Field.DataSet.State=dsInsert) then Field.DataSet.Post;
            end;
        end else
          if AnsiCompareText(Field.FieldName,'ptype')=0 then
          begin
            if GetIdFromString(Field.DisplayLabel, '', i, PERIODS) then
              if (i>0) and (Field.Value<>i) then
              begin
                if not (Field.DataSet.State=dsEdit) then Field.DataSet.Edit;
                Field.Value:=i;
                //if not (Field.DataSet.State=dsInsert) then Field.DataSet.Post;
              end;
          end
  end;
end;

procedure TfrmPeriods.DataSetNewRecord(DataSet: TDataSet);
begin
  if (DataSet.Active) and (DataSet.State=dsInsert) then
  begin
    if DataSet.FieldByName('ynum').IsNull then
      DataSet.FieldByName('ynum').Value:=FYear;
    if DataSet.FieldByName('sem').IsNull then
      DataSet.FieldByName('sem').Value:=FSem;
  end
end;

procedure TfrmPeriods.DataSetGetText(Sender: TField; var Text: String;
  DisplayText: Boolean);
begin
  if not Sender.IsNull then
  begin
    if AnsiCompareText(Sender.FieldName,'ptype')=0 then
      case Sender.AsInteger of
        1: Text:='1 п/семестр';
        2: Text:='2 п/семестр';
        3: Text:='Ёкз. сесси€';
        else Text:=Sender.AsString;
      end // case
      else
      if AnsiCompareText(Sender.FieldName,'sem')=0 then
        case Sender.AsInteger of
          1:  Text:='ќсенний';
          2:  Text:='¬есенний';
          else Text:=Sender.AsString;
        end;  // case
  end
  else Text:=rsNull;
end;

procedure TfrmPeriods.TabSetChange(Sender: TObject; NewTab: Integer;
  var AllowChange: Boolean);
begin
  if DataSet.State=dsBrowse then Set_Sem(NewTab+1)
    else AllowChange:=false;
end;

end.
