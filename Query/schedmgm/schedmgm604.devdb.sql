-- 604 установка поток. занятия (strid,week,wday,npair)
declare
  @strid bigint,
  @week tinyint,
  @wday tinyint,
  @npair tinyint
--  @aid tinyint

declare
  @lsem tinyint,
  @lpsem tinyint,
  @ltype tinyint

set @strid=3
set @week=1
set @wday=1
set @npair=5

-- выборка sem,psem
select @lsem=sem, @lpsem=psem
  from tb_Stream
  where strid=@strid

print 'sem:  '+cast(@lsem as varchar)
print 'psem: '+cast(@lpsem as varchar)


-- лекц. поток: один преп-ль, одна аудитория
-- практ. и лаб. поток: отдельно для кажд. группы

if
  -- проверка на отсутствие занятий у поточ. групп
  dbo.uf_checkstrm(@strid,@week,@wday,@npair)=1 and
-- проверка занятости лектора
-- проверка занятости аудитории
--print dbo.uf_freeaudit(@lsem,@lpsem,@week,@wday,@npair,@aid)
-- проверка вместимости аудитории (поток)
--print dbo.uf_checkcapstrm(@strid,@aid)
-- проверка на превышение нормы нагрузки потоком
  dbo.uf_checkloadstrm(@strid,@week)=1
begin
-- вставка нов. занятия
  insert tb_Schedule (lid,[week],wday,npair,hgrp,tid)
    select lid,@week,@wday,@npair,0,dbo.uf_freestrmtid(@lsem,@lpsem,@week,@wday,@npair,@strid,tid)
      from tb_Load
      where strid=@strid
end
