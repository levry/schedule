unit LinkList;

interface

uses
  Classes;

type
  PLinkListEntry = ^TLinkListEntry;
  TLinkListEntry = record
    Key: Variant;          // ключ
    Value: Variant;        // значение
  end;

  // список для поля синхрон. просмостра
  TLinkList = class(TObject)
  private
    FList: TList;
    function GetCount: integer;
    function GetKey(Index: integer): Variant;
    function GetValue(Index: integer): Variant;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(const AKey, AValue: Variant);
    procedure Clear;
    function ValueOfKey(const AKey: Variant): Variant;    // возвращает значение по ключу
    function KeyOfValue(const AValue: Variant): Variant;  // возвращает ключ по значению
    property Count: integer read GetCount;
    property Keys[Index: integer]: Variant read GetKey;
    property Values[Index: integer]: Variant read GetValue;
  end;


implementation

uses
  Variants;

{TLinkList}

constructor TLinkList.Create;
begin
  FList := TList.Create;
end;

destructor TLinkList.Destroy;
begin
  if FList <> nil then Clear;
  FList.Free;
end;

function TLinkList.GetCount: integer;
begin
  Result:=FList.Count;
end;

procedure TLinkList.Add(const AKey, AValue: Variant);
var
  ListEntry: PLinkListEntry;
begin
  New(ListEntry);
  ListEntry.Key := AKey;
  ListEntry.Value := AValue;
  FList.Add(ListEntry);
end;

procedure TLinkList.Clear;
var
  I: Integer;
begin
  for I := 0 to FList.Count - 1 do
    Dispose(PLinkListEntry(FList.Items[I]));
  FList.Clear;
end;

// возвращает ключ (16.09.2004)
function TLinkList.GetKey(Index: integer): Variant;
begin
  Result:=Null;
  if (Index>0) and (Index<FList.Count) then
    Result:= PLinkListEntry(FList.Items[Index]).Key;
end;

// возвращает значение (16.09.2004)
function TLinkList.GetValue(Index: integer): Variant;
begin
  Result:=Null;
  if (Index>=0) and (Index<FList.Count) then
    Result:= PLinkListEntry(FList.Items[Index]).Value;
end;

// возвращает значение по ключу (16.09.2004)
function TLinkList.ValueOfKey(const AKey: Variant): Variant;
var
  I: Integer;
begin
  Result := Null;
  if not VarIsNull(AKey) then
    for I := 0 to FList.Count - 1 do
      if PLinkListEntry(FList.Items[I]).Key = AKey then
      begin
        Result := PLinkListEntry(FList.Items[I]).Value;
        Break;
      end;
end;

// возвращает ключ по значению (16.09.2004)
function TLinkList.KeyOfValue(const AValue: Variant): Variant;
var
  I: Integer;
begin
  Result := Null;
  if not VarIsNull(AValue) then
    for I := 0 to FList.Count - 1 do
      if PLinkListEntry(FList.Items[I]).Value = AValue then
      begin
        Result := PLinkListEntry(FList.Items[I]).Key;
        Break;
      end;
end;

end.
 