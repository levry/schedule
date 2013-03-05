{
  Модуль составления расписания экзаменов
  v0.0.0  (25.04.06)
  (C) Leonid Riskov, 2006
}
unit ExamForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Modules, ToolWin, ComCtrls, Grids, BaseGrid, AdvGrid, Planner,
  ActnList,
  SExams, STypes, ExamEditForm, ImgList;

type
  TfrmExamTable = class(TModuleForm)
    ToolBar: TToolBar;
    Planner: TPlanner;
    ActionList: TActionList;
    acExamUpdate: TAction;
    actExamAddGroup: TAction;
    btnExamAddGrp: TToolButton;
    btnExamUpdate: TToolButton;
    ToolButton3: TToolButton;
    actExamDelGroups: TAction;
    btnExamDelGroups: TToolButton;
    actExamLayerExam: TAction;
    actExamLayerAll: TAction;
    actExamLayerCons: TAction;
    btnExamLayerAll: TToolButton;
    btnExamLayerExam: TToolButton;
    btnExamLayerCons: TToolButton;
    ToolButton1: TToolButton;
    actExamDelete: TAction;
    actExamAdd: TAction;
    btnExamAdd: TToolButton;
    btnExamDelete: TToolButton;
    ToolButton5: TToolButton;
    ImageList: TImageList;
    actExamExport: TAction;
    btnExamExport: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure OnActionsExecute(Sender: TObject);
    procedure OnActionsUpdate(Sender: TObject);
    procedure PlannerDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure PlannerDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure PlannerItemHint(Sender: TObject; Item: TPlannerItem;
      var Hint: String);
    procedure PlannerPlannerDblClick(Sender: TObject; Position, FromSel,
      FromSelPrecise, ToSel, ToSelPrecise: Integer);
    procedure PlannerItemDelete(Sender: TObject; Item: TPlannerItem);
    procedure PlannerItemInsert(Sender: TObject; Position, FromSel,
      FromSelPrecise, ToSel, ToSelPrecise: Integer);
//    procedure PlannerItemMoving(Sender: TObject; Item: TPlannerItem;
//      DeltaBegin, DeltaPos: Integer; var Allow: Boolean);
  private
    { Private declarations }
    FExamTable: TXMTable;
    FItemEditor: TExamItemEditor;

  private
    function FindPosGroup(AGroup: TXMGroup): integer;
    function GetGroupOfPos(pos: integer): TXMGroup;
    function FindItemExam(AExam: TExam): TPlannerItem;
    procedure ClearPlanner;
    function BuildPlannerItem(Pos: integer; AExam: TBaseExam): TPlannerItem;

  private
    { Events TXMTable }
    procedure OnChangePeriod(Sender: TObject);
    procedure OnGroupInsert(Sender: TObject);
    procedure OnGroupDelete(Sender: TObject);
    procedure OnGroupUpdate(Sender: TObject);

    procedure OnExamInsert(Sender: TBaseExam; var Allow: boolean);
    procedure OnExamDelete(Sender: TBaseExam; var Allow: boolean);
    procedure OnExamUpdate(Sender: TBaseExam; UpdateFlag: WORD; var Allow: boolean);

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
  DateUtils, Math,
  ExamModule, SUtils, SForms, SStrings, SHelp,
  GroupsDlg, ExamListDlg, ExportExamTableDlg;

{$R *.dfm}

const
  LAYER_ALL  = 0;     // все слои
  LAYER_EXAM = 1;     // слой экз
  LAYER_CONS = 2;     // слой конс


{ TfrmExamTable }

procedure TfrmExamTable.FormCreate(Sender: TObject);
begin
  ImageList.ResourceLoad(rtBitmap, 'EXAMPAGE', clFuchsia);

  FExamTable:=TXMTable.Create(dmExam.Period);
  FExamTable.OnChangePeriod:=OnChangePeriod;
  FExamTable.OnGroupInsert:=OnGroupInsert;
  FExamTable.OnGroupDelete:=OnGroupDelete;
  FExamTable.OnGroupUpdate:=OnGroupUpdate;

  FExamTable.OnExamInsert:=OnExamInsert;
  FExamTable.OnExamDelete:=OnExamDelete;
  FExamTable.OnExamUpdate:=OnExamUpdate;

  FItemEditor:=TExamItemEditor.Create(Self);
  FItemEditor.Caption:='Событие';
  FItemEditor.EditorUse:=euDblClick;
  Planner.DefaultItem.Editor:=FItemEditor;

  Planner.Sidebar.DateTimeFormat:='dd mmmm'#13'dddd';
  OnChangePeriod(FExamTable);
