unit ModelData;

// модель данных (версия 2) 

interface

uses
  DBData, DB, ADOInt;

type

  // кафдера
  TDBKafedra = class(TDBObject)
  private
    fname: string;
  protected
    procedure Assign(Source: TObject); overload; override;
    procedure Assign(Source: Fields); reintroduce; overload;
    function Assign(const Source: string): boolean; reintroduce; overload;
  public

    property name: string read fname;
  end;

  // аудитория
  TDBAuditory = class(TDBObject)
  private
    fname: string;
    fcapacity: byte;
//    fkafedra: TDBKafedra;
  protected
    procedure Assign(Source: TObject); overload; override;
    procedure Assign(Source: Fields); reintroduce; overload;
  public
    constructor Create(const aid: int64); override;
    destructor Destroy; override;

    property name: string read fname;
    property capacity: byte read fcapacity;
//    property kafedfra: TDBKafedra read fkafedra;
  end;

  // группа
  TDBGroup = class(TDBObject)
  private
    fname: string;
    fstuds: byte;
    fcourse: byte;
    fkafedra: TDBKafedra;
  protected
    procedure Assign(Source: TObject); overload; override;
    procedure Assign(Source: Fields); reintroduce; overload;
  public
    constructor Create(const aid: int64); override;
    destructor Destroy; override;

    property name: string read fname;
    property studs: byte read fstuds;
    property course: byte read fcourse;
  end;

  // дисциплина
  TDBSubject = class(TDBObject)
  private
    fname: string;
    fsmall: string;
  protected
    procedure Assign(Source: TObject); overload; override;
    procedure Assign(Source: Fields); reintroduce; overload;
    function Assign(Source: string): boolean; reintroduce; overload;
  public

    property name: string read fname;
    property small: string read fsmall;
  end;


  // преподаватель
  TDBTeacher = class(TDBObject)
  private
    fname: string;
    fpost: string;
//    fkafedra: TDBKafedra;
  protected
    procedure Assign(Source: TObject); overload; override;
    procedure Assign(Source: Fields); reintroduce; overload;
    function Assign(const Source: string): boolean; reintroduce; overload;
  public
    constructor Create(const aid: int64); override;
    destructor Destroy; override;

    property name: string read fname;
    property post: string read fpost;
//    property kafedra: TDBKafedra read fkafedra;
  end;

  TDBWorkplan = class;

  TLsnsType = (ltLection=1, ltPractic=2, ltLabo=3);

  // нагрузка
  TDBLoad = class(TDBObject)
  private
    fpsem: byte;
    ftype: TLsnsType;
    fhours: byte;
    fstrid: int64;
    fteacher: TDBTeacher;

    procedure SetTeacher(Value: TDBTeacher);
    function GetWorkplan: TDBWorkplan;
  protected
    procedure SetHours(Value: byte);
    procedure Assign(Source: TObject); overload; override;
    procedure Assign(Source: Fields); reintroduce; overload;
  public
    constructor Create(const aid: int64); override;
    destructor Destroy; override;

    property workplan: TDBWorkplan read GetWorkplan;
    property psem: byte read fpsem;
    property ltype: TLsnsType read ftype;
    property hours: byte read fhours write SetHours;
    property teacher: TDBTeacher read fteacher write SetTeacher;
    property strid: int64 read fstrid;
  end;

  // набор нагрузок
  TDBLoadList = class(TDBList)
  private
    fworkplan: TDBWorkplan;
  protected
    function GetLoadIndex(index: integer): TDBLoad;
    function CheckObject(DBObject: TDBObject): boolean; override;
    function ExternalChange(DBObject: TDBObject; FieldName: string;
        const Value: Variant): boolean; override;
  public
    constructor Create(Workplan: TDBWorkplan);
    property Items[index: integer]: TDBLoad read GetLoadIndex; default;
  end;

  // раб. план (1 дисциплина)
  TDBWorkplan = class(TDBObject)
  private
    fsubject: TDBSubject;
    fkafedra: TDBKafedra;
    fsem: byte;
    fexamen: boolean;
    floads: TDBLoadList;

    procedure SetExamen(value: boolean);
    procedure SetKafedra(value: TDBKafedra);

    procedure DoLoadInsert(Sender: TObject; DBObject: TDBObject; var Id: int64);
    procedure DoLoadDelete(Sender: TObject; DBObject: TDBObject; var Allow: boolean);
    procedure DoLoadChange(Sender: TObject; DBObject: TDBObject; const FieldName: string;
        const NewValue: Variant; var Allow: boolean);
  protected
    procedure Assign(Source: TObject); overload; override;
    procedure Assign(Source: Fields); reintroduce; overload;
  public
    constructor Create(const aid: int64); override;
    destructor Destroy; override;

    property subject: TDBSubject read fsubject;
    property kafedra: TDBKafedra read fkafedra write SetKafedra;
    property sem: byte read fsem;
    property examen: boolean read fexamen write SetExamen;
    property loads: TDBLoadList read floads;
  end;

  // раб. план (набор)
  TDBWorkplanList = class(TDBList)
  protected
    function GetWorkplanIndex(index: integer): TDBWorkplan;
    function CheckObject(DBObject: TDBObject): boolean; override;
    function ExternalChange(DBObject: TDBObject; FieldName: string;
        const Value: Variant): boolean; override;
  public
    property Items[index: integer]: TDBWorkplan read GetWorkplanIndex; default;
  end;

  CoSubject = class
  public
    class function Create(Fields: TFields): TDBSubject; overload;
    class function Create(ssbj: string): TDBSubject; overload;
  end;

  CoKafedra = class
  public
    class function Create(Fields: TFields): TDBKafedra; overload;
    class function Create(const skaf: string): TDBKafedra; overload;
  end;

  CoTeacher = class
  public
    class function Create(Fields: TFields): TDBTeacher; overload;
    class function Create(const sthr: string): TDBTeacher; overload;
  end;

  CoLoad = class
  public
    class function Create(npsem, ntype, nhours: byte): TDBLoad; overload;
    class function Create(Fields: TFields): TDBLoad; overload;
  end;

  CoWorkplan = class
  public
    class function Create(nsem: byte; ssbj, skaf: string; bexamen: boolean): TDBWorkplan; overload;
    class function Create(Fields: TFields): TDBWorkplan; overload;
  end;

