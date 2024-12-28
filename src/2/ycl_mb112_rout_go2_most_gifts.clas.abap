CLASS ycl_mb112_rout_go2_most_gifts DEFINITION
  PUBLIC
  INHERITING FROM ycl_mb112_router
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS: select_next_city REDEFINITION.
  PROTECTED SECTION.





  PRIVATE SECTION.
    METHODS follow_path.
    METHODS set_city_path_by_most_gifts.

ENDCLASS.



CLASS ycl_mb112_rout_go2_most_gifts IMPLEMENTATION.

  METHOD select_next_city.
    TRY.
        IF targeted_city IS NOT INITIAL.
          follow_path( ).
        ELSE.
          set_city_path_by_most_gifts( ).
          follow_path( ).
        ENDIF.
      CATCH ycx_mb12_path_fail.
        IF sy-index MOD 3 = 0.
          me->select_random_city( ).
        ELSE.
          me->select_closest_city( ).
        ENDIF.
    ENDTRY.
    journal->set_next_city( next_connection->dest ).
  ENDMETHOD.


  METHOD follow_path.
    READ TABLE route WITH KEY from = last_connection->dest ASSIGNING FIELD-SYMBOL(<step>).
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE ycx_mb12_path_fail.
    ENDIF.
    READ TABLE all_connections WITH TABLE KEY binding COMPONENTS src = <step>-from
                                                                 dest = <step>-to
                               REFERENCE INTO next_connection.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE ycx_mb12_path_fail.
    ENDIF.

    IF next_connection->dest = targeted_city.
      CLEAR: targeted_city, route.
    ENDIF.
  ENDMETHOD.


  METHOD set_city_path_by_most_gifts.
    gifts_mngr->get_loaded_gifts( IMPORTING result = DATA(loaded_gifts) ).
    targeted_city = toolset->get_city_wth_most_gifts( loaded_gifts ).
    IF targeted_city = toolset->co_city_not_existing.
      RAISE EXCEPTION TYPE ycx_mb12_path_fail.
    ENDIF.
    route = dijkstra->find_shortest_path(
              i_from = last_connection->dest
              i_to   = targeted_city
            ).
  ENDMETHOD.

ENDCLASS.
