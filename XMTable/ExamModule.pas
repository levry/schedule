{
  Модуль данный (расписание занятий)
  v0.0.2 (28/11/06)
}
unit ExamModule;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ClientModule, ADODB, DB,
  STypes, ImgList;

type
  TdmExam = class(TClientDataModule)
    spExamMgm: TADOCommand;
    BtnImageList: TImageList;

  private
    { Private declarations }
    FPeriods: array[1..2] of TDatePeriod;

    function Get_Period: TDatePeriod;

  private
    function prd_Get_t(AYear: WORD): _Recordset;
    function xm_GetKaf_f: _Recordset;

    function Get_FID: integer;
    function Get_FName: string;

//  protected
    { Protected declarations }
//    function DoLoginUser: boolean; override;
//    procedure DoLogoffUser; override;

  public
    { Public declarations }
    function ChangeYear: boolean; override;

    property Period: TDatePeriod read Get_Period;

    function GetPerformKaf(AList: TStrings): boolean;

    function xm_GetGrp(grid: int64): _Recordset;
    function xm_Create(wpid: int64; xmtype: byte; xmtime: TDateTime;
      hgrp: boolean; aid: int64): boolean;
    function xm_Delete(wpid: int64; xmtype: byte): boolean;
    function xm_SetAdr(wpid: int64; xmtype: byte; aid: int64): boolean;
    function xm_SetHGrp(wpid: int64; hgrp: boolean): boolean;
    function xm_SetTime(wpid: int64; xmtype: byte; xmtime: TDateTime): boolean;
    function xm_GetFreeAid_f(fid: integer; xmtime: TDateTime): _Recordset;
    function xm_GetFreeAid_w(wpid: int64; xmtime: TDateTime): _Recordset;
    function xm_GetAvail_wp(wpid: int64; xmtype: byte; xmtime: TDateTime): _Recordset;
    function xm_GetAvail_grp(grid: int64; xmtype: byte; xmtime: TDateTime): _Recordset;
    function xm_GetFcl(fid: integer; xmtype: byte): _Recordset;
    function xm_Get_k(kid: int64): _Recordset;
    function xm_Get_a(kid: int64): _Recordset;

    property FacultyID: integer read Get_FID;
    property FacultyName: string read Get_FName;

  end;

var
  dmExam: TdmExam;

implementation

uses
  DateUtils, Types,
  SConsts, SStrings, SUtils, StringListDlg, BaseModule;

{$R *.dfm}

{ TdmExam }

// возвращает id текущего факультета (13/09/06)
function TdmExam.Get_FID: integer;
begin
  Result:=GetID(FacultyList[0]);
end;

// возвращает название текущего факультета (13/09/06)
function TdmExam.Get_FName: string;
begin
  Result:=FacultyList.ValueFromIndex[0];
end;

