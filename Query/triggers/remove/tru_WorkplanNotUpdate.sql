-- удален
-- огр-ние на изм-ние иск. ключа (grid,sbid,sem)
CREATE TRIGGER tru_WorkplanNotUpdate ON dbo.tb_Workplan
FOR UPDATE
AS
BEGIN
  set nocount on
  
  if update(grid) or update(sbid) or update(sem)
  begin
    raiserror('[tru_WorkplanNotUpdate]: Это поле нельзя модифицировать',16,1)
    rollback transaction
  end
END
