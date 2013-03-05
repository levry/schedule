{
  Окно просмотра структуры (для групп)
  v0.0.5  (14/09/06)
}

unit BrowseForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ChildForm, ToolWin, ActnList, ImgList, Menus, DB,
  ADODB, StdCtrls;

type
  TGroupKind = (gkKafedra, gkCourse);

  TObjectChange = procedure(Sender: TObject; id: int64; name: string) of object;

  TfrmBrowser = class(TChildForm)
    TreeView: TTreeView;
    ToolBar: TToolBar;
    ActionList: TActionList;
    TreeList: TImageList;
    actGroupKafedra: TAction;
    actGroupCourse: TAction;
    btnGroupBy: TToolButton;
    mnuGroupBy: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    setDBView: TADODataSet;
    CaptionLabel: TLabel;
    actGroupView: TAction;
    actUpdate: TAction;
    actSelect: TAction;
    PopupMenu: TPopupMenu;
    mnuSelect: TMenuItem;
    mnuUpdate: TMenuItem;
    procedure FormCreate(Sender: TObject);
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

    FOnGroupChange: TObjectChange;
    FOnKafedraChange: TObjectChange;

    FGroupKind: TGroupKind;
    tnRoot: TTreeNode;

    procedure GroupItems(AGroupKind: TGroupKind);
    procedure DoGroupItems(AGroupKind: TGroupKind);
    procedure UpdateChildNodes(ANode: TTreeNode);

  public
    { Public declarations }
    procedure Clear;
    
    property OnGroupChange: TObjectChange read FOnGroupChange write FOnGroupChange;
    property OnKafedraChange: TObjectChange read FOnKafedraChange write FOnKafedraChange;

  end;

implementation

uses
  WorkModule, ADOInt,
  SDBUtils, SUtils;

{$R *.dfm}

{ TfrmBrowser }

procedure TfrmBrowser.FormCreate(Sender: TObject);
begin
  TreeList.ResourceLoad(rtBitmap, 'TREES', clFuchsia);


  FGroupKind:=gkCourse;
//  if FGroupKind=gkKafedra then btnGroupBy.ImageIndex:=5
//    else btnGroupBy.ImageIndex:=6;

  tnRoot:=TreeView.Items.AddChild(nil, 'Группы');
  GroupItems(FGroupKind);
//  if tnRoot.Count>0 then tnRoot.Expand(false);
end;

procedure TfrmBrowser.DoGroupItems(AGroupKind: TGroupKind);
begin
  if FGroupKind<>AGroupKind then
  begin
    FGroupKind:=AGroupKind;
    GroupItems(AGroupKind);
//    if FGroupKind=gkKafedra then btnGroupBy.ImageIndex:=5
//      else btnGroupBy.ImageIndex:=6;
  end;
end;

procedure TfrmBrowser.GroupItems(AGroupKind: TGroupKind);
begin
  if tnRoot.Count>0 then tnRoot.DeleteChildren;
  tnRoot.HasChildren:=true;
  tnRoot.Expand(false);
end;

procedure TfrmBrowser.TreeViewExpanding(Sender: TObject; Node: TTreeNode;
  var AllowExpansion: Boolean);


  procedure LoadFirstLevel(ANodes: TTreeNodes; ANode: TTreeNode);
  var
    i: integer;
    pid: PInt64;
    s: string;

  begin
    if FGroupKind=gkKafedra then
    begin
      if GetRecordset(dmWork.dbv_GetFacultyKaf(dmWork.FacultyID),setDBView) then
        try
          while not setDBView.Eof do
          begin
            New(pid);
            pid^:=setDBView.FieldByName('kid').AsInteger;
            if bDebugMode then
              s:=setDBView.FieldByName('kid').AsString+'='+setDBView.FieldByName('kName').AsString
            else s:=setDBView.FieldByName('kName').AsString;
            ANodes.AddChildObject(ANode,s,pid).HasChildren:=true;
            setDBView.Next;
          end;  // while
        finally
          setDBView.Close;
        end; // if
    end
    else
    begin
      for i:=0 to 4 do
      begin
        Node:=TreeView.Items.AddChild(tnRoot, IntToStr(i+1)+' курс');
        Node.HasChildren:=true;
      end
    end;
  end;  // procedure LoadFirstLevel

  function LoadGroupKaf(ANodes: TTreeNodes; ANode: TTreeNode): boolean;
  var
    pkid, pgrid: PInt64;
    s: string;
  begin
    pkid:=nil;
    pgrid:=nil;

    pkid:=ANode.Data;
    if GetRecordset(dmWork.dbv_GetGrpKaf(pkid^),setDBView) then
      try
        Result:=not setDBView.Eof;
        while not setDBView.Eof do
        begin
          New(pgrid);
          pgrid^:=setDBView.FieldByName('grid').AsInteger;
          if bDebugMode then
            s:=setDBView.FieldByName('grid').AsString+'='+setDBView.FieldByName('grName').AsString
          else s:=setDBView.FieldByName('grName').AsString;
          ANodes.AddChildObject(ANode,s,pgrid);
          setDBView.Next;
        end;
      finally
        setDBView.Close;
      end
    else Result:=false;

  end;

  function LoadGroupCrs(ANodes: TTreeNodes; ANode: TTreeNode): boolean;
  var
    pgrid: PInt64;
    crs: byte;
    s: string;
  begin
    pgrid:=nil;

    crs:=StrToInt(Copy(ANode.Text,0,1));
    if GetRecordset(dmWork.dbv_GetGroupCrs(crs),setDBView) then
      try
        Result:=not SetDBView.Eof;
        while not setDBView.Eof do
        begin
          New(pgrid);
          pgrid^:=setDBView.FieldByName('grid').AsInteger;
          if bDebugMode then
            s:=setDBView.FieldByName('grid').AsString+'='+setDBView.FieldByName('grName').AsString
          else s:=setDBView.FieldByName('grName').AsString;
          ANodes.AddChildObject(ANode,s,pgrid);
          setDBView.Next;
        end;
      finally
        setDBView.Close;
      end
    else Result:=false;

  end;

