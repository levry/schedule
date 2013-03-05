{
  Диалог выбора нагрузки для занятия
  v0.0.5 (22.03.06)
}

unit LsnsListDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, VirtualTrees, ToolWin, ComCtrls, SClasses, ActnList, ADODb,
  ImgList, StdCtrls, Contnrs;

type

  TfrmLsnsListDlg = class(TForm)
    ToolBar: TToolBar;
    vstLsns: TVirtualStringTree;
    ActionList: TActionList;
    actViewLc: TAction;
    actViewPr: TAction;
    actViewLb: TAction;
    btnViewLc: TToolButton;
    btnViewPr: TToolButton;
    btnViewLb: TToolButton;
    actUpdate: TAction;
    ImageList: TImageList;
    actSelect: TAction;
    actCancel: TAction;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    btnSelect: TToolButton;
    btnCancel: TToolButton;
    btnUpdate: TToolButton;
    StatusBar: TStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure vstLsnsGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: WideString);
    procedure ActionsExecute(Sender: TObject);
    procedure ActionsUpdate(Sender: TObject);
    procedure vstLsnsGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure vstLsnsDblClick(Sender: TObject);
    procedure StatusBarResize(Sender: TObject);
    procedure vstLsnsColumnClick(Sender: TBaseVirtualTree;
      Column: TColumnIndex; Shift: TShiftState);
    procedure vstLsnsBeforeItemErase(Sender: TBaseVirtualTree;
      TargetCanvas: TCanvas; Node: PVirtualNode; ItemRect: TRect;
      var ItemColor: TColor; var EraseAction: TItemEraseAction);
  private
    { Private declarations }
    fweek: byte;
    fwday: byte;
    fnpair: byte;
    fgroup: string;           // grid=grName

    FList: TObjectList;       // список нагрузок
    FLsnsType: byte;          // тип занятий (1-lec,2-prac,3-labo)

    procedure UpdateList;
    function GetLsns(VNode: PVirtualNode): TAvailLsns;
    function GetResultLsns: TLsns;
    procedure InitNodes;
    procedure UpdateBar;
  public
    { Public declarations }
  end;

function ShowLsnsListDlg(aweek,awday,anpair: byte; agroup: string): TLsns;

implementation

uses
  TimeModule, DB, SUtils, SConsts;

{$R *.dfm}


type
  TNodeData = record
    index: integer;
  end;
  PNodeData = ^TNodeData;


function ShowLsnsListDlg(aweek,awday,anpair: byte; agroup: string): TLsns;
var
  frmDlg: TfrmLsnsListDlg;
begin
  Result:=nil;

  frmDlg:=TfrmLsnsListDlg.Create(Application);
  try
    with frmDlg do
    begin
      fweek:=aweek;
      fwday:=awday;
      fnpair:=anpair;
      fgroup:=agroup;
      Caption:='Доступные занятия - '+GetValue(fgroup);
      UpdateBar;
      UpdateList;
      if ShowModal=mrOk then Result:=GetResultLsns;
    end;  // with
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

{ TfrmLsnsListDlg }

procedure TfrmLsnsListDlg.FormCreate(Sender: TObject);
begin
  FLsnsType:=1;
  FList:=TObjectList.Create;
  vstLsns.NodeDataSize:=sizeof(TNodeData);
  ImageList.ResourceLoad(rtBitmap,'TLSNS',clFuchsia);
end;

procedure TfrmLsnsListDlg.FormDestroy(Sender: TObject);
begin
  FList.Free;
  FList:=nil;
end;

// загрузка нагрузок (занятий)
procedure TfrmLsnsListDlg.UpdateList;
var
  ds: TADODataSet;
  lsns: TAvailLsns;
begin
  if FList.Count>0 then FList.Clear;

  ds:=CreateDataSet(dmMain.sdl_GetAvail_g(fweek,fwday+1,fnpair+1,GetID(fgroup)));
  if Assigned(ds) then
  try
    ds.Sort:='type ASC, sbName ASC';
    while not ds.Eof do
    begin
      lsns:=TAvailLsns.Create;
      lsns.Assign(ds.Fields);
      FList.Add(lsns);
      ds.Next;
    end;
    InitNodes;
  finally
    ds.Close;
    ds.Free;
    ds:=nil;
  end;
