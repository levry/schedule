{
  ���������
  v0.2.2 (03.04.06)
  (C) Leonid Riskov, 2006
}

unit SConsts;

interface

uses
  Messages;
              
const

  DB_VER_MAJOR   = 0;           // ���������
  DB_VER_MINOR   = 2;           // ���������
  DB_VER_RELEASE = 0;           // �� ������
  DB_VER_BUILD   = 13;          // �� �����������

  SCH_NAME =    '����������';
  WPM_NAME =    '������� ����';
  XMT_NAME =    '���������� ���������';
  DBA_NAME =    'DBAdmin';
  WIM_NAME =    '������ ������� ������';

  SCH_VERSION = '0.2.1.0';   // ������ Shedule (����������)
  WPM_VERSION = '0.2.1.0';    // ������ WPM     (������� ����)
  XMT_VERSION = '0.2.1.0';    // ������ XMTable (���������� ���������)
  DBA_VERSION = '0.2.1.0';    // ������ DBAdmin
  WIM_VERSION = '0.2.1.0';    // ������ WImport (������ ������� ������)

  // ����� �������
  REG_ROOT    = 'Software\Schedule';      // ������
  REG_DTABLE  = 'DTable';
  REG_WPM     = 'WPM';
  REG_XMTABLE = 'XMTable';
  REG_DBADMIN = 'DBAdmin';
  REG_WIMPORT = 'WImport';

  REG_RTABLE  = 'RTable';
  REG_RWPM    = 'RWPM';

  CAT_DTABLE      = 'DTable';
  CAT_EXPORTTABLE = 'ExportTable';

  CAT_WPM         = 'WPM';

  CAT_XMTABLE     = 'XMTable';

  CAT_DBADMIN     = 'DBAdmin';
  CAT_QUERY       = 'Query';

  CAT_WIMPORT     = 'WImport';
  CAT_COLORS      = 'Colors';
  CAT_EXCELSCHEMA = 'Schema';

  // ��������� ������
  ERROR_CON_SUCCESS = 0;     // �����
  ERROR_CON_FAILED  = 1;     // ��� ����������
  ERROR_CON_VERSION = 2;     // ������������ ������
  ERROR_CON_FACULTY = 3;     // ��� �����������
  ERROR_CON_YEAR    = 4;     // ��� ��. �����
  ERROR_CON_EXAM    = 5;     // ��� ������� ���. ������
  ERROR_CON_USER    = 6;     // ������ ��� ����������� ������������

  ERROR_SP_PARAM    = -1;    // ����. �����-�� ������ �����������
  ERROR_SP_CASE     = -100;  // �� �� �������
  ERROR_SP_EXECUTE  = -1000; // ������ ��� ������ ��

  STATE_FREE   = 0;    // ��������
  STATE_BUSY   = 1;    // �����
  STATE_GREEN  = 2;    // ���������
  STATE_RED    = 3;    // ������

  // ��������� ��������
  SELECT_YEARS   = 'SELECT * FROM tb_Year';
  SELECT_FACULTY = 'SELECT * FROM tb_Faculty';
  SELECT_KAFEDRA = 'SELECT * FROM tb_Kafedra';
  SELECT_SUBJECT = 'SELECT * FROM tb_Subject WHERE sbName like %s%%';

  // ��������� ������ ��

  // ���������� �������� �������
  //wpInsert=             1;    // ����� ������
  //wpSelectAvilSemestr = 2;    // ����� ������������ ���������
  //wpSelectStream =      3;    // ����� ������� ������ ��� ����� ������. ������ (���, �������, ����. �������, Id ������)
  //wpSelDeclExport =     4;    // ����� ������ ��� ����. ������� (���, �������, ����. �������) ��� ��������
  wpSelWP          = 1;    // ����� ���. ����� ��������� ������ (grid,sem)
  wpSelDeclareKaf  = 2;    // ����� ������ �� ����. �������
  wpSelDeclareSubj = 3;    // ����� ������ �� �������+����������
  wpSelDeclareExp  = 4;    // ����� ������ (�������)
  wpSelect         = 5;    // ����� ���. ����� ������
  wpCreate         = 10;   // ���������� ���������� � ���. ���� ������
  wpAddLoad        = 11;   // ���������� �������� �� ����������
  wpCopy           = 12;   // ����������� ���������� �.�.
  wpDelete         = 13;   // �������� ���������� �� �.�. ������
  wpDelLoad        = 14;   // �������� ��������
  wpCopyGrp        = 15;   // ����������� �.�. � ������ ������
  wpGetKaf         = 16;   // ���������� �������-����������� ��� ����������

  // �������� ����
  dbvSelKaf=         101;  // ����� ���� ������
  dbvSelGroupOfKaf = 102;  // ����� ����� �������
  dbvSelSubjOfKaf=   103;  // ����� ��������� �������
  dbvSelSubjOfGrp=   104;  // ����� ��������� ������
  dbvSelPosts=       105;  // ����� ���������� ����-���
  dbvSelGrpCrs=      106;  // ����� ����� �����
