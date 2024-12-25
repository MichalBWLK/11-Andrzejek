CLASS ycl_mb112_rout_go2_most_gifts DEFINITION
  PUBLIC
  INHERITING FROM ycl_mb112_router
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS: select_next_city REDEFINITION.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ycl_mb112_rout_go2_most_gifts IMPLEMENTATION.

  METHOD select_next_city.
    IF sy-index MOD 3 = 0.
      me->select_random_city( ).
    ELSE.
      me->select_closest_city( ).
    ENDIF.
    journal->set_next_city( next_connection->dest ).
  ENDMETHOD.

ENDCLASS.
