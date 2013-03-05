-- проверка времени экзамена
CREATE FUNCTION dbo.chk_exam_time
(
@wpid bigint,
@start datetime,
@end datetime
)
RETURNS tinyint AS
BEGIN
declare
  @res tinyint,
  @length int,
  @p_start datetime,
  @p_end datetime
  

if(@start is not null)and(@end is not null)and(@wpid is not null)
begin
-- проверка длительности мероприятия (экзамена, конс.)
set @length=datediff(hour,@start,@end)
if(@length>0 and @length<8)

select @p_start=p.p_start, @p_end=@p_end
  from tb_Workplan w
    join tb_Group g on g.grid=w.grid
    join tb_Period p on p.ynum=g.ynum and p.ptype=3
  where w.wpid=@wpid

end
else set @res=0


return @res
END