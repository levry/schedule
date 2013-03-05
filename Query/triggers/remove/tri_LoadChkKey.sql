-- удален (индекс вместо)
-- проверка иск. ключа таблицы (wpid,psem,type)
CREATE TRIGGER tri_LoadChkKey on dbo.tb_Load
FOR INSERT
AS
BEGIN
  set nocount on

  -- проверка отсутствия нагрузки для wpid, psem, type
  if exists(
    select l.lid
      from tb_Load l
        join Inserted ins on ins.lid<>l.lid and ins.wpid=l.wpid and ins.psem=l.psem and ins.type=l.type)
  begin
    raiserror('[tri_LoadChkKey]: Нарушение искусственного ключа',16,1)
    rollback transaction
  end
END