implementation

uses
  Variants, SysUtils, SUtils;

{ TDBKafedra }

procedure TDBKafedra.Assign(Source: TObject);

  procedure CopyFromDBObject(DBObject: TDBKafedra);
  begin
    fid:=DBObject.id;
    fname:=DBObject.name;
  end;

  procedure CopyFromFields(Fields: TFields);
  begin
    fid:=Fields.FieldByName('kid').AsInteger;
    fname:=Fields.FieldByName('kName').AsString;
  end;

begin
  if Assigned(Source) then
    if Source is TDBKafedra then CopyFromDBObject(TDBKafedra(Source)) else
      if Source is TFields then CopyFromFields(TFields(Source))
        else raise Exception.Create('TDBKafedra.Assign: Unknown object class');
end;

procedure TDBKafedra.Assign(Source: Fields);
begin
  fid:=Source.Item['kid'].Value;
  fname:=Source.Item['kname'].Value;
end;

function TDBKafedra.Assign(const Source: string): boolean;
var
  nid: int64;
begin
  Result:=false;
  if Source<>'' then
  begin
    nid:=StrToInt64(GetName(Source));
    if nid>0 then
    begin
      fid:=nid;
      fname:=GetValue(Source);
      Result:=true;
    end;
  end;
end;

{ TDBAuditory }

constructor TDBAuditory.Create(const aid: int64);
begin
  inherited Create(aid);
//  fkafedra:=TDBKafedra.Create(0);
end;

procedure TDBAuditory.Assign(Source: TObject);

  procedure CopyFromDBObject(DBObject: TDBAuditory);
  begin
    fid:=DBObject.id;
    fname:=DBObject.name;
    fcapacity:=DBObject.capacity;
//    fkafedra.Assign(DBObject.kafedfra);
  end;

begin
  if Assigned(Source) then
    if Source is TDBAuditory then CopyFromDBObject(TDBAuditory(Source))
      else raise Exception.Create('TDBAuditory.Assign: Unknown object class');
end;

procedure TDBAuditory.Assign(Source: Fields);
begin
  fid:=Source.Item['aid'].Value;
  fname:=Source.Item['aname'].Value;
//  fkafedra.Assign(Source);
end;

