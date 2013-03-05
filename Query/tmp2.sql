declare
  @sem tinyint,
  @psem tinyint,
  @type tinyint,
  @kid bigint,
  @sbid bigint,
  @strid bigint,
  @lid bigint

set @sem=1
set @psem=1
set @type=1
set @kid=21
set @sbid=50

set @strid=1
set @lid=53

-- выбор свобод. групп (strid), к-рые м. добавить в strid
/*
select l.lid, g.grName, sb.sbName
  from tb_Workplan wp
    join tb_Group g on wp.grid=g.grid
    join tb_Subject sb on wp.sbid=sb.sbid
    join tb_Load l on wp.wpid=l.wpid
    join tb_Stream s on wp.sem=s.sem
      and l.psem=s.psem and l.type=s.type and l.hours=s.hours and wp.kid=s.kid
  where s.strid=@strid and l.strid is null
    and wp.grid not in (select grid from tb_Workplan w join tb_Load ld on w.wpid=ld.wpid where ld.strid=@strid)
*/

-- выбор свобод. групп (sem,psem,type,kid,sbid), не входящ. в потоки
/*
select l.lid, g.grName, s.sbName, l.hours
  from tb_Load l
    join tb_Workplan wp on l.wpid=wp.wpid
    join tb_Group g on wp.grid=g.grid
    join tb_Subject s on wp.sbid=s.sbid
  where wp.sem=@sem and l.psem=@psem and l.type=@type
    and wp.kid=@kid and wp.sbid=@sbid and l.strid is not null
*/

-- добавление группы в поток (strid, lid)
/*
update l set strid=s.strid
  from tb_Workplan wp
    join tb_Load l on wp.wpid=l.wpid and l.strid is null
    join tb_Stream s on wp.sem=s.sem and l.psem=s.psem and l.type=s.type
      and l.hours=s.hours and wp.kid=s.kid
  where l.lid=@lid and s.strid=@strid
    and wp.grid not in (select grid from tb_Workplan w join tb_Load ld on w.wpid=ld.wpid where ld.strid=@strid)
*/    

-- выбор заявок на дисциплину
-- + дисциплины, объед. через потоки (sem,psem,type,kid,sbid)

  select l.lid, wp.grid, g.grName, wp.sbid, sb.sbName, l.tid, t.tName, l.strid, l.hours
    from tb_Stream s
      join tb_Load l on s.strid=l.strid
      join tb_Workplan wp on l.wpid=wp.wpid
      join tb_Group g on wp.grid=g.grid
      join tb_Subject sb on wp.sbid=sb.sbid
      left join tb_Teacher t on l.tid=t.tid
    where s.kid=@kid and wp.sem=@sem
      and s.type=@type and s.psem=@psem
  union
  select l.lid, wp.grid, g.grName, wp.sbid, sb.sbName, l.tid, t.tName, l.strid, l.hours
    from tb_Load l
      join tb_Workplan wp on l.wpid=wp.wpid
      join tb_Group g on wp.grid=g.grid
      join tb_Subject sb on wp.sbid=sb.sbid
      left join tb_Teacher t on l.tid=t.tid
    where wp.sem=@sem and l.psem=@psem
      and l.type=@type and wp.kid=@kid and wp.sbid=@sbid


-- выбор преп-лей для нагрузки (lid)
/*  select t.tid, t.tName
    from tb_Load l
      join tb_Workplan wp on l.wpid=wp.wpid
      join tb_Teacher t on wp.kid=t.kid
    where lid=@lid
*/

