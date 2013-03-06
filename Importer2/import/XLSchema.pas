{
  XML Data Binding
  v0.0.1  (15/07/07)
}
unit XLSchema;

interface

uses xmldom, XMLDoc, XMLIntf;

type

{ Forward Decls }

  IXLSchema = interface;
  IXLCell = interface;

{ IXLSchema }

  IXLSchema = interface(IXMLNodeCollection)
    ['{51CD0559-1462-4E0F-9F5B-8633CBC1B9C6}']
    { Property Accessors }
    function getCell(Index: Integer): IXLCell;

    { Methods & Properties }
    function Add: IXLCell;
    function Insert(const Index: Integer): IXLCell;
    function CellByName(const CellName: string): IXLCell;
    function findLastCell: IXLCell;

    property Cell[Index: Integer]: IXLCell read getCell; default;

  end;

{ IXLCell }

  IXLCell = interface(IXMLNode)
    ['{EC2BD1A9-B92D-4FD2-BD51-4DFFD039065D}']
    { Property Accessors }
    function getName: WideString;
    function getTitle: WideString;
    function getRow: integer;
    function getColl: integer;
    procedure setName(Value: WideString);
    procedure setTitle(Value: WideString);
    procedure setRow(Value: integer);
    procedure setColl(Value: integer);

    { Methods & Properties }
    function equalsCell(cell: IXLCell): boolean;
    function isLast: boolean;

    property Name: WideString read getName write setName;
    property Title: WideString read getTitle write setTitle;
    property Row: integer read getRow write setRow;
    property Coll: integer read getColl write setColl;
  end;

{ Forward Decls }

  TXLSchema = class;
  TXLCell = class;

{ TXLSchema }

  TXLSchema = class(TXMLNodeCollection, IXLSchema)
  protected
    { IXLSchema }
    function getCell(Index: Integer): IXLCell;
    function Add: IXLCell;
    function Insert(const Index: Integer): IXLCell;
  public
    procedure AfterConstruction; override;
    function CellByName(const CellName: string): IXLCell;
    function findLastCell: IXLCell;

  end;

{ TXLCell }

  TXLCell = class(TXMLNode, IXLCell)
  protected
    { IXLCell }
    function getName: WideString;
    function getTitle: WideString;
    function getRow: integer;
    function getColl: integer;
    procedure setName(Value: WideString);
    procedure setTitle(Value: WideString);
    procedure setRow(Value: integer);
    procedure setColl(Value: integer);
  public
    function equalsCell(cell: IXLCell): boolean;
    function isLast: boolean;

  end;

{ Global Functions }

function GetXLSchema(Doc: IXMLDocument): IXLSchema;
function LoadXLSchema(const FileName: WideString): IXLSchema;
function NewXLSchema: IXLSchema;
function CreateXLSchema(const XMLData: string): IXLSchema;

const
  TargetNamespace = 'http://microsoft.com/xml';

implementation

uses
  SysUtils;

{ Global Functions }

function Getxlschema(Doc: IXMLDocument): IXLSchema;
begin
  Result := Doc.GetDocBinding('xlschema', TXLSchema, TargetNamespace) as IXLSchema;
end;

function Loadxlschema(const FileName: WideString): IXLSchema;
begin
  Result := LoadXMLDocument(FileName).GetDocBinding('xlschema', TXLSchema, TargetNamespace) as IXLSchema;
end;

function Newxlschema: IXLSchema;
begin
  Result := NewXMLDocument.GetDocBinding('xlschema', TXLSchema, TargetNamespace) as IXLSchema;
end;

function CreateXLSchema(const XMLData: string): IXLSchema;
begin
  Result:=LoadXMLData(XMLData).GetDocBinding('xlschema', TXLSchema, TargetNamespace) as IXLSchema;
end;

{ Local functions }


{ TXLSchema }

procedure TXLSchema.AfterConstruction;
begin
  RegisterChildNode('cell', TXLCell);
  ItemTag := 'cell';
  ItemInterface := IXLCell;
  inherited;
end;

function TXLSchema.getCell(Index: Integer): IXLCell;
begin
  Result := List[Index] as IXLCell;
end;

function TXLSchema.Add: IXLCell;
begin
  Result := AddItem(-1) as IXLCell;
end;

function TXLSchema.Insert(const Index: Integer): IXLCell;
begin
  Result := AddItem(Index) as IXLCell;
end;

function TXLSchema.CellByName(const CellName: string): IXLCell;
var
  i: integer;
begin
  for i:=0 to List.Count-1 do
    if AnsiCompareText(getCell(i).Name, CellName)=0 then
    begin
      Result:=getCell(i);
      Exit;
    end;
  Result:=nil;
end;

function TXLSchema.findLastCell: IXLCell;
var
  i: integer;
begin
  for i:=0 to List.Count-1 do
    if getCell(i).isLast then
    begin
      Result:=getCell(i);
      Exit;
    end;
  Result:=nil;
end;

{ TXLCell }

function TXLCell.getName: WideString;
begin
  Result := AttributeNodes['name'].Text;
end;

procedure TXLCell.setName(Value: WideString);
begin
  SetAttribute('name', Value);
end;

function TXLCell.getTitle: WideString;
begin
  Result := AttributeNodes['title'].Text;
end;

procedure TXLCell.setTitle(Value: WideString);
begin
  SetAttribute('title', Value);
end;

function TXLCell.getRow: integer;
begin
  if HasAttribute('row') then Result := GetAttribute('row')
    else Result:=-1;
end;

procedure TXLCell.setRow(Value: integer);
begin
  SetAttribute('row', Value);
end;

function TXLCell.getColl: integer;
begin
  Result := GetAttribute('coll');
end;

procedure TXLCell.setColl(Value: integer);
begin
  SetAttribute('coll', Value);
end;

function TXLCell.equalsCell(cell: IXLCell): boolean;
begin
  Result:=(getColl=cell.Coll) and (getRow=cell.Row);
end;

function TXLCell.isLast: boolean;
begin
  if HasAttribute('last') then Result:=GetAttribute('last')
    else Result:=false;
end;

end.