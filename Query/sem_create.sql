-- создание семестра для учеб. года
-- RETURN_VALUE: 0 - успех, иначе год ошибки (>0)
-- -1 неправильное задание параметров
CREATE PROCEDURE dbo.sem_create
(
@sem tinyint,
@yNumber smallint,
@sm_start datetime,
@sm_end datetime,
@xm_start datetime,
@xm_end datetime
)
AS
BEGIN
  set nocount on

  declare @err int

  if (@sem is not null) and (@yNumber is not null)
    and (@sm_start is not null) and (@sm_end is not null)
    and (@xm_start is not null) and (@xm_end is not null)
  begin
    -- проверка пересечений семестов и сессий
    set @err=0
    begin tran
      select sem
        from tb_Semester
        where dbo.uf_inrange_d(@sm_start,sm_start,sm_end)=1
          or dbo.uf_inrange_d(@sm_end,sm_start,sm_end)=1
          or dbo.uf_inrange_d(@xm_start,xm_start,xm_end)=1
          or dbo.uf_inrange_d(@xm_end,xm_start,xm_end)=1
      
      insert tb_Semester (sem, yNumber, sm_start, sm_end, xm_start, xm_end)
        values (@sem, @yNumber, @sm_start, @sm_end, @xm_start, @xm_end)
      select @err=@@error
    if @err=0
      commit tran
    else
      rollback tran
  end
  else set @err=-1

  return @err
END