{
  ћодуль формировани€ потоков
  v0.2.6 (15/08/06)
}

unit StreamsForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, VirtualTrees, ToolWin, ComCtrls, ExtCtrls, Menus, ActiveX, SConsts,
  StdCtrls, Modules, ActnList;

type

  TfrmStreams = class(TModuleForm)
    ToolBar: TToolBar;
    PanelStream: TPanel;
    tcType: TTabControl;
    btnUpdate: TToolButton;
    vstStreams: TVirtualStringTree;
    Splitter: TSplitter;
    vstDeclares: TVirtualStringTree;
    TabMenu: TPopupMenu;
    mnuTop: TMenuItem;
    mnuLeft: TMenuItem;
    mnuRight: TMenuItem;
    mnuBottom: TMenuItem;
    btnView: TToolButton;
    ViewMenu: TPopupMenu;
    mnuVertical: TMenuItem;
    mnuHorizontal: TMenuItem;
    ToolButton1: TToolButton;
    PanelDeclare: TPanel;
    LabelDeclare: TLabel;
    LabelStream: TLabel;
    ActionList: TActionList;
    actNewStrm: TAction;
    actDeleteStrm: TAction;
    actAddGroup: TAction;
    actDeleteGroup: TAction;
    actUpdate: TAction;
    ToolButton2: TToolButton;
    btnNewStrm: TToolButton;
    btnDeleteStrm: TToolButton;
    btnAddGroup: TToolButton;
    btnDeleteGroup: TToolButton;
    StreamMenu: TPopupMenu;
    mnuAddGroup: TMenuItem;
    mnuDeleteGroup: TMenuItem;
    mnuDeleteStrm: TMenuItem;
    mnuNewStrm: TMenuItem;
    procedure mnuClick(Sender: TObject);
    procedure mnuViewClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure vstDeclaresGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: WideString);
    procedure vstStreamsGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: WideString);
    procedure vtCreateEditor(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; out EditLink: IVTEditLink);
    procedure vstEditing(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; var Allowed: Boolean);
    procedure vstStreamsDragOver(Sender: TBaseVirtualTree; Source: TObject;
      Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode;
      var Effect: Integer; var Accept: Boolean);
    procedure vstStreamsDragDrop(Sender: TBaseVirtualTree; Source: TObject;
      DataObject: IDataObject; Formats: TFormatArray; Shift: TShiftState;
      Pt: TPoint; var Effect: Integer; Mode: TDropMode);
    procedure tcTypeChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ActionsExecute(Sender: TObject);
    procedure ActionsUpdate(Sender: TObject);
  protected
    function GetModuleName: string; override;
    procedure ModuleHandler(var Msg: TMessage); override;
    function GetHelpTopic: string; override;

  private
    { Private declarations }

    fkafedra: string;        // kid=kName
    fsubject: string;        // sbid=sbName

    function Get_kid: int64;
    function Get_sbid: int64;
    function Get_kName: string;
    function Get_sbName: string;
  private
    FTeacherList: TStringList;
    FStreamList: TList;
    FDeclareList: TList;

    function GetDeclare(VTree: TBaseVirtualTree; VNode: PVirtualNode): Pointer;
    function GetStream(VTree: TBaseVirtualTree; VNode: PVirtualNode): Pointer;
    procedure UpdateData(bUpdateTeachers: boolean=false);
    procedure LoadTeachers;
    procedure LoadStreams;
    procedure LoadFreeDeclares;
    function ExistsDeclare(strid, grid: int64): boolean;
    procedure InitFreeNodes(sort: boolean);
    procedure InitStreamNodes(sort: boolean);
//    procedure LoadDeclares;

    procedure PrepareEdit(Sender: TObject; var Allow: boolean);
    procedure EndEdit(Sender: TObject; var Allow: boolean);
  public
    { Public declarations }
    procedure Open(const akafedra, asubject: string);
    procedure OpenGroup(grid: int64; const asubject: string);
    procedure UpdateModule; override;

    property kafedra: string read fkafedra;
    property subject: string read fsubject;

    property kid: int64 read Get_kid;
    property sbid: int64 read Get_sbid;
    property kName: string read Get_kName;
    property sbName: string read Get_sbName;
  end;


