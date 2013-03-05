{
  Строки
  v0.2.3  (06/10/06)
  (C) Leonid Riskov, 2006
}

unit SStrings;

interface

const
  csPSemester = 'п/семестр';
  csSemester: array[1..2] of string = ('осенний','весенний');
  csDayNames: array[0..5] of string = ('Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб');

resourcestring
  rsSchedule = 'Расписание';
  rsWorkplan = 'Рабочий план';
  rsXMTable  = 'Расписание экзаменов';
  rsHelp     = 'Справка';

  rsContinue = 'Продолжить?';
  rsNull     = '(Неизвестно)';
  rsFirstSem = 'Осенний';
  rsSecondSem= 'Весенний';

  // entity
  rsFaculty  = 'Факультет';
  rsKafedra  = 'Кафедра';
  rsAuditory = 'Аудитория';
  rsTeacher  = 'Преподаватель';
  rsSubject  = 'Дисциплина';
  rsGroup    = 'Группа';
  rsPost     = 'Должность';
  rsStream   = 'Поток';
  rsExam     = 'Экзамен';
  rsCons     = 'Консультация';
  rsYear     = 'Учебный год';

  rsPeriodTitle = '%s семестр %d п/семестр %d-%d учебного года';

  rsErrAddStrmGrp = 'Не удалось объединить заявку (lid=%d)';
  rsNotFoundDclrs = 'Не найдено свободных заявок для потока';

  rsErrNoDataNode = 'Узел не имеет данных';
  rsErrCopyWP     = 'Ошибка при копировании дисцилплины ''%s''';
  rsErrResult     = 'Код возврата CODE=%d';
  rsErrInvalidID  = 'Неправильный идентификатор ID=%d';
  rsErrAddFaculty = 'Ошибка при добавлении факультета ''%s'''#13'Код возврата: %d';
  rsErrAddKafedra = 'Ошибка при добавлении кафедры ''%s'''#13'Код возврата: %d';
  rsErrKafedraList= 'Ошибка при создании списка кафедр';
  rsErrNoConnect  = 'Нет соединения с БД';

  // Excel
  rsExRun         = 'Запуск MS Excel (версия %s)';
  rsExQuit        = 'Закрытие MS Excel (версия %s)';
  rsExOldVersion  = 'Используется старая версия MS Excel (версия %s).';
  rsExInvalidView = 'Некоторые элементы оформления могут неправильно отображаться.';
  rsExNotFoundXlt = 'Файл шаблона %s не найден.';
  rsExMuchEvents  = 'Слишком много событий';

  // Excel (import)
  rsExLoadData    = 'Загрузка данных';
  rsExOpenBook    = 'Открытие книги: ''%s''';
  rsExErrOpenBook = 'Ошибка при открытии книги';
  rsExExistsData  = 'Рабочий план группы ''%s'' (%s) уже загружен. Заменить?';
  rsExCheckBooks  = 'Проверка Excel книг';
  rsExCheckBook   = 'Проверка книги ''%s''';
  rsExCheckSheet  = 'Проверка листа: ''%s''';
  rsExBookWithErr = 'Ошибки в книге ''%s''';
  rsExSheetWithErr= 'Ошибки на листе ''%s''';
  rsExBookNotErr  = 'Книга не имеет ошибок';
  rsExGetSheetData= 'Извлечение данных с листа: ''%s''';
  rsExEmptySubject= 'Пустая дисциплина!';
  rsExErrSbjIndex = 'Не указан индекс для дисциплины ''%s''';
  rsExErrSbjKaf   = 'Не указана кафедра для дисциплины ''%s''';
  rsExErrGrpPrefix= 'Название группы (%s) не имеет префикса';
  rsExErrGrpToCnt = 'Не соответствие числа групп числу сведений о кол-ве студентов';
  rsExErrNoSem    = 'Не указан семестр обучения';
  rsExErrNoGrpKaf = 'Не указана кафедра группы';
  rsExUserAbort   = 'Процесс прерван пользователем!';
  rsExErrGetSheet = 'Ошибка при извлечении данных с листа ''%s''';
  rsExErrGetBook  = 'Ошибка при извлечении данных из книги ''%s''';
  rsExBookComplete= 'Книга: ''%s''. Данные успешно извлечены';

  // Log messages
  rsLogCheckData  = 'Проверка данных';
  rsLogCheckSuccess='Данные доступны для импорта';
  rsLogCheckFault = 'Данные на прошли проверку';
  rsLogImportData = 'Импорт данных';
  rsLogUnknownSbj = 'Неизвестная дисциплина ''%s''';
  rsLogUnknownKaf = 'Неизвестная кафедра ''%s''';
  rsLogInvalidYear= 'Учебный год ''%s'' неправильно оформлен';
  rsLogExistsGrp  = 'Группа ''%s'' уже существует в БД';
  rsLogImportGrp  = 'Импорт группы ''%s'' ...';
  rsLogImportWP   = 'Импорт рабочего плана группы ''%s'' ...';
  rsLogErrImportSbj='Ошибка при добавлении дисциплины ''%s''';
  rsLogErrImportLd= 'Ошибка при добавлении ауд. нагрузки';
  rsLogImportSuccess = 'Импорт данных успешно произведен';
  rsLogImportFault= 'Импорт не выполнен. Прозведен откат всех действий';

function GetPeriodTitle(Sem,PSem: BYTE; Year: WORD): string;

implementation

uses
  SysUtils;

// возвращает строку периода (семестр,п/семестр,год)
function GetPeriodTitle(Sem,PSem: BYTE; Year: WORD): string;
begin
  Result:=Format(rsPeriodTitle,[csSemester[Sem],PSem,Year,Year+1]);
end;

end.
