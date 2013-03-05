declare
@spkName varchar(50),  -- кафедра спец-ти
@spCode varchar(10),   -- код спец-ти
@spName varchar(50),   -- назв. спец-ти
@grName varchar(10),   -- назв. группы
@Studs smallint,       -- число студентов
@sbName varchar(100),  -- назв. дисциплины

@wpId bigint,       -- id р.п.
@Sem tinyint,       -- семестр
@tSem tinyint,      -- академ. семестр
@sbCode varchar(20),-- индекс дисциплины
@WP1 tinyint,       -- недель в 1 п/с
@WP2 tinyint,       -- недель во 2 п/с
@TotalHLP int,      -- всего по уч. плану
@TotalAHLP int,     -- всего по уч. планку (ауд. наргузка)
@Compl int,         -- пройдено ранее
@Kp tinyint,        -- курс. проекты
@Kr tinyint,        -- курс. работы 
@Rg tinyint,        -- расчет. граф. работы
@Cr tinyint,        -- контр. работы
@Hr tinyint,        -- дом. работы
@Koll tinyint,      -- коллоквиумы
@Z tinyint,         -- зачет
@E tinyint,         -- экзамен
@lkName varchar(50) -- назв. кафедры, чит. дисциплину

--@PSem tinyint,   -- п/с
--@Type tinyint,   -- тип
--@Hours tinyint   -- часов в неделю

-- лок. перем.
declare
@spkid bigint,  -- id кафедры спец-ти
@wkid bigint,   -- id кафедры, чит. дисциплину
@spid bigint,   -- id спец-ти
@grid bigint,   -- id группы
@sbid bigint,   -- id предмета
--@wpid bigint,   -- id р.п.
@res int        -- рез-т

  set @res=0

  -- добавление кафедр
  set @spkid=null
  set @wkid=null
  -- кафедра спец-ти
  select @spkid=kid from tb_Kafedra where kName=@spkName
  if @spkid is null
  begin
    insert tb_Kafedra (kName) values (@spkName)
    select @spkId=@@identity
    set @res=@res+2
  end
  -- каф-ра, чит. дисциплину
  select @wkid=kid from tb_Kafedra where kName=@lkName
  if @wkid is null
  begin
    insert tb_Kafedra (kName) values (@lkName)
    select @wkId=@@identity
    set @res=@res+4
  end

  -- добавление специальности
  set @spid=null
  select @spid=spid from tb_Special 
    where kid=@spkid and spCode=@spCode and spName=@spName
  if @spid is null
  begin
    insert tb_Special (kid, spCode, spName) values (@spkid, @spCode, @spName)
    select @spid=@@identity
    set @res=@res+8
  end
  
  -- добавление группы
  set @grid=null
  select @grid=grid from tb_Group where spid=@spid and grName=@grName
  if @grid is null
  begin
    insert tb_Group (spid, grName, studs) values (@spid, @grName, @Studs)
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
  set @wpId=null
  select @wpId=wpid from tb_Workplan
    where grid=@grid and sbid=@sbid and Sem=@Sem
  -- доб-ние
  if @wpId is null
  begin
    insert tb_Workplan (grid, sbid, kid, Sem, tSem, sbCode, WP1, WP2, TotalHLP, TotalAHLP, Compl, Kp, Kr, Rg, Cr, Hr, Koll, Z, E)
      values (@grid, @sbid, @wkid, @Sem, @tSem, @sbCode, @WP1, @WP2, @TotalHLP, @TotalAHLP, @Compl, @Kp, @Kr, @Rg, @Cr, @Hr, @Koll, @Z, @E)
    select @wpId=@@identity
    if @@rowcount=1
      set @res=@res+65
  end
  -- изм-ние
  else
  begin
    update tb_Workplan set kid=@wkid, tSem=@tSem, sbCode=@sbCode, WP1=@WP1, WP2=@WP2,
        TotalHLP=@TotalAHLP, Compl=@Compl, Kp=@Kp, Kr=@Kr, Rg=@Rg, Cr=@Cr, Hr=@Hr,
        Koll=@Koll, Z=@Z, E=@E
      where wpid=@wpId
    if @@rowcount=1
      set @res=@res+1
  end  