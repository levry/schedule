{
  Отчеты в Excel
  v0.0.1  (8/10/06)
}
unit XReport;

interface

uses
  Types, DB, Excel2000;


function XConnect(xApp: TExcelApplication): boolean;
procedure XDisconnect(xApp: TExcelApplication);

function XOpenSheet(xApp: TExcelApplication;
    const Template, SheetName: string; DeleteOthers: boolean): _Worksheet;
function XGetRangePoint(xSheet: _Worksheet; const RangeName: string): TPoint;
procedure XSetValueRangeSave(xSheet: _Worksheet; const RangeName: string;
    RangeValue: OleVariant);

//function XExportDataSet(xSheet: _Worksheet; FirstCell: TPoint;
//    DataSet: TDataSet; FieldNames: array of string): boolean;

procedure DoExportDataSet(const xltfile, outfile, sheetname, title, period: string;
    DataSet: TDataSet; FieldNames: array of string);

implementation

uses
  Windows, OleServer, ActiveX, SysUtils, Variants, Dialogs,
  SUtils, SStrings;

const
  xlLCID = LOCALE_USER_DEFAULT;

// поключение к Excel (8/10/06)
function XConnect(xApp: TExcelApplication): boolean;
begin
  Assert(Assigned(xApp),
    'B3C89E79-A394-4C2A-9E80-A6C0678F7687'#13'XConnect: xApp is nil'#13);

  Result:=false;
  try
    xApp.ConnectKind := ckNewInstance;
    xApp.Connect;
    Result:=true;
  except
    on E: Exception do
    begin
      E.Message:='Excel: '+E.Message;
      Result:=false;
    end;
  end;
end;

// закрытие сеанса с Excel (8/10/06)
procedure XDisconnect(xApp: TExcelApplication);
begin
  Assert(Assigned(xApp),
    'C4F377B8-9FC2-44C9-BF49-F672BC7CCEE4'#13'XDisconnect: xApp is nil'#13);

  if (xApp.Workbooks.Count > 0) and (not xApp.Visible[xlLCID]) then
  // не закрывайте не свои книги
  begin
    xApp.WindowState[xlLCID] := TOLEEnum(xlMinimized);
    xApp.Visible[xlLCID] := true;
  end
  else xApp.Quit;
  xApp.Disconnect;
end;

// возвращает координаты именов. области (8/10/06)
function XGetRangePoint(xSheet: _Worksheet; const RangeName: string): TPoint;
var
  IR: ExcelRange;
begin
  IDispatch(IR):=xSheet.Range[RangeName,EmptyParam];
  Result.X:=IR.Column;
  Result.Y:=IR.Row;
end;

procedure XSetValueRange(xSheet: _Worksheet; const RangeName: string;
    RangeValue: OleVariant);
var
  IR: ExcelRange;
begin
  try
    IDispatch(IR):=xSheet.Range[RangeName,EmptyParam];
    if Assigned(IR) then IR.Value:=RangeValue
      else raise Exception.CreateFmt('Range "%s" not found',[RangeName]);
  except
    on E: Exception do
      ShowMessageFmt('XSetValueRange: %s',[E.Message]);
  end;
end;

procedure XSetValueRangeSave(xSheet: _Worksheet; const RangeName: string;
    RangeValue: OleVariant);
var
  IR: ExcelRange;

begin
  try
    IDispatch(IR):=xSheet.Range[RangeName,EmptyParam];
    if Assigned(IR) then IR.Value:=RangeValue
  except
  end;
end;

// открытие раб. листа  (8/10/06)
function XOpenSheet(xApp: TExcelApplication;
    const Template, SheetName: string; DeleteOthers: boolean): _Worksheet;
var
  xWb: _Workbook;
  xSh: _Worksheet;
  i: integer;
begin
  Result:=nil;

  try
    xWb:=xApp.Workbooks.Add(Template, xlLCID);

    if DeleteOthers then
    begin
      xApp.DisplayAlerts[xlLCID]:=false;
      for i:=xWb.Worksheets.Count downto 1 do
      begin
        xSh:=xWb.Worksheets.Item[i] as _Worksheet;
        if xSh.Name<>SheetName then xSh.Delete(xlLCID);
      end;
      xApp.DisplayAlerts[xlLCID]:=true;
    end;

    Result:=xWb.Worksheets.Item[SheetName] as _Worksheet;
  except
    on E: Exception do
    begin
      ShowMessageFmt('XOpenSheet: %s',[E.Message]);
      Result:=nil;
    end;
  end;
end;

// экспорт DataSet`a  (8/10/06)
procedure XExportDataSet(xSheet: _Worksheet; FirstCell: TPoint;
    DataSet: TDataSet; FieldNames: array of string);

  // заполнение массива
  procedure FillArray(var Arr: OleVariant);
  var
    bkmSave: TBookmark;
    row,i,cols: integer;
  begin
    DataSet.DisableControls;
    try
      bkmSave:=DataSet.GetBookmark;
      try
        DataSet.First;
        row:=0;
        cols:=Length(FieldNames);
        while not DataSet.Eof do
        begin
          for i:=0 to cols-1 do
            Arr[row,i]:=DataSet.FieldByName(FieldNames[i]).Value;
          inc(row);
          DataSet.Next;
        end;
        DataSet.GotoBookmark(bkmSave);
      finally
        DataSet.FreeBookmark(bkmSave);
      end;
    finally
      DataSet.EnableControls;
    end;
  end;  // procedure InitArray

var
  IR1,IR2: ExcelRange;
  Arr: OleVariant;
  cols,rows: integer;
begin

  cols:=Length(FieldNames);
  rows:=DataSet.RecordCount;

  Arr:=VarArrayCreate([0,rows-1, 0,cols-1], varVariant);
  FillArray(Arr);

  IDispatch(IR1):=xSheet.Cells.Item[FirstCell.y,FirstCell.x];
  IDispatch(IR2):=xSheet.Cells.Item[FirstCell.y+rows-1,FirstCell.x+cols-1];
  xSheet.Range[IR1,IR2].Value:=Arr;

end;

// экспорт DataSet`a в Excel (6/10/06)
procedure DoExportDataSet(const xltfile, outfile, sheetname, title, period: string;
    DataSet: TDataSet; FieldNames: array of string);
var
  xApp: TExcelApplication;
  xSh: _Worksheet;
  fcell: TPoint;
  fullname: string;
begin
  fullname:=BuildFullName(xltfile);

  if fullname<>'' then
  begin
    xApp:=TExcelApplication.Create(nil);
    try
      if XConnect(xApp) then
      begin
        xSh:=XOpenSheet(xApp,fullname,sheetname,true);

        if Assigned(xSh) then
        begin
          if title<>'' then XSetValueRange(xSh, 'TitleCell', title);
          if period<>'' then XSetValueRange(xSh,'PeriodCell', period);
          fcell:=XGetRangePoint(xSh,'FirstCell');
          XExportDataSet(xSh,fcell,DataSet,FieldNames);
          (xSh.Parent as _Workbook).Close(true,outfile,EmptyParam,xlLCID);
        end;
      end;
    finally
      XDisconnect(xApp);
      xApp.Free;
      xApp:=nil;
    end;
  end
  else raise Exception.CreateFmt(rsExNotFoundXlt,[xltfile]);
end;

end.
