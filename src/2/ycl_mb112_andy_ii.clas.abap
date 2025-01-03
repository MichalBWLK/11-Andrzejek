CLASS ycl_mb112_andy_ii DEFINITION
  PUBLIC
  INHERITING FROM ycl_mb112_andy
  CREATE PUBLIC .

  PUBLIC SECTION.
  PROTECTED SECTION.
    METHODS call_algorithms REDEFINITION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ycl_mb112_andy_ii IMPLEMENTATION.
  METHOD call_algorithms.
    "unload
    gifts->unload_simple( ).
    IF gifts->unloading_happened = abap_true.
      gifts->unload_all( ).
    ENDIF.

    "load
    IF router->targeted_city IS NOT INITIAL.
      gifts->load_for_targetted_city( ).
      gifts->load_for_path_cities_frm_1st( ).
    ENDIF.
    gifts->load_for_already_loaded( ).
    gifts->load_most_for_one_limited(
      i_max_weight = 160
      i_max_volume = 250
    ).
*    gifts->load_simple_limited(
*      i_max_weight = 190
*      i_max_volume = 280
*    ).

    "select next destination city

    IF router->route IS NOT INITIAL.
      router->follow_path( ).
    ELSE.
      router->set_rt_to_city_by_most_gifts( ).
      IF router->route IS INITIAL.
        router->set_rt_closst_ct_wth_av_gift( ).
      ENDIF.
      IF router->route IS NOT INITIAL.
        gifts->load_for_targetted_city( ).
        gifts->load_for_path_cities_frm_1st( ).
        router->follow_path( ).
      ELSE.
        IF sy-index MOD 3 = 0.
          router->select_random_city( ).
        ELSE.
          router->select_closest_city( ).
        ENDIF.
        gifts->load_for_next_city( ).
      ENDIF.
    ENDIF.


    journal->set_next_city( router->next_connection->dest ).

  ENDMETHOD.

ENDCLASS.