destructor TDBAuditory.Destroy;
begin
//  if Assigned(fkafedra) then
//  begin
//    fkafedra.Free;
//    fkafedra:=nil;
//  end;
  inherited;
end;

{ TDBGroup }

constructor TDBGroup.Create(const aid: int64);
begin
  inherited Create(aid);
  fkafedra:=TDBKafedra.Create(0);
end;

procedure TDBGroup.Assign(Source: TObject);

  procedure CopyFromDBObject(DBObject: TDBGroup);
  begin
    fid:=DBObject.id;
    fname:=DBObject.name;
    fcourse:=DBObject.course;
    fstuds:=DBObject.studs;
    fkafedra.Assign(DBObject);
  end;

begin
  if Assigned(Source) then
    if Source is TDBGroup then CopyFromDBObject(TDBGroup(Source))
      else raise Exception.Create('TDBGroup.Assign: Unknown object class');
end;

procedure TDBGroup.Assign(Source: Fields);
begin
  fid:=Source.Item['grid'].Value;
  fname:=Source.Item['grname'].Value;
  fcourse:=Source.Item['course'].Value;
  fstuds:=Source.Item['studs'].Value;
  fkafedra.Assign(Source);
end;

destructor TDBGroup.Destroy;
begin
  if Assigned(fkafedra) then
  begin
    fkafedra.Free;
    fkafedra:=nil;
  end;
  inherited;
end;

{ TDBSubject }

procedure TDBSubject.Assign(Source: TObject);

  procedure CopyFromDBObject(DBObject: TDBSubject);
  begin
    fid:=DBObject.id;
    fname:=DBObject.name;
    fsmall:=DBObject.small;
  end;

  procedure CopyFromFields(Fields: TFields);
  begin
    fid:=Fields.FieldByName('sbid').AsInteger;
    fname:=Fields.FieldByName('sbName').AsString;
    fsmall:=Fields.FieldByName('sbSmall').AsString;
  end;

begin
  if Assigned(Source) then
    if Source is TDBSubject then CopyFromDBObject(TDBSubject(Source)) else
      if Source is TFields then CopyFromFields(TFields(Source))
      else raise Exception.Create('TDBSubject.Assign: Unknown object class');
end;

procedure TDBSubject.Assign(Source: Fields);
begin
  fid:=Source.Item['sbid'].Value;
  fname:=Source.Item['sbname'].Value;
  fsmall:=Source.Item['sbsmall'].Value;
end;

function TDBSubject.Assign(Source: string): boolean;
var
  nid: int64;
begin
  Result:=false;
  if Source<>'' then
  begin
    nid:=StrToInt64(GetName(Source));
    if nid>0 then
    begin
      fid:=nid;
      fname:=GetValue(Source);
      Result:=true;
    end;
  end;
end;

{ TDBLoadList }

constructor TDBLoadList.Create(Workplan: TDBWorkplan);
begin
  inherited Create;
  fworkplan:=Workplan;
end;

function TDBLoadList.GetLoadIndex(index: integer): TDBLoad;
begin
  Result:=GetObjectIndex(index) as TDBLoad;
end;

// проверка на возможность вставки нагрузки
function TDBLoadList.CheckObject(DBObject: TDBObject): boolean;
  // существование нагрузки (тип, п/сем)
  function ExistsLoad: boolean;
  var
    i: integer;
    load: TDBLoad;
  begin
    Result:=false;
    for i:=0 to Count-1 do
    begin
      load:=Items[i];
      if (load.ltype=TDBLoad(DBObject).ltype)
          and (load.psem=TDBLoad(DBObject).psem) then
      begin
        Result:=true;
        break;                  
      end;  // if
    end;  // for
  end;
begin
  // успех: это нагрузка & часы>0 & нет нагрузки
  if DBObject is TDBLoad then
    Result:=(TDBLoad(DBObject).hours>0) and (not ExistsLoad)
  else Result:=false;
end;

function TDBLoadList.ExternalChange(DBObject: TDBObject; FieldName: string;
    const Value: Variant): boolean;
begin
  Result:=inherited ExternalChange(DBObject, FieldName, Value);
end;

{ TDBLoad }

