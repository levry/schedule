{
  Настройки
  v0.2.2 (20.03.06)
}

unit CustomOptions;

interface

uses
  Classes, Registry, Contnrs;

type
  TCustomOptions = class;

  TCategory = class(TPersistent)
  private
    FName: string;                 // название (подключ FKey)
    FParent: TCustomOptions;
  protected
    procedure DoCreate; virtual;
    procedure DoDestroy; virtual;
  public
    constructor Create(const AName: string; const AOwner: TCustomOptions);
    destructor Destroy; override;
    procedure SetDefault; virtual; abstract;

    property Name: string read FName write FName;
    property Parent: TCustomOptions read FParent;
  end;

  // главные настроки
  TRootCategory = class(TCategory)
  private
    FConnStr: string;
    FHelpFile: string;
    FSem: byte;
    FPSem: byte;
  public
    procedure SetDefault; override;
  published
    property ConnStr: string read FConnStr write FConnStr;   // строка соединения
    property HelpFile: string read FHelpFile write FHelpFile;// файл справки
    property Sem: byte read FSem write FSem;                 // сем
    property PSem: byte read FPSem write FPSem;              // п/сем
  end;

  TCustomOptions = class
  private
    FRegKey: string;           // ключ приложения
    FRootKey: string;          // ключ пакета

    FReg: TRegistry;
    FRoot: TRootCategory;      // глав.
    FList: TObjectList;        // список категорий

    procedure ReadObject(const AObj: TPersistent);
    procedure WriteObject(const AObj: TPersistent);


  protected
    procedure AddCategory(ACategory: TCategory);
    function CategoryByName(const AName: string): TCategory;
    procedure SaveCategory(const AKey: string; ACategory: TCategory);
    procedure LoadCategory(const AKey: string; ACategory: TCategory);

  public
    constructor Create(const ARoot, AKey: string); virtual;
    destructor Destroy; override;

    property RegKey: string read FRegKey;
    property Root: TRootCategory read FRoot;
    property Items[const name: string]: TCategory read CategoryByName; default;

    procedure LoadSettings;
    procedure SaveSettings;
  end;

implementation

uses
  Windows, TypInfo, SysUtils;

type

  TWrapper = class(TComponent)
  private
    FObject: TObject;
  published
    property PObject: TObject read FObject write FObject;
  end;

// чтение объекта из реестра
// AObj - объект
// AValueName - имя значения
// AReg - объект реестра
procedure ReadObjFromReg(AObj: TObject; AValueName: string; AReg: TRegistry);
var
  s: TMemoryStream;
  wrapper: TWrapper;
  pbuf: array of char;
  size: integer;
