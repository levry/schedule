{
  Справочная система
  v0.0.1  (29/09/06)
}
unit SHelp;

interface

const
  HELP_FILENAME = 'schedule.chm';
  HELP_WORKPLAN = 'workplan_topic.htm';
  HELP_WORKPLAN_IMPORT = 'workplan_import.htm';
  HELP_WORKPLAN_IMPORT_LOAD = 'workplan_import_load.htm';
  HELP_WORKPLAN_IMPORT_CHECKFILE = 'workplan_import_checkfile.htm';
  HELP_WORKPLAN_IMPORT_CHECK = 'workplan_import_check.htm';
  HELP_WORKPLAN_IMPORT_IMPORT = 'workplan_import_import.htm';
  HELP_WORKPLAN_TREE = 'workplan_tree.htm';
  HELP_WORKPLAN_GROUP = 'workplan_group.htm';
  HELP_WORKPLAN_WORKPLAN = 'workplan_workplan.htm';
  HELP_WORKPLAN_WORKPLAN_SUBJECT = 'workplan_workplan_subject.htm';
  HELP_WORKPLAN_WORKPLAN_LOAD = 'worklpan_workplan_load.htm';
  HELP_WORKPLAN_WORKPLAN_COPYSUBJECT = 'workplan_workplan_copysubject.htm';
  HELP_WORKPLAN_WORKPLAN_COPY = 'workplan_workplan_copy.htm';

  HELP_TIMETABLE = 'timetable_topic.htm';
  HELP_TIMETABLE_STREAMS = 'timetable_streams.htm';
  HELP_TIMETABLE_TABLE = 'timetable_table.htm';
  HELP_TIMETABLE_TEACHERTIME = 'timetable_teachertime.htm';
  HELP_TIMETABLE_AUDITORYTIME = 'timetable_auditorytime.htm';
  HELP_TIMETABLE_AUDITORYLOAD = 'timetable_auditoryload.htm';

  HELP_EXAMTABLE = 'examtable_topic.htm';
  HELP_EXAMTABLE_TABLE = 'examtable_table.htm';
  HELP_EXAMTABLE_EXAMLIST = 'examtable_examlist.htm';

procedure DisplayTopic(const Topic: string);

function HtmlHelp(hwndCaller: THandle; pszFile: PChar; uCommand: cardinal;
    dwData: longint): THandle; stdcall;

implementation

uses
  Forms, SysUtils;

const
  HH_DISPLAY_TOPIC        = $0000;

function HtmlHelp(hwndCaller: THandle; pszFile: PChar; uCommand: cardinal;
    dwData: longint): THandle; stdcall; external 'hhctrl.ocx' name 'HtmlHelpA';

procedure DisplayTopic(const Topic: string);
var
  URL: string;
begin
  if Topic = '' then URL := ''
    else if Topic[1] = '/' then URL := '::' + Topic
    else URL := '::/' + Topic;
  HtmlHelp(Application.Handle, PChar(Application.HelpFile + URL), HH_DISPLAY_TOPIC, 0);
end;

end.
