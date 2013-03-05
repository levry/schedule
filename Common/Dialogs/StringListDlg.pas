{
  Диалог список
  v0.0.9 (05.05.06)
}

unit StringListDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TListKind = (lkMultiple, lkColor);
  TListModes = set of TListKind;

  TfrmStringListDlg = class(TForm)
    ListBox: TListBox;
    btnOk: TButton;
    btnCancel: TButton;
    procedure ListBoxDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure ListBoxDblClick(Sender: TObject);
  private
    { Private declarations }
    FListModes: TListModes;

    function Get_id: int64;
    function Get_name: string;
    function Get_string: string;
    function Get_Index: integer;
  public
    { Public declarations }

    property xid: int64 read Get_id;
    property xname: string read Get_name;
    property xstring: string read Get_string;
    property xindex: integer read Get_Index;
  end;

procedure ShowStringList(const sCaption: string; list: TStrings);
function GetIdFromList(const sCaption, sString: string; var nResult: int64;
  List: TStrings): boolean; overload;
function GetIdFromList(const sCaption, sString: string; var nResult: integer;
  List: TStrings): boolean; overload;
function GetStrFromList(const sCaption, sString: string; var sResult: string;
  List: TStrings; ListMode: TListModes): boolean; overload;
function GetStrFromList(const sCaption, sString: string; var sResult: string;
  List: TStrings): boolean; overload;

function GetStrFromString(const sCaption, sString: string; var sResult: string;
  const StringList: string): boolean; overload;
function GetIdFromString(const sCaption, sString: string; var nResult: integer;
  const StringList: string): boolean; overload;

function GetIndexFromList(const sCaption: string; var nIndex: integer;
  List: TStrings): boolean;

implementation

uses
  SUtils, SConsts;

{$R *.dfm}

// просмотр списка
procedure ShowStringList(const sCaption: string; list: TStrings);
var
  frmDlg: TfrmStringListDlg;
begin
  frmDlg:=TfrmStringListDlg.Create(Application);
  try
    frmDlg.Caption:=sCaption;
    frmDlg.btnOk.Visible:=false;
    frmDlg.ListBox.Items.AddStrings(list);
    frmDlg.ShowModal;
  finally
    frmDlg.Free;
    frmDlg:=nil;
  end;
end;

function GetIdFromList(const sCaption, sString: string; var nResult: int64;
    List: TStrings): boolean;
var
  frmDlg: TfrmStringListDlg;
