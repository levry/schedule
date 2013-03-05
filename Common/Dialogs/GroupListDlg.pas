{
  Диалог списка групп
  v0.0.2  (18/09/06)
}

unit GroupListDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Menus, Buttons, ADOInt;

type
  TLoadGroupFunc = function (nCourse: byte): _Recordset of object;

  TfrmGroupListDlg = class(TForm)
    btnOk: TButton;
    btnCancel: TButton;
    CourseMenu: TPopupMenu;
    mnuCourse1: TMenuItem;
    mnuCourse2: TMenuItem;
    mnuCourse3: TMenuItem;
    mnuCourse4: TMenuItem;
    mnuCourse5: TMenuItem;
    ListBox: TListBox;
    btnGroupCourse: TSpeedButton;
    procedure ListBoxDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure MenuCourseClick(Sender: TObject);
    procedure btnGroupCourseClick(Sender: TObject);
    procedure ListBoxDblClick(Sender: TObject);
  private
    { Private declarations }
    FCourse: byte;
    FLoadGroupFunc: TLoadGroupFunc;
    procedure DoLoadGroup(course: byte);

    function Get_grid: int64;
    function Get_grName: string;
    function Get_group: string;

  public
    { Public declarations }
    property grid: int64 read Get_grid;
    property grName: string read Get_grName;
    property group: string read Get_group;

  end;

function GetGroupFromList(nCourse: byte; LoadGroupFunc: TLoadGroupFunc;
    var sResult: string): boolean;

implementation

uses
  SUtils;

{$R *.dfm}

function GetGroupFromList(nCourse: byte; LoadGroupFunc: TLoadGroupFunc;
    var sResult: string): boolean;
var
  frmDlg: TfrmGroupListDlg;
begin
  Result:=false;

  frmDlg:=TfrmGroupListDlg.Create(Application);
  try
    frmDlg.FLoadGroupFunc:=LoadGroupFunc;
    frmDlg.DoLoadGroup(nCourse);

    if frmDlg.ShowModal=mrOk then
    begin
      Result:=true;
      sResult:=frmDlg.group;
    end;

  finally
    frmDlg.Free;
  end;
end;

{ TfrmGroupListDlg }

function TfrmGroupListDlg.Get_grid: int64;
var
  i: integer;
begin
  i:=ListBox.ItemIndex;
  if i>=0 then Result:=GetID(ListBox.Items[i])
    else Result:=-1;
end;

function TfrmGroupListDlg.Get_grName: string;
var
  i: integer;
begin
  i:=ListBox.ItemIndex;
  if i>=0 then Result:=SUtils.GetValue(ListBox.Items[i]) else Result:='';
end;

function TfrmGroupListDlg.Get_group: string;
var
  i: integer;
begin
  i:=ListBox.ItemIndex;
  if i>=0 then Result:=ListBox.Items[i] else Result:='';
end;

// загрузка групп курса
procedure TfrmGroupListDlg.DoLoadGroup(course: byte);
var
  rs: _Recordset;
  s: string;
begin
  Assert(Assigned(FLoadGroupFunc),
    'A8B75B83-7283-4EED-8781-69E29B4E1A1A'#13'DoLoadGroup: FLoadGroupFunc is nil'#13);

  if FCourse<>course then
  begin
    FCourse:=course;

    ListBox.Clear;
    rs:=FLoadGroupFunc(FCourse);
    if Assigned(rs) then
    try
      while not rs.EOF do
      begin
        s:=VarToStr(rs.Fields['grid'].Value)+'='+VarToStr(rs.Fields['grName'].Value);
        ListBox.AddItem(s, nil);
        rs.MoveNext;
      end;
    finally
      rs.Close;
      rs:=nil;
    end;

  end;  // if(FCourse<>course)
end;

procedure TfrmGroupListDlg.ListBoxDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  FCanvas: TCanvas;
  s: string;
begin
  if Control is TCustomListBox then
  begin
    FCanvas:=TCustomListBox(Control).Canvas;
    TControlCanvas(FCanvas).UpdateTextFlags;
    FCanvas.FillRect(Rect);
    if bDebugMode then s:=TCustomListBox(Control).Items[Index]
      else s:=SUtils.GetValue(TCustomListBox(Control).Items[Index]);
    FCanvas.TextOut(Rect.Left + 2, Rect.Top, s);
  end;
end;

procedure TfrmGroupListDlg.MenuCourseClick(Sender: TObject);
begin
  if Sender is TMenuItem then
    DoLoadGroup(TMenuItem(Sender).Tag);
end;

procedure TfrmGroupListDlg.btnGroupCourseClick(Sender: TObject);
var
  pt: TPoint;
begin
  with Sender as TSpeedButton do
  begin
    pt:=ClientToScreen(Point(0,Height));
    CourseMenu.Popup(pt.X,pt.Y);
  end;
end;

procedure TfrmGroupListDlg.ListBoxDblClick(Sender: TObject);
begin
  ModalResult:=mrOk;
end;

end.
