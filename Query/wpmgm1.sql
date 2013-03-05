declare
  @opertype int,
  @grid bigint,
  @sem tinyint

set @grid=6
set @opertype=1
set @sem=1

  select 
      wp.sbCode, s.sbName, wp.TotalHLP, wp.TotalAHLP, wp.Compl, wp.WP1, 

      (WP1*(isnull(l1.h,0)+isnull(p1.h,0)+isnull(lb1.h,0))
        +WP2*(isnull(l2.h,0)+isnull(p2.h,0)+isnull(lb2.h,0))) as Cur,
      cast(isnull(l1.h,0)as varchar(3))+'/'+cast((isnull(p1.h,0)+isnull(lb1.h,0))as varchar(3)) as psem1,
      cast(isnull(l2.h,0)as varchar(3))+'/'+cast((isnull(p2.h,0)+isnull(lb2.h,0))as varchar(3)) as psem2,
      WP1*isnull(l1.h,0)+WP2*isnull(l2.h,0) as lect,
      WP1*isnull(p1.h,0)+WP2*isnull(p2.h,0) as pract,
      WP1*isnull(lb1.h,0)+WP2*isnull(lb2.h,0) as lab,

      Kp, Kr, Rg, Cr, Hr, Koll, Z, E, k.kName
    from tb_Workplan wp
      left join tb_Subject s on wp.sbid=s.sbid
      left join tb_Kafedra k on wp.kid=k.kid
      left join (select wpid, h=hours from tb_Load where type=1 and psem=1) l1 on wp.wpid=l1.wpid
      left join (select wpid, h=hours from tb_Load where type=2 and psem=1) p1 on wp.wpid=p1.wpid
      left join (select wpid, h=hours from tb_Load where type=3 and psem=1) lb1 on wp.wpid=lb1.wpid
      left join (select wpid, h=hours from tb_Load where type=1 and psem=2) l2 on wp.wpid=l2.wpid
      left join (select wpid, h=hours from tb_Load where type=2 and psem=2) p2 on wp.wpid=p2.wpid
      left join (select wpid, h=hours from tb_Load where type=3 and psem=2) lb2 on wp.wpid=lb2.wpid
    where wp.grid=@grid and wp.Sem=@sem
