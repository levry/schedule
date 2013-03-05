-- проверка работы триггеров при возникновении пуст. потоков
declare @rows int

print 'select tb_Stream'
select * from tb_Stream

--select * from tb_Load where strid is not null
--select * from tb_Load where lid=725

set @rows=0
begin tran
  print 'update'
  update tb_Load set strid=null where lid=725

  print 'select empty streams'
  select @rows=count(*)
    from tb_Stream s
    where not exists(select strid from tb_Load where strid=s.strid)
  print 'Empty streams: '+cast(@rows as varchar)

if @rows>0
begin
  rollback tran
  print 'Rollback'
end
else
begin
  commit tran
  print 'Commit'
  print 'select tb_Streams'
  select * from tb_Stream
end
