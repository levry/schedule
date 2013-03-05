{
  Модуль доступа к данным (wimport)
  v0.0.3  (11/10/06)
}
unit ImportModule;

interface

uses
  SysUtils, Classes, DB, ADODB,
  kbmMemTable,
  BaseModule, STypes, WIOptions;

type
  TdmImport = class(TBaseDataModule)
    spImport2: TADOCommand;
    GroupTable: TkbmMemTable;
    Group_RecState: TWordField;
    Group_grid: TLargeintField;
    Group_grName: TStringField;
    Group_kid: TLargeintField;
    Group_kName: TStringField;
    Group_studs: TSmallintField;
    Group_course: TWordField;
    Group_ynum: TSmallintField;
    Group_flags: TWordField;
    WorkplanTable: TkbmMemTable;
    Workplan_wpid: TLargeintField;
    Workplan_grid: TLargeintField;
    Workplan_grName: TStringField;
    Workplan_sbid: TLargeintField;
    Workplan_sbName: TStringField;
    Workplan_kid: TLargeintField;
    Workplan_kName: TStringField;
    Workplan_Sem: TWordField;
    Workplan_sbCode: TStringField;
    Workplan_WP1: TWordField;
    Workplan_WP2: TWordField;
    Workplan_TotalHLP: TIntegerField;
    Workplan_TotalAHLP: TIntegerField;
    Workplan_Compl: TIntegerField;
    Workplan_Lec1: TWordField;
    Workplan_Prc1: TWordField;
    Workplan_Lab1: TWordField;
    Workplan_Lec2: TWordField;
    Workplan_Prc2: TWordField;
    Workplan_Lab2: TWordField;
    Workplan_Kp: TWordField;
    Workplan_Kr: TWordField;
    Workplan_Rg: TWordField;
    Workplan_Cr: TWordField;
    Workplan_Hr: TWordField;
    Workplan_Koll: TWordField;
    Workplan_Z: TWordField;
    Workplan_E: TWordField;
    WorkplanSource: TDataSource;
    GroupSource: TDataSource;
    Group_chkyear: TBooleanField;
    spSubjMgm: TADOCommand;
    spDBView: TADOCommand;
    Workplan_RecState: TWordField;
    LogTable: TkbmMemTable;
    Log_MsgType: TIntegerField;
    Log_Msg: TStringField;
    Log_grName: TStringField;
    Log_xValue: TStringField;
    Log_sem: TWordField;
    LogSource: TDataSource;
    LogTablekName: TStringField;
    Log_xSet: TSmallintField;
    procedure DataModuleCreate(Sender: TObject);
    procedure GroupTableBeforeDelete(DataSet: TDataSet);
    procedure Log_MsgGetText(Sender: TField; var Text: String;
      DisplayText: Boolean);
    procedure MemoryTableAfterPost(DataSet: TDataSet);

  private
    { Private declarations }
    FSem: byte;
    FChecked: boolean;

    procedure Set_Sem(Value: byte);

  private
    function grp_GetID(grName: string): int64;
    function kaf_GetID(kName: string): int64;
    function sbj_GetID(sbName: string): int64;
    function chk_YearData(ynum: word): boolean;
    function sbj_GetLetter(letter: string): _Recordset;
    function dbv_GetKaf: _Recordset;
    function grp_Create(grName: string; kid: int64; studs,course: byte; ynum: word): int64;
    function wp_Create2(grid: int64; sem: byte; sbid: int64; kid: int64;
      sbCode: string; wp1,wp2: byte; TotalHLP,TotalAHLP,Compl: integer;
      Kp,Kr,Rg,Cr,Hr,Koll,z,e: byte): int64;
    function ld_Create(wpid: int64; psem,ltype,hours:byte): int64;

//    procedure GetSubjectList(Letter: char; List: TStrings);

  private
    procedure LogClear;
    procedure LogMsg(MsgType: TLogMsgType; Msg, Value: string);
    procedure LogMsgGrp(MsgType: TLogMsgType; Msg, Value, Group: string);
    procedure LogMsgWP(MsgType: TLogMsgType; Msg, Value: string; Target: array of const);

  protected
    { Protected declarations }
    function DoConnect: integer; override;
    procedure DoDisconnect; override;

  public
    { Public declarations }
    property Sem: byte read FSem write Set_Sem;

    function IsChecked: boolean;

    procedure ChangeKafedra(ADataSet: TDataSet);
    procedure ChangeSubject(ADataSet: TDataSet);

    procedure DoLoadData(category: TImportCategory);
    procedure DoCheckData;
    procedure DoImportData;
    procedure DoClearData;

    procedure DoLocateLog;

  end;

