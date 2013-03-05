{
  Диалог экспорта заявок
  v0.0.5 (11/09/06)
}
unit ExportDeclare;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons, Excel2000, OleServer, ActiveX,
  SClasses;

type
  TfrmExportDeclareDlg = class(TForm)
    InfoPanel: TPanel;
    Label1: TLabel;
    GroupBox1: TGroupBox;
    lblFile: TLabel;
    btnOpen: TSpeedButton;
    Label2: TLabel;
    lblSem: TLabel;
    btnOk: TButton;
    btnCancel: TButton;
    Bevel1: TBevel;
    Label3: TLabel;
    cbType: TComboBox;
    cbKafedra: TComboBox;
    SaveDialog: TSaveDialog;
    procedure OnBtnsClick(Sender: TObject);
    procedure ComboDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
  private
    { Private declarations }
    xApp: TExcelApplication;
    function XConnect: boolean;
    procedure XDisconnect;
    function XExportDeclares: boolean;

  public
    { Public declarations }
  end;

procedure DoExportDeclare(const skafedra: string = '');

implementation

uses
  TimeModule, DB, ADODB, SUtils, SStrings;

const
  xlLCID = LOCALE_USER_DEFAULT;

{$R *.dfm}

// экспорт заявок с выбором кафедры
procedure DoExportDeclare(const skafedra: string = '');
var
  frmDlg: TfrmExportDeclareDlg;
  s: string;
  list: TStringList;
begin

  list:=TStringList.Create;
  try
    if dmMain.GetPerformKafList(list) then
    begin
      frmDlg:=TfrmExportDeclareDlg.Create(Application);
      try
        with frmDlg do
        begin
          cbKafedra.Items.AddStrings(list);
          if skafedra<>'' then cbKafedra.ItemIndex:=cbKafedra.Items.IndexOf(skafedra)
            else cbKafedra.ItemIndex:=0;
          if dmMain.Sem=1 then s:='Осенний' else s:='Весенний';
          lblSem.Caption:=SysUtils.Format('%s  (%d п/с)', [s,dmMain.PSem]);

          if ShowModal=mrOk then XExportDeclares;
        end; // with
      finally
        frmDlg.Free;
        frmDlg:=nil;
      end;
    end  // if(get list)
    else MessageDlg(rsErrKafedraList,mtError,[mbOK],0);
  finally
    list.Free;
    list:=nil;
  end;
end;

procedure TfrmExportDeclareDlg.OnBtnsClick(Sender: TObject);
var
  s: string;
begin
  s:=GetValue(cbKafedra.Items[cbKafedra.ItemIndex]);
  SaveDialog.FileName:=SUtils.FixFileName(s);
  if SaveDialog.Execute then
  begin
    s:=SaveDialog.FileName;
    lblFile.Caption:=s;
    lblFile.Hint:=s;
    btnOk.Enabled:=true;
  end;
end;

function TfrmExportDeclareDlg.XConnect: boolean;
begin
  Result:=false;
  xApp := TExcelApplication.create(nil);
  if Assigned(xApp) then
  begin
    try
      xApp.ConnectKind := ckNewInstance;
      xApp.Connect;
    except
      on E: Exception do
      begin
        E.Message:='Excel: '+E.Message;
        Exit;
      end;
    end;
    Result:=true;
  end;
end;

procedure TfrmExportDeclareDlg.XDisconnect;
begin
  if Assigned(xApp) then
  begin
    if (xApp.Workbooks.Count > 0) and (not xApp.Visible[xlLCID]) then
    // не закрывайте не свои книги
    begin
      xApp.WindowState[xlLCID] := TOLEEnum(xlMinimized);
      xApp.Visible[xlLCID] := true;
    end
    else xApp.Quit;
    xApp.Disconnect;
    FreeAndNil(xApp);
  end;
end;

