unit SIntf;

interface

uses
  Classes, Graphics;

type

  TObjectKind = (okRoot,okKafedra,okGroup,okSubject,okGroups,okDeclares,okDeclare);

  TBrowseObject = class
  private
    fkind: TObjectKind;
    fparent: TBrowseObject;    // parent object
    fid: int64;                // id
    fname: string;             // name
    function GetText: string;
  public
    constructor Create(AKind: TObjectKind; AParent: TBrowseObject);
    procedure Assign(Source: TObject);
    property Kind: TObjectKind read FKind;
    property Id: int64 read FId;
    property Name: string read FName;
    property Parent: TBrowseObject read FParent;
    property Text: string read GetText;
  end;

function CreateBrowseObject(AKind: TObjectKind; AId: int64; AName: string;
    AParent: TBrowseObject): TBrowseObject; overload;
function CreateBrowseObject(AKind: TObjectKind; AObject: TObject;
    AParent: TBrowseObject): TBrowseObject; overload;



implementation

uses
  SysUtils, DB;

function CreateBrowseObject(AKind: TObjectKind; AId: int64; AName: string;
    AParent: TBrowseObject): TBrowseObject;
begin
  Result:=TBrowseObject.Create(AKind, AParent);
  Result.FId:=AId;
  Result.FName:=AName;
end;

function CreateBrowseObject(AKind: TObjectKind; AObject: TObject;
    AParent: TBrowseObject): TBrowseObject;
begin
  Result:=TBrowseObject.Create(AKind, AParent);
  if Assigned(AObject) then Result.Assign(AObject);
end;


{ TBrowseObject }

constructor TBrowseObject.Create(AKind: TObjectKind; AParent: TBrowseObject);
begin
  FKind:=AKind;
  FParent:=AParent;
end;

function TBrowseObject.GetText: string;
begin
  Result:=IntToStr(FId)+'='+FName;
end;

procedure TBrowseObject.Assign(Source: TObject);

  procedure CopyFromObject(AObject: TBrowseObject);
  begin
    fkind:=AObject.fkind;
    fparent:=AObject.fparent;
    fid:=AObject.fid;
    fname:=AObject.fname;
  end;

  procedure CopyFromFields(AFields: TFields);
  var
    sid, sname: string;
  begin
    case fkind of
      okKafedra:
        begin
          sid:='kid';
          sname:='kName';
        end;
      okGroup:
        begin
          sid:='grid';
          sname:='grName';
        end;
      okSubject, okDeclare:
        begin
          sid:='sbid';
          sname:='sbName';
        end;
      else
        begin
          sid:='';
          sname:='';
        end;
    end;  // case(fkind)
    if (sid<>'') and (sname<>'') then
    begin
      fid:=AFields.FieldByName(sid).AsInteger;
      fname:=AFields.FieldByName(sname).AsString;
    end;
  end;

begin
  if Assigned(Source) then
  begin
    if Source is TBrowseObject then CopyFromObject(TBrowseObject(Source)) else
      if Source is TFields then CopyFromFields(TFields(Source))
        else raise Exception.Create('TBrowseObject.Assign: Unknown object class');
  end;
end;

end.
