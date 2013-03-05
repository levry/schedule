{
  ћодуль управлени€ дисциплинами
  v0.2.1  (15.03.06)
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
    actUpdate: TAction;
    btnReplace: TToolButton;
    btnUpdate: TToolButton;
    actViewGroup: TAction;
    btnViewGroup: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure HTMLabelAnchorClick(Sender: TObject; Anchor: String);
    procedure ActionsExecute(Sender: TObject);
    procedure ActionsUpdate(Sender: TObject);
  private
    { Private declarations }
    FLetter: char;
    procedure Set_letter(Value: char);
//    function Get_sbid: int64;
//    function Get_sbName: string;
//    function Get_sbSmall: string;
  protected
    function GetModuleName: string; override;

  public
    { Public declarations }
    procedure UpdateModule; override;

//    property Letter: char read FLetter write Set_letter;
//    property sbid: int64 read Get_sbid;
//    property sbName: string read Get_sbName;
//    property sbSmall: string read Get_sbSmall;
  end;

implementation

uses
  DataModule, ADOInt, Variants, SUtils, CloneDlgs, StringListDlg, BaseModule;

{$R *.dfm}

{ TfrmSubject }

function TfrmSubjects.GetModuleName: string;
begin
  Result:='ƒисциплины';
end;

procedure TfrmSubjects.FormCreate(Sender: TObject);
  procedure FillAlphabet;
  const
    letters: string = 'јЅ¬√ƒ≈∆«» ЋћЌќѕ–—“”‘’„ўЎЁёя';
    link: string = '<A href="%s">%s</A>';
  var
    i, l: integer;
    s: string;
    html: string;
  begin
    html:='<P align="center">';
    l:=Length(letters);
    for i:=1 to l do
    begin
      s:=Format(link,[letters[i],letters[i]]);
      html:=html+s;
      if i<l then html:=html+'  ';
    end;
    html:=html+'</P>';
    HTMLabel.HTMLText.Add(html);
  end; // procedure FillAlphabet
begin
  FLetter:='а';
  FillAlphabet;

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
//    Caption:='ƒисциплины: '+UpperCase(FLetter)+'...';
    UpdateModule;
  end;
end;

procedure TfrmSubjects.UpdateModule;
begin
  GetRecordset(dmMain.sbj_GetLetter(FLetter), DataSet);
end;

procedure TfrmSubjects.HTMLabelAnchorClick(Sender: TObject; Anchor: String);
begin
  Set_letter(Anchor[1]);
end;

// TODO: Delete
{
function TfrmSubjects.Get_sbid: int64;
var
  Field: TField;
begin
  Result:=0;
  if SubjectSet.Active then
    if SubjectSet.RecordCount>0 then
    begin
      Field:=SubjectSet.FieldByName('sbid');
      if Assigned(Field) then Result:=Field.AsInteger;
    end;
end;

function TfrmSubjects.Get_sbName: string;
var
  Field: TField;
begin
  Result:='';
  if sbid>0 then
  begin
    Field:=SubjectSet.FieldByName('sbName');
    if Assigned(Field) then Result:=Field.AsString;
  end;
end;

function TfrmSubjects.Get_sbSmall: string;
var
  Field: TField;
begin
  Result:='';
  if sbid>0 then
  begin
    Field:=SubjectSet.FieldByName('sbSmall');
    if Assigned(Field) then Result:=Field.AsString;
  end;
end;
}

procedure TfrmSubjects.ActionsExecute(Sender: TObject);

  procedure ViewGroups;
  var
    list: TStringList;
    ds: TADODataSet;
    sbid,grid: int64;
    s: string;
  begin
    if DataSet.Active then
    begin
      sbid:=DataSet.FieldByName('sbid').AsInteger;
      if sbid>0 then
      begin

        ds:=CreateDataSet(dmMain.dbv_GetGrpSubj(sbid));
        if Assigned(ds) then
        try
          if not ds.Eof then
          begin
            ds.Sort:='grName ASC';
            list:=TStringList.Create;
            try
              grid:=0;
              while not ds.Eof do
              begin
                if grid<>ds.FieldByName('grid').AsInteger then
                begin
                  grid:=ds.FieldByName('grid').AsInteger;
                  s:=ds.FieldByName('grid').AsString+'='+ds.FieldByName('grName').AsString;
                  list.Add(s);
                end;
                ds.Next;
              end;  // while
              ShowStringList('√руппы',list);
            finally
              list.Free;
              list:=nil;
            end;
          end  // if(not ds.eof)
          else
            MessageDlg('ƒисциплины нет ни в одном рабочем плане',mtInformation,[mbOK],0);  
        finally
          ds.Close;
          ds.Free;
        end;

      end;
    end;  // if Active
  end;  // procedure ViewGroups

begin
  case TAction(Sender).Tag of
    -1: // update
      UpdateModule;

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
