-- 608 выбор свобод. преп-лей (lid,week,wday,npair)

declare
  @lid bigint,
  @week tinyint,
  @wday tinyint,
  @npair tinyint


declare
  @lsem tinyint,
  @lpsem tinyint,
  @lkid bigint

-- выборка sem,psem,kid
select @lsem=w.sem, @lpsem=l.psem, @lkid=w.kid
  from tb_Workplan w
    join tb_Load l on w.wpid=l.wpid
  where l.lid=@lid

-- выборка свобод. преп-лей
select t.tid, t.tName, dbo.ud_prefteach(t.tid,@wday,@npair) as tprefer
  from tb_Teacher t
  where t.kid=@lkid and not exists(
    select s.lid
      from tb_Schedule s
        join tb_Load l on s.lid=l.lid
        join tb_Workplan w on l.wpid=w.wpid
      where w.sem=@lsem and l.psem=@lpsem and s.tid=t.tid
        and (s.week=@week or s.week=0) and s.wday=@wday and s.npair=@npair)

