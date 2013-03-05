/*
  ������ �࠭. ��楤���
*/
CREATE PROCEDURE dbo.<procname>
(
...
)
AS
BEGIN
  set nocount on

  -- TODO: �஢�ઠ �室. ��ࠬ-஢ (-1)
  if(...) return -1

  declare @err int, @trans int
  select @err=0, @trans=@@trancount

  if(@trans=0) begin tran
    else save tran <savename>

  if(@err!=0)
  begin
    if(@trans=0) rollback tran
      else rollback tran <savename>
  end
  else if(@trans=0) commit tran

  return @err
END
