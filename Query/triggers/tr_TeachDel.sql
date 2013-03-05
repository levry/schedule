-- =============================================
-- Create basic Instead Of Trigger
-- =============================================
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'tr_TeachDel' 
	   AND 	  type = 'TR')
    DROP TRIGGER tr_TeachDel
GO

CREATE TRIGGER tr_TeachDel
ON tb_Teacher
INSTEAD OF DELETE
AS
BEGIN
  -- 㤠����� �� �ᯨᠭ��
  update tb_Schedule set tid=NULL
    from tb_Schedule
      join Deleted on Deleted.tid=tb_Schedule.tid

  -- 㤠����� �� ����㧮�
  update tb_Load set tid=NULL
    from tb_Load
      join Deleted on Deleted.tid=tb_Load.tid

  -- 㤠����� �� tb_Teacher
  delete tb_Teacher
    from tb_Teacher
      join Deleted on Deleted.tid=tb_Teacher.tid
END
GO

