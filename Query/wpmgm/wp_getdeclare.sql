-- выбор заявок на кафедру (sem, kid)
CREATE PROCEDURE dbo.wp_getdeclare
(
@sem tinyint,
@kid bigint
)
AS
  set nocount on

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