procedure TDBLoad.Assign(Source: TObject);

  procedure CopyFromDBObject(DBObject: TDBLoad);
  begin
    fid:=DBObject.id;
    fpsem:=DBObject.psem;
    ftype:=DBObject.ltype;
    fhours:=DBObject.hours;
    fstrid:=DBObject.strid;
    fteacher.Assign(DBObject);
  end;

  procedure CopyFromFields(Fields: TFields);
  begin
    fid:=Fields.FieldByName('lid').AsInteger;
    fpsem:=Fields.FieldByName('psem').AsInteger;
    ftype:=TLsnsType(Fields.FieldByName('type').AsInteger);
    fhours:=Fields.FieldByName('hours').AsInteger;
    fstrid:=Fields.FieldByName('strid').AsInteger;
    fteacher.Assign(Fields);
  end;

begin
  if Assigned(Source) then
    if Source is TDBLoad then CopyFromDBObject(TDBLoad(Source)) else
      if Source is TFields then CopyFromFields(TFields(Source))
        else raise Exception.Create('TDBLoad.Assign: Unknown object class');
end;

procedure TDBLoad.Assign(Source: Fields);
begin
  fid:=Source.Item['lid'].Value;
  fpsem:=Source.Item['psem'].Value;
  ftype:=Source.Item['type'].Value;
  fhours:=Source.Item['hours'].Value;
  fstrid:=Source.Item['strid'].Value;
  fteacher.Assign(Source);
end;

procedure TDBLoad.SetHours(Value: byte);
begin
  if Value<>fhours then
  begin
    if Assigned(List) then
    begin
      if TDBLoadList(List).ExternalChange(Self, 'hours', Value) then
        fhours:=Value;
    end
    else fhours:=Value;
  end; // if
end;

function TDBLoad.GetWorkplan: TDBWorkplan;
begin
  if Assigned(List) then
    Result:=(List as TDBLoadList).fworkplan
  else Result:=nil;
end;

constructor TDBLoad.Create(const aid: int64);
begin
  inherited Create(aid);
  fteacher:=TDBTeacher.Create(0);
end;

destructor TDBLoad.Destroy;
begin
  if Assigned(fteacher) then
  begin
    fteacher.Free;
    fteacher:=nil;
  end;

  inherited;
end;

procedure TDBLoad.SetTeacher(Value: TDBTeacher);
var
  vtid: Variant;
begin
  if teacher.id<>value.id then
  begin
    if Assigned(List) then
    begin
      if value.id>0 then vtid:=value.id else vtid:=Null;
      if TDBWorkplanList(List).ExternalChange(Self, 'tid', vtid) then
        fteacher.Assign(value);
    end
    else fteacher.Assign(value);
  end;
end;

{ TDBWorkplan }

constructor TDBWorkplan.Create(const aid: int64);
begin
  inherited Create(aid);
  fkafedra:=TDBKafedra.Create(0);
  fsubject:=TDBSubject.Create(0);
  floads:=TDBLoadList.Create(Self);
  floads.OnInsert:=DoLoadInsert;
  floads.OnDelete:=DoLoadDelete;
  floads.OnChange:=DoLoadChange;
end;

destructor TDBWorkplan.Destroy;
begin
  if Assigned(floads) then
  begin
    floads.Free;
    floads:=nil;
  end;
  if Assigned(fkafedra) then
  begin
    fkafedra.Free;
    fkafedra:=nil;
  end;
  if Assigned(fsubject) then
  begin
    fsubject.Free;
    fsubject:=nil;
  end;

  inherited Destroy;
end;

procedure TDBWorkplan.Assign(Source: TObject);

  procedure CopyFromDBObject(DBObject: TDBWorkplan);
  begin
    fid:=DBObject.id;
    fsem:=DBObject.sem;
    fsubject.Assign(DBObject.subject);
    fkafedra.Assign(DBObject.kafedra);
    fexamen:=DBObject.examen;
    floads.Assign(DBObject.loads);
  end;

  procedure CopyFromFields(Fields: TFields);
  begin
    fid:=Fields.FieldByName('wpid').AsInteger;
    fsem:=Fields.FieldByName('sem').AsInteger;
    fsubject.Assign(Fields);
    fkafedra.Assign(Fields);
    fexamen:=(Fields.FieldByName('e').AsInteger>0);
    floads.Clear;
    //floads.Assign(DBObject.loads);
  end;

begin
  if Assigned(Source) then
    if Source is TDBWorkplan then CopyFromDBObject(TDBWorkplan(Source)) else
      if Source is TFields then CopyFromFields(TFields(Source))
        else raise Exception.Create('TDBWorkplan.Assign: Unknown object class');
