-- уст-ка часов для нагрузки (lid,hours)
ALTER PROCEDURE dbo.ld_sethours
(
@lid bigint,
@hours tinyint
)
AS
  set nocount on

  declare
    @lhours tinyint,
    @res int

  set @res=0
  select @lhours=hours from tb_Load
    where lid=@lid

  if isnull(@hours,0)<>isnull(@lhours,0)
  begin
    update tb_Load set hours=@hours where lid=@lid
    set @res=@@rowcount
  end

  return @res