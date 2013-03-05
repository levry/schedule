{
  Окно просмотра структуры (полная)
  v0.2.7 (13/09/06)
}

unit BrowserForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ImgList, DB, ADODB, SConsts, SIntf,
  StdCtrls, ExtCtrls, ActnList, ToolWin, Menus, HTMLabel, SCategory, STypes;

type
  TfmBrowser = class(TFrame)
    TreeView: TTreeView;
    BrowseImageList: TImageList;
    CaptionLabel: TLabel;
    ActionList: TActionList;
    actViewPerformKaf: TAction;
    actViewFacultyKaf: TAction;
    actUpdate: TAction;
    actSelect: TAction;
    ToolBar: TToolBar;
    btnViewKafAll: TToolButton;
    btnViewKafGrp: TToolButton;
    PopupMenu: TPopupMenu;
    btnUpdate: TMenuItem;
    btnSelect: TMenuItem;
    HTMLabel: THTMLabel;
    actViewDeclare: TAction;
    btnViewDeclare: TToolButton;
    procedure TreeViewExpanding(Sender: TObject; Node: TTreeNode;
      var AllowExpansion: Boolean);
    procedure TreeViewGetImageIndex(Sender: TObject; Node: TTreeNode);
    procedure TreeViewDeletion(Sender: TObject; Node: TTreeNode);
    procedure TreeViewDblClick(Sender: TObject);
    procedure ActionsExecute(Sender: TObject);
    procedure ActionsUpdate(Sender: TObject);
    procedure TreeViewMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure HTMLabelAnchorClick(Sender: TObject; Anchor: String);
    procedure TreeViewKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    FBrowseMode: TBrowseMode;        // режим
    FLetter: string;

    function GetRootText: string;
    procedure DoBrowseMode(Mode: TBrowseMode);
//    function LoadNodes(ANode: TTreeNode; AKind: TObjectKind; AParent: TBrowseObject): boolean;
    function ExpandLevel(ANode: TTreeNode): boolean;
    procedure UpdateChildNodes(ANode: TTreeNode);
    procedure DeleteSubjects;
  private
    { Private declarations }
    tnRoot: TTreeNode;         // корневой узел

    FOnChange: TNotifyEvent;
    procedure OnChangeSem(var Msg: TSMChangeTime); message SM_CHANGETIME;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent; AParent: TWinControl; AMode: TBrowseMode);

    procedure Clear;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

implementation

uses
  TimeModule, SUtils;

{$R *.dfm}

constructor TfmBrowser.Create(AOwner: TComponent; AParent: TWinControl; AMode: TBrowseMode);
begin
  inherited Create(AOwner);

  Align:=alClient;
  Parent:=AParent;
  BrowseImageList.ResourceLoad(rtBitmap,'SBROWSE',clFuchsia);

  FLetter:='А';
  FBrowseMode:=AMode;
  HTMLabel.HTMLText.Add(GetHTMLAlphabet);
  HTMLabel.Visible:=(FBrowseMode=bmDeclare);

  tnRoot:=TreeView.Items.AddChildObject(nil,
      GetRootText, CreateBrowseObject(okRoot,nil,nil));
  tnRoot.HasChildren:=true;
end;

function TfmBrowser.GetRootText: string;
begin
  case FBrowseMode of
    bmPerformKafedra,
    bmFacultyKafedra:  Result:='Кафедры';
    bmDeclare:         Result:=Format('Дисциплины: %s...',[AnsiUpperCase(FLetter)]);
    else Result:='';
  end;
end;

// изм-ние режима
procedure TfmBrowser.DoBrowseMode(Mode: TBrowseMode);
begin
  if FBrowseMode<>Mode then
  begin
    FBrowseMode:=Mode;
    tnRoot.Text:=GetRootText;;
    TreeView.Repaint;
    HTMLabel.Visible:=(FBrowseMode=bmDeclare);
    UpdateChildNodes(tnRoot);
  end;
end;

// обновление подузлов
procedure TfmBrowser.UpdateChildNodes(ANode: TTreeNode);
var
  Nodes: TTreeNodes;
  e: boolean;
begin
  Nodes:=ANode.Owner;
  Nodes.BeginUpdate;
  try
    e:=ANode.Expanded;
    if Assigned(ANode.getFirstChild()) then ANode.DeleteChildren;
    ANode.HasChildren:=true;
    if e or (FBrowseMode=bmDeclare) then ANode.Expand(false);
  finally
    Nodes.EndUpdate;
    Nodes:=nil;
  end;
end;

procedure TfmBrowser.DeleteSubjects;

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
  node, child: TTreeNode;
begin
  if FBrowseMode<>bmDeclare then
  begin
    node:=tnRoot.getFirstChild;
    while Assigned(node) do
    begin
      child:=node.getFirstChild;
      while Assigned(child) do
      begin
        if AnsiCompareText(child.Text,'Группы')=0 then DeleteChildren(child,4) else
          if AnsiCompareText(child.Text,'Заявки')=0 then DeleteChildren(child,3);
        child:=child.getNextSibling;
      end;
      node:=node.getNextSibling;
    end;
  end;  // if(not bmSubject)
