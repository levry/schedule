{
  Модуль управления должностями
  v0.0.1  (03.04.06)
}

unit PostForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, DBGrids, DB, ADODB, Modules;

type
  TfrmPosts = class(TModuleForm)
    DBGrid: TDBGrid;
    DataSet: TADODataSet;
    DataSource: TDataSource;
    DataSetpid: TAutoIncField;
    DataSetpname: TStringField;
    DataSetpsmall: TStringField;
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

var
  frmPosts: TfrmPosts;

implementation

uses
  AdminModule,
  SDBUtils;

const
  SELECT_POSTS = 'select * from tb_Post';

{$R *.dfm}

procedure TfrmPosts.FormCreate(Sender: TObject);
begin
  FQuery:=SELECT_POSTS;
end;

function TfrmPosts.GetModuleName: string;
begin
  Result:='Должности';
end;

procedure TfrmPosts.UpdateModule;
begin
  GetRecordset(dmAdmin.OpenQuery(FQuery),DataSet);
end;

end.
