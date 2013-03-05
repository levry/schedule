SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


-- ���-��� ��⮪. ������ (strid,week,wday,npair,aid,tid)
-- RETURN_VALUE ���-�� ���. ����ᥩ
ALTER   PROCEDURE dbo.sdl_setlsns_s
(
@strid bigint,
@week tinyint,
@wday tinyint,
@npair tinyint,
@aid bigint,
@tid bigint
)
AS
  set nocount on

  declare
    @lsem tinyint,
    @lpsem tinyint,
    @res int

  set @res=0
  -- ���-��� sem,psem
  select @lsem=sem, @lpsem=psem from tb_Stream where strid=@strid

  if 
      -- �஢�ઠ ������� �९-��
      ((dbo.uf_freetid_s(@lsem,@lpsem,@week,@wday,@npair,@strid,@tid)=@tid) or (@tid is null))
      -- �஢�ઠ ������� �㤨�ਨ
      and ((dbo.uf_freeaid_s(@lsem,@lpsem,@week,@wday,@npair,@strid,@aid)=@aid) or (@aid is null))
      -- �஢�ઠ ����⨬��� �㤨�ਨ
      and (dbo.uf_checkcapstrm(@strid,@aid)=1)
  begin
    -- ���-�� �९-�� ��� ��⮪�
    exec @res=dbo.stm_setstrmthr @strid, @tid
    -- ���-��� �㤨�ਨ ��� ��⮪. ������
    update s set aid=@aid
      from tb_Schedule s
        join tb_Load l on s.lid=l.lid
      where s.week=@week and s.wday=@wday and s.npair=@npair and l.strid=@strid
    set @res=@res+@@rowcount
  end

  return @res


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

