declare
  @case tinyint,
  @sem tinyint,
  @psem tinyint,
  @type tinyint,
  @kid bigint,
  @sbid bigint,
  @strid bigint,
  @lid bigint

set @sem=1
set @psem=1
set @type=1
set @kid=21
set @sbid=50

-- ���. ��६.
declare
  @lstrid bigint,
  @lhours tinyint

-- �롮� ��⮪�� ��䥤�� (year,sem,psem,type,kid,sbid)
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
end

-- 㤠����� ��⮪� (strid)
if @case=203
  delete tb_Stream where strid=@strid

-- ���������� ��㯯� � ��⮪ (strid, lid)
if @case=204
  update l set strid=s.strid
    from tb_Workplan wp
      join tb_Load l on wp.wpid=l.wpid and l.strid is null
      join tb_Stream s on wp.sem=s.sem and l.psem=s.psem and l.type=s.type
        and l.hours=s.hours and wp.kid=s.kid
    where l.lid=@lid and s.strid=@strid
      -- �஢�ઠ �� ������⢨� ��㯯� � ��⮪�
      and wp.grid not in (select grid from tb_Workplan w join tb_Load ld on w.wpid=ld.wpid where ld.strid=@strid)


-- 㤠����� ��㯯� �� ��⮪� (lid)
if @case=205
begin
  select @lstrid=strid from tb_Load where lid=@lid
  if @lstrid is not null
  begin
    update tb_Load set strid=null where lid=@lid
    if not exists(select lid from tb_Load where strid=@lstrid)
      delete tb_Stream where strid=@lstrid
  end
end

-- �롮� ᢮������ ��㯯 (strid), �� �室��. � ���. ��⮪
if @case=206
  select l.lid, g.grName, sb.sbName
    from tb_Workplan wp
      join tb_Group g on wp.grid=g.grid
      join tb_Subject sb on wp.sbid=sb.sbid
      join tb_Load l on wp.wpid=l.wpid
      join tb_Stream s on wp.sem=s.sem
        and l.psem=s.psem and l.type=s.type and l.hours=s.hours and wp.kid=s.kid
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

