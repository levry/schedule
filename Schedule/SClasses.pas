{
  ������� ����������
  v0.2.7 (02/09/06)
  (C) Leonid Riskov, 2006
}

unit SClasses;

interface

uses
  Contnrs, Classes, ADOInt;

const
  NumberDays: integer = 6;         // ���-�� ����
  NumberPairs: integer = 7;        // ���-�� ��� � ����

type

  // ������ ��
  TDataItem = record
    id: int64;          // id
    name: string;       // �������. ����
    tag: integer;
  end;
  PDataItem = ^TDataItem;

  // ������ �������� ��
  TDataList = class
  private
    FList: TList;

  protected
    function GetItem(index: integer): PDataItem;

    function GetID(index: integer): int64;
    function GetName(index: integer): string;
    function GetTag(index: integer): integer;
    function GetCount: integer;

  public
    constructor Create;
    destructor Destroy; override;

    function Add(id: integer; name: string; tag: integer): integer;
    procedure Delete(index: integer);
    procedure Clear;
    procedure CopyTo(AList: TStrings; OnlyName: boolean=true);

    property Items[index: integer]: PDataItem read GetItem;
    property ID[index: integer]: int64 read GetID;
    property Name[index: integer]: string read GetName;
    property Tag[index: integer]: integer read GetTag;
    property Count: integer read GetCount;

  end;

  TBaseLsns = class;
  TLsns = class;
  TPair = class;
  TGroup = class;
  TSchedule = class;

  TUpdateKind = (ukAuditory, ukTeacher, ukSub);
  TUpdateErrors = set of TUpdateKind;

  // �������
  TNotifyLsnsEvent = procedure(Sender: TBaseLsns) of object;
  TAllowLsnsEvent = procedure(Sender: TBaseLsns; iDay,iPair: byte;
      var Allow: boolean) of object;
  TUpdateLsnsEvent = procedure(Sender: TBaseLsns; iDay,iPair: byte;
      Update: TUpdateKind; var Allow: boolean) of object;

  TNotifyPairEvent = procedure(Sender: TPair) of object;
  TNotifyGrpEvent = procedure(Sender: TGroup) of object;
  TParamGrpEvent = procedure(Sender: TGroup; id: int64) of object;

  TNotifySdlEvent = procedure(Sender: TSchedule) of object;

  TNotifyStrmEvent = procedure(Sender: TSchedule; strid: int64) of object;
  TStrmSdlEvent = procedure(Sender: TSchedule; strid: int64; iWeek,iDay,iPair: byte;
      HGrp: boolean; xid: int64; var Allow: boolean) of object;
  //TStrmSdlEvent = procedure(Sender: TSchedule; strid: int64; iWeek,iDay,iPair: byte; var Allow: boolean) of object;


  // ���. ����� �������
  TBaseLsns = class
  private
    function Get_sbid: int64;
    function Get_aid: int64;
    function Get_tid: int64;

    procedure Set_auditory(value: string); virtual;
    procedure Set_teacher(value: string); virtual;
    procedure Set_subgrp(value: boolean); virtual;
  protected
    fltype: byte;      // ��� (1-������, 2-��������, 3-���.)
    flid: int64;       // id ��������
    fstrid: int64;     // id ������
    fsubject: string;  // sbid=sbName;sbSmall
    fauditory: string; // aid=aName;pref
    fteacher: string;  // tid=[pSmall+Initial];pref (pref>1,free=0)
    fparity: byte;     // �������� (0-����. ������, 1-���., 2-�����.)
    fsubgrp: boolean;  // ���������

    procedure Assign(Source: TObject); virtual;
  public
    constructor Create; overload; virtual;
    constructor Create(ALsns: TBaseLsns); overload; virtual;

    property ltype: byte read fltype;
    property lid: int64 read flid;
    property strid: int64 read fstrid;
    property subject: string read fsubject;
    property auditory: string read fauditory write Set_auditory;
    property teacher: string read fteacher write Set_teacher;
    property parity: byte read fparity;
    property subgrp: boolean read fsubgrp write Set_subgrp;

    property sbid: int64 read Get_sbid;
    property aid: int64 read Get_aid;
    property tid: int64 read Get_tid;

    function IsStrm: boolean;     // �����. �������?
  end;

  // ������. �������
  TAvailLsns = class(TBaseLsns)
  private
    fexists: boolean;      // ����� �� ����
    fflsns:  boolean;      // �. ��������� ���. ������(�)
    fhlsns:  boolean;      // �. ��������� ���������(�)
    fahours: byte;         // �������� �����
    fhours:  byte;         // ������. ��������
    ftstate: byte;         // ������ ����-��

    procedure Set_subgrp(value: boolean); override;
  public
    constructor Create; overload; override;
    constructor Create(const Src: TAvailLsns); overload;

    // from TBaseLsns
    property ltype: byte read fltype;
    property lid: int64 read flid;
    property strid: int64 read fstrid;
    property subject: string read fsubject;
    property auditory: string read fauditory;
    property teacher: string read fteacher;
    property parity: byte read fparity;
    property subgrp: boolean read fsubgrp write Set_subgrp;

    // TAvailLsns
    property exists: boolean read fexists;
    property hours: byte read fhours;
    property ahours: byte read fahours;
    property flsns: boolean read fflsns;
    property hlsns: boolean read fhlsns;
    property tstate: byte read ftstate;

    procedure Assign(Source: TObject); override;
    function CheckLsns: boolean;       // ���. ��������
    function CheckStm: boolean;        // �������� ������
    function CheckedSub: boolean;      // ������-�� ���-��� ���������
    function CheckThr: boolean;        // �������� ����-��
    function CheckHours: boolean;      // �������� ����� (������ ��� �������)
  end;

  // �������
  TLsns = class(TBaseLsns)
  private
    FParent: TPair;
    procedure Set_auditory(value: string); override;
    procedure Set_teacher(value: string); override;
    procedure Set_subgrp(value: boolean); override;
  public
    constructor Create; override;

    function Save(Update: TUpdateKind): boolean;
    procedure Assign(Source: TObject); override;

    property Parent: TPair read FParent;
  end;

  // ����
  TPair = class
  private
    FParent: TGroup;

    FList: TObjectList;       // �������
    FDay: byte;               // ����
    FPair: byte;              // ����� ����

    function GetLsnsIndex(index: integer): TLsns;
    function GetCount: integer;

    function InternalAdd(ALsns: TLsns): integer;
    function InternalDelete(ALsns: TLsns): boolean;
  public
    constructor Create(iDay,iPair: byte; const AParent: TGroup);
    destructor Destroy; override;

    property Parent: TGroup read FParent;
    property Day: byte read FDay;
    property Pair: byte read FPair;
    property Item[index: integer]: TLsns read GetLsnsIndex; default;
    property Count: integer read GetCount;

    function IsDoubled: boolean;           // ������� ������� ����
    function IsSplitted: boolean;          // ������� ����������� ������

    function CheckLsns(const ALsns: TBaseLsns): boolean;
    function CheckPlace(iweek: byte): boolean;

    function Add(ALsns: TLsns): integer;    // ���������� �������
    function Delete(ALsns: TLsns): boolean; // �������� ������� (������)

    function GetParity(prty: byte): integer;

    function FindStrm(strid: int64): TLsns;   // ����� �����. �������
    function FindLsns(lid: int64): TLsns;     // ����� �������
    function FindTchr(tid: int64): integer;   // ����� ����-��
    function FindAudr(aid: int64): integer;   // ����� ���������

    procedure Clear;
  end;


  // ������
  TGroup = class
  private
    FGrid: int64;          // grid
    FName: string;         // grName
    FPairs: array[0..5,0..6] of TPair;   // ���������� ������
    FParent: TSchedule;    // ����������

    // �������
    // ��� ���������� ����������
    // ��� ���������� �������
    // ��� �������� �������

    function Get(iDay, iPair: byte): TPair;

    function DoAdd(iday,ipair: byte; ALsns: TBaseLsns): boolean;
    function DoDelete(iday,ipair: byte; ALsns: TLsns): boolean;
  public
    constructor Create(agrid: int64; aname: string; const AParent: TSchedule);
    destructor Destroy; override;

    procedure Clear;
    procedure Update;
    procedure UpdateLsns(lid: int64);
    function IsPlace(iDay,iPair,iWeek: byte): boolean;

    procedure BeginUpdate;
    procedure EndUpdate;

    property Grid: int64 read FGrid;
    property Name: string read FName;
    property Parent: TSchedule read FParent;
    property Item[day,pair: byte]: TPair read Get;
  end;

  // ����������
  TSchedule = class
  private
    FList: TObjectList;
    FUpdateCount: integer;   // ���� >0, �� �� ����������� �������

    FOnGetSchedule: TParamGrpEvent;     // ������� ��� ���������� ����������
    FOnAddGroup: TNotifyGrpEvent;       // ������� ��� ���������� ������
    FOnDelGroup: TNotifyGrpEvent;       // ������� ��� �������� ������

    FOnAddLessons: TAllowLsnsEvent;     // ������� ��� ���������� �������
    FOnDelLessons: TAllowLsnsEvent;     // ������� ��� �������� �������
    FOnSaveLessons: TUpdateLsnsEvent;   // ������� ��� ���������� �������

    FOnAddStream: TStrmSdlEvent;        // ������� ��� ���������� ���. �������
    FOnDelStream: TStrmSdlEvent;        // ������� ��� �������� ���. �������
    FOnGetStream: TNotifyStrmEvent;     // ������� ��� �������� ���������� ������

    function IsLocked: boolean;
    function GetCount: integer;         // ����� ����� � ����������
    function GetGroupIndex(index: integer): TGroup;
  public
    constructor Create;
    destructor Destroy; override;

    function FindGroup(const grid: int64): integer;
    function GroupByName(const name: string): TGroup;
    function GroupByGrid(const grid: int64): TGroup;
    function AddGroup(const grid: int64; const name: string): integer;
    function DelGroup(const grid: int64): boolean;
    function AddStream(const strid: int64; const iWeek,iDay,iPair: byte; HGrp: boolean; aid: int64): boolean;
    function DelStream(const strid: int64; const iWeek,iDay,iPair: byte): boolean;
    procedure UpdateStrm(const strid: int64);
    procedure Update;
    procedure Clear;
    procedure BeginUpdate;
    procedure EndUpdate;

    property Item[index: integer]: TGroup read GetGroupIndex;
    property Count: integer read GetCount;

    property OnGetSchedule: TParamGrpEvent read FOnGetSchedule write FOnGetSchedule;
    property OnAddGroup: TNotifyGrpEvent read FOnAddGroup write FOnAddGroup;
    property OnDelGroup: TNotifyGrpEvent read FOnDelGroup write FOnDelGroup;

    property OnAddLessons: TAllowLsnsEvent read FOnAddLessons write FOnAddLessons;
    property OnDelLessons: TAllowLsnsEvent read FOnDelLessons write FOnDelLessons;
    property OnSaveLessons: TUpdateLsnsEvent read FOnSaveLessons write FOnSaveLessons;

    property OnAddStream: TStrmSdlEvent read FOnAddStream write FOnAddStream;
    property OnDelStream: TStrmSdlEvent read FOnDelStream write FOnDelStream;
    property OnGetStream: TNotifyStrmEvent read FOnGetStream write FOnGetStream;
  end;


  // ������ �������� (����������) ��� ����-�� � ���������

  TTimeGrid = class;

  // �������
  TTimeLsns = class
  private
    FGroupList: TDataList; // ������ �����   (id=grid,name=grName,tag=course)

    FLSID: int64;      // id ������� (lid - ��� ����. �������, strid - ��� ������)
    FLType: byte;      // ��� ������� (1-���,2-�����,3-���)
    FDay: byte;        // ��. ����
    FPair: byte;       // ����� ����
    FWeek: byte;       // �������� ������
    FResource: string; // ������ (��������� {aid=aName;pref},
                       // �������������={tid=[pSmall+Initial];pref (pref>1,free=0)})

  private
    function GetGroupItem(index: integer): PDataItem;
    function GetGroupCount: integer;
    function FindGroup(id: int64): integer;

  public
    constructor Create;
    destructor Destroy; override;

    function GetGroupString(ACount: integer): string;
    function AddGroup(id: int64; name: string; course: byte): integer;

    property LSID: int64 read FLSID;
    property LType: byte read FLType;
    property Day: byte read FDay;
    property Pair: byte read FPair;
    property Week: byte read FWeek;
    property Resource: string read FResource;

    property GroupCount: integer read GetGroupCount;
    property Groups[index: integer]: PDataItem read GetGroupItem;
  end;

  // ���������� �������
  TTimeList = class
  private
    FParent: TTimeGrid;
    FLsnsList: TObjectList;          // ������ ������� (����������)
    FId: int64;                      // id
    FName: string;                   // name

    function GetCount: integer;
