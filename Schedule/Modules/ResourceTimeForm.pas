{
  Модуль занятости ресурсов (преп-ли, аудитории)
  v0.2.4  (06/10/06)
}
unit ResourceTimeForm;

// TODO: Режимы выбора кафедр: кафедры факультета, кафедры-исполнители

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Modules, ToolWin, ComCtrls, Grids, BaseGrid, AdvGrid,
  SClasses, ActnList, ExtCtrls, StdCtrls, CheckLst, Tabs, CustomOptions;

type
  TKafedraKind = (kkFaculty, kkPerformer);

  TfrmResTime = class(TModuleForm)
    ToolBar: TToolBar;
    Grid: TAdvStringGrid;
    ActionList: TActionList;
    lbResList: TCheckListBox;
    Splitter: TSplitter;
    cbKafedra: TComboBox;
    btnTimeShowTeacher: TToolButton;
    ToolButton2: TToolButton;
    ListPanel: TPanel;
    actTimeShowList: TAction;
    actTimeDeleteItem: TAction;
    btnTimeDeleteItem: TToolButton;
    DayTabControl: TTabControl;
    actTimeExport: TAction;
    SaveDialog: TSaveDialog;
    btnTimeExport: TToolButton;
    actTimeDeleteAll: TAction;
    btnTimeDeleteAll: TToolButton;
    ListToolBar: TToolBar;
    btnListFacultyKaf: TToolButton;
    btnListPerformKaf: TToolButton;
    actListFacultyKaf: TAction;
    actListPerformKaf: TAction;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ResListDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure cbKafedraDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure cbKafedraChange(Sender: TObject);
    procedure ActionExecute(Sender: TObject);
    procedure ResListClickCheck(Sender: TObject);
    procedure GridGetDisplText(Sender: TObject; ACol, ARow: Integer;
      var Value: String);
    procedure ActionUpdate(Sender: TObject);
    procedure GridSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure DayTabControlChange(Sender: TObject);
    procedure ResListDblClick(Sender: TObject);
    procedure GridGridHint(Sender: TObject; ARow, ACol: Integer;
      var hintstr: String);
    procedure lbResListKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);

  private
    { Private declarations }
    fkid: int64;

    FTimeGrid: TTimeGrid;
    procedure OnAddItem(Sender: TObject);
    procedure OnDeleteItem(Sender: TObject);
    procedure OnUpdateItem(Sender: TObject);

    function LoadKafedraList: boolean;
    function LoadResourceList: boolean;

    procedure Set_kid(Value: int64);

  private

    function ToRow(iday,ipair: byte): integer;
    function RowToDay(row: integer): byte;
    function RowToPair(row: integer): byte;

    function FindColItem(ATimeList: TTimeList): integer;
    procedure ShowResourceList(AVisible: boolean);
    procedure MergeFixedCells;   // объед-ние фикс. ячеек


  protected
    { Protected declarations }
    FKafedraFilter: TKafedraKind;       // тип кафедры (факультета, исполнители)
    procedure SetKafedraFilter(Value: TKafedraKind);
    procedure ShowKafedraFilter(Value: boolean);

    procedure ModuleHandler(var Msg: TMessage); override;

    function DoLoadKafedraList: boolean; virtual; abstract;  // загрузка списка кафедр
    function DoLoadResourceList: boolean; virtual; abstract;  // загрузка списка ресурсов
    procedure DoLoadResourceTime(ATimeList: TTimeList); virtual; abstract;  // загрузка расписания
    function GetResName: string; virtual; abstract;
    function VisibleKafedraFilter: boolean; virtual;

  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    constructor CreateModule(AOwner: TComponent; AOptions: TCustomOptions); override;

    procedure UpdateModule; override;

  end;

  // расписание преп-лей
  TfrmTeacherTime = class(TfrmResTime)
  protected
    function GetModuleName: string; override;
    function GetHelpTopic: string; override;

    function DoLoadKafedraList: boolean; override;
    function DoLoadResourceList: boolean; override;
    procedure DoLoadResourceTime(ATimeList: TTimeList); override;
    function GetResName: string; override;

  end;

  // расписание аудиторий
  TfrmAuditoryTime = class(TfrmResTime)
  protected
    function GetModuleName: string; override;
    function GetHelpTopic: string; override;

    function DoLoadKafedraList: boolean; override;
    function DoLoadResourceList: boolean; override;
    procedure DoLoadResourceTime(ATimeList: TTimeList); override;
    function GetResName: string; override;
    function VisibleKafedraFilter: boolean; override;

  end;

