{
  Модуль просмотра заявок на кафедру
  v0.0.3  (15/08/06)
}

unit DeclareForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, DBGrids, Modules, DB, ADODB;

type
  TfrmDeclare = class(TModuleForm)
    DBGrid: TDBGrid;
    DeclareSet: TADODataSet;
    DataSource: TDataSource;
    DeclareSetsbCode: TStringField;
    DeclareSetsbName: TStringField;
    DeclareSetgrName: TStringField;
    DeclareSetTotalHLP: TIntegerField;
    DeclareSetTotalAHLP: TIntegerField;
    DeclareSetCompl: TIntegerField;
    DeclareSetWP1: TWordField;
    DeclareSetl1: TWordField;
    DeclareSetp1: TWordField;
    DeclareSetlb1: TWordField;
    DeclareSetWP2: TWordField;
    DeclareSetl2: TWordField;
    DeclareSetp2: TWordField;
    DeclareSetlb2: TWordField;
    DeclareSetKp: TWordField;
    DeclareSetKr: TWordField;
    DeclareSetRg: TWordField;
    DeclareSetCr: TWordField;
    DeclareSetHr: TWordField;
    DeclareSetKoll: TWordField;
    DeclareSetZ: TWordField;
    DeclareSetE: TWordField;
    DeclareSetHours1: TStringField;
    DeclareSetHours2: TStringField;
    DeclareSetLec: TSmallintField;
    DeclareSetPrc: TSmallintField;
    DeclareSetLab: TSmallintField;
    procedure DeclareSetCalcFields(DataSet: TDataSet);
  private
    { Private declarations }
    fkafedra: string;       // kid=kName;

    function Get_kid: int64;
    function Get_kName: string;
  protected
    function GetModuleName: string; override;
    procedure ModuleHandler(var Msg: TMessage); override;

  public
    { Public declarations }
    procedure UpdateModule; override;
    procedure Open(const akafedra: string);

    property kid: int64 read Get_kid;
    property kName: string read Get_kName;
    property kafedra: string read fkafedra;
  end;

implementation

uses
  TimeModule,
  SConsts, SUtils, STypes, SDBUtils;

{$R *.dfm}

// обновление модуля
procedure TfrmDeclare.UpdateModule;
begin
  if kid>0 then
    if GetRecordset(dmMain.wp_GetDeclare(kid), DeclareSet) then
      DeclareSet.Sort:='sbName ASC, grName ASC';
end;

function TfrmDeclare.GetModuleName: string;
begin
//  Result:=Format('Заявки: %s',[kName]);
  Result:='Заявки';
end;

procedure TfrmDeclare.ModuleHandler(var Msg: TMessage);
begin
  case Msg.Msg of
    SM_CHANGETIME:
      if (TSMChangeTime(Msg).Flags and CT_YEAR)=CT_YEAR then
        TSMChangeTime(Msg).Result:=MRES_DESTROY
      else
        if (TSMChangeTime(Msg).Flags and CT_SEM)=CT_SEM then
        begin
          UpdateModule;
          TSMChangeTime(Msg).Result:=MRES_UPDATE;
        end;

  end;  // case
end;

function TfrmDeclare.Get_kid: int64;
begin
  if fkafedra<>'' then Result:=StrToIntDef(SUtils.GetName(fkafedra),0)
    else Result:=0;
end;

function TfrmDeclare.Get_kName: string;
begin
  if fkafedra<>'' then Result:=SUtils.GetValue(fkafedra)
    else Result:='';
end;

// загрузка заявок на кафедру (кафедра)
procedure TfrmDeclare.Open(const akafedra: string);
begin
  if akafedra<>fkafedra then
  begin
    fkafedra:=akafedra;
    Caption:=Format('Заявки: %s',[kName]);;
    UpdateModule;
  end;
end;

procedure TfrmDeclare.DeclareSetCalcFields(DataSet: TDataSet);
var
  wp1, wp2: integer;
  l1,p1,lb1: integer;
  l2,p2,lb2: integer;
begin
  with DataSet do
  begin
    l1:=FieldByName('l1').AsInteger;
    p1:=FieldByName('p1').AsInteger;
    lb1:=FieldByName('lb1').AsInteger;
    l2:=FieldByName('l2').AsInteger;
    p2:=FieldByName('p2').AsInteger;
    lb2:=FieldByName('lb2').AsInteger;
    FieldByName('Hours1').Value:=SysUtils.Format('%d / %d', [l1,p1+lb1]);
    FieldByName('Hours2').Value:=SysUtils.Format('%d / %d', [l2,p2+lb2]);

    wp1:=FieldByName('WP1').AsInteger;
    wp2:=FieldByName('WP2').AsInteger;
    FieldByName('Lec').Value:=wp1*l1+wp2*l2;
    FieldByName('Prc').Value:=wp1*p2+wp2*l2;
    FieldByName('Lab').Value:=wp1*lb1+wp2*lb2;
  end;
end;

end.
