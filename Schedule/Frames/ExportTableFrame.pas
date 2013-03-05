{
  Редактирование параметров экспорта расписания в Excel
  v0.2.1 (29.03.06)
}

unit ExportTableFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, SCategory, ComCtrls, ToolWin, ImgList, Mask;

type
  TElementType = (etObject, etLessons);

  TfmExportTable = class(TFrame)
    lbElements: TListBox;
    cbSize: TComboBox;
    boxElement: TGroupBox;
    ToolBar: TToolBar;
    btnBold: TToolButton;
    btnItalic: TToolButton;
    btnUnderline: TToolButton;
    ToolButton4: TToolButton;
    btnUp: TToolButton;
    btnDown: TToolButton;
    ToolButton3: TToolButton;
    boxFills: TGroupBox;
    cbLesson: TComboBox;
    cbPractic: TComboBox;
    cbLabo: TComboBox;
    lblLection: TLabel;
    lblPractics: TLabel;
    lblLabo: TLabel;
    boxOther: TGroupBox;
    chkMerge: TCheckBox;
    lblParityStyle: TLabel;
    cbParityStyle: TComboBox;
    ImageList: TImageList;
    btnDefault: TButton;
    lblSmall: TLabel;
    cbSmall: TComboBox;
    lblDoublePair: TLabel;
    cbDoublePair: TComboBox;
    procedure lbElementsClick(Sender: TObject);
    procedure OnElementBtnsClick(Sender: TObject);
    procedure cbSizeChange(Sender: TObject);
    procedure ComboDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure cbPatternChange(Sender: TObject);
    procedure chkMergeClick(Sender: TObject);
    procedure cbOtherChange(Sender: TObject);
    procedure btnDefaultClick(Sender: TObject);
  private
    { Private declarations }
    bmpBuf: TBitmap;
    bmpPat: TBitmap;

    FOptions: TExportTableCategory;
    procedure UpdateFrame;
    procedure SetOptions(Value: TExportTableCategory);
    function GetOrders: string;

    procedure ViewOrders;
    procedure UpdateUpDownBtns;
    procedure UpdateControls;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property Options: TExportTableCategory read FOptions write SetOptions;
  end;

implementation

const
  iPatternSize = 16;

{$R *.dfm}

{ TfmExportS }

constructor TfmExportTable.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FOptions:=nil;
  bmpBuf:=TBitmap.Create;
  bmpBuf.LoadFromResourceName(HInstance,'PATTERN');

  bmpPat:=TBitmap.Create;
  bmpPat.Width:=iPatternSize;
  bmpPat.Height:=iPatternSize;

  ImageList.ResourceLoad(rtBitmap,'MORE',clFuchsia);
end;

destructor TfmExportTable.Destroy;
begin
  bmpPat.Free;
  bmpBuf.Free;

  inherited Destroy;
end;

// обновление отображения парам-ов
procedure TfmExportTable.UpdateFrame;
begin
  ViewOrders;
  UpdateControls;
  lbElements.ItemIndex:=0;
  lbElements.OnClick(lbElements);
end;

procedure TfmExportTable.SetOptions(Value: TExportTableCategory);
begin
  if FOptions<>Value then
  begin
    FOptions:=Value;
    UpdateFrame;
  end;
end;

procedure TfmExportTable.lbElementsClick(Sender: TObject);
var
  i: integer;
  fontsize: integer;
  fontstyle: TFontStyles;
