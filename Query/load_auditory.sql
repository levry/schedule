-- загрузка аудторий в расписании по на отдельные учебные дни
declare
  @ynum smallint,
  @sem tinyint,
  @psem tinyint

set @ynum=2006
set @sem=1
set @psem=1

select a.aid,a.aname,s.wday,
    sum(
      case 
        when s.[week]=0 then 2 
        when s.[week] in (1,2) then 1
        else 0
      end)as hours
  from tb_auditory a
    left join
      (select distinct week,wday,npair,aid
        from vw_schedule
        where ynum=@ynum and sem=@sem and psem=@psem) s on s.aid=a.aid
  where a.aid=22 and  s.npair is not null
  group by a.aid,a.aname,s.wday
