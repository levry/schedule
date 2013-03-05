{
  Базовый модуль данных (клиент. программы)
  v0.0.3  (08/08/06)
  (C) Leonid Riskov, 2006
}
unit ClientModule;

interface

uses
  SysUtils, Classes, ADODB, DB,
  STypes, BaseModule;

type

  // базовый класс модуля данных (клиент. программы)
  // для наследников необходимо переопределять методы
  // DoLoginUser и DoLogoffUser
  TClientDataModule = class(TBaseDataModule)
    spDBView: TADOCommand;

  private
    { Private declarations }
    FYear: word;                // год
    FSem:  byte;                // семестр (1 - осенний, 2 - весенний)
    FPSem: byte;                // полусеместр (1 - 1ый, 2 - 2ой)
    FOnChangeTime: TFlagsEvent; // событие изм-ния времени

    FFacultyList: TStringList;  // список факультетов
    function GetFacultyList(AList: TStrings): boolean;

    procedure Set_Year(value: word);
    procedure Set_PSem(value: byte);
    procedure Set_Sem(value: byte);

  protected
    function DoConnect: integer; override;
    procedure DoDisconnect; override;

    function DoLoginUser: boolean; virtual;
    procedure DoLogoffUser;

    function yr_GetAll: _Recordset;
    function pst_GetAll: _Recordset;
    function fcl_GetAll: _Recordset;
    function kaf_Get_f(fid: integer): _Recordset;

  public
    { Public declarations }
    property Year: word read FYear write Set_Year;
    property Sem: byte read FSem write Set_Sem;
    property PSem: byte read FPSem write Set_PSem;
    property FacultyList: TStringList read FFacultyList;

    property OnChangeTime: TFlagsEvent read FOnChangeTime write FOnChangeTime;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function ChangeYear: boolean; virtual;

    // списки
    function GetKafedraList(AList: TStrings): boolean; overload;
    function GetKafedraList(fid: integer; AList: TStrings): boolean; overload;
    function GetPostList(AList: TStrings): boolean;

    // функции просмотра данных
    function dbv_GetKaf: _Recordset;
    function dbv_GetGrpKaf(kid: int64): _Recordset;
    function dbv_GetSubjGrp(grid: int64): _Recordset;
    function dbv_GetSubjKaf(kid: int64): _Recordset;
    function dbv_GetGroupCrs(course: byte): _Recordset;
//    function dbv_GetKafWithGrp: _Recordset;
    function dbv_GetSubjWP(letter: string): _Recordset;
    function dbv_GetGrpSubj(sbid: int64): _Recordset;
    function dbv_GetSubjGrp_e(grid: int64): _Recordset;

  end;

implementation

uses
  Variants, OleDB, ADOInt, Dialogs, Windows,
  SStrings, SConsts, SUtils, StringListDlg;

{$R *.dfm}

{ TClientDataModule }

constructor TClientDataModule.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FYear:=0;
  FSem:=0;
  FPSem:=0;

  FFacultyList:=TStringList.Create;
end;

destructor TClientDataModule.Destroy;
begin
  FFacultyList.Free;
  FFacultyList:=nil;

  inherited Destroy;
end;

