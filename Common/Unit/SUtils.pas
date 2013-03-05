{
  Функции
  v0.0.6 (3/10/06)
}
unit SUtils;

interface

uses
  Windows, Graphics, Classes, Messages;


{ procedures }
function IsNumeric(c: char): Boolean;  // определение символа как числа
function IsFlag(Value: WORD; Flag: WORD): boolean;  // опр-ние уст-ки флага(битов)

// name=value;tag
function GetName(const s: string): string;     // перед =
function GetValue(const s: string): string;    // после =
function GetTag(const s: string): string;      // после ;
function Format(Name: string; Value: string=''; Tag: string=''): string; overload;
function GetId(const s: string): int64;        // name as int64
function GetState(const s: string): byte;      // tag as byte;

function BuildFullName(const AFileName: string): string;
function RemoveChars(const chars, s: string): string;
function FixFileName(const AFilename: string): string;
function GetHTMLAlphabet: string;
function TextLine(const Text: string; BreakChar: char; Index: integer): string;


procedure WriteText(ACanvas: TCanvas; ARect: TRect; DX, DY: Integer;
  const Text: string; Alignment: TAlignment; ARightToLeft: Boolean);

// HTML function
function ColorToBGR(Color: TColor): TColor;
function ToHTML(s: string; FStyle: TFontStyles; FColor: TColor=clBlack): string;

const
  cDelimiter: char = '=';
  cTag: char       = ';';
  cInvalidFileChars: string = '<>:"/\|*?';

var
  bDebugMode: boolean = false;        // режим debug


//  WM_UPDATESDL = WM_APP + 10;        // обновление расписания
//  WM_DELETEGRP = WM_APP + 11;        // удаление группы

implementation

uses
  Controls, Math, Types, SysUtils, Forms;

function IsNumeric(c: char): Boolean;
begin
  Result := Pos(c, '0123456789') > 0; {do not localize}
end;

function IsFlag(Value: WORD; Flag: WORD): boolean;
begin
  Result:=((Value and Flag)=Flag);
end;

// возвращает Name (перед =)
function GetName(const s: string): string;
var
  i: integer;
begin
  Result := s;
  i := Pos(cDelimiter, Result);
  if i <> 0 then SetLength(Result, i-1)
  else
  begin
    i:=pos(cTag, Result);
    if i>0 then SetLength(Result, i-1);
  end;
end;

// возвращает value(после =)
function GetValue(const s: string): string;
var
  i: integer;
begin
  i:=Pos(cDelimiter, s);
  if i>0 then
  begin
    Result:=Copy(s, i+1, MaxInt);
    i:=pos(cTag,Result);
    if i>0 then SetLength(Result, i-1);
  end else Result:='';
end;

// возвращает Tag (после ;)
function GetTag(const s: string): string;
var
  i: integer;
begin
  i:=Pos(cTag, s);
  if i>0 then Result:=copy(s, i+1, MaxInt)
    else Result:='';
end;

// возвращает строку вида name=value;tag
function Format(Name: string; Value: string=''; Tag: string=''): string; overload;
begin

  if Name<>'' then
  begin
    Result:=Name+cDelimiter;
    if Value<>'' then
    begin
      Result:=Result+Value;
      if Tag<>'' then Result:=Result+cTag+Tag;
    end;
  end
  else Result:='';
end;

// возвращает name как int64
function GetId(const s: string): int64;
begin
  Result:=StrToInt64Def(GetName(s),0);
end;

// возвращает состояние (tag)
function GetState(const s: string): byte;
begin
  Result:=StrToIntDef(GetTag(s),0);
end;

// построение полного имени файла
function BuildFullName(const AFileName: string): string;
begin
  Result:=IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName));
  Result:=Result+ExtractFileName(AFileName);
  if not FileExists(Result) then Result:='';
end;

// удаление символов chars из строки s
function RemoveChars(const chars, s: string): string;
var
  c: char;
  i: integer;
begin
  Result:=s;

  i:=Length(Result);
  while i>0 do
  begin
    c:=Result[i];
    if Pos(c, chars)>0 then Delete(Result,i,1);
    dec(i);
  end;

end;

// удаление недопустим. символов из имени файла
function FixFileName(const AFilename: string): string;
begin
  Result:=RemoveChars(cInvalidFileChars,AFilename);
end;

// возвращает html строку алфавита
function GetHTMLAlphabet: string;
const
  letters: string = 'абвгдежзиклмнопрстуфхцчщшэюя';
  link: string = '<A href="%s">%s</A>';
var
  i, l: integer;
  s: string;
begin
  Result:='<P align="center">';
  l:=Length(letters);
  for i:=1 to l do
  begin
    s:=Format(link,[letters[i],AnsiUpperCase(letters[i])]);
    Result:=Result+s;
    if i<l then Result:=Result+'  ';
  end;
  Result:=Result+'</P>';
