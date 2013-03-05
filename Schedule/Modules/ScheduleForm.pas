{
  Модуль составления расписания
  v0.2.3 (22.04.06)
}

unit ScheduleForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, BaseGrid, AdvGrid, ToolWin, ComCtrls, StdCtrls, SClasses,
  SConsts, PairEditDlg, Modules, ActnList, Menus;

type
  TfrmSchedule = class(TModuleForm)
    sGrid: TAdvStringGrid;
    ToolBar: TToolBar;
    btnToggleParity: TToolButton;
    btnUpdateTable: TToolButton;
    btnSeparator1: TToolButton;
    btnShowEditor: TToolButton;
    btnSeparator2: TToolButton;
    btnExport: TToolButton;
    ActionList: TActionList;
    actShowEditor: TAction;
    actToggleParity: TAction;
    actDeleteGrp: TAction;
    actAddGroup: TAction;
    actDeleteGrpList: TAction;
    actUpdateTable: TAction;
    actExportTable: TAction;
    btnAddGrp: TToolButton;
    btnDeleteGrpList: TToolButton;
    PopupMenu: TPopupMenu;
    mnuToggleParity: TMenuItem;
    mnuDeleteGroup: TMenuItem;
    mnuShowEditor: TMenuItem;
    actExecWorkplan: TAction;
    btnExecWorkplan: TToolButton;
    mnuDivider: TMenuItem;
    mnuExecWorkplan: TMenuItem;
    actDoublePair: TAction;
    btnDoublePair: TToolButton;
    mnuDoublePair: TMenuItem;
    DayTabControl: TTabControl;
    actExportNotRes: TAction;
    ExportMenu: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    procedure FormCreate(Sender: TObject);


    procedure sGridDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure sGridDragDrop(Sender, Source: TObject; X, Y: Integer);
//    procedure SchedGridGridHint(Sender: TObject; ARow, ACol: Integer;
//      var hintstr: String);
    procedure sGridDblClickCell(Sender: TObject; ARow, ACol: Integer);
    procedure sGridGetDisplText(Sender: TObject; ACol, ARow: Integer;
      var Value: String);
    procedure FormDestroy(Sender: TObject);
    procedure ActionsExecute(Sender: TObject);
    procedure ActionsUpdate(Sender: TObject);
    procedure sGridSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure DayTabControlChange(Sender: TObject);
//    procedure SchedGridGetCellColor(Sender: TObject; ARow, ACol: Integer;
//      AState: TGridDrawState; ABrush: TBrush; AFont: TFont);
  private
    { Private declarations }
    FSchedule: TSchedule;          // расписание
    FPairEditor: TfrmPairEditDlg;  // редактор пары
    rpp: integer;                  // кол-во строк на пару

    { grid functions }
    function FindColGroup(AGrp: TGroup): integer;
    function RowToWeek(row,col: integer): byte;
    function RowToDay(row: integer): byte;
    function RowToPair(row: integer): byte;
    function ToRow(iday,ipair,iweek: byte): integer;

    { update functions }
    procedure UpdateViewGrp(const AGrp: TGroup);
//    procedure UpdateViewStrm(const strid: int64; wday: integer=-1; npair: integer=-1);
//    procedure UpdateViewLsns(const lid: int64; wday: integer=-1; npair: integer=-1);

    { merge functions }
    procedure MergeCol(grp: TGroup);  overload;
    procedure MergeCol(col: integer); overload;
    procedure MergeFixedCells;                    // объед-ние фикс. ячеек
    procedure UpdateMergeCells;                   // обновление объ-ния всех ячеек

    { notifications }
    procedure OnGetSchedule(Sender: TGroup; lid: int64);
    procedure OnAddGroup(Sender: TGroup);
    procedure OnDelGroup(Sender: TGroup);
    procedure OnAddLsns(Sender: TBaseLsns; iDay,iPair: byte; var Allow: boolean);
    procedure OnDelLsns(Sender: TBaseLsns; iDay,iPair: byte; var Allow: boolean);
    procedure OnSaveLsns(Sender: TBaseLsns; iDay,iPair: byte; UpdateKind: TUpdateKind; var Allow: boolean);
    // потоки
    procedure OnAddStrm(Sender: TSchedule; strid: int64; iWeek,iDay,iPair: byte;
        HGrp: boolean; aid: int64; var Allow: boolean);
    procedure OnDelStrm(Sender: TSchedule; strid: int64; iWeek,iDay,iPair: byte;
        HGrp: boolean; xid: int64; var Allow: boolean);
    procedure OnGetStrm(Sender: TSchedule; strid: int64);
    // редактор пары
    procedure OnPairEditorChange(Sender: TObject);

    { business functions }
    procedure DoMoveLsns(ALsns: TLsns; AWeek, ADay, ANPair: byte; NoAuditory: boolean);

  protected
    function GetModuleName: string; override;
    procedure ModuleHandler(var Msg: TMessage); override;
    function GetHelpTopic: string; override;


  public
    { Public declarations }
    procedure UpdateModule; override;

  end;

implementation

uses
  ADODB,
  TimeModule, SDBUtils, SIntf, SCategory, SUtils, STypes, SStrings, SHelp,
  GroupsDlg, LsnsTypeDlg, ExportTimeTable, ExecWorkplanDlg;

{$R *.dfm}

function TfrmSchedule.GetModuleName: string;
begin
  Result:='Расписание';
end;

procedure TfrmSchedule.ModuleHandler(var Msg: TMessage);
begin
  case Msg.Msg of
    SM_CHANGETIME:
      if (TSMChangeTime(Msg).Flags and CT_YEAR)=CT_YEAR then   // изм-ние года
        TSMChangeTime(Msg).Result:=MRES_DESTROY
      else
      begin
        UpdateModule;
        TSMChangeTime(Msg).Result:=MRES_UPDATE;
      end;

  end;  // case
