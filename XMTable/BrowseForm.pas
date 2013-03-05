{
  Окно просмотра структуры (для групп)
  v0.0.3  (22.04.06)
  (C) Leonid Riskov, 2006
}

unit BrowseForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ToolWin, ActnList, ImgList, Menus, DB,
  ADODB, StdCtrls, ClientModule, STypes, SForms;

type
  TfrmBrowser = class(TCustomEntityForm)
    TreeView: TTreeView;
    ActionList: TActionList;
    TreeList: TImageList;
    CaptionLabel: TLabel;
    actUpdate: TAction;
    actSelect: TAction;
    PopupMenu: TPopupMenu;
    mnuSelect: TMenuItem;
    mnuUpdate: TMenuItem;
    procedure TreeViewExpanding(Sender: TObject; Node: TTreeNode;
      var AllowExpansion: Boolean);
    procedure TreeViewDeletion(Sender: TObject; Node: TTreeNode);
    procedure TreeViewDblClick(Sender: TObject);
    procedure TreeViewGetImageIndex(Sender: TObject; Node: TTreeNode);
    procedure ActionsExecute(Sender: TObject);
    procedure ActionsUpdate(Sender: TObject);
    procedure TreeViewMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
    FData: TClientDataModule;
    FRootNode: TTreeNode;

    procedure UpdateChildNodes(ANode: TTreeNode);
    procedure OnChangeTime(var Msg: TSMChangeTime); message SM_CHANGETIME;

  public
    { Public declarations }
    constructor Create(AOwner: TComponent; AParent: TWinControl;
        AData: TClientDataModule); reintroduce;

    procedure Clear;
    function GetEntityData(var AEntity: TEntityData): boolean; override;
    function GetParentData(var AEntity: TEntityData): boolean; override;
    function GetEntityKind: TEntityKind; override;

  end;

implementation

uses
  ADOInt, SUtils;

{$R *.dfm}

{ TfrmBrowser }

constructor TfrmBrowser.Create(AOwner: TComponent; AParent: TWinControl;
    AData: TClientDataModule);
begin
  inherited Create(AOwner);
  BorderStyle:=bsNone;
  Align:=alClient;
  Parent:=AParent;

  FData:=AData;

  TreeList.ResourceLoad(rtBitmap, 'TREES', clFuchsia);

  TreeView.Items.BeginUpdate;
  try
    FRootNode:=TreeView.Items.AddChild(nil, 'Группы');
    FRootNode.HasChildren:=true;
    FRootNode.Expand(false);
  finally
    TreeView.Items.EndUpdate;
  end;
end;

procedure TfrmBrowser.TreeViewExpanding(Sender: TObject; Node: TTreeNode;
  var AllowExpansion: Boolean);

  procedure LoadFirstLevel(ANodes: TTreeNodes; ANode: TTreeNode);
  var
    i: integer;
  begin
    for i:=0 to 4 do
      ANodes.AddChild(ANode, IntToStr(i+1)+' курс').HasChildren:=true;
  end;  // procedure

  function LoadGroup(ANodes: TTreeNodes; ANode: TTreeNode): boolean;
  var
    pentity: PEntityData;
    crs: byte;
    s: string;
    rs: _Recordset;
  begin
    pentity:=nil;

    crs:=StrToInt(Copy(ANode.Text,0,1));
    rs:=FData.dbv_GetGroupCrs(crs);
    if Assigned(rs) then
      try
        Result:=(not rs.EOF);
        while not rs.EOF do
        begin
          New(pentity);
          pentity.kind:=ekGroup;
          pentity.id:=rs.Fields['grid'].Value;
          pentity.name:=VarToStr(rs.Fields['grName'].Value);
          if bDebugMode then s:=Format('%d=%s',[pentity.id,pentity.name])
            else s:=pentity.name;
          ANodes.AddChildObject(ANode,s,pentity).HasChildren:=true;
          rs.MoveNext;
        end;
      finally
        rs.Close;
        rs:=nil;
      end
    else Result:=false;

  end;  // function LoadGroup

  // загрузка дисциплин
  function LoadSubject(ANodes: TTreeNodes; ANode: TTreeNode): boolean;
  var
    grid: int64;
    pentity: PEntityData;
    s: string;
    rs: _Recordset;
  begin
    Result:=false;
    pentity:=nil;

    if Assigned(ANode.Data) then
    begin
      grid:=PEntityData(ANode.Data).id;
      rs:=FData.dbv_GetSubjGrp_e(grid);
      if Assigned(rs) then
      try
        Result:=(not rs.EOF);
        rs.Sort:='sbName ASC';
        while not rs.EOF do
        begin
          New(pentity);
          pentity.kind:=ekExamSubject;
          pentity.id:=rs.Fields['wpid'].Value;
          pentity.name:=VarToStr(rs.Fields['sbName'].Value);

          if bDebugMode then s:=Format('%d=%s',[pentity.id,pentity.name])
            else s:=pentity.name;
          ANodes.AddChildObject(ANode,s,pentity);
          rs.MoveNext;
        end;
      finally
        rs.Close;
        rs:=nil;
      end;
    end;
  end;  // function LoadSubject

