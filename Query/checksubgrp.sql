declare
  @week tinyint,
  @wday tinyint,
  @npair tinyint,
  @hgrp tinyint,
  @lid bigint


declare
  @lsem tinyint,
  @lpsem tinyint,
  @lgrid bigint

set @lid=12

set @wday=1
set @npair=2
set @week=1
set @hgrp=1

select @lsem=w.sem, @lpsem=l.psem, @lgrid=w.grid
  from tb_Workplan w
    join tb_Load l on l.wpid=w.wpid
  where l.lid=@lid

select s.lid
  from tb_Schedule s
    join tb_Load l on l.lid=s.lid
    join tb_Workplan w on w.wpid=l.wpid and w.grid=@lgrid
  where w.sem=@lsem and l.psem=@lpsem and s.wday=@wday and s.npair=@npair
    and s.week=@week and s.lid<>@lid
    and ((@hgrp=0) or (@hgrp=1 and s.hgrp=0))



