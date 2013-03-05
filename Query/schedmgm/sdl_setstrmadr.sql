-- уст-ка аудитории для всего поток. занятия (strid,week,wday,npair,aid)
declare
  @strid bigint,
  @week tinyint,
  @wday tinyint,
  @npair tinyint,
  @aid bigint

set @strid=3
set @week=0
set @wday=1
set @npair=5
set @aid=5

  declare
    @lsem tinyint,
    @lpsem tinyint
  
  select @lsem=sem, @lpsem=psem from tb_Stream where strid=@strid
  
  if dbo.uf_freeaudit(@lsem,@lpsem,@week,@wday,@npair,@aid)=1 and
      dbo.uf_checkcapstrm(@strid,@aid)=1
    update s set aid=@aid
      from tb_Schedule s
        join tb_Load l on s.lid=l.lid
      where s.week=@week and s.wday=@wday and s.npair=@npair and l.strid=@strid
