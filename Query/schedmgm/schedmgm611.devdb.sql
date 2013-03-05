-- 611 выбор свобод. аудиторий (вместимость) (week,wday,npair,lid)
declare
  @lid bigint,
  @week tinyint,
  @wday tinyint,
  @npair tinyint

declare
  @lsem tinyint,
  @lpsem tinyint,
  @mans int

-- выборка year,sem,psem,studs
select @lsem=w.sem, @lpsem=l.psem, @mans=g.studs
  from tb_Workplan w
    join tb_Load l on w.wpid=l.wpid
    join tb_Group g on w.grid=g.grid
  where l.lid=@lid
-- выбор свобод. аудиторий
select aid, aName, dbo.uf_prefaudit(aid,@wday,@npair)as aprefer
  from tb_Auditory a
  where a.capacity>=@mans and not exists(
    select s.lid
      from tb_Schedule s
        join tb_Load l on s.lid=l.lid
        join tb_Workplan w on l.wpid=w.wpid
      where w.sem=@lsem and l.psem=@lpsem and (s.week=@week or s.week=0)
        and s.wday=@wday and s.npair=@npair and aid=a.aid)
