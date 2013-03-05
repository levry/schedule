
declare
  @lid bigint,
  @week tinyint,
  @wday tinyint,
  @npair tinyint,
  @hgrp tinyint,

  @res tinyint,
  @lsem tinyint,
  @lpsem tinyint,
  @lgrid bigint

set @lid=1121--1121--801
set @week=0
set @wday=1--1--2
set @npair=5--5--6
set @hgrp=0

select *
  from tb_Schedule
  where lid=@lid and [week]=@week and wday=@wday and npair=@npair

-- выборка sem, psem, grid от lid
select @lsem=w.sem, @lpsem=l.psem, @lgrid=w.grid
  from tb_Workplan w
    join tb_Load l on l.wpid=w.wpid
  where l.lid=@lid

-- если нет, то true
select *--s.lid
  from tb_Schedule s
    join tb_Load l on l.lid=s.lid
    join tb_Workplan w on w.wpid=l.wpid and w.grid=@lgrid
  where w.sem=@lsem and l.psem=@lpsem and s.wday=@wday and s.npair=@npair
    and s.week=@week
    and ((s.lid<>@lid and l.strid is null) or (s.lid=@lid and l.strid is not null))
    and ((@hgrp=0) or (@hgrp=1 and (s.hgrp=0)))  
--    and s.week=@week and s.lid<>@lid and ((@hgrp=0) or (@hgrp=1 and s.hgrp=0))  