implementation

{$R *.dfm}

uses
  ADODb,
  TimeModule, ClientModule,
  SUtils, STypes, SConsts, SStrings, SHelp,
  ExportResTime;

const
  RPP = 1;              // кол-во колонок на пару

{ TfrmTeacherTime }

constructor TfrmResTime.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  ShowKafedraFilter(VisibleKafedraFilter);
  Caption:=GetModuleName();
end;

constructor TfrmResTime.CreateModule(AOwner: TComponent;
  AOptions: TCustomOptions);
begin
  inherited CreateModule(AOwner, AOptions);

  ShowKafedraFilter(VisibleKafedraFilter);
  Caption:=GetModuleName();
end;

procedure TfrmResTime.ShowKafedraFilter(Value: boolean);
begin
  ListToolBar.Visible:=Value;
  if not Value then
  begin
    lbResList.Top:=lbResList.Top-cbKafedra.Top;
    lbResList.Height:=lbResList.Height+cbKafedra.Top;
    cbKafedra.Top:=0;
  end;
end;

function TfrmResTime.VisibleKafedraFilter: boolean;
begin
  Result:=true;
end;

// обновление модуля (01/08/06)
procedure TfrmResTime.UpdateModule;
begin
  cbKafedra.Enabled:=LoadKafedraList();
  if cbKafedra.Enabled then
  begin
    if fkid<=0 then fkid:=GetID(cbKafedra.Items[0]);
    cbKafedra.ItemIndex:=cbKafedra.Items.IndexOfName(IntToStr(fkid));
    LoadResourceList();
    FTimeGrid.Update;
  end;
end;

procedure TfrmResTime.FormCreate(Sender: TObject);
begin
  Grid.FixedCols:=2;
  Grid.FixedRows:=1;
  Grid.DefaultRowHeight:=2*(Canvas.TextHeight('HG')+2*Grid.XYOffset.Y);
  Grid.RowCount:=NumberDays*NumberPairs*RPP+Grid.FixedRows;

  FTimeGrid:=TTimeGrid.Create;
  FTimeGrid.OnAddItem:=OnAddItem;
  FTimeGrid.OnDeleteItem:=OnDeleteItem;
  FTimeGrid.OnUpdateItem:=OnUpdateItem;

  MergeFixedCells;

  ShowResourceList(false);
end;

procedure TfrmResTime.FormDestroy(Sender: TObject);
begin
  FTimeGrid.Free;
end;

// определение строки по паре (02/08/06)
function TfrmResTime.ToRow(iday,ipair: byte): integer;
begin
  Result:=iday*NumberPairs*RPP+ipair*RPP+Grid.FixedRows;
end;

// определение дня по строке (02/08/06)
function TfrmResTime.RowToDay(row: integer): byte;
begin
  Result:=((row-Grid.FixedRows)div RPP) div NumberPairs;
end;

// определение номера пары по строке (02/08/06)
function TfrmResTime.RowToPair(row: integer): byte;
begin
  Result:=((row-Grid.FixedRows)div RPP) mod NumberPairs;
end;

// поиск колонки, соответст. преп-лю (02/08/06)
function TfrmResTime.FindColItem(ATimeList: TTimeList): integer;
var
  i: integer;
