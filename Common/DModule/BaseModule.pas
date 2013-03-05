{
  Базовый класс для модулей данных проекта
  v0.0.3  (25/09/06)
  (C) Leonid Riskov, 2006
}
unit BaseModule;

interface

uses
  SysUtils, Classes, DB, ADODB,
  STypes;

type

  TBaseDataModule = class(TDataModule)
    Connection: TADOConnection;
    
  private
    { Private declarations }
    FDBVersion: TVersionInfo;     // версия БД

    function Get_DBName: string;
    function prc_Version(var AVersion: TVersionInfo): boolean;
    function GetVersionAsString: string;

  protected
    { Protected declarations }
    function DoConnect: integer; virtual; abstract;
    procedure DoDisconnect; virtual; abstract;

    procedure NullParams(Parameters: TParameters);
    function ExecSP(ACommand: TADOCommand; NameArgs: array of string;
        Args: array of Variant): integer;
    function _ExecSP(ACommand: TADOCommand; NameArgs: array of string;
        Args: array of Variant; OutArg: string; var OutValue: Variant): integer;
    function OpenSP(ACommand: TADOCommand; NameArgs: array of string;
        Args: array of Variant): _Recordset;
    function _OpenSP(ACommand: TADOCommand; NameArgs: array of string;
        Args: array of Variant): _Recordset;

    function RecordsetToList(rs: _Recordset; AList: TStrings;
      const Sort,IdField,NameField,TagField: string): boolean;

  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;

    function Connect(const ConnStr: string): integer;
    procedure Disconnect;

    property DBVersion: TVersionInfo read FDBVersion;
    property VersionAsString: string read GetVersionAsString;
    property DBName: string read Get_DBName;

  end;

implementation

uses
  Windows, Variants, Dialogs, OleDB, ADOInt,
  SConsts, SStrings, SUtils, SDBUtils;

{$R *.dfm}

{ TBaseDataModule }

constructor TBaseDataModule.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  ZeroMemory(@FDBVersion, sizeof(TVersionInfo));
end;

function TBaseDataModule.Connect(const ConnStr: string): integer;

  // проверка версии БД
  function CheckVersion: boolean;
  begin
    Result:=false;

    ZeroMemory(@FDBVersion, sizeof(TVersionInfo));
    if prc_Version(FDBVersion) then
    begin
      if (FDBVersion.major=DB_VER_MAJOR) and
         (FDBVersion.minor=DB_VER_MINOR) and
         (FDBVersion.release<=DB_VER_RELEASE) then Result:=true;
    end;
  end;  // function CheckVersion

begin
  if ConnStr<>'' then
  begin
    Result:=ERROR_CON_SUCCESS;

    Connection.ConnectionString:=ConnStr;
    try
      Connection.Open
    except
      Result:=ERROR_CON_FAILED;
    end;

    // проверка соединения
    if Connection.Connected and (Result=ERROR_CON_SUCCESS) then
      // проверка версии
      if not CheckVersion then Result:=ERROR_CON_VERSION else
        // действия потомков
        Result:=DoConnect;
        
    if Result<>ERROR_CON_SUCCESS then Connection.Close;

  end
  else
  begin
    Result:=ERROR_CON_FAILED;
    raise Exception.Create('Пустая строка соединения');
  end;
end;

procedure TBaseDataModule.Disconnect;
begin
  DoDisconnect;

  Connection.Close;
  ZeroMemory(@FDBVersion, sizeof(TVersionInfo));
end;

function TBaseDataModule.Get_DBName: string;
begin
  if Connection.Connected then
    Result:=Connection.Properties.Item['Current Catalog'].Value
  else Result:='';
end;

function TBaseDataModule.GetVersionAsString: string;
begin
  if Connection.Connected then
    Result:=Format('%d.%d.%d.%d',[FDBVersion.major,FDBVersion.minor,
        FDBVersion.release,FDBVersion.build])
  else Result:=rsNull;
end;

function TBaseDataModule.prc_Version(var AVersion: TVersionInfo): boolean;
var
  rs: _Recordset;
  cm: _Command;
  VarRecs: OleVariant;
begin
  Result:=false;

  if Connection.Connected then
  begin
    try
      cm:=CoCommand.Create;
      try
        cm.Set_ActiveConnection(Connection.ConnectionObject);
        cm.CommandType:=adCmdStoredProc;
        cm.CommandText:='prc_Version';
        rs:=cm.Execute(VarRecs,EmptyParam,integer(adCmdStoredProc));
        if Assigned(rs) then
        begin
          AVersion.major:=rs.Fields.Item['major'].Value;
          AVersion.minor:=rs.Fields.Item['minor'].Value;
          AVersion.release:=rs.Fields.Item['release'].Value;
          AVersion.build:=rs.Fields.Item['build'].Value;
          Result:=true;
          rs:=nil;
        end;
      finally
        cm:=nil;
      end;
    except
      on E: Exception do
      begin
        ShowMessageFmt('Ошибка БД: %s',[E.Message]);
        Result:=false;
        rs:=nil;
      end;
    end;  // except
  end else raise Exception.Create(rsErrNoConnect);
end;

// установка параметров в Null (28.08.2004)
procedure TBaseDataModule.NullParams(Parameters: TParameters);
var
  i: integer;
begin
  for i:=0 to Parameters.Count-1 do
    Parameters.Items[i].Value:=Null;
end;

// выполнение хп
function TBaseDataModule.ExecSP(ACommand: TADOCommand; NameArgs: array of string;
    Args: array of Variant): integer;
var
  i: integer;