implementation

uses
  ADODB,
  TimeModule, SUtils, SStrings, STypes, SHelp,
  DeclareListDlg;

{$R *.dfm}

type
  TDeclareData = record
    lid: int64;
    strid: int64;
    grid: int64;
    grName: string;
    sbid: int64;
    sbName: string;
    tid: int64;
    tName: string;
    hours: byte;
  end;
  PDeclareData = ^TDeclareData;

  TNodeData = record
    index: integer;
  end;
  PNodeData = ^TNodeData;

  TAllowEvent = procedure(Sender: TObject; var Allow: boolean) of object;
  // редактор
  TNodeEditor = class(TInterfacedObject, IVTEditLink)
  private
    FEdit: TComboBox;          // класс редактора
    FTree: TVirtualStringTree; // обратна€ ссылка на VirtualTreeView
    FNode: PVirtualNode;       // редактируемый узел
    FColumn: Integer;          // столбец редактируемого узла

    FOnPrepareEdit: TAllowEvent;
    FOnEndEdit: TAllowEvent;
  protected
    procedure EditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditDrawItem(Control: TWinControl; Index: Integer;
                 Rect: TRect; State: TOwnerDrawState);
  public
    property OnPrepareEdit: TAllowEvent read FOnPrepareEdit write FOnPrepareEdit;
    property OnEndEdit: TAllowEvent read FOnEndEdit write FOnEndEdit;

    constructor Create(const OnPrepare, OnEnd: TAllowEvent);
    destructor Destroy; override;           // деструктор
    function BeginEdit: Boolean; stdcall;   // начало редактировани€
    function CancelEdit: Boolean; stdcall;  // отмена редактировани€
    function EndEdit: Boolean; stdcall;     // конец редактировани€
    function GetBounds: TRect; stdcall;     // определение области вывода редактора
    function PrepareEdit(Tree: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex): Boolean; stdcall;
    procedure ProcessMessage(var Message: TMessage); stdcall;
    procedure SetBounds(R: TRect); stdcall; // установка области вывода редактора
  end;


procedure ClearList(var AList: TList);
var
  i: integer;
begin
  for i:=0 to AList.Count-1 do
    Dispose(AList.Items[i]);
  AList.Clear;
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

// сравнение за€вок (по названию группы)
function CompareDeclare(Item1, Item2: Pointer): integer;
begin
  Result:=AnsiCompareText(PDeclareData(Item1).grName, PDeclareData(Item2).grName);
end;

// сравнение за€вок (по потокам)
function CompareStream(Item1, Item2: Pointer): integer;
begin
  Result:=PDeclareData(Item1).strid-PDeclareData(Item2).strid;
  if Result=0 then
    Result:=AnsiCompareText(PDeclareData(Item1).grName,PDeclareData(Item2).grName);
end;

procedure TfrmStreams.FormCreate(Sender: TObject);
begin
  FTeacherList:=TStringList.Create;
  FStreamList:=TList.Create;
  FDeclareList:=TList.Create;

  vstStreams.NodeDataSize:=SizeOf(TNodeData);
  vstDeclares.NodeDataSize:=SizeOf(TNodeData);
end;

procedure TfrmStreams.FormDestroy(Sender: TObject);
begin
  ClearList(FStreamList);
  FStreamList.Free;
  ClearList(FDeclareList);
  FDeclareList.Free;

  FTeacherList.Free;
  FTeacherList:=nil;
end;

function TfrmStreams.GetHelpTopic: string;
begin
  Result:=HELP_TIMETABLE_STREAMS;
end;

// загрузка потоков
procedure TfrmStreams.Open(const akafedra, asubject: string);
begin
  if (fkafedra<>akafedra) or (fsubject<>asubject) then
  begin
    fkafedra:=akafedra;
    fsubject:=asubject;
    Caption:=Format('%s (кафедра: %s)', [sbName,kName]);
    UpdateModule;
  end;
end;

