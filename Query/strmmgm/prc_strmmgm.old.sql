SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO


/*
  201  �롮� ��⮪�� ��� ��䥤��+���樯���� (sem, psem, type, kid, sbid)
  202  ᮧ����� ��⮪� (lid)
  203  㤠����� ��⮪� (strid)
  204  ���������� ��㯯� � ��⮪ (strid, lid)
  205  㤠����� ��㯯� �� ��⮪� (lid)
  206  �롮� ᢮������ ��㯯 (strid), �� �室��. � 㪠�. ��⮪
  207  �롮� ᢮���. ��㯯 (sem,psem,type,kid,sbid), �� �室��. � ��⮪�
  208  �롮ઠ ��� �� ���樯����+���樯���� ��ꥤ. �१ ��⮪� (sem,psem,type,kid,sbid)
*/
ALTER   PROCEDURE dbo.prc_StrmMgm
(
@case tinyint,
@sem tinyint,
@psem tinyint,
@type tinyint,
@kid bigint,
@sbid bigint,
@strid bigint,
@lid bigint
)
AS
SET NOCOUNT ON

declare
  @rows int,
  @lstrid bigint

-- �롮� ��⮪�� ��� ��䥤��+���樯���� (sem, psem, type, kid, sbid)
if @case=201
  select l.strid, l.lid, wp.grid, g.grName, wp.sbid, s.sbName, l.tid, t.tName
    from tb_Load l
      join tb_Workplan wp on l.wpid=wp.wpid
      left join tb_Group g on wp.grid=g.grid
      left join tb_Subject s on wp.sbid=s.sbid
      left join tb_Teacher t on l.tid=t.tid
    where wp.sem=@sem and l.psem=@psem and l.type=@type
      and l.strid in (select strid from tb_Load l1 join tb_Workplan w1 on l1.wpid=w1.wpid where w1.sbid=@sbid and strid is not null)

-- ᮧ����� ��⮪� (lid)
if @case=202
begin
  set @lstrid=0
  -- ᮧ����� ���. ��⮪�
  insert into tb_Stream(sem,psem,type,hours,kid)
    select wp.sem, l.psem, l.type, l.hours, wp.kid
      from tb_Load l
        join tb_Workplan wp on l.wpid=wp.wpid
      where lid=@lid
  -- ���������� ��㯯� � ����� ᮧ���. ��⮪
  select @lstrid=@@identity
  if @lstrid is not null
    update tb_Load set strid=@lstrid where lid=@lid
  return @lstrid
end

-- 㤠����� ��⮪� (strid)
if @case=203
begin
  set @rows=0
  delete tb_Stream where strid=@strid
  set @rows=@@rowcount
  return @rows
end

-- ���������� ��㯯� � ��⮪ (strid, lid)
if @case=204
begin
  update l set strid=s.strid
    from tb_Workplan wp
      join tb_Load l on wp.wpid=l.wpid and l.strid is null
      join tb_Stream s on wp.sem=s.sem and l.psem=s.psem and l.type=s.type
        and l.hours=s.hours and wp.kid=s.kid
    where l.lid=@lid and s.strid=@strid
      -- �஢�ઠ �� ������⢨� ��㯯� � ��⮪�
      and wp.grid not in (select grid from tb_Workplan w join tb_Load ld on w.wpid=ld.wpid where ld.strid=@strid)
  return @@rowcount
end

-- 㤠����� ��㯯� �� ��⮪� (lid)
if @case=205
begin
  set @rows=0
  -- �롮ઠ strid ��� lid
  select @lstrid=strid from tb_Load where lid=@lid
  if @lstrid is not null
  begin
    -- 㤠����� ��㯯� �� ��⮪�
    update tb_Load set strid=NULL where lid=@lid
    set @rows=@@rowcount
    -- �᫨ � ��⮪� ��� ����� ��㯯
    if not exists(select lid from tb_Load where strid=@lstrid)
    begin
      -- 㤠����� ��⮪�
      delete tb_Stream where strid=@strid
      set @rows=@rows+@@rowcount
    end
  end
  return @rows
end

-- �롮� ᢮������ ��㯯 (strid)
if @case=206
  select l.lid, g.grName, sb.sbName
    from tb_Workplan wp
      join tb_Group g on wp.grid=g.grid
      join tb_Subject sb on wp.sbid=sb.sbid
      join tb_Load l on wp.wpid=l.wpid
      join tb_Stream s on wp.sem=s.sem and l.psem=s.psem and l.type=s.type and l.hours=s.hours and wp.kid=s.kid
    where s.strid=@strid and l.strid is null
      and wp.grid not in (select grid from tb_Workplan w join tb_Load ld on w.wpid=ld.wpid where ld.strid=@strid)

-- �롮� ᢮���. ��㯯 (sem,psem,type,kid,sbid), �� �室��. � ��⮪�
if @case=207
  select l.lid, g.grName, s.sbName, l.hours
    from tb_Load l
      join tb_Workplan wp on l.wpid=wp.wpid
      join tb_Group g on wp.grid=g.grid
      join tb_Subject s on wp.sbid=s.sbid
    where wp.sem=@sem and l.psem=@psem and l.type=@type
      and wp.kid=@kid and wp.sbid=@sbid and l.strid is not null

-- �롮� ��� �� ���樯����
-- + ���樯����, ��ꥤ. �१ ��⮪� (sem,psem,type,kid,sbid)
if @case=208
  select ld.lid, wp.grid, g.grName, wp.sbid, s.sbName, ld.tid, t.tName, ld.strid, ld.hours
    from tb_Workplan wp
      join tb_Load ld on wp.wpid=ld.wpid
      join tb_Group g on wp.grid=g.grid
      join tb_Subject s on wp.sbid=s.sbid
      left join tb_Teacher t on ld.tid=t.tid
    where wp.sem=@sem and wp.kid=@kid and ld.psem=@psem and ld.type=@type
      and 
      (wp.sbid=@sbid or exists
        (
        select *
          from tb_Stream s
          where s.kid=wp.kid and strid=ld.strid
            and exists(
              select *
                from tb_Load l
                  join tb_Workplan w on l.wpid=w.wpid
                where l.strid=s.strid and w.sbid=@sbid
        )
      ))


/*
  select l.lid, wp.grid, g.grName, wp.sbid, sb.sbName, l.tid, t.tName, l.strid, l.hours
    from tb_Stream s
      join tb_Load l on s.strid=l.strid
      join tb_Workplan wp on l.wpid=wp.wpid
      join tb_Group g on wp.grid=g.grid
      join tb_Subject sb on wp.sbid=sb.sbid
      left join tb_Teacher t on l.tid=t.tid
    where s.kid=@kid and wp.[year]=@year and wp.sem=@sem
      and s.type=@type and s.psem=@psem
  union
  select l.lid, wp.grid, g.grName, wp.sbid, sb.sbName, l.tid, t.tName, l.strid, l.hours
    from tb_Load l
      join tb_Workplan wp on l.wpid=wp.wpid
      join tb_Group g on wp.grid=g.grid
      join tb_Subject sb on wp.sbid=sb.sbid
      left join tb_Teacher t on l.tid=t.tid
    where wp.[year]=@year and wp.sem=@sem and l.psem=@psem
      and l.type=@type and wp.kid=@kid and wp.sbid=@sbid
*/

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

