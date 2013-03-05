/*
  �஢�ઠ �६��� ��� �/����
  - 1 ᮡ�⨥ � ���� ��� ���. �� (@hgrp=0)
  - �����६������� ��� ��� ����� (@hgrp=1)
  - ��� ��㣨� �/���� ����� ��������. �/����.
  RETURN_VALUE: 1 - �ᯥ�
*/
CREATE FUNCTION dbo.uf_chktime_xm
(
@wpid bigint,
@xmtype tinyint,
@xmtime datetime,
@hgrp tinyint
)
RETURNS tinyint AS
BEGIN
  declare
    @l_grid bigint,
    @l_time datetime,
    @l_start datetime,
    @l_end datetime,
    @res tinyint

  set @res=1

  select @l_grid=grid from tb_Workplan where wpid=@wpid
  set @l_start=dbo.uf_date(@xmtime)
  set @l_end=dateadd(dd,1,@l_start)

  if(@hgrp=0)
  begin
    -- ���� �/���� � ����
    if exists
    (
      select xm.wpid
        from tb_Exam xm
          join tb_Workplan w on w.wpid=xm.wpid and w.wpid!=@wpid and w.grid=@l_grid
        where xmtime between @l_start and @l_end
    )
      set @res=0
  end
  else
  begin
    -- �஢�ઠ �����६������ � ��� ����㯯
    if exists
    (
      select xm.wpid
        from tb_Exam xm
          join tb_Workplan w on w.wpid=xm.wpid and w.grid=@l_grid and xm.wpid!=@wpid
        where xmtime between @l_start and @l_end and (hgrp=0 or xmtime!=@xmtime)
    )
      set @res=0

    -- �஢�ઠ ������⢨� ����祭�� �/���� ����� ��㣨��
    if(@res=1)
      if exists
      (
        select xm.wpid
          from tb_Exam xm
            join tb_Exam cs on cs.wpid=xm.wpid and cs.xmtype!=xm.xmtype and cs.xmtype=1
            join tb_Workplan w on w.wpid=xm.wpid and w.grid=@l_grid and xm.wpid!=@wpid
          where @xmtype between cs.xmtime and xm.xmtime
      )
        set @res=0
  end

  return @res
END