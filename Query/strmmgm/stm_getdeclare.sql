-- выбор потоков для кафедры+дисциплины (sem, psem, type, kid, sbid)
declare
  @sem tinyint,
  @psem tinyint,
  @type tinyint,
  @kid bigint,
  @sbid bigint

select l.strid, l.lid, wp.grid, g.grName, wp.sbid, s.sbName, l.tid, t.tName
  from tb_Load l
    join tb_Workplan wp on l.wpid=wp.wpid
    left join tb_Group g on wp.grid=g.grid
    left join tb_Subject s on wp.sbid=s.sbid
    left join tb_Teacher t on l.tid=t.tid
  where wp.sem=@sem and l.psem=@psem and l.type=@type
    and l.strid in (select strid from tb_Load l1 join tb_Workplan w1 on l1.wpid=w1.wpid where w1.sbid=@sbid and strid is not null)
