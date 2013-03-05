{
  Константы
  v0.2.2 (03.04.06)
  (C) Leonid Riskov, 2006
}

unit SConsts;

interface

uses
  Messages;
              
const

  DB_VER_MAJOR   = 0;           // равенство
  DB_VER_MINOR   = 2;           // равенство
  DB_VER_RELEASE = 0;           // не больше
  DB_VER_BUILD   = 13;          // не учитывается

  SCH_NAME =    'Расписание';
  WPM_NAME =    'Рабочий план';
  XMT_NAME =    'Расписание экзаменов';
  DBA_NAME =    'DBAdmin';
  WIM_NAME =    'Импорт рабочих планов';

  SCH_VERSION = '0.2.1.0';   // версия Shedule (Расписание)
  WPM_VERSION = '0.2.1.0';    // версия WPM     (Рабочий план)
  XMT_VERSION = '0.2.1.0';    // версия XMTable (Расписание экзаменов)
  DBA_VERSION = '0.2.1.0';    // версия DBAdmin
  WIM_VERSION = '0.2.1.0';    // версия WImport (Импорт рабочих планов)

  // ключи реестра
  REG_ROOT    = 'Software\Schedule';      // корень
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

  // константы ошибок
  ERROR_CON_SUCCESS = 0;     // успех
  ERROR_CON_FAILED  = 1;     // нет соединения
  ERROR_CON_VERSION = 2;     // неправильная версия
  ERROR_CON_FACULTY = 3;     // нет факультетов
  ERROR_CON_YEAR    = 4;     // нет уч. годов
  ERROR_CON_EXAM    = 5;     // нет периода экз. сессии
  ERROR_CON_USER    = 6;     // ошибка при авторизации пользователя

  ERROR_SP_PARAM    = -1;    // вход. парам-ры заданы неправильно
  ERROR_SP_CASE     = -100;  // ХП не найдена
  ERROR_SP_EXECUTE  = -1000; // ошибка при вызове ХП

  STATE_FREE   = 0;    // свободно
  STATE_BUSY   = 1;    // занят
  STATE_GREEN  = 2;    // пожелание
  STATE_RED    = 3;    // запрет

  // константы запросов
  SELECT_YEARS   = 'SELECT * FROM tb_Year';
  SELECT_FACULTY = 'SELECT * FROM tb_Faculty';
  SELECT_KAFEDRA = 'SELECT * FROM tb_Kafedra';
  SELECT_SUBJECT = 'SELECT * FROM tb_Subject WHERE sbName like %s%%';

  // константы вызова ХП

  // управление рабочими планами
  //wpInsert=             1;    // новая запись
  //wpSelectAvilSemestr = 2;    // выбор существующих семестров
  //wpSelectStream =      3;    // выбор рабочих планов для групп указан. потока (год, семестр, назв. кафедры, Id потока)
  //wpSelDeclExport =     4;    // выбор заявок для указ. кафедры (год, семестр, назв. кафедры) для экспорта
  wpSelWP          = 1;    // выбор раб. плана указанной группы (grid,sem)
  wpSelDeclareKaf  = 2;    // выбор заявок на указ. кафедру
  wpSelDeclareSubj = 3;    // выбор заявок на кафедру+дисциплина
  wpSelDeclareExp  = 4;    // выбор заявок (экспорт)
  wpSelect         = 5;    // выбор раб. плана группы
  wpCreate         = 10;   // добавление дисциплины в раб. план группы
  wpAddLoad        = 11;   // добавление нагрузки на дисциплину
  wpCopy           = 12;   // копирование дисциплины р.п.
  wpDelete         = 13;   // удаление дисциплины из р.п. группы
  wpDelLoad        = 14;   // удаление нагрузки
  wpCopyGrp        = 15;   // копирование р.п. в другую группу
  wpGetKaf         = 16;   // извлечение кафедры-исполнителя для дисциплины

  // просмотр базы
  dbvSelKaf=         101;  // выбор всех кафедр
  dbvSelGroupOfKaf = 102;  // выбор групп кафедры
  dbvSelSubjOfKaf=   103;  // выбор дисциплин кафедры
  dbvSelSubjOfGrp=   104;  // выбор дисциплин группы
  dbvSelPosts=       105;  // выбор должностей преп-лей
  dbvSelGrpCrs=      106;  // выбор групп курса