var
  Nodes: TTreeNodes;
begin
  if not Assigned(Node.getFirstChild()) then
  begin
    Nodes:=Node.Owner;
    Nodes.BeginUpdate;
    try
      case Node.Level of

        0:  // Root level
          begin
            LoadFirstLevel(Nodes, Node);
            AllowExpansion:=true;
          end;

        1:  // course level
          if LoadGroup(Nodes,Node) then AllowExpansion:=true
            else Node.HasChildren:=false;

        2:  // subject level
          if LoadSubject(Nodes,Node) then AllowExpansion:=true
            else Node.HasChildren:=false;

      end;  // case(Node.Level)
    finally
      Nodes.EndUpdate;
    end;
  end;  // if(FirstChild<>nil)
end;

// обновление подузлов
procedure TfrmBrowser.UpdateChildNodes(ANode: TTreeNode);
var
  Nodes: TTreeNodes;
  e: boolean;
begin
  if ANode.Level>0 then
  begin
    Nodes:=ANode.Owner;
    Nodes.BeginUpdate;
    try
      e:=ANode.Expanded;
      if Assigned(ANode.getFirstChild()) then ANode.DeleteChildren;
      ANode.HasChildren:=true;
      if e then ANode.Expand(false);
    finally
      Nodes.EndUpdate;
    end;
  end;
end;

procedure TfrmBrowser.Clear;
var
  node: TTreeNode;
begin
  TreeView.Items.BeginUpdate;
  try
    node:=FRootNode.getFirstChild;
    while Assigned(node) do
    begin
      node.DeleteChildren;
      node.HasChildren:=true;
      node:=node.getNextSibling();
    end;
//    FRootNode.DeleteChildren;
//    FRootNode.HasChildren:=true;
  finally
    TreeView.Items.EndUpdate;
  end;
end;

procedure TfrmBrowser.TreeViewDeletion(Sender: TObject; Node: TTreeNode);
begin
  if Assigned(Node.Data) then
  begin
    Dispose(PEntityData(Node.Data));
    Node.Data:=nil;
  end;
end;

procedure TfrmBrowser.TreeViewDblClick(Sender: TObject);
var
  Node: TTreeNode;
begin
  if Sender is TTreeView then
  begin
    Node:=TTreeView(Sender).Selected;
    if Assigned(Node) then
      if Assigned(Node.Data) and (Node.Level>=2) then
        DoEntityChange(PEntityData(Node.Data)^);
  end;
end;

procedure TfrmBrowser.TreeViewGetImageIndex(Sender: TObject;
  Node: TTreeNode);
begin
  case Node.Level of
    0:  Node.ImageIndex:=0;
    1:  if Node.Expanded then Node.ImageIndex:=2  else Node.ImageIndex:=1;
    2:  Node.ImageIndex:=4;
    3:  Node.ImageIndex:=5;
  end; // case
  Node.SelectedIndex:=Node.ImageIndex;
end;

