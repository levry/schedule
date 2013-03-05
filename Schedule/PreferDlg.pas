{
  Диалог изм-ния пожеланий/огр-ний
  v0.0.1
}

unit PreferDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DB;

type
  TViewColor = (vcBkgnd, vcHeader, vcHeaderText, vcNames, vcNamesText,
       vcField, vcFieldBkgnd);

  TElement = record
    Value: boolean;
    Modified: boolean;
  end;
  TWorkWeek = array[0..5,0..6] of TElement;

  TViewInfo = record
    ColWidth: integer;          // ширина колонки
    RowHeight: integer;         // высота строки
    Width: integer;             // ширина
    Height: integer;            // высота
    TrackCell: TPoint;
    HeaderRect: TRect;          // заголовок
    DaysRect: TRect;            // дни недели
    PairsRect: TRect;           // номера пар
    FieldRect: TRect;           // гл. поле
    Colors: array[TViewColor] of TColor;     // цвета
  end;

  TfrmPreferDlg = class(TForm)
    OkBtn: TButton;
    CancelBtn: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private
    { Private declarations }
    bmpBuffer: TBitmap;              // граф. буфер
    FViewInfo: TViewInfo;            // инфо об разметке областей

    procedure CalculateViewInfo;     // расчет областей
    procedure DrawBuffer;            // отрисовка граф. буфера
  public
    { Public declarations }
    WorkWeek: TWorkWeek;             // массив ограничений
    Header: string;

    procedure UpdateClient;
  end;


function ShowPreferDlg(Value, FieldName, Caption, Header: string; DataSet: TDataSet): boolean;

implementation

uses
  Types,
  SStrings;

const
  cDelta = 5;                 // отступ от края окна

{$R *.dfm}

function ShowPreferDlg(Value, FieldName, Caption, Header: string; DataSet: TDataSet): boolean;
var
  frmDlg: TfrmPreferDlg;
  i, j: integer;
begin
  Result:=false;
  try
    frmDlg:=TfrmPreferDlg.Create(Application);
    frmDlg.Caption:=Caption;
    frmDlg.Header:=Header;
    while not DataSet.Eof do
    begin
      frmDlg.WorkWeek[DataSet.FieldByName('wday').AsInteger-1,
          DataSet.FieldByName('npair').AsInteger-1].Value:=true;
      DataSet.Next;
    end;
    frmDlg.UpdateClient;
    if frmDlg.ShowModal=mrOk then
    begin
      DataSet.First;
      while not DataSet.Eof do
      begin
        if frmDlg.WorkWeek[DataSet.FieldByName('wday').AsInteger-1,
          DataSet.FieldByName('npair').AsInteger-1].Modified then
          DataSet.Delete
        else DataSet.Next;
      end;
      for i:=0 to 5 do
        for j:=0 to 6 do
          if frmDlg.WorkWeek[i,j].Modified and frmDlg.WorkWeek[i,j].Value then
          begin
            DataSet.Append;
            DataSet.FieldByName(FieldName).AsString:=Value;
            DataSet.FieldByName('wday').Value:=i+1;
            DataSet.FieldByName('npair').Value:=j+1;
            DataSet.Post;
          end;
    end;
  finally
    frmDlg.Free;
  end;
end;

procedure TfrmPreferDlg.FormCreate(Sender: TObject);
begin
  CalculateViewInfo;
  bmpBuffer:=TBitmap.Create;
  bmpBuffer.Width:=FViewInfo.Width;
  bmpBuffer.Height:=FViewInfo.Height;
  ClientWidth:=bmpBuffer.Width;
  ClientHeight:=bmpBuffer.Height+OkBtn.Height+5+cDelta;
  DrawBuffer;
end;

