{
  Набор данных "Рабочий план",
  источник данных для cxGrid
  v0.0.3

  06.02.06: Исправлено добавление нагрузки для второго п/с
  11.02.06: fgrid->fgroup
}

unit WorkplanSource;

interface

uses
  ModelData, cxCustomData, cxGridTableView, Classes;

type
  TWorkplanSet = class(TDBWorkplanList)
  private
    fgroup: string;      // grid=grName
//    fgrid: int64;
    fsem: byte;
    fpsem: byte;
    function Get_grid: int64;
    function Get_grName: string;
    procedure Set_group(Value: string);
    procedure Set_sem(Value: byte);
    procedure Set_psem(Value: byte);
  private
    FOnGetWorkplan: TNotifyEvent;
  public
    constructor Create;
    procedure Change(sGroup: string; nSem, nPSem: byte);
    procedure Update;

    property grid: int64 read Get_grid;
    property grName: string read Get_grName;
    property group: string read fgroup write Set_group;
    property sem: byte read fsem write Set_sem;
    property psem: byte read fpsem write Set_psem;

    property OnGetWorkplan: TNotifyEvent read FOnGetWorkplan write FOnGetWorkplan;
  end;

  TWorkplanDataSource = class(TcxCustomDataSource)
  private
    FWorkplanSet: TWorkplanSet;
  protected
    procedure DeleteRecord(ARecordHandle: TcxDataRecordHandle); override;
    //function GetDisplayText(ARecordHandle: TcxDataRecordHandle;
    //    AItemHandle: TcxDataItemHandle): string; override;
    function GetRecordCount: Integer; override;
    function GetValue(ARecordHandle: TcxDataRecordHandle;
        AItemHandle: TcxDataItemHandle): Variant; override;
    function InsertRecord(ARecordHandle: TcxDataRecordHandle): TcxDataRecordHandle; override;
    function AppendRecord: TcxDataRecordHandle; override;
    procedure SetValue(ARecordHandle: TcxDataRecordHandle;
        AItemHandle: TcxDataItemHandle; const AValue: Variant); override;
  public
    constructor Create(AWorkplanSet: TWorkplanSet);
    destructor Destroy; override;
  end;

  TLoadDataSource = class(TcxCustomDataSource)
  private
    FWorkplanSet: TWorkplanSet;
  protected
    function AppendRecord: TcxDataRecordHandle; override;
    procedure DeleteRecord(ARecordHandle: TcxDataRecordHandle); override;
    function GetDisplayText(ARecordHandle: TcxDataRecordHandle;
        AItemHandle: TcxDataItemHandle): string; override;
    function GetMasterRecordIndex: integer;
    function GetColumnId(AItemIndex: integer): integer;
    function GetRecordCount: integer; override;
    function GetValue(ARecordHandle: TcxDataRecordHandle;
        AItemHandle: TcxDataItemHandle): Variant; override;
    function InsertRecord(ARecordHandle: TcxDataRecordHandle): TcxDataRecordHandle; override;
    procedure SetValue(ARecordHandle: TcxDataRecordHandle;
        AItemHandle: TcxDataItemHandle; const AValue: Variant); override;
  public
    constructor Create(AWorkplanSet: TWorkplanSet);
    destructor Destroy; override;
  end;

const
  windex_subject = 0;
  windex_kafedra = 1;
  windex_examen  = 2;

  lindex_type    = 0;
  lindex_teacher = 1;
  lindex_stream  = 2;
  lindex_hours   = 3;


const
  LTypeNames: array[TLsnsType] of string = ('лекция','практика','лабораторная');

procedure PrepareWorkplanColumns(AView: TcxGridTableView);
procedure PrepareLoadColumns(AView: TcxGridTableView);

implementation

uses
  SysUtils, Variants, cxGridCustomTableView, cxDataStorage, DBData, SUtils;

type
  TColumnInfo = packed record
//    Caption: string;
    Index: integer;
    ValueType: TcxValueTypeClass;
//    Editable: boolean;
//    EditClass: TcxCustomEditPropertiesClass;
  end;


// создание колонок для р.п.
procedure PrepareWorkplanColumns(AView: TcxGridTableView);
const
  ColumnInfos: array[0..2] of TColumnInfo =
  (
    // subject
    (  Index: windex_subject;  ValueType: TcxStringValueType; ),
    // kafedra
    (  Index: windex_kafedra;  ValueType: TcxStringValueType; ),
    // examen
    (  Index: windex_examen;   ValueType: TcxIntegerValueType; )
  );
