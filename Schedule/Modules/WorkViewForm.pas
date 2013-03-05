{
  Модуль просмотра рабочего плана
  v0.0.6  (15/08/06)
}
unit WorkViewForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, DBGrids, TimeModule, Modules, DB, ADODB, SConsts;

type
  TfrmWorkView = class(TModuleForm)
    DBGrid: TDBGrid;
    WorkplanSet: TADODataSet;
    DataSource: TDataSource;
    WorkplanSetsbCode: TStringField;
    WorkplanSetsbName: TStringField;
    WorkplanSetTotalHLP: TIntegerField;
    WorkplanSetTotalAHLP: TIntegerField;
    WorkplanSetCompl: TIntegerField;
    WorkplanSetWP1: TWordField;
    WorkplanSetl1: TWordField;
    WorkplanSetp1: TWordField;
    WorkplanSetlb1: TWordField;
    WorkplanSetWP2: TWordField;
    WorkplanSetl2: TWordField;
    WorkplanSetp2: TWordField;
    WorkplanSetlb2: TWordField;
    WorkplanSetKp: TWordField;
    WorkplanSetKr: TWordField;
    WorkplanSetRg: TWordField;
    WorkplanSetCr: TWordField;
    WorkplanSetHr: TWordField;
    WorkplanSetKoll: TWordField;
    WorkplanSetZ: TWordField;
    WorkplanSetE: TWordField;
    WorkplanSetkName: TStringField;
    WorkplanSetHours1: TStringField;
    WorkplanSetHours2: TStringField;
    WorkplanSetLec: TSmallintField;
    WorkplanSetPrc: TSmallintField;
    WorkplanSetLab: TSmallintField;
    procedure WorkplanSetCalcFields(DataSet: TDataSet);
  protected
    function GetModuleName: string; override;
    procedure ModuleHandler(var Msg: TMessage); override;

  private
    { Private declarations }
    fgroup: string;       // grid=grName

    function Get_grid: int64;
    function Get_grName: string;

  public
    { Public declarations }
    procedure UpdateModule; override;
    procedure Open(const AGroup: string);

    property group: string read fgroup;
    property grid: int64 read Get_grid;
    property grName: string read Get_grName;
  end;

implementation

uses
  SUtils, STypes, SDBUtils;

{$R *.dfm}

function TfrmWorkView.Get_grid: int64;
begin
  if fgroup<>'' then Result:=GetID(fgroup)
    else Result:=0;
end;

function TfrmWorkView.Get_grName: string;
begin
  if fgroup<>'' then Result:=SUtils.GetValue(fgroup)
    else Result:='';
end;

// загрузка раб. плана (группа и семестр)
procedure TfrmWorkView.Open(const AGroup: string);
begin
  if agroup<>fgroup then
  begin
    fgroup:=AGroup;
    Caption:=Format('Рабочий план: %s',[grName]);
    UpdateModule;
  end;
end;

function TfrmWorkView.GetModuleName: string;
begin
  Result:='Рабочий план';
//  Result:=Format('Рабочий план: %s',[grName]);
end;

procedure TfrmWorkView.ModuleHandler(var Msg: TMessage);
begin
  case Msg.Msg of
    SM_CHANGETIME:  // изм-ние времени
      if (TSMChangeTime(Msg).Flags and CT_YEAR)=CT_YEAR then   // изм-ние года
        TSMChangeTime(Msg).Result:=MRES_DESTROY
      else
        if (TSMChangeTime(Msg).Flags and CT_SEM)=CT_SEM then   // изм-ние сем
        begin
          UpdateModule;
          TSMChangeTime(Msg).Result:=MRES_UPDATE;
        end;
  end;  // case
end;

// обновление модуля
procedure TfrmWorkView.UpdateModule;
begin
  Assert(grid>0,
    'CE1D0AB0-F4FD-49A1-ADD6-95295A9C55EF'#13'TfrmWPView.UpdateModule: invalid grid'#13);

  if grid>0 then
    GetRecordset(dmMain.wp_GetWorkplan(grid), WorkplanSet);
end;

procedure TfrmWorkView.WorkplanSetCalcFields(DataSet: TDataSet);
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
    FieldByName('Prc').Value:=wp1*p1+wp2*p2;
    FieldByName('Lab').Value:=wp1*lb1+wp2*lb2;
  end;
end;

end.