end;

procedure TfrmExamTable.FormDestroy(Sender: TObject);
begin
  FExamTable.Free;
end;

function TfrmExamTable.GetModuleName: string;
begin
  Result:='Экзамены';
end;

procedure TfrmExamTable.ModuleHandler(var Msg: TMessage);
var
  flags: WORD;
begin
  case Msg.Msg of

    SM_CHANGETIME:
      begin
        flags:=TSMChangeTime(Msg).Flags;
        if (flags and CT_YEAR)=CT_YEAR then // изм-ние года
        begin
          FExamTable.Clear;
          ClearPlanner;
          FExamTable.Period:=dmExam.Period;
        end else
          if (flags and CT_SEM)=CT_SEM then
          begin
            FExamTable.Period:=dmExam.Period;
          end;
      end;  // SM_CHANGETIME

  end;  // case
end;

function TfrmExamTable.GetHelpTopic: string;
begin
  Result:=HELP_EXAMTABLE_TABLE;
end;

// обновление модуля
procedure TfrmExamTable.UpdateModule;
begin
  FExamTable.Update;
end;

procedure TfrmExamTable.OnActionsExecute(Sender: TObject);

  procedure AddExam;
  var
    group: TXMGroup;
    xmtime: TDateTime;
    exam: TBaseExam;
  begin
    if Planner.SelPosition>=0 then
    begin
      group:=GetGroupOfPos(Planner.SelPosition);
      if Assigned(group) then
      begin
        xmtime:=Planner.CellToTime(Planner.SelItemBegin,0);
        exam:=TBaseExam.Create;
        try
          if ShowExamListDlg(xmtime,group,exam) then
            group.AddExam(exam);
        finally
          exam.Free;
          exam:=nil;
        end;
      end;
    end;
  end;  // procedure AddExam

  // удаление экз/конс
  procedure DeleteExam;
  var
    exam: TExam;
    item: TPlannerItem;
  begin
    item:=Planner.Items.Selected;
    if Assigned(item) then
    begin
      exam:=(item.ItemObject as TExam);
      if MessageDlg('Удалить событие?', mtConfirmation,[mbYes,mbNo],0)=mrYes then
        if exam.Parent.DelExam(exam) then
          Planner.FreeItem(item);
    end;
  end;  // procedure DeleteExam

begin
  case (Sender as TAction).Tag of

    -1:  // update
      UpdateModule;

    1:  // add groups
      ShowGroupListDlg(gdmAdd, dmExam, FExamTable, Planner.GridControl);

    2:  // delete groups
      ShowGroupListDlg(gdmDelete, dmExam, FExamTable, Planner.GridControl);

    3:  // add exam
      AddExam;

    4:  // delete exam
      DeleteExam;

    7:  // layer all
      Planner.Layer:=LAYER_ALL;

    8:  // layer exam
      Planner.Layer:=LAYER_EXAM;

    9:  // layer cons
      Planner.Layer:=LAYER_CONS;

    10:
      ShowExportExamTableDlg(FExamTable);

    else
      raise Exception.CreateFmt('Unknown action (Tag=%d)', [TAction(Sender).Tag]);

  end;  // case
end;

procedure TfrmExamTable.OnActionsUpdate(Sender: TObject);

  // проверка времени на вставку нов. экз/конс
  function AddedDate: boolean;
  var
    group: TXMGroup;
    xmtime: TDateTime;
  begin
    Result:=false;
    if Planner.SelItemBegin>=0 then
    begin
      group:=GetGroupOfPos(Planner.SelPosition);
      xmtime:=Planner.CellToTime(Planner.SelItemBegin,0);
      if Assigned(group) then Result:=group.CheckTime(xmtime);
    end;
  end;

