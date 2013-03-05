{
  Модуль управления учебными годами
  v0.0.1  (15.04.06)
}
unit YearsForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Modules, DB, Grids, DBGrids, ADODB, ComCtrls, ToolWin, PeriodsForm,
  ExtCtrls;

type
  TfrmYears = class(TModuleForm)
    ToolBar: TToolBar;
    DBGrid: TDBGrid;
    YearSet: TADODataSet;
    YearSource: TDataSource;
    YearSetynum: TSmallintField;
    procedure FormCreate(Sender: TObject);
    procedure YearSetAfterScroll(DataSet: TDataSet);
  private
    { Private declarations }
    FQuery: string;
    FPeriodsForm: TfrmPeriods;

  protected
    function GetModuleName: string; override;

  public
    { Public declarations }
    procedure UpdateModule; override;

  end;

implementation

uses
  AdminModule, SConsts, SDBUtils;


{$R *.dfm}

{ TfrmYear }

procedure TfrmYears.FormCreate(Sender: TObject);
begin
  FQuery:=SELECT_YEARS;

  FPeriodsForm:=TfrmPeriods.Create(Self);
  FPeriodsForm.Parent:=Self;
  FPeriodsForm.Left:=Width-FPeriodsForm.Width-20;
  FPeriodsForm.Top:=Height-FPeriodsForm.Height-20;
  FPeriodsForm.Anchors:=[akRight,akBottom];
  FPeriodsForm.Show;
end;

function TfrmYears.GetModuleName: string;
begin
  Result:='Учебный год';
end;

procedure TfrmYears.UpdateModule;
begin
  GetRecordset(dmAdmin.OpenQuery(FQuery),YearSet);
end;

procedure TfrmYears.YearSetAfterScroll(DataSet: TDataSet);
begin
  if DataSet.Active then
    if not DataSet.FieldByName('ynum').IsNull then
      FPeriodsForm.Year:=DataSet.FieldByName('ynum').AsInteger;
end;

end.
