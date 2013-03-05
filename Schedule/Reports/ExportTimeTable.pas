{
  Экспорт расписания занятий
  v0.2.3  (01/09/06)
}
unit ExportTimeTable;

interface

uses
  SClasses, SCategory;

procedure DoExportTimeTable(Faculty: string; ASchedule: TSchedule; AOptions: TExportTableCategory);
procedure DoExportNotResTable(AYear: word; ASem, APSem: byte; ASchedule: TSchedule);

implementation

uses
  Classes, Controls, Windows, Forms, Graphics, Dialogs, Variants, SysUtils,
  OleServer, ActiveX, Excel2000, Office2000,
  SUtils, SStrings, PageDlg, ExportSourcePage, ExportTablePage,
  XReport;

const
  xlLCID = LOCALE_USER_DEFAULT;

  xl_rpp  = 3;            // кол-во строк на пару
  xl_fcol = 4;            // 1ая колонка
  xl_frow = 5;            // 1ая строка
  xl_lcol = 22;           // последняя колонка
  xl_lrow = 135;          // последняя строка
  xl_grow = 4;            // строка названий групп


function XExportTimeTable(Faculty: string; ASchedule: TSchedule; AGrpList: TList;
    AOptions: TExportTableCategory; AFileName: string): boolean; forward;
function XExportNotResTable(AYear: word; ASem, APSem: byte; ASchedule: TSchedule;
    AGrpList: TList; AFileName: string): boolean; forward;


// вызов диалога экспорта расписания занятий (01/09/06)
procedure DoExportTimeTable(Faculty: string; ASchedule: TSchedule; AOptions: TExportTableCategory);
var
  frmDlg: TfrmPageDlg;
  SourcePage: TfrmExportSourcePage;
  ExportPage: TfrmExportTablePage;

  GrpList: TList;
begin
  frmDlg:=TfrmPageDlg.Create(Application);
  try
    frmDlg.Caption:='Экспорт расписания занятий';

    SourcePage:=frmDlg.AddPage('Источник',TfrmExportSourcePage) as TfrmExportSourcePage;
    SourcePage.AssignList(ASchedule);
    ExportPage:=frmDlg.AddPage('Оформление',TfrmExportTablePage) as TfrmExportTablePage;
    ExportPage.Options:=AOptions;

    if frmDlg.ShowModal=mrOk then
    begin
      GrpList:=TList.Create;
      try
        if SourcePage.GetObjectList(GrpList)>0 then;
          XExportTimeTable(Faculty, ASchedule,GrpList,AOptions,SourcePage.FileName);
      finally
        GrpList.Free;
      end;
    end;
  finally
    frmDlg.Free;
  end;
end;

// экспорт расписания занятий групп (занятия без аудиторий) (01/09/06)
procedure DoExportNotResTable(AYear: word; ASem, APSem: byte; ASchedule: TSchedule);
var
  frmDlg: TfrmPageDlg;
  SourcePage: TfrmExportSourcePage;

  GrpList: TList;
begin
  frmDlg:=TfrmPageDlg.Create(Application);
  try
    frmDlg.Caption:='Расписание внеаудиторных занятий';
    SourcePage:=frmDlg.AddPage('Источник',TfrmExportSourcePage) as TfrmExportSourcePage;
    SourcePage.AssignList(ASchedule);

    if frmDlg.ShowModal=mrOk then
    begin
      GrpList:=TList.Create;
      try
        if SourcePage.GetObjectList(GrpList)>0 then
          XExportNotResTable(AYear,ASem,APSem,ASchedule,GrpList,SourcePage.FileName);
      finally
        GrpList.Free;
      end;
    end;
  finally
    frmDlg.Free;
  end;
end;

function FontStyleToXL(AFontStyle: TFontStyles): string;
begin
  Result:='';
  if fsBold in AFontStyle then Result:=Result+'Bold ';
  if fsItalic in AFontStyle then Result:=Result+'Italic ';
  if fsUnderline in AFontStyle then Result:=Result+'Underline ';
  Delete(Result, Length(Result), 1);
end;

// подключение к Excel (01/09/06)
function XConnect(xApp: TExcelApplication): boolean;
var
  s, ver: string;
  i: integer;
