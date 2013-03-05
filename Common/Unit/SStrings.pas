{
  ������
  v0.2.3  (06/10/06)
  (C) Leonid Riskov, 2006
}

unit SStrings;

interface

const
  csPSemester = '�/�������';
  csSemester: array[1..2] of string = ('�������','��������');
  csDayNames: array[0..5] of string = ('��', '��', '��', '��', '��', '��');

resourcestring
  rsSchedule = '����������';
  rsWorkplan = '������� ����';
  rsXMTable  = '���������� ���������';
  rsHelp     = '�������';

  rsContinue = '����������?';
  rsNull     = '(����������)';
  rsFirstSem = '�������';
  rsSecondSem= '��������';

  // entity
  rsFaculty  = '���������';
  rsKafedra  = '�������';
  rsAuditory = '���������';
  rsTeacher  = '�������������';
  rsSubject  = '����������';
  rsGroup    = '������';
  rsPost     = '���������';
  rsStream   = '�����';
  rsExam     = '�������';
  rsCons     = '������������';
  rsYear     = '������� ���';

  rsPeriodTitle = '%s ������� %d �/������� %d-%d �������� ����';

  rsErrAddStrmGrp = '�� ������� ���������� ������ (lid=%d)';
  rsNotFoundDclrs = '�� ������� ��������� ������ ��� ������';

  rsErrNoDataNode = '���� �� ����� ������';
  rsErrCopyWP     = '������ ��� ����������� ����������� ''%s''';
  rsErrResult     = '��� �������� CODE=%d';
  rsErrInvalidID  = '������������ ������������� ID=%d';
  rsErrAddFaculty = '������ ��� ���������� ���������� ''%s'''#13'��� ��������: %d';
  rsErrAddKafedra = '������ ��� ���������� ������� ''%s'''#13'��� ��������: %d';
  rsErrKafedraList= '������ ��� �������� ������ ������';
  rsErrNoConnect  = '��� ���������� � ��';

  // Excel
  rsExRun         = '������ MS Excel (������ %s)';
  rsExQuit        = '�������� MS Excel (������ %s)';
  rsExOldVersion  = '������������ ������ ������ MS Excel (������ %s).';
  rsExInvalidView = '��������� �������� ���������� ����� ����������� ������������.';
  rsExNotFoundXlt = '���� ������� %s �� ������.';
  rsExMuchEvents  = '������� ����� �������';

  // Excel (import)
  rsExLoadData    = '�������� ������';
  rsExOpenBook    = '�������� �����: ''%s''';
  rsExErrOpenBook = '������ ��� �������� �����';
  rsExExistsData  = '������� ���� ������ ''%s'' (%s) ��� ��������. ��������?';
  rsExCheckBooks  = '�������� Excel ����';
  rsExCheckBook   = '�������� ����� ''%s''';
  rsExCheckSheet  = '�������� �����: ''%s''';
  rsExBookWithErr = '������ � ����� ''%s''';
  rsExSheetWithErr= '������ �� ����� ''%s''';
  rsExBookNotErr  = '����� �� ����� ������';
  rsExGetSheetData= '���������� ������ � �����: ''%s''';
  rsExEmptySubject= '������ ����������!';
  rsExErrSbjIndex = '�� ������ ������ ��� ���������� ''%s''';
  rsExErrSbjKaf   = '�� ������� ������� ��� ���������� ''%s''';
  rsExErrGrpPrefix= '�������� ������ (%s) �� ����� ��������';
  rsExErrGrpToCnt = '�� ������������ ����� ����� ����� �������� � ���-�� ���������';
  rsExErrNoSem    = '�� ������ ������� ��������';
  rsExErrNoGrpKaf = '�� ������� ������� ������';
  rsExUserAbort   = '������� ������� �������������!';
  rsExErrGetSheet = '������ ��� ���������� ������ � ����� ''%s''';
  rsExErrGetBook  = '������ ��� ���������� ������ �� ����� ''%s''';
  rsExBookComplete= '�����: ''%s''. ������ ������� ���������';

  // Log messages
  rsLogCheckData  = '�������� ������';
  rsLogCheckSuccess='������ �������� ��� �������';
  rsLogCheckFault = '������ �� ������ ��������';
  rsLogImportData = '������ ������';
  rsLogUnknownSbj = '����������� ���������� ''%s''';
  rsLogUnknownKaf = '����������� ������� ''%s''';
  rsLogInvalidYear= '������� ��� ''%s'' ����������� ��������';
  rsLogExistsGrp  = '������ ''%s'' ��� ���������� � ��';
  rsLogImportGrp  = '������ ������ ''%s'' ...';
  rsLogImportWP   = '������ �������� ����� ������ ''%s'' ...';
  rsLogErrImportSbj='������ ��� ���������� ���������� ''%s''';
  rsLogErrImportLd= '������ ��� ���������� ���. ��������';
  rsLogImportSuccess = '������ ������ ������� ����������';
  rsLogImportFault= '������ �� ��������. ��������� ����� ���� ��������';

function GetPeriodTitle(Sem,PSem: BYTE; Year: WORD): string;

implementation

uses
  SysUtils;

// ���������� ������ ������� (�������,�/�������,���)
function GetPeriodTitle(Sem,PSem: BYTE; Year: WORD): string;
begin
  Result:=Format(rsPeriodTitle,[csSemester[Sem],PSem,Year,Year+1]);
end;

end.
