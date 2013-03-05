{
  Диалог выбора групп
  v0.0.1
}

unit GroupsDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, CheckLst, SClasses, ComCtrls, ToolWin, ActnList, Menus;

type
  TGroupDlgMode = (gdmAdd, gdmDelete);

  TfrmGroupsDlg = class(TForm)
    btnOk: TButton;
    btnCancel: TButton;
    lbGroups: TCheckListBox;
    ToolBar: TToolBar;
    btnGroupAll: TToolButton;
    btnGroupCourse: TToolButton;
    ActionList: TActionList;
    actGroupAll: TAction;
    actGroupCourse: TAction;
    CourseMenu: TPopupMenu;
    mnuCourse1: TMenuItem;
    mnuCourse2: TMenuItem;
    mnuCourse3: TMenuItem;
    mnuCourse4: TMenuItem;
    mnuCourse5: TMenuItem;
    procedure lbGroupsDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure GroupActionsExecute(Sender: TObject);
    procedure GroupActionsUpdate(Sender: TObject);
    procedure MenuCourseClick(Sender: TObject);
  private
    { Private declarations }
    FDlgMode: TGroupDlgMode;
    FCourse: byte;

    procedure LoadGroups(course: byte); overload;
    procedure LoadGroups(ASchedule: TSchedule); overload;
  public
    { Public declarations }
  end;

procedure ShowGroupListDlg(ADlgMode: TGroupDlgMode; ASchedule: TSchedule);

implementation

uses
  TimeModule, ADODB, SUtils, SDBUtils;

{$R *.dfm}

procedure ShowGroupListDlg(ADlgMode: TGroupDlgMode; ASchedule: TSchedule);
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
          ASchedule.AddGroup(grid,SUtils.GetValue(s));
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
        ASchedule.DelGroup(grid);
      end;
  end;

begin
  frmDlg:=TfrmGroupsDlg.Create(Application);
  try
    frmDlg.FDlgMode:=ADlgMode;
    if ADlgMode=gdmAdd then frmDlg.LoadGroups(1)
      else frmDlg.LoadGroups(ASchedule);

    if frmDlg.ShowModal=mrOk then
      if ADlgMode=gdmAdd then AddGroups
        else DeleteGroups;
  finally
    frmDlg.Free;
    frmDlg:=nil;
  end;
end;

{ TfrmGroupsDlg }

// загрузка групп курса(02.02.06)
procedure TfrmGroupsDlg.LoadGroups(course: byte);
var
  ds: TADODataSet;
begin
  if FCourse<>course then
  begin
    FCourse:=course;
    lbGroups.Clear;
    ds:=TADODataSet.Create(Self);
    try
      if GetRecordset(dmMain.grp_GetCourse(FCourse),ds) then
      begin
        ds.Sort:='grName ASC';
        while not ds.Eof do
        begin
          lbGroups.Items.Add(ds.FieldByName('grid').AsString+'='+ds.FieldByName('grName').AsString);
          ds.Next;
        end;
      end;
    finally
      ds.Close;
      ds.Free;
      ds:=nil;
    end;
  end;
end;

// загрузка групп из сетки расписания (02.02.06)
procedure TfrmGroupsDlg.LoadGroups(ASchedule: TSchedule);
var
  i: integer;
  grp: TGroup;
begin
  lbGroups.Clear;
  for i:=0 to ASchedule.Count-1 do
  begin
    grp:=ASchedule.Item[i];
    lbGroups.AddItem(IntToStr(grp.Grid)+'='+grp.Name, nil);
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

procedure TfrmGroupsDlg.GroupActionsExecute(Sender: TObject);
var
  btn: TToolButton;
  i: integer;
begin
  case (Sender as TAction).Tag of

    -1: // all
      begin
        TAction(Sender).Checked:=not TAction(Sender).Checked;
        for i:=0 to lbGroups.Count-1 do
          lbGroups.Checked[i]:=TAction(Sender).Checked;
      end;

    -2: // view course
      if TAction(Sender).ActionComponent is TToolButton then
      begin
        btn:=TToolButton(TAction(Sender).ActionComponent);
        if Assigned(btn.DropdownMenu) then btn.CheckMenuDropdown;
      end;

    else
      raise Exception.CreateFmt('Unknown action (Tag=%d)', [TAction(Sender).Tag]);

  end;  // case
end;

procedure TfrmGroupsDlg.GroupActionsUpdate(Sender: TObject);
var
  i: integer;
  check: boolean;
begin
  case (Sender as TAction).Tag of

    -1: // all
      if lbGroups.Count>0 then
      begin
        check:=lbGroups.Checked[0];
        if check then
          for i:=1 to lbGroups.Count-1 do
            if not lbGroups.Checked[i] then
            begin
              check:=false;
              break;
            end;
        TAction(Sender).Checked:=check;
        TAction(Sender).Enabled:=true;
      end
      else TAction(Sender).Enabled:=false;

    -2: // course
      TAction(Sender).Visible:=(FDlgMode=gdmAdd);

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