end;

function TfrmSchedule.GetHelpTopic: string;
begin
  Result:=HELP_TIMETABLE_TABLE;
end;

// поиск колонки, соответст. группе
function TfrmSchedule.FindColGroup(AGrp: TGroup): integer;
var
  i: integer;
begin
  Result:=-1;

  for i:=sGrid.FixedCols to sGrid.ColCount-1 do
    if sGrid.Objects[i, 0]=AGrp then
    begin
      Result:=i;
      Break;
    end;
end;

// объед-ние фикс. ячеек
procedure TfrmSchedule.MergeFixedCells;
var
  i, j: integer;
begin
  sGrid.BeginUpdate;
  try
    for i:=0 to NumberDays-1 do
    begin
//    MergeFixed(i);
      sGrid.MergeCells(0, i*NumberPairs*rpp+1, 1, NumberPairs*rpp);
      sGrid.Cells[0, i*NumberPairs*rpp+1]:=csDayNames[i];
      for j:=0 to NumberPairs-1 do
      begin
        if rpp>1 then sGrid.MergeCells(1,i*NumberPairs*rpp+j*rpp+1, 1, rpp);
        sGrid.Cells[1, i*NumberPairs*rpp+j*rpp+1]:=IntToStr(j+1);
      end;
    end;
  finally
    sGrid.EndUpdate;
  end;
end;

procedure TfrmSchedule.FormCreate(Sender: TObject);
begin
  rpp:=2;

  FSchedule:=TSchedule.Create;
  
  sGrid.FixedCols:=2;
  sGrid.DefaultRowHeight:=2*(Canvas.TextHeight('HG')+2*sGrid.XYOffset.Y);
  sGrid.RowCount:=NumberDays*NumberPairs*rpp+sGrid.FixedRows;
  MergeFixedCells;

  FPairEditor:=TfrmPairEditDlg.Create(Self);
  FPairEditor.OnChange:=OnPairEditorChange;

  // установка событий
  FSchedule.OnAddGroup:=OnAddGroup;
  FSchedule.OnDelGroup:=OnDelGroup;
  FSchedule.OnAddLessons:=OnAddLsns;
  FSchedule.OnDelLessons:=OnDelLsns;
  FSchedule.OnSaveLessons:=OnSaveLsns;
  FSchedule.OnAddStream:=OnAddStrm;
  FSchedule.OnDelStream:=OnDelStrm;
  FSchedule.OnGetStream:=OnGetStrm;
  FSchedule.OnGetSchedule:=OnGetSchedule;
end;

procedure TfrmSchedule.FormDestroy(Sender: TObject);
begin
  if Assigned(FSchedule) then
  begin
    FSchedule.Free;
    FSchedule:=nil;
  end;
end;

// событие при добавления расписания группы
// Sender - добавляемая группа
procedure TfrmSchedule.OnAddGroup(Sender: TGroup);
begin
  if Assigned(sGrid.Objects[sGrid.ColCount-1,0]) then sGrid.AddColumn;
  sGrid.Objects[sGrid.ColCount-1,0]:=Sender;
  sGrid.Cells[sGrid.ColCount-1,0]:=Sender.Name;

//  if sGrid.Cells[sGrid.ColCount-1, 0]<>'' then
//    sGrid.ColCount:=sGrid.ColCount+1;
//  sGrid.Cells[sGrid.ColCount-1, 0]:=Sender.Name;
end;

// событие при удаления группы из расписания
// Sender - удаляем. группа
procedure TfrmSchedule.OnDelGroup(Sender: TGroup);
var
  col: integer;
