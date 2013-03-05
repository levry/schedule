-- 603 удаление занятия (lid,week,wday,npair)
declare
  @lid bigint,
  @week tinyint,
  @wday tinyint,
  @npair tinyint

set @lid=17
set @week=0
set @wday=1
set @npair=1

delete 
    tb_Schedule 
  where lid=@lid and [week]=@week and wday=@wday and npair=@npair


