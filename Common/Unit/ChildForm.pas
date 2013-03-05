unit ChildForm;

interface

uses
  Windows, Messages, Forms, Controls, Classes;

type
  TChildForm = class(TForm)
  private
    FAsChild: boolean;
    FTempParent: TWinControl;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure Loaded; override;
  public
    constructor Create(AOwner: TComponent); overload;override;
    constructor Create(AOwner: TComponent; AParent: TWinControl); reintroduce; overload;
  end;

implementation

{ TChildForm }

constructor TChildForm.Create(AOwner: TComponent);
begin
  FAsChild:=false;
  inherited Create(AOwner);
end;

constructor TChildForm.Create(AOwner: TComponent; AParent: TWinControl);
begin
  FAsChild:=true;
  FTempParent:=AParent;
  inherited Create(AOwner);
end;

procedure TChildForm.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  if FAsChild then
    Params.Style := Params.Style or WS_CHILD;
end;

procedure TChildForm.Loaded;
begin
  inherited;
  if FAsChild then
  begin
    Align := alClient;
    BorderStyle := bsNone;
    BorderIcons := [];
    Parent := FTempParent;
    Position := poDefault;
  end;
end;

end.
 