{
  Диалог со страницами.
  v0.0.1  (01/09/06)
}
unit PageDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls;

type
  // форма-страница
  TPageForm = class(TForm)
  private
    FOnAction: TNotifyEvent;
  protected
    procedure DoAction;
  public
    constructor Create(AOwner: TComponent); override;
    function IsValid: boolean; virtual;
  end;

  TPageFormClass = class of TPageForm;

  TfrmPageDlg = class(TForm)
    btnOk: TButton;
    btnCancel: TButton;
    PageControl: TPageControl;

  private
    { Private declarations }

    procedure OnPageAction(Sender: TObject);
    function GetPageForm(index: integer): TPageForm;
    
  public
    { Public declarations }
    function AddPage(ACaption: string; APageClass: TPageFormClass): TPageForm;
    
  end;

var
  frmPageDlg: TfrmPageDlg;

implementation

{$R *.dfm}

{ TPageForm }

constructor TPageForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  AutoScroll:=false;
  BorderStyle:=bsNone;
end;

procedure TPageForm.DoAction;
begin
  if Assigned(FOnAction) then FOnAction(Self);
end;

function TPageForm.IsValid: boolean;
begin
  Result:=true;
end;

{ TfrmPageDlg }

function TfrmPageDlg.AddPage(ACaption: string;
    APageClass: TPageFormClass): TPageForm;
var
  Page: TTabSheet;
begin
  Page:=TTabSheet.Create(PageControl);
  Page.PageControl:=PageControl;
  Page.Caption:=ACaption;

  Result:=APageClass.Create(Self);
  Result.FOnAction:=OnPageAction;

  if Result.Width>PageControl.ClientWidth then
    ClientWidth:=ClientWidth+(Result.Width-PageControl.ClientWidth);
  if Result.Height>PageControl.ClientHeight then
    ClientHeight:=ClientHeight+(Result.Height-PageControl.ClientHeight);

  Result.Parent:=Page;
  Result.Align:=alClient;
  Result.Show;

  OnPageAction(Result);
end;

// извлечение фрейма-страницы со страницы (01/09/06)
function TfrmPageDlg.GetPageForm(index: integer): TPageForm;
var
  i: integer;
  Sheet: TTabSheet;
begin
  Result:=nil;

  Sheet:=PageControl.Pages[index];
  for i:=0 to Sheet.ControlCount-1 do
    if Sheet.Controls[i] is TPageForm then
    begin
      Result:=TPageForm(Sheet.Controls[i]);
      break;
    end;
end;

procedure TfrmPageDlg.OnPageAction(Sender: TObject);
var
  i: integer;
  PageForm: TPageForm;
begin
  btnOk.Enabled:=true;

  for i:=0 to PageControl.PageCount-1 do
  begin
    PageForm:=GetPageForm(i);
    if Assigned(PageForm) then
      if not PageForm.IsValid then
      begin
        btnOk.Enabled:=false;
        break;
      end;
  end;
end;

end.