begin
  Assert(Length(NameArgs)=Length(Args),
    'AD8D405E-863E-4145-B131-3CC3BDD90051'#13'ExecSP: Length(NameArgs)<>Lentgh(Args)'#13);

  if ACommand.Connection.Connected then
    try
      NullParams(ACommand.Parameters);
      for i:=Low(NameArgs) to High(NameArgs) do
        ACommand.Parameters.ParamByName(NameArgs[i]).Value:=Args[i];
      ACommand.Execute;
      Result:=ACommand.Parameters.ParamByName('@RETURN_VALUE').Value;
    except
      on E: Exception do
      begin
        Result:=ERROR_SP_EXECUTE;
        raise Exception.CreateFmt('Ошибка БД: %s', [E.Message]);
      end
    end
  else raise Exception.Create(rsErrNoConnect);
end;

// выполнение хп (16.04.06)
// возвращает результат хп, возвращ. параметр
function TBaseDataModule._ExecSP(ACommand: TADOCommand; NameArgs: array of string;
    Args: array of Variant; OutArg: string; var OutValue: Variant): integer;
var
  i: integer;
begin
  Assert(Length(NameArgs)=Length(Args),
    '37793A20-B5CD-44DF-8079-F048200BB8BB'#13'_ExecSP: Length(NameArgs)<>Lentgh(Args)'#13);
  Assert(OutArg<>'',
    '2683A764-52E7-463D-8EB1-A52606779718'#13'_ExecSP: OutArg is empty string'#13);

  OutValue:=Null;
  if ACommand.Connection.Connected then
    try
      NullParams(ACommand.Parameters);
      for i:=Low(NameArgs) to High(NameArgs) do
        ACommand.Parameters.ParamByName(NameArgs[i]).Value:=Args[i];
      ACommand.Execute;
      OutValue:=ACommand.Parameters.ParamByName(OutArg).Value;
      Result:=ACommand.Parameters.ParamByName('@RETURN_VALUE').Value;
    except
      on E: Exception do
      begin
        Result:=ERROR_SP_EXECUTE;
        OutValue:=Null;
        raise Exception.CreateFmt('Ошибка БД: %s', [E.Message]);
      end
    end
  else raise Exception.Create(rsErrNoConnect);
end;

// выполение хп, возвращ. набор данных (ред-ние данных)
function TBaseDataModule.OpenSP(ACommand: TADOCommand; NameArgs: array of string;
    Args: array of Variant): _Recordset;
var
  i: integer;
  com: _Command;
begin
  Assert(Length(NameArgs)=Length(Args),
    '1007D655-BE37-4013-B2CA-322794AC7020'#13'OpenSP: Length(NameArgs)<>Length(Args)'#13);

  if ACommand.Connection.Connected then
    try
      NullParams(ACommand.Parameters);
      for i:=Low(NameArgs) to High(NameArgs) do
        ACommand.Parameters.ParamByName(NameArgs[i]).Value:=Args[i];
      com:=CloneCommand(ACommand);

      Result:=CoRecordset.Create;
      Result.CursorLocation:=adUseClient;
      Result.Open(com,EmptyParam,adOpenKeyset,adLockOptimistic,adCmdStoredProc);
    except
      on E: Exception do
      begin
        Result:=nil;
        raise Exception.CreateFmt('Ошибка БД: %s', [E.Message]);
      end;
    end
  else raise Exception.Create(rsErrNoConnect);
end;

// выполение хп, возвращ. набор данных (без ред-ния данных)
function TBaseDataModule._OpenSP(ACommand: TADOCommand; NameArgs: array of string;
    Args: array of Variant): _Recordset;
var
  i: integer;
begin
  Assert(Length(NameArgs)=Length(Args),
    'FC6270CA-B969-4406-A57C-EAE026200978'#13'_OpenSP: Length(NameArgs)<>Length(Args)'#13);

  if ACommand.Connection.Connected then
    try
      NullParams(ACommand.Parameters);
      for i:=Low(NameArgs) to High(NameArgs) do
        ACommand.Parameters.ParamByName(NameArgs[i]).Value:=Args[i];

      Result:=ACommand.Execute;
    except
      on E: Exception do
      begin
        Result:=nil;
        raise Exception.CreateFmt('Ошибка БД: %s', [E.Message]);
      end;
    end
  else raise Exception.Create(rsErrNoConnect);
end;

// заполнение списка данными из recordset`a  (20/09/06)
function TBaseDataModule.RecordsetToList(rs: _Recordset; AList: TStrings;
  const Sort,IdField,NameField,TagField: string): boolean;
var
  s: string;
begin
  Assert(Assigned(AList),
    '992B25D4-6181-43F1-AE5D-59CA1BCA62F3'#13'GetList: AList is nil'#13);
  Assert(IdField<>'',
    '3A758E55-5359-4B90-8605-76A37BD8C86D'#13'GetList: IdField is empty string'#13);
  Assert(NameField<>'',
    '4B5240E6-7556-46D1-A81F-FFA3FD675FF0'#13'GetList: NameField is empty string'#13);

  Result:=false;
  if Assigned(rs) then
    if (rs.State and adStateOpen)=1 then
    begin
      AList.Clear;
      try
        rs.Sort:=Sort;
        while not rs.EOF do
        begin
          if TagField<>'' then
            s:=SUtils.Format(VarToStr(rs.Fields[IdField].Value),
                VarToStr(rs.Fields[NameField].Value),
                VarToStr(rs.Fields[TagField].Value))
          else
            s:=VarToStr(rs.Fields[IdField].Value)+'='+VarToStr(rs.Fields[NameField].Value);
          AList.Add(s);
          rs.MoveNext;
        end;
        rs.Sort:='';
      except
        on E: Exception do
        begin
          ShowMessageFmt('Error: %s',[E.Message]);
          AList.Clear;
        end;
      end;

      Result:=(AList.Count>0);
    end;

end;

end.
