unit ExportTimeTable2;

interface

uses
  SClasses, SCategory;

procedure DoExportTimeTable(ASchedule: TSchedule; AOptions: TExportTableCategory);

implementation

uses
  Classes, Controls, Windows, Forms, Graphics, Dialogs, Variants, SysUtils,
  OleServer, ActiveX, Excel2000, Office2000,
  SUtils, SStrings, PageDlg, ExportSourcePage, ExportTablePage;

const
  xlLCID = LOCALE_USER_DEFAULT;

  xl_rpp  = 3;            // ���-�� ����� �� ����
  xl_fcol = 4;            // 1�� �������
  xl_frow = 5;            // 1�� ������
  xl_lcol = 22;           // ��������� �������
  xl_lrow = 135;          // ��������� ������
  xl_grow = 4;            // ������ �������� �����


function XExportTimeTable(AShedule: TSchedule; AGrpList: TList;
    AOptions: TExportTableCategory; AFileName: string): boolean; forward;

procedure DoExportTimeTable(ASchedule: TSchedule; AOptions: TExportTableCategory);
var
  frmDlg: TfrmPageDlg;
  SourceFrame: TfrmExportSourcePage;
  ExportFrame: TfrmExportTablePage;

  GrpList: TList;
begin
  frmDlg:=TfrmPageDlg.Create(Application);
  try
    frmDlg.Caption:='������� ���������� �������';

    SourceFrame:=frmDlg.AddPage('��������',TfrmExportSourcePage) as TfrmExportSourcePage;
    SourceFrame.AssignList(ASchedule);
    ExportFrame:=frmDlg.AddPage('����������',TfrmExportTablePage) as TfrmExportTablePage;
    ExportFrame.Options:=AOptions;

    if frmDlg.ShowModal=mrOk then
    begin
      GrpList:=TList.Create;
      try
        if SourceFrame.GetObjectList(GrpList)>0 then;
          XExportTimeTable(ASchedule,GrpList,AOptions,SourceFrame.FileName);
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

      // �������� ������ (�� ���� 2000 (v9))
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

// ������� ���������� ������� � Excel
function XExportTimeTable(AShedule: TSchedule; AGrpList: TList;
    AOptions: TExportTableCategory; AFileName: string): boolean;

var
  xApp: TExcelApplication;

  // ���������� ����� ������, ���������. ����. ����
  function ToRowXL(iday,ipair: byte): integer;
  begin
    Result:=iday*(NumberPairs*xl_rpp+1)+ipair*xl_rpp+xl_frow;
