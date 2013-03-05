{
  Экспорт расписания исп-ния ресурсов (преп-ли, аудитории)
  v0.0.1  (06/08/06)
}
unit ExportResTime;

// TODO: Выбор режима вывода расписаний: разделять на листы, все на один лист

interface

uses
  SClasses;  

procedure DoExportResTimeGrid(AYear: WORD; ASem,APSem: byte;
    ATimeGrid: TTimeGrid; AFileName,AXLTFile: string);

implementation

uses
  Windows,Excel2000,Office2000,OleServer,ActiveX,SysUtils,Dialogs,Variants,
  SUtils,SStrings;

const
  xlLCID = LOCALE_USER_DEFAULT;


function XConnect(xApp: TExcelApplication): boolean;
begin
  Assert(Assigned(xApp),
    '470C07F9-B4D3-4A56-9B10-B7FB5F8B0173'#13'XConnect: xApp is nil'#13);

  Result:=false;
  if Assigned(xApp) then
  begin
    try
      xApp.ConnectKind := ckNewInstance;
      xApp.Connect;
      Result:=true;
    except
      on E: Exception do E.Message:='Excel: '+E.Message;
    end;
  end;
end;

// разъединение с Excel
procedure XDisconnect(var xApp: TExcelApplication);
begin
  Assert(Assigned(xApp),
    '766F2749-2077-4E08-A08C-D28C7F4FAB9D'#13'XDisConnect: xApp is nil'#13);

  if (xApp.Workbooks.Count > 0) and (not xApp.Visible[xlLCID]) then
  begin
    xApp.WindowState[xlLCID] := TOLEEnum(xlMinimized);
    xApp.Visible[xlLCID] := true;
  end
  else xApp.Quit;
  xApp.Disconnect;
end;

// экспорт расписания исп-ния ресурсов (06/08/06)
procedure DoExportResTimeGrid(AYear: WORD; ASem,APSem: byte;
    ATimeGrid: TTimeGrid; AFileName,AXLTFile: string);

var
  HeadRow, FirstRow, FirstCol, NumCol: integer;

  // возвращает номер строки, соответст. указ. паре
  function ToRowXL(iday,ipair: byte): integer;
  begin
    Result:=iday*NumberPairs+ipair+FirstRow;
  end;  // ToRowXL

  // экспорт расписания исп-ния ресурса
  procedure ExportTimeList(ATimeList: TTimeList; ACol: integer;
    ASheet: _Worksheet);

    // форматирование один. пар
    procedure FormatLsns(ALsns: TTimeLsns; ARow: integer);
    var
      sg,sr,sp: string;
      IR: ExcelRange;
    begin
      IDispatch(IR):=ASheet.Cells.Item[ARow,ACol];

      sg:=IR.Value;
      if sg<>'' then sg:=sg+' ';
      sg:=sg+ALsns.GetGroupString(1);
      sr:=GetValue(ALsns.Resource);
      case ALsns.Week of
        1: sp:=' (чт)';
        2: sp:=' (нч)';
        else sp:='';
      end;  // case
      IR.Value:=Format('%s / %s%s',[sg,sr,sp]);
      IR.Characters[Length(sg)+3,Length(sr)+1].Font.Bold:=True;
    end;  // FormatLsns


    // форматирование двой. пар
    procedure FormatDoubleLsns(ALsns: TTimeLsns; ARow: integer; bSingle: boolean);

      procedure MergeDouble;
      var
        IR1,IR2: ExcelRange;
      begin
        IDispatch(IR1):=ASheet.Cells.Item[ARow,ACol];
        IDispatch(IR2):=ASheet.Cells.Item[ARow+1,ACol];
        IDispatch(IR1):=ASheet.Range[IR1,IR2];
        IR1.Merge(false);
      end;

      procedure SplitDouble;
      var
        IR: ExcelRange;
      begin
        IDispatch(IR):=ASheet.Cells.Item[ARow,ACol];
        IR.Borders.Item[xlEdgeBottom].LineStyle:=xlDot;
      end;

    begin
      if bSingle and (ALsns.Week=0) then MergeDouble
        else SplitDouble;

      if ALsns.Week=2 then inc(ARow);
      FormatLsns(ALsns,ARow);
    end;  // FormatDoubleLsns;

    procedure FormatShape(ARow, ACount: integer);
    var
      IR1,IR2: ExcelRange;
    begin
      IDispatch(IR1):=ASheet.Cells.Item[ARow,ACol];
      IDispatch(IR2):=ASheet.Cells.Item[ARow+ACount-1,ACol];
      IDispatch(IR1):=ASheet.Range[IR1,IR2];
      ASheet.Shapes.AddShape(msoShapeLeftBrace,
          IR1.Left+1, IR1.Top+1, 5, IR1.Height-2);
    end;

  var
    d,p: byte;
    i,c,row: integer;
    bDoubled: boolean;
    IR: ExcelRange;
  begin
    ASheet.Cells.Item[HeadRow,ACol].Value:=ATimeList.Name;

    for d:=0 to NumberDays-1 do
    begin
      p:=0;
      while p<NumberPairs do
      begin
        c:=ATimeList.GetLsnsCount(d,p);

        if c>0 then
        begin
          bDoubled:=ATimeList.IsDoublePair(d,p);
          row:=ToRowXL(d,p);

          // двой. пары
          if bDoubled then
          begin
            for i:=0 to c-1 do
              FormatDoubleLsns(ATimeList.GetLsns(d,p,i),row,(c=1));
            FormatShape(row,2);
            inc(p);
          end
          else
            // один. занятия
            for i:=0 to c-1 do
              FormatLsns(ATimeList.GetLsns(d,p,i),row);
        end;

        inc(p);
      end;  // while(p);
    end;  // for(d)
    
  end;  // ExportTimeList

var
  xltfile: string;

  xApp: TExcelApplication;
  xWb: _Workbook;
  xSh, outSh: _Worksheet;
  IR: ExcelRange;
  Col: integer;

  i: integer;
  sPeriod: string;
  dt: TDateTime;
begin
  xltfile:=BuildFullName(AXLTFile);

  if xltfile='' then
  begin
    ShowMessageFmt(rsExNotFoundXlt,[AXLTFile]);
    Exit;
  end;

  sPeriod:=Format('%s семестр %d п/семестра %d-%d учебного года',
      [csSemester[ASem],APSem,AYear,AYear+1]);
  dt:=Now();

  xApp:=TExcelApplication.Create(nil);
  try
    xWb:=xApp.Workbooks.Add(xltfile,xlLCID);
    try
      xSh:=xWb.Worksheets.Item['timelist'] as _Worksheet;

      try
        // опр-ние заголовка таблицы
        IDispatch(IR):=xSh.Range['HeadCell',EmptyParam];
        HeadRow:=IR.Row;
        // определение первой колонки данных
        IDispatch(IR):=xSh.Range['FirstCell',EmptyParam];
        FirstCol:=IR.Column;
        FirstRow:=IR.Row;
        // опр-ние кол-ва колонок под данные
        IDispatch(IR):=xSh.Range['LastCell',EmptyParam];
        NumCol:=IR.Column-FirstCol+1;

        Col:=FirstCol;
        i:=0;
        while i<ATimeGrid.Count do
        begin
          // для каждых NumCol расписаний создаем свой лист
          if (i mod (NumCol))=0 then
          begin
            xSh.Copy(xSh,EmptyParam,xlLCID);
            outSh:=xWb.Worksheets.Item[xSh.Index[xlLCID]-1] as _Worksheet;
            //outSh.Activate(xlLCID);
            outSh.Name:=Format('Лист %d',[((i+1) div NumCol)+1]);
            outSh.Range['PeriodCell',EmptyParam].Value:=sPeriod;
            outSh.Range['DateCell',EmptyParam].Value:=dt;
            Col:=FirstCol;
          end;
          ExportTimeList(ATimeGrid.Items[i],Col,outSh);
          inc(Col);
          inc(i);
        end;
      finally
        xApp.DisplayAlerts[xlLCID]:=false;
        xSh.Delete(xlLCID);
        xApp.DisplayAlerts[xlLCID]:=true;
        xSh:=nil;
      end;

      xWb.Close(true,AFileName,EmptyParam,xlLCID);
    finally
      xWb:=nil;
    end;
  finally
    XDisconnect(xApp);
    xApp.Free;
    xApp:=nil;
  end;
end;

end.
