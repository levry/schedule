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

set @lid=17

set @wday=1
set @npair=2
set @week=2
set @hgrp=0

select @lsem=w.sem, @lpsem=l.psem, @lgrid=w.grid
  from tb_Workplan w
    join tb_Load l on l.wpid=w.wpid
  where l.lid=@lid

select s.lid
  from tb_Schedule s
    join tb_Load l on l.lid=s.lid
    join tb_Workplan w on w.wpid=l.wpid and w.grid=@lgrid
  where w.sem=@lsem and l.psem=@lpsem and s.wday=@wday and s.npair=@npair
    and s.lid<>@lid and
    (
      ((@week=0 and @hgrp=0) or (@week=0 and (@hgrp=1 and s.hgrp=0)) or (@week=0 and s.week<>0))
    or
      ((@week<>0 and s.week=0) or
       (@week<>0 and s.week in (0,@week) and @hgrp=0) or
       (@week<>0 and s.week in (0,@week) and (@hgrp=1 and s.hgrp=0)))
    )



