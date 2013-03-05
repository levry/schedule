-- 602 уст-ка занятия (lid,week,wday,npair,hgrp,aid,tid)
declare
  @lid bigint,
  @week tinyint,
  @wday tinyint,
  @npair tinyint,
  @hgrp tinyint,
  @tid bigint,
  @aid bigint

declare
  @lsem tinyint,
  @lpsem tinyint,
  @lgrid bigint,
  @rows int

--set @sem=1
--set @psem=1
set @lid=17
set @wday=1
set @npair=1
set @week=0
set @hgrp=0
set @aid=2
set @tid=2

set @rows=0


--if not exists(
    select lid from tb_Schedule
      where lid=@lid and [week]=@week and wday=@wday and npair=@npair--)
--begin
-- опр-ние sem,psem,grid от lid
select @lsem=w.sem, @lpsem=l.psem, @lgrid=grid
  from tb_Load l
    join tb_Workplan w on l.wpid=w.wpid
  where l.lid=@lid
--if
  -- проверка занятости преподавателя
print  dbo.uf_freeteach(@lsem,@lpsem,@week,@wday,@npair,@tid)--=1 and
  -- проверка занятости аудитории
print  dbo.uf_freeaudit(@lsem,@lpsem,@week,@wday,@npair,@aid)--=1 and
  -- проверка вместимости аудитории
print  dbo.uf_checkcapgrp(@lgrid,@aid,@hgrp)--=1 and
  -- проверка на превышение нормы нагрузки (х2 - на две недели)
print  dbo.uf_checkload(@lid,@week,@hgrp)--=1 and
  -- проверка возвможности поставить занятие на паре
print  dbo.uf_checklsns(@lsem,@lpsem,@week,@wday,@npair,@hgrp,@lgrid)--=1
--begin
  -- добавление занятия
--  insert tb_Schedule (lid,[week],wday,npair,hgrp,aid,tid)
--    values(@lid,@week,@wday,@npair,@hgrp,@aid,@tid)
--  set @rows=@@rowcount
--end
--end


--print @rows