end;

// извлекает строку под номером Line (строки разделены символом BreakStr)
function TextLine(const Text: string; BreakChar: char; Index: integer): string;
var
  b, e: integer;
  j, len: integer;
begin
  Result:='';

  j:=0;

  len:=Length(Text);
  if len>0 then
  begin
    b:=1;
    e:=1;
    while (b<=len) and (e<=len) do
    begin
      if j=Index then
        if Text[e]=BreakChar then break else inc(e)
      else
        if Text[b]=BreakChar then
        begin
          inc(b);
          e:=b;
          inc(j)
        end
        else inc(b);
    end;
    if e>b then Result:=Copy(Text, b, e-b);
  end;
end;

procedure WriteText(ACanvas: TCanvas; ARect: TRect; DX, DY: Integer;
  const Text: string; Alignment: TAlignment; ARightToLeft: Boolean);
const
  AlignFlags : array [TAlignment] of Integer =
    ( DT_LEFT or DT_WORDBREAK or DT_EXPANDTABS or DT_NOPREFIX,
      DT_RIGHT or DT_WORDBREAK or DT_EXPANDTABS or DT_NOPREFIX,
      DT_CENTER or DT_WORDBREAK or DT_EXPANDTABS or DT_NOPREFIX );
  RTL: array [Boolean] of Integer = (0, DT_RTLREADING);
var
  B, R: TRect;
  Hold, Left: Integer;
  I: TColorRef;
  bmpBuf: TBitmap;
begin
  bmpBuf:=TBitmap.Create;
  I := ColorToRGB(ACanvas.Brush.Color);
  if GetNearestColor(ACanvas.Handle, I) = I then
  begin                       { Use ExtTextOut for solid colors }
    { In BiDi, because we changed the window origin, the text that does not
      change alignment, actually gets its alignment changed. }
    if (ACanvas.CanvasOrientation = coRightToLeft) and (not ARightToLeft) then
      ChangeBiDiModeAlignment(Alignment);
    case Alignment of
      taLeftJustify:
        Left := ARect.Left + DX;
      taRightJustify:
        Left := ARect.Right - ACanvas.TextWidth(Text) - 3;
    else { taCenter }
      Left := ARect.Left + (ARect.Right - ARect.Left) shr 1
        - (ACanvas.TextWidth(Text) shr 1);
    end;
    ACanvas.TextRect(ARect, Left, ARect.Top + DY, Text);
  end
  else begin                  { Use FillRect and Drawtext for dithered colors }
    bmpBuf.Canvas.Lock;
    try
      with bmpBuf, ARect do { Use offscreen bitmap to eliminate flicker and }
      begin                     { brush origin tics in painting / scrolling.    }
        Width := Max(Width, Right - Left);
        Height := Max(Height, Bottom - Top);
        R := Types.Rect(DX, DY, Right - Left - 1, Bottom - Top - 1);
        B := Types.Rect(0, 0, Right - Left, Bottom - Top);
      end;
      with bmpBuf.Canvas do
      begin
        Font := ACanvas.Font;
        Font.Color := ACanvas.Font.Color;
        Brush := ACanvas.Brush;
        Brush.Style := bsSolid;
        FillRect(B);
        SetBkMode(Handle, TRANSPARENT);
        if (ACanvas.CanvasOrientation = coRightToLeft) then
          ChangeBiDiModeAlignment(Alignment);
        DrawText(Handle, PChar(Text), Length(Text), R,
          AlignFlags[Alignment] or RTL[ARightToLeft]);
      end;
      if (ACanvas.CanvasOrientation = coRightToLeft) then
      begin
        Hold := ARect.Left;
        ARect.Left := ARect.Right;
        ARect.Right := Hold;
      end;
      ACanvas.CopyRect(ARect, bmpBuf.Canvas, B);
    finally
      bmpBuf.Canvas.Unlock;
    end;
  end;
  bmpBuf.Free;
end;

// Convert RGB to BGR (for HTML format)
function ColorToBGR(Color: TColor): TColor;
begin
  Result:=RGB(GetBValue(Color),GetGValue(Color),GetRValue(Color));
end;

// форматирование строки в HTML формат
// FStyle - стиль шрифта
// FColor - цвет шрифта
function ToHTML(s: string; FStyle: TFontStyles; FColor: TColor=clBlack): string;
begin
  Result:=s;
  if fsBold in FStyle then Result:='<B>'+Result+'</B>';
  if fsItalic in FStyle then Result:='<I>'+Result+'</I>';
  if fsUnderline in FStyle then Result:='<U>'+Result+'</U>';
  if fsStrikeOut in FStyle then Result:='<S>'+Result+'</S>';
  if FColor<>clBlack then
    Result:='<FONT color="#'+IntToHex(ColorToBGR(FColor),6)+'">'+Result+'</FONT>';
end;


end.
