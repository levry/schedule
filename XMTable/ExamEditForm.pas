{
  Редактор события TPlanner
  v0.0.1  (04.05.06)
  (C) Leonid Riskov, 2006
}
unit ExamEditForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Planner, StdCtrls, ComCtrls, Buttons,
  SExams;

type
  TEditFieldKind = (efkTime, efkAuditory, efkSubgrp);
  TEditFields = set of TEditFieldKind;

  TfrmExamEdit = class(TForm)
    btnOk: TButton;
    btnCancel: TButton;
    lblSubject: TLabel;
    Label1: TLabel;
    lblTeacher: TLabel;
    lblTime: TLabel;
    TimePicker: TDateTimePicker;
    Label2: TLabel;
    lblAuditory: TLabel;
    btnFacAuditory: TSpeedButton;
    chkSubgrp: TCheckBox;
    Label3: TLabel;
    TabControl: TTabControl;
    btnKafAuditory: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure OnExamChange(Sender: TObject);
    procedure btnAuditoryClick(Sender: TObject);
  private
    { Private declarations }
    FExam: TBaseExam;
    FEditFields: TEditFields;

    procedure SetExam(Value: TBaseExam);
    procedure DoViewExam(AExam: TBaseExam);
    procedure SetEditFields(Value: TEditFields);

    procedure GetFacultyAuditory(const Value: string; List: TStrings);

  public
    { Public declarations }

    property Exam: TBaseExam read FExam write SetExam;
    property EditFields: TEditFields read FEditFields write SetEditFields;
  end;

  // редактор TPlannerItem
  TExamItemEditor = class(TCustomItemEditor)
  private
    FEditForm: TfrmExamEdit;
  public
    constructor Create(AOwner: TComponent); override;
    function QueryEdit(APlannerItem: TPlannerItem): Boolean; override;
    procedure CreateEditor(AOwner: TComponent); override;
    procedure DestroyEditor; override;
    function Execute: Integer; override;
    procedure PlannerItemToEdit(APlannerItem: TPlannerItem); override;
    procedure EditToPlannerItem(APlannerItem: TPlannerItem); override;

  end;

implementation

uses
  DateUtils, ADODB,
  SUtils, SStrings, DataListDlg, ExamModule, StringListDlg;

{$R *.dfm}

{ TExamItemEditor }

constructor TExamItemEditor.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

function TExamItemEditor.QueryEdit(APlannerItem: TPlannerItem): Boolean;
begin
  if Assigned(APlannerItem.ItemObject) then
    Result:=(APlannerItem.ItemObject is TExam)
  else
    Result:=false;
end;

// создание формы-редактора
procedure TExamItemEditor.CreateEditor(AOwner: TComponent);
begin
  inherited;

  FEditForm:=TfrmExamEdit.Create(AOwner);
  FEditForm.Caption:=Caption;
end;

// уничтожение формы-редактора
procedure TExamItemEditor.DestroyEditor;
begin
  inherited;
  FEditForm.Free;
end;

// сохранение события
procedure TExamItemEditor.EditToPlannerItem(APlannerItem: TPlannerItem);
var
  exam: TBaseExam;
  s: string;
begin
  exam:=(APlannerItem.ItemObject as TBaseExam);

  if exam.AssignFrom(FEditForm.Exam) then
  begin
    APlannerItem.ItemStartTime:=exam.xmtime;
    APlannerItem.ItemEnd:=APlannerItem.ItemBegin+1;
    DateTimeToString(s, 'hh:nn', exam.xmtime);
    APlannerItem.CaptionText:=s;
    APlannerItem.AllowOverlap:=exam.subgrp;

    APlannerItem.Text.Clear;
    APlannerItem.Text.Add(exam.subject);
    if exam.auditory<>'' then APlannerItem.Text.Add(GetValue(exam.auditory));
  end;

end;

function TExamItemEditor.Execute: Integer;
begin
  Result:=FEditForm.ShowModal;
end;

// загрузка события в форму-редактор
procedure TExamItemEditor.PlannerItemToEdit(APlannerItem: TPlannerItem);
begin
  FEditForm.Exam:=(APlannerItem.ItemObject as TBaseExam);

  if Planner.Items.ItemsAtCell(APlannerItem.ItemBegin,
    APlannerItem.ItemEnd,APlannerItem.ItemPos)>1 then
    FEditForm.EditFields:=[efkAuditory];
end;

{ TfrmItemEditor }

