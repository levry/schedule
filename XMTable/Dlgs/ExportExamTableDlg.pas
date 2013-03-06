{
  ������� ���������� ���/���� � Excel
  v0.0.2  (16.05.06)
}
unit ExportExamTableDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Excel2000,
  SExams, StdCtrls, ComCtrls, CheckLst, Buttons;

type
  TfrmExportExamTableDlg = class(TForm)
    PageControl: TPageControl;
    btnOk: TButton;
    btnCancel: TButton;
    tsSource: TTabSheet;
    lbGroups: TCheckListBox;
    chkAllGroups: TCheckBox;
    GroupBox: TGroupBox;
    lblFile: TLabel;
    SaveBtn: TSpeedButton;
    SaveDialog: TSaveDialog;
    procedure SaveBtnClick(Sender: TObject);
    procedure chkAllGroupsClick(Sender: TObject);
    procedure lbGroupsClickCheck(Sender: TObject);
    procedure lbGroupsDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure lbGroupsDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
  private
    { Private declarations }
    FExamTable: TXMTable;                     // ����������-��������
    FFileName: string;                        // �����. ����

    procedure SetExamTable(Value: TXMTable);
    function DoCheckSource: boolean;


  private
    xApp: TExcelApplication;

    function XConnect: boolean;
    procedure XDisconnect;
    procedure XExportTable;

  public
    { Public declarations }
    procedure DoExport;

    property ExamTable: TXMTable read FExamTable write SetExamTable;
  end;

procedure ShowExportExamTableDlg(AExamTable: TXMTable);

implementation

uses
  DateUtils, Types, OleServer, ActiveX, Contnrs, Office2000,
  SUtils, SStrings, STypes;

const
  xlLCID = LOCALE_USER_DEFAULT;

  xl_frow = 6;    // 1�� ������
  xl_fcol = 2;    // 1�� �������
  xl_lcol = 21;   // ��������� �������
  xl_gcol = 1;    // ������� ��� �������� �����
  xl_drow = 5;    // ������ ��� ����
  xl_days = 20;   // ���-�� ����
  xl_rpp  = 6;    // ���-�� ����� �� ����



{$R *.dfm}

// ����� ������� �������� ���������� ���/����
procedure ShowExportExamTableDlg(AExamTable: TXMTable);
var
  frmDlg: TfrmExportExamTableDlg;
