{
  Модуль доступа к данным (admin)
  v0.0.2  (25/09/06)
}                  
unit AdminModule;

interface

uses
  SysUtils, Classes, ADODB, DB,
  BaseModule, ImgList, Controls;

type

  TdmAdmin = class(TBaseDataModule)
    comExecSql: TADOCommand;
    spImport2: TADOCommand;
    spPlanMgm: TADOCommand;
    spSubjMgm: TADOCommand;
    BtnImageList: TImageList;

  private
    { Private declarations }

  protected
    { Protected declarations }
    function DoConnect: integer; override;
    procedure DoDisconnect; override;

  public
    { Public declarations }
    function OpenQuery(query: string): _Recordset;

    function fcl_Create(fName: string): integer;
    function kaf_Create(fid: integer; kName: string): int64;

    function yr_Create(ynum: smallint): boolean;
    function prd_Get_y(ynum: smallint): _Recordset;
    function prd_Create(ynum: smallint; sem,ptype: byte; p_start,p_end: string): integer;

    function sbj_GetLetter(cLetter: string): _Recordset;
    function sbj_Replace(sbid,new: int64): boolean;
  end;

var
  dmAdmin: TdmAdmin;

implementation

uses
  Windows, Dialogs, ADOInt, OLEDB, Variants,
  SConsts, SDBUtils;

{$R *.dfm}

{ TdmAdmin }

function TdmAdmin.DoConnect: integer;
begin
  Result:=ERROR_CON_SUCCESS;
end;

procedure TdmAdmin.DoDisconnect;
begin
end;

function TdmAdmin.OpenQuery(query: string): _Recordset;
var
  com: _Command;
begin
  Assert(query<>'',
    '039CCAAC-D6F2-4392-A4C0-81C99F63EE98'#13'OpenQuery: query is empty'#13);

  try
    comExecSql.CommandType:=cmdText;
    comExecSql.CommandText:=query;
    com:=CloneCommand(comExecSql);

    Result:=CoRecordset.Create;
    Result.CursorLocation:=adUseClient;
    Result.Open(com,EmptyParam,adOpenKeyset,adLockOptimistic,adCmdText);
  except
    on E: Exception do
    begin
      Result:=nil;
      raise Exception.CreateFmt('Ошибка БД: %s', [E.Message]);
    end;
  end;
end;

// добавление факультета (03.04.06)
function TdmAdmin.fcl_Create(fName: string): integer;
var
  value: Variant;
  res: integer;
begin
  Assert(fName<>'',
    'BD92FAC1-8696-43B6-A61C-2B372F50CBCF'#13'fcl_Create: fName is empty string'#13);

  res:=_ExecSP(spImport2,['@case','@fName'],[impAddFaculty,fName],'@fid',value);
  if res=0 then
    if not VarIsNull(value) then Result:=value else Result:=0
  else Result:=-1;
end;

// добавление кафедры (03.04.06)
function TdmAdmin.kaf_Create(fid: integer; kName: string): int64;
var
  value: Variant;
  res: integer;
begin
  Assert(fid>0,
    '2E55F2E2-1BFD-413A-B6E2-4E6BBA3AA7CD'#13'kaf_Create: invalid fid'#13);
  Assert(kName<>'',
    '9F367486-A9F3-4742-9FE9-F2EB3CE94FA2'#13'kaf_Create: kName is empty string'#13);

  res:=_ExecSP(spImport2,['@case','@fid','@kName'],[impAddKafedra,fid,kName],
    '@kid',value);
  if res=0 then
    if not VarIsNull(value) then Result:=value else Result:=0
  else Result:=-1;
end;

// добавление уч. года (16.04.06)
function TdmAdmin.yr_Create(ynum: smallint): boolean;
var
  res: integer;
begin
  Assert(ynum>0,
    '2C3951E2-B089-497D-BF45-515E973F0B68'#13'yr_Create: invalid ynum'#13);

  res:=ExecSP(spPlanMgm,['@case','@ynum'],[plnAddYear,ynum]);
  Result:=(res=0);
end;

// выбор семестров уч. года (15.04.06)
function TdmAdmin.prd_Get_y(ynum: smallint): _Recordset;
begin
  Assert(ynum>0,
    'E3C8AB96-B682-487B-9800-661FC85D4A89'#13'prd_Get_y: invalid ynum'#13);

  Result:=OpenSP(spPlanMgm,['@case','@ynum'],[plnSelPeriods,ynum]);
end;

// добавление семестра для уч. года (15.04.06)
function TdmAdmin.prd_Create(ynum: smallint; sem,ptype: byte;
  p_start,p_end: string): integer;
var
  value: Variant;
  res: integer;
begin
  Assert(sem in [1,2],
    'C3DF0D18-7F6A-4AC4-84A4-A26C9D84BB46'#13'sem_Create: invalid sem'#13);
  Assert(ynum>0,
    'B3C09447-E67C-4261-9CE8-B9202066F817'#13'sem_Create: invalid ynum'#13);
  Assert((ptype>=1) and (ptype<=3),
    '603C6452-9BE8-421D-9AC1-6D5B98EDCE00'#13'prd_Create: invalid ptype'#13);

  res:=_ExecSP(spPlanMgm,['@case','@ynum','@sem','@ptype','@p_start','@p_end'],
    [plnAddPeriod,ynum,sem,ptype,p_start,p_end], '@prid', value);

  if res=0 then
    if not VarIsNull(value) then Result:=value else Result:=0
  else Result:=-1;
end;

// выбор дисциплин по первому символу  (25/09/06)
function TdmAdmin.sbj_GetLetter(cLetter: string): _Recordset;
begin
  Result:=OpenSP(spSubjMgm, ['@case','@letter'], [sbjSelLetter,cLetter]);
end;

// TODO: Доработать
// замена дисциплины (15.03.06)
function TdmAdmin.sbj_Replace(sbid, new: int64): boolean;
var
  res: integer;
begin
  Result:=false;
  Assert((sbid>0) and (new>0),
    'F4452F5D-72A1-48BE-8D8B-53328EC044AD'#13'sbj_Replace: invalid identifiers'#13);

  res:=ExecSP(spSubjMgm,['@case','@sbid','@new'],[sbjReplace,sbid,new]);
  Result:=(res=0);
end;

end.