procedure TfrmExamEdit.FormCreate(Sender: TObject);
begin
  FEditFields:=[efkTime,efkAuditory,efkSubgrp];
  
  FExam:=TBaseExam.Create;
end;

procedure TfrmExamEdit.FormDestroy(Sender: TObject);
begin
  FExam.Free;
end;

procedure TfrmExamEdit.SetExam(Value: TBaseExam);
begin
  FExam.Assign(Value);
  DoViewExam(FExam);
end;

procedure TfrmExamEdit.DoViewExam(AExam: TBaseExam);
begin
  Assert(Assigned(AExam),
    'C8A5E9F9-A694-4BF6-BBAD-FB1DF1D992AE'#13'AssignFromExam: AExam is nil'#13);

  if AExam.xmtype=xmtExam then TabControl.Tabs[0]:=rsExam
    else TabControl.Tabs[0]:=rsCons;

  lblSubject.Caption:=AExam.subject;
  lblTeacher.Caption:=StringReplace(AExam.teacher, ';', #10#13,
      [rfReplaceAll, rfIgnoreCase]);
  TimePicker.DateTime:=AExam.xmtime;
  lblAuditory.Caption:=GetValue(AExam.auditory);
  chkSubgrp.Checked:=AExam.subgrp;
  if AExam.xmtype=xmtCons then chkSubgrp.Enabled:=false;
end;

// загрузка свобод. аудиторий факультета
procedure TfrmExamEdit.GetFacultyAuditory(const Value: string; List: TStrings);
var
  rs: _Recordset;
  fid: int64;
  s: string;
begin
  fid:=integer(GetID(Value));
  if fid>0 then
  begin
    rs:=dmExam.xm_GetFreeAid_f(fid, FExam.xmtime);
    if Assigned(rs) then
    try
      rs.Sort:='aName ASC';
      List.Add('0=');
      while not rs.EOF do
      begin
        s:=VarToStr(rs.Fields['aid'].Value)+'='+VarToStr(rs.Fields['aName'].Value);
        List.Add(s);
        rs.MoveNext;
      end;
    finally
      rs.Close;
      rs:=nil;
    end;
  end;
end;

procedure TfrmExamEdit.OnExamChange(Sender: TObject);
begin
  case (Sender as TComponent).Tag of
    1:  // change time
      begin
        FExam.xmtime:=TDateTimePicker(Sender).DateTime;
        FExam.auditory:='';
        lblAuditory.Caption:=GetValue(FExam.auditory);
      end;
    2:  // change sub
      FExam.subgrp:=TCheckBox(Sender).Checked;
    else
      raise Exception.CreateFmt('Unknown sender (Tag=%d)',[TComponent(Sender).Tag]);
  end;
end;

procedure TfrmExamEdit.btnAuditoryClick(Sender: TObject);

  function GetKafedraAuditory(var sResult: string): boolean;
  var
    list: TStringList;
    rs: _Recordset;
    s: string;
  begin
    Result:=false;
    
    rs:=dmExam.xm_GetFreeAid_w(FExam.wpid, FExam.xmtime);
    if Assigned(rs) then
    try
      list:=TStringList.Create;
      try
        list.Add('0=');
        rs.Sort:='aName ASC';
        while not rs.EOF do
        begin
          s:=VarToStr(rs.Fields['aid'].Value)+'='+VarToStr(rs.Fields['aName'].Value);
          list.Add(s);
          rs.MoveNext;
        end;
        Result:=GetStrFromList(rsAuditory, FExam.auditory, sResult, list);
      finally
        list.Free;
        list:=nil;
      end;
    finally
      rs.Close;
      rs:=nil;
    end;
  end;

var
  s: string;
  change: boolean;
begin
  case (Sender as TSpeedButton).Tag of
    3:
      change:=GetDataFromList(rsAuditory, GetFacultyAuditory, dmExam.FacultyList, s);
    4:
      change:=GetKafedraAuditory(s);
    else
      change:=false;
  end;  // case

  if change then
  begin
    FExam.auditory:=s;
    lblAuditory.Caption:=GetValue(FExam.auditory);
  end;
end;

procedure TfrmExamEdit.SetEditFields(Value: TEditFields);
begin
  if FEditFields<>Value then
  begin
    FEditFields:=Value;
    TimePicker.Enabled:=(efkTime in FEditFields);
    btnFacAuditory.Enabled:=(efkAuditory in FEditFields);
    btnKafAuditory.Enabled:=(efkAuditory in FEditFields);
    chkSubgrp.Enabled:=(efkSubgrp in FEditFields);
  end;
end;

end.
