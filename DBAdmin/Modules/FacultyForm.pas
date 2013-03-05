{
  Модуль управления факультетами
  v0.0.1  (03.04.06)
}

unit FacultyForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, DBGrids, DB, ADODB, Modules;

type
  TfrmFaculty = class(TModuleForm)
    DataSource: TDataSource;
    DBGrid: TDBGrid;
    DataSet: TADODataSet;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FQuery: string;

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

procedure TfrmFaculty.FormCreate(Sender: TObject);
begin
  FQuery:=SELECT_FACULTY;
end;

function TfrmFaculty.GetModuleName: string;
begin
  Result:='Факультеты';
end;

procedure TfrmFaculty.UpdateModule;
begin
  GetRecordset(dmAdmin.OpenQuery(FQuery), DataSet);
end;

end.
