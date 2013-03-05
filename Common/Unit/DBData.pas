unit DBData;

interface

uses
  Classes, DB;

type

  TDBObject = class;
  TCustomDBList = class;

  TDBClass = class of TDBObject;

  TDBNotifyEvent = procedure(Sender: TDBObject) of object;
  TDBAllowEvent = procedure(Sender: TObject; DBObject: TDBObject; var Allow: boolean) of object;
  TDBChangeEvent = procedure(Sender: TObject; DBObject: TDBObject;
      const FieldName: string; const NewValue: Variant; var Allow: boolean) of object;
  TDBInsertEvent = procedure(Sender: TObject; DBObject: TDBObject;
      var Id: int64) of object;


  TDBObjectStatus = (osVirtual=1, osClient=2, osStored=3);

  TDBObject = class
  private
    FList: TCustomDBList;

    function GetObjectStatus: TDBObjectStatus;
  protected
    fid: int64;

    procedure Assign(Source: TObject); virtual; abstract;

    property List: TCustomDBList read FList;
  public
    constructor Create(const aid: int64); virtual;


    property id: int64 read fid;
    property Status: TDBObjectStatus read GetObjectStatus;
  end;

  TCustomDBList = class
  private
    FOnInsert: TDBInsertEvent;
    FOnDelete: TDBAllowEvent;
    FOnChange: TDBChangeEvent;

    function DoInsert(DBObject: TDBObject; var Id: int64): boolean;
    function DoDelete(DBObject: TDBObject): boolean;
    function DoChange(DBObject: TDBObject; FieldName: string;
        NewValue: Variant): boolean;
  protected
    function GetCount: integer; virtual; abstract;
    function GetObjectIndex(index: integer): TDBObject; virtual; abstract;
    function CheckObject(DBObject: TDBObject): boolean; virtual; abstract;
    function InternalInsert(DBObject: TDBObject): boolean; virtual; abstract;
    function InternalDelete(DBObject: TDBObject): boolean; virtual; abstract;
    function ExternalChange(DBObject: TDBObject; FieldName: string;
        const Value: Variant): boolean; virtual;

    property Items[index: integer]: TDBObject read GetObjectIndex;

    property OnInsert: TDBInsertEvent read FOnInsert write FOnInsert;
    property OnDelete: TDBAllowEvent read FOnDelete write FOnDelete;
    property OnChange: TDBChangeEvent read FOnChange write FOnChange;
  public
    function Insert(DBObject: TDBObject): int64;
    function Delete(DBObject: TDBObject): boolean; overload;
    function Delete(index: integer): boolean; overload;

    property Count: integer read GetCount;
  end;

  TDBList = class(TCustomDBList)
  private
    FList: TList;
  protected
    function GetCount: integer; override;
    function GetObjectIndex(index: integer): TDBObject; override;
    function InternalInsert(DBObject: TDBObject): boolean; override;
    function InternalDelete(DBObject: TDBObject): boolean; override;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Assign(ADBList: TDBList);
    procedure Clear;
    function IndexOf(DBObject: TDBObject): integer;

    property Items[index: integer]: TDBObject read GetObjectIndex;
    property OnInsert;
    property OnDelete;
    property OnChange;
  end;

  CoDBList = class
    class function InternalInsert(DBObject: TDBObject; DBList: TCustomDBList): boolean;
    class function InternalDelete(DBObject: TDBObject; DBList: TCustomDBList): boolean;
  end;

implementation

{ TDBObject }

constructor TDBObject.Create(const aid: int64);
begin
  inherited Create;
  fid:=aid;
  FList:=nil;
end;

function TDBObject.GetObjectStatus: TDBObjectStatus;
begin
  if fid>0 then Result:=osStored else
    if Assigned(List) then Result:=osClient else
      Result:=osVirtual;
end;

{ TCustomDBList }

// вставка объекта
function TCustomDBList.Insert(DBObject: TDBObject): int64;
var
  Added: boolean;
begin
  if CheckObject(DBObject) then Added:=DoInsert(DBObject, Result)
    else Added:=false;

  if Added then
    if InternalInsert(DBObject) then DBObject.fid:=Result;
end;

// удаление объекта
function TCustomDBList.Delete(DBObject: TDBObject): boolean;
begin
  if DoDelete(DBObject) then
    Result:=InternalDelete(DBObject)
  else Result:=false;
end;

function TCustomDBList.Delete(index: integer): boolean;
var
  DBObject: TDBObject;
begin
  DBObject:=Items[index];
  if Assigned(DBObject) then Result:=Delete(DBObject)
    else Result:=false;
end;

function TCustomDBList.ExternalChange(DBObject: TDBObject; FieldName: string;
    const Value: Variant): boolean;
begin
  Result:=DoChange(DBObject, FieldName, Value);
end;

// вызов событи€ вставки (внешн€€ вставка объекта)
function TCustomDBList.DoInsert(DBObject: TDBObject; var Id: int64): boolean;
begin
  Id:=0;
  if Assigned(FOnInsert) then
  begin
    FOnInsert(Self, DBObject, Id);
    Result:=(Id>0);
  end
//  else Result:=false;
  else Result:=true;
end;

// вызов событи€ удалени€ (внешнее удаление объекта)
function TCustomDBList.DoDelete(DBObject: TDBObject): boolean;
begin
  if Assigned(FOnDelete) then FOnDelete(Self, DBObject, Result)
    else Result:=true;
end;

// вызов событи€ при изменении свойства (внешнее измение пол€)
function TCustomDBList.DoChange(DBObject: TDBObject; FieldName: string;
     NewValue: Variant): boolean;
begin
  if Assigned(FOnChange) then FOnChange(Self, DBObject, FieldName, NewValue, Result)
    else Result:=true;
end;


{ TDBList }

constructor TDBList.Create;
begin
  inherited;
  FList:=TList.Create;
end;

destructor TDBList.Destroy;
begin
  if Assigned(FList) then
  begin
    Clear;
    FList.Free;
  end;
  inherited;
end;

procedure TDBList.Assign(ADBList: TDBList);
begin
  FList.Assign(ADBList.FList);
end;

function TDBList.GetCount: integer;
begin
  Result:=FList.Count;
end;

function TDBList.GetObjectIndex(index: integer): TDBObject;
begin
  Result:=TDBObject(Flist.Items[index]);
end;

procedure TDBList.Clear;
var
  i: integer;
begin
  for i:=0 to FList.Count-1 do
    TDBObject(FList.Items[i]).Free;

  FList.Clear;
end;

function TDBList.InternalInsert(DBObject: TDBObject): boolean;
begin
  Result:=(FList.Add(DBObject)>=0);
  if Result then
    DBObject.FList:=Self;
end;

function TDBList.InternalDelete(DBObject: TDBObject): boolean;
begin
  Result:=(FList.Remove(DBObject)>=0);
end;

function TDBList.IndexOf(DBObject: TDBObject): integer;
begin
  Result:=FList.IndexOf(DBObject);
end;

{ CoDBList }

class function CoDBList.InternalDelete(DBObject: TDBObject;
  DBList: TCustomDBList): boolean;
begin
  Result:=DBList.InternalDelete(DBObject);
end;

class function CoDBList.InternalInsert(DBObject: TDBObject;
  DBList: TCustomDBList): boolean;
begin
  Result:=DBList.InternalInsert(DBObject);
end;

end.
