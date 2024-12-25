CLASS ycl_mb112_gift_city_tools DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS calc_target_city
      IMPORTING
        i_gift TYPE int4
      RETURNING
        VALUE(result) TYPE ymb11_city.


  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ycl_mb112_gift_city_tools IMPLEMENTATION.

  METHOD calc_target_city.
    result = floor( i_gift / 100 ).
  ENDMETHOD.

ENDCLASS.
