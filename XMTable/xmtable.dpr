{
  Проект "Расписание экзаменов"
}
program xmtable;

uses
  Forms,
  MainForm in 'MainForm.pas' {frmMain},
  BaseModule in '..\Common\DModule\BaseModule.pas' {BaseDataModule: TDataModule},
  ClientModule in '..\Common\DModule\ClientModule.pas' {ClientDataModule: TDataModule},
  ExamModule in 'ExamModule.pas' {dmExam: TDataModule},
  BrowseForm in 'BrowseForm.pas' {frmBrowser},
  CustomOptions in '..\Common\Unit\CustomOptions.pas',
  Modules in '..\Common\Unit\Modules.pas',
  SCategory in '..\Common\Unit\SCategory.pas',
  SConsts in '..\Common\Unit\SConsts.pas',
  SStrings in '..\Common\Unit\SStrings.pas',
  STypes in '..\Common\Unit\STypes.pas',
  SUtils in '..\Common\Unit\SUtils.pas',
  SDBUtils in '..\Common\Unit\SDBUtils.pas',
  ChildForm in '..\Common\Unit\ChildForm.pas',
  StringListDlg in '..\Common\Dialogs\StringListDlg.pas' {frmStringListDlg},
  ConnectEdit in '..\Common\Dialogs\ConnectEdit.pas' {frmConEdit},
  XMOptions in 'XMOptions.pas',
  ExamForm in 'Modules\ExamForm.pas' {frmExamTable},
  SExams in 'SExams.pas',
  GroupsDlg in 'Dlgs\GroupsDlg.pas' {frmGroupsDlg},
  ExamEditForm in 'ExamEditForm.pas' {frmExamEdit},
  DataListDlg in '..\Common\Dialogs\DataListDlg.pas' {frmDataListDlg},
  SForms in '..\Common\Unit\SForms.pas',
  ExamListDlg in 'Dlgs\ExamListDlg.pas' {frmExamListDlg},
  ExportExamTableDlg in 'Dlgs\ExportExamTableDlg.pas' {frmExportExamTableDlg},
  ExamListForm in 'Modules\ExamListForm.pas' {frmExamList},
  ExcelReport in 'ExcelReport.pas',
  SHelp in '..\Common\Unit\SHelp.pas',
  ExamKafForm in 'Modules\ExamKafForm.pas' {frmExamKafedra},
  XReport in '..\Common\Unit\XReport.pas',
  ExamAuditoryForm in 'Modules\ExamAuditoryForm.pas' {frmExamAuditory};

{$R *.res}
{$R res\pictures.res}

begin
  Application.Initialize;
  Application.Title := 'Расписание экзаменов';
  Application.CreateForm(TdmExam, dmExam);
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
