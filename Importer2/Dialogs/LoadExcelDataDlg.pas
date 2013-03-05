{
  Диалог загрузки файлов с раб. планами
  v0.0.1  (29.06.06)
}
unit LoadExcelDataDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ToolWin, DB, ADODB, ExtCtrls, ImgList,
  Excel2000, ActnList, XLSchema;

type
  TLogMsg = (lmInfo=0, lmWarning=1, lmError=2);

  TXLError = class
  private
    FFilename: string;
    FSheet: string;
    FBook: string;
  public
    constructor Create(AFile, ABook, ASheet: string);
    property Filename: string read FFilename;
    property Book: string read FBook;
    property Sheet: string read FSheet;
  end;

  TLoadExcelDlg = class(TForm)
    ToolBar: TToolBar;
    btnSep1: TToolButton;
    btnAdd: TToolButton;
    btnDel: TToolButton;
    lbFiles: TListBox;
    OpenDialog: TOpenDialog;
    lbLog: TListBox;
    Splitter1: TSplitter;
    btnCheck: TToolButton;
    btnOpen: TToolButton;
    InfoPanel: TPanel;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    btnLoad: TToolButton;
    ActionList: TActionList;
    actAdd: TAction;
    actDelete: TAction;
    actCheck: TAction;
    actLoad: TAction;
    actOpen: TAction;
    StatusBar: TStatusBar;
    ImageList: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lbLogDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure lbLogDblClick(Sender: TObject);
    procedure ActionExecute(Sender: TObject);
    procedure ActionUpdate(Sender: TObject);
  private
    { Private declarations }
    FIcons: TBitmap;

    FGroupSet: TDataSet;
    FWorkplanSet: TDataSet;

  private
    FXLSchema: IXLSchema;
    function CellValue(sheet: _Worksheet; const CellName: string): OleVariant;
    function CellByName(const CellName: string): IXLCell;

  private
    procedure ToLog(Msg: string; TypeMsg: TLogMsg=lmInfo; Error: TXLError=nil);
    function XConnect(blog: boolean=true): boolean;
    procedure XDisConnect(blog: boolean=true);

    // проверка листа Excel на ошибки
    function CheckSheet(const xSh: _Worksheet; fname: string; log: boolean=true): integer;
    // проверка файлов Excel раб. планов
    function DoCheckWorkplan(FileList: TStrings): integer;

    // загрузка данных с листа Excel
    function LoadSheet(const xSh: _Worksheet; fname: string): boolean;
    // загрузка данных из книг Excel
    procedure DoLoadWorkplan(FileList: TStrings);

  public
    { Public declarations }
  end;

procedure ShowLoadExcelDlg(XLSchema: IXLSchema; GroupSet, WorkplanSet: TDataSet);

implementation

uses
  OleServer, ActiveX, StrUtils, ComObj, ShellAPI, Math,
  LoadDlg, SStrings, SDBUtils;

const
  xlLCID = LOCALE_USER_DEFAULT;
  wpInsert = 1;

  cInfo = #4;
  cWarning = #5;
  cError = #6;
  cIcoChar: array[TLogMsg] of char = (cInfo, cWarning, cError);

  msgNotFoundCell = 'Не найдено описание ячейки (%s)';

type
  TGroupInfo = record
    grname: string;
    kname: string;
    year: word;
    course: byte;
    studs: byte;
  end;
  PGroupInfo = ^TGroupInfo;

var
  xApp: TExcelApplication;

{$R *.dfm}

procedure ShowLoadExcelDlg(XLSchema: IXLSchema; GroupSet, WorkplanSet: TDataSet);
var
  frmDlg: TLoadExcelDlg;
begin
  frmDlg:=TLoadExcelDlg.Create(Application);
  try
    frmDlg.FXLSchema:=XLSchema;
    frmDlg.FGroupSet:=GroupSet;
    frmDlg.FWorkplanSet:=WorkplanSet;

    frmDlg.ShowModal;
  finally
    FreeAndNil(frmDlg);
  end;
end;

{ TErrorSource }

function CreateXLError(AFile: string; xSh: _Worksheet): TXLError;
begin
  Result:=TXLError.Create(AFile, (xSh.Parent as _Workbook).Name, xSh.Name);
end;

constructor TXLError.Create(AFile, ABook, ASheet: string);
begin
  FFilename:=AFile;
  FBook:=ABook;
  FSheet:=ASheet;
end;

