-- управление аудитор. нагрузками
/*
  900  доб-ние (wpid, psem, type, tid, strid, hours) / изм-ние (wpid, psem, type, hours)
*/
CREATE PROCEDURE prc_LoadMgm
(
@OperType int,
@lid bigint output,	-- id нагрузки
@wpId bigint,		-- id р.п.
@PSem tinyint,		-- п/с
@Type tinyint,		-- тип занятия (1-лекция, 2-практика, 3-лаб.)
@tId bigint,		-- id преп-ля
@strId bigint,		-- id потока
@Hours tinyint		-- часы в неделю
)
AS
begin
declare @res int
set @res=0

-- доб-ние/изм-ние (только часы)
if @OperType=900
begin
  set @lid=null
  select @lid=lid from tb_Load where wpid=@wpId and PSem=@PSem and Type=@Type
  -- доб-ние
  if @lid is null
  begin
    insert tb_Load (wpid, PSem, Type, tid, strid, Hours) values (@wpId, @PSem, @Type, @tId, @strId, @Hours)
    select @lid=@@identity
    if @@rowcount=1
      set @res=1
  end
  else
  begin
    update tb_Load set Hours=@Hours where lid=@lid
    set @res=2
  end
  return @res
end

end
GO