//  dbvSelKafWithGrp = 107;  // ����� ������ � ��������
  dbvSelSubj       = 108;  // ����� ���������, ���������. � �.�. ����. ��������
  dbvSelGroupOfSbj = 109;  // ����� �����, �.�. �-��� �������� ����������
  dbvSelFaculty    = 110;  // ����� ���� �����������
  dbvSelKafOfFcl   = 111;  // ����� ������ ����������
  dbvSelYears      = 112;  // ����� ��. �����
  dbvSelExamSubj   = 113;  // ����� ��������� ������, �� �-��� ���������� ��� (sem,grid)
  dbvSelPerformKaf = 114;  // ����� ������-������������ ��� ���������� (ynum,sem,fid)


//  dbvSelAvilSemestr= 108;  // ����� ������������ ���������

  // ���������� ��������
  smSelKafSbj      = 201;  // ����� ������� ������� �� ���������� (sem,psem,type,kid,sbid)
  smCreate         = 202;  // �������� ������ (lid)
  smDelete         = 203;  // �������� ������ (strid)
  smAddGrp         = 204;  // ���������� ������ � ����� (strid, lid)
  smDeleteGroup    = 205;  // �������� ������ �� ������ (lid)
  smSelForStrm     = 206;  // ����� ������. ������ ��� ������
  smSelFreeDeclare = 207;  // ����� ������. ������ (sem,psem,type,kid,sbid)
  smSelSbj=          208;  // ����� ������ �� ����.+����., �����. ����� ������ (kid,sbid)
  smSetThr         = 209;  // ���-�� ������� ��� ������ (strid,tid)
  // TODO : DEL
//  smSelStreamKaf=    201;  // ����� ���� ������� ��������� ������� (���, �������, �������)
//  smSelStreamSubj=   202;  // ����� ������� �� ����. ���������� (���, �������, �������, ����������)
//  smSelGrpOfStream=  203;  // ����� ����� � ������. ������ (Id ������)
//  smCreateStream=    204;  // �������� ������ (���, �������, Id ������, �������, ��������, �������, ����. ������, ����. ����������)
//  smDeleteStream=    205;  // �������� ������ (Id ������)
//  smAddGroup=        206;  // ���������� ������ � ����� (���, �������, ����������, Id ������, ����. ������, ��������, �������)
//  smDelGroup=        207;  // �������� ������ �� ������ (Id ������, ����. ������)
//  smSelFreeGroup=    208;  // ����� ������. ����� (���, �������, �������, ����������)
//  smUpdateStream=    209;  // ��������� ���������� � ������(������ � ������) (Id ������, Id �������, Id ��������, Id ���������, ����. ������)

  // ���������� ���������������
  thSelTchKaf=       301;  // ����� �������������� ������� (kid)
  thSelTchLd=        302;  // ����� ����-��� ��� �������� (kid)
  thSelTchList=      303;  // ����� ������ ����-��� ������� (kid)
  thSelPrefer=       304;  // ����� ����������� ����-�� (tid)

  // ���������� �����������
  audSelectKaf     = 401;  // ����� ��������� �������
  audSelectFclty   = 402;  // ����� ��������� ����������
  audSelectPrefer  = 404;  // ����� ����������� ���������

  // ���������� �����-��(��������-��)
  preSelectTeach   = 501;  // ����� ��������-�� ��� ������-�� (Id ������-��)
  preSelectAud     = 502;  // ����� ����������� ��� ��������� (����. ���������)

  // ���������� �����������
  sdlSelectGrp     = 601;  // ����� ���������� ������ (grid,sem,psem)
  sdlNewLsns       = 602;  // ���-�� ������� (lid,week,wday,npair,hgrp,aid)
  sdlDelLsns       = 603;  // �������� ������� (lid,week,wday,npair)

  sdlSetThrGrp     = 604;  // ���-� ����-�� ������� (lid,week,wday,npair,tid)
  sdlSetAdrGrp     = 605;  // ���-� ��������� ������� (lid,week,wday,npair,aid)
  sdlSetHgrp       = 606;  // ���-� ��������� ������� (lid,week,wday,npair,hgrp)

