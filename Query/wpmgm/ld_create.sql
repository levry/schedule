-- добавление нагрузки (wpid,psem,type,tid,hours)
-- RETURN_VALUE - кол-во добавл. записей
CREATE PROCEDURE dbo.ld_create
(
@wpid bigint,
@psem tinyint,
@type tinyint,
@hours tinyint
)
AS
  set nocount on
  
  declare
    @res int
  
  set @res=0
  if (not exists(select lid from tb_Load where wpid=@wpid and psem=@psem and type=@type))
     and (@hours>0)
  begin
    insert tb_Load (wpid,psem,type,hours)
      values(@wpid,@psem,@type,@hours)
    set @res=@@rowcount
  end
  
  return @res
