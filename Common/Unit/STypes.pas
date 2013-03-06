{
  Типы, сообщения
  v0.0.2 (02.05.06)
}
unit STypes;

interface

uses
  Messages;

type
  TFlagsEvent = procedure(Sender: TObject; Flags: WORD) of object;

  // версия
  TVersionInfo = record
    major: BYTE;
    minor: BYTE;
    release: BYTE;
    build: WORD;
  end;

  // период времени
  TDatePeriod = record
    dbegin: TDateTime;   // начало
    dend: TDateTime;     // конец
  end;

  // cсообщение смены времени (год,сем,п/сем)
  TSMChangeTime = packed record
    Msg: cardinal;
    Flags:  WORD;       // флаги изм-ния времени
    Year: WORD;         // зн-ние года
    Sem: BYTE;          // зн-ние семестра
    PSem: BYTE;         // зн-ние п/семестра
    Reserved: WORD;     // резерв
    Result: longint;
  end;

  TEntityKind = (ekNone, ekFaculty, ekKafedra, ekAuditory, ekSubject, ekTeacher,
                 ekGroup, ekExamSubject);

  // объект модели
  TEntityData = record
    kind: TEntityKind;
    id: int64;
    name: string;
  end;
  PEntityData = ^TEntityData;

  TLogMsgType = (lmtInfo, lmtWarning, lmtError);

const

  // сообщения
  SM_APP = WM_APP+100;       // начало номеров для сообщений

  SM_CHANGETIME = SM_APP+1;  // сообщение при смене п/сем, сем, года

  // флаги изм-ния времени (TSMChangeTime)
  CT_YEAR = 1;          // изм-ние года
  CT_SEM  = 2;          // изм-ние семестра
  CT_PSEM = 4;          // изм-ние п/семестра

  // результаты на сообщения TMessage.Result
  MRES_NONE    = 0;
  MRES_DESTROY = 1;    // удаление модуля
  MRES_UPDATE  = 2;    // обновление модуля

function SizePeriod(APeriod: TDatePeriod): integer;

implementation

uses
  DateUtils;

// возвращает кол-во дней в периоде
function SizePeriod(APeriod: TDatePeriod): integer;
begin
  Result:=DaysBetween(APeriod.dend, APeriod.dbegin)+1;
end;
  
end.
 