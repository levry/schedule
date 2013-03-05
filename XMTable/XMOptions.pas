{
  Настройки XMTable
  v0.0.1  (24.04.06)
}

unit XMOptions;

interface

uses
  CustomOptions;

type
  TXMOptions = class(TCustomOptions)
  public
    constructor Create(const ARoot, AKey: string); override;
  end;



implementation

uses
  SConsts, SCategory;

{ TXMOptions }

constructor TXMOptions.Create(const ARoot, AKey: string);
begin
  inherited Create(ARoot, AKey);
  AddCategory(TClientCategory.Create(CAT_XMTABLE, Self));
end;

end.
 