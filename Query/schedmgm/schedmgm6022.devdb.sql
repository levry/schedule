-- 604 изм-ние занятия (lid,week,wday,npair,hgrp,aid,tid)
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

set @lid=12
set @wday=1
set @npair=2
set @week=1
set @hgrp=1
--set @aid=1
--set @tid=3


  set @rows=0

  if exists(
      select lid from tb_Schedule
        where lid=@lid and [week]=@week and wday=@wday and npair=@npair)
  begin
    -- опр-ние sem,psem,grid от lid
    select @lsem=w.sem, @lpsem=l.psem, @lgrid=grid
      from tb_Load l
        join tb_Workplan w on l.wpid=w.wpid
      where l.lid=@lid
    if --(@lsem is not null) and (@lpsem is not null) and (@lgrid is not null) and
      -- проверка занятости преподавателя
      (dbo.uf_freeteachlid(@lsem,@lpsem,@week,@wday,@npair,@tid,@lid)=1) and
      -- проверка занятости аудитории
      (dbo.uf_freeauditlid(@lsem,@lpsem,@week,@wday,@npair,@aid,@lid)=1) and
      -- проверка вместимости аудитории
      (dbo.uf_checkcapgrp(@lgrid,@aid,@hgrp)=1) and
      -- проверка изм-ния hgrp
      (dbo.uf_checkhgrp(@lid,@week,@wday,@npair,@hgrp)=1)
    begin
      -- обновление занятия
      update tb_Schedule set hgrp=@hgrp, aid=@aid, tid=@tid
        where lid=@lid and [week]=@week and wday=@wday and npair=@npair
      set @rows=@@rowcount
    end
  end

print @rows






