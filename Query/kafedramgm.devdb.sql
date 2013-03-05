-- управление кафедрами
/*
  100  выборка/создание кафедры
--  101  выборка кафедр
*/
CREATE PROCEDURE prc_KafedraMgm
(
@OperType int,
@kId bigint output,
@kName varchar(50)
)
AS
begin

declare @res tinyint
set @res=0

-- выборка/создание кафедры
if @OperType=100
begin
  set @kId=null
  select @kId=kid from tb_Kafedra where kName=@kName
  if @kId is null
  begin
    insert tb_Kafedra (kName) values (@kName)
    select @kId=@@identity
    set @res=1
  end
  else set @res=2
  return @res
end

-- выборка всех кафедр
--if @OperType=101
--  select kid, kName from tb_Kafedra


end
GO
