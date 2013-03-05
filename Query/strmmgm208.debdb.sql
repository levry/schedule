declare
  @sem tinyint,
  @psem tinyint,
  @type tinyint,
  @kid bigint,
  @sbid bigint,

  @strid bigint

set @sem=1
set @psem=1
set @type=1
set @kid=21
set @sbid=50

set @strid=1

-- все заявки на кафедру  (sem,kid)
select ld.lid, wp.grid, g.grName, wp.sbid, s.sbName, ld.tid, t.tName, ld.strid, ld.hours
  from tb_Workplan wp
    join tb_Load ld on wp.wpid=ld.wpid
    join tb_Group g on wp.grid=g.grid
    join tb_Subject s on wp.sbid=s.sbid
    left join tb_Teacher t on ld.tid=t.tid
  where wp.sem=@sem and wp.kid=@kid
    and ld.psem=@psem and ld.type=@type
and (exists(
-- все потоки кафедры
select *
  from tb_Stream s
  where s.kid=wp.kid and strid=ld.strid
and exists(
-- проверка принадлжености sbid к strid (strid,sbid,kid)
select *
  from tb_Load l
    join tb_Workplan w on l.wpid=w.wpid
  where l.strid=s.strid and w.sbid=@sbid
)) or wp.sbid=@sbid)

/*
select *
  from tb_Workplan w
  where w.sem=@sem and w.kid=@kid and
    (exists(
      select *
        from tb_Stream s
          join tb_Load l on s.strid=l.strid
          join w on l.wpid=w.wpid
--          join tb_Workplan wp on l.wpid=wp.wpid
        where s.kid=@kid and sbid=@sbid)
    or w.sbid=@sbid)
*/

/*
select *
  from tb_Load l
    join tb_Workplan wp on l.wpid=wp.wpid
  where wp.sem=@sem and l.psem=@psem and l.type=@type and wp.kid=@kid
    and exists(select * from tb_Stream s join tb_Load ld on  where)
*/
/*
select l.lid, wp.grid, g.grName, wp.sbid, s.sbName, l.tid, t.tName, l.strid, l.hours
  from tb_Workplan wp
    join tb_Load l on wp.wpid=l.wpid
    join tb_Group g on wp.grid=g.grid
    join tb_Subject s on wp.sbid=s.sbid
    left join tb_Teacher t on l.tid=t.tid
  where wp.sem=@sem and l.psem=@psem and l.type=@type and wp.kid=@kid
    and exists(select * from tb_Stream s join tb_Workplan w on s.kid=w.kid where w.wpid=wp.wpid and w.sbid=@sbid)
*/
-- заявки на кафедру (kid,sbid)
/*
select l.lid, wp.grid, g.grName, wp.sbid, s.sbid, l.tid, t.tName, l.strid, l.hours
  from tb_Load l
    join tb_Workplan wp on l.wpid=wp.wpid
    join tb_Group g on wp.grid=g.grid
    join tb_Subject s on wp.sbid=s.sbid
    left join tb_Teacher t on l.tid=t.tid
  where wp.sem=@sem and l.psem=@psem and l.type=@type
    and wp.kid=@kid and wp.sbid=@sbid
*/
