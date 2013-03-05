{
  Модуль данных "Рабочий план"
  v0.0.1  (20/09/06)
}
unit WorkModule;

interface

uses
  SysUtils, Classes,
  ClientModule, ADODB, DB, ImgList, Controls;

type
  TdmWork = class(TClientDataModule)
    spWPMgm: TADOCommand;
    spSubjMgm: TADOCommand;
    spGroupMgm: TADOCommand;
    spTeachMgm: TADOCommand;
    comExecSql: TADOCommand;
    BtnImageList: TImageList;
  private
    { Private declarations }

    // функции управления преподавателями
    function thr_GetList(kid: int64): _Recordset;

    function Get_FID: integer;
    function Get_FName: string;

  public
    { Public declarations }

    // списки
    function GetTeacherList(kid: int64; AList: TStrings): boolean;

    function dbv_GetFacultyKaf(fid: integer): _Recordset;

    // функции управления дисциплинами
    function sbj_GetLetter(letter: string): _Recordset;
    function sbj_Replace(sbid,new: int64): boolean;        // ?

    function wp_GetGrp(asem, apsem: byte; grid: int64): _Recordset;
    function wp_Create(grid, sbid, kid: int64; asem: byte; examen: boolean): int64;
    function wp_Delete(wpid: int64): boolean;
    function wp_Copy(wpid, sbid: int64): int64;
    function wp_CopyGrp(grid, ngrid: int64): boolean;
    function ld_Create(wpid: int64; ltype, apsem, hours: byte): int64;
    function ld_Delete(lid: int64): boolean;

    // функции управления группами
    function grp_Get_k(kid: int64): _Recordset;

    function UpdateRecord(ATable,AKeyField: string; AId: int64; AField: string;
        AValue: Variant): boolean;

    property FacultyID: integer read Get_FID;
    property FacultyName: string read Get_FName;
  end;

var
  dmWork: TdmWork;

implementation

uses
  Variants, Dialogs,
  SConsts, SUtils;

const
  // SQL Scripts
  SQL_UPDATE = 'update %s set %s=:@value where %s=:@id';
  SQL_DELETE = 'delete %s where %s=:@id';

{$R *.dfm}

{ TdmWork }

// возвращает id текущего факультета (13/09/06)
function TdmWork.Get_FID: integer;
begin
  Result:=GetID(FacultyList[0]);
end;

// возвращает название текущего факультета (13/09/06)
function TdmWork.Get_FName: string;
begin
  Result:=FacultyList.ValueFromIndex[0];
end;

// списки

// список преподавателей кафедры (20/09/06)
function TdmWork.GetTeacherList(kid: int64; AList: TStrings): boolean;
var
  rs: _Recordset;
begin
  Result:=false;

  Result:=RecordsetToList(thr_GetList(kid), AList, 'Initials ASC',
      'tid', 'Initials', 'pSmall');
end;

function TdmWork.dbv_GetFacultyKaf(fid: integer): _Recordset;
begin
  Result:=kaf_Get_f(fid);
end;

