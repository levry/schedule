-- выбор возмож. занятий по типу (sem,psem,week,wday,npair,grid)


declare
  @sem tinyint,
  @psem tinyint,
  @week tinyint,
  @wday tinyint,
  @npair tinyint,
  @grid bigint,


set @sem=1
set @psem=1
set @week=0
set @wday=1
set @npair=1
set @grid=22

--select *
select w.wpid,w.sbid,s.sbName,s.sbSmall,
    l.lid,l.tid,p.pSmall,t.Initials,dbo.uf_freeteach(@sem,@psem,@week,@wday,@npair,l.tid) as tfree,
    dbo.uf_prefteach(l.tid,@wday,@npair) as tprefer,
    l.hours,dbo.uf_getavail(l.lid) as ahours,
    l.strid,dbo.uf_checkstrm(l.strid,@week,@wday,@npair) as chkstm,
    dbo.uf_checklsns(@sem,@psem,@week,@wday,@npair,0,@grid) as chklsns,
    dbo.uf_existshgrp(@sem,@psem,@week,@wday,@npair,@grid) as hgrp
  from tb_Workplan w
    join tb_Load l on l.wpid=w.wpid
    join tb_Subject s on s.sbid=w.sbid
    left join tb_Teacher t on t.tid=l.tid
    left join tb_Post p on p.pid=t.pid
  where w.sem=@sem and l.psem=@psem
    and w.grid=@grid