begin
  Assert(Assigned(AExamTable),
    'C7D069E7-3224-48BE-A006-C9E19A2F1BB9'#13'ShowExportExamTableDlg: AExamTable is nil'#13);

  frmDlg:=TfrmExportExamTableDlg.Create(Application);
  try
    frmDlg.ExamTable:=AExamTable;

    if frmDlg.ShowModal=mrOk then frmDlg.DoExport;
  finally
    frmDlg.Free;
    frmDlg:=nil;
  end;
end;

{ TfrmExportXMTableDlg }

// ��������� ����������-���������
procedure TfrmExportExamTableDlg.SetExamTable(Value: TXMTable);
var
  i: integer;
begin
  Assert(Assigned(Value),
    '6DB5F397-570C-4F46-8FC8-3D13A3AF33D2'#13'SetExamTable: Value is nil'#13);

  if FExamTable<>Value then
  begin
    FExamTable:=Value;
    for i:=0 to FExamTable.GroupCount-1 do
      lbGroups.AddItem(FExamTable.Groups[i].grName, TObject(i));
  end;
end;

procedure TfrmExportExamTableDlg.SaveBtnClick(Sender: TObject);
begin
  if SaveDialog.Execute then
  begin
    FFileName:=SaveDialog.FileName;
    lblFile.Caption:=FFileName;
    lblFile.Hint:=FFileName;
    btnOk.Enabled:=DoCheckSource;
  end;
end;

procedure TfrmExportExamTableDlg.chkAllGroupsClick(Sender: TObject);
var
  i: integer;
begin
  if Sender is TCheckBox then
    for i:=0 to lbGroups.Count-1 do
      lbGroups.Checked[i]:=TCheckBox(Sender).Checked;
  btnOk.Enabled:=DoCheckSource;
end;

// �������� �� ���� ���� ������
function TfrmExportExamTableDlg.DoCheckSource: boolean;
begin
  Result:=(lblFile.Caption<>'') and (chkAllGroups.State in [cbChecked,cbGrayed]);
end;

procedure TfrmExportExamTableDlg.lbGroupsClickCheck(Sender: TObject);
var
  CheckState: TCheckBoxState;
  check: boolean;
  i: integer;
begin
  if Sender is TCheckListBox then
  begin
    if TCheckListBox(Sender).Count>0 then
    begin
      check:=TCheckListBox(Sender).Checked[0];
      if check then CheckState:=cbChecked else CheckState:=cbUnchecked;
      for i:=1 to TCheckListBox(Sender).Count-1 do
        if TCheckListBox(Sender).Checked[i]<>check then
        begin
          CheckState:=cbGrayed;
          break;
        end;
    end
    else CheckState:=cbUnchecked;
    chkAllGroups.OnClick:=nil;
    chkAllGroups.State:=CheckState;
    chkAllGroups.OnClick:=chkAllGroupsClick;

    btnOk.Enabled:=DoCheckSource;
  end;
end;

procedure TfrmExportExamTableDlg.lbGroupsDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  i: integer;
begin
  if (Sender is TCheckListBox) and (Source is TCheckListBox) then
  begin
    i:=TCheckListBox(Sender).ItemAtPos(Types.Point(X,Y), true);
    if i>=0 then
    begin
      TCheckListBox(Sender).Items.Move(TCheckListBox(Source).ItemIndex,i);
      TCheckListBox(Sender).ItemIndex:=i;
    end;
  end; // if Sender and Source is TCheckListBox
end;

procedure TfrmExportExamTableDlg.lbGroupsDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
var
  i, j: integer;
begin
  if (Sender is TCheckListBox) and (Source is TCheckListBox) then
  begin
    i:=TCheckListBox(Sender).ItemAtPos(Types.Point(X,Y), true);
    j:=TCheckListBox(Source).ItemIndex;
    Accept:=(Sender=Source) and (j<>-1) and (j<>i);
  end;
end;

function TfrmExportExamTableDlg.XConnect: boolean;
var
  s, ver: string;
  i: integer;
begin
  Result:=false;

  xApp := TExcelApplication.create(nil);
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

procedure TfrmExportExamTableDlg.XDisconnect;
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
    FreeAndNil(xApp);
  end;
end;

// ������� ���������� ���/����
procedure TfrmExportExamTableDlg.DoExport;
begin
  if Assigned(FExamTable) then XExportTable;
end;

procedure TfrmExportExamTableDlg.XExportTable;

  // �������� ������ ��������
  function LoadGroup(AList: TList): boolean;
  var
    i: integer;
    grp: TXMGroup;
  begin
    for i:=0 to lbGroups.Count-1 do
      if lbGroups.Checked[i] then
      begin
        grp:=FExamTable.Groups[integer(lbGroups.Items.Objects[i])];
        AList.Add(grp);
      end;
    Result:=(AList.Count>0);
  end;

  // ���������� �����
  procedure FillWorksheet(ASheet: _Worksheet; AList: TList);

    // ���������� �����
    procedure PrepareWorksheet;
    var
      IR1, IR2: ExcelRange;
      cols, rows: integer;
      nums: integer;
      i: integer;
      day: TDateTime;
      s: string;
    begin


      cols:=SizePeriod(FExamTable.Period);
      nums:=xl_days;
      day:=FExamTable.Period.dbegin;

      // ������� �������� ��� ���������� �����
      IDispatch(IR1):=ASheet.Columns.Item[xl_lcol,EmptyParam];
      while cols>nums do
      begin
        IR1.Insert(xlShiftToRight);
        inc(nums);
      end;

      // ���������� �����-����
      for i:=0 to cols-1 do
      begin
        IDispatch(IR1):=ASheet.Cells.Item[xl_drow,xl_fcol+i];
        DateTimeToString(s,'DD MMMM YYYY'#10'DDDD', day);
        IR1.Value:=s;
        // �������������� �����-�����. ����
        if DayOfTheWeek(day)=DaySunday then
        begin
          IDispatch(IR1):=ASheet.Cells.Item[xl_frow,xl_fcol+i];
          IDispatch(IR2):=ASheet.Cells.Item[xl_frow+xl_rpp-1,xl_fcol+i];
          with ASheet.Range[IR1,IR2] do
          begin
            Merge(false);
            Interior.Pattern:=xlGray8;
          end;
        end;
        day:=IncDay(day);
      end;


      // ���������� �����-�����
      rows:=AList.Count;
      nums:=1;

      // ������� �����
      IDispatch(IR1):=ASheet.Rows.Item[xl_frow+xl_rpp-1,EmptyParam];
      while rows>nums do
      begin
        for i:=0 to xl_rpp-1 do IR1.Insert(xlShiftDown);
        inc(nums);
      end;

      // ������� �������� - �������� ������
      for i:=0 to AList.Count-1 do
      begin
        IDispatch(IR1):=ASheet.Cells.Item[xl_frow+xl_rpp*i,xl_gcol];
        IDispatch(IR2):=ASheet.Cells.Item[xl_frow+xl_rpp*(i+1)-1,xl_gcol];
        ASheet.Range[IR1,IR2].Merge(false);
        IR1.HorizontalAlignment:=xlCenter;

        IDispatch(IR2):=ASheet.Cells.Item[xl_frow+xl_rpp*(i+1)-1,xl_fcol+cols-1];
        ASheet.Range[IR1,IR2].Borders.Item[xlEdgeTop].Weight := xlMedium;

        IR1.Value:=TXMGroup(AList[i]).grName;
      end;

    end;  // procedure PrepareWorksheet

    procedure FillExamTable;


      // ���������� ����� ������� ��� ����
      function DateToCol(ADate: TDateTime): integer;
      begin
        Result:=xl_fcol+DaysBetween(ADate, FExamTable.Period.dbegin);
      end;  // function DateToCol


      procedure BuildSingleDate(AGroup: TXMGroup; ADate: TDateTime; AFirstRow: integer);

        procedure BuildSingleExam(AExam: TExam);
        var
          Arr: OleVariant;
          IR1, IR2: ExcelRange;

          rsubject, rteacher, rtime, rauditory: integer;

          col: integer;
          n: integer;

          s: string;
        begin
          Assert(CompareDate(AExam.xmtime, ADate)=EqualsValue,
            'E6677265-807D-4264-813B-4DEDB875E47A'#13'BuildSingleExam: xmtime<>ADate'#13);

          col:=DateToCol(AExam.xmtime);

          // ���-��� ��������� ���-���
          if AExam.xmtype=xmtExam then
          begin
            rsubject:=0;
            rtime:=4;
            rauditory:=5;
            if AExam.GetTeacherCount=2 then rteacher:=2 else rteacher:=3;
          end
          else
          begin
            rsubject:=1;
            rteacher:=2;
            rtime:=3;
            rauditory:=4;
          end;

          Arr:=VarArrayCreate([0,5,0,0], varOleStr);

          if AExam.xmtype=xmtExam then
          begin
            s:=AExam.subject;
            // �������������� ����������
            if rteacher-rsubject>1 then
            begin
              IDispatch(IR1):=ASheet.Cells.Item[AFirstRow, col];
              IDispatch(IR2):=ASheet.Cells.Item[AFirstRow+rteacher-1, col];
              IR1:=ASheet.Range[IR1,IR2];
              IR1.Merge(false);
              IR1.WrapText:=true;
              n:=Length(AExam.subject);
              if n>70 then
              begin
                if AExam.sbsmall<>'' then s:=AExam.sbsmall
              end
              else if n>30 then IR1.Font.Size:=12;
            end;
            Arr[rsubject,0]:=s;
          end
          else Arr[rsubject,0]:=rsCons;

          if rtime-rteacher=2 then
          begin
            Arr[rteacher,0]:=AExam.GetTeacherOfIndex(0);
            Arr[rteacher+1,0]:=AExam.GetTeacherOfIndex(1);
          end
          else Arr[rteacher,0]:=AExam.GetTeacherOfIndex(0);

          DateTimeToString(s, 'HH:nn', AExam.xmtime);
          Arr[rtime,0]:=s;
          Arr[rauditory,0]:=GetValue(AExam.auditory);

          IDispatch(IR1):=ASheet.Cells.Item[AFirstRow, col];
          IDispatch(IR2):=ASheet.Cells.Item[AFirstRow+xl_rpp-1, col];
          ASheet.Range[IR1,IR2].Value:=Arr;

        end;  // procedure BuildSingleExam

        procedure BuildMultipleExam(AExam: TExam; num,index: integer);
        var
          IR: ExcelRange;
          col: integer;
          rpe: integer;      // rows per exam (���-�� ����� ��� ���)
          s: string;
        begin
          Assert(CompareDate(AExam.xmtime,ADate)=EqualsValue,
            '98C8E45D-4570-4B7D-B760-62C1D321231F'#13'BuildMultipleExam: xmtime<>ADate'#13);
          Assert(AExam.xmtype=xmtExam,
            '4A15D411-74F6-4F1F-A86B-AC3CA51175E3'#13'BuildMultipleExam: AExam is Cons'#13);

          col:=DateToCol(AExam.xmtime);
          rpe:=xl_rpp div num;
          if num=2 then
          begin
            // �������������� ����������
            IDispatch(IR):=ASheet.Cells.Item[AFirstRow+index*rpe, col];
            s:=AExam.subject;
            if Length(s)>25 then
              if AExam.sbsmall<>'' then s:=AExam.sbsmall;
            IR.Value:=s;

            // �������������� ����-��
            IDispatch(IR):=ASheet.Cells.Item[AFirstRow+index*rpe+1, col];
            IR.Value:=AExam.teacher;

            // �������������� ������� � ���������
            IDispatch(IR):=ASheet.Cells.Item[AFirstRow+index*rpe+2, col];
            DateTimeToString(s,'HH:nn',AExam.xmtime);
            IR.Value:=Format('%s  %s',[s,GetValue(AExam.auditory)]);

          end
          else
          begin
            // �������������� ����������
            IDispatch(IR):=ASheet.Cells.Item[AFirstRow+index*rpe, col];
            if AExam.sbsmall<>'' then s:=AExam.sbsmall else s:=AExam.subject;
            IR.Value:=s;

            // �������������� ����-��, ������� � ���������
            IDispatch(IR):=ASheet.Cells.Item[AFirstRow+index*rpe+1, col];
            DateTimeToString(s,'HH:nn',AExam.xmtime);
            s:=Format('%s %s %s',[AExam.GetTeacherOfIndex(0),s,GetValue(AExam.auditory)]);
            IR.Value:=s;
          end;
          
          // ����� ������� ����� ���������
          if index<num-1 then
            with IR.Borders.Item[xlEdgeBottom] do
            begin
              LineStyle:=xlDot;
              Weight:=xlThin;
            end;
        end;  // procedure BuildMultipleExam

        // ����� ���������
        procedure BuildMessage(Mes: string);
        var
          col: integer;
          IR1, IR2: ExcelRange;
        begin
          col:=DateToCol(ADate);
          IDispatch(IR1):=ASheet.Cells.Item[AFirstRow,col];
          IDispatch(IR2):=ASheet.Cells.Item[AFirstRow+xl_rpp-1,col];

          with ASheet.Range[IR1,IR2] do
          begin
            Merge(false);
            Font.ColorIndex:=3;
            WrapText:=true;
            Value:=Mes;
          end;
        end;  // procedure BuildMessage

      var
        i: integer;
        n: integer;
        exam: TExam;
      begin
        n:=AGroup.NumOfTime(ADate);
        if n<=3 then
          for i:=0 to n-1 do
          begin
            exam:=AGroup.ExamOfTime(ADate,i);
            if Assigned(exam) then
              if n=1 then BuildSingleExam(exam) else
                if n<=3 then BuildMultipleExam(exam,n,i);
          end
        else BuildMessage(rsExMuchEvents);

      end;  // procedure BuildSingleDate


    var
      i,j,n: integer;
      d: TDateTime;
      group: TXMGroup;
      exam: TExam;
    begin
      for i:=0 to AList.Count-1 do
      begin
        group:=TXMGroup(AList[i]);
        d:=FExamTable.Period.dbegin;
        while d<=FExamTable.Period.dend do
        begin
          n:=group.NumOfTime(d);
          BuildSingleDate(group, d, xl_frow+i*xl_rpp);
          d:=IncDay(d);
        end;
      end;  // for

    end;  // procedure FillExamTable;

  begin
    PrepareWorksheet;

    FillExamTable;
  end;

var
  Groups: TList;        // ������ ������. �����

  xWb: _Workbook;
  xSh: _Worksheet;
  xltfile: string;

begin
  xltfile:=BuildFullName('examtable.xlt');
  if xltfile='' then
  begin
    ShowMessageFmt(rsExNotFoundXlt,['examtable.xlt']);
    Exit;
  end;

  Groups:=TList.Create;
  try

    if LoadGroup(Groups) then
    begin
      if XConnect() then
      try

        xWb:=xApp.Workbooks.Add(xltfile,xlLCID);
        try

          xSh:=xWb.Worksheets.Item['xmtable'] as _Worksheet;
          try
            FillWorksheet(xSh,Groups);
          finally
            xSh:=nil;
          end;

          xWb.Close(true,FFileName,EmptyParam,xlLCID);
        finally
          xWb:=nil;
        end;

      finally
        XDisconnect();
      end;

    end;  // if(LoadGroup)

  finally
    Groups.Free;
  end;
end;

end.
