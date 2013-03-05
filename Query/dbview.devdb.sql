/*
 101 ����� ������
 102 ����� ����� ������� (kid)
 103 ����� ��������� ������� (year, sem, kid)
 104 ����� ��������� ������ (year, sem, grid)
 108 ����� ����������� ���������
*/

declare
  @OperType int,
  @Year char(4),
  @Sem smallint,
  @kid bigint,
  @grid bigint
  
-- ����� ������
if @OperType=101
begin
  select kid, kName from tb_Kafedra order by kName
end

-- ����� ����� �������
if @OperType=102
begin
  select grid, grName from tb_Group where kid=@kid order by grName
end

-- ����� ��������� ������� (year, sem, kid)
if @OperType=103
begin
  select distinct Sbj.sbid, sbName
    from tb_Subject Sbj
      join tb_Workplan Wp on Sbj.sbid=Wp.sbid
    where Wp.[Year]=@Year and Wp.Sem=@Sem and Wp.kid=@kid
    order by sbName
end

-- ����� ��������� ������ (year, sem, grid)
if @OperType=104
begin
  select Sbj.sbid, sbName 
    from tb_Subject Sbj
      join tb_Workplan Wp on Sbj.sbid=Wp.sbid
    where Wp.[Year]=@Year and Wp.Sem=@Sem and Wp.grid=@grid
    order by sbName
end

-- ����� �������. ���������
if @OperType=108
begin
  select distinct [Year], Sem from tb_Workplan
end