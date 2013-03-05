declare
  @sem tinyint,
  @psem tinyint,
  @lid bigint,
  @week tinyint,
  @wday tinyint,
  @npair tinyint,
  @hgrp tinyint,
  @tid bigint,
  @aid bigint

declare
  @lgrid bigint,
  @rows int

set @sem=1
set @psem=1
set @lid=47
set @week=1
set @wday=1
set @npair=2
set @hgrp=0
set @aid=1
set @tid=2

--set @lgrid=8

--set @rows=dbo.uf_freeteachgrp(@sem,@psem,@week,@wday,@npair,@tid,@lgrid)
--print @rows

      select sc.lid
        from tb_Schedule sc
          join tb_Load l on sc.lid=l.lid
          join tb_Workplan w on l.wpid=w.wpid
        where w.sem=@sem and l.psem=@psem and sc.wday=@wday
          and sc.npair=@npair and sc.tid=@tid
          and ((@week=0)or((@week<>0)and(sc.week in (0,@week))))
--          and isnull(w.grid,0)<>isnull(@lgrid,0)

  select t.tid, t.tName, dbo.uf_prefteach(t.tid,@wday,@npair) as tprefer
    from tb_Teacher t
    where not exists(
      select s.lid
        from tb_Schedule s
          join tb_Load l on s.lid=l.lid
          join tb_Workplan w on l.wpid=w.wpid
        where w.sem=@sem and l.psem=@psem and s.tid=t.tid  and s.wday=@wday and s.npair=@npair
           and ((@week=0)or((@week<>0)and(s.week in (0,@week))))  )
