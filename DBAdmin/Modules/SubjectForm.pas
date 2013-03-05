{
  Модуль управления дисциплинами
  v0.2.4  (25/01/10)
}

unit SubjectForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, Modules, DB, ADODB, Grids, DBGrids, ToolWin, ComCtrls, StdCtrls,
  HTMLabel, ActnList;

type
  TfrmSubjects = class(TModuleForm)
    DBGrid: TDBGrid;
    DataSet: TADODataSet;
    DataSource: TDataSource;
    ToolBar: TToolBar;
    HTMLabel: THTMLabel;
    ActionList: TActionList;
    actReplace: TAction;
    btnReplace: TToolButton;
    actViewGroup: TAction;
    btnViewGroup: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure HTMLabelAnchorClick(Sender: TObject; Anchor: String);
    procedure ActionsExecute(Sender: TObject);
    procedure ActionsUpdate(Sender: TObject);
  private
    { Private declarations }
    FQuery: string;
    FLetter: char;
    procedure Set_letter(Value: char);

  protected
    function GetModuleName: string; override;

  public
    { Public declarations }
    procedure UpdateModule; override;

  end;

implementation

uses
  ADOInt, Variants,
  AdminModule, SUtils, SConsts, SStrings, SDBUtils,
  CopyObjectDlg, StringListDlg, SubjectListDlg, RecordsetDlg;


{$R *.dfm}

{ TfrmSubject }

function TfrmSubjects.GetModuleName: string;
begin
  Result:='Дисциплины';
end;

procedure TfrmSubjects.FormCreate(Sender: TObject);
begin
  FQuery:=SELECT_SUBJECT;
  FLetter:='а';
  HTMLabel.HTMLText.Add(GetHTMLAlphabet);

  if bDebugMode then
    with DBGrid.Columns.Insert(0) as TColumn do
    begin
      FieldName:='sbid';
      ReadOnly:=true;
      Width:=50;
    end;
end;

procedure TfrmSubjects.Set_letter(Value: char);
begin
  if FLetter<>Value then
  begin
    FLetter:=Value;
    UpdateModule;
  end;
end;

procedure TfrmSubjects.UpdateModule;
begin
  GetRecordset(dmAdmin.sbj_GetLetter(FLetter),DataSet);
end;

procedure TfrmSubjects.HTMLabelAnchorClick(Sender: TObject; Anchor: String);
begin
  Set_letter(Anchor[1]);
end;

function GetSubject: string;
begin
  Result:='';
  GetSubjectFromList(#0, dmAdmin.sbj_GetLetter, Result);
end;

// копироавние дисциплины
// (параметры в обратном порядке в отличие от CopyDlg.TCopyFunc)
function CopySubject(new,sbid: int64): boolean;
begin
  Result:=dmAdmin.sbj_Replace(sbid,new);
end;

procedure TfrmSubjects.ActionsExecute(Sender: TObject);

  procedure ViewGroups;
  const
    SELECT_GROUP_SUBJ =
      'select g.grName, g.ynum,'#13+
          'sem ='#13+
            'case sem'#13+
              'when 1 then ''%s'''#13+
              'when 2 then ''%s'''#13+
              'else cast(sem as varchar)'#13+
            'end'#13+
        'from tb_workplan w'#13+
          'join tb_group g on g.grid=w.grid'#13+
        'where w.sbid=%d';
  var
    rs: _Recordset;

    sbid: int64;
    s: string;
  begin

    // TODO: Доработать
    if DataSet.Active then
    begin

      sbid:=DataSet.FieldByName('sbid').AsInteger;
      if sbid>0 then
      begin

        s:=Format(SELECT_GROUP_SUBJ,[csSemester[1],csSemester[2],sbid]);
        rs:=dmAdmin.OpenQuery(s);
        if Assigned(rs) then
        try
          if not rs.EOF then
          begin
            rs.Sort:='grName ASC';
            ShowRecordsetDlg('Группы',rs,
                ['grName','ynum','sem'],['Группа','Учебный год','Семестр']);
          end
          else
            MessageDlg('Дисциплины нет ни в одном рабочем плане',mtInformation,[mbOK],0);
        finally
          rs.Close;
          rs:=nil;
        end;

      end;  // if(sbid>0)

    end;  // if Active

  end;  // procedure ViewGroups

  function ReplaceSubject(sbid: int64; sbName: string): boolean;
  begin
    Result:=CopyObject('Замена дисциплины','Дисциплина',
        sbid,sbid,sbName,dmAdmin.Connection,GetSubject,CopySubject,nil);
  end;

begin
  case TAction(Sender).Tag of

    1:  // replace
      with DataSet do
        if Active then
          if not FieldByName('sbid').IsNull then
            if ReplaceSubject(FieldByName('sbid').AsInteger, FieldByName('sbName').AsString) then
              UpdateModule;

    2:  // view group
      ViewGroups;

    else
      raise Exception.CreateFmt('Unknown action (Tag=%d)', [TAction(Sender).Tag]);
  end; // case
end;

procedure TfrmSubjects.ActionsUpdate(Sender: TObject);

  function SelectedSubject: boolean;
  begin
    Result:=false;
    if DataSet.Active then
      if not DataSet.FieldByName('sbid').IsNull then Result:=true;
  end;

begin
  case TAction(Sender).Tag of

    1,2:  // replace,view groups
      TAction(Sender).Enabled:=SelectedSubject;

    else
      raise Exception.CreateFmt('Unknown action (Tag=%d)', [TAction(Sender).Tag]);
  end;
end;

end.
