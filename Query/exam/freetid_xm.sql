/*
  Проверка занятости преп-лей (расписание экз/конс)
  RETURN_VALUE: 0-занят 1-свободен
*/
CREATE FUNCTION dbo.uf_freetid_xm
(
@wpid bigint,
@start datetime,
@end datetime
)
RETURNS tinyint AS
BEGIN
  declare @res tinyint

  if exists
  (
    select xm.wpid
      from tb_Exam xm
        join tb_load l on l.wpid=xm.wpid and l.type=1
      where exists(select tid from tb_Load where wpid=@wpid and tid=l.tid and type=1)
        and ((@start>=xmstart and @start<=xmend) or (@end>=xmstart and @end<=xmend)
        or (xmstart>=@start and xmstart<=@end))
  )
    set @res=0
  else set @res=1

  return @res
END