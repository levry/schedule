/*
 101 выбор кафедр
 102 выбор групп кафедры (kid)
 103 выбор дисциплин кафедры (year, sem, kid)
 104 выбор дисциплин группы (year, sem, grid)
 108 выбор существущих семестров
*/

declare
  @OperType int,
  @Year char(4),
  @Sem smallint,
  @kid bigint,
  @grid bigint
  
-- выбор кафедр
if @OperType=101
begin
  select kid, kName from tb_Kafedra order by kName
end

-- выбор групп кафедры
if @OperType=102
begin
  select grid, grName from tb_Group where kid=@kid order by grName
end

-- выбор дисциплин кафедры (year, sem, kid)
if @OperType=103
begin
  select distinct Sbj.sbid, sbName
    from tb_Subject Sbj
      join tb_Workplan Wp on Sbj.sbid=Wp.sbid
    where Wp.[Year]=@Year and Wp.Sem=@Sem and Wp.kid=@kid
    order by sbName
end

-- выбор дисциплин группы (year, sem, grid)
if @OperType=104
begin
  select Sbj.sbid, sbName 
    from tb_Subject Sbj
      join tb_Workplan Wp on Sbj.sbid=Wp.sbid
    where Wp.[Year]=@Year and Wp.Sem=@Sem and Wp.grid=@grid
    order by sbName
end

-- выбор существ. семестров
if @OperType=108
begin
  select distinct [Year], Sem from tb_Workplan
end