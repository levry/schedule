{
  Модуль упр-ния раб. планом
  v0.2.3  (01/08/06)
}

unit WorkplanForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Modules, STypes, WorkplanSource, ModelData, cxStyles, cxCustomData,
  cxGraphics, cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData,
  ToolWin, ComCtrls, cxGridLevel, cxClasses, cxControls, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid, ADODB,
  cxButtonEdit, cxCheckBox, cxDropDownEdit, DBData, SConsts, ActnList,
  CustomOptions;

type
  TfrmWorkplan = class(TModuleForm)
    lvlWorkplan: TcxGridLevel;
    cxGrid: TcxGrid;
    ToolBar: TToolBar;
    lvlLoad: TcxGridLevel;
    tvWorkplan: TcxGridTableView;
    tvLoad: TcxGridTableView;
    tvWorkplanColumn1: TcxGridColumn;
    tvWorkplanColumn2: TcxGridColumn;
    tvWorkplanColumn3: TcxGridColumn;
    tvLoadColumn1: TcxGridColumn;
    tvLoadColumn4: TcxGridColumn;
    setWorkplan: TADODataSet;
    tvLoadColumn2: TcxGridColumn;
    tvLoadColumn3: TcxGridColumn;
    ActionList: TActionList;
    actWorkplanCopySbj: TAction;
    actWorkplanUpdate: TAction;
    btnWorkplanCopySbj: TToolButton;
    btnWorkplanUpdate: TToolButton;
    btnWorkplanCopyGrp: TToolButton;
    actWorkplanCopyGrp: TAction;
    procedure tvWorkplanEditing(Sender: TcxCustomGridTableView;
      AItem: TcxCustomGridTableItem; var AAllow: Boolean);
    procedure tvLoadEditing(Sender: TcxCustomGridTableView;
      AItem: TcxCustomGridTableItem; var AAllow: Boolean);
    procedure tvWorkplanColumn1PropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure tvWorkplanColumn2PropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure tvLoadColumn1PropertiesDrawItem(AControl: TcxCustomComboBox;
      ACanvas: TcxCanvas; AIndex: Integer; const ARect: TRect;
      AState: TOwnerDrawState);
    procedure tvLoadColumn2PropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure ActionsExecute(Sender: TObject);
    procedure ActionsUpdate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }

    function Get_group: string;
    function Get_sem: byte;
    function Get_psem: byte;
    procedure Set_sem(Value: byte);
    procedure Set_psem(Value: byte);
    procedure Set_group(Value: string);
  private
    FWorkplanSet: TWorkplanSet;
    FWorkplanDataSource: TWorkplanDataSource;
    FLoadDataSource: TLoadDataSource;

    procedure OnGetWorkplan(Sender: TObject);
    procedure PrepareCreate;

    procedure OnDataDelete(Sender: TObject; DBObject: TDBObject; var Allow: boolean);
    procedure OnDataChange(Sender: TObject; DBObject: TDBObject;
        const FieldName: string; const NewValue: Variant; var Allow: boolean);
    procedure OnDataInsert(Sender: TObject; DBObject: TDBObject; var Id: int64);

  protected
    function GetModuleName: string; override;
    procedure ModuleHandler(var Msg: TMessage); override;
    function GetHelpTopic: string; override;
//    procedure GetSubjectList(Letter: char; List: TStrings);

  public
    { Public declarations }
    procedure UpdateModule; override;
    procedure Open(sGroup: string; nSem,nPSem: byte);

    property group: string read Get_group write Set_group;
    property sem: byte read Get_sem write Set_sem;
    property psem: byte read Get_psem write Set_psem;
  end;

implementation

uses
  ADOInt, 
  WorkModule, SDBUtils, SUtils, SHelp,
  StringListDlg, SubjectListDlg, GroupListDlg, CopyObjectDlg;

{$R *.dfm}

{ TfrmWorkplan }

procedure TfrmWorkplan.FormCreate(Sender: TObject);
begin
  PrepareCreate;
end;

procedure TfrmWorkplan.FormDestroy(Sender: TObject);
begin
  FLoadDataSource.Free;
  FWorkplanDataSource.Free;
  FWorkplanSet.Free;
end;

function TfrmWorkplan.GetModuleName: string;
begin
  Result:='Рабочий план';
end;