begin
  Assert(Assigned(List),
    'A697AA12-23FB-48A2-8F43-529BD070A669'#13'GetIdFromList: List is nil'#13);
  Result:=false;

  frmDlg:=TfrmStringListDlg.Create(Application);
  try
    frmDlg.Caption:=sCaption;
    frmDlg.ListBox.Items.AddStrings(List);
    frmDlg.ListBox.ItemIndex:=frmDlg.ListBox.Items.IndexOf(sString);
    if frmDlg.ShowModal=mrOk then
    begin
      nResult:=frmDlg.xid;
      Result:=true;
    end;
  finally
    frmDlg.Free;
    frmDlg:=nil;
  end;
end;

function GetIdFromList(const sCaption, sString: string; var nResult: integer;
  List: TStrings): boolean;
var
  frmDlg: TfrmStringListDlg;
begin
  Assert(Assigned(List),
    'FCD50CAF-C555-41F7-B6FB-AB9D253F5656'#13'GetIdFromList: List is nil'#13);
  Result:=false;

  frmDlg:=TfrmStringListDlg.Create(Application);
  try
    frmDlg.Caption:=sCaption;
    frmDlg.ListBox.Items.AddStrings(List);
    frmDlg.ListBox.ItemIndex:=frmDlg.ListBox.Items.IndexOf(sString);
    if frmDlg.ShowModal=mrOk then
    begin
      nResult:=frmDlg.xid;
      Result:=true;
    end;
  finally
    frmDlg.Free;
    frmDlg:=nil;
  end;
end;

function GetStrFromList(const sCaption, sString: string; var sResult: string;
  List: TStrings; ListMode: TListModes): boolean;
var
  frmDlg: TfrmStringListDlg;
begin
  Assert(Assigned(List),
    'F6487FF0-ADAF-468F-AC6F-A5C21AFB13BD'#13'GetStrFromList: List is nil'#13);
  Result:=false;

  frmDlg:=TfrmStringListDlg.Create(Application);
  try
    frmDlg.Caption:=sCaption;
    frmDlg.FListModes:=ListMode;
    frmDlg.ListBox.Items.AddStrings(List);
    frmDlg.ListBox.ItemIndex:=frmDlg.ListBox.Items.IndexOf(sString);
    if frmDlg.ShowModal=mrOk then
    begin
      sResult:=frmDlg.xstring;
      Result:=true;
    end;
  finally
    frmDlg.Free;
    frmDlg:=nil;
  end;
end;

function GetIndexFromList(const sCaption: string; var nIndex: integer;
  List: TStrings): boolean;
var
  frmDlg: TfrmStringListDlg;
begin
  Assert(Assigned(List),
    'C494F23C-F088-46DC-A76D-A054649081F7'#13'GetIndexFromList: List is nil'#13);

  Result:=false;

  frmDlg:=TfrmStringListDlg.Create(Application);
  try
    frmDlg.Caption:=sCaption;
    frmDlg.FListModes:=[];
    frmDlg.ListBox.Items.AddStrings(List);
    if frmDlg.ShowModal=mrOk then
    begin
      nIndex:=frmDlg.xindex;
      Result:=(nIndex>=0);
    end;
  finally
    frmDlg.Free;
    frmDlg:=nil;
  end;
end;

function GetStrFromList(const sCaption, sString: string; var sResult: string;
    List: TStrings): boolean;
begin
  Result:=GetStrFromList(sCaption, sString, sResult, List, []);
end;

function GetStrFromString(const sCaption, sString: string;
    var sResult: string; const StringList: string): boolean;
var
  list: TStringList;
begin
  list:=TStringList.Create;
  try
    list.CommaText:=StringList;
    Result:=GetStrFromList(sCaption,sString,sResult,list);
  finally
    list.Free;
    list:=nil;
  end;
end;

function GetIdFromString(const sCaption, sString: string; var nResult: integer;
  const StringList: string): boolean;
var
  list: TStringList;
begin
  list:=TStringList.Create;
  try
    list.CommaText:=StringList;
    Result:=GetIdFromList(sCaption,sString,nResult,list);
  finally
    list.Free;
    list:=nil;
  end;
end;

{ TfrmStringListDlg }

function TfrmStringListDlg.Get_Index: integer;
begin
  Result:=ListBox.ItemIndex;
end;

function TfrmStringListDlg.Get_id: int64;
var
  i: integer;
begin
  i:=ListBox.ItemIndex;
  if i>=0 then Result:=GetID(ListBox.Items[i])
    else Result:=-1;
end;

function TfrmStringListDlg.Get_string: string;
var
  i: integer;
begin
  i:=ListBox.ItemIndex;
  if i>=0 then Result:=ListBox.Items[i]
    else Result:='';
end;

function TfrmStringListDlg.Get_name: string;
var
  i: integer;
begin
  i:=ListBox.ItemIndex;
  if i>=0 then Result:=SUtils.GetValue(ListBox.Items[i])
    else Result:='';
end;

procedure TfrmStringListDlg.ListBoxDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  FCanvas: TCanvas;
  s, tag: string;
  OldColor: TColor;
begin
  if Control is TCustomListBox then
  begin
    FCanvas:=TCustomListBox(Control).Canvas;
    TControlCanvas(FCanvas).UpdateTextFlags;

    s:=TCustomListBox(Control).Items[Index];

    if lkColor in FListModes then
    begin
      OldColor:=FCanvas.Brush.Color;
      case GetState(s) of
        STATE_BUSY:  FCanvas.Brush.Color:=clRed;
        STATE_GREEN: FCanvas.Brush.Color:=clMoneyGreen;
        STATE_RED:   FCanvas.Brush.Color:=clSkyBlue;
      end;
    end;

    if not bDebugMode then s:=SUtils.GetValue(s);

    FCanvas.FillRect(Rect);
    FCanvas.TextOut(Rect.Left + 2, Rect.Top, s);

    if lkColor in FListModes then
      FCanvas.Brush.Color:=OldColor;
  end;
end;

procedure TfrmStringListDlg.ListBoxDblClick(Sender: TObject);
begin
  ModalResult:=mrOk;
end;

end.