//    function GetLsnsOfPair(ADay,APair: byte): TTimeLsns;
    function CheckPlace(ADay,APair,AWeek: byte): boolean;

  public
    constructor Create(AId: int64; AName: string; AParent: TTimeGrid);
    destructor Destroy; override;

    function AddTimeLsns(ALSID: int64; ADay,APair,AWeek,ALType: byte;
        AResource: string): TTimeLsns;
    function GetLsns(ADay,APair: byte; AIndex: integer): TTimeLsns;
    function GetLsnsCount(ADay,APair: byte): integer;
    function IsDoublePair(ADay,APair: byte): boolean;
    procedure LoadFrom(ARecordset: _Recordset; AResId, AResName: string);

    procedure Clear;
    procedure Update;

    property Count: integer read GetCount;
    property Id: int64 read FId;
    property Name: string read FName;
//    property TimeLsns[Day,Pair: byte]: TTimeLsns read GetLsnsOfPair;
  end;

  // ���������� ��� ������������� (���������)
  TTimeGrid = class
  private
    FList: TObjectList;

    FOnAddItem: TNotifyEvent;         // �������: ����������
    FOnDeleteItem: TNotifyEvent;      // �������: ��������
    FOnUpdateItem: TNotifyEvent;      // �������: ���������� (���������� ����������)

    function GetItemIndex(index: integer): TTimeList;
    function GetItemCount: integer;

  public
    constructor Create;
    destructor Destroy; override;

    function FindItem(const id: int64): integer;
    function Add(id: int64; name: string): integer;
    procedure Remove(ATimeList: TTimeList);
    procedure Delete(index: integer);
    procedure Update;
    procedure Clear;

    property Count: integer read GetItemCount;
    property Items[index: integer]: TTimeList read GetItemIndex;
    property OnAddItem: TNotifyEvent read FOnAddItem write FOnAddItem;
    property OnDeleteItem: TNotifyEvent read FOnDeleteItem write FOnDeleteItem;
    property OnUpdateItem: TNotifyEvent read FOnUpdateItem write FOnUpdateItem;

  end;