begin
  Assert(Assigned(FOptions),
    '8E150BA7-D5BD-493B-BA19-AF45DBD8B406'#13'lbElementsClick: FOptions is nil'#13);

  i:=TListBox(Sender).ItemIndex;
  if i>=0 then
  begin
    case i of
      0: // subject
        begin
          fontsize:=FOptions.SubjectSizeFont;
          fontstyle:=FOptions.SubjectStyleFont;
        end;
      1: // auditory
        begin
          fontsize:=FOptions.AuditorySizeFont;
          fontstyle:=FOptions.AuditoryStyleFont;
        end;
      2: // teacher
        begin
          fontsize:=FOptions.TeacherSizeFont;
          fontstyle:=FOptions.TeacherStyleFont;
        end;
    end; // case
    btnBold.Down:=fsBold in fontstyle;
    btnItalic.Down:=fsItalic in fontstyle;
    btnUnderline.Down:=fsUnderline in fontstyle;
    cbSize.Text:=IntToStr(fontsize);
    UpdateUpDownBtns();
  end; // if i>=0

end;

// отображение порядка
procedure TfmExportTable.ViewOrders;
var
  i: integer;
  et: TElementType;
  s: string;
begin
  Assert(Assigned(FOptions),
    '7E1D48AD-27C4-4FDA-8F8F-D9E1BBB25977'#13'ViewOrders: FOptions is nil'#13);

  lbElements.Clear;
  for i:=0 to FOptions.Orders.Count-1 do
  begin
    case FOptions.GetElement(i) of
      etSubject:  s:='Дисциплина';
      etAuditory: s:='Аудитория';
      etTeacher:  s:='Преподаватель';
      else
      begin
        s:='';
        Assert(false,'464CE7BA-A547-4A5F-805D-3F9FBAE3A734'#13'ViewOrders: invalid order value'#13);
      end;
    end;
    lbElements.Items.Add(s);
  end;
end;

function TfmExportTable.GetOrders: string;
var
  s: string;
  i: integer;
begin
  Result:='';
  for i:=0 to lbElements.Count-1 do
  begin
    s:=lbElements.Items[i];
    if AnsiCompareText(s,'Дисциплина')=0 then Result:=Result+'subject,' else
      if AnsiCompareText(s,'Аудитория')=0 then Result:=Result+'auditory,' else
      if AnsiCompareText(s,'Преподаватель')=0 then Result:=Result+'teacher,'
  end;
  Delete(Result, Length(Result),1);
end;

procedure TfmExportTable.OnElementBtnsClick(Sender: TObject);

var
  style: TFontStyles;
  down: boolean;
  newindex: integer;
begin
  Assert(Assigned(FOptions),
    '14939D1C-F0C3-4FB1-A3D5-BE8DD01571D2'#13'OnBtnsClick: FOptions is nil'#13);

  if (Sender is TToolButton) then
  begin
    style:=[];
    case TToolButton(Sender).Tag of
    1:  // bold
      style:=[fsBold];
    2:  // italic
      style:=[fsItalic];
    3:  // underline
      style:=[fsUnderline];
    4,5:  // up & down
      begin
        newindex:=lbElements.ItemIndex;
        if TToolButton(Sender).Tag=4 then dec(newindex)
          else inc(newindex);
        lbElements.Items.Move(lbElements.ItemIndex,newindex);
        lbElements.ItemIndex:=newindex;
        FOptions.Orders.CommaText:=GetOrders();
        UpdateUpDownBtns();
      end;
    end;

    if style<>[] then
    begin
      down:=TToolButton(Sender).Down;
      case lbElements.ItemIndex of
      0:  // subject
        if down then FOptions.SubjectStyleFont:=FOptions.SubjectStyleFont+style
          else FOptions.SubjectStyleFont:=FOptions.SubjectStyleFont-style;
      1:  // auditory
        if down then FOptions.AuditoryStyleFont:=FOptions.AuditoryStyleFont+style
          else FOptions.AuditoryStyleFont:=FOptions.AuditoryStyleFont-style;
      2:  // teacher
        if down then FOptions.TeacherStyleFont:=FOptions.TeacherStyleFont+style
          else FOptions.TeacherStyleFont:=FOptions.TeacherStyleFont-style;
      end; // case
    end;

  end;  // if Sender is TCheckBox
end;

procedure TfmExportTable.cbSizeChange(Sender: TObject);
var
  size: integer;
begin
  Assert(Assigned(FOptions),
    'F8742F72-531A-46F6-BF9D-0A6822171A68'#13'cbSizeChange: FOptions is nil'#13);

  if Sender is TComboBox then
  begin
    size:=StrToIntDef(TComboBox(Sender).Text, 8);

    case lbElements.ItemIndex of
    0:  // subject
      FOptions.SubjectSizeFont:=size;
    1:  // auditory
      FOptions.AuditorySizeFont:=size;
    2:  // teacher
      FOptions.TeacherSizeFont:=size;
    end; // case
  end;
end;

// обновление состояния кнопок (up & down)
procedure TfmExportTable.UpdateUpDownBtns;
var
  i: integer;
  bup,bdown: boolean;
begin
  i:=lbElements.ItemIndex;
  bup:=false;
  bdown:=false;

  if i=0 then bdown:=true else
    if i=lbElements.Count-1 then bup:=true else
    if (i>0) and (i<lbElements.Count) then
    begin
      bup:=true;
      bdown:=true;
    end;

  btnUp.Enabled:=bup;
  btnDown.Enabled:=bdown;
end;


procedure TfmExportTable.ComboDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  c: TCanvas;
  oldbmp: TBitmap;
begin
  if Control is TComboBox then
  begin
    c:=TComboBox(Control).Canvas;

    BitBlt(bmpPat.Canvas.Handle,0,0,bmpPat.Width,bmpPat.Height,bmpBuf.Canvas.Handle,
        Index*iPatternSize,0,SRCCOPY);

    oldbmp:=c.Brush.Bitmap;
    c.Brush.Bitmap:=bmpPat;
    c.FillRect(Rect);
    c.Brush.Bitmap:=oldbmp;
  end;
end;

procedure TfmExportTable.cbPatternChange(Sender: TObject);
var
  i: integer;
begin
  Assert(Assigned(FOptions),
    'A452AD91-5B92-4B32-8135-4B6B8A5856D2'#13'cbPatternChange: FOptions is nil'#13);

  if Sender is TComboBox then
  begin
    i:=TComboBox(Sender).ItemIndex;
    case TComboBox(Sender).Tag of
      1:  // lection
        FOptions.LctnPattern:=TPatternStyle(i);
      2:  // practic
        FOptions.PrctPattern:=TPatternStyle(i);
      3:  // laboratory
        Foptions.LbryPattern:=TPatternStyle(i);
    end;  // case
  end; // if is
end;

procedure TfmExportTable.chkMergeClick(Sender: TObject);
begin
  Assert(Assigned(FOptions),
    '{E314036B-5C13-4237-AF09-D9352042B723'#13'chkMergeClick: FOptions is nil'#13);

  if Sender is TCheckBox then
    FOptions.MergeCells:=TCheckBox(Sender).Checked;
end;

procedure TfmExportTable.cbOtherChange(Sender: TObject);
var
  n: integer;
begin
  Assert(Assigned(FOptions),
    'A52920D3-0550-4DB9-B276-7B7D47D69F45'#13'cbParityStyle: FOptions is nil'#13);

  case (Sender as TComboBox).Tag of

    4:  // parity style
      FOptions.ParityStyle:=TParityStyle(TComboBox(Sender).ItemIndex);

    5:  // small percent
      begin
        n:=StrToIntDef(TComboBox(Sender).Text,-1);
        if (n>0) and (n<255) then FOptions.SmallPercent:=byte(n)
          else TComboBox(Sender).Text:=IntToStr(FOptions.SmallPercent);
      end;

    6:  // double pair style
      FOptions.DoubleStyle:=TDoubleStyle(TComboBox(Sender).ItemIndex);

  end;  // case(tag)
end;

// обновление Control`ов
procedure TfmExportTable.UpdateControls;
begin
  // обновление ComboBox`ов
  cbLesson.ItemIndex:=Ord(FOptions.LctnPattern);
  cbPractic.ItemIndex:=Ord(FOptions.PrctPattern);
  cbLabo.ItemIndex:=Ord(FOptions.LbryPattern);

  cbParityStyle.ItemIndex:=Ord(FOptions.ParityStyle);
  cbSmall.Text:=IntToStr(FOptions.SmallPercent);
  cbDoublePair.ItemIndex:=Ord(FOptions.DoubleStyle);

  // обновление CheckBox`ов
  chkMerge.OnClick:=nil;
  chkMerge.Checked:=FOptions.MergeCells;
  chkMerge.OnClick:=chkMergeClick;
end;

procedure TfmExportTable.btnDefaultClick(Sender: TObject);
begin
  if Assigned(FOptions) then
  begin
    FOptions.SetDefault;
    UpdateFrame;
  end;
end;

end.