// действия
procedure TfrmBrowser.ActionsExecute(Sender: TObject);
begin
  case (Sender as TAction).Tag of
    1:  // select node
      if Assigned(TreeView.Selected) then TreeView.OnDblClick(TreeView);
    2:  // update node
      if Assigned(TreeView.Selected) then UpdateChildNodes(TreeView.Selected);
  end;
end;

// обновление
procedure TfrmBrowser.ActionsUpdate(Sender: TObject);

  function SelectedNode(ANode: TTreeNode): boolean;
  begin
    if Assigned(ANode) then Result:=(ANode.Level=2)
      else Result:=false;
  end;

  function UpdatedNode(ANode: TTreeNode): boolean;
  begin
    if Assigned(ANode) then Result:=(ANode.Level in [1,2]) else Result:=false;
  end;

begin
  case (Sender as TAction).Tag of
    1:  // select node
      TAction(Sender).Enabled:=SelectedNode(TreeView.Selected);
    2:  // update node
      TAction(Sender).Enabled:=UpdatedNode(TreeView.Selected);
  end;
end;

procedure TfrmBrowser.TreeViewMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  node: TTreeNode;
begin
  if Button=mbRight then
  begin
    node:=TTreeView(Sender).GetNodeAt(X,Y);
    if Assigned(node) then node.Selected:=true;
  end;
end;

procedure TfrmBrowser.OnChangeTime(var Msg: TSMChangeTime);

  // удаление дисциплин
  procedure DeleteSubjects;

    procedure DeleteChildren(node: TTreeNode; level: integer);
    var
      item: TTreeNode;
    begin
      if node.Level=level-1 then
      begin
        node.DeleteChildren;
        node.HasChildren:=true;
      end
      else
        if node.Level<level-1 then
        begin
          item:=node.getFirstChild;
          while Assigned(item) do
          begin
            DeleteChildren(item,level);
            item:=item.getNextSibling;
          end;
        end;
    end;  // procedure DeleteChildren

  var
    node: TTreeNode;
  begin

    node:=FRootNode.getFirstChild;     // уровень курсов

    TreeView.Items.BeginUpdate;
    try
      while Assigned(node) do
      begin
        DeleteChildren(node,3);
        node:=node.getNextSibling;
      end;
    finally
      TreeView.Items.EndUpdate;
    end;

  end;  // procedure DeleteSubjects

begin
  case Msg.Msg of
    SM_CHANGETIME:   // изм-ние семестра
      if (Msg.Flags and CT_YEAR)=CT_YEAR then Clear else
        if (Msg.Flags and CT_SEM)=CT_SEM then DeleteSubjects;
  end;
end;

// возвращает тип тек. объекта модели (06.05.06)
function TfrmBrowser.GetEntityKind: TEntityKind;
begin
  Result:=ekNone;
  if Assigned(TreeView.Selected) then
    if Assigned(TreeView.Selected.Data) then
      Result:=PEntityData(TreeView.Selected.Data).kind;
end;

// определение тек. объекта модели (06.05.06)
function TfrmBrowser.GetEntityData(var AEntity: TEntityData): boolean;
var
  pentity: PEntityData;
  node: TTreeNode;
begin
  Result:=false;

  node:=TreeView.Selected;
  if Assigned(node) then
  begin
    pentity:=node.Data;
    Result:=Assigned(pentity);
    if Result then
    begin
       AEntity.kind:=pentity.kind;
       AEntity.id:=pentity.id;
       AEntity.name:=pentity.name;
     end;
  end;
end;

// определение объекта-предка модели  (06.05.06)
function TfrmBrowser.GetParentData(var AEntity: TEntityData): boolean;
var
  pentity: PEntityData;
  node: TTreeNode;
begin
  Result:=false;
  // опр-ние только для дисциплин-экзаменов
  node:=TreeView.Selected;
  if Assigned(node) then
    if node.Level=3 then
    begin
      pentity:=node.Parent.Data;
      Result:=Assigned(pentity);
      if Result then
      begin
        AEntity.kind:=pentity.kind;
        AEntity.id:=pentity.id;
        AEntity.name:=pentity.name;
      end;
    end;  // if(level=3)
end;

end.