// расчет областей {12.10.2004}
procedure TfrmPreferDlg.CalculateViewInfo;
begin
  FViewInfo.TrackCell:=Point(-1, -1);
  FViewInfo.ColWidth:=5*Canvas.TextWidth('0');
  FViewInfo.RowHeight:=Canvas.TextHeight('0')+6;

  // область заголовка
  with FViewInfo.HeaderRect do
  begin
    Top:=0;
    Left:=0;
    Bottom:=Top+FViewInfo.RowHeight;
    Right:=Left+7*FViewInfo.ColWidth+2*cDelta;   //
  end;
  // область назв. дней
  with FViewInfo.DaysRect do
  begin
    Top:=FViewInfo.HeaderRect.Bottom+cDelta;    //
    Left:=FViewInfo.ColWidth+cDelta;            //
    Bottom:=Top+FViewInfo.RowHeight;
    Right:=Left+6*FViewInfo.ColWidth;
  end;
  // область номеров пар
  with FViewInfo.PairsRect do
  begin
    Top:=FViewInfo.DaysRect.Bottom;
    Left:=cDelta;                               //
    Bottom:=Top+7*FViewInfo.RowHeight;
    Right:=FViewInfo.DaysRect.Left;
  end;
  // область осн. поля
  with FViewInfo.FieldRect do
  begin
    Top:=FViewInfo.DaysRect.Bottom;
    Left:=FViewInfo.DaysRect.Left;
    Right:=FViewInfo.DaysRect.Right;
    Bottom:=FViewInfo.PairsRect.Bottom;
  end;

  FViewInfo.Colors[vcBkgnd]:=Color;
  FViewInfo.Colors[vcHeader]:=clGray;
  FViewInfo.Colors[vcHeaderText]:=clWhite;
  FViewInfo.Colors[vcNames]:=clSilver;
  FViewInfo.Colors[vcNamesText]:=clWhite;
  FViewInfo.Colors[vcField]:=clMoneyGreen;
  FViewInfo.Colors[vcFieldBkgnd]:=clWhite;
  FViewInfo.Width:=FViewInfo.FieldRect.Right+cDelta;   //
  FViewInfo.Height:=FViewInfo.FieldRect.Bottom+cDelta;
end;