//  sdlSetLsns       = 604;  // ���-��� ������� (lid,week,wday,npair,hgrp,aid,tid)

  sdlNewStrm       = 607;  // ���-�� �����. ������� (strid,week,wday,npair,aid)
  sdlDelStrm       = 608;  // �������� �����. ������� (strid,week,wday,npair)
  sdlSetThrStrm    = 609;  // ���-� ����-�� ���. ������� (strid,week,wday,npair,tid)
  sdlSetAdrStrm    = 610;  // ���-� ��������� ���. ������� (strid,week,wday,npair,aid)

  sdlSelFreeThr    = 611;  // ����� ������. ����-��� (lid,week,wday,npair)
  sdlAvailSubject  = 612;  // ����� ������. ������� (sem,psem,week,wday,npair,grid,sbid)
  sdlSelectStrm    = 613;  // ����� �����. ������� (strid,[wday,npair])
  sdlSelFreeAdrGrp = 614;  // ����� ������. ��������� (lid,week,wday,npair)
  sdlSelectLsns    = 615;  // ����� ������� �������� (lid,[wday,npair])
  sdlAvailGroup    = 616;  // ����� ������. �������
  sdlAvailPSem     = 617;  // ����� ������. ������� � �/��� (sem,psem,grid)
  sdlSelFreeAdrKaf = 618;  // ����� ����. ���-��� ���-��� (lid,week,wday,npair)

  sdlSelectThr     = 620;  // ����� ���������� ����-�� (ynum,sem,psem,tid)
  sdlSelectAdr     = 621;  // ����� ��������� ��������� (ynum,sem,psem,aid)

  sdlGetLoadAdr    = 630;  // ����� �������� ��������� � ���������� (ynum,sem,psem,aid)

  // ���������� ������������
  sbjSelLetter     = 701;  // ����� ��������� �� 1� �����
  sbjReplace       = 702;  // ������ ����������

  // ���������� ��������
  grpSelKaf        = 801;  // ����� ����� �������
  grpSelCrs        = 802;  // ����� ����� �����

  // ������ ������
  impAddFaculty    = 901;  // ���������� ����������
  impAddKafedra    = 902;  // ���������� �������
  impGetGRID       = 903;  // ����������� ID ������ (grName)
  impGetKID        = 904;  // ����������� ID ������� (kName)
  impGetSBID       = 905;  // ����������� ID ���������� (sbName)
  impChkYear       = 906;  // �������� ������ ��. ���� (ynum)
  impAddGroup      = 907;  // ���������� ������ (grName,kid,studs,course,ynum)
  impAddWorkplan   = 908;  // ���������� ���������� ([all])
  impAddLoad       = 909;  // ���������� ���. �������� (wpid,psem,type,hours)

  // ���-��� ��.-�����. ������
  plnAddYear      = 1000;  // ���������� ��. ���� (ynum)
  plnSelPeriods   = 1001;  // ����� �������� ��. ���� (ynum)
  plnAddPeriod    = 1002;  // ���������� ������� ��. ���� (ynum,sem,ptype,p_start,p_end)

  // ���-��� ���/����
  xmSelect        = 1101;  // ����� ���������� ���/���� ������ (grid,sem)
  xmAdd           = 1102;  // ���������� ���/����
  xmDelete        = 1103;  // �������� ���/���� (wpid, xmtype)
  xmSetAdr        = 1104;  // ���-��� ��������� ���/���� (wpid,xmtype,aid)
  xmSetHGrp       = 1105;  // ����� ������� ������ (wpid, hgrp)
  xmSetTime       = 1106;  // ����� ������� ���/���� (wpid,xmtype,xmtime)
  xmGetPeriods    = 1107;  // ���������� ������� ���. ������ (ynum,sem,start out,end out)
  xmGetFreeAudFac = 1108;  // ����� ������. ���-��� ���-�� (fid,xmtime)
  xmGetFreeAudWP  = 1109;  // ����� ������. ���-��� ���-��� (wpid,xmtime)
  xmGetAvailWP    = 1110;  // ����� ������. ���/���� ��� ���������� (wpid,xmtype,xmtime)
  xmGetAvailGrp   = 1111;  // ����� ������. ���/���� ��� ������ (grid,sem,xmtype,xmtime)
  xmGetFaculty    = 1112;  // ����� ���������� ���/���� ���������� (ynum,sem,fid,xmtype)
  xmGetKafedra    = 1113;  // ����� ���������� ���/���� ������� (ynum,sem,fid,kid)
  xmGetPerformKaf = 1114;  // ����� ������-������������ ��������� (ynum,sem,fid)
  xmGetLoadAdry   = 1115;  // ����� ��������� ��������� (ynum,sem,fid,[kid])

implementation

end.
