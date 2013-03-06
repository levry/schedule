{
  ����, ���������
  v0.0.2 (02.05.06)
}
unit STypes;

interface

uses
  Messages;

type
  TFlagsEvent = procedure(Sender: TObject; Flags: WORD) of object;

  // ������
  TVersionInfo = record
    major: BYTE;
    minor: BYTE;
    release: BYTE;
    build: WORD;
  end;

  // ������ �������
  TDatePeriod = record
    dbegin: TDateTime;   // ������
    dend: TDateTime;     // �����
  end;

  // c��������� ����� ������� (���,���,�/���)
  TSMChangeTime = packed record
    Msg: cardinal;
    Flags:  WORD;       // ����� ���-��� �������
    Year: WORD;         // ��-��� ����
    Sem: BYTE;          // ��-��� ��������
    PSem: BYTE;         // ��-��� �/��������
    Reserved: WORD;     // ������
    Result: longint;
  end;

  TEntityKind = (ekNone, ekFaculty, ekKafedra, ekAuditory, ekSubject, ekTeacher,
                 ekGroup, ekExamSubject);

  // ������ ������
  TEntityData = record
    kind: TEntityKind;
    id: int64;
    name: string;
  end;
  PEntityData = ^TEntityData;

  TLogMsgType = (lmtInfo, lmtWarning, lmtError);

const

  // ���������
  SM_APP = WM_APP+100;       // ������ ������� ��� ���������

  SM_CHANGETIME = SM_APP+1;  // ��������� ��� ����� �/���, ���, ����

  // ����� ���-��� ������� (TSMChangeTime)
  CT_YEAR = 1;          // ���-��� ����
  CT_SEM  = 2;          // ���-��� ��������
  CT_PSEM = 4;          // ���-��� �/��������

  // ���������� �� ��������� TMessage.Result
  MRES_NONE    = 0;
  MRES_DESTROY = 1;    // �������� ������
  MRES_UPDATE  = 2;    // ���������� ������

function SizePeriod(APeriod: TDatePeriod): integer;

implementation

uses
  DateUtils;

// ���������� ���-�� ���� � �������
function SizePeriod(APeriod: TDatePeriod): integer;
begin
  Result:=DaysBetween(APeriod.dend, APeriod.dbegin)+1;
end;
  
end.
 