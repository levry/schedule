-- проверка вместимости потока в аудиторию

declare
  @strid bigint,
  @aid bigint

declare
  @lstuds smallint,
  @lcap smallint

set @strid=1
set @aid=5

  select @lstuds=sum(studs)
    from tb_Group g
      join tb_Workplan w on w.grid=g.grid
      join tb_Load l on l.wpid=w.wpid
    where l.strid=@strid
  
  select @lcap=capacity
    from tb_Auditory
    where aid=@aid

print @lstuds
print @lcap

print dbo.uf_checkcapstrm(@strid,@aid)