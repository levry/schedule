{
  Диалог импорта факультетов+кафедр (схема)
  v0.0.2  (09.04.06)
}
unit ImportSchema;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Excel2000, StdCtrls, AdvEdit, AdvEdBtn, AdvFileNameEdit;

type
  TfrmImportSchemaDlg = class(TForm)
    btnOk: TButton;
    btnCancel: TButton;
    feFile: TAdvFileNameEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FFacultyList: TList;
    FKafedraList: TList;

    procedure ClearList(AList: TList);
  private
    xApp: TExcelApplication;

    function XConnect: boolean;
    procedure XDisconnect;
    function XGetSchemaList(const AFilename: string): boolean;
    procedure ImportSchema;
  public
    { Public declarations }
  end;

procedure ShowImportSchemaDlg;

implementation

uses
  OleServer, ActiveX, AdminModule, SStrings;

{$R *.dfm}

const
  xlLCID = LOCALE_USER_DEFAULT;

type
  PSchemaData = ^TSchemaData;
  TSchemaData = record
    parent: PSchemaData;
    id: integer;
    name: string;
  end;

// вызов диалога-импорта
procedure ShowImportSchemaDlg;
var
  frmDlg: TfrmImportSchemaDlg;
begin
  frmDlg:=TfrmImportSchemaDlg.Create(Application);
  try
    if frmDlg.ShowModal=mrOk then frmDlg.ImportSchema;
  finally
    frmDlg.Free;
    frmDlg:=nil;
  end;
end;

{ TfrmImportSchemaDlg }

procedure TfrmImportSchemaDlg.FormCreate(Sender: TObject);
begin
  FFacultyList:=TList.Create;
  FKafedraList:=TList.Create;
end;

procedure TfrmImportSchemaDlg.FormDestroy(Sender: TObject);
begin
  ClearList(FFacultyList);
  FFacultyList.Free;
  ClearList(FKafedraList);
  FKafedraList.Free;
end;

// очистка списков
procedure TfrmImportSchemaDlg.ClearList(AList: TList);
var
  i: integer;
begin
  for i:=0 to AList.Count-1 do Dispose(AList.Items[i]);
  AList.Clear;
end;

function TfrmImportSchemaDlg.XConnect: boolean;
var
  ver, s: string;
  i: integer;
