-- добавление дисциплины в раб. план (grid,sbid,kid,sem)
-- RETURN_VALUE - wpid (id раб. плана)
CREATE PROCEDURE dbo.wp_create
(
@grid bigint,
@sbid bigint,
@kid bigint,
@sem tinyint
)
AS
  set nocount on
  declare @res bigint

  set @res=null
  if not exists(
      select wpid
        from tb_Workplan
        where grid=@grid and sbid=@sbid and sem=@sem)
  begin
    insert tb_Workplan (grid,sbid,kid,sem)
      values (@grid,@sbid,@kid,@sem)
    set @res=@@identity
  end

  return @res