{
  Диалог возмож. экз/конс
  v0.0.1  (08.05.06)
  (C) Leonid Riskov, 2006
}
unit ExamListDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, Tabs, VirtualTrees, ToolWin, ActnList, ImgList, Contnrs,
  SExams;

type
  TfrmExamListDlg = class(TForm)
    ToolBar: TToolBar;
    vstGrid: TVirtualStringTree;
    TabSet: TTabSet;
    btnSelect: TToolButton;
    btnCancel: TToolButton;
    ToolButton3: TToolButton;
    btnUpdate: TToolButton;
    TimePicker: TDateTimePicker;
    ToolButton1: TToolButton;
    ActionList: TActionList;
    ImageList: TImageList;
    actSelect: TAction;
    actCancel: TAction;
    actUpdate: TAction;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ActionsExecute(Sender: TObject);
    procedure ActionsUpdate(Sender: TObject);
    procedure vstGridDblClick(Sender: TObject);
    procedure vstGridGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: WideString);
    procedure vstGridGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure vstGridColumnClick(Sender: TBaseVirtualTree;
      Column: TColumnIndex; Shift: TShiftState);
    procedure vstGridBeforeItemErase(Sender: TBaseVirtualTree;
      TargetCanvas: TCanvas; Node: PVirtualNode; ItemRect: TRect;
      var ItemColor: TColor; var EraseAction: TItemEraseAction);
    procedure TabSetChange(Sender: TObject; NewTab: Integer;
      var AllowChange: Boolean);
    procedure TimePickerChange(Sender: TObject);
  private
    { Private declarations }
    FList: TObjectList;       // список экз/конс
    FTime: TDateTime;         // дата время
    FXMType: TXMType;         // тип
    fgrid: int64;             // grid


  private
    procedure UpdateList;     // загрузка списка
    procedure InitNodes;      // инициализация узлов
    function GetExam(VNode: PVirtualNode): TAvailExam;
    function GetResultExam(var AExam: TBaseExam): boolean;
    procedure SetTime(Value: TDateTime);
    procedure SetXMType(Value: TXMType);

  public
    { Public declarations }
  end;

function ShowExamListDlg(ATime: TDateTime; AGroup: TXMGroup;
    var AExam: TBaseExam): boolean;

implementation

uses
  ADODb, DateUtils,
  SUtils, ExamModule, SStrings;

{$R *.dfm}

type
  TNodeData = record
    index: integer;
  end;
  PNodeData = ^TNodeData;

const
  START_HOUR = 9;

// вывод диалога выбора экз/конс
function ShowExamListDlg(ATime: TDateTime; AGroup: TXMGroup;
    var AExam: TBaseExam): boolean;
var
  frmDlg: TfrmExamListDlg;
  s: string;
