CLASS ycl_mb112_rout_go2_most_gifts DEFINITION
  PUBLIC
  INHERITING FROM ycl_mb112_router
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS: select_next_city REDEFINITION.
  PROTECTED SECTION.
    DATA: targeted_city TYPE ymb11_city.
    DATA: route TYPE ycl_mb11_graph_d=>ty_steps.

    METHODS select_city_by_most_gifts.

  PRIVATE SECTION.

ENDCLASS.



CLASS ycl_mb112_rout_go2_most_gifts IMPLEMENTATION.

  METHOD select_next_city.
    IF sy-index MOD 3 = 0.
      me->select_random_city( ).
    ELSE.
      me->select_closest_city( ).
    ENDIF.

    select_city_by_most_gifts( ).
    journal->set_next_city( next_connection->dest ).
  ENDMETHOD.


  METHOD select_city_by_most_gifts.
    IF targeted_city IS NOT INITIAL.
      "follow the already choosen path
      READ TABLE route WITH KEY from = last_connection->dest ASSIGNING FIELD-SYMBOL(<step>).
      READ TABLE all_connections WITH TABLE KEY binding COMPONENTS src = <step>-from
                                                                   dest = <step>-to
                                 REFERENCE INTO next_connection.
      IF next_connection->dest = targeted_city.
        CLEAR: targeted_city, route.
      ENDIF.

    ENDIF.

  ENDMETHOD.

ENDCLASS.