function TdmExam.Get_Period: TDatePeriod;
begin
  Assert(Sem in [1,2],
    '293BFC40-FB0F-40B1-8BD0-DB0FE595F228'#13'Get_Period: invalid Sem'#13);

  Result:=FPeriods[Sem];
end;

// смена(выбор) уч. года (03.05.06)
function TdmExam.ChangeYear: boolean;

  function LoadExamPeriod(AYear: WORD): boolean;
  var
    rs: _Recordset;
    i: byte;
    b, e: TDateTime;
  begin
    Result:=false;

    rs:=prd_Get_t(AYear);
    if Assigned(rs) then
    try
      Result:=(rs.RecordCount=2);
      while not rs.EOF do
      begin
        i:=rs.Fields['sem'].Value;
        b:=rs.Fields['p_start'].Value;
        e:=rs.Fields['p_end'].Value;
        FPeriods[i].dbegin:=b;
        FPeriods[i].dend:=e;
        rs.MoveNext;
      end;
    finally
      rs.Close;
      rs:=nil;
    end;
  end;  // proc LoadExamPeriod

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
          if Result then
            if LoadExamPeriod(y) then Year:=y;
        end;
    finally
      list.Free;
      list:=nil;
    end;
  end
  else raise Exception.Create(rsErrNoConnect);
end;

{
// начало сеанса пользователя (01/08/06)
function TdmExam.DoLoginUser: boolean;
begin
  Result:=ChangeYear;
end;
}

// завершение сеанса (01/08/06)
{
procedure TdmExam.DoLogoffUser;
begin
  // TODO: Сохранять имзенен. настройки в БД для пользователя
end;
}

// выбор расписания экз/конс (01.05.2006)
function TdmExam.xm_GetGrp(grid: int64): _Recordset;
begin
  Assert(grid>0,
    'F891E59C-6814-4E69-84B7-81001798AC17'#13'xm_GetGrp: invalid grid'#13);

  Result:=_OpenSP(spExamMgm,['@case','@grid','@sem'],[xmSelect,grid,Sem]);
end;

// добавление конс/экз (01.05.2005)
function TdmExam.xm_Create(wpid: int64; xmtype: byte; xmtime: TDateTime;
    hgrp: boolean; aid: int64): boolean;
var
  res: integer;
  vaid: Variant;
begin
  Assert(wpid>0,
    'C62B091F-3C0B-474C-B7D6-40A9238180CF'#13'xm_Create: invalid wpid'#13);
  Assert(xmtype in [0,1],
    '6CA2F592-43E7-47E0-AB74-2E16AFFA1EE7'#13'xm_Create: invalid xmtype'#13);

  if aid>0 then vaid:=aid else vaid:=Null;
  res:=ExecSP(spExamMgm,['@case','@wpid','@xmtype','@start','@hgrp','@aid'],
      [xmAdd,wpid,xmtype,xmtime,byte(hgrp),vaid]);
  Result:=(res=0);
end;

// ужаление конс/экз (01.05.2006)
function TdmExam.xm_Delete(wpid: int64; xmtype: byte): boolean;
var
  res: integer;
begin
  Assert(wpid>0,
    '86F66544-C047-42A4-97C4-4EF8D0AC2B65'#13'xm_Delete: invalid wpid'#13);
  Assert(xmtype in [0,1],
    'A516A87A-7AC2-4862-8427-9F7940E0713D'#13'xm_Delete: invalid xmtype'#13);

  res:=ExecSP(spExamMgm,['@case','@wpid','@xmtype'],[xmDelete,wpid,xmtype]);
  Result:=(res=0);
end;

// изм-ние аудитории экз/конс (02.05.2006)
function TdmExam.xm_SetAdr(wpid: int64; xmtype: byte; aid: int64): boolean;
var
  res: integer;
  vaid: Variant;
begin
  Assert(wpid>0,
    '231516F6-0A88-4A2A-B14A-47DDC49F25CD'#13'xm_SetAdr: invalid wpid'#13);
  Assert(xmtype in [0,1],
    '60B8F4CF-8547-465F-B868-7ACE658882BD'#13'xm_SetAdr: invalid xmtype'#13);

  if aid>0 then vaid:=aid else vaid:=Null;
  res:=ExecSP(spExamMgm,['@case','@wpid','@xmtype','@aid'],
    [xmSetAdr,wpid,xmtype,vaid]);
  Result:=(res=0);
end;

// смена состава группы (02.05.2006)
function TdmExam.xm_SetHGrp(wpid: int64; hgrp: boolean): boolean;
var
  res: integer;
begin
  Assert(wpid>0,
    '9705730F-6091-4CCA-B768-6FC0EE31DA95'#13'xm_SetHGrp: invalid wpid'#13);

  res:=ExecSP(spExamMgm,['@case','@wpid','@hgrp'],[xmSetHGrp,wpid,byte(hgrp)]);
  Result:=(res=0);
end;

// смена времени проведения экз/конс (02.05.2006)
function TdmExam.xm_SetTime(wpid: int64; xmtype: byte; xmtime: TDateTime): boolean;
var
  res: integer;
begin
  Assert(wpid>0,
    '80A94C59-8433-4B62-865E-F167E4A5626C'#13'xm_SetTime: invalid wpid'#13);
  Assert(xmtype in [0,1],
    'B0CE3633-CA0F-44B4-B55A-7307D785C3D2'#13'xm_SetTime: invalid xmtype'#13);

  res:=ExecSP(spExamMgm,['@case','@wpid','@xmtype','@start'],
    [xmSetTime,wpid,xmtype,xmtime]);
  Result:=(res=0);
end;

// извлечение периода экз. сессии (02.05.2006)
function TdmExam.prd_Get_t(AYear: WORD): _Recordset;
begin
  Result:=_OpenSP(spExamMgm,['@case','@ynum'],[xmGetPeriods,AYear]);
end;

// выбор свобод. ауд-рий фак-та (05.05.06)
function TdmExam.xm_GetFreeAid_f(fid: integer; xmtime: TDateTime): _Recordset;
begin
  Assert(fid>0,
    '3D692A7A-F5CC-4DB6-9521-ADD7ECCDB708'#13'xm_GetFreeAid_f: invalid fid'#13);

  Result:=_OpenSP(spExamMgm,['@case','@fid','@start'],
      [xmGetFreeAudFac,fid,xmtime]);
end;

// выбор свобод. ауд-рий каф-исп (05.05.06)
function TdmExam.xm_GetFreeAid_w(wpid: int64; xmtime: TDateTime): _Recordset;
begin
  Assert(wpid>0,
    'F7A0EBD3-4B74-4BD2-ACDC-37BE782199D4'#13'xm_GetFreeAud_w: invalid wpid'#13);

  Result:=_OpenSP(spExamMgm,['@case','@wpid','@start'],
      [xmGetFreeAudWP,wpid,xmtime]);
end;

// выбор возмож. экз/конс для дисципилны (08.05.06)
function TdmExam.xm_GetAvail_wp(wpid: int64; xmtype: byte; xmtime: TDateTime): _Recordset;
begin
  Assert(wpid>0,
    '1D1CDA42-3FB5-4AB6-9CC8-03F42D92A979'#13'xm_GetAvail_wp: invalid wpid'#13);
  Assert(xmtype in [0,1],
    '40CA056B-C6B0-4569-9CEE-A8923EC8139B'#13'xm_GetAvail_wp: invalid xmtype'#13);
  Assert((CompareDate(xmtime,Period.dbegin)<>LessThanValue)
    and (CompareDate(xmtime,Period.dend)<>GreaterThanValue),
    '698C76ED-EAA0-4E48-AA2B-657DDBEEA125'#13'xm_GetAvail_wp: xmtime out range current period'#13);

  Result:=_OpenSP(spExamMgm,['@case','@wpid','@xmtype','@start'],
      [xmGetAvailWP,wpid,xmtype,xmtime]);
end;

// выбор возмож. экз/конс для группы (08.05.06)
function TdmExam.xm_GetAvail_grp(grid: int64; xmtype: byte; xmtime: TDateTime): _Recordset;
begin
  Assert(grid>0,
    '60F9F72A-D2D2-45CC-8338-B53EA28D9C2F'#13'xm_GetAvail_grp: invalid grid'#13);
  Assert(xmtype in [0,1],
    'F4763F34-CDDE-485C-8E45-45E8E8040D7E'#13'xm_GetAvail_grp: invalid xmtype'#13);
  Assert((CompareDate(xmtime,Period.dbegin)<>LessThanValue)
    and (CompareDate(xmtime,Period.dend)<>GreaterThanValue),
    '5A628559-2874-4731-8B86-543169AEAF65'#13'xm_GetAvail_grp: xmtime out range current period'#13);

  Result:=_OpenSP(spExamMgm,['@case','@grid','@sem','@xmtype','@start'],
      [xmGetAvailGrp, grid, Sem, xmtype, xmtime]);
end;

// выбор расписания экз/конс факультета (11.05.06)
function TdmExam.xm_GetFcl(fid: integer; xmtype: byte): _Recordset;
begin
  Assert(fid>0,
    'FC305CCD-7648-4A63-BCF2-8A0CE62F5228'#13'xm_GetFcl: invalid fid'#13);
  Assert(xmtype in [0,1],
    '9C553DCF-C02A-4291-BA86-0ED6AACA1D28'#13'xm_GetFcl: invalid xmtype'#13);

  Result:=_OpenSP(spExamMgm,['@case','@ynum','@sem','@fid','@xmtype'],
      [xmGetFaculty,Year,Sem,fid,xmtype]);
end;

// выбор расписания экз/конс кафедры  (28/11/06)
function TdmExam.xm_Get_k(kid: int64): _Recordset;
begin
  Assert(kid>0,
    '20FC71FE-1227-4873-89ED-2185F1FC930F'#13'xm_GetKaf: invalid kid'#13);

  Result:=_OpenSP(spExamMgm,['@case','@ynum','@sem','@fid','@kid'],
      [xmGetKafedra,Year,Sem,FacultyID,kid]);
end;

// выбор кафедр-исполнителей экзаменов  (29/11/06)
function TdmExam.xm_GetKaf_f: _Recordset;
begin
  Result:=_OpenSP(spExamMgm,['@case','@ynum','@sem','@fid'],
      [xmGetPerformKaf,Year,Sem,FacultyID]);
end;

// список кафедр-исполнителей экзаменов  (29/11/06)
function TdmExam.GetPerformKaf(AList: TStrings): boolean;
begin
  Result:=RecordsetToList(xm_GetKaf_f(),AList,'kName ASC','kid','kName','');
end;

// выбор занятости аудиторий  (15/12/06)
function TdmExam.xm_Get_a(kid: int64): _Recordset;
var
  vkid: Variant;
begin
  if kid>0 then vkid:=kid else vkid:=Null;

  Result:=_OpenSP(spExamMgm,['@case','@ynum','@sem','@fid','@kid'],
    [xmGetLoadAdry,Year,Sem,FacultyID,vkid]);
end;

end.
