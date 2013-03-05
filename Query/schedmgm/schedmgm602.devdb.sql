-- 602 ���-��/���-��� ������� (sem,psem,lid,week,wday,npair,hgrp,aid,tid)
declare
  @sem tinyint,
  @psem tinyint,
  @lid bigint,
  @week tinyint,
  @wday tinyint,
  @npair tinyint,
  @hgrp tinyint,
  @tid bigint,
  @aid bigint

declare
  @lgrid bigint,
  @rows int

set @sem=1
set @psem=1
set @lid=47
set @week=1
set @wday=2
set @npair=1
set @hgrp=0
set @aid=1
set @tid=2

select @lgrid=grid
  from tb_Load l
    join tb_Workplan w on l.wpid=w.wpid
  where l.lid=@lid
print @lgrid
-- �஢�ઠ ������� �९�����⥫�
set @rows=dbo.uf_freeteachgrp(@sem,@psem,@week,@wday,@npair,@tid,@lgrid)
print @rows
-- �஢�ઠ ������� �㤨�ਨ
set @rows=dbo.uf_freeauditgrp(@sem,@psem,@week,@wday,@npair,@aid,@lgrid)
print @rows
-- �஢�ઠ ����⨬��� �㤨�ਨ
set @rows=dbo.uf_checkcapgrp(@lgrid,@aid,@hgrp)
print @rows
-- �஢�ઠ �� �ॢ�襭�� ���� ����㧪�
/*
-- �஢�ઠ ������ �ᥩ ��㯯� �� ���. ���
if exists(
     select *
       from tb_Schedule sc
         join tb_Load l on sc.lid=l.lid
         join tb_Workplan w on l.wpid=w.wpid
       where w.sem=@sem and l.psem=@psem and sc.hgrp=0
         and (sc.week=@week or sc.week=0) and sc.wday=@wday and sc.npair=@npair
     )

begin
  -- ���-��� ������
  update tb_Schedule set tid=@tid, aid=@aid, hgrp=@hgrp 
    where lid=@lid and [week]=@week and wday=@wday and npair=@npair
  set @rows=@@rowcount
  print 'change' 
end
else
begin
  -- ���������� ������
  insert tb_Schedule values(@lid,@week,@wday,@npair,@hgrp,@tid,@aid)
  set @rows=@@rowcount
  print 'insert'
end
print @rows
*/
