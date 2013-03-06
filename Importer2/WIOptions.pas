{
  Настройки WImport
  v0.0.2  (15/07/07)
}
unit WIOptions;

interface

uses
  CustomOptions, SCategory, XLSchema,
  Windows;

type

  // настройки для WImport
  TWIOptions = class(TCustomOptions)
  public
    constructor Create(const ARoot, AKey: string); override;
  end;

  TImportCategory = class(TWindowCategory)
  private
    FXLSchema: string;

  public
    procedure SetDefault; override;
    function buildXLSchema: IXLSchema;

  published
    property XLSchema: string read FXLSchema write FXLSchema;

  end;

  // цвета
  TColorCategory = class(TCategory)
  private
    FNullColor: COLORREF;              // null значение
    FErrorColor: COLORREF;             // error значение

  public
    procedure SetDefault; override;

  published
    property NullColor: COLORREF read FNullColor write FNullColor;
    property ErrorColor: COLORREF read FErrorColor write FErrorColor;

  end;

implementation

uses
  Classes,
  SConsts;

function LoadFromResource(const ResName: string): string;
var
  ResStream: TResourceStream;
begin
  ResStream:=TResourceStream.Create(HInstance, ResName, RT_RCDATA);
  try
    with TStringStream.Create('') do
    begin
      CopyFrom(ResStream, ResStream.Size);
      Result:=DataString;
      Free;
    end;
  finally
    ResStream.Free;
  end;
end;

{ TColorCategory }

procedure TColorCategory.SetDefault;
begin
  FNullColor:=$E5E5E5;
  FErrorColor:=$C1E0FF;
end;

{ TWIOptions }

constructor TWIOptions.Create(const ARoot, AKey: string);
begin
  inherited Create(ARoot, AKey);
  AddCategory(TImportCategory.Create(CAT_WIMPORT, Self));
  AddCategory(TColorCategory.Create(CAT_COLORS,Self));
end;

{ TImportCategory }

function TImportCategory.buildXLSchema: IXLSchema;
begin
  Result:=CreateXLSchema(XLSchema);
end;

procedure TImportCategory.SetDefault;
begin
  inherited;

  FXLSchema:=LoadFromResource('SCHEMA');
end;

end.
