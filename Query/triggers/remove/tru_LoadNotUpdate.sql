-- удален
-- ограничение на изм-ние иск. ключа таблицы (wpid,psem,type)
CREATE TRIGGER tru_LoadNotUpdate on dbo.tb_Load
FOR UPDATE
AS
BEGIN
  set nocount on

  -- нельзя модифицировать искуств. ключ
  if update(wpid) or update(psem) or update(type)
  begin
    raiserror('[tru_LoadNotUpdate]: Это поле нельзя модифицировать',16,1)
    rollback transaction
  end
END