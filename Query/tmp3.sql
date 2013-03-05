-- выборка нагрузок для группы (sem,psem,grid)
declare
  @sem tinyint,
  @psem tinyint,
  @grid bigint

set @sem=1
set @psem=1
set @grid=6

select *
  from tb_Load l
    join tb_Workplan w on l.wpid=w.wpid
    join tb_Subject s on w.sbid=s.sbid
  where w.sem=@sem and l.psem=@psem and w.grid=@grid