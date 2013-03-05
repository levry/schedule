{
  �������� �������
  v0.2.8 (11/09/06)
}

unit EditLsnsFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, SClasses, ExtCtrls, ComCtrls, Buttons;

type
  TEditKind = (ekTeacher, ekAuditory, ekSubgrp);
  TEditable = set of TEditKind;

  TfmEditLsns = class(TFrame)
    lblSubject: TLabel;
    imgTeacher: TImage;
    imgAuditory: TImage;
    chkSub: TCheckBox;
    tcType: TTabControl;
    lblTeacher: TLabel;
    lblAuditory: TLabel;
    btnTeacherList: TSpeedButton;
    btnAuditoryList: TSpeedButton;
    Bevel1: TBevel;
    Bevel2: TBevel;
    btnAuditoryKafList: TSpeedButton;
    procedure DoChange(Sender: TObject);
  private
    { Private declarations }
    fwday: byte;         // ����
    fnpair: byte;        // � ����

    FLsns: TBaseLsns;       // ������ �� ������. �������
    FEditable: TEditable;

    FOnChange: TNotifyEvent;

    procedure LoadFreeAuditory(const Value: string; List: TStrings);
    function GetTeacherFromList: string;
    function GetAuditoryFromList: string;
    function GetAuditoryKafFromList: string;

    procedure ShowTeacher;
    procedure ShowAuditory;
  public
    { Public declarations }
    property Lsns: TBaseLsns read FLsns;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;

    procedure SetPair(ADay,APair: byte);
    procedure Init(wday,npair: byte; const ALsns: TBaseLsns;
        const AEditable: TEditable);
//    function IsModified: boolean;
  end;

implementation

uses
  ADODB,
  TimeModule, SUtils, SConsts,
  StringListDlg, DataListDlg;

{$R *.dfm}

// ����� ����
procedure TfmEditLsns.SetPair(ADay,APair: byte);
begin
  if (fwday<>ADay) or (fnpair<>APair) then
  begin
    fwday:=ADay;
    fnpair:=APair;
  end;
end;

function TfmEditLsns.GetTeacherFromList: string;
var
  rs: _Recordset;
  list: TStringList;
  s: string;
begin
  Result:='';

  rs:=dmMain.sdl_GetFreeThr_l(FLsns.lid,FLsns.parity,fwday+1,fnpair+1);
  list:=TStringList.Create;
  try
    rs.Sort:='Initials ASC';
    list.Add('0=');
    while not rs.EOF do
    begin
      s:=Format(rs.Fields.Item['tid'].Value,
        rs.Fields.Item['psmall'].Value+' '+rs.Fields.Item['initials'].Value,
        rs.Fields.Item['tprefer'].Value);
      list.Add(s);
      rs.MoveNext;
    end;
    if GetStrFromList('�������������',FLsns.teacher,s,list,[lkColor]) then Result:=s;
  finally
    list.Free;
    rs:=nil;
  end;
end;

// �������� ������ (������. ���������)
procedure TfmEditLsns.LoadFreeAuditory(const Value: string; List: TStrings);
var
  rs: _Recordset;
  fid: integer;
  s: string;
begin
  fid:=integer(GetID(Value));
  rs:=dmMain.sdl_GetFreeAdr_l(fid, FLsns.lid,FLsns.parity,fwday+1,fnpair+1);
  if Assigned(rs) then
  try
    rs.Sort:='aName ASC';
    List.Add('0=');
    while not rs.EOF do
    begin
      s:=Format(rs.Fields.Item['aid'].Value,
        rs.Fields.Item['aName'].Value,
        rs.Fields.Item['aprefer'].Value);
      List.Add(s);
      rs.MoveNext;
    end;
  finally
    rs.Close;
    rs:=nil;
  end;
end;

function TfmEditLsns.GetAuditoryFromList: string;
begin
  if not GetDataFromList('���������', LoadFreeAuditory, dmMain.FacultyList, Result) then
    Result:='';
end;

function TfmEditLsns.GetAuditoryKafFromList: string;
var
  rs: _Recordset;
  list: TStringList;
  s: string;
