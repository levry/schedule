-- ���-� �����㯯� ��� ������ (lid,week,wday,npair,hgrp)
-- (��� ������. ��� ��⮪. ������)
-- RETURN_VALUE - ���-�� ���. ����ᥩ
ALTER   PROCEDURE dbo.sdl_sethgrp
(
@lid bigint,
@week tinyint,
@wday tinyint,
@npair tinyint,
@hgrp tinyint
)
AS
BEGIN
  set nocount on

  declare
    @res int,
    @lstrid bigint

  set @res=0

  -- �᫨ ����⨥ �������
  if exists(
      select lid from tb_Schedule
        where lid=@lid and [week]=@week and wday=@wday and npair=@npair)
  begin
    if (dbo.uf_chkhgrp(@lid,@week,@wday,@npair,@hgrp)=1)
    begin
      select @lstrid=strid from tb_Load where lid=@lid

      if @lstrid is null
      begin
        -- ���-��� ����. ������
        update tb_Schedule set hgrp=@hgrp
          where lid=@lid and [week]=@week and wday=@wday and npair=@npair
        set @res=@@rowcount
      end
      else
      begin
        -- ���-��� ��⮪. ������
        update s set hgrp=@hgrp
          from tb_Schedule s
            join tb_Load l on l.lid=s.lid and l.strid=@lstrid
          where s.week=@week and s.wday=@wday and s.npair=@npair
        set @res=@@rowcount
      end
    end
    else set @res=-2
  end
  else set @res=-1

  return @res
END