{
  Диалог выбора заявок для потоков
  v0.2.3
}

unit DeclareListDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, VirtualTrees, ADODB;

type
  TDeclareGroupKind = (dgkGroup, dgkSubject, dgkCourse);

  TfrmDeclareListDlg = class(TForm)
    vstDeclares: TVirtualStringTree;
    btnOk: TButton;
    btnCancel: TButton;
    cbGroupBy: TComboBox;
    lblGroupBy: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure vstDeclaresGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: WideString);
    procedure vstDeclaresChecked(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure FormDestroy(Sender: TObject);
    procedure cbGroupByChange(Sender: TObject);
  private
    { Private declarations }
    FGroupKind: TDeclareGroupKind; // группировка (группа, предмет, курс)

    FDeclareList: TList;           // список заявок
    procedure ClearDeclare;
    procedure CheckDeclare(index: integer);
    procedure LoadDeclares(rs: _Recordset);
    procedure GroupBy(Value: TDeclareGroupKind);

  private
    procedure InitNodes;
    function GetList(var list: TStringList): integer;

  public
    { Public declarations }
  end;

function GetDeclaresForStream(strid: int64; var list: TStringList): boolean;

implementation

uses
  TimeModule, SUtils, SStrings, Math, StrUtils;

{$R *.dfm}

type
  // заявка
  TDeclareData = record
    check: boolean;           // выделено
    lid: int64;
    grid: int64;
    grName: string;
    course: byte;
    sbid: int64;
    sbName: string;
    hours: byte;
  end;
  PDeclareData = ^TDeclareData;

  TNodeData = record
    index: integer;
  end;
  PNodeData = ^TNodeData;

// выбор свобод. заявок для потока
function GetDeclaresForStream(strid: int64; var list: TStringList): boolean;
var
  frmDlg: TfrmDeclareListDlg;
  rs: _Recordset;
begin
  Result:=false;

  rs:=dmMain.stm_GetFree_s(strid);

  if Assigned(rs) then
  try

    if not rs.EOF then
    begin
      frmDlg:=TfrmDeclareListDlg.Create(Application);
      try
        frmDlg.Caption:='Свободные заявки';
        frmDlg.LoadDeclares(rs);
        if frmDlg.ShowModal=mrOk then Result:=(frmDlg.GetList(list)>0);
      finally
        frmDlg.Free;
        frmDlg:=nil;
      end;
    end
    else MessageDlg(rsNotFoundDclrs, mtInformation, [mbOK], -1);

  finally
    rs:=nil;
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

// сравнение названий групп
function CompareGroup(Item1, Item2: Pointer): integer;
begin
//  Result:=CompareValue(PDeclareData(Item1).grid, PDeclareData(Item2).grid);
  Result:=AnsiCompareText(PDeclareData(Item1).grName, PDeclareData(Item2).grName);
  if Result=0 then
    Result:=AnsiCompareText(PDeclareData(Item1).sbName, PDeclareData(Item2).sbName);
end;

// сравнение названий дисциплин
function CompareSubject(Item1, Item2: Pointer): integer;
begin
//  Result:=CompareValue(PDeclareData(Item1).sbid, PDeclareData(Item2).sbid);
  Result:=AnsiCompareText(PDeclareData(Item1).sbName, PDeclareData(Item2).sbName);
  if Result=0 then
    Result:=AnsiCompareText(PDeclareData(Item1).grName, PDeclareData(Item2).grName);
end;

// сравнение курсов
function CompareCourse(Item1, Item2: Pointer): integer;
begin
  Result:=PDeclareData(Item1).course-PDeclareData(Item2).course;
  if Result=0 then
  begin
    Result:=AnsiCompareText(PDeclareData(Item1).grName,PDeclareData(Item2).grName);
    if Result=0 then
      Result:=AnsiCompareText(PDeclareData(Item1).sbName,PDeclareData(Item2).sbName);
  end;
end;

{ TfrmDeclareListDlg }

procedure TfrmDeclareListDlg.FormCreate(Sender: TObject);
begin
  FDeclareList:=TList.Create;
  vstDeclares.NodeDataSize:=sizeof(TNodeData);
  FGroupKind:=dgkGroup;
end;

procedure TfrmDeclareListDlg.FormDestroy(Sender: TObject);
begin
  ClearDeclare;
  FDeclareList.Free;
end;

// очистка списка заявок
procedure TfrmDeclareListDlg.ClearDeclare;
var
  i: integer;
begin
  for i:=0 to FDeclareList.Count-1 do
    Dispose(FDeclareList.Items[i]);
  FDeclareList.Clear;
end;

// выбор заявки
procedure TfrmDeclareListDlg.CheckDeclare(index: integer);
var
  i: integer;
  grid: int64;
  pdeclare: PDeclareData;
begin
  pdeclare:=nil;
  pdeclare:=FDeclareList.Items[index];
  if Assigned(pdeclare) then
  begin
    pdeclare.check:=not pdeclare.check;
    // если выбрали заявку, то ..
    if pdeclare.check then
    begin
      // .. снимаем выбор со всех заявок с выбран. группы 
      grid:=pdeclare^.grid;
      for i:=0 to FDeclareList.Count-1 do
        if i<>index then
        begin
          pdeclare:=FDeclareList.Items[i];
          if pdeclare.grid=grid then
            pdeclare.check:=false;
        end;
    end;
  end
  else raise Exception.CreateFmt('Declare (index=%d) is nil',[index]);
end;

// загрузка данных
procedure TfrmDeclareListDlg.LoadDeclares(rs: _Recordset);
var
  ds: TADODataSet;
  pdeclare: PDeclareData;
begin


  ds:=CreateDataSet(rs);
  if Assigned(ds) then
  try
    case FGroupKind of
      dgkGroup: ds.Sort:='grName ASC, sbName ASC';
      dgkSubject: ds.Sort:='sbName ASC, grName ASC';
      dgkCourse: ds.Sort:='course ASC, grName ASC, sbName ASC';
    end;

    while not ds.Eof do
    begin
      New(pdeclare);
      with pdeclare^ do
      begin
        check:=false;
        lid:=ds.FieldByName('lid').AsInteger;
        grid:=ds.FieldByName('grid').AsInteger;
        grName:=ds.FieldByName('grName').AsString;
        course:=ds.FieldByName('course').AsInteger;
        sbid:=ds.FieldByName('sbid').AsInteger;
        sbName:=ds.FieldByName('sbName').AsString;
        hours:=ds.FieldByName('hours').AsInteger;
      end;
      FDeclareList.Add(pdeclare);
      ds.Next;
    end;

{
    vstDeclares.BeginUpdate;
    try
      while not ds.Eof do
      begin
        if grid<>ds.FieldByName('grid').AsInteger then
        begin
          grid:=ds.FieldByName('grid').AsInteger;
          nd.lid:=ds.FieldByName('lid').AsInteger;
          nd.grName:=ds.FieldByName('grName').AsString;
          nd.sbName:=ds.FieldByName('sbName').AsString;
          nd.hours:=ds.FieldByName('hours').AsInteger;
          vn:=AddTreeNode(vstDeclares, nd, nil);
        end
        else
        begin
          nd.lid:=ds.FieldByName('lid').AsInteger;
          nd.grName:=ds.FieldByName('grName').AsString;
          nd.sbName:=ds.FieldByName('sbName').AsString;
          nd.hours:=ds.FieldByName('hours').AsInteger;
          AddTreeNode(vstDeclares, nd, vn).CheckType:=ctCheckBox;
          ds.Next;
        end;
      end; // while
    finally
      vstDeclares.EndUpdate;
    end;
    vstDeclares.FullExpand(nil);
}

    InitNodes;
  finally
    ds.Close;
    ds.Free;
    ds:=nil;
  end;
end;

// группировка по ..(дисциллине, группе, курсу)
procedure TfrmDeclareListDlg.GroupBy(Value: TDeclareGroupKind);
begin
  if FGroupKind<>Value then
  begin
    FGroupKind:=Value;
    case FGroupKind of
      dgkGroup: FDeclareList.Sort(CompareGroup);
      dgkSubject: FDeclareList.Sort(CompareSubject);
      dgkCourse: FDeclareList.Sort(CompareCourse);
    end;  // case FGroupKind
    InitNodes;
  end;
end;

// инициализация узлов
procedure TfrmDeclareListDlg.InitNodes;

  function IfThen(AValue, ATrue, AFalse: boolean): boolean;
  begin
    if AValue then Result:=ATrue
      else Result:=AFalse;
  end;

  // сравнение заявок (~ от типа группировки)
  function CompareDeclare(index1, index2: integer): boolean;
  var
    pdeclare1, pdeclare2: PDeclareData;
  begin
    if (index1>=0) and (index2>=0) then
    begin
      pdeclare1:=FDeclareList[index1];
      pdeclare2:=FDeclareList[index2];
      case FGroupKind of
        dgkGroup:   Result:=(pdeclare1.grid=pdeclare2.grid);
        dgkSubject: Result:=(pdeclare1.sbid=pdeclare2.sbid);
        dgkCourse:  Result:=(pdeclare1.course=pdeclare2.course);
      end;  // case
    end
    else Result:=false;
  end;

var
  ndata: TNodeData;
  vnode: PVirtualNode;
  //pdeclare: PDeclareData;
  i,f: integer;
  //xid: int64;
begin
  vnode:=nil;

  vstDeclares.BeginUpdate;
  try
    i:=0;
    f:=-1;
    //xid:=0;
    vnode:=nil;

    vstDeclares.Clear;
    while i<FDeclareList.Count do
    begin
      //pdeclare:=FDeclareList.Items[i];
      if not CompareDeclare(i,f) then
      //if IfThen(FGroupKind=dgkGroup, xid<>pdeclare.grid, xid<>pdeclare.sbid) then
      begin
        f:=i;
        //if FGroupKind=dgkGroup then xid:=pdeclare.grid else xid:=pdeclare.sbid;
        ndata.index:=i;
        vnode:=AddTreeNode(vstDeclares,ndata, nil);
      end
      else
      begin
        ndata.index:=i;
        with AddTreeNode(vstDeclares, ndata, vnode)^ do
        begin
          CheckType:=ctCheckBox;
          if PDeclareData(FDeclareList[i]).check then CheckState:=csCheckedNormal;
        end;
        inc(i);
      end;
    end;
    vstDeclares.FullExpand();
  finally
    vstDeclares.EndUpdate;
  end;
end;

// загрузка выбранных заявок в список
function TfrmDeclareListDlg.GetList(var list: TStringList): integer;
var
  i: integer;
  pdeclare: PDeclareData;

//  vnode, vchild: PVirtualNode;
//  ndata: PNodeData;
begin
  for i:=0 to FDeclareList.Count-1 do
  begin
    pdeclare:=FDeclareList.Items[i];
    if pdeclare.check then list.Add(IntToStr(pdeclare.lid));
  end;
  Result:=list.Count;
{
  vnode:=vstDeclares.RootNode.FirstChild;
  while Assigned(vnode) do
  begin
    vchild:=vnode.FirstChild;
    while Assigned(vchild) do
    begin
      if vchild.CheckType=ctCheckBox then
        if vchild.CheckState=csCheckedNormal then
        begin
          ndata:=vstDeclares.GetNodeData(vchild);
          if Assigned(ndata) then list.Add(IntToStr(ndata.lid));
        end; // if vchild.check
      vchild:=vchild.NextSibling;
    end;  // while(vchild)
    vnode:=vnode.NextSibling;
  end;  // while(vnode)
  Result:=list.Count;
}
end;
// формирование текста для ячейки
procedure TfrmDeclareListDlg.vstDeclaresGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: WideString);
var
  ndata: PNodeData;
  pdeclare: PDeclareData;
