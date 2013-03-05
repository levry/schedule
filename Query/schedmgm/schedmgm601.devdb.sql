-- 601 выбор расписания группы (sem,psem,grid)
declare
  @sem tinyint,
  @psem tinyint,
  @grid bigint

set @sem=1
set @psem=1
set @grid=6

  select 
      sc.lid,
      l.strid,
  
      w.sbid,
      s.sbName,
  
      sc.tid,
      t.tName,
      dbo.uf_prefteach(sc.tid,sc.wday,sc.npair) as tprefer,
  
      sc.aid,
      a.aName,
      dbo.uf_prefaudit(sc.aid,sc.wday,sc.npair) as aprefer,
  
      sc.[week],
      sc.wday,
      sc.npair,
      sc.hgrp,
      l.type
    from tb_Schedule sc
      join tb_Load l on sc.lid=l.lid
      join tb_Workplan w on l.wpid=w.wpid
      join tb_Subject s on w.sbid=s.sbid
      left join tb_Auditory a on sc.aid=a.aid
      left join tb_Teacher t on sc.tid=t.tid
    where w.sem=@sem and l.psem=@psem and w.grid=@grid
  

