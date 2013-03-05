{
  Диалог список дисциплин
  v0.0.5  (25/01/10)
}

unit SubjectListDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, HTMLabel, ADOInt;

type
  TLoadSubjectFunc = function(sLetter: string): _Recordset of object;

  TfrmSubjectListDlg = class(TForm)
    btnOk: TButton;
    btnCancel: TButton;
    ListBox: TListBox;
    HTMLabel: THTMLabel;
    procedure FormCreate(Sender: TObject);
    procedure ListBoxDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure HTMLabelAnchorClick(Sender: TObject; Anchor: String);
    procedure ListBoxDbClick(Sender: TObject);

  private
    { Private declarations }
    FLoadSubjectFunc: TLoadSubjectFunc;
    FLetter: char;

    procedure DoLoadSubjects(cLetter: char);

//    procedure UpdateList;
    function Get_sbid: int64;
    function Get_sbName: string;
    function Get_subject: string;
  public
    { Public declarations }
    property sbid: int64 read Get_sbid;
    property sbName: string read Get_sbName;
    property subject: string read Get_subject;
  end;

function GetSubjectFromList(Letter: char; LoadSubjectFunc: TLoadSubjectFunc;
    var sResult: string): boolean;

implementation

uses
  SUtils, ADODB;

{$R *.dfm}

function GetSubjectFromList(Letter: char; LoadSubjectFunc: TLoadSubjectFunc;
    var sResult: string): boolean;
var
  frmDlg: TfrmSubjectListDlg;
begin
  Result:=false;

  frmDlg:=TfrmSubjectListDlg.Create(Application);
  try
    frmDlg.FLoadSubjectFunc:=LoadSubjectFunc;

    if Letter<>#0 then frmDlg.DoLoadSubjects(Letter)
      else frmDlg.DoLoadSubjects('а');

    if frmDlg.ShowModal=mrOk then
    begin
      sResult:=frmDlg.subject;
      Result:=(sResult<>'');
    end;
  finally
    frmDlg.Free;
  end;
end;

{ TfrmSubjectListDlg }

procedure TfrmSubjectListDlg.DoLoadSubjects(cLetter: char);
var
  rs: _Recordset;
  s: string;
begin
  if FLetter<>cLetter then
  begin
    FLetter:=cLetter;

    ListBox.Items.BeginUpdate;
    try
      ListBox.Clear;

      rs:=FLoadSubjectFunc(FLetter);
      if Assigned(rs) then
      try
        while not rs.EOF do
        begin
          s:=VarToStr(rs.Fields['sbid'].Value)+'='+VarToStr(rs.Fields['sbName'].Value);
          ListBox.AddItem(s,nil);
          rs.MoveNext;
        end;
      finally
        rs.Close;
        rs:=nil;
      end;

    finally
      ListBox.Items.EndUpdate;
    end;

  end;
end;

procedure TfrmSubjectListDlg.FormCreate(Sender: TObject);
begin
  FLetter:=#0;
  HTMLabel.HTMLText.Add(SUtils.GetHTMLAlphabet);
end;

// обновление списка
{
procedure TfrmSubjectListDlg.UpdateList;
var
  ds: TADODataSet;
begin
  if FLetter<>'' then
  begin
    ListBox.Clear;
    ds:=TADODataSet.Create(self);
    try
      if GetRecordset(dmMain.sbj_GetLetter(FLetter),ds) then
        while not ds.Eof do
        begin
          ListBox.Items.Add(ds.FieldByName('sbid').AsString+'='+ds.FieldByName('sbName').AsString);
          ds.Next;
        end;
    finally
      ds.Close;
      ds.Free;
    end;
  end;
end;
}

function TfrmSubjectListDlg.Get_sbid: int64;
var
  i: integer;
begin
  i:=ListBox.ItemIndex;
  if i>=0 then Result:=GetID(ListBox.Items[i])
    else Result:=-1;
end;

function TfrmSubjectListDlg.Get_sbName: string;
var
  i: integer;
begin
  i:=ListBox.ItemIndex;
  if i>=0 then Result:=SUtils.GetValue(ListBox.Items[i])
    else Result:='';
end;

function TfrmSubjectListDlg.Get_subject: string;
var
  i: integer;
begin
  i:=ListBox.ItemIndex;
  if i>=0 then Result:=ListBox.Items[i] else Result:='';
end;

procedure TfrmSubjectListDlg.ListBoxDrawItem(Control: TWinControl;
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
      else s:=SUtils.GetValue(TCustomListBox(Control).Items[Index]);
    FCanvas.TextOut(Rect.Left + 2, Rect.Top, s);
  end;
end;

procedure TfrmSubjectListDlg.HTMLabelAnchorClick(Sender: TObject;
  Anchor: String);
begin
  DoLoadSubjects(Anchor[1]);
end;

procedure TfrmSubjectListDlg.ListBoxDbClick(Sender: TObject);
begin
  ModalResult:=mrOk;
end;

end.
