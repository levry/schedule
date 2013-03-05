{
  Настройки WPM
  v0.0.1  (14.03.06)
}

unit WOptions;

interface

uses
  CustomOptions;

type
  TWOptions = class(TCustomOptions)
  public
    constructor Create(const ARoot, AKey: string); override;
  end;

implementation

uses
  SConsts, SCategory;

{ TWOptions }

constructor TWOptions.Create(const ARoot, AKey: string);
begin
  inherited Create(ARoot, AKey);
  AddCategory(TClientCategory.Create(CAT_WPM, Self));
end;

end.
 