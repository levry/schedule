{
  Экспорт отчетов в Excel
  v0.0.3  (21.06.06)
}
unit ExcelReport;

interface

uses
  ADODb,
  STypes, SExams;

procedure ExportExamList(AYear: WORD; ASem: BYTE; ADataSet: TADODataSet;
    const AFileName, AXLTFile: string);
procedure ExportExamKafedra(AYear: WORD; ASem: BYTE; const AKafedra: string;
    ADataSet: TADODataSet; const AFileName, AXLTFile: string);
procedure ExportExamAuditory(AYear: WORD; ASem: BYTE; const AKafedra: string;
    APeriod: TDatePeriod; AXMType: TXMType; ADataSet: TADODataSet;
    const AFileName, AXLTFile: string);

implementation

uses
  Windows, Excel2000, OleServer, ActiveX, SysUtils, Dialogs,
  Types, DateUtils, Classes, Variants, StrUtils, Math,
  SUtils, SStrings, XReport, DB;

const
  xlLCID = LOCALE_USER_DEFAULT;

type
  TExamItem = record
    xmtime: TDateTime;
    number: integer;
    grName: string;
    Initials: string;
    sbName: string;
    aName: string;
  end;
  PExamItem = ^TExamItem;



procedure ClearList(AList: TList);
var
  i: integer;
begin
  for i:=0 to AList.Count-1 do Dispose(AList[i]);
  AList.Clear;
end;

function CompareExams(Item1, Item2: Pointer): integer;
begin
  Result:=CompareDate(PExamItem(Item1).xmtime,PExamItem(Item2).xmtime);
  if Result=EqualsValue	then
    Result:=AnsiCompareText(PExamItem(Item1).grName, PExamItem(Item2).grName);
end;

// экспорт списка экзаменов факультета
procedure ExportExamList(AYear: WORD; ASem: BYTE; ADataSet: TADODataSet;
    const AFileName, AXLTFile: string);

  procedure LoadList(AList: TList);
  var
    pexam: PExamItem;
  begin
    pexam:=nil;

    ADataSet.DisableControls;

    ADataSet.First;
    while not ADataSet.Eof do
    begin
      New(pexam);
      pexam.xmtime:=ADataSet.FieldByName('xmtime').AsDateTime;
      pexam.grName:=ADataSet.FieldByName('grName').AsString;
      pexam.Initials:=ADataSet.FieldByName('Initials').AsString;
      pexam.sbName:=ADataSet.FieldByName('sbName').AsString;
      pexam.aName:=ADataSet.FieldByName('aName').AsString;
      AList.Add(pexam);

      ADataSet.Next;
    end;

    ADataSet.First;
    ADataSet.EnableControls;

    AList.Sort(CompareExams);
  end;  // procedure LoadList

  procedure FillArray(var Arr: OleVariant; AList: TList);
  var
    i, num: integer;
    pexam: PExamItem;
    xmdate: TDateTime;
    sdate, stime: string;
  begin
    xmdate:=0;
    num:=1;

    for i:=0 to AList.Count-1 do
    begin
      pexam:=AList[i];
      if CompareDate(pexam.xmtime, xmdate)=EqualsValue then
      begin
        sdate:='';
        inc(num);
      end
        else
        begin
          xmdate:=pexam.xmtime;
          num:=1;
          DateTimeToString(sdate,'DD.MM.YYYY',pexam.xmtime);
        end;

      DateTimeToString(stime,'HH:nn',pexam.xmtime);
      Arr[i,0]:=sdate;
      Arr[i,1]:=num;
      Arr[i,2]:=stime;
      Arr[i,3]:=pexam.grName;
      Arr[i,4]:=pexam.Initials;
      Arr[i,5]:=pexam.sbName;
      Arr[i,6]:=pexam.aName;
    end;
  end;  // procedure FillArray

const
  TITLE = 'Расписание экзаменов %s экзаменационной сессии %d/%d гг.';

var

  list: TList;
  xlArray: OleVariant;  // массив [row,col]

  xltfile: string;

  xApp: TExcelApplication;
  xWb: _Workbook;
  xSh: _Worksheet;
  IR1, IR2: ExcelRange;

  frow,fcol: integer;
  lrow,lcol: integer;
  s: string;
  d: TDateTime;
  i: integer;