var
  i: integer;
begin
  with AView do
  begin
    //ClearItems;
    for i:=0 to ItemCount-1 do
    with Columns[i] do
      begin
        DataBinding.ValueTypeClass:=ColumnInfos[i].ValueType;
        DataBinding.Data:=Pointer(ColumnInfos[i].Index);
      end;
  end;
end;

// создание колонок для нагрузок
procedure PrepareLoadColumns(AView: TcxGridTableView);
const
  ColumnInfos: array[0..3] of TColumnInfo =
  (
    // тип занятия
    (  Index:lindex_type;  ValueType:TcxStringValueType;  ),
    // преподаватель
    (  Index:lindex_teacher;  ValueType:TcxStringValueType;  ),
    // поток
    (  Index:lindex_stream;  ValueType:TcxIntegerValueType;  ),
    // часы
    (  Index:lindex_hours; ValueType:TcxIntegerValueType; )
  );
var
  i: integer;
begin
  with AView do
  begin
    for i:=0 to ItemCount-1 do
      with Columns[i] do
      begin
//       Caption := ColumnInfos[i].Caption;
       DataBinding.ValueTypeClass := ColumnInfos[i].ValueType;
       DataBinding.Data := Pointer(ColumnInfos[i].Index);
//       Options.Editing:=ColumnInfos[i].Editable;
//       if Assigned(ColumnInfos[i].EditClass) then
//         PropertiesClass:=ColumnInfos[i].EditClass;
      end; // with CreateColumn
  end;
end;

{ TWorkplanSet }

constructor TWorkplanSet.Create;
begin
  inherited Create;
  fgroup:='';
  fsem:=1;
  fpsem:=1;
end;

function TWorkplanSet.Get_grid: int64;
begin
  Result:=StrToInt64Def(SUtils.GetName(fgroup),0);
end;

function TWorkplanSet.Get_grName: string;
begin
  Result:=SUtils.GetValue(fgroup);
end;