//  dbvSelKafWithGrp = 107;  // выбор кафедр с группами
  dbvSelSubj       = 108;  // выбор дисциплин, присутств. в р.п. указ. семестра
  dbvSelGroupOfSbj = 109;  // выбор групп, р.п. к-рых содержат дисциплину
  dbvSelFaculty    = 110;  // выбор всех факультетов
  dbvSelKafOfFcl   = 111;  // выбор кафедр факультета
  dbvSelYears      = 112;  // выбор уч. годов
  dbvSelExamSubj   = 113;  // выбор дисциплин группы, по к-рым проводится экз (sem,grid)
  dbvSelPerformKaf = 114;  // выбор кафедр-исполнителей для факультета (ynum,sem,fid)


//  dbvSelAvilSemestr= 108;  // выбор существующих семестров

  // управление потоками
  smSelKafSbj      = 201;  // выбор потоков кафедры по дисциплине (sem,psem,type,kid,sbid)
  smCreate         = 202;  // создание потока (lid)
  smDelete         = 203;  // удаление потока (strid)
  smAddGrp         = 204;  // добавление группы в поток (strid, lid)
  smDeleteGroup    = 205;  // удаление группы из потока (lid)
  smSelForStrm     = 206;  // выбор свобод. заявок для потока
  smSelFreeDeclare = 207;  // выбор свобод. заявок (sem,psem,type,kid,sbid)
  smSelSbj=          208;  // выбор заявок по дисц.+дисц., объед. через потоки (kid,sbid)
  smSetThr         = 209;  // уст-ка лектора для потока (strid,tid)
  // TODO : DEL
//  smSelStreamKaf=    201;  // выбор всех потоков указанной кафедры (год, семестр, кафедра)
//  smSelStreamSubj=   202;  // выбор потоков по указ. дисциплине (год, семестр, кафедра, дисциплина)
//  smSelGrpOfStream=  203;  // выбор групп в указан. потоке (Id потока)
//  smCreateStream=    204;  // создание потока (год, семестр, Id потока, лектора, лаборант, практик, назв. группы, назв. дисциплины)
//  smDeleteStream=    205;  // удаление потока (Id потока)
//  smAddGroup=        206;  // добавление группы в поток (год, семестр, дисциплина, Id потока, назв. группы, лаборант, практик)
//  smDelGroup=        207;  // удаление группы из потока (Id потока, назв. группы)
//  smSelFreeGroup=    208;  // выбор свобод. групп (год, семестр, кафедра, дисциплина)
//  smUpdateStream=    209;  // изменение информации о потоке(группе в потоке) (Id потока, Id лектора, Id практика, Id лаборанта, назв. группы)

  // управление преподавателями
  thSelTchKaf=       301;  // выбор преподавателей кафедры (kid)
  thSelTchLd=        302;  // выбор преп-лей для нагрузки (kid)
  thSelTchList=      303;  // выбор списка преп-лей кафедры (kid)
  thSelPrefer=       304;  // выбор ограничений преп-ля (tid)

  // управления аудиториями
  audSelectKaf     = 401;  // выбор аудиторий кафедры
  audSelectFclty   = 402;  // выбор аудиторий факультета
  audSelectPrefer  = 404;  // выбор ограничений аудиторий

  // управление огран-ми(предпочт-ми)
  preSelectTeach   = 501;  // выбор предпочт-ий для препод-ля (Id препод-ля)
  preSelectAud     = 502;  // выбор ограничений для аудитории (назв. аудитории)

  // управление расписанием
  sdlSelectGrp     = 601;  // выбор расписания группы (grid,sem,psem)
  sdlNewLsns       = 602;  // уст-ка занятия (lid,week,wday,npair,hgrp,aid)
  sdlDelLsns       = 603;  // удаление занятия (lid,week,wday,npair)

  sdlSetThrGrp     = 604;  // изм-е преп-ля занятия (lid,week,wday,npair,tid)
  sdlSetAdrGrp     = 605;  // изм-е аудитории занятия (lid,week,wday,npair,aid)
  sdlSetHgrp       = 606;  // изм-е подгруппы занятия (lid,week,wday,npair,hgrp)

