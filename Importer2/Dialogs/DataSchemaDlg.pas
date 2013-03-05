{
  Диалог редактирования схемы данных
  v0.0.1  (15/07/07)
  (C) Riskov Leonid, 2007
}
unit DataSchemaDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, WIOptions, XLSchema, StdCtrls, ExtCtrls, GridsEh, DBGridEh, DB,
  kbmMemTable;

type
  TfrmDataSchemaDlg = class(TForm)
    btnOk: TButton;
    btnCancel: TButton;
    SchemaTable: TkbmMemTable;
    DataSource: TDataSource;
    DBGrid: TDBGridEh;
    InfoPanel: TPanel;
    InfoLabel: TLabel;
    Label2: TLabel;
    SchemaTable_name: TStringField;
    SchemaTable_title: TStringField;
    SchemaTable_row: TIntegerField;
    SchemaTable_coll: TIntegerField;
    btnExport: TButton;
    btnImport: TButton;
    procedure DBGridColumns1GetCellParams(Sender: TObject;
      EditMode: Boolean; Params: TColCellParamsEh);
    procedure SchemaTable_rowValidate(Sender: TField);
    procedure btnClick(Sender: TObject);
  private
    { Private declarations }
    FXML: string;
    FLoading: boolean;

    procedure loadSchema(schema: IXLSchema);
    procedure changeSchema(schema: IXLSchema);

  public
    { Public declarations }
    function editSchema(schema: IXLSchema): boolean;

  end;

procedure EditXLSchema(category: TImportCategory);

implementation

{$R *.dfm}

uses
  Math, XMLIntf;

// вызов диалога редактирования схемы данных  (15/07/07)
procedure EditXLSchema(category: TImportCategory);
var
  frmDlg: TfrmDataSchemaDlg;
  schema: IXLSchema;
begin
  frmDlg:=TfrmDataSchemaDlg.Create(Application);
  try
    schema:=category.buildXLSchema;
    if frmDlg.editSchema(schema) then
      category.XLSchema:=schema.OwnerDocument.XML.Text;
  finally
    frmDlg.Free;
  end;
end;

{ TXDataSchemaDlg }

procedure TfrmDataSchemaDlg.changeSchema(schema: IXLSchema);
var
  cell: IXLCell;
  i: integer;
begin
  SchemaTable.DisableControls;
  try
     SchemaTable.First;
     while not SchemaTable.Eof do
     begin
        cell:=schema.CellByName(SchemaTable.FieldByName('name').AsString);
        i:=SchemaTable.FieldByName('row').AsInteger;
        if i>0 then cell.Row:=i;
        i:=SchemaTable.FieldByName('coll').AsInteger;
        if i>0 then cell.Coll:=i;
        SchemaTable.Next;
     end;
  finally
    SchemaTable.EnableControls;
  end;
end;

function TfrmDataSchemaDlg.editSchema(schema: IXLSchema): boolean;
begin
  loadSchema(schema);

  Result:=ShowModal()=mrOk;
  if Result then changeSchema(schema);
end;

procedure TfrmDataSchemaDlg.loadSchema(schema: IXLSchema);
var
  i: integer;
  cell: IXLCell;
begin
  FXML:=schema.OwnerDocument.XML.Text;

  SchemaTable.DisableControls;
  try
    SchemaTable.Open;
    SchemaTable.EmptyTable;

    FLoading:=true;
    for i:=0 to schema.Count-1 do
    begin
      cell:=schema.Cell[i];

      SchemaTable.Append;
      SchemaTable.FieldByName('name').Value:=cell.Name;
      SchemaTable.FieldByName('title').Value:=cell.Title;
      SchemaTable.FieldByName('row').Value:=cell.Row;
      SchemaTable.FieldByName('coll').Value:=cell.Coll;
      SchemaTable.Post;
    end;
    SchemaTable.First;

  finally
    FLoading:=false;
    SchemaTable.EnableControls;
  end;
end;

procedure TfrmDataSchemaDlg.DBGridColumns1GetCellParams(Sender: TObject;
  EditMode: Boolean; Params: TColCellParamsEh);
begin
  if SchemaTable.FieldByName(TDBGridColumnEh(Sender).FieldName).AsInteger<=0 then
  begin
    Params.ReadOnly:=true;
    Params.Background:=$E5E5E5;
  end;
end;

procedure TfrmDataSchemaDlg.SchemaTable_rowValidate(Sender: TField);
begin
  if (Sender.AsInteger<=0) and (not FLoading) then
    raise Exception.Create('Значение должно быть положительным');
end;

procedure TfrmDataSchemaDlg.btnClick(Sender: TObject);

  const
    DLG_FILTER = 'XML files|*.xml|Any files|*.*';
    DLG_FILENAME = 'xlschema.xml';

  // импорт схемы из файла
  procedure DoImportSchema;
  var
    dlg: TOpenDialog;
  begin
    dlg:=TOpenDialog.Create(Self);
    try

      dlg.Filter:=DLG_FILTER;
      dlg.FileName:=DLG_FILENAME;
      if dlg.Execute then
        loadSchema(LoadXLSchema(dlg.FileName));

    finally
      dlg.Free;
    end;
  end;

  // экспорт схемы в файл
  procedure DoExportSchema;
  var
    dlg: TSaveDialog;
    schema: IXLSchema;
  begin
    schema:=CreateXLSchema(FXML);
    changeSchema(schema);

    dlg:=TSaveDialog.Create(Self);
    try
      dlg.Filter:=DLG_FILTER;
      dlg.DefaultExt:='xml';
      dlg.FileName:=DLG_FILENAME;
      if dlg.Execute then
        schema.OwnerDocument.SaveToFile(dlg.FileName);
    finally
      dlg.Free;
    end;
  end;

begin
  case (Sender as TButton).Tag of

    1:  // import
      DoImportSchema;

    2:  // export
      DoExportSchema;

  end;
end;

end.
