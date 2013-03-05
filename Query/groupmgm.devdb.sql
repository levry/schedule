-- управление группами
/*
  100  выборка/создание группы
*/
CREATE PROCEDURE prc_GroupMgm
(
@OperType int,
@grId bigint output,
@spId bigint,
@grName varchar(10),
@Studs smallint
)
AS
begin

declare @res int
set @res=0

-- выборка/создание группы
if @OperType=100
begin
  set @grId=null
  select @grId=grid from tb_Group where grName=@grName
  if @grId is null
  begin
    insert tb_Group (spid, grName, studs) values (@spId, @grName, @Studs)
    select @grId=@@identity
    set @res=1
  end
  else set @res=2
  return @res
end

end
GO
