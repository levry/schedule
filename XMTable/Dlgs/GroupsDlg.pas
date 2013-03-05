{
  Диалог выбора групп (XMTable)
  v0.0.2 (09.05.06)
}

unit GroupsDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, CheckLst, ComCtrls, ToolWin, ActnList, Menus,
  SExams, ClientModule, Buttons;

type
  TGroupDlgMode = (gdmAdd, gdmDelete);

  TfrmGroupsDlg = class(TForm)
    btnOk: TButton;
    btnCancel: TButton;
    lbGroups: TCheckListBox;
    CourseMenu: TPopupMenu;
    mnuCourse1: TMenuItem;
    mnuCourse2: TMenuItem;
    mnuCourse3: TMenuItem;
    mnuCourse4: TMenuItem;
    mnuCourse5: TMenuItem;
    btnGroupAll: TSpeedButton;
    btnGroupCourse: TSpeedButton;
    procedure lbGroupsDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure OnBtnsClick(Sender: TObject);
    procedure MenuCourseClick(Sender: TObject);
  private
    { Private declarations }
    FData: TClientDataModule;
    FDlgMode: TGroupDlgMode;
    FCourse: byte;

    procedure LoadGroups(course: byte); overload;
    procedure LoadGroups(AXMTable: TXMTable); overload;
  public
    { Public declarations }
  end;

procedure ShowGroupListDlg(ADlgMode: TGroupDlgMode; AData: TClientDataModule;
    AXMTable: TXMTable; ATableControl: TControl);

implementation

uses
  ADODB, SUtils;

{$R *.dfm}

procedure ShowGroupListDlg(ADlgMode: TGroupDlgMode; AData: TClientDataModule;
    AXMTable: TXMTable; ATableControl: TControl);
var
  frmDlg: TfrmGroupsDlg;

  // добавление расписаний групп
  procedure AddGroups;
  var
    grid: int64;
    s: string;
    i: integer;
  begin
    for i:=0 to frmDlg.lbGroups.Count-1 do
      if frmDlg.lbGroups.Checked[i] then
      begin
        s:=frmDlg.lbGroups.Items[i];
        grid:=GetID(s);
        if grid>0 then
          AXMTable.AddGroup(grid,SUtils.GetValue(s));
      end;
  end;

  // удаление расписаний групп
  procedure DeleteGroups;
  var
    grid: int64;
    i: integer;
  begin
    for i:=0 to frmDlg.lbGroups.Count-1 do
      if frmDlg.lbGroups.Checked[i] then
      begin
        grid:=GetID(frmDlg.lbGroups.Items[i]);
        AXMTable.DelGroup(grid);
      end;
  end;

begin
  frmDlg:=TfrmGroupsDlg.Create(Application);
  try
    frmDlg.FDlgMode:=ADlgMode;
    frmDlg.FData:=AData;
    frmDlg.btnGroupCourse.Visible:=(ADlgMode=gdmAdd);

    if ADlgMode=gdmAdd then frmDlg.LoadGroups(1)
      else frmDlg.LoadGroups(AXMTable);

    if frmDlg.ShowModal=mrOk then
    begin
      ATableControl.Perform(WM_SETREDRAW,integer(False),0);
      try
        if ADlgMode=gdmAdd then AddGroups
          else DeleteGroups;
      finally
        ATableControl.Perform(WM_SETREDRAW,integer(true),0);
        ATableControl.Repaint;
      end;
    end;

  finally
    frmDlg.Free;
    frmDlg:=nil;
  end;
end;

{ TfrmGroupsDlg }

// загрузка групп курса(02.02.06)
procedure TfrmGroupsDlg.LoadGroups(course: byte);
var
  rs: _Recordset;
  s: string;
begin
  if FCourse<>course then
  begin
    FCourse:=course;
    lbGroups.Clear;
    rs:=FData.dbv_GetGroupCrs(FCourse);
    if Assigned(rs) then
    try
      rs.Sort:='grName ASC';
      while not rs.EOF do
      begin
        s:=VarToStr(rs.Fields['grid'].Value)+'='+VarToStr(rs.Fields['grName'].Value);
        lbGroups.Items.Add(s);
        rs.MoveNext;
      end;
    finally
      rs.Close;
      rs:=nil;
    end;
  end;
end;

// загрузка групп из сетки расписания (02.02.06)
procedure TfrmGroupsDlg.LoadGroups(AXMTable: TXMTable);
var
  i: integer;
  grp: TXMGroup;
begin
  lbGroups.Clear;
  for i:=0 to AXMTable.GroupCount-1 do
  begin
    grp:=AXMTable.Groups[i];
    lbGroups.AddItem(IntToStr(grp.grid)+'='+grp.grName, nil);
  end;
end;

procedure TfrmGroupsDlg.lbGroupsDrawItem(Control: TWinControl;
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
      else s:=TCustomListBox(Control).Items.ValueFromIndex[Index];
    FCanvas.TextOut(Rect.Left + 2, Rect.Top, s);
  end;
end;

procedure TfrmGroupsDlg.OnBtnsClick(Sender: TObject);
var
  btn: TControl;
  pt: TPoint;
  i: integer;
begin
  case (Sender as TSpeedButton).Tag of

    1: // all
      begin
        for i:=0 to lbGroups.Count-1 do
          lbGroups.Checked[i]:=true;
      end;

    2: // view course
      begin
        btn:=TSpeedButton(Sender);
        pt:=ClientToScreen(Point(btn.BoundsRect.Left,btn.BoundsRect.Bottom));
        CourseMenu.Popup(pt.X,pt.Y);
      end;

    // TODO: Разве TAction(Sender) ?  
    else
      raise Exception.CreateFmt('Unknown action (Tag=%d)', [TAction(Sender).Tag]);

  end;  // case
end;

procedure TfrmGroupsDlg.MenuCourseClick(Sender: TObject);
begin
  if Sender is TMenuItem then
    LoadGroups(TMenuItem(Sender).Tag);
end;

end.