begin
  Result:='';

  rs:=dmMain.sdl_GetFreeAdr_lk(FLsns.lid,FLsns.parity,fwday+1,fnpair+1);
  list:=TStringList.Create;
  try
    rs.Sort:='aName ASC';
    list.Add('0=');
    while not rs.EOF do
    begin
      s:=Format(rs.Fields.Item['aid'].Value,
        rs.Fields.Item['aName'].Value,
        rs.Fields.Item['aprefer'].Value);
      list.Add(s);
      rs.MoveNext;
    end;
    if GetStrFromList('���������',FLsns.auditory,s,list,[lkColor]) then Result:=s;
  finally
    list.Free;
    rs:=nil;
  end;
end;

procedure TfmEditLsns.ShowTeacher;
begin
  if bDebugMode then lblTeacher.Caption:=FLsns.teacher
    else lblTeacher.Caption:=SUtils.GetValue(FLsns.teacher);

  case GetState(FLsns.teacher) of
    STATE_FREE:  lblTeacher.Font.Color:=clWindowText;
    STATE_BUSY:  lblTeacher.Font.Color:=clRed;
    STATE_GREEN: lblTeacher.Font.Color:=clGreen;
    STATE_RED:   lblTeacher.Font.Color:=clNavy;
  end;
end;

procedure TfmEditLsns.ShowAuditory;
begin
  if bDebugMode then lblAuditory.Caption:=FLsns.auditory
    else lblAuditory.Caption:=SUtils.GetValue(FLsns.auditory);

  case GetState(FLsns.auditory) of
    STATE_FREE:  lblAuditory.Font.Color:=clWindowText;
    STATE_BUSY:  lblAuditory.Font.Color:=clRed;
    STATE_GREEN: lblAuditory.Font.Color:=clGreen;
    STATE_RED:   lblAuditory.Font.Color:=clNavy;
  end;
end;

// �������������
procedure TfmEditLsns.Init(wday,npair: byte; const ALsns: TBaseLsns;
  const AEditable: TEditable);

const
  stype: array[0..2] of string = ('������','��������','���. �������');
begin
  fwday:=wday;
  fnpair:=npair;
  FLsns:=ALsns;
  FEditable:=AEditable;
//  FLsns.Assign(ALsns);

  // �������
  if bDebugMode then lblSubject.Caption:=Lsns.subject
    else lblSubject.Caption:=SUtils.GetValue(Lsns.subject);
  tcType.Tabs[0]:=stype[Lsns.ltype-1];

  // ����-��
  btnTeacherList.Enabled:=ekTeacher in FEditable;
  ShowTeacher;

  // ���������
  btnAuditoryList.Enabled:=ekAuditory in FEditable;
  btnAuditoryKafList.Enabled:=ekAuditory in FEditable;
  ShowAuditory;

  // ���������
  chkSub.Enabled:=(ekSubgrp in FEditable);
  chkSub.Checked:=Lsns.subgrp;
end;

procedure TfmEditLsns.DoChange(Sender: TObject);
var
  change: boolean;
  s: string;
  hgrp: boolean;
begin
  change:=false;
  case TComponent(Sender).Tag of

    1: // Teacher
      if ekTeacher in FEditable then
      begin
        s:=GetTeacherFromList;
        if (FLsns.tid<>GetId(s)) and (s<>'') then
        begin
          FLsns.teacher:=s;
          //ShowTeacher;             // �������: ��������� � �����. ��������
          change:=true;
        end;
      end; // 1

    2: // Auditory
      if ekAuditory in FEditable then
      begin
        s:=GetAuditoryFromList;
        if (FLsns.aid<>GetId(s)) and (s<>'') then
        begin
          FLsns.auditory:=s;
          ShowAuditory;
          change:=true;
        end;
      end; // 2

    3: // Sub group
      if ekSubgrp in FEditable then
      begin
        hgrp:=(Sender as TCheckBox).Checked;
        if FLsns.subgrp<>hgrp then
        begin
          FLsns.subgrp:=hgrp;
          change:=true;
        end;
      end; // 3

    4:  // auditory of kafedra
      if ekAuditory in FEditable then
      begin
        s:=GetAuditoryKafFromList();
        if (FLsns.aid<>GetID(s)) and (s<>'') then
        begin
          FLsns.auditory:=s;
          ShowAuditory();
          change:=true;
        end;
      end;

  end; // case

  if change then if Assigned(FOnChange) then FOnChange(Self);
end;

// ���-��� ���-��� �������
//function TfmEditLsns.IsModified: boolean;
//begin
//  Result:=(Lsns.auditory<>foldadr) or (Lsns.teacher<>foldthr) or (Lsns.subgrp<>foldsub);
//end;


end.
