-- ���������� �������. ����������
/*
  900  ���-��� (wpid, psem, type, tid, strid, hours) / ���-��� (wpid, psem, type, hours)
*/
CREATE PROCEDURE prc_LoadMgm
(
@OperType int,
@lid bigint output,	-- id ��������
@wpId bigint,		-- id �.�.
@PSem tinyint,		-- �/�
@Type tinyint,		-- ��� ������� (1-������, 2-��������, 3-���.)
@tId bigint,		-- id ����-��
@strId bigint,		-- id ������
@Hours tinyint		-- ���� � ������
)
AS
begin
declare @res int
set @res=0

-- ���-���/���-��� (������ ����)
if @OperType=900
begin
  set @lid=null
  select @lid=lid from tb_Load where wpid=@wpId and PSem=@PSem and Type=@Type
  -- ���-���
  if @lid is null
  begin
    insert tb_Load (wpid, PSem, Type, tid, strid, Hours) values (@wpId, @PSem, @Type, @tId, @strId, @Hours)
    select @lid=@@identity
    if @@rowcount=1
      set @res=1
  end
  else
  begin
    update tb_Load set Hours=@Hours where lid=@lid
    set @res=2
  end
  return @res
end

end
GO
