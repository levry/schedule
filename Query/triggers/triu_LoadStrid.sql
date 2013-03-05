SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO







-- ����⢨� �� ����䨪�樨 ���� strid
-- ����䨪��� 20.10.05
ALTER        TRIGGER triu_LoadStrid ON dbo.tb_Load
FOR INSERT, UPDATE
AS
  set nocount on

  declare @err tinyint


  set @err=0
  if update(strid)
  begin
    -- �஢�ઠ ������⢨� ��㯯� � ��⮪�
    if exists(
      select *
        from Inserted ins
          join tb_Workplan w on w.wpid=ins.wpid
        where w.grid in 
            (select grid 
               from tb_Workplan wp 
                 join tb_Load l on l.wpid=wp.wpid and l.strid=ins.strid and l.lid<>ins.lid))
    begin
      raiserror('[triu_LoadStrid]: ��㯯� 㦥 ��������� � ��⮪�',16,1)
      set @err=1
    end

    -- �஢�ઠ sem,psem,hours,type
    if @err=0
      if exists(
        select *
          from Inserted ins
            join tb_Workplan w on w.wpid=ins.wpid
            join tb_Stream s on s.strid=ins.strid
          where w.sem<>s.sem or ins.psem<>s.psem or ins.hours<>s.hours or ins.type<>s.type)
      begin
        raiserror('[triu_LoadStrid]: ���ࠢ���� ��⮪: ࠧ���� ��� ᥬ����(����ᥬ����), ��� ����㧪� �� �ᠬ, ��� ⨯ ������',16,1)
        set @err=1
      end

    -- �஢�ઠ kid
    if @err=0
      if exists(
        select *
          from Inserted ins
            join tb_Workplan w on w.wpid=ins.wpid
            join tb_Stream s on s.strid=ins.strid
          where w.kid<>s.kid)
      begin
        raiserror('[triu_LoadStrid]: ���ࠢ���� ��⮪: ��䥤�� ���樯��� ࠧ����',16,1)
        set @err=1
      end

    -- �஢�ઠ ᮢ������� �९-��� (tid(lid)=tid(strid))
    if @err=0
      if exists(
        select *
          from Inserted ins
            join tb_Stream s on s.strid=ins.strid
          where isnull(ins.tid,0)<>isnull(s.tid,0))
      begin
        raiserror('[triu_LoadStrid]: ���ࠢ���� ��⮪: ������� �९�����⥫� ����㧪� � ��⮪�',16,1)
        set @err=1
      end

    if @err=0
    begin
      -- 㤠����� ����⨩ �� �ᯨᠭ��, ��� �-��� ���-�� strid
      delete s
        from Inserted ins
          join Deleted del on del.lid=ins.lid and isnull(del.strid,0)<>isnull(ins.strid,0)
          join tb_Schedule s on s.lid=del.lid

      -- 㤠����� ����⨩ ������塞�� ��⮪��
      delete s
        from tb_Schedule s
          join tb_Load l on l.lid=s.lid
          join Inserted ins on ins.strid=l.strid
          join Deleted del on del.lid=ins.lid and isnull(del.strid,0)<>isnull(ins.strid,0)
    end
  end
  
  if @err<>0
    rollback transaction







GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

