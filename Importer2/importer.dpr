program importer;

uses
  Forms,
  STypes in '..\Common\Unit\STypes.pas',
  SStrings in '..\Common\Unit\SStrings.pas',
  SConsts in '..\Common\Unit\SConsts.pas',
  SUtils in '..\Common\Unit\SUtils.pas',
  MainForm in 'MainForm.pas' {frmMain},
  ImportModule in 'ImportModule.pas' {dmImport: TDataModule},
  SCategory in '..\Common\Unit\SCategory.pas',
  CustomOptions in '..\Common\Unit\CustomOptions.pas',
  WIOptions in 'WIOptions.pas',
  ConnectEdit in '..\Common\Dialogs\ConnectEdit.pas' {frmConEdit},
  LoadExcelDataDlg in 'Dialogs\LoadExcelDataDlg.pas' {LoadExcelDlg},
  LoadDlg in 'Dialogs\LoadDlg.pas' {frmLoadDlg},
  SDBUtils in '..\Common\Unit\SDBUtils.pas',
  StringListDlg in '..\Common\Dialogs\StringListDlg.pas' {frmStringListDlg},
  SubjectListDlg in '..\Common\Dialogs\SubjectListDlg.pas' {frmSubjectListDlg},
  SHelp in '..\Common\Unit\SHelp.pas',
  BaseModule in '..\Common\DModule\BaseModule.pas' {BaseDataModule: TDataModule},
  SLogger in '..\Common\Unit\SLogger.pas',
  XLSchema in 'import\XLSchema.pas',
  DataSchemaDlg in 'Dialogs\DataSchemaDlg.pas' {frmDataSchemaDlg};

{$R *.res}
{$R res\pictures.res}

begin
  Application.Initialize;
  Application.CreateForm(TdmImport, dmImport);
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