//    Result:=iday*NumberPairs*xl_rpp+ipair*xl_rpp+xl_frow+iday;
  end;

  // ���������� ��-� (����������,���������,����-��) �� �������
  function GetElement(AIndex: integer; ALsns: TLsns): string;
  begin
    case AOptions.GetElement(AIndex) of
      etSubject:  Result:=ALsns.subject;
      etAuditory: Result:=ALsns.auditory;
      etTeacher:  Result:=ALsns.teacher;
    else Result:='';
    end;
  end;

  // ���������� id ��-�� (����.,�����.,����-��) �� �������)
  function GetElementId(AIndex: integer; ALsns: TLsns): int64;
  begin
    case AOptions.GetElement(AIndex) of
      etSubject:  Result:=ALsns.sbid;
      etAuditory: Result:=ALsns.aid;
      etTeacher:  Result:=ALsns.tid;
    else Result:=0;
    end;
  end;

  // ������� ������
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

    // TODO: ����������: �� ������������ ���. ������� 
    // ���� ������ = �������
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
        // ���������� ������ �������
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

        // �������������� ������
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

    // ����� ������� (��� �������)
    procedure FormatLsns(ARow: integer; ALsns: TLsns; ASingle: boolean);

      // �������� ������ ������ ��� ������
      function CheckWidth(ACell: ExcelRange; const s: string): boolean;
      var
        aw, cw: integer;
      begin
        Result:=true;

        cw:=ACell.ColumnWidth;
        ACell.Value:=s;
        ACell.Columns.AutoFit;
        aw:=ACell.ColumnWidth;
        if aw>cw then
          if aw>cw*(1+AOptions.SmallPercent/100) then Result:=false
            else ACell.ShrinkToFit:=true;
        ACell.ColumnWidth:=cw;
      end;

      // ���� ������ = ��-� ������� (�������,���������,����-��)
      procedure FormatCell(ACell: ExcelRange; ALsns: TLsns; AIndex: integer);
      var
        s, small: string;
        fstyle: TFontStyles;
      begin
        ACell.Font.Size:=GetFontSizeElement(AIndex);
        fstyle:=GetFontStyleElement(AIndex);
        ACell.Font.FontStyle:=FontStyleToXL(fstyle);
        //ACell.Interior.Pattern:=AOptions.GetPattern(ALsns.ltype);

        // �������������� ������ ��� ����������
        if AOptions.GetElement(AIndex)=etSubject then
        begin
          s:=SUtils.GetValue(ALsns.subject);
          if not CheckWidth(ACell, s) then
          begin
            small:=SUtils.GetTag(ALsns.subject);
            if small<>'' then
            begin
              if not CheckWidth(ACell,small) then s:=Copy(s,1,15)+'...'
                else s:=small
            end
            else s:=Copy(s,1,15)+'...';
          end else
            // ���� ������ ���-��, �� ����������� ����������
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
          if ALsns.subgrp then s:='1/2 ��.  '+s;
          if ALsns.parity=1 then s:=s+'  ��' else
            if ALsns.parity=2 then s:=s+'  ��';
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
        // ����� � 1� ������
        IDispatch(IR):=ASheet.Cells.Item[ARow,ACol];
        FormatSingle(IR,ALsns,' ');
      end
      else
        // ����� �� ���������
        for i:=0 to xl_rpp-1 do
        begin
          IDispatch(IR):=ASheet.Cells.Item[ARow+i,ACol];
          FormatCell(IR,ALsns,i);
        end
    end; // procedure FormatLsns

    // ����� �������� ������ (+������� (��� ������� ��� ��������))
    procedure FormatParity(ARow, ACount: integer; ALsns: TLsns);

      // ����� ������� ������� ��� ����������
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

    // �������������� ����. ���� (�/�)
    procedure FormatDoublePair(ARow: integer; ALsns: TLsns);
    var
      i: integer;
      IR, IR2: ExcelRange;
    begin
      Assert(not ALsns.Parent.IsSplited, '374FBA0A-76F6-46BE-BB7D-D1B72D1BCFE4');
      Assert(ALsns.Parent.Count=1, '27CA3B33-6BBC-4D50-8652-F183F0426849');
      
      case AOptions.DoubleStyle of

        dsNone:  // ��� ���-��� ���
          for i:=0 to 1 do
          begin
            FormatLsns(ARow+i*xl_rpp, ALsns, false);
            FormatParity(ARow+i*xl_rpp,xl_rpp-1,ALsns);
          end;

        dsShift: // ����� ������� �� ������� �� 1 ������ ����
          begin
            FormatLsns(ARow+1,ALsns,false);
            FormatParity(ARow,2*xl_rpp-1,ALsns);
            //FormatParity(ARow+2*xl_rpp-1,xl_rpp-1,ALsns);
            // �������� �������
            IDispatch(IR):=ASheet.Cells.Item[ARow+xl_rpp-1,ACol];
            IR.Borders.Item[xlEdgeBottom].LineStyle:=xlLineStyleNone;
          end;

        dsFull:  // ���-��� ����� 2� ���
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

    // �������������� ����. ���� (�/�)
    procedure FormatSplittedPair(ARow: integer; APair: TPair);
    var
      i, r: integer;
      lsns: TLsns;
      IR: ExcelRange;
    begin
      Assert(APair.IsSplited, '{03638E96-36FB-4013-B9C6-3AE5729F7FEB}');

      for i:=0 to APair.Count-1 do
      begin
        lsns:=APair.Item[i];
        if lsns.parity>0 then r:=APair.Pair+lsns.parity-1 else r:=APair.Pair;
        FormatLsns(ToRowXL(APair.Day,r),lsns,false);
      end;

      // ������ �������� ������
