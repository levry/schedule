{
  Редактор пары
  v0.2.3 (22.03.06)
}

unit PairEditDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, SClasses, ToolWin, ComCtrls, Grids,
  BaseGrid, AdvGrid, frmctrllink, EditLsnsFrame, Contnrs, ActnList;

type
  TActionKind = (akUpdatePair, akDeleteGrp);

  TfrmPairEditDlg = class(TForm)
    LsnsGrid: TAdvStringGrid;
    ToolBar: TToolBar;
    CtrlEditLink: TFormControlEditLink;
    btnLsnsEdit: TToolButton;
    btnLsnsDelete: TToolButton;
    StatusBar: TStatusBar;
    ActionList: TActionList;
    actLsnsEdit: TAction;
    actLsnsDelete: TAction;
    actLsnsAdd: TAction;
    btnLsnsAdd: TToolButton;
    ToolButton1: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure LsnsGridGetEditorType(Sender: TObject; ACol, ARow: Integer;
      var AEditor: TEditorType);
    procedure FormDestroy(Sender: TObject);
    procedure LsnsGridGetDisplText(Sender: TObject; ACol, ARow: Integer;
      var Value: String);
    procedure CtrlEditLinkSetEditorValue(Sender: TObject;
      Grid: TAdvStringGrid; AValue: String);
    procedure LsnsGridRowChanging(Sender: TObject; OldRow, NewRow: Integer;
      var Allow: Boolean);
