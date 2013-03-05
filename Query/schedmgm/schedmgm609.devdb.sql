-- 609 �롮� ��������� ����⨩ (sem,psem,week,wday,npair,grid,sbid)
declare
  @sem tinyint,
  @psem tinyint,

  @week tinyint,
  @wday tinyint,
  @npair tinyint,

  @grid bigint,
  @sbid bigint

/*
 �뢮�
  1) ���樨: ����㯭� �ᮢ, lid
  2) �ࠪ⨪�: ����㯭� �ᮢ, lid
  3) ����: ����㯭� �ᮢ, lid
  4) ��⮪:
    - ���樨: ����㯭� �ᮢ, strid, �����ᢨ� ����⨩ � ��⮪. ��㯯
    - �ࠪ⨪�: ����㯭� �ᮢ, strid, �����ᢨ� ����⨩ � ��⮪. ��㯯
    - ����: ����㯭� �ᮢ, strid, �����ᢨ� ����⨩ � ��⮪. ��㯯
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
    dbo.uf_existshgrp(@sem,@psem,@week,@wday,@npair,@grid) as hgrp,    -- �⮨� �����㯯�
    -- ����. ����⨥    
    ll.lid as llid,  -- lid ���樨
    ll.strid as lstrid,  -- ����. strid
    dbo.uf_checkstrm(ll.strid,@week,@wday,@npair) as lchk, -- ����������� ��⠢���
    dbo.uf_getavail(ll.lid) as lh, -- �����. ����. ���
    ll.tid as ltid,  -- tid �����
    (select tName from tb_Teacher where tid=ll.tid) as lname, -- 䠬. �����
    dbo.uf_freeteach(@sem,@psem,@week,@wday,@npair,ll.tid) lfree,  -- ����㯭���� �����
    dbo.uf_prefteach(ll.tid,@wday,@npair) as lpref,  -- �।���⥭�� �����
    -- �ࠪ��. ����⨥
    lp.lid as plid,  -- lid �ࠪ⨪�
    lp.strid as pstrid,  -- �ࠪ��. strid
    dbo.uf_checkstrm(lp.strid,@week,@wday,@npair) as pchk,  -- ����������� ��⠢���
    dbo.uf_getavail(lp.lid) as ph,  -- �����. ��� �ࠪ⨪�
    lp.tid as ptid,  -- tid �ࠪ⨪�
    (select tName from tb_Teacher where tid=lp.tid) as pname, -- 䠬. �ࠪ⨪�
    dbo.uf_freeteach(@sem,@psem,@week,@wday,@npair,lp.tid) as pfree,  -- ����㯭���� �ࠪ⨪�
    dbo.uf_prefteach(lp.tid,@wday,@npair) as ppref, -- �।���⥭�� �ࠪ⨪�
    -- �����. ����⨥
    lb.lid as blid,  -- lid ����࠭�
    lb.strid as bstrid,  -- ������. strid
    dbo.uf_checkstrm(lb.strid,@week,@wday,@npair) as bchk,  -- ����������� ��⠢���
    dbo.uf_getavail(lb.lid) as bh,  -- �����. ���. ���
    lb.tid as btid,  -- tid ����࠭�
    (select tName from tb_Teacher where tid=lb.tid) as bname, -- 䠬. ����࠭�
    dbo.uf_freeteach(@sem,@psem,@week,@wday,@npair,lb.tid) as bfree,  -- ����㯭���� ����࠭�
    dbo.uf_prefteach(lb.tid,@wday,@npair) as bpref  -- �।���⥭�� ����࠭�

  from tb_Workplan w
    left join tb_Load ll on ll.wpid=w.wpid and ll.psem=@psem and ll.type=1
    left join tb_Load lp on lp.wpid=w.wpid and lp.psem=@psem and lp.type=2
    left join tb_Load lb on lb.wpid=w.wpid and lb.psem=@psem and lb.type=3
  where w.sem=@sem and w.sbid=@sbid and w.grid=@grid
  