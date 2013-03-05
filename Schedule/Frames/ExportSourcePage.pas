{
  Редактирование источника для экспорта
  v0.0.2  (01/09/06)
}
unit ExportSourcePage;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, StdCtrls, CheckLst, Buttons, SClasses, PageDlg;

type
  TfrmExportSourcePage = class(TPageForm)
    lbList: TCheckListBox;
    chkAll: TCheckBox;
    GroupBox: TGroupBox;
    lblFile: TLabel;
    SaveBtn: TSpeedButton;
    SaveDialog: TSaveDialog;
    procedure chkAllClick(Sender: TObject);
    procedure lbListClickCheck(Sender: TObject);
    procedure lbListDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure lbListDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure SaveBtnClick(Sender: TObject);
  private
    { Private declarations }
    FFileName: string;

  public
    { Public declarations }
    function IsValid: boolean; override;

    procedure AssignList(AList: TStrings); overload;
    procedure AssignList(AList: TSchedule); overload;
    
    function GetList(var AList: TStrings): integer;
    function GetObjectList(var AList: TList): integer;

    property FileName: string read FFileName;

  end;

implementation

{$R *.dfm}

{ TfmExportSource }

// проверка на ввод всех данных (31/08/06)
function TfrmExportSourcePage.IsValid: boolean;
begin
  Result:=(lblFile.Caption<>'') and (chkAll.State in [cbChecked,cbGrayed]);
end;

procedure TfrmExportSourcePage.chkAllClick(Sender: TObject);
var
  i: integer;
begin
  if Sender is TCheckBox then
    for i:=0 to lbList.Count-1 do
      lbList.Checked[i]:=TCheckBox(Sender).Checked;
  DoAction();
end;

procedure TfrmExportSourcePage.lbListClickCheck(Sender: TObject);
var
  CheckState: TCheckBoxState;
  check: boolean;
  i: integer;
begin
  if Sender is TCheckListBox then
  begin
    if TCheckListBox(Sender).Count>0 then
    begin
      check:=TCheckListBox(Sender).Checked[0];
      if check then CheckState:=cbChecked else CheckState:=cbUnchecked;
      for i:=1 to TCheckListBox(Sender).Count-1 do
        if TCheckListBox(Sender).Checked[i]<>check then
        begin
          CheckState:=cbGrayed;
          break;
        end;
    end
    else CheckState:=cbUnchecked;
    chkAll.OnClick:=nil;
    chkAll.State:=CheckState;
    chkAll.OnClick:=chkAllClick;

    DoAction();
  end;
end;

procedure TfrmExportSourcePage.lbListDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  i: integer;
begin
  if (Sender is TCheckListBox) and (Source is TCheckListBox) then
  begin
    i:=TCheckListBox(Sender).ItemAtPos(Point(X,Y), true);
    if i>=0 then
    begin
      TCheckListBox(Sender).Items.Move(TCheckListBox(Source).ItemIndex,i);
      TCheckListBox(Sender).ItemIndex:=i;
    end;
  end; // if Sender and Source is TCheckListBox
end;

procedure TfrmExportSourcePage.lbListDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
var
  i, j: integer;
begin
  if (Sender is TCheckListBox) and (Source is TCheckListBox) then
  begin
    i:=TCheckListBox(Sender).ItemAtPos(Point(X,Y), true);
    j:=TCheckListBox(Source).ItemIndex;
    Accept:=(Sender=Source) and (j<>-1) and (j<>i);
  end;

end;

procedure TfrmExportSourcePage.SaveBtnClick(Sender: TObject);
begin
  if SaveDialog.Execute then
  begin
    FFileName:=SaveDialog.FileName;
    lblFile.Caption:=FFileName;
    lblFile.Hint:=FFileName;
    DoAction();
  end;
end;

// загрузка списка (31/08/06)
procedure TfrmExportSourcePage.AssignList(AList: TStrings);
begin
  lbList.Items.BeginUpdate;
  lbList.Items.Clear;
  lbList.Items.AddStrings(AList);
  lbList.Items.EndUpdate;
end;

// загрузка групп (31/08/06)
procedure TfrmExportSourcePage.AssignList(AList: TSchedule);
var
  i: integer;
begin
  lbList.Items.BeginUpdate;
  lbList.Clear;
  for i:=0 to AList.Count-1 do
    lbList.AddItem(AList.Item[i].Name, AList.Item[i]);
  lbList.Items.EndUpdate;
end;

// извлечение списка строк (31/08/06)
function TfrmExportSourcePage.GetList(var AList: TStrings): integer;
var
  i: integer;
begin
  Assert(Assigned(AList),
    'FBBF5930-9AA9-4E70-BD97-72222525AC03'#13'GetList: AList is nil'#13);

  for i:=0 to lbList.Count-1 do
    if lbList.Checked[i] then AList.Add(lbList.Items[i]);

  Result:=AList.Count;
end;

// извлечение списка объектов (31/08/06)
function TfrmExportSourcePage.GetObjectList(var AList: TList): integer;
var
  i: integer;
begin
  Assert(Assigned(AList),
    'E77831CD-8E26-46DA-8F1F-1CCF278AD35A'#13'GetObjectList: AList is nil'#13);

  for i:=0 to lbList.Count-1 do
    if lbList.Checked[i] then AList.Add(lbList.Items.Objects[i]);

  Result:=AList.Count;
end;

end.
