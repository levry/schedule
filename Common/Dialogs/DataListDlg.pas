{
  Диалог список (фильтр)
  v0.0.1 (11.04.06)
}
unit DataListDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TLoadListEvent = procedure(const Value: string; List: TStrings) of object;

  TfrmDataListDlg = class(TForm)
    btnOk: TButton;
    btnCancel: TButton;
    ListBox: TListBox;
    cbFilter: TComboBox;
    procedure ListBoxDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure cbFilterDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure cbFilterChange(Sender: TObject);
    procedure ListBoxDblClick(Sender: TObject);
  private
    { Private declarations }

    FOnLoadList: TLoadListEvent;
    function Get_xdata: string;
    procedure DoLoadList;
  public
    { Public declarations }
    property xdata: string read Get_xdata;
    property OnLoadList: TLoadListEvent read FOnLoadList write FOnLoadList;
  end;

function GetDataFromList(const sCaption: string; LoadListEvent: TLoadListEvent;
    FilterList: TStrings; var sResult: string): boolean;

implementation

uses
  SUtils, SConsts;

{$R *.dfm}

function GetDataFromList(const sCaption: string; LoadListEvent: TLoadListEvent;
    FilterList: TStrings; var sResult: string): boolean;
var
  frmDlg: TfrmDataListDlg;
begin
  Result:=false;

  frmDlg:=TfrmDataListDlg.Create(Application);
  try
    frmDlg.Caption:=sCaption;
    frmDlg.cbFilter.Items.AddStrings(FilterList);
    frmDlg.cbFilter.ItemIndex:=0;
    frmDlg.OnLoadList:=LoadListEvent;
    frmDlg.DoLoadList;

    if frmDlg.ShowModal=mrOk then
    begin
      sResult:=frmDlg.xdata;
      Result:=true;
    end;
  finally
    frmDlg.Free;
    frmDlg:=nil;
  end;
end;

{ TfrmDataListDlg }

function TfrmDataListDlg.Get_xdata: string;
var
  i: integer;
begin
  i:=ListBox.ItemIndex;
  if i>=0 then Result:=ListBox.Items[i] else Result:='';
end;

procedure TfrmDataListDlg.ListBoxDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  FCanvas: TCanvas;
  s: string;
  OldColor: TColor;
begin
  if Control is TCustomListBox then
  begin
    FCanvas:=TCustomListBox(Control).Canvas;
    TControlCanvas(FCanvas).UpdateTextFlags;

    s:=TCustomListBox(Control).Items[Index];

    OldColor:=FCanvas.Brush.Color;
    case GetState(s) of
      STATE_BUSY:  FCanvas.Brush.Color:=clRed;
      STATE_GREEN: FCanvas.Brush.Color:=clMoneyGreen;
      STATE_RED:   FCanvas.Brush.Color:=clSkyBlue;
    end;

    if not bDebugMode then s:=SUtils.GetValue(s);

    FCanvas.FillRect(Rect);
    FCanvas.TextOut(Rect.Left + 2, Rect.Top, s);

    FCanvas.Brush.Color:=OldColor;
  end;
end;

procedure TfrmDataListDlg.cbFilterDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  FCanvas: TCanvas;
  s: string;
begin
  if Control is TComboBox then
  begin
    FCanvas:=(Control as TComboBox).Canvas;
    TControlCanvas(FCanvas).UpdateTextFlags;
    FCanvas.FillRect(Rect);
    s:=TComboBox(Control).Items[Index];
    if not bDebugMode then s:=GetValue(s);
    FCanvas.TextOut(Rect.Left + 2, Rect.Top, s);
  end;
end;

procedure TfrmDataListDlg.DoLoadList;
var
  i: integer;
begin
  i:=cbFilter.ItemIndex;
  if i>=0 then
    if Assigned(FOnLoadList) then
    begin
      ListBox.Clear;
      FOnLoadList(cbFilter.Items[i], ListBox.Items);
    end;
end;

procedure TfrmDataListDlg.cbFilterChange(Sender: TObject);
begin
  DoLoadList;
end;

procedure TfrmDataListDlg.ListBoxDblClick(Sender: TObject);
begin
  ModalResult:=mrOk;
end;

end.