begin
  Assert(Assigned(AGroup),
    '51D337C4-22F1-45AA-8A52-AB627657969D'#13'ShowExamListDlg: AGroup is nil'#13);
  Assert(Assigned(AExam),
    '154399FB-9581-498E-BAD4-451EBC31E4E2'#13'ShowExamListDlg: AExam is nil'#13);

  Result:=false;

  frmDlg:=TfrmExamListDlg.Create(Application);
  try
    with frmDlg do
    begin
      fgrid:=AGroup.grid;
      FXMType:=xmtExam;
      FTime:=RecodeHour(ATime, START_HOUR);

      DateTimeToString(s,'DD MMM YYYY (DDDD)',FTime);
      Caption:=Format('%s: %s [%s]', ['Доступные события', AGroup.grName, s]);
      Timepicker.DateTime:=FTime;

      UpdateList;

      if ShowModal=mrOk then Result:=GetResultExam(AExam);
    end;
  finally
    frmDlg.Free;
    frmDlg:=nil;
  end;
end;

function AddTreeNode(VTree: TVirtualStringTree; Data: TNodeData;
    VNode: PVirtualNode=nil): PVirtualNode;
var
  nd: PNodeData;
begin
  nd:=nil;
  Result:=VTree.AddChild(VNode);
  nd:=VTree.GetNodeData(Result);
  if Assigned(nd) then
    Move(Data, nd^, sizeof(TNodeData));
end;


{ TfrmExamListDlg }

procedure TfrmExamListDlg.FormCreate(Sender: TObject);
begin
  fgrid:=0;
  FList:=TObjectList.Create;
  vstGrid.NodeDataSize:=sizeof(TNodeData);
  
  ImageList.ResourceLoad(rtBitmap, 'TEXAM', clFuchsia);
end;

procedure TfrmExamListDlg.FormDestroy(Sender: TObject);
begin
  FList.Free;
  FList:=nil;
end;

// изм-ние времени
procedure TfrmExamListDlg.SetTime(Value: TDateTime);
begin
  if FTime<>Value then
  begin
    FTime:=Value;
    UpdateList;
  end;
end;

// изм-ние типа экз/конс
procedure TfrmExamListDlg.SetXMType(Value: TXMType);
begin
  if Value<>FXMType then
  begin
    FXMType:=Value;
    UpdateList;
  end;
end;

function TfrmExamListDlg.GetExam(VNode: PVirtualNode): TAvailExam;
var
  pdata: PNodeData;
begin
  Result:=nil;
  if Assigned(VNode) then
  begin
    pdata:=vstGrid.GetNodeData(VNode);
    if Assigned(pdata) then Result:=(FList[pdata.index] as TAvailExam);
  end;
end;

// извлекает выбран. экз/конс
function TfrmExamListDlg.GetResultExam(var AExam: TBaseExam): boolean;
var
  exam: TAvailExam;
begin
  Result:=false;

  exam:=GetExam(vstGrid.GetFirstSelected);
  if Assigned(exam) then
  begin
    Result:=exam.Check;
    if Result then AExam.Assign(exam);
  end;
end;

// инициализация узлов VirtualStringTree
procedure TfrmExamListDlg.InitNodes;
var
  i: integer;
  ndata: TNodeData;
  pnode: PVirtualNode;
  exam: TAvailExam;
begin
  pnode:=nil;

  vstGrid.BeginUpdate;
  try
    vstGrid.Clear;
    for i:=0 to FList.Count-1 do
    begin
      exam:=TAvailExam(FList[i]);
      ndata.index:=i;
      AddTreeNode(vstGrid,ndata,nil);
    end;
  finally
    vstGrid.EndUpdate;
  end;
end;

// загрузка списка возмож. экз/конс
procedure TfrmExamListDlg.UpdateList;
var
  rs: _Recordset;
begin
  FList.Clear;

  rs:=dmExam.xm_GetAvail_grp(fgrid,byte(FXMType),FTime);
  if Assigned(rs) then
  try
    InitAvailList(FXMType,FTime,FList,rs);
    InitNodes;
  finally
    rs.Close;
    rs:=nil;
  end;
end;

procedure TfrmExamListDlg.ActionsExecute(Sender: TObject);

  procedure SelectExam;
  var
    exam: TAvailExam;
  begin
    exam:=GetExam(vstGrid.GetFirstSelected);
    if Assigned(exam) then
      if exam.Check then ModalResult:=mrOk;
  end;  // procedure SelectLsns

begin
  case (Sender as TAction).Tag of
    -1: // update
      UpdateList;

    1:  // select
      SelectExam;

    2:  // cancel
      ModalResult:=mrCancel;

    else raise Exception.CreateFmt('Unknown action (Tag=%d)', [TAction(Sender).Tag]);
  end;  // case
end;

procedure TfrmExamListDlg.ActionsUpdate(Sender: TObject);

  function SelectedExam: boolean;
  var
    exam: TAvailExam;
  begin
    Result:=false;
    exam:=GetExam(vstGrid.GetFirstSelected);
    if Assigned(exam) then Result:=exam.Check;
  end;  // function SelectedExam

begin
  case (Sender as TAction).Tag of

    1:  // select exam
       TAction(Sender).Enabled:=SelectedExam;

    else raise Exception.CreateFmt('Unknown action (Tag=%d)', [TAction(Sender).Tag]);
  end;  // case
end;

procedure TfrmExamListDlg.vstGridDblClick(Sender: TObject);
var
  exam: TAvailExam;
begin
  if Sender is TBaseVirtualTree then
  begin
    exam:=GetExam(TBaseVirtualTree(Sender).GetFirstSelected);
    if Assigned(exam) then
      if exam.Check then ModalResult:=mrOk
  end;  // if Sender
end;

procedure TfrmExamListDlg.vstGridGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: WideString);
var
  exam: TAvailExam;
begin
  exam:=GetExam(Node);
  if Assigned(exam) then
    case Column of
      4:  CellText:=exam.subject;
      5:  CellText:=exam.teacher;
      else CellText:='';
    end;  // case(Column)
end;

procedure TfrmExamListDlg.vstGridGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var
  exam: TAvailExam;
begin
  exam:=GetExam(Node);
  if Assigned(exam) then
  begin
    case Column of

      0: // exists?
        if exam.exists then ImageIndex:=7;

      1: // teacher?
        if not exam.tfree then ImageIndex:=8;

      2: // order?
        if not exam.order then ImageIndex:=9;

      3: // half group
        begin
          if exam.Check then
            if not exam.CheckedSub then
            begin
              if exam.subgrp then ImageIndex:=13 else ImageIndex:=12;
            end
            else
              if exam.subgrp then ImageIndex:=11 else ImageIndex:=10;
        end;

      else ImageIndex:=-1;
    end;  // case(Column)
  end
  else ImageIndex:=-1;
end;

procedure TfrmExamListDlg.vstGridColumnClick(Sender: TBaseVirtualTree;
  Column: TColumnIndex; Shift: TShiftState);
var
  exam: TAvailExam;
begin
  if Column=3 then
  begin
    exam:=GetExam(Sender.GetFirstSelected);
    if Assigned(exam) then
      if exam.Check and exam.CheckedSub then
      begin
        exam.subgrp:=not exam.subgrp;
        Sender.RepaintNode(Sender.GetFirstSelected);
      end;
  end;
end;

procedure TfrmExamListDlg.vstGridBeforeItemErase(Sender: TBaseVirtualTree;
  TargetCanvas: TCanvas; Node: PVirtualNode; ItemRect: TRect;
  var ItemColor: TColor; var EraseAction: TItemEraseAction);
var
  exam: TAvailExam;
begin
  exam:=GetExam(Node);
  if Assigned(exam) then
  begin
    if exam.Check then ItemColor:=TVirtualStringTree(Sender).Color
      else ItemColor:=$F0F0F0;
    EraseAction:=eaColor;
  end;
end;

procedure TfrmExamListDlg.TabSetChange(Sender: TObject; NewTab: Integer;
  var AllowChange: Boolean);
begin
  AllowChange:=true;
  SetXMType(TXMType(NewTab));
end;

procedure TfrmExamListDlg.TimePickerChange(Sender: TObject);
begin
  SetTime(TDateTimePicker(Sender).DateTime);
end;

end.
