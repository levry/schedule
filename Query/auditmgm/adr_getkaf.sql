-- �롮ઠ �㤨�਩ 㪠�. ��䥤��
declare
  @kid bigint

set @kid=null

select aid, aName, kid, Capacity from tb_Auditory
  where kid=@kid or ((@kid is null) and (kid is null))