// изм-ние уч. года
procedure TClientDataModule.Set_Year(value: word);
begin
  Assert(value>0,
    'A538E750-0D65-4C91-B998-B488A83284C4'#13'Set_Year: invalid value'#13);

  if value<>FYear then
  begin
    FYear:=value;
    FSem:=1;
    FPSem:=1;
    if Assigned(FOnChangeTime) then
      FOnChangeTime(Self, CT_YEAR or CT_SEM or CT_PSEM);
  end;
end;

// изм=ние семестра
procedure TClientDataModule.Set_Sem(value: byte);
begin
  Assert(value in [1,2],
    '53A5572D-3E80-4F67-A9EE-F1D0CE5BD53F'#13'Set_Sem: invalid value'#13);

  if value<>FSem then
  begin
    FSem:=value;
    FPSem:=1;
    if Assigned(FOnChangeTime) then FOnChangeTime(Self, CT_SEM or CT_PSEM);
  end;
end;

// изм-ние п/сем
procedure TClientDataModule.Set_PSem(value: byte);
begin
  Assert(value in [1,2],
    '2CD1B259-903A-4E65-85AA-68A8F3D4DAE6'#13'Set_PSem: invalid value'#13);

  if value<>FPSem then
  begin
    FPSem:=value;
    if Assigned(FOnChangeTime) then FOnChangeTime(Self, CT_PSEM);
  end;
end;

// смена уч. года (08/08/06)
function TClientDataModule.ChangeYear: boolean;

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

// начало сеанса пользователя (31/07/06)
// TODO: Изменить при добавлении функциональной роли - кафедры
function TClientDataModule.DoLoginUser: boolean;
var
  FacultyIndex: integer;
begin
  Result:=false;

  if GetIndexFromList(rsFaculty, FacultyIndex, FFacultyList) then
  begin
    FFacultyList.Move(FacultyIndex,0);
    Result:=ChangeYear;
  end
end;

// завершение сеанса (31/07/06)
procedure TClientDataModule.DoLogoffUser;
begin
  // TODO: Сохранять имзенен. настройки в БД для пользователя
end;

function TClientDataModule.DoConnect: integer;
begin
  if not GetFacultyList(FFacultyList) then Result:=ERROR_CON_FACULTY else
    if DoLoginUser then Result:=ERROR_CON_SUCCESS
      else Result:=ERROR_CON_USER;
end;

procedure TClientDataModule.DoDisconnect;
begin
  DoLogoffUser;
end;

// списки

// возвращает список факультетов (09.04.06)
function TClientDataModule.GetFacultyList(AList: TStrings): boolean;
var
  rs: _Recordset;
  s: string;
begin
  Assert(Assigned(AList),
    'C5C7EC7F-97DA-4C30-817B-1F002590E075'#13'GetFacultyList: AList is nil'#13);

  rs:=fcl_GetAll();
  if Assigned(rs) then
  try
    AList.Clear;
    try
      while not rs.EOF do
      begin
        s:=VarToStr(rs.Fields['fid'].Value)+'='+VarToStr(rs.Fields['fName'].Value);
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

// возвращает список кафедр
function TClientDataModule.GetKafedraList(AList: TStrings): boolean;
var
  rs: _Recordset;
  s: string;
begin
  Assert(Assigned(AList),
    '6021FD48-DF8D-4010-A155-B040C2D961D2'#13'GetKafedraList: AList is nil'#13);

  rs:=dbv_GetKaf();
  if Assigned(rs) then
  try
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

// возвращает список кафедр факультета (10.04.06)
function TClientDataModule.GetKafedraList(fid: integer; AList: TStrings): boolean;
var
  rs: _Recordset;
  s: string;
begin
  Assert(fid>0,
    '8E5632D6-7444-4D16-82F5-E5EB41EB7C49'#13'GetKafedraList: invalid fid'#13);
  Assert(Assigned(AList),
    '5AC66CFC-3C2A-4E09-A6E9-4886FAEC7E0F'#13'GetKafedraList: AList is nil'#13);

  rs:=kaf_Get_f(fid);
  if Assigned(rs) then
  try
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

// возвращает список ранков
function TClientDataModule.GetPostList(AList: TStrings): boolean;
var
  rs: _Recordset;
  s: string;
begin
  rs:=pst_GetAll;
  if Assigned(rs) then
  try
    AList.Clear;
    rs.Sort:='pName ASC';
    while not rs.EOF do
    begin
      s:=SUtils.Format(VarToStr(rs.Fields['pid'].Value),
          VarToStr(rs.Fields['pName'].Value),
          VarToStr(rs.Fields['pSmall'].Value));
      AList.Add(s);
      rs.MoveNext;
    end;
  finally
    rs.Close;
    rs:=nil;
  end;

  Result:=(AList.Count>0);
end;

// Переопр-ся у потомков
{
// смена(выбор) уч. года (20.04.06)
function TdmCommon.ChangeYear: boolean;

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
          if Result then Set_Year(y);
        end;
    finally
      list.Free;
      list:=nil;
    end;
  end
  else raise Exception.Create(rsErrNoConnect);
end;
}

// Выбор групп кафедры (14.08.04)
function TClientDataModule.dbv_GetGrpKaf(kid: int64): _Recordset;
begin
  Assert(kid>0,
    '10A07DCF-B0D9-4D90-9F0A-036B837A76DF'#13'dbv_GetGrpKaf: invalid kid'#13);

  Result:=_OpenSP(spDBView, ['@case','@ynum','@kid'],[dbvSelGroupOfKaf,FYear,kid]);
end;

// выбор групп курса (25.01.06)
function TClientDataModule.dbv_GetGroupCrs(course: byte): _Recordset;
begin
  Result:=_OpenSP(spDBView, ['@case','@ynum','@course'],[dbvSelGrpCrs,FYear,course]);
end;

// выбор кафедр-заказчиков (1.03.06)
{
function TClientDataModule.dbv_GetKafWithGrp: _Recordset;
begin
  Result:=_OpenSP(spDBView, ['@case','@ynum'], [dbvSelKafWithGrp,FYear]);
end;
}

// Выбор всех кафедр (13.08.2004)
function TClientDataModule.dbv_GetKaf: _Recordset;
begin
  Result:=_OpenSP(spDBView,['@case'],[dbvSelKaf]);
end;

// выбор дисциплин кафедры (15.08.2004)
function TClientDataModule.dbv_GetSubjKaf(kid: int64): _Recordset;
begin
  Assert(kid>0,
    'ED6DE0FA-89C1-4B01-A57A-185B41085BF9'#13'dbv_GetSubjKaf: invalid kid'#13);

  Result:=_OpenSP(spDBView,['@case','@ynum','@sem','@kid'],
      [dbvSelSubjOfKaf,FYear,FSem,kid]);
end;

// выбор дисциплин указ. группы для дан. семестра (30.10.2004)
function TClientDataModule.dbv_GetSubjGrp(grid: int64): _Recordset;
begin
  Assert(grid>0,
    '47718A88-2821-4362-B606-3734826FC004'#13'dbv_GetSubjGrp: invalid grid'#13);

  Result:=_OpenSP(spDBView,['@case','@sem','@grid'],[dbvSelSubjOfGrp,FSem,grid]);
end;

// выбор дисциплин, присутств. в р.п. (16.03.06)
function TClientDataModule.dbv_GetSubjWP(letter: string): _Recordset;
begin
  Assert(letter<>'',
    '1DED8EE5-CF98-4B48-814F-3783F9876CD0'#13'dbv_GetSubjWP: invalid letter'#13);

  Result:=_OpenSP(spDBView,['@case','@letter','@ynum','@sem'],
    [dbvSelSubj,letter,FYear,FSem]);
end;

// выбор групп, р.п. к-рых содержат дисциплину (16.03.06)
function TClientDataModule.dbv_GetGrpSubj(sbid: int64): _Recordset;
begin
  Assert(sbid>0,
    'FBA0B9BA-0B4B-4105-A78A-A1476A33019D'#13'sbj_GetWP: invalid sbid'#13);

  Result:=_OpenSP(spDBView,['@case','@sbid','@ynum','@sem'],
    [dbvSelGroupOfSbj,sbid,FYear,FSem]);
end;

// выбор званий преп-лей (12.08.2005)
function TClientDataModule.pst_GetAll: _Recordset;
begin
  Result:=_OpenSP(spDBView,['@case'],[dbvSelPosts]);
end;

// выбор факультетов (09.04.06)
function TClientDataModule.fcl_GetAll: _Recordset;
begin
  Result:=_OpenSP(spDBView,['@case'],[dbvSelFaculty]);
end;

// выбор кафедр факультета (09.04.06)
function TClientDataModule.kaf_Get_f(fid: integer): _Recordset;
begin
  Assert(fid>0,
    '99E9F2B5-6ABC-43B8-90BC-7F1B43BC9F46'#13'kaf_Get_f: invalid fid'#13);

  Result:=_OpenSP(spDBView,['@case','@fid'],[dbvSelKafOfFcl,fid]);
end;

function TClientDataModule.yr_GetAll: _Recordset;
begin
  Result:=_OpenSP(spDBView,['@case'],[dbvSelYears]);
end;

// выбор дисциплин группы, по к-рым проводится экз (06.05.06)
function TClientDataModule.dbv_GetSubjGrp_e(grid: int64): _Recordset;
begin
  Assert(grid>0,
    'E9FB67F7-5E1C-4636-89B8-75BCD454459E'#13'dbv_GetSubjGrp_e: invalid grid'#13);

  Result:=_OpenSP(spDBView,['@case','@sem','@grid'],[dbvSelExamSubj,FSem,grid]);
end;

end.
