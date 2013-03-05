{
  Настройки DBAdmin
  v0.0.1  (09.04.06)
}
unit AOptions;

interface

uses
  CustomOptions, SCategory;

type
  // настройки для DBAdmin
  TAOptions = class(TCustomOptions)
  public
    constructor Create(const ARoot, AKey: string); override;
  end;

implementation

uses
  SConsts;

{ TAOptions }

constructor TAOptions.Create(const ARoot, AKey: string);
begin
  inherited Create(ARoot, AKey);
  AddCategory(TWindowCategory.Create(CAT_DBADMIN, Self));
end;

end.
 