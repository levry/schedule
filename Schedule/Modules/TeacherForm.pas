{
  Модуль управления преподавателями
  v0.2.2 (31/07/06)
}

unit TeacherForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, DBGrids, ComCtrls, ToolWin, StdCtrls, DB,
  Modules, ADODB;

type
  TfrmTeachers = class(TModuleForm)
    ToolBar1: TToolBar;
    btnNewTeacher: TToolButton;
    btnEditTeacher: TToolButton;
    btnDelTeacher: TToolButton;
    btnPreferTeacher: TToolButton;
    DBGrid: TDBGrid;
    cbKafedra: TComboBox;
    Label1: TLabel;
    ToolButton1: TToolButton;
    btnUpdate: TToolButton;
    DataSet: TADODataSet;
    DataSource: TDataSource;
    DataSettid: TLargeintField;
    DataSetkid: TLargeintField;
    DataSetpid: TIntegerField;
    DataSettName: TStringField;
    DataSetName: TStringField;
    DataSetPartname: TStringField;
    DataSetInitials: TStringField;
    DataSetBDay: TDateTimeField;
    DataSetAdress: TStringField;
    DataSetPhone: TStringField;
    procedure OnBtnsClick(Sender: TObject);
    procedure cbKafedraChange(Sender: TObject);
    procedure cbKafedraDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure DBGridEditButtonClick(Sender: TObject);
    procedure DataSetkidGetText(Sender: TField; var Text: String;
      DisplayText: Boolean);
    procedure DataSetpidGetText(Sender: TField; var Text: String;
      DisplayText: Boolean);
  protected
    function GetModuleName: string; override;
  private
    { Private declarations }
//    fkid: int64;
    fkafedra: string;
    Posts: TStringList;             // звания преп-лей

    function LoadKafedrs: boolean;  // загрузка кафедр
    procedure LoadPosts;            // загрузка ранков
    procedure LoadTeachers;         // загрузка преп-лей

    function GetKid: int64;
    function GetkName: string;
    procedure SetKafedra(Value: string);
//    procedure OnBeforePost(DataSet: TDataSet);
//    procedure LinkFieldGetText(Sender: TField; var Text: String; DisplayText: Boolean);
//    procedure LinkFieldSetText(Sender: TField; const Text: String);
  public
    { Public declarations }

    procedure UpdateModule; override;

    property kid: int64 read GetKid;
    property kName: string read GetkName;
    property kafedra: string read fkafedra write SetKafedra;
  end;


implementation

uses
  TimeModule,
  TeachDlg, PreferDlg, SUtils, SStrings, StringListDlg, SDBUtils;

{$R *.dfm}


procedure TfrmTeachers.FormCreate(Sender: TObject);
begin
  Posts:=TStringList.Create;
end;

procedure TfrmTeachers.FormDestroy(Sender: TObject);
begin
  Posts.Free;
  Posts:=nil;
end;

function TfrmTeachers.GetModuleName: string;
begin
  Result:='Преподаватели';
end;

// загрузка кафедр (10.01.06)
function TfrmTeachers.LoadKafedrs: boolean;
var
  list: TStringList;
begin
  list:=TStringList.Create;
  try
    if dmMain.GetKafedraList(list) then;
    begin
      cbKafedra.Clear;
      cbKafedra.Items.AddStrings(list);
    end;
  finally
    list.Free;
    list:=nil;
  end;
  Result:=(cbKafedra.Items.Count>0);
end;

// загрузка званий (10.01.06)
procedure TfrmTeachers.LoadPosts;
var
  list: TStringList;