// загрузка потоков (кафедра-исполнитель определ€етс€ из р.п. группы)
procedure TfrmStreams.OpenGroup(grid: int64; const asubject: string);

  function GetKafedra: string;
  var
    rs: _Recordset;
  begin
    Result:='';

    rs:=dmMain.wp_GetKaf(grid,GetId(asubject));
    if Assigned(rs) then
    try
      if not rs.EOF then
      try
        Result:=VarToStr(rs.Fields.Item['kid'].Value)+'='+rs.Fields.Item['kName'].Value;
      except
        Result:='';
      end;
    finally
      rs.Close;
      rs:=nil;
    end;
  end;

var
  s: string;
begin
  s:=GetKafedra;
  if s<>'' then Open(s,asubject);
end;

function TfrmStreams.Get_kid: int64;
begin
  if fkafedra<>'' then Result:=StrToIntDef(SUtils.GetName(fkafedra),0)
    else Result:=0;
end;

function TfrmStreams.Get_sbid: int64;
begin
  if fsubject<>'' then Result:=StrToIntDef(SUtils.GetName(fsubject),0)
    else Result:=0;
end;

function TfrmStreams.Get_kName: string;
begin
  if fkafedra<>'' then Result:=SUtils.GetValue(fkafedra)
    else Result:='';
end;

function TfrmStreams.Get_sbName: string;
begin
  if fsubject<>'' then Result:=SUtils.GetValue(fsubject)
    else Result:='';
end;

// for tabs (top, left, right, bottom)
procedure TfrmStreams.mnuClick(Sender: TObject);
const
//  Align: array[1..4] of TAlign = (alTop, alLeft, alRight, alBottom);
  TabPos: array[1..4] of TTabPosition = (tpTop, tpLeft, tpRight, tpBottom);
begin
  if (Sender as TMenuItem).Checked then exit;
//  tcType.Align:=Align[(Sender as TMenuItem).Tag];
  tcType.TabPosition:=TabPos[(Sender as TMenuItem).Tag];
  (Sender as TMenuItem).Checked:=true;
end;

// view (vertical, horizontal)
procedure TfrmStreams.mnuViewClick(Sender: TObject);
const
  Align: array[1..2] of TAlign = (alLeft, alTop);
begin
  if (Sender as TMenuItem).Checked then exit;
  PanelStream.Align:=Align[(Sender as TMenuItem).Tag];
  //vtStrm.Align:=Align[(Sender as TMenuItem).Tag];
  Splitter.Align:=Align[(Sender as TMenuItem).Tag];
  case Splitter.Align of
  alLeft:
    begin
      vstStreams.Width:=(tcType.Width div 2)-Splitter.Width;
      Splitter.Left:=PanelStream.Width+1;
    end;
  alTop:
    begin
      vstStreams.Height:=(tcType.Height div 2)-Splitter.Height;
      Splitter.Top:=PanelStream.Height+1;
    end;
  end;
  (Sender as TMenuItem).Checked:=true;
end;

// возвращает за€вку
function TfrmStreams.GetDeclare(VTree: TBaseVirtualTree; VNode: PVirtualNode): Pointer;
var
  pdata: PNodeData;
