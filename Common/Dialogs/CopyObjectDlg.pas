{
  Диалог копирования объектов БД
  v0.0.3  (25/09/06)
}
unit CopyObjectDlg;

// TODO: Вывод информирующего сообщения

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ActnList, ExtCtrls, ADODB;

type
  TGetObjectFunc = function: string;
  TCloneFunc = function(old,new: int64): boolean;
  TDeleteFunc = function(id: int64): boolean;

  TfrmCopyDlg = class(TForm)
    btnAdd: TSpeedButton;
    btnDel: TSpeedButton;
    ListBox: TListBox;
    btnOk: TButton;
    btnCancel: TButton;
    lblSource: TLabel;
    chkDelSource: TCheckBox;
    Label1: TLabel;
    ActionList: TActionList;
    actCloneAdd: TAction;
    actCloneRemove: TAction;
    Bevel1: TBevel;
    Bevel2: TBevel;
    procedure ActionsExecute(Sender: TObject);
    procedure ActionsUpdate(Sender: TObject);
    procedure ListBoxDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
  private
    { Private declarations }
    FConnection: TADOConnection;
    FGetObjectFunc: TGetObjectFunc;
    FCloneFunc: TCloneFunc;
    FDeleteFunc: TDeleteFunc;

    fid: int64;

    function DoClone(id: int64): boolean;

  public
    { Public declarations }
  end;

function CopyObject(const DialogCaption, ObjName: string;
  id, fid: int64; const fName: string;
  Connection: TADOConnection;
  GetObjectFunc: TGetObjectFunc; CloneFunc: TCloneFunc; DeleteFunc: TDeleteFunc): boolean;

implementation

uses
  SUtils, SStrings;

{$R *.dfm}

function CopyObject(const DialogCaption, ObjName: string;
  id, fid: int64; const fName: string;
  Connection: TADOConnection;
  GetObjectFunc: TGetObjectFunc; CloneFunc: TCloneFunc; DeleteFunc: TDeleteFunc): boolean;
var
  frmDlg: TfrmCopyDlg;
begin
  Assert(id>0,
    '18ADF2CA-3AA9-475C-9579-5E4EA31FED44'#13''#13);
  Assert(fid>0,
    '3054BD7A-83CA-4124-93B7-102F40815937'#13''#13);
  Assert(Assigned(GetObjectFunc),
    '5BA06981-44E9-4100-954D-3284BA4310BD'#13''#13);
  Assert(Assigned(CloneFunc),
    '83D2CA46-60F9-4DE1-B9CA-2548F06DED52'#13''#13);

  Result:=false;

  frmDlg:=TfrmCopyDlg.Create(Application);
  try
    frmDlg.Caption:=DialogCaption;
    frmDlg.Label1.Caption:=ObjName;
    frmDlg.fid:=fid;
    frmDlg.lblSource.Caption:=fName;

    frmDlg.FConnection:=Connection;
    frmDlg.FGetObjectFunc:=GetObjectFunc;
    frmDlg.FCloneFunc:=CloneFunc;

    frmDlg.chkDelSource.Visible:=Assigned(DeleteFunc);

    if frmDlg.ShowModal=mrOk then
    begin
      if frmDlg.chkDelSource.Checked then frmDlg.FDeleteFunc:=DeleteFunc;
      Result:=frmDlg.DoClone(id);
    end;
  finally
    frmDlg.Free;
  end;
end;

procedure TfrmCopyDlg.ActionsExecute(Sender: TObject);
var
  s: string;
begin
  case (Sender as TAction).Tag of

    1:  // add
      begin
        s:=FGetObjectFunc();
        if (fid<>GetID(s)) and (s<>'') and (ListBox.Items.IndexOf(s)=-1) then
          ListBox.AddItem(s,nil);
      end; // 1

    2:  // remove
      if ListBox.ItemIndex>=0 then ListBox.DeleteSelected;

    else
      raise Exception.CreateFmt('Unknown action (Tag=%d)', [TAction(Sender).Tag]);

  end; // case
end;

procedure TfrmCopyDlg.ActionsUpdate(Sender: TObject);
begin
  case (Sender as TAction).Tag of

    1:  // add
      TAction(Sender).Enabled:=Assigned(FGetObjectFunc);

    2:  // remove
      TAction(Sender).Enabled:=ListBox.ItemIndex>=0;

    else
      raise Exception.CreateFmt('Unknown action (Tag=%d)', [TAction(Sender).Tag]);
  end; // case

end;

// Копирование объектов  (25/09/06)
function TfrmCopyDlg.DoClone(id: int64): boolean;
var
  i: integer;
  err: boolean;
  msg: string;
  newid: int64;
begin
  Assert(Assigned(FConnection),
    '16B795C0-FB57-4BD5-A76F-D1C1CBF7DA96'#13'DoClone: FConnection is nil'#13);
  Assert(Assigned(FCloneFunc),
    'BB7140ED-AE21-439D-9AF2-1470D037908E'#13'DoClone: FCloneFunc is nil'#13);

  if ListBox.Count>0 then
  begin
    err:=false;
    FConnection.BeginTrans;
    try

      for i:=0 to ListBox.Count-1 do
      begin
        newid:=GetID(ListBox.Items.Names[i]);

        if newid>0 then
        try
          err:=not FCloneFunc(id,newid);
          if err then
          begin
            msg:=Format('Ошибка при копировании "%s"',[ListBox.Items.ValueFromIndex[i]]);
            break;
          end;
        except
          on E: Exception do
          begin
            err:=true;
            msg:=Format('Ошибка при копировании "%s"',[ListBox.Items.ValueFromIndex[i]]);
            msg:=msg+#13+E.Message;
            break;
          end;
        end;  // try/except

      end;  // for(i)

      if Assigned(FDeleteFunc) and (not err) then
        if not FDeleteFunc(id) then
        begin
          err:=true;
          msg:='Ошибка удаления источника';
        end;

    finally
      if err then
      begin
        FConnection.RollbackTrans;
        if msg<>'' then MessageDlg(msg, mtError, [mbOK], -1);
      end else FConnection.CommitTrans;
    end;

    Result:=not err;
  end else Result:=false;
end;

procedure TfrmCopyDlg.ListBoxDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  FCanvas: TCanvas;
  s: string;
begin
  if Control is TCustomListBox then
  begin
    FCanvas:=TCustomListBox(Control).Canvas;
    TControlCanvas(FCanvas).UpdateTextFlags;
    FCanvas.FillRect(Rect);
    if bDebugMode then s:=TCustomListBox(Control).Items[Index]
      else s:=TCustomListBox(Control).Items.ValueFromIndex[Index];
    FCanvas.TextOut(Rect.Left + 2, Rect.Top, s);
  end;
end;

end.