begin
  Assert(Assigned(Posts),
    'EAC7050A-FA47-4676-9510-1870B3C92C15'#13'LoadPosts: Posts is nil'#13);

  list:=TStringList.Create;
  try
    if dmMain.GetPostList(list) then
    begin
      Posts.Clear;
      Posts.AddStrings(list);
    end;
  finally
    list.Free;
    list:=nil;
  end;
end;

// загрузка преп-лей (10.01.06)
procedure TfrmTeachers.LoadTeachers;
begin
  GetRecordset(dmMain.thr_GetKaf(kid), DataSet);
end;

// обновление модуля
procedure TfrmTeachers.UpdateModule;
begin
  LoadPosts;
  cbKafedra.Enabled:=LoadKafedrs;
  if cbKafedra.Enabled then
  begin
    if kid<=0 then fkafedra:=cbKafedra.Items[0];
    cbKafedra.ItemIndex:=cbKafedra.Items.IndexOf(fkafedra);
    LoadTeachers;
  end;
end;

procedure TfrmTeachers.SetKafedra(Value: string);
begin
  if fkafedra<>Value then
  begin
    fkafedra:=Value;
    LoadTeachers;
  end;
end;

function TfrmTeachers.GetKid: int64;
begin
  if fkafedra<>'' then Result:=StrToIntDef(SUtils.GetName(fkafedra),0)
    else Result:=0;
end;

function TfrmTeachers.GetkName: string;
begin
  if fkafedra<>'' then Result:=SUtils.GetValue(fkafedra)
    else Result:='';
end;

procedure TfrmTeachers.OnBtnsClick(Sender: TObject);
var
  PreferSet: TADODataSet;
begin
  if (DBGrid.DataSource<>nil) and (DBGrid.DataSource.State<>dsInactive) then
    with DBGrid.DataSource.DataSet do
      case (Sender as TToolButton).Tag of

      1:  // добавить преподавателя
        //Insert;
        ShowTeachDlg(tdsAdd, DataSet, cbKafedra.Text, Posts);

      2:  // удалить преподавателя
        if Active and CanModify and not (EOF and BOF) then
          if MessageDlg('Удалить преподавателя "'+FieldByName('tName').AsString+'"',
            mtConfirmation, mbOKCancel, 0)<>idCancel then Delete;

      3:  // редактирование преподавателя
        if not FieldByName('tid').IsNull then
          ShowTeachDlg(tdsEdit, DataSet, cbKafedra.Text, Posts);

      { TODO: Исправить вызов предпочтений}
      4: // изм-ние предпочтений преподавателя
        if not FieldByName('tid').IsNull then
        begin
          PreferSet:=TADODataSet.Create(Self);
          try
            PreferSet.Connection:=dmMain.Connection;
            GetRecordset(dmMain.thr_GetPrefer(FieldByName('tid').AsInteger), PreferSet);
            ShowPreferDlg(FieldByName('tid').AsString, 'tid', 'Ограничения',
              FieldByName('tName').AsString, PreferSet);
          finally
            PreferSet.Close;
            PreferSet.Free;
          end;
        end;

      5: // обновление
        UpdateModule;

      end; // case
end;

procedure TfrmTeachers.cbKafedraChange(Sender: TObject);
begin
  if TComboBox(Sender).Text<>'' then
  begin
    kafedra:=TComboBox(Sender).Text;
//    fkid:=StrToIntDef(GetName(TComboBox(Sender).Text),0);
//    LoadTeachers;
  end;
end;

procedure TfrmTeachers.cbKafedraDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  FCanvas: TCanvas;
  s: string;
begin
  if Control is TComboBox then
  begin
    FCanvas:=(Control as TComboBox).Canvas;
    TControlCanvas(FCanvas).UpdateTextFlags;
    s:=(Control as TComboBox).Items[Index];
    if not bDebugMode then s:=GetValue(s);
//{$IF RTLVersion>=15.0}
//    s:=(Control as TComboBox).Items.ValueFromIndex[Index];
//{$ELSE}
//    s:=GetValue((Control as TComboBox).Items[Index]);
//{$IFEND}

    FCanvas.FillRect(Rect);
    FCanvas.TextOut(Rect.Left + 2, Rect.Top, s);
  end;
end;

{
procedure TfrmTeachers.OnBeforePost(DataSet: TDataSet);
begin
  if TForm(Self).Showing then
    if DataSet.State=dsInsert then
      if DataSet.FieldByName('kid').IsNull then
        DataSet.FieldByName('kid').Value:=StrToInt(GetName(cbKafedra.Text));
end;
}

{
procedure TfrmTeachers.LinkFieldGetText(Sender: TField; var Text: String;
  DisplayText: Boolean);
var
  v: Variant;
begin
  if (Assigned(PostList)) and (Assigned(Sender)) and (not Sender.IsNull) then
  begin
    v:=PostList.ValueOfKey(Sender.Value);
    if VarIsNull(v) then LoadPosts;
    Text:=PostList.ValueOfKey(Sender.Value);
  end;
    //Text:=RankList.ValueOfKey(Sender.Value);
end;
}

{
procedure TfrmTeachers.LinkFieldSetText(Sender: TField; const Text: String);
var
  Value: Variant;
begin
  Value:=PostList.KeyOfValue(Text);
  if not VarIsNull(Value) then
  begin
    Sender.OnSetText:=nil;
    Sender.Value:=Value;
//    Sender.Text:=VarToStr(Value);
    Sender.OnSetText:=LinkFieldSetText;
  end;
end;
}

procedure TfrmTeachers.DBGridEditButtonClick(Sender: TObject);
var
  Field: TField;
  id: int64;
  slist: TStrings;
begin
  if Sender is TDBGrid then
  begin
    Field:=TDBGrid(Sender).SelectedField;
    if Assigned(Field) then
    begin
      if AnsiCompareText(Field.FieldName,'kid')=0 then slist:=cbKafedra.Items else
        if AnsiCompareText(Field.FieldName,'pid')=0 then slist:=Posts else
          slist:=nil;

      if Assigned(slist) then
      begin
        if GetIdFromList(Field.DisplayLabel, Field.AsString, id,
            slist) then
          if (id>0) and (Field.Value<>id) then
          begin
            if not (Field.DataSet.State=dsEdit) then Field.DataSet.Edit;
            Field.Value:=id;
            //if not (Field.DataSet.State=dsInsert) then Field.DataSet.Post;
          end;
      end; // if slist<>nil
    end; // if Field<>nil
  end; // if (it is TDBGrid)
end;

procedure TfrmTeachers.DataSetkidGetText(Sender: TField; var Text: String;
  DisplayText: Boolean);
var
  i: integer;
begin
  if (not Sender.IsNull) then
  begin
    i:=cbKafedra.Items.IndexOfName(Sender.AsString);
    if i>=0 then
    begin
      if bDebugMode then Text:=cbKafedra.Items[i]
        else Text:=cbKafedra.Items.ValueFromIndex[i]
    end  else Text:='Неизвестная кафедра';
  end
  else Text:=rsNull;
end;

procedure TfrmTeachers.DataSetpidGetText(Sender: TField; var Text: String;
  DisplayText: Boolean);
var
  i: integer;
begin
  if (not Sender.IsNull) then
  begin
    i:=Posts.IndexOfName(Sender.AsString);
    if i>=0 then
    begin
      if bDebugMode then Text:=Posts[i]
        else Text:=SUtils.GetValue(Posts[i]);
    end  else Text:='Неизвестное звание';
  end
  else Text:='Нет звания';
end;

end.