begin
  case (Sender as TAction).Tag of

    2,  // delete groups
    10: // export exams
      TAction(Sender).Enabled:=(FExamTable.GroupCount>0);

    3:  // add exam
      TAction(Sender).Enabled:=AddedDate;

    4:  // delete exam
      TAction(Sender).Enabled:=Assigned(Planner.Items.Selected);

    7:  // layer all
      TAction(Sender).Checked:=(Planner.Layer=LAYER_ALL);

    8:  // layer exam
      TAction(Sender).Checked:=(Planner.Layer=LAYER_EXAM);

    9:  // layer cons
      TAction(Sender).Checked:=(Planner.Layer=LAYER_CONS);

  end;  // case
end;

// поиск позиции, соотв. группе (03.05.06)
function TfrmExamTable.FindPosGroup(AGroup: TXMGroup): integer;
var
  i: integer;
begin
  Result:=-1;

  for i:=0 to Planner.Header.Captions.Count-1 do
    if Planner.Header.Captions[i]=AGroup.grName then
    begin
      Result:=i-1;
      break;
    end;
end;

// опр-ние группы по позиции (08.05.06)
function TfrmExamTable.GetGroupOfPos(pos: integer): TXMGroup;
var
  s: string;
begin
  Result:=nil;

  if pos<Planner.Positions then
  begin
    s:=Planner.Header.Captions[pos+1];
    Result:=FExamTable.GroupByName(s);
  end;
end;

// поиск PlannerItam, соответ. AExam (04.05.06)
function TfrmExamTable.FindItemExam(AExam: TExam): TPlannerItem;
var
  i: integer;
  item: TPlannerItem;
begin
  Result:=nil;
  for i:=0 to Planner.Items.Count-1 do
  begin
    item:=Planner.Items[i];
    if item.ItemObject=AExam then
    begin
      Result:=item;
      break;
    end;
  end;  // for(i)
end;

procedure TfrmExamTable.ClearPlanner;
var
  i: integer;
begin
  Planner.GridControl.BeginUpdate;
  try
    for i:=Planner.Positions-1 downto 1 do
      Planner.DeletePosition(i);
    Planner.Items.ClearPosition(0);
    Planner.Header.Captions[1]:='';
  finally
    Planner.GridControl.EndUpdate;
  end;
end;

// событие при смене периода (03.05.06)
procedure TfrmExamTable.OnChangePeriod(Sender: TObject);
var
  period: TDatePeriod;
begin
  if Sender is TXMTable then
  begin
    period:=TXMTable(Sender).Period;
    Planner.Mode.BeginUpdate;
    Planner.Mode.PeriodStartDate:=period.dbegin;
    Planner.Mode.PeriodEndDate:=period.dend;
    Planner.Mode.EndUpdate;
  end;
end;

// событие при добавлении группы (03.05.06)
procedure TfrmExamTable.OnGroupInsert(Sender: TObject);
var
  group: TXMGroup;
  pos: integer;
begin
  if Sender is TXMGroup then
  begin
    group:=TXMGroup(Sender);
    pos:=Planner.Positions;
    if Planner.Header.Captions[pos]<>'' then
    begin
      inc(pos);
      Planner.Positions:=pos;
    end;
    Planner.Header.Captions[pos]:=group.grName;
  end;
end;

// событие при удалении группы (03.05.06)
procedure TfrmExamTable.OnGroupDelete(Sender: TObject);
var
  pos: integer;
begin
  if Sender is TXMGroup then
  begin
    pos:=FindPosGroup(TXMGroup(Sender));

    Planner.GridControl.BeginUpdate;

    if (pos>=0) and (Planner.Positions>1) then
      Planner.DeletePosition(pos)
    else
      if (pos=0) and (Planner.Positions=1) then
      begin
        Planner.Items.ClearPosition(pos);
        Planner.Header.Captions[pos+1]:='';
      end;

    Planner.GridControl.EndUpdate;

  end;
end;

// создание PlannerItem для экз/конс (08.05.06)
function TfrmExamTable.BuildPlannerItem(Pos: integer; AExam: TBaseExam): TPlannerItem;
var
  s: string;
