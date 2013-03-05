{
  Объекты расписания экзаменов
  v0.0.1  (01.05.2006)
  (C) Leonid Riskov, 2006
}
unit SExams;

interface

uses
  Contnrs, Classes, ADOInt, STypes;

type
  TXMType = (xmtExam=0, xmtCons=1);

  TBaseExam = class;
  TXMGroup = class;
  TXMTable = class;

  // события
  TXMNotifyEvent = procedure(Sender: TBaseExam) of object;
  TXMAllowEvent = procedure(Sender: TBaseExam; var Allow: boolean) of object;
  TXMUpdateEvent = procedure(Sender: TBaseExam; UpdateFlag: WORD; var Allow: boolean) of object;
//  TXMPeriodEvent = procedure(Sender: TXMTable; var ABegin, AEnd: TDateTime) of object;

  // базовый класс экз/конс
  TBaseExam = class
  private
    fwpid: int64;
    fxmtype: TXMType;      // тип
    fsubject: string;      // sbName - название дисциплины
    fsbsmall: string;      // sbSmall - сокращ. название дисциплины
    fteacher: string;      // tName[0];tName[1]

    fxmtime: TDatetime;    // время (начало)
    fsubgrp: boolean;      // подгруппа
    fauditory: string;     // aid=aName

    procedure SetSubgrp(Value: boolean);
    procedure SetAuditory(Value: string);
    procedure SetTime(Value: TDateTime);
    function Get_aid: int64;

  protected
    function DoChangeSubgrp(Value: boolean): boolean; virtual;
    function DoChangeAuditory(Value: string): boolean; virtual;
    function DoChangeTime(Value: TDateTime): boolean; virtual;

  public
    procedure Assign(AExam: TBaseExam); virtual;
    function AssignFrom(AExam: TBaseExam): boolean;
    function GetTeacherCount: integer;
    function GetTeacherOfIndex(index: integer): string;

    property wpid: int64 read fwpid;
    property xmtype: TXMType read fxmtype;
    property subject: string read fsubject;
    property sbsmall: string read fsbsmall;
    property teacher: string read fteacher;

    property xmtime: TDatetime read fxmtime write SetTime;
    property subgrp: boolean read fsubgrp write SetSubgrp;
    property auditory: string read fauditory write SetAuditory;

    property aid: int64 read Get_aid;

  end;

  // класс экз/конс
  TExam = class(TBaseExam)
  private
    FParent: TXMGroup;

  protected
    function DoChangeSubgrp(Value: boolean): boolean; override;
    function DoChangeAuditory(Value: string): boolean; override;
    function DoChangeTime(Value: TDateTime): boolean; override;

  public
    constructor Create(AParent: TXMGroup); overload;
    constructor Create(AParent: TXMGroup; AExam: TBaseExam); overload;

    property Parent: TXMGroup read FParent;

  end;

  // класс возмож. экз/конс
  TAvailExam = class(TBaseExam)
  private
    fexists: boolean; // существование экз/конс в расписании
    ftfree: boolean;  // занятость преп-лей
    forder: boolean;  // очередность экз/конс
    ffull: boolean;   // возможность поставить пол. грп
    fhalf: boolean;   // возможность поставить подгрп

  protected
    function DoChangeSubgrp(Value: boolean): boolean; override;
    function DoChangeTime(Value: TDateTime): boolean; override;

  public
    constructor Create(axmtype: TXMType; axmtime: TDateTime);

    function Check: boolean;
    function CheckedSub: boolean;

    property exists: boolean read fexists;
    property tfree: boolean read ftfree;
    property order: boolean read forder;
    property full: boolean read ffull;
    property half: boolean read fhalf; 
  end;

  // класс расписания экз/конс группы
  TXMGroup = class
  private
    FParent: TXMTable;

    fid: int64;
    fname: string;
    FExams: TObjectList;

    function GetExamCount: integer;
    function GetExamIndex(index: integer): TExam;

  private
    function InternalInsert(AExam: TExam): integer;
    procedure InternalDelete(AExam: TExam);
    function InternalUpdate(AExam: TExam; AUpdateFlag: WORD): boolean;

    function FindInverseExam(wpid: int64; xmtype: TXMType): TExam;
    function FindExamOfDate(xmtime: TDateTime): TExam;
    function CheckExam(AExam: TBaseExam): boolean;

  public
    constructor Create(AId: int64; AName: string; AParent: TXMTable);
    destructor Destroy; override;

    function AddExam(AExam: TBaseExam): integer;
    function DelExam(AExam: TExam): boolean;
    function FindExam(wpid: int64; xmtype: TXMType): TExam;
    function CheckPlace(wpid: int64; xmtype: TXMType; xmtime: TDateTime): boolean;
    function CheckTime(xmtime: TDateTime): boolean;
    function NumOfTime(xmtime: TDateTime): integer;
    function ExamOfTime(xmtime: TDateTime; index: integer): TExam;

    procedure Update;
    procedure Clear;

    property grid: int64 read fid;
    property grName: string read fname;
    property ExamCount: integer read GetExamCount;
    property Exams[index: integer]: TExam read GetExamIndex;

  end;

  // класс расписание экз/конс групп
  TXMTable = class
  private
    FGroups: TObjectList;
    FPeriod: TDatePeriod;                        // экз. сессия

    procedure SetPeriod(Value: TDatePeriod);
    function GetGroupIndex(index: integer): TXMGroup;
    function GetCount: integer;

  private
    { events }
    FOnGroupInsert: TNotifyEvent;                 // добавление группы
    FOnGroupDelete: TNotifyEvent;                 // удаление группы
    FOnGroupUpdate: TNotifyEvent;                 // обновление группы

    FOnExamInsert: TXMAllowEvent;                 // добавление экз/конс
    FOnExamDelete: TXMAllowEvent;                 // удаление экз/конс
    FOnExamUpdate: TXMUpdateEvent;                // обновление экз/конс

    FonChangePeriod: TNotifyEvent;                // смена периода

    procedure DoGroupUpdate(group: TXMGroup);
    procedure DoGroupInsert(group: TXMGroup);
    procedure DoGroupDelete(group: TXMGroup);

    function DoExamInsert(AExam: TBaseExam): boolean;
    function DoExamDelete(AExam: TBaseExam): boolean;
    function DoExamUpdate(AExam: TBaseExam; AUpdateFlag: WORD): boolean;

    procedure DoChangePeriod;

  public
    constructor Create(APeriod: TDatePeriod);
    destructor Destroy; override;

    function AddGroup(const grid: int64; const grName: string): integer;
    procedure DelGroup(const grid: int64);
    procedure Clear;
    procedure Update;

    function FindGroup(const grid: int64): integer;
    function GroupByGrid(const grid: int64): TXMGroup;
    function GroupByName(const grName: string): TXMGroup;

    property Groups[index: integer]: TXMGroup read GetGroupIndex;
    property GroupCount: integer read GetCount;
    property Period: TDatePeriod read FPeriod write SetPeriod;

    property OnGroupInsert: TNotifyEvent read FOnGroupInsert write FOnGroupInsert;
    property OnGroupDelete: TNotifyEvent read FOnGroupDelete write FOnGroupDelete;
    property OnGroupUpdate: TNotifyEvent read FOnGroupUpdate write FOnGroupUpdate;
    property OnExamInsert: TXMAllowEvent read FOnExamInsert write FOnExamInsert;
    property OnExamDelete: TXMAllowEvent read FOnExamDelete write FOnExamDelete;
    property OnExamUpdate: TXMUpdateEvent read FOnExamUpdate write FOnExamUpdate;
    property OnChangePeriod: TNotifyEvent read FOnChangePeriod write FOnChangePeriod;
