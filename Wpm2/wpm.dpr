program wpm;

uses
  Forms,
  BaseModule in '..\Common\DModule\BaseModule.pas' {BaseDataModule: TDataModule},
  ClientModule in '..\Common\DModule\ClientModule.pas' {ClientDataModule: TDataModule},
  WorkModule in 'WorkModule.pas' {dmWork: TDataModule},
  MainForm in 'MainForm.pas' {frmMain},
  BrowseForm in 'BrowseForm.pas' {frmBrowser},
  ChildForm in '..\Common\Unit\ChildForm.pas',
  SConsts in '..\Common\Unit\SConsts.pas',
  Modules in '..\Common\Unit\Modules.pas',
  GroupForm in 'Modules\GroupForm.pas' {frmGroups},
  WorkplanForm in 'Modules\WorkplanForm.pas' {frmWorkplan},
  SUtils in '..\Common\Unit\SUtils.pas',
  SDBUtils in '..\Common\Unit\SDBUtils.pas',
  ModelData in '..\Common\Unit\ModelData.pas',
  DBData in '..\Common\Unit\DBData.pas',
  WorkplanSource in '..\Common\Unit\WorkplanSource.pas',
  ConnectEdit in '..\Common\Dialogs\ConnectEdit.pas' {frmConEdit},
  StringListDlg in '..\Common\Dialogs\StringListDlg.pas' {frmStringListDlg},
  SubjectListDlg in '..\Common\Dialogs\SubjectListDlg.pas' {frmSubjectListDlg},
  CopyObjectDlg in '..\Common\Dialogs\CopyObjectDlg.pas' {frmCopyDlg},
  SStrings in '..\Common\Unit\SStrings.pas',
  GroupListDlg in '..\Common\Dialogs\GroupListDlg.pas' {frmGroupListDlg},
  WOptions in 'WOptions.pas',
  CustomOptions in '..\Common\Unit\CustomOptions.pas',
  SCategory in '..\Common\Unit\SCategory.pas',
  STypes in '..\Common\Unit\STypes.pas',
  SHelp in '..\Common\Unit\SHelp.pas';

{$R *.res}
{$R res\pictures.res}

begin
  Application.Initialize;
  Application.Title := 'Рабочий план';
  Application.CreateForm(TdmWork, dmWork);
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
