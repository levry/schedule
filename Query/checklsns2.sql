declare
@sem tinyint,
@psem tinyint,
@week tinyint,
@wday tinyint,
@npair tinyint,
@hgrp tinyint,
@grid bigint

set @sem=1
set @psem=1
set @wday=1
set @npair=6
set @week=2
set @hgrp=0
set @grid=22

print dbo.uf_checklsns(@sem,@psem,@week,@wday,@npair,@hgrp,@grid)

/*
select s.lid, s.week, s.hgrp
  from tb_Schedule s
    join tb_Load l on s.lid=l.lid
    join tb_Workplan w on l.wpid=w.wpid
  where w.grid=@grid
    and w.sem=@sem and l.psem=@psem and s.wday=@wday and s.npair=@npair
    and 
    (
      (@week=0 and s.week<>0) or (@week<>0 and s.week=0)
      or ((@hgrp=0 or  s.hgrp=0) and s.week=@week)
    )

    (
      ( (@week=0 and @hgrp=0) or (@week=0 and ( (@hgrp=1 and s.hgrp=0) or s.week<>0) ) )
--      ((@week=0 and @hgrp=0) or (@week=0 and (@hgrp=1 and s.hgrp=0)) or (@week=0 and s.week<>0))
      or
      ((@week<>0 and s.week=0) or  -- стоит на кажд. недели (хотим через неделю)
      (@week<>0 and s.week in (0,@week) and @hgrp=0) or
      (@week<>0 and s.week in (0,@week) and (@hgrp=1 and s.hgrp=0)))
    )
*/
