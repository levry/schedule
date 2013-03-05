{
  Модуль просмотра экзаменов кафедры
  v0.0.1  (28/11/06)
  (C) Leonid Riskov, 2006
}
unit ExamKafForm;

// TODO: Выделить отдель. цветами каждого преподавателя

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Modules, DB, ADODB, Grids, DBGrids, ToolWin, ComCtrls, StdCtrls,
  SExams;

type
  TfrmExamKafedra = class(TModuleForm)
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
    procedure DBGridDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
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
  clSecond = clSkyBlue;

{ TfrmExamKafedra }

procedure TfrmExamKafedra.FormCreate(Sender: TObject);
begin
  FXMType:=xmtExam;
  FColorTID:=Unassigned;
  FColor:=DBGrid.Color;

  if dmExam.GetPerformKaf(cbKafedra.Items) then
    cbKafedra.ItemIndex:=0;
end;

function TfrmExamKafedra.GetHelpTopic: string;
begin
  Result:='';
end;

function TfrmExamKafedra.GetModuleName: string;
begin
  Result:='Экзамены кафедры';
end;

function TfrmExamKafedra.Get_KID: int64;
begin
  if cbKafedra.ItemIndex>=0 then
    Result:=GetID(cbKafedra.Items[cbKafedra.ItemIndex])
  else Result:=0;
end;

function TfrmExamKafedra.Get_kName: string;
begin
  if cbKafedra.ItemIndex>=0 then
    Result:=GetValue(cbKafedra.Items[cbKafedra.ItemIndex])
  else Result:='';
end;

procedure TfrmExamKafedra.ModuleHandler(var Msg: TMessage);
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

procedure TfrmExamKafedra.UpdateModule;
begin
  DataSet.DisableControls;
  try
    if GetRecordset(dmExam.xm_Get_k(Get_KID), DataSet) then
    begin
      DataSet.Filtered:=false;
      DataSet.Filter:=Format('xmtype=%d',[integer(FXMTYpe)]);
      DataSet.Filtered:=true;
      DataSet.Sort:='Initials ASC, grName ASC, sbName ASC, xmtype ASC';
    end;
  finally
    DataSet.EnableControls;
  end;
end;

procedure TfrmExamKafedra.ComboDrawItem(Control: TWinControl;
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

procedure TfrmExamKafedra.ComboChange(Sender: TObject);
begin
  UpdateModule;
end;

procedure TfrmExamKafedra.ButtonsClick(Sender: TObject);

  procedure DoExport;
  begin
    if DataSet.RecordCount>0 then
    begin
      SaveDialog.FileName:=SUtils.FixFileName(Get_kName);
      if SaveDialog.Execute then
        ExcelReport.ExportExamKafedra(dmExam.Year, dmExam.Sem, Get_kName,
            DataSet, SaveDialog.FileName,'xmkafedra.xlt');
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

procedure TfrmExamKafedra.SetType(Value: TXMType);
begin
  if FXMType<>Value then
  begin
    FXMType:=Value;
    UpdateModule;
  end;
end;

procedure TfrmExamKafedra.TabControlChange(Sender: TObject);
begin
  SetType(TXMType(TTabControl(Sender).TabIndex));
end;

procedure TfrmExamKafedra.DBGridDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn;
  State: TGridDrawState);
var
  Value: Variant;
  BrushColor, FontColor: TColor;
begin

//  if gdSelected in State then
//  begin
//    BrushColor:=clHighLight;
//    FontColor:=clHighLightText;
//  end
//  else
  begin
    Value:=TDBGrid(Sender).DataSource.DataSet.FieldByName('tid').Value;

    if FColorTID<>Value then
    begin
      FColorTID:=Value;
      if FColor<>clSecond then FColor:=clSecond
        else FColor:=TDBGrid(Sender).Color;
    end;

    BrushColor:=FColor;
    FontColor:=TDBGrid(Sender).Font.Color;
  end;

  TDBGrid(Sender).Canvas.Brush.Color:=BrushColor;
  TDBGrid(Sender).Canvas.Font.Color:=FontColor;
  TDBGrid(Sender).DefaultDrawColumnCell(Rect,DataCol,Column,State);
end;

end.
