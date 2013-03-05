unit LoadDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, ComCtrls;

type
  TfrmLoadDlg = class(TForm)
    Grid: TStringGrid;
    btnOk: TButton;
    Label1: TLabel;
    Label2: TLabel;
    lblGroup: TLabel;
    lblSubject: TLabel;
    btnCancel: TButton;
    procedure OnUDClick(Sender: TObject; Button: TUDBtnType);
    procedure FormCreate(Sender: TObject);
    procedure GridSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
  private
    { Private declarations }
    udHours: TUpDown;
  public
    { Public declarations }
  end;

  TLoads = array[0..2,0..2] of Word; // аудитор. нагрузка [всего-п/с, зан€тие]


function ShowLoadDlg(grName, sbName: string; var aLoads: TLoads): boolean;

implementation

{$R *.dfm}

function ShowLoadDlg(grName, sbName: string; var aLoads: TLoads): boolean;
var
  frmDlg: TfrmLoadDlg;
  c, r: integer;
begin
  Result:=false;
  try
    frmDlg:=TfrmLoadDlg.Create(Application);
    frmDlg.lblGroup.Caption:=grName;
    frmDlg.lblSubject.Caption:=sbName;
    for c:=0 to 2 do
      for r:=0 to 2 do
        frmDlg.Grid.Cells[r+1, c+1]:=IntToStr(aLoads[c,r]);
    if frmDlg.ShowModal=mrOk then
    begin
      for c:=0 to 2 do
        for r:=0 to 2 do
          aLoads[c,r]:=StrToIntDef(frmDlg.Grid.Cells[r+1, c+1], 0);
      Result:=true;
    end;
  finally
    frmDlg.Free;
  end;
end;

procedure TfrmLoadDlg.FormCreate(Sender: TObject);
const
  s1: array[0..2] of string = ('ƒоступно', '1 полусеместр', '2 полусеместр');
  s2: array[0..2] of string = ('лекции', 'практич.', 'лаб.');
var
  i: integer;
  procedure GridResize;
  var
    maxl, l: integer;
    j: integer;
    R: TRect;
  begin
    maxl:=0;
    for j:=1 to Grid.RowCount-1 do
    begin
      l:=Grid.Canvas.TextWidth(Grid.Cells[0,j]);
      if maxl<l then maxl:=l;
    end;
    inc(maxl, 10);
    Grid.ColWidths[0]:=maxl;
    l:=(Grid.Width-maxl) div (Grid.ColCount-1)-Grid.GridLineWidth;
    for j:=Grid.FixedCols to Grid.ColCount-1 do
      Grid.ColWidths[j]:=l;
    R:=Grid.CellRect(Grid.ColCount-1, Grid.RowCount-1);
    Grid.ClientHeight:=R.Bottom+Grid.GridLineWidth+1;
  end;
begin
  for i:=0 to 2 do Grid.Cells[0, i+1]:=s1[i];
  for i:=0 to 2 do Grid.Cells[i+1, 0]:=s2[i];
  GridResize;
  udHours:=TUpDown.Create(Self);
  udHours.Parent:=Self;
  udHours.Visible:=false;
  udHours.OnClick:=OnUDClick;
  udHours.Max:=0;
  udHours.Increment:=1;
end;

procedure TfrmLoadDlg.GridSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
var
  R: TRect;
begin
  CanSelect:=false;
  if (ARow<>1) and (ACol<>1) then
  begin
    R:=Grid.CellRect(ACol, ARow);
    Inc(R.Left, (R.Right-R.Left-(R.Bottom-R.Top)));
    R.TopLeft:=Grid.ClientToParent(R.TopLeft);
    R.BottomRight:=Grid.ClientToParent(R.BottomRight);
    udHours.BoundsRect:=R;

    udHours.Max:=StrToIntDef(Grid.Cells[ACol, 1], 0)+StrToIntDef(Grid.Cells[ACol, ARow], 0);
    udHours.Position:=StrToIntDef(Grid.Cells[ACol, ARow], 0);
    udHours.Show;
    CanSelect:=true;
  end;
end;

procedure TfrmLoadDlg.OnUDClick(Sender: TObject; Button: TUDBtnType);
var
  c, r, s: integer;
begin
  c:=Grid.Selection.Left;
  r:=Grid.Selection.Top;
  Grid.Cells[c, r]:=IntToStr(TUpDown(Sender).Position);
  Grid.Cells[c, 1]:=IntToStr(TUpDown(Sender).Max-TUpDown(Sender).Position);
  s:=0;
  for c:=Grid.FixedRows to Grid.ColCount-1 do
    inc(s, StrToIntDef(Grid.Cells[c, Grid.FixedRows], 0));
  if s=0 then btnOk.Enabled:=true
    else btnOk.Enabled:=false;
end;


end.