begin
  col:=FindColGroup(Sender);
  if col<>-1 then
  begin
    Assert((col>=0)and(col<sGrid.ColCount),
      '805F20D0-1256-451E-B514-8B05B60FDB31'#13'OnDelGroup: invalid variable "col"'#13);

    sGrid.BeginUpdate;

    sGrid.SplitAllCells;
    if (sGrid.ColCount=sGrid.FixedCols+1) and (col=sGrid.ColCount-1) then
        sGrid.ClearCols(col,1)
      else sGrid.RemoveCols(col, 1);
    UpdateMergeCells;

    sGrid.EndUpdate;

    if Assigned(FPairEditor.Pair) then
      if FPairEditor.Pair.Parent=Sender then FPairEditor.DoAction(akDeleteGrp);
  end;
end;

// событие при добавлении занятия
procedure TfrmSchedule.OnAddLsns(Sender: TBaseLsns; iDay, iPair: byte; var Allow: boolean);
begin
  Assert(not Sender.IsStrm,
    '50021335-AAC8-4BA6-A3DF-67A0BA6B3D22'#13'OnAddLsns: Add lessons, but strid='+IntToStr(Sender.strid)+#13);

  Allow:=dmMain.sdl_NewLsns_g(Sender.lid,Sender.parity,iDay+1,iPair+1,
      byte(Sender.subgrp),Sender.aid);
end;

procedure TfrmSchedule.OnPairEditorChange(Sender: TObject);
begin
  with Sender as TfrmPairEditDlg do
    UpdateViewGrp(Pair.Parent);
//    UpdateViewPair(Pair.Parent,Pair.Day,Pair.Pair);
end;

// событие при удалении занятия из расписания (30.07.2005)
procedure TfrmSchedule.OnDelLsns(Sender: TBaseLsns; iDay,iPair: byte; var Allow: boolean);
begin
  // удаление занятия из базы
  Allow:=dmMain.sdl_DelLsns_g(Sender.lid,Sender.parity,iDay+1,iPair+1);
end;

// событие при обновлении (изм-нии) занятия
procedure TfrmSchedule.OnSaveLsns(Sender: TBaseLsns; iDay,iPair: byte;
    UpdateKind: TUpdateKind; var Allow: boolean);
begin
  Assert((iDay<=6)and(iPair<=7),
    '559CB169-6EAD-4AAF-9B25-3797239444F5'#13'OnSaveLsns: invalid pair'#13);

  with Sender do
  begin
    case UpdateKind of
    ukAuditory: // изм-ние аудитории
      if Sender.IsStrm then
      begin
        Allow:=dmMain.sdl_SetAdr_s(strid,parity,iDay+1,iPair+1,aid);
        if Allow then (Sender as TLsns).Parent.Parent.Parent.UpdateStrm(strid); //UpdateViewStrm(strid,iDay,iPair);
      end
      else
        Allow:=dmMain.sdl_SetAdr_l(lid,parity,iDay+1,iPair+1,aid);
    ukTeacher: // изм-ние преп-ля
      if Sender.IsStrm then
      begin
        Allow:=dmMain.sdl_SetThr_s(strid,parity,iDay+1,iPair+1,tid);
        if Allow then (Sender as TLsns).Parent.Parent.Parent.UpdateStrm(strid); //UpdateViewStrm(strid);
      end
      else
      begin
        Allow:=dmMain.sdl_SetThr_l(lid,parity,iDay+1,iPair+1,tid);
        if Allow then (Sender as TLsns).Parent.Parent.UpdateLsns(lid);
      end;
    ukSub: // изм-ние подгруппы
      begin
        Allow:=dmMain.sdl_SetHGrp(lid,parity,iDay+1,iPair+1,byte(subgrp));
        if Allow and IsStrm then
          (Sender as TLsns).Parent.Parent.Parent.UpdateStrm(strid); //UpdateViewStrm(strid,iDay,iPair);
      end;
    end;
  end;
end;

// событие при добавлении поток. занятия
procedure TfrmSchedule.OnAddStrm(Sender: TSchedule; strid: int64;
    iWeek,iDay,iPair: byte; HGrp: boolean; aid: int64; var Allow: boolean);
begin
  Allow:=dmMain.sdl_NewLsns_s(strid,iWeek,iDay+1,iPair+1, byte(HGrp), aid);
  // TODO: Добавить занятия поток. занятия в расписание групп 
  if Allow then Sender.UpdateStrm(strid); //UpdateViewStrm(strid,iDay,iPair);
end;

// событие при удалении поток. занятия (10.08.2005)
procedure TfrmSchedule.OnDelStrm(Sender: TSchedule; strid: int64;
    iWeek,iDay,iPair: byte; HGrp: boolean; xid: int64; var Allow: boolean);
var
  i: integer;
  grp: TGroup;
  lsns: TLsns;
begin
  Allow:=false;

  // удаление в базе
  if dmMain.sdl_DelLsns_s(strid,iWeek,iDay+1,iPair+1) then
  begin

    Allow:=true;
    // удаление объектов
    for i:=0 to Sender.Count-1 do
    begin
      grp:=Sender.Item[i];
      if Assigned(grp) then
      begin
        grp.BeginUpdate;
        lsns:=grp.Item[iDay,iPair].FindStrm(strid);
        if Assigned(lsns) then
          if lsns.parity=iWeek then
            grp.Item[iDay,iPair].Delete(lsns);
        lsns:=nil;
        grp.EndUpdate;
      end;
      grp:=nil;
    end;

  end;
end;

// загрузка расписания потока (01/11/06)
procedure TfrmSchedule.OnGetStrm(Sender: TSchedule; strid: int64);
var
  grp: TGroup;
  lsns: TLsns;
  d,p: byte;

  ds: TADODataSet;
begin
  ds:=TADODataSet.Create(Self);
  try
    if GetRecordset(dmMain.sdl_GetLsns_s(strid,0,0),ds) then
    begin
      Sender.BeginUpdate;
      try
        ds.Sort:='grid ASC, wday ASC, npair ASC, week ASC';
        while not ds.Eof do
        begin
          grp:=FSchedule.GroupByGrid(ds.FieldByName('grid').AsInteger);

          if Assigned(grp) then
          begin
            d:=ds.FieldByName('wday').AsInteger-1;
            p:=ds.FieldByName('npair').AsInteger-1;

            lsns:=TLsns.Create;
            lsns.Assign(ds.Fields);
            grp.Item[d,p].Add(Lsns);

          end; // if grp<>nil

          ds.Next;

        end; // while not Eof
      finally
        ds.Sort:='';
        ds.Close;
        Sender.EndUpdate;
      end; // tr/finally
      UpdateMergeCells;
    end;  // if GetRecordset(...)
  finally
    ds.Free;
    ds:=nil;
  end;

  if FPairEditor.Showing then FPairEditor.DoAction(akUpdatePair);
end;

// перемещение занятия  (27/10/06)
// NoAuditory = true - перемещение без аудитории
procedure TfrmSchedule.DoMoveLsns(ALsns: TLsns; AWeek,ADay,ANPair: byte;
    NoAuditory: boolean);

  // изменение в БД
  function UpdateBase: boolean;
  var
    err: boolean;
    wday,npair: byte;
    aid: int64;
  begin
    err:=true;
    wday:=ALsns.Parent.Day+1;
    npair:=ALsns.Parent.Pair+1;
    if NoAuditory then aid:=0 else aid:=ALsns.aid;

    dmMain.Connection.BeginTrans;
    try
      if ALsns.IsStrm then
      begin
        if dmMain.sdl_DelLsns_s(ALsns.strid,ALsns.parity,wday,npair) then
          err:=not dmMain.sdl_NewLsns_s(ALsns.strid,AWeek,ADay+1,ANPair+1,
              byte(ALsns.subgrp),aid);
      end
      else
      begin
        if dmMain.sdl_DelLsns_g(ALsns.lid,ALsns.parity,wday,npair) then
          err:=not dmMain.sdl_NewLsns_g(ALsns.lid,AWeek,ADay+1,ANPair+1,
            byte(ALsns.subgrp),aid);
      end;
    finally
      if err then dmMain.Connection.RollbackTrans
        else dmMain.Connection.CommitTrans;
    end;

    Result:=not err;
  end;  // function UpdateBase

begin
  if UpdateBase then
    if ALsns.IsStrm then ALsns.Parent.Parent.Parent.UpdateStrm(ALsns.strid) //UpdateViewStrm(ALsns.strid)
      else ALsns.Parent.Parent.UpdateLsns(ALsns.lid); //UpdateViewLsns(ALsns.lid);
end;

// строка с занятиями с указ. четностью
function BuildStrLsns(APair: TPair; prty: byte): string;

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

const
  line1: string = '%s %s %s';         // в одну строку
  line2: string = '%s'#13'%s  %s';    // в две строки
  line3: string = '%s'#13'%s'#13'%s'; // в три строки
var
  count: integer;
  i: integer;
  sbj,thr,adr: string;
  sf: string;  // формат
  Lsns: TLsns;
begin
  Lsns:=nil;
  Result:='';

  count:=APair.GetParity(prty);
  if count>0 then
  begin
    sf:=line3;
    if count>1 then sf:=line1
      else if prty<>0 then sf:=line2;

    i:=0;
    Lsns:=APair.Item[i];
    while (count>=0) and Assigned(Lsns) do
    begin
      if Lsns.parity=prty then
      begin
        sbj:=ToHTML(GetValue(Lsns.subject),[fsBold]);
        thr:=BuildStr(Lsns.teacher,'Преподаватель',[]);
        adr:=BuildStr(Lsns.auditory,'Аудитория',[fsBold]);
        Result:=Result+SysUtils.Format(sf,[sbj,thr,adr]);
        if count>1 then Result:=Result+#13;
        dec(count);
      end;  // if prty
      inc(i);
      Lsns:=APair.Item[i];
    end; // while

  end // if count>0
  else Result:='';
end;

procedure TfrmSchedule.sGridGetDisplText(Sender: TObject; ACol,
  ARow: Integer; var Value: String);
var
  iday, ipair, iweek: byte;
  grp: TGroup;
  pair: TPair;
begin
  if Sender is TAdvStringGrid then
    with Sender as TAdvStringGrid do
    begin
      if (ACol>=FixedCols) and (ARow>=FixedRows)
          and (ACol<ColCount) and (ARow<RowCount) then
      begin
        if IsBaseCell(ACol,ARow) then
        begin
          grp:=TGroup(Objects[ACol,0]);
          if Assigned(grp) then
          begin
            iday:=RowToDay(ARow);
            ipair:=RowToPair(ARow);
            iweek:=RowToWeek(ARow,ACol);
            pair:=grp.Item[iday,ipair];
            if Assigned(pair) then Value:=BuildStrLsns(pair,iweek);
          end;
        end;
      end;
    end; // with
end;

{
// обновление вывода расписания занятий нагрузки (22.08.2005)
procedure TfrmSchedule.UpdateViewLsns(const lid: int64;
    wday: integer=-1; npair: integer=-1);
var
  grp: TGroup;
  pair: TPair;
  lsns: TLsns;
  d,p: byte;

  ds: TADODataSet;
begin
  ds:=TADODataSet.Create(Self);
  try
    if GetRecordset(dmMain.sdl_GetLsns_l(lid, wday+1, npair+1),ds) then
    begin
//      sGrid.BeginUpdate;
      try
        ds.Sort:='grid ASC, wday ASC, npair ASC, week ASC';

        grp:=FSchedule.GroupByGrid(ds.FieldByName('grid').AsInteger);
        if Assigned(grp) then
        begin
          grp.BeginUpdate;
          while not ds.Eof do
          begin
            lsns:=nil;
            d:=ds.FieldByName('wday').AsInteger-1;
            p:=ds.FieldByName('npair').AsInteger-1;

            pair:=grp.Item[d,p];
            if Assigned(pair) then
            begin
              lsns:=nil;
              lsns:=pair.FindLsns(ds.FieldByName('lid').AsInteger);
              if not Assigned(lsns) then
              begin
                lsns:=TLsns.Create;
                pair.Add(Lsns);
              end;
              lsns.Assign(ds.Fields);

//              UpdateViewPair(grp,d,p);
            end; // if Pair<>nil

            ds.Next;
          end; // while not Eof
          grp.EndUpdate;
        end; // if Grp<>nil

      finally
        ds.Sort:='';
        ds.Close;
//        sGrid.EndUpdate;
      end;
      UpdateViewGrp(grp);
    end;  // if GetRecordset(...)
  finally
    ds.Free;
    ds:=nil;
  end;
end;
}

{
// обновление вывода расписания потока (8.08.2005)
procedure TfrmSchedule.UpdateViewStrm(const strid: int64;
    wday: integer=-1; npair: integer=-1);
var
  grp: TGroup;
  pair: TPair;
  lsns: TLsns;
  d,p: byte;

  ds: TADODataSet;
begin
  ds:=TADODataSet.Create(Self);
  try
    if GetRecordset(dmMain.sdl_GetLsns_s(strid,wday+1,npair+1),ds) then
    begin
//      sGrid.BeginUpdate;
      FSchedule.BeginUpdate;
      try
        ds.Sort:='grid ASC, wday ASC, npair ASC, week ASC';
        while not ds.Eof do
        begin
          grp:=FSchedule.GroupByGrid(ds.FieldByName('grid').AsInteger);

          if Assigned(grp) then
          begin
            lsns:=nil;
            d:=ds.FieldByName('wday').AsInteger-1;
            p:=ds.FieldByName('npair').AsInteger-1;

            pair:=grp.Item[d,p];
            if Assigned(pair) then
            begin
              // поиск занятия потока
              lsns:=Pair.FindLsns(ds.FieldByName('lid').AsInteger);
              // добавляем занятие, если не найдено
              if not Assigned(lsns) then
              begin
                lsns:=TLsns.Create;
                pair.Add(Lsns);
              end;

              // обновление полей занятия
              if Assigned(lsns) then
                lsns.Assign(ds.Fields);

//              UpdateViewPair(Grp,d,p);
            end; // if pair<>nil
          end; // if grp<>nil

          ds.Next;

        end; // while not Eof
      finally
        ds.Sort:='';
        ds.Close;
        FSchedule.EndUpdate;
//        sGrid.EndUpdate;
      end; // tr/finally
      UpdateMergeCells;
    end;  // if GetRecordset(...)
  finally
    ds.Free;
    ds:=nil;
  end;
end;
}

// обновление вывода расписания группы (28.07.2005)
procedure TfrmSchedule.UpdateViewGrp(const AGrp: TGroup);
var
  col: integer;
begin
//  UpdateMergeCells();
  col:=FindColGroup(AGrp);
  if col<>-1 then
  begin
    MergeCol(col);
    sGrid.RepaintCol(col);
  end;
end;

// обновление модуля
procedure TfrmSchedule.UpdateModule;
begin
  FSchedule.Update;
  if (FPairEditor.Visible) and (Assigned(FPairEditor.Pair)) then
    if FSchedule.FindGroup(FPairEditor.Pair.Parent.Grid)<>-1 then
      FPairEditor.DoAction(akUpdatePair);
end;

// событие при заполнении расписания
procedure TfrmSchedule.OnGetSchedule(Sender: TGroup; lid: int64);
var
  d,p: byte;
  lsns: TLsns;
  ds: TADODataSet;      // TODO: Заменить на _Recordset
begin
  ds:=nil;

  if lid>0 then ds:=CreateDataSet(dmMain.sdl_GetLsns_l(lid))
    else ds:=CreateDataSet(dmMain.sdl_GetLsns_g(Sender.grid));
  try
    if Assigned(ds) then
    begin
      FSchedule.BeginUpdate;
      try
        // заполнение расписания
        while not ds.Eof do
        begin
          d:=ds.FieldByName('wday').AsInteger-1;
          p:=ds.FieldByName('npair').AsInteger-1;

          lsns:=TLsns.Create;
          lsns.Assign(ds.Fields);
          Sender.Item[d,p].Add(lsns);

          ds.Next;
        end; // while
      finally
        FSchedule.EndUpdate;
      end; // try/finally (if bOpen)
    end;  // if ds<>nil
  finally
    ds.Close;
    ds.Free;
    ds:=nil;
  end;

  if FPairEditor.Showing then FPairEditor.DoAction(akUpdatePair);
  UpdateViewGrp(Sender);
end;

// событие Drag-n-Drop на разрешение переноса
procedure TfrmSchedule.sGridDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
var
  col,row: integer;

  // проверка принятия из дерева объектов
  function AcceptFromBrowser: boolean;
  var
    obj: TBrowseObject;
    grp: TGroup;
    iwday,inpair,iweek: byte;
  begin

    Result:=false;

    if TObject(TTreeView(Source).Selected.Data) is TBrowseObject then
      obj:=TTreeView(Source).Selected.Data
    else obj:=nil;

    if Assigned(obj) then
    begin
      // добавление группы
      if obj.Kind=okGroup then Result:=(FSchedule.FindGroup(obj.Id)=-1);

      // добавление занятия
      if (obj.Kind=okSubject) and (Row>=TAdvStringGrid(Sender).FixedRows) then
      begin
        grp:=FSchedule.GroupByGrid(obj.Parent.Id);
        if Assigned(grp) then
        begin
          iwday:=RowToDay(Row);
          inpair:=RowToPair(Row);
          iweek:=RowToWeek(Row,Col);
          Result:=grp.IsPlace(iwday,inpair,iweek);
        end; // if grp<>nil
      end; // if add lsns

    end; // if(obj<>nil)

  end;  // function AcceptFromTreeView

  // проверка принятия из редактора пары
  function AcceptFromPairEditor: boolean;
  var
    grp: TGroup;
    iwday,inpair,iweek: byte;
  begin
    Result:=false;

    if Assigned(FPairEditor.Pair) then grp:=FPairEditor.Pair.Parent
      else grp:=nil;

    if Assigned(grp) then
    begin
      iwday:=RowToDay(Row);
      inpair:=RowToPair(Row);
      iweek:=RowToWeek(Row,Col);
      Result:=Grp.IsPlace(iwday,inpair,iweek);
    end; // if grp<>nil

  end;  // function AcceptFromPairEditor

begin
  Accept:=false;

  TAdvStringGrid(Sender).MouseToCell(X,Y,col,row);
  if (col<>-1) and (row<>-1) then
    if Source is TTreeView then Accept:=AcceptFromBrowser() else
      if Source is TAdvStringGrid then Accept:=AcceptFromPairEditor();

end;

// событие Drag-n-Drop при приеме
procedure TfrmSchedule.sGridDragDrop(Sender, Source: TObject; X,
  Y: Integer);

  // прием из дерева объектов
  procedure DropFromBrowser;
  var
    obj: TBrowseObject;
    Grp: TGroup;
    lsns: TLsns;
    Row, Col: integer;
    iday, ipair, iweek: byte;
  begin
    if TObject(TTreeView(Source).Selected.Data) is TBrowseObject then
      obj:=TTreeView(Source).Selected.Data
    else obj:=nil;

    if Assigned(obj) then
    begin

      // добавление расписания группы
      if obj.Kind=okGroup then FSchedule.AddGroup(obj.Id,obj.Name);

      // добавление занятия в расписание
      if obj.Kind=okSubject then
      begin
        TAdvStringGrid(Sender).MouseToCell(X, Y, Col, Row);
        if (Col<>-1) and (Row<>-1) then
        begin
          iday:=RowToDay(Row);
          ipair:=RowToPair(Row);
          iweek:=RowToWeek(Row,Col);

          lsns:=ShowLsnsTypeDlg(obj.Parent.Text,obj.Text,iweek,iday,ipair);
          // TODO: Добавление занятия
          if AddLsns(FSchedule,obj.Parent.Id,iday,ipair,lsns) then
          begin
            if not lsns.IsStrm then TAdvStringGrid(Sender).RepaintCell(Col,Row);
            if FPairEditor.Visible then FPairEditor.DoAction(akUpdatePair);
          end;
        end; // if (col) and (row)
      end; // if добавление занятия

    end;  // if(obj<>nil)

  end;  // procedure DropFromBrowser

  // прием из редактора пары
  procedure DropFromPairEditor;
  var
    lsns: TLsns;
    Row, Col: integer;
    iday, ipair, iweek: byte;
    key: smallint;
    NoAuditory: boolean;
  begin

    TAdvStringGrid(Sender).MouseToCell(X, Y, Col, Row);
    if (Col<>-1) and (Row<>-1) then
    begin
      iday:=RowToDay(Row);
      ipair:=RowToPair(Row);
      iweek:=RowToWeek(Row,Col);
      lsns:=FPairEditor.SelectedLsns;
      NoAuditory:=boolean(Hi(GetKeyState(VK_SHIFT)));
      if Assigned(lsns) then
        DoMoveLsns(lsns,iweek,iday,ipair,NoAuditory);
    end;

  end;  // procedure DropFromPairEditor

begin
  if Source is TTreeView then DropFromBrowser else
    if Source is TAdvStringGrid then DropFromPairEditor;
end;

// событие на Dbl click
procedure TfrmSchedule.sGridDblClickCell(Sender: TObject; ARow,
  ACol: Integer);
var
  iday, ipair, iweek: byte;
  Pair: TPair;
  Grp: TGroup;
begin
//  Pair:=nil;
  Grp:=nil;
  with Sender as TadvStringGrid do
  begin
    if (ARow>=FixedRows) and (ACol>=FixedCols) and (Cells[ACol,0]<>'') then
    begin
      Grp:=TGroup(Objects[ACol,0]);
//      Grp:=dmMain.Workspace.Schedule.GroupByName(Cells[ACol,0]);
      if Assigned(Grp) then
      begin
        iweek:=RowToWeek(ARow,ACol);
        iday:=RowToDay(ARow);
        ipair:=RowToPair(ARow);
        Pair:=Grp.Item[iday,ipair];
//        PairEditor.Color:=Color;
        FPairEditor.EditPair(Pair,iweek);
      end; // Grp<>nil
    end;
  end; // with
end;

{
procedure TfrmSchedPage.SchedGridGridHint(Sender: TObject; ARow,
  ACol: Integer; var hintstr: String);
var
  Grp: TGroup;
  d, n: integer;
  s: string;
begin
  with Sender as TadvStringGrid do
  begin
    if (ARow>=FixedRows) and (ACol>=FixedCols) and (Cells[ACol, 0]<>'') then
    begin
      Grp:=dmMain.Workspace.Schedule.GroupByName(Cells[ACol, 0]);
      d:=(ARow-1)div 7;
      n:=(ARow-1)mod 7;
      if Grp.Lessons[d,n].FType<>ltNone then
      begin
        case Grp.Lessons[d,n].FType of
          ltLect: s:='Лекция';
          ltPract: s:='Практика';
          ltLab: s:='Лабораторная';
        end;
        hintstr:=Format('%s'#10#13'Дисциплина: %s'#10#13'Преподаватель: %s'#10#13'Аудитория: %s',
          [s, Grp.Lessons[d,n].Subject, GetValue(Grp.Lessons[d,n].Teacher), GetName(Grp.Lessons[d,n].Auditory)]);
      end;
    end;
  end;
end;
}

// действия
procedure TfrmSchedule.ActionsExecute(Sender: TObject);

  // срздание двой. пары (09/08/06)
  procedure DoDoublePair(group: TGroup; wday,npair: byte);
  var
    i: integer;
    pair,nextpair: TPair;
    lsns: TLsns;
    err: boolean;
  begin
    if npair<NumberPairs-1 then
    begin
      pair:=group.Item[wday,npair];
      nextpair:=group.Item[wday,npair+1];
      if(pair.Count>0)and(nextpair.Count=0)then
      begin
        err:=false;
        dmMain.Connection.BeginTrans;
        try
          // копирование занятий на след. пару
          for i:=0 to pair.Count-1 do
          begin
            if pair.Item[i].IsStrm then
            begin
              // добавление потока
              lsns:=pair.Item[i];
              err:=not group.Parent.AddStream(lsns.strid,lsns.parity,wday,npair+1,
                  lsns.subgrp,lsns.aid)
            end
            else
            begin
              // добавление обыч. занятия
              lsns:=TLsns.Create;
              lsns.Assign(pair.Item[i]);
              err:=not (nextpair.Add(lsns)>=0);
              if err then lsns.Free;
            end;

            if err then break;
          end;  // for

          if err then
          begin
            group.Parent.BeginUpdate;
            try
              nextpair.Clear;
            finally
              group.Parent.EndUpdate;
            end;
          end;
        finally
          if not err then dmMain.Connection.CommitTrans
            else dmMain.Connection.RollbackTrans;
          UpdateViewGrp(group);
        end;
      end;  // if(count=0)
    end;
  end;  // DoDoublePair

var
  row, col: integer;
  grp: TGroup;
  lsns: TLsns;
  iweek, iwday, inpair: integer;
begin
  case (Sender as TAction).Tag of

    1:  // show a pair editor
      with sGrid do
      begin
        row:=Selection.Top;
        col:=Selection.Left;
        OnDblClickCell(sGrid,row,col);
      end; // with

    2:  // toggle parity
      begin
        grp:=nil;
        row:=sGrid.Selection.Top;
        col:=sGrid.Selection.Left;
        if (row>=sGrid.FixedRows) and (col>=sGrid.FixedCols) then
        begin
          grp:=TGroup(sGrid.Objects[col,0]);
          if Assigned(grp) then
          begin
            iwday:=RowToDay(row);
            inpair:=RowToPair(row);
            if grp.Item[iwday,inpair].Count=0 then
            begin
              iweek:=RowToWeek(row,col);
              if iweek=0 then
              begin
                if sGrid.IsMergedCell(col,row) then sGrid.SplitCells(col,row)
              end
              else sGrid.MergeCells(col,row-(iweek-1),1,rpp);
            end;
          end;
        end;
        grp:=nil;
      end; // 2

    3:  // add group
      ShowGroupListDlg(gdmAdd, FSchedule);

    4:  // delete group
      with sGrid do
      begin
        row:=Selection.Top;
        col:=Selection.Left;
        if (row>=FixedRows) and (col>=FixedCols) then
        begin
          grp:=TGroup(Objects[col,0]);
          if Assigned(grp) then FSchedule.DelGroup(grp.Grid);
        end;
      end; // with

    5:  // delete a group list
      ShowGroupListDlg(gdmDelete, FSchedule);

    6:  // update table
      UpdateModule();

    7:  // export table
      if FSchedule.Count>0 then
        DoExportTimeTable(dmMain.FacultyName, FSchedule, FOptions[CAT_EXPORTTABLE] as TExportTableCategory);

    8:  // execute workplan
      with sGrid do
      begin
        row:=Selection.Top;
        col:=Selection.Left;
        if (row>=sGrid.FixedRows) and (col>=sGrid.FixedCols) then
        begin
          grp:=TGroup(sGrid.Objects[col,0]);
          if Assigned(grp) then ShowExecWorkplanDlg(grp.Grid,grp.Name);
        end;
      end;

    9: // double pair
      begin
        grp:=nil;
        row:=sGrid.Selection.Top;
        col:=sGrid.Selection.Left;
        if (row>=sGrid.FixedRows) and (col>=sGrid.FixedCols) then
        begin
          grp:=TGroup(sGrid.Objects[col,0]);
          if Assigned(grp) then
          begin
            iwday:=RowToDay(row);
            inpair:=RowToPair(row);
            DoDoublePair(grp,iwday,inpair);
          end;
        end;
      end;

      10: // export table not res
        if FSchedule.Count>0 then
          DoExportNotResTable(dmMain.Year,dmMain.Sem,dmMain.PSem,FSchedule);

    else
      raise Exception.CreateFmt('Unknown action (Tag=%d)', [TAction(Sender).Tag]);

  end;  // case
end;

procedure TfrmSchedule.ActionsUpdate(Sender: TObject);
var
  row, col: integer;
  iweek, iwday, inpair: integer;
  grp: TGroup;
  e: boolean;
begin
  case (Sender as TAction).Tag of

    1:  // show a pair editor
      with sGrid do
      begin
        grp:=nil;
        col:=sGrid.Selection.Left;
        grp:=TGroup(Objects[col,0]);
        TAction(Sender).Enabled:=Assigned(grp) and (not FPairEditor.Visible);
      end;

    2:  // toggle parity
      begin
        grp:=nil;
        row:=sGrid.Selection.Top;
        col:=sGrid.Selection.Left;
        if (row>=sGrid.FixedRows) and (col>=sGrid.FixedCols) then
        begin
          grp:=TGroup(sGrid.Objects[col,0]);
          if Assigned(grp) then
          begin
            iwday:=RowToDay(row);
            inpair:=RowToPair(row);
            TAction(Sender).Enabled:=(grp.Item[iwday,inpair].Count=0);
          end
          else TAction(Sender).Enabled:=false;
        end
        else TAction(Sender).Enabled:=false;
      end;  // 2

    3:  // add group
      TAction(Sender).Enabled:=true;

    4,  // delete group,
    8:  // execute workplan
      with sGrid do
      begin
        row:=Selection.Top;
        col:=Selection.Left;
        if (row>=FixedRows) and (col>=FixedCols) then
        begin
          grp:=TGroup(Objects[col,0]);
          TAction(Sender).Enabled:=Assigned(grp);
        end;
      end; // with

    5,  // delete a group list
    6,  // update table
    7,  // export table
    10: // export table not res
      TAction(Sender).Enabled:=FSchedule.Count>0;

    9:  // double pair
      begin
        e:=false;
        grp:=nil;
        row:=sGrid.Selection.Top;
        col:=sGrid.Selection.Left;
        if (row>=sGrid.FixedRows) and (col>=sGrid.FixedCols) then
        begin
          grp:=TGroup(sGrid.Objects[col,0]);
          if Assigned(grp) then
          begin
            iwday:=RowToDay(row);
            inpair:=RowToPair(row);
            if inpair<NumberPairs-1 then
              e:=(grp.Item[iwday,inpair].Count>0)and(grp.Item[iwday,inpair+1].Count=0);
          end
        end;
        TAction(Sender).Enabled:=e;
      end;

    else
      raise Exception.CreateFmt('Unknown action (Tag=%d)', [TAction(Action).Tag]);
  end;  // case
end;

// объединение ячеек группы
procedure TfrmSchedule.MergeCol(grp: TGroup);
var
  col, row: integer;
  d, p: byte;
  pair: TPair;
begin
  sGrid.BeginUpdate;
  try
    col:=FindColGroup(grp);
    if col<>-1 then
    begin
      sGrid.SplitColumnCells(col);
      for d:=0 to NumberDays-1 do
        for p:=0 to NumberPairs-1 do
        begin
          row:=ToRow(d,p,0);
          pair:=grp.Item[d,p];
          if not pair.IsSplitted then sGrid.MergeCells(col,row,1,rpp);
        end;
    end;
  finally
    sGrid.EndUpdate;
  end;
end;

// объединение ячеек колонки
procedure TfrmSchedule.MergeCol(col: integer);
var
  row: integer;
  d,p: byte;
  grp: TGroup;
  pair: TPair;
begin
  sGrid.BeginUpdate;
  try
    sGrid.SplitColumnCells(col);
    
    grp:=TGroup(sGrid.Objects[col,0]);
    if Assigned(grp) then
      for d:=0 to NumberDays-1 do
        for p:=0 to NumberPairs-1 do
        begin
          row:=ToRow(d,p,0);
          pair:=grp.Item[d,p];
          if not pair.IsSplitted then sGrid.MergeCells(col,row,1,rpp);
        end;
  finally
    sGrid.EndUpdate;
  end;
end;

// обновление объед. всех ячеек
procedure TfrmSchedule.UpdateMergeCells;
var
  i: integer;
begin
  sGrid.BeginUpdate;
  try
    sGrid.SplitAllCells;
    MergeFixedCells;
    for i:=sGrid.FixedCols to sGrid.ColCount-1 do
      MergeCol(i);
  finally
    sGrid.EndUpdate;
  end;
end;

{
procedure TfrmSchedPage.SchedGridGetCellColor(Sender: TObject; ARow,
  ACol: Integer; AState: TGridDrawState; ABrush: TBrush; AFont: TFont);
var
  Grp: TGroup;
  Lsns: TLessons;
  d,p: integer;
  Clr: TColor;
begin
  if gdFixed in AState then exit;

  if not Odd((ARow-SchedGrid.FixedRows)div 7) then Clr:=clCream
    else Clr:=SchedGrid.Color;

  Grp:=dmMain.Workspace.Schedule.GroupByName(TadvStringGrid(Sender).Cells[ACol,0]);
  if Assigned(Grp) then
  begin
    d:=(ARow-1)div 7;
    p:=(ARow-1)mod 7;
    Lsns:=Grp.Lessons[d,p];

    if Lsns.FType<>ltNone then
      if (GetName(Lsns.Auditory)='') or (GetName(Lsns.Teacher)='') then
        Clr:=$C0C0DC
      else
      if (GetTag(Lsns.Teacher)='1') or (GetTag(Lsns.Auditory)='1') then
        Clr:=clMoneyGreen;
  end;

  ABrush.Color:=Clr;
end;
}

// определение недели по строке
function TfrmSchedule.RowToWeek(row,col: integer): byte;
begin
  Result:=(row-sGrid.FixedRows) mod rpp;
  if Result>=(rpp div 2) then Result:=2 else Result:=1;
  if sGrid.IsMergedCell(col,row) then
    if sGrid.CellSpan(col,row).Y=rpp-1 then Result:=0;
end;

// определение дня по строке
function TfrmSchedule.RowToDay(row: integer): byte;
begin
  Result:=((row-sGrid.FixedRows)div rpp) div NumberPairs;
end;

// определение номера пары по строке
function TfrmSchedule.RowToPair(row: integer): byte;
begin
  Result:=((row-sGrid.FixedRows)div rpp) mod NumberPairs;
end;

// определение первой строки по паре
function TfrmSchedule.ToRow(iday,ipair,iweek: byte): integer;
var
  i: integer;  // смещение внутри блока строк уч. пары
begin
  if iweek=2 then i:=rpp div 2 else i:=0;
  Result:=iday*NumberPairs*rpp+ipair*rpp+sGrid.FixedRows + i;
end;

procedure TfrmSchedule.sGridSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
var
  r: TGridRect;
begin
  r:=TAdvStringGrid(Sender).Selection;
  DayTabControl.TabIndex:=RowToDay(ARow);
  TAdvStringGrid(Sender).RepaintCell(r.Left,r.Top);
end;

procedure TfrmSchedule.DayTabControlChange(Sender: TObject);
var
  r: TGridRect;
begin
  r:=sGrid.Selection;
  r.Top:=ToRow(TTabControl(Sender).TabIndex,0,0);
  r.Bottom:=r.Top;
  sGrid.Selection:=r;
  sGrid.TopRow:=r.Top;
end;

end.
