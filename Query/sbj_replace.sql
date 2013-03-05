-- ������ ���樯����
declare
  @sbid bigint,
  @nsbid bigint,
  @err int

set @err=0
begin tran
  -- ���������� ࠡ.�����
  update tb_Workplan set sbid=@nsbid where sbid=@sbid
  select @err=@@error
  if @err=0
  begin
    -- 㤠����� ��室. ���樯����
    delete tb_Subject where sbid=@sbid
    if (@@rowcount=1) and (@@error=0)
      set @err=0
    else set @err=1
  end
if @err=0
  commit tran
else rollback tran