procedure TLoadExcelDlg.FormCreate(Sender: TObject);
begin
//  ImageList.ResourceLoad(rtBitmap, 'BTNS', clFuchsia);
  FIcons:=TBitmap.Create;
  FIcons.LoadFromResourceName(HInstance, 'ICOLOG');
end;

procedure TLoadExcelDlg.FormDestroy(Sender: TObject);
begin
  if Assigned(xApp) then XDisconnect(false);
  FreeAndNil(FIcons);
end;

// добавление сообщение в лог (6.03.2005)
procedure TLoadExcelDlg.ToLog(Msg: string; TypeMsg: TLogMsg=lmInfo; Error: TXLError=nil);
var
  i: integer;
begin
  Assert(Msg<>'',
    '9BF0C5F8-1D22-4BF5-A02C-88CE2D937CD5'#13'ToLog: Empty Msg'#13);

  i:=lbLog.Items.Add(cIcoChar[TypeMsg]+Msg);
  if Assigned(Error) then
    lbLog.Items.Objects[i]:=Error;
  lbLog.Update;
end;

function TLoadExcelDlg.XConnect(blog: boolean=true): boolean;
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
    '4153BADE-B44C-4FCC-9F07-A45ABAE4368F'#13'XConnect: xApp is not null'#13);

  xApp := TExcelApplication.create(nil);
  if Assigned(xApp) then
  begin
    try
      xApp.ConnectKind := ckNewInstance;
      xApp.Connect;
      if blog then
      begin
        ver:=xApp.Application.Version[xlLCID];
        i:=Pos('.',ver);
        if i>0 then s:=Copy(ver,1,i-1) else s:=ver;
        if StrToFloatDef(s,0)>=9 then ToLog(Format(rsExRun,[ver]))
          else ToLog(Format(rsExOldVersion,[ver]),lmWarning);
      end;

    except
      on E: Exception do
      begin
        if blog then ToLog('Excel: '+E.Message, lmError);
        Exit;
      end;
    end;
    Result:=true;
  end;
end;

procedure TLoadExcelDlg.XDisConnect(blog: boolean=true);
begin
  if Assigned(xApp) then
  begin
    if blog then ToLog(Format(rsExQuit,[xApp.Application.Version[xlLCID]]));

    if (xApp.Workbooks.Count > 0) and (not xApp.Visible[xlLCID]) then
    begin
      xApp.WindowState[xlLCID] := TOLEEnum(xlMinimized);
      xApp.Visible[xlLCID] := true;
    end
    else xApp.Quit;

    xApp.Disconnect;
    xApp.Free;
    xApp:=nil;
  end;
end;

// возвращает описатель ячейки
function TLoadExcelDlg.CellByName(const CellName: string): IXLCell;
begin
  Result:=FXLSchema.CellByName(CellName);
  if not Assigned(Result) then
    raise Exception.Create(Format(msgNotFoundCell, [CellName]));
end;

// возвращает значение ячейки
function TLoadExcelDlg.CellValue(sheet: _Worksheet;
  const CellName: string): OleVariant;
var
  cell: IXLCell;
begin
  cell:=CellByName(CellName);
  Result:=sheet.Cells.Item[cell.Row, cell.Coll]
end;


// проверка листа
// возвращает кол-во найден. ошибок
function TLoadExcelDlg.CheckSheet(const xSh: _Worksheet; fname: string; log: boolean=true): integer;
var
  k, j: integer;
  s: string;
{$IF RTLVersion>=15.0}
  IR1,IR2: ExcelRange;
{$ELSE}
  IR1,IR2: Range;
{$IFEND}
  Arr: OleVariant;
  GroupList,GroupCount: TStringList;
  first, cell: IXLCell;
begin
  Result:=0;
  GroupList:=TStringList.Create;
  GroupCount:=TStringList.Create;
  try
    try
      Assert(Assigned(xSh),
        '5CA07B9D-948B-418A-8D81-E69F97405067'#13'CheckSheet: xSh is null'#13);

      if log then ToLog(Format(rsExCheckSheet,[xSh.Name]), lmInfo);

      // Проверка указания кафедры
      if VarToStrDef(CellValue(xSh, 'kname'),'')='' then
      begin
        inc(Result);
        if log then ToLog(rsExErrNoGrpKaf,lmError,CreateXLError(fname,xSh));
      end;

      // Проверка указания семестра обучения
      if StrToIntDef(CellValue(xSh, 'course'),0)=0 then
      begin
        inc(Result);
        if log then ToLog(rsExErrNoSem,lmError,CreateXLError(fname,xSh));
      end;

      //Проверка на совпадение числа групп и числа студентов
      GroupList.Clear;
      GroupCount.Clear;
      GroupList.Text:=StringReplace(Trim(VarToStr(CellValue(xSh,'group'))),',',#13#10,[rfReplaceAll]);
      GroupCount.Text:=StringReplace(Trim(VarToStr(CellValue(xSh,'studs'))),',',#13#10,[rfReplaceAll]);
      if GroupCount.Count<>GroupList.Count then
      begin
        Inc(Result);
        if log then ToLog(rsExErrGrpToCnt, lmError, CreateXLError(fname,xSh));
      end;

      // Проверка префиксов группы
      for k:=0 to GroupList.Count-1 do
      begin
        s:=Trim(GroupList[k]);
        if not IsCharAlpha(s[1]) then
        begin
          inc(Result);
          if log then
            ToLog(Format(rsExErrGrpPrefix,[s]),lmError,CreateXLError(fname,xSh));
        end;
      end;

      // Проверка инфы о дисциплинах
      first:=CellByName('first');
      j:=first.Row;
      while VarToStr(xSh.Cells.Item[j,first.Coll])<>'' do inc(j);

      IDispatch(IR1):=xSh.Cells.Item[first.Row,first.Coll];
      cell:=FXLSchema.findLastCell;
      IDispatch(IR2):=xSh.Cells.Item[j,cell.Coll];
      Arr:=VarArrayCreate([1,j-first.Coll+1,1,cell.Coll],varVariant);
      Arr:=xSH.Range[IR1,IR2].Value;

      for  k:=1 to j-first.Row do
      begin
        // Проверка на пустую строку (есть номер, нет дисциплины)
        if Arr[k,CellByName('sbName').Coll]='' then
        begin
          if log then
            ToLog(rsExEmptySubject, lmWarning);
          continue;
        end;
        // Проверка наличия кода дисциплины
        if Arr[k,CellByName('sbCode').Coll]='' then
        begin
          if log then
            ToLog(Format(rsExErrSbjIndex,[Arr[k,3]]),lmError,CreateXLError(fname,xSh));
          inc(Result);
        end;
        // Проверка указания кафедры
        if Arr[k,CellByName('skname').Coll]='' then
        begin
          if log then
            ToLog(Format(rsExErrSbjKaf, [Arr[k,3]]),lmError,CreateXLError(fname,xSh));
          Inc(Result);
        end;
      end;    // for

      if Result>0 then
        ToLog(Format(rsExSheetWithErr,[xSh.Name]), lmWarning);

    except
      on e: Exception do ToLog('Ошибка программы: '+e.Message, lmError);
    end;

  finally
    GroupCount.Free;
    GroupList.Free;
  end;
end;

procedure TLoadExcelDlg.ActionExecute(Sender: TObject);
var
  i: integer;
  s: string;
begin
  case (Sender as TAction).Tag of

    1:  // add files
      if OpenDialog.Execute then
        for i:=0 to OpenDialog.Files.Count-1 do
          if lbFiles.Items.IndexOf(OpenDialog.Files[i])=-1 then
            lbFiles.Items.Add(OpenDialog.Files[i]);

    2:  // delete files
      lbFiles.Items.Delete(lbFiles.ItemIndex);

    3:  // check
      begin
        Enabled:=false;
        lbLog.Clear;
        StatusBar.SimpleText:='Проверка';
        try
          i:=DoCheckWorkPlan(lbFiles.Items);
          StatusBar.SimpleText:=Format('Количество ошибок: %d', [i]);
        finally
          Enabled:=true;
        end;
      end;

    4:  // load
      begin
        lbLog.Clear;
        StatusBar.SimpleText:='';

//        FGroupSet.DisableControls;
        FWorkplanSet.DisableControls;
        try

          if FWorkplanSet.Filtered then
          begin
            s:=FWorkplanSet.Filter;
            FWorkplanSet.Filtered:=false;
          end
          else s:='';

          DoLoadWorkplan(lbFiles.Items);

          if s<>'' then
          begin
            FWorkplanSet.Filtered:=false;
            FWorkplanSet.Filter:=s;
            FWorkplanSet.Filtered:=true;
          end;

        finally
//          FGroupSet.EnableControls;
          FWorkplanSet.EnableControls;
        end;

      end;  // 4

    5:  // open file
      begin
        i:=lbFiles.ItemIndex;
        if i>=0 then
          ShellExecute(Handle,'open',PAnsiChar(lbFiles.Items[i]),nil,nil,SW_SHOWNORMAL);
      end;

    else
      raise Exception.CreateFmt('Unknown action (Tag=%d)', [TAction(Sender).Tag]);

  end;  // case
end;

procedure TLoadExcelDlg.ActionUpdate(Sender: TObject);
begin
  case (Sender as TAction).Tag of

    2,  // delete files
    5:
      TAction(Sender).Enabled:=(lbFiles.ItemIndex<>-1);

    3,  // check
    4:
      TAction(Sender).Enabled:=(lbFiles.Count>0);

  end;  // case
end;

// Проверка книг (6.03.2005)
// возвращает кол-во найден. ошибок
function TLoadExcelDlg.DoCheckWorkplan(FileList: TStrings): integer;
var
  xWB: _Workbook;
  i,z: integer;
  SaveCursor: TCursor;
  Errors: integer;
begin
  Result:=0;
  
  if FileList.Count>0 then
  begin
    ToLog(rsExCheckBooks, lmInfo);
    saveCursor := Screen.Cursor;
    Screen.Cursor := crHourGlass;
    Errors:=0;

    try

      if XConnect then
      try

        for z := 0 to FileList.Count - 1 do    // Iterate
        begin
          try
            ToLog(Format(rsExCheckBook,[FileList[z]]));

            try
              xWb:=xApp.Workbooks.Open(FileList[z],EmptyParam,true,EmptyParam,
                EmptyParam,EmptyParam,EmptyParam,EmptyParam,EmptyParam,EmptyParam,
                EmptyParam,EmptyParam,EmptyParam,xlLCID);
              //xWb:=xApp.Workbooks.Add(FileList[z],xlLCID);
            except
              ToLog('Ошибка при открытии книги', lmError);
              raise;
            end;

            Assert(Assigned(xWb),
              '6D429166-376D-4605-BBDF-F5A85E2895E6'#13'DoCheckWorkplan: xWb is nil'#13);

            for i:=1 to xWb.Worksheets.Count  do
            begin //идем по всем страницам книги
              if ((xWb.Worksheets.item[i] as _Worksheet).Name='Пример заполнения') or
                 ((xWb.Worksheets.item[i] as _Worksheet).Name='В') or
                 ((xWb.Worksheets.item[i] as _Worksheet).Name='О') then continue;
              if ((AnsiStartsText('Осенний семестр',(xWb.Worksheets.item[i] as _Worksheet).Cells.Item[2,8]))
                or(AnsiStartsText('Весенний семестр',(xWb.Worksheets.item[i] as _Worksheet).Cells.Item[2,8]))) then
              begin
                  Inc(Errors, CheckSheet((xWb.Worksheets.item[i] as _Worksheet), FileList[z]));
//                Inc(Errors, CheckSheet(i));
              end;
            end;  // идем по всем страницам книги

            if Errors>0 then
            begin
              Inc(Result, Errors);
              ToLog(Format(rsExBookWithErr,[xWb.Name]), lmWarning);
              ToLog('Количество ошибок: '+IntToStr(Errors), lmWarning);
            end
            else ToLog(rsExBookNotErr, lmInfo);

            xWB.Close(false, EmptyParam, EmptyParam, xlLCID);
          finally
            xWB:=nil;
            Errors:=0;
          end;

        end; // for filelist.count

      finally
        XDisConnect;
      end;

    finally
      Screen.Cursor := saveCursor;
    end;  // try/finally

  end else ToLog('Ни одного файла не найдено!', lmError);
end;

procedure TLoadExcelDlg.lbLogDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  //DRect, SRect: TRect;
  i, w: integer;
  s: string;
  bmp: TBitmap;
begin
  if Control is TListBox then
    with TListBox(Control) do
    begin
      Canvas.FillRect(Rect);
      s:=Items[index];
      case s[1] of
        cInfo:    i:=0;
        cWarning: i:=1;
        cError:   i:=2;
      end;
      w:=FIcons.Height;
      // рисование иконки
      try
        bmp:=TBitmap.Create;
        bmp.Width:=w;
        bmp.Height:=w;
        BitBlt(bmp.Canvas.Handle, 0, 0, w, w, FIcons.Canvas.Handle, i*w, 0, SRCCOPY);
        bmp.Transparent:=true;
        bmp.TransparentColor:=clFuchsia;
        Canvas.Draw(Rect.Left+2, Rect.Top, bmp);
      finally
        FreeAndNil(bmp);
      end;
      // рисование текста
      s:=Copy(s, 2, Length(s)-1);
      Canvas.TextOut(Rect.Left+w+TabWidth, Rect.Top, s);
    end;
end;

procedure TLoadExcelDlg.lbLogDblClick(Sender: TObject);

  function FindWorkbook(const AName: string; const ABooks: Workbooks): integer;
  var
    i: integer;
  begin
    Result:=-1;
    for i:=1 to ABooks.Count do
      if (ABooks.Item[i] as _Workbook).Name=aName then
      begin
        Result:=i;
        break;
      end;
  end;

  function FindWorksheet(const AName: string; ASheets: Sheets): integer;
  var
    i: integer;
  begin
    Result:=-1;
    for i:=1 to ASheets.Count do
      if (ASheets.Item[i] as _Worksheet).Name=aName then
      begin
        Result:=i;
        break;
      end;
  end;

var
  i: integer;
  XLError: TXLError;
  xWB: _Workbook;
  xSh: _Worksheet;
begin
  if Sender is TListBox then
  begin
    i:=TListBox(Sender).ItemIndex;
    XLError:=TXLError(TListBox(Sender).Items.Objects[i]);
    if Assigned(XLError) then
    begin
      if not Assigned(xApp) then XConnect(false);

      try
        if Assigned(xApp) then
        begin

          xWb:=nil;
          i:=FindWorkbook(XLError.Book,xApp.Workbooks);
          if i<>-1 then xWb:=(xApp.Workbooks.Item[i] as _Workbook)
            else xWB:=xApp.Workbooks.Open(XLError.Filename,EmptyParam,EmptyParam,EmptyParam,
              EmptyParam,EmptyParam,EmptyParam,EmptyParam,EmptyParam,EmptyParam,EmptyParam,
              EmptyParam,EmptyParam,xlLCID);

          Assert(Assigned(xWB),
            '2F639B6F-80F3-409D-B66E-43DDA6D633AC'#13'lbLogDblClick: xWb is nil'#13);

          if Assigned(xWB) then
          begin
            i:=FindWorksheet(XLError.Sheet, xWb.Worksheets);
            if i<>-1 then xSh:=(xWb.Worksheets.Item[i] as _Worksheet);

            if Assigned(xSh) then
            begin
              xSh.Activate(xlLCID);
              xSh.Visible[xlLCID]:=1;
              xApp.Visible[xlLCID]:=true;
            end;
            xWB.Saved[xlLCID]:=true;
          end;

        end; // if xApp<>nil

      except
        XDisconnect(false);
      end;
    end; // if XLError<>nil
  end;
end;

// загрузка данных листа
// false - ошибка при загрузке
function TLoadExcelDlg.LoadSheet(const xSh: _Worksheet; fname: string): boolean;
var
  Arr: OleVariant;

  iLoads: TLoads;//array[0..2,0..2] of integer; // аудитор. нагрузка [всего-п/с, занятие]
  k: integer;

  // определение аудит. нагрузки
  // false - неопределно
  function GetLoad(gr, sbj: string; weeks: byte): boolean;
  var
    ps, l: integer;
    icoord: array[1..2] of integer;
  begin
    Result:=true;

    ZeroMemory(@iLoads, sizeof(TLoads));

    iLoads[1,0]:=StrToIntDef(Arr[k,CellByName('lec1').Coll],0);  // лекции 1 п/с
    iLoads[2,0]:=StrToIntDef(Arr[k,CellByName('lec2').Coll],0);  // лекции 2 п/с

    // если для прак. и лаб. занятий отдельные колонки
    if not (CellByName('prac1').equalsCell(CellByName('lab1')) and
       CellByName('prac2').equalsCell(CellByName('lab2'))) then
    begin
      iLoads[1,1]:=StrToIntDef(Arr[k,CellByName('prac1').Coll],0);
      iLoads[1,2]:=StrToIntDef(Arr[k,CellByName('lab1').Coll],0);
      iLoads[2,1]:=StrToIntDef(Arr[k,CellByName('prac2').Coll],0);
      iLoads[2,2]:=StrToIntDef(Arr[k,CellByName('lab2').Coll],0);
    end
    else
    begin
      icoord[1]:=CellByName('prac1').Coll;
      icoord[2]:=CellByName('prac2').Coll;

       // доступно часов на кажд. тип занятия
      iLoads[0,1]:=Round(2*StrToFloatDef(Arr[k,CellByName('practice').Coll],0)/weeks);
      iLoads[0,2]:=Round(2*StrToFloatDef(Arr[k,CellByName('lab').Coll],0)/weeks);

      // неопределенность: для кажд. п/с присутствуют как практики, так и лаб.
      // невозможно определить часы на конкретном п/с
      if iLoads[0,1]*iLoads[0,2]*StrToIntDef(Arr[k,CellByName('prac1').Coll],0)*StrToIntDef(Arr[k,CellByName('prac2').Coll],0)<>0 then
      begin
        if not ShowLoadDlg(gr, sbj, iLoads) then Result:=false;
      end  // if неопределенность
      else
        for l:=1 to 2 do     // 1-prct, 2-lab
          for ps:=1 to 2 do  // 1-1p/s 2-2p/s
            iLoads[ps,l]:=Min(StrToIntDef(Arr[k,icoord[ps]],0), iLoads[0,l]);
    end;
  end;  // function GetLoad

  // извлечение инф-ции о группах с листа
  function GetGroups(AGroupList: TList): boolean;
  var
    list: TStringList;
    pgroup: PGroupInfo;
    i: integer;
  begin
    Result:=true;

    list:=TStringList.Create;
    try

      try
        list.Text:=StringReplace(Trim(VarToStr(CellValue(xSh,'group'))),
            ',',#13#10,[rfReplaceAll]);
        for i:=0 to list.Count-1 do
        begin
          New(pgroup);
          pgroup.grname:=Trim(list[i]);
          pgroup.kname:=Trim(VarToStr(CellValue(xSh, 'kname')));
          pgroup.course:=(StrToIntDef(CellValue(xSh,'course'),1)+1) div 2;
          pgroup.year:=StrToInt(CellValue(xSh, 'eduYear'));
          pgroup.studs:=0;
          AGroupList.Add(pgroup);
        end;

        list.Text:=StringReplace(Trim(VarToStr(CellValue(xSh,'studs'))),
            ',',#13#10,[rfReplaceAll]);
        if list.Count=AGroupList.Count then
          for i:=0 to AGroupList.Count-1 do
            PGroupInfo(AGroupList[i]).studs:=StrToIntDef(list[i],0);
      except
        Result:=false;
      end;

    finally
      list.Free;
    end;
  end;  // procedure GetGroups

  procedure InsertGroup(PGroup: PGroupInfo);
  begin
    if not FGroupSet.Locate('grName',PGroup.grname,[loCaseInsensitive]) then
    begin
      FGroupSet.Append;
      FGroupSet.FieldByName('RecState').Value:=0;
      FGroupSet.FieldByName('grName').Value:=PGroup.grname;
      FGroupSet.FieldByName('kName').Value:=PGroup.kname;
      FGroupSet.FieldByName('course').Value:=PGroup.course;
      FGroupSet.FieldByName('ynum').Value:=PGroup.year;
      FGroupSet.FieldByName('studs').Value:=PGroup.studs;
      FGroupSet.FieldByName('Flags').Value:=0;
      FGroupSet.Post;
    end;
  end;  // procedure InsertGroup

  // удаление рабочего плана (group,sem)
  procedure DeleteWorkplan(PGroup: PGroupInfo; ASem: byte);
  begin
    if FGroupSet.Locate('grName',PGroup.grname,[loCaseInsensitive]) then
    begin
      FWorkplanSet.Filtered:=false;
      FWorkplanSet.Filter:=Format('[grName]=''%s'' and [Sem]=%d',[PGroup.grname,ASem]);
      FWorkplanSet.Filtered:=true;
      FWorkplanSet.First;
      while not FWorkplanSet.Eof do FWorkplanSet.Delete;
      FWorkplanSet.Filtered:=false;
    end;
  end;  // procedure DeleteWorkplan

var
  GroupList: TList;
//  year: word;
  sem: byte;
  wp1, wp2: byte;

  i, j: integer;
  pgroup: PGroupInfo;
  flags: word;
//  s: string;

{$IF RTLVersion>=15.0}
  IR1,IR2: ExcelRange;
{$ELSE}
  IR1,IR2: Range;
{$IFEND}
  Error: boolean;
  first, cell: IXLCell;

begin
  Assert(Assigned(xSh),
    'AE238ABC-025B-40F3-A203-3E940E602DEB'#13'LoadSheet: xSh is null'#13);

  Error:=false;
  GroupList:=TList.Create;
  try
      ToLog(Format(rsExGetSheetData,[xSh.Name]), lmInfo);

      if GetGroups(GroupList) then
      begin

        if AnsiStartsText('Осенний семестр',VarToStr(CellValue(xSh,'sem'))) then
          sem:=1
        else sem:=2;

        first:=CellByName('first');
        j:=first.Row;
        while VarToStr(xSh.Cells.Item[j,first.Coll])<>'' do inc(j);

        cell:=CellByName('wp1');
        wp1:=StrToIntDef(VarToStr(xSh.Cells.Item[j+cell.Row,cell.Coll]),8);
        cell:=CellByName('wp2');
        wp2:=StrToIntDef(VarToStr(xSh.Cells.Item[j+cell.Row,cell.Coll]),8);

        cell:=FXLSchema.findLastCell;
        IDispatch(IR1):=CellValue(xSh, 'first');
        IDispatch(IR2):=xSh.Cells.Item[j,cell.Coll];
        Arr:= VarArrayCreate([1,j-first.Coll+1,1,cell.Coll],varVariant);
        Arr:= xSH.Range[IR1,IR2].Value;

        // Добавляем данные из плана
        for i:=0 to GroupList.Count-1 do
        begin
          pgroup:=PGroupInfo(GroupList[i]);

          InsertGroup(pgroup);

          flags:=FGroupSet.FieldByName('Flags').AsInteger;
          if (flags and sem)=sem then
            if MessageDlg(Format(rsExExistsData,[pgroup.grname, csSemester[sem]]), mtConfirmation,
                [mbYes, mbNo], 0)=mrYes then DeleteWorkplan(pgroup,sem)
            else continue;


          FWorkplanSet.Filtered:=false;
          for  k:=1 to j-first.Row do
          begin
            cell:=CellByName('sbName');
            if Arr[k,cell.Coll]='' then
            begin
              ToLog(rsExEmptySubject, lmWarning);
              continue;
            end;

            if GetLoad(Format('%s (%s)', [pgroup.grname, csSemester[sem]]), Arr[k,cell.Coll], wp1+wp2) then
            begin
              FWorkplanSet.Append;

              FWorkplanSet.FieldByName('Sem').Value:=sem;
              FWorkplanSet.FieldByName('grName').Value:=pgroup.grname;

              FWorkplanSet.FieldByName('Lec1').Value:=iLoads[1,0];
              FWorkplanSet.FieldByName('Prc1').Value:=iLoads[1,1];
              FWorkplanSet.FieldByName('Lab1').Value:=iLoads[1,2];
              FWorkplanSet.FieldByName('Lec2').Value:=iLoads[2,0];
              FWorkplanSet.FieldByName('Prc2').Value:=iLoads[2,1];
              FWorkplanSet.FieldByName('Lab2').Value:=iLoads[2,2];

              FWorkplanSet.FieldByName('sbCode').Value:=Arr[k,CellByName('sbCode').Coll];
              FWorkplanSet.FieldByName('sbName').Value:=Arr[k,CellByName('sbName').Coll];
              FWorkplanSet.FieldByName('TotalHLP').Value:=StrToIntDef(Arr[k,CellByName('totalHLP').Coll],0);
              FWorkplanSet.FieldByName('TotalAHLP').Value:=StrToIntDef(Arr[k,CellByName('totalAHLP').Coll],0);
              FWorkplanSet.FieldByName('Compl').Value:=StrToIntDef(Arr[k,CellByName('Compl').Coll],0);
              FWorkplanSet.FieldByName('Kp').Value:=StrToIntDef(Arr[k,CellByName('Kp').Coll],0);
              FWorkplanSet.FieldByName('Kr').Value:=StrToIntDef(Arr[k,CellByName('Kr').Coll],0);
              FWorkplanSet.FieldByName('Rg').Value:=StrToIntDef(Arr[k,CellByName('Rg').Coll],0);
              FWorkplanSet.FieldByName('Cr').Value:=StrToIntDef(Arr[k,CellByName('Cr').Coll],0);
              FWorkplanSet.FieldByName('Hr').Value:=StrToIntDef(Arr[k,CellByName('Hr').Coll],0);
              FWorkplanSet.FieldByName('Koll').Value:=StrToIntDef(Arr[k,CellByName('Koll').Coll],0);
              FWorkplanSet.FieldByName('Z').Value:=Length(VarToStr(Arr[k,CellByName('Z').Coll]));
              FWorkplanSet.FieldByName('E').Value:=Length(VarToStr(Arr[k,CellByName('E').Coll]));
              FWorkplanSet.FieldByName('kName').Value:=Arr[k,CellByName('skname').Coll];

              FWorkplanSet.FieldByName('WP1').Value:=wp1;
              FWorkplanSet.FieldByName('WP2').Value:=wp2;

              FWorkplanSet.Post;
            end
            else
            begin
              Error:=true;
              ToLog(rsExUserAbort, lmError);
              Break;
            end;

          end;    // for (k)

          FGroupSet.Edit;
          flags:=(flags or sem);
          FGroupSet.FieldByName('Flags').Value:=flags;
          FGroupSet.Post;

          if Error then Break;
        end;    // for (groups[i])

      end // if
      else
      begin
        Error:=true;
        ToLog('Ошибка при извлечении данных о группе',
            lmError, CreateXLError(fname,xSh));
      end;

      if Error then
        ToLog(Format(rsExErrGetSheet,[xSh.Name]), lmError);

  finally
    for i:=0 to GroupList.Count-1 do
      Dispose(PGroupInfo(GroupList[i]));
    GroupList.Free;
  end;

  Result:=not Error;
end; // function ImportSheet


// загрузка рабочих планов из Excel
procedure TLoadExcelDlg.DoLoadWorkplan(FileList: TStrings);
var
  xWB: _Workbook;
  xSh: _Worksheet;
  i,z: integer;
  SaveCursor: TCursor;
  Err: boolean;          // признак ошибки

  function isDataSheet(sheet: _Worksheet): boolean;
  var
    s: string;
  begin
    if (sheet.Name='Пример заполнения') or (sheet.Name='В') or (sheet.Name='О') then
      Result:=false
    else
    begin
      s:=CellValue(sheet, 'sem');
      Result:=AnsiStartsText('Осенний семестр',s)
          or AnsiStartsText('Весенний семестр',s);
    end;
  end;

begin
  Err:=false;

  if FileList.Count>0 then
  begin
    ToLog(rsExLoadData, lmInfo);
    saveCursor := Screen.Cursor;
    Screen.Cursor := crHourGlass;

    try
      if XConnect then
      try

        for z := 0 to FileList.Count - 1 do    // Iterate
        begin

          try

            ToLog(Format(rsExOpenBook,[FileList[z]]));
            try
              xWb:=xApp.Workbooks.Open(FileList[z],EmptyParam,True,EmptyParam,
                EmptyParam,EmptyParam,EmptyParam,EmptyParam,EmptyParam,EmptyParam,
                EmptyParam,EmptyParam,EmptyParam,xlLCID);
            except
              Err:=true;
              ToLog(rsExErrOpenBook, lmError);
              raise;
            end;

            Assert(Assigned(xWb),
              '216D00EE-929B-4B0A-8051-3BBC3B66D6A1'#13'DoLoadWorkplan: xWb is nil'#13);

            for i:=1 to xWb.Worksheets.Count  do
            begin
              xSh:=(xWb.Worksheets.item[i] as _Worksheet);

              Assert(Assigned(xSh),
                '894715A1-03BA-4630-B6DE-9821FBF09BD9'#13);

              try
                if isDataSheet(xSh) then
                begin

                  // проверка листа
                  if CheckSheet(xSh, FileList[z], false)=0 then
                  begin
                    Err:=not LoadSheet(xSh, FileList[z]);
                  end
                  else
                  begin
                    Err:=true;
                    ToLog(Format(rsExSheetWithErr,[xSh.Name]), lmWarning);
                  end;

                end;
              finally
                xSh:=nil;
              end;

              if Err then break;
            end;  // идем по всем страницам книги

            if Err then ToLog(Format(rsExErrGetBook,[xWb.Name]), lmError)
              else ToLog(Format(rsExBookComplete,[xWb.Name]));

            xWB.Close(false, EmptyParam, EmptyParam, xlLCID);

          finally
            xWB:=nil;
          end;

          if Err then break;

        end; // for filelist.count

        if Err then DeleteTemporary(FGroupSet)
          else CommitTemporary(FGroupSet);

      finally
        XDisConnect;
      end;

    finally
      Screen.Cursor := saveCursor;
    end;  // try/finally

  end
  else MessageDlg('Ни одного файла не найдено.', mtWarning, [mbOk],0);
end;

end.
