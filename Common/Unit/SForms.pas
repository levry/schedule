{
  ����� �������
  v0.0.1  (07.05.06)
}
unit SForms;

interface

uses
  Forms, Controls,
  STypes;

type
  TEntityChangeEvent = procedure(Sender: TObject; const Entity: TEntityData) of object;

  TCustomEntityForm = class(TForm)
  private
    FOnEntityChange: TEntityChangeEvent;

  protected
    procedure DoEntityChange(const Entity: TEntityData);

  public
    // ���-��� ���. ������� ������
    function GetEntityData(var AEntity: TEntityData): boolean; virtual; abstract;
    // ���-��� ������ ���. ������� ������
    function GetParentData(var AEntity: TEntityData): boolean; virtual; abstract;
    // ���-��� ���� ���. ������� ������
    function GetEntityKind: TEntityKind; virtual; abstract;

    property OnEntityChange: TEntityChangeEvent read FOnEntityChange write FOnEntityChange;
  end;

function GetEntityForm(Control: TControl): TCustomEntityForm;

implementation

// ���������� TCustomEntityForm ��� Control`�
function GetEntityForm(Control: TControl): TCustomEntityForm;
begin
  Result:=nil;
  while Assigned(Control.Parent) do
  begin
    if Control.Parent is TCustomEntityForm then
    begin
      Result:=TCustomEntityForm(Control.Parent);
      break;
    end;
    Control:=Control.Parent;
  end;
end;


{ TCustomEntityForm }

procedure TCustomEntityForm.DoEntityChange(const Entity: TEntityData);
begin
  if Assigned(FOnEntityChange) then FOnEntityChange(Self, Entity);
end;

end.
 