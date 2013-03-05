-- 604 ��⠭���� ��⮪. ������ (strid,week,wday,npair)
declare
  @strid bigint,
  @week tinyint,
  @wday tinyint,
  @npair tinyint
--  @aid tinyint

declare
  @lsem tinyint,
  @lpsem tinyint,
  @ltype tinyint

set @strid=3
set @week=1
set @wday=1
set @npair=5

-- �롮ઠ sem,psem
select @lsem=sem, @lpsem=psem
  from tb_Stream
  where strid=@strid

print 'sem:  '+cast(@lsem as varchar)
print 'psem: '+cast(@lpsem as varchar)


-- ����. ��⮪: ���� �९-��, ���� �㤨���
-- �ࠪ�. � ���. ��⮪: �⤥�쭮 ��� ����. ��㯯�

if
  -- �஢�ઠ �� ������⢨� ����⨩ � ����. ��㯯
  dbo.uf_checkstrm(@strid,@week,@wday,@npair)=1 and
-- �஢�ઠ ������� �����
-- �஢�ઠ ������� �㤨�ਨ
--print dbo.uf_freeaudit(@lsem,@lpsem,@week,@wday,@npair,@aid)
-- �஢�ઠ ����⨬��� �㤨�ਨ (��⮪)
--print dbo.uf_checkcapstrm(@strid,@aid)
-- �஢�ઠ �� �ॢ�襭�� ���� ����㧪� ��⮪��
  dbo.uf_checkloadstrm(@strid,@week)=1
begin
-- ��⠢�� ���. ������
  insert tb_Schedule (lid,[week],wday,npair,hgrp,tid)
    select lid,@week,@wday,@npair,0,dbo.uf_freestrmtid(@lsem,@lpsem,@week,@wday,@npair,@strid,tid)
      from tb_Load
      where strid=@strid
end
