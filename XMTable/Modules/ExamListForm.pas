{
  Модуль списка экзаменов факультета
  v0.0.2  (27/09/06)
  (C) Leonid Riskov, 2006
}

// TODO: Выделить цветом строки грида отдельно каждый день
// TODO: Фильтр для дисциплины

unit ExamListForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,
  Modules, DB, Grids, DBGrids, ADODB, ComCtrls, ToolWin, StdCtrls;

type
  TfrmExamList = class(TModuleForm)
    ExamDataSet: TADODataSet;
    DBGrid: TDBGrid;
    DataSource: TDataSource;
    ToolBar: TToolBar;
    btnExport: TToolButton;
    btnUpdate: TToolButton;
    SaveDialog: TSaveDialog;
    procedure ButtonsClick(Sender: TObject);
    
  private
    { Private declarations }

  protected
    function GetModuleName: string; override;
    procedure ModuleHandler(var Msg: TMessage); override;
    function GetHelpTopic: string; override;

  public
    { Public declarations }
    procedure UpdateModule; override;

  end;

implementation

uses
  SUtils, SStrings, STypes, SDBUtils, SHelp,
  ExamModule, ExcelReport;

{$R *.dfm}

{ TfrmExamFaculty }

function TfrmExamList.GetModuleName: string;
begin
  Result:='Экзамены факультета';
end;

procedure TfrmExamList.ModuleHandler(var Msg: TMessage);
begin
  case Msg.Msg of
    SM_CHANGETIME:
      if (TSMChangeTime(Msg).Flags and CT_YEAR)=CT_YEAR then
        TSMChangeTime(Msg).Result:=MRES_DESTROY
      else
        if (TSMChangeTime(Msg).Flags and CT_SEM)=CT_SEM then
        begin
          UpdateModule;
          TSMChangeTime(Msg).Result:=MRES_UPDATE;
        end;

  end;  // case
end;

function TfrmExamList.GetHelpTopic: string;
begin
  Result:=HELP_EXAMTABLE_EXAMLIST;
end;

procedure TfrmExamList.UpdateModule;
begin
  ExamDataSet.DisableControls;
  try
    if GetRecordset(dmExam.xm_GetFcl(dmExam.FacultyID,0), ExamDataSet) then
      ExamDataSet.Sort:='xmtime ASC, grName ASC';
  finally
    ExamDataSet.EnableControls;
  end;
end;

procedure TfrmExamList.ButtonsClick(Sender: TObject);

  // экспорт DataSet (экзамены факультета)
  procedure DoExportExamList;
  begin
    if ExamDataSet.RecordCount>0 then
    begin
      SaveDialog.FileName:=SUtils.FixFileName(dmExam.FacultyName);
      if SaveDialog.Execute then
        ExcelReport.ExportExamList(dmExam.Year, dmExam.Sem, ExamDataSet,
            SaveDialog.FileName,'xmfaculty.xlt');
    end;
  end;  // procedure DoExportExamList

begin
  case (Sender as TToolButton).Tag of

    1:  // export exam list
      DoExportExamList;

    2:  // update module
      UpdateModule;

  end;  // case(Tag)
end;

end.