end;

// возвращает возмож. занятие (PLsnsData)
function TfrmLsnsListDlg.GetLsns(VNode: PVirtualNode): TAvailLsns;
var
  pdata: PNodeData;
begin
  Result:=nil;
  if Assigned(VNode) then
  begin
    pdata:=vstLsns.GetNodeData(VNode);
    if Assigned(pdata) then Result:=(FList[pdata.index] as TAvailLsns);
  end;
end;

// возвращает занятие (TLsns)
function TfrmLsnsListDlg.GetResultLsns: TLsns;
var
  lsns: TAvailLsns;
begin
  Result:=nil;

  lsns:=GetLsns(vstLsns.GetFirstSelected);
  if Assigned(lsns) then
    if lsns.CheckLsns then
    begin
      Result:=TLsns.Create;
      Result.Assign(lsns);
    end;
end;

// инициализация узлов
procedure TfrmLsnsListDlg.InitNodes;
var
  i: integer;
  ndata: TNodeData;
  pnode: PVirtualNode;
  lsns: TAvailLsns;
begin
  pnode:=nil;

  vstLsns.BeginUpdate;
  try
    vstLsns.Clear;
    for i:=0 to FList.Count-1 do
    begin
      lsns:=(FList[i] as TAvailLsns);
      if lsns.ltype=FLsnsType then
      begin
        ndata.index:=i;
        AddTreeNode(vstLsns,ndata,nil);
      end;
    end;
  finally
    vstLsns.EndUpdate;
  end;
end;

procedure TfrmLsnsListDlg.vstLsnsGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: WideString);
var
  lsns: TAvailLsns;
  pdata: PNodeData;
begin
  pdata:=Sender.GetNodeData(Node);
  if Assigned(pdata) then
  begin
    lsns:=(FList[pdata.index] as TAvailLsns);
    if Assigned(lsns) then
      case Column of
        4:  CellText:=GetValue(lsns.subject);
        5:  CellText:=GetValue(lsns.teacher);
        6:  CellText:=Format('%d / %2.1g', [lsns.hours,lsns.ahours / 2]);
        //7:  CellText:=IntToStr(plsns.strid);
        else CellText:='';
      end;
  end;
end;

procedure TfrmLsnsListDlg.ActionsExecute(Sender: TObject);

  procedure SelectLsns;
  var
    lsns: TAvailLsns;
  begin
    lsns:=GetLsns(vstLsns.GetFirstSelected);
    if Assigned(lsns) then
      if lsns.CheckLsns then ModalResult:=mrOk;
  end;  // procedure SelectLsns

begin
  case (Sender as TAction).Tag of
    -1: // update
        UpdateList;

    1,2,3:
      if FLsnsType<>TAction(Sender).Tag then
      begin
        FLsnsType:=TAction(Sender).Tag;
        InitNodes;
      end;

    4:  // select lsns
      SelectLsns;

    5:  // cancel
      ModalResult:=mrCancel;

    else raise Exception.CreateFmt('Unknown action (Tag=%d)', [TAction(Sender).Tag]);
  end;  // case
end;

procedure TfrmLsnsListDlg.ActionsUpdate(Sender: TObject);

  function SelectedLsns: boolean;
  var
    lsns: TAvailLsns;
  begin
    Result:=false;
    lsns:=GetLsns(vstLsns.GetFirstSelected);
    if Assigned(lsns) then
      Result:=lsns.CheckLsns;
  end;  // function SelectedLsns

