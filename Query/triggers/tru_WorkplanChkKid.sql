-- ���-��� �� ���-��� ��䥤��
CREATE TRIGGER tru_WorkplanChkKid ON dbo.tb_Workplan
FOR UPDATE
AS

  set nocount on

  if exists(
      select l.lid
        from tb_Load l
          join Inserted ins on ins.wpid=l.wpid
        where (l.tid is not null) or (l.strid is not null)
    )
  begin
    raiserror('[tru_WorkplanChkKid]: ��� ���樯���� ��⠭������ �९�����⥫� ��� ��⮪�',16,1)
    rollback transaction
  end