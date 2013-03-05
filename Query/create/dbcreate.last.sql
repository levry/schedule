SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

-- возвращает только дату
CREATE   FUNCTION dbo.uf_date
(
@date datetime
)
RETURNS datetime AS
BEGIN
  return convert(datetime, convert(varchar, @date, 101),101)
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

-- проверка вхождения даты в указ. период
-- возвращает 1 если дата входит в период, иначе 0
CREATE FUNCTION dbo.uf_inrange
(
@date datetime,
@startdate datetime,
@enddate datetime
)
RETURNS tinyint AS
BEGIN
  declare @res tinyint

  if (@date>=@startdate) and (@date<=@enddate) set @res=1
    else set @res=0

  return @res
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO



-- проверка вхождения даты в указ. период
-- проверяються только дата
-- возвращает 1 если дата входит в период, иначе 0
CREATE   FUNCTION dbo.uf_inrange_d
(
@date datetime,
@startdate datetime,
@enddate datetime
)
RETURNS tinyint AS
BEGIN
declare
  @l_date datetime,
  @l_start datetime,
  @l_end datetime,
  @res tinyint

  set @l_date=dbo.uf_date(@date)
  set @l_start=dbo.uf_date(@startdate)
  set @l_end=dbo.uf_date(@enddate)

  if (@l_date>=@l_start) and (@l_date<=@l_end) set @res=1
    else set @res=0

  return @res
END



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


-- проверка вхождения времени в укза. период
-- проверятся только время
-- возвращает 1 если время входит в период, иначе 0
CREATE  FUNCTION dbo.uf_inrange_t
(
@date datetime,
@startdate datetime,
@enddate datetime
)
RETURNS tinyint AS
BEGIN
  declare
    @l_date datetime,
    @l_start datetime,
    @l_end datetime,
    @res tinyint
  
  set @l_date=dbo.uf_time(@date)
  set @l_start=dbo.uf_time(@startdate)
  set @l_end=dbo.uf_time(@enddate)
  
  if (@l_date>=@l_start) and (@l_date<=@l_end) set @res=1
    else set @res=0
  
  return @res
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

-- возвращает только время
CREATE   FUNCTION dbo.uf_time
(
@date datetime
)
RETURNS datetime AS
BEGIN
  return convert(datetime, convert(varchar, @date, 108))
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


-- проверка принадлежности кафедры факультету
-- возвращает 1 если кафедра принадлежит факультету, иначе 0
CREATE   FUNCTION dbo.chk_existskid
(
@fid int,
@kid bigint
)
RETURNS TINYINT AS
BEGIN
  declare @res tinyint

  if (@kid is not null) and (@fid is not null)
  begin
    if exists(select kid from tb_Kafedra where kid=@kid and fid=@fid)
      set @res=1
    else
      set @res=0
  end
  else set @res=1

  return @res
END




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO



-- возвращает кол-во п/сем в году (ynum)
CREATE   FUNCTION dbo.chk_getpsem
(
@ynum smallint
)
RETURNS tinyint AS
BEGIN
  declare @res tinyint

  if(@ynum is not null)
    select @res=count(prid)
      from tb_Period
      where ynum=@ynum and ptype in (1,2)
  else set @res=0

  return @res
END



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

-- прверка вместимости группы в аудиторию (grid,aid)
-- 0 - capacity<studs, 1 capacity>=studs
CREATE   FUNCTION dbo.uf_chkcap_g
(
@grid bigint,
@aid bigint,
@hgrp tinyint  -- подгруппа (0 - вся группа)
)  
RETURNS tinyint AS  
BEGIN 
  declare @res tinyint

  if (@grid is null) or (@aid is null) or (@hgrp!=0)
    set @res=1
  else
  begin
    if exists(
        select grid
          from tb_Group g
            join tb_Auditory a on g.grid=@grid and a.aid=@aid
          where a.capacity>=g.studs)
      set @res=1
    else set @res=0
  end

  return @res
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

-- возвращает сокр. звания
CREATE FUNCTION dbo.uf_getpsmall
(
@tid bigint
)
RETURNS varchar(10) AS
BEGIN
  declare @res varchar(10)

  if @tid is not null
    select @res=p.psmall
      from tb_Teacher t
        join tb_Post p on p.pid=t.pid
      where t.tid=@tid
  else set @res=null

  return @res
END



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

-- проверка времени экзамена
CREATE  FUNCTION dbo.chk_exam_time
(
@wpid bigint,
@start datetime
)
RETURNS tinyint AS
BEGIN
  declare
    @res tinyint,
    @p_start datetime,
    @p_end datetime,
    @d_start int
  
  set @res=0

  if(@start is not null)and(@wpid is not null)
  begin

    -- проверка дня экз/конс (все раб. дни, кроме ВС)
    set @d_start=datepart(weekday,@start)

    if(@d_start!=8-@@datefirst)
    begin
      -- проверка экз. на принадлежность сессии
      select @p_start=p.p_start, @p_end=p.p_end
        from tb_Workplan w
          join tb_Group g on g.grid=w.grid
          join tb_Period p on p.ynum=g.ynum and p.sem=w.sem and p.ptype=3
        where w.wpid=@wpid
      if(datediff(d,@p_start,@start)>=0 and datediff(d,@start,@p_end)>=0) set @res=1
      --if(@start>@p_start and @start<@p_end) set @res=1
    end

  end

  return @res
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

-- проверка сущ-ния периода для раб.плана (wpid,ptype)
-- 1 - есть период, иначе 0
CREATE FUNCTION dbo.uf_existsprid_w
(
@wpid bigint,
@ptype tinyint
)
RETURNS tinyint AS
BEGIN
  declare @res tinyint

  if(@wpid is not null) and (@ptype is not null)
  begin
    if exists(
        select prid
          from tb_Workplan w
            join tb_Group g on g.grid=w.grid
            join tb_Period p on p.ynum=g.ynum
          where w.wpid=@wpid and p.sem=w.sem and p.ptype=@ptype)
      set @res=1
    else set @res=0
  end
  else set @res=0

  return @res
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO



-- возвращает огр-ние аудитории на дан. пару (aid, wday, npair)
-- если не установлено, то 0
CREATE   FUNCTION dbo.uf_prefaid
(
@aid bigint,
@wday tinyint,
@npair tinyint
)  
RETURNS tinyint AS  
BEGIN 
  declare @res tinyint
  select @res=astate from tb_PrefAudit where aid=@aid and wday=@wday and npair=@npair
  if @res is null
    set @res=0
  return @res
END




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

-- возвращает код огр-ния преп-ля на дан. пару (tid, wday, npair)
-- если нет огр-ния, то 0
CREATE   FUNCTION dbo.uf_preftid 
(
@tid bigint,
@wday tinyint,
@npair tinyint
)  
RETURNS tinyint AS  
BEGIN 
  declare @res tinyint
  select @res=tstate from tb_PrefTeach where tid=@tid and wday=@wday and npair=@npair
  if @res is null
    set @res=0
  return @res
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

-- проверка экзамена для раб.плана + сущ-ния периода для сессии
-- возвращает 1, если tb_Workplan.e!=0 and exists(tb_Period.prid), иначе 0
CREATE  FUNCTION dbo.chk_exam_wp
(
@wpid bigint
)
RETURNS tinyint AS
BEGIN
  declare
    @res tinyint,
    @e tinyint

  set @res=0

  if(@wpid is not null)
  begin
    select @e=e from tb_Workplan where wpid=@wpid
    if(isnull(@e,0)>0)
      if (dbo.uf_existsprid_w(@wpid,3)=1)
        set @res=1
  end

  return @res
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO



-- проверка вместимости аудитории потока (strid, aid, hgrp)
-- возвращает 1 - если поток помещается в аудиторию
CREATE   FUNCTION dbo.uf_chkcap_s
(
@strid bigint,
@aid bigint,
@hgrp tinyint
)
RETURNS tinyint AS  
BEGIN 
  declare
    @lstuds smallint,
    @lcap smallint,
    @res tinyint

  if (@aid is not null) and (isnull(@hgrp,0)=0)
  begin
    -- определение кол-ва студентов в потоке
    select @lstuds=sum(studs)
      from tb_Group g
        join tb_Workplan w on w.grid=g.grid
        join tb_Load l on l.wpid=w.wpid
      where l.strid=@strid

    -- определение вместимости аудитории
    select @lcap=capacity
      from tb_Auditory
      where aid=@aid

    if @lcap>=@lstuds
      set @res=1
    else set @res=0
  end
  else set @res=1

  return @res
END




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO



-- проверка возможности поставить занятие (один.|поток.) (lid,week,wday,npair,hgrp)
-- RETURN_VALUE: 1 - есть возможность, 0 - нет
CREATE   FUNCTION dbo.uf_chklsns
(
@lid bigint,
@week tinyint,
@wday tinyint,
@npair tinyint,
@hgrp tinyint
)
RETURNS tinyint AS
BEGIN
  declare
    @res tinyint,
    @l_sem tinyint,
    @l_psem tinyint,
    @l_grid bigint,
    @l_strid bigint

  set @res=0

  select @l_sem=w.sem, @l_psem=l.psem, @l_grid=w.grid, @l_strid=l.strid
    from tb_Load l
      join tb_Workplan w on w.wpid=l.wpid
    where l.lid=@lid

  if(@l_strid is null)
    -- проверка один. занятия
    set @res=dbo.uf_chklsns_g(@l_sem,@l_psem,@week,@wday,@npair,@hgrp,@l_grid)
  else
    -- проверка поток. занятия
    set @res=dbo.uf_chklsns_s(@l_strid,@week,@wday,@npair,@hgrp)

  return @res
END



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/*
  Проверка очередности конс/экз (конс. перед экз.)
  RETURN_VALUE: 1-очередность выполняется, иначе 0
*/
CREATE  FUNCTION dbo.uf_chkorder_xm
(
@wpid bigint,
@xmtype tinyint,
@xmtime datetime
)
RETURNS tinyint AS
BEGIN
  declare
    @l_time datetime,
    @res tinyint

  set @res=0

  select @l_time=xmtime from tb_Exam where wpid=@wpid and xmtype=1-@xmtype

  if(@l_time is not null)
  begin
    if(@xmtype=0)
    begin
      if(@xmtime>@l_time) set @res=1  -- экз. после конс.
    end
    else if(@xmtime<@l_time) set @res=1  -- конс. перед экз.
  end
  else set @res=1  -- еще не стоит

  return @res
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO




/*
  проверка времени для экз/конс
  - 1 событие в день для пол. грп (@hgrp=0)
  - одновременность для всех подгрп (@hgrp=1)
  - нет других экз/конс между одноимен. экз/конс.
  RETURN_VALUE: 1 - успех
*/
CREATE    FUNCTION dbo.uf_chktime_xm
(
@wpid bigint,
@xmtype tinyint,
@xmtime datetime,
@hgrp tinyint
)
RETURNS tinyint AS
BEGIN
  if(@xmtype=1 and @hgrp=1) return 0

  declare
    @l_grid bigint,
    @l_start datetime,
    @l_end datetime,
    @res tinyint


  set @res=1

  select @l_grid=grid from tb_Workplan where wpid=@wpid
  set @l_start=dbo.uf_date(@xmtime)
  set @l_end=dateadd(dd,1,@l_start)

  if(@hgrp=0)
  begin
    -- один экз/конс в день
    if exists
    (
      select xm.wpid
        from tb_Exam xm
          join tb_Workplan w on w.wpid=xm.wpid
        where (xmtime between @l_start and @l_end) and w.grid=@l_grid
          and not (xm.wpid=@wpid and xm.xmtype=@xmtype)
    )
      set @res=0
  end
  else
  begin
    -- проверка одновременности экз для погрупп
    if exists
    (
      select xm.wpid
        from tb_Exam xm
          join tb_Workplan w on w.wpid=xm.wpid
        where (xmtime between @l_start and @l_end) and w.grid=@l_grid
          and not (xm.wpid=@wpid and xm.xmtype=@xmtype)
          and (hgrp=0 or xmtime!=@xmtime or xmtype!=@xmtype)
    )
      set @res=0

  end

  -- проверка включения экз/конс между другими
  if(@res=1)
    if exists
    (
      select xm.wpid
        from tb_Exam xm
          join tb_Exam cs on cs.wpid=xm.wpid and cs.xmtype!=xm.xmtype and cs.xmtype=1
          join tb_Workplan w on w.wpid=xm.wpid and w.grid=@l_grid and xm.wpid!=@wpid
        where @xmtime>cs.xmtime and @xmtime<xm.xmtime
    )
      set @res=0

  -- проверка включения других между экз/конс
  if(@res=1)
  begin
    set @l_start=null
    set @l_end=null

    if(@xmtype=0)
      select @l_start=xmtime, @l_end=@xmtime
        from tb_Exam where wpid=@wpid and xmtype!=@xmtype
    else
      select @l_start=@xmtime, @l_end=xmtime
        from tb_Exam where wpid=@wpid and xmtype!=@xmtype
  
    if(@l_end>@l_start)
      if exists
      (
        select xm.wpid
          from tb_Exam xm
            join tb_Workplan w on w.wpid=xm.wpid and w.grid=@l_grid
          where xm.xmtime>@l_start and xm.xmtime<@l_end
            and not(xm.wpid=@wpid and xm.xmtype=@xmtype) 
      )
        set @res=0
  end

  return @res
END




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/*
  Проверка наличия экзамена в расписании (wpid,xmtype)
  возвращает 1 если есть, иначе 0
*/
CREATE FUNCTION dbo.uf_existsxm
(
@wpid bigint,
@xmtype tinyint
)
RETURNS tinyint AS
BEGIN
  declare @res tinyint
  set @res=0

  if(@wpid is not null)and(@xmtype is not null)
    if exists(select wpid from tb_Exam where wpid=@wpid and xmtype=@xmtype)
      set @res=1

  return @res
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/*
  Проверка занятости аудитории (расписание экз/конс)
  RETURN_VALUE: 0-занята, 1-свободна
*/
CREATE FUNCTION dbo.uf_freeaid_xm
(
@aid bigint,
@xmtime datetime
)
RETURNS tinyint AS
BEGIN
  if(@aid is null) return 1

  if exists(select wpid from tb_Exam where aid=@aid and xmtime=@xmtime)
    return 0

  return 1
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/*
  Проверка занятости преп-лей (расписание экз/конс)
  RETURN_VALUE: 0-занят 1-свободен
*/
CREATE  FUNCTION dbo.uf_freetid_xm
(
@wpid bigint,
@xmtime datetime
)
RETURNS tinyint AS
BEGIN
  declare @res tinyint

  if exists
  (
    select wpid
      from tb_Load l
      where wpid=@wpid and l.type=1 and
        exists
        (
          select xm.wpid
            from tb_Exam xm
              join tb_Load ll on ll.wpid=xm.wpid and ll.type=1 and ll.tid=l.tid
            where xm.xmtime=@xmtime
        )
  )
    set @res=0
  else set @res=1

  return @res
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO


-- возвращает нагрузку для дисциплины
-- (wpid, psem, type)
CREATE  FUNCTION dbo.uf_gethours
(
@wpid bigint,
@psem tinyint,
@type tinyint
)  
RETURNS tinyint AS  
BEGIN 
  declare @res tinyint

  set @res=0
  select @res=Hours from tb_Load where wpid=@wpid and psem=@psem and type=@type

  return @res
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


-- проверка на поток (lid)
-- RETURN_VALUE - 1 - поток, 0 - не поток
CREATE  FUNCTION dbo.uf_isstrm
(
@lid bigint
)
RETURNS bit AS
BEGIN
  declare
    @res tinyint,
    @l_strid bigint

  select @l_strid=strid from tb_Load where lid=@lid
  if(@l_strid is null) set @res=0
    else set @res=1

  return @res
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


-- проверка вместимости аудитории (grid,aid)
-- 0 - capacity<studs, 1 capacity>=studs
CREATE  FUNCTION dbo.uf_chkcap
(
@lid bigint,
@aid bigint,
@hgrp tinyint  -- подгруппа (0 - вся группа)
)  
RETURNS tinyint AS  
BEGIN 
  declare
    @l_grid bigint,
    @l_strid bigint,
    @res tinyint

  if (@lid is not null) and (@aid is not null) and (@hgrp=0)
  begin
    select @l_grid=w.grid,@l_strid=l.strid
      from tb_Load l
        join tb_Workplan w on w.wpid=l.wpid
      where l.lid=@lid

    if(@l_strid is not null)
      set @res=dbo.uf_chkcap_s(@l_strid,@aid,@hgrp)
    else
      set @res=dbo.uf_chkcap_g(@l_grid,@aid,@hgrp)
  end
  else set @res=1

  return @res
END




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

-- проверка существования занятия на паре (week,wday,npair,lid)
-- 1 - есть занятие, иначе 0
CREATE FUNCTION dbo.uf_existslsns
(
@week tinyint,
@wday tinyint,
@npair tinyint,
@lid bigint
)
RETURNS tinyint
AS
BEGIN
  declare @res tinyint
  
  if exists(
    select lid from tb_Schedule
      where [week]=@week and wday=@wday and npair=@npair and lid=@lid  )
    set @res=1
  else set @res=0

  return @res
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO


-- расчет доступ. часов за две недели (lid)
CREATE  FUNCTION dbo.uf_getavail
(
@lid bigint
)  
RETURNS smallint AS  
BEGIN 
  declare
    @res smallint,
    @les smallint, -- число занятий к/н пол. групп
    @hles smallint, -- число занятий ч/н или подгрупп
    @hhles smallint, -- число занятий ч/н подгрупп
    @hh tinyint -- нагрузка
  
  -- опр-ние нагрузки
  select @hh=hours from tb_Load where lid=@lid
  -- число занятий (к/неделю)
  select @les=count(*) from tb_Schedule where lid=@lid and [week]=0 and hgrp=0
  -- число занятий (ч/н + пгрп)
  select @hles=count(*) from tb_Schedule where lid=@lid and (([week]<>0 and hgrp=0) or ([week]=0 and hgrp=1))
  -- число занятий подгрупп ч/н
  select @hhles=count(*) from tb_Schedule where lid=@lid and ([week]<>0 and hgrp=1)
  set @res=2*@hh-4*@les-2*@hles-@hhles
  return @res
END




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

-- проверка на возможность смены подгруппы <-> пол группу (lid,week,wday,npair,hgrp)
-- (нельзя поставить, если стоят др. подгруппы, нарушена недель. нагрузка)
-- возвращает 1 если можно поставить hgrp, иначе 0
CREATE  FUNCTION dbo.uf_chkhgrp
(
@lid bigint,
@week tinyint,
@wday tinyint,
@npair tinyint,
@hgrp tinyint
)
RETURNS tinyint AS
BEGIN
  declare
    @l_ynum smallint,
    @l_sem tinyint,
    @l_psem tinyint,
    @l_strid bigint,
    @l_grid bigint,
    @res tinyint

  set @res=0

  select @l_ynum=ynum, @l_sem=sem, @l_psem=psem, @l_strid=strid, @l_grid=grid
    from vw_Workplan
    where lid=@lid

  if @l_strid is null
  begin
    -- проверка одиноч. занятия
    if not exists(
      select lid
        from vw_Schedule
        where ynum=@l_ynum and sem=@l_sem and psem=@l_psem and grid=@l_grid
          and wday=@wday and npair=@npair and [week]=@week
          and lid<>@lid and ((@hgrp=0) or (@hgrp=1 and hgrp=0)))
      set @res=1
  end
  else
  begin
    -- проверка поточ. занятия
    if not exists(
      select *
        from vw_Schedule
        where ynum=@l_ynum and sem=@l_sem and psem=@l_psem
          and wday=@wday and npair=@npair
          and grid in (select grid from tb_workplan ww join tb_load ll on ll.wpid=ww.wpid and ll.strid=@l_strid)
          and (strid<>@l_strid or strid is null) and
          (
            ((@hgrp=0 or hgrp=0) and ([week]=@week))
            or    
            (@week=0 and [week]<>0) or (@week<>0 and [week]=0)
          ))
      set @res=1
  end

  -- проверка на превышение нагрузки (при смене на пол. группу)
  if (@res=1) and (@hgrp=0)
  begin
    declare @hh smallint
    if @week=0 set @hh=2 else set @hh=1

    if @l_strid is null
    begin
      -- проверка один. занятия
      if (dbo.uf_getavail(@lid)-@hh)<0
        set @res=0
    end
    else
    begin
      -- проверка поток. занятия
      if exists(
          select * from tb_Load
            where strid=@l_strid and ((dbo.uf_getavail(lid)-@hh)<0)  )
        set @res=0
    end
  end

  return @res
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO



-- проверка на превышение нормы нагрузки (lid, week, hgrp)
-- возвращает 1 - если нагрузка не превышена, иначе 0
CREATE FUNCTION dbo.uf_chkhours_l
(
@lid bigint,
@week tinyint,
@hgrp tinyint
)
RETURNS smallint AS  
BEGIN 
  declare
    @hh smallint,
    @res smallint

  -- опр-ние добавл. часов (x2 на две недели)
  if @week=0 
    if @hgrp=0 set @hh=4 else set @hh=2
  else
    if @hgrp=0 set @hh=2 else set @hh=1

  if (dbo.uf_getavail(@lid)-@hh)>=0
    set @res=1
  else set @res=0

  return @res
END




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO




-- проверка возможности поставить занятие на пару (sem,psem,week,wday,npair,hgrp,grid)
-- возвращает 1 - если можно поставить, иначе 0
CREATE      FUNCTION dbo.uf_chklsns_g
(
@sem tinyint,
@psem tinyint,
@week tinyint,
@wday tinyint,
@npair tinyint,
@hgrp tinyint,
@grid bigint
)
RETURNS tinyint AS  
BEGIN 
  declare 
    @res tinyint

  if exists(
      select lid
        from vw_Schedule
        where grid=@grid
          -- выбор пары
          and sem=@sem and psem=@psem and wday=@wday and npair=@npair
          -- проверка
          and 
          (
            (@week=0 and [week]<>0) or (@week<>0 and [week]=0)
            or ((@hgrp=0 or  hgrp=0) and [week]=@week)
          )
      )
    set @res=0
  else set @res=1

  return @res
END




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO




-- проверка на возможность поставить поток. занятие (strid,week,wday,npair)
-- (есть возможность поставить занятий у групп, входящие в поток)
-- возвращает 1 - если возможно
CREATE    FUNCTION dbo.uf_chklsns_s
(
@strid bigint,
@week tinyint,
@wday tinyint,
@npair tinyint,
@hgrp tinyint
)
RETURNS tinyint AS  
BEGIN 
  declare
    @res tinyint,
    @l_ynum smallint,
    @l_sem tinyint,
    @l_psem tinyint
  
  select @l_ynum=ynum, @l_sem=sem, @l_psem=psem from tb_Stream where strid=@strid
  
  if (@strid is null) or
    exists
    (
      select *
        from vw_Schedule s
          join 
            (select grid from tb_Load l
               join tb_Workplan w on w.wpid=l.wpid
             where l.strid=@strid) g on g.grid=s.grid
        where s.ynum=@l_ynum and s.sem=@l_sem and s.psem=@l_psem
          and s.wday=@wday and s.npair=@npair
          and 
          (
            (@week=0 and s.[week]<>0) or (@week<>0 and s.[week]=0)
            or
            ((@hgrp=0 or s.hgrp=0) and (s.[week]=@week))
          )
    )
    set @res=0
  else set @res=1

  return @res
END





GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO



-- определение существования подгруппы на дан. паре
-- (sem,psem,week,wday,npair,grid)
-- возвращает 1, если на паре стоит хотя бы одна подгруппа
CREATE   FUNCTION dbo.uf_existshgrp
(
@sem tinyint,
@psem tinyint,
@week tinyint,
@wday tinyint,
@npair tinyint,
@grid bigint
)
RETURNS tinyint AS  
BEGIN 
  declare @res tinyint

  if exists
  (
    select lid
      from vw_Schedule
      where sem=@sem and psem=@psem and [week]=@week and wday=@wday
        and npair=@npair and grid=@grid and hgrp=1
  )
    set @res=1
  else set @res=0

  return @res
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO




-- проверка занятости аудитории (sem,psem,week,wday,npair,aid)
-- возвращает 1, если аудитория свободен, иначе 0
CREATE      FUNCTION dbo.uf_freeaid
(
@ynum smallint,
@sem tinyint,
@psem tinyint,
@week tinyint,
@wday tinyint,
@npair tinyint,
@aid bigint
)  
RETURNS tinyint AS  
BEGIN 
  declare @res tinyint

  if @aid is not null
  begin
    if exists
    (
      select lid
        from vw_Schedule
        where ynum=@ynum and sem=@sem and psem=@psem and aid=@aid
          and wday=@wday and npair=@npair
          and ((@week=0)or((@week<>0)and([week] in (0,@week))))
    )
      set @res=0
    else set @res=1
  end
  else set @res=1

  return @res
END




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO



-- доступность аудитории на задан. паре (ynum,sem,psem,week,wday,npair,aid,lid)
-- искл. указ. занятие
-- возвращает 1 - если аудитория свободна, иначе 0
CREATE   FUNCTION dbo.uf_freeaid_l
(
@ynum smallint,
@sem tinyint,
@psem tinyint,
@week tinyint,
@wday tinyint,
@npair tinyint,
@aid bigint,
@lid bigint
)  
RETURNS tinyint AS  
BEGIN 
  declare @res tinyint

  if (@aid is not null) and (@lid is not null)
  begin
    if exists
    (
      select lid
        from vw_Schedule
        where ynum=@ynum and sem=@sem and psem=@psem
          and wday=@wday and npair=@npair and aid=@aid
          and ((@week=0)or((@week<>0)and([week] in (0,@week))))
          and lid<>@lid
    )
      set @res=0
    else set @res=1
  end
  else set @res=1

  return @res
END



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO




-- проверка занятости аудитории (ynum,sem,psem,week,wday,npair,strid,aid)
-- искл. поточ. занятие 
-- возвращает aid, если аудитория свободна, иначе null
CREATE    FUNCTION dbo.uf_freeaid_s
(
@ynum smallint,
@sem tinyint,
@psem tinyint,
@week tinyint,
@wday tinyint,
@npair tinyint,
@strid bigint,
@aid bigint
)  
RETURNS bigint AS  
BEGIN 
  declare @res bigint

  if (@strid is not null) and (@aid is not null)
  begin
    if exists
    (
      select lid
        from vw_Schedule
        where ynum=@ynum and sem=@sem and psem=@psem
          and wday=@wday and npair=@npair and aid=@aid
          and isnull(strid,0)<>isnull(@strid,0)
          and ((@week=0)or((@week<>0)and([week] in (0,@week))))
    )
      set @res=null
    else set @res=@aid
  end
  else set @res=null

  return @res
END




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO




-- проверка на занятость преп-ля (ynum,sem,psem,week,wday,npair,tid)
-- возвращает 1 если преп-ль свободен, иначе 0
CREATE       FUNCTION dbo.uf_freetid 
(
@ynum smallint,
@sem tinyint,
@psem tinyint,
@week tinyint,
@wday tinyint,
@npair tinyint,
@tid bigint
)  
RETURNS tinyint AS  
BEGIN 
  declare
    @res tinyint

  if @tid is not null
  begin
    if exists
    (
      select lid
        from vw_Schedule
        where ynum=@ynum and sem=@sem and psem=@psem
          and wday=@wday and npair=@npair and tid=@tid
          and ((@week=0)or((@week<>0)and([week] in (0,@week))))
    )
      set @res=0
    else set @res=1
  end
  else set @res=1

  return @res
END




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

-- доступность преп-ля нагрузки на указ. паре (lid,week,wday,npair)
-- опр-ние ynum, sem, psem от lid
-- искл. занятия (поточ. или простого)
-- возвращает 1 - преп-ль свободен, иначе 0
CREATE FUNCTION dbo.uf_freetid_l
(
@lid bigint,
@week tinyint,
@wday tinyint,
@npair tinyint
)
RETURNS tinyint AS
BEGIN
  declare 
    @res tinyint,
    @l_ynum smallint,
    @l_sem tinyint,
    @l_psem tinyint,
    @l_tid bigint,
    @l_strid bigint

  select @l_ynum=ynum, @l_sem=sem, @l_psem=psem, @l_tid=tid, @l_strid=strid
    from vw_Workplan
    where lid=@lid

  if (@l_ynum is not null) and (@l_sem is not null) and (@l_psem is not null)
    and (@l_tid is not null)
  begin
    if exists
    (
      select lid
        from vw_Schedule
        where ynum=@l_ynum and sem=@l_sem and psem=@l_psem and tid=@l_tid
           -- если есть поток, искл. поток. занятия
           and (((@l_strid is not null)and(isnull(strid,0)<>isnull(@l_strid,0)))
           -- иначе, искл. занятия
           or((@l_strid is null)and(lid<>@lid)))
--           and isnull(l.strid,0)<>isnull(@strid,0) and s.lid<>@lid
           and wday=@wday and npair=@npair
           and ((@week=0)or((@week<>0)and([week] in (0,@week))))
    )
      set @res=0
    else set @res=1
  end
  else set @res=1
  
  return @res
END


















GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO






-- проверка занятости преп-ля (strid,week,wday,npair)
-- иск. поточ. занятие
-- опр-ние tid,sem,psem от strid
-- возвращает 1, если преп-ль свободен, иначе 0
CREATE      FUNCTION dbo.uf_freetid_s
(
@strid bigint,
@week tinyint,
@wday tinyint,
@npair tinyint
)  
RETURNS tinyint AS  
BEGIN 
  declare
    @res tinyint,
    @l_ynum smallint,
    @l_sem tinyint,
    @l_psem tinyint,
    @l_tid bigint

  select @l_ynum=ynum, @l_sem=sem, @l_psem=psem, @l_tid=tid
    from tb_Stream
    where strid=@strid

  if (@strid is not null) and (@l_tid is not null)
    and (@l_ynum is not null) and (@l_sem is not null) and (@l_psem is not null)
  begin
    if exists
    (
      select lid
        from vw_Schedule
        where ynum=@l_ynum and sem=@l_sem and psem=@l_psem
          and wday=@wday and npair=@npair
          and tid=@l_tid and strid<>@strid
          and ((@week=0)or((@week<>0)and([week] in (0,@week))))
    )
      set @res=0
    else set @res=1
  end
  else set @res=1

  return @res
END







GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO



-- проверка на превышение нормы нагрузки потоком (strid,week)
-- возвращает 1 - если нагрузка не превышена, иначе 0
CREATE   FUNCTION dbo.uf_chkhours_s
(
@strid bigint,
@week tinyint,
@hgrp tinyint
)
RETURNS tinyint AS  
BEGIN 
  declare @res tinyint

  -- выборка нагрузок, для которых будет превышение
  if not exists(select lid from tb_Load where strid=@strid and dbo.uf_chkhours_l(lid,@week,@hgrp)=0)
    set @res=1
  else set @res=0

  return @res
END



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


-- возвращает состояние аудитории
-- 0 - свободна, 1 - занята, 2 - огр-ние
CREATE  FUNCTION dbo.uf_stateaid
(
@ynum smallint,
@sem tinyint,
@psem tinyint,
@week tinyint,
@wday tinyint,
@npair tinyint,
@aid bigint
)
RETURNS tinyint AS
BEGIN
  declare @res tinyint

  if @aid is not null
  begin
    set @res=dbo.uf_freeaid(@ynum,@sem,@psem,@week,@wday,@npair,@aid)
    if @res=1
    begin
      set @res=dbo.uf_prefaid(@aid,@wday,@npair)
      if @res=1 set @res=2
    end
    else set @res=1
  end
  else set @res=0

  return @res
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO



-- возвращает состояние преп-ля
-- 0 - свободен, 1 - занят, 2 - пред-ние
CREATE   FUNCTION dbo.uf_statetid
(
@ynum smallint,
@sem tinyint,
@psem tinyint,
@week tinyint,
@wday tinyint,
@npair tinyint,
@tid bigint
)
RETURNS tinyint AS
BEGIN
  declare @res tinyint

  if @tid is not null
  begin
    set @res=dbo.uf_freetid(@ynum,@sem,@psem,@week,@wday,@npair,@tid)
    if @res=1
      set @res=dbo.uf_preftid(@tid,@wday,@npair)
    else set @res=1
  end
  else set @res=0

  return @res
