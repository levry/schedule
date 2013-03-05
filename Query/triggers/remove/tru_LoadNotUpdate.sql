-- 㤠���
-- ��࠭�祭�� �� ���-��� ��. ���� ⠡���� (wpid,psem,type)
CREATE TRIGGER tru_LoadNotUpdate on dbo.tb_Load
FOR UPDATE
AS
BEGIN
  set nocount on

  -- ����� ������஢��� �����. ����
  if update(wpid) or update(psem) or update(type)
  begin
    raiserror('[tru_LoadNotUpdate]: �� ���� ����� ������஢���',16,1)
    rollback transaction
  end
END