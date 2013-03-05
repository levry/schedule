declare
  @sem tinyint,
  @psem tinyint,
  @kid bigint,
  @type tinyint

set @sem=1
set @psem=1
set @kid=21
set @type=1


select
    l.strid,
    wp.sbCode,
    s.sbName,
    g.grName,
    g.studs,
    wp.TotalHLP,
    wp.TotalAHLP,
    wp.Compl,
    wp.WP1,
    (select isnull(sum(hours),0) from tb_Load where wpid=wp.wpid and type=1 and psem=1) as l1,  -- лекц. часы в 1п/с
    (select isnull(sum(hours),0) from tb_Load where wpid=wp.wpid and type<>1 and psem=1) as p1, -- практ. в 1п/с
    wp.WP2,
    (select isnull(sum(hours),0) from tb_Load where wpid=wp.wpid and type=1 and psem=2) as l2,  -- лекц. часы в 1п/с
    (select isnull(sum(hours),0) from tb_Load where wpid=wp.wpid and type<>1 and psem=2) as p2, -- практ. в 1п/с
    (select wp.WP1*isnull(sum(hours),0) from tb_Load where wpid=wp.wpid and type=2) as sumprak,
    (select wp.WP2*isnull(sum(hours),0) from tb_Load where wpid=wp.wpid and type=3) as sumlab,
    wp.Kp,
    wp.Kr,
    wp.Rg,
    wp.Cr,
    wp.Hr,
    wp.Koll,
    wp.Z,
    wp.E
  from tb_Workplan wp
    join tb_Subject s on wp.sbid=s.sbid
    join tb_Group g on wp.grid=g.grid
    left join tb_Load l on wp.wpid=l.wpid and l.type=@type and l.psem=@psem
  where wp.sem=@sem and wp.kid=@kid
  order by strid desc, sbName, sbCode, TotalHLP, TotalAHLP, Compl, WP1, l1, p1, WP2, l2,
    p2, sumprak, sumlab, Kp, Kr, Rg, Cr,Hr, Koll, Z, E, grName 


  