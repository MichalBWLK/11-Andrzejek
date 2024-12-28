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
    load_for_already_loaded( ).
    load_most_for_one_limited(
      i_max_weight = 190
      i_max_volume = 280
    ).
    load_simple_limited(
      i_max_weight = 172
      i_max_volume = 256
    ).

  ENDMETHOD.

  METHOD yif_mb112_gifts_mngr~unload.
    me->unload_simple( ).
    IF unloading_happened = abap_true.
      me->unload_all( ).
    ENDIF.
    me->fetch_local_gifts( ).
  ENDMETHOD.




ENDCLASS.
