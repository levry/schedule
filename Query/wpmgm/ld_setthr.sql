-- уст-ка преп-ля для нагрузки (lid,tid)
CREATE PROCEDURE dbo.ld_setthr
(
@lid bigint,
@tid bigint
)
AS
  set nocount on

  declare
    @ltid bigint,
    @res int

  select @ltid=tid from tb_Load where lid=@lid

  if isnull(@tid,0)<>isnull(@ltid,0)
  begin
    update tb_Load set tid=@tid where lid=@lid
    set @res=@@rowcount
  end

  return @res
