-- ��� ��⮪��

declare
  @strid bigint,
  @lid bigint

declare
  @lhours tinyint,
  @rows int

set @strid=4
set @lid=3

-- �஢�ઠ �� ������������ year,sem,psem,type,hours,kid
select count(*) from 
(select wp.kid, wp.sem, l.psem, l.type, l.hours
  from tb_Load l
    join tb_Workplan wp on l.wpid=wp.wpid
  where lid=@lid
union
select wp.kid, wp.sem, l.psem, l.type, l.hours
  from tb_Load l
    join tb_Workplan wp on l.wpid=wp.wpid
  where strid=@strid) un
--select @rows=@@rowcount
--print '����� '+cast(@rows as varchar)


-- �஢�ઠ �� ������⢨� ��㯯� � ��⮪� (� ��⮪� �� �.�. >2 ����. ��㯯)
select * from tb_Load l
    join tb_Workplan w on l.wpid=w.wpid
  where lid=@lid and grid not in
(select wp.grid
  from tb_Load l
    join tb_Workplan wp on l.wpid=wp.wpid
  where l.strid=@strid)

