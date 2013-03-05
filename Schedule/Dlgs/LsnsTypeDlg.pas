{
  Диалог выбора доступ. занятий по дисциплине
  v0.0.3 (22.03.06)
}

unit LsnsTypeDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, BaseGrid, AdvGrid, StdCtrls, SClasses, ExtCtrls,
  frmctrllink, EditLsnsFrame, ComCtrls;

type
  TfrmLsnsTypeDlg = class(TForm)
    LsnsGrid: TAdvStringGrid;
    btnOk: TButton;
    btnCancel: TButton;
    CtrlEditLink: TFormControlEditLink;
    lblPair: TLabel;
    procedure LsnsGridGetDisplText(Sender: TObject; ACol, ARow: Integer;
      var Value: String);
    procedure LsnsGridCellChanging(Sender: TObject; OldRow, OldCol, NewRow,
      NewCol: Integer; var Allow: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure LsnsGridGetEditorType(Sender: TObject; ACol, ARow: Integer;
      var AEditor: TEditorType);
    procedure CtrlEditLinkSetEditorValue(Sender: TObject;
      Grid: TAdvStringGrid; AValue: String);
    procedure LsnsGridCanEditCell(Sender: TObject; ARow, ACol: Integer;
      var CanEdit: Boolean);
  private
    { Private declarations }
    FEditor: TfmEditLsns;

    FList: array[0..2] of TAvailLsns;   // занятия (тип)
    findex: integer;

    fgroup: string;       // grid=grName
    fsubject: string;     // sbid=sbName
    fweek: byte;
    fwday: byte;
    fnpair: byte;
    function GetResultLsns: TAvailLsns;
    procedure LoadList;
    procedure ClearList;
  public
    { Public declarations }
  end;

function ShowLsnsTypeDlg(const group,subject: string; aweek,awday,anpair: byte): TLsns;

implementation

uses
  TimeModule, SUtils, ADODB, SConsts;

{$R *.dfm}

function ShowLsnsTypeDlg(const group,subject: string; aweek,awday,anpair: byte): TLsns;
var
  frmDlg: TfrmLsnsTypeDlg;
  lsns: TAvailLsns;
const
  sDays: array[0..5] of string = ('Понедельник','Вторник','Среда','Четверг','Пятница','Суббота');
  sWeek: array[0..2] of string = ('','[четная]','[нечетная]');

begin
  Assert(group<>'',
    '6DCA2EA2-B83E-499A-82FE-FE8F3A70B966'#13'ShowLsnsTypeDlg: invalid group'#13);
  Assert(subject<>'',
    '265C537B-66B9-44CC-B708-3C1F2373EEA4'#13'ShowLsnsTypeDlg: invalid subject'#13);

  Result:=nil;
  frmDlg:=TfrmLsnsTypeDlg.Create(Application);
  try
    frmDlg.Caption:=Format('Выбор занятия - %s',[GetValue(group)]);
//    frmDlg.lblInfo.Caption:=GetValue(group);
    frmDlg.lblPair.Caption:=SysUtils.Format('[%s] [%d пара] %s',[sDays[awday],anpair+1,sWeek[aweek]]);
    frmDlg.findex:=-1;
    frmDlg.fgroup:=group;
    frmDlg.fsubject:=subject;
    frmDlg.fweek:=aweek;
    frmDlg.fwday:=awday;
    frmDlg.fnpair:=anpair;
    frmDlg.LoadList;
    if frmDlg.ShowModal=mrOk then
    begin
      lsns:=frmDlg.GetResultLsns;
      if Assigned(lsns) then Result:=TLsns.Create(lsns);
    end;
  finally
    frmDlg.Free;
    frmDlg:=nil;
  end;
end;

// загрузка данных
procedure TfrmLsnsTypeDlg.LoadList;
var
  ds: TADODataSet;
  i: integer;
begin
  Assert(GetId(fgroup)>0,
    '468CD077-6F75-48DB-B8D9-6B40EDE2F786'#13'LoadLsns: invalid fgroup'#13);
  Assert(GetId(fsubject)>0,
    '2028B4B1-295D-4035-A6AA-9BCA131C9A24'#13'LoadLsns: invalid fsubject'#13);

  findex:=-1;
  ClearList;
  ds:=CreateDataSet(dmMain.sdl_GetAvail_sb(GetId(fgroup),GetId(fsubject),
      fweek,fwday+1,fnpair+1));
  if Assigned(ds) then
  try
    while not ds.Eof do
    begin
      i:=ds.FieldByName('type').AsInteger-1;
      FList[i]:=TAvailLsns.Create;
      FList[i].Assign(ds.Fields);

      if findex=-1 then
        if FList[i].CheckLsns then
        begin
          LsnsGrid.SelectRows(i,1);
          findex:=i;
        end;

      ds.Next;
    end;
  finally
    ds.Close;
    ds.Free;
    ds:=nil;
  end;

  btnOk.Enabled:=findex<>-1;
end;

procedure TfrmLsnsTypeDlg.ClearList;
var
  i: integer;
begin
  for i:=Low(FList) to High(FList) do
    if Assigned(FList[i]) then
    begin
      FList[i].Free;
      FList[i]:=nil;
    end;
end;

function TfrmLsnsTypeDlg.GetResultLsns: TAvailLsns;
begin
  Result:=nil;
  if findex<>-1 then
    if Assigned(FList[findex]) then
      if FList[findex].CheckLsns then Result:=FList[findex];
end;

procedure TfrmLsnsTypeDlg.LsnsGridGetDisplText(Sender: TObject; ACol,
  ARow: Integer; var Value: String);
const
  s: string = '%s'#13'%s'#13'Преподаватель: %s'#13'Аудитория: %s';
  st: array[0..2] of string = ('Лекция', 'Практическое занятие', 'Лабораторное занятие');
var
  ss,sbj,thr,aud,war: string;
  lsns: TAvailLsns;

  function BuildStr(s,sdef: string; FStyle: TFontStyles=[]): string;
  var
    clr: TColor;
    ss: string;
//    tag: integer;
  begin
    if GetId(s)>0 then
    begin
      ss:=GetValue(s);
      case GetState(s) of
        STATE_BUSY:
          begin
            clr:=clRed;
            ss:=ss+' (занят)';
          end;
        STATE_GREEN:
          begin
            clr:=clGreen;
            ss:=ss+' (пжл.)';
          end;
        STATE_RED:
          begin
            clr:=clNavy;
            ss:=ss+' (огр.)'
          end;
        else clr:=clBlack;
      end;  // case
    end
    else
    begin
      clr:=clRed;
      ss:=sdef;
    end;
    Result:=ToHTML(ss,FStyle,clr);
  end;

begin
  lsns:=FList[ARow];
  if Assigned(lsns) then
  begin
    sbj:=GetValue(lsns.subject);
    if lsns.IsStrm then sbj:=sbj+' (поток)';
    sbj:=ToHTML(sbj,[fsBold]);
    thr:=BuildStr(lsns.teacher,'[Не указан]');
    aud:=BuildStr(lsns.auditory,'[Не указана]');
    ss:=SysUtils.Format(s,[st[ARow],sbj,thr,aud]);
    ss:=ss+#13'Доступно (часы): '+FloatToStr(lsns.ahours/2);
    // причина недоступности занятия
    if not lsns.CheckLsns then
    begin
      war:='';
      if lsns.ahours<=0 then war:='Нет доступных часов'#13;
      if (not lsns.CheckThr) then war:=war+'Преподаватель занят'#13;
      if (not lsns.CheckStm) then war:=war+'Группы заняты';
      ss:=ss+#13+ToHTML(war,[],clRed);
    end
  end
  else ss:=st[ARow]+#13'Занятия не определены';
  Value:=ss;
end;

procedure TfrmLsnsTypeDlg.LsnsGridCellChanging(Sender: TObject; OldRow,
  OldCol, NewRow, NewCol: Integer; var Allow: Boolean);
begin
  Allow:=true;
  findex:=-1;
  if Assigned(FList[NewRow]) then
    if FList[NewRow].CheckLsns then findex:=NewRow;
  btnOk.Enabled:=(findex<>-1);
end;

procedure TfrmLsnsTypeDlg.FormDestroy(Sender: TObject);
begin
  ClearList;
end;

procedure TfrmLsnsTypeDlg.FormCreate(Sender: TObject);
begin
  FEditor:=TfmEditLsns.Create(Self);
  CtrlEditLink.Control:=FEditor;

  with LsnsGrid do
  begin
    DefaultColWidth:=Width-2*GridLineWidth-2*BorderWidth-1;
    DefaultRowHeight:=(Height-(RowCount)*GridLineWidth-2*BorderWidth) div RowCount;
  end;
end;

procedure TfrmLsnsTypeDlg.LsnsGridGetEditorType(Sender: TObject; ACol,
  ARow: Integer; var AEditor: TEditorType);
begin
  (Sender as TadvStringGrid).EditLink:=CtrlEditLink;
  AEditor:=edCustom;
end;

procedure TfrmLsnsTypeDlg.CtrlEditLinkSetEditorValue(Sender: TObject;
  Grid: TAdvStringGrid; AValue: String);
var
  lsns: TAvailLsns;
  Editable: TEditable;
begin
  lsns:=FList[TEditLink(Sender).EditCell.Y];
  if Assigned(lsns) then
  begin
    Editable:=[ekAuditory];
    if lsns.CheckedSub then Include(Editable,ekSubgrp);

    FEditor.Init(fwday,fnpair,lsns,Editable);
  end;
end;

procedure TfrmLsnsTypeDlg.LsnsGridCanEditCell(Sender: TObject; ARow,
  ACol: Integer; var CanEdit: Boolean);
begin
  if Assigned(FList[Arow]) then CanEdit:=FList[ARow].CheckLsns
    else CanEdit:=false;
//  CanEdit:=Assigned(ALsns[Arow]);
end;

end.