end;

procedure TDBWorkplan.Assign(Source: Fields);
begin
  fid:=Source.Item['wpid'].Value;
  fsem:=Source.Item['sem'].Value;
  fsubject.Assign(Source);
  fkafedra.Assign(Source);
  fexamen:=Source.Item['e'].Value;
  if floads.Count>0 then floads.Clear;
end;

procedure TDBWorkplan.SetExamen(Value: boolean);
begin
  if Value<>fexamen then
  begin
    if Assigned(List) then
    begin
      if TDBWorkplanList(List).ExternalChange(Self, 'e', integer(Value)) then
        fexamen:=Value;
    end
    else fexamen:=Value;
  end; // if
end;

procedure TDBWorkplan.SetKafedra(value: TDBKafedra);
begin
  if fkafedra.id<>value.id then
  begin
    if Assigned(List) then
    begin
      if TDBWorkplanList(List).ExternalChange(Self, 'kid', value.id) then
        fkafedra.Assign(value);
    end
    else fkafedra.Assign(value);
  end;
end;

procedure TDBWorkplan.DoLoadInsert(Sender: TObject; DBObject: TDBObject;
    var Id: int64);
begin
  Id:=0;
  if Assigned(List) then
    if Assigned(TDBWorkplanList(List).OnInsert) then
      TDBWorkplanList(List).OnInsert(Self, DBObject, Id)
end;

procedure TDBWorkplan.DoLoadDelete(Sender: TObject; DBObject: TDBObject;
    var Allow: boolean);
begin
  Allow:=true;
  if Assigned(List) then
    if Assigned(TDBWorkplanList(List).OnDelete) then
      TDBWorkplanList(List).OnDelete(Self, DBObject, Allow);
end;

procedure TDBWorkplan.DoLoadChange(Sender: TObject; DBObject: TDBObject;
    const FieldName: string; const NewValue: Variant; var Allow: boolean);
begin
  Allow:=true;
  if Assigned(List) then
    if Assigned(TDBWorkplanList(List).OnChange) then
      TDBWorkplanList(List).OnChange(Self, DBObject, FieldName, NewValue, Allow)
end;