begin
  Assert(VTree=vstDeclares,
    'C2B6F936-2171-4495-892D-A3B464A51C7F'#13'GetDeclare: VTree is not vstDeclares'#13);

  Result:=nil;
  pdata:=VTree.GetNodeData(VNode);
  if Assigned(pdata) then Result:=FDeclareList[pdata.index];
end;

// возвращает поток
function TfrmStreams.GetStream(VTree: TBaseVirtualTree; VNode: PVirtualNode): Pointer;
var
  pdata: PNodeData;
begin
  Assert(VTree=vstStreams,
    'C7AF20BD-9B4E-43B2-8A39-DE08CF4162BC'#13'VTree is not vstStreams'#13);

  Result:=nil;
  pdata:=VTree.GetNodeData(VNode);
  if Assigned(pdata) then Result:=FStreamList[pdata.index];
end;

// загрузка потоков кафедры
procedure TfrmStreams.LoadStreams;
var
  ds: TADODataSet;
  pdeclare: PDeclareData;
begin
  ds:=nil;
  pdeclare:=nil;

  ds:=CreateDataSet(dmMain.stm_Get_ks(tcType.TabIndex+1,kid,sbid));
  if Assigned(ds) then
  try
    ClearList(FStreamList);
    ds.Sort:='strid ASC, grName ASC';
    while not ds.Eof do
    begin
      New(pdeclare);
      with pdeclare^ do
      begin
        lid:=ds.FieldByName('lid').AsInteger;
        strid:=ds.FieldByName('strid').AsInteger;
        grid:=ds.FieldByName('grid').AsInteger;
        grName:=ds.FieldByName('grName').AsString;
        sbid:=ds.FieldByName('sbid').AsInteger;
        sbName:=ds.FieldByName('sbName').AsString;
        tid:=ds.FieldByName('tid').AsInteger;
        tName:=ds.FieldByName('tName').AsString;
        hours:=ds.FieldByName('hours').AsInteger;
      end;
      FStreamList.Add(pdeclare);
      ds.Next;
    end;
  finally
    ds.Close;
    ds.Free;
    ds:=nil;
  end;
end;

// загрузка свобод. за€вок
procedure TfrmStreams.LoadFreeDeclares;
var
  ds: TADODataSet;
  pdeclare: PDeclareData;
begin
  ds:=nil;
  pdeclare:=nil;

  ds:=CreateDataSet(dmMain.stm_GetFree_d(tcType.TabIndex+1,kid,sbid));
  if Assigned(ds) then
  try
    ClearList(FDeclareList);
    ds.Sort:='grName ASC';
    while not ds.Eof do
    begin
      New(pdeclare);
      with pdeclare^ do
      begin
        lid:=ds.FieldByName('lid').AsInteger;
        strid:=ds.FieldByName('strid').AsInteger;
        grid:=ds.FieldByName('grid').AsInteger;
        grName:=ds.FieldByName('grName').AsString;
        sbid:=ds.FieldByName('sbid').AsInteger;
        sbName:=ds.FieldByName('sbName').AsString;
        tid:=ds.FieldByName('tid').AsInteger;
        tName:=ds.FieldByName('tName').AsString;
        hours:=ds.FieldByName('hours').AsInteger;
      end;
      FDeclareList.Add(pdeclare);
      ds.Next;
    end;
  finally
    ds.Close;
    ds.Free;
    ds:=nil;
  end;

end;

// проверка существовани€ группы в потоке
function TfrmStreams.ExistsDeclare(strid, grid: int64): boolean;
var
  i: integer;
  pdeclare: PDeclareData;
begin
  Result:=false;
  for i:=0 to FStreamList.Count-1 do
  begin
    pdeclare:=FStreamList[i];
    if (pdeclare.strid=strid) and (pdeclare.grid=grid) then
    begin
      Result:=true;
      break;
    end;
  end;
end;

// инициализаци€ vtree за€вок
procedure TfrmStreams.InitFreeNodes(sort: boolean);
var
  ndata: TNodeData;
  i: integer;
begin
  vstDeclares.BeginUpdate;
  try
    vstDeclares.Clear;

    if sort and (FDeclareList.Count>0) then FDeclareList.Sort(CompareDeclare);
    for i:=0 to FDeclareList.Count-1 do
    begin
      ndata.index:=i;
      AddTreeNode(vstDeclares, ndata);
    end;
  finally
    vstDeclares.EndUpdate;
  end;
end;

// инициализаци€ vtree потоков
procedure TfrmStreams.InitStreamNodes(sort: boolean);
var
  i: integer;
  ndata: TNodeData;
  vnode: PVirtualNode;
  strid: int64;
  pdeclare: PDeclareData;
begin
  vnode:=nil;
  strid:=0;

  vstStreams.BeginUpdate;
  try
    vstStreams.Clear;
    i:=0;

    if sort and (FStreamList.Count>0) then FStreamList.Sort(CompareStream);

    while i<FStreamList.Count do
    begin
      pdeclare:=FStreamList[i];
      ndata.index:=i;
      if strid<>pdeclare.strid then
      begin
        strid:=pdeclare.strid;
        vnode:=AddTreeNode(vstStreams, ndata, nil);
      end
      else
      begin
        AddTreeNode(vstStreams, ndata, vnode);
        inc(i);
      end;
    end;
    vstStreams.FullExpand(nil);
  finally
    vstStreams.EndUpdate;
  end;
end;

// загрузка списка преп-лей кафедры
procedure TfrmStreams.LoadTeachers;
begin
  Assert(Assigned(FTeacherList),
    '713E0EA6-5D0C-4367-95C3-CBB3F32CBF16'#13'LoadTeachers: FTeacherList is nil'#13);

  if Assigned(FTeacherList) then
  begin
    dmMain.GetTeacherList(kid, FTeacherList);
    FTeacherList.Insert(0,'');
  end; // if Teachers<>nil
end;

function TfrmStreams.GetModuleName: string;
begin
//  Result:=Format('%s (кафедра: %s)', [sbName,kName]);
  Result:='ѕотоки';
end;

procedure TfrmStreams.ModuleHandler(var Msg: TMessage);
begin
  case Msg.Msg of
    SM_CHANGETIME:
      if (TSMChangeTime(Msg).Flags and CT_YEAR)=CT_YEAR then   // изм-ние года
        TSMChangeTime(Msg).Result:=MRES_DESTROY
      else
      begin
        UpdateData(false);
        TSMChangeTime(Msg).Result:=MRES_UPDATE;
      end;

  end;  // case
end;

// обновление данных
procedure TfrmStreams.UpdateData(bUpdateTeachers: boolean=false);
begin
  if bUpdateTeachers then LoadTeachers;
  LoadStreams;
  InitStreamNodes(false);
  LoadFreeDeclares;
  InitFreeNodes(false);
end;

// обновление модул€
procedure TfrmStreams.UpdateModule;
begin
  UpdateData(true);
end;

procedure TfrmStreams.vstDeclaresGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: WideString);
var
  pdeclare: PDeclareData;
begin
  CellText:='';
  pdeclare:=GetDeclare(Sender, Node);
  if Assigned(pdeclare) then
    case Column of
      0: CellText:=pdeclare.grName;
      1: CellText:=pdeclare.sbName;
      2: CellText:=IntToStr(pdeclare.hours);
    end;  // case
end;

procedure TfrmStreams.vstStreamsGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: WideString);
var
  pdeclare: PDeclareData;
begin

  CellText:='';
  pdeclare:=GetStream(Sender, Node);
  if Assigned(pdeclare) then
  begin
    if Sender.GetNodeLevel(Node)=0 then
      case Column of
        0: CellText:=IntToStr(pdeclare.strid);
        1: CellText:=pdeclare.tName;
        2: CellText:=IntToStr(pdeclare.hours);
      end  // case (level=0)
    else
      case Column of
        0: CellText:=pdeclare.grName;
        1: CellText:=pdeclare.sbName;
        2: CellText:=IntToStr(pdeclare.hours);
      end;  // case (level=1)
  end; // if pdeclare<>nil
end;

{ TNodeEditor }

// Ќачало редактировани€ (24.08.2004)
function TNodeEditor.BeginEdit: Boolean;
begin
  Result := True;
  FEdit.Show;
  FEdit.SetFocus;
  FEdit.DroppedDown:=true;
end;

// ќтмeна редактировани€ (24.08.2004)
function TNodeEditor.CancelEdit: Boolean;
begin
  Result := True;
  FEdit.Hide;
end;

constructor TNodeEditor.Create(const OnPrepare, OnEnd: TAllowEvent);
begin
  inherited Create;
  FOnPrepareEdit:=OnPrepare;
  FOnEndEdit:=OnEnd;
end;

destructor TNodeEditor.Destroy;
begin
  FEdit.Free;
  inherited;
end;

// —обытие отрисовки элемента списка (25.08.2004)
procedure TNodeEditor.EditDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  FCanvas: TCanvas;
  s: string;
begin
  if Control is TComboBox then
  begin
    FCanvas:=(Control as TComboBox).Canvas;
    TControlCanvas(FCanvas).UpdateTextFlags;

    if bDebugMode then s:=TComboBox(Control).Items[Index]
      else s:=GetValue(TComboBox(Control).Items[Index]);

    FCanvas.FillRect(Rect);
    FCanvas.TextOut(Rect.Left + 2, Rect.Top, s);
  end;
end;

// —обытие от нажати€ клавиши дл€ ComboBox`а (24.08.2004)
procedure TNodeEditor.EditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  CanAdvance: Boolean;
begin
  case Key of
    VK_RETURN,
    VK_UP,
    VK_DOWN:
      begin
        // Consider special cases before finishing edit mode.
        CanAdvance := Shift = [];
        CanAdvance := CanAdvance and not FEdit.DroppedDown;

        if CanAdvance then
        begin
          // Forward the keypress to the tree. It will asynchronously change the focused node.
          PostMessage(FTree.Handle, WM_KEYDOWN, Key, 0);
          Key := 0;
        end;
      end;
  end;
end;

//  онец редактировани€ (24.08.2004)
function TNodeEditor.EndEdit: Boolean;
begin
  Result:=false;
  if Assigned(FOnEndEdit) then FOnEndEdit(Self, Result);
  FTree.InvalidateNode(FNode);
  //if Result then FTree.InvalidateNode(FNode);
  FEdit.Hide;
  FTree.SetFocus;
end;

function TNodeEditor.GetBounds: TRect;
begin
  Result := FEdit.BoundsRect;
end;

// ѕодготовка редактора (24.08.2004)
function TNodeEditor.PrepareEdit(Tree: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex): Boolean;
begin
  Result:=false;
  if not Assigned(FOnPrepareEdit) then exit;
  FTree := Tree as TVirtualStringTree;
  FNode := Node;
  FColumn := Column;
  FreeAndNil(FEdit);
  FEdit := TComboBox.Create(Tree);
  if Assigned(FEdit) then
  begin
    FEdit.Parent:=Tree;
//    FEdit.Visible:=False;
    FEdit.Style:=csOwnerDrawFixed;
    FEdit.OnKeyDown:=EditKeyDown;
    FEdit.OnDrawItem:=EditDrawItem;
    if Assigned(FOnPrepareEdit) then FOnPrepareEdit(Self, Result);
  end; // if Assigned(FEdit)
end;

procedure TNodeEditor.ProcessMessage(var Message: TMessage);
begin
  FEdit.WindowProc(Message);
end;

procedure TNodeEditor.SetBounds(R: TRect);
var
  Dummy: Integer;
begin
  FTree.Header.Columns.GetColumnBounds(FColumn, Dummy, R.Right);
  FEdit.BoundsRect := R;
end;

procedure TfrmStreams.vtCreateEditor(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; out EditLink: IVTEditLink);
begin
  EditLink:=TNodeEditor.Create(PrepareEdit, EndEdit);
end;

procedure TfrmStreams.vstEditing(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
begin
  if Sender.GetNodeLevel(Node)=0 then Allowed:=(Column=1)
    else Allowed:=false;
end;

procedure TfrmStreams.EndEdit(Sender: TObject; var Allow: boolean);
var
  pdeclare: PDeclareData;
begin
  Allow:=true;
  with Sender as TNodeEditor do
  begin
    pdeclare:=GetStream(FTree, FNode);
    if Assigned(pdeclare) then
      if (pdeclare.strid>0) and (pdeclare.tid<>GetId(FEdit.Text)) then
        if dmMain.stm_SetThr(pdeclare.strid, GetId(FEdit.Text)) then
        begin
          pdeclare.tid:=GetId(FEdit.Text);
          pdeclare.tName:=GetValue(FEdit.Text);
        end
        else ShowMessage('ќшибка при обновлении Ѕƒ');
  end;  // with Sender
end;

procedure TfrmStreams.PrepareEdit(Sender: TObject; var Allow: boolean);
var
  pdeclare: PDeclareData;
begin

  Allow:=False;
  if FTeacherList.Count>0 then
    with Sender as TNodeEditor do
    begin
      pdeclare:=GetStream(FTree,FNode);
      if Assigned(pdeclare) then
      begin
        FEdit.Items.Clear;
        FEdit.Items.AddStrings(FTeacherList);
        FEdit.ItemIndex:=FEdit.Items.IndexOfName(IntToStr(pdeclare.tid));
      end;
      Allow:=(FEdit.Items.Count>0);
    end; // with Sender

  //Allow:=False;
  //with Sender as TNodeEditor do
  //begin
  //  Data:=FTree.GetNodeData(FNode);
  //  if Data.DataType=dtDclr then
  //    if dmMain.SelectTeachLd(Data.Value[0]) then
  //    try
  //      FEdit.Items.Clear;
  //      while not dmMain.spTeachMgm.Eof do
  //      begin
  //        FEdit.Items.Add(dmMain.spTeachMgm.FieldByName('tid').AsString+'='+dmMain.spTeachMgm.FieldByName('tName').AsString);
  //        dmMain.spTeachMgm.Next;
  //      end;
  //      FEdit.ItemIndex:=FEdit.Items.IndexOfName(GetName(Data.Value[3]));
  //    finally
  //      dmMain.spTeachMgm.Close;
  //    end;
  //  Allow:=(FEdit.Items.Count>0);
  //end; // with sender as TNodeEditor
end;

// проверка на Drop
procedure TfrmStreams.vstStreamsDragOver(Sender: TBaseVirtualTree;
  Source: TObject; Shift: TShiftState; State: TDragState; Pt: TPoint;
  Mode: TDropMode; var Effect: Integer; var Accept: Boolean);
//  Data: PNodeData;

  // проверка на возможность перемещени€
  function AllowDrop(const Dest, Src: PVirtualNode): boolean;
  var
    pdeclare, pstream: PDeclareData;
  begin
    Result:=false;

    pdeclare:=GetDeclare(Source as TBaseVirtualTree, Src);
    if Assigned(pdeclare) then
    begin
      pstream:=GetStream(Sender, Dest);
      if Assigned(pstream) then
        if pstream.hours=pdeclare.hours then
          Result:=not ExistsDeclare(pstream.strid,pdeclare.grid);
    end  // if pdeclare<>nil

  end; // function

var
  vnSource, vnDest: PVirtualNode;

begin
  vnSource:=nil; vnDest:=nil;

  Accept:=false;
  if (Source is TBaseVirtualTree) and (Sender<>Source) then
  begin
    vnSource:=(Source as TBaseVirtualTree).GetFirstSelected;
    vnDest:=Sender.DropTargetNode;
    if Assigned(vnSource) and Assigned(vnDest) then
      if Sender.GetNodeLevel(vnDest)=0 then
        Accept:=AllowDrop(vnDest, vnSource);
  end;
end;

// завершение DragDrop
procedure TfrmStreams.vstStreamsDragDrop(Sender: TBaseVirtualTree;
  Source: TObject; DataObject: IDataObject; Formats: TFormatArray;
  Shift: TShiftState; Pt: TPoint; var Effect: Integer; Mode: TDropMode);
var
  pdeclare, pstream: PDeclareData;
  vndst, vnsrc: PVirtualNode;
begin
  vndst:=nil; vnsrc:=nil;

  if (Source is TBaseVirtualTree) and (Sender<>Source) then
  begin
    vnsrc:=TBaseVirtualTree(Source).GetFirstSelected;  // за€вка
    vndst:=Sender.DropTargetNode;                      // поток

    pdeclare:=GetDeclare(TBaseVirtualTree(Source), vnsrc);
    pstream:=GetStream(Sender, vndst);

    if Assigned(pdeclare) and Assigned(pstream) then
      // изм-ние в базе
      if dmMain.stm_AddGrp(pstream.strid,pdeclare.lid) then
      begin
        // перемещение узла
        FDeclareList.Remove(pdeclare);
        pdeclare.strid:=pstream.strid;
        FStreamList.Add(pdeclare);
        InitStreamNodes(true);
        InitFreeNodes(false);
      end; // if
  end;
end;

procedure TfrmStreams.tcTypeChange(Sender: TObject);
begin
  UpdateData(false);
end;

// действи€
procedure TfrmStreams.ActionsExecute(Sender: TObject);

  // создание потока
  procedure CreateStrm;
  var
    pnode: PVirtualNode;
    pdeclare: PDeclareData;
  begin
    pnode:=vstDeclares.GetFirstSelected;
    if Assigned(pnode) then
    begin
      pdeclare:=GetDeclare(vstDeclares, pnode);
      if Assigned(pdeclare) then
        if dmMain.stm_Create(pdeclare.lid)>0 then UpdateData(false);
    end;
  end; // procedure CreateStrm

  // удаление потока
  procedure DeleteStrm;
  var
    pnode: PVirtualNode;
    pstream: PDeclareData;
  begin
    pnode:=vstStreams.GetFirstSelected;
    if Assigned(pnode) then
    begin
      pstream:=GetStream(vstStreams,pnode);
      if Assigned(pstream) then
        if pstream.strid>0 then
          if dmMain.stm_Delete(pstream.strid) then UpdateData(false);
    end; // if pnode<>nil
  end;  // procedure DeleteStrm

  // добавление группы в поток
  procedure AddGroup;
  var
    i: integer;
    vnode: PVirtualNode;
    pstream: PDeclareData;
    list: TStringList;
    lid: int64;
    berr: boolean;        // признак ошибки
    msg: string;          // сообщение об ошибке
  begin
    vnode:=vstStreams.GetFirstSelected;
    if Assigned(vnode) then
    begin
      pstream:=GetStream(vstStreams, vnode);
      if Assigned(pstream) then
        if pstream.strid>0 then
        begin
          list:=TStringList.Create;
          try
            if GetDeclaresForStream(pstream.strid, list) then
            begin
              berr:=false;

              dmMain.Connection.BeginTrans;
              try
                for i:=0 to list.Count-1 do
                try
                  lid:=StrToInt64Def(list[i],0);
                  if lid>0 then
                    if not dmMain.stm_AddGrp(pstream.strid,lid) then
                    begin
                      berr:=true;
                      msg:=Format(rsErrAddStrmGrp,[lid]);
                      break;
                    end;
                except
                  on E: Exception do
                  begin
                    berr:=true;
                    msg:=E.Message;
                    break;
                  end;
                end;
              finally
                if berr then
                begin
                  dmMain.Connection.RollbackTrans;
                  if msg<>'' then MessageDlg(msg,mtError,[mbOK],-1);
                end
                else
                begin
                  dmMain.Connection.CommitTrans;
                  UpdateData(false);
                end;
              end;

            end;
          finally
            list.Free;
            list:=nil;
          end;
        end;  // if pstream.strid>0
    end;  // if vnode<>nil
  end;  // procedure AddGroup

  // удаление группы из потока
  procedure DeleteGroup;
  var
    vnode: PVirtualNode;
    pdeclare: PDeclareData;
  begin
    vnode:=vstStreams.GetFirstSelected;
    if Assigned(vnode) then
    begin
      pdeclare:=GetStream(vstStreams,vnode);
      if Assigned(pdeclare) then
        if dmMain.stm_DelGrp(pdeclare.lid) then UpdateData(false);
    end;  // if vnode<>nil
  end;  // procedure DeleteGroup

begin
  case (Sender as TAction).Tag of
    -1: // update
      UpdateModule;

    1:  // new strm
      CreateStrm;

    2:  // delete strm
      DeleteStrm;

    3:  // add group
      AddGroup;

    4:  // delete group
      DeleteGroup;

    else raise Exception.CreateFmt('Unknown action (tag=%d)', [TAction(Sender).Tag]);
  end;  // case
end;

// обновление состо€ний
procedure TfrmStreams.ActionsUpdate(Sender: TObject);
var
  vnode: PVirtualNode;
begin
  case (Sender as TAction).Tag of

    1:  // new strm
      if vstDeclares.Focused then
      begin
        vnode:=vstDeclares.GetFirstSelected;
        if Assigned(vnode) then
          TAction(Sender).Enabled:=(vnode<>vstDeclares.RootNode)
        else TAction(Sender).Enabled:=false;
      end
      else TAction(Sender).Enabled:=false;

    2,3:  // delete strm (2), add group (3)
      if vstStreams.Focused then
      begin
        vnode:=vstStreams.GetFirstSelected;
        if Assigned(vnode) then
          TAction(Sender).Enabled:=(vstStreams.GetNodeLevel(vnode)=0) and
              (vnode<>vstStreams.RootNode)
        else TAction(Sender).Enabled:=false;
      end
      else TAction(Sender).Enabled:=false;

    4:  // delete group
      if vstStreams.Focused then
      begin
        vnode:=vstStreams.GetFirstSelected;
        if Assigned(vnode) then
          TAction(Sender).Enabled:=(vstStreams.GetNodeLevel(vnode)=1) and
              (vnode<>vstStreams.RootNode)
        else TAction(Sender).Enabled:=false;
      end
      else TAction(Sender).Enabled:=false;

  end;  // case
end;

end.
