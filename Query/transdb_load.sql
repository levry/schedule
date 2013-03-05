set identity_insert devdb..tb_load on
go

declare @err int, @c int

begin tran

insert into devdb..tb_load (lid,wpid,psem,type,tid,strid,hours)
select wl.lid,wl.wpid,wl.psem,wl.type,wl.tid,wl.strid,wl.hours
  from workdb..tb_load wl
    join workdb..tb_workplan ww on ww.wpid=wl.wpid
    join workdb..tb_group wg on wg.grid=ww.grid
  where wg.ynum=2006
select @err=@@error, @c=@@rowcount

if (@c=4332) and (@err=0)
begin
  print 'commit tran'
  commit tran
end
else
begin
  print 'rollback tran'
  print 'error: '+cast(@err as varchar)
  rollback tran
end
go

set identity_insert devdb..tb_load off
go