procedure TfrmWorkplan.ModuleHandler(var Msg: TMessage);
begin
  case Msg.Msg of
    SM_CHANGETIME:  // смена п/сем,сем,года
      if (TSMChangeTime(Msg).Flags and CT_YEAR)=CT_YEAR then
        TSMChangeTime(Msg).Result:=MRES_DESTROY
      else Open(FWorkplanSet.group,TSMChangeTime(Msg).Sem,TSMChangeTime(Msg).PSem);
  end;  // case
end;

function TfrmWorkplan.GetHelpTopic: string;
begin
  Result:=HELP_WORKPLAN_WORKPLAN;
end;

procedure TfrmWorkplan.PrepareCreate;
begin
  FWorkplanSet:=TWorkplanSet.Create;
  FWorkplanSet.OnGetWorkplan:=OnGetWorkplan;
  FWorkplanSet.OnDelete:=OnDataDelete;
  FWorkplanSet.OnInsert:=OnDataInsert;
  FWorkplanSet.OnChange:=OnDataChange;

  FWorkplanDataSource:=TWorkplanDataSource.Create(FWorkplanSet);
  FLoadDataSource:=TLoadDataSource.Create(FWorkplanSet);

  PrepareWorkplanColumns(tvWorkplan);
  PrepareLoadColumns(tvLoad);

  tvWorkplan.DataController.CustomDataSource:=FWorkplanDataSource;
  tvLoad.DataController.CustomDataSource:=FLoadDataSource;
end;

