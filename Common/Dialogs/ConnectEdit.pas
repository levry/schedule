{
  Диалог редактирования строки соединения
  v0.0.1  (03.04.06)
}

unit ConnectEdit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, CustomOptions;

type
  TfrmConEdit = class(TForm)
    Bevel1: TBevel;
    Label1: TLabel;
    rbUseFile: TRadioButton;
    rbUseString: TRadioButton;
    edFile: TEdit;
    edString: TEdit;
    btnOpen: TButton;
    btnBuild: TButton;
    btnOk: TButton;
    btnCancel: TButton;
    procedure OnBtnsClick(Sender: TObject);
    procedure OnUseClick(Sender: TObject);
  private
    { Private declarations }
    function GetConnectionString: string;
    procedure SetConnectionString(Value: string);
  public
    { Public declarations }
    property ConnectionString: string read GetConnectionString write SetConnectionString;
  end;

function EditConnection(ASettings: TRootCategory): boolean; overload;
function EditConnection(var AConnStr: string): boolean; overload;

implementation

uses
  ADODB, ADOInt;

{$R *.dfm}

function EditConnection(ASettings: TRootCategory): boolean;
var
  frmDlg: TfrmConEdit;
  ConnStr: string;
begin
  Result:=false;
  frmDlg:=TfrmConEdit.Create(Application);
  try
    frmDlg.ConnectionString:=ASettings.ConnStr;
    if frmDlg.ShowModal=mrOk then
    begin
      ConnStr:=frmDlg.ConnectionString;
      if ASettings.ConnStr<>ConnStr then
      begin
        ASettings.ConnStr:=ConnStr;
        Result:=true;
      end;
    end;
  finally
    frmDlg.Free;
    frmDlg:=nil;
  end;
end;

function EditConnection(var AConnStr: string): boolean;
var
  frmDlg: TfrmConEdit;
begin
  Result:=false;

  frmDlg:=TfrmConEdit.Create(Application);
  try
    frmDlg.ConnectionString:=AConnStr;
    if (frmDlg.ShowModal=mrOk) and (frmDlg.ConnectionString<>AConnStr) then
    begin
      AConnStr:=frmDlg.ConnectionString;
      Result:=true;
    end;
  finally
    frmDlg.Free;
    frmDlg:=nil;
  end;
end;

{ TfrmConEdit }

function TfrmConEdit.GetConnectionString: string;
begin
  if rbUseString.Checked then Result := edString.Text else
    if edFile.Text <> '' then Result:=CT_FILENAME+edFile.Text
      else Result:='';
end;

procedure TfrmConEdit.SetConnectionString(Value: string);
var
  FileName: string;
begin
  if Pos(CT_FILENAME, Value) = 1 then
  begin
    rbUseFile.Checked:=true;
    FileName := Copy(Value, Length(CT_FILENAME)+1, MAX_PATH);
    edFile.Text := FileName;
  end else
  begin
    edString.Text := Value;
    rbUseString.Checked := True;
  end;
  OnUseClick(nil);
end;

procedure TfrmConEdit.OnBtnsClick(Sender: TObject);
begin
  case (Sender as TButton).Tag of
    1:  // open file
      edFile.Text := PromptDataLinkFile(Handle, edFile.Text);
    2:  // build string
      edString.Text := PromptDataSource(Handle, edString.Text);
  end;
end;

procedure TfrmConEdit.OnUseClick(Sender: TObject);
const
  EnabledColor: array[Boolean] of TColor = (clBtnFace, clWindow);
begin
  edFile.Enabled := rbUseFile.Checked;
  edFile.Color := EnabledColor[edFile.Enabled];
  btnOpen.Enabled := edFile.Enabled;
  edString.Enabled := rbUseString.Checked;
  edString.Color := EnabledColor[edString.Enabled];
  btnBuild.Enabled := edString.Enabled;
  if edFile.Enabled then ActiveControl := edFile
    else ActiveControl := edString;
end;

end.
