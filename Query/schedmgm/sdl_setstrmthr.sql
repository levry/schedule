-- уст-ка преп-ля для всего поток. занятия (strid,week,wday,npair,tid)
declare
  @strid bigint,
  @week tinyint,
  @wday tinyint,
  @npair tinyint,
  @tid bigint

set @strid=3
set @week=0
set @wday=1
set @npair=5
set @tid=2

  declare
    @lsem tinyint,
    @lpsem tinyint
  
  select @lsem=sem, @lpsem=psem from tb_Stream where strid=@strid
  
  if dbo.uf_freeteach(@lsem,@lpsem,@week,@wday,@npair,@tid)=1
    update s set tid=@tid
      from tb_Schedule s
        join tb_Load l on s.lid=l.lid
      where s.week=@week and s.wday=@wday and s.npair=@npair and l.strid=@strid
