-- ᮧ����� ��⮪� (lid)

declare
  @lid bigint

declare
  @lstrid bigint

  set @lstrid=0
  -- ᮧ����� ���. ��⮪�
  insert into tb_Stream(sem,psem,type,hours,kid)
    select wp.sem, l.psem, l.type, l.hours, wp.kid
      from tb_Load l
        join tb_Workplan wp on l.wpid=wp.wpid
      where lid=@lid
  -- ���������� ��㯯� � ����� ᮧ���. ��⮪
  select @lstrid=@@identity
  if @lstrid is not null
    update tb_Load set strid=@lstrid where lid=@lid
--  return @lstrid