function TfrmExportDeclareDlg.XExportDeclares: boolean;
var
  skafedra: string;    // kid=kName
  xltfile: string;     // файл шаблона

  OldCursor: TCursor;

  iSize: integer;                   // размер sqlArr
  sqlArr: array of array of string; // 2х мер. массив - [row,col]
  outArr: OleVariant;               // 2х мер. массив - таблица для Excel


  // объединение один. значений
  function MergeValue(index, col: integer): boolean;
  var
    p, start: PChar;
    s, s1: string;
    first, merge: boolean;
  begin
    p:=Pointer(sqlArr[index, col]);
    if p<>nil then
    begin
      merge:=true;
      first:=true;
      while p^ <> #0 do
      begin
        start:=p;
        while not (p^ in [#0, #10, #13]) do Inc(p);
        if first then
        begin
          SetString(s1, start, p-start);
          first:=false;
        end
        else
        begin
          SetString(s, start, p-start);
          if s<>s1 then
          begin
            merge:=false;
            break;
          end;
        end;
        if p^ = #13 then Inc(p);
        if p^ = #10 then Inc(p);
      end; // while p^<>#0
      if merge then sqlArr[index, col]:=s1;
    end; // if p<>nil
    Result:=merge;
  end;


  // заменяет 0 на ''
  function FreeZero(Value: string): string;
  begin
    if Value<>'0' then Result:=Value
      else Result:='';
  end;

  // загрузка данных (из запроса в массив sqlArr)
  // возвращает кол-во записей
  function LoadData: integer;

    // добавляет в конец массива нов. запись
    procedure NewRec(const Fields: TFields);
    var
      l: integer;
      index: integer;
    begin
      index:=High(sqlArr);
      SetLength(sqlArr[index], Fields.Count);
      for l:=0 to Fields.Count-1 do
        sqlArr[index,l]:=Fields[l].AsString;
    end;  // procedure NewRec

    // проверка на возможность объед-я строк
    function IsEqual(index: integer; const Fields: TFields): boolean;
    var
      l: integer;
    begin
      Result:=true;
      for l:=6 to Fields.Count-1 do
        if sqlArr[index,l]<>Fields[l].AsString then
        begin
          Result:=false;
          Break;
        end;
    end;  // function IsEqual

  var
    ds: TADODataSet;
    //Adding: boolean;

  begin
    Result:=0;

    ds:=CreateDataSet(
        dmMain.wp_ExportDeclare(GetId(skafedra),cbType.ItemIndex+1));
    if Assigned(ds) then
    try
      if not ds.Eof then
      begin
        Result:=1;
        // создание 2мер. массива под записи
        SetLength(sqlArr, Result);

        // запопление массива
        NewRec(ds.Fields);
        ds.Next;
        while not ds.Eof do
        begin

          if (not ds.Fields[0].IsNull) and
             (ds.Fields[0].AsString=sqlArr[Result-1,0]) and
             IsEqual(Result-1, ds.Fields) then
          begin
            sqlArr[Result-1,3]:=sqlArr[Result-1,3]+#10+ds.Fields[3].AsString;
            sqlArr[Result-1,4]:=sqlArr[Result-1,4]+#10+ds.Fields[4].AsString;
            sqlArr[Result-1,5]:=sqlArr[Result-1,5]+#10+ds.Fields[5].AsString;
          end
          else
          begin
            MergeValue(Result-1, 5);          // ?
            inc(Result);
            SetLength(sqlArr, Result);
            NewRec(ds.Fields);
          end;

          ds.Next;
        end;
        ds.Close;
      end  // if not ds.eof
      else ShowMessage('Нет ни одной заявки на кафдере');

    finally
      ds.Free;
      ds:=nil;
    end;
  end;

  // создание выход. массива для Excel (+ копирование из sqlArr)
  procedure CreateExcelData;

    // копир-е из врем. массива в выходной
    procedure CopyRec(n, dest, src: integer);
    begin
      outArr[dest, 0]:=n;
      outArr[dest, 1]:=sqlArr[src,1];     // код дисциплины
      outArr[dest, 2]:=sqlArr[src,2];     // назв. дисциплины
      outArr[dest, 3]:=sqlArr[src,5];     // всего по уч. плану
      outArr[dest, 4]:=sqlArr[src,6];     // всего лекций по уч. плану
      outArr[dest, 5]:=sqlArr[src,7];     // пройдено ранее
      outArr[dest, 6]:=Format('=H%d*(I%d+K%d)+L%d*(M%d+O%d)', [dest+9,dest+9,dest+9,dest+9,dest+9,dest+9]); // планир. на тек. семестр (calc)
      outArr[dest, 7]:=sqlArr[src,8];     // недель в 1 п/семестре
      outArr[dest, 8]:=sqlArr[src,9];     // лекц. часов в неделю
      outArr[dest, 9]:='/';
      outArr[dest, 10]:=sqlArr[src,10];   // практ. часов в неделю
      outArr[dest, 11]:=sqlArr[src,11];   // недель во 2 п/семестре
      outArr[dest, 12]:=sqlArr[src,12];   // лекц. часов в неделю
      outArr[dest, 13]:='/';
      outArr[dest, 14]:=sqlArr[src,13];   // практ. часов в неделю
      outArr[dest, 15]:=Format('=H%d*I%d+L%d*M%d', [dest+9,dest+9,dest+9,dest+9]);  // лекции (calc)
      outArr[dest, 16]:=sqlArr[src,14];   // практ. занятия
      outArr[dest, 17]:=sqlArr[src,15];   // лаб. занятия
      outArr[dest, 18]:=Null;             // номер потока
      outArr[dest, 19]:=sqlArr[src,3];    // номер группы
      outArr[dest, 20]:=sqlArr[src,4];    // число студентов

      outArr[dest, 21]:=FreeZero(sqlArr[src,16]);   // курс. проекты
      outArr[dest, 22]:=FreeZero(sqlArr[src,17]);   // курс. работы
      outArr[dest, 23]:=FreeZero(sqlArr[src,18]);   // расч.-граф. работы
      outArr[dest, 24]:=FreeZero(sqlArr[src,19]);   // контр. работы
      outArr[dest, 25]:=FreeZero(sqlArr[src,20]);   // дом. работы
      outArr[dest, 26]:=FreeZero(sqlArr[src,21]);   // коллоквиумы
      outArr[dest, 27]:=FreeZero(sqlArr[src,22]);   // зачет
      outArr[dest, 28]:=FreeZero(sqlArr[src,23]);   // экзамен
    end;  // procedure CopyRec

  var
    n: integer;
    i: integer;
  begin
    // копир-е врем. массива в вых. массив
    outArr:=VarArrayCreate([0, iSize-1, 0, 28], varVariant);
    n:=1;
    CopyRec(n, 0, 0);
    for i:=1 to iSize-1 do
    begin
      if (sqlArr[i,0]<>sqlArr[i-1,0]) or (sqlArr[i][0]='') then n:=n+1;
      CopyRec(n, i, i);
    end;
  end; // procedure CreateExcelData

  // экспорт выход. массива в Excel
  procedure ExportExcelData(const sXltFile, sOutFile: string);
  var
    i,j: integer;
{$IF RTLVersion>=15.0}
    IR1,IR2: ExcelRange;
{$ELSE}
    IR1,IR2: Range;
{$IFEND}
    xWB: _Workbook;
    xSh: _Worksheet;
  begin
    Assert(sXltFile<>'',
      'FC08694A-1E56-4C9F-BD11-13D72854F079'#13'ExportExcelData: sXltFile is null'#13);
    Assert(sOutFile<>'',
      '1DD2AD46-C689-43E3-8D34-517E2183CA70'#13'ExportExcelFile: sOutFile is null'#13);

    XConnect;
    try
      xWb:=xApp.Workbooks.Add(sXltFile,xlLCID);
      try
        xSh:=xWb.Worksheets.Item['Declare'] as _Worksheet;
        try
          // подготовка листа
          IDispatch(IR1):=xSh.Cells.Item[1, 'A'];
          if dmMain.Sem=1 then
            IR1.Value:='Заявка на учебную нагрузку в осеннем семестре для кафедры'
          else
            IR1.Value:='Заявка на учебную нагрузку в весеннем семестре для кафедры';
          xSh.Cells.Item[2, 'A'].Value:=GetValue(skafedra);

          // добавление строк под массив
          IDispatch(IR1):=xSh.Cells.Item[9,'A'];
          IDispatch(IR2):=xSh.Cells.Item[9,'AC'];
          for i:=0 to iSize-2 do
            xSh.Range[IR1, IR2].Insert(xlShiftDown);

          // вставка выход. массива в Excel лист
          IDispatch(IR1):=xSh.Cells.Item[9,'A'];
          IDispatch(IR2):=xSh.Cells.Item[8+iSize,'AC'];
          xSH.Range[IR1,IR2].Value:=outArr;

          // форматирование Excel листа
          with xSh.Range[IR1, IR2] do
          begin
            WrapText:=true;
            Orientation:=0;
            AddIndent:=false;
            ShrinkToFit:=false;
            MergeCells:=false;
            if Rows.Count>1 then
              Borders.Item[xlInsideHorizontal].LineStyle:=xlContinuous;
            Rows.AutoFit();
          end;
          with xSh.Range[IR1, IR2].Font do
          begin
            Name:='Arial';
            Size:=9;
            Strikethrough:=False;
            Superscript:=False;
            Subscript:=False;
            OutlineFont:=False;
            Shadow:=False;
            Underline:=xlUnderlineStyleNone;
            ColorIndex:=xlAutomatic;
          end;

          // форматирование ячеек для потоков с раз. дисциплинами
          xApp.DisplayAlerts[xlLCID]:=false;
          i:=Low(sqlArr)+1;
          while i<=High(sqlArr) do
          begin
            if (sqlArr[i,0]=sqlArr[i-1,0]) and (sqlArr[i,0]<>'') then
            begin
              for j:=i to High(sqlArr) do
                if sqlArr[j,0]<>sqlArr[i,0] then break;
              IDispatch(IR1):=xSh.Cells.Item[8+i, 'A'];
              IDispatch(IR2):=xSh.Cells.Item[8+j, 'A'];
              xSh.Range[IR1, IR2].Merge(False);
              IDispatch(IR2):=xSh.Cells.Item[8+j, 'AC'];
              xSh.Range[IR1, IR2].Borders[xlInsideHorizontal].LineStyle:=xlLineStyleNone;
              i:=j;
            end
            else i:=i+1;
          end;
          xApp.DisplayAlerts[xlLCID]:=true;

        finally
          xSh:=nil;
        end;
        xWB.Close(true, sOutFile, EmptyParam, xlLCID);
      finally
        xWb:=nil;
      end;

    finally
      XDisConnect;
    end;  // try/finally}

  end;  // procedure ExportExcelData

var
  i: integer;

begin

  skafedra:=cbKafedra.Items[cbKafedra.ItemIndex];

  xltfile:=BuildFullName('declares.xlt');
  if xltfile<>'' then
  begin
    iSize:=LoadData();
    if iSize>0 then
    try

      OldCursor := Screen.Cursor;
      Screen.Cursor := crHourGlass;
      try
        CreateExcelData;
        ExportExcelData(xltfile, lblFile.Caption);
      finally
        VarClear(outArr);
        Screen.Cursor := OldCursor;
      end;

    finally
      // освобождение памяти
      for i:=Low(sqlArr) to High(sqlArr) do SetLength(sqlArr[i], 0);
      SetLength(sqlArr, 0);
    end;
  end
  else ShowMessageFmt(rsExNotFoundXlt, ['declares.xlt']);

end;

procedure TfrmExportDeclareDlg.ComboDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  FCanvas: TCanvas;
  s: string;
begin
  if Control is TComboBox then
  begin
    FCanvas:=TComboBox(Control).Canvas;
    TControlCanvas(FCanvas).UpdateTextFlags;

    if bDebugMode then s:=TComboBox(Control).Items[Index]
      else s:=SUtils.GetValue(TComboBox(Control).Items[Index]);

    FCanvas.FillRect(Rect);
    FCanvas.TextOut(Rect.Left + 2, Rect.Top, s);
  end;
end;

end.
