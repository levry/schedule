-- проверка на возможность смены подгрупп<->пол. группы потока (strid,week,wday,npair,hgrp)
declare
@strid bigint,
@week tinyint,
@wday tinyint,
@npair tinyint,
@hgrp tinyint

set @strid=24
set @wday=1
set @npair=7
set @week=2
set @hgrp=0

declare
@lsem tinyint,
@lpsem tinyint

select @lsem=sem, @lpsem=psem from tb_Stream where strid=@strid
--select grid from tb_workplan ww join tb_load ll on ll.wpid=ww.wpid and ll.strid=@strid

select *
  from tb_Schedule s
    join tb_Load l on l.lid=s.lid
    join tb_Workplan w on w.wpid=l.wpid
  where w.sem=@lsem and l.psem=@lpsem and s.wday=@wday and s.npair=@npair
    and w.grid in (select grid from tb_workplan ww join tb_load ll on ll.wpid=ww.wpid and ll.strid=@strid)
    and (l.strid<>@strid or l.strid is null) and
(
((@hgrp=0 or s.hgrp=0) and (s.week=@week))
or    
(@week=0 and s.week<>0) or (@week<>0 and s.week=0)
)