procedure TfrmWorkplan.Set_sem(Value: byte);
begin
  Assert(Value in [1,2],
    'A6A30F67-929F-406C-A165-FF7BA8B3937B'#13'TfrmWorkplan.SetSem: invalid sem'#13);

  if FWorkplanSet.sem<>Value then
  begin
    FWorkplanDataSource.DataController.BeginUpdate;
    FWorkplanDataSource.DataController.CollapseDetails;
    FWorkplanSet.sem:=Value;
    FWorkplanDataSource.DataChanged;
    FWorkplanDataSource.DataController.EndUpdate;
  end;
end;

procedure TfrmWorkplan.Set_psem(Value: byte);
begin
  Assert(Value in [1,2],
    '72944BE6-D866-4D6D-A2C4-8C10FD5C4AA4'#13'TfrmWorkplan.SetPSem: invalid psem'#13);

  if FWorkplanSet.psem<>Value then
  begin
    FWorkplanDataSource.DataController.BeginUpdate;
    FWorkplanDataSource.DataController.CollapseDetails;
    FWorkplanSet.psem:=Value;
    FWorkplanDataSource.DataChanged;
    FWorkplanDataSource.DataController.EndUpdate;
  end;
end;

function TfrmWorkplan.Get_group: string;
begin
  Result:=FWorkplanSet.group;
end;

function TfrmWorkplan.Get_sem: byte;
begin
  Result:=FWorkplanSet.sem;
end;

function TfrmWorkplan.Get_psem: byte;
begin
  Result:=FWorkplanSet.psem;
end;

procedure TfrmWorkplan.Set_group(Value: string);
begin
  Assert(Value<>'',
    '8E0C2DB4-32E3-497B-99E2-9B2D865ADC61'#13'TfrmWorkplan.Set_group: invalid grid'#13);

  if FWorkplanSet.group<>Value then
  begin
    FWorkplanDataSource.DataController.BeginUpdate;
    FWorkplanDataSource.DataController.CollapseDetails;
    FWorkplanSet.group:=Value;
    FWorkplanDataSource.DataChanged;
    FWorkplanDataSource.DataController.EndUpdate;
  end;
end;

// смена группы, сем, п/сем
procedure TfrmWorkplan.Open(sGroup: string; nSem,nPSem: byte);
begin
  FWorkplanDataSource.DataController.BeginUpdate;
  try
    FWorkplanDataSource.DataController.CollapseDetails;
    FWorkplanSet.Change(sGroup,nSem,nPSem);
    FWorkplanDataSource.DataChanged;
  finally
    FWorkplanDataSource.DataController.EndUpdate;
  end;
end;

// загрузка раб. плана
procedure TfrmWorkplan.OnGetWorkplan(Sender: TObject);
var
  workplan: TDBWorkplan;
  load: TDBLoad;
  wset: TWorkplanSet;

  wpid: int64;
begin
  if Sender is TWorkplanSet then
  begin
    wset:=Sender as TWorkplanSet;

    wpid:=-1;
    workplan:=nil;
    load:=nil;

    if GetRecordset(dmWork.wp_GetGrp(wset.sem,wset.psem,wset.grid),setWorkplan) then
    begin
      if setWorkplan.RecordCount>0 then
      begin
//        setWorkplan.Sort:='sbName ASC, type ASC';
        setWorkplan.Sort:='wpid ASC, type ASC';
        try
          while not setWorkplan.Eof do
          begin
            if wpid<>setWorkplan.FieldByName('wpid').Value then
            begin
              wpid:=setWorkplan.FieldByName('wpid').Value;
              //workplan:=TDBWorkplan.Create(0);
              //workplan.Assign(DataSet.Fields);
              workplan:=CoWorkplan.Create(setWorkplan.Fields);
              CoDBList.InternalInsert(workplan, wset);
            end
            else
            begin
              if Assigned(workplan) then
              begin
                if not setWorkplan.FieldByName('lid').IsNull then
                //if not VarIsNull(rs.Fields.Item['lid'].Value) then
                begin
                  //load:=TDBLoad.Create(0);
                  //load.Assign(DataSet.Fields);
                  load:=CoLoad.Create(setWorkplan.Fields);
                  CoDBList.InternalInsert(load, workplan.loads);
                end; // if [lid] not is null
              end;
              setWorkplan.Next;
            end;
          end; // while
        finally
          setWorkplan.Sort:='';
          setWorkplan.Close;
        end; // try/finally
      end; // if
    end; // if GetRecord
  end; // if Sender is TWorkplanSet
end;

procedure TfrmWorkplan.UpdateModule;
begin
  if (FWorkplanSet.grid>0) then
  begin
    FWorkplanDataSource.DataController.BeginUpdate;
    FWorkplanDataSource.DataController.CollapseDetails;
    FWorkplanSet.Update;
    FWorkplanDataSource.DataChanged;
    FWorkplanDataSource.DataController.EndUpdate;
  end;
end;

procedure TfrmWorkplan.tvWorkplanEditing(Sender: TcxCustomGridTableView;
  AItem: TcxCustomGridTableItem; var AAllow: Boolean);
begin
  if integer(AItem.DataBinding.Data)=windex_subject then
    AAllow:=Sender.DataController.NewItemRowFocused
  else AAllow:=true;
end;

procedure TfrmWorkplan.tvLoadEditing(Sender: TcxCustomGridTableView;
  AItem: TcxCustomGridTableItem; var AAllow: Boolean);

  procedure GetLTypes(AList: TStrings);
  var
    workplan: TDBWorkplan;
    loads: TDBLoadList;
    ltype: TLsnsType;
    i: integer;
    exists: boolean;
  begin
    AList.Clear;

    i:=Sender.DataController.GetMasterRecordIndex;

    workplan:=FWorkplanSet.Items[i];
    if Assigned(workplan) then
    begin
      loads:=workplan.loads;
      for ltype:=Low(TLsnsType) to High(TLsnsType) do
      begin
        exists:=false;
        for i:=0 to loads.Count-1 do
          if ltype=loads.Items[i].ltype then
          begin
            exists:=true;
            break;
          end;
        if not exists then AList.Add(IntToStr(integer(ltype)));
      end; // for
    end; // if workplan<>nil
  end; // procedure

begin
  case integer(AItem.DataBinding.Data) of

    lindex_type:
      begin
        AAllow:=Sender.DataController.NewItemRowFocused;
        if AAllow and (AItem.Properties is TcxComboBoxProperties) then
          GetLTypes(TcxComboBoxProperties(AItem.Properties).Items);
      end;

    lindex_teacher:
      AAllow:=true;

    lindex_stream:
      AAllow:=false;

    lindex_hours:
      AAllow:=true;

    else AAllow:=false;
  end; // case
end;

// изм-ние дисциплины
procedure TfrmWorkplan.tvWorkplanColumn1PropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
var
//  frmDlg: TfrmSubjects;
  s: string;
//  sbid: int64;
begin
  Assert(tvWorkplan.DataController.NewItemRowFocused,
    '80AAD3DC-4ADE-486F-AF39-4F2A4F45DF8D'#13'Запрещено изменять дисциплину'#13);

  if GetSubjectFromList(#0, dmWork.sbj_GetLetter, s) then
    tvWorkplanColumn1.EditValue:=s;

//  frmDlg:=TfrmSubjects.CreateList(Self);
//  try
//    if frmDlg.ShowModal=mrOk then
//    begin
//      sbid:=frmDlg.sbid;
//      if sbid>0 then
//        tvWorkplanColumn1.EditValue:=Format('%d=%s',[sbid,frmDlg.sbName]);
//    end
//  finally
//    frmDlg.Free;
//  end;
end;

// изм-ние кафедры
procedure TfrmWorkplan.tvWorkplanColumn2PropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
var
//  frmDlg: TfrmKafedrs;
//  kid: int64;
  list: TStringList;
  s: string;
begin

  list:=TStringList.Create;
  try
    dmWork.GetKafedraList(list);
    if GetStrFromList('Кафедра','',s,list) then
      tvWorkplanColumn2.EditValue:=s;
  finally
    list.free;
    list:=nil;
  end

{
  frmDlg:=TfrmKafedrs.CreateList(Self);
  try
    if frmDlg.ShowModal=mrOk then
    begin
      kid:=frmDlg.kid;
      if kid>0 then
        tvWorkplanColumn2.EditValue:=Format('%d=%s',[kid,frmDlg.kName])
    end; // if
  finally
    frmDlg.Free;
  end;
}
end;

// изм-ние преп-ля
procedure TfrmWorkplan.tvLoadColumn2PropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var
  i,j: integer;
  s: string;
  list: TStringList;
  workplan: TDBWorkplan;
begin
  i:=tvWorkplan.DataController.FocusedRecordIndex;
  if i>=0 then
  begin
    workplan:=FWorkplanSet.Items[i];
    if Assigned(workplan) then
    begin

      // извлечение списка преп-лей групп
      list:=TStringList.Create;
      try
        if dmWork.GetTeacherList(workplan.kafedra.id,list) then
        begin
          list.Insert(0, '0=');
          if GetStrFromList('Преподаватели','',s,list) then
          begin
            j:=cxGrid.FocusedView.DataController.FocusedRecordIndex;
            if j>=0 then
              cxGrid.FocusedView.DataController.Values[j,lindex_teacher]:=s;
          end; // if GetStrFromList
        end;  // if list<>nil;
      finally
        list.Free;
      end;

    end;  // if workplan<>nil
  end;  // if i>=0
end;

// отрисовка ComboBox`а для ltype-поля
procedure TfrmWorkplan.tvLoadColumn1PropertiesDrawItem(
  AControl: TcxCustomComboBox; ACanvas: TcxCanvas; AIndex: Integer;
  const ARect: TRect; AState: TOwnerDrawState);
var
  s: string;
  i: integer;
begin
  ACanvas.FillRect(ARect);

  s:=TcxComboBox(AControl).Properties.Items[AIndex];
  i:=StrToIntDef(s,0);
  if (i>=1) and (i<=3) then s:=LTypeNames[TLsnsType(i)] else s:='Неизвестный тип';

  ACanvas.DrawText(s, ARect, cxAlignLeft or cxShowEndEllipsis);
end;

// удаление объектов из БД
procedure TfrmWorkplan.OnDataDelete(Sender: TObject;
    DBObject: TDBObject; var Allow: boolean);
begin
  Allow:=false;
  if DBObject is TDBWorkplan then Allow:=dmWork.wp_Delete(DBObject.id) else
    if DBObject is TDBLoad then Allow:=dmWork.ld_Delete(DBObject.id) else
      raise Exception.Create('OnDataDelete: Unknown class of DBObject');
end;

// изм-ние полей объектов
procedure TfrmWorkplan.OnDataChange(Sender: TObject; DBObject: TDBObject;
    const FieldName: string; const NewValue: Variant; var Allow: boolean);
var
  table, key: string;
begin
  table:='';
  key:='';

  if DBObject is TDBWorkplan then
  begin
    table:='tb_Workplan';
    key:='wpid';
  end else
    if DBObject is TDBLoad then
    begin
      table:='tb_Load';
      key:='lid';
    end
      else raise Exception.Create('OnDataChange: Unknown class of DBObject');

  if (table<>'') and (key<>'') then
    Allow:=dmWork.UpdateRecord(table,key,DBObject.id,FieldName,NewValue);

end;

// создание объектов в БД
procedure TfrmWorkplan.OnDataInsert(Sender: TObject;
    DBObject: TDBObject; var Id: int64);
var
  wset: TWorkplanSet;
  workplan: TDBWorkplan;
  load: TDBLoad;
begin
  Id:=0;

  if DBObject is TDBWorkplan then
  begin
    if Sender is TWorkplanSet then
    begin
      wset:=TWorkplanSet(Sender);
      workplan:=TDBWorkplan(DBObject);
      Id:=dmWork.wp_Create(wset.grid,workplan.subject.id,
          workplan.kafedra.id,wset.sem,workplan.examen);
    end;
  end else
    if DBObject is TDBLoad then
    begin
      if Sender is TDBWorkplan then
      begin
        workplan:=TDBWorkplan(Sender);
        load:=TDBLoad(DBObject);
        Id:=dmWork.ld_Create(workplan.id,byte(load.ltype),load.psem,load.hours);
      end
      else raise Exception.Create('OnDataInsert: Sender is not TDBWorkplan');
    end
      else raise Exception.Create('OnDataInsert: Unknown class of DBObject');
end;

function GetSubject: string;
begin
  Result:='';
  GetSubjectFromList(#0, dmWork.sbj_GetLetter, Result);
end;

function CopyWP(wpid,sbid: int64): boolean;
begin
  Result:=(dmWork.wp_Copy(wpid,sbid)>0);
end;

function DeleteWP(wpid: int64): boolean;
begin
  Result:=dmWork.wp_Delete(wpid);
end;

function GetGroup: string;
begin
  Result:='';
  GetGroupFromList(1,dmWork.dbv_GetGroupCrs,Result);
end;

function CopyGroup(grid, newid: int64): boolean;
begin
  Result:=dmWork.wp_CopyGrp(grid,newid);
end;

procedure TfrmWorkplan.ActionsExecute(Sender: TObject);

  // копирование дисциплины раб. плана (25/09/06)
  function CloneWorkplan(wpid, sbid: int64; sbName: string): boolean;
  begin
    Result:=CopyObject('Копирование дисциплины','Дисциплина',
        wpid,sbid,sbName,
        dmWork.Connection,GetSubject,CopyWP,DeleteWP);
  end;  // CloneWorkplan

  function CloneGroup(grid: int64; grName: string): boolean;
  begin
    Result:=CopyObject('Копирование раб. плана','Группа',
        grid,grid,grName,
        dmWork.Connection,GetGroup,CopyGroup,nil);
  end;  // CloneGroup

var
  workplan: TDBWorkplan;
  i: integer;
begin
  case (Sender as TAction).Tag of

    -1: // update
      UpdateModule;

    1:  // copy a subject
      begin
        i:=tvWorkplan.DataController.FocusedRecordIndex;
        if i>=0 then
        begin
          workplan:=FWorkplanSet.Items[i];
          if Assigned(workplan) then
            if CloneWorkplan(workplan.id,workplan.subject.id,workplan.subject.name) then
              UpdateModule;
        end;
      end;  // 1

    2:  // clone a workplan
      CloneGroup(FWorkplanSet.grid, FWorkplanSet.grName);

    else
      raise Exception.CreateFmt('Unknown action (Tag=%d)', [TAction(Sender).Tag]);
  end;  // case
end;

procedure TfrmWorkplan.ActionsUpdate(Sender: TObject);
begin
  case (Sender as TAction).Tag of

    1:  // copy a subject
      TAction(Sender).Enabled:=(tvWorkplan.Focused)
          and(not tvWorkplan.DataController.NewItemRowFocused)
          and(tvWorkplan.DataController.FocusedRecordIndex>=0);

    2:  // copy a workplan
      TAction(Sender).Enabled:=(FWorkplanSet.grid>0);

    else
      raise Exception.CreateFmt('Unknown action (Tag=%d)', [TAction(Sender).Tag]);
  end;  // case
end;

// TODO: Delete
{
// выборка дисциплин (01/08/06)
procedure TfrmWorkplan.GetSubjectList(Letter: char; List: TStrings);
var
  rs: _Recordset;
  s: string;
begin
  List.Clear;

  rs:=dmWork.sbj_GetLetter(letter);

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

end.
