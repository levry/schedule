-- 606 удаление поток. занятия (strid,week,wday,npair)
declare
  @strid bigint,
  @week tinyint,
  @wday tinyint,
  @npair tinyint

  delete s
    from tb_Schedule s
      join tb_Load l on s.lid=l.lid
    where s.week=@week and s.wday=@wday and s.npair=@npair and l.strid=@strid