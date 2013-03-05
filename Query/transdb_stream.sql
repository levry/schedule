set identity_insert devdb..tb_stream on
go
declare @err int, @c int

begin tran

insert into devdb..tb_stream (strid,ynum,sem,psem,type,hours,kid,tid)
  select ws.strid,ws.ynum,ws.sem,ws.psem,ws.type,ws.hours,dk.kid,ws.tid
    from workdb..tb_stream ws
      join workdb..tb_kafedra wk on wk.kid=ws.kid
      join devdb..tb_kafedra dk on dk.kname=wk.kname
    where ws.ynum=2006
select @err=@@error, @c=@@rowcount

if (@err=0) and @c=279
  commit tran
else rollback tran

set identity_insert devdb..tb_stream off
go