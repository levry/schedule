{
  Система логирования
  v0.0.1
  (C) Riskov Leonid, 2007
}
unit SLogger;

interface

uses
  Classes;

type

  TLogMsgType = (lmtError, lmtWarn, lmtInfo);

  TLogMsg = record
    msgtype: TLogMsgType;
    msg: string;
    logobj: TObject;
  end;

  {
    Драйвер лога
    реализация данного интерфейса должна осуществлять
    непосредственный вывод сообщения
  }
  ILogDriver = interface
    ['{218EFD87-A5D5-4AA1-AD3B-BC9D6886F99C}']
    procedure log(msg: TLogMsg);

  end;

  TLogger = class
  private
    FLogDriver: ILogDriver;
    procedure log(msgtype: TLogMsgType; msg: string; logobj: TObject);

  public
    constructor Create(LogDriver: ILogDriver);
    procedure error(msg: string; logobj: TObject=nil);
    procedure warn(msg: string; logobj: TObject=nil);
    procedure info(msg: string; logobj: TObject=nil);

  end;

  TLogMsgEvent = procedure(msg: TLogMsg) of object;

  TCallbackLogDriver = class(TInterfacedObject, ILogDriver)
  private
    FOnMsgLog: TLogMsgEvent;

  public
    constructor Create(LogEvent: TLogMsgEvent);
    procedure log(msg: TLogMsg);

  end;

implementation

{ TLogger }

function buildLog(msgtype: TLogMsgType; msg: string; logobj: TObject): TLogMsg;
begin
  Result.msgtype:=msgtype;
  Result.msg:=msg;
  Result.logobj:=logobj;
end;

constructor TLogger.Create(LogDriver: ILogDriver);
begin
  FLogDriver:=LogDriver;
end;

procedure TLogger.log(msgtype: TLogMsgType; msg: string; logobj: TObject);
begin
  FLogDriver.log(buildLog(msgtype, msg, logobj));
end;

procedure TLogger.error(msg: string; logobj: TObject);
begin
  log(lmtError, msg, logobj);
end;

procedure TLogger.info(msg: string; logobj: TObject);
begin
  log(lmtInfo, msg, logobj);
end;

procedure TLogger.warn(msg: string; logobj: TObject);
begin
  log(lmtWarn, msg, logobj);
end;

{ TCallbackLogDriver }

constructor TCallbackLogDriver.Create(LogEvent: TLogMsgEvent);
begin
  Assert(Assigned(LogEvent),
    '6E19C432-9014-409F-9284-6627CE34F0C4'#13'TCallbackLogDriver: LogEvent is null'#13);

  FOnMsgLog:=LogEvent;
end;

procedure TCallbackLogDriver.log(msg: TLogMsg);
begin
  if Assigned(FOnMsgLog) then
    FOnMsgLog(msg);
end;

end.
