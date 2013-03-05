-- копирование раб. плана дисциплины в др. (wpid,sbid)
CREATE PROCEDURE dbo.wp_copy
(
@wpid bigint,
@sbid bigint
)
AS
  set nocount on
  
  declare
    @lwpid bigint
  set @lwpid=null

  if not exists(
    select wpid from tb_Workplan wp
      where sbid=@sbid 
        and exists(select wpid from tb_Workplan where grid=wp.grid and sem=wp.sem and wpid=@wpid))
  begin
    -- copy workplan
    insert tb_Workplan (grid,sbid,kid,sem,sbCode,wp1,wp2,totalhlp,totalahlp,compl,kp,kr,rg,cr,hr,koll,z,e)
      select grid,@sbid,kid,sem,sbCode,wp1,wp2,totalhlp,totalahlp,compl,kp,kr,rg,cr,hr,koll,z,e from tb_Workplan where wpid=@wpid
    -- copy loads
    select @lwpid=@@identity
    if @lwpid is not null
      insert tb_Load (wpid,psem,type,tid,strid,hours)
        select @lwpid,psem,type,tid,strid,hours from tb_Load where wpid=@wpid
  end
