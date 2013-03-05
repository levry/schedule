set identity_insert devdb..tb_workplan on
go

declare @err int, @c int

begin tran

insert into devdb..tb_workplan (wpid,grid,sbid,kid,sem,sbcode,wp1,wp2,totalhlp,
    totalahlp,compl,kp,kr,rg,cr,hr,koll,z,e)
select ww.wpid,ww.grid,ds.sbid,dk.kid,ww.sem,ww.sbcode,ww.wp1,ww.wp2,ww.totalhlp,
    ww.totalahlp,ww.compl,ww.kp,ww.kr,ww.rg,ww.cr,ww.hr,ww.koll,ww.z,ww.e
  from workdb..tb_workplan ww  
    join workdb..tb_group wg on wg.grid=ww.grid
    join workdb..tb_kafedra wk on wk.kid=ww.kid
    join workdb..tb_subject ws on ws.sbid=ww.sbid
    join devdb..tb_kafedra dk on dk.kname=wk.kname
    join devdb..tb_subject ds on ds.sbname=ws.sbname
  where wg.ynum=2006
select @err=@@error, @c=@@rowcount

if (@err=0) and (@c=1649)
begin
  print 'commit tran'
  commit tran
end
else
begin
  print 'error: '+cast(@err as varchar)
  print 'rolback tran'
  rollback
end

set identity_insert devdb..tb_workplan off
go