//  sdlSetLsns       = 604;  // изм-ние занятия (lid,week,wday,npair,hgrp,aid,tid)

  sdlNewStrm       = 607;  // уст-ка поток. занятия (strid,week,wday,npair,aid)
  sdlDelStrm       = 608;  // удаление поток. занятия (strid,week,wday,npair)
  sdlSetThrStrm    = 609;  // изм-е преп-ля пот. занятия (strid,week,wday,npair,tid)
  sdlSetAdrStrm    = 610;  // изм-е аудитории пот. занятия (strid,week,wday,npair,aid)

  sdlSelFreeThr    = 611;  // выбор свобод. преп-лей (lid,week,wday,npair)
  sdlAvailSubject  = 612;  // выбор доступ. занятий (sem,psem,week,wday,npair,grid,sbid)
  sdlSelectStrm    = 613;  // выбор поток. занятий (strid,[wday,npair])
  sdlSelFreeAdrGrp = 614;  // выбор свобод. аудиторий (lid,week,wday,npair)
  sdlSelectLsns    = 615;  // выбор занятий нагрузки (lid,[wday,npair])
  sdlAvailGroup    = 616;  // выбор возмож. занятий
  sdlAvailPSem     = 617;  // выбор возмож. занятий в п/сем (sem,psem,grid)
  sdlSelFreeAdrKaf = 618;  // выбор своб. ауд-рий каф-исп (lid,week,wday,npair)

  sdlSelectThr     = 620;  // выбор расписания преп-ля (ynum,sem,psem,tid)
  sdlSelectAdr     = 621;  // выбор занятости аудитории (ynum,sem,psem,aid)

  sdlGetLoadAdr    = 630;  // выбор загрузки аудитории в расписании (ynum,sem,psem,aid)

  // управление дисциплинами
  sbjSelLetter     = 701;  // выбор дисциплин по 1й букве
  sbjReplace       = 702;  // замена дисциплины

  // управление группами
  grpSelKaf        = 801;  // выбор групп кафедры
  grpSelCrs        = 802;  // выбор групп курса

  // импорт данных
  impAddFaculty    = 901;  // добавление факультета
  impAddKafedra    = 902;  // добавление кафедры
  impGetGRID       = 903;  // определение ID группы (grName)
  impGetKID        = 904;  // определение ID кафедры (kName)
  impGetSBID       = 905;  // определение ID дисциплины (sbName)
  impChkYear       = 906;  // проверка данных уч. года (ynum)
  impAddGroup      = 907;  // добавление группы (grName,kid,studs,course,ynum)
  impAddWorkplan   = 908;  // добавление дисциплины ([all])
  impAddLoad       = 909;  // добавление ауд. нагрузки (wpid,psem,type,hours)

  // упр-ние уч.-произ. планом
  plnAddYear      = 1000;  // добавление уч. года (ynum)
  plnSelPeriods   = 1001;  // выбор периодов уч. года (ynum)
  plnAddPeriod    = 1002;  // добавление периода уч. года (ynum,sem,ptype,p_start,p_end)

  // упр-ние экз/конс
  xmSelect        = 1101;  // выбор расписания экз/конс группы (grid,sem)
  xmAdd           = 1102;  // добавление экз/конс
  xmDelete        = 1103;  // удаление экз/конс (wpid, xmtype)
  xmSetAdr        = 1104;  // изм-ние аудитории экз/конс (wpid,xmtype,aid)
  xmSetHGrp       = 1105;  // смена состава группы (wpid, hgrp)
  xmSetTime       = 1106;  // смена времени экз/конс (wpid,xmtype,xmtime)
  xmGetPeriods    = 1107;  // извлечение периода экз. сессии (ynum,sem,start out,end out)
  xmGetFreeAudFac = 1108;  // выбор свобод. ауд-рий фак-та (fid,xmtime)
  xmGetFreeAudWP  = 1109;  // выбор свобод. ауд-рий каф-исп (wpid,xmtime)
  xmGetAvailWP    = 1110;  // выбор возмож. экз/конс для дисципилны (wpid,xmtype,xmtime)
  xmGetAvailGrp   = 1111;  // выбор возмож. экз/конс для группы (grid,sem,xmtype,xmtime)
  xmGetFaculty    = 1112;  // выбор расписания экз/конс факультета (ynum,sem,fid,xmtype)
  xmGetKafedra    = 1113;  // выбор расписания экз/конс кафедры (ynum,sem,fid,kid)
  xmGetPerformKaf = 1114;  // выбор кафедр-исполнителей экзаменов (ynum,sem,fid)
  xmGetLoadAdry   = 1115;  // выбор занятости аудиторий (ynum,sem,fid,[kid])

implementation

end.
