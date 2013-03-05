{
  Модуль доступа к данным
  v0.2.6 (18/08/06)
}

unit DataModule;

interface

uses
  SysUtils, Classes, DB, ADODB, ComCtrls, VirtualTrees, StdCtrls,
  Controls, Messages, Types, ImgList, STypes, ClientModule;

type
  TdmMain = class(TClientDataModule)
//    Connection: TADOConnection;
    ImageBtnList: TImageList;
//    spVersion: TADOCommand;
    spAudMgm: TADOCommand;
//    spDBView: TADOCommand;
    spTeachMgm: TADOCommand;
    spWPMgm: TADOCommand;
    spSubjMgm: TADOCommand;
    spGroupMgm: TADOCommand;
    comExecSql: TADOCommand;
    spSchedMgm: TADOCommand;
    spStrmMgm: TADOCommand;
    procedure DataModuleCreate(Sender: TObject);
//    procedure DataModuleDestroy(Sender: TObject);

  private
    { Private declarations }
    function Get_FID: integer;
    function Get_FName: string;

  protected
    { Protected declarations }
//    function DoLoginUser: boolean; override;
//    procedure DoLogoffUser; override;

  public
    { Public declarations }

//    function ChangeYear: boolean; override;

    // списки
    function GetTeacherList(kid: int64; AList: TStrings): boolean;
    function GetAuditoryList(kid: int64; AList: TStrings): boolean;
    function GetPerformKafList(AList: TStrings): boolean;


    function dbv_GetPerformKaf(fid: integer): _Recordset;
    function dbv_GetFacultyKaf(fid: integer): _Recordset;

//    function fcl_GetAll: _Recordset;              // TODO: Delete
//    function kaf_Get_f(fid: integer): _Recordset; // TODO: Delete
//    function yr_GetAll: _Recordset;               // TODO: Delete

    // функции управления кафедрами
//    function kaf_GetAll: _Recordset;

    // функции управления званиями
//    function pst_GetAll: _Recordset;

    // функции управления раб. планами
    function wp_ExportDeclare(kid: int64; ltype: byte): _Recordset;
    function wp_GetDeclare(kid: int64): _Recordset;
    function wp_GetWorkplan(grid: int64): _Recordset;

    function wp_GetGrp(asem, apsem: byte; grid: int64): _Recordset;
    function wp_Create(grid, sbid, kid: int64; asem: byte; examen: boolean): int64;
    function wp_Delete(wpid: int64): boolean;
    function wp_Copy(wpid, sbid: int64): int64;
    function wp_CopyGrp(grid, ngrid: int64): boolean;
    function ld_Create(wpid: int64; ltype, apsem, hours: byte): int64;
    function ld_Delete(lid: int64): boolean;
    function wp_GetKaf(grid, sbid: int64): _Recordset;

    // функции управления преподавателями
    function thr_GetKaf(kid: int64): _Recordset;
    function thr_GetList(kid: int64): _Recordset;
    function thr_GetPrefer(tid: int64): _Recordset;

    // функции управления потоками
    function stm_Get_ks(ltype: byte; kid, sbid: int64): _Recordset;
    function stm_Create(lid: int64): int64;
    function stm_Delete(strid: int64): boolean;
    function stm_AddGrp(strid, lid: int64): boolean;
    function stm_DelGrp(lid: int64): boolean;
    function stm_GetFree_s(strid: int64): _Recordset;
    function stm_SetThr(strid, tid: int64): boolean;
    function stm_GetFree_d(ltype: byte; kid, sbid: int64): _Recordset;
    function stm_GetDeclare(ltype: byte; kid, sbid: int64): _Recordset;  // TODO: удалить (не исп-ся)

    // функции управления аудиториями
    function adr_GetList_fk(fid: integer; kid: int64): _Recordset;
    function adr_GetPrefer(aid: string): _Recordset;
    function adr_Get_f(fid: integer): _Recordset;

    // функции управления расписанием
    function sdl_GetFreeThr_l(lid: int64; week, wday, npair: byte): _Recordset;
    function sdl_GetFreeAdr_l(fid: integer; lid: int64; week, wday, npair: byte): _Recordset;
    function sdl_DelLsns_s(strid: int64; week, wday, npair: byte): boolean;
    function sdl_DelLsns_g(lid: int64; week, wday, npair: byte): boolean;
    function sdl_SetThr_s(strid: int64; week,wday,npair: byte; tid: int64): boolean;
    function sdl_SetThr_l(lid: int64; week,wday,npair: byte; tid: int64): boolean;
    function sdl_SetAdr_l(lid: int64; week,wday,npair: byte; aid: int64): boolean;
    function sdl_SetAdr_s(strid: int64; week,wday,npair: byte; aid: int64): boolean;
    function sdl_SetHGrp(lid: int64; week,wday,npair,hgrp: byte): boolean;
    function sdl_NewLsns_s(strid: int64; week,wday,npair,hgrp: byte; aid: int64): boolean;
    function sdl_NewLsns_g(lid: int64; week,wday,npair,hgrp: byte; aid: int64): boolean;
    function sdl_GetLsns_s(strid: int64; wday: byte=0; npair: byte=0): _Recordset;
    function sdl_GetAvail_sb(grid,sbid: int64; week,wday,npair: byte): _Recordset;
    function sdl_GetLsns_g(grid: int64): _Recordset;
    function sdl_GetLsns_l(lid: int64; wday: byte=0; npair: byte=0): _Recordset;
    function sdl_GetAvail_g(week,wday,npair: byte; grid: int64): _Recordset;
    function sdl_GetAvail_psem(grid: int64): _Recordset;
    function sdl_GetLsns_t(tid: int64): _Recordset;
    function sdl_GetLsns_a(aid: int64): _Recordset;
    function sdl_GetFreeAdr_lk(lid: int64; week,wday,npair: byte): _Recordset;

    // функции управления дисциплинами