// отрисовка граф. буфера {12.10.2004}
procedure TfrmPreferDlg.DrawBuffer;
  // отрисовка области заголовка
  procedure DrawHeader;
  var
    szText: TSize;
    R: TRect;
  begin
    R:=FViewInfo.HeaderRect;
    bmpBuffer.Canvas.Brush.Color:=FViewInfo.Colors[vcHeader];
    bmpBuffer.Canvas.FillRect(FViewInfo.DaysRect);
    bmpBuffer.Canvas.Font.Color:=FViewInfo.Colors[vcHeaderText];
    szText:=bmpBuffer.Canvas.TextExtent(Header);
    bmpBuffer.Canvas.TextRect(R, R.Left+(R.Right-R.Left-szText.cx)div 2,
      R.Top+(R.Bottom-R.Top-szText.cy)div 2, Header);
  end;
  // отрисовка области назв. дней
  procedure DrawDays;
  var
    i: integer;
    R: TRect;
    szText: TSize;
  begin
    bmpBuffer.Canvas.Brush.Color:=FViewInfo.Colors[vcNames];
    bmpBuffer.Canvas.FillRect(FViewInfo.DaysRect);

    R.Top:=FViewInfo.DaysRect.Top;
    R.Bottom:=FViewInfo.DaysRect.Bottom;
    for i:=0 to 5 do
    begin
      if FViewInfo.TrackCell.X=i then bmpBuffer.Canvas.Font.Color:=clHighlight
        else bmpBuffer.Canvas.Font.Color:=FViewInfo.Colors[vcNamesText];
      with R do
      begin
        Left:=FViewInfo.DaysRect.Left+i*FViewInfo.ColWidth;
        Right:=Left+FViewInfo.ColWidth;
      end;
      szText:=bmpBuffer.Canvas.TextExtent(csDayNames[i]);
      bmpBuffer.Canvas.TextRect(R, R.Left+(R.Right-R.Left-szText.cx)div 2,
        R.Top+(R.Bottom-R.Top-szText.cy)div 2, csDayNames[i]);
    end;
  end;
  // отрисовка области номеров пар
  procedure DrawPairs;
  var
    i: integer;
    R: TRect;
    S: string;
    szText: TSize;
  begin
    bmpBuffer.Canvas.Brush.Color:=FViewInfo.Colors[vcNames];
    bmpBuffer.Canvas.FillRect(FViewInfo.PairsRect);
    R.Left:=FViewInfo.PairsRect.Left;
    R.Right:=FViewInfo.PairsRect.Right;
    for i:=0 to 6 do
    begin
      if FViewInfo.TrackCell.Y=i then bmpBuffer.Canvas.Font.Color:=clHighlight
        else bmpBuffer.Canvas.Font.Color:=FViewInfo.Colors[vcNamesText];
      with R do
      begin
        Top:=FViewInfo.PairsRect.Top+i*FViewInfo.RowHeight;
        Bottom:=Top+FViewInfo.RowHeight;
      end;
      S:=IntToStr(i+1);
      szText:=bmpBuffer.Canvas.TextExtent(S);
      bmpBuffer.Canvas.TextRect(R, R.Left+(R.Right-R.Left-szText.cx)div 2,
        R.Top+(R.Bottom-R.Top-szText.cy)div 2, S);
    end; // for
  end;
  // отрисовка области осн. поля
  procedure DrawField;
  var
    i, j: integer;
    R: TRect;
    szText: TSize;
  const
    S: string = 'X';
  begin
    bmpBuffer.Canvas.Brush.Color:=FViewInfo.Colors[vcFieldBkgnd];
    bmpBuffer.Canvas.FillRect(FViewInfo.FieldRect);
    bmpBuffer.Canvas.Brush.Color:=FViewInfo.Colors[vcField];
    szText:=bmpBuffer.Canvas.TextExtent(S);
    for i:=0 to 5 do
      for j:=0 to 6 do
        if WorkWeek[i, j].Value then
        begin
          R.Left:=FViewInfo.FieldRect.Left+i*FViewInfo.ColWidth;
          R.Top:=FViewInfo.FieldRect.Top+j*FViewInfo.RowHeight;
          R.Right:=R.Left+FViewInfo.ColWidth;
          R.Bottom:=R.Top+FViewInfo.RowHeight;

          bmpBuffer.Canvas.FillRect(R);
          bmpBuffer.Canvas.Font.Color:=clWhite;
          bmpBuffer.Canvas.TextRect(R, R.Left+(R.Right-R.Left-szText.cx)div 2,
            R.Top+(R.Bottom-R.Top-szText.cy)div 2, S);
        end;
    bmpBuffer.Canvas.Pen.Color:=FViewInfo.Colors[vcHeader];
    bmpBuffer.Canvas.Polyline([Point(FViewInfo.PairsRect.Left, FViewInfo.FieldRect.Top),
        Point(FViewInfo.FieldRect.Right, FViewInfo.FieldRect.Top)]);
    bmpBuffer.Canvas.Polyline([Point(FViewInfo.PairsRect.Left, FViewInfo.FieldRect.Bottom),
        Point(FViewInfo.FieldRect.Right, FViewInfo.FieldRect.Bottom)]);
    //bmpBuffer.Canvas.FrameRect(FViewInfo.FieldRect);
  end;
var
  clOldBrush, clOldPen: TColor;
begin
  clOldBrush:=bmpBuffer.Canvas.Brush.Color;
  clOldPen:=bmpBuffer.Canvas.Pen.Color;

  // очистка
  bmpBuffer.Canvas.Brush.Color:=FViewInfo.Colors[vcBkgnd];
  bmpBuffer.Canvas.FillRect(Rect(0, 0, bmpBuffer.Width, bmpBuffer.Height));

  DrawHeader;
  DrawDays;
  DrawPairs;
  DrawField;

  bmpBuffer.Canvas.Pen.Color:=clOldPen;
  bmpBuffer.Canvas.Brush.Color:=clOldBrush;
end;

procedure TfrmPreferDlg.FormPaint(Sender: TObject);
begin
  Canvas.Draw(0, 0, bmpBuffer);
end;

procedure TfrmPreferDlg.FormDestroy(Sender: TObject);
begin
  bmpBuffer.Free;
end;