//      if bSplitted then
      FormatParity(ARow,2*xl_rpp-1,APair.Item[0]);
      //FormatParity(xlRow,2*xl_rpp-1,pair.Item[0].parity);

      // �������� �������
      IDispatch(IR):=ASheet.Cells.Item[ARow+xl_rpp-1,ACol];
      if APair.Count=0 then
        IR.Borders.Item[xlEdgeBottom].LineStyle:=xlLineStyleNone
      else IR.Borders.Item[xlEdgeBottom].LineStyle:=xlDot;

      // ����� ������� "�/�" (���� ���� ����. ���� ����� ������)
      if APair.Count<=1 then
      begin
        r:=APair.Item[0].parity;
        if r=1 then r:=APair.Pair+1 else
          if r=2 then r:=APair.Pair else
            Assert(false, '{B6586A6A-21C4-4280-8FBB-2BD9889B63F5');
        IDispatch(IR):=ASheet.Cells.Item[ToRowXL(APair.Day,r)+1,ACol];
        IR.Font.Bold:=true;
        IR.Font.Size:=12;
        IR.Value:='����� ������';
      end;

    end;  // procedure FormatSplittedPair

    // �������� ������� ����
    function IsDoublePair(APair: TPair): boolean;

      // �������� ������������� ������. �������
      function ExistsNextLsns(NPair: TPair; ALsns: TLsns): boolean;
      var
        i: integer;
        l: TLsns;
      begin
        Result:=false;
        for i:=0 to NPair.Count-1 do
        begin
          l:=NPair.Item[i];
          // �����: lid,parity,aid,tid,subgrp(false)
          if (l.lid=ALsns.lid) and (l.parity=ALsns.parity) and (l.aid=ALsns.aid)
            and (l.tid=ALsns.tid) and (l.subgrp=ALsns.subgrp) and (not l.subgrp) then
          begin
            Result:=true;
            Break;
          end;
        end;
      end;  // function

    var
      i: integer;
      npair: TPair;
    begin
      Result:=false;
      if APair.Pair<6 then
      begin
        npair:=APair.Parent.Item[APair.Day,APair.Pair+1];

        if APair.Count=npair.Count then
        begin
          Result:=true;
          for i:=0 to APair.Count-1 do
            if not ExistsNextLsns(npair,APair.Item[i]) then
            begin
              Result:=false;
              break;
            end;
        end;

      end;  // if Pair<6
    end;  // function IsDoublePair


  var
    xlRow: integer;
    d,p: byte;

    i,r: integer;
    bMultiple: boolean;          // ������� ���������� ������� �� ����
    bSplitted: boolean;          // ������� ����������� ������
    bDoubled: boolean;           // ������� ���� ���

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
          bSplitted:=pair.IsSplited;
          bDoubled:=IsDoublePair(pair);
          xlRow:=ToRowXL(d,p);

          // ���� ������� (�� ������� ����, �� �.�. � �/�)
          if (not bMultiple) and (not bDoubled) then
          begin
            FormatLsns(xlRow, pair.Item[0], false);
            FormatParity(xlRow,xl_rpp-1,pair.Item[0]);
            //if bSplitted then FormatParity(xlRow,xl_rpp-1,pair.Item[0]);
          end

          else
            // ���� ����. ����
            // TODO: ����������: ���� ������ ���-��� �/�, ���� ���-��� ������ 2� ���
            if bDoubled then
            begin
              if (not bSplitted) then FormatDoublePair(xlRow, pair.Item[0])
                else FormatSplittedPair(xlRow, pair);
{
              for i:=0 to pair.Count-1 do
              begin
                lsns:=pair.Item[i];
                if lsns.parity>0 then r:=p+lsns.parity-1 else r:=p;
                FormatLsns(ToRowXL(d,r),lsns,false);
              end;

              // ������ �������� ������
              FormatParity(xlRow,2*xl_rpp-1,pair.Item[0]);

              // �������� �������
              IDispatch(IR1):=ASheet.Cells.Item[xlRow+xl_rpp-1,ACol];
              if not bMultiple then
                IR1.Borders.Item[xlEdgeBottom].LineStyle:=xlLineStyleNone
              else IR1.Borders.Item[xlEdgeBottom].LineStyle:=xlDot;

              // ����� ������� �/� (���� ���� ����. ���� ����� ������)
              if (not bMultiple) and (bSplitted) then
              begin
                r:=pair.Item[0].parity;
                if r=1 then r:=p+1 else
                  if r=2 then r:=p else
                    Assert(false, '{B6586A6A-21C4-4280-8FBB-2BD9889B63F5');
                IDispatch(IR1):=ASheet.Cells.Item[ToRowXL(d,r)+1,ACol];
                IR1.Font.Bold:=true;
                IR1.Font.Size:=12;
                IR1.Value:='����� ������';
              end;
}
              inc(p);
            end

            else
              // ���� ������� ��������
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

                //FormatParity(xlRow,xl_rpp,lsns);
                //FormatParity(xlRow,xl_rpp,1);

                //if bSplitted then
                //begin
                //  IDispatch(IR1):=ASheet.Cells.Item[xlRow+1,ACol];
                //  IR1.Borders.Item[xlDiagonalUp].LineStyle:=xlDouble;
                //end;

              end;

