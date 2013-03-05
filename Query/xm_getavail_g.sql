declare
@grid bigint,
@sem tinyint,
@xmtype tinyint,
@xmtime datetime

set @grid=22
set @sem=1
set @xmtype=0
set @xmtime='2006-01-21 10:00'


select
  w.wpid,@xmtype as xmtype, @xmtime as xmtime,
  s.sbName,
  ll.psmall, ll.initials,

  dbo.uf_existsxm(w.wpid,@xmtype) as [exists],
  dbo.uf_freetid_xm(w.wpid,@xmtime) as [tfree],
  dbo.uf_chkorder_xm(w.wpid,@xmtype,@xmtime) as [order],
  dbo.uf_chktime_xm(w.wpid,@xmtype,@xmtime,0) as [full],
  dbo.uf_chktime_xm(w.wpid,@xmtype,@xmtime,1) as [half]
  
from tb_Workplan w
  join tb_Subject s on s.sbid=w.sbid
  left join 
    (select distinct l.wpid, t.tid, t.Initials, p.psmall
        from tb_Load l
          join tb_Teacher t on t.tid=l.tid
          join tb_Post p on p.pid=t.pid
        where l.type=1) ll
    on ll.wpid=w.wpid
where w.grid=@grid and w.sem=@sem and w.e>0