begin
  if not ADataSet.Active then exit;

  xltfile:=BuildFullName(AXLTFile);

  if xltfile='' then
  begin
    ShowMessageFmt(rsExNotFoundXlt,[AXLTFile]);
    Exit;
  end;

  if not ADataSet.IsEmpty then
  begin
    list:=TList.Create;
    try
      LoadList(list);
      xlArray:=VarArrayCreate([0,list.Count-1,0,6], varOleStr);
      FillArray(xlArray, list);

      xApp:=TExcelApplication.Create(nil);
      try

        if XConnect(xApp) then
        begin

          xSh:=XOpenSheet(xApp,xltfile,'xmfaculty',true);
          if Assigned(xSh) then
          begin

            // заполнение заголовка
            IDispatch(IR1):=xSh.Range['Title',EmptyParam];
            if ASem=1 then s:='осенней' else s:='весенней';
            IR1.Value:=Format(TITLE, [s,AYear,AYear+1]);

            // заполнение данных
            IDispatch(IR1):=xSh.Range['FirstCell',EmptyParam];
            frow:=IR1.Row;
            fcol:=IR1.Column;
            lrow:=frow+VarArrayHighBound(xlArray,1);
            lcol:=fcol+VarArrayHighBound(xlArray,2);
            IDispatch(IR2):=xSh.Cells.Item[lrow,lcol];
            xSh.Range[IR1,IR2].Value:=xlArray;

            // разрывы между днями
            d:=PExamItem(list[list.Count-1]).xmtime;
            for i:=list.Count-2 downto 0 do
              if CompareDate(d,PExamItem(list[i]).xmtime)<>EqualsValue then
              begin
                d:=PExamItem(list[i]).xmtime;
                IDispatch(IR1):=xSh.Rows.Item[frow+i+1,EmptyParam];
                IR1.Insert(xlShiftUp);
                IDispatch(IR1):=xSh.Cells.Item[frow+i+1,fcol];
                IDispatch(IR2):=xSh.Cells.Item[frow+i+1,lcol];
                xSh.Range[IR1,IR2].Borders.Item[xlEdgeTop].Weight:=xlThin;
              end;

            (xSh.Parent as _Workbook).Close(true,AFileName,EmptyParam,xlLCID);
          end;  // if(xSh<>nil)

        end;  // if(XConnect)

      finally
        XDisconnect(xApp);
        xApp.Free;
        xApp:=nil;
      end;

    finally
      ClearList(list);
      list.Free;
    end;
  end;

end;