procedure TWorkplanSet.Set_group(Value: string);
begin
  Assert(Value<>'',
    '809A6A1C-5522-4A60-8B0C-127B6A82D8A9'#13'TWorkplanSet.Set_group: invalid Value'#13);

  if fgroup<>Value then
  begin
    fgroup:=Value;
    Update;
  end;
end;

procedure TWorkplanSet.Set_sem(Value: byte);
begin
  Assert(Value in [1,2],
    '917A5C57-3B87-4D54-98E4-C05F6D77CC89'#13'TWorkplanSet.SetSem: invalid Value'#13);

  if fsem<>Value then
  begin
    fsem:=Value;
    Update;
  end;
end;

procedure TWorkplanSet.Set_psem(Value: byte);
begin
  Assert(Value in [1,2],
    '12CC7A86-01BC-4828-821D-1AF3E7B039C8'#13'TWorkplanSet.SetPSem: invalid Value'#13);
    
  if fpsem<>Value then
  begin
    fpsem:=Value;
    Update;
  end;
end;

procedure TWorkplanSet.Update;
begin
  if (fsem in [1,2]) and (fpsem in [1,2]) then
  begin
    Clear;
    if Assigned(FOnGetWorkplan) then FOnGetWorkplan(Self);
  end;
end;

// изм-ние сем. и п/сем. одновременно
procedure TWorkplanSet.Change(sGroup: string; nSem, nPSem: byte);
begin
  Assert(sGroup<>'',
    'EFCB1106-93EE-424A-8951-485E7F6D1AE3'#13'TWorkplanSet.Change: invalid sGroup'#13);
  Assert((nSem in [1,2]) and (nPSem in [1,2]),
    '981EB495-82EB-4E3F-B9CA-BA0207BB0681'#13'TWorkplanSet.Change: invalid nSem or nPSem'#13);

  if (fgroup<>sGroup) or (fsem<>nSem) or (fpsem<>nPSem) then
  begin
    fgroup:=sGroup;
    fsem:=nSem;
    fpsem:=nPSem;
    Update;
  end;
end;

{ TWorkplanDataSource }

constructor TWorkplanDataSource.Create(AWorkplanSet: TWorkplanSet);
begin
  inherited Create;
  FWorkplanSet:=AWorkplanSet;
end;

function TWorkplanDataSource.AppendRecord: TcxDataRecordHandle;
var
  i: integer;
  workplan: TDBWorkplan;
  skaf,ssbj: string;
  bexamen: boolean;
  value: Variant;

begin
  i:=DataController.NewItemRecordIndex;

  // извлечение инфы из строки
  skaf:=VarToStrDef(DataController.Values[i,windex_kafedra], '');
  ssbj:=VarToStrDef(DataController.Values[i,windex_subject], '');
  value:=DataController.Values[i,windex_examen];
  if VarIsNull(value) then bexamen:=false else bexamen:=boolean(value);

  // если указаны "кафедра" и "дисциплина"
  workplan:=CoWorkplan.Create(FWorkplanSet.sem, ssbj, skaf, bexamen);
  if Assigned(workplan) then
  begin
    FWorkplanSet.Insert(workplan);
    if workplan.Status<>osVirtual then
    begin
      Result:=TcxDataRecordHandle(FWorkplanSet.IndexOf(workplan));
      DataChanged;
    end
    else workplan.Free;
  end;

  //raise Exception.Create('Don`t append record. Use method TDBWorkplanList.Insert.');
end;

procedure TWorkplanDataSource.DeleteRecord(ARecordHandle: TcxDataRecordHandle);
begin
  if FWorkplanSet.Delete(integer(ARecordHandle)) then
    DataChanged;
end;

function TWorkplanDataSource.GetRecordCount: Integer;
begin
  Result:=FWorkplanSet.Count;
end;

function TWorkplanDataSource.GetValue(ARecordHandle: TcxDataRecordHandle;
  AItemHandle: TcxDataItemHandle): Variant;
var
  column: integer;
  workplan: TDBWorkplan;
begin
  workplan:=FWorkplanSet.Items[integer(ARecordHandle)] as TDBWorkplan;
  if Assigned(workplan) then
  begin
    column:=GetDefaultItemID(integer(AItemHandle));
    case column of
      windex_subject: Result:=workplan.subject.name;
      windex_kafedra: Result:=workplan.kafedra.name;
      windex_examen : Result:=workplan.examen;
      else raise Exception.CreateFmt('Unknown a column number: %d', [column]);
    end;
  end;
end;

function TWorkplanDataSource.InsertRecord(
  ARecordHandle: TcxDataRecordHandle): TcxDataRecordHandle;
begin
  raise Exception.Create('Don`t insert record. Use method TDBWorkplanList.Insert.');
end;

procedure TWorkplanDataSource.SetValue(ARecordHandle: TcxDataRecordHandle;
  AItemHandle: TcxDataItemHandle; const AValue: Variant);
var
  column: integer;
  workplan: TDBWorkplan;
  kafedra: TDBKafedra;
  Value: Variant;
begin
  if not DataController.NewItemRowFocused then
  begin
    workplan:=FWorkplanSet.Items[integer(ARecordHandle)];
    if Assigned(workplan) then
    begin
      column:=GetDefaultItemID(integer(AItemHandle));
      if VarIsNull(AValue) then VarClear(Value)
        else Value:=AValue;
      case column of

        windex_subject:
          raise Exception.Create('Don`t change subject. Use property TDBWorkplan.subject.');

        windex_kafedra:  // изм-ние кафедры
          begin
            kafedra:=CoKafedra.Create(string(Value));
            if Assigned(kafedra) then
            begin
              workplan.kafedra:=kafedra;
              kafedra.Free;
            end;
          end;
          //raise Exception.Create('Don`t change kafedra. Use property TDBWorkplan.kafedra.');

        windex_examen : workplan.examen:=boolean(Value);

      end; // case
    end; // if
  end; // if focus on new row
end;

destructor TWorkplanDataSource.Destroy;
begin
  FWorkplanSet:=nil;
  inherited Destroy;
end;

{ TLoadDataSource }

constructor TLoadDataSource.Create(AWorkplanSet: TWorkplanSet);
begin
  inherited Create;
  FWorkplanSet:=AWorkplanSet;
end;

function TLoadDataSource.AppendRecord: TcxDataRecordHandle;
var
  i: integer;
  workplan: TDBWorkplan;
  load: TDBLoad;
  ntype, nhours: byte;
  value: Variant;

begin
  workplan:=FWorkplanSet.Items[GetMasterRecordIndex];

  if Assigned(workplan) then
  begin
    i:=DataController.NewItemRecordIndex;

    // извлечение инфы из строки
    value:=DataController.Values[i,lindex_type];
    if VarIsNull(value) then ntype:=0 else ntype:=integer(value);
    value:=DataController.Values[i,lindex_hours];
    if VarIsNull(value) then nhours:=0 else nhours:=integer(value);

    load:=CoLoad.Create(FWorkplanSet.psem, ntype, nhours);
    if Assigned(load) then
    begin
      workplan.loads.Insert(load);
      if load.Status<>osVirtual then
      begin
        Result:=TcxDataRecordHandle(workplan.loads.IndexOf(load));
        DataChanged;
      end
      else load.Free;
    end;
  end; // if workplan<>nil

//  raise Exception.Create('Don`t append record. Use method TDBLoadList.Insert.');
end;

procedure TLoadDataSource.DeleteRecord(ARecordHandle: TcxDataRecordHandle);
var
  workplan: TDBWorkplan;
begin
  workplan:=FWorkplanSet.Items[GetMasterRecordIndex];
  if Assigned(workplan) then
  begin
    workplan.loads.Delete(integer(ARecordHandle));
    DataChanged;
  end;
end;

destructor TLoadDataSource.Destroy;
begin
  FWorkplanSet:=nil;
  inherited Destroy;
end;

function TLoadDataSource.GetColumnId(AItemIndex: integer): integer;
begin
  Result := TcxCustomGridTableItem(DataController.GetItem(AItemIndex)).ID;
end;

function TLoadDataSource.GetDisplayText(ARecordHandle: TcxDataRecordHandle;
  AItemHandle: TcxDataItemHandle): string;
var
  column: integer;
  workplan: TDBWorkplan;
  load: TDBLoad;
begin
  column:=GetColumnId(integer(AItemHandle));
  if column=lindex_type then
  begin
    workplan:=FWorkplanSet.Items[GetMasterRecordIndex];
    if Assigned(workplan) then
    begin
      load:=workplan.loads.Items[integer(ARecordHandle)];
      Result:=LTypeNames[load.ltype];
    end // if
  end
  else Result:=inherited GetDisplayText(ARecordHandle,AItemHandle);
end;

function TLoadDataSource.GetMasterRecordIndex: integer;
begin
  Result:=DataController.GetMasterRecordIndex;
end;

function TLoadDataSource.GetRecordCount: integer;
var
  mindex: integer;
begin
  mindex:=GetMasterRecordIndex;
  if mindex>=0 then
    Result:=FWorkplanSet.Items[mindex].loads.Count
  else Result:=0;
end;

function TLoadDataSource.GetValue(ARecordHandle: TcxDataRecordHandle;
  AItemHandle: TcxDataItemHandle): Variant;
var
  workplan: TDBWorkplan;
  load: TDBLoad;
  column: integer;
begin
  workplan:=FWorkplanSet.Items[GetMasterRecordIndex];
  if Assigned(workplan) then
  begin
    load:=workplan.loads[integer(ARecordHandle)];
    if Assigned(load) then
    begin
      column:=GetColumnId(integer(AItemHandle));
      case column of
        lindex_type : Result:=load.ltype;
        lindex_teacher: Result:=load.teacher.name;
        lindex_stream: Result:=load.strid;
        lindex_hours: Result:=load.hours;
        else raise Exception.CreateFmt('Unknown a column number: %d', [column]);
      end; // case
    end;
  end;
end;

function TLoadDataSource.InsertRecord(
  ARecordHandle: TcxDataRecordHandle): TcxDataRecordHandle;
begin
  raise Exception.Create('Don`t insert record. Use method TDBLoadList.Insert.');
end;

procedure TLoadDataSource.SetValue(ARecordHandle: TcxDataRecordHandle;
  AItemHandle: TcxDataItemHandle; const AValue: Variant);
var
  workplan: TDBWorkplan;
  load: TDBLoad;
  teacher: TDBTeacher;
  column: integer;
  value: Variant;
begin
  if not DataController.NewItemRowFocused then
  begin
    workplan:=FWorkplanSet.Items[GetMasterRecordIndex];
    if Assigned(workplan) then
    begin
      load:=workplan.loads[integer(ARecordHandle)];
      if Assigned(load) then
      begin
        column:=GetColumnId(integer(AItemHandle));
        if VarIsNull(AValue) then VarClear(value)
          else value:=AValue;
        case column of

          lindex_type :
            raise Exception.Create('Don`t change ltype.');

          lindex_teacher:  // изм-ние преп-ля
            begin
              teacher:=CoTeacher.Create(string(value));
              if Assigned(teacher) then
              begin
                load.teacher:=teacher;
                teacher.Free;
                teacher:=nil;
              end;
            end;

          lindex_stream:
            raise Exception.Create('Don`t change strid.');

          lindex_hours:
            load.hours:=byte(value);

        end; // case
      end; // if load<>nil
    end; // if workplan<>nil
  end;  // if focus on new row
end;

end.
