-- выбор пуст. потоков
select *
  from tb_Stream s
  where not exists(select strid from tb_Load where strid=s.strid)

-- выбор несоответствия часов нагрузки и потока
select *
  from tb_Stream s
    join tb_Load l on l.strid=s.strid and l.hours<>s.hours

-- выбор несоответствия преподов нагрузки и потока: tid(lid=tid(strid)
select *
  from tb_Stream s
    join tb_Load l on l.strid=s.strid
  where isnull(s.tid,0)<>isnull(l.tid,0)

-- выбор занятий подгрупп в рамках поток. занятия
select *
  from tb_Schedule s
    join tb_Load l on l.lid=s.lid
  where (l.strid is not null) and (s.hgrp<>0)