//    procedure BtnsClick(Sender: TObject);
    procedure LsnsGridCanEditCell(Sender: TObject; ARow, ACol: Integer;
      var CanEdit: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ActionsExecute(Sender: TObject);
    procedure ActionsUpdate(Sender: TObject);
    procedure LsnsGridMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure LsnsGridMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure LsnsGridEndDrag(Sender, Target: TObject; X, Y: Integer);
    procedure LsnsGridMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
    FDragPoint: TPoint;
    FStartDrag: boolean;

    RH: integer;            // высота строки
    EH: integer;            // высота редактора
    
    FEditor: TfmEditLsns;   // редактор занятия
    FList: TList;           // список редактир. занятий

    FPair: TPair;
    FWeek: byte;

    FOnChange: TNotifyEvent;

    procedure UpdateGrid;
    procedure UpdateBar;
    procedure SetPair(const APair: TPair; const AWeek: byte);
    function GetSelectedLsns: TLsns;

    procedure FOnEditorChange(Sender: TObject);
  public
    { Public declarations }

    property Pair: TPair read FPair;
    property SelectedLsns: TLsns read GetSelectedLsns;
    property Week: byte read FWeek;

    property OnChange: TNotifyEvent read FOnChange write FOnChange;

    procedure EditPair(const APair: TPair; const AWeek: byte);
    procedure UpdatePair;

    procedure DoAction(const Action: TActionKind);
  end;

implementation

{$R *.dfm}

uses
  SUtils, TimeModule, LsnsListDlg, SConsts;

procedure TfrmPairEditDlg.FormCreate(Sender: TObject);
begin
  FStartDrag:=false;

  FWeek:=0;
  FPair:=nil;
  FList:=TList.Create;

  FEditor:=TfmEditLsns.Create(Self);
  FEditor.OnChange:=FOnEditorChange;
  EH:=FEditor.Height;
  CtrlEditLink.Control:=FEditor;

  with LsnsGrid do
  begin
    RH:=4*Canvas.TextHeight('HG')+2*XYOffset.Y;
    DefaultRowHeight:=RH;
    DefaultColWidth:=Width-2*GridLineWidth-2*BorderWidth-1;
  end; // with LsnsGrid
end;

procedure TfrmPairEditDlg.FormDestroy(Sender: TObject);
begin
  if Assigned(FList) then FList.Free;
  FPair:=nil;
end;

procedure TfrmPairEditDlg.LsnsGridGetEditorType(Sender: TObject; ACol,
  ARow: Integer; var AEditor: TEditorType);
begin
  (Sender as TadvStringGrid).EditLink:=CtrlEditLink;
  AEditor:=edCustom;
end;

// событие на изм-ние полей редактора
procedure TfrmPairEditDlg.FOnEditorChange(Sender: TObject);
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;


// установка пары
procedure TfrmPairEditDlg.SetPair(const APair: TPair; const AWeek: byte);
var
  i: integer;
  lsns: TLsns;
begin
  FList.Clear;

  if Assigned(APair) then
  begin
    FPair:=APair;
    FWeek:=AWeek;

    for i:=0 to FPair.Count-1 do
    begin
      lsns:=FPair.Item[i];
      if lsns.parity=FWeek then FList.Add(lsns);
    end; // for

  end // if APair<>nil
  else
  begin
    FPair:=nil;
    FWeek:=0;
  end;

  if Assigned(FPair) then Caption:='Редактор пары - '+FPair.Parent.Name
    else Caption:='Редактор пары';

  UpdateGrid;
  UpdateBar;
end;

// обновление
procedure TfrmPairEditDlg.UpdatePair;
begin
  SetPair(FPair,FWeek);
//  SetPair(FGroup,FWeek,FDay,FNPair);

//  UpdateGrid;
//  UpdateBar;
end;


// редактирование
procedure TfrmPairEditDlg.EditPair(const APair: TPair; const AWeek: byte);
//procedure TfrmPairEditDlg.EditPair(AGroup: TGroup; AWeek,ADay,ANPair: byte);
//var
//  i: integer;
//  ELsns: TEditLsns;
//  Lsns: TBaseLsns;
begin
//  if (FGroup<>AGroup) or (FWeek<>AWeek) or (FDay<>ADay) or (FNPair<>ANPair) then
  SetPair(APair,AWeek);
//    SetPair(AGroup,AWeek,ADay,ANPair)
//  else SetPair(FGroup,FWeek,FDay,FNPair);

//  UpdateGrid;
//  UpdateBar;

  if not Visible then Show;
end;

procedure TfrmPairEditDlg.LsnsGridGetDisplText(Sender: TObject; ACol,
  ARow: Integer; var Value: String);
const
  s: string = '%s'#13'%s'#13'%s   %s';
  st: array[0..2] of string = ('Лекция', 'Практическое занятие', 'Лабораторное занятие');
var
  ss,sbj,thr,aud: string;

  function BuildStr(s,sdef: string; FStyle: TFontStyles): string;
  var
    clr: TColor;
    ss: string;
  begin
    if GetId(s)>0 then
    begin
      case GetState(s) of
        STATE_FREE:  clr:=clBlack;
        STATE_BUSY:  clr:=clRed;
        STATE_GREEN: clr:=clGreen;
        STATE_RED:   clr:=clNavy;
      end;  // case
      ss:=GetValue(s);
    end
    else
    begin
      clr:=clRed;
      ss:=sdef;
    end;
    Result:=ToHTML(ss,FStyle,clr);
  end;

var
  Lsns: TLsns;
  //i,j: integer;

begin

  if ARow<FList.Count then Lsns:=FList.Items[ARow]
    else Lsns:=nil;
//  Lsns:=TLsns(TAdvStringGrid(Sender).Objects[ACol,ARow]);
//  Lsns:=((Sender as TadvStringGrid).Objects[ACol,ARow] as TLsns);
  if Assigned(Lsns) then
  begin
    sbj:=GetValue(Lsns.subject);
    if Lsns.strid>0 then sbj:=sbj+' (поток)';
    sbj:=ToHTML(sbj,[fsBold]);
    thr:=BuildStr(Lsns.teacher,'Преподаватель', []);
    aud:=BuildStr(Lsns.auditory,'Аудитория', []);
    ss:=SysUtils.Format(s,[st[Lsns.ltype-1],sbj,thr,aud]);
    if Lsns.subgrp then ss:=ss+#13'подгруппа'
  end
  else ss:='Нет занятий.';
  Value:=ss;

//  if FList.Count>0 then
//  begin
//    ELsns:=TEditLsns(FList.Items[ARow]);
//    if Assigned(ELsns) then
//    begin
//      sbj:=GetValue(ELsns.subject);
//      if ELsns.strid>0 then sbj:=sbj+' (поток)';
//      sbj:=ToHTML(sbj,[fsBold]);
//      thr:=BuildStr(ELsns.teacher,'Преподаватель', []);
//      aud:=BuildStr(ELsns.auditory,'Аудитория', []);
//      ss:=SysUtils.Format(s,[st[ELsns.ltype-1],sbj,thr,aud]);
//      if ELsns.subgrp then ss:=ss+#13'подгруппа'
//    end;
//  end
//  else ss:='Нет занятий.';
//  Value:=ss;
end;

procedure TfrmPairEditDlg.CtrlEditLinkSetEditorValue(Sender: TObject;
  Grid: TAdvStringGrid; AValue: String);
var
  Lsns: TLsns;
  Editable: TEditable;
  //pt: TPoint;
  i: integer;
begin
//  Assert(FList.Count>0,
//    '2DEA5D43-67B0-400A-9B96-DA1FB165C73C'#13'No lessons for editor'#13);

{
  if Assigned(FGroup) then
  begin
    Pair:=FGroup.Item[FDay,FNPair];
    if Assigned(Pair) then
    begin
      pt:=TEditLink(Sender).EditCell;
      i:=TEditLink(Sender).Grid.Ints[pt.X,pt.Y];
      Lsns:=Pair.Item[i];
      if Assigned(Lsns) then
      begin
        Editable:=[ekTeach,ekAudit];
        if (Pair.GetParity(Lsns.parity)=1) and (Lsns.strid=0) then
          Editable:=Editable+[ekSubgrp];
        FEditor.Init(FDay,FNpair,Lsns,Editable,true);
      end;
    end; // if Pair<>nil
  end; // if FGroup<>nil
}

  if Assigned(FPair)and(FList.Count>0) then
  begin
    i:=TEditLink(Sender).EditCell.Y;
    if (i>=0) and (i<FList.Count) then
    begin
      Lsns:=FList.Items[i];
      if Assigned(Lsns) then
      begin
        Editable:=[ekTeacher,ekAuditory];
        if (FList.Count=1) then Editable:=Editable+[ekSubgrp];

        FEditor.Init(FPair.Day,FPair.Pair,Lsns,Editable);
      end; // if ELsns<>nil
    end; // if valid i
  end; // if count>0
end;

procedure TfrmPairEditDlg.LsnsGridRowChanging(Sender: TObject; OldRow,
  NewRow: Integer; var Allow: Boolean);
begin
  with Sender as TadvStringGrid do
  begin
    if (OldRow>=0) and (OldRow<RowCount) then RowHeights[OldRow]:=RH;
    if (NewRow>=0) and (NewRow<RowCount) then RowHeights[NewRow]:=EH;
  end;
  Allow:=true;
end;

procedure TfrmPairEditDlg.LsnsGridCanEditCell(Sender: TObject; ARow,
  ACol: Integer; var CanEdit: Boolean);
var
  Lsns: TLsns;
  i: integer;
begin
  CanEdit:=false;

  // проверка присутствия занятия на паре
  if Assigned(FPair)and(ARow>=0)and(ARow<FList.Count) then
  begin
    Lsns:=FList.Items[ARow];
    if Assigned(Lsns) then
      for i:=0 to FPair.Count-1 do
        if FPair.Item[i]=Lsns then
        begin
          CanEdit:=true;
          break;
        end;
    if not CanEdit then UpdatePair;
  end; // if FGroup<>nil

//  CanEdit:=( (ARow>=0) and (ARow<FList.Count) );
end;

function TfrmPairEditDlg.GetSelectedLsns: TLsns;
var
  row: integer;
begin
  Result:=nil;

  row:=LsnsGrid.Selection.Top;
  if Assigned(FPair)and(row>=0)and(row<FList.Count) then
    Result:=FList.Items[row];
end;

//обновление сетки
procedure TfrmPairEditDlg.UpdateGrid;
//var
//  rows: integer;
//  i,j: integer;
//  s: string;
//  Lsns: TLsns;
begin
  LsnsGrid.HideInplaceEdit;

  LsnsGrid.BeginUpdate;
  LsnsGrid.RowCount:=1;
  LsnsGrid.RowHeights[0]:=EH;
  if Assigned(FPair) and (FList.Count>1) then
    LsnsGrid.RowCount:=FList.Count;
  LsnsGrid.EndUpdate;
end;

// обновление строки состояния
procedure TfrmPairEditDlg.UpdateBar;
const
  sDays: array[0..5] of string = ('Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота');
  sWeek: array[0..2] of string = ('','четная','нечетная');
begin
  if Assigned(FPair) then
  begin
    StatusBar.Panels.Items[0].Text:=sDays[FPair.Day];
    StatusBar.Panels.Items[1].Text:=SysUtils.Format('%d %s', [FPair.Pair+1, 'пара']);
    StatusBar.Panels.Items[2].Text:=sWeek[FWeek];
  end;
end;

// реакции на действия
procedure TfrmPairEditDlg.DoAction(const Action: TActionKind);
begin
  case Action of
  akUpdatePair: // обновление пары
    UpdatePair;

  akDeleteGrp: // удаление группы
    begin
      SetPair(nil,0);
      if Visible then Hide;
    end;
  end; // case
end;

procedure TfrmPairEditDlg.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  FPair:=nil;
  FList.Clear;
end;

procedure TfrmPairEditDlg.ActionsExecute(Sender: TObject);

  procedure DeleteLsns;
  var
    i: integer;
    lsns: TLsns;
    del: boolean;
  begin
    if Assigned(FPair)and(FList.Count>0) then
    begin
      i:=LsnsGrid.Selection.Top;
      lsns:=FList.Items[i];
      if Assigned(lsns) then
      begin
        del:=false;
        if lsns.IsStrm then
          del:=FPair.Parent.Parent.DelStream(lsns.strid,lsns.parity,FPair.Day,FPair.Pair)
        else
          del:=FPair.Delete(lsns);

        if del then
        begin
          FList.Delete(i);
          UpdateGrid();
          if Assigned(FOnChange) then FOnChange(Self);
        end; // if succes delete

      end; // if Lsns<>nil
    end; // 3
  end;  // procedure DeleteLsns

  procedure AddLsns;
  var
    lsns: TLsns;
    s: string;
  begin
    // TODO: Закончить
    s:=IntToStr(FPair.Parent.Grid)+'='+FPair.Parent.Name;
    lsns:=ShowLsnsListDlg(FWeek,FPair.Day,FPair.Pair,s);
    if Assigned(lsns) then
      if SClasses.AddLsns(FPair.Parent.Parent,FPair.Parent.Grid,FPair.Day,FPair.Pair,lsns) then
      begin
        UpdatePair;
        if Assigned(FOnChange) then FOnChange(Self);
      end;
  end;  // procedure AddLsns

begin
  case (Sender as TAction).Tag of

    1:  // edit lsns
      if (Assigned(FPair)) and (FList.Count>0) then
      begin
///        LsnsGrid.SetFocus;
        if LsnsGrid.EditActive then LsnsGrid.HideInplaceEdit
          else LsnsGrid.ShowInplaceEdit;
      end; // if FGroup<>nil

    2:  // add lsns
      AddLsns;

    3:  // delete lsns
      DeleteLsns;

    else raise Exception.CreateFmt('Unknown action (Tag=%d)', [TAction(Sender).Tag]);
  end;  // case
end;

procedure TfrmPairEditDlg.ActionsUpdate(Sender: TObject);
begin
  case (Sender as TAction).Tag of

    1:
      begin
        TAction(Sender).Enabled:=((Assigned(FPair))and(FList.Count>0));
        TAction(Sender).Checked:=LsnsGrid.EditActive;
      end;

    2:
      if Assigned(FPair) then TAction(Sender).Enabled:=FPair.CheckPlace(FWeek)
        else TAction(Sender).Enabled:=false;

    3: TAction(Sender).Enabled:=((Assigned(FPair))and(FList.Count>0));

    else raise Exception.CreateFmt('Unknown action (Tag=%d)', [TAction(Sender).Tag]);
  end;  // case
end;

procedure TfrmPairEditDlg.LsnsGridMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Button=mbLeft) and (Assigned(GetSelectedLsns())) then
  begin
    FDragPoint:=Point(X,Y);
    FStartDrag:=true;             
  end;
end;

procedure TfrmPairEditDlg.LsnsGridMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if (FStartDrag) and (abs(FDragPoint.X-X)>5) and (abs(FDragPoint.Y-Y)>5) then
    TControl(Sender).BeginDrag(false);
end;

procedure TfrmPairEditDlg.LsnsGridEndDrag(Sender, Target: TObject; X,
  Y: Integer);
begin
  FStartDrag:=false;
end;

procedure TfrmPairEditDlg.LsnsGridMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FStartDrag:=false;
end;

end.
