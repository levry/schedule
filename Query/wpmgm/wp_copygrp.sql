-- копирование р.п. в другую группу (grid,ngrid)
-- RETURN VALUE - 1 успешно, 0 - неудача
CREATE PROCEDURE dbo.wp_copygrp
(
@grid bigint,
@ngrid bigint
)
AS
  set nocount on

  declare @err int
  
  set @err=0
  
  begin tran
    -- удаление стар. р.п.
    exec dbo.wp_delgrp @ngrid
    select @err=@@error
    if @err=0
    begin
      -- копирование дисциплин
      insert tb_Workplan (grid,sbid,kid,sem,e)
        select @ngrid,sbid,kid,sem,e from tb_Workplan where grid=@grid
      select @err=@@error
    
      if @err=0
      begin
        -- копирование нагрузок
        insert tb_Load (wpid,psem,type,tid,strid,hours)
          select wn.wpid,l.psem,l.type,l.tid,l.strid,l.hours
            from tb_Workplan w
              join tb_Load l on l.wpid=w.wpid
              join tb_Workplan wn on wn.sem=w.sem and wn.sbid=w.sbid
            where w.grid=@grid and wn.grid=@ngrid
        select @err=@@error
      end
    end
  
  if @err=0
  begin
    commit tran
    return 1
  end
  else 
  begin
    rollback tran
    return 0
  end