//    property OnGetPeriod: TXMPeriodEvent read FOnGetPeriod write FOnGetPeriod;
  end;

const
  FLAG_XM_TIME      = 1;   // флаг изм-ния времени
  FLAG_XM_SUBGRP    = 2;   // флаг изм-ния подгруппы
  FLAG_XM_AUDITORY  = 4;   // флаг изм-ния аудитории

type
  TCompareExamResult = (cerEquals, cerNotEquals, cerOthers);

function InRangeDate(const AValue, AMin, AMax: TDateTime): boolean;

//procedure InitExam(AExam: TExam; AFields: Fields);
//procedure ReInitExam(AExam: TExam; AFields: Fields);

//function InternalInsert(AExam: TExam; AGroup: TXMGroup): integer;
function CompareExam(const A, B: TBaseExam): TCompareExamResult;
function InverseXMType(AXMType: TXMType): TXMType;
//function GetTeacherCount(AExam: TBaseExam): integer;
//function GetTeacherIndex(AExam

procedure InitGroup(AGroup: TXMGroup; ARecordset: _Recordset);
procedure InitSingleExam(AExam: TAvailExam; ARecordset: _Recordset);
procedure InitAvailList(AXMType: TXMType; AXMTime: TDateTime;
    AList: TObjectList; ARecordset: _Recordset);