// выбор раб. плана группы (25.01.06)
function TdmWork.wp_GetGrp(asem,apsem: byte; grid: int64): _Recordset;
begin
  Assert(((asem in [1,2]) and (apsem in [1,2])),
    '00B8F564-6C08-490E-AAC5-2783DA12BA28'#13'wp_GetGrp: invalid [asem] or [apsem]'#13);

  Result:=OpenSP(spWPMgm,['@case','@sem','@psem','@grid'],[wpSelect,asem,apsem,grid]);
end;

function TdmWork.wp_Create(grid, sbid, kid: int64; asem: byte;
    examen: boolean): int64;
var
  res: integer;
  vwpid: Variant;
begin
  res:=_ExecSP(spWPMgm,['@case','@grid','@sbid','@kid','@sem','@e'],
    [wpCreate,grid,sbid,kid,asem,byte(examen)], '@wpid', vwpid);
  if res=0 then
    if not VarIsNull(vwpid) then Result:=vwpid else Result:=0
  else Result:=-1;
end;

// удаление дисциплины из раб. плана группы (25.01.06)
function TdmWork.wp_Delete(wpid: int64): boolean;
var
  res: integer;
begin
  res:=ExecSP(spWPMgm,['@case','@wpid'],[wpDelete,wpid]);
  Result:=(res=0);
end;

// копирование дисциплины р.п. (06.02.06)
function TdmWork.wp_Copy(wpid, sbid: int64): int64;
var
  res: integer;
  vwpid: Variant;
begin
  res:=_ExecSP(spWPMgm,['@case','@wpid','@sbid'],[wpCopy,wpid,sbid],'@wpid',vwpid);
  if res=0 then
    if not VarIsNull(vwpid) then Result:=vwpid else Result:=0
  else Result:=-1;
end;

// копирование р.п. в другую группу (06.02.06)
// wp_copygrp: 0 - успешно, иначе код ошибки
function TdmWork.wp_CopyGrp(grid, ngrid: int64): boolean;
var
  res: integer;
begin
  // kid=ngrid
  res:=ExecSP(spWPMgm,['@case','@grid','@kid'],[wpCopyGrp,grid,ngrid]);
  Result:=(res=0);
end;

// добавление нагрузки на дисциплину (25.01.06)
function TdmWork.ld_Create(wpid: int64; ltype, apsem, hours: byte): int64;
var
  res: integer;
  vlid: Variant;
begin
  Assert(wpid>0,
    '2D6A01EF-9C47-40EE-9833-CABC8125B48C'#13'ld_Create: invalid wpid'#13);
  Assert(ltype in [1,2,3],
    '5131E06A-ADE4-43FD-9B74-7DD85591A0D4'#13'ld_Create: invalid ltype'#13);
  Assert(apsem in [1,2],
    '73CC35D8-DB9A-49C2-A129-9EA02840FF37'#13'ld_Create: invalid apsem'#13);
  Assert(hours>0,
    'FF0AEDCE-BC34-4B05-B354-2333D91DC2C9'#13'ld_Create: invalid hours'#13);

  res:=_ExecSP(spWPMgm, ['@case','@wpid','@type','@psem','@hours'],
    [wpAddLoad,wpid,byte(ltype),apsem,hours], '@lid', vlid);
  if res=0 then
    if not VarIsNull(vlid) then Result:=vlid else Result:=0
  else Result:=-1;
end;

// удаление нагрузки (25.01.06)
function TdmWork.ld_Delete(lid: int64): boolean;
var
  res: integer;
begin
  Assert(lid>0,
    '183269CF-D9F1-4C42-8CC2-108825CFF01E'#13'ld_Delete: invalid lid'#13);

  res:=ExecSP(spWPMgm,['@case','@lid'],[wpDelLoad,lid]);
  Result:=(res=0);
end;

// выбор дисциплин по 1ой букве
function TdmWork.sbj_GetLetter(letter: string): _Recordset;
begin
  Result:=OpenSP(spSubjMgm, ['@case','@letter'], [sbjSelLetter,letter]);
end;

// замена дисциплины (15.03.06)
function TdmWork.sbj_Replace(sbid,new: int64): boolean;
var
  res: integer;
begin
  Assert((sbid>0) and (new>0),
    '60CE1DC9-CE09-4CCA-BB3D-F1C7CFB1B380'#13'sbj_Replace: invalid identifiers'#13);

  res:=ExecSP(spSubjMgm,['@case','@sbid','@new'],[sbjReplace,sbid,new]);
  Result:=(res=0);
end;

// выбор групп кафедры (25.01.06)
function TdmWork.grp_Get_k(kid: int64): _Recordset;
begin
  Result:=OpenSP(spGroupMgm, ['@case','@ynum','@kid'],[grpSelKaf,Year,kid]);
end;

// выбор списка преп-лей кафедры (kid)
function TdmWork.thr_GetList(kid: int64): _Recordset;
begin
  Assert(kid>0,
    Format('3657770E-8CCB-4612-BDDF-35A4434ED22F'#13'thr_GetList: invalid kid=%d'#13,[kid]));

  Result:=_OpenSP(spTeachMgm,['@case','@kid'],[thSelTchList,kid]);
end;

// обновление записи
// ATable - имя таблицы
// AKeyField - ключ. поле таблцы
// AId - id записи
// AField - имя поля
// AValue - зн-ние поля
function TdmWork.UpdateRecord(ATable,AKeyField: string; AId: int64;
  AField: string; AValue: Variant): boolean;
var
  sql: string;
  rows: integer;
begin
  rows:=0;
  sql:=Format(SQL_UPDATE,[ATable,AField,AKeyField]);
  try
    comExecSql.CommandText:=sql;
    comExecSql.Parameters.ParamByName('@id').Value:=AId;
    comExecSql.Parameters.ParamByName('@value').Value:=AValue;
    comExecSql.Execute(rows, EmptyParam);
    Result:=(rows>0);
  except
    on E: Exception do
    begin
      ShowMessageFmt('Error: %s', [E.Message]);
      Result:=false;
    end;
  end;
end;

end.
