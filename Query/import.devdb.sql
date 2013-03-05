declare
@spkName varchar(50),  -- ������� ����-��
@spCode varchar(10),   -- ��� ����-��
@spName varchar(50),   -- ����. ����-��
@grName varchar(10),   -- ����. ������
@Studs smallint,       -- ����� ���������
@sbName varchar(100),  -- ����. ����������

@wpId bigint,       -- id �.�.
@Sem tinyint,       -- �������
@tSem tinyint,      -- ������. �������
@sbCode varchar(20),-- ������ ����������
@WP1 tinyint,       -- ������ � 1 �/�
@WP2 tinyint,       -- ������ �� 2 �/�
@TotalHLP int,      -- ����� �� ��. �����
@TotalAHLP int,     -- ����� �� ��. ������ (���. ��������)
@Compl int,         -- �������� �����
@Kp tinyint,        -- ����. �������
@Kr tinyint,        -- ����. ������ 
@Rg tinyint,        -- ������. ����. ������
@Cr tinyint,        -- �����. ������
@Hr tinyint,        -- ���. ������
@Koll tinyint,      -- �����������
@Z tinyint,         -- �����
@E tinyint,         -- �������
@lkName varchar(50) -- ����. �������, ���. ����������

--@PSem tinyint,   -- �/�
--@Type tinyint,   -- ���
--@Hours tinyint   -- ����� � ������

-- ���. �����.
declare
@spkid bigint,  -- id ������� ����-��
@wkid bigint,   -- id �������, ���. ����������
@spid bigint,   -- id ����-��
@grid bigint,   -- id ������
@sbid bigint,   -- id ��������
--@wpid bigint,   -- id �.�.
@res int        -- ���-�

  set @res=0

  -- ���������� ������
  set @spkid=null
  set @wkid=null
  -- ������� ����-��
  select @spkid=kid from tb_Kafedra where kName=@spkName
  if @spkid is null
  begin
    insert tb_Kafedra (kName) values (@spkName)
    select @spkId=@@identity
    set @res=@res+2
  end
  -- ���-��, ���. ����������
  select @wkid=kid from tb_Kafedra where kName=@lkName
  if @wkid is null
  begin
    insert tb_Kafedra (kName) values (@lkName)
    select @wkId=@@identity
    set @res=@res+4
  end

  -- ���������� �������������
  set @spid=null
  select @spid=spid from tb_Special 
    where kid=@spkid and spCode=@spCode and spName=@spName
  if @spid is null
  begin
    insert tb_Special (kid, spCode, spName) values (@spkid, @spCode, @spName)
    select @spid=@@identity
    set @res=@res+8
  end
  
  -- ���������� ������
  set @grid=null
  select @grid=grid from tb_Group where spid=@spid and grName=@grName
  if @grid is null
  begin
    insert tb_Group (spid, grName, studs) values (@spid, @grName, @Studs)
    select @grid=@@identity
    set @res=@res+16
  end

  -- ���������� ����������
  set @sbid=null
  select @sbid=sbid from tb_Subject where sbName=@sbName
  if @sbid is null
  begin
    insert tb_Subject (sbName) values (@sbName)
    select @sbid=@@identity
    set @res=@res+32
  end

  -- ���-�/���-��� �.�.
  set @wpId=null
  select @wpId=wpid from tb_Workplan
    where grid=@grid and sbid=@sbid and Sem=@Sem
  -- ���-���
  if @wpId is null
  begin
    insert tb_Workplan (grid, sbid, kid, Sem, tSem, sbCode, WP1, WP2, TotalHLP, TotalAHLP, Compl, Kp, Kr, Rg, Cr, Hr, Koll, Z, E)
      values (@grid, @sbid, @wkid, @Sem, @tSem, @sbCode, @WP1, @WP2, @TotalHLP, @TotalAHLP, @Compl, @Kp, @Kr, @Rg, @Cr, @Hr, @Koll, @Z, @E)
    select @wpId=@@identity
    if @@rowcount=1
      set @res=@res+65
  end
  -- ���-���
  else
  begin
    update tb_Workplan set kid=@wkid, tSem=@tSem, sbCode=@sbCode, WP1=@WP1, WP2=@WP2,
        TotalHLP=@TotalAHLP, Compl=@Compl, Kp=@Kp, Kr=@Kr, Rg=@Rg, Cr=@Cr, Hr=@Hr,
        Koll=@Koll, Z=@Z, E=@E
      where wpid=@wpId
    if @@rowcount=1
      set @res=@res+1
  end  