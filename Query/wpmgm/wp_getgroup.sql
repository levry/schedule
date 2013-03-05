-- ��ᬮ�� �.�. ��㯯� (sem,grid)
declare
  @sem tinyint,
  @grid bigint

  select 
      wp.sbCode, s.sbName, wp.TotalHLP, wp.TotalAHLP, wp.Compl, wp.WP1,
      (select hours from tb_Load l where l.wpid=wp.wpid and type=1 and psem=1) as l1,  -- ����. ��� � 1�/�
      (select hours from tb_Load l where l.wpid=wp.wpid and type=2 and psem=1) as p1, -- �ࠪ�. � 1�/�
      (select hours from tb_Load l where l.wpid=wp.wpid and type=3 and psem=1) as lb1, -- ���. � 1�/�
      wp.WP2,
      (select hours from tb_Load l where l.wpid=wp.wpid and type=1 and psem=2) as l2,  -- ����. � 2�/�
      (select hours from tb_Load l where l.wpid=wp.wpid and type=2 and psem=2) as p2, -- �ࠪ�. � 2�/�
      (select hours from tb_Load l where l.wpid=wp.wpid and type=3 and psem=2) as lb2, -- ���. � 2�/�
      Kp, Kr, Rg, Cr, Hr, Koll, Z, E, k.kName
    from tb_Workplan wp
      left join tb_Subject s on wp.sbid=s.sbid
      left join tb_Kafedra k on wp.kid=k.kid
    where wp.grid=@grid and wp.Sem=@sem
