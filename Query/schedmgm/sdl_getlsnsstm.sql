-- выборка поточ. занятия (strid,[wday,npair])
declare
  @strid bigint,
--  @week tinyint,
  @wday tinyint,
  @npair tinyint

set @strid=3
--set @week=0
set @wday=1
set @npair=5

select 
    s.lid, l.strid,
    w.sbid, sb.sbName,
    s.tid, t.tName, dbo.uf_prefteach(s.tid,s.wday,s.npair) as tprefer,
    s.aid, a.aName, dbo.uf_prefaudit(s.aid,s.wday,s.npair) as aprefer,
    s.[week],
    s.wday,
    s.npair,
    s.hgrp,
    l.type
  from tb_Schedule s
    join tb_Load l on l.lid=s.lid
    join tb_Workplan w on w.wpid=l.wpid
    join tb_Subject sb on sb.sbid=w.sbid
    left join tb_Teacher t on t.tid=s.tid
    left join tb_Auditory a on a.aid=s.aid
  where l.strid=@strid
    and (((@wday is not null) and (@npair is not null)) and (s.wday=@wday and s.npair=@npair)
    or (@wday is null or @npair is null))