// обработчик события нажатия на клавишу мыши {12.10.2004}
procedure TfrmPreferDlg.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
  // изменение ограничений для всего дня
  procedure ChangeDay(iDay: integer);
  var
    i: integer;
    NewValue: boolean;
  begin
    NewValue:=true;
    for i:=0 to 6 do
      if WorkWeek[iDay, i].Value then
      begin
        NewValue:=false;
        Break;
      end;
    for i:=0 to 6 do
    begin
      if WorkWeek[iDay, i].Value<>NewValue then
      begin
        WorkWeek[iDay, i].Value:=NewValue;
        WorkWeek[iDay, i].Modified:=not WorkWeek[iDay, i].Modified;
      end;
    end;
  end;
  // изменение ограниечий для пары на все дни
  procedure ChangePair(iPair: integer);
  var
    i: integer;
    NewValue: boolean;
  begin
    NewValue:=true;
    for i:=0 to 5 do
      if WorkWeek[i, iPair].Value then
      begin
        NewValue:=false;
        Break;
      end;
    for i:=0 to 5 do
    begin
      if WorkWeek[i, iPair].Value<>NewValue then
      begin
        WorkWeek[i, iPair].Value:=NewValue;
        WorkWeek[i, iPair].Modified:=not WorkWeek[i, iPair].Modified;
      end;
    end;
  end;
var
  i, j: integer;
  Redraw: boolean;
begin
  Redraw:=false;
  // в область осн. поля
  if PtInRect(FViewInfo.FieldRect, Point(X, Y)) then
  begin
    i:=(X-FViewInfo.FieldRect.Left) div FViewInfo.ColWidth;
    j:=(Y-FViewInfo.FieldRect.Top) div FViewInfo.RowHeight;
    WorkWeek[i,j].Value:=not WorkWeek[i,j].Value;
    WorkWeek[i,j].Modified:=not WorkWeek[i,j].Modified;
    Redraw:=true;
  end;
  // в область назв. дней
  if PtInRect(FViewInfo.DaysRect, Point(X, Y)) then
  begin
    ChangeDay((X-FViewInfo.DaysRect.Left) div FViewInfo.ColWidth);
    Redraw:=true;
  end;
  // в область номеров пар
  if PtInRect(FViewInfo.PairsRect, Point(X, Y)) then
  begin
    ChangePair((Y-FViewInfo.PairsRect.Top) div FViewInfo.RowHeight);
    Redraw:=true;
  end;
  if Redraw then
  begin
    DrawBuffer;
    InvalidateRect(Handle, nil, False);
  end;
end;

// обработчик события передвижения курсора мыши {12.10.2004}
procedure TfrmPreferDlg.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
  procedure Redraw;
  begin
    DrawBuffer;
    InvalidateRect(Handle, nil, False);
  end;
var
  i, j: integer;
begin
  // в области осн. поля
  if PtInRect(FViewInfo.FieldRect, Point(X, Y)) then
  begin
    i:=(X-FViewInfo.FieldRect.Left) div FViewInfo.ColWidth;
    j:=(Y-FViewInfo.FieldRect.Top) div FViewInfo.RowHeight;
    if (FViewInfo.TrackCell.X<>i) or (FViewInfo.TrackCell.Y<>j) then
    begin
      FViewInfo.TrackCell:=Point(i, j);
      Redraw;
    end;
    Exit;
  end;
  // в области назв. дней
  if PtInRect(FViewInfo.DaysRect, Point(X, Y)) then
  begin
    i:=(X-FViewInfo.DaysRect.Left) div FViewInfo.ColWidth;
    j:=-1;
    if (FViewInfo.TrackCell.X<>i) or (FViewInfo.TrackCell.Y<>j) then
    begin
      FViewInfo.TrackCell:=Point(i, j);
      Redraw;
    end;
    Exit;
  end;
  // в области номеров пар
  if PtInRect(FViewInfo.PairsRect, Point(X, Y)) then
  begin
    i:=-1;
    j:=(Y-FViewInfo.PairsRect.Top) div FViewInfo.RowHeight;
    if (FViewInfo.TrackCell.X<>i) or (FViewInfo.TrackCell.Y<>j) then
    begin
      FViewInfo.TrackCell:=Point(i, j);
      Redraw;
    end;
    Exit;
  end;

  if (FViewInfo.TrackCell.X<>-1) or (FViewInfo.TrackCell.Y<>-1) then
  begin
    FViewInfo.TrackCell:=Point(-1,-1);
    Redraw;
  end;
end;

procedure TFrmPreferDlg.UpdateClient;
begin
  DrawBuffer;
  InvalidateRect(Handle, nil, False);
end;

end.