implementation

uses
  Variants, DateUtils, Types, StrUtils,
  SUtils;

// указывает, что дата находится внутри области (AMin,AMax)
function InRangeDate(const AValue, AMin, AMax: TDateTime): boolean;
begin

  if AMin<AMax then
    Result:=(CompareDate(AValue,AMin)=GreaterThanValue)
           and (CompareDate(AValue,AMax)=LessThanValue)
  else
    Result:=(CompareDate(AValue,AMax)=GreaterThanValue)
           and (CompareDate(AValue,AMin)=LessThanValue)
end;

{
function InternalInsert(AExam: TExam; AGroup: TXMGroup): integer;
begin
  Assert(Assigned(AGroup),
    'B68836DE-CE62-4C9C-9451-E560356C5465'#13'InternalInsert: AGroup is nil'#13);
  Assert(Assigned(AExam),
    '18882418-E28A-45B0-B296-A7248D336094'#13'InternalInsert: AExam is nil'#13);

  Result:=AGroup.InternalInsert(AExam);
end;
}

// загрузка расписания экз/конс из набора данных
procedure InitGroup(AGroup: TXMGroup; ARecordset: _Recordset);

  procedure InitExam(AExam: TExam; AFields: Fields);
  begin
    AExam.fwpid:=AFields['wpid'].Value;
    AExam.fxmtype:=AFields['xmtype'].Value;
    AExam.fsubject:=VarToStr(AFields['sbName'].Value);
    AExam.fsbsmall:=VarToStr(AFields['sbSmall'].Value);
    AExam.fxmtime:=VarToDateTime(AFields['xmtime'].Value);
    AExam.fsubgrp:=AFields['hgrp'].Value;

    if not VarIsNull(AFields['Initials'].Value) then
      AExam.fteacher:=VarToStr(AFields['psmall'].Value)+' '+VarToStr(AFields['Initials'].Value);
    if not VarIsNull(AFields['aid'].Value) then
      AExam.fauditory:=VarToStr(AFields['aid'].Value)+'='+VarToStr(AFields['aName'].Value);
  end;

  procedure ReInitExam(AExam: TExam; AFields: Fields);
  begin
    AExam.fteacher:=AExam.fteacher+';'+
        VarToStr(AFields['psmall'].Value)+' '+VarToStr(AFields['Initials'].Value);
  end;

var
  exam: TExam;
  wpid: int64;
  xmtype: byte;

  vwpid: int64;
  vxmtype: byte;
begin
  if IsFlag(ARecordset.State, adStateOpen) then
  begin
    ARecordset.Sort:='wpid ASC, xmtype ASC, Initials ASC';

    exam:=nil;
    wpid:=-1;
    xmtype:=255;

    while not ARecordset.EOF do
    begin
      vwpid:=ARecordset.Fields['wpid'].Value;
      vxmtype:=ARecordset.Fields['xmtype'].Value;

      if (wpid<>vwpid) or (xmtype<>vxmtype) then
      begin
        exam:=TExam.Create(AGroup);
        InitExam(exam, ARecordset.Fields);
        wpid:=exam.wpid;
        xmtype:=integer(exam.xmtype);
        AGroup.InternalInsert(exam);
      end
      else
        if Assigned(exam) then ReInitExam(exam, ARecordset.Fields);

      ARecordset.MoveNext();
    end;

  end;  // if(ARecordset is open)
end;

// инициализация AvailExam
procedure InitSingleExam(AExam: TAvailExam; ARecordset: _Recordset);

  procedure InitExam(exam: TAvailExam; fields: Fields);
  begin
    exam.fwpid:=fields['wpid'].Value;

    exam.fsubject:=VarToStr(fields['sbName'].Value);
    exam.fsbsmall:=VarToStr(fields['sbSmall'].Value);
    exam.fauditory:='';

    exam.fexists:=(fields['exists'].Value=1);
    exam.ftfree:=(fields['tfree'].Value=1);
    exam.forder:=(fields['order'].Value=1);
    exam.ffull:=(fields['full'].Value=1);
    exam.fhalf:=(fields['half'].Value=1);

    if not VarIsNull(fields['Initials'].Value) then
      exam.fteacher:=VarToStr(fields['psmall'].Value)
                      +' '+VarToStr(fields['Initials'].Value);

    exam.fsubgrp:=(exam.half and (not exam.full));
  end;

  procedure ReInitExam(exam: TAvailExam; fields: Fields);
  begin
    exam.fteacher:=exam.fteacher
        +';'+VarToStr(fields['psmall'].Value)
        +' '+VarToStr(fields['Initials'].Value);
  end;

begin
  InitExam(AExam,ARecordset.Fields);
  ARecordset.MoveNext;

  while (AExam.fwpid=ARecordset.Fields['wpid'].Value) and (not ARecordset.EOF) do
  begin
    ReInitExam(AExam, ARecordset.Fields);
    ARecordset.MoveNext;
  end;
end;

// загрузка списка возмож. экз/конс
procedure InitAvailList(AXMType: TXMType; AXMTime: TDateTime;
    AList: TObjectList; ARecordset: _Recordset);

  procedure InitExam(AExam: TAvailExam; AFields: Fields);
  begin
    AExam.fwpid:=AFields['wpid'].Value;

    AExam.fsubject:=VarToStr(AFields['sbName'].Value);
    AExam.fsbsmall:=VarToStr(AFields['sbSmall'].Value);
    AExam.fauditory:='';

    AExam.fexists:=(AFields['exists'].Value=1);
    AExam.ftfree:=(AFields['tfree'].Value=1);
    AExam.forder:=(AFields['order'].Value=1);
    AExam.ffull:=(AFields['full'].Value=1);
    AExam.fhalf:=(AFields['half'].Value=1);

    if not VarIsNull(AFields['Initials'].Value) then
      AExam.fteacher:=VarToStr(AFields['psmall'].Value)
                      +' '+VarToStr(AFields['Initials'].Value);

    AExam.fsubgrp:=(AExam.half and (not AExam.full));
  end;

  procedure ReInitExam(AExam: TAvailExam; AFields: Fields);
  begin
    AExam.fteacher:=AExam.fteacher
        +';'+VarToStr(AFields['psmall'].Value)
        +' '+VarToStr(AFields['Initials'].Value);
  end;

var
  exam: TAvailExam;
  wpid, vwpid: int64;
begin
  if IsFlag(ARecordset.State, adStateOpen) then
  begin
    exam:=nil;
    wpid:=-1;

    ARecordset.Sort:='sbName ASC, Initials ASC';
    while not ARecordset.EOF do
    begin
      vwpid:=ARecordset.Fields['wpid'].Value;

      if wpid<>vwpid then
      begin
        exam:=TAvailExam.Create(AXMType, AXMTime);
        InitExam(exam, ARecordset.Fields);
        wpid:=exam.wpid;
        AList.Add(exam);
      end
      else
        if Assigned(exam) then ReInitExam(exam, ARecordset.Fields);

      ARecordset.MoveNext();
    end;

  end;
end;

// сравнение экз/конс
// cerEquals - равны
// cerNotEquals - неравны (но wpid & xmtype равны)
// cerOther - несравнимы (разные wpid | xmtype)
function CompareExam(const A, B: TBaseExam): TCompareExamResult;
begin
  Result:=cerEquals;
  if (A.fwpid<>B.fwpid) or (A.fxmtype<>B.fxmtype) then Result:=cerOthers else
    if (A.fxmtime<>B.fxmtime) or (A.fsubgrp<>B.fsubgrp) or (A.fauditory<>B.fauditory) then
      Result:=cerNotEquals;
end;

// инвертировать TXMType (xmtExam->xmtCons, xmtCons->xmtExam)
function InverseXMType(AXMType: TXMType): TXMType;
begin
  if AXMType=xmtExam then Result:=xmtCons else Result:=xmtExam;
end;

// возвращает кол-во преп-лей
{
function GetTeacherCount(AExam: TBaseExam): integer;
var
  i: integer;
begin
  if AExam.fteacher<>'' then
  begin
    Result:=1;
    i:=0;
    repeat
      i:=Pos(';',AExam.fteacher[i+1]);
      if i>0 then inc(Result);
    until i=0
  end
  else Result:=0;
end;
}

{ TBaseExam }

procedure TBaseExam.SetSubgrp(Value: boolean);
var
  old: boolean;
begin
  if fsubgrp<>value then
  begin
    old:=fsubgrp;
    fsubgrp:=Value;
    if not DoChangeSubgrp(Value) then fsubgrp:=old;
  end;
end;

procedure TBaseExam.SetAuditory(Value: string);
var
  old: string;
begin
  if fauditory<>Value then
  begin
    old:=fauditory;
    fauditory:=Value;
    if not DoChangeAuditory(Value) then fauditory:=old;
  end;
end;

procedure TBaseExam.SetTime(Value: TDateTime);
var
  old: TDateTime;
begin
  if fxmtime<>Value then
  begin
    old:=fxmtime;
    fxmtime:=Value;
    if not DoChangeTime(Value) then fxmtime:=old;
  end;
end;

function TBaseExam.DoChangeSubgrp(Value: boolean): boolean;
begin
  Result:=true;
end;

function TBaseExam.DoChangeAuditory(Value: string): boolean;
begin
  Result:=true;
end;

function TBaseExam.DoChangeTime(Value: TDateTime): boolean;
begin
  Result:=true;
end;

// полное копирование полей
procedure TBaseExam.Assign(AExam: TBaseExam);
begin
  fwpid:=AExam.fwpid;
  fxmtype:=AExam.fxmtype;
  fsubject:=AExam.fsubject;
  fsbsmall:=AExam.fsbsmall;
  fteacher:=AExam.fteacher;

  fxmtime:=AExam.fxmtime;
  fsubgrp:=AExam.fsubgrp;
  fauditory:=AExam.fauditory;
end;

// копирование/изм-ние полей (xmtime,audtiory,subgrp)
function TBaseExam.AssignFrom(AExam: TBaseExam): boolean;
begin
  Result:=(CompareExam(Self, AExam)=cerNotEquals);
  if Result then
  begin
    if fauditory<>AExam.fauditory then auditory:=AExam.fauditory;
    if fxmtime<>AExam.fxmtime then xmtime:=AExam.fxmtime;
    if fsubgrp<>AExam.fsubgrp then subgrp:=AExam.fsubgrp;
  end;
end;


function TBaseExam.Get_aid: int64;
begin
  Result:=GetID(fauditory);
end;

// возвращает кол-во преп-лей (14.05.06)
function TBaseExam.GetTeacherCount: integer;
var
  i, len: integer;
begin
  len:=Length(fteacher);
  if len>0 then
  begin
    Result:=1;

    i:=1;
    while i<=len do
    begin
      if fteacher[i]=';' then inc(Result);
      inc(i);
    end;
  end
  else Result:=0;
end;

// возвращает преп-ля по индексу (14.05.06)
function TBaseExam.GetTeacherOfIndex(index: integer): string;
begin
  Result:=TextLine(fteacher,';',index);
end;
{
function TBaseExam.GetTeacherOfIndex(index: integer): string;
var
  b, e: integer;
  j, len: integer;
begin
  Result:='';

  j:=0;

  len:=Length(fteacher);
  if len>0 then
  begin
    b:=1;
    e:=1;
    while (b<=len) and (e<=len) do
    begin
      if j=index then
        if fteacher[e]=';' then break else inc(e)
      else
        if fteacher[b]=';' then
        begin
          inc(b);
          e:=b;
          inc(j)
        end
        else inc(b);
    end;
    if e>b then Result:=Copy(fteacher, b, e-b);
  end;
end;
}

{ TExam }

constructor TExam.Create(AParent: TXMGroup);
begin
  FParent:=AParent;
end;

constructor TExam.Create(AParent: TXMGroup; AExam: TBaseExam);
begin
  FParent:=AParent;
  Assign(AExam);
end;

function TExam.DoChangeSubgrp(Value: boolean): boolean;
begin
  Result:=FParent.InternalUpdate(Self, FLAG_XM_SUBGRP);
end;

function TExam.DoChangeAuditory(Value: string): boolean;
begin
  Result:=FParent.InternalUpdate(Self, FLAG_XM_AUDITORY);
end;

function TExam.DoChangeTime(Value: TDateTime): boolean;
begin
  Result:=FParent.InternalUpdate(Self, FLAG_XM_TIME);
end;

{ TAvailExam }

constructor TAvailExam.Create(axmtype: TXMType; axmtime: TDateTime);
begin
  fxmtype:=axmtype;
  fxmtime:=axmtime;
end;

function TAvailExam.DoChangeSubgrp(Value: boolean): boolean;
begin
  Result:=CheckedSub;
end;

function TAvailExam.DoChangeTime(Value: TDateTime): boolean;
begin
  Assert(false,
    'F31FE337-1960-4B02-AAE2-A45C243F315E'#13'TAvailExam.DoChangeTime: don`t change time'#13);

  Result:=false;
end;

// проверка доступности экз/конс
function TAvailExam.Check: boolean;
begin
  Result:=((not fexists) and (ffull or fhalf) and forder and ftfree);
end;

// проверка возмож-ти смены подгрп
function TAvailExam.CheckedSub: boolean;
begin
  Result:=(ffull and fhalf);
end;

{ TXMGroup }

constructor TXMGroup.Create(AId: int64; AName: string; AParent: TXMTable);
begin
  FExams:=TObjectList.Create;

  fid:=AId;
  fname:=AName;
  FParent:=AParent;
end;

function TXMGroup.AddExam(AExam: TBaseExam): integer;
var
  exam: TExam;
begin
  Assert(Assigned(AExam),
    '4F226AA8-98DF-4AA6-B04B-935E1A47EBEC'#13'TXMGroup.AddExam: AExam is nil'#13);

  Result:=-1;
  if CheckExam(AExam) then
  begin
    exam:=TExam.Create(Self,AExam);
    if FParent.DoExamInsert(exam) then Result:=InternalInsert(exam)
      else exam.Free;
  end;
end;

function TXMGroup.DelExam(AExam: TExam): boolean;
begin
  Assert(Assigned(AExam),
    'AD0755BE-C3C1-4009-A58B-0E59D9F12B78'#13'TXMGroup.DelExam: AExam is nil'#13);

  Result:=FParent.DoExamDelete(AExam);
  if Result then InternalDelete(AExam);
end;

destructor TXMGroup.Destroy;
begin
  FExams.Free;
  inherited Destroy;
end;

procedure TXMGroup.InternalDelete(AExam: TExam);
begin
  Assert(Assigned(AExam),
    'F6C8D555-8AE6-4DA3-9CDE-D2512217ABC1'#13'TXMGroup.InternalDelete: AExam is nil'#13);

  FExams.Remove(AExam);
end;

function TXMGroup.InternalInsert(AExam: TExam): integer;
begin
  Assert(Assigned(AExam),
    '8CDC3E73-99C8-483A-AB93-C2212227775A'#13'TXMGroup.InternalInsert: AExam is nil'#13);

  AExam.FParent:=Self;
  Result:=FExams.Add(AExam);
end;

procedure TXMGroup.Update;
begin
  Assert(Assigned(FParent),
    'E77E6A29-BC87-43AE-9A8D-1276327D72AE'#13'TXMGroup.Update: FParent is nil'#13);

  Clear;
  FParent.DoGroupUpdate(Self);
end;

function TXMGroup.InternalUpdate(AExam: TExam; AUpdateFlag: WORD): boolean;
begin
  Result:=FParent.DoExamUpdate(AExam, AUpdateFlag)
end;

procedure TXMGroup.Clear;
begin
  FExams.Clear;
end;

// поиск экз/конс (07.05.06)
function TXMGroup.FindExam(wpid: int64; xmtype: TXMType): TExam;
var
  i: integer;
  exam: TExam;
begin
  Result:=nil;

  for i:=0 to FExams.Count-1 do
  begin
    exam:=TExam(FExams[i]);
    if (exam.wpid=wpid) and (exam.xmtype=xmtype) then
    begin
      Result:=exam;
      break;
    end;
  end;
end;

// поиск экз/конс по дате (07.05.06)
function TXMGroup.FindExamOfDate(xmtime: TDateTime): TExam;
var
  i: integer;
  exam: TExam;
begin
  Result:=nil;
  for i:=0 to FExams.Count-1 do
  begin
    exam:=TExam(FExams[i]);
    if CompareDate(xmtime, exam.xmtime)=EqualsValue then
    begin
      Result:=exam;
      break;
    end;
  end;
end;

// поиск инверс. экз/конс
function TXMGroup.FindInverseExam(wpid: int64; xmtype: TXMType): TExam;
begin
  Result:=FindExam(wpid,InverseXMType(xmtype));
end;

// проверка времени для события (07.05.06)
function TXMGroup.CheckPlace(wpid: int64; xmtype: TXMType;
    xmtime: TDateTime): boolean;

  // проверка порядка
  function CheckOrder: boolean;
  var
    exam: TExam;
    cd:  TValueRelationship;
  begin
    exam:=FindExam(wpid, InverseXMType(xmtype));
    if Assigned(exam) then
    begin
      cd:=CompareDate(exam.xmtime, xmtime);
      // экз после конс (конс перед экз)
      Result:=((xmtype=xmtExam) and (cd=LessThanValue))
              or ((xmtype=xmtCons) and (cd=GreaterThanValue));
    end
    else Result:=true;
  end;  // function CheckOrder

  // проверка отсутствия включения между другими экз/конс
  function CheckIntersect: boolean;
  var
    i: integer;
    exam, invexam, tmp: TExam;
  begin
    Result:=true;

    invexam:=FindInverseExam(wpid, xmtype);
    for i:=0 to FExams.Count-1 do
    begin
      exam:=TExam(FExams[i]);

      if exam=invexam then continue;

      // включение между тек. и его инвер. событием
      tmp:=FindInverseExam(exam.wpid,exam.xmtype);
      if Assigned(tmp) then
        if InRangeDate(xmtime, tmp.xmtime, exam.xmtime) then
        begin
          Result:=false;
          break;
        end;

      // включение между тек. и своим инвер. событием
      if Assigned(invexam) then
        if InRangeDate(exam.xmtime, xmtime, invexam.xmtime) then
        begin
          Result:=false;
          break;
        end;
    end;
  end;

  // проверка дня на наличие пол. грп (отсутствие пол. грп позволяет поставить)
  function CheckDay: boolean;
  var
    exam: TExam;
  begin
    exam:=FindExamOfDate(xmtime);
    if Assigned(exam) then Result:=(exam.subgrp and (xmtype=xmtExam))
      else Result:=true;
  end;

begin
  Result:=(DayOfTheWeek(xmtime)<>DaySunday);

  if Result then
  begin
    Result:=(not Assigned(FindExam(wpid,xmtype)));
    // проверка порядка
    if Result then Result:=CheckOrder;
    // проверка отсутствия включения между другими экз/конс
    if Result then Result:=CheckIntersect;
    // проверка наличия подгрупп
    if Result then Result:=CheckDay;
  end;
end;

// проверка времени на возможность поставить экз/конс
function TXMGroup.CheckTime(xmtime: TDateTime): boolean;

  // проверка отсутствия включения между другими экз/конс
  function CheckIntersect: boolean;
  var
    i: integer;
    exam, tmp: TExam;
  begin
    Result:=true;

    for i:=0 to FExams.Count-1 do
    begin
      exam:=TExam(FExams[i]);

      // включение между тек. и его инвер. событием
      tmp:=FindInverseExam(exam.wpid,exam.xmtype);
      if Assigned(tmp) then
        if InRangeDate(xmtime, tmp.xmtime, exam.xmtime) then
        begin
          Result:=false;
          break;
        end;

    end;  // for(i)
  end;

  // проверка дня на наличие пол. грп (отсутствие пол. грп позволяет поставить)
  function CheckDay: boolean;
  var
    exam: TExam;
  begin
    exam:=FindExamOfDate(xmtime);
    if Assigned(exam) then Result:=exam.subgrp
      else Result:=true;
  end;

begin
  Result:=(DayOfTheWeek(xmtime)<>DaySunday);

  if Result then
  begin
    // проверка отсутствия включения между другими экз/конс
    if Result then Result:=CheckIntersect;
    // проверка наличия подгрупп
    if Result then Result:=CheckDay;
  end;
end;

// проверка экзамена при добавлении (01.05.06)
function TXMGroup.CheckExam(AExam: TBaseExam): boolean;
var
  i: integer;
  exam: TExam;
begin
  Result:=((CompareDate(AExam.xmtime,FParent.Period.dbegin)<>LessThanValue)
    and (CompareDate(AExam.xmtime,FParent.Period.dend)<>GreaterThanValue));

  if Result then
    for i:=0 to FExams.Count-1 do
    begin
      exam:=TExam(FExams[i]);
      if CompareDate(AExam.fxmtime, exam.fxmtime)=EqualsValue then
        Result:=(AExam.fsubgrp and exam.fsubgrp);
      if not Result then break;
    end;
end;

function TXMGroup.GetExamCount: integer;
begin
  Result:=FExams.Count;
end;

function TXMGroup.GetExamIndex(index: integer): TExam;
begin
  Result:=TExam(FExams[index]);
end;

// возвращает кол-во экз/конс на указ. дате (09.05.06)
function TXMGroup.NumOfTime(xmtime: TDateTime): integer;
var
  i: integer;
begin
  Result:=0;
  for i:=0 to FExams.Count-1 do
    if CompareDate(TExam(FExams[i]).xmtime, xmtime)=EqualsValue then Inc(Result);
end;

// возвращает экз/конс для указ. даты по номеру
function TXMGroup.ExamOfTime(xmtime: TDateTime; index: integer): TExam;
var
  i,j: integer;
  exam: TExam;
begin
  Result:=nil;
  
  j:=0;
  for i:=0 to FExams.Count-1 do
  begin
    exam:=TExam(FExams[i]);
    if CompareDate(exam.xmtime, xmtime)=EqualsValue then
      if j=index then
      begin
        Result:=exam;
        break
      end
      else inc(j);
  end;  // for
end;

{ TXMTable }

function TXMTable.AddGroup(const grid: int64; const grName: string): integer;
var
  group: TXMGroup;
begin
  Result:=FindGroup(grid);
  if Result=-1 then
  begin
    group:=TXMGroup.Create(grid,grName,Self);
    Result:=FGroups.Add(group);
    DoGroupInsert(group);
    DoGroupUpdate(group);
  end;
end;

procedure TXMTable.Clear;
begin
  FGroups.Clear;
end;

constructor TXMTable.Create(APeriod: TDatePeriod);
begin
  FGroups:=TObjectList.Create;
  FPeriod:=APeriod;
end;

// удаление группы из списка (01.05.06)
procedure TXMTable.DelGroup(const grid: int64);
var
  i: integer;
begin
  i:=FindGroup(grid);
  if i>=0 then
  begin
    DoGroupDelete(TXMGroup(FGroups[i]));
    FGroups.Delete(i);
  end;
end;

destructor TXMTable.Destroy;
begin
  FGroups.Free;
  inherited Destroy;
end;

procedure TXMTable.DoChangePeriod;
begin
  if Assigned(FOnChangePeriod) then FOnChangePeriod(Self);
end;

{
procedure TXMTable.DoGetPeriod;
begin
  if Assigned(FOnGetPeriod) then FOnGetPeriod(Self, FBeginDate, FEndDate);
end;
}

function TXMTable.DoExamDelete(AExam: TBaseExam): boolean;
begin
  if Assigned(FOnExamDelete) then FOnExamDelete(AExam, Result)
    else Result:=true;
end;

function TXMTable.DoExamInsert(AExam: TBaseExam): boolean;
begin
  if Assigned(FOnExamInsert) then FOnExamInsert(AExam, Result)
    else Result:=true;
end;

function TXMTable.DoExamUpdate(AExam: TBaseExam;
    AUpdateFlag: WORD): boolean;
begin
  if Assigned(FOnExamUpdate) then FOnExamUpdate(AExam, AUpdateFlag, Result)
    else Result:=true;
end;

procedure TXMTable.DoGroupDelete(group: TXMGroup);
begin
  if Assigned(FOnGroupDelete) then FOnGroupDelete(group);
end;

procedure TXMTable.DoGroupInsert(group: TXMGroup);
begin
  if Assigned(FOnGroupInsert) then FOnGroupInsert(group);
end;

procedure TXMTable.DoGroupUpdate(group: TXMGroup);
begin
  if Assigned(FOnGroupUpdate) then FOnGroupUpdate(group);
end;

// поиск группы по grid
function TXMTable.FindGroup(const grid: int64): integer;
var
  i: integer;
begin
  Result:=-1;
  for i:=0 to FGroups.Count-1 do
    if TXMGroup(FGroups[i]).grid=grid then
    begin
      Result:=i;
      break;
    end;
end;

function TXMTable.GetCount: integer;
begin
  Result:=FGroups.Count;
end;

function TXMTable.GetGroupIndex(index: integer): TXMGroup;
begin
  Result:=TXMGroup(FGroups[index]);
end;

// возвращает группу по grid
function TXMTable.GroupByGrid(const grid: int64): TXMGroup;
var
  i: integer;
begin
  Result:=nil;
  for i:=0 to FGroups.Count-1 do
    if TXMGroup(FGroups[i]).grid=grid then
    begin
      Result:=TXMGroup(FGroups[i]);
      break;
    end;
end;

// возвращает группу по grName
function TXMTable.GroupByName(const grName: string): TXMGroup;
var
  i: integer;
begin
  Result:=nil;
  for i:=0 to FGroups.Count-1 do
    if TXMGroup(FGroups[i]).grName=grName then
    begin
      Result:=TXMGroup(FGroups[i]);
      break;
    end;
end;

procedure TXMTable.Update;
var
  i: integer;
begin
  for i:=0 to FGroups.Count-1 do
    TXMGroup(FGroups[i]).Update;
end;

{
procedure TXMTable.Set_Sem(Value: byte);
begin
  if FSem<>Value then
  begin
    FSem:=Value;
    DoGetPeriod;
  end;
end;
}

{
procedure TXMTable.Set_Year(Value: WORD);
begin
  if FYear<>Value then
  begin
    FYear:=Value;
    FSem:=1;
    Clear;
    DoGetPeriod;
  end;
end;
}

procedure TXMTable.SetPeriod(Value: TDatePeriod);
begin
  FPeriod:=Value;
  DoChangePeriod;
  Update;
end;

end.
