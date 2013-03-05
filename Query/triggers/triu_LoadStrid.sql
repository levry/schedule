SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO







-- действие при модификации поля strid
-- модификация 20.10.05
ALTER        TRIGGER triu_LoadStrid ON dbo.tb_Load
FOR INSERT, UPDATE
AS
  set nocount on

  declare @err tinyint


  set @err=0
  if update(strid)
  begin
    -- проверка отсутствия группы в потоке
    if exists(
      select *
        from Inserted ins
          join tb_Workplan w on w.wpid=ins.wpid
        where w.grid in 
            (select grid 
               from tb_Workplan wp 
                 join tb_Load l on l.wpid=wp.wpid and l.strid=ins.strid and l.lid<>ins.lid))
    begin
      raiserror('[triu_LoadStrid]: Группа уже присутствует в потоке',16,1)
      set @err=1
    end

    -- проверка sem,psem,hours,type
    if @err=0
      if exists(
        select *
          from Inserted ins
            join tb_Workplan w on w.wpid=ins.wpid
            join tb_Stream s on s.strid=ins.strid
          where w.sem<>s.sem or ins.psem<>s.psem or ins.hours<>s.hours or ins.type<>s.type)
      begin
        raiserror('[triu_LoadStrid]: Неправильный поток: различны или семестр(полусеместр), или нагрузка по часам, или тип занятия',16,1)
        set @err=1
      end

    -- проверка kid
    if @err=0
      if exists(
        select *
          from Inserted ins
            join tb_Workplan w on w.wpid=ins.wpid
            join tb_Stream s on s.strid=ins.strid
          where w.kid<>s.kid)
      begin
        raiserror('[triu_LoadStrid]: Неправильный поток: Кафедры дисциплин различны',16,1)
        set @err=1
      end

    -- проверка совпадения преп-лей (tid(lid)=tid(strid))
    if @err=0
      if exists(
        select *
          from Inserted ins
            join tb_Stream s on s.strid=ins.strid
          where isnull(ins.tid,0)<>isnull(s.tid,0))
      begin
        raiserror('[triu_LoadStrid]: Неправильный поток: Различны преподаватели нагрузки и потока',16,1)
        set @err=1
      end

    if @err=0
    begin
      -- удаление занятий из расписания, для к-рых изм-но strid
      delete s
        from Inserted ins
          join Deleted del on del.lid=ins.lid and isnull(del.strid,0)<>isnull(ins.strid,0)
          join tb_Schedule s on s.lid=del.lid

      -- удаление занятий дополняемых потоков
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

