CLASS ycl_mb112_toolset DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CONSTANTS co_city_not_existing TYPE i VALUE 9999999.

  TYPES: BEGIN OF ty_picked_for_city,
           city          TYPE ymb11_city,
           gifts_counter TYPE i,
         END OF ty_picked_for_city,
         ty_picked_for_cities TYPE STANDARD TABLE OF ty_picked_for_city WITH EMPTY KEY.

    METHODS calc_target_city
      IMPORTING
        i_gift TYPE int4
      RETURNING
        VALUE(result) TYPE ymb11_city.

    METHODS get_city_wth_most_gifts
      IMPORTING
        i_gifts TYPE ymb112_gifts
      RETURNING
        VALUE(result) TYPE ymb11_city.

    METHODS get_cities_wth_most_gifts
      IMPORTING
        i_gifts TYPE ymb112_gifts
      RETURNING
        VALUE(result) TYPE ty_picked_for_cities.


  PROTECTED SECTION.
  PRIVATE SECTION.

    TYPES:
      ty_picked_per_cities TYPE STANDARD TABLE OF ty_picked_for_city WITH DEFAULT KEY.

    METHODS fetch_gifts_per_cities
      IMPORTING
        i_gifts                    TYPE ymb112_gifts
      RETURNING
        value(result) TYPE ty_picked_per_cities.
ENDCLASS.



CLASS ycl_mb112_toolset IMPLEMENTATION.

  METHOD calc_target_city.
    DATA: res TYPE p LENGTH 8 DECIMALS 3.
    res = i_gift / 100.
    result = floor( res ).
  ENDMETHOD.


  METHOD get_city_wth_most_gifts.
    DATA(picked_per_cities) = fetch_gifts_per_cities( i_gifts ).

    SORT picked_per_cities BY gifts_counter DESCENDING.
    READ TABLE picked_per_cities ASSIGNING FIELD-SYMBOL(<result>) INDEX 1.
    IF sy-subrc = 0.
      result = <result>-city.
    ELSE.
      result = co_city_not_existing.
    ENDIF.
  ENDMETHOD.


  METHOD get_cities_wth_most_gifts.
    result = fetch_gifts_per_cities( i_gifts ).
    SORT result BY gifts_counter DESCENDING.
  ENDMETHOD.


  METHOD fetch_gifts_per_cities.
    LOOP AT i_gifts ASSIGNING FIELD-SYMBOL(<gift>).
      DATA(target_city) = calc_target_city( <gift>-gift ).
      READ TABLE result WITH KEY city = target_city ASSIGNING FIELD-SYMBOL(<picked>).
      IF sy-subrc = 0.
        <picked>-gifts_counter += 1.
      ELSE.
        DATA(picked) = VALUE ty_picked_for_city( city = target_city gifts_counter = 1 ).
        INSERT picked INTO result INDEX 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
