{
  Диалог исп-ния раб. плана
  v0.0.1  (09/08/06)
}
unit ExecWorkplanDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Contnrs, VirtualTrees, ImgList;

type
  TfrmExecWorkplanDlg = class(TForm)
    vstList: TVirtualStringTree;
    ImageList: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure vstListGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: WideString);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure vstListGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure vstListBeforeItemErase(Sender: TBaseVirtualTree;
      TargetCanvas: TCanvas; Node: PVirtualNode; ItemRect: TRect;
      var ItemColor: TColor; var EraseAction: TItemEraseAction);
  private
    { Private declarations }
    fgrid: int64;

    procedure DoLoadList;

  public
    { Public declarations }
  end;

procedure ShowExecWorkplanDlg(grid: int64; grName: string);

implementation

uses
  ADODB, Math, Types,
  TimeModule, SUtils;

{$R *.dfm}

procedure ShowExecWorkplanDlg(grid: int64; grName: string);
var
  frmDlg: TfrmExecWorkplanDlg;
begin
  Assert(grid>0,
    'B3854C30-BFB5-41CE-94FC-925AD779AB8A'#13'ShowExecWorkplanDlg: invalid grid'#13);

  frmDlg:=TfrmExecWorkplanDlg.Create(Application);
  try
    frmDlg.Caption:=Format(frmDlg.Caption,[grName]);
    frmDlg.fgrid:=grid;
    frmDlg.DoLoadList;
    frmDlg.ShowModal;
  finally
    frmDlg.Free;
    frmDlg:=nil;
  end;
end;

type
  TNodeData = record
    sbName: string;
    hours: array[0..2,0..1] of byte;    // часы [ltype,hours={0-hours,1-ahours}]
  end;
  PNodeData = ^TNodeData;

function IsExecWorkplan(PData: PNodeData): boolean;
var
  i: integer;
begin
  Result:=true;
  for i:=0 to 2 do
    if PData.hours[i,1]<>0 then
    begin
      Result:=false;
      break;
    end;
end;

{ TfrmExecWorkplanDlg }

procedure TfrmExecWorkplanDlg.FormCreate(Sender: TObject);
begin
  vstList.NodeDataSize:=SizeOf(TNodeData)
end;

// загрузка исп-ния раб. плана (09/08/06)
procedure TfrmExecWorkplanDlg.DoLoadList;
var
  rs: _Recordset;
  wpid: int64;
  ltype: byte;
  vnode: PVirtualNode;
  pdata: PNodeData;
begin
  Assert(fgrid>0,
    '9EC700D5-322D-40B2-B272-C8C90F77DE49'#13'DoLoadList: invalid fgrid'#13);
  rs:=nil;

  rs:=dmMain.sdl_GetAvail_psem(fgrid);
  if Assigned(rs) then
  try
    rs.Sort:='sbName ASC, type ASC';

    vstList.BeginUpdate;
    try
      vnode:=nil;
      pdata:=nil;
      wpid:=0;

      while not rs.EOF do
      begin
        if CompareValue(wpid,rs.Fields['wpid'].Value)<>EqualsValue then
        begin
          vnode:=vstList.AddChild(nil);
          pdata:=vstList.GetNodeData(vnode);

          wpid:=rs.Fields['wpid'].Value;
          pdata.sbName:=VarToStr(rs.Fields['sbName'].Value);
        end
        else
        begin
          ltype:=rs.Fields['type'].Value;
          pdata.hours[ltype-1,0]:=rs.Fields['hours'].Value;
          pdata.hours[ltype-1,1]:=rs.Fields['ahours'].Value;

          rs.MoveNext;
        end;
      end;
    finally
      vstList.EndUpdate;
    end;
  finally
    rs.Close;
    rs:=nil;
  end;
end;

procedure TfrmExecWorkplanDlg.vstListGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: WideString);
var
  pdata: PNodeData;
begin
  pdata:=Sender.GetNodeData(Node);
  if Assigned(pdata) then
    case Column of
      1:  // sbName
        CellText:=pdata.sbName;
      2,  // lection
      3,  // practic
      4:  // labo
        CellText:=Format('%d / %2.1g',
            [pdata.hours[Column-2,0],pdata.hours[Column-2,1]/2]);

      else CellText:='';
    end;
end;

procedure TfrmExecWorkplanDlg.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key=VK_ESCAPE then ModalResult:=mrCancel;
end;

procedure TfrmExecWorkplanDlg.vstListGetImageIndex(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind;
  Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
var
  pdata: PNodeData;
begin
  pdata:=Sender.GetNodeData(Node);
  if Assigned(pdata) and (Column=0) then
  begin
    if IsExecWorkplan(pdata) then ImageIndex:=1
      else ImageIndex:=0;
  end;
end;

procedure TfrmExecWorkplanDlg.vstListBeforeItemErase(
  Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode;
  ItemRect: TRect; var ItemColor: TColor;
  var EraseAction: TItemEraseAction);
var
  pdata: PNodeData;
begin
  pdata:=Sender.GetNodeData(Node);
  if Assigned(pdata) then
  begin
    if IsExecWorkplan(pdata) then ItemColor:=$DCFFDC
      else ItemColor:=TVirtualStringTree(Sender).Color;
    EraseAction:=eaColor;
  end;
end;

end.
