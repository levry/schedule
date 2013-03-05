{
  Диалог "О программе"
  v0.0.2  (01/11/06)
}
unit AboutDlg;

// TODO: Вывод времени компиляции проекта

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TfrmAboutDlg = class(TForm)
    btnOk: TButton;
    lblProductName: TLabel;
    lblVersion: TLabel;
    lblVersionDB: TLabel;
    lblDeveloper: TLabel;
    imgLogo: TImage;
    lblOthers: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

procedure ShowAboutDlg(const sProduct, sVersion, sVersionDB: string);

implementation

{$R *.dfm}

// вызов диалога (01.02.06)
procedure ShowAboutDlg(const sProduct, sVersion, sVersionDB: string);
var
  frmDlg: TfrmAboutDlg;
begin
  frmDlg:=TfrmAboutDlg.Create(Application);
  try
    with frmDlg do
    begin
      if FindResource(HInstance,'LOGO',RT_BITMAP)<>0 then
        imgLogo.Picture.Bitmap.LoadFromResourceName(HInstance, 'LOGO');

      lblProductName.Caption:=AnsiUpperCase(sProduct);
      lblVersion.Caption:=lblVersion.Caption+sVersion;
      lblVersionDB.Caption:=lblVersionDB.Caption+sVersionDB;
      lblOthers.Caption:=lblOthers.Caption+#10#09'Others';
      ShowModal;
    end;
  finally
    frmDlg.Free;
  end;
end;

end.