//    function sbj_GetLetter(letter: string): _Recordset;  // ?
//    function sbj_Replace(sbid,new: int64): boolean;      // ?

    // функции управления группами
    function grp_Get_k(kid: int64): _Recordset;          // ?
    function grp_GetCourse(course: byte): _Recordset;

//    function UpdateRecord(ATable,AKeyField: string; AId: int64; AField: string;
//        AValue: Variant): boolean;   // ?


    property FacultyID: integer read Get_FID;
    property FacultyName: string read Get_FName;
  end;

type
  // данные для управления потоками
  TStreamDataType = (sdtNone, sdtStrm, sdtGrp);
  PStreamData = ^TStreamData;
  TStreamData = record
    DataType: TStreamDataType;
    Value: array[0..2] of string;  // stdStrms[strid,'',''] dtGrp[sbj,grp,teach]
    Changed: boolean;
  end;

var
  dmMain: TdmMain;

// создание ADODataSet`а
function CreateDataSet(Recordset: _Recordset): TADODataSet;

implementation

uses
  Windows, ADOConEd, Graphics, Variants, ADOInt, OLEDB,
  SUtils, SConsts, SStrings, Dialogs, StringListDlg, BaseModule;

const
  // SQL Scripts
  SQL_UPDATE = 'update %s set %s=:@value where %s=:@id';
  SQL_DELETE = 'delete %s where %s=:@id';

{$R *.dfm}


// создание ADODataSet`а
function CreateDataSet(Recordset: _Recordset): TADODataSet;
begin
  Result:=nil;
  if Assigned(Recordset) then
    if (Recordset.State and adStateOpen)=1 then
    begin
      Result:=TADODataSet.Create(nil);
      try
        Result.Recordset:=Recordset;
      except
        Result.Free;
        Result:=nil;
      end;
   end;
end;

{ TdmMain }

procedure TdmMain.DataModuleCreate(Sender: TObject);
begin
  ImageBtnList.ResourceLoad(rtBitmap, 'BTNS', clFuchsia);
end;