end;

procedure TfmBrowser.Clear;
begin
  TreeView.Items.BeginUpdate;
  try
    tnRoot.DeleteChildren;
    tnRoot.HasChildren:=true;
  finally
    TreeView.Items.EndUpdate;
  end;
end;

// раскрытие уровня (загрузка дочер. объектов)
function TfmBrowser.ExpandLevel(ANode: TTreeNode): boolean;
var
  pobj, obj: TBrowseObject;
  kind: TObjectKind;
  childs: boolean;
  ds: TADODataSet;
  rs: _Recordset;
  s: string;
  Nodes: TTreeNodes;
begin
  Result:=false;
  if Assigned(ANode.Data) then
  begin
    rs:=nil;

    pobj:=TBrowseObject(ANode.Data);
    case pobj.Kind of
      okRoot:      // корень (bmKafedra: кафедры; bmDeclare: дисциплины)
        begin
          case FBrowseMode of
            bmPerformKafedra:
              begin
                rs:=dmMain.dbv_GetPerformKaf(dmMain.FacultyID);
                kind:=okKafedra;
              end;
            bmFacultyKafedra:
              begin
                rs:=dmMain.dbv_GetFacultyKaf(dmMain.FacultyID); 
                kind:=okKafedra;
              end;
            bmDeclare:
              begin
                rs:=dmMain.dbv_GetSubjWP(FLetter);
                kind:=okDeclare;
              end;
          end;  // case
          childs:=true;
        end;

      okKafedra:   // кафедра (загрузка: "группы" и "заявки")
        begin
          rs:=nil;
          obj:=CreateBrowseObject(okGroups,pobj.Id,pobj.Name,pobj);
          ANode.Owner.AddChildObject(ANode,'Группы',obj).HasChildren:=true;
          obj:=CreateBrowseObject(okDeclares,pobj.Id,pobj.Name,pobj);
          ANode.Owner.AddChildObject(ANode,'Заявки',obj).HasChildren:=true;
        end;

      okGroup:     // группа (загрузка: дисциплины)
        if FBrowseMode in [bmPerformKafedra,bmFacultyKafedra] then
        begin
          rs:=dmMain.dbv_GetSubjGrp(pobj.Id);
          kind:=okSubject;
          childs:=false;
        end;

      okSubject:   // дисциплина ()
        begin
          rs:=nil;
          childs:=false;
        end;

      okGroups:    // "группы" (загрузка: группы)
        begin
          rs:=dmMain.dbv_GetGrpKaf(pobj.id);
          kind:=okGroup;
          childs:=true;
        end;

      okDeclares:  // "заявки" (загрузка: дисциплины-заявки)
        begin
          rs:=dmMain.dbv_GetSubjKaf(pobj.Id);
          kind:=okDeclare;
          childs:=false;
        end;

      okDeclare:   // заявки (bmSubject: групп)
        if FBrowseMode=bmDeclare then
        begin
          rs:=dmMain.dbv_GetGrpSubj(pobj.Id);
          kind:=okGroup;
          childs:=false;
        end;
    end;  // case(kind)

    if Assigned(rs) then
    begin
      ds:=CreateDataSet(rs);
      if Assigned(ds) then
      try

        Nodes:=ANode.Owner;
        Nodes.BeginUpdate;
        try
          while not ds.Eof do
          begin
            obj:=CreateBrowseObject(kind,ds.Fields,pobj);
            if bDebugMode then s:=obj.Text else s:=obj.Name;
            Nodes.AddChildObject(ANode,s,obj).HasChildren:=childs;
            ds.Next;
          end;
        finally
          Nodes.EndUpdate;
          Nodes:=nil;
        end;

      finally
        ds.Close;
        ds.Free;
      end;
    end;  // if (rs<>nil)
  end;
  Result:=Assigned(ANode.getFirstChild());
end;

procedure TfmBrowser.TreeViewExpanding(Sender: TObject; Node: TTreeNode;
  var AllowExpansion: Boolean);
var
  TreeNodes: TTreeNodes;
begin
  if Node.getFirstChild<>nil then exit;

  Cursor:=crHourGlass;

  TreeNodes:=Node.Owner;
  TreeNodes.BeginUpdate;
  try
    if ExpandLevel(Node) then AllowExpansion:=true
      else Node.HasChildren:=false;
  finally
    TreeNodes.EndUpdate;
    Cursor:=crDefault;
  end;

end;

procedure TfmBrowser.TreeViewGetImageIndex(Sender: TObject;
  Node: TTreeNode);
var
  obj: TBrowseObject;