// экспорт расписания экзаменов кафедры  (28/11/06)
procedure ExportExamKafedra(AYear: WORD; ASem: BYTE; const AKafedra: string;
    ADataSet: TADODataSet; const AFileName, AXLTFile: string);

  // экспорт списка
  procedure ExportData(ASheet: _Worksheet);

    procedure ClearArray(var Arr: OleVariant);
    var
      i: integer;
    begin
      for i:=0 to 7 do Arr[i]:='';
    end;  // ClearArray

    procedure FillArray(var Arr: OleVariant);
    var
      s: string;
    begin
      Arr[0]:=ADataSet.FieldByName('grName').AsString;

      s:=ADataSet.FieldByName('sbName').AsString;
      if Length(s)>30 then
        if not ADataSet.FieldByName('sbSmall').IsNull then
          s:=ADataSet.FieldByName('sbSmall').AsString
        else s:=Copy(s,1,27)+'...';
      Arr[1]:=s;

      if ADataSet.FieldByName('xmtype').AsInteger=0 then
      begin
        DateTimeToString(s,'DD MMM',ADataSet.FieldByName('xmtime').AsDateTime);
        Arr[2]:=s;
        DateTimeToString(s,'HH:nn',ADataSet.FieldByName('xmtime').AsDateTime);
        Arr[3]:=s;
        Arr[4]:=ADataSet.FieldByName('aName').AsString;
      end
      else
      begin
        DateTimeToString(s,'DD MMM',ADataSet.FieldByName('xmtime').AsDateTime);
        Arr[5]:=s;
        DateTimeToString(s,'HH:nn',ADataSet.FieldByName('xmtime').AsDateTime);
        Arr[6]:=s;
        Arr[7]:=ADataSet.FieldByName('aName').AsString;
      end;
    end;  // FillArray

  var
    bFilter: boolean;

    xlArray: OleVariant;  // массив [row,col]
    IR1,IR2: ExcelRange;
    fpt: TPoint;
    row: integer;

    i: integer;

    tid: Variant;
    wpid: int64;
  begin
    tid:=Unassigned;
    wpid:=-1;

    xlArray:=VarArrayCreate([0,7], varOleStr);
    ClearArray(xlArray);

    fpt:=XGetRangePoint(ASheet,'FirstCell');
    row:=fpt.Y;

    bFilter:=ADataSet.Filtered;
    ADataSet.DisableControls;
    try
      ADataSet.Filtered:=false;
      ADataSet.First;

      while not ADataSet.Eof do
      begin

        if VarCompareValue(tid,ADataSet.FieldByName('tid').Value)=vrEqual then
        begin
          ClearArray(xlArray);

          // заполнение массива экз/конс
          wpid:=ADataSet.FieldByName('wpid').AsInteger;
          while (not ADataSet.Eof)
              and (CompareValue(wpid,ADataSet.FieldByName('wpid').Value)=EqualsValue)
              and (VarCompareValue(tid,ADataSet.FieldByName('tid').Value)=vrEqual) do
          begin
            FillArray(xlArray);
            ADataSet.Next;
          end;

          // вывод строки экз/конс
          IDispatch(IR1):=ASheet.Cells.Item[row,fpt.X];
          IDispatch(IR2):=ASheet.Cells.Item[row,fpt.X+7];
          ASheet.Range[IR1,IR2].Value:=xlArray;
          inc(row);

        end
        else
        begin
          // разделение экз/конс преп-лей
          if not VarIsEmpty(tid) then
          begin
            IDispatch(IR1):=ASheet.Cells.Item[row,fpt.X];
            IDispatch(IR2):=ASheet.Cells.Item[row,fpt.X+7];
            IDispatch(IR1):=ASheet.Range[IR1,IR2];
            IR1.Borders.Item[xlEdgeTop].Weight:=xlThin;
            IR1.Borders.Item[xlInsideVertical].LineStyle:=xlNone;
            IR1.Borders.Item[xlEdgeLeft].LineStyle:=xlNone;
            IR1.Borders.Item[xlEdgeRight].LineStyle:=xlNone;
            inc(row);
          end;

          tid:=ADataSet.FieldByName('tid').Value;

          // вывод ФИО преп-ля
          IDispatch(IR1):=ASheet.Cells.Item[row,fpt.X];
          IDispatch(IR2):=ASheet.Cells.Item[row,fpt.X+7];
          ASheet.Range[IR1,IR2].Merge(false);
          if ADataSet.FieldByName('Initials').IsNull then IR1.Value:='<Преподаватель>'
            else IR1.Value:=ADataSet.FieldByName('Initials').AsString;
          IR1.Font.Bold:=true;
          inc(row);
        end;

      end;  // while

    finally
      ADataSet.Filtered:=bFilter;
      ADataSet.EnableControls;
    end;

  end;  // ExportData

const
  PERIOD = '%s сессии %d/%d уч. года';

var
  xltfile: string;
  xApp: TExcelApplication;
  xWb: _Workbook;
  xSh: _Worksheet;
  IR: ExcelRange;

  s: string;

begin
  xltfile:=BuildFullName(AXLTFile);

  if xltfile='' then
  begin
    ShowMessageFmt(rsExNotFoundXlt,[AXLTFile]);
    Exit;
  end;

  if not ADataSet.IsEmpty then
  begin
    xApp:=TExcelApplication.Create(nil);
    try
      if XConnect(xApp) then
      begin

        xSh:=XOpenSheet(xApp,xltfile,'xmkafedra',true);
        if Assigned(xSh) then
        begin

          // заполнение заголовка
          IDispatch(IR):=xSh.Range['KafedraCell',EmptyParam];
          IR.Value:=AKafedra;

          IDispatch(IR):=xSh.Range['PeriodCell',EmptyParam];
          if ASem=1 then s:='осенней' else s:='весенней';
          IR.Value:=Format(PERIOD, [s,AYear,AYear+1]);

          ExportData(xSh);
          (xSh.Parent as _Workbook).Close(true,AFileName,EmptyParam,xlLCID);
        end;  // if(xSh<>nil)

      end;  // if(XConnect)
    finally
      XDisconnect(xApp);
      xApp.Free;
      xApp:=nil;
    end;
  end;
