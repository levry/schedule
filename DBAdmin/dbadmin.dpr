program dbadmin;

uses
  Forms,
  MainForm in 'MainForm.pas' {frmMain},
  AdminModule in 'AdminModule.pas' {dmAdmin: TDataModule},
  SConsts in '..\Common\Unit\SConsts.pas',
  ConnectEdit in '..\Common\Dialogs\ConnectEdit.pas' {frmConEdit},
  CustomOptions in '..\Common\Unit\CustomOptions.pas',
  Modules in '..\Common\Unit\Modules.pas',
  SStrings in '..\Common\Unit\SStrings.pas',
  SUtils in '..\Common\Unit\SUtils.pas',
  SHelp in '..\Common\Unit\SHelp.pas',
  StringListDlg in '..\Common\Dialogs\StringListDlg.pas' {frmStringListDlg},
  SCategory in '..\Common\Unit\SCategory.pas',
  STypes in '..\Common\Unit\STypes.pas',
  CopyObjectDlg in '..\Common\Dialogs\CopyObjectDlg.pas' {frmCopyDlg},
  PostForm in 'Modules\PostForm.pas' {frmPosts},
  SubjectForm in 'Modules\SubjectForm.pas' {frmSubjects},
  FacultyForm in 'Modules\FacultyForm.pas' {frmFaculty},
  ImportSchema in 'Dialogs\ImportSchema.pas' {frmImportSchemaDlg},
  KafedraForm in 'Modules\KafedraForm.pas' {frmKafedrs},
  YearsForm in 'Modules\YearsForm.pas' {frmYears},
  AOptions in 'AOptions.pas',
  PeriodsForm in 'PeriodsForm.pas' {frmPeriods: TFrame},
  SubjectListDlg in '..\Common\Dialogs\SubjectListDlg.pas' {frmSubjectListDlg},
  BaseModule in '..\Common\DModule\BaseModule.pas' {BaseDataModule: TDataModule},
  SDBUtils in '..\Common\Unit\SDBUtils.pas',
  RecordsetDlg in '..\Common\Dialogs\RecordsetDlg.pas' {frmRecordsetDlg};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TdmAdmin, dmAdmin);
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
