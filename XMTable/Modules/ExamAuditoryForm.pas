{
  Модуль просмотра занятости аудиторий
  v0.0.1  (15/12/06)
  (C) Leonid Riskov, 2006
}
unit ExamAuditoryForm;

// TODO: экспорт занятости

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Modules, DB, ADODB, Grids, DBGrids, ToolWin, ComCtrls, StdCtrls,
  SExams;

type
  TfrmExamAuditory = class(TModuleForm)
    ToolBar: TToolBar;
    DataSource: TDataSource;
    DBGrid: TDBGrid;
    DataSet: TADODataSet;
    btnExport: TToolButton;
    btnUpdate: TToolButton;
    lblKafedra: TLabel;
    cbKafedra: TComboBox;
    SaveDialog: TSaveDialog;
    TabControl: TTabControl;
    procedure FormCreate(Sender: TObject);
    procedure ComboDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure ComboChange(Sender: TObject);
    procedure ButtonsClick(Sender: TObject);
    procedure TabControlChange(Sender: TObject);
  private
    { Private declarations }
    FXMType: TXMType;
    FColorTID: Variant;
    FColor: TColor;

    procedure SetType(Value: TXMType);
    function Get_KID: int64;
    function Get_kName: string;


  protected
    function GetModuleName: string; override;
    procedure ModuleHandler(var Msg: TMessage); override;
    function GetHelpTopic: string; override;

  public
    { Public declarations }

    procedure UpdateModule; override;

  end;

implementation

{$R *.dfm}

uses
  STypes, SDBUtils, SUtils,
  ExamModule, ExcelReport;

const
  COLOR1 = clWindow;
  COLOR2 = clRed;// $00F7F7F7;

{ TfrmExamKafedra }

procedure TfrmExamAuditory.FormCreate(Sender: TObject);
begin
  FXMType:=xmtExam;
  FColorTID:=Unassigned;
  FColor:=COLOR1;

  if dmExam.GetPerformKaf(cbKafedra.Items) then
  begin
    cbKafedra.Items.Insert(0,'0=Факультет');
    cbKafedra.ItemIndex:=0;
  end;
end;

function TfrmExamAuditory.GetHelpTopic: string;
begin
  Result:='';
end;

function TfrmExamAuditory.GetModuleName: string;
begin
  Result:='Занятость аудиторий';
end;

function TfrmExamAuditory.Get_KID: int64;
begin
  if cbKafedra.ItemIndex>=0 then
    Result:=GetID(cbKafedra.Items[cbKafedra.ItemIndex])
  else Result:=0;
end;

function TfrmExamAuditory.Get_kName: string;
begin
  if cbKafedra.ItemIndex>=0 then
    Result:=GetValue(cbKafedra.Items[cbKafedra.ItemIndex])
  else Result:='';
end;

procedure TfrmExamAuditory.ModuleHandler(var Msg: TMessage);
begin
  case Msg.Msg of
    SM_CHANGETIME:
      if (TSMChangeTime(Msg).Flags and CT_PSEM)<>CT_PSEM then
      begin
        UpdateModule;
        TSMChangeTime(Msg).Result:=MRES_UPDATE;
      end;

  end;  // case
end;

procedure TfrmExamAuditory.UpdateModule;
begin
  DataSet.DisableControls;
  try
    if GetRecordset(dmExam.xm_Get_a(Get_KID), DataSet) then
    begin
      DataSet.Filtered:=false;
      DataSet.Filter:=Format('xmtype=%d',[integer(FXMTYpe)]);
      DataSet.Filtered:=true;
      DataSet.Sort:='aName ASC, xmtime ASC';
    end;
  finally
    DataSet.EnableControls;
  end;
end;

procedure TfrmExamAuditory.ComboDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  FCanvas: TCanvas;
  s: string;
begin
  if Control is TComboBox then
  begin
    FCanvas:=(Control as TComboBox).Canvas;
    TControlCanvas(FCanvas).UpdateTextFlags;
    s:=(Control as TComboBox).Items[Index];
    if not bDebugMode then s:=GetValue(s);
//{$IF RTLVersion>=15.0}
//    s:=(Control as TComboBox).Items.ValueFromIndex[Index];
//{$ELSE}
//    s:=GetValue((Control as TComboBox).Items[Index]);
//{$IFEND}

    FCanvas.FillRect(Rect);
    FCanvas.TextOut(Rect.Left + 2, Rect.Top, s);
  end;
end;

procedure TfrmExamAuditory.ComboChange(Sender: TObject);
begin
  UpdateModule;
end;

procedure TfrmExamAuditory.ButtonsClick(Sender: TObject);

  procedure DoExport;
  begin
    if DataSet.RecordCount>0 then
    begin
      if FXMType=xmtExam then
        SaveDialog.FileName:=SUtils.FixFileName(Get_kName)+' (экзамены)'
      else
        SaveDialog.FileName:=SUtils.FixFileName(Get_kName)+' (консультации)';
        
      if SaveDialog.Execute then
        ExcelReport.ExportExamAuditory(dmExam.Year, dmExam.Sem, Get_kName,
            dmExam.Period, FXMType, DataSet,
            SaveDialog.FileName,'xmauditory.xlt');
    end;
  end;  // DoExport

begin
  case (Sender as TToolButton).Tag of

    1:  // export
      DoExport;

    2:  // update
      UpdateModule;

  end;
end;

procedure TfrmExamAuditory.SetType(Value: TXMType);
begin
  if FXMType<>Value then
  begin
    FXMType:=Value;
    UpdateModule;
  end;
end;

procedure TfrmExamAuditory.TabControlChange(Sender: TObject);
begin
  SetType(TXMType(TTabControl(Sender).TabIndex));
end;

end.