function ExistsStrm(const APair: TPair): boolean;
function AddLsns(schedule: TSchedule; grid: int64; wday,npair: byte; lsns: TLsns): boolean;
function InternalAddLsns(APair: TPair; ALsns: TLsns): integer;
function InternalDelLsns(APair: TPair; ALsns: TLsns): boolean;

implementation

uses
  DB, Variants, SysUtils,
  SConsts, SUtils;

// �������� ������������� �����. ������� �� ���� (10.08.2005)
function ExistsStrm(const APair: TPair): boolean;
var
  i: integer;
begin
  Result:=false;
  if Assigned(APair) then
    for i:=0 to APair.Count-1 do
      if APair.Item[i].IsStrm then
      begin
        Result:=true;
        break;
      end;
end;

// ���������� ������� � ���������� ������
// awday in [0..5], anpair in [0..6]
function AddLsns(schedule: TSchedule; grid: int64; wday,npair: byte;
    lsns: TLsns): boolean;
var
  grp: TGroup;
begin
  Assert(Assigned(schedule),
    '6017051F-D673-429C-8919-2FBD9700A43D'#13'SClasses.AddLsns: schedule is nil'#13);
  Assert(grid>0,
    'BB80E75E-10D5-4599-8955-35A82F8694E4'#13'SClasses.AddLsns: invalid grid'#13);
  Assert(wday<=5,
    'CE8698BC-E37A-4DF6-9D7F-BC4763BA8E9B'#13'SClasses.AddLsns: invalid wday'#13);
  Assert(npair<=6,
    '83491A75-E5B8-4EDB-9BB0-D3DBBE543A43'#13'SClasses.AddLsns: invalid npair'#13);


  Result:=false;

  if Assigned(lsns) then
  begin

    if lsns.IsStrm then
      // ���������� �����. �������
      Result:=schedule.AddStream(lsns.strid,lsns.parity,wday,npair,lsns.subgrp,lsns.aid)
    else
    begin
      // ���������� ������� ������
      grp:=schedule.GroupByGrid(grid);
      if Assigned(grp) then
        Result:=(grp.Item[wday,npair].Add(lsns)>=0);
    end;
  end; // if ALsns<>nil
end;

// ���������� ������� �� ���� (��������)
function InternalAddLsns(APair: TPair; ALsns: TLsns): integer;
begin
  Assert(Assigned(APair),
    '0D9ED5AC-4E95-4841-A44D-027025137C09'#13'InternalAddLsns: APair is nil'#13);
  Assert(Assigned(ALsns),
    '276D17A9-E43D-4AD4-AC03-BB1187215A14'#13'InternalAddLsns: ALsns is nil'#13);

  Result:=APair.InternalAdd(ALsns);
end;

// �������� ������� (��������)
function InternalDelLsns(APair: TPair; ALsns: TLsns): boolean;
begin
  Assert(Assigned(APair),
    '14CB87CF-52B3-47EA-B5F2-96195DBEAF9B'#13'InternalDelLsns: APair is nil'#13);
  Assert(Assigned(ALsns),
    'DAD9F602-BB4D-4147-B993-5873FD57F2BD'#13'InternalDelLsns: ALsns is nil'#13);

  Result:=APair.InternalDelete(ALsns);
end;

{ TDataList }

constructor TDataList.Create;
begin
  FList:=TList.Create;
end;

destructor TDataList.Destroy;
begin
  Clear;
  FList.Free;
  inherited;
end;

function TDataList.GetID(index: integer): int64;
begin
  Result:=GetItem(index).id;
end;

function TDataList.GetName(index: integer): string;
begin
  Result:=GetItem(index).name;
end;

function TDataList.GetTag(index: integer): integer;
begin
  Result:=GetItem(index).tag;
end;

function TDataList.GetItem(index: integer): PDataItem;
begin
  Result:=PDataItem(FList[index]);
end;

function TDataList.Add(id: integer; name: string; tag: integer): integer;
var
  pitem: PDataItem;
begin
  New(pitem);
  pitem.id:=id;
  pitem.name:=name;
  pitem.tag:=tag;
  Result:=FList.Add(pitem);
end;

procedure TDataList.Delete(index: integer);
var
  pitem: PDataItem;
begin
  pitem:=FList[index];
  FList.Delete(index);
  Dispose(pitem);
end;

procedure TDataList.Clear;
var
  i: integer;
begin
  for i:=0 to FList.Count-1 do
    Dispose(PDataItem(FList[i]));
  FList.Clear;
end;

function TDataList.GetCount: integer;
begin
  Result:=FList.Count;
end;

// ����������� ������ � TStrings (02/08/06)
procedure TDataList.CopyTo(AList: TStrings; OnlyName: boolean);
var
  i: integer;
  s: string;
  pitem: PDataItem;
begin
  Assert(Assigned(AList),
    'A76E7349-E17E-4541-99EC-518BA7961106'#13'TDataList.CopyTo: AList is nil'#13);

  AList.BeginUpdate;
  try
    AList.Clear;
    for i:=0 to FList.Count-1 do
    begin
      pitem:=GetItem(i);
      if OnlyName then s:=pitem.name
        else s:=Format('%d=%s;%d',[pitem.id,pitem.name,pitem.tag]);
      AList.Add(s);
    end;
  finally
    AList.EndUpdate;
  end;
end;


{ TBaseLsns }

constructor TBaseLsns.Create;
begin
end;

constructor TBaseLsns.Create(ALsns: TBaseLsns);
begin
  Assert(Assigned(ALsns),
    'FF94665E-F7D7-4C2D-BC8E-641D57A8AE62'#13'TBaseLsns.Create: ALsns is nil'#13);
  if Assigned(ALsns) then Assign(ALsns);
end;
procedure TBaseLsns.Assign(Source: TObject);

  procedure CopyFromLsns(Lsns: TBaseLsns);
  begin
    fltype:=Lsns.fltype;
    flid:=Lsns.flid;
    fstrid:=Lsns.fstrid;
    fsubject:=Lsns.fsubject;
    fauditory:=Lsns.fauditory;
    fteacher:=Lsns.fteacher;
    fparity:=Lsns.fparity;
    fsubgrp:=Lsns.fsubgrp;
  end; // procedure

begin
  if Source is TBaseLsns then CopyFromLsns(TBaseLsns(Source))
    else raise Exception.Create('TBaseLsns.Assign: Unknown object class');
end;

// ���-��� ���������
procedure TBaseLsns.Set_auditory(value: string);
begin
  fauditory:=value;
end;

// ���-��� ����-��
procedure TBaseLsns.Set_teacher(value: string);
begin
  fteacher:=value;
end;

// ���-��� ���������
procedure TBaseLsns.Set_subgrp(value: boolean);
begin
  fsubgrp:=value;
end;

// ��������� �������?
function TBaseLsns.IsStrm: boolean;
begin
  Result:=(fstrid>0);
end;

// ���������� sbid
function TBaseLsns.Get_sbid: int64;
begin
  Result:=GetID(fsubject);
end;

// ���������� aid
function TBaseLsns.Get_aid: int64;
begin
  Result:=GetID(fauditory);
end;

// ���������� tid
function TBaseLsns.Get_tid: int64;
begin
  Result:=GetID(fteacher);
end;

{ TLsns }
constructor TLsns.Create;
begin
  //inherited Create;
  FParent:=nil;
end;

// ���-��� ��������
procedure TLsns.Set_auditory(value: string);
var
  old: string;
begin
  old:=fauditory;
  if aid<>GetId(value) then
  begin
    fauditory:=value;
    if not Save(ukAuditory) then fauditory:=old;
  end
end;

// ���-��� ����-��
procedure TLsns.Set_teacher(value: string);
var
  old: string;
begin
  old:=fteacher;
  if tid<>GetId(value) then
  begin
    fteacher:=value;
    if not Save(ukTeacher) then fteacher:=old;
  end;
end;

// ���-��� ���������
procedure TLsns.Set_subgrp(value: boolean);
var
  old: boolean;
begin
  old:=fsubgrp;
  if old<>value then
  begin
    fsubgrp:=value;
    if not Save(ukSub) then fsubgrp:=old;
  end;
end;

// ���������� ������� � ����
function TLsns.Save(Update: TUpdateKind): boolean;
begin
  Result:=false;
  if Assigned(FParent.Parent.Parent.OnSaveLessons) then
    FParent.Parent.Parent.OnSaveLessons(Self,FParent.Day,FParent.Pair,Update,Result);
end;

procedure TLsns.Assign(Source: TObject);

  procedure CopyFromFields(Fields: TFields);
  begin
    with Fields do
    begin
      flid:=FieldByName('lid').AsInteger;
      fltype:=FieldByName('type').AsInteger;
      fsubject:=SUtils.Format(
        FieldByName('sbid').AsString,
        FieldByName('sbName').AsString,
        FieldByName('sbSmall').AsString );
      if not FieldByName('tid').IsNull then
        fteacher:=SUtils.Format(
          FieldByName('tid').AsString,
          FieldByName('psmall').AsString+' '+FieldByName('Initials').AsString,
          FieldByName('tprefer').AsString)
      else fteacher:='';
      if not FieldByName('aid').IsNull then
        fauditory:=SUtils.Format(
          FieldByName('aid').AsString,
          FieldByName('aName').AsString,
          FieldByName('aprefer').AsString)
      else fauditory:='';
      fparity:=FieldByName('week').AsInteger;
      fsubgrp:=(FieldByName('hgrp').AsInteger=1);
      fstrid:=FieldByName('strid').AsInteger;
    end;  // with(Fields)
  end;  // procedure CopyFromFields

begin
  if Source is TBaseLsns then inherited Assign(Source) else
    if Source is TFields then CopyFromFields(TFields(Source))
      else raise Exception.Create('TLsns.Assign: Unknown object class');
end;

// ���������� ������ ����������
//function TLsns.GetSchedule: TSchedule;
//begin
//  Result:=Parent.Parent.Parent;
//end;

{ TAvailLsns }

constructor TAvailLsns.Create;
begin
//  inherited Create;
  fexists:=false;
  fflsns:=false;
  fhlsns:=false;
  fahours:=0;
  fhours:=0;
  ftstate:=0;
end;

constructor TAvailLsns.Create(const Src: TAvailLsns);
begin
  Assert(Assigned(Src),
    'F0C7207A-20B6-4EA4-B414-ACA9CD354DA6'#13'TAvailLsns.Create: Src is nil'#13);

  Assign(Src);
end;

procedure TAvailLsns.Assign(Source: TObject);

  procedure CopyFromLsns(ALsns: TAvailLsns);
  begin
    inherited Assign(ALsns);
    fahours:=ALsns.fahours;
    fhours:=ALsns.fhours;
    fexists:=ALsns.fexists;
    fflsns:=ALsns.fflsns;
    fhlsns:=ALsns.fhlsns;
    ftstate:=ALsns.ftstate;
  end;  // procedure CopyFromLsns

  procedure CopyFromFields(AFields: TFields);
  begin
    // from TBaseLsns
    with AFields do
    begin
      flid:=FieldByName('lid').AsInteger;
      fltype:=FieldByName('type').AsInteger;
      fsubject:=SUtils.Format(
          FieldByName('sbid').AsString,
          FieldByName('sbName').AsString,
          FieldByName('sbSmall').AsString );
      if not FieldByName('tid').IsNull then
        fteacher:=SUtils.Format(
            FieldByName('tid').AsString,
            FieldByName('pSmall').AsString+' '+AFields.FieldByName('Initials').AsString,
            FieldByName('tstate').AsString)
      else fteacher:='';
      fauditory:='';
      fparity:=FieldByName('week').AsInteger;
      fstrid:=FieldByName('strid').AsInteger;

      // from TAvailLsns
      fexists:=(FieldByName('exists').AsInteger=1);
      fflsns:=(FieldByName('flsns').AsInteger=1);
      fhlsns:=(FieldByName('hlsns').AsInteger=1);
      fahours:=FieldByName('ahours').AsInteger;
      fhours:=FieldByName('hours').AsInteger;
      ftstate:=FieldByName('tstate').AsInteger;
    end;

    // calculate
    if CheckLsns then
    begin
      fsubgrp:=(fhlsns and (not fflsns));    // �������� ������ ���������
      if not fsubgrp then
        fsubgrp:=((fahours<4) and (fparity=0)) or ((fahours<2) and (fparity<>0));
    end;

  end;  // procedure CopyFromFields

begin
  if Source is TAvailLsns then CopyFromLsns(TAvailLsns(Source)) else
    if Source is TFields then CopyFromFields(TFields(Source))
      else raise Exception.Create('TAvailLsns.Assign: Unknown object class');
end;

// �������� ����������� �������
function TAvailLsns.CheckLsns: boolean;
begin
  Result:=CheckThr                // ����-�� �� �����
    and (fahours>0)               // ���� ������. ����
    and (fflsns or fhlsns)        // ������� � ����� ������� ������
    and CheckStm                  // ��� ������ | �������� �����. �������
    and (not fexists)             // ��� ������� �� ����
    and CheckHours;               // ���������� ����� ��� �������
end;

// �������� ����������� ������
function TAvailLsns.CheckStm: boolean;
begin
  Result:=(fstrid=0) or fflsns or fhlsns;
end;

// �������� ����������� ���-��� ���������
function TAvailLsns.CheckedSub: boolean;
begin
  Result:=(fflsns and fhlsns)
    and (((fahours>=4) and (fparity=0)) or ((ahours>=2) and (fparity<>0)));
end;

// �������� ����������� ����-��
function TAvailLsns.CheckThr: boolean;
begin
  Result:=(ftstate<>STATE_BUSY);
end;

// �������� ����� (���������� ��� �������� �������)
function TAvailLsns.CheckHours: boolean;
begin
  if fparity=0 then Result:=(fahours>=2) else Result:=(fahours>=1);
end;

procedure TAvailLsns.Set_subgrp(value: boolean);
begin
  if CheckedSub and (value<>fsubgrp) then
    fsubgrp:=value;
end;

{ TPair }

constructor TPair.Create(iDay,iPair: byte; const AParent: TGroup);
begin
  Assert(((iDay<6)and(iPair<7)),'D0398B5C-5A03-42B7-9D9A-7D05CB35B2E7'#13'TPair.Create'#13);

  inherited Create;
  FParent:=AParent;
  FDay:=iDay;
  FPair:=iPair;
  FList:=TObjectList.Create;
end;

destructor TPair.Destroy;
begin
  if Assigned(FParent) then
    FParent.FPairs[FDay,FPair]:=nil;
  FList.Free;
  inherited Destroy;
end;

function TPair.GetLsnsIndex(index: integer): TLsns;
begin
  if (index>=0) and (index<FList.Count) then Result:=TLsns(FList.Items[index])
    else Result:=nil;
end;

// ���������� ����� ������� �� ����
function TPair.GetCount: integer;
begin
  Result:=FList.Count;
end;

// true - ����������� ����
function TPair.IsSplitted: boolean;
var
  i: integer;
begin
  Result:=false;
  for i:=0 to FList.Count-1 do
    if TLsns(FList.Items[i]).parity<>0 then
    begin
      Result:=true;
      break;
    end;
end;

// ���������� ������� (�������) � ������
function TPair.InternalAdd(ALsns: TLsns): integer;
begin
  Assert(Assigned(ALsns),
    '4F3499AF-0719-4B24-934D-10521A0BC872'#13'TPair.InternalAdd: ALsns is nil'#13);

  Result:=FList.Add(ALsns);
  if Result>=0 then ALsns.FParent:=Self;
end;

// ���������� �������
// ���������� ������ (-1 - ���� �� ���������)
function TPair.Add(ALsns: TLsns): integer;
begin
  Result:=-1;
//  if CheckLsns(ALsns) then
    if FParent.DoAdd(FDay,FPair,ALsns) then
      Result:=InternalAdd(ALsns);
end;

// �������� ������� (�������) �� ������
function TPair.InternalDelete(ALsns: TLsns): boolean;
begin
  Assert(Assigned(ALsns),
    '010FB7FC-F789-4599-B9B9-34CBD74E23D8'#13'TPair.InterbalDelete: ALsns is nil'#13);

  Result:=(FList.Remove(ALsns)>=0);
  if Result then FList.Pack;
end;

// �������� �������
// true - ������� �������
function TPair.Delete(ALsns: TLsns): boolean;
begin
  Result:=FParent.DoDelete(FDay,FPair,ALsns);
  if Result then
    InternalDelete(ALsns);
end;

// ����������� ����� ������� ��� ����. �������� ������
function TPair.GetParity(prty: byte): integer;
var
  i: integer;
begin
  Assert((prty<=2),
    '04B30F27-995A-4F46-98A9-B03D9FC366D7'#13'TPair.GetParity: invalid prty'#13);
  Result:=0;
  for i:=0 to FList.Count-1 do
    if TLsns(FList.Items[i]).parity=prty then inc(Result);
end;

// �������� �� ����������� ������� ������� �� ����
function TPair.CheckLsns(const ALsns: TBaseLsns): boolean;
var
  i: integer;
begin
  Result:=true;
  if not FParent.FParent.IsLocked then
    for i:=0 to FList.Count-1 do
    begin
      with TLsns(FList[i]) do
      begin
        // ���� ����� ������ ������ �� ����./����. ������
        if (not subgrp) and ((parity=ALsns.parity) or (parity=0)) then Result:=false;
        // ���� ����. lid �� ������
        if (lid=ALsns.lid) and (parity=ALsns.parity) then Result:=false;
      end;
      if not Result then break;
    end;
end;

// �������� ����� �� ����
function TPair.CheckPlace(iweek: byte): boolean;
var
  i: integer;
begin
  Result:=true;
  for i:=0 to FList.Count-1 do
    with TLsns(FList[i]) do
      if (not subgrp) and ((parity=iweek) or (parity=0)) then
      begin
        Result:=false;
        break;
      end;
end;

// ����� ������� ������
// ���������� �������, ���� ���-�� �������, ����� nil
function TPair.FindStrm(strid: int64): TLsns;
var
  i: integer;
begin
  Assert(strid>0,
    '8422C263-8AF8-452F-8C85-F2583C066B79'#13'TPair.FindStrm: invalid strid'#13);

  Result:=nil;
  for i:=0 to FList.Count-1 do
    if TLsns(FList[i]).strid=strid then
    begin
      Result:=Item[i];
      break;
    end;
end;

// ����� �������
// ���������� �������, ���� ����������, ����� nil
function TPair.FindLsns(lid: int64): TLsns;
var
  i: integer;
begin
  Assert(lid>0,
    '2E6886F6-1314-4C0C-9432-278AA6E9C2D2'#13'TPair.FindLsns: Invalid lid'#13);

  Result:=nil;
  for i:=0 to FList.Count-1 do
    if TLsns(FList[i]).lid=lid then
    begin
      Result:=Item[i];
      break;
    end;
end;

// ����� ����-��
// ���������� ������ �������, ��� ������������ ����-��, ����� -1
function TPair.FindTchr(tid: int64): integer;
var
  i: integer;
begin
  Result:=-1;
  for i:=0 to FList.Count-1 do
    if TLsns(FList[i]).tid=tid then
    begin
      Result:=i;
      break;
    end;
end;

// ����� ���������
// ���������� ������ �������, ��� ������������ ���., ����� -1
function TPair.FindAudr(aid: int64): integer;
var
  i: integer;
begin
  Result:=-1;
  for i:=0 to FList.Count-1 do
    if TLsns(FList[i]).aid=aid then
    begin
      Result:=i;
      break;
    end;
end;

// ������� ����
procedure TPair.Clear;
begin
  FList.Clear;
end;

// �������� �� ������� ���� (02/09/06)
function TPair.IsDoubled: boolean;
  // �������� ������������� ������. �������
  function ExistsNextLsns(NPair: TPair; ALsns: TLsns): boolean;
  var
    i: integer;
    l: TLsns;
  begin
    Result:=false;
    for i:=0 to NPair.Count-1 do
    begin
      l:=NPair.Item[i];
      // �����: lid,parity,aid,tid,subgrp(false)
      if (l.lid=ALsns.lid) and (l.parity=ALsns.parity) and (l.aid=ALsns.aid)
        and (l.tid=ALsns.tid) and (l.subgrp=ALsns.subgrp) and (not l.subgrp) then
      begin
        Result:=true;
        Break;
      end;
    end;
  end;  // function

var
  i: integer;
  npair: TPair;
begin
  Result:=false;

  if FPair<6 then
  begin
    npair:=Parent.Item[FDay,FPair+1];

    if FList.Count=npair.Count then
    begin
      Result:=true;
      for i:=0 to FList.Count-1 do
        if not ExistsNextLsns(npair,TLsns(FList[i])) then
        begin
          Result:=false;
          break;
        end;
    end;

  end;  // if Pair<6
end;

{ TGroup }

constructor TGroup.Create(agrid: int64; aname: string; const AParent: TSchedule);
//constructor TGroup.Create(const name: string; const AParent: TSchedule);
var
  i, j: integer;
begin
  inherited Create;
  for i:=0 to 5 do
    for j:=0 to 6 do
      FPairs[i,j]:=TPair.Create(i,j,Self);

  FGrid:=agrid;
  FName:=aname;
  FParent:=AParent;
end;

destructor TGroup.Destroy;
var
  i,j: integer;
begin
  if Assigned(FParent) then
  begin
    FParent.FList.Extract(Self);
    FParent.FList.Pack;
  end;

  Clear;
  for i:=0 to 5 do
    for j:=0 to 6 do
      if Assigned(FPairs[i,j]) then
      begin
        FPairs[i,j].Free;
        FPairs[i,j]:=nil;
      end;
  FParent:=nil;
  inherited Destroy;
end;

// ��������� ���� ����. ��� � ������
function TGroup.Get(iDay, iPair: byte): TPair;
begin
  Assert((iDay<=5)and(iPair<=6),'8AF0C173-73F8-42FA-905C-38F80D47521A'#13'TGroup.Get'#13);

  Result:=FPairs[iDay,iPair];
end;

// ���������� ����������
procedure TGroup.Update;
begin
  if Assigned(FParent.OnGetSchedule) then
  begin
    BeginUpdate;
    Clear;
    FParent.OnGetSchedule(Self,-1);
    EndUpdate;
  end;
end;

// ���������� ���������� �������
procedure TGroup.UpdateLsns(lid: int64);
var
  d,p: byte;
  Lsns: TLsns;
begin
  Assert(lid>0,
    'CC3A4086-0322-4A0D-8258-EB7970FE8189'#13'TGroup.UpdateLsns: lid<=0'#13);

  if Assigned(FParent.OnGetSchedule) then
  begin
    BeginUpdate;
    for d:=0 to 5 do
      for p:=0 to 6 do
        with FPairs[d,p] do
        begin
          repeat
            Lsns:=FindLsns(lid);
            if Assigned(Lsns) then Delete(Lsns);
          until not Assigned(Lsns);

        end; // with
    FParent.OnGetSchedule(Self,lid);
    EndUpdate;
  end;
end;

// ������� ���������� ������
procedure TGroup.Clear;
var
  i, j: integer;
begin
  for i:=0 to 5 do
    for j:=0 to 6 do
      FPairs[i,j].Clear;
end;

// �������� � ���� ��� ��������
function TGroup.DoAdd(iday,ipair: byte; ALsns: TBaseLsns): boolean;
begin
  if FParent.IsLocked then Result:=true else
    if Assigned(FParent.OnAddLessons) then
      FParent.OnAddLessons(ALsns,iday,ipair,Result);
end;

// �������� � ���� ��� ��������
function TGroup.DoDelete(iday,ipair: byte; ALsns: TLsns): boolean;
begin
  if FParent.IsLocked then Result:=true else
    if Assigned(FParent.OnDelLessons) then
      FParent.OnDelLessons(ALsns,iday,ipair,Result);
end;

procedure TGroup.BeginUpdate;
begin
  if Assigned(FParent) then FParent.BeginUpdate;
end;

procedure TGroup.EndUpdate;
begin
  if Assigned(FParent) then FParent.EndUpdate;
end;

// �������� �� ����������� �������� �������
// true - ����� ��������
function TGroup.IsPlace(iDay,iPair,iWeek: byte): boolean;
var
  Pair: TPair;
  i: integer;
begin
  Assert((iDay<=5)and(iPair<=6)and(iWeek<=2),
      'CC306D4E-69FB-4FFF-84D0-ACE82191D140'#13'TGroup.IsPlace'#13);

  Result:=false;
  Pair:=Get(iDay,iPair);
  if Assigned(Pair) then
  begin
    Result:=true;
    for i:=0 to Pair.Count-1 do
    begin
      with Pair.Item[i] do
        if (not subgrp) and ((parity=iWeek) or (parity=0)) then
        begin
          Result:=false;
          break;
        end;
    end;
  end;
end;

{ TSchedule }

// ���������� ������ � ����������
// grid - id ������
// name - ����. ������
// ��� �����. ���������� ���������� ������ ������, ����� -1
function TSchedule.AddGroup(const grid: int64; const name: string): integer;
//function TSchedule.AddGroup(const name: string): integer;
var
  Grp: TGroup;
begin
  Result:=FindGroup(grid);
  if Result=-1 then
  begin
    Grp:=TGroup.Create(grid,name,Self);
    Result:=FList.Add(Grp);
    if Assigned(OnAddGroup) then OnAddGroup(Grp);
    Grp.Update;
  end;
end;

// ���������� �����. �������
// strid - id ������
// iDay - ����
// iPair - ����
// true - ������� ���������
function TSchedule.AddStream(const strid: int64; const iWeek, iDay, iPair: byte;
    HGrp: boolean; aid: int64): boolean;
begin
  Assert(strid>0, '7432B6E6-A18C-476C-8856-87757CCC7243'#13'TSchedule.AddStream'#13);
  Assert((iDay<=5)and(iPair<=6),'2EAE3778-E575-4FBD-B9F7-A73CD71E906E'#13'TSchedule.AddStream'#13);

  Result:=false;
  if Assigned(OnAddStream) then
  begin
    BeginUpdate;
    OnAddStream(Self, strid, iWeek, iDay, iPair, HGrp, aid, Result);
    EndUpdate;
  end;
end;                                                     

procedure TSchedule.BeginUpdate;
begin
  inc(FUpdateCount);
end;

// ������� ����������
procedure TSchedule.Clear;
begin
  FList.Clear;
end;

constructor TSchedule.Create;
begin
  inherited Create;
  FUpdateCount:=0;
  FList:=TObjectList.Create;
end;

// �������� ������ �� ����������
// ���������� true, ���� ������ ������� ������� �� ����������s
function TSchedule.DelGroup(const grid: int64): boolean;
//function TSchedule.DelGroup(const name: string): boolean;
var
  Grp: TGroup;
begin
  Result:=false;
  Grp:=GroupByGrid(grid);
  if Assigned(Grp) then
  begin
    if Assigned(OnDelGroup) then OnDelGroup(Grp);
    FList.Remove(Grp);
    FList.Pack;
  end;
end;

// �������� �����. ������� �� ����������
// strid - id ������
// iDay - ����
// iPair - ����
// true - ������� �������
function TSchedule.DelStream(const strid: int64; const iWeek,iDay,iPair: byte): boolean;
begin
  Assert(strid>0,'EEE49EA9-3A74-4723-ADD4-AA49AFEA1261'#13'TSchedule.DelStream'#13);
  Assert((iDay<=5)and(iPair<=6),'BDB142F8-9611-42A0-AD8C-B58720F9D829'#13'TSchedule.DelStream'#13);

  Result:=false;
  if Assigned(OnDelStream) then
  begin
    BeginUpdate;
    OnDelStream(Self, strid, iWeek, iDay, iPair, false, -1, Result);
    EndUpdate;
  end;
end;

// ���������� ���������� ������  (01/11/06)
procedure TSchedule.UpdateStrm(const strid: int64);
var
  i: integer;
  d,p: byte;
  grp: TGroup;
  lsns: TLsns;
begin
  Assert(strid>0,
    'BE4495CC-B704-418B-B9D3-A9F8B638FABA'#13'TSchedule.UpdateStrm: strid<=0'#13);

  if Assigned(OnGetStream) then
  begin
    BeginUpdate;

    for i:=0 to FList.Count-1 do
    begin
      grp:=GetGroupIndex(i);

      for d:=0 to 5 do
        for p:=0 to 6 do
          with grp.Item[d,p] do
            repeat
              lsns:=FindStrm(strid);
              if Assigned(lsns) then Delete(lsns);
            until not Assigned(lsns);
    end;

    OnGetStream(Self,strid);
    EndUpdate;
  end;
end;

destructor TSchedule.Destroy;
begin
  FList.Free;
  inherited Destroy;
end;

procedure TSchedule.EndUpdate;
begin
  Assert(FUpdateCount>0,
    '18C28129-CA2D-4073-A35C-20A2865D5BF8'#13'TSchedule.EndUpdate: FUpdateCount<=0'#13);

  dec(FUpdateCount);
end;

// ����� ������ �� �����
// ���� ������ ��� ���������� -1, ����� ������ ������
function TSchedule.FindGroup(const grid: int64): integer;
//function TSchedule.FindGroup(const grid: string): integer;
var
  i: integer;
begin
  Result:=-1;
  for i:=0 to FList.Count-1 do
    if TGroup(FList.Items[i]).Grid=grid then
    begin
      Result:=i;
      break;
    end;
end;

// ����� ������ �� ������� (08.08.2005)
// ���������� ��������� �� ������
function TSchedule.GroupByGrid(const grid: int64): TGroup;
var
  i: integer;
begin
  Result:=nil;
  for i:=0 to FList.Count-1 do
    if TGroup(FList.Items[i]).Grid=grid then
    begin
      Result:=TGroup(FList.Items[i]);
      break;
    end;
end;

// ���������� ����� ����� � ����������
function TSchedule.GetCount: integer;
begin
  Result:=FList.Count;
end;

function TSchedule.GetGroupIndex(index: integer): TGroup;
begin
  Result:=TGroup(FList.Items[index]);
end;

// ����� ������ �� �����
// ���������� ��������� �� ������
function TSchedule.GroupByName(const name: string): TGroup;
var
  i: integer;
begin
  Result:=nil;
  for i:=0 to FList.Count-1 do
    if TGroup(FList.Items[i]).Name=name then
    begin
      Result:=TGroup(FList.Items[i]);
      break;
    end;
//  i:=FindGroup(name);
//  if i<>-1 then Result:=TGroup(FList.Items[i]);
end;

// true - �����������
function TSchedule.IsLocked: boolean;
begin
  Result:=(FUpdateCount>0);
end;

// ���������� ���������� ���� �����
procedure TSchedule.Update;
var
  i: integer;
begin
  BeginUpdate;
  for i:=0 to FList.Count-1 do
    TGroup(FList.Items[i]).Update;
  EndUpdate;
end;

{ TTimeLsns }

constructor TTimeLsns.Create;
begin
  FGroupList:=TDataList.Create;
end;

destructor TTimeLsns.Destroy;
begin
  FGroupList.Free;
  FGroupList:=nil;
  inherited;
end;

// ����� ������ �� id (02/08/06)
function TTimeLsns.FindGroup(id: int64): integer;
var
  i: integer;
begin
  Result:=-1;

  for i:=0 to FGroupList.Count-1 do
    if id=FGroupList.GetID(i) then
    begin
      Result:=i;
      break;
    end;
end;

// ���������� ���-�� ����� �� ������� (01/08/06)
function TTimeLsns.GetGroupCount: integer;
begin
  Result:=FGroupList.Count;
end;

// ���������� ������ (01/08/06)
function TTimeLsns.GetGroupItem(index: integer): PDataItem;
begin
  Result:=FGroupList.Items[index];
end;

// ���������� ������-������ ����� (02/08/06)
function TTimeLsns.GetGroupString(ACount: integer): string;

  // ������ ����
  function GetGroupNames: string;
  var
    i,c: integer;
  begin
    Result:='';
    c:=FGroupList.Count;
    if ACount<c then c:=ACount;

    for i:=0 to c-2 do
      Result:=Result+FGroupList.Name[i]+'; ';
    Result:=Result+FGroupList.Name[c-1];
  end;  // function GetGroupNames

  // ������ ������
  function GetGroupCourses: string;
  var
    i: integer;
    iCourses: array[0..6] of integer;
  begin
    for i:=0 to 6 do iCourses[i]:=0;

    for i:=0 to FGroupList.Count-1 do
      Inc(iCourses[FGroupList.Tag[i]-1]);

    for i:=0 to 6 do
      if iCourses[i]>0 then Result:=Format('%s%d,',[Result,i+1]);
    Delete(Result,Length(Result),1);
    Result:=Result+' ����';
  end;  // function GetGroupCourses

begin
  if ACount>=FGroupList.Count then Result:=GetGroupNames()
    else Result:=GetGroupCourses();
end;

// ���������� ������ � ������ (02/08/06)
function TTimeLsns.AddGroup(id: int64; name: string;
  course: byte): integer;
begin
  Result:=-1;
  if FindGroup(id)=-1 then FGroupList.Add(id,name,course);
end;

{ TTimeList }

// ���������� ������� � ������ (02/08/06)
function TTimeList.AddTimeLsns(ALSID: int64; ADay, APair, AWeek, ALType: byte;
  AResource: string): TTimeLsns;
begin
  Assert(ADay in [0..NumberDays-1],
    'C12D6993-354D-45CD-A776-3E46941E27E7'#13'AddTimeLsns: invalid ADay'#13);
  Assert(APair in [0..NumberPairs-1],
    '0BEDA5E8-3BD9-4438-84D1-015DF2707651'#13'AddTimeLsns: invalid APair'#13);
  Assert(AWeek in [0..2],
    '102C7A79-02B0-4A2D-AED4-98528ED3A684'#13'AddTimeLsns: invalid AWeek'#13);

  Result:=nil;

  if CheckPlace(ADay,APair,AWeek) then
  begin
    Result:=TTimeLsns.Create;
    Result.FLSID:=ALSID;
    Result.FLType:=ALType;
    Result.FDay:=ADay;
    Result.FPair:=APair;
    Result.FWeek:=AWeek;
    Result.FResource:=AResource;
    FLsnsList.Add(Result);
  end
  else Assert(false, '838B7A65-90C5-44F3-BD84-52E650FF93DB'#13'AddTimeLsns: global error'#13);
end;

// �������� ����������� �������� ������� (02/08/06)
// ���������� �������� ����������� ��
function TTimeList.CheckPlace(ADay, APair, AWeek: byte): boolean;
var
  i: integer;
  lsns: TTimeLsns;
begin
  Assert(ADay in [0..NumberDays-1],
    '9F82101A-8D41-4D92-97F7-4532702AD9B7'#13'CheckPlace: invalid ADay'#13);
  Assert(APair in [0..NumberPairs-1],
    '2259EF88-CA8B-42AA-B19C-54253B33AF91'#13'CheckPlace: invalid APair'#13);
  Assert(AWeek in [0..2],
    '99A7FB70-3018-48CF-B258-BE41AD67E66E'#13'CheckPlace: invalid AWeek'#13);

  Result:=true;

  for i:=0 to FLsnsList.Count-1 do
  begin
    lsns:=TTimeLsns(FLsnsList[i]);
    if (lsns.Day=ADay) and (lsns.Pair=APair) and
      ((lsns.Week=AWeek) or (AWeek=0) or (lsns.Week=0)) then
    begin
      Result:=false;
      break;
    end;
  end;
end;

procedure TTimeList.Clear;
begin
  FLsnsList.Clear;
end;

constructor TTimeList.Create(AId: int64; AName: string; AParent: TTimeGrid);
begin
  FLsnsList:=TObjectList.Create;
  FParent:=AParent;
  FId:=AId;
  FName:=AName;
end;

destructor TTimeList.Destroy;
begin
  FLsnsList.Free;
  inherited;
end;

// ���������� ���-�� ������� (02/08/06)
function TTimeList.GetCount: integer;
begin
  Result:=FLsnsList.Count;
end;

// ���������� ������� ����. ���� (������) (03/08/06)
function TTimeList.GetLsns(ADay, APair: byte; AIndex: integer): TTimeLsns;
var
  i,n: integer;
  TimeLsns: TTimeLsns;
begin
  Assert(ADay in [0..NumberDays-1],
    '65121EA4-BA36-427B-82CA-ED3ABAC0ECD6'#13'GetLsns: invalid ADay'#13);
  Assert(APair in [0..NumberPairs-1],
    '180AB2BF-9DD8-4E45-ABC6-350266919CEE'#13'GetLsns: invalid APair'#13);
  Assert(AIndex in [0..1],
    'C18C856D-6467-40F7-80A5-8FCD72A6ACBB'#13'GetLsns: global error'#13);

  Result:=nil;

  n:=0;
  for i:=0 to FLsnsList.Count-1 do
  begin
    TimeLsns:=TTimeLsns(FLsnsList[i]);
    if (TimeLsns.Day=ADay) and (TimeLsns.Pair=APair) then
      if n=AIndex then
      begin
        Result:=TimeLsns;
        break;
      end
      else Inc(n);
  end;
end;

// ���������� ���-�� ������� �� ����. ���� (03/08/06)
function TTimeList.GetLsnsCount(ADay,APair: byte): integer;
var
  i: integer;
  lsns: TTimeLsns;
begin
  Assert(ADay in [0..NumberDays-1],
    'E07D8AA8-6683-4C4E-986F-6A28E2867657'#13'GetLsnsCount: invalid ADay'#13);
  Assert(APair in [0..NumberPairs-1],
    'F3EEAFEB-34D1-4C80-A93E-BBB155E6D8B7'#13'GetLsnsCount: invalid APair'#13);

  Result:=0;
  for i:=0 to FLsnsList.Count-1 do
  begin
    lsns:=TTimeLsns(FLsnsList[i]);
    if (lsns.Day=ADay) and (lsns.Pair=APair) then Inc(Result);
  end;
end;

// ���������� ������� ����. ���� (02/08/06)
{
function TTimeList.GetLsnsOfPair(ADay,APair: byte): TTimeLsns;
var
  i: integer;
  TimeLsns: TTimeLsns;
begin
  Assert(ADay in [1..6],
    'C47C0D32-5941-453E-A3B0-947E62C2AA52'#13'GetLsnsOfPair: invalid ADay'#13);
  Assert(APair in [1..7],
    'A0254960-6C5F-45AD-B2F9-5BEDA2797793'#13'GetLsnsOfPair: invalid APair'#13);

  Result:=nil;

  for i:=0 to FLsnsList.Count-1 do
  begin
    TimeLsns:=TTimeLsns(FLsnsList[i]);
    if (TimeLsns.Day=ADay) and (TimeLsns.Pair=APair) then
    begin
      Result:=TimeLsns;
      break;
    end;
  end;
end;
}

// �������� �� ����. ���� (06/08/06)
function TTimeList.IsDoublePair(ADay, APair: byte): boolean;

  function ExistsNextLsns(ALsns: TTimeLsns): boolean;
  var
    i,c: integer;
    l: TTimeLsns;
  begin
    Result:=false;
    c:=GetLsnsCount(ADay,APair+1);
    for i:=0 to c-1 do
    begin
      l:=GetLsns(ADay,APair+1,i);
      if (l.LSID=ALsns.LSID) and (GetID(l.Resource)=GetID(ALsns.Resource))
          and (l.Week=ALsns.Week) then
      begin
        Result:=true;
        break;
      end;
    end;

  end;  // ExistsNextLsns

var
  c, nc: integer;
  i: integer;
begin
  Assert(ADay in [0..NumberDays-1],
    '8F45E819-9364-4784-A9D3-C15B753AF66A'#13'IsDoublePair: invalid ADay'#13);
  Assert(APair in [0..NumberPairs-1],
    'B4C3AE86-6E18-426B-83E6-22F8A263E7E3'#13'IsDoublePair: invalid APair'#13);

  Result:=false;

  if APair<NumberPairs-1 then
  begin
    c:=GetLsnsCount(ADay,APair);
    nc:=GetLsnsCount(ADay,APair+1);
    if (c=nc) and (c>0) then
    begin
      Result:=true;
      for i:=0 to c-1 do
        if not ExistsNextLsns(GetLsns(ADay,APair,i)) then
        begin
          Result:=false;
          break;
        end;
    end;
  end;
end;

// �������� ������ ������� �� ������ ������ (02/08/06)
procedure TTimeList.LoadFrom(ARecordset: _Recordset; AResId, AResName: string);
var
  week,wday,npair: integer;
  s: string;
  lsid: int64;
  lsns: TTimeLsns;
begin
  lsns:=nil;
  week:=-1;
  wday:=-1;
  npair:=-1;

  ARecordset.Sort:='wday ASC, npair ASC, week ASC';
  while not ARecordset.EOF do
  begin
    if (wday<>integer(ARecordset.Fields['wday'].Value)-1) or
       (npair<>integer(ARecordset.Fields['npair'].Value)-1) or
       (week<>integer(ARecordset.Fields['week'].Value)) then
    begin
      wday:=integer(ARecordset.Fields['wday'].Value)-1;
      npair:=integer(ARecordset.Fields['npair'].Value)-1;
      week:=integer(ARecordset.Fields['week'].Value);
      s:=SUtils.Format(VarToStr(ARecordset.Fields[AResId].Value),
          VarToStr(ARecordset.Fields[AResName].Value));
      if VarIsNull(ARecordset.Fields['strid'].Value) then
        lsid:=ARecordset.Fields['lid'].Value
      else lsid:=ARecordset.Fields['strid'].Value;
      lsns:=AddTimeLsns(lsid,wday,npair,week,integer(ARecordset.Fields['type'].Value),s);
    end
    else
    begin
      lsns.AddGroup(ARecordset.Fields['grid'].Value,
        VarToStr(ARecordset.Fields['grName'].Value),
        integer(ARecordset.Fields['course'].Value));
      ARecordset.MoveNext;
    end;
  end;
end;

// ���������� ������ ������� (01/08/06)
procedure TTimeList.Update;
begin
  FLsnsList.Clear;
  if Assigned(FParent.FOnUpdateItem) then FParent.FOnUpdateItem(Self);
end;

{ TTimeGrid }

// ���������� ����������(��������) ������� (01/08/06)
function TTimeGrid.Add(id: int64; name: string): integer;
var
  TimeList: TTimeList;
begin
  Result:=FindItem(id);
  if Result=-1 then
  begin
    TimeList:=TTimeList.Create(id,name,Self);
    Result:=FList.Add(TimeList);
    if Assigned(FOnAddItem) then FOnAddItem(TimeList);
    if Assigned(FOnUpdateItem) then FOnUpdateItem(TimeList);
  end;
end;

// �������� ���� ���������� (15/08/06)
procedure TTimeGrid.Clear;
var
  i: integer;
begin
  for i:=FList.Count-1 downto 0 do Delete(i);
end;

constructor TTimeGrid.Create;
begin
  FList:=TObjectList.Create;
end;

// �������� ���������� (��������) ������� (01/08/06)
procedure TTimeGrid.Delete(index: integer);
var
  TimeList: TTimeList;
begin
  TimeList:=TTimeList(FList[index]);
  Remove(TimeList);
//  if Assigned(FOnDeleteItem) then FOnDeleteItem(TimeList);
//  FList.Remove(TimeList);
//  FList.Pack;
end;

destructor TTimeGrid.Destroy;
begin
  FList.Free;
  inherited;
end;

// ����� ������� (01/08/06)
function TTimeGrid.FindItem(const id: int64): integer;
var
  i: integer;
begin
  Result:=-1;

  for i:=0 to FList.Count-1 do
    if TTimeList(FList[i]).Id=id then
    begin
      Result:=i;
      break;
    end;
end;

// ���������� ���-�� ���������� (06/08/06)
function TTimeGrid.GetItemCount: integer;
begin
  Result:=FList.Count;
end;

// ���������� ������� �� ������� (01/08/06)
function TTimeGrid.GetItemIndex(index: integer): TTimeList;
begin
  Result:=TTimeList(FList[index]);
end;

// �������� ���������� (��������) ������� (04/08/06)
procedure TTimeGrid.Remove(ATimeList: TTimeList);
begin
  if Assigned(FOnDeleteItem) then FOnDeleteItem(ATimeList);
  FList.Remove(ATimeList);
  FList.Pack;
end;

// ���������� (02/08/06)
procedure TTimeGrid.Update;
var
  i: integer;
begin
  for i:=0 to FList.Count-1 do
    TTimeList(FList[i]).Update;
end;

end.