{
procedure TDBWorkplan.SetSem(value: byte);
begin
  Assert(value in [1,2],
    '1F154EE3-C23C-49A5-A114-85E52D00E67C'#13'TDBWorkplan.SetSem: invalid Value'#13);

  // нельзя изм-ть значение, если объект в списке
  if (fsem<>value) and (not Assigned(List)) then
    fsem:=value;
end;
}

{ TDBWorkplanList }

function TDBWorkplanList.GetWorkplanIndex(index: integer): TDBWorkplan;
begin
  Result:=GetObjectIndex(index) as TDBWorkplan;
end;

function TDBWorkplanList.CheckObject(DBObject: TDBObject): boolean;

  // существование дисциплины
  function ExistsWorkplan: boolean;
  var
    i: integer;
    wp: TDBWorkplan;
  begin
    Result:=false;
    for i:=0 to Count-1 do
    begin
      wp:=Items[i];
      if (wp.subject.id=TDBWorkplan(DBObject).subject.id) and
        (wp.sem=TDBWorkplan(DBObject).sem) then
      begin
        Result:=true;
        break;
      end;
    end; // for
  end;

begin
  if DBObject is TDBWorkplan then
    Result:=(TDBWorkplan(DBObject).subject.id>0) and (TDBWorkplan(DBObject).kafedra.id>0)
      and (TDBWorkplan(DBObject).sem in [1,2]) and (not ExistsWorkplan)
  else Result:=false;
end;

function TDBWorkplanList.ExternalChange(DBObject: TDBObject; FieldName: string;
    const Value: Variant): boolean;
begin
  Result:=inherited ExternalChange(DBObject, FieldName, Value);
end;

{ TDBTeacher }

procedure TDBTeacher.Assign(Source: TObject);

  procedure CopyFromDBObject(DBObject: TDBTeacher);
  begin
    fid:=DBObject.id;
    fname:=DBObject.name;
    fpost:=DBObject.post;
//    fkafedra.Assign(DBObject.kafedra);
  end;

  procedure CopyFromFields(Fields: TFields);
  begin
    fid:=Fields.FieldByName('tid').AsInteger;
    fname:=Fields.FieldByName('initials').AsString;
    fpost:=Fields.FieldByName('pSmall').AsString;
//    fkafedra.Assign(Fields);
  end;

begin
  if Assigned(Source) then
    if Source is TDBTeacher then CopyFromDBObject(TDBTeacher(Source)) else
      if Source is TFields then CopyFromFields(TFields(Source))
        else raise Exception.Create('TDBTeacher.Assign: Unknown object class');
end;

procedure TDBTeacher.Assign(Source: Fields);
begin
  fid:=Source.Item['tid'].Value;
  fname:=Source.Item['initials'].Value;
  fpost:=Source.Item['pSmall'].Value;
//  fkafedra.Assign(Source);
end;

function TDBTeacher.Assign(const Source: string): boolean;
var
  nid: int64;
begin
  Result:=false;
  if Source<>'' then
  begin
    nid:=GetID(Source);
    fid:=nid;
    if nid>0 then fname:=GetValue(Source);
    fpost:='';
    Result:=true;
  end;
end;

constructor TDBTeacher.Create(const aid: int64);
begin
  inherited Create(aid);
//  fkafedra:=TDBKafedra.Create(0);
end;

destructor TDBTeacher.Destroy;
begin
//  if Assigned(fkafedra) then
//  begin
//    fkafedra.Free;
//    fkafedra:=nil;
//  end;
  inherited;
end;

{ CoKafedra }

class function CoKafedra.Create(Fields: TFields): TDBKafedra;
begin
  Result:=TDBKafedra.Create(0);
  Result.Assign(Fields);
end;

class function CoKafedra.Create(const skaf: string): TDBKafedra;
begin
  Result:=nil;
  if skaf<>'' then
  begin
    Result:=TDBKafedra.Create(0);
    if not Result.Assign(skaf) then
    begin
      Result.Free;
      Result:=nil;
    end;
  end;
end;

{ CoTeacher }

class function CoTeacher.Create(Fields: TFields): TDBTeacher;
begin
  Result:=TDBTeacher.Create(0);
  Result.Assign(Fields);
end;

class function CoTeacher.Create(const sthr: string): TDBTeacher;
begin
  Result:=nil;
  if sthr<>'' then
  begin
    Result:=TDBTeacher.Create(0);
    if not Result.Assign(sthr) then
    begin
      Result.Free;
      Result:=nil;
    end;
  end;
end;

{ CoSubject }

class function CoSubject.Create(Fields: TFields): TDBSubject;
begin
  Result:=TDBSubject.Create(0);
  Result.Assign(Fields);
end;

class function CoSubject.Create(ssbj: string): TDBSubject;
begin
  Result:=nil;
  if ssbj<>'' then
  begin
    Result:=TDBSubject.Create(0);
    if not Result.Assign(ssbj) then
    begin
      Result.Free;
      Result:=nil;
    end;
  end;
end;

{ CoLoad }

class function CoLoad.Create(npsem, ntype, nhours: byte): TDBLoad;
begin
  if (npsem in [1,2]) and (ntype in [1,2,3]) and (nhours>0) then
  begin
    Result:=TDBLoad.Create(0);
    Result.fpsem:=npsem;
    Result.ftype:=TLsnsType(ntype);
    Result.fhours:=nhours;
  end
  else Result:=nil;
end;

class function CoLoad.Create(Fields: TFields): TDBLoad;
begin
  Result:=TDBLoad.Create(0);
  Result.Assign(Fields);
end;

{ CoWorkplan }

class function CoWorkplan.Create(nsem: byte; ssbj, skaf: string;
    bexamen: boolean): TDBWorkplan;
begin
  Result:=nil;
  if (nsem in [1,2]) and (ssbj<>'') and (skaf<>'') then
  begin
    Result:=TDBWorkplan.Create(0);
    if (Result.subject.Assign(ssbj)) and (Result.kafedra.Assign(skaf)) then
    begin
      Result.fsem:=nsem;
      Result.fexamen:=bexamen;
    end
    else
    begin
      Result.Free;
      Result:=nil;
    end;
  end;
end;

class function CoWorkplan.Create(Fields: TFields): TDBWorkplan;
begin
  Result:=TDBWorkplan.Create(0);
  Result.Assign(Fields);
end;

end.