begin
  Assert(Assigned(AObj),
    'BEE42A05-3358-4DD4-8FD7-EBD51DB9E113'#13'ReadObjFromReg: AObj is nil'#13);

  pbuf:=nil;
  size:=0;

  if Assigned(AObj) then
  begin
    wrapper:=TWrapper.Create(nil);
    wrapper.PObject:=AObj;
    try
      s:=TMemoryStream.Create;
      try
        if AReg.ValueExists(AValueName) then
        begin
          size:=AReg.GetDataSize(AValueName);
          if size>0 then
          begin
            GetMem(pbuf,size);
            try
              AReg.ReadBinaryData(AValueName,pbuf[0],size);
              s.Position:=0;
              s.WriteBuffer(pbuf[0],size);
              s.Position:=0;
              s.ReadComponent(wrapper);
            finally
              FreeMem(pbuf);
              pbuf:=nil;
            end; // try/finally (GetMem(pbuf))
          end; // if size>0
        end; // if ValueExists
      finally
        s.Free;
      end; // try/finally (s)
    finally
      wrapper.PObject:=nil;
      wrapper.Free;
    end; // try/finally (wrapper)
  end; // if AObj<>nil
end;

// запись объекта в реестр
// AObj - объект
// AValueName - имя значения
// AReg - объект реестра
procedure WriteObjToReg(AObj: TObject; AValueName: string; AReg: TRegistry);
var
  wrapper: TWrapper;
  s: TMemoryStream;
  pbuf: array of char;
  size: integer;
begin
  Assert(Assigned(AObj),
    '15DF739D-A0AF-479D-BCD2-C75B59E20487'#13'WriteObjToReg: AObj is nil'#13);

  pbuf:=nil;
  size:=0;

  if Assigned(AObj) then
  begin
    wrapper:=TWrapper.Create(nil);
    wrapper.PObject:=AObj;
    try
      s:=TMemoryStream.Create;
      try
        s.WriteComponent(wrapper);
        size:=s.Size;
        GetMem(pbuf,size);
        try
          s.Position:=0;
          s.ReadBuffer(pbuf[0],size);
          AReg.WriteBinaryData(AValueName,pbuf[0],size);
        finally
          FreeMem(pbuf);
          pbuf:=nil;
        end; // try/finally (GetMem(pbuf))
      finally
        s.Free;
      end; // try/finally (s)
    finally
      wrapper.PObject:=nil;
      wrapper.Free;
    end; // try/finally (wrapper)
  end; // if AObj<>nil
end;

//Returns the number of properties of a given object
function GetPropCount(Instance: TPersistent): Integer;
var
  Data: PTypeData;
Begin
  Data:=GetTypeData(Instance.Classinfo);
  Result:=Data^.PropCount;
End;

//Returns the property name of an instance at a certain index
function GetPropName(Instance: TPersistent; Index: Integer): String;
var
  PropList: PPropList;
  PropInfo: PPropInfo;
  Data: PTypeData;
Begin
  Result:='';
  Data:=GetTypeData(Instance.Classinfo);
  GetMem(PropList,Data^.PropCount*Sizeof(PPropInfo));
  try
    GetPropInfos(Instance.ClassInfo,PropList);
    PropInfo:=PropList^[Index];
    Result:=PropInfo^.Name;
  finally
    FreeMem(PropList,Data^.PropCount*Sizeof(PPropInfo));
  end;
End;

{ TCategory }

constructor TCategory.Create(const AName: string; const AOwner: TCustomOptions);
begin
  Assert(Assigned(AOwner),
    'E87CB756-4CB1-4CDC-922A-01B57B8249E6'#13'TCategory.Create: AOwner is nil'#13);

  FParent:=AOwner;
  FName:=AName;

  DoCreate();
  SetDefault();
//  FParent.Load(Self);
end;

destructor TCategory.Destroy;
begin
  DoDestroy();
  inherited;
end;

procedure TCategory.DoCreate;
begin
end;

procedure TCategory.DoDestroy;
var
  i, count: integer;
  PropName: string;
  PropObj: TObject;
begin
  count:=GetPropCount(self);
  for i:=0 to count-1 do
  begin
    PropName:=GetPropName(self, i);
    if PropName<>'Name' then
    begin
      if PropType(self, PropName)=tkClass then
      begin
        PropObj:=GetObjectProp(self,PropName);
        if Assigned(PropObj) then
        begin
          PropObj.Free;
          PropObj:=nil;
        end;
      end;
    end;
  end;
end;

{ TRootCategory }

procedure TRootCategory.SetDefault;
begin
  FConnStr:='FILE NAME=link.udl';
  FHelpFile:='schedule.chm';
  FSem:=1;
  FPSem:=1;
end;

{ TCustomOptions }

constructor TCustomOptions.Create(const ARoot, AKey: string);
begin
  FRootKey:=ARoot;
  FRegKey:=AKey;

  FReg:=TRegistry.Create;
  FReg.RootKey:=HKEY_CURRENT_USER;
//  FReg.OpenKey(FRootKey,true);

  FRoot:=TRootCategory.Create('',Self);
  FList:=TObjectList.Create;
end;

destructor TCustomOptions.Destroy;
begin
  FList.Free;
  FRoot.Free;
  FReg.Free;

  inherited Destroy;
end;

// добавление категории
procedure TCustomOptions.AddCategory(ACategory: TCategory);
begin
  Assert(not Assigned(CategoryByName(ACategory.Name)),
    'BA6353CD-7A0C-4E14-8DCC-E8983F485785'#13'AddCategory: ACategory already exists'#13);

  if FList.IndexOf(ACategory)=-1 then
    FList.Add(ACategory);
end;

// возвращает категорию по имени
function TCustomOptions.CategoryByName(const AName: string): TCategory;
var
  i: integer;
begin
  Result:=nil;
  for i:=0 to FList.Count-1 do
    if TCategory(FList[i]).Name=AName then
    begin
      Result:=(FList[i] as TCategory);
      break;
    end;
end;

// сохранение категории
procedure TCustomOptions.SaveCategory(const AKey: string; ACategory: TCategory);
//var
//  OldKey: string;
begin
//  OldKey:='\'+FReg.CurrentPath;
  try
    if FReg.OpenKey(AKey,true) then
//    if FReg.OpenKey(FRegKey+'\'+ACategory.Name,true) then
      WriteObject(ACategory);
  finally
    FReg.CloseKey;
//    FReg.OpenKey(OldKey,false);
  end;
end;

procedure TCustomOptions.ReadObject(const AObj: TPersistent);
var
  i, count: integer;
  PropName: string;
  obj: TObject;
begin
  count:=GetPropCount(AObj);
  for i:=0 to count-1 do
  begin
    PropName:=GetPropName(AObj,i);
    if (PropName='Name') or (not FReg.ValueExists(PropName)) then continue;
    case PropType(AObj, PropName) of
      tkString,
      tkLString,
      tkWString: SetStrProp(AObj, PropName, FReg.ReadString(PropName));

      tkChar,
      tkEnumeration,
      tkInteger: SetOrdProp(AObj, PropName, FReg.ReadInteger(PropName));

      tkSet:
        SetSetProp(AObj, PropName, FReg.ReadString(PropName));

      tkClass:
        begin
          obj:=nil;
          obj:=GetObjectProp(AObj,PropName);
          if Assigned(obj) then
          begin
            if obj is TStrings then TStrings(obj).CommaText:=FReg.ReadString(PropName)
              else ReadObjFromReg(obj,PropName,FReg);
          end; // if obj<>nil
        end;
    end; // case
  end;
end;

procedure TCustomOptions.WriteObject(const AObj: TPersistent);
var
  i, count: integer;
  PropName: string;
  obj: TObject;
begin
  count:=GetPropCount(AObj);
  for i:=0 to count-1 do
  begin
    PropName:=GetPropName(AObj,i);
    if (PropName='Name')then continue;
    case PropType(AObj, PropName) of
      tkString,
      tkLString,
      tkWString: FReg.WriteString(PropName, GetStrProp(AObj, PropName));

      tkChar,
      tkEnumeration,
      tkInteger: FReg.WriteInteger(PropName, GetOrdProp(AObj, PropName));

      tkSet: FReg.WriteString(PropName, GetSetProp(AObj, PropName));

      tkClass:
        begin
          obj:=nil;
          obj:=GetObjectProp(AObj,PropName);
          if Assigned(obj) then
            if obj is TStrings then FReg.WriteString(PropName, TStrings(obj).CommaText)
              else WriteObjToReg(obj,PropName,FReg);
        end;
    end; // case
  end;
end;

// загрузка категории
procedure TCustomOptions.LoadCategory(const AKey: string; ACategory: TCategory);
//var
//  OldKey: string;
begin
//  OldKey:='\'+FReg.CurrentPath;
  try
    if FReg.OpenKey(AKey,true) then
//    if FReg.OpenKey(FRegKey+'\'+ACategory.Name,true) then
      ReadObject(ACategory);
  finally
    FReg.CloseKey;
//    FReg.OpenKey(OldKey,false);
  end;
end;

procedure TCustomOptions.LoadSettings;
var
  i: integer;
  skey: string;
  category: TCategory;
begin
  LoadCategory(FRootKey, FRoot);
  for i:=0 to FList.Count-1 do
  begin
    category:=FList[i] as TCategory;
    if AnsiCompareText(category.Name,FRegKey)=0 then skey:=FRootKey+'\'+FRegKey
      else skey:=FRootKey+'\'+FRegKey+'\'+category.Name;
    LoadCategory(skey, category);
  end;  // for(i)
end;

procedure TCustomOptions.SaveSettings;
var
  i: integer;
  skey: string;
  category: TCategory;
begin
  SaveCategory(FRootKey, FRoot);
  for i:=0 to FList.Count-1 do
  begin
    category:=FList[i] as TCategory;
    if AnsiCompareText(category.Name,FRegKey)=0 then skey:=FRootKey+'\'+FRegKey
      else skey:=FRootKey+'\'+FRegKey+'\'+category.Name;
    SaveCategory(skey, category);
  end;  // for(i)
end;

end.
