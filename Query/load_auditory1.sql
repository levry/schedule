-- выборка загрузки аудиторий в расписании
declare
  @ynum smallint,
  @sem tinyint,
  @psem tinyint

set @ynum=2005
set @sem=1
set @psem=1

select a.aid,a.aname,
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
  group by a.aid,a.aname