var
  Nodes: TTreeNodes;
begin
  if not Assigned(Node.getFirstChild()) then
  begin
    Nodes:=Node.Owner;
    Nodes.BeginUpdate;
    try
      case Node.Level of
        0:  // root level
          begin
            LoadFirstLevel(Nodes,Node);
            AllowExpansion:=true;
          end;

        1:  // kafedra|course level
          if FGroupKind=gkKafedra then
          begin
            // загрузка групп кафедр
            if LoadGroupKaf(Nodes,Node) then AllowExpansion:=true
              else Node.HasChildren:=false;
          end
          else
            // загрузка групп курса
            if LoadGroupCrs(Nodes,Node) then AllowExpansion:=true
              else Node.HasChildren:=false;

      end;  // case(Node.Level)
    finally
      Nodes.EndUpdate;
    end;
  end;
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
  end
  else GroupItems(FGroupKind);
end;

procedure TfrmBrowser.Clear;
begin
  TreeView.Items.BeginUpdate;
  try
    tnRoot.DeleteChildren;
    tnRoot.HasChildren:=true;
  finally
    TreeView.Items.EndUpdate;
  end;

//  FGroupKind:=gkCourse;
//  GroupItems(gkCourse);
end;
               
procedure TfrmBrowser.TreeViewDeletion(Sender: TObject; Node: TTreeNode);
begin
  if Assigned(Node.Data) then
  begin
    Dispose(PInt64(Node.Data));
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
      case Node.Level of
        1:  // only kafedra
          if FGroupKind=gkKafedra then
            if Assigned(Node.Data) then
              if Assigned(FOnKafedraChange) then
                FOnKafedraChange(Self, PInt64(Node.Data)^, Node.Text);
        2:  // group
          if Assigned(Node.Data) then
            if Assigned(FOnGroupChange) then
              FOnGroupChange(Self,PInt64(Node.Data)^,Node.Text);
      end; // case
  end;
end;

procedure TfrmBrowser.TreeViewGetImageIndex(Sender: TObject;
  Node: TTreeNode);
begin
  case Node.Level of
    0: Node.ImageIndex:=0;
    1:
      if FGroupKind=gkKafedra then Node.ImageIndex:=3
      else
        if Node.Expanded then Node.ImageIndex:=2
          else Node.ImageIndex:=1;
    2:
      Node.ImageIndex:=4;
  end; // case
  Node.SelectedIndex:=Node.ImageIndex;
end;

// действия
procedure TfrmBrowser.ActionsExecute(Sender: TObject);
var
  btn: TToolButton;
begin
  case (Sender as TAction).Tag of
    1:  // group by kafedries
      DoGroupItems(gkKafedra);
    2:  // group by course
      DoGroupItems(gkCourse);
    3:  // group view
      if TAction(Sender).ActionComponent is TToolButton then
      begin
        btn:=TToolButton(TAction(Sender).ActionComponent);
        if Assigned(btn.DropdownMenu) then btn.CheckMenuDropdown;
      end;
    4:  // update node
      if Assigned(TreeView.Selected) then UpdateChildNodes(TreeView.Selected);
    5:  // select node
      if Assigned(TreeView.Selected) then TreeView.OnDblClick(TreeView);
  end;
end;

// обновление
procedure TfrmBrowser.ActionsUpdate(Sender: TObject);

  function SelectedNode(ANode: TTreeNode): boolean;
  begin
    if Assigned(ANode) then
      Result:=((ANode.Level=1) and (FGroupKind=gkKafedra)) or (ANode.Level=2)
    else Result:=false;
  end;

  function UpdatedNode(ANode: TTreeNode): boolean;
  begin
    if Assigned(ANode) then Result:=(ANode.Level<>2) else Result:=false;
  end;

begin
  case (Sender as TAction).Tag of
    1:  // group by kafedries
      TAction(Sender).Checked:=(FGroupKind=gkKafedra);
    2:  // group by course
      TAction(Sender).Checked:=(FGroupKind=gkCourse);
    3:  // group view
      if FGroupKind=gkKafedra then TAction(Sender).ImageIndex:=actGroupKafedra.ImageIndex
        else TAction(Sender).ImageIndex:=actGroupCourse.ImageIndex;
    4:  // update node
      TAction(Sender).Enabled:=UpdatedNode(TreeView.Selected);
    5:  // select node
      TAction(Sender).Enabled:=SelectedNode(TreeView.Selected);
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

end.