var
  dmImport: TdmImport;

implementation

uses
  Windows, Variants, ADOInt, Dialogs,
  SConsts, SDBUtils, SStrings, SUtils,
  LoadExcelDataDlg, StringListDlg, SubjectListDlg;

{$R *.dfm}

const
  GROUP_SET    = 1;
  WORKPLAN_SET = 2;


{ TdmImport }

function TdmImport.DoConnect: integer;
begin
  Result:=ERROR_CON_SUCCESS;
end;

procedure TdmImport.DoDisconnect;
begin
end;


procedure TdmImport.DataModuleCreate(Sender: TObject);
begin
  FChecked:=false;
  FSem:=1;

  LogTable.Open;
  GroupTable.Open;
  WorkplanTable.Open;
  WorkplanTable.Filter:='[Sem]=1';
  WorkplanTable.Filtered:=true;
end;

procedure TdmImport.Set_Sem(Value: byte);
begin
  if Value<>FSem then
  begin
    FSem:=Value;
    if WorkplanTable.State=dsEdit then WorkplanTable.Cancel;
    WorkplanTable.Filtered:=false;
    WorkplanTable.Filter:=Format('[Sem]=%d',[FSem]);
    WorkplanTable.Filtered:=true;
  end;
end;

// завершенность проверки данных
function TdmImport.IsChecked: boolean;
begin
  Result:=(FChecked and Connection.Connected and not GroupTable.IsEmpty);
end;

// определение ID группы (29.06.06)
function TdmImport.grp_GetID(grName: string): int64;
var
  value: Variant;
  res: integer;
