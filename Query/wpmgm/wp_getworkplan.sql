-- выборка р.п. группы (sem, grid)
CREATE PROCEDURE dbo.wp_getworkplan
(
@sem tinyint,
@grid bigint
)
AS
  set nocount on

  select 
      wp.sbCode, s.sbName, wp.TotalHLP, wp.TotalAHLP, wp.Compl, wp.WP1,
      (select hours from tb_Load l where l.wpid=wp.wpid and type=1 and psem=1) as l1,  -- лекц. часы в 1п/с
      (select hours from tb_Load l where l.wpid=wp.wpid and type=2 and psem=1) as p1, -- практ. в 1п/с
      (select hours from tb_Load l where l.wpid=wp.wpid and type=3 and psem=1) as lb1, -- лаб. в 1п/с
      wp.WP2,
      (select hours from tb_Load l where l.wpid=wp.wpid and type=1 and psem=2) as l2,  -- лекц. в 2п/с
      (select hours from tb_Load l where l.wpid=wp.wpid and type=2 and psem=2) as p2, -- практ. в 2п/с
      (select hours from tb_Load l where l.wpid=wp.wpid and type=3 and psem=2) as lb2, -- лаб. в 2п/с
      Kp, Kr, Rg, Cr, Hr, Koll, Z, E, k.kName
    from tb_Workplan wp
      left join tb_Subject s on wp.sbid=s.sbid
      left join tb_Kafedra k on wp.kid=k.kid
    where wp.grid=@grid and wp.Sem=@sem
