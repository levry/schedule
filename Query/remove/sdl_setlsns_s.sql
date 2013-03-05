SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


-- изм-ние поток. занятия (strid,week,wday,npair,aid,tid)
-- RETURN_VALUE кол-во изм. записей
ALTER   PROCEDURE dbo.sdl_setlsns_s
(
@strid bigint,
@week tinyint,
@wday tinyint,
@npair tinyint,
@aid bigint,
@tid bigint
)
AS
  set nocount on

  declare
    @lsem tinyint,
    @lpsem tinyint,
    @res int

  set @res=0
  -- опр-ние sem,psem
  select @lsem=sem, @lpsem=psem from tb_Stream where strid=@strid

  if 
      -- проверка занятости преп-ля
      ((dbo.uf_freetid_s(@lsem,@lpsem,@week,@wday,@npair,@strid,@tid)=@tid) or (@tid is null))
      -- проверка занятости аудитории
      and ((dbo.uf_freeaid_s(@lsem,@lpsem,@week,@wday,@npair,@strid,@aid)=@aid) or (@aid is null))
      -- проверка вместимости аудитории
      and (dbo.uf_checkcapstrm(@strid,@aid)=1)
  begin
    -- уст-ка преп-ля для потока
    exec @res=dbo.stm_setstrmthr @strid, @tid
    -- изм-ние аудитории для поток. занятия
    update s set aid=@aid
      from tb_Schedule s
        join tb_Load l on s.lid=l.lid
      where s.week=@week and s.wday=@wday and s.npair=@npair and l.strid=@strid
    set @res=@res+@@rowcount
  end

  return @res


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

