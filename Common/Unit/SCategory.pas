{
  Категории (настройки)
  v0.0.3 (29.03.06)
}

unit SCategory;

interface

uses
  Classes, CustomOptions, Graphics, Excel2000;

type
  TBrowseMode = (bmPerformKafedra,bmFacultyKafedra,bmDeclare);
  TElementType = (etSubject, etAuditory, etTeacher);
  TPatternStyle = (psNone=0,psLightGray=1,psMediumGray=2,psDarkGray=3);
  TParityStyle = (psBracket=0, psPattern=1);
  TDoubleStyle = (dsNone=0, dsShift=1, dsFull=2);

  // опции глав. окна
  TWindowCategory = class(TCategory)
  private
    FTop: integer;
    FLeft: integer;
    FHeight: integer;
    FWidth: integer;
    FDebug: boolean;
  public
    procedure SetDefault; override;
  published
    property Top: integer read FTop write FTop;
    property Left: integer read FLeft write FLeft;
    property Height: integer read FHeight write FHeight;
    property Width: integer read FWidth write FWidth;
    property Debug: boolean read FDebug write FDebug;
  end;

  // опции глав. окна (клиент)
  TClientCategory = class(TWindowCategory)
  private
    FBrowseMode: TBrowseMode;
    FAutoConn: boolean;
  public
    procedure SetDefault; override;
  published
    property AutoConn: boolean read FAutoConn write FAutoConn;
    property BrowseMode: TBrowseMode read FBrowseMode write FBrowseMode;
  end;

  // опции экспорта расписания
  TExportTableCategory = class(TCategory)
  private
    FxltFile: string;                 // файл-шаблон
    FMergeCells: boolean;             // объед-ние ячеек
    FSmallPercent: byte;              // % сокращения дисциплины

    FOrders: TStringList;             // порядок эл-тов (дисциплина,аудитория,преп-ль)

    FSubjectSizeFont: integer;        // размер шрифта дисциплины
    FSubjectStyleFont: TFontStyles;   // стиль шрифта дисциплины
    FAuditorySizeFont: integer;       // размер шрифта аудитории
    FAuditoryStyleFont: TFontStyles;  // стиль шрифта аудитории
    FTeacherSizeFont: integer;        // размер шрифта преп-ля
    FTeacherStyleFont: TFontStyles;   // стиль шрифта преп-ля

    FLctnPattern: TPatternStyle;      // заливка лекций
    FPrtcPattern: TPatternStyle;      // заливка практик
    FLbryPattern: TPatternStyle;      // заливка лабораторных

    FParityStyle: TParityStyle;       // оформление ч/н
    FDoubleStyle: TDoubleStyle;       // оформление двой. пар (к/н)
  protected
    procedure DoCreate; override;
  public
    destructor Destroy; override;
    procedure SetDefault; override;
    function GetElement(index: integer): TElementType;
    function GetPattern(ltype: byte): integer;
  published
    property xltFile: string read FxltFile write FxltFile;
    property MergeCells: boolean read FMergeCells write FMergeCells;

    property Orders: TStringList read FOrders;
    { параметры шрифтов }
    property SubjectSizeFont: integer read FSubjectSizeFont write FSubjectSizeFont;
    property SubjectStyleFont: TFontStyles read FSubjectStyleFont write FSubjectStyleFont;
    property AuditorySizeFont: integer read FAuditorySizeFont write FAuditorySizeFont;
    property AuditoryStyleFont: TFontStyles read FAuditoryStyleFont write FAuditoryStyleFont;
    property TeacherSizeFont: integer read FTeacherSizeFont write FTeacherSizeFont;
    property TeacherStyleFont: TFontStyles read FTeacherStyleFont write FTeacherStyleFont;
    { закраска занятий }
    property LctnPattern: TPatternStyle read FLctnPattern write FLctnPattern;
    property PrctPattern: TPatternStyle read FPrtcPattern write FPrtcPattern;
    property LbryPattern: TPatternStyle read FLbryPattern write FLbryPattern;

    property ParityStyle: TParityStyle read FParityStyle write FParityStyle;
    property SmallPercent: byte read FSmallPercent write FSmallPercent;
    property DoubleStyle: TDoubleStyle read FDoubleStyle write FDoubleStyle;
  end;

var
  PatternStyles: array[TPatternStyle] of integer =
      (xlPatternNone,xlPatternGray8,xlPatternGray16,xlPatternGray25);

implementation

uses
  SysUtils;

{ TWindowCategory }

procedure TWindowCategory.SetDefault;
begin
  FTop:=0;
  FLeft:=0;
  FHeight:=470;
  FWidth:=700;
end;

{ TClientCategory }

procedure TClientCategory.SetDefault;
begin
  inherited SetDefault;
  FAutoConn:=true;
  FBrowseMode:=bmPerformKafedra;
end;

{ TExportTableCategory }

destructor TExportTableCategory.Destroy;
begin
  FreeAndNil(FOrders);
//  FreeAndNil(FSbjFont);
//  FreeAndNil(FAudFont);
//  FreeAndNil(FThrFont);

  inherited Destroy;
end;

procedure TExportTableCategory.DoCreate;
begin
  FOrders:=TStringList.Create;
end;

function TExportTableCategory.GetElement(index: integer): TElementType;
var
  s: string;
begin
  Assert(index<FOrders.Count,
    'F91B6FDA-9E6D-49E7-ACE1-3C9ACE63042D'#13'TExportTableCategory.GetElement: index out of range'#13);

  s:=FOrders[index];
  if AnsiCompareText(s,'subject')=0 then Result:=etSubject;
    if AnsiCompareText(s,'auditory')=0 then Result:=etAuditory;
    if AnsiCompareText(s,'teacher')=0 then Result:=etTeacher;
end;

function TExportTableCategory.GetPattern(ltype: byte): integer;
begin
  case ltype of
    1:   Result:=PatternStyles[FLctnPattern];
    2:   Result:=PatternStyles[FPrtcPattern];
    3:   Result:=PatternStyles[FLbryPattern];
    else Result:=xlPatternNone;
  end;
end;

procedure TExportTableCategory.SetDefault;
begin
  FXltFile:='timetable.xlt';
  FMergeCells:=true;
  FOrders.CommaText:='subject,auditory,teacher';
  FParityStyle:=psBracket;
  FDoubleStyle:=dsNone;
  FSmallPercent:=50;

  FSubjectSizeFont:=14;
  FSubjectStyleFont:=[fsBold];
  FAuditorySizeFont:=12;
  FAuditoryStyleFont:=[];
  FTeacherSizeFont:=14;
  FTeacherStyleFont:=[fsBold];

  FLctnPattern:=psLightGray;
  FPrtcPattern:=psNone;
  FLbryPattern:=psNone;
end;

end.
