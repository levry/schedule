-- выборка преп-лей кафедры (kid)
declare
  @kid bigint

  select * from tb_Teacher where kid=@kid