begin
  if Assigned(Node.Data) then
  begin
    obj:=Node.Data;
    case obj.Kind of
      okRoot:
        case FBrowseMode of
          bmPerformKafedra,
          bmFacultyKafedra: Node.ImageIndex:=1;
          bmDeclare:        Node.ImageIndex:=5;
        end;
      okKafedra:            Node.ImageIndex:=2;
      okGroup:              Node.ImageIndex:=4;
      okSubject:            Node.ImageIndex:=5;
      okGroups, okDeclares: Node.ImageIndex:=3;
      okDeclare:            Node.ImageIndex:=5;
    end;  // case
  end;
  Node.SelectedIndex:=Node.ImageIndex;
end;

procedure TfmBrowser.TreeViewDeletion(Sender: TObject; Node: TTreeNode);
begin
  if Assigned(Node.Data) then
  begin
    TBrowseObject(Node.Data).Free;
//    Dispose(PInt64(Node.Data));
    Node.Data:=nil;
  end;
end;

procedure TfmBrowser.TreeViewDblClick(Sender: TObject);
var
  Node: TTreeNode;
  NodeObject: TBrowseObject;
begin
  if Assigned(FOnChange) then
  begin
    Node:=TTreeView(Sender).Selected;
    if Assigned(Node) then
      if Assigned(Node.Data) then
      begin
        NodeObject:=Node.Data;
        FOnChange(NodeObject);
      end; // if Node.Data<>nil
  end;
end;

procedure TfmBrowser.OnChangeSem(var Msg: TSMChangeTime);
begin
  case Msg.Msg of
    SM_CHANGETIME:   // изм-ние семестра
      if (Msg.Flags and CT_YEAR)=CT_YEAR then Clear
      else
        if (Msg.Flags and CT_SEM)=CT_SEM then
          case FBrowseMode of
            bmPerformKafedra,
            bmFacultyKafedra:
              DeleteSubjects;
            bmDeclare:
              UpdateChildNodes(tnRoot);
          end;  // case (FBrowseMode)
  end;
end;

procedure TfmBrowser.ActionsExecute(Sender: TObject);
begin
  case (Sender as TAction).Tag of
    -1: // обновить
      if TreeView.Focused then
        if Assigned(TreeView.Selected) then UpdateChildNodes(TreeView.Selected);

    1:  // кафедры-исполнители
      DoBrowseMode(bmPerformKafedra);

    2:  // кафедры факультета
      DoBrowseMode(bmFacultyKafedra);

    3:  // выбрать
      if TreeView.Focused then
        if Assigned(TreeView.Selected) then
          TreeViewDblClick(TreeView);

    4:  // дисципилны-заявки
      DoBrowseMode(bmDeclare);

    else raise Exception.CreateFmt('Unknown action (tag=%d)', [TAction(Sender).Tag]);
  end;
end;

procedure TfmBrowser.ActionsUpdate(Sender: TObject);

  // проверка на обновление узла
  function UpdatedNode(node: TTreeNode): boolean;
  var
    obj: TBrowseObject;
  begin
    Result:=false;
    if Assigned(node) then
      if Assigned(node.Data) then
      begin
        obj:=TBrowseObject(node.Data);
        case FBrowseMode of
          bmPerformKafedra,
          bmFacultyKafedra: Result:=(obj.Kind<>okSubject) and (obj.Kind<>okDeclare);
          bmDeclare:    Result:=(obj.Kind=okRoot) or (obj.Kind=okDeclare);
        end;
      end
      else Result:=true;
  end;  // function UpdatedNode

  // проверка на выбор узла
  function SelectedNode(node: TTreeNode): boolean;
  begin
    if Assigned(node) then Result:=Assigned(node.Data) else Result:=false;
  end;  // function SelectedNode

begin
  case (Sender as TAction).Tag of
    -1:
      TAction(Sender).Enabled:=UpdatedNode(TreeView.Selected);

    1: // кафедры-исполнители
      TAction(Sender).Checked:=(FBrowseMode=bmPerformKafedra);

    2: // кафедры факультета
      TAction(Sender).Checked:=(FBrowseMode=bmFacultyKafedra);

    3:  // выбрать
      TAction(Sender).Enabled:=SelectedNode(TreeView.Selected);

    4:  // дисциплины-заявки
      TAction(Sender).Checked:=(FBrowseMode=bmDeclare);

    else raise Exception.CreateFmt('Unknown action (tag=%d)', [TAction(Sender).Tag]);
  end;
end;

procedure TfmBrowser.TreeViewMouseUp(Sender: TObject;
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

procedure TfmBrowser.HTMLabelAnchorClick(Sender: TObject; Anchor: String);
begin
  if FBrowseMode=bmDeclare then
  begin
    FLetter:=Anchor[1];
    tnRoot.Text:=GetRootText;
    UpdateChildNodes(tnRoot);
  end;
end;

procedure TfmBrowser.TreeViewKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Assigned(TTreeView(Sender).Selected) then
    case Key of
      VK_RETURN: actSelect.Execute;
      VK_F5:     actUpdate.Execute;
    end;
end;

end.