begin
  case (Sender as TAction).Tag of
    -1:  // update
      case FLsnsType of
        1: StatusBar.Panels[0].Text:='Лекции';
        2: StatusBar.Panels[0].Text:='Практики';
        3: StatusBar.Panels[0].Text:='Лабораторные';
      end;

    1,2,3:  // view lsns of type
      TAction(Sender).Checked:=(TAction(Sender).Tag=FLsnsType);

    4:  // select lsns
      TAction(Sender).Enabled:=SelectedLsns;

    else raise Exception.CreateFmt('Unknown action (Tag=%d)', [TAction(Sender).Tag]);
    
  end;  // case
end;

procedure TfrmLsnsListDlg.vstLsnsGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var
  lsns: TAvailLsns;
begin
  lsns:=GetLsns(Node);
  if Assigned(lsns) then
  begin
    case Column of

      0: // teacher?
        if lsns.tid>0 then
          case lsns.tstate of
            STATE_BUSY:  ImageIndex:=10;             // занят
            STATE_GREEN, STATE_RED: ImageIndex:=11;  // огр-ние
          end;  // case

      1: // hours?
        if lsns.ahours=0 then ImageIndex:=13 else
          if not lsns.CheckHours then ImageIndex:=14;

      2: // stream?
        if (lsns.strid>0) and (not lsns.CheckStm) then ImageIndex:=12;

      3: // half group
        begin
          if lsns.CheckLsns then
            if not lsns.CheckedSub then
            begin
              if lsns.subgrp then ImageIndex:=17 else ImageIndex:=15;
            end
            else
              if lsns.subgrp then ImageIndex:=16 else ImageIndex:=15;
        end;

      7: // exists stream
        if lsns.strid>0 then ImageIndex:=16 else ImageIndex:=15;

      else ImageIndex:=-1;
    end;  // case(Column)
  end;
end;

procedure TfrmLsnsListDlg.vstLsnsDblClick(Sender: TObject);
var
  lsns: TAvailLsns;
begin
  if Sender is TBaseVirtualTree then
  begin
    lsns:=GetLsns(TBaseVirtualTree(Sender).GetFirstSelected);
    if Assigned(lsns) then
      if lsns.CheckLsns then ModalResult:=mrOk
  end;  // if Sender
end;

procedure TfrmLsnsListDlg.StatusBarResize(Sender: TObject);
var
  nwidth: integer;
  i: integer;
begin
  nwidth:=0;
  for i:=1 to TStatusBar(Sender).Panels.Count-1 do
    inc(nwidth,TStatusBar(Sender).Panels[i].Width);
  TStatusBar(Sender).Panels[0].Width:=TStatusBar(Sender).Width-nwidth;
end;

procedure TfrmLsnsListDlg.UpdateBar;
const
  sDays: array[0..5] of string = ('Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота');
  sWeek: array[0..2] of string = ('','четная','нечетная');
begin
  StatusBar.Panels[1].Text:=sDays[fwday];
  StatusBar.Panels[2].Text:=SysUtils.Format('%d %s', [fnpair+1, 'пара']);
  StatusBar.Panels[3].Text:=sWeek[fweek];
end;

procedure TfrmLsnsListDlg.vstLsnsColumnClick(Sender: TBaseVirtualTree;
  Column: TColumnIndex; Shift: TShiftState);
var
  lsns: TAvailLsns;
begin
  if Column=3 then
  begin
    lsns:=GetLsns(Sender.GetFirstSelected);
    if Assigned(lsns) then
      if lsns.CheckLsns and lsns.CheckedSub then
      begin
        lsns.subgrp:=not lsns.subgrp;
        Sender.RepaintNode(Sender.GetFirstSelected);
      end;
  end;
end;

procedure TfrmLsnsListDlg.vstLsnsBeforeItemErase(Sender: TBaseVirtualTree;
  TargetCanvas: TCanvas; Node: PVirtualNode; ItemRect: TRect;
  var ItemColor: TColor; var EraseAction: TItemEraseAction);
var
  lsns: TAvailLsns;
begin
  lsns:=GetLsns(Node);
  if Assigned(lsns) then
  begin
    if lsns.CheckLsns then ItemColor:=TVirtualStringTree(Sender).Color
      else ItemColor:=$F0F0F0;
    EraseAction:=eaColor;
  end;
end;

end.
