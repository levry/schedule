{
  DB-функции
  v0.0.2  (25/09/06)
}
unit SDBUtils;

interface

uses
  DB, ADODB, ADOInt, Classes;

procedure CommitTemporary(ADataSet: TDataSet);
procedure DeleteTemporary(ADataSet: TDataSet);
function CloneCommand(ACommand: TADOCommand): _Command;
function GetRecordset(Recordset: _Recordset; DataSet: TADODataSet): boolean;

implementation

uses
  OLEDB, Dialogs, SysUtils,
  SUtils;

// принятие времен. записей
procedure CommitTemporary(ADataSet: TDataSet);
var
  Field: TField;
begin
  ADataSet.First;
  while not ADataSet.Eof do
  begin
    Field:=ADataSet.FieldByName('RecState');
    if field.AsInteger=0 then
    begin
      ADataSet.Edit;
      Field.Value:=1;
      ADataSet.Post;
    end;
    ADataSet.Next;
  end;
end;

// удаление времен. записей
procedure DeleteTemporary(ADataSet: TDataSet);
begin
  ADataSet.First;

  while not ADataSet.Eof do
  begin
    if ADataSet.FieldByName('RecState').Value=0 then ADataSet.Delete
      else ADataSet.Next;
  end;  // while
end;

// создание Command (ADO) на основе TADOCommand
function CloneCommand(ACommand: TADOCommand): _Command;
const
  CommandTypeValues: array[TCommandType] of TOleEnum = (adCmdUnknown,
    adCmdText, adCmdTable, adCmdStoredProc, adCmdFile, adCmdTableDirect);
var
  i: integer;
  prm: _Parameter;
begin
  Assert(Assigned(ACommand.Connection),
    'CEC8EA2A-BFBA-44BC-8682-2A54998E6A84'#13'CloneCommand: ACommand.Connection is nil'#13);

  if Assigned(ACommand) then
  begin
    Result:=CoCommand.Create;

    Result.Set_ActiveConnection(ACommand.Connection.ConnectionObject);
    Result.CommandText:=ACommand.CommandText;
    Result.CommandTimeout:=ACommand.CommandTimeout;
    Result.CommandType:=CommandTypeValues[ACommand.CommandType];
    Result.Prepared:=ACommand.Prepared;

    for i:=0 to ACommand.Parameters.Count-1 do
    begin
      prm:=ACommand.Parameters[i].ParameterObject;
      prm:=Result.CreateParameter(prm.Name,prm.Type_,prm.Direction,prm.Size,prm.Value);
      Result.Parameters.Append(prm);
    end;
  end;
end;

// DataSet.Recordset=Recordset  (25/09/06)
function GetRecordset(Recordset: _Recordset; DataSet: TADODataSet): boolean;
begin
  DataSet.Close;
  try
    if Assigned(Recordset) then
      if (Recordset.State and adStateOpen)=1 then DataSet.Recordset:=Recordset;
  except
    on E: Exception do
    begin
      DataSet.Close;
      ShowMessageFmt('Ошибка: %s',[E.Message]);
    end;
  end;
  Result:=DataSet.Active;
end;


end.
