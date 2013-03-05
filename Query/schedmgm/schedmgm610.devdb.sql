-- 610 выбор занятий потока (strid,wday,npair)

declare
  @strid bigint,
  @wday tinyint,
  @npair tinyint

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
    join tb_Load l on l.lid=sc.lid
    join tb_Workplan w on w.wpid=l.wpid
    join tb_Subject s on s.sbid=w.sbid
    left join tb_Auditory a on a.aid=sc.aid
    left join tb_Teacher t on t.tid=sc.tid
  where l.strid=@strid and sc.wday=@wday and sc.npair=@npair