begin
  Result:=Planner.CreateItem;
  Result.ItemStartTime:=AExam.xmtime;
  Result.ItemEnd:=Result.ItemBegin+1;
  Result.ItemPos:=Pos;
  Result.ItemObject:=AExam;
  Result.AllowOverlap:=AExam.subgrp;

  if AExam.xmtype=xmtExam then
  begin
    Result.Layer:=LAYER_EXAM;
    Result.ImageID:=0;
  end
  else
  begin
    Result.Layer:=LAYER_CONS;
    Result.ImageID:=1;
  end;
  Result.CaptionType:=ctText;
  DateTimeToString(s, 'hh:nn', AExam.xmtime);
  Result.CaptionText:=s;
  Result.Text.Clear;
  Result.Text.Add(AExam.subject);
  if AExam.auditory<>'' then Result.Text.Add(GetValue(AExam.auditory));
end;

// событие при обновлении расписания группы (03.05.06)
procedure TfrmExamTable.OnGroupUpdate(Sender: TObject);
var
  group: TXMGroup;
  pos: integer;
  i: integer;
  exam: TExam;
begin
  if Sender is TXMGroup then
  begin
    group:=TXMGroup(Sender);
    pos:=FindPosGroup(group);
    if pos>=0 then
    begin
      Planner.Items.BeginUpdate;
      Planner.Items.ClearPosition(pos);

      InitGroup(group, dmExam.xm_GetGrp(group.grid));

      // вывод, существующих экз/конс
      for i:=0 to group.ExamCount-1 do
      begin
        exam:=group.Exams[i];
        BuildPlannerItem(pos, exam);
      end;  // for

      Planner.Items.EndUpdate;

    end;  // if(pos>0)

  end;  // if(is TXMGroup)
end;

// событие при добавлении экз/конс (08.05.06)
procedure TfrmExamTable.OnExamInsert(Sender: TBaseExam; var Allow: boolean);
var
  pos: integer;
begin
  Allow:=dmExam.xm_Create(Sender.wpid,byte(Sender.xmtype),Sender.xmtime,
      Sender.subgrp, Sender.aid);
  if Allow then
  begin
    pos:=FindPosGroup(TExam(Sender).Parent);
    if pos>=0 then BuildPlannerItem(pos,Sender);
  end;
end;

// событие при удалении экз/конс (04.05.06)
procedure TfrmExamTable.OnExamDelete(Sender: TBaseExam; var Allow: boolean);
begin
  Allow:=dmExam.xm_Delete(Sender.wpid, byte(Sender.xmtype));
end;

// событие при обновлении экз/конс (04.05.06)
procedure TfrmExamTable.OnExamUpdate(Sender: TBaseExam; UpdateFlag: WORD;
  var Allow: boolean);
