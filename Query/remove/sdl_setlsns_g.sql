SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO





-- ���-��� ������ (lid,week,wday,npair,hgrp,aid,tid)
-- RETURN_VALUE - ���-�� ������. ����ᥩ
ALTER      PROCEDURE dbo.sdl_setlsns_g
(
@lid bigint,
@week tinyint,
@wday tinyint,
@npair tinyint,
@hgrp tinyint,
@aid bigint,
@tid bigint
)
AS
  set nocount on

  declare
    @lsem tinyint,
    @lpsem tinyint,
    @lgrid bigint,
    @rows int

  set @rows=0

  -- �᫨ ����⨥ �������
  if exists(
      select lid from tb_Schedule
        where lid=@lid and [week]=@week and wday=@wday and npair=@npair)
  begin
    -- ���-��� sem,psem,grid �� lid
    select @lsem=w.sem, @lpsem=l.psem, @lgrid=grid
      from tb_Load l
        join tb_Workplan w on l.wpid=w.wpid
      where l.lid=@lid
    if (@lsem is not null) and (@lpsem is not null) and (@lgrid is not null) and
      -- �஢�ઠ ������� �९�����⥫�
      (dbo.uf_freeteachlid(@lsem,@lpsem,@week,@wday,@npair,@tid,@lid)=1) and
      -- �஢�ઠ ������� �㤨�ਨ
      (dbo.uf_freeauditlid(@lsem,@lpsem,@week,@wday,@npair,@aid,@lid)=1) and
      -- �஢�ઠ ����⨬��� �㤨�ਨ
      (dbo.uf_checkcapgrp(@lgrid,@aid,@hgrp)=1) and
      -- �஢�ઠ ���-��� hgrp
     (dbo.uf_checkhgrp(@lid,@week,@wday,@npair,@hgrp)=1)
    begin
      -- ���������� ������ (hgrp)
      update tb_Schedule set hgrp=@hgrp, aid=@aid
        where lid=@lid and [week]=@week and wday=@wday and npair=@npair
      set @rows=@@rowcount
      -- ���������� �९-�� ����㧪� 
      update tb_Load set tid=@tid where lid=@lid
      set @rows=@rows+@@rowcount
    end
  end

  return @rows






GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

