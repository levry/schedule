program Shedule;

uses
  Forms,
  Modules in '..\Common\Unit\Modules.pas',
  MainForm in 'MainForm.pas' {frmMain},
  ClientModule in '..\Common\DModule\ClientModule.pas' {ClientDataModule: TDataModule},
  TimeModule in 'TimeModule.pas' {dmMain: TDataModule},
  TeachDlg in 'TeachDlg.pas' {frmTeachDlg},
  ExportDeclare in 'Reports\ExportDeclare.pas' {frmExportDeclareDlg},
  PreferDlg in 'PreferDlg.pas' {frmPreferDlg},
  AuditoryForm in 'Modules\AuditoryForm.pas' {frmAuditory},
  TeacherForm in 'Modules\TeacherForm.pas' {frmTeachers},
  DeclareForm in 'Modules\DeclareForm.pas' {frmDeclare},
  ScheduleForm in 'Modules\ScheduleForm.pas' {frmSchedule},
  StreamsForm in 'Modules\StreamsForm.pas' {frmStreams},
  WorkViewForm in 'Modules\WorkViewForm.pas' {frmWorkView},
  ResourceTimeForm in 'Modules\ResourceTimeForm.pas' {frmResTime},
  ResourceLoadForm in 'Modules\ResourceLoadForm.pas' {frmResLoad},
  LoadDlg in 'Dlgs\LoadDlg.pas' {frmLoadDlg},
  PairEditDlg in 'PairEditDlg.pas' {frmPairEditDlg},
  LsnsTypeDlg in 'Dlgs\LsnsTypeDlg.pas' {frmLsnsTypeDlg},
  EditLsnsFrame in 'Frames\EditLsnsFrame.pas' {fmEditLsns: TFrame},
  SClasses in 'SClasses.pas',
  SIntf in 'SIntf.pas',
  SConsts in '..\Common\Unit\SConsts.pas',
  CustomOptions in '..\Common\Unit\CustomOptions.pas',
  SUtils in '..\Common\Unit\SUtils.pas',
  SDBUtils in '..\Common\Unit\SDBUtils.pas',
  BrowserForm in 'BrowserForm.pas' {fmBrowser},
  StringListDlg in '..\Common\Dialogs\StringListDlg.pas' {frmStringList},
  ConnectEdit in '..\Common\Dialogs\ConnectEdit.pas' {frmConEdit},
  SStrings in '..\Common\Unit\SStrings.pas',
  GroupsDlg in 'Dlgs\GroupsDlg.pas' {frmGroupsDlg},
  DeclareListDlg in 'Dlgs\DeclareListDlg.pas' {frmDeclareListDlg},
  LsnsListDlg in 'Dlgs\LsnsListDlg.pas' {frmLsnsListDlg},
  SCategory in '..\Common\Unit\SCategory.pas',
  DOptions in 'DOptions.pas',
  SubjectListDlg in '..\Common\Dialogs\SubjectListDlg.pas' {frmSubjectListDlg},
  GroupListDlg in '..\Common\Dialogs\GroupListDlg.pas' {frmGroupListDlg},
  DataListDlg in '..\Common\Dialogs\DataListDlg.pas' {frmDataListDlg},
  BaseModule in '..\Common\DModule\BaseModule.pas' {BaseDataModule: TDataModule},
  STypes in '..\Common\Unit\STypes.pas',
  ExportResTime in 'Reports\ExportResTime.pas',
  ExportTablePage in 'Frames\ExportTablePage.pas' {frmExportTablePage: TFrame},
  ExportSourcePage in 'Frames\ExportSourcePage.pas' {frmExportSourcePage: TFrame},
  ExecWorkplanDlg in 'Dlgs\ExecWorkplanDlg.pas' {frmExecWorkplanDlg},
  ExportTimeTable in 'Reports\ExportTimeTable.pas',
  PageDlg in '..\Common\Dialogs\PageDlg.pas' {frmPageDlg},
  SHelp in '..\Common\Unit\SHelp.pas',
  XReport in '..\Common\Unit\XReport.pas';

{$R *.res}
{$R res\pictures.res}

begin
  Application.Initialize;
  Application.Title := 'Расписание';
  Application.CreateForm(TdmMain, dmMain);
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run
end.
