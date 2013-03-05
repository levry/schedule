-- замена дисциплины
declare
  @sbid bigint,
  @nsbid bigint,
  @err int

set @err=0
begin tran
  -- обновление раб.плана
  update tb_Workplan set sbid=@nsbid where sbid=@sbid
  select @err=@@error
  if @err=0
  begin
    -- удаление исход. дисциплины
    delete tb_Subject where sbid=@sbid
    if (@@rowcount=1) and (@@error=0)
      set @err=0
    else set @err=1
  end
if @err=0
  commit tran
else rollback tran