begin
  Result:=-1;

  for i:=Grid.FixedCols to Grid.ColCount-1 do
    if Grid.Objects[i, 0]=ATimeList then
    begin
      Result:=i;
      Break;
    end;
end;

// объединение фикс. ячеек (01/08/07)
procedure TfrmResTime.MergeFixedCells;
var
  i, j: integer;
begin
  Grid.BeginUpdate;
  try
    for i:=0 to NumberDays-1 do
    begin
      Grid.MergeCells(0, i*NumberPairs*RPP+1, 1, NumberPairs*RPP);
      Grid.Cells[0, i*NumberPairs*RPP+1]:=csDayNames[i];
      for j:=0 to NumberPairs-1 do
      begin
        if RPP>1 then Grid.MergeCells(1,i*NumberPairs*RPP+j*RPP+1, 1, RPP);
        Grid.Cells[1, i*NumberPairs*RPP+j*rpp+1]:=IntToStr(j+1);
      end;
    end;
  finally
    Grid.EndUpdate;
  end;

end;

// добавление расписания исп-я ресурса
procedure TfrmResTime.OnAddItem(Sender: TObject);
begin
  Assert(Sender is TTimeList,
    'A8FB3A54-B820-46AA-B27C-E83A5E0D8D76'#13'OnAddItem: Sender is not TTimeList'#13);

  if Assigned(Grid.Objects[Grid.ColCount-1,0]) then Grid.AddColumn;
  Grid.Objects[Grid.ColCount-1,0]:=Sender;
  Grid.Cells[Grid.ColCount-1,0]:=TTimeList(Sender).Name;
end;

// удаление расписания исп-я ресурса
procedure TfrmResTime.OnDeleteItem(Sender: TObject);
var
  col: integer;
  i: integer;
begin
  Assert(Sender is TTimeList,
    '0968FBCF-58E0-4D94-AC46-9628298FD12F'#13'OnDeleteItem: Sender is not TTimeList'#13);

  col:=FindColItem(TTimeList(Sender));
  if col<>-1 then
  begin
    Assert((col>=0)and(col<Grid.ColCount),
      'FD6ED875-7DF5-4C11-B99B-7FF9586D216B'#13'OnDeleteItem: invalid variable "col"'#13);

    Grid.BeginUpdate;
    if (Grid.ColCount=Grid.FixedCols+1) and (col=Grid.ColCount-1) then
      Grid.ClearCols(col,1)
    else Grid.RemoveCols(col, 1);
    Grid.EndUpdate;

    // обновление списка ресурсов
    for i:=0 to lbResList.Count-1 do
      if TTimeList(Sender).Id=GetID(lbResList.Items[i]) then
      begin
        lbResList.OnClickCheck:=nil;
        lbResList.Checked[i]:=false;
        lbResList.OnClickCheck:=ResListClickCheck;
      end;
  end;
end;

// обновление (извлечение) расписания исп-я ресурса
procedure TfrmResTime.OnUpdateItem(Sender: TObject);
begin
  Assert(Sender is TTimeList,
    '1AA33C68-73C0-4410-8F06-FB500559B0A7'#13'OnUpdateItem: Sender is not TTimeList'#13);

  Grid.BeginUpdate;
  DoLoadResourceTime(TTimeList(Sender));
  Grid.EndUpdate;
end;

// загрузка кафедр (02/08/06)
function TfrmResTime.LoadKafedraList: boolean;
begin
  cbKafedra.Items.BeginUpdate;
  try
    Result:=DoLoadKafedraList();
  finally
    cbKafedra.Items.EndUpdate;
  end;
//  Result:=dmMain.GetKafedraList(cbKafedra.Items);
end;

// загрузка списка ресурсов (02/08/06)
function TfrmResTime.LoadResourceList: boolean;
var
  i: integer;
begin
  Result:=DoLoadResourceList();
  //Result:=dmMain.GetTeacherList(fkid,lbResList.Items);

  if Result then
  begin
    lbResList.OnClickCheck:=nil;
    for i:=0 to lbResList.Count-1 do
      lbResList.Checked[i]:=(FTimeGrid.FindItem(GetID(lbResList.Items[i]))>=0);
    lbResList.OnClickCheck:=ResListClickCheck;
  end;
end;

procedure TfrmResTime.ResListDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  FCanvas: TCanvas;
  s: string;
begin
  if Control is TCustomListBox then
  begin
    FCanvas:=(Control as TCustomListBox).Canvas;
    TControlCanvas(FCanvas).UpdateTextFlags;
    s:=(Control as TCustomListBox).Items[Index];
    if not bDebugMode then s:=GetValue(s);
//{$IF RTLVersion>=15.0}
//    s:=(Control as TComboBox).Items.ValueFromIndex[Index];
//{$ELSE}
//    s:=GetValue((Control as TComboBox).Items[Index]);
//{$IFEND}

    FCanvas.FillRect(Rect);
    FCanvas.TextOut(Rect.Left + 2, Rect.Top, s);
  end;

end;

procedure TfrmResTime.cbKafedraDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  FCanvas: TCanvas;
  s: string;
begin
  if Control is TComboBox then
  begin
    FCanvas:=(Control as TComboBox).Canvas;
    TControlCanvas(FCanvas).UpdateTextFlags;
    s:=(Control as TComboBox).Items[Index];
    if not bDebugMode then s:=GetValue(s);
//{$IF RTLVersion>=15.0}
//    s:=(Control as TComboBox).Items.ValueFromIndex[Index];
//{$ELSE}
//    s:=GetValue((Control as TComboBox).Items[Index]);
//{$IFEND}

    FCanvas.FillRect(Rect);
    FCanvas.TextOut(Rect.Left + 2, Rect.Top, s);
  end;
end;

procedure TfrmResTime.Set_Kid(Value: int64);
begin
  if fkid<>Value then
  begin
    fkid:=Value;
    LoadResourceList();
  end;
end;

procedure TfrmResTime.cbKafedraChange(Sender: TObject);
begin
  if TComboBox(Sender).Text<>'' then
    Set_Kid(GetID(TComboBox(Sender).Text));
end;

procedure TfrmResTime.ActionExecute(Sender: TObject);

  procedure DoDeleteItem;
  var
    iRow,iCol: integer;
    TimeList: TTimeList;
  begin
    with Grid do
    begin
      iRow:=Selection.Top;
      iCol:=Selection.Left;
      if (iRow>=FixedRows) and (iCol>=FixedCols) then
      begin
        TimeList:=TTimeList(Objects[iCol,0]);
        if Assigned(TimeList) then FTimeGrid.Remove(TimeList);
      end;
    end; // with
  end;  // procedure DoDeleteItem

  // экспорт расписания исп-ния ресурсов
  procedure DoExportTime;
  begin
    if FTimeGrid.Count>0 then
    begin
      SaveDialog.FileName:=cbKafedra.Items.ValueFromIndex[cbKafedra.ItemIndex];
      if SaveDialog.Execute then
        DoExportResTimeGrid(dmMain.Year,dmMain.Sem,dmMain.PSem,FTimeGrid,
            SaveDialog.FileName,'timelist.xlt');
    end;
  end;  // DoExportTime

  // удаление всех расписаний
  procedure DoDeleteAll;
  begin
    Grid.BeginUpdate;
    FTimeGrid.Clear;
    Grid.EndUpdate;
  end;  // DoDeleteAll

begin
  case (Sender as TAction).Tag of

    -3: // kafedra-performer
      SetKafedraFilter(kkPerformer);

    -2: // kafedra of faculty
      SetKafedraFilter(kkFaculty);

    -1: // Show/hide resource list
      ShowResourceList(not ListPanel.Visible);

    1:  // delete time
      DoDeleteItem;

    2:  // export time grid
      DoExportTime;

    3:  // delete all
      DoDeleteAll;

    else
      raise Exception.CreateFmt('Unknown action (Tag=%d)', [TAction(Sender).Tag]);
  end;  // case
end;

procedure TfrmResTime.ActionUpdate(Sender: TObject);

  function DeletedItem: boolean;
  var
    iRow,iCol: integer;
    TimeList: TTimeList;
  begin
    Result:=false;
    with Grid do
    begin
      iRow:=Selection.Top;
      iCol:=Selection.Left;
      if (iRow>=FixedRows) and (iCol>=FixedCols) then
      begin
        TimeList:=TTimeList(Objects[iCol,0]);
        Result:=Assigned(TimeList);
      end;
    end; // with
  end;  // function DeletedItem

begin
  case (Sender as TAction).Tag of
    -3: // kafedra-performer
      TAction(Sender).Checked:=(FKafedraFilter=kkPerformer);

    -2: // kafedra of faculty
      TAction(Sender).Checked:=(FKafedraFilter=kkFaculty);

    -1: // show list
      TAction(Sender).Checked:=ListPanel.Visible;

    1:  // delete item
      TAction(Sender).Enabled:=DeletedItem();

    2,  // export time grid
    3:  // delete all
      TAction(Sender).Enabled:=(FTimeGrid.Count>0);

    else
      raise Exception.CreateFmt('Unknown action (Tag=%d)', [TAction(Action).Tag]);
  end;  // case
end;

// показ/скрытие списка ресурсов (15/08/06)
procedure TfrmResTime.ShowResourceList(AVisible: boolean);
begin
  LockWindowUpdate(Handle);
  ListPanel.Visible:=AVisible;
  if AVisible then
    Splitter.Left:=ListPanel.Left-Splitter.Width;
  Splitter.Visible:=AVisible;
  LockWindowUpdate(0);
end;

procedure TfrmResTime.ResListClickCheck(Sender: TObject);
var
  id: int64;
  s: string;
  index: integer;
begin
  index:=TCustomListBox(Sender).ItemIndex;

  if index>=0 then
  begin
    s:=TCustomListBox(Sender).Items[index];
    id:=GetID(s);
    index:=FTimeGrid.FindItem(id);
    if index>=0 then FTimeGrid.Delete(index)
      else FTimeGrid.Add(id, GetValue(s));
  end;
end;

// отображение текста ячейки (02/08/06)
procedure TfrmResTime.GridGetDisplText(Sender: TObject; ACol,
  ARow: Integer; var Value: String);

  function BuildStrPair(ADay, APair: byte; ATimeList: TTimeList): string;

    function BuildStr(s,sdef: string; FStyle: TFontStyles): string;
    var
      clr: TColor;
      ss: string;
    begin
      if GetId(s)>0 then
      begin
        case SUtils.GetState(s) of
          SConsts.STATE_FREE:  clr:=clBlack;
          SConsts.STATE_BUSY:  clr:=clRed;
          SConsts.STATE_GREEN: clr:=clGreen;
          SConsts.STATE_RED:   clr:=clNavy;
          else clr:=clBlack;
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
    sf = '%s / %s %s'#13;
  var
    i, c: integer;
    lsns: TTimeLsns;
    sg, sa, sp: string;
  begin
    Result:='';

    c:=ATimeList.GetLsnsCount(ADay,APair);
    for i:=0 to c-1 do
    begin
      lsns:=ATimeList.GetLsns(ADay,APair,i);
      sg:=lsns.GetGroupString(1);
      sa:=BuildStr(lsns.Resource,GetResName,[fsBold]);
      case lsns.Week of
        1: sp:='(чт)';
        2: sp:='(нч)';
        else sp:='';
      end;
      Result:=Result+Format(sf,[sg,sa,sp]);
    end;
  end;  // function BuildStrLsns

var
  iday, ipair: byte;
  TimeList: TTimeList;
begin
  if Sender is TAdvStringGrid then
    with Sender as TAdvStringGrid do
    begin
      if (ACol>=FixedCols) and (ARow>=FixedRows)
          and (ACol<ColCount) and (ARow<RowCount) then
      begin
        if IsBaseCell(ACol,ARow) then
        begin
          TimeList:=TTimeList(Objects[ACol,0]);
          if Assigned(TimeList) then
          begin
            iday:=RowToDay(ARow);
            ipair:=RowToPair(ARow);
            if TimeList.GetLsnsCount(iday,ipair)>0 then
              Value:=BuildStrPair(iday,ipair,TimeList);
          end;
        end;
      end;
    end; // with
end;

procedure TfrmResTime.GridGridHint(Sender: TObject; ARow,
  ACol: Integer; var hintstr: String);

  function BuildStrPair(ADay, APair: byte; ATimeList: TTimeList): string;
  const
    sformat = '%s'#13'Группы: %s'#13'%s: %s'#13;
    stypes: array[1..3] of string = ('Лекция','Практика','Лабораторное');
  var
    i,c: integer;
    lsns: TTimeLsns;
    sl,sg,sa: string;
  begin
    Result:='';

    c:=ATimeList.GetLsnsCount(ADay,APair);
    for i:=0 to c-1 do
    begin
      lsns:=ATimeList.GetLsns(ADay,APair,i);
      case lsns.Week of
        1: sl:='(чт)';
        2: sl:='(нч)';
        else sl:='';
      end;
      sl:=Format('%s %s',[stypes[lsns.LType],sl]);
      sg:=lsns.GetGroupString(lsns.GroupCount);
      sa:=GetValue(lsns.Resource);
      Result:=Result+Format(sformat,[sl,sg,GetResName(),sa]);
    end;
    Delete(Result,Length(Result),1);
  end;  // function BuildStrPair

var
  TimeList: TTimeList;
  iday,ipair: byte;
begin
  if Sender is TAdvStringGrid then
    with TadvStringGrid(Sender) do
    begin
      if (ACol>=FixedCols) and (ARow>=FixedRows)
          and (ACol<ColCount) and (ARow<RowCount) then
      begin
        TimeList:=TTimeList(Objects[ACol,0]);
        if Assigned(TimeList) then
        begin
          iday:=RowToDay(ARow);
          ipair:=RowToPair(ARow);
          if TimeList.GetLsnsCount(iday,ipair)>0 then
            hintstr:=BuildStrPair(iday,ipair,TimeList);
        end;
      end;
    end;  // with
end;

procedure TfrmResTime.ModuleHandler(var Msg: TMessage);
begin
  case Msg.Msg of
    SM_CHANGETIME:
      if (TSMChangeTime(Msg).Flags and CT_YEAR)=CT_YEAR then   // изм-ние года
        TSMChangeTime(Msg).Result:=STypes.MRES_DESTROY
      else
      begin
        UpdateModule;
        TSMChangeTime(Msg).Result:=STypes.MRES_UPDATE;
      end;
  end;  // case
end;

procedure TfrmResTime.SetKafedraFilter(Value: TKafedraKind);
begin
  if Value<>FKafedraFilter then
  begin
    FKafedraFilter:=Value;
    LoadKafedraList();

    cbKafedra.ItemIndex:=cbKafedra.Items.IndexOfName(IntToStr(fkid));
    if cbKafedra.ItemIndex=-1 then
    begin
      fkid:=GetID(cbKafedra.Items[0]);
      cbKafedra.ItemIndex:=0;
    end;

    LoadResourceList();
  end;
end;

procedure TfrmResTime.GridSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
  DayTabControl.TabIndex:=RowToDay(ARow);
end;

procedure TfrmResTime.DayTabControlChange(Sender: TObject);
var
  r: TGridRect;
begin
  r:=Grid.Selection;
  r.Top:=ToRow(TTabControl(Sender).TabIndex,0);
  r.Bottom:=r.Top;
  Grid.Selection:=r;
  Grid.TopRow:=r.Top;
end;

procedure TfrmResTime.ResListDblClick(Sender: TObject);
var
  id: int64;
  index: integer;
  r: TGridRect;
begin
  index:=TCustomListBox(Sender).ItemIndex;

  if index>=0 then
  begin
    id:=GetID(TCustomListBox(Sender).Items[index]);
    index:=FTimeGrid.FindItem(id);
    if index>=0 then
    begin
      index:=FindColItem(FTimeGrid.Items[index]);
      r:=Grid.Selection;
      r.Left:=index;
      r.Right:=index;
      Grid.Selection:=r;
      Grid.LeftCol:=index;
    end;
  end;

end;

procedure TfrmResTime.lbResListKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  i: integer;
  s: string;
  id: int64;
begin
  if ((Key=Ord('A')) or (Key=Ord('a'))) and (ssCtrl in Shift) then
    for i:=0 to TCheckListBox(Sender).Count-1 do
    begin
      s:=TCheckListBox(Sender).Items[i];
      id:=GetID(s);
      if FTimeGrid.FindItem(id)=-1 then
      begin
        lbResList.Checked[i]:=true;
        FTimeGrid.Add(id,GetValue(s));
      end;
    end;
end;

{ TfrmTeacherTime }

function TfrmTeacherTime.DoLoadKafedraList: boolean;
begin
  if FKafedraFilter=kkFaculty then
    Result:=dmMain.GetKafedraList(dmMain.FacultyID, cbKafedra.Items)
  else Result:=dmMain.GetPerformKafList(cbKafedra.Items);
end;

function TfrmTeacherTime.DoLoadResourceList: boolean;
begin
  Result:=dmMain.GetTeacherList(fkid,lbResList.Items);
end;

procedure TfrmTeacherTime.DoLoadResourceTime(ATimeList: TTimeList);
var
  rs: _Recordset;
begin
  rs:=dmMain.sdl_GetLsns_t(ATimeList.Id);
  if Assigned(rs) then
  try
    ATimeList.LoadFrom(rs,'aid','aName');
  finally
    rs.Close;
    rs:=nil;
  end;
end;

function TfrmTeacherTime.GetModuleName: string;
begin
  Result:='Занятость преподавателей';
end;

function TfrmTeacherTime.GetHelpTopic: string;
begin
  Result:=SHelp.HELP_TIMETABLE_TEACHERTIME;
end;

function TfrmTeacherTime.GetResName: string;
begin
  Result:=SStrings.rsAuditory;
end;

{ TfrmAuditoryTime }

function TfrmAuditoryTime.DoLoadKafedraList: boolean;
begin
  Result:=dmMain.GetKafedraList(dmMain.FacultyID, cbKafedra.Items);
  cbKafedra.Items.Insert(0,'0=Факультет');
end;

// загрузка списка аудиторий (15/08/06)
function TfrmAuditoryTime.DoLoadResourceList: boolean;
begin
  Result:=dmMain.GetAuditoryList(fkid,lbResList.Items);
end;

// загрузка занятости аудиторий (15/08/06)
procedure TfrmAuditoryTime.DoLoadResourceTime(ATimeList: TTimeList);
var
  rs: _Recordset;
begin
  rs:=dmMain.sdl_GetLsns_a(ATimeList.Id);
  if Assigned(rs) then
  try
    ATimeList.LoadFrom(rs,'tid','Initials');
  finally
    rs.Close;
    rs:=nil;
  end;
end;

function TfrmAuditoryTime.GetModuleName: string;
begin
  Result:='Занятость аудиторий';
end;

function TfrmAuditoryTime.GetHelpTopic: string;
begin
  Result:=SHelp.HELP_TIMETABLE_AUDITORYTIME;
end;

function TfrmAuditoryTime.GetResName: string;
begin
  Result:=SStrings.rsTeacher;
end;

function TfrmAuditoryTime.VisibleKafedraFilter: boolean;
begin
  Result:=false;
end;

end.
