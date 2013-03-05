declare
@wpId bigint,-- id �.�.
@Lect tinyint,-- ������
@Prct tinyint,-- ��������
@Labs tinyint,-- ���.
@PSem tinyint-- �/�

-- local
declare
@lid bigint,
@res int

set @res=0
-- ���������� ������
set @lid=null
if isnull(@Lect,0)>0
begin
  select @lid=lid from tb_Load where wpid=@wpId and PSem=@PSem and Type=1
  if @lid is null
    insert tb_Load (wpid, PSem, Type, Hours) values (@wpId, @PSem, 1, @Lect)
  else
    update tb_Load set Hours=@Lect where lid=@lid
end
else delete from tb_Load where wpid=@wpId and PSem=@PSem and Type=1
set @res=@@rowcount

-- ���������� �������
set @lid=null
if isnull(@Prct,0)>0
begin
  select @lid=lid from tb_Load where wpid=@wpId and PSem=@PSem and Type=2
  if @lid is null
    insert tb_Load (wpid, PSem, Type, Hours) values (@wpId, @PSem, 2, @Prct)
  else
    update tb_Load set Hours=@Prct where lid=@lid
end
else delete from tb_Load where wpid=@wpId and PSem=@PSem and Type=2
set @res=@res+@@rowcount

-- ���������� ���.
set @lid=null
if isnull(@Labs,0)>0
begin
  select @lid=lid from tb_Load where wpid=@wpId and PSem=@PSem and Type=3
  if @lid is null
    insert tb_Load (wpid, PSem, Type, Hours) values (@wpId, @PSem, 3, @Labs)
  else
    update tb_Load set Hours=@Labs where lid=@lid
end
else delete from tb_Load where wpid=@wpId and PSem=@PSem and Type=3
set @res=@res+@@rowcount

