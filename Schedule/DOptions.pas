{
  Настройки DTable
  v0.0.1 (14.03.06)
}

unit DOptions;

interface

uses
  CustomOptions, SCategory;

type
  // настройки для DTable
  TDOptions = class(TCustomOptions)
  public
    constructor Create(const ARoot, AKey: string); override;
  end;

implementation

uses
  SConsts;

{ TDOptions }

constructor TDOptions.Create(const ARoot, AKey: string);
begin
  inherited Create(ARoot, AKey);
  AddCategory(TClientCategory.Create(CAT_DTABLE, Self));
  AddCategory(TExportTableCategory.Create(CAT_EXPORTTABLE, Self));
end;

end.
 