end;

// экспорт занятости аудиторий  (18/12/06)
procedure ExportExamAuditory(AYear: WORD; ASem: BYTE; const AKafedra: string;
    APeriod: TDatePeriod; AXMType: TXMType; ADataSet: TADODataSet;
    const AFileName, AXLTFile: string);

  // экспорт списка
  procedure ExportData(ASheet: _Worksheet);

    // очистка массива
    procedure ClearArray(var Arr: OleVariant);
    var
      l,h: integer;
      i: integer;
    begin
      l:=VarArrayLowBound(Arr,1);
      h:=VarArrayHighBound(Arr,1);
      for i:=l to h do Arr[i,0]:='';
    end;  // ClearArray

    // определение кол-ва дней в периоде, искл. вс.
    function DaysOfPeriod: integer;
    var
      day: TDateTime;
    begin
      Result:=0;

      day:=APeriod.dbegin;
      while day<APeriod.dend do
      begin
        if DayOfTheWeek(day)<>DaySunday then Inc(Result);
        day:=IncDay(day);
      end;
    end;  // DaysOfPeriod

    // определение индекса массива для указ. даты
    function DayIndex(ADay: TDateTime): integer;
    var
      day: TDateTime;
    begin
      Result:=0;

      day:=APeriod.dbegin;

      while day<APeriod.dend do
      begin
        if SameDate(day,ADay) then break;
        if DayOfTheWeek(day)<>DaySunday then Inc(Result);
        day:=IncDay(day);
      end;
    end;  // DayIndex

    // заполнение массива
    procedure FillArray(var Arr: OleVariant);
    var
      idx: integer;
      s: string;
      day: TDateTime;
    begin
      day:=ADataSet.FieldByName('xmtime').AsDateTime;
      idx:=DayIndex(day);
      DateTimeToString(s, 'h:nn', day);
      s:=Format('%s  %s',[s,ADataSet.FieldByName('grName').AsString]);
      if Arr[idx,0]<>'' then Arr[idx,0]:=Arr[idx,0]+#10+s
        else Arr[idx,0]:=s;
    end;  // FillArray

    // подготовка листа
    procedure PrepareSheet(ADays: integer);
    var
      IR: ExcelRange;
      col, row: integer;
      day: TDateTime;
      s: string;

    begin
      // вывод заголовка
      if AXMType=xmtExam then s:='экзамены' else s:='консультации';
      s:=Format('Занятость аудиторий (%s)',[s]);
      ASheet.Range['TitleCell',EmptyParam].Value:=s;

      // заполнение ячеек-дней
      IDispatch(IR):=ASheet.Range['DateCell',EmptyParam];
      col:=IR.Column;
      row:=IR.Row;
      day:=APeriod.dbegin;
      while day<APeriod.dend do
      begin
        if DayOfTheWeek(day)<>DaySunday then
        begin
          IDispatch(IR):=ASheet.Cells.Item[row,col];
          DateTimeToString(s,'D MMM'#10'(ddd)', day);
          IR.Value:=s;
          inc(row);
        end;
        day:=IncDay(day);
      end;
    end;  // PrepareSheet

    procedure ExportArray(var Arr: OleVariant; ARow, ACol, ARows: integer);
    var
      IR1,IR2: ExcelRange;
      r,h: integer;
    begin
      // вывод строки занятости
      IDispatch(IR1):=ASheet.Cells.Item[ARow,ACol];
      IDispatch(IR2):=ASheet.Cells.Item[ARow+ARows-1,ACol];
      IDispatch(IR1):=ASheet.Range[IR1,IR2];
      IR1.Value:=Arr;

      for r:=ARow to ARow+ARows-1 do
      begin
        IDispatch(IR1):=ASheet.Cells.Item[r,ACol];
        h:=IR1.RowHeight;
        IR1.Rows.AutoFit;
        if h>IR1.RowHeight then IR1.RowHeight:=h;
      end;
    end;  // ExportArray

  var
    xlArray: OleVariant;  // массив [row,col] - эл-т = {время  группа}
    IR1,IR2: ExcelRange;
    VP: VPageBreak;

    cell: TPoint;
    lcol, hrow: integer;
    days: integer;

    aid: Variant;
    aName: string;

  begin
    aid:=Unassigned;

    days:=DaysOfPeriod;
    xlArray:=VarArrayCreate([0,days-1,0,0], varOleStr);
    ClearArray(xlArray);

    PrepareSheet(days);

    cell:=XGetRangePoint(ASheet, 'FirstCell');
    lcol:=XGetRangePoint(ASheet, 'LastCell').X;
    hrow:=XGetRangePoint(ASheet, 'Header').Y;

    ADataSet.DisableControls;
    try
      ADataSet.First;

      while not ADataSet.Eof do
      begin

        if VarCompareValue(aid,ADataSet.FieldByName('aid').Value)=vrEqual then
        begin
          FillArray(xlArray);
          ADataSet.Next;

          if ADataSet.Eof then
          begin
            IDispatch(IR1):=ASheet.Cells.Item[hrow,cell.X];
            IR1.Value:=aName;
            ExportArray(xlArray,cell.Y,cell.X,days);
          end;

        end
        else
        begin

          if not VarIsEmpty(aid) then
          begin

            // добавление столбцов
            if cell.X>=lcol then
            begin
              IDispatch(IR1):=ASheet.Columns.Item[cell.x, EmptyParam];
              IR1.Insert(xlShiftToRight);
            end;

            // вывод занятости
            IDispatch(IR1):=ASheet.Cells.Item[hrow,cell.X];
            IR1.Value:=aName;
            ExportArray(xlArray,cell.Y,cell.X,days);

            inc(cell.X);

          end;

          aid:=ADataSet.FieldByName('aid').Value;
          aName:=ADataSet.FieldByName('aName').AsString;
          ClearArray(xlArray);

        end;  // else


      end;  // while

    finally
      ADataSet.EnableControls;
    end;
{
    if cell.X>lcol then
      if ASheet.VPageBreaks.Count>0 then
      begin
        VP:=ASheet.VPageBreaks.Item[1];
        ASheet.
        VP.Application.ActiveWindow.View:=xlPageBreakPreview;
        try
          VP.DragOff(xlToRight,1);
        finally
          VP.Application.ActiveWindow.View:=xlNormalView;
        end;
      end;
}
  end;  // ExportData

const
  PERIOD = '%s сессии %d/%d уч. года';

var
  xltfile: string;
  xApp: TExcelApplication;
  xWb: _Workbook;
  xSh: _Worksheet;
  IR: ExcelRange;

  s: string;

begin
  xltfile:=BuildFullName(AXLTFile);

  if xltfile='' then
  begin
    ShowMessageFmt(rsExNotFoundXlt,[AXLTFile]);
    Exit;
  end;

  if not ADataSet.IsEmpty then
  begin
    xApp:=TExcelApplication.Create(nil);
    try
      if XConnect(xApp) then
      begin

        xSh:=XOpenSheet(xApp,xltfile,'xmauditory',true);
        if Assigned(xSh) then
        begin

          // заполнение заголовка
          IDispatch(IR):=xSh.Range['KafedraCell',EmptyParam];
          IR.Value:=AKafedra;

          IDispatch(IR):=xSh.Range['PeriodCell',EmptyParam];
          if ASem=1 then s:='осенней' else s:='весенней';
          IR.Value:=Format(PERIOD, [s,AYear,AYear+1]);

          ExportData(xSh);
          (xSh.Parent as _Workbook).Close(true,AFileName,EmptyParam,xlLCID);
        end;  // if(xSh<>nil)

      end;  // if(XConnect)
    finally
      XDisconnect(xApp);
      xApp.Free;
      xApp:=nil;
    end;
  end;
end;

end.