begin
  Allow:=false;

  case UpdateFlag of

    FLAG_XM_TIME     :  // изм-ния времени
      Allow:=dmExam.xm_SetTime(Sender.wpid,byte(Sender.xmtype),Sender.xmtime);

    FLAG_XM_SUBGRP   :  // изм-ния подгруппы
      begin
        Assert(Sender.xmtype=xmtExam,
          '94E67CF3-F5E5-4D3A-9C8D-995DFC963BD9'#13'Change hgrp only for exams'#13);
        Allow:=dmExam.xm_SetHGrp(Sender.wpid, Sender.subgrp);
      end;

    FLAG_XM_AUDITORY :  // изм-ния аудитории
      Allow:=dmExam.xm_SetAdr(Sender.wpid, byte(Sender.xmtype), Sender.aid);
      
  end;  // case
end;

procedure TfrmExamTable.PlannerDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);

  // проверка возмож-ти поставить экз/конс (07.05.06)
  function CheckEvent(const entity, pentity: TEntityData): boolean;
  var
    group: TXMGroup;
    xmtype: TXMType;
    xmdate: TDateTime;
    pt: TPoint;
  begin
    Assert(pentity.kind=ekGroup,
      'E4C7A866-64F7-4D60-BCD1-A3C60C74677A'#13'CheckEvent: pentity is not group'#13);

    Result:=false;

    group:=FExamTable.GroupByGrid(pentity.id);
    if Assigned(group) then
    begin
      xmtype:=TXMType(IfThen(GetKeyState(VK_CONTROL)<0, ord(xmtCons), ord(xmtExam)));
      pt:=TPlanner(Sender).XYToCell(X,Y);
      if (pt.X>=0) and (pt.Y>=0) then
      begin
        xmdate:=TPlanner(Sender).CellToTime(pt.X,pt.Y);
        Application.MainForm.Caption:=DateTimeToStr(xmdate);
        Result:=group.CheckPlace(entity.id,xmtype,xmdate);
      end;
    end;
  end;

var
  SourceForm: TCustomEntityForm;
  entity, pentity: TEntityData;
begin
  Accept:=false;

  if Source is TControl then
  begin
    SourceForm:=GetEntityForm(TControl(Source));
    if Assigned(SourceForm) then
      if SourceForm.GetEntityData(entity) then
      begin

        case entity.kind of

          ekGroup:  // проверка отсутствия группы
            Accept:=(FExamTable.FindGroup(entity.id)=-1);

          ekExamSubject:  // проверка отсутствия события в группе
            if SourceForm.GetParentData(pentity) then
              Accept:=CheckEvent(entity,pentity);

          else Accept:=false;
        end;  // case(kind)

      end;
  end;  // if (Source is TControl)
end;

procedure TfrmExamTable.PlannerDragDrop(Sender, Source: TObject; X, Y: Integer);

  // добавление экз/конс
  procedure AddExam(const entity, pentity: TEntityData);
  begin
  end;  // procedure AddExam

var
  SourceForm: TCustomEntityForm;
  entity, pentity: TEntityData;
begin
  if Source is TControl then
  begin
    SourceForm:=GetEntityForm(TControl(Source));
    if Assigned(SourceForm) then
      if SourceForm.GetEntityData(entity) then
      begin

        case entity.kind of
          ekGroup: // добавление группы
            FExamTable.AddGroup(entity.id,entity.name);
          ekExamSubject: // добавление экз/конс
            if SourceForm.GetParentData(pentity) then AddExam(entity,pentity);
        end;  // case(kind)

      end;
  end;
end;

// перетаскивание PlannerItem
{
procedure TfrmExamTable.PlannerItemMoving(Sender: TObject;
  Item: TPlannerItem; DeltaBegin, DeltaPos: Integer; var Allow: Boolean);
var
  exam: TExam;
  xmdate: TDateTime;
begin
  Allow:=false;

  if (DeltaPos=0) and (DeltaBegin<>0) then
  begin
    exam:=(Item.ItemObject as TExam);
    xmdate:=IncDay(Item.ItemStartTime, DeltaBegin);
    Allow:=exam.Parent.CheckPlace(exam.wpid,exam.xmtype,xmdate);

    Application.MainForm.Caption:=Format('xmdate: %s, item.date: %s, begin: %d, pos: %d',
      [DateTimeToStr(xmdate), DateTimeToStr(item.ItemStartTime), DeltaBegin, DeltaPos]);
  end;
end;
}

procedure TfrmExamTable.PlannerItemHint(Sender: TObject;
  Item: TPlannerItem; var Hint: String);
var
  exam: TExam;
  s: string;
begin
  exam:=(Item.ItemObject as TExam);

  if Assigned(exam) then
  begin
    if exam.xmtype=xmtExam then Hint:=rsExam else Hint:=rsCons;
    DateTimeToString(s, 'HH:mm', exam.xmtime);
    Hint:=Format('%s'#10#13'Время: %s'#10#13'%s'#10#13'%s: %s'#10#13'%s: %s',
      [Hint, s, exam.subject, rsTeacher, exam.teacher, rsAuditory, GetValue(exam.auditory)]);
  end
  else Hint:='';
end;

procedure TfrmExamTable.PlannerPlannerDblClick(Sender: TObject; Position,
  FromSel, FromSelPrecise, ToSel, ToSelPrecise: Integer);
begin
  if actExamAdd.Enabled then actExamAdd.Execute;
end;

procedure TfrmExamTable.PlannerItemDelete(Sender: TObject;
  Item: TPlannerItem);
begin
  if actExamDelete.Enabled then actExamDelete.Execute;
end;

procedure TfrmExamTable.PlannerItemInsert(Sender: TObject; Position,
  FromSel, FromSelPrecise, ToSel, ToSelPrecise: Integer);
begin
  if actExamAdd.Enabled then actExamAdd.Execute;
end;

end.
