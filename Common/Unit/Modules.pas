{
  Баз. классы модулей и менеджера
  v0.0.3 (22.04.06)
  (C) Leonid Riskov, 2006
}

unit Modules;

interface

uses
  Classes, Contnrs, Forms, Controls, Messages, CustomOptions;

type
  // форма модуля
  // GetModuleName - имя модуля
  // 
  TModuleForm = class(TForm)
  private

    FIsModule: boolean;
    FOnDestroyModule: TNotifyEvent;

  protected
    FOptions: TCustomOptions;

    //procedure OnModuleClose(Sender: TObject; var Action: TCloseAction);
    constructor CreateModule(AOwner: TComponent; AOptions: TCustomOptions); virtual;
    function GetModuleName: string; virtual; abstract;
    procedure ModuleHandler(var Msg: TMessage); virtual;

    function GetHelpTopic: string; virtual;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure UpdateModule; virtual; abstract;

    function CanHelp: boolean;
    procedure DoHelp;

    property IsModule: boolean read FIsModule;
    property ModuleName: string read GetModuleName;
  end;

  TModuleClass = class of TModuleForm;

  TModuleManager = class
  private
    FControl: TWinControl;
    FOptions: TCustomOptions;

    FOnCreateModule: TNotifyEvent;
    FOnDestroyModule: TNotifyEvent;
    FOnChangeModule: TNotifyEvent;

    function GetActiveModule: TModuleForm;
    function GetCount: integer;
    procedure DoDestroyModule(Sender: TObject);
  public
    constructor Create(AControl: TWinControl; AOptions: TCustomOptions);
    destructor Destroy; override;

    procedure CloseAll;
    procedure Broadcast(Msg: TMessage);
    function FindByClass(AModuleClass: TModuleClass): TModuleForm;
    procedure Hide(AModuleClass: TModuleClass);
    function Show(AModuleClass: TModuleClass; AUpdate: boolean=false): TModuleForm;

    property ActiveModule: TModuleForm read GetActiveModule;
    property Count: integer read GetCount;
    property OnCreateModule: TNotifyEvent read FOnCreateModule write FOnCreateModule;
    property OnDestroyModule: TNotifyEvent read FOnDestroyModule write FOnDestroyModule;
    property OnChangeModule: TNotifyEvent read FOnChangeModule write FOnChangeModule;
  end;

implementation

uses
  Windows,
  STypes, SHelp;

{ TModuleForm }

constructor TModuleForm.Create(AOwner: TComponent);
begin
  FOptions:=nil;
  inherited Create(AOwner);
  FIsModule:=false;
end;

constructor TModuleForm.CreateModule(AOwner: TComponent; AOptions: TCustomOptions);
begin
  FIsModule:=true;
  FOptions:=AOptions;

  inherited Create(AOwner);
//  OnClose:=OnModuleClose;
  FormStyle:=fsNormal;
  BorderStyle:=bsNone;
  Align:=alClient;
end;

destructor TModuleForm.Destroy;
begin
  if Assigned(FOnDestroyModule) then FOnDestroyModule(Self);
  inherited Destroy;
end;

procedure TModuleForm.ModuleHandler(var Msg: TMessage);
begin
end;

//procedure TModuleForm.OnModuleClose(Sender: TObject; var Action: TCloseAction);
//begin
//  Action:=caFree;
//end;

// страница справки  (29/09/06)
function TModuleForm.GetHelpTopic: string;
begin
  Result:='';
end;

// доступность справки  (29/09/06)
function TModuleForm.CanHelp: boolean;
begin
  Result:=((Application.HelpFile<>'') and (GetHelpTopic<>''));
end;

// вызов справки  (29/09/06)
procedure TModuleForm.DoHelp;
begin
  if CanHelp then DisplayTopic(GetHelpTopic);
end;

{ TModuleManager }

constructor TModuleManager.Create(AControl: TWinControl; AOptions: TCustomOptions);
begin
//  Assert(AForm.FormStyle=fsMDIForm,
//    '58C9F001-475F-4DB3-B811-6BFD64A76429'#13'TModuleManager.Create: Form is not MDI'#13);

  //FModuleList:=TClassList.Create;
  FControl:=AControl;
  FOptions:=AOptions;
end;

destructor TModuleManager.Destroy;
begin
  FControl:=nil;
  //FModuleList.Free;
  //FModuleList:=nil;
  inherited Destroy;
end;

function TModuleManager.GetActiveModule: TModuleForm;
begin
  Result:=nil;
  if FControl.ControlCount>0 then
    if FControl.Controls[FControl.ControlCount-1] is TModuleForm then
      Result:=TModuleForm(FControl.Controls[FControl.ControlCount-1]);
end;

// возвращает число открытых модулей
function TModuleManager.GetCount: integer;
var
  i: integer;
begin
  Result:=0;
  for i:=0 to FControl.ControlCount-1 do
    if FControl.Controls[i] is TModuleClass then
      Inc(Result);
end;

procedure TModuleManager.DoDestroyModule(Sender: TObject);
begin
  if Assigned(FOnDestroyModule) then
    FOnDestroyModule(Sender);
end;

function TModuleManager.FindByClass(AModuleClass: TModuleClass): TModuleForm;
var
  i: integer;
begin
  Result:=nil;
  for i:=0 to FControl.ControlCount-1 do
    if FControl.Controls[i] is AModuleClass then
    begin
      Result:=(FControl.Controls[i] as TModuleForm);
      break;
    end;
end;

procedure TModuleManager.Hide(AModuleClass: TModuleClass);
var
  ModuleForm: TModuleForm;
begin
  ModuleForm:=FindByClass(AModuleClass);
  if Assigned(ModuleForm) then
    ModuleForm.Hide;
end;

function TModuleManager.Show(AModuleClass: TModuleClass; AUpdate: boolean=false): TModuleForm;
begin
  Result:=FindByClass(AModuleClass);   
  if not Assigned(Result) then
  begin
    Result:=AModuleClass.CreateModule(Application, FOptions);
    Result.FOnDestroyModule:=DoDestroyModule;
    Result.Parent:=FControl;
    if Assigned(FOnCreateModule) then FOnCreateModule(Result);
    if AUpdate then Result.UpdateModule;
  end;

  Result.Show;
  Result.BringToFront;
  if Assigned(FOnChangeModule) then FOnChangeModule(Result);
end;

// закрытие всех модулей
procedure TModuleManager.CloseAll;
var
  i: integer;
begin
  for i:=FControl.ControlCount-1  downto 0 do
    if FControl.Controls[i] is TModuleClass then
      TModuleForm(FControl.Controls[i]).Free;
end;

// посылка события всем модулям
procedure TModuleManager.Broadcast(Msg: TMessage);
var
  i: integer;
  Module: TModuleForm;
begin
  LockWindowUpdate(FControl.Handle);

  for i:=FControl.ControlCount-1 downto 0 do
  begin
    if FControl.Controls[i] is TModuleClass then
    begin
      Msg.Result:=0;

      module:=TModuleForm(FControl.Controls[i]);
      module.ModuleHandler(Msg);

      if Msg.Result = MRES_DESTROY then
      begin
        FControl.RemoveControl(module);
        module.Free;
      end;
    end;
  end;

  if Assigned(ActiveModule) then
    if Assigned(FOnChangeModule) then FOnChangeModule(ActiveModule);

  LockWindowUpdate(0);
end;

end.
