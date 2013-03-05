{
  Диалог редактирование инф-ции о преп-ле
  v0.0.1
}

unit TeachDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Mask, DB;

type
  TTeachDlgStyle = (tdsEdit, tdsAdd);

  TfrmTeachDlg = class(TForm)
    Panel1: TPanel;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Edit4: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    Edit6: TEdit;
    Label6: TLabel;
    Memo1: TMemo;
    Label7: TLabel;
    Label8: TLabel;
    Label10: TLabel;
    OkBtn: TButton;
    CancelBtn: TButton;
    AddBtn: TButton;
    Bevel1: TBevel;
    lblKafedra: TLabel;
    cbPost: TComboBox;
    Edit5: TMaskEdit;
    procedure BtnsClick(Sender: TObject);
    procedure EditsChange(Sender: TObject);
    procedure cbDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
  private
    { Private declarations }

    FDataSet: TDataSet;
    FDlgStyle: TTeachDlgStyle;
    kid: string;
  public
    { Public declarations }
  end;


procedure ShowTeachDlg(DlgStyle: TTeachDlgStyle; ADataSet: TDataSet;
  const kaf: string; const APosts: TStringList);

implementation

uses
  SUtils;

// Вызов окна с инф-цие о преподавателе (21.08.2004)
procedure ShowTeachDlg(DlgStyle: TTeachDlgStyle; ADataSet: TDataSet;
  const kaf: string; const APosts: TStringList);
var
  frmDlg: TfrmTeachDlg;
begin
  Assert(Assigned(APosts),
    '87D232B1-462C-404E-BFC2-92CE3A198D3A'#13'ShowTeachDlg: APosts is nil'#13);

  if ADataSet.Active then
  begin
    frmDlg:=TfrmTeachDlg.Create(Application);
    try
      frmDlg.FDlgStyle:=DlgStyle;
      frmDlg.FDataSet:=ADataSet;
      frmDlg.cbPost.Items.AddStrings(APosts);
      if DlgStyle=tdsEdit then
        with frmDlg do
        begin
          Edit1.Text:=ADataSet.FieldByName('tName').AsString;
          Edit2.Text:=ADataSet.FieldByName('Name').AsString;
          Edit3.Text:=ADataSet.FieldByName('Partname').AsString;
          Edit4.Text:=ADataSet.FieldByName('Initials').AsString;
          Edit5.Text:=ADataSet.FieldByName('BDay').AsString;
          Memo1.Lines.Add(ADataSet.FieldByName('Adress').AsString);
          Edit6.Text:=ADataSet.FieldByName('Phone').AsString;
          cbPost.ItemIndex:=cbPost.Items.IndexOfName(ADataSet.FieldByName('pid').AsString);
          if cbPost.ItemIndex=-1 then cbPost.ItemIndex:=0;
          AddBtn.Enabled:=false;
        end
      else frmDlg.cbPost.ItemIndex:=0;
      frmDlg.lblKafedra.Caption:=GetValue(kaf);
      frmDlg.kid:=GetName(kaf);
      frmDlg.ShowModal;
    finally
      frmDlg.Free;
    end;
  end; // if
end;

{$R *.dfm}

{ Событие от нажатия на кнопки (21.08.2004) }
procedure TfrmTeachDlg.BtnsClick(Sender: TObject);

  procedure ClearEdits;
  var
    i: integer;
  begin
    for i:=0 to Self.ControlCount-1 do
      if Self.Controls[i] is TCustomEdit then
        TCustomEdit(Self.Controls[i]).Clear;
    cbPost.ItemIndex:=0;
    Edit1.SetFocus;
  end;

var
  str: string;
  dt: TDateTime;
begin
  if (Sender as TButton).Tag<>3 then
  begin
    if (Edit1.Text<>'')and(Edit4.Text<>'')and(FDataSet.Active) then
    begin
      Assert(Edit1.Text<>'',
        '7431B18F-C2D4-40D6-8D46-A5BAF322F779'#13'BtnsClick: Edit.Text=""'#13);

      if FDlgStyle=tdsAdd then FDataSet.Append else FDataSet.Edit;

      FDataSet.FieldByName('tName').AsString:=Edit1.Text;
      if Trim(Edit2.Text)<>'' then FDataSet.FieldByName('Name').AsString:=Edit2.Text
        else FDataSet.FieldByName('Name').Clear;
      if Trim(Edit3.Text)<>'' then FDataSet.FieldByName('Partname').AsString:=Edit3.Text
        else FDataSet.FieldByName('Partname').Clear;
      FDataSet.FieldByName('Initials').AsString:=Edit4.Text;

      if TryStrToDate(Edit5.EditText,dt) then FDataSet.FieldByName('BDay').AsString:=Edit5.EditText
        else FDataSet.FieldByName('BDay').Clear;

      str:=Trim(Memo1.Lines.Text);
      str:=StringReplace(str , #13#10, ' ', [rfReplaceAll]);
      if Trim(str)<>'' then FDataSet.FieldByName('Adress').AsString:=str
        else FDataSet.FieldByName('Adress').Clear;
      if Trim(Edit6.Text)<>'' then FDataSet.FieldByName('Phone').AsString:=Edit6.Text
        else FDataSet.FieldByName('Phone').Clear;
      FDataSet.FieldByName('pid').AsString:=GetName(cbPost.Items[cbPost.ItemIndex]);
      FDataSet.FieldByName('kid').Value:=kid;
      FDataSet.Post;
      if TButton(Sender).Tag=2 then ClearEdits;
    end;
  end;
end;

{ Событие от изменения в Edit`ах (21.08.2004) }
procedure TfrmTeachDlg.EditsChange(Sender: TObject);
var
  name, pname: string;
begin
  if Sender is TEdit then
  begin
    if Edit1.Text='' then OkBtn.Enabled:=false else OkBtn.Enabled:=true;
    if Edit2.Text<>'' then name:=' '+Copy(Edit2.Text, 1, 1)+'.' else name:='';
    if Edit3.Text<>'' then pname:=' '+Copy(Edit3.Text, 1, 1)+'.' else pname:='';
    Edit4.Text:=Edit1.Text+name+pname;
  end;
end;

procedure TfrmTeachDlg.cbDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  FCanvas: TCanvas;
  s: string;
begin
  if Control is TComboBox then
  begin
    FCanvas:=(Control as TComboBox).Canvas;
    TControlCanvas(FCanvas).UpdateTextFlags;
    s:=SUtils.GetValue((Control as TComboBox).Items[Index]);
    FCanvas.FillRect(Rect);
    FCanvas.TextOut(Rect.Left + 2, Rect.Top, s);
  end;
end;

end.