begin
  pdeclare:=nil;
  ndata:=nil;


  ndata:=Sender.GetNodeData(Node);
  if Assigned(ndata) then
  begin
    pdeclare:=FDeclareList.Items[ndata.index];
    if Sender.GetNodeLevel(Node)=0 then
    begin
      if Column=0 then
        case FGroupKind of
          dgkGroup:   CellText:=pdeclare.grName;
          dgkSubject: CellText:=pdeclare.sbName;
          dgkCourse:  CellText:=Format('%d курс', [pdeclare.course]);
        end
      else CellText:='';
    end
    else
      case Column of
        0:
          case FGroupKind of
            dgkGroup:   CellText:=pdeclare.sbName;
            dgkSubject: CellText:=pdeclare.grName;
            dgkCourse:  CellText:=Format('%s / %s',[pdeclare.grName,pdeclare.sbName]);
          end;
        1: CellText:=IntToStr(pdeclare.hours);
        else CellText:='';
      end;
  end;
end;

procedure TfrmDeclareListDlg.vstDeclaresChecked(Sender: TBaseVirtualTree;
  Node: PVirtualNode);

{
  // проверка существования выдел. узлов
  function ExistsCheckNodes: boolean;
  var
    vnode, vchild: PVirtualNode;
  begin
    Result:=false;

    vnode:=Sender.RootNode.FirstChild;
    while Assigned(vnode) do
    begin

      vchild:=vnode.FirstChild;
      while Assigned(vchild) do
      begin
        if vchild<>Node then
          if vchild.CheckType=ctCheckBox then
            if vchild.CheckState=csCheckedNormal then
            begin
              Result:=true;
              break;
            end;
        vchild:=vchild.NextSibling;
      end;

      if Result then break else vnode:=vnode.NextSibling;

    end;
  end;
}

  procedure UpdateCheckNodes;
  var
    vnode, vchild: PVirtualNode;
    ndata: PNodeData;
    pdeclare: PDeclareData;
  begin
    Sender.BeginUpdate;
    try
      vnode:=Sender.RootNode.FirstChild;
      while Assigned(vnode) do
      begin

        vchild:=vnode.FirstChild;
        while Assigned(vchild) do
        begin
          ndata:=Sender.GetNodeData(vchild);
          if Assigned(ndata) then
          begin
            pdeclare:=FDeclareList.Items[ndata.index];
            if pdeclare.check then
            begin
              vchild.CheckType:=ctCheckBox;
              vchild.CheckState:=csCheckedNormal;
            end
            else
            begin
              vchild.CheckType:=ctCheckBox;
              vchild.CheckState:=csUncheckedNormal;
            end;
          end;  // if ndata<>nil
          vchild:=vchild.NextSibling;
        end;  // while vchild<>nil

        vnode:=vnode.NextSibling;
      end;  // while vnode<>nil
    finally
      Sender.EndUpdate;
    end;
  end;  // procedure DoFilter


var
  ndata: PNodeData;
begin
  ndata:=nil;

  // выделение не больше одной заявки на группу
  ndata:=Sender.GetNodeData(Node);
  if Assigned(ndata) then
  begin
    CheckDeclare(ndata.index);
    UpdateCheckNodes;
  end;
end;

procedure TfrmDeclareListDlg.cbGroupByChange(Sender: TObject);
begin
  if Sender is TComboBox then
    GroupBy(TDeclareGroupKind(TComboBox(Sender).ItemIndex));
end;

end.
