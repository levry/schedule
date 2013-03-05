declare
  @kid bigint,
  @nkid bigint,
  @err int

set @kid=37
set @nkid=50

set @err=0
begin tran
  -- replace tb_Group
  print 'update tb_Group'
  update tb_Group set kid=@nkid where kid=@kid
  -- replace tb_Auditory
  print 'update tb_Auditory'
  update tb_Auditory set kid=@nkid where kid=@kid
  -- replace tb_Teacher
  print 'update tb_Teacher'
  update tb_Teacher set kid=@nkid where kid=@kid

  -- replace tb_Workplan
  print 'update tb_Workplan'
  alter table tb_Workplan disable trigger tru_WorkplanChkKid
  update tb_Workplan set kid=@nkid where kid=@kid
  alter table tb_Workplan enable trigger tru_WorkplanChkKid
  select @err=@@error

  if @err=0
  begin
    -- replace tb_Stream
    print 'update tb_Stream'
    alter table tb_Stream disable trigger tru_StrmNotUpdate
    update tb_Stream set kid=@nkid where kid=@kid
    alter table tb_Stream enable trigger tru_StrmNotUpdate
    select @err=@@error
  end
  if @err=0
  begin
    print 'delete tb_Kafedra'
    delete from tb_Kafedra where kid=@kid
    if (@@rowcount=1) or (@@error=0)
      set @err=0
    else set @err=1
  end
  
if @err=0
  commit tran
else rollback tran
