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

ENDCLASS.
