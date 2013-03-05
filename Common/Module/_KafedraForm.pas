{
  Модуль упр-ния кафедрами
  v0.2.1
}

unit KafedraForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Modules, DB, ADODB, Grids, DBGrids, ToolWin, ComCtrls, ActnList,
  ModelData;

type
  TfrmKafedrs = class(TModuleForm)
    DBGrid: TDBGrid;
    DataSet: TADODataSet;
    DataSource: TDataSource;
    ToolBar: TToolBar;
    ActionList: TActionList;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }

  protected
    function GetModuleName: string; override;

  public
    { Public declarations }
    procedure UpdateModule; override;
  end;

implementation

uses
  DataModule, ADOInt, SUtils;

{$R *.dfm}

procedure TfrmKafedrs.FormCreate(Sender: TObject);
begin
  if bDebugMode then
    with DBGrid.Columns.Insert(0) as TColumn do
    begin
      FieldName:='kid';
      ReadOnly:=true;
      Width:=50;
    end;
end;

function TfrmKafedrs.GetModuleName: string;
begin
  Result:='Кафедры';
end;

procedure TfrmKafedrs.UpdateModule;
begin
  GetRecordset(dmMain.kaf_GetAll, DataSet);
end;

end.