begin
  Result:=false;
  if Assigned(xApp) then
  begin
    xApp.Quit;
    xApp.Disconnect;
    xApp.Free;
    xApp:=nil;
  end;

  Assert(not Assigned(xApp),
    'C3CB866C-435A-4B3C-A1A3-1B4CF60A4D72'#13'XConnect: xApp is not null'#13);

  xApp := TExcelApplication.create(nil);
  if Assigned(xApp) then
  begin
    try
      xApp.ConnectKind := ckNewInstance;
      xApp.Connect;
      Result:=true;
    except
      on E: Exception do
      begin
        ShowMessage('Excel: '+E.Message);
        Result:=false;
      end;
    end;
  end;
end;

procedure TfrmImportSchemaDlg.XDisconnect;
begin
  if Assigned(xApp) then
  begin
    if (xApp.Workbooks.Count > 0) and (not xApp.Visible[xlLCID]) then
    begin
      xApp.WindowState[xlLCID] := TOLEEnum(xlMinimized);
      xApp.Visible[xlLCID] := true;
    end else xApp.Quit;

    xApp.Disconnect;
    xApp.Free;
    xApp:=nil;
  end;
end;

// загрузка схемы из excel-файла
function TfrmImportSchemaDlg.XGetSchemaList(const AFilename: string): boolean;

  // загрузка списка
  procedure LoadList(ASheet: _Worksheet);

    function GetRangeName(const faculty: string): string;
    const
      faculties: array[0..19,0..1] of string =
        (
          ('Металлургический','МТ'),//1
          ('Химико-технологический','ХТ'),
          ('Механико-машиностроительный','ММ'),//3
          ('Электротехнический','ЭТ'),
          ('Строительный','СТ'),//5
          ('Экономики и управления','ФЭУ'),
          ('Физико-технический','ФТ'),//7
          ('Радиотехнический','РТ'),
          ('Строительного материаловедения','СМ'),//9
          ('Теплоэнергетический','ТЭ'),
          ('Гуманитарного образования','ФГО'),//11
          ('Физической культуры','ФФК'),
          ('Военного обучения','ФВО'),//13
          ('Межвузовский центр худ. культуры студентов','МЦ'),
          ('Центр ЦСТО','ЦЦ'),//15
          ('Довузовского образования','ДВЗ'),
          ('Непрерывных технологий образования','НТО'),//17
          ('Дистанционного образования','ДО'),
          ('Центр переподг. незанятых выпускников','ЦПНВ'),//19
          ('Институт образоват. и информ. технологий','ИОИТ')
        );
    var
      i: integer;
    begin
      Result:='';
      for i:=Low(faculties) to High(faculties) do
        if AnsiCompareText(faculty,faculties[i,0])=0 then
        begin
          Result:=faculties[i,1];
          break;
        end;
    end;  // function GetRangeName

  var
    IListRange,ISubRange: ExcelRange;
    pfaculty, pkafedra: PSchemaData;
    i,j: integer;
    srange: string;
  begin
    Assert(Assigned(ASheet),
      '946B5F86-610D-4F59-8E1E-3874C02FFAB8'#13'LoadList: ASheet is nil'#13);

    IDispatch(IListRange):=ASheet.Range['Факультеты',EmptyParam];
    for i:=1 to IListRange.Rows.Count do
    begin
      New(pfaculty);
      pfaculty.parent:=nil;
      pfaculty.id:=0;
      pfaculty.name:=IListRange.Item[i,1].Value;

      srange:=GetRangeName(pfaculty.name);
      if srange<>'' then
      begin
        IDispatch(ISubRange):=ASheet.Range[srange,EmptyParam];
        for j:=1 to ISubRange.Rows.Count do
        begin
          New(pkafedra);
          pkafedra.parent:=pfaculty;
          pkafedra.id:=0;
          pkafedra.name:=ISubRange.Item[j,1].Value;

          FKafedraList.Add(pkafedra);
        end;  // for(j)
      end;

      FFacultyList.Add(pfaculty);
    end;  // for(i)
  end;  // procedure LoadList

var
  xWb: _Workbook;
  xSh: _Worksheet;
  i: integer;
begin
  Assert(FileExists(AFilename),
    '857FC81B-4231-41A0-AEF9-23C3781CC565'#13'XGetSchemaList: file not exists'#13);

  ClearList(FFacultyList);
  ClearList(FKafedraList);

  if XConnect then
  try
    xWb:=xApp.Workbooks.Open(AFilename,EmptyParam,True,EmptyParam,
        EmptyParam,EmptyParam,EmptyParam,EmptyParam,EmptyParam,EmptyParam,
        EmptyParam,EmptyParam,EmptyParam,xlLCID);
    if Assigned(xWb) then
    try
      for i:=1 to xWb.Worksheets.Count do
      begin
        xSh:=(xWb.Worksheets.Item[i] as _Worksheet);
        if AnsiCompareText(xSh.Name,'Списки')=0 then
        begin
          LoadList(xSh);
          break;
        end;
      end;
    finally
      xWb.Close(false,EmptyParam,EmptyParam,xlLCID);
      xWb:=nil;
    end;
  finally
    XDisconnect;
  end;

  Result:=(FFacultyList.Count>0);
end;

procedure TfrmImportSchemaDlg.ImportSchema;

  procedure ImportData;
  var
    i: integer;
    pfaculty,pkafedra: PSchemaData;
    err: boolean;           // признак ошибки
  begin
    err:=false;

    if dmAdmin.Connection.Connected then
    begin
      dmAdmin.Connection.BeginTrans;
      try
        for i:=0 to FFacultyList.Count-1 do
        begin
          pfaculty:=FFacultyList[i];
          try
            pfaculty.id:=dmAdmin.fcl_Create(pfaculty.name);
            if not (pfaculty.id>0) then
              raise Exception.CreateFmt(rsErrAddFaculty,[pfaculty.name,pfaculty.id]);
          except
            on E: Exception do
            begin
              err:=true;
              ShowMessage(E.Message);
              break;
            end;
          end;
        end;  // for(FFacultyList[i])

        if not err then
          for i:=0 to FKafedraList.Count-1 do
          begin
            pkafedra:=FKafedraList[i];
            if pkafedra.parent.id>0 then
            try
              pkafedra.id:=dmAdmin.kaf_Create(pkafedra.parent.id,pkafedra.name);
              if not (pkafedra.id>0) then
                raise Exception.CreateFmt(rsErrAddKafedra,[pkafedra.name,pkafedra.id]);
            except
              on E: Exception do
              begin
                err:=true;
                ShowMessage(E.Message);
                break;
              end;
            end;
          end;  // for(FKafedraList[i])

      finally
        if not err then dmAdmin.Connection.CommitTrans
          else dmAdmin.Connection.RollbackTrans;
      end;
    end;  // if(Connected)
  end;  // procedure ImportData 

begin
  if feFile.Text<>'' then
    if XGetSchemaList(feFile.Text) then ImportData;
end;

end.