END



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE TABLE [dbo].[tb_Faculty] (
	[fid] [int] IDENTITY (1, 1) NOT NULL ,
	[fName] [varchar] (80) COLLATE Cyrillic_General_CI_AS NOT NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[tb_Post] (
	[pid] [int] IDENTITY (1, 1) NOT NULL ,
	[pName] [varchar] (20) COLLATE Cyrillic_General_CI_AS NOT NULL ,
	[pSmall] [varchar] (10) COLLATE Cyrillic_General_CI_AS NOT NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[tb_Subject] (
	[sbid] [bigint] IDENTITY (1, 1) NOT NULL ,
	[sbName] [varchar] (100) COLLATE Cyrillic_General_CI_AS NOT NULL ,
	[sbSmall] [varchar] (20) COLLATE Cyrillic_General_CI_AS NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[tb_Year] (
	[ynum] [smallint] NOT NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[tb_Kafedra] (
	[kid] [bigint] IDENTITY (1, 1) NOT NULL ,
	[fid] [int] NOT NULL ,
	[kName] [varchar] (150) COLLATE Cyrillic_General_CI_AS NOT NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[tb_Period] (
	[prid] [int] IDENTITY (1, 1) NOT NULL ,
	[ynum] [smallint] NOT NULL ,
	[sem] [tinyint] NOT NULL ,
	[ptype] [tinyint] NOT NULL ,
	[p_start] [datetime] NOT NULL ,
	[p_end] [datetime] NOT NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[tb_Auditory] (
	[aid] [bigint] IDENTITY (1, 1) NOT NULL ,
	[aName] [varchar] (10) COLLATE Cyrillic_General_CI_AS NOT NULL ,
	[kid] [bigint] NULL ,
	[Capacity] [int] NOT NULL ,
	[fid] [int] NOT NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[tb_Group] (
	[grid] [bigint] IDENTITY (1, 1) NOT NULL ,
	[kid] [bigint] NOT NULL ,
	[grName] [varchar] (10) COLLATE Cyrillic_General_CI_AS NOT NULL ,
	[studs] [smallint] NOT NULL ,
	[course] [tinyint] NOT NULL ,
	[ynum] [smallint] NOT NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[tb_Stream] (
	[strid] [bigint] IDENTITY (1, 1) NOT NULL ,
	[ynum] [smallint] NOT NULL ,
	[sem] [tinyint] NOT NULL ,
	[psem] [tinyint] NOT NULL ,
	[type] [tinyint] NOT NULL ,
	[hours] [tinyint] NOT NULL ,
	[kid] [bigint] NOT NULL ,
	[tid] [bigint] NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[tb_Teacher] (
	[tid] [bigint] IDENTITY (1, 1) NOT NULL ,
	[kid] [bigint] NOT NULL ,
	[pid] [int] NOT NULL ,
	[tName] [varchar] (50) COLLATE Cyrillic_General_CI_AS NOT NULL ,
	[Name] [varchar] (50) COLLATE Cyrillic_General_CI_AS NULL ,
	[Partname] [varchar] (50) COLLATE Cyrillic_General_CI_AS NULL ,
	[Initials] [varchar] (50) COLLATE Cyrillic_General_CI_AS NOT NULL ,
	[BDay] [datetime] NULL ,
	[Adress] [varchar] (100) COLLATE Cyrillic_General_CI_AS NULL ,
	[Phone] [varchar] (20) COLLATE Cyrillic_General_CI_AS NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[tb_PrefAudit] (
	[aid] [bigint] NOT NULL ,
	[wday] [tinyint] NOT NULL ,
	[npair] [tinyint] NOT NULL ,
	[astate] [tinyint] NOT NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[tb_PrefTeach] (
	[tid] [bigint] NOT NULL ,
	[wday] [tinyint] NOT NULL ,
	[npair] [tinyint] NOT NULL ,
	[tstate] [tinyint] NOT NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[tb_Workplan] (
	[wpid] [bigint] IDENTITY (1, 1) NOT NULL ,
	[grid] [bigint] NOT NULL ,
	[sbid] [bigint] NOT NULL ,
	[kid] [bigint] NOT NULL ,
	[Sem] [tinyint] NOT NULL ,
	[sbCode] [varchar] (20) COLLATE Cyrillic_General_CI_AS NULL ,
	[WP1] [tinyint] NULL ,
	[WP2] [tinyint] NULL ,
	[TotalHLP] [int] NULL ,
	[TotalAHLP] [int] NULL ,
	[Compl] [int] NULL ,
	[Kp] [tinyint] NULL ,
	[Kr] [tinyint] NULL ,
	[Rg] [tinyint] NULL ,
	[Cr] [tinyint] NULL ,
	[Hr] [tinyint] NULL ,
	[Koll] [tinyint] NULL ,
	[Z] [tinyint] NULL ,
	[E] [tinyint] NOT NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[tb_Exam] (
	[wpid] [bigint] NOT NULL ,
	[xmtype] [tinyint] NOT NULL ,
	[xmtime] [datetime] NOT NULL ,
	[hgrp] [tinyint] NOT NULL ,
	[aid] [bigint] NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[tb_Load] (
	[lid] [bigint] IDENTITY (1, 1) NOT NULL ,
	[wpid] [bigint] NOT NULL ,
	[PSem] [tinyint] NOT NULL ,
	[Type] [tinyint] NOT NULL ,
	[tid] [bigint] NULL ,
	[strid] [bigint] NULL ,
	[Hours] [tinyint] NOT NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[tb_Schedule] (
	[lid] [bigint] NOT NULL ,
	[week] [tinyint] NOT NULL ,
	[wday] [tinyint] NOT NULL ,
	[npair] [tinyint] NOT NULL ,
	[hgrp] [tinyint] NOT NULL ,
	[aid] [bigint] NULL 
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[tb_Faculty] WITH NOCHECK ADD 
	CONSTRAINT [PK_Faculty] PRIMARY KEY  CLUSTERED 
	(
		[fid]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[tb_Post] WITH NOCHECK ADD 
	CONSTRAINT [PK_Post] PRIMARY KEY  CLUSTERED 
	(
		[pid]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[tb_Subject] WITH NOCHECK ADD 
	CONSTRAINT [PK_Subject] PRIMARY KEY  CLUSTERED 
	(
		[sbid]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[tb_Year] WITH NOCHECK ADD 
	CONSTRAINT [PK_Year] PRIMARY KEY  CLUSTERED 
	(
		[ynum]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[tb_Kafedra] WITH NOCHECK ADD 
	CONSTRAINT [PK_Kafedra] PRIMARY KEY  CLUSTERED 
	(
		[kid]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[tb_Period] WITH NOCHECK ADD 
	CONSTRAINT [PK_Period] PRIMARY KEY  CLUSTERED 
	(
		[prid]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[tb_Auditory] WITH NOCHECK ADD 
	CONSTRAINT [PK_Auditory] PRIMARY KEY  CLUSTERED 
	(
		[aid]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[tb_Group] WITH NOCHECK ADD 
	CONSTRAINT [PK_Group] PRIMARY KEY  CLUSTERED 
	(
		[grid]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[tb_Stream] WITH NOCHECK ADD 
	CONSTRAINT [PK_Stream] PRIMARY KEY  CLUSTERED 
	(
		[strid]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[tb_Teacher] WITH NOCHECK ADD 
	CONSTRAINT [PK_Teacher] PRIMARY KEY  CLUSTERED 
	(
		[tid]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[tb_PrefAudit] WITH NOCHECK ADD 
	CONSTRAINT [PK_PrefAud] PRIMARY KEY  CLUSTERED 
	(
		[aid],
		[wday],
		[npair]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[tb_PrefTeach] WITH NOCHECK ADD 
	CONSTRAINT [PK_PrefTeach] PRIMARY KEY  CLUSTERED 
	(
		[tid],
		[wday],
		[npair]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[tb_Workplan] WITH NOCHECK ADD 
	CONSTRAINT [PK_Workplan] PRIMARY KEY  CLUSTERED 
	(
		[wpid]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[tb_Exam] WITH NOCHECK ADD 
	CONSTRAINT [PK_Exam] PRIMARY KEY  CLUSTERED 
	(
		[wpid],
		[xmtype]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[tb_Load] WITH NOCHECK ADD 
	CONSTRAINT [PK_Load] PRIMARY KEY  CLUSTERED 
	(
		[lid]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[tb_Schedule] WITH NOCHECK ADD 
	CONSTRAINT [PK_Schedule] PRIMARY KEY  CLUSTERED 
	(
		[lid],
		[week],
		[wday],
		[npair]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[tb_Faculty] ADD 
	CONSTRAINT [IX_Faculty] UNIQUE  NONCLUSTERED 
	(
		[fName]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[tb_Post] ADD 
	CONSTRAINT [IX_Post] UNIQUE  NONCLUSTERED 
	(
		[pName]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[tb_Subject] ADD 
	CONSTRAINT [IX_Subject] UNIQUE  NONCLUSTERED 
	(
		[sbName]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[tb_Year] ADD 
	CONSTRAINT [CK_Year] CHECK ([ynum] > 0)
GO

ALTER TABLE [dbo].[tb_Kafedra] ADD 
	CONSTRAINT [IX_Kafedra] UNIQUE  NONCLUSTERED 
	(
		[kName]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[tb_Period] ADD 
	CONSTRAINT [IX_Period] UNIQUE  NONCLUSTERED 
	(
		[ynum],
		[sem],
		[ptype]
	)  ON [PRIMARY] ,
	CONSTRAINT [CK_Period] CHECK (([sem] = 1 or [sem] = 2) and [p_end] > [p_start]),
	CONSTRAINT [CK_Period_ptype] CHECK ([ptype] > 0 and [ptype] < 4)
GO

ALTER TABLE [dbo].[tb_Auditory] ADD 
	CONSTRAINT [DF_Auditory_Capacity] DEFAULT (20) FOR [Capacity],
	CONSTRAINT [IX_Auditory] UNIQUE  NONCLUSTERED 
	(
		[aName]
	)  ON [PRIMARY] ,
	CONSTRAINT [CK_Auditory] CHECK ([Capacity] > 0),
	CONSTRAINT [CK_Auditory_kid] CHECK ([dbo].[chk_existskid]([fid], [kid]) = 1)
GO

ALTER TABLE [dbo].[tb_Group] ADD 
	CONSTRAINT [IX_Group] UNIQUE  NONCLUSTERED 
	(
		[grName]
	)  ON [PRIMARY] ,
	CONSTRAINT [CK_Group] CHECK ([studs] > 0 and ([course] >= 1 and [course] <= 5)),
	CONSTRAINT [CK_Group_ynum] CHECK ([dbo].[chk_getpsem]([ynum]) = 4)
GO

ALTER TABLE [dbo].[tb_PrefAudit] ADD 
	CONSTRAINT [DF_PrefAudit_astate] DEFAULT (2) FOR [astate],
	CONSTRAINT [CK_PrefAudit] CHECK ([wday] >= 1 and [wday] <= 6 and ([npair] >= 1 and [npair] <= 7) and [astate] >= 2)
GO

ALTER TABLE [dbo].[tb_PrefTeach] ADD 
	CONSTRAINT [DF_PrefTeach_tstate] DEFAULT (2) FOR [tstate],
	CONSTRAINT [CK_PrefTeach] CHECK ([wday] >= 1 and [wday] <= 6 and ([npair] >= 1 and [npair] <= 7) and [tstate] >= 2)
GO

ALTER TABLE [dbo].[tb_Workplan] ADD 
	CONSTRAINT [DF_Workplan_Z] DEFAULT (0) FOR [Z],
	CONSTRAINT [DF_Workplan_E] DEFAULT (0) FOR [E],
	CONSTRAINT [IX_Workplan] UNIQUE  NONCLUSTERED 
	(
		[grid],
		[sbid],
		[Sem]
	)  ON [PRIMARY] ,
	CONSTRAINT [CK_Workplan] CHECK (([Sem] = 2 or [Sem] = 1) and ([E] = 2 or ([E] = 1 or [E] = 0)) and ([Z] = 2 or ([Z] = 1 or [Z] = 0)))
GO

ALTER TABLE [dbo].[tb_Exam] ADD 
	CONSTRAINT [DF_Exam_etype] DEFAULT (0) FOR [xmtype],
	CONSTRAINT [DF_Exam_hgrp] DEFAULT (0) FOR [hgrp],
	CONSTRAINT [CK_Exam_hgrp] CHECK ([hgrp] = 0 or [hgrp] = 1 and [xmtype] = 0),
	CONSTRAINT [CK_Exam_time] CHECK ([dbo].[chk_exam_time]([wpid], [xmtime]) = 1),
	CONSTRAINT [CK_Exam_wp] CHECK ([dbo].[chk_exam_wp]([wpid]) = 1),
	CONSTRAINT [CK_Exam_xmtype] CHECK ([xmtype] = 0 or [xmtype] = 1)
GO

ALTER TABLE [dbo].[tb_Load] ADD 
	CONSTRAINT [DF_Load_PSem] DEFAULT (1) FOR [PSem],
	CONSTRAINT [DF_Load_Type] DEFAULT (1) FOR [Type],
	CONSTRAINT [DF_Load_Hours] DEFAULT (2) FOR [Hours],
	CONSTRAINT [IX_Load] UNIQUE  NONCLUSTERED 
	(
		[wpid],
		[PSem],
		[Type]
	)  ON [PRIMARY] ,
	CONSTRAINT [CK_Load] CHECK (([PSem] = 2 or [PSem] = 1) and ([Type] = 3 or ([Type] = 2 or [Type] = 1)) and [Hours] > 0)
GO

ALTER TABLE [dbo].[tb_Schedule] ADD 
	CONSTRAINT [DF_Schedule_week] DEFAULT (0) FOR [week],
	CONSTRAINT [DF_Schedule_hgrp] DEFAULT (0) FOR [hgrp],
	CONSTRAINT [CK_Schedule] CHECK ([week] >= 0 and [week] <= 2 and ([wday] >= 1 and [wday] <= 6) and ([npair] >= 1 and [npair] <= 7) and ([hgrp] = 0 or [hgrp] = 1))
GO

ALTER TABLE [dbo].[tb_Kafedra] ADD 
	CONSTRAINT [FK_Kafedra_Faculty] FOREIGN KEY 
	(
		[fid]
	) REFERENCES [dbo].[tb_Faculty] (
		[fid]
	)
GO

ALTER TABLE [dbo].[tb_Period] ADD 
	CONSTRAINT [FK_Period_Year] FOREIGN KEY 
	(
		[ynum]
	) REFERENCES [dbo].[tb_Year] (
		[ynum]
	)
GO

ALTER TABLE [dbo].[tb_Auditory] ADD 
	CONSTRAINT [FK_Auditory_Faculty] FOREIGN KEY 
	(
		[fid]
	) REFERENCES [dbo].[tb_Faculty] (
		[fid]
	),
	CONSTRAINT [FK_Auditory_Kafedra] FOREIGN KEY 
	(
		[kid]
	) REFERENCES [dbo].[tb_Kafedra] (
		[kid]
	) ON UPDATE CASCADE 
GO

ALTER TABLE [dbo].[tb_Group] ADD 
	CONSTRAINT [FK_Group_Kafedra] FOREIGN KEY 
	(
		[kid]
	) REFERENCES [dbo].[tb_Kafedra] (
		[kid]
	),
	CONSTRAINT [FK_Group_Year] FOREIGN KEY 
	(
		[ynum]
	) REFERENCES [dbo].[tb_Year] (
		[ynum]
	)
GO

ALTER TABLE [dbo].[tb_Stream] ADD 
	CONSTRAINT [FK_Stream_Kafedra] FOREIGN KEY 
	(
		[kid]
	) REFERENCES [dbo].[tb_Kafedra] (
		[kid]
	) ON UPDATE CASCADE 
GO

ALTER TABLE [dbo].[tb_Teacher] ADD 
	CONSTRAINT [FK_Teacher_Kafedra] FOREIGN KEY 
	(
		[kid]
	) REFERENCES [dbo].[tb_Kafedra] (
		[kid]
	),
	CONSTRAINT [FK_Teacher_Post] FOREIGN KEY 
	(
		[pid]
	) REFERENCES [dbo].[tb_Post] (
		[pid]
	)
GO

ALTER TABLE [dbo].[tb_PrefAudit] ADD 
	CONSTRAINT [FK_PrefAud_Auditory] FOREIGN KEY 
	(
		[aid]
	) REFERENCES [dbo].[tb_Auditory] (
		[aid]
	) ON DELETE CASCADE 
GO

ALTER TABLE [dbo].[tb_PrefTeach] ADD 
	CONSTRAINT [FK_PrefTeach_Teacher] FOREIGN KEY 
	(
		[tid]
	) REFERENCES [dbo].[tb_Teacher] (
		[tid]
	) ON DELETE CASCADE 
GO

ALTER TABLE [dbo].[tb_Workplan] ADD 
	CONSTRAINT [FK_Workplan_Group] FOREIGN KEY 
	(
		[grid]
	) REFERENCES [dbo].[tb_Group] (
		[grid]
	) ON DELETE CASCADE  ON UPDATE CASCADE ,
	CONSTRAINT [FK_Workplan_Kafedra] FOREIGN KEY 
	(
		[kid]
	) REFERENCES [dbo].[tb_Kafedra] (
		[kid]
	),
	CONSTRAINT [FK_Workplan_Subject] FOREIGN KEY 
	(
		[sbid]
	) REFERENCES [dbo].[tb_Subject] (
		[sbid]
	)
GO

ALTER TABLE [dbo].[tb_Exam] ADD 
	CONSTRAINT [FK_Exam_Auditory] FOREIGN KEY 
	(
		[aid]
	) REFERENCES [dbo].[tb_Auditory] (
		[aid]
	),
	CONSTRAINT [FK_Exam_Workplan] FOREIGN KEY 
	(
		[wpid]
	) REFERENCES [dbo].[tb_Workplan] (
		[wpid]
	) ON DELETE CASCADE 
GO

ALTER TABLE [dbo].[tb_Load] ADD 
	CONSTRAINT [FK_Load_Stream] FOREIGN KEY 
	(
		[strid]
	) REFERENCES [dbo].[tb_Stream] (
		[strid]
	) ON UPDATE CASCADE ,
	CONSTRAINT [FK_Load_Workplan] FOREIGN KEY 
	(
		[wpid]
	) REFERENCES [dbo].[tb_Workplan] (
		[wpid]
	) ON DELETE CASCADE 
GO

ALTER TABLE [dbo].[tb_Schedule] ADD 
	CONSTRAINT [FK_Schedule_Auditory] FOREIGN KEY 
	(
		[aid]
	) REFERENCES [dbo].[tb_Auditory] (
		[aid]
	),
	CONSTRAINT [FK_Schedule_Load] FOREIGN KEY 
	(
		[lid]
	) REFERENCES [dbo].[tb_Load] (
		[lid]
	) ON DELETE CASCADE 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE VIEW dbo.vw_Workplan
AS
  select g.ynum,g.grid,g.course,
      w.wpid,w.sbid,w.kid,w.sem,w.e,
      l.lid,l.psem,l.type,l.tid,l.strid,l.hours
    from tb_Group g
      join tb_Workplan w on w.grid=g.grid
      left join tb_Load l on l.wpid=w.wpid

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO



CREATE    VIEW dbo.vw_Schedule
AS
  select g.ynum,w.sem,l.psem,
      g.grid,w.wpid,w.sbid,l.lid,l.type,l.tid,l.strid,
      s.week,s.wday,s.npair,s.hgrp,s.aid
    from tb_Schedule s
      join tb_Load l on l.lid=s.lid
      join tb_Workplan w on w.wpid=l.wpid
      join tb_Group g on g.grid=w.grid
--    from tb_Group g
--      join tb_Workplan w on w.grid=w.grid
--      join tb_Load l on l.wpid=w.wpid
--      join tb_Schedule s on s.lid=l.lid




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


-- версия базы
CREATE    PROCEDURE dbo.prc_Version
AS
BEGIN
  set nocount on
  select 0 as major, 2 as minor, 0 as release, 13 as build
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO




/*
  добавление факультета (fName,fid output)
  RETURN_VALUE:
    0  успех (fid=id факультета)
    -1 имя факультета не задано
    >0 server error
*/
CREATE PROCEDURE dbo.fcl_create
(
@fName varchar(80),
@fid int output
)
AS
BEGIN
  set nocount on

  if(@fName is null) return -1

  declare @err int, @trans int
  select @err=0, @trans=@@trancount

  if(@trans=0) begin tran
    else save tran fclcreate

  insert tb_Faculty (fName) values(@fName)
  select @err=@@error,@fid=@@identity

  if(@err!=0)
  begin
    if(@trans=0) rollback tran
      else rollback tran fclcreate
    set @fid=null
  end
  else if(@trans=0) commit tran

  return @err
END









GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

-- выбор факультетов
CREATE  PROCEDURE dbo.fcl_getall
AS
BEGIN
  set nocount on
  select fid, fName from tb_Faculty order by fName
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS OFF 
GO

-- выборка всех должностей
CREATE   PROCEDURE dbo.pst_getall
AS
BEGIN
  set nocount on
  select pid, pname, psmall from tb_Post
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/*
  Извлечение ID дисциплины (sbName)
*/
CREATE PROCEDURE dbo.sbj_getid
(
@sbName varchar(100),
@sbid bigint output
)
AS
BEGIN
  set nocount on

  if(@sbName is not null)
    select @sbid=sbid from tb_Subject where sbName=@sbName
  else
    return -1
  
  return 0
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

-- выборка дисциплин по первой букве (letter)
CREATE   PROCEDURE dbo.sbj_getletter
(
@letter char(1)
)
AS
BEGIN
  set nocount on
  
  if(@letter is not null)
    select sbid,sbName,sbSmall
      from tb_Subject
      where sbName like @letter+'%'
  else return -1
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO




/*
  создание уч. года (ynum)
    0 - успех
    -1  неправиль. параметры
    -2  уч. год уже существует
    >0 server error (ошибка при добавлении в tb_Year)
*/
CREATE    PROCEDURE dbo.yr_create
(
@ynum smallint
)
AS
BEGIN
  set nocount on

  if(@ynum is null) return -1

  declare @err int
  set @err=0

  if not exists(select ynum from tb_Year where ynum=@ynum)
  begin
    insert tb_Year(ynum) values (@ynum)
    select @err=@@error
  end else set @err=-2

  return @err
END




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/*
  Проверка существования уч. года
  RETURN_VALUE:
    0  существует
    -1 вход. парам. заданы неправильно
    -2 не существует
*/
CREATE PROCEDURE dbo.yr_exists
(
@ynum smallint
)
AS
BEGIN
  set nocount on

  if(@ynum is null) return -1

  if exists(select ynum from tb_Year where ynum=@ynum) return 0
    else return -2
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

-- выбор всех уч. годов
CREATE PROCEDURE dbo.yr_getall
AS
BEGIN
  set nocount on
  select ynum from tb_Year
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


/*
  добавление кафедры (fid,kName,kid output)
  RETURN_VALUE:
    0  успех (kid=id кафедры)
    -1 вход. парам-ры заданы неправильно
    -2 ошибка при добавлении в tb_Kafedra
    -3 ошибка при обновлении tb_Kafedra
*/
CREATE PROCEDURE dbo.kaf_create
(
@fid int,
@kName varchar(150),
@kid bigint output
)
AS
BEGIN
  set nocount on

  if(@fid is null)or(@kName is null) return -1

  declare @err int, @trans int
  select
    @err=0,
    @trans=@@trancount,
    @kid=null

  if(@trans=0) begin tran
    else save tran kafcreate

  select @kid=kid from tb_Kafedra where kName=@kName
  if(@kid is null)
  begin
    insert tb_Kafedra (fid, kName) values (@fid,@kName)
    select @err=@@error, @kid=@@identity
    if(@err!=0) set @err=-2
  end
  else
  begin
    update tb_Kafedra set fid=@fid where kid=@kid
    select @err=@@error
    if(@err!=0) set @err=-3
  end

  if(@err!=0)
  begin
    if(@trans=0) rollback tran
      else rollback tran kafcreate
    set @kid=null
  end
  else if(@trans=0) commit tran

  return @err
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO



-- выбор кафедр факультета (fid)
CREATE   PROCEDURE dbo.kaf_get_f
(
@fid int
)
AS
BEGIN
  set nocount on
  if(@fid is not null)
    select kid,kName,fid from tb_Kafedra
      where fid=@fid
      order by kName
  else return -1
END



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO



-- выбор кафедр
CREATE   PROCEDURE dbo.kaf_getall
AS
set nocount on
select kid, kName, fid from tb_Kafedra order by kName
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


/*
  Извлечение ID кафедры (kName)
*/
CREATE  PROCEDURE dbo.kaf_getid
(
@kName varchar(150),
@kid bigint output
)
AS
BEGIN
  set nocount on

  if(@kName is not null)
    select @kid=kid from tb_Kafedra where kName=@kName
  else
    return -1
  
  return 0
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO




/*
  создание периода для уч. года
  RETURN:
  0   успех
  >0  код ошибки
  -1  неправильное задание параметров
  -2  пересечение времен. интервалов
*/ 
CREATE       PROCEDURE dbo.prd_create
(
@prid int output,
@ynum smallint,
@sem tinyint,
@ptype tinyint,
@p_start datetime,
@p_end datetime
)
AS
BEGIN
  set nocount on

  if(@ynum is null)or(@sem is null)or(@ptype is not null)
    or(@p_start is null)or(@p_end is null)
    return -1

  declare @err int
  select @err=0, @prid=null

  -- TODO: проверить дублирование данных (ynum,sem,ptype)
  -- проверка пересечения
  if not exists(
    select prid
      from tb_Period
      where dbo.uf_inrange_d(@p_start,p_start,p_end)=1
        or dbo.uf_inrange_d(@p_end,p_start,p_end)=1
        or dbo.uf_inrange_d(p_start,@p_start,@p_end)=1)
  begin
    insert tb_Period (ynum,sem,ptype,p_start,p_end)
      values (@ynum,@sem,@ptype,@p_start,@p_end)
    select @err=@@error, @prid=@@identity
    if(@err!=0) set @prid=null
  end
  else set @err=-2

  return @err
END






GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

-- выбор периодов года опр. типа (ynum,ptype)
CREATE PROCEDURE dbo.prd_get_t
(
@ynum smallint,
@ptype tinyint
)
AS
BEGIN
  set nocount on
  if(@ynum is null)or(@ptype is null) return -1
  select ynum, sem, ptype, p_start, p_end
    from tb_Period
    where ynum=@ynum and ptype=@ptype
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

-- выбор периодов уч. года (ynum)
CREATE PROCEDURE dbo.prd_get_y
(
@ynum smallint
)
AS
BEGIN
  set nocount on
  if(@ynum is not null)
    select prid,ynum,sem,ptype,p_start,p_end
      from tb_Period
      where ynum=@ynum
  else return -1
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


/*
  Определение границ периода (ynum,sem,ptype,pstart out,pend out)
*/
CREATE  PROCEDURE dbo.prd_getdate
(
@ynum smallint,
@sem tinyint,
@ptype tinyint,
@pstart datetime output,
@pend datetime output
)
AS
BEGIN
  set nocount on

  if(@ynum is null)or(@sem is null)or(@ptype is null) return -1

  select @pstart=p_start, @pend=p_end from tb_Period
    where ynum=@ynum and sem=@sem and ptype=@ptype
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


-- выбор аудиторий факультета (fid)
CREATE   PROCEDURE dbo.adr_get_f
(
@fid int
)
AS
BEGIN
  set nocount on
  if(@fid is not null)
    select aid, aName, kid, Capacity, fid
      from tb_Auditory
      where fid=@fid
  else return -1
END



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


-- выборка аудиторий указ. кафедры (fid,kid) или общекафедральные (kid=null)
CREATE PROCEDURE dbo.adr_getlist_fk
(
@fid int,
@kid bigint
)
AS
BEGIN
  set nocount on

  if(@fid is null) return -1

  select aid, aName
    from tb_Auditory
    where fid=@fid and (kid=@kid or ((@kid is null) and (kid is null)))
END



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/*
  Добавление учеб. группы (grName,kid,studs,course,ynum)
  RETURN_VALUE:
  0  успех
  -1 вход. параметры заданы неправильно
  -2 группа уже существует
  -3 ошибка при добавлении в tb_Group
*/
CREATE PROCEDURE dbo.grp_create
(
@grName varchar(10),
@kid bigint,
@studs smallint,
@course tinyint,
@ynum smallint,
@grid bigint output
)
AS
BEGIN
  set nocount on
  if(@grName is null)or(@kid is null)or(@studs is null)or(@course is null)or(@ynum is null)
    return -1

  declare @err int, @trans int
  select @err=0, @trans=@@trancount, @grid=null

  if(@trans=0) begin tran
    else save tran grpcreate

  if not exists(select grid from tb_Group where grName=@grName)
  begin
    insert tb_Group (grName,kid,studs,course,ynum)
      values (@grName,@kid,@studs,@course,@ynum)
    select @grid=@@identity,@err=@@error
    if(@err!=0) set @err=-3
  end
  else set @err=-2

  if(@err!=0)
  begin
    if(@trans=0) rollback tran
      else rollback tran grpcreate
    set @grid=null
  end
  else if(@trans=0) commit tran

  return @err
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

-- выбор групп кафедры
CREATE PROCEDURE dbo.grp_get_k
(
@ynum smallint,
@kid bigint
)
AS
BEGIN
  set nocount on
  if(@ynum is not null) and (@kid is not null)
    select grid, grName, kid, studs, course, ynum
      from tb_Group
      where ynum=@ynum and kid=@kid
      order by grName
  else return -1
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


-- выбор групп одного курса (ynum,course)
CREATE    PROCEDURE dbo.grp_getcourse
(
@ynum smallint,
@course tinyint
)
AS
BEGIN
  set nocount on
  if (@ynum is not null) and (@course is not null)
    select grid,grName,g.kid,kName,course,ynum
      from tb_Group g
        join tb_Kafedra k on k.kid=g.kid
      where g.ynum=@ynum and g.course=@course
  else return -1
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/*
  Извлечение ID группы
*/
CREATE PROCEDURE dbo.grp_getid
(
@grName varchar(10),
@grid bigint output
)
AS
BEGIN
  set nocount on

  if(@grName is not null)
    select @grid=grid from tb_Group where grName=@grName
  else
    return -1

  return 0
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO




/*

  Упр-ние учеб.-произв. планом (графиком)

  1000  добавление уч. года (ynum)
  1001  выбор периодов уч. года (ynum)
  1002  добавление периода (ynum,sem,ptype,p_start,p_end)

*/
CREATE    PROCEDURE dbo.prc_PlanMgm
(
@case int,
@ynum smallint,
@sem tinyint,
@prid int output,
@ptype tinyint,
@p_start datetime,
@p_end datetime
)
AS
BEGIN
  set nocount on
  declare @err int

  -- добавление уч. года (ynum)
  if @case=1000
  begin
    exec @err=dbo.yr_create @ynum
    return @err
  end

  -- выбор периодов уч. года (ynum)
  if @case=1001
  begin
    exec @err=dbo.prd_get_y @ynum
    return @err
  end

  -- добавление семестра (ynum,sem,ptype,p_start,p_end,prid out)
  if @case=1002
  begin
    exec @err=dbo.prd_create @prid output,@ynum,@sem,@ptype,@p_start,@p_end
    return @err
  end

  return -100
END





GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/*
  удаление потока (strid)
  RETURN_VALUE:
    0  успех
    -1 вход. парам-ры заданы неправильно
    >0 server error (ошибка при удалинии записи в tb_Stream)
*/
CREATE PROCEDURE dbo.stm_delete
(
@strid bigint
)
AS
BEGIN
  set nocount on

  if(@strid is null) return -1

  declare @err int, @trans int

  select @err=0, @trans=@@trancount

  if(@trans=0) begin tran
    else save tran stmdelete

  delete tb_Stream where strid=@strid
  select @err=@@error

  if(@err!=0)
  begin
    if(@trans=0) rollback tran
      else rollback tran stmdelete
  end
  else if(@trans=0) commit tran

  return @err
END




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


/*
  установка лектора для потока (strid,tid)
  RETURN_VALUE:
    0  успех
    -1 вход. парам-ры заданы неправильно
    -2 кафедры потока и преп-ля различны
    -3 ошибка при обновлении tb_Stream
*/
CREATE  PROCEDURE dbo.stm_setthr
(
@strid bigint,
@tid bigint
)
AS
BEGIN
  set nocount on

  if(@strid is null) return -1

  declare @err int, @trans int

  select @err=0, @trans=@@trancount

  if(@trans=0) begin tran
    else save tran stmsetthr

  -- проверка кафедр преп-ля и потока (kid(tid)=kid(strid))
  if @tid is not null
    if not exists(
        select s.strid
          from tb_Stream s
            join tb_Teacher t on t.kid=s.kid
          where s.strid=@strid and t.tid=@tid)
      set @err=-2

  if(@err=0)
  begin
    update tb_Stream set tid=@tid where strid=@strid
    select @err=@@error
    if(@err!=0) set @err=-3
  end

  if(@err!=0)
  begin
    if(@trans=0) rollback tran
      else rollback tran stmsetthr
  end
  else if(@trans=0) commit tran

  return @err
END  


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO


-- выборка преп-лей кафедры (kid)
CREATE    PROCEDURE dbo.thr_getkaf
(
@kid bigint
)
AS
BEGIN
  set nocount on

  if(@kid is not null)
    select * from tb_Teacher where kid=@kid
  else return -1
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

-- выбор преп-лей кафедры (kid)
CREATE   PROCEDURE dbo.thr_getlist
(
@kid bigint
)
AS
BEGIN
  set nocount on

  if(@kid is not null)
    select t.tid, t.tName, t.Initials, p.pSmall
      from tb_Teacher t
        left join tb_Post p on p.pid=t.pid
    where kid=@kid
  else return -1

END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


-- выборка ограничений аудитории (aid)
CREATE   PROCEDURE dbo.adr_getprefer
(
@aid bigint
) 
AS
BEGIN
  set nocount on
  if(@aid is not null)
    select * from tb_PrefAudit where aid=@aid
  else return -1
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

-- выбор кафедр-исполнителей для факультета (ynum,sem,fid)
CREATE PROCEDURE dbo.kaf_getperformer
(
@ynum smallint,
@sem tinyint,
@fid int
)
AS
BEGIN
  set nocount on

  if(@ynum is null)or(@sem is null)or(@fid is null)
    return -1

  select kid,kName
    from tb_Kafedra k
    where exists
    (
      select w.kid
        from tb_Workplan w
          join tb_Group g on g.grid=w.grid
          join tb_Kafedra ck on ck.kid=g.kid
        where g.ynum=@ynum and w.sem=@sem and ck.fid=@fid and w.kid=k.kid
    )
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO




/*
  Управление группами

  801  выбор групп кафедры (ynum,kid)
  802  выбор групп курса (ynum,course)

*/
CREATE    PROCEDURE dbo.prc_GroupMgm
(
@case int,
@ynum smallint,
@grid bigint,
@kid bigint,
@grName varchar(10),
@studs tinyint,
@course tinyint 
)
AS
BEGIN
set nocount on

declare @err int

-- выбор групп кафедры (ynum,kid)
if @case=801
begin
  exec @err=dbo.grp_get_k @ynum, @kid
  return @err
end

-- выбор групп курса (ynum,course)
if @case=802
begin
  exec @err=dbo.grp_getcourse @ynum,@course
  return @err
end

return -100
END



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO




-- выбор дисциплин, к-рые есть в р.п. указ. семестра (ynum,sem)
CREATE PROCEDURE dbo.sbj_get_w
(
@letter char(1),
@ynum smallint,
@sem tinyint
)
AS
BEGIN
  set nocount on

  if (@letter is not null) and (@ynum is not null) and (@sem is not null)
    select s.sbid,s.sbName
      from tb_Subject s
      where s.sbName like @letter+'%'
        and exists(
          select sbid from tb_Workplan w join tb_Group g on g.grid=w.grid
            where g.ynum=@ynum and w.sem=@sem and w.sbid=s.sbid)
  else return -1
END




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO




-- выбор дисциплин группы (sem, grid)
CREATE    PROCEDURE dbo.sbj_getgrp
(
@sem tinyint,
@grid bigint
)
AS
BEGIN
  set nocount on

  if (@sem is not null) and (@grid is not null)
    select Sbj.sbid, sbName 
      from tb_Subject Sbj
        join tb_Workplan Wp on Sbj.sbid=Wp.sbid
      where Wp.Sem=@Sem and Wp.grid=@grid
      order by sbName
  else return -1
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


/*
  Выбор дисциплин группы, по к-рым проводится экз (sem,grid)
*/
CREATE  PROCEDURE dbo.sbj_getgrp_e
(
@sem tinyint,
@grid bigint
)
AS
BEGIN
  set nocount on

  if(@sem is null)or(@grid is null) return -1

  select w.wpid, s.sbName 
    from tb_Subject s
      join tb_Workplan w on s.sbid=w.sbid
    where w.sem=@sem and w.grid=@grid and w.e>0
END



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

-- выбор групп, р.п. к-рых содержат указ. дисциплину (sbid,ynum,sem)
CREATE PROCEDURE dbo.sbj_getgrp_s
(
@sbid bigint,
@ynum smallint,
@sem tinyint
)
AS
BEGIN
  set nocount on

  if(@sbid is null)or(@ynum is null)or(@sem is null) return -1

  select w.wpid,w.grid,g.grName,g.ynum,w.sem
    from tb_workplan w
      join tb_subject s on s.sbid=w.sbid
      join tb_group g on g.grid=w.grid
    where w.sbid=@sbid and (g.ynum=@ynum or @ynum is null)
       and (w.sem=@sem or @sem is null)
END




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO





-- выбор дисциплин кафедры (заявки) (ynum,sem,kid)
CREATE  PROCEDURE dbo.sbj_getkaf
(
@ynum smallint,
@sem tinyint,
@kid bigint
)
AS
BEGIN
  set nocount on
  if(@ynum is not null) and (@sem is not null) and (@kid is not null)
    select distinct s.sbid, s.sbName
      from tb_Subject s
        join tb_Workplan w on s.sbid=w.sbid
        join tb_Group g on g.grid=w.grid
      where g.ynum=@ynum and w.sem=@sem and w.kid=@kid
      order by sbName
  else return -1
END



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

/*
  замена дисциплины (sbid -> new)
  RETURN_VALUE:
    0  успех
    -1 вход. парам-ры заданы неправильно
    -2 ошибка при обновлении tb_Workplan
    -3 ошибка при удалении исход. дисциплины

  TODO: учесть р.п., к-рые содержат нов. дисциплину
*/
CREATE      PROCEDURE dbo.sbj_replace
(
@sbid bigint,  -- исход. дисциплина
@new bigint    -- нов. дисциплина
)
AS
BEGIN
  set nocount on

  if(@sbid is null)or(@new is null)or(@sbid=@new) return -1

  declare @err int, @trans int
  select @err=0, @trans=@@trancount

  if(@trans=0) begin tran
    else save tran sbjreplace
  
  -- обновление раб.плана
  --update w set sbid=@new
  --  from tb_Workplan w
  --  where sbid=@sbid and sbid<>@new and
  --    not exists(select wpid from tb_Workplan where grid=w.grid and sem=w.sem and sbid=@new)
  update tb_Workplan set sbid=@new where sbid=@sbid and sbid<>@new
  select @err=@@error

  if(@err=0)
  begin
    -- удаление исход. дисциплины
    delete tb_Subject where sbid=@sbid
    select @err=@@error
    if(@err!=0) set @err=-3
  end
  else set @err=-2
  
  if(@err!=0)
  begin
    if(@trans=0) rollback tran
      else rollback tran sbjreplace
  end
  else if(@trans=0) commit tran

  return @err
END





GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

-- выборка предпочтений преп-ля (tid)
CREATE  PROCEDURE dbo.thr_getprefer
(
@tid bigint
)
AS
BEGIN
  set nocount on

  if(@tid is not null)
    select * from tb_PrefTeach where tid=@tid
  else return -1
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

/*
  добавление дисциплины в раб. план (grid,sem,sbid,kid,e,wpid output)
  RETURN_VALUE:
    0  успех (wpid=id раб.плана)
    -1 вход. парам-ры заданы неправильно
    -2 дисциплина уже существует в раб.плане
    -3 ошибка при добавлении в tb_Workplan
*/
CREATE PROCEDURE dbo.wp_create
(
@grid bigint,
@sem tinyint,
@sbid bigint,
@kid bigint,
@e tinyint,
@wpid bigint output
)
AS
BEGIN
  set nocount on

  if(@grid is null)or(@sbid is null)or(@kid is null)or(@sem is null)or(@e is null)
    return -1

  declare @err int, @trans int

  set @err=0
  set @trans=@@trancount
  set @wpid=null

  if(@trans=0) begin tran
    else save tran wpcreate

  if not exists
  (
    select wpid
      from tb_Workplan
      where grid=@grid and sbid=@sbid and sem=@sem
  )
  begin
    insert tb_Workplan (grid,sbid,kid,sem,e) values (@grid,@sbid,@kid,@sem,@e)
    select @wpid=@@identity, @err=@@error
    if(@err!=0) set @err=-3
  end
  else set @err=-2

  if(@err!=0)
  begin
    if(@trans=0) rollback tran
      else rollback tran wpcreate
    set @wpid=null
  end
  else if(@trans=0) commit tran
    
  return @err
END




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/*
  добавление дисциплины в раб. план ([all],wpid output)
  RETURN_VALUE:
    0  успех (wpid=id раб.плана)
    -1 вход. парам-ры заданы неправильно
    -2 дисциплина уже существует в раб.плане
    -3 ошибка при добавлении в tb_Workplan
*/
CREATE PROCEDURE dbo.wp_create2
(
@grid bigint,
@sem tinyint,
@sbid bigint,
@kid bigint,
@sbCode varchar(20),
@WP1 tinyint,
@WP2 tinyint,
@TotalHLP int,
@TotalAHLP int,
@Compl int,
@Kp tinyint,
@Kr tinyint,
@Rg tinyint,
@Cr tinyint,
@Hr tinyint,
@Koll tinyint,
@z tinyint,
@e tinyint,
@wpid bigint output
)
AS
BEGIN
  set nocount on

  if(@grid is null)or(@sbid is null)or(@kid is null)or(@sem is null)or(@e is null)
    return -1

  declare @err int, @trans int

  select @err=0,@trans=@@trancount,@wpid=null

  if(@trans=0) begin tran
    else save tran wpcreate2

  if not exists
  (
    select wpid from tb_Workplan where grid=@grid and sbid=@sbid and sem=@sem
  )
  begin
    insert tb_Workplan (grid,sbid,kid,sem,sbCode,WP1,WP2,TotalHLP,TotalAHLP,Compl,Kp,Kr,Rg,Cr,Hr,Koll,z,e)
      values (@grid,@sbid,@kid,@sem,@sbCode,@WP1,@WP2,@TotalHLP,@TotalAHLP,@Compl,@Kp,@Kr,@Rg,@Cr,@Hr,@Koll,@z,@e)
    select @wpid=@@identity, @err=@@error
    if(@err!=0) set @err=-3
  end
  else set @err=-2

  if(@err!=0)
  begin
    if(@trans=0) rollback tran
      else rollback tran wpcreate2
    set @wpid=null
  end
  else if(@trans=0) commit tran
    
  return @err
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO



/*
  удаление дисциплины из раб. плана (wpid)
  RETURN_VALUE:
    0  успех
    -1 вход. парам-ры заданы неправильно
    >0 server error (ошибка при удалении в tb_Workplan)
*/
CREATE    PROCEDURE dbo.wp_delete
(
@wpid bigint
)
AS
BEGIN
  set nocount on

  if(@wpid is null) return -1

  declare @err int, @trans int
  select @err=0, @trans=@@trancount

  if(@trans=0) begin tran
    else save tran wpdelete

  delete tb_Workplan where wpid=@wpid
  select @err=@@error

  if(@err!=0)
  begin
    if(@trans=0) rollback tran
      else rollback tran wpcreate
  end
  else if(@trans=0) commit tran

  return @err
END



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO


/*
  удаление раб. плана группы
  RETURN_VALUE:
    0  успех
    -1 вход. парам-ры заданы неправильно
    >0 server error (ошибка при удалении в tb_Group)
*/
CREATE  PROCEDURE dbo.wp_delgrp
(
@grid bigint
)
AS
BEGIN
  set nocount on

  if(@grid is null) return -1

  declare @err int, @trans int
  select @err=0, @trans=@@trancount

  if(@trans=0) begin tran
    else save tran delgrp

  delete tb_Workplan where grid=@grid
  set @err=@@error

  if(@err!=0)
  begin
    if(@trans=0) rollback tran
      else rollback tran delgpr
  end
  else if(@trans=0) commit tran

  return @err
END












GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


-- возвращает кафедру-исполнителя
CREATE  PROCEDURE dbo.wp_getkaf
(
@sem tinyint,
@grid bigint,
@sbid bigint
)
AS
BEGIN
  set nocount on

  if(@sem is null)or(@grid is null)or(@sbid is null) return -1

  select w.kid,k.kName
    from tb_Workplan w
      join tb_Kafedra k on k.kid=w.kid
    where w.sem=@sem and w.grid=@grid and w.sbid=@sbid
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


/*
  Выбор кафедр-исполнителей для экзаменов
*/
CREATE  PROCEDURE dbo.xm_getkaf_f
(
@ynum smallint,
@sem tinyint,
@fid int
)
AS
BEGIN
  set nocount on

  if(@ynum is null)or(@sem is null)or(@fid is null)
    return -1

  select distinct wk.kid,wk.kName
    from tb_Workplan w
      join tb_Group g on g.grid=w.grid
      join tb_Kafedra k on k.kid=g.kid
      join tb_Kafedra wk on wk.kid=w.kid
    where g.ynum=@ynum and w.sem=@sem and k.fid=@fid and w.e>0
END



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO





/*
  добавление нагрузки (wpid,psem,type,tid,hours,lid output)
  RETURN_VALUE:
    0  успех
    -1 вход. парам-ры заданы неправильно
    -2 нагрузка уже существует
    -3 ошибка при добавлении в tb_Load
    >0 server error
*/
CREATE     PROCEDURE dbo.ld_create
(
@wpid bigint,
@psem tinyint,
@type tinyint,
@hours tinyint,
@lid bigint output
)
AS
BEGIN
  set nocount on
  
  if(@wpid is null)or(@psem is null)or(@type is null)or(@hours!>0) return -1  

  declare @err int, @trans int
  select @err=0, @trans=@@trancount

  if(@trans=0) begin tran
    else save tran ldcreate

  if not exists(select lid from tb_Load where wpid=@wpid and psem=@psem and type=@type)
  begin
    insert tb_Load (wpid,psem,type,hours) values(@wpid,@psem,@type,@hours)
    select @err=@@error, @lid=@@identity
    if(@err!=0) set @err=-3
  end
  else set @err=-2

  if(@err!=0)
  begin
    if(@trans=0) rollback tran
      else rollback tran ldcreate
    set @lid=null
  end
  else if(@trans=0) commit tran

  return @err
END










GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO


/*
  удаление нагрузки (lid)
  RETURN_VALUE:
    0  успех
    -1 вход. парам-ры заданы непрвавильно
    -2 ошибка при удалении
*/
CREATE  PROCEDURE dbo.ld_delete
(
@lid bigint
)
AS
BEGIN
  set nocount on

  if(@lid is null) return -1

  declare @err int, @trans int
  select @err=0, @trans=@@trancount

  if(@trans=0) begin tran
    else save tran lddelete

  delete tb_Load where lid=@lid
  select @err=@@error
  if(@err!=0) set @err=-2

  if(@err!=0)
  begin
    if(@trans=0) rollback tran
      else rollback tran lddelete
  end
  else if(@trans=0) commit tran

  return @err
END



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO



/*
  401  выбор аудиторий кафедры (fid,kid)
  402  выбор аудиторий факультета (fid)
  404  выбор ограничений аудитории (aid)
*/
CREATE    PROCEDURE dbo.prc_AudMgm
(
@case int,
@aid bigint,
@fid int,
@kid bigint
)
AS
BEGIN
  set nocount on

  declare @err int
  set @err=0

  -- выбор аудиторий кафедры (fid,kid)
  if @case=401
  begin
    exec @err=adr_getlist_fk @fid,@kid
    return @err
  end

  -- выбор аудиторий факультета (fid)
  if @case=402
  begin
    exec @err=dbo.adr_get_f @fid
    return @err
  end

  -- выбор ограничений аудитории (aid)
  if @case=404
  begin
    exec @err=dbo.adr_getprefer @aid
    return @err
  end

  return -100
END



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO






/*
  Просмотр структуры БД

  101  выбор кафедр
  102  выбор групп кафедры (ynum,kid)
  103  выбор дисциплин кафедры (ynum,sem,kid)
  104  выбор дисциплин группы (sem,grid)
  105  выбор всех должностей преп-лей
  106  выбор групп курса (ynum,course)
  107  
  108  выбор дисциплин, имеющ. в р.п. (letter,ynum,sem)
  109  выбор групп, р.п. к-рых содержат дисциплину (sbid,[ynum,sem])
  110  выбор факультетов
  111  выбор кафедр факультета (fid)
  112  выбор уч. годов
  113  выбор дисциплин группы, по к-рым проводится экз (sem,grid)
  114  выбор кафедр-исполнителей для факультета (ynum,sem,fid)
*/
CREATE         PROCEDURE dbo.prc_DBView
(
@case int,
@ynum smallint, -- год
@sem tinyint,	-- семестр
@fid int,		-- id факультета
@kid bigint,	-- id кафедры
@grid bigint,	-- id группы
@sbid bigint,	-- id дисциплины
@letter char(1),	-- первая буква дисциплины
@course tinyint	-- номер курса
)
AS
BEGIN
set nocount on
declare @err int

-- выбор кафедр
if @case=101
begin
  exec @err=kaf_getall
  return @err
end

-- выбор групп кафедры (ynum,kid)
if @case=102
begin
  exec @err=grp_get_k @ynum, @kid
  return @err
end

-- выбор дисциплин кафедры (ynum,sem,kid)
if @case=103
begin
  exec @err=sbj_getkaf @ynum, @sem, @kid
  return @err
end

-- выбор дисциплин группы (sem,grid)
if @case=104
begin
  exec @err=sbj_getgrp @sem, @grid
  return @err
end

if @case=105
begin
  exec @err=pst_getall
  return @err
end

-- выбор групп одного курса (ynum,course)
if @case=106
begin
  exec @err=grp_getcourse @ynum, @course
  return @err
end

-- выбор дисциплин, имеющ. в р.п. (letter,ynum,sem)
if @case=108
begin
  exec @err=dbo.sbj_get_w @letter, @ynum, @sem
  return @err
end

-- выбор групп, р.п. к-рых содержат дисциплину (sbid,[ynum,sem])
if @case=109
begin
  exec @err=dbo.sbj_getgrp_s @sbid, @ynum, @sem
  return @err
end

-- выбор факультетов
if @case=110
begin
  exec @err=dbo.fcl_getall
  return @err
end

-- выбор кафедр факультета (fid)
if @case=111
begin
  exec @err=dbo.kaf_get_f @fid
  return @err
end

-- выбор уч. годов
if @case=112
begin
  exec @err=dbo.yr_getall
  return @err
end

-- выбор дисциплин группы, по к-рым проводится экз (sem,grid)
if @case=113
begin
  exec @err=dbo.sbj_getgrp_e @sem,@grid
  return @err
end

-- выбор кафедр-исполнителей для факультета (ynum,sem,fid)
if @case=114
begin
  exec @err=dbo.kaf_getperformer @ynum,@sem,@fid
  return @err
end

return -100
END
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO


-- импорт аудит. нагрузки р.п.
-- возврат 1 - успех
CREATE  PROCEDURE dbo.prc_ImportLoad
(
@wpId bigint,	-- id р.п.
@Lect tinyint,	-- лекции
@Prct tinyint,	-- практика
@Labs tinyint,	-- лабы
@PSem tinyint	-- п/с
)
AS
BEGIN
SET NOCOUNT ON

  declare @lid bigint

  -- обновление лекций
  set @lid=null
  if isnull(@Lect,0)>0
  begin
    select @lid=lid from tb_Load where wpid=@wpId and PSem=@PSem and Type=1
    if @lid is null
      insert tb_Load (wpid, PSem, Type, Hours) values (@wpId, @PSem, 1, @Lect)
    else
      update tb_Load set Hours=@Lect where lid=@lid
  end
  else delete from tb_Load where wpid=@wpId and PSem=@PSem and Type=1

  -- обновление практик
  set @lid=null
  if isnull(@Prct,0)>0
  begin
    select @lid=lid from tb_Load where wpid=@wpId and PSem=@PSem and Type=2
    if @lid is null
      insert tb_Load (wpid, PSem, Type, Hours) values (@wpId, @PSem, 2, @Prct)
    else
      update tb_Load set Hours=@Prct where lid=@lid
  end
  else delete from tb_Load where wpid=@wpId and PSem=@PSem and Type=2

  -- обновление лаб.
  set @lid=null
  if isnull(@Labs,0)>0
  begin
    select @lid=lid from tb_Load where wpid=@wpId and PSem=@PSem and Type=3
    if @lid is null
      insert tb_Load (wpid, PSem, Type, Hours) values (@wpId, @PSem, 3, @Labs)
    else
      update tb_Load set Hours=@Labs where lid=@lid
  end
  else delete from tb_Load where wpid=@wpId and PSem=@PSem and Type=3

END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/*
  Управление дисциплинами

  701  выборка дисциплин по 1ой букве (letter)
  702  замена дисциплины (sbid,new)
*/
CREATE     PROCEDURE dbo.prc_SubjMgm
(
@case int,
@letter char(1),
@sbid bigint,
@new bigint
)
AS
BEGIN
set nocount on
declare @err int

-- выборка дисциплин по 1ой букве (letter)
if @case=701
begin
  exec @err=dbo.sbj_getletter @letter
  return @err
end

-- замена дисциплины (sbid,nsbid)
if @case=702
begin
  exec @err=dbo.sbj_replace @sbid, @new
  return @err
end

return -100
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO




/*
  добавление группы в поток (strid, lid)
  RETURN_VALUE:
  0  успех
  -1 вход. парам-ры заданы неправильно
  >0 server error (ошибка при обновлении tb_Load)
*/
CREATE    PROCEDURE dbo.stm_addgrp
(
@strid bigint,
@lid bigint
)
AS
BEGIN
  set nocount on

  if(@strid is null)or(@lid is null) return -1

  declare @err int, @trans int

  select @err=0, @trans=@@trancount

  if(@trans=0) begin tran
    else save tran stmaddgrp

  update l set strid=s.strid, tid=s.tid
    from tb_Workplan wp
      join tb_Load l on wp.wpid=l.wpid and l.strid is null
      join tb_Stream s on wp.sem=s.sem and l.psem=s.psem and l.type=s.type
        and l.hours=s.hours and wp.kid=s.kid
    where l.lid=@lid and s.strid=@strid
      -- проверка на отсутствие группы в потоке
      and wp.grid not in (select grid from tb_Workplan w join tb_Load ld on w.wpid=ld.wpid where ld.strid=@strid)
  select @err=@@error
  
  if(@err!=0)
  begin
    if(@trans=0) rollback tran
      else rollback tran stmaddgrp
  end
  else if(@trans=0) commit tran

  return @err
END




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/*
  удаление группы из потока (lid)
  RETURN_VALUE:
    0  успех
    -1 вход. парам-ры заданы неправильно
    -2 нагрузка не в потоке
    -3 ошибка при обновлении tb_Load
    -4 ошибка при удалении tb_Stream (удаление пуст. потоков)
*/
CREATE PROCEDURE dbo.stm_delgrp
(
@lid bigint
)
AS
BEGIN
  set nocount on

  if(@lid is null) return -1

  declare 
    @l_strid bigint,
    @err int,
    @trans int

  select @err=0, @trans=@@trancount

  if(@trans=0) begin tran
    else save tran stmdelgrp

  -- выборка strid для lid
  select @l_strid=strid from tb_Load where lid=@lid

  if(@l_strid is not null)
  begin

    -- удаление группы из потока
    update tb_Load set strid=NULL where lid=@lid
    select @err=@@error
    if(@err!=0) set @err=-3

    if(@err=0)
    begin
      -- если в потоке нет больше групп
      if not exists(select lid from tb_Load where strid=@l_strid)
      begin
        -- удаление потока
        delete tb_Stream where strid=@l_strid
        select @err=@@error
        if(@err!=0) set @err=-4
      end
    end

  end else set @err=-2


  if(@err!=0)
  begin
    if(@trans=0) rollback tran
      else rollback tran stmdelgrp
  end
  else if(@trans=0) commit tran

  return @err
END




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

-- выбор потоков кафедры по дисциплине (ynum,sem,psem,type,kid,sbid)
CREATE  PROCEDURE dbo.stm_get_ks
(
@ynum smallint,
@sem tinyint,
@psem tinyint,
@type tinyint,
@kid bigint,
@sbid bigint
)
AS
BEGIN
  set nocount on

  if(@ynum is null)or(@sem is null)or(@psem is null)or(@type is null)
    or(@kid is null)or(@sbid is null)
    return -1

  select l.lid, w.grid, g.grName, w.sbid, s.sbName, l.strid, l.tid, t.tName, l.hours
    from tb_Workplan w
      join tb_Load l on l.wpid=w.wpid
      join tb_Group g on g.grid=w.grid
      join tb_Subject s on s.sbid=w.sbid
      left join tb_Teacher t on t.tid=l.tid
    where g.ynum=@ynum and w.sem=@sem and l.psem=@psem and l.type=@type
      and l.strid in 
        (select strid 
          from tb_Load ld 
            join tb_Workplan wp on wp.wpid=ld.wpid
          where wp.kid=@kid and wp.sbid=@sbid and ld.strid is not null)
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

-- выбор заявок на дисциплину
-- + дисциплины, объед. через потоки (ynum,sem,psem,type,kid,sbid)
CREATE   PROCEDURE dbo.stm_getdeclare
(
@ynum smallint,
@sem tinyint,
@psem tinyint,
@type tinyint,
@kid bigint,
@sbid bigint
)
AS
BEGIN
  set nocount on

  if(@ynum is null)or(@sem is null)or(@psem is null)or(@type is null)
    or(@kid is null)or(@sbid is null)
    return -1

  select ld.lid, wp.grid, g.grName, wp.sbid, s.sbName, st.tid, t.tName, ld.strid, ld.hours
    from tb_Workplan wp
      join tb_Load ld on wp.wpid=ld.wpid
      join tb_Group g on wp.grid=g.grid
      join tb_Subject s on wp.sbid=s.sbid
      left join tb_Stream st on ld.strid=st.strid
      left join tb_Teacher t on st.tid=t.tid
    where g.ynum=@ynum and wp.sem=@sem and wp.kid=@kid and ld.psem=@psem and ld.type=@type
      and 
      (wp.sbid=@sbid or exists
        (
        select *
          from tb_Stream s
          where s.kid=wp.kid and strid=ld.strid
            and exists(
              select *
                from tb_Load l
                  join tb_Workplan w on l.wpid=w.wpid
                where l.strid=s.strid and w.sbid=@sbid
        )
      ))
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


-- выбор свобод. заявок (ynum,sem,psem,type,kid,sbid)
CREATE  PROCEDURE dbo.stm_getfree_d
(
@ynum smallint,
@sem tinyint,
@psem tinyint,
@type tinyint,
@kid bigint,
@sbid bigint
)
AS
BEGIN
  set nocount on

  if(@ynum is null)or(@sem is null)or(@psem is null)or(@type is null)
    or(@kid is null)or(@sbid is null)
    return -1

  select l.lid, l.strid, wp.grid, g.grName, wp.sbid, s.sbName, l.tid, t.tName, l.hours
    from tb_Load l
      join tb_Workplan wp on l.wpid=wp.wpid
      join tb_Group g on wp.grid=g.grid
      join tb_Subject s on wp.sbid=s.sbid
      left join tb_Teacher t on t.tid=l.tid
    where g.ynum=@ynum and wp.sem=@sem and l.psem=@psem and l.type=@type
      and wp.kid=@kid and wp.sbid=@sbid and l.strid is null
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


-- выбор свобод. заявок для потока (strid)
CREATE  PROCEDURE dbo.stm_getfree_s
(
@strid bigint
)
AS
BEGIN
  set nocount on

  if (@strid is not null)
    select l.lid, g.grid, g.grName, g.course, sb.sbid, sb.sbName, l.hours
      from tb_Workplan wp
        join tb_Group g on wp.grid=g.grid
        join tb_Subject sb on wp.sbid=sb.sbid
        join tb_Load l on wp.wpid=l.wpid
        join tb_Stream s on s.ynum=g.ynum and s.sem=wp.sem and s.psem=l.psem
          and s.type=l.type and s.hours=l.hours and s.kid=wp.kid
      where s.strid=@strid and l.strid is null
        and wp.grid not in 
          (select grid from tb_Workplan w join tb_Load ld on w.wpid=ld.wpid
            where ld.strid=@strid)
  else return -1
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

-- выбор преп-лей для нагрузки (lid)
CREATE      PROCEDURE dbo.thr_getload
(
@lid bigint
)
AS
BEGIN
  set nocount on

-- TODO: вывод tb_Post.pSmall

  if(@lid is not null)
    select t.tid, t.tName, t.Initials
      from tb_Load l
        join tb_Workplan wp on l.wpid=wp.wpid
        join tb_Teacher t on wp.kid=t.kid
      where lid=@lid
  else return -1
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


/*
  копирование раб. плана дисциплины в др. (wpid output,sbid)
  RETURN_VALUE:
    0  успех (@wpid)
    -1 вход. парам-ры заданы неправильно
    -2 дисциплина существует в раб. плане
    -3 ошибка копирования дисциплины
    -4 ошибка копирования нагрузки
*/
CREATE  PROCEDURE dbo.wp_copy
(
@wpid bigint output,
@sbid bigint
)
AS
BEGIN
  set nocount on
  
  if(@wpid is null)or(@sbid is null) return -1

  declare
    @newid bigint,
    @err int,
    @trans int

  set @newid=null
  set @err=0
  set @trans=@@trancount

  if(@trans=0) begin tran
    else save tran wpcopy

  if not exists
  (
    select wpid from tb_Workplan wp
      where sbid=@sbid 
        and exists(
          select wpid from tb_Workplan where grid=wp.grid and sem=wp.sem and wpid=@wpid)
  )
  begin
    -- copy workplan
    insert tb_Workplan
        (grid,sbid,kid,sem,sbCode,wp1,wp2,totalhlp,totalahlp,compl,kp,kr,rg,cr,hr,koll,z,e)
      select grid,@sbid,kid,sem,sbCode,wp1,wp2,totalhlp,totalahlp,compl,kp,kr,rg,cr,hr,koll,z,e
        from tb_Workplan where wpid=@wpid

    select @err=@@error, @newid=@@identity

    -- copy loads
    if(@err=0)and(@newid is not null)
    begin
      insert tb_Load (wpid,psem,type,hours)
        select @newid,psem,type,hours from tb_Load where wpid=@wpid
      select @err=@@error
      if(@err=0) select @wpid=@newid
        else set @err=-4
    end
    else set @err=-3

  end
  else set @err=-2

  if(@err!=0)
  begin
    if(@trans=0) rollback tran
      else rollback tran wpcopy
    set @wpid=null
  end
  else if(@trans=0) commit tran

  return @err
END









GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO



-- копирование р.п. в другую группу (grid,new)
-- RETURN VALUE - 0 успешно, @err - неудача
CREATE   PROCEDURE dbo.wp_copygrp
(
@grid bigint,
@new bigint
)
AS
BEGIN
  set nocount on

  if(@grid is null)or(@new is null)or(@grid=@new) return -1

  declare @err int, @trans int
  select @err=0, @trans=@@trancount

  if(@trans=0) begin tran
    else save tran copygrp

  -- удаление стар. р.п.
  exec @err=dbo.wp_delgrp @new

  if(@err=0)
  begin
    -- копирование дисциплин
    insert tb_Workplan (grid,sbid,kid,sem,sbCode,
        wp1,wp2,totalhlp,totalahlp,compl,kp,kr,rg,cr,hr,koll,z,e)
      select @new,sbid,kid,sem,sbcode,
          wp1,wp2,totalhlp,totalahlp,compl,kp,kr,rg,cr,hr,koll,z,e
        from tb_Workplan where grid=@grid
    select @err=@@error

    if(@err=0)
    begin
      -- копирование нагрузок
      insert tb_Load (wpid,psem,type,tid,hours)
        select wn.wpid,l.psem,l.type,l.tid,l.hours
          from tb_Workplan w
            join tb_Load l on l.wpid=w.wpid
            join tb_Workplan wn on wn.sem=w.sem and wn.sbid=w.sbid
          where w.grid=@grid and wn.grid=@new
      select @err=@@error
    end
  end

  if(@err!=0)
  begin
    if(@trans=0) rollback tran
      else rollback tran copygrp
  end
  else if(@trans=0) commit tran

  return @err
END













GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


-- экспорт заявок кафедры (ynum,sem,psem,kid,type)
CREATE  PROCEDURE dbo.wp_exportdeclare
(
@ynum smallint,
@sem tinyint,
@psem tinyint,
@kid bigint,
@type tinyint
)
AS
BEGIN
  set nocount on

  if(@ynum is null)or(@sem is null)or(@psem is null)or(@kid is null)or(@type is null)
    return -1

  select
      l.strid,
      wp.sbCode,
      s.sbName,
      g.grName,
      g.studs,
      wp.TotalHLP,
      wp.TotalAHLP,
      wp.Compl,
      wp.WP1,
      (select isnull(sum(hours),0) from tb_Load where wpid=wp.wpid and type=1 and psem=1) as l1,  -- лекц. часы в 1п/с
      (select isnull(sum(hours),0) from tb_Load where wpid=wp.wpid and type<>1 and psem=1) as p1, -- практ. в 1п/с
      wp.WP2,
      (select isnull(sum(hours),0) from tb_Load where wpid=wp.wpid and type=1 and psem=2) as l2,  -- лекц. часы в 1п/с
      (select isnull(sum(hours),0) from tb_Load where wpid=wp.wpid and type<>1 and psem=2) as p2, -- практ. в 1п/с
      (select wp.WP1*isnull(sum(hours),0) from tb_Load where wpid=wp.wpid and type=2) as sumprak,
      (select wp.WP2*isnull(sum(hours),0) from tb_Load where wpid=wp.wpid and type=3) as sumlab,
      wp.Kp,
      wp.Kr,
      wp.Rg,
      wp.Cr,
      wp.Hr,
      wp.Koll,
      wp.Z,
      wp.E
    from tb_Workplan wp
      join tb_Subject s on wp.sbid=s.sbid
      join tb_Group g on wp.grid=g.grid
      left join tb_Load l on wp.wpid=l.wpid and l.type=@type and l.psem=@psem
    where g.ynum=@ynum and wp.sem=@sem and wp.kid=@kid
    order by strid desc, grName, sbName, sbCode, TotalHLP, TotalAHLP, Compl, WP1, l1, p1, WP2, l2,
      p2, sumprak, sumlab, Kp, Kr, Rg, Cr,Hr, Koll, Z, E
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


-- выбор заявок на кафедру (ynum,sem,kid)
CREATE  PROCEDURE dbo.wp_getdeclare
(
@ynum smallint,
@sem tinyint,
@kid bigint
)
AS
BEGIN
  set nocount on

  if(@ynum is null)or(@sem is null)or(@kid is null) return -1

  select 
      wp.sbCode, s.sbName, g.grName, wp.TotalHLP, wp.TotalAHLP, wp.Compl, wp.WP1,
      (select hours from tb_Load l where l.wpid=wp.wpid and type=1 and psem=1) as l1,  -- лекц. часы в 1п/с
      (select hours from tb_Load l where l.wpid=wp.wpid and type=2 and psem=1) as p1, -- практ. в 1п/с
      (select hours from tb_Load l where l.wpid=wp.wpid and type=3 and psem=1) as lb1, -- лаб. в 1п/с
      wp.WP2,
      (select hours from tb_Load l where l.wpid=wp.wpid and type=1 and psem=2) as l2,  -- лекц. в 2п/с
      (select hours from tb_Load l where l.wpid=wp.wpid and type=2 and psem=2) as p2, -- практ. в 2п/с
      (select hours from tb_Load l where l.wpid=wp.wpid and type=3 and psem=2) as lb2, -- лаб. в 2п/с
      Kp, Kr, Rg, Cr, Hr, Koll, Z, E
    from tb_Workplan wp
      left join tb_Subject s on wp.sbid=s.sbid
      left join tb_Group g on wp.grid=g.grid
    where g.ynum=@ynum and wp.sem=@sem and wp.kid=@kid
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

-- выбор раб. плана группы (sem,psem,grid)
CREATE    PROCEDURE dbo.wp_getgrp
(
@sem tinyint,
@psem tinyint,
@grid bigint
)
AS
BEGIN
  set nocount on

  if(@sem is null)or(@psem is null)or(@grid is null) return -1

  select w.wpid,w.grid,
      w.sbid,s.sbName,s.sbSmall,
      w.kid,k.kName,w.sem,w.e,
      l.lid,l.psem,l.type,l.hours,
      l.tid,t.Initials,p.pSmall,l.strid
    from tb_Workplan w
      left join tb_Load l on l.wpid=w.wpid and l.psem=@psem
      left join tb_Subject s on s.sbid=w.sbid
      left join tb_Kafedra k on k.kid=w.kid
      left join tb_Teacher t on t.tid=l.tid
      left join tb_Post p on p.pid=t.pid
    where w.sem=@sem and w.grid=@grid

/*
  select w.wpid,w.grid,w.sbid,w.sbCode,s.sbName,w.kid,k.kName,w.sem,
      w.totalhlp,w.totalahlp,w.compl,w.kp,w.kr,w.rg,w.cr,w.hr,w.koll,w.z,w.e,
      l.lid,l.psem,l.type,l.hours,l.tid,t.tName,l.strid
    from tb_Workplan w
      left join tb_Load l on l.wpid=w.wpid and l.psem=@psem
      left join tb_Subject s on s.sbid=w.sbid
      left join tb_Kafedra k on k.kid=w.kid
      left join tb_Teacher t on t.tid=l.tid
    where w.sem=@sem and w.grid=@grid
*/
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


-- выборка р.п. группы (sem, grid)
CREATE  PROCEDURE dbo.wp_getworkplan
(
@sem tinyint,
@grid bigint
)
AS
BEGIN
  set nocount on

  if(@sem is null)or(@grid is null) return -1

  select 
      wp.sbCode, s.sbName, wp.TotalHLP, wp.TotalAHLP, wp.Compl, wp.WP1,
      (select hours from tb_Load l where l.wpid=wp.wpid and type=1 and psem=1) as l1,  -- лекц. часы в 1п/с
      (select hours from tb_Load l where l.wpid=wp.wpid and type=2 and psem=1) as p1, -- практ. в 1п/с
      (select hours from tb_Load l where l.wpid=wp.wpid and type=3 and psem=1) as lb1, -- лаб. в 1п/с
      wp.WP2,
      (select hours from tb_Load l where l.wpid=wp.wpid and type=1 and psem=2) as l2,  -- лекц. в 2п/с
      (select hours from tb_Load l where l.wpid=wp.wpid and type=2 and psem=2) as p2, -- практ. в 2п/с
      (select hours from tb_Load l where l.wpid=wp.wpid and type=3 and psem=2) as lb2, -- лаб. в 2п/с
      Kp, Kr, Rg, Cr, Hr, Koll, Z, E, k.kName
    from tb_Workplan wp
      left join tb_Subject s on wp.sbid=s.sbid
      left join tb_Kafedra k on wp.kid=k.kid
    where wp.grid=@grid and wp.Sem=@sem
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


/*
  Удаление экзамена/конс-ции (wpid,xmtype)
  0  успех
  -1 вход. парам-ры заданы неправильно
  >0 server error (ошибка при удалении в tb_Exam)
*/
CREATE  PROCEDURE dbo.xm_delete
(
@wpid bigint,
@xmtype tinyint
)
AS
BEGIN
  set nocount on

  if(@wpid is null)or(@xmtype is null) return -1

  declare @err int, @trans int
  select @err=0, @trans=@@trancount

  if(@trans=0) begin tran

  delete tb_Exam where wpid=@wpid and xmtype=@xmtype
  set @err=@@error

  if(@trans=0)
    if(@err=0) commit tran
      else rollback tran

  return @err
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


/*
  Выбор занятости каф./общекаф. аудиторий в расписании экз/конс
  (экз/конс только одного факультета)
*/
CREATE  PROCEDURE dbo.xm_get_a
(
@ynum smallint,
@sem tinyint,
@fid int,
@kid bigint
)
AS
BEGIN
  set nocount on

  if(@ynum is null)or(@sem is null)or(@fid is null)
    return -1

  select 
      w.wpid,
      xm.xmtime,
      xm.xmtype,
      g.grName,
      s.sbName,
      s.sbSmall,
      a.aid,
      a.aName
    from tb_Exam xm
      join tb_Workplan w on w.wpid=xm.wpid
      join tb_Group g on g.grid=w.grid
      join tb_Kafedra k on k.kid=g.kid
      join tb_Auditory a on a.aid=xm.aid
      join tb_Subject s on s.sbid=w.sbid
    where g.ynum=@ynum and w.sem=@sem and k.fid=@fid
      and ((@kid is null and a.fid=@fid and a.kid is null) or a.kid=@kid)
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO



/*
  Выбор расписания экзаменов кафедры
*/
CREATE  PROCEDURE dbo.xm_get_k
(
@ynum smallint,
@sem tinyint,
@fid int,
@kid bigint
)
AS
BEGIN
  set nocount on

  if(@ynum is null)or(@sem is null)or(@kid is null)
    return -1

  select
      w.wpid,
      xm.xmtime,
      xm.xmtype,
      g.grName,
      t.tid,
      t.Initials,
      s.sbName,
      s.sbSmall,
      a.aName
    from tb_Exam xm
      join tb_Workplan w on w.wpid=xm.wpid
      join tb_Group g on g.grid=w.grid
      join tb_Kafedra k on k.kid=g.kid
      join tb_Subject s on s.sbid=w.sbid
      left join 
        (select distinct wpid,tid 
          from tb_Load 
          where type=1 and tid is not null) l
        on l.wpid=w.wpid
      left join tb_Teacher t on t.tid=l.tid
      left join tb_Auditory a on a.aid=xm.aid
    where g.ynum=@ynum and w.sem=@sem and k.fid=@fid and w.kid=@kid
END




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/*
  Выбор расписания экзаменов факультета (ynum,sem,fid)
*/
CREATE PROCEDURE dbo.xm_getfcl
(
@ynum smallint,
@sem tinyint,
@fid int,
@xmtype tinyint
)
AS
BEGIN
  set nocount on

  if(@ynum is null)or(@sem is null)or(@fid is null)or(@xmtype is null) return -1

  select
      xm.xmtime,
      g.grName,
      t.Initials,
      s.sbName,
      a.aName
    from tb_Exam xm
      join tb_Workplan w on w.wpid=xm.wpid
      join tb_Group g on g.grid=w.grid
      join tb_Kafedra k on k.kid=g.kid
      join tb_Subject s on s.sbid=w.sbid
      left join (select distinct wpid, tid from tb_Load where type=1 and tid is not null) l
        on l.wpid=w.wpid
      left join tb_Teacher t on t.tid=l.tid
      left join tb_Auditory a on a.aid=xm.aid
    where g.ynum=@ynum and w.sem=@sem and k.fid=@fid and xm.xmtype=@xmtype
END  


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/*
  Выбор свобод. аудиторий (fid,xmtime)
*/
CREATE PROCEDURE dbo.xm_getfreeaid_f
(
@fid int,
@xmtime datetime
)
AS
BEGIN
  set nocount on

  if(@fid is null)or(@xmtime is null) return -1

  select a.aid, a.aName
    from tb_Auditory a
    where fid=@fid and not exists(select * from tb_Exam where aid=a.aid and xmtime=@xmtime)
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/*
  Выбор свобод. аудитории кафедры-исполнителя (wpid,xmtime)
*/
CREATE PROCEDURE dbo.xm_getfreeaid_w
(
@wpid bigint,
@xmtime datetime
)
AS
BEGIN
  set nocount on

  if(@wpid is null)or(@xmtime is null) return -1

  declare @l_kid bigint
  select @l_kid=kid from tb_workplan where wpid=@wpid

  select a.aid, a.aName
    from tb_Auditory a
    where a.kid=@l_kid and
      not exists(select wpid from tb_Exam where aid=a.aid and xmtime=@xmtime)
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


/*
  Выбор расписания экз/конс (grid,sem)
*/
CREATE    PROCEDURE dbo.xm_getgrp
(
@grid bigint,
@sem tinyint
)
AS
BEGIN
  set nocount on

  if(@grid is null)or(@sem is null) return -1

  select
      xm.wpid,xm.xmtype,xm.xmtime,xm.hgrp,
      xm.aid,a.aName,
      s.sbName,s.sbSmall,
      p.pSmall,t.Initials
    from tb_Exam xm
      join tb_Workplan w on w.wpid=xm.wpid
      join tb_Subject s on s.sbid=w.sbid
      left join (select distinct wpid, tid from tb_Load where type=1 and tid is not null) l
        on l.wpid=w.wpid
      left join tb_Teacher t on t.tid=l.tid
      left join tb_Post p on p.pid=t.pid
      left join tb_Auditory a on a.aid=xm.aid
    where w.grid=@grid and w.sem=@sem
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO







/*
  Смена состава группы для экз (пол<->подгрп.)
  Прим: конс. всегда для пол. группы
  RETURN_VALUE:
    0  успех
    -1 вход. парам-ры заданы неправильно
    -2 экз не стоит
    -3 нельзя сменит состав
    >0 server error (ошибка при обновлении tb_Exam)
*/
CREATE         PROCEDURE dbo.xm_sethgrp
(
@wpid bigint,
@hgrp tinyint
)
AS
BEGIN
  set nocount on

  if(@wpid is null)or(@hgrp is null) return -1

  declare
    @l_time datetime,
    @err int

  set @err=0

  select @l_time=xmtime from tb_Exam where wpid=@wpid and xmtype=0

  if(@l_time is not null)
  begin
    if(dbo.uf_chktime_xm(@wpid,0,@l_time,@hgrp)=1)
    begin
      update tb_Exam set hgrp=@hgrp where wpid=@wpid and xmtype=0
      set @err=@@error
    end
    else set @err=-3
  end
  else set @err=-2

  return @err
END









GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS OFF 
GO


-- процедура импорта
-- импорт только раб. плана (аудит. нагрзки в prc_LoadMgm)
CREATE PROCEDURE dbo.prc_Import
(
@gkName varchar(150),	-- кафедра группы
@grName varchar(10),	-- назв. группы
@Studs smallint,		-- число студентов
@Course tinyint,		-- номер курса группы
@sbName varchar(100),	-- назв. дисциплины
@Sem tinyint,		-- семестр
@sbCode varchar(20),	-- индекс дисциплины
@WP1 tinyint,		-- недель в 1 п/с
@Lect1 tinyint,		-- лекции в 1 п/с
@Prct1 tinyint,		-- практики в 1 п/с
@Lab1 tinyint,		-- лабы в 1 п/с
@WP2 tinyint,		-- недель во 2 п/с
@Lect2 tinyint,		-- лекции во 2 п/с
@Prct2 tinyint,		-- практика во 2 п/с
@Lab2 tinyint,		-- лабы во 2 п/с
@TotalHLP int,		-- всего по уч. плану
@TotalAHLP int,	-- всего по уч. планку (ауд. наргузка)
@Compl int,		-- пройдено ранее
@Kp tinyint,		-- курс. проекты
@Kr tinyint,		-- курс. работы 
@Rg tinyint,		-- расчет. граф. работы
@Cr tinyint,		-- контр. работы
@Hr tinyint,		-- дом. работы
@Koll tinyint,		-- коллоквиумы
@Z tinyint,		-- зачет
@E tinyint,		-- экзамен
@lkName varchar(150)	-- назв. кафедры, чит. дисциплину
)
AS
begin
SET NOCOUNT ON
  -- лок. перем.
  declare
  @wpid bigint,	-- id р.п.
  @gkid bigint,	-- id кафедры группы
  @wkid bigint,	-- id кафедры, чит. дисциплину
  @grid bigint,	-- id группы
  @sbid bigint,	-- id предмета
  @res int	-- рез-т

  set @res=0

  -- добавление кафедр
  set @gkid=null
  set @wkid=null
  -- кафедра спец-ти
  select @gkid=kid from tb_Kafedra where kName=@gkName
  if @gkid is null
  begin
    insert tb_Kafedra (kName) values (@gkName)
    select @gkid=@@identity
    set @res=@res+2
  end
  -- каф-ра, чит. дисциплину
  select @wkid=kid from tb_Kafedra where kName=@lkName
  if @wkid is null
  begin
    insert tb_Kafedra (kName) values (@lkName)
    select @wkid=@@identity
    set @res=@res+4
  end

  -- добавление группы
  set @grid=null
  select @grid=grid from tb_Group where kid=@gkid and grName=@grName
  if @grid is null
  begin
    insert tb_Group (kid, grName, studs, course) values (@gkid, @grName, @Studs, @Course)
    select @grid=@@identity
    set @res=@res+16
  end

  -- добавление дисциплины
  set @sbid=null
  select @sbid=sbid from tb_Subject where sbName=@sbName
  if @sbid is null
  begin
    insert tb_Subject (sbName) values (@sbName)
    select @sbid=@@identity
    set @res=@res+32
  end

  -- доб-е/изм-ние р.п.
  set @wpid=null
  select @wpid=wpid from tb_Workplan
    where grid=@grid and sbid=@sbid and Sem=@Sem
  -- доб-ние
  if @wpid is null
  begin
    insert tb_Workplan (grid, sbid, kid, Sem, sbCode, WP1, WP2, TotalHLP, TotalAHLP, Compl, Kp, Kr, Rg, Cr, Hr, Koll, Z, E)
      values (@grid, @sbid, @wkid, @Sem, @sbCode, @WP1, @WP2, @TotalHLP, @TotalAHLP, @Compl, @Kp, @Kr, @Rg, @Cr, @Hr, @Koll, @Z, @E)
    select @wpid=@@identity
    if @@rowcount=1
      set @res=@res+64
  end
  -- изм-ние
  else
  begin
    update tb_Workplan set kid=@wkid, sbCode=@sbCode, WP1=@WP1, WP2=@WP2,
        TotalHLP=@TotalAHLP, Compl=@Compl, Kp=@Kp, Kr=@Kr, Rg=@Rg, Cr=@Cr, Hr=@Hr,
        Koll=@Koll, Z=@Z, E=@E
      where wpid=@wpid
  end

  -- импорт аудит. нагрузки
  if @wpid is not null
  begin
    exec dbo.prc_ImportLoad @wpid, @Lect1, @Prct1, @Lab1, 1
    exec dbo.prc_ImportLoad @wpid, @Lect2, @Prct2, @Lab2, 2
    set @res=@res+1
  end

  return @res
end


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


/*
  Импорт данных

  901  добавление факультета (fName, fid output)
  902  добавление кафедры (fid, kName, kid output)
  903  определение ID группы (grName)
  904  определение ID кафедры (kName)
  905  определение ID дисциплины (sbName)
  906  проверка данных учеб. года
  907  добавление группы (grName,kid,studs,course,ynum,grid out)
  908  добавление дисциплины в р.п.([all],wpid out)
  909  добавление ауд. нагрузки (wpid,psem,type,hours,lid out)
*/
CREATE  PROCEDURE dbo.prc_Import2
(
@case int,
@ynum smallint,
@fid int output,
@kid bigint output,
@grid bigint output,
@sbid bigint output,
@wpid bigint output,
@lid bigint output,
@fName varchar(80),
@kName varchar(150),
@grName varchar(10),
@sbName varchar(100),
@studs smallint,
@course tinyint,
@sem tinyint,
@sbCode varchar(20),
@WP1 tinyint,
@WP2 tinyint,
@TotalHLP int,
@TotalAHLP int,
@Compl int,
@Kp tinyint,
@Kr tinyint,
@Rg tinyint,
@Cr tinyint,
@Hr tinyint,
@Koll tinyint,
@z tinyint,
@e tinyint,
@psem tinyint,
@type tinyint,
@hours tinyint
)
AS
BEGIN
  set nocount on

  declare @err int

  -- добавление факультета (fName, fid output)
  if @case=901
  begin
    exec @err=dbo.fcl_create @fName, @fid output
    return @err
  end
  
  -- добавление кафедры (fid, kName)
  if @case=902
  begin
    exec @err=dbo.kaf_create @fid, @kName, @kid output
    return @err
  end

  -- определение ID группы (grName)
  if @case=903
  begin
    exec @err=dbo.grp_getid @grName, @grid output
    return @err
  end

  -- определение ID кафедры (kName)
  if @case=904
  begin
    exec @err=dbo.kaf_getid @kName, @kid output
    return @err
  end

  -- определение ID дисциплины (sbName)
  if @case=905
  begin
    exec @err=dbo.sbj_getid @sbName, @sbid output
    return @err
  end

  -- проверка данных учеб. года
  if @case=906
  begin
    if(@ynum is not null)
    begin
      set @err=dbo.chk_getpsem(@ynum)
      if(@err=4) set @err=0 else set @err=1
    end
    else set @err=-1
    return @err
  end

  -- добавление группы (grName,kid,studs,course,ynum,grid out)
  if @case=907
  begin
    exec @err=dbo.grp_create @grName,@kid,@studs,@course,@ynum,@grid out
    return @err
  end

  -- добавление дисциплины в р.п.([all],wpid out)
  if @case=908
  begin
    exec @err=dbo.wp_create2 @grid,@sem,@sbid,@kid,@sbCode,@WP1,@WP2,@TotalHLP,@TotalAHLP,
        @Compl,@Kp,@Kr,@Rg,@Cr,@Hr,@Koll,@z,@e,@wpid out
    return @err
  end

  --909  добавление ауд. нагрузки (wpid,psem,type,hours,lid out)
  if @case=909
  begin
    exec @err=dbo.ld_create @wpid,@psem,@type,@hours,@lid out
    return @err
  end

  return -100
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/*
  Управление преподавателями

  301  выбор преп-лей кафедры (kid)
  302  выбор преп-лей для нагрузки (lid)
  303  выбор преп-лей кафедры (список) (kid)
  304  выбор предпочтений преп-ля (tid)
*/
CREATE    PROCEDURE dbo.prc_TeachMgm
(
@case int,
@tid bigint,
@kid bigint,
@lid bigint
)
AS
BEGIN
set nocount on
declare @err int

-- выбор преп-лей кафедры (kid)
if @case=301
begin
  exec @err=dbo.thr_getkaf @kid
  return @err
end

-- выбор преп-лей для нагрузки (lid)
if @case=302
begin
  exec @err=dbo.thr_getload @lid
  return @err
end

-- выбор преп-лей кафедры (список) (kid)
if @case=303
begin
  exec @err=dbo.thr_getlist @kid
  return @err
end

-- выбор предпочтений преп-ля (tid)
if @case=304
begin
  exec @err=dbo.thr_getprefer @tid
  return @err
end

return -100
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO



/*
  Управление раб. планами

  1  просмотр р.п. группы (grid,sem)
  2  выбор заявок на кафедру (ynum,sem,kid)
  3  выбор заявок для указ. кафедры+дисциплина (sem, kid, sbid)
  4  выбор заявок на кафедру для экспорта (ynum,sem,psem,kid,type)
  5  выборка раб. плана группы (sem,psem,grid)
  10  добавление дисциплины в раб. план (grid,sem,sbid,kid,sem,e,wpid output)
  11  добавление нагрузки для дисциплины (wpid,psem,type,hours,lid output)
  12  копирование дисциплины р.п. (wpid output,sbid)
  13  удаление дисциплины из р.п. (wpid)
  14  удаление нагрузки (lid)
  15  копирование р.п. в другую группу (grid, kid=ngrid)
  16  извлечение кафедры-исполнителя (sem,grid,sbid)
*/
CREATE            PROCEDURE dbo.prc_WPMgm
(
@case int,
@ynum smallint,
@sem tinyint,
@psem tinyint,
@wpid bigint output,
@grid bigint,
@kid bigint,  -- kid (исп-ся и как ngrid для wp_copygrp)
@sbid bigint,
@e tinyint,
@lid bigint output,
@type tinyint,
@hours tinyint
)
AS
BEGIN
set nocount on
declare @err int

-- просмотр р.п. группы (sem, grid)
if @case=1
begin
  exec @err=dbo.wp_getworkplan @sem, @grid
  return @err
end

-- выбор заявок на кафедру (sem, kid)
if @case=2
begin
  exec @err=dbo.wp_getdeclare @ynum, @sem, @kid
  return @err
end

-- выбор заявок для указ. кафедры+дисциплина (sem, kid, sbid)
if @case=3
begin
  select
      wp.sbCode, s.sbName, g.grName, wp.TotalHLP, wp.TotalAHLP, wp.Compl, wp.WP1,
      (select hours from tb_Load l where l.wpid=wp.wpid and type=1 and psem=1) as l1,  -- лекц. часы в 1п/с
      (select hours from tb_Load l where l.wpid=wp.wpid and type=2 and psem=1) as p1, -- практ. в 1п/с
      (select hours from tb_Load l where l.wpid=wp.wpid and type=3 and psem=1) as lb1, -- лаб. в 1п/с
      wp.WP2,
      (select hours from tb_Load l where l.wpid=wp.wpid and type=1 and psem=2) as l2,  -- лекц. в 2п/с
      (select hours from tb_Load l where l.wpid=wp.wpid and type=2 and psem=2) as p2, -- практ. в 2п/с
      (select hours from tb_Load l where l.wpid=wp.wpid and type=3 and psem=2) as lb2, -- лаб. в 2п/с
      Kp, Kr, Rg, Cr, Hr, Koll, Z, E
    from tb_Workplan wp
      left join tb_Subject s on wp.sbid=s.sbid
      left join tb_Group g on wp.grid=g.grid
    where wp.Sem=@sem and wp.kid=@kid and wp.sbid=@sbid
  return
end

-- выбор заявок на кафедру для экспорта (ynum,sem,psem,kid,type)
if @case=4
begin
  exec @err=dbo.wp_exportdeclare @ynum, @sem, @psem, @kid, @type
  return @err
end

-- выборка раб. плана группы (sem,psem,grid)
if @case=5
begin
  exec @err=dbo.wp_getgrp @sem, @psem, @grid
  return @err
end

-- добавление дисциплины в раб. план (grid,sbid,kid,sem)
if @case=10
begin
  exec @err=dbo.wp_create @grid, @sem, @sbid, @kid, @e, @wpid output
  return @err
end

-- добавление нагрузки для дисциплины (wpid,psem,type,hours,lid output)
if @case=11
begin
  exec @err=dbo.ld_create @wpid, @psem, @type, @hours, @lid output
  return @err
end

-- копирование дисциплины р.п. (wpid output,sbid)
if @case=12
begin
  exec @err=dbo.wp_copy @wpid output, @sbid
  return @err
end

-- удаление дисциплины из р.п. (wpid)
if @case=13
begin
  exec @err=dbo.wp_delete @wpid
  return @err
end

-- удаление нагрузки (lid)
if @case=14
begin
  exec @err=dbo.ld_delete @lid
  return @err
end

-- копирование р.п. в другую группу (grid,xid)
if @case=15
begin
  exec @err=dbo.wp_copygrp @grid, @kid
  return @err
end

-- извлечение кафедры-исполнителя (sem,grid,sbid)
if @case=16
begin
  exec @err=dbo.wp_getkaf @sem, @grid, @sbid
  return @err
end
return -100
END










GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO



/*
  удаление занятия (lid,week,wday,npair)
  RETURN_VALUE:
    0  успех
    -1 вход. парам-ры заданы неправильно
    >0 server error (ошибка при удалинии из tb_Schedule)
*/
CREATE   PROCEDURE dbo.sdl_dellsns_g
(
@lid bigint,
@week tinyint,
@wday tinyint,
@npair tinyint
)
AS
BEGIN
  set nocount on

  if(@lid is null)or(@week is null)or(@wday is null)or(@npair is null) return -1

  declare @err int, @trans int
  select @err=0, @trans=@@trancount

  if(@trans=0) begin tran
    else save tran sdldellsnsg

  delete tb_Schedule
    where lid=@lid and [week]=@week and wday=@wday and npair=@npair
  select @err=@@error

  if(@err!=0)
  begin
    if(@trans=0) rollback tran
      else rollback tran sdldellsnsg
  end
  else if(@trans=0) commit tran

  return @err
END







GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/*
  удаление поток. занятия (strid, week, wday, npair)
  RETURN_VALUE:
    0  успех
    -1 вход. парам-ры заданы неправильно
    >0 server error (ошибка при удалении записей из tb_Schedule)
*/
CREATE    PROCEDURE dbo.sdl_dellsns_s
(
@strid bigint,
@week tinyint,
@wday tinyint,
@npair tinyint
)
AS
BEGIN
  set nocount on

  if(@strid is null)or(@week is null)or(@wday is null)or(@npair is null) return -1

  declare @err int, @trans int
  select @err=0, @trans=@@trancount

  if(@trans=0) begin tran
    else save tran sdldellsnss

  delete s
    from tb_Schedule s
      join tb_Load l on s.lid=l.lid
    where s.[week]=@week and s.wday=@wday and s.npair=@npair and l.strid=@strid
  select @err=@@error

  if(@err!=0)
  begin
    if(@trans=0) rollback tran
      else rollback tran sdldellsnss
  end
  else if(@trans=0) commit tran

  return @err
END





GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

-- выборка занятости аудиторий (ynum,sem,psem,aid)
CREATE PROCEDURE dbo.sdl_getlsns_a
(
@ynum smallint,
@sem tinyint,
@psem tinyint,
@aid bigint
)
AS
BEGIN
  set nocount on

  if (@ynum is null)or(@sem is null)or(@psem is null)or(@aid is null)
    return -1

  select
      sc.lid,
      l.strid,
      g.grid,
      g.grName,
      g.course,
      w.sbid,
      sb.sbName,
      sb.sbSmall,
      sc.aid,
      l.tid,
      t.Initials,
      dbo.uf_preftid(l.tid,sc.wday,sc.npair) as tprefer,
      sc.[week],
      sc.wday,
      sc.npair,
      sc.hgrp,
      l.type
    from  tb_Schedule sc
      join tb_Load l on l.lid=sc.lid
      join tb_Workplan w on w.wpid=l.wpid
      join tb_Group g on g.grid=w.grid
      left join tb_Subject sb on sb.sbid=w.sbid
      left join tb_Teacher t on t.tid=l.tid
    where g.ynum=@ynum and w.sem=@sem and l.psem=@psem and sc.aid=@aid
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


-- выбор расписания группы (sem,psem,grid)
CREATE  PROCEDURE dbo.sdl_getlsns_g
(
@sem tinyint,
@psem tinyint,
@grid bigint
)
AS
BEGIN
  set nocount on

  if(@sem is not null)and(@psem is not null)and(@grid is not null)
    select 
        sc.lid,
        l.strid,
        w.sbid,
        s.sbName,
        s.sbSmall,
        l.tid,
        p.pSmall,
        t.Initials,
        dbo.uf_preftid(l.tid,sc.wday,sc.npair) as tprefer,
        sc.aid,
        a.aName,
        dbo.uf_prefaid(sc.aid,sc.wday,sc.npair) as aprefer,
        sc.[week],
        sc.wday,
        sc.npair,
        sc.hgrp,
        l.type
      from tb_Schedule sc
        join tb_Load l on sc.lid=l.lid
        join tb_Workplan w on l.wpid=w.wpid
        join tb_Subject s on w.sbid=s.sbid
        left join tb_Auditory a on sc.aid=a.aid
        left join tb_Teacher t on l.tid=t.tid
        left join tb_Post p on p.pid=t.pid
      where w.sem=@sem and l.psem=@psem and w.grid=@grid
  else return -1
END








GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


-- выборка занятий для нагрузки (lid,[wday,npair])
-- если wday=null and npair=null выборка на все дни, иначе только для указ. пары
CREATE      PROCEDURE dbo.sdl_getlsns_l
(
@lid bigint,
@wday tinyint=null,
@npair tinyint=null
)
AS
BEGIN
  set nocount on

  if (@lid is not null)
    select
        w.grid,
        s.lid, l.strid,
        w.sbid, sb.sbName, sb.sbSmall,
        l.tid, p.pSmall, t.Initials, dbo.uf_preftid(l.tid,s.wday,s.npair) as tprefer,
        s.aid, a.aName, dbo.uf_prefaid(s.aid,s.wday,s.npair) as aprefer,
        s.[week],
        s.wday,
        s.npair,
        s.hgrp,
        l.type
      from tb_Schedule s
        join tb_Load l on l.lid=s.lid
        join tb_Workplan w on w.wpid=l.wpid
        join tb_Subject sb on sb.sbid=w.sbid
        left join tb_Teacher t on t.tid=l.tid
        left join tb_Post p on p.pid=t.pid
        left join tb_Auditory a on a.aid=s.aid
      where s.lid=@lid
        and ((((@wday is not null)and(@npair is not null))and(s.wday=@wday and s.npair=@npair))
        or (@wday is null and @npair is null))
  else return -1
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

-- выборка поточ. занятия (strid,[wday,npair])
-- если wday=null and npair=null - выборка всех занятий, иначе только для указан. пары
CREATE  PROCEDURE dbo.sdl_getlsns_s
(
@strid bigint,
@wday tinyint,
@npair tinyint
)
AS
BEGIN
  set nocount on

  if(@strid is not null)
    select 
        w.grid,
        s.lid, l.strid,
        w.sbid, sb.sbName, sb.sbSmall,
        l.tid, p.pSmall, t.Initials, dbo.uf_preftid(l.tid,s.wday,s.npair) as tprefer,
        s.aid, a.aName, dbo.uf_prefaid(s.aid,s.wday,s.npair) as aprefer,
        s.[week],
        s.wday,
        s.npair,
        s.hgrp,
        l.type
      from tb_Schedule s
        join tb_Load l on l.lid=s.lid
        join tb_Workplan w on w.wpid=l.wpid
        join tb_Subject sb on sb.sbid=w.sbid
        left join tb_Teacher t on t.tid=l.tid
        left join tb_Post p on p.pid=t.pid
        left join tb_Auditory a on a.aid=s.aid
      where l.strid=@strid
        and (((@wday is not null) and (@npair is not null)) and (s.wday=@wday and s.npair=@npair)
        or (@wday is null and @npair is null))
  else return -1
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

-- выбор расписания преподавателя (ynum,sem,psem,tid)
CREATE PROCEDURE dbo.sdl_getlsns_t
(
@ynum smallint,
@sem tinyint,
@psem tinyint,
@tid bigint
)
AS
BEGIN
  set nocount on

  if(@ynum is null)or(@sem is null)or(@psem is null)or(@tid is null)
    return -1

  select 
      sc.lid,
      l.strid,
      g.grid,
      g.grName,
      g.course,
      w.sbid,
      s.sbName,
      s.sbSmall,
      sc.aid,
      a.aName,
      dbo.uf_prefaid(sc.aid,sc.wday,sc.npair) as aprefer,
      sc.[week],
      sc.wday,
      sc.npair,
      sc.hgrp,
      l.type
    from tb_Schedule sc
      join tb_Load l on l.lid=sc.lid
      join tb_Workplan w on w.wpid=l.wpid
      join tb_Group g on g.grid=w.grid
      left join tb_Subject s on s.sbid=w.sbid
      left join tb_Auditory a on a.aid=sc.aid
    where g.ynum=@ynum and w.sem=@sem and l.psem=@psem
      and l.tid=@tid
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/*
  создание потока (lid,strid output)
  RETURN_VALUE
    0  успех
    -1 вход. парам-ры заданы неправильно
    -2 нагрузка уже включена в поток
    -3 ошибка при добавлении в tb_Stream
    -4 ошибка при обновлении tb_Load
*/
CREATE PROCEDURE dbo.stm_create
(
@lid bigint,
@strid bigint output
)
AS
BEGIN
  set nocount on

  if(@lid is null) return -1

  declare @err int, @trans int

  set @err=0
  set @trans=@@trancount
  set @strid=null

  if(@trans=0) begin tran
    else save tran stmcreate

  if exists(select lid from tb_Load where lid=@lid and strid is null)
  begin
    -- создание нов. потока
    insert into tb_Stream (ynum,sem,psem,type,hours,kid,tid)
      select ynum,sem,psem,type,hours,kid,tid from vw_Workplan where lid=@lid
    select @strid=@@identity, @err=@@error
  
    -- добавление группы в вновь создан. поток
    if (@strid is not null) and (@err=0)
    begin
      update tb_Load set strid=@strid where lid=@lid
      select @err=@@error
      if(@err!=0) set @err=-4
    end
    else set @err=-3

  end
  else set @err=-2

  if(@err!=0)
  begin
    if(@trans=0) rollback tran
      else rollback tran stmcreate
    set @strid=null
  end
  else if(@trans=0) commit tran

  return @err
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO







/*
  Добавление экз./конс. (wpid,xmtype,xmstart,xmend,hgrp,aid)
  RETURN_VALUE:
    0  успех
    -1 вход. парам-ры заданы неправильно
    -2 экз/конс. уже стоит
    -3 преп-ль занят
    -4 нарушена очередность
    -5 аудитория занята
    -6 неправильное время экз/конс (см. uf_chktime_xm)
    >0 server error (ошибка при вставке в tb_Exam)
*/
CREATE       PROCEDURE dbo.xm_create
(
@wpid bigint,
@xmtype bigint,
@xmtime datetime,
@hgrp tinyint,
@aid bigint
)
AS
BEGIN
  set nocount on

  if(@wpid is null)or(@xmtype is null)or(@xmtime is null)or(@hgrp is null) return -1

  declare @err int, @trans int
  set @err=0

  if not exists(select wpid from tb_Exam where wpid=@wpid and xmtype=@xmtype)
  begin
    -- проверка занятости препод-лей
    if(dbo.uf_freetid_xm(@wpid,@xmtime)=0) set @err=-3

    -- проверка экзамен после конс-ции (-4)
    if(@err=0)
      if(dbo.uf_chkorder_xm(@wpid,@xmtype,@xmtime)=0) set @err=-4

    -- проверка занятостм аудитории (-5)
    if(@err=0)
      if(dbo.uf_freeaid_xm(@aid,@xmtime)=0) set @err=-5

    -- проверка времени экз/конс (-6)
    if(@err=0)
      if(dbo.uf_chktime_xm(@wpid,@xmtype,@xmtime,@hgrp)=0) set @err=-6

    if(@err=0)
    begin
      set @trans=@@trancount
      if(@trans=0) begin tran

      insert tb_Exam (wpid,xmtype,xmtime,hgrp,aid)
        values (@wpid,@xmtype,@xmtime,@hgrp,@aid)
      set @err=@@error

      if(@trans=0)
        if(@err=0) commit tran
          else rollback tran
    end
  end
  else set @err=-2

  return @err
END








GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO






/*
  Выбор возмож. для группы экз/конс в указ. время (grid,sem,xmtype,xmtime)
*/
CREATE      PROCEDURE xm_getavail_grp
(
@grid bigint,
@sem tinyint,
@xmtype tinyint,
@xmtime datetime
)
AS
BEGIN
  set nocount on

  if(@grid is null)or(@sem is null)or(@xmtype is null)or(@xmtime is null) return -1

  select
    w.wpid,
    s.sbName, s.sbSmall,
    ll.psmall, ll.initials,

    dbo.uf_existsxm(w.wpid,@xmtype) as [exists],
    dbo.uf_freetid_xm(w.wpid,@xmtime) as [tfree],
    dbo.uf_chkorder_xm(w.wpid,@xmtype,@xmtime) as [order],
    dbo.uf_chktime_xm(w.wpid,@xmtype,@xmtime,0) as [full],
    dbo.uf_chktime_xm(w.wpid,@xmtype,@xmtime,1) as [half]

  from tb_Workplan w
    join tb_Subject s on s.sbid=w.sbid
    left join 
      (select distinct l.wpid, t.Initials, p.psmall
          from tb_Load l
            join tb_Teacher t on t.tid=l.tid
            join tb_Post p on p.pid=t.pid
          where l.type=1) ll
      on ll.wpid=w.wpid
  where w.grid=@grid and w.sem=@sem and w.e>0
END






GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO







/*
  Выбор для wpid возмож. экз/конс в указ. время (wpid,xmtype,xmtime)
*/
CREATE       PROCEDURE dbo.xm_getavail_wp
(
@wpid bigint,
@xmtype tinyint,
@xmtime datetime
)
AS
BEGIN
  set nocount on

  if(@wpid is null)or(@xmtype is null)or(@xmtime is null) return -1

  select
    w.wpid,
    s.sbName, s.sbSmall,
    ll.pSmall,ll.Initials,
  
    dbo.uf_existsxm(w.wpid,@xmtype) as [exists],
    dbo.uf_freetid_xm(w.wpid,@xmtime) as [tfree],
    dbo.uf_chkorder_xm(w.wpid,@xmtype,@xmtime) as [order],
    dbo.uf_chktime_xm(w.wpid,@xmtype,@xmtime,0) as [full],
    dbo.uf_chktime_xm(w.wpid,@xmtype,@xmtime,1) as [half]
    
  from tb_Workplan w
    join tb_Subject s on s.sbid=w.sbid
    left join 
      (select distinct l.wpid, p.pSmall, t.Initials
        from tb_Load l
          join tb_Teacher t on t.tid=l.tid
          join tb_Post p on p.pid=t.pid
        where type=1) ll on ll.wpid=w.wpid
  where w.wpid=@wpid and w.e>0
END







GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO



/*
  Смена аудитории экз/конс (wpid,xmtype,aid)
  RETURN_VALUE:
    0  успех
    -1 вход. парам-ры заданы неправильно
    -2 экз/конс. не стоит
    -3 аудитоия занята
    >0 server error (ошибка при обновлении tb_Exam)
*/
CREATE     PROCEDURE dbo.xm_setadr
(
@wpid bigint,
@xmtype tinyint,
@aid bigint
)
AS
BEGIN
  set nocount on

  if(@wpid is null) or (@xmtype is null) return -1

  declare
    @l_time datetime,
    @err int
  set @err=0

  select @l_time=xmtime from tb_Exam where wpid=@wpid and xmtype=@xmtype

  if(@l_time is not null)
  begin
    if(dbo.uf_freeaid_xm(@aid,@l_time)=1)
    begin
      update tb_Exam set aid=@aid where wpid=@wpid and xmtype=@xmtype
      set @err=@@error
    end
    else set @err=-3
  end
  else set @err=-2

  return @err
END



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO







/*
  Смена времени конс/экз (wpid,xmstart,xmend)
  RETURN_VALUE:
    0  успех
    -1 вход. парам-ры заданы неправильно
    -2 конс/экз не стоит
    -3 нарушение очередности конс-экз
    -4 нарушение времен. правил
    -5 занята аудитория
    -6 занят(ы) препод-ль(и)
    >0 server error (ошибка обновления tb_Exam)
*/
CREATE          PROCEDURE dbo.xm_settime
(
@wpid bigint,
@xmtype tinyint,
@xmtime datetime
)
AS
BEGIN
  set nocount on

  if(@wpid is null)or(@xmtype is null)or(@xmtime is null) return -1

  declare
    @l_hgrp tinyint,
    @l_aid bigint,
    @err int

  set @err=0

  select @l_hgrp=hgrp, @l_aid=aid
    from tb_Exam where wpid=@wpid and xmtype=@xmtype

  if(@l_hgrp is not null)
  begin
    -- проверка очередности конс/экз
    if(dbo.uf_chkorder_xm(@wpid,@xmtype,@xmtime)=0) set @err=-3

    -- проверка времени
    if(@err=0)
      if(dbo.uf_chktime_xm(@wpid,@xmtype,@xmtime,@l_hgrp)=0) set @err=-4

    -- проверка занятости ауд-рии в нов. время
    if(@err=0)
      if(dbo.uf_freeaid_xm(@l_aid, @xmtime)=0) set @err=-5

    -- проверка занятости преп-ля(ей)
    if(@err=0)
      if(dbo.uf_freetid_xm(@wpid,@xmtime)=0) set @err=-6

    if(@err=0)
    begin
      update tb_Exam set xmtime=@xmtime where wpid=@wpid and xmtype=@xmtype
      set @err=@@error
    end
  end
  else set @err=-2

  return @err
END







GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


/*
  Упр-ние экз/конс

  1101 выбор расписания экз/конс группы (grid,sem)
  1102 добавление экз/конс
  1103 удаление экз/конс
  1104 уст-ка ауд-рии (wpid,xmtype,aid)
  1105 смена состава группы (wpid, hgrp)
  1106 смена времени проведения экз/конс (wpid,xmtype,xmtime)
  1107 извлечение периодов экз. сессии (ynum)
  1108 выбор свобод. ауд-рий ф-та (fid,xmtime)
  1109 выбор свобод. ауд-рий каф-исп (wpid,xmtime)
  1110 выбор возмож. экз/конс для дисциплины (wpid,xmtype,xmtime)
  1111 выбор возмож. экз/конс для группы (grid,sem,xmtype,xmtime)
  1112 выбор расписания экз/конс факультета (ynum,sem,fid,xmtype)
  1113 выбор расписания экз/конс кафедры (ynum,sem,fid,kid)
  1114 выбор кафедр-исполнителей экзаменов (ynum,sem,fid)
  1115 выбор занятости аудиторий (ynum,sem,fid,[kid])

*/
CREATE  PROCEDURE dbo.prc_ExamMgm
(
@case int,
@ynum smallint,
@sem tinyint,
@fid int,
@kid bigint,
@grid bigint,
@wpid bigint,
@xmtype tinyint,
@start datetime,
@end datetime,
@hgrp tinyint,
@aid bigint
)
AS
BEGIN
set nocount on
declare @err int

-- выбор расписания экз/конс группы (grid,sem)
if @case=1101
begin
  exec @err=dbo.xm_getgrp @grid,@sem
  return @err
end

-- добавление экз/конс
if @case=1102
begin
  exec @err=dbo.xm_create @wpid,@xmtype,@start,@hgrp,@aid
  return @err
end

-- удаление экз/конс
if @case=1103
begin
  exec @err=dbo.xm_delete @wpid, @xmtype
  return @err
end

-- уст-ка ауд-рии (wpid,xmtype,aid)
if @case=1104
begin
  exec @err=dbo.xm_setadr @wpid, @xmtype, @aid
  return @err
end

-- смена состава группы (wpid, hgrp)
if @case=1105
begin
  exec @err=dbo.xm_sethgrp @wpid, @hgrp
  return @err
end

-- смена времени проведения экз/конс (wpid,xmtype,xmstart,xmend)
if @case=1106
begin
  exec @err=dbo.xm_settime @wpid,@xmtype,@start
  return @err
end

-- извлечение периода экз. сессии (ynum,sem,start out,end out)
if @case=1107
begin
  exec @err=dbo.prd_get_t @ynum, 3
  return @err
end

-- выбор свобод. ауд-рий ф-та (fid,xmtime)
if @case=1108
begin
  exec @err=dbo.xm_getfreeaid_f @fid, @start
  return @err
end

-- выбор свобод. ауд-рий каф-исп (wpid,xmtime)
if @case=1109
begin
  exec @err=dbo.xm_getfreeaid_w @wpid, @start
  return @err
end

-- выбор возмож. экз/конс для дисциплины (wpid,xmtype,xmtime)
if @case=1110
begin
  exec @err=dbo.xm_getavail_wp @wpid,@xmtype,@start
  return @err
end

-- выбор возмож. экз/конс для группы (grid,sem,xmtype,xmtime)
if @case=1111
begin
  exec @err=dbo.xm_getavail_grp @grid,@sem,@xmtype,@start
  return @err
end

-- выбор расписания экз/конс факультета (ynum,sem,fid,xmtype)
if @case=1112
begin
  exec @err=dbo.xm_getfcl @ynum,@sem,@fid,@xmtype
  return @err
end

-- выбор расписания экз/конс кафедры (ynum,sem,fid,kid)
if @case=1113
begin
  exec @err=dbo.xm_get_k @ynum,@sem,@fid,@kid
  return @err
end

-- выбор кафедр-исполнителей экзаменов (ynum,sem,fid)
if @case=1114
begin
  exec @err=dbo.xm_getkaf_f @ynum,@sem,@fid
  return @err
end

--  выбор занятости аудиторий (ynum,sem,fid,[kid])
if @case=1115
begin
  exec @err=dbo.xm_get_a @ynum,@sem,@fid,@kid
  return @err
end

return -100
END
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO


/*
  Управление потоками

  201  выбор потоков кафедры по дисциплине (ynum,sem,psem,type,kid,sbid)
  202  создание потока (lid)
  203  удаление потока (strid)
  204  добавление группы в поток (strid, lid)
  205  удаление группы из потока (lid)
  206  выбор свобод. заявок для потока (strid), не входящ. в указ. поток
  207  выбор свобод. заявок (ynum,sem,psem,type,kid,sbid)
  208  выборка заявок на дисциплину+дисциплины объед. через потоки (ynum,sem,psem,type,kid,sbid)
  209 установка лектора для потока (strid, [tid])
*/
CREATE     PROCEDURE dbo.prc_StrmMgm
(
@case tinyint,
@ynum smallint,
@sem tinyint,
@psem tinyint,
@type tinyint,
@kid bigint,
@sbid bigint,
@strid bigint output,
@lid bigint,
@tid bigint
)
AS
BEGIN
set nocount on
declare @err int

-- выбор потоков кафедры по дисциплине (ynum,sem,psem,type,kid,sbid)
if @case=201
begin
  exec @err=dbo.stm_get_ks @ynum, @sem, @psem, @type, @kid, @sbid
  return @err
end

-- создание потока (lid)
if @case=202
begin
  exec @err=dbo.stm_create @lid, @strid output
  return @err
end

-- удаление потока (strid)
if @case=203
begin
  exec @err=dbo.stm_delete @strid
  return @err
end

-- добавление группы в поток (strid, lid)
if @case=204
begin
  exec @err=dbo.stm_addgrp @strid, @lid
  return @err
end

-- удаление группы из потока (lid)
if @case=205
begin
  exec @err=dbo.stm_delgrp @lid
  return @err
end

-- выбор свобод. заявок для потока (strid)
if @case=206
begin
  exec @err=dbo.stm_getfree_s @strid
  return @err
end

-- выбор свобод. заявок (ynum,sem,psem,type,kid,sbid)
if @case=207
begin
  exec @err=dbo.stm_getfree_d @ynum, @sem, @psem, @type, @kid, @sbid
  return @err
end

-- выбор заявок на дисциплину
-- + дисциплины, объед. через потоки (ynum,sem,psem,type,kid,sbid)
if @case=208
begin
  exec @err=dbo.stm_getdeclare @ynum, @sem, @psem, @type, @kid, @sbid
  return @err
end

-- установка лектора для потока (strid, [tid])
if @case=209
begin
  exec @err=dbo.stm_setthr @strid, @tid
  return @err
end

return -100
END



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

-- выбор возмож. занятий в п/сем - контроль исп-ния р.п. (sem,psem,grid)
CREATE PROCEDURE dbo.sdl_getavail_psem
(
@sem tinyint,
@psem tinyint,
@grid bigint
)
AS
BEGIN
  set nocount on

  if(@sem is null)or(@psem is null)or(@grid is null)
    return -1

  select
      w.wpid,
      sb.sbName,
      l.lid,
      l.type,
      l.hours,
      dbo.uf_getavail(l.lid) as ahours
    from tb_Group g
      join tb_Workplan w on w.grid=g.grid
      join tb_Load l on l.wpid=w.wpid
      join tb_Subject sb on sb.sbid=w.sbid
    where g.grid=@grid and w.sem=@sem and l.psem=@psem
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO



-- выбор свобод. преп-лей (lid,week,wday,npair)
-- ynum, sem, psem, kid определяются от lid
CREATE PROCEDURE dbo.sdl_getfreethr_l
(
@lid bigint,
@week tinyint,
@wday tinyint,
@npair tinyint
)
AS
BEGIN
  set nocount on

  if(@lid is null)or(@week is null)or(@wday is null)or(@npair is null)
    return -1

  declare
    @l_ynum smallint,
    @l_sem tinyint,
    @l_psem tinyint,
    @l_kid tinyint

  -- выборка ynum,sem,psem,kid
  select @l_ynum=ynum,@l_sem=sem,@l_psem=psem,@l_kid=kid
    from vw_Workplan
    where lid=@lid

  if(@l_ynum is null)or(@l_sem is null)or(@l_psem is null)or(@l_kid is null)
    return -2
  
  -- выборка свобод. преп-лей
  select 
      t.tid,
      p.psmall,
      t.initials,
      dbo.uf_preftid(t.tid,@wday,@npair) as tprefer
    from tb_Teacher t
      left join tb_Post p on p.pid=t.pid
    where t.kid=@l_kid
      and not exists
      (
        select lid
          from vw_Schedule
          where ynum=@l_ynum and sem=@l_sem and psem=@l_psem
            and tid=t.tid
            and wday=@wday and npair=@npair and lid<>@lid
            --and (s.week=@week or s.week=0))  -- лог. ошибка
            and ((@week=0)or((@week<>0)and([week] in (0,@week))))
      )
END





GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO



-- выборка загрузки аудитории в расписании (ynum,sem,psem,aid)
CREATE   PROCEDURE dbo.sdl_getload_a
(
@ynum smallint,
@sem tinyint,
@psem tinyint,
@aid bigint
)
AS
BEGIN
  set nocount on
  if(@ynum is null)or(@sem is null)or(@psem is null)or(@aid is null)
    return -1
  select a.aid,a.aname,a.kid,k.kname,
      sum(
        case 
          when s.[week]=0 then 2 
          when s.[week] in (1,2) then 1
          else 0
        end)as hours
    from tb_auditory a
      left join
        (select distinct week,wday,npair,aid
          from vw_schedule
          where ynum=@ynum and sem=@sem and psem=@psem) s on s.aid=a.aid
      left join tb_kafedra k on k.kid=a.kid
    where a.aid=@aid
    group by a.aid,a.aname,a.kid,k.kname
END



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


-- выбор свобод. аудиторий (вместимость) (fid,lid,week,wday,npair)
-- ynum, sem, psem, mans определяются от lid
CREATE    PROCEDURE dbo.sdl_getfreeadr_l
(
@fid int,
@lid bigint,
@week tinyint,
@wday tinyint,
@npair tinyint
)
AS
BEGIN
  set nocount on

  if(@fid is null)or(@lid is null)or(@week is null)
    or(@wday is null)or(@npair is null)
    return -1

  declare
    @l_ynum smallint,
    @l_sem tinyint,
    @l_psem tinyint,
    @l_strid bigint,
    @l_hgrp tinyint,
    @mans smallint

  -- опр-ние ynum, sem, psem, strid, hgrp
  select @l_ynum=g.ynum,@l_sem=w.sem,@l_psem=l.psem,@l_strid=l.strid,@l_hgrp=s.hgrp
    from tb_Load l
      join tb_Workplan w on w.wpid=l.wpid
      join tb_Group g on g.grid=w.grid
      left join tb_Schedule s on s.lid=l.lid and s.[week]=@week and s.wday=@wday and s.npair=@npair
    where l.lid=@lid

  -- опр-ние кол-ва студентов
  if @l_hgrp=1
    set @mans=1
  else
    select @mans=sum(studs)
      from tb_Load l
        join tb_Workplan w on w.wpid=l.wpid
        join tb_Group g on g.grid=w.grid
      where l.strid=@l_strid or l.lid=@lid

  -- выбор свобод. аудиторий
  select aid, aName, dbo.uf_prefaid(aid,@wday,@npair) AS aprefer
    from tb_Auditory a
    where a.capacity>=@mans and a.fid=@fid
      and dbo.uf_freeaid(@l_ynum,@l_sem,@l_psem,@week,@wday,@npair,a.aid)=1
END
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

-- выбор свободных аудиторий кафедры-исполнителя (+вместимость) (lid,week,wday,npair)
-- ynum, sem, psem, mans, kid определяются от lid
CREATE PROCEDURE dbo.sdl_getfreeadr_lk
(
@lid bigint,
@week tinyint,
@wday tinyint,
@npair tinyint
)
AS
BEGIN
  set nocount on

  declare
    @l_ynum smallint,
    @l_sem tinyint,
    @l_psem tinyint,
    @l_kid bigint,
    @l_strid bigint,
    @l_hgrp tinyint,
    @mans smallint

  -- опр-ние ynum, sem, psem, strid, hgrp, kid
  select @l_ynum=g.ynum,@l_sem=w.sem,@l_kid=w.kid,@l_psem=l.psem,
      @l_strid=l.strid,@l_hgrp=s.hgrp
    from tb_Load l
      join tb_Workplan w on w.wpid=l.wpid
      join tb_Group g on g.grid=w.grid
      left join tb_Schedule s on s.lid=l.lid and s.[week]=@week and 
        s.wday=@wday and s.npair=@npair
    where l.lid=@lid

  -- опр-ние кол-ва студентов
  if(@l_hgrp=1) set @mans=1
    else
      select @mans=sum(studs)
        from tb_Load l
          join tb_Workplan w on w.wpid=l.wpid
          join tb_Group g on g.grid=w.grid
        where l.strid=@l_strid or l.lid=@lid

  -- выбор свобод. аудиторий
  select aid, aName, dbo.uf_prefaid(aid,@wday,@npair) AS aprefer
    from tb_Auditory a
    where a.capacity>=@mans and a.kid=@l_kid
      and dbo.uf_freeaid(@l_ynum,@l_sem,@l_psem,@week,@wday,@npair,a.aid)=1
END
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO





/*
  уст-ка занятия (lid,week,wday,npair,hgrp,aid)
  RETURN_VALUE:
    0  занятие добавлено (нет ошибок)
    -1 параметры заданы неправильно
    -2 занятие уже стоит на паре
    -3 преп-ль занят
    -4 аудитория занята
    -5 нет мест в аудитории
    -6 превышена норма нагрузки
    -7 нельзя поставить занятие на пару (см. uf_chklsns_g)
    -8 ошибка при добавлении записи
    -9 не определены все аттрибуты от lid
*/
CREATE     PROCEDURE dbo.sdl_newlsns_g
(
@lid bigint,
@week tinyint,
@wday tinyint,
@npair tinyint,
@hgrp tinyint,
@aid bigint
)
AS
BEGIN
  set nocount on

  -- проверка вход. параметров
  if(@lid is null)or(@week is null)or(@wday is null)or(@npair is null)or(@hgrp is null)
    return -1

  declare
    @l_ynum smallint,
    @l_sem tinyint,
    @l_psem tinyint,
    @l_grid bigint,
    @l_tid bigint,
    @err int,
    @trans int

  select @err=0, @trans=@@trancount

  if(@trans=0) begin tran
    else save tran sdlnewlsnsg

  -- если занятие не стоит
  if not exists
  (
    select lid from tb_Schedule
      where lid=@lid and [week]=@week and wday=@wday and npair=@npair
  )
  begin
    -- опр-ние ynum,sem,psem,grid от lid
    select @l_ynum=ynum, @l_sem=sem, @l_psem=psem, @l_grid=grid, @l_tid=tid
      from vw_Workplan
      where lid=@lid

    if(@l_ynum is not null) and (@l_sem is not null) and (@l_psem is not null)
      and (@l_grid is not null)
    begin
      -- проверка занятости преп-ля
      if(dbo.uf_freetid(@l_ynum,@l_sem,@l_psem,@week,@wday,@npair,@l_tid)!=1) set @err=-3 

      -- проверка занятости аудитории
      if(@err=0)
        if(dbo.uf_freeaid(@l_ynum,@l_sem,@l_psem,@week,@wday,@npair,@aid)!=1) set @err=-4

      -- проверка вместимости аудитории
      if(@err=0)
        if(dbo.uf_chkcap_g(@l_grid,@aid,@hgrp)!=1) set @err=-5

      -- проверка на превышение нормы нагрузки (х2 - на две недели)
      if(@err=0)
        if(dbo.uf_chkhours_l(@lid,@week,@hgrp)!=1) set @err=-6

      -- проверка возвможности поставить занятие на паре
      if(@err=0)
        if(dbo.uf_chklsns_g(@l_sem,@l_psem,@week,@wday,@npair,@hgrp,@l_grid)!=1) set @err=-7

      -- добавление занятия
      if(@err=0)
      begin
        insert tb_Schedule (lid,[week],wday,npair,hgrp,aid)
          values(@lid,@week,@wday,@npair,@hgrp,@aid)
        select @err=@@error
        if(@err!=0) set @err=-8
      end

    end
    else set @err=-9
  end
  else set @err=-2

  if(@err!=0)
  begin
    if(@trans=0) rollback tran
      else rollback tran sdlnewlsnsg
  end
  else if(@trans=0) commit tran

  return @err
END















GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/*
  изм-ние аудитории занятия (lid,week,wday,npair,aid)
  RETURN_VALUE:
    0  изменение успешно (нет ошибок)
    -1 вход. параметры заданы неправильно
    -2 аттрибуты для lid не определены
    -3 аудитория занята
    -4 вместимость аудитории
    -5 ошибка при обновлении занятия
*/
CREATE PROCEDURE dbo.sdl_setadr_l
(
@lid bigint,
@week tinyint,
@wday tinyint,
@npair tinyint,
@aid bigint
)
AS
BEGIN
  set nocount on

  if(@lid is null)or(@week is null)or(@wday is null)or(@npair is null) return -1

  declare
    @l_ynum smallint,
    @l_sem tinyint,
    @l_psem tinyint,
    @l_grid bigint,
    @l_hgrp tinyint,
    @err int,
    @trans int

  select @err=0, @trans=@@trancount

  if(@trans=0) begin tran
    else save tran sdlsetadrl

  -- опр-ние ynum,sem,psem,grid,hgrp
  select @l_ynum=ynum,@l_sem=sem,@l_psem=psem,@l_grid=grid,@l_hgrp=hgrp
    from vw_Schedule
    where lid=@lid and [week]=@week and wday=@wday and npair=@npair

  -- если занятие существует (найдены все ynum,sem,psem,grid,hgrp)
  if (@l_ynum is not null)and(@l_sem is not null) and (@l_psem is not null)
      and (@l_grid is not null) and (@l_hgrp is not null)
  begin

    -- проверка занятости аудитории
    if(dbo.uf_freeaid(@l_ynum,@l_sem,@l_psem,@week,@wday,@npair,@aid)!=1) set @err=-3

    -- проверка вместимости аудитории
    if(@err=0)
      if(dbo.uf_chkcap_g(@l_grid,@aid,@l_hgrp)!=1) set @err=-4

    -- обновление занятия
    if(@err=0)
    begin
      update tb_Schedule set aid=@aid
        where lid=@lid and [week]=@week and wday=@wday and npair=@npair
      set @err=@@error
      if(@err!=0) set @err=-5
    end

  end else set @err=-2

  if(@err!=0)
  begin
    if(@trans=0) rollback tran
      else rollback tran sdlsetadrl
  end
  else if(@trans=0) commit tran

  return @err
END








GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/*
  уст-ка аудитории для поток. занятия (strid,week,wday,npair,aid)
  RETURN_VALUE:
    0  изм-ние успешно (нет ошибок)
    -1 вход. параметры заданы неправильно
    -2 аттрибуты потока не определены
    -3 аудитория занята
    -4 вместимость аудитории
    -5 ошибка при обновлении записи (@@rowcount>0)
    >0 server error
*/
CREATE PROCEDURE dbo.sdl_setadr_s
(
@strid bigint,
@week tinyint,
@wday tinyint,
@npair tinyint,
@aid bigint
)
AS
BEGIN
  set nocount on

  if(@strid is null)or(@week is null)or(@wday is null)or(@npair is null) return -1

  declare
    @l_ynum smallint,
    @l_sem tinyint,
    @l_psem tinyint,
    @l_hgrp tinyint,
    @err int,
    @trans int

  select @err=0, @trans=@@trancount

  if(@trans=0) begin tran
    else save tran sdlsetadrs

  select @l_ynum=ynum,@l_sem=sem,@l_psem=psem from tb_Stream where strid=@strid
  select @l_hgrp=s.hgrp
    from tb_Schedule s
      join tb_Load l on l.lid=s.lid
    where s.[week]=@week and s.wday=@wday and s.npair=@npair
      and s.lid=(select top 1 lid from tb_Load where strid=@strid)

  -- проверка аттрибутов потока
  if (@l_ynum is not null)and(@l_sem is not null)and(@l_psem is not null)
    and(@l_hgrp is not null)
  begin

    -- проверка занятости аудитории
    if(dbo.uf_freeaid(@l_ynum,@l_sem,@l_psem,@week,@wday,@npair,@aid)!=1) set @err=-3

    -- проверка вместимости аудитории (поток.)
    if(@err=0)
      if(dbo.uf_chkcap_s(@strid,@aid,@l_hgrp)!=1) set @err=-4

    if(@err=0)
    begin
      update s set aid=@aid
        from tb_Schedule s
          join tb_Load l on s.lid=l.lid
        where s.[week]=@week and s.wday=@wday and s.npair=@npair and l.strid=@strid
      select @err=@@error
      if(@err!=0) set @err=-5
    end

  end else set @err=-2

  if(@err!=0)
  begin
    if(@trans=0) rollback tran
      else rollback tran sdlsetadrs
  end
  else if(@trans=0) commit tran

  return @err
END





GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/*
  изм-е подгруппы для занятия (lid,week,wday,npair,hgrp)
  (для одиноч. или поток. занятия)
  RETURN_VALUE:
    0  изм-ние успешно
    -1 вход. парам-ры заданы неправильно
    -2 нет занятия
    -3 нельзя поставить подгруппу (см. uf_chkhgrp)
    -4 вместимость аудитории
    -5 ошибка при обновлении записи (@@rowcount!>0)
*/
CREATE PROCEDURE dbo.sdl_sethgrp
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

  if(@lid is null)or(@week is null)or(@wday is null)or(@npair is null)or(@hgrp is null)
    return -1

  declare
    @l_strid bigint,
    @l_aid bigint,
    @err int,
    @trans int

  select @err=0, @trans=@@trancount

  if(@trans=0) begin tran
    else save tran sdlsethgrp

  -- если занятие существует
  if exists(
      select lid from tb_Schedule
        where lid=@lid and [week]=@week and wday=@wday and npair=@npair)
  begin
    -- проверка возможности поставить подгруппу(ы)
    if(dbo.uf_chkhgrp(@lid,@week,@wday,@npair,@hgrp)=0) set @err=-3

    -- проверка вместимости аудитории
    if(@err=0)and(@hgrp=0)
    begin
      select @l_aid=aid from tb_Schedule
        where [week]=@week and wday=@wday and npair=@npair and lid=@lid
      if(dbo.uf_chkcap(@lid,@l_aid,@hgrp)=0) set @err=-4
    end

    if(@err=0)
    begin
      select @l_strid=strid from tb_Load where lid=@lid

      update s set hgrp=@hgrp
        from tb_Schedule s
          join tb_Load l on l.lid=s.lid
        where s.[week]=@week and s.wday=@wday and s.npair=@npair
          and (l.strid=isnull(@l_strid,0) or s.lid=@lid)
      select @err=@@error
      if(@err!=0) set @err=-5
    end
  end
  else set @err=-2

  if(@err!=0)
  begin
    if(@trans=0) rollback tran
      else rollback tran sdlsethgrp
  end
  else if(@trans=0) commit tran

  return @err
END









GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/*
  изм-ние преп-ля для занятия (lid,week,wday,npair,tid)
  RETURN_VALUE:
    0  изм-ние успешно
    -1 вход. парам-ры заданы неправильно
    -2 аттрибуты занятия не определены
    -3 преп-лья занят
    -4 ошибка при обновлении записи
    >0 server error
*/
CREATE PROCEDURE dbo.sdl_setthr_l
(
@lid bigint,
@week tinyint,
@wday tinyint,
@npair tinyint,
@tid bigint
)
AS
BEGIN
  set nocount on

  if(@lid is null)or(@week is null)or(@wday is null)or(@npair is null) return -1

  declare
    @l_ynum smallint,
    @l_sem tinyint,
    @l_psem tinyint,
    @err int,
    @trans int

  select @err=0, @trans=@@trancount

  if(@trans=0) begin tran
    else save tran sdlsetthrl

  -- опр-ние ynum,sem,psem от lid
  select @l_ynum=ynum,@l_sem=sem, @l_psem=psem
    from vw_Schedule
    where lid=@lid and [week]=@week and wday=@wday and npair=@npair

  -- если занятие существует
  if (@l_ynum is not null) and (@l_sem is not null) and (@l_psem is not null)
  begin

    -- проверка занятости преподавателя
    if(dbo.uf_freetid(@l_ynum,@l_sem,@l_psem,@week,@wday,@npair,@tid)=1)
    begin
      -- обновление преп-ля нагрузки
      update tb_Load set tid=@tid where lid=@lid
      set @err=@@error
      if(@err!=0) set @err=-4
    end else set @err=-3

  end else set @err=-2

  if(@err!=0)
  begin
    if(@trans=0) rollback tran
      else rollback tran sdlsetthrl
  end
  else if(@trans=0) commit tran

  return @err
END
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO



/*
  уст-ка преп-ля для всего поток. занятия (strid,week,wday,npair,tid)
  RETURN_VALUE:
    0  изм-ние успешно (рез-т stm_setthr)
    -1 вход. парам-ры заданы неправильно
    -2 аттрибуты потока не определены
    -3 преп-ль занят
*/
CREATE   PROCEDURE dbo.sdl_setthr_s
(
@strid bigint,
@week tinyint,
@wday tinyint,
@npair tinyint,
@tid bigint
)
AS
BEGIN
  set nocount on

  if(@strid is null)or(@week is null)or(@wday is null)or(@npair is null) return -1

  declare
    @l_ynum smallint,
    @l_sem tinyint,
    @l_psem tinyint,
    @err int,
    @trans int

  select @err=0, @trans=@@trancount

  if(@trans=0) begin tran
    else save tran sdlsetthrs

  select @l_ynum=ynum, @l_sem=sem, @l_psem=psem from tb_Stream where strid=@strid
  
  if (@l_ynum is not null)and(@l_sem is not null)and(@l_psem is not null)
  begin
    -- проверка занятости преп-ля
    if dbo.uf_freetid(@l_ynum,@l_sem,@l_psem,@week,@wday,@npair,@tid)=1
    begin
      exec @err=dbo.stm_setthr @strid, @tid
      if(@err!=0) set @err=@err-10
    end
    else set @err=-3
  end
  else set @err=-2

  if(@err!=0)
  begin
    if(@trans=0) rollback tran
      else rollback tran sdlsetthrs
  end
  else if(@trans=0) commit tran

  return @err
END






GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


-- выбор занятий для пары (все)
CREATE  PROCEDURE dbo.sdl_getavail_g
(
@sem tinyint,
@psem tinyint,
@week tinyint,
@wday tinyint,
@npair tinyint,
@grid bigint
)
AS
BEGIN
  set nocount on

  if(@sem is null)or(@psem is null)or(@week is null)
    or(@wday is null)or(@npair is null)or(@grid is null)
    return -1

  select
      w.wpid,
      w.sbid,s.sbName,s.sbSmall,
      l.lid,
      l.type,
      l.hours,
      l.tid,p.pSmall,t.Initials,
      l.strid,
      @week as [week],

      dbo.uf_getavail(l.lid) as ahours,
      dbo.uf_statetid(g.ynum,@sem,@psem,@week,@wday,@npair,l.tid) as tstate,
      dbo.uf_chklsns(l.lid,@week,@wday,@npair,0) as flsns, -- можно пол. группу?
      dbo.uf_chklsns(l.lid,@week,@wday,@npair,1) as hlsns, -- можно подгруппу?
      dbo.uf_existslsns(@week,@wday,@npair,l.lid) as [exists]
    from tb_Group g
      join tb_Workplan w on w.grid=g.grid
      join tb_Load l on l.wpid=w.wpid
      join tb_Subject s on s.sbid=w.sbid
      left join tb_Teacher t on t.tid=l.tid
      left join tb_Post p on p.pid=t.pid
    where w.sem=@sem and l.psem=@psem and g.grid=@grid
END







GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

-- выбор возмож. занятий дисциплины (sem,psem,week,wday,npair,grid,sbid)
CREATE PROCEDURE dbo.sdl_getavail_sb
(
@sem tinyint,
@psem tinyint,
@week tinyint,
@wday tinyint,
@npair tinyint,
@grid bigint,
@sbid bigint
)
AS
BEGIN
  set nocount on

  if(@sem is null)or(@psem is null)or(@week is null)
    or(@wday is null)or(@npair is null)or(@grid is null)or(@sbid is null)
    return -1

  select
      w.wpid,
      w.sbid,s.sbName,s.sbSmall,
      l.lid,
      l.type,
      l.hours,
      l.tid,p.pSmall,t.Initials,
      l.strid,
      @week as [week],

      dbo.uf_statetid(g.ynum,@sem,@psem,@week,@wday,@npair,l.tid) as tstate,-- статус преп-ля
      dbo.uf_getavail(l.lid) as ahours,
      dbo.uf_chklsns(l.lid,@week,@wday,@npair,0) as flsns,-- можно пол. группу?
      dbo.uf_chklsns(l.lid,@week,@wday,@npair,1) as hlsns,-- можно подгруппу?
      dbo.uf_existslsns(@week,@wday,@npair,l.lid) as [exists]
    from tb_Group g
      join tb_Workplan w on w.grid=g.grid
      join tb_Load l on l.wpid=w.wpid
      join tb_Subject s on s.sbid=w.sbid
      left join tb_Teacher t on t.tid=l.tid
      left join tb_Post p on p.pid=t.pid
    where w.sem=@sem and l.psem=@psem and g.grid=@grid and w.sbid=@sbid
END





GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


/*
  создание поток. занятия (strid,week,wday,npair,hgrp,aid)
  RETURN_VALUE:
    0  занятие добавлено (нет ошибок)
    -1 параметры заданы неправильно
    -2 неопредены аттрибуты потока
    -3 преп-ль занят
    -4 аудитория занята
    -5 нет мест в аудитории
    -6 нельзя поставить занятие (см. uf_chklsns_s)
    -7 превышена норма нагрузки
    -8 ошибка при добавлении записи
    >0 ошибка server`а
*/
CREATE PROCEDURE dbo.sdl_newlsns_s
(
@strid bigint,
@week tinyint,
@wday tinyint,
@npair tinyint,
@hgrp tinyint,
@aid bigint
)
AS
BEGIN
  set nocount on

  -- проверка вход. параметров
  if(@strid is null)or(@week is null)or(@wday is null)or(@npair is null)or(@hgrp is null)
    return -1

  declare
    @l_ynum smallint,
    @l_sem tinyint,
    @l_psem tinyint,
    @l_tid bigint,
    @err int,
    @trans int

  select @err=0, @trans=@@trancount

  if(@trans=0) begin tran
    else save tran sdlnewlsnss

  -- выборка sem,psem
  select @l_ynum=ynum,@l_sem=sem,@l_psem=psem,@l_tid=tid
    from tb_Stream where strid=@strid

  if(@l_ynum is not null)and(@l_sem is not null)and(@l_psem is not null)
  begin
    -- проверка занятости преп-ля
    if (dbo.uf_freetid(@l_ynum,@l_sem,@l_psem,@week,@wday,@npair,@l_tid)!=1) set @err=-3

    -- проверка занятости аудитории
    if(@err=0)
      if (dbo.uf_freeaid(@l_ynum, @l_sem,@l_psem,@week,@wday,@npair,@aid)!=1) set @err=-4

    -- проверка вместимости аудитории
    if(@err=0)
      if (dbo.uf_chkcap_s(@strid,@aid,@hgrp)!=1) set @err=-5

    -- проверка на возможность поставить поток. занятие
    if(@err=0)
      if (dbo.uf_chklsns_s(@strid,@week,@wday,@npair,@hgrp)!=1) set @err=-6

    -- проверка на превышение нормы нагрузки потоком
    if(@err=0)
      if (dbo.uf_chkhours_s(@strid,@week,@hgrp)!=1) set @err=-7
  
    -- вставка нов. занятия
    if(@err=0)
    begin
      insert tb_Schedule (lid,[week],wday,npair,hgrp,aid)
        select lid,@week,@wday,@npair,@hgrp,@aid from tb_Load where strid=@strid
      select @err=@@error
      if(@err!=0) set @err=-8  
    end

  end
  else set @err=-2

  if(@err!=0)
  begin
    if(@trans=0) rollback tran
      else rollback tran sdlnewlsnss
  end
  else if(@trans=0) commit tran

  return @err
END
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/*
  Управление расписанием

  601 выбор расписания группы (sem,psem,grid)
  602 уст-ка занятия (lid,week,wday,npair,hgrp,aid)
  603 удаление занятия (lid,week,wday,npair)

  604 изм-ние преп-ля занятия (lid,week,wday,npair,tid)
  605 изм-ние аудитории занятия (lid,week,wday,npair,aid)
  606 изм-ние подгруппы занятия (lid,week,wday,npair,hgrp)

  607 уст-ка поток. занятия (strid,week,wday,npair,hgrp,aid)
  608 удаление поток. занятия (strid,week,wday,npair)
  609 изм-е преп-ля поток. занятия (strid,week,wday,npair,tid)
  610 изм-е аудитории поток. занятия (strid,week,wday,npair,aid)

  611 выбор свобод. преп-лей (lid,week,wday,npair)
  612 выбор возможных занятий дисциплины (sem,psem,week,wday,npair,grid,sbid)
  613 выбор поток. занятий (strid,[wday,npair])
  614 выбор свобод. аудиторий (вместимость) (week,wday,npair,lid)
  615 выбор занятий нагрузки (lid, [wday,npair])
  616 выбор возмож. занятий (sem,psem,week,wday,npair,grid)
  617 выбор возмож. занятий в п/сем (sem,psem,grid)
  618 выбор свобод. ауд-рий каф.-исп. (lid,week,wday,npair) 

  620 выбор расписания преп-ля (ynum,sem,psem,tid)
  621 выбор занятости аудитории (ynum,sem,psem,aid)

  630 выбор загрузки аудитории в расписании (ynum,sem,psem,aid)
*/
CREATE        PROCEDURE dbo.prc_SchedMgm
(
@case int,
@fid int,
@ynum smallint,
@sem tinyint,
@psem tinyint,
@week tinyint,
@wday tinyint,
@npair tinyint,
@hgrp tinyint,
@lid bigint,
@grid bigint,
@sbid bigint,
@strid bigint,
@tid bigint,
@aid bigint
)
AS
BEGIN
set nocount on
declare @err int

-- выбор расписания группы (sem,psem,grid)
if @case=601
begin
  exec @err=dbo.sdl_getlsns_g @sem, @psem, @grid
  return @err
end

-- уст-ка занятия (lid,week,wday,npair,hgrp,aid)
if @case=602
begin
  exec @err=dbo.sdl_newlsns_g @lid, @week, @wday, @npair, @hgrp, @aid
  return @err
end

-- удаление занятия (lid,week,wday,npair)
if @case=603
begin
  exec @err=dbo.sdl_dellsns_g @lid, @week, @wday, @npair
  return @err
end

-- изм-ние преп-ля занятия (lid,week,wday,npair,tid)
if @case=604
begin
  exec @err=dbo.sdl_setthr_l @lid, @week, @wday, @npair, @tid
  return @err
end

-- изм-ние аудитории занятия (lid,week,wday,npair,aid)
if @case=605
begin
  exec @err=dbo.sdl_setadr_l @lid, @week, @wday, @npair, @aid
  return @err
end

-- изм-ние подгруппы занятия (lid,week,wday,npair,hgrp)
if @case=606
begin
  exec @err=dbo.sdl_sethgrp @lid, @week, @wday, @npair, @hgrp
  return @err
end

-- уст-ка поток. занятия (strid,week,wday,npair,aid)
if @case=607
begin
  exec @err=dbo.sdl_newlsns_s @strid,@week,@wday,@npair,@hgrp,@aid
  return @err
end

-- удаление поток. занятия (strid,week,wday,npair)
if @case=608
begin
  exec @err=dbo.sdl_dellsns_s @strid,@week,@wday,@npair
  return @err
end

-- изм-е преп-ля поток. занятия (strid,week,wday,npair,tid)
if @case=609
begin
  exec @err=dbo.sdl_setthr_s @strid, @week, @wday, @npair, @tid
  return @err
end

-- изм-е аудитории поток. занятия (strid,week,wday,npair,aid)
if @case=610
begin
  exec @err=dbo.sdl_setadr_s @strid, @week, @wday, @npair, @aid
  return @err
end

-- выбор свобод. преп-лей (lid,week,wday,npair)
if @case=611
begin
  exec @err=dbo.sdl_getfreethr_l @lid, @week, @wday, @npair
  return @err
end

-- выбор возмож. занятий дисциплины (sem,psem,week,wday,npair,grid,sbid)
if @case=612
begin
  exec @err=dbo.sdl_getavail_sb @sem, @psem, @week, @wday, @npair, @grid, @sbid
  return @err
end

-- выбор поток. занятий (strid,[wday,npair])
if @case=613
begin
  exec @err=dbo.sdl_getlsns_s @strid, @wday, @npair
  return @err
end

-- выбор свобод. аудиторий (вместимость) (week,wday,npair,lid)
if @case=614
begin
  exec @err=dbo.sdl_getfreeadr_l @fid, @lid, @week, @wday, @npair
  return @err
end

-- выбор занятий нагрузки (lid, [wday,npair])
if @case=615
begin
  exec @err=dbo.sdl_getlsns_l @lid, @wday, @npair
  return @err
end

-- выбор возмож. занятий (sem,psem,week,wday,npair,grid)
if @case=616
begin
  exec @err=dbo.sdl_getavail_g @sem,@psem,@week,@wday,@npair,@grid
  return @err
end

-- выбор возмож. занятий в п/сем (sem,psem,grid)
if @case=617
begin
  exec @err=dbo.sdl_getavail_psem @sem,@psem,@grid
  return @err
end

--  618 выбор свобод. ауд-рий каф.-исп. (lid,week,wday,npair) 
if @case=618
begin
  exec @err=dbo.sdl_getfreeadr_lk @lid,@week,@wday,@npair
  return @err
end

-- выбор расписания преп-ля (ynum,sem,psem,tid)
if @case=620
begin
  exec @err=dbo.sdl_getlsns_t @ynum,@sem,@psem,@tid
  return @err
end

-- выбор занятости аудитории (ynum,sem,psem,aid)
if @case=621
begin
  exec @err=dbo.sdl_getlsns_a @ynum,@sem,@psem,@aid
  return @err
end

-- выбор загрузки аудитории в расписании (ynum,sem,psem,aid)
if @case=630
begin
  exec @err=dbo.sdl_getload_a @ynum,@sem,@psem,@aid
  return @err
end

return -100
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


-- триггер для проверки на пересечения врем. интервалов
CREATE  TRIGGER dbo.triu_PeriodChkDate ON dbo.tb_Period
FOR INSERT, UPDATE
AS
BEGIN
  set nocount on

  declare @err int

  set @err=0

  -- проверка пересечения времен. интервалов
  if exists
  (
    select *
      from Inserted i
      where exists
      (
        select *
          from tb_Period p
          where (i.prid!=p.prid) and
          (
            dbo.uf_inrange_d(i.p_start, p.p_start, p.p_end)=1 or
            dbo.uf_inrange_d(i.p_end,   p.p_start, p.p_end)=1 or
            dbo.uf_inrange_d(p.p_start, i.p_start, i.p_end)=1
          )
      )
  )
  begin
    set @err=1
    raiserror('[triu_PeriodChkDate]: Пересечение временных интервалов',16,1)
  end

  if(@err!=0) rollback transaction
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

-- триггер после удаления периода
-- проверка ссылок на период из групп (tb_Group.ynum=Deleted.ynum)
CREATE TRIGGER dbo.trd_Period ON dbo.tb_Period
FOR DELETE
AS
BEGIN
  declare @err int

  set @err=0

  -- проверка ссылок на удаляем. период
  if exists
    (
      select d.prid
        from Deleted d
        where exists(select grid from tb_Group g where g.ynum=d.ynum)
    )
  begin
    set @err=1
    raiserror('[trd_Period]: Удаляемый период используется группами',16,1)
  end

  if(@err!=0) rollback transaction
END



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE  TRIGGER trd_Auditory ON dbo.tb_Auditory
INSTEAD OF DELETE
AS
BEGIN
  set nocount on

  -- удаление из расписания занятий
  update tb_Schedule set aid=NULL
    from tb_Schedule
      join Deleted on tb_Schedule.aid=Deleted.aid

  -- удаление из расписания экзаменов
  update tb_Exam set aid=NULL
    from tb_Exam
      join Deleted on tb_Exam.aid=Deleted.aid

  -- удаление из tb_Auditory
  delete tb_Auditory
    from tb_Auditory
      join Deleted on Deleted.aid=tb_Auditory.aid

  set nocount off
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE TRIGGER trd_Stream ON dbo.tb_Stream 
INSTEAD OF DELETE 
AS
  set nocount on
  -- удаление групп из потока (tb_Load.strid=NULL)
  update tb_Load set strid=NULL
    where strid in (select strid from Deleted)

  -- удаление записей
  delete tb_Stream 
    from tb_Stream
      join Deleted on tb_Stream.strid=Deleted.strid


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

-- ограничение на изм-ние полей ynum,sem,psem,type,hours,kid
CREATE TRIGGER tru_StrmNotUpdate ON dbo.tb_Stream
FOR UPDATE 
AS
  set nocount on

  if( update(ynum) or update(sem) or update(psem)
    or update(type) or update(hours) or update(kid))
  begin
    raiserror('[tru_StrmNotUpdate]: Это поле нельзя модифицировать',16,1)
    rollback transaction
  end


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE TRIGGER tri_StrmChkTid ON dbo.tb_Stream
FOR INSERT
AS
  set nocount on

  if update(tid)
  begin
    -- проверка кафедры преподавателя
    if exists(
      select *
        from Inserted ins
          join tb_Teacher t on ins.tid=t.tid
        where t.kid<>ins.kid)
    begin
      raiserror('[tri_StrmChkTid]: Преподаватель с другой кафедры',16,1)
      rollback transaction
    end
  end


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE TRIGGER tru_StrmChkTid ON dbo.tb_Stream
FOR UPDATE
AS
  set nocount on

  if update(tid)
  begin
    -- проверка кафедры преподавателя
    if exists(
      select *
        from Inserted ins
          join tb_Teacher t on ins.tid=t.tid
        where t.kid<>ins.kid)
    begin
      raiserror('[tru_StrmChkTid]: Преподаватель с другой кафедры',16,1)
      rollback transaction
    end
    -- обновление преп-лей для нагрузок потока
    else
      update l set tid=ins.tid
        from tb_Load l
          join Inserted ins on ins.strid=l.strid
          join Deleted del on del.strid=ins.strid and isnull(del.tid,0)<>isnull(ins.tid,0)
  end


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE   TRIGGER trd_Teacher ON dbo.tb_Teacher
INSTEAD OF DELETE
AS
BEGIN
  set nocount on

  -- удаление ссылок из потоков
  update tb_Stream set tid=NULL
    from tb_Stream
      join Deleted on Deleted.tid=tb_Stream.tid

  -- удаление ссылок из нагрузок
  update tb_Load set tid=NULL
    from tb_Load
      join Deleted on Deleted.tid=tb_Load.tid

  -- удаление из tb_Teacher
  delete tb_Teacher
    from tb_Teacher
      join Deleted on Deleted.tid=tb_Teacher.tid

  set nocount off
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

-- огр-ние на изм-ние кафедры
CREATE   TRIGGER tru_WorkplanChkKid ON dbo.tb_Workplan
FOR UPDATE
AS
BEGIN
  set nocount on
  if update(kid)
    if exists
    (
      select l.lid
        from tb_Load l
          join Inserted ins on ins.wpid=l.wpid
        where (l.tid is not null) or (l.strid is not null)
    )
    begin
      raiserror('[tru_WorkplanChkKid]: Для дисциплины установлены преподаватели или потоки',16,1)
      rollback transaction
    end
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

-- удаление пуст. потоков
CREATE TRIGGER trd_Load ON dbo.tb_Load
FOR DELETE
AS 
BEGIN
  set nocount on
  -- удаление сущ. пуст. потоков
  delete tb_Stream
    from tb_Stream s
    where not exists(select strid from tb_Load where strid=s.strid)

  -- удаление пуст. потоков, к-рые могут возникнут при удалении записей
  delete tb_Stream
    from tb_Stream s
      join Deleted del on del.strid=s.strid
    where not exists(select strid from tb_Load where strid=s.strid and lid<>del.lid)
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

-- проверка преподавателя нагрузки
CREATE TRIGGER triu_LoadChkTid ON dbo.tb_Load
FOR INSERT, UPDATE
AS
BEGIN
  set nocount on  

  declare @err tinyint
  set @err=0

  if update(tid)
  begin
    -- проверка кафедры преп-ля
    if exists(
      select *
        from Inserted ins
          join tb_Workplan w on w.wpid=ins.wpid
          join tb_Teacher t on t.tid=ins.tid
        where w.kid<>t.kid)
    begin
      raiserror('[triu_LoadChkTid]: Преподаватель с другой кафедры',16,1)
      set @err=1
    end
    -- проверка совпадения tid(strid)=tid(lid)
    if @err=0
      if exists(
        select *
          from Inserted ins
            join tb_Stream s on s.strid=ins.strid
          where isnull(ins.tid,0)<>isnull(s.tid,0))
      begin
        raiserror('[triu_LoadChkTid]: Для нагрузки установлен поток',16,1)
        set @err=1
      end

    -- удаление занятий, для которых нарущена занятость преп-ля
    if @err=0
      delete s
        from Inserted ins
          join tb_Schedule s on s.lid=ins.lid 
        where dbo.uf_freetid_l(s.lid,s.[week],s.wday,s.npair)=0

    -- обновление преп-лей для занятий
    -- удалено: удалено поле tb_Schedule.tid
    --if @err=0
    --  update tb_Schedule set tid=dbo.uf_freetid(w.sem,ins.psem,s.week,s.wday,s.npair,ins.tid)
    --    from Inserted ins
    --      join tb_Schedule s on s.lid=ins.lid
    --      join tb_Workplan w on w.wpid=ins.wpid
  end

  if(@err<>0) rollback transaction
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

-- действие при модификации поля strid
-- модификация 19.04.06
CREATE TRIGGER triu_LoadStrid ON dbo.tb_Load
FOR INSERT, UPDATE
AS
BEGIN
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

    -- проверка ynum,sem,psem,hours,type
    if @err=0
      if exists(
        select *
          from Inserted ins
            join tb_Workplan w on w.wpid=ins.wpid
            join tb_Group g on g.grid=w.grid
            join tb_Stream s on s.strid=ins.strid
          where g.ynum<>s.ynum or w.sem<>s.sem or ins.psem<>s.psem or ins.hours<>s.hours or ins.type<>s.type)
      begin
        raiserror('[triu_LoadStrid]: Нагрузка не может объединена с указ. потоком',16,1)
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
  
  if(@err<>0) rollback transaction
END








GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO



-- действия при модификации поля hours
-- 25.01.06 запрет изм-ния, если установ. поток
CREATE   TRIGGER tru_LoadHours ON dbo.tb_Load
FOR UPDATE
AS
  set nocount on
  declare @err tinyint

  set @err=0
  if update(hours)
  begin
    -- запрет изм-ния при установл. потоке (hours(lid)<>hours(strid))
    if exists(
        select lid
          from Inserted ins
            join tb_Stream s on s.strid=ins.strid
          where ins.hours<>s.hours)
    begin
      raiserror('[tru_LoadHours]: Нарушение равенства часов аудит. нагрузок внутри потока',16,1)
      set @err=1
    end

    if @err=0
    begin
      -- удаление занятия, для которых уменьшена нагрузка
      delete s
        from Inserted ins
          join Deleted del on del.lid=ins.lid and del.hours>ins.hours
          join tb_Schedule s on s.lid=ins.lid
    end
  end

  if @err<>0
    rollback transaction




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

