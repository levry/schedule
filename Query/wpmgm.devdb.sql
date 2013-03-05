/*
  1 просмостр раб. плана группы (grid, year, sem)
  2 выбор заявок для указ. кафедры (year, sem, kid)
  3 выбор заявок для указ. кафедры+дисциплина (year, sem, kid, sbid)
*/

declare
  @opertype int,
  @sem tinyint,
  @psem tinyint,
  @grid bigint,
  @kid bigint,
  @sbid bigint,
  @type tinyint

set @grid=1
set @opertype=3
set @sem=1
set @kid=21

set @sbid=22
set @type=3
set @psem=2

if @opertype=1
  select 
      wp.sbCode, s.sbName, wp.TotalHLP, wp.TotalAHLP, wp.Compl, wp.WP1,
      (select isnull(sum(hours),0) from tb_Load l where l.wpid=wp.wpid and type=1 and psem=1) as l1,  -- лекц. часы в 1п/с
      (select isnull(sum(hours),0) from tb_Load l where l.wpid=wp.wpid and type=2 and psem=1) as p1, -- практ. в 1п/с
      (select isnull(sum(hours),0) from tb_Load l where l.wpid=wp.wpid and type=3 and psem=1) as lb1, -- лаб. в 1п/с
      wp.WP2,
      (select isnull(sum(hours),0) from tb_Load l where l.wpid=wp.wpid and type=1 and psem=2) as l2,  -- лекц. в 2п/с
      (select isnull(sum(hours),0) from tb_Load l where l.wpid=wp.wpid and type=2 and psem=2) as p2, -- практ. в 2п/с
      (select isnull(sum(hours),0) from tb_Load l where l.wpid=wp.wpid and type=3 and psem=2) as lb2, -- лаб. в 2п/с
      Kp, Kr, Rg, Cr, Hr, Koll, Z, E, k.kName
    from tb_Workplan wp
      left join tb_Subject s on wp.sbid=s.sbid
      left join tb_Kafedra k on wp.kid=k.kid
    where wp.grid=@grid and wp.Sem=@sem

if @opertype=2
  select 
      wp.sbCode, s.sbName, g.grName, wp.TotalHLP, wp.TotalAHLP, wp.Compl, wp.WP1,
      (select hours from tb_Load l where l.wpid=wp.wpid and type=1 and psem=1) as l1,  -- лекц. часы в 1п/с
      (select hours from tb_Load l where l.wpid=wp.wpid and type=2 and psem=1) as p1, -- практ. в 1п/с
      (select hours from tb_Load l where l.wpid=wp.wpid and type=3 and psem=1) as lb1, -- лаб. в 1п/с
      wp.WP2,
      (select hours from tb_Load l where l.wpid=wp.wpid and type=1 and psem=2) as l2,  -- лекц. в 2п/с
      (select hours from tb_Load l where l.wpid=wp.wpid and type=2 and psem=2) as p2, -- практ. в 2п/с
      (select hours from tb_Load l where l.wpid=wp.wpid and type=3 and psem=2) as lb2, -- лаб. в 2п/с
      Kp, Kr, Rg, Cr, Hr, Koll, Z, E
    from tb_Workplan wp
      left join tb_Subject s on wp.sbid=s.sbid
      left join tb_Group g on wp.grid=g.grid
    where wp.kid=@kid and wp.Sem=@sem

if @opertype=3
  select
      wp.sbCode, s.sbName, g.grName, wp.TotalHLP, wp.TotalAHLP, wp.Compl, wp.WP1,
      (select hours from tb_Load l where l.wpid=wp.wpid and type=1 and psem=1) as l1,  -- лекц. часы в 1п/с
      (select hours from tb_Load l where l.wpid=wp.wpid and type=2 and psem=1) as p1, -- практ. в 1п/с
      (select hours from tb_Load l where l.wpid=wp.wpid and type=3 and psem=1) as lb1, -- лаб. в 1п/с
      wp.WP2,
      (select hours from tb_Load l where l.wpid=wp.wpid and type=1 and psem=2) as l2,  -- лекц. в 2п/с
      (select hours from tb_Load l where l.wpid=wp.wpid and type=2 and psem=2) as p2, -- практ. в 2п/с
      (select hours from tb_Load l where l.wpid=wp.wpid and type=3 and psem=2) as lb2, -- лаб. в 2п/с
      Kp, Kr, Rg, Cr, Hr, Koll, Z, E
    from tb_Workplan wp
      left join tb_Subject s on wp.sbid=s.sbid
      left join tb_Group g on wp.grid=g.grid
--      join tb_Load l on wp.wpid=l.wpid and l.type=@type and l.psem=@psem
    where wp.Sem=@sem and wp.kid=@kid and wp.sbid=@sbid
 