{
          // ���� ������� ������ 1
          for i:=0 to xl_rpp-1 do
          begin
            IDispatch(IR1):=ASheet.Cells.Item[xlRow+i,AGrpXL.Column];

            if bMultiple then
            begin
              lsns:=pair.Item[i];
              if Assigned(lsns) then
              begin
                FormatSingle(IR1,lsns);
              end;
            end
              else
                begin
                  s:=SUtils.GetValue(GetElement(i,pair.Item[0]));
                  IR1.Value:=s;
                  FormatCell(IR1,i);
                end

          end; // for
}
        end; // if pair.count>0
        inc(p);
      end; // while pair<7
    end; // for day
  end;  // procedure ExportGroup

  // ����������� �����: ������������� (������ ������)
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
    // ������������� �������� ����. ��-�� (����.,�����.,����-��)
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

        // �����-��� ����� �������� ��� ������� ��-�� �������
        for e:=0 to xl_rpp-1 do
        begin
          i:=0;

          while i<AList.Count do
          begin
            spanx:=1;

            pair:=TGroup(AList.Items[i]).Item[d,p];
            // ���� ������� ���� ..
            if pair.Count=1 then
            begin
              lsns:=pair.Item[0];
              // .. � ��� ��������� (�� �� ���������)
              if (lsns.IsStrm) and (not lsns.subgrp) then

                // ������ ����� ����. ����. ��-��� �������
                for c:=i+1 to AList.Count-1 do
                  if ExistsNextElem(lsns,e,TGroup(AList.Items[c])) then inc(spanx)
                    else break;

              // �����-��� �����, ���� ����� ����. ����. ��-��� > 1
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
          if xSh.Shapes.Count>0 then xShape:=xSh.Shapes.Item(1)
            else xShape:=Null;
          //if not VarIsNull(xShape) then xShape.SetShapesDefaultProperties;

          xlCol:=xl_fcol-1;
          try
            // ����������� �����
            if AOptions.MergeCells then MergeCells(AGrpList,xSh);
            // ����� ���������� �������� ��� �����
            for i:=0 to AGrpList.Count-1 do
            try
              inc(xlCol);
              ExportGroup(TGroup(AGrpList.Items[i]),xlCol,xSh, xShape);
            except
              Result:=false;
              break;
            end;
            // ����������� �����
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
      else ShowMessageFmt(rsExNotFoundXlt, [AOptions.xltFile]);
    end;  // if (XConnect)
  finally
    XDisconnect(xApp);
    xApp.Free;
    xApp:=nil;
  end;
end; // procedure

end.
 