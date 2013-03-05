-- 㤠��� (������ �����)
-- �஢�ઠ ��. ���� ⠡���� (wpid,psem,type)
CREATE TRIGGER tri_LoadChkKey on dbo.tb_Load
FOR INSERT
AS
BEGIN
  set nocount on

  -- �஢�ઠ ������⢨� ����㧪� ��� wpid, psem, type
  if exists(
    select l.lid
      from tb_Load l
        join Inserted ins on ins.lid<>l.lid and ins.wpid=l.wpid and ins.psem=l.psem and ins.type=l.type)
  begin
    raiserror('[tri_LoadChkKey]: ����襭�� �����⢥����� ����',16,1)
    rollback transaction
  end
END