declare
  @sem tinyint,
  @psem tinyint,
  @grid bigint

set @sem=1
set @psem=1
set @grid=22

select w.wpid,w.grid,w.sbid,w.sbCode,s.sbName,w.kid,k.kName,w.sem,
    w.totalhlp,w.totalahlp,w.compl,w.kp,w.kr,w.rg,w.cr,w.hr,w.koll,w.z,w.e,
    l.lid,l.psem,l.type,l.hours,l.tid,t.tName,l.strid
  from tb_Workplan w
    left join tb_Load l on l.wpid=w.wpid
    left join tb_Subject s on s.sbid=w.sbid
    left join tb_Kafedra k on k.kid=w.kid
    left join tb_Teacher t on t.tid=l.tid
  where w.sem=@sem and l.psem=@psem and w.grid=@grid