begin
  Result:=false;

  if Assigned(xApp) then
  begin
    try
      xApp.ConnectKind := ckNewInstance;
      xApp.Connect;

      // проверка версии (не ниже 2000 (v9))
      ver:=xApp.Version[xlLCID];
      i:=Pos('.',ver);
      if i>0 then s:=Copy(ver,1,i-1) else s:=ver;
      if StrToIntDef(s,0)>=9 then Result:=true
        else
          if MessageDlg(Format(rsExOldVersion+#13'%s'#13'%s',[ver,rsExInvalidView,rsContinue]),
              mtConfirmation, [mbYes,mbNo],0)=mrNo then
            Result:=false
          else Result:=true;

    except
      on E: Exception do
      begin
        E.Message:='Excel: '+E.Message;
        Result:=false;
      end;
    end;

  end;
end;

// закрытие Excel (01/09/06)
procedure XDisconnect(xApp: TExcelApplication);
begin
  if Assigned(xApp) then
  begin
    if (xApp.Workbooks.Count > 0) and (not xApp.Visible[xlLCID]) then
    begin
      xApp.WindowState[xlLCID] := TOLEEnum(xlMinimized);
      xApp.Visible[xlLCID] := true;
    end
    else xApp.Quit;
    xApp.Disconnect;
  end;
end;

// проверка ширины ячейки для строки
function XCheckCellWidth(ACell: ExcelRange; const s: string;
    APercent: byte): boolean;
var
  aw, cw: integer;
begin
  Result:=true;

  cw:=ACell.ColumnWidth;
  ACell.Value:=s;
  ACell.Columns.AutoFit;
  aw:=ACell.ColumnWidth;
  if aw>cw then
    if aw>cw*(1+APercent/100) then Result:=false
      else ACell.ShrinkToFit:=true;
  ACell.ColumnWidth:=cw;
end;  // function XCheckCellWidth

// экспорт расписания занятий в Excel
function XExportTimeTable(Faculty: string; ASchedule: TSchedule; AGrpList: TList;
    AOptions: TExportTableCategory; AFileName: string): boolean;

var
  xApp: TExcelApplication;

  // возвращает номер строки, соответст. указ. паре
  function ToRowXL(iday,ipair: byte): integer;
  begin
    Result:=iday*(NumberPairs*xl_rpp+1)+ipair*xl_rpp+xl_frow;
//    Result:=iday*NumberPairs*xl_rpp+ipair*xl_rpp+xl_frow+iday;
  end;

  // возвращает эл-т (дисциплина,аудитория,преп-ль) по индексу
  function GetElement(AIndex: integer; ALsns: TLsns): string;
  begin
    case AOptions.GetElement(AIndex) of
      etSubject:  Result:=ALsns.subject;
      etAuditory: Result:=ALsns.auditory;
      etTeacher:  Result:=ALsns.teacher;
    else Result:='';
    end;
  end;

  // возвращает id эл-та (дисц.,аудит.,преп-ль) по индексу)
  function GetElementId(AIndex: integer; ALsns: TLsns): int64;
  begin
    case AOptions.GetElement(AIndex) of
      etSubject:  Result:=ALsns.sbid;
      etAuditory: Result:=ALsns.aid;
      etTeacher:  Result:=ALsns.tid;
    else Result:=0;
    end;
  end;

  // экспорт группы
  procedure ExportGroup(AGroup: TGroup; ACol: integer; ASheet: _Worksheet;
      AShape: OleVariant);

    function GetFontSizeElement(AIndex: integer): integer;
    begin
      case AOptions.GetElement(AIndex) of
        etSubject:  Result:=AOptions.SubjectSizeFont;
        etAuditory: Result:=AOptions.AuditorySizeFont;
        etTeacher:  Result:=AOptions.TeacherSizeFont;
        else Result:=12;
      end;
    end;

    function GetFontStyleElement(AIndex: integer): TFontStyles;
    begin
      case AOptions.GetElement(AIndex) of
        etSubject:  Result:=AOptions.SubjectStyleFont;
        etAuditory: Result:=AOptions.AuditoryStyleFont;
        etTeacher:  Result:=AOptions.TeacherStyleFont;
      else Result:=[];
      end;
    end;

    // TODO: Доработать: не использовать дин. массивы 
    // одна ячейка = занятие
    procedure FormatSingle(ACell: ExcelRange; ALsns: TLsns; ADelimiter: char);
    var
      i: integer;
      s, se: string;
      ipos, ilen: array of integer;
    begin
      s:='';

      SetLength(ipos,AOptions.Orders.Count);
      SetLength(ilen,AOptions.Orders.Count);
      try
        // построение строки занятия
        for i:=0 to AOptions.Orders.Count-1 do
        begin
          ipos[i]:=Length(s);

          if AOptions.GetElement(i)=etSubject then
          begin
            se:=SUtils.GetTag(ALsns.subject);
            if se='' then se:=SUtils.GetValue(ALsns.subject);
          end
          else se:=SUtils.GetValue(GetElement(i,ALsns));

          ilen[i]:=Length(se);
          s:=s+se+ADelimiter;
        end;
        Delete(s, Length(s), 1);

        // форматирование ячейки
        ACell.Value:=s;
        for i:=0 to AOptions.Orders.Count-1 do
          ACell.Characters[ipos[i],ilen[i]].Font.FontStyle:=FontStyleToXL(GetFontStyleElement(i));
        //ACell.Interior.Pattern:=AOptions.GetPattern(ALsns.ltype);

        ACell.ShrinkToFit:=true;

      finally
        SetLength(ilen,0);
        SetLength(ipos,0);
      end;
    end;  // procedure FormatSingle

    // вывод занятия (без заливки)
    procedure FormatLsns(ARow: integer; ALsns: TLsns; ASingle: boolean);

      // одна ячейка = эл-т занятия (предмет,аудитория,преп-ль)
      procedure FormatCell(ACell: ExcelRange; ALsns: TLsns; AIndex: integer);
      var
        s, small: string;
        fstyle: TFontStyles;
      begin
        ACell.Font.Size:=GetFontSizeElement(AIndex);
        fstyle:=GetFontStyleElement(AIndex);
        ACell.Font.FontStyle:=FontStyleToXL(fstyle);
        //ACell.Interior.Pattern:=AOptions.GetPattern(ALsns.ltype);

        // форматирование ячейки под дисциплину
        if AOptions.GetElement(AIndex)=etSubject then
        begin
          s:=SUtils.GetValue(ALsns.subject);
          if not XCheckCellWidth(ACell, s, AOptions.SmallPercent) then
          begin
            small:=SUtils.GetTag(ALsns.subject);
            if small<>'' then
            begin
              if not XCheckCellWidth(ACell,small,AOptions.SmallPercent) then
                s:=Copy(s,1,15)+'...'
              else s:=small
            end
            else s:=Copy(s,1,15)+'...';
          end else
            // если ячейки объ-ны, то растягиваем дисциплину
            if ACell.MergeCells=true then
              if ACell.MergeArea.Count>2 then
              begin
                s:='   '+s;
                ACell.HorizontalAlignment:=xlFill;
              end;

        end
        else s:=SUtils.GetValue(GetElement(AIndex,ALsns));

        if AOptions.GetElement(AIndex)=etAuditory then
        begin
          if ALsns.subgrp then s:='1/2 гр.  '+s;
          if ALsns.parity=1 then s:=s+'  чт' else
            if ALsns.parity=2 then s:=s+'  нч';
        end;

        ACell.Value:=s;
        ACell.ShrinkToFit:=true;
      end;  // procedure FormatCell

    var
      i: integer;
      IR: ExcelRange;
    begin
      if ASingle then
      begin
        // вывод в 1у строку
        IDispatch(IR):=ASheet.Cells.Item[ARow,ACol];
        FormatSingle(IR,ALsns,' ');
      end
      else
        // вывод по элементам
        for i:=0 to xl_rpp-1 do
        begin
          IDispatch(IR):=ASheet.Cells.Item[ARow+i,ACol];
          FormatCell(IR,ALsns,i);
        end
    end; // procedure FormatLsns

    // вывод четности недели (+заливка (нет заливки для подгрупп))
    procedure FormatParity(ARow, ACount: integer; ALsns: TLsns);

      // выбор шаблона заливки для автофигуры
      function GetShapePattern(ltype: byte): integer;
      const
        PatternShapeStyles: array[TPatternStyle] of integer =
          (-1,msoPattern10Percent,msoPattern20Percent,msoPattern25Percent);
      var
        pstyle: TPatternStyle;
      begin
        case ltype of
          1: pstyle:=AOptions.LctnPattern;
          2: pstyle:=AOptions.PrctPattern;
          3: pstyle:=AOptions.LbryPattern;
        else pstyle:=psNone;
        end; // case
        Result:=PatternShapeStyles[pstyle];
      end;

    var
      IR1,IR2: ExcelRange;
      Shape: OleVariant;
      pattern: integer;
    begin
      if not ALsns.subgrp then
      begin
        IDispatch(IR1):=ASheet.Cells.Item[ARow,ACol];
        IDispatch(IR2):=ASheet.Cells.Item[ARow+ACount,ACol];
        IR1:=ASheet.Range[IR1,IR2];

        if ALsns.parity>0 then
        begin
          if (not VarIsNull(AShape)) and (AOptions.ParityStyle=psPattern) then
          begin
            Shape:=AShape.Duplicate;
            Shape.Left:=IR1.Left;
            Shape.Top:=IR1.Top;
            Shape.Width:=IR1.Width;
            Shape.Height:=IR1.Height;

            pattern:=GetShapePattern(ALsns.ltype);
            if pattern>0 then Shape.Fill.Patterned(pattern);

            if ALsns.parity=1 then Shape.Flip(1) else Shape.Flip(0); // 0 = msoFlipHorizontal  (1 = msoFlipVertical)
          end
          else
            if ACount>3 then
              Shape:=ASheet.Shapes.AddShape(msoShapeLeftBrace,
                IR1.Left+3, IR1.Top+3, 10, IR1.Height-6);
        end
        else IR1.Interior.Pattern:=AOptions.GetPattern(ALsns.ltype);
      end; // if not subgrp
    end; // procedure FormatParity

    // форматирование двой. пары (к/н)
    procedure FormatDoublePair(ARow: integer; ALsns: TLsns);
    var
      i: integer;
      IR, IR2: ExcelRange;
    begin
      Assert(not ALsns.Parent.IsSplitted, '374FBA0A-76F6-46BE-BB7D-D1B72D1BCFE4');
      Assert(ALsns.Parent.Count=1, '27CA3B33-6BBC-4D50-8652-F183F0426849');

      case AOptions.DoubleStyle of

        dsNone:  // нет объ-ния пар
          for i:=0 to 1 do
          begin
            FormatLsns(ARow+i*xl_rpp, ALsns, false);
            FormatParity(ARow+i*xl_rpp,xl_rpp-1,ALsns);
          end;

        dsShift: // вывод занятия со сдвигом на 1 ячейку вниз
          begin
            FormatLsns(ARow+1,ALsns,false);
            FormatParity(ARow,2*xl_rpp-1,ALsns);
            //FormatParity(ARow+2*xl_rpp-1,xl_rpp-1,ALsns);
            // удаление границы
            IDispatch(IR):=ASheet.Cells.Item[ARow+xl_rpp-1,ACol];
            IR.Borders.Item[xlEdgeBottom].LineStyle:=xlLineStyleNone;
          end;

        dsFull:  // объ-ние ячеек 2х пар
          begin
            xApp.DisplayAlerts[xlLCID]:=false;

            IDispatch(IR):=ASheet.Cells.Item[ARow,ACol];
            IDispatch(IR2):=ASheet.Cells.Item[ARow+2*xl_rpp-1,ACol];
            IR:=ASheet.Range[IR,IR2];
            IR.Merge(false);
            FormatSingle(IR, ALsns, #10);

            xApp.DisplayAlerts[xlLCID]:=true;
          end;

      end;  // case(DoubleStyle)
    end;  // procedure FormatDoublePair

    // форматирование двой. пары (ч/н)
    procedure FormatSplittedPair(ARow: integer; APair: TPair);
    var
      i, r: integer;
      lsns: TLsns;
      IR: ExcelRange;
    begin
      Assert(APair.IsSplitted, '{03638E96-36FB-4013-B9C6-3AE5729F7FEB}');

      for i:=0 to APair.Count-1 do
      begin
        lsns:=APair.Item[i];
        if lsns.parity>0 then r:=APair.Pair+lsns.parity-1 else r:=APair.Pair;
        FormatLsns(ToRowXL(APair.Day,r),lsns,false);
      end;

      // формат четности недели
//      if bSplitted then
      FormatParity(ARow,2*xl_rpp-1,APair.Item[0]);
      //FormatParity(xlRow,2*xl_rpp-1,pair.Item[0].parity);

      // удаление границы
      IDispatch(IR):=ASheet.Cells.Item[ARow+xl_rpp-1,ACol];
      if APair.Count=0 then
        IR.Borders.Item[xlEdgeBottom].LineStyle:=xlLineStyleNone
      else IR.Borders.Item[xlEdgeBottom].LineStyle:=xlDot;

      // вывод надписи "ч/н" (если одна двой. пара через неделю)
      if APair.Count<=1 then
      begin
        r:=APair.Item[0].parity;
        if r=1 then r:=APair.Pair+1 else
          if r=2 then r:=APair.Pair else
            Assert(false, '{B6586A6A-21C4-4280-8FBB-2BD9889B63F5');
        IDispatch(IR):=ASheet.Cells.Item[ToRowXL(APair.Day,r)+1,ACol];
        IR.Font.Bold:=true;
        IR.Font.Size:=12;
        IR.Value:='через неделю';
      end;

    end;  // procedure FormatSplittedPair

  var
    xlRow: integer;
    d,p: byte;

    i,r: integer;
    bMultiple: boolean;          // признак нескольких занятий на паре
    bSplitted: boolean;          // признак чередования недель
    bDoubled: boolean;           // признак двух пар

    pair: TPair;
    lsns: TLsns;
{$IF RTLVersion>=15.0}
    IR1,IR2: ExcelRange;
{$ELSE}
    IR1,IR2: Range;
{$IFEND}
  begin
    ASheet.Cells.Item[xl_grow,ACol].Value:=AGroup.Name;
    for d:=0 to 5 do
    begin
      p:=0;
      while p<7 do
      begin
        pair:=AGroup.Item[d,p];
        if pair.Count>0 then
        begin
          bMultiple:=pair.Count>1;
          bSplitted:=pair.IsSplitted;
          bDoubled:=pair.IsDoubled;
//          bDoubled:=IsDoublePair(pair);
          xlRow:=ToRowXL(d,p);

          // одно занятие (не двойная пара, но м.б. и ч/н)
          if (not bMultiple) and (not bDoubled) then
          begin
            FormatLsns(xlRow, pair.Item[0], false);
            FormatParity(xlRow,xl_rpp-1,pair.Item[0]);
            //if bSplitted then FormatParity(xlRow,xl_rpp-1,pair.Item[0]);
          end

          else
            // если двой. пара
            // TODO: Доработать: либо убрать объ-ние к/н, либо объ-ние ячейки 2х пар
            if bDoubled then
            begin
              if (not bSplitted) then FormatDoublePair(xlRow, pair.Item[0])
                else FormatSplittedPair(xlRow, pair);
              inc(p);
            end

            else
              // если занятия подгрупп
              for i:=0 to pair.Count-1 do
              begin
                lsns:=pair.Item[i];
                case lsns.parity of
                0:
                  r:=xlRow+i;
                2:
                  r:=xlRow+2;
                else
                  r:=xlRow;
                end;
                FormatLsns(r,lsns,true);

              end;

        end; // if pair.count>0
        inc(p);
      end; // while pair<7
    end; // for day
  end;  // procedure ExportGroup

  // объединение ячеек: горизонтально (только потоки)
  procedure MergeCells(AList: TList; ASheet: _Worksheet);

  {
    function ExistsNextLsns(ALsns: TLsns; AGroup: TGroup): boolean;
    var
      lsns: TLsns;
      pair: TPair;
    begin
      pair:=AGroup.Item[ALsns.Parent.Day,ALsns.Parent.Pair];
      lsns:=pair.FindStrm(ALsns.strid);
      if Assigned(lsns) then Result:=(ALsns.parity=lsns.parity)
        else Result:=false;
    end;
  }
    // существование смежного один. эл-та (дисц.,аудит.,преп-ль)
    function ExistsNextElem(ALsns: TLsns; AIndex: integer; AGroup: TGroup): boolean;
    var
      lsns: TLsns;
      pair: TPair;
    begin
      Result:=false;
      pair:=AGroup.Item[ALsns.Parent.Day,ALsns.Parent.Pair];
      lsns:=pair.FindStrm(ALsns.strid);
      if Assigned(lsns) then
        Result:=(GetElementId(AIndex,ALsns)=GetElementId(AIndex,lsns))
          and (ALsns.strid=lsns.strid);
    end;

  var
    i,e,c: integer;
    spanx: integer;

    xlRow: integer;
    IR1,IR2: ExcelRange;

    d,p: byte;
    pair: TPair;
    lsns: TLsns;
  begin
    for d:=0 to NumberDays-1 do
      for p:=0 to NumberPairs-1 do
      begin
        xApp.DisplayAlerts[xlLCID]:=false;

        // объед-ние ячеек отдельно для каждого эл-та занятия
        for e:=0 to xl_rpp-1 do
        begin
          i:=0;

          while i<AList.Count do
          begin
            spanx:=1;

            pair:=TGroup(AList.Items[i]).Item[d,p];
            // если занятие одно ..
            if pair.Count=1 then
            begin
              lsns:=pair.Item[0];
              // .. и оно потоковое (но не подгруппа)
              if (lsns.IsStrm) and (not lsns.subgrp) then

                // расчет числа один. смеж. эл-тов занятий
                for c:=i+1 to AList.Count-1 do
                  if ExistsNextElem(lsns,e,TGroup(AList.Items[c])) then inc(spanx)
                    else break;

              // объед-ние ячеек, если число смеж. один. эл-тов > 1
              if spanx>1 then
              begin
                xlRow:=ToRowXL(d,p)+e;
                IDispatch(IR1):=ASheet.Cells.Item[xlRow,xl_fcol+i];
                IDispatch(IR2):=ASheet.Cells.Item[xlRow,xl_fcol+i+spanx-1];
                ASheet.Range[IR1,IR2].Merge(false);
              end;
            end; // if pair.count=1

            inc(i,spanx);
          end; // while(i)

        end; // for(j)

        xApp.DisplayAlerts[xlLCID]:=true;
      end;  // for day & pair
  end;  // procedure MergeCells

var
  i: integer;
  xlCol: integer;
  xltfile: string;

  xWb: _Workbook;
  xSh: _Worksheet;
  xShape: OleVariant;
begin
  Assert(AGrpList.Count>0,
    '9D4B832E-9EEB-4374-B9E4-0E6A027A0EF3'#13'XExportTimeTable: AGrpList.Count=0'#13);

  Result:=true;

  xApp := TExcelApplication.Create(nil);
  try
    if XConnect(xApp) then
    begin
      xltfile:=BuildFullName(AOptions.XltFile);
      if xltfile<>'' then
      begin
        xWb:=xApp.Workbooks.Add(xltfile,xlLCID);
        try
          xSh:=xWb.Worksheets.Item['Timetable'] as _Worksheet;

          XReport.XSetValueRangeSave(xSh, 'faculty', Faculty);
          //xSh.Range['faculty', EmptyParam].Value:=Faculty;

          if xSh.Shapes.Count>0 then xShape:=xSh.Shapes.Item(1)
            else xShape:=Null;
          //if not VarIsNull(xShape) then xShape.SetShapesDefaultProperties;

          xlCol:=xl_fcol-1;
          try
            // объединение ячеек
            if AOptions.MergeCells then MergeCells(AGrpList,xSh);
            // вывод расписания отдельно для групп
            for i:=0 to AGrpList.Count-1 do
            try
              inc(xlCol);
              ExportGroup(TGroup(AGrpList.Items[i]),xlCol,xSh,xShape);
            except
              Result:=false;
              break;
            end;
            // объединение ячеек
            //if AOptions.MergeCells then MergeCells(GrpList,xSh);
          finally
            if not VarIsNull(xShape) then xShape.Delete;
            xShape:=Null;
            xSh:=nil;
          end;

          xWb.Close(true,AFileName,EmptyParam,xlLCID);
        finally
          xWb:=nil;
        end;
      end  // if xltfile<>''
//      else ShowMessageFmt('Current dir: %s', [GetCurrentDir()]);
      else ShowMessageFmt(rsExNotFoundXlt, [AOptions.xltFile]);
    end;  // if (XConnect)
  finally
    XDisconnect(xApp);
    xApp.Free;
    xApp:=nil;
  end;
end; // procedure

// экспорт расписания занятий групп (занятия без аудиторий) (01/09/06)
function XExportNotResTable(AYear: word; ASem,APSem: byte;
    ASchedule: TSchedule; AGrpList: TList; AFileName: string): boolean;
var
  HeadRow, FirstRow, FirstCol, NumCol: integer;

  // возвращает номер строки, соответст. указ. паре
  function ToRowXL(iday,ipair: byte): integer;
  begin
    Result:=iday*NumberPairs+ipair+FirstRow;
  end;  // ToRowXL

  // экспорт расписания группы
  procedure ExportGroup(AGroup: TGroup; ASheet: _Worksheet; ACol: integer);

    // форматирование один. пар
    procedure FormatLsns(ALsns: TLsns; ARow: integer);
    var
      s, small: string;
      IR: ExcelRange;
    begin
      IDispatch(IR):=ASheet.Cells.Item[ARow,ACol];

      s:=SUtils.GetValue(ALsns.subject);
      if not XCheckCellWidth(IR, s, 50) then
      begin
        small:=SUtils.GetTag(ALsns.subject);
        if small<>'' then
        begin
          if not XCheckCellWidth(IR,small,50) then
            s:=Copy(s,1,15)+'...'
          else s:=small
        end
        else s:=Copy(s,1,15)+'...';
      end;
      
      IR.Value:=s;
    end;  // procedure FormatLsns

    // форматирование двой. пар
    procedure FormatDoubleLsns(ALsns: TLsns; ARow: integer; bSingle: boolean);

      procedure MergeDouble;
      var
        IR1,IR2: ExcelRange;
      begin
        IDispatch(IR1):=ASheet.Cells.Item[ARow,ACol];
        IDispatch(IR2):=ASheet.Cells.Item[ARow+1,ACol];
        IDispatch(IR1):=ASheet.Range[IR1,IR2];
        IR1.Merge(false);
      end;  // procedure MergeDouble

      procedure SplitDouble;
      var
        IR: ExcelRange;
      begin
        IDispatch(IR):=ASheet.Cells.Item[ARow,ACol];
        IR.Borders.Item[xlEdgeBottom].LineStyle:=xlDot;
      end;  // procedure SplitDouble

    begin
      if bSingle and (ALsns.parity=0) then MergeDouble
        else SplitDouble;

      if ALsns.parity=2 then inc(ARow);
      FormatLsns(ALsns,ARow);
    end;  // procedure FormatDoubleLsns;

    procedure FormatShape(ARow, ACount: integer);
    var
      IR1,IR2: ExcelRange;
    begin
      IDispatch(IR1):=ASheet.Cells.Item[ARow,ACol];
      IDispatch(IR2):=ASheet.Cells.Item[ARow+ACount-1,ACol];
      IDispatch(IR1):=ASheet.Range[IR1,IR2];
      ASheet.Shapes.AddShape(msoShapeLeftBrace,
          IR1.Left+1, IR1.Top+1, 5, IR1.Height-2);
    end;  // procedure FormatShape

  var
    d,p: byte;
    pair: TPair;

    i,c,row: integer;
    bDoubled, bShape: boolean;
    IR: ExcelRange;
  begin
    ASheet.Cells.Item[HeadRow,ACol].Value:=AGroup.Name;

    for d:=0 to NumberDays-1 do
    begin
      p:=0;
      while p<NumberPairs do
      begin
        pair:=AGroup.Item[d,p];
        c:=pair.Count;

        if c>0 then
        begin
          bDoubled:=pair.IsDoubled;
          row:=ToRowXL(d,p);

          // двой. пары
          if bDoubled then
          begin
            bShape:=false;

            for i:=0 to c-1 do
              if pair.Item[i].aid=0 then
              begin
                FormatDoubleLsns(pair.Item[i],row,(c=1));
                bShape:=true;
              end;

            if bShape then FormatShape(row,2);
            inc(p);
          end
          else
            // один. занятия
            for i:=0 to c-1 do
              if pair.Item[i].aid=0 then FormatLsns(pair.Item[i],row);
        end;  // if(c>0)

        inc(p);
      end;  // while(p);
    end;  // for(d)

  end;  // procedure ExportGroup

var
  xltfile: string;

  xApp: TExcelApplication;
  xWb: _Workbook;
  xSh, outSh: _Worksheet;
  IR: ExcelRange;

  col, i: integer;
  sPeriod: string;
  dt: TDateTime;
begin
  xltfile:=BuildFullName('timelist.xlt');
  if xltfile='' then
  begin
    ShowMessageFmt(rsExNotFoundXlt,['timelist.xlt']);
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

        // TODO: Доработать
        Col:=FirstCol;
        i:=0;
        while i<AGrpList.Count do
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

          ExportGroup(TGroup(AGrpList[i]),outSh,Col);

          inc(Col);
          inc(i);
        end; // while
        
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
end;  // function XExportNotResTable

end.
