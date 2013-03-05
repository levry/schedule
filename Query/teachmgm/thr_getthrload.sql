-- выбор преп-лей для нагрузки (lid)

declare
  @lid bigint

  select t.tid, t.tName
    from tb_Load l
      join tb_Workplan wp on l.wpid=wp.wpid
      join tb_Teacher t on wp.kid=t.kid
    where lid=@lid
