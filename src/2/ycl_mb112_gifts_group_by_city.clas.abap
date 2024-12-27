CLASS ycl_mb112_gifts_group_by_city DEFINITION
  PUBLIC
  INHERITING FROM ycl_mb112_gifts_mngr
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS: yif_mb112_gifts_mngr~load REDEFINITION,
      yif_mb112_gifts_mngr~unload REDEFINITION.
  PROTECTED SECTION.
  PRIVATE SECTION.


ENDCLASS.



CLASS ycl_mb112_gifts_group_by_city IMPLEMENTATION.

  METHOD yif_mb112_gifts_mngr~load.
    IF router->targeted_city IS NOT INITIAL.
      load_for_targetted_city( ).
      load_for_path_cities_frm_1st( ).
    ENDIF.
    load_simple_limited(
      i_max_weight = 110
      i_max_volume = 160
    ).

  ENDMETHOD.

  METHOD yif_mb112_gifts_mngr~unload.
    me->unload_simple( ).
    me->fetch_local_gifts( ).
  ENDMETHOD.







ENDCLASS.
