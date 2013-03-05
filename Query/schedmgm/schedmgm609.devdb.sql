-- 609 выбор возможных занятий (sem,psem,week,wday,npair,grid,sbid)
declare
  @sem tinyint,
  @psem tinyint,

  @week tinyint,
  @wday tinyint,
  @npair tinyint,

  @grid bigint,
  @sbid bigint

/*
 вывод
  1) лекции: доступно часов, lid
  2) практики: доступно часов, lid
  3) лабы: доступно часов, lid
  4) поток:
    - лекции: доступно часов, strid, отсутсвие занятий у поток. групп
    - практики: доступно часов, strid, отсутсвие занятий у поток. групп
    - лабы: доступно часов, strid, отсутсвие занятий у поток. групп
*/

set @sem=1
set @psem=1
set @grid=6
set @sbid=23
set @week=1
set @wday=1
set @npair=1

select 
    w.wpid,
    dbo.uf_existshgrp(@sem,@psem,@week,@wday,@npair,@grid) as hgrp,    -- стоит подгруппа
    -- лекц. занятие    
    ll.lid as llid,  -- lid лекции
    ll.strid as lstrid,  -- лекц. strid
    dbo.uf_checkstrm(ll.strid,@week,@wday,@npair) as lchk, -- возможность вставить
    dbo.uf_getavail(ll.lid) as lh, -- доступ. лекц. часы
    ll.tid as ltid,  -- tid лектора
    (select tName from tb_Teacher where tid=ll.tid) as lname, -- фам. лектора
    dbo.uf_freeteach(@sem,@psem,@week,@wday,@npair,ll.tid) lfree,  -- доступность лектора
    dbo.uf_prefteach(ll.tid,@wday,@npair) as lpref,  -- предпочтение лектора
    -- практич. занятие
    lp.lid as plid,  -- lid практики
    lp.strid as pstrid,  -- практич. strid
    dbo.uf_checkstrm(lp.strid,@week,@wday,@npair) as pchk,  -- возможность вставить
    dbo.uf_getavail(lp.lid) as ph,  -- доступ. часы практики
    lp.tid as ptid,  -- tid практика
    (select tName from tb_Teacher where tid=lp.tid) as pname, -- фам. практика
    dbo.uf_freeteach(@sem,@psem,@week,@wday,@npair,lp.tid) as pfree,  -- доступность практика
    dbo.uf_prefteach(lp.tid,@wday,@npair) as ppref, -- предпочтение практика
    -- лабор. занятие
    lb.lid as blid,  -- lid лаборанта
    lb.strid as bstrid,  -- лаборат. strid
    dbo.uf_checkstrm(lb.strid,@week,@wday,@npair) as bchk,  -- возможность вставить
    dbo.uf_getavail(lb.lid) as bh,  -- доступ. лаб. часы
    lb.tid as btid,  -- tid лаборанта
    (select tName from tb_Teacher where tid=lb.tid) as bname, -- фам. лаборанта
    dbo.uf_freeteach(@sem,@psem,@week,@wday,@npair,lb.tid) as bfree,  -- доступность лаборанта
    dbo.uf_prefteach(lb.tid,@wday,@npair) as bpref  -- предпочтение лаборанта

  from tb_Workplan w
    left join tb_Load ll on ll.wpid=w.wpid and ll.psem=@psem and ll.type=1
    left join tb_Load lp on lp.wpid=w.wpid and lp.psem=@psem and lp.type=2
    left join tb_Load lb on lb.wpid=w.wpid and lb.psem=@psem and lb.type=3
  where w.sem=@sem and w.sbid=@sbid and w.grid=@grid
  