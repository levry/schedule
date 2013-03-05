-- =============================================
-- Create basic Instead Of Trigger
-- =============================================
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'tr_AuditDel' 
	   AND 	  type = 'TR')
    DROP TRIGGER tr_AuditDel
GO

CREATE TRIGGER tr_AuditDel
ON tb_Auditory
INSTEAD OF DELETE
AS
BEGIN
  -- 㤠����� �� �ᯨᠭ��
  update tb_Schedule set aid=NULL
    from tb_Schedule
      join Deleted on tb_Schedule.aid=Deleted.aid

  -- 㤠����� �� tb_Auditory
  delete tb_Auditory
    from tb_Auditory
      join Deleted on Deleted.aid=tb_Auditory.aid
END
GO