begin
  Assert(grName<>'',
    '5868AAFA-A2CB-4BD4-BEB4-E85410C39B94'#13'grp_GetID: grName is empty string'#13);

  res:=_ExecSP(spImport2,['@case','@grName'],[impGetGRID,grName],'@grid',value);
  if res=0 then
    if not VarIsNull(value) then Result:=value else Result:=0
  else Result:=-1;
end;

// определение ID кафедры (29.06.06)
function TdmImport.kaf_GetID(kName: string): int64;
var
  value: Variant;
  res: integer;
begin
  Assert(kName<>'',
    '14101A65-E190-4614-92E3-6BBED239569E'#13'kaf_GetID: kName is empty string'#13);

  res:=_ExecSP(spImport2,['@case','@kName'],[impGetKID,kName],'@kid',value);
  if res=0 then
    if not VarIsNull(value) then Result:=value else Result:=0
  else Result:=-1;
end;

// определение ID дисциплины (29.06.06)
function TdmImport.sbj_GetID(sbName: string): int64;
var
  value: Variant;
  res: integer;
begin
  Assert(sbName<>'',
    '28AC959D-8576-4A9D-83AD-2064AC623E8C'#13'sbj_GetID: sbName is empty string'#13);

  res:=_ExecSP(spImport2,['@case','@sbName'],[impGetSBID,sbName],'@sbid',value);
  if res=0 then
    if not VarIsNull(value) then Result:=value else Result:=0
  else Result:=-1;
end;

// проверка данных учеб. года (29.06.06)
function TdmImport.chk_YearData(ynum: word): boolean;

begin
  Assert(ynum>0,
    '90F706E1-53E8-4CC8-BD96-62E5A490DAB6'#13'chk_YearData: invalid ynum'#13);

  Result:=(ExecSP(spImport2,['@case','@ynum'],[impChkYear,ynum])=0);
end;

// Выбор всех кафедр (13.08.2004)
function TdmImport.dbv_GetKaf: _Recordset;
begin
  Result:=_OpenSP(spDBView,['@case'],[dbvSelKaf]);
end;

// выбор дисциплин по 1ой букве
function TdmImport.sbj_GetLetter(letter: string): _Recordset;
begin
  Result:=OpenSP(spSubjMgm, ['@case','@letter'], [sbjSelLetter,letter]);
end;

// добавление группы (01.07.06)
function TdmImport.grp_Create(grName: string; kid: int64; studs,
  course: byte; ynum: word): int64;
var
  value: Variant;
  res: integer;
begin
  Assert(grName<>'',
    'BD6CE182-2890-4412-B9DD-F131150D0D5E'#13'grName is empty string'#13);
  Assert(kid>0,
    '03B97B37-1CBA-4155-B2B3-9B77967FC6AC'#13'Invalid kid'#13);
  Assert(studs>0,
    'F16EDD1E-62A7-41FF-9944-C3ADFAB5E424'#13'Invalid studs'#13);
  Assert((course>=1) and (course<=6),
    'AB482631-BBAC-46B7-9A5F-B468E4D0FA00'#13'Invalid course'#13);

  res:=_ExecSP(spImport2,['@case','@grName','@kid','@studs','@course','@ynum'],
    [impAddGroup,grName,kid,studs,course,ynum],'@grid',value);
  if res=0 then
    if not VarIsNull(value) then Result:=value else Result:=0
  else Result:=-1;

end;

// добавление ауд. нагрузки (01.07.06)
function TdmImport.ld_Create(wpid: int64; psem, ltype, hours: byte): int64;
var
  value: Variant;
  res: integer;
begin
  Assert(wpid>0,
    '89C49BA6-ABA6-40F7-8A20-47135FB01F48'#13'Invalid wpid'#13);
  Assert(psem in [1,2],
    'BB5E2F35-BFD8-44D3-9078-A054E784537E'#13'Invalid psem'#13);
  Assert(ltype in [1,2,3],
    '2888E806-6A1B-443C-A5E8-791C095D009C'#13'Invalid ltype'#13);
  Assert(hours>0,
    'E56F6717-834E-4150-804E-68D7B8826FB6'#13'Invalid hours'#13);

  res:=_ExecSP(spImport2,['@case','@wpid','@psem','@type','@hours'],
    [impAddLoad,wpid,psem,ltype,hours],'@lid',value);
  if res=0 then
    if not VarIsNull(value) then Result:=value else Result:=0
  else Result:=-1;

end;

// добавление уч. дисциплиены (01.07.06)
function TdmImport.wp_Create2(grid: int64; sem: byte; sbid, kid: int64;
  sbCode: string; wp1, wp2: byte; TotalHLP, TotalAHLP, Compl: integer; Kp,
  Kr, Rg, Cr, Hr, Koll, z, e: byte): int64;
var
  value: Variant;
  res: integer;
begin
  Assert(grid>0,
    'E90799A9-519D-49CA-85DB-670553EE3ECF'#13'invalid grid'#13);
  Assert(sem in [1,2],
    '2DCB728F-BF70-4A1E-B811-147F9EF236EA'#13'invalid sem'#13);
  Assert(sbid>0,
    'DFF7345F-0152-4C34-B818-B1EFF987883C'#13'invalid sbid'#13);
  Assert(kid>0,
    '09296CBD-E71F-43CF-AF7B-0195AB20EA87'#13'invalid kid'#13);

  res:=_ExecSP(spImport2,['@case','@grid','@sem','@sbid','@kid',
    '@sbCode','@wp1','@wp2','@TotalHLP','@TotalAHLP','@Compl',
    '@Kp','@Kr','@Rg','@Cr','@Hr','@Koll','@z','@e'],
    [impAddWorkplan,grid,sem,sbid,kid,sbCode,wp1,wp2,TotalHLP,TotalAHLP,
    Compl,Kp,Kr,Rg,Cr,Hr,Koll,z,e],'@wpid',value);
  if res=0 then
    if not VarIsNull(value) then Result:=value else Result:=0
  else Result:=-1;
end;

// загрузка данных (29.06.06)
procedure TdmImport.DoLoadData(category: TImportCategory);
begin
  FChecked:=false;
  ShowLoadExcelDlg(category.buildXLSchema, GroupTable, WorkplanTable);
end;

// проверка данных (29.06.06)
procedure TdmImport.DoCheckData;

  // проверка данных группы
  function CheckGroup: boolean;
  var
    id: int64;
    grName: string;
  begin
    Result:=true;

    grName:=GroupTable.FieldByName('grName').AsString;

    GroupTable.Edit;

    // проверка данных учеб. года
    Result:=chk_YearData(GroupTable.FieldByName('ynum').AsInteger);
    GroupTable.FieldByName('chkyear').Value:=Result;

    if not Result then
      LogMsgGrp(lmtWarning, rsLogInvalidYear,
          GroupTable.FieldByName('ynum').AsString, grName);

    // проверка отсутствия группы в БД
    id:=grp_GetID(grName);
    GroupTable.FieldByName('grid').Value:=id;
    Result:=Result and (id=0);

    if id>0 then
      LogMsgGrp(lmtWarning, rsLogExistsGrp, grName, grName);

    // проверка присутствия кафедры-заказчика в БД
    id:=kaf_GetID(GroupTable.FieldByName('kName').AsString);
    GroupTable.FieldByName('kid').Value:=id;
    Result:=Result and (id>0);

    if not (id>0) then
      LogMsgGrp(lmtWarning, rsLogUnknownKaf,
          GroupTable.FieldByName('kName').AsString, grName);

    if GroupTable.Modified then GroupTable.Post else GroupTable.Cancel;

  end;

  // проверка данных рабочего плана
  function CheckWorkplan: boolean;
  var
    id: int64;
  begin
    Result:=true;

    WorkplanTable.Edit;
    // проверка наличия дисциплины в БД
    id:=sbj_GetID(WorkplanTable.FieldByName('sbName').AsString);
    WorkplanTable.FieldByName('sbid').Value:=id;
    Result:=Result and (id>0);

    if not (id>0) then
      LogMsgWP(lmtWarning, rsLogUnknownSbj,WorkplanTable.FieldByName('sbName').AsString,
          [WorkplanTable.FieldByName('grName').AsString,
          WorkplanTable.FieldByName('sbName').AsString,
          WorkplanTable.FieldByName('Sem').AsInteger]);

    // проверка наличия кафедры-исполнителя в БД
    id:=kaf_GetID(WorkplanTable.FieldByName('kName').AsString);
    WorkplanTable.FieldByName('kid').Value:=id;
    Result:=Result and (id>0);

    if not (id>0) then
      LogMsgWP(lmtWarning, rsLogUnknownKaf, WorkplanTable.FieldByName('kName').AsString,
          [WorkplanTable.FieldByName('grName').AsString,
          WorkplanTable.FieldByName('sbName').AsString,
          WorkplanTable.FieldByName('Sem').AsInteger]);

    if WorkplanTable.Modified then WorkplanTable.Post
      else WorkplanTable.Cancel;

  end;

var
  chk: boolean;

begin
  chk:=true;

  LogClear();

  LogMsg(lmtInfo,rsLogCheckData,'');

//  GroupTable.DisableControls;
  WorkplanTable.DisableControls;
  WorkplanTable.Filtered:=false;

  try

    GroupTable.First;
    while not GroupTable.Eof do
    begin
      if not CheckGroup() then chk:=false;

      WorkplanTable.First;
      while not WorkplanTable.Eof do
      begin
        if not CheckWorkplan() then chk:=false;
        WorkplanTable.Next;
      end;

      GroupTable.Next;
    end;
  finally
    WorkplanTable.Filtered:=true;
//    GroupTable.EnableControls;
    WorkplanTable.EnableControls;
  end;

  if chk then LogMsg(lmtInfo,rsLogCheckSuccess,'')
    else LogMsg(lmtInfo,rsLogCheckFault,'');

  FChecked:=chk;
end;

// импорт данных
procedure TdmImport.DoImportData;

  function ImportGroup(var id: int64): boolean;
  var
    grName: string;
  begin
    Assert(GroupTable.FieldByName('RecState').AsInteger=1,
      '488A779B-BDDE-44B8-AB2C-6E7B777B2FDD'#13'GroupTable: Temporary record'#13);
    Assert(GroupTable.FieldByName('grid').AsInteger=0,
      '582B66CB-C3D4-4C95-B99B-4702E7E1AB1D'#13'Exists group'#13);

    Result:=false;
    with GroupTable do
    begin
      grName:=FieldByName('grName').AsString;

      LogMsg(lmtInfo,Format(rsLogImportGrp,[grName]),'');

      id:=grp_Create(grName,
              FieldByName('kid').AsInteger,
              FieldByName('studs').AsInteger,
              FieldByName('course').AsInteger,
              FieldByName('ynum').AsInteger);

      Result:=(id>0);
      if Result then
      begin
        Edit;
        FieldByName('grid').Value:=id;
        Post;
      end;

    end;  // with(GroupTable)

  end;  // function ImportGroup

  function ImportWorkplan(grid: int64): boolean;
  const
    FieldNames: array[1..2,1..3] of string =
        (('Lec1','Prc1','Lab1'),('Lec2','Prc2','Lab2'));
  var
    wpid,lid: int64;
    p,t,h: byte;
  begin
    Assert(grid>0,
      '8972B2CF-45BC-4620-B824-A3E957FCAF74'#13'ImportWorkplan: invalid grid'#13);
      
    wpid:=0;
    lid:=0;
    Result:=true;

    LogMsg(lmtInfo, Format(rsLogImportWP,[GroupTable.FieldByName('grName').AsString]), '');

    while not WorkplanTable.Eof do
    begin
      with WorkplanTable do
      begin
        wpid:=wp_Create2(grid,
            FieldByName('sem').Value,
            FieldByName('sbid').Value,
            FieldByName('kid').Value,
            FieldByName('sbCode').Value,
            FieldByName('wp1').Value,
            FieldByName('wp2').Value,
            FieldByName('TotalHLP').Value,
            FieldByName('TotalAHLP').Value,
            FieldByName('Compl').Value,
            FieldByName('Kp').Value,
            FieldByName('Kr').Value,
            FieldByName('Rg').Value,
            FieldByName('Cr').Value,
            FieldByName('Hr').Value,
            FieldByName('Koll').Value,
            FieldByName('z').Value,
            FieldByName('e').Value);

        Result:=(wpid>0);
        if Result then
        begin
          try
            // добавление ауд. нагрузки
            for p:=1 to 2 do
              for t:=1 to 3 do
              begin
                h:=FieldByName(FieldNames[p,t]).Value;
                if h>0 then
                begin
                  lid:=ld_Create(wpid,p,t,h);
                  if not (lid>0) then
                    raise Exception.Create(rsLogErrImportLd);
                end;
              end;
          except
            on E: Exception do
            begin
              LogMsg(lmtError,Format(rsLogErrImportSbj,[FieldByName('sbName').AsString]),'');
              LogMsg(lmtError,E.Message,'');
              Result:=false;
            end;
          end;
        end  // if(wpid>0)
        else LogMsg(lmtError,Format(rsLogErrImportSbj,[FieldByName('sbName').AsString]),'');

      end;  // with(WorkplanTable)

      if not Result then break;

      WorkplanTable.Next;
    end;  // while (not WorkplanTable.Eof)

  end;  // function ImportWorkplan

  procedure CompleteImport(Imported: boolean);
  begin
    GroupTable.First;
    while not GroupTable.Eof do
    begin
      GroupTable.Edit;
      if not Imported then GroupTable.FieldByName('grid').Value:=0
        else GroupTable.FieldByName('RecState').Value:=2;
      GroupTable.Post;
      while not WorkplanTable.Eof do
      begin
        WorkplanTable.Edit;
        if not Imported then WorkplanTable.FieldByName('wpid').Value:=0
          else WorkplanTable.FieldByName('RecState').Value:=2;
        WorkplanTable.Post;
        WorkplanTable.Next;
      end;
      GroupTable.Next;
    end;  // while
  end;  // procedure CompleteImport


var
  grid: int64;
  err: boolean;

begin
  Assert(GroupTable.RecordCount>0,
    '18F5A941-2BAA-4920-9202-260F75C1120C'#13'GroupTable is empty'#13);
  Assert(WorkplanTable.RecordCount>0,
    '78D79336-AD77-4A0B-8783-69B6358A8767'#13'Workplan is empty'#13);

  grid:=0;
  err:=false;

  LogClear;

  LogMsg(lmtInfo,rsLogImportData,'');

  GroupTable.First;

  WorkplanTable.DisableControls;
  WorkplanTable.Filtered:=false;
  try

    Connection.BeginTrans;
    try

      try
        while not GroupTable.Eof do
        begin

          if ImportGroup(grid) then
          begin

            WorkplanTable.First;
            while not WorkplanTable.Eof do
            begin
              if not ImportWorkplan(grid) then
                raise Exception.Create('Ошибка при импорте дисциплины');
              WorkplanTable.Next;
            end;

          end
          else raise Exception.Create('Ошибка при импорте группы');

          GroupTable.Next;
        end;
      except
        on E: Exception do
        begin
          LogMsg(lmtError,E.Message,'');
          err:=true;
        end;
      end;

    finally
      if err then Connection.RollbackTrans else Connection.CommitTrans;
      CompleteImport(not err);
    end;

  finally
    WorkplanTable.Filtered:=true;
    WorkplanTable.EnableControls;
  end;

  if not err then LogMsg(lmtInfo,rsLogImportSuccess,'')
    else LogMsg(lmtError,rsLogImportFault,'');
end;

// удаление всех данных (05.07.06)
procedure TdmImport.DoClearData;
begin
  GroupTable.EmptyTable;
  WorkplanTable.EmptyTable;
end;

procedure TdmImport.GroupTableBeforeDelete(DataSet: TDataSet);
var
  i: integer;
  list: TList;
  ds: TDataSet;
  f: boolean;
begin
  list:=TList.Create;
  try
    DataSet.GetDetailDataSets(list);

    for i:=0 to list.Count-1 do
    begin
      ds:=TDataSet(list[i]);
      ds.DisableControls;
      try
        f:=ds.Filtered;
        ds.Filtered:=false;
        ds.First;
        while not ds.Eof do ds.Delete;
        ds.Filtered:=f;
      finally
        ds.EnableControls;
      end;
    end;

  finally
    list.Free;
  end;
{
  WorkplanTable.DisableControls;
  try
    WorkplanTable.Filtered:=false;
    WorkplanTable.First;
    while not WorkplanTable.Eof do WorkplanTable.Delete;
    WorkplanTable.Filtered:=true;
  finally
    WorkplanTable.EnableControls;
  end;
}
end;

// изм-ние кафедры (01.07.06)
procedure TdmImport.ChangeKafedra(ADataSet: TDataSet);

  procedure GetKafedraList(AList: TStringList);
  var
    rs: _Recordset;
    s: string;
  begin
    rs:=dbv_GetKaf();
    if Assigned(rs) then
    try
      AList.Clear;
      while not rs.EOF do
      begin
        s:=VarToStr(rs.Fields['kid'].Value)+'='+VarToStr(rs.Fields['kName'].Value);
        AList.Add(s);
        rs.MoveNext;
      end;
    finally
      rs.Close;
      rs:=nil;
    end;
  end;  // procedure GetKafedraList

var
  list: TStringList;
  s: string;

begin
  list:=TStringList.Create;
  try
    GetKafedraList(list);

    if GetStrFromList(rsKafedra,'',s,list) then
    begin
      ADataSet.Edit;
      ADataSet.FieldByName('kid').Value:=GetID(s);
      ADataSet.FieldByName('kName').Value:=GetValue(s);
//      if ADataSet.State=dsEdit then
//        if ADataSet.Modified then ADataSet.Post;
    end;
  finally
    list.Free;
  end;
end;

// Удалено, исп-ся sbj_GetLetter
{
// выборка дисциплин (01.07.06)
procedure TdmImport.GetSubjectList(Letter: char; List: TStrings);
var
  rs: _Recordset;
  s: string;
begin
  List.Clear;

  rs:=sbj_GetLetter(letter);

  if Assigned(rs) then
  try
    while not rs.EOF do
    begin
      s:=VarToStr(rs.Fields['sbid'].Value)+'='+VarToStr(rs.Fields['sbName'].Value);
      List.Add(s);
      rs.MoveNext;
    end;
  finally
    rs.Close;
    rs:=nil;
  end;
end;
}

// изм-ние дисциплины (01.07.06)
procedure TdmImport.ChangeSubject(ADataSet: TDataSet);
var
  c: char;
  s: string;
begin
  s:=ADataSet.FieldByName('sbName').AsString;
  if Length(s)>0 then c:=s[1] else c:='а';

  if GetSubjectFromList(c, sbj_GetLetter, s) then
  begin
    ADataSet.Edit;
    ADataSet.FieldByName('sbid').Value:=GetID(s);
    ADataSet.FieldByName('sbName').Value:=GetValue(s);
//    if ADataSet.State=dsEdit then
//      if ADataSet.Modified then ADataSet.Post;
  end;
end;

// очистка лога (04.07.06)
procedure TdmImport.LogClear;
begin
  LogTable.EmptyTable;
end;

// добавление события
procedure TdmImport.LogMsg(MsgType: TLogMsgType; Msg, Value: string);
begin
  LogTable.Append;
  LogTable.FieldByName('MsgType').Value:=integer(MsgType);
  LogTable.FieldByName('Msg').Value:=Msg;
  LogTable.FieldByName('xValue').Value:=Value;
  LogTable.Post;
end;

// добавление события (для группы)
procedure TdmImport.LogMsgGrp(MsgType: TLogMsgType; Msg, Value, Group: string);
begin
  LogTable.Append;
  LogTable.FieldByName('MsgType').Value:=integer(MsgType);
  LogTable.FieldByName('Msg').Value:=Msg;
  LogTable.FieldByName('xSet').Value:=GROUP_SET;
  LogTable.FieldByName('xValue').Value:=Value;
  LogTable.FieldByName('grName').Value:=Group;
  LogTable.Post;
end;

// добавление события (для р.п.)
procedure TdmImport.LogMsgWP(MsgType: TLogMsgType; Msg, Value: string;
  Target: array of const);
var
  i: integer;
begin
  LogTable.Append;
  LogTable.FieldByName('MsgType').Value:=integer(MsgType);
  LogTable.FieldByName('Msg').Value:=Msg;
  LogTable.FieldByName('xSet').Value:=WORKPLAN_SET;
  LogTable.FieldByName('xValue').Value:=Value;
  for i:=0 to High(Target) do
    case i of
      0:  // grName
        LogTable.FieldByName('grName').Value:=string(Target[i].VAnsiString);
      1:  // sbName
        LogTable.FieldByName('sbName').Value:=string(Target[i].VAnsiString);
      2:  // sem
        LogTable.FieldByName('Sem').Value:=Target[i].VInteger;
      else raise Exception.CreateFmt('LogMsg: array index can not be %d',[i]);
    end;
  LogTable.Post;

end;

// переход к источнику ошибки (предупреждения)
procedure TdmImport.DoLocateLog;
var
  grName, sbName: string;
  
begin
  if not LogTable.IsEmpty then
  begin

    if LogTable.FieldByName('MsgType').AsInteger=Ord(lmtWarning) then
    begin
      WorkplanTable.DisableControls;
      try
        Assert(not LogTable.FieldByName('grName').IsNull,
          '4E68B13D-76BD-4E97-8517-2363662A8BC6'#13'DoLocateLog: Field[grName] is null'#13);
          
        grName:=LogTable.FieldByName('grName').AsString;
        if GroupTable.Locate('grName',grName,[loCaseInsensitive]) then
          if LogTable.FieldByName('xSet').AsInteger=WORKPLAN_SET then
          begin

            sbName:=LogTable.FieldByName('sbName').AsString;
            FSem:=LogTable.FieldByName('sem').Value;
            WorkplanTable.Filtered:=false;
            WorkplanTable.Filter:=Format('[Sem]=%d',[FSem]);
            WorkplanTable.Filtered:=true;

            WorkplanTable.Locate('grName;sbName;Sem',
                VarArrayOf([grName,sbName,FSem]),[loCaseInsensitive]);


          end;  // if(Workplan_set)
      finally
        WorkplanTable.EnableControls;
      end;
    end;  // if(warning)

  end;  // if(not IsEmpty)
end;

procedure TdmImport.Log_MsgGetText(Sender: TField; var Text: String;
  DisplayText: Boolean);
var
  DataSet: TDataSet;

begin
  DataSet:=Sender.DataSet;
  case DataSet.FieldByName('MsgType').AsInteger of
    0:  // info
      Text:=Sender.AsString;

    1,  // warning
    2:  // error
      Text:=Format(Sender.AsString, [DataSet.FieldByName('xValue').AsString]);

    else
      raise Exception.CreateFmt('Unknown type message [MsgType=%d]',
          [DataSet.FieldByName('MsgType').AsInteger]);

  end;  // case
end;

procedure TdmImport.MemoryTableAfterPost(DataSet: TDataSet);
begin
  FChecked:=false;
end;

end.