// смена(выбор) уч. года (20.04.06)
{
function TdmMain.ChangeYear: boolean;

  function GetYearList(AList: TStrings): boolean;
  var
    rs: _Recordset;
    i: integer;
    s: string;
  begin
    Assert(Assigned(AList),
      '5E291935-B801-4D96-822B-00937D74D44F'#13'GetYearList: AList is nil'#13);

    rs:=yr_GetAll();
    if Assigned(rs) then
    try
      AList.Clear;
      try
        i:=0;
        while not rs.EOF do
        begin
          s:=Format('%d=%s',[i,VarToStr(rs.Fields['ynum'])]);
          AList.Add(s);
          inc(i);
          rs.MoveNext;
        end;
      except
        AList.Clear;
      end;
    finally
      rs.Close;
      rs:=nil;
    end;
    Result:=(AList.Count>0);
  end;

var
  list: TStringList;
  n: integer;
  y: word;

begin
  Result:=false;

  if Connection.Connected then
  begin
    list:=TStringList.Create;
    try
      if GetYearList(list) then
        if GetIndexFromList('Учебный год',n,list) then
        begin
          y:=StrToIntDef(list.ValueFromIndex[n],0);
          Result:=(y>0);
          if Result then Year:=y;
        end;
    finally
      list.Free;
      list:=nil;
    end;
  end
  else raise Exception.Create(rsErrNoConnect);
end;
}

// начало сеанса пользователя (31/07/06)
{
function TdmMain.DoLoginUser: boolean;
begin
  Result:=ChangeYear;
end;
}

// завершение сеанса (31/07/06)
{
procedure TdmMain.DoLogoffUser;
begin
  // TODO: Сохранять имзенен. настройки в БД для пользователя
end;
}

// возвращает id текущего факультета (13/09/06)
function TdmMain.Get_FID: integer;
begin
  Result:=GetID(FacultyList[0]);
end;

// возвращает название текущего факультета (13/09/06)
function TdmMain.Get_FName: string;
begin
  Result:=FacultyList.ValueFromIndex[0];
end;

// списки

function TdmMain.GetTeacherList(kid: int64; AList: TStrings): boolean;
var
  rs: _Recordset;
  s: string;
begin
  Result:=false;

  rs:=thr_GetList(kid);
  if Assigned(rs) then
  try
    AList.Clear;
    rs.Sort:='Initials ASC';
    try
      while not rs.EOF do
      begin
        s:=SUtils.Format(VarToStr(rs.Fields['tid'].Value),
          VarToStr(rs.Fields['Initials'].Value),
          VarToStr(rs.Fields['pSmall'].Value));
        AList.Add(s);
        rs.MoveNext;
      end;
    except
      AList.Clear;
    end;
  finally
    rs.Close;
    rs:=nil;
  end;

  Result:=(AList.Count>0);
end;

// список аудиторий (15/08/06)
function TdmMain.GetAuditoryList(kid: int64; AList: TStrings): boolean;
var
  rs: _Recordset;
  s: string;
  fid: integer;
begin
  Result:=false;

  fid:=Get_FID;

  rs:=adr_GetList_fk(fid,kid);
  if Assigned(rs) then
  try
    AList.Clear;
    rs.Sort:='aName ASC';
    try
      while not rs.EOF do
      begin
        s:=Format('%s=%s', [VarToStr(rs.Fields['aid'].Value), VarToStr(rs.Fields['aName'].Value)]);
        AList.Add(s);
        rs.MoveNext;
      end;
    except
      AList.Clear;
    end;
  finally
    rs.Close;
    rs:=nil;
  end;

  Result:=(AList.Count>0);
end;

// список кафедр-исполнителей (03/09/06)
function TdmMain.GetPerformKafList(AList: TStrings): boolean;
var
  rs: _Recordset;
  s: string;
begin
  Assert(Assigned(AList),
    'E26E6535-9DEA-41A9-BB80-03FC01A542BA'#13'GetPerformKafList: AList is nil'#13);

  rs:=dbv_GetPerformKaf(Get_FID);
  if Assigned(rs) then
  try
    rs.Sort:='kName ASC';
    AList.Clear;
    try
      while not rs.EOF do
      begin
        s:=VarToStr(rs.Fields['kid'].Value)+'='+VarToStr(rs.Fields['kName'].Value);
        AList.Add(s);
        rs.MoveNext;
      end;
    except
      AList.Clear;
    end;
  finally
    rs.Close;
    rs:=nil;
  end;
  Result:=(AList.Count>0);
end;

// выбор кафедр-исполнителей для факультета (03/09/06)
function TdmMain.dbv_GetPerformKaf(fid: integer): _Recordset;
begin
  Assert(fid>0,
    'A8F2CC74-BC61-4E70-A464-814B2220FF32'#13'dbv_GetPerformKaf: invalid fid'#13);

  Result:=_OpenSP(spDBView,['@case','@ynum','@sem','@fid'],
      [dbvSelPerformKaf,Year,Sem,fid]);
end;

function TdmMain.dbv_GetFacultyKaf(fid: integer): _Recordset;
begin
  Result:=kaf_Get_f(fid);
end;

// выбор заявок для экспорта (kid,type) (15.02.06)
function TdmMain.wp_ExportDeclare(kid: int64; ltype: byte): _Recordset;
begin
  Assert(kid>0,
    '{8AA99919-CDFF-421C-8C49-E192A106AD90'#13'wp_ExportDeclare: invalid nKid'#13);
  Assert((ltype>=1) and (ltype<=3),
    'C4F95A65-9B3D-4B2F-B0D4-17DE9803D3D8'#13'wp_ExportDeclare: invalid nLType'#13);

  Result:=_OpenSP(spWPMgm,['@case','@ynum','@sem','@psem','@kid','@type'],
    [wpSelDeclareExp,Year,Sem,PSem,kid,ltype]);
end;


// выбор преподвателей кафедры (kid) (3.07.2005)
function TdmMain.thr_GetKaf(kid: int64): _Recordset;
begin
  Result:=OpenSP(spTeachMgm,['@case','@kid'],[thSelTchKaf,kid]);
end;

// выбор списка преп-лей кафедры (kid)
function TdmMain.thr_GetList(kid: int64): _Recordset;
begin
  Assert(kid>0,
    Format('C976BA92-469D-43E0-AC8D-05C1AF746F1B'#13'thr_GetList: invalid kid=%d'#13,[kid]));

  Result:=_OpenSP(spTeachMgm,['@case','@kid'],[thSelTchList,kid]);
end;

// выбор заявок на кафедру (3.10.05)
function TdmMain.wp_GetDeclare(kid: int64): _Recordset;
begin
  Assert(kid>0,
    Format('7253205D-F761-49FC-89A0-99FAC6C4549B'#13'wp_GetDeclare: invalid kid=%d'#13,[kid]));

  Result:=_OpenSP(spWPMgm,['@case','@ynum','@sem','@kid'],
      [wpSelDeclareKaf,Year,Sem,kid]);
end;

// DELETE: дублирование dbv_GetKaf
{
// выбор всех кафедр (изм-ние) (29.01.06)
function TdmMain.kaf_GetAll: _Recordset;
begin
  Result:=OpenSP(spDBView,['@case'],[dbvSelKaf]);
end;
}

// выборка р.п. группы (3.10.2005)
function TdmMain.wp_GetWorkplan(grid: int64): _Recordset;
begin
  Assert(grid>0,
    '308B7510-8A68-4D21-BC8D-7F1C66D44525'#13'wp_GetWorkplan: invalid agrid'#13);

  Result:=_OpenSP(spWPMgm,['@case','@sem','@grid'],[wpSelWP,Sem,grid]);
end;

// stream management function

// добавление группы в поток (20.02.06)
function TdmMain.stm_AddGrp(strid, lid: int64): boolean;
var
  res: integer;
begin
  Assert(strid>0,
    '{1633D203-90FC-4697-895F-FD24A611704B'#13'stm_AddGrp: invalid strid'#13);
  Assert(lid>0,
    'D52EB290-6886-459E-8749-CC8058B53076'#13'stm_AddGrp: invalid lid'#13);

  res:=ExecSP(spStrmMgm,['@case','@strid','@lid'],[smAddGrp,strid,lid]);
  Result:=(res=0);
end;

// удвление потока (20.02.06)
function TdmMain.stm_Delete(strid: int64): boolean;
var
  res: integer;
begin
  Assert(strid>0,
    '5E7F1CE2-E4FA-469F-B92D-98814DBA3140'#13'stm_Delete: invalid strid'#13);

  res:=ExecSP(spStrmMgm,['@case','@strid'],[smDelete,strid]);
  Result:=(res=0);
end;

// удаление группы из потока (20.02.06)
function TdmMain.stm_DelGrp(lid: int64): boolean;
var
  res: integer;
begin
  Assert(lid>0,
    '09C3C619-1A6A-40F5-A133-B05DBAFB3E3F'#13'stm_DelGrp: invalid lid'#13);

  res:=ExecSP(spStrmMgm,['@case','@lid'],[smDeleteGroup,lid]);
  Result:=(res=0);
end;

// выбор потоков кафедры по дисциплине (26.02.06)
function TdmMain.stm_Get_ks(ltype: byte; kid, sbid: int64): _Recordset;
begin
  Assert(ltype in [1,2,3],
    'C18D62D6-6719-40DF-ADB0-7846632DF8E5'#13'stm_Get_ks: invalid ltype'#13);
  Assert(kid>0,
    'E32FCD83-0BD0-4386-99B9-D0CA73822D10'#13'stm_Get_ks: invalid kid'#13);
  Assert(sbid>0,
    '0758A0E7-D60C-4739-8CDD-BBDF27D06CAD'#13'stm_Get_ks: invalid sbid'#13);

  Result:=_OpenSP(spStrmMgm,['@case','@ynum','@sem','@psem','@type','@kid','@sbid'],
      [smSelKafSbj,Year,Sem,PSem,ltype,kid,sbid]);
end;

// создание потока (20.02.06)
// Result = strid (>0)
function TdmMain.stm_Create(lid: int64): int64;
var
  value: Variant;
  res: integer;
begin
  Assert(lid>0,
    'C6C9F38A-AC08-4093-85C7-FA51DDA0356C'#13'stm_Create: invalid lid'#13);

  res:=_ExecSP(spStrmMgm,['@case','@lid'],[smCreate,lid],'@strid',value);
  if res=0 then
    if not VarIsNull(value) then Result:=value else Result:=0
  else Result:=-1;
end;

// выбор свобод. заявок для потока (19.02.06)
function TdmMain.stm_GetFree_s(strid: int64): _Recordset;
begin
  Assert(strid>0,
    '67133F39-05CB-4D71-8E22-A3B481EB28D0'#13'stm_GetFree_l: invalid strid'#13);

  Result:=_OpenSP(spStrmMgm,['@case','@strid'],[smSelForStrm,strid]);
end;

// выбор свобод. заявок (27.02.06)
function TdmMain.stm_GetFree_d(ltype: byte; kid, sbid: int64): _Recordset;
begin
  Assert(ltype in [1,2,3],
    'C19542A2-8E48-4A5F-90AC-805208BD8114'#13'stm_GetFree_d: invalid ltype'#13);
  Assert(kid>0,
    '9B0E99B6-60CE-46E6-AFE6-37803653D36B'#13'stm_GetFree_d: invalid kid'#13);
  Assert(sbid>0,
    '72F4BFD8-5CC8-449B-AC08-1F54A64E6B3E'#13'stm_GetFree_d: invalid sbid'#13);

  Result:=_OpenSP(spStrmMgm,['@case','@ynum','@sem','@psem','@type','@kid','@sbid'],
    [smSelFreeDeclare,Year,Sem,PSem,ltype,kid,sbid]);
end;

// выборка заявок по дисц. +дисц., объед. через потоки (27.02.06)
// не используется (извлекаются как потоки, так и свобод. заявки - устарело)
function TdmMain.stm_GetDeclare(ltype: byte; kid, sbid: int64): _Recordset;
begin
  Assert(ltype in [1,2,3],
    '49B97021-2B2B-4F22-BC5B-A3431902DE0D'#13'stm_GetDeclare: invalid ltype'#13);
  Assert(kid>0,
    '895FD804-4BBC-4D0E-855E-33BC9249C502'#13'stm_GetDeclare: invalid kid'#13);
  Assert(sbid>0,
    '8E9BFE08-D9CE-4161-A45B-51E644B11558'#13'stm_GetDeclare: invalid sbid'#13);

  Result:=_OpenSP(spStrmMgm,['@case','@ynum','@sem','@psem','@type','@kid','@sbid'],
    [smSelSbj,Year,Sem,PSem,ltype,kid,sbid]);
end;

// уст-ка лектора потока (26.02.06)
function TdmMain.stm_SetThr(strid, tid: int64): boolean;
var
  res: integer;
  vtid: Variant;
begin
  Assert(strid>0,
    '2EE43B9C-AE7D-485F-8F7B-B1A17AFE6254'#13'stm_SetThr: invalid strid'#13);

  if tid>0 then vtid:=tid else vtid:=Null;
  res:=ExecSP(spStrmMgm,['@case','@strid','@tid'],[smSetThr,strid,vtid]);
  Result:=(res=0);
end;

// auditor's management function

// выбор аудиторий кафедры (fid,kid) (15/08/06)
function TdmMain.adr_GetList_fk(fid: integer; kid: int64): _Recordset;
var
  vkid: Variant;
begin
  Assert(fid>0,
    'C2664FEF-F62A-4267-87CF-F4A55A7E9DB8'#13'adr_GetList_fk: invalid fid'#13);

  if kid>0 then vkid:=kid else vkid:=Null;
  Result:=OpenSP(spAudMgm, ['@case','@fid','@kid'],[audSelectKaf,fid,vkid]);
end;

// выбор аудиторий факультета (09.04.06)
function TdmMain.adr_Get_f(fid: integer): _Recordset;
begin
  Assert(fid>0,
    'CBCEBAE4-2D7A-45D3-87AA-DAB84B11D72B'#13'adr_Get_f: invalid fid'#13);

  Result:=OpenSP(spAudMgm,['@case','@fid'],[audSelectFclty,fid]);
end;

// выбор предпочтений преп-ля (11.01.06)
function TdmMain.thr_GetPrefer(tid: int64): _Recordset;
begin
  Assert(tid>0,
    Format('63ABA06C-9FF5-484C-9F43-171DB6D2D176'#13'thr_GetPrefer: Invalid tid=%d'#13,[tid]));

  Result:=OpenSP(spTeachMgm,['@case','@tid'],[thSelPrefer,tid]);
end;

// выбор ограничений аудитории (10.01.06)
function TdmMain.adr_GetPrefer(aid: string): _Recordset;
begin
  Result:=OpenSP(spAudMgm, ['@case','@aid'], [audSelectPrefer,aid]);
end;

// schedule management function

// выбор расписания группы (grid,sem,psem)
function TdmMain.sdl_GetLsns_g(grid: int64): _Recordset;
begin
  Assert(grid>0,
    '6E65F860-E6B8-4D6A-B999-793096B98896'#13'sdl_GetLsns_g: invalid grid'#13);

  Result:=_OpenSP(spSchedMgm,['@case','@sem','@psem','@grid'],
      [sdlSelectGrp,Sem,PSem,grid]);
end;

// выбор свобод. аудиторий с учетом вместимости группы (13.02.06)
function TdmMain.sdl_GetFreeAdr_l(fid: integer; lid: int64; week, wday, npair: byte): _Recordset;
begin
  Assert((week<=2)and((wday>=1)and(wday<=6))and((npair>=1)and(npair<=7)),
    '925560ED-25AA-4740-8DB0-28B30EAB3EBA'#13'sdl_GetFreeAud_l: invalid pair'#13);

  Result:=_OpenSP(spSchedMgm,['@case','@fid','@lid','@week','@wday','@npair'],
      [sdlSelFreeAdrGrp,fid,lid,week,wday,npair]);
end;

// выбор свобод. аудиторий кафедры-исп-ля (16/08/06)
function TdmMain.sdl_GetFreeAdr_lk(lid: int64; week,wday,npair: byte): _Recordset;
begin
  Assert(week<=2,
    'C534A2D8-A298-4C7B-B6D5-BEBBCE617DD1'#13'sdl_GetFreeAdr_lk: invalid week'#13);
  Assert(wday in [1..6],
    '45771375-BFAD-41F1-8B3F-E9D30A6B6052'#13'sdl_GetFreeAdr_lk: invalid wday'#13);
  Assert(npair in [1..7],
    '9BA6F612-2C96-48CD-ADE3-003AD9A92939'#13'sdl_GetFreeAdr_lk: invlid npair'#13);

  Result:=_OpenSP(spSchedMgm,['@case','@lid','@week','@wday','@npair'],
      [sdlSelFreeAdrKaf,lid,week,wday,npair]);
end;

// выбор свободных препод-лей (13.02.06)
function TdmMain.sdl_GetFreeThr_l(lid: int64; week, wday, npair: byte): _Recordset;
begin
  Assert((week<=2)and(wday>=1)and(wday<=6)and(npair>=1)and(npair<=7),
    'DA364C90-9A85-4E8A-A129-AC6E1AB32E60'#13'sdl_GetFreeThr_l: invalid pair'#13);

  Result:=_OpenSP(spSchedMgm,['@case','@lid','@week','@wday','@npair'],
    [sdlSelFreeThr,lid,week,wday,npair]);
end;

// уст-ка поток. занятия (14.02.06)
function TdmMain.sdl_NewLsns_s(strid: int64; week,wday,npair,hgrp: byte;
    aid: int64): boolean;
var
  res: integer;
  vaid: Variant;
begin
  Assert((week<=2)and(wday>=1)and(wday<=6)and(npair>=1)and(npair<=7),
    '59B5E753-4F34-4A24-B6B7-CECCDEEC57E4'#13'sdl_NewLsns_s: invalid pair'#13);

  if aid>0 then vaid:=aid else vaid:=Null;
  res:=ExecSP(spSchedMgm,['@case','@strid','@week','@wday','@npair','@hgrp','@aid'],
    [sdlNewStrm,strid,week,wday,npair,hgrp,vaid]);
  Result:=(res=0);
end;

// удаление поток. занятия (14.02.06)
function TdmMain.sdl_DelLsns_s(strid: int64; week, wday, npair: byte): boolean;
var
  res: integer;
begin
  Assert((week<=2)and(wday>=1)and(wday<=6)and(npair>=1)and(npair<=7),
    '93C55D47-029B-428F-B4AC-7E2D3B0EC255'#13'sdl_DelLsns_s: invalid pair'#13);

  res:=ExecSP(spSchedMgm,['@case','@strid','@week','@wday','@npair'],
    [sdlDelStrm,strid,week,wday,npair]);
  Result:=(res=0);
end;

// уст-ка занятия (14.02.06)
// (lid,week,wday,npair,hgrp,aid)
function TdmMain.sdl_NewLsns_g(lid: int64; week,wday,npair,hgrp: byte; aid: int64): boolean;
var
  res: integer;
  vaid: Variant;
begin
  Assert((week<=2)and(wday>=1)and(wday<=6)and(npair>=1)and(npair<=7),
    '6D6F844F-2DDB-4021-8F61-C0214BECF020'#13'sdl_NewLsns_g: invalid pair'#13);

  if aid>0 then vaid:=aid else vaid:=Null;
  res:=ExecSP(spSchedMgm,['@case','@lid','@week','@wday','@npair','@hgrp','@aid'],
    [sdlNewLsns,lid,week,wday,npair,hgrp,vaid]);
  Result:=(res=0);
end;

// изм-е преп-ля занятия (14.02.06)
function TdmMain.sdl_SetThr_l(lid: int64; week,wday,npair: byte; tid: int64): boolean;
var
  res: integer;
  vtid: Variant;
begin
  Assert((week<=2)and(wday>=1)and(wday<=6)and(npair>=1)and(npair<=7),
    '18A910B8-DCC2-43BF-82C6-94D40C960E54'#13'sdl_SetThr_l: invalid pair'#13);

  if tid>0 then vtid:=tid else vtid:=Null;
  res:=ExecSP(spSchedMgm,['@case','@lid','@week','@wday','@npair','@tid'],
    [sdlSetThrGrp,lid,week,wday,npair,vtid]);
  Result:=(res=0);
end;

// изм-е аудитории занятия (14.02.06)
function TdmMain.sdl_SetAdr_l(lid: int64; week,wday,npair: byte; aid: int64): boolean;
var
  res: integer;
  vaid: Variant;
begin
  Assert((week<=2)and(wday>=1)and(wday<=6)and(npair>=1)and(npair<=7),
    '491C82A2-9B04-45AF-9E92-F650C2610B2D'#13'sdl_SetAdr_l: invalid pair'#13);

  if aid>0 then vaid:=aid else vaid:=Null;
  res:=ExecSP(spSchedMgm,['@case','@lid','@week','@wday','@npair','@aid'],
    [sdlSetAdrGrp,lid,week,wday,npair,vaid]);
  Result:=(res=0);
end;

// изм-е подгруппы занятия (14.02.06)
function TdmMain.sdl_SetHGrp(lid: int64; week,wday,npair,hgrp: byte): boolean;
var
  res: integer;
begin
  Assert((week<=2)and(wday>=1)and(wday<=6)and(npair>=1)and(npair<=7),
    'F394217D-60A1-48B8-A26C-584ADF2981DD'#13'sdl_SetHGrp_l: invalid pair'#13);

  res:=ExecSP(spSchedMgm,['@case','@lid','@week','@wday','@npair','@hgrp'],
    [sdlSetHgrp,lid,week,wday,npair,hgrp]);
  Result:=(res=0);
end;

// изм-е преп-ля пот. занятия (14.02.06)
function TdmMain.sdl_SetThr_s(strid: int64; week,wday,npair: byte;
    tid: int64): boolean;
var
  res: integer;
  vtid: Variant;
begin
  Assert((week<=2)and(wday>=1)and(wday<=6)and(npair>=1)and(npair<=7),
    '21210EF5-7AD6-40C1-9F5A-CC10E0DD2AF7'#13'sdl_SetThr_s: invalid pair'#13);

  if tid>0 then vtid:=tid else vtid:=Null;
  res:=ExecSP(spSchedMgm,['@case','@strid','@week','@wday','@npair','@tid'],
    [sdlSetThrStrm,strid,week,wday,npair,vtid]);
  Result:=(res=0);
end;

// изм-е аудитории пот. занятия (14.02.06)
function TdmMain.sdl_SetAdr_s(strid: int64; week,wday,npair: byte;
    aid: int64): boolean;
var
  res: integer;
  vaid: Variant;
begin
  Assert((week<=2)and(wday>=1)and(wday<=6)and(npair>=1)and(npair<=7),
    'BB754399-E22D-4350-AD4D-10B1179126B6'#13'sdl_SetAdr_s: invalid pair'#13);

  if aid>0 then vaid:=aid else vaid:=Null;
  res:=ExecSP(spSchedMgm,['@case','@strid','@week','@wday','@npair','@aid'],
    [sdlSetAdrStrm,strid,week,wday,npair,vaid]);
  Result:=(res=0);
end;

// удаление занятия из расписания группы (14.02.06)
function TdmMain.sdl_DelLsns_g(lid: int64; week, wday, npair: byte): boolean;
var
  res: integer;
begin
  Assert((week<=2)and(wday>=1)and(wday<=6)and(npair>=1)and(npair<=7),
    'FDC55B2D-0741-4518-9D78-FAB78876C9D4'#13'sdl_DelLsns_g: invalid pair'#13);

  res:=ExecSP(spSchedMgm,['@case','@lid','@week','@wday','@npair'],
      [sdlDelLsns,lid,week,wday,npair]);
  Result:=(res=0);
end;

// выбод доступ. занятий по дисциплине (14.02.06)
// (sem,psem,week,wday,npair,grid,sbid)
function TdmMain.sdl_GetAvail_sb(grid,sbid: int64;
    week,wday,npair: byte): _Recordset;
begin
  Assert((week<=2)and(wday>=1)and(wday<=6)and(npair>=1)and(npair<=7),
    'DDB43809-80D9-4D72-A2E6-FFB2F838222C'#13'sdl_GetAvailLsns: invalid pair'#13);

  Result:=_OpenSP(spSchedMgm,['@case','@sem','@psem','@week','@wday',
    '@npair','@grid','@sbid'],
    [sdlAvailSubject,Sem,PSem,week,wday,npair,grid,sbid]);
end;

// выбор поточ. занятий (strid,[wday,npair]) (14.02.06)
function TdmMain.sdl_GetLsns_s(strid: int64; wday: byte=0;
    npair: byte=0): _Recordset;
begin
  Assert(((wday>0)and(npair>0))or((wday=0)and(npair=0))or((wday<=6)and(npair<=7)),
    '937A3928-DE74-4B96-82D4-C3CBADD3BEB6'#13'sdl_GetLsns_s: invalid pair(wday,npair)=('+IntToStr(wday)+','+IntToStr(npair)+')'#13);

  if (wday>0) and (npair>0) then
    Result:=_OpenSP(spSchedMgm,['@case','@strid','@wday','@npair'],
        [sdlSelectStrm,strid,wday,npair])
  else
    Result:=_OpenSP(spSchedMgm,['@case','@strid'],[sdlSelectStrm,strid]);
end;

// выбор занятий нагрузки (22.08.2005)
// (lid,[wday,npair])
function TdmMain.sdl_GetLsns_l(lid: int64;
    wday: byte=0; npair: byte=0): _Recordset;
begin
  Assert(((wday>0)and(npair>0))or((wday=0)and(npair=0))or((wday<=6)and(npair<=7)),
    '0B09BCA3-EB37-43E6-B3B2-65F4F26D15F6'#13'sdl_GetLsns_l: invalid pair(wday,npair)='+IntToStr(wday)+','+IntToStr(npair)+')'#13);

  if (wday>0) and (npair>0) then
    Result:=_OpenSP(spSchedMgm,['@case','@lid','@wday','@npair'],
        [sdlSelectLsns,lid,wday,npair])
  else
    Result:=_OpenSP(spSchedMgm,['@case','@lid'],[sdlSelectLsns,lid]);
end;

// выбор возмож. занятий группы (03.03.06)
function TdmMain.sdl_GetAvail_g(week,wday,npair: byte; grid: int64): _Recordset;
begin
  Assert(week<=2,
    '85EF48D8-A83C-4420-9E13-BCEA8436C27E'#13'sdl_GetAvail_g: invalid week'#13);
  Assert((wday>=1) and (wday<=6),
    '1E112D73-D72A-452A-8E41-D5B3DC4514EA'#13'sdl_GetAvail_g: invalid wday'#13);
  Assert((npair>=1) and (npair<=7),
    '0D71D6F5-4726-425D-A397-1F0C31FE77D3'#13'sdl_GetAvail_g: invalid npair'#13);
  Assert(grid>0,
    '56F9016D-5C03-4195-BDB0-99DE3BEED026'#13'sdl_GetAvail_g: invalid grid'#13);

  Result:=_OpenSP(spSchedMgm,['@case','@sem','@psem','@week','@wday','@npair','@grid'],
    [sdlAvailGroup,Sem,PSem,week,wday,npair,grid]);
end;

// выбор возможн. занятий в п/сем (09/08/06)
function TdmMain.sdl_GetAvail_psem(grid: int64): _Recordset;
begin
  Assert(grid>0,
    'D0788F6D-A598-4F8C-89B5-CC31FA3E2091'#13'sdl_GetAvail_psem: invalid grid'#13);

  Result:=_OpenSP(spSchedMgm,['@case','@sem','@psem','@grid'],
      [sdlAvailPSem,Sem,PSem,grid]);
end;

// выбор расписания преп-ля (02/08/06)
function TdmMain.sdl_GetLsns_t(tid: int64): _Recordset;
begin
  Assert(tid>0,
    '7D529FFA-BA31-4FA0-83E9-ACFC1375E1B7'#13'sdl_GetLsns_t: invalid tid'#13);

  Result:=_OpenSP(spSchedMgm,['@case','@ynum','@sem','@psem','@tid'],
      [sdlSelectThr,Year,Sem,PSem,tid]);
end;

// выбор занятости аудитории (15/08/06)
function TdmMain.sdl_GetLsns_a(aid: int64): _Recordset;
begin
  Assert(aid>0,
    '2BC35FED-CB9E-4190-984E-9043F42D045A'#13'sdl_GetLsns_a: invalid aid'#13);

  Result:=_OpenSP(spSchedMgm,['@case','@ynum','@sem','@psem','@aid'],
      [sdlSelectAdr,Year,Sem,PSem,aid]);
end;

// TODO: Delete
{
// выбор дисциплин по 1ой букве
function TdmMain.sbj_GetLetter(letter: string): _Recordset;
begin
  Result:=OpenSP(spSubjMgm, ['@case','@letter'], [sbjSelLetter,letter]);
end;
}

// TODO: Delete
// замена дисциплины (15.03.06)
{
function TdmMain.sbj_Replace(sbid,new: int64): boolean;
var
  res: integer;
begin
  Assert((sbid>0) and (new>0),
    '60CE1DC9-CE09-4CCA-BB3D-F1C7CFB1B380'#13'sbj_Replace: invalid identifiers'#13);

  res:=ExecSP(spSubjMgm,['@case','@sbid','@new'],[sbjReplace,sbid,new]);
  Result:=(res=0);
end;
}

// выбор групп курса (25.01.06)
function TdmMain.grp_GetCourse(course: byte): _Recordset;
begin
  Result:=OpenSP(spGroupMgm,['@case','@ynum','@course'],[grpSelCrs,Year,course]);
end;

// выбор групп кафедры (25.01.06)
function TdmMain.grp_Get_k(kid: int64): _Recordset;
begin
  Result:=OpenSP(spGroupMgm, ['@case','@ynum','@kid'],[grpSelKaf,Year,kid]);
end;

// выбор раб. плана группы (25.01.06)
function TdmMain.wp_GetGrp(asem,apsem: byte; grid: int64): _Recordset;
begin
  Assert(((asem in [1,2]) and (apsem in [1,2])),
    '00B8F564-6C08-490E-AAC5-2783DA12BA28'#13'wp_GetGrp: invalid [asem] or [apsem]'#13);
    
  Result:=OpenSP(spWPMgm,['@case','@sem','@psem','@grid'],[wpSelect,asem,apsem,grid]);
end;

// добавление дисциплины в раб. план (25.01.06)
function TdmMain.wp_Create(grid, sbid, kid: int64; asem: byte;
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
function TdmMain.wp_Delete(wpid: int64): boolean;
var
  res: integer;
begin
  res:=ExecSP(spWPMgm,['@case','@wpid'],[wpDelete,wpid]);
  Result:=(res=0);
end;

// копирование дисциплины р.п. (06.02.06)
function TdmMain.wp_Copy(wpid, sbid: int64): int64;
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
function TdmMain.wp_CopyGrp(grid, ngrid: int64): boolean;
var
  res: integer;
begin
  // kid=ngrid
  res:=ExecSP(spWPMgm,['@case','@grid','@kid'],[wpCopyGrp,grid,ngrid]);
  Result:=(res=0);
end;

// удаление нагрузки (25.01.06)
function TdmMain.ld_Delete(lid: int64): boolean;
var
  res: integer;
begin
  res:=ExecSP(spWPMgm,['@case','@lid'],[wpDelLoad,lid]);
  Result:=(res=0);
end;

// добавление нагрузки на дисциплину (25.01.06)
function TdmMain.ld_Create(wpid: int64; ltype, apsem, hours: byte): int64;
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

// извлечение кафедры-исполнителя для дисциплины (28.02.06)
function TdmMain.wp_GetKaf(grid, sbid: int64): _Recordset;
begin
  Assert(grid>0,
    '150067BD-DCC8-4925-BC43-6638D66910AE'#13'wp_GetKaf: invalid grid'#13);
  Assert(sbid>0,
    '940964FE-633A-44D1-A4AE-63A6D876C14E'#13'wp_GetKaf: invalid sbid'#13);

  Result:=_OpenSP(spWPMgm,['@case','@sem','@grid','@sbid'],
    [wpGetKaf,Sem,grid,sbid]);
end;

// TODO: Delete
{
// обновление записи
// ATable - имя таблицы
// AKeyField - ключ. поле таблцы
// AId - id записи
// AField - имя поля
// AValue - зн-ние поля
function TdmMain.UpdateRecord(ATable,AKeyField: string; AId: int64;
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
      ShowMessage(E.Message);
      Result:=false;
    end;
  end;
end;
}

end.
