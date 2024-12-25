CLASS ycl_mb11_nav_gifts_in_next_c DEFINITION
  PUBLIC
  INHERITING FROM ycl_mb11_navigator_random
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        i_journal  TYPE REF TO ycl_mb11_journal
        i_scenario TYPE int2
        i_path_max_depth TYPE i.

    METHODS select_city REDEFINITION.

  PROTECTED SECTION.
    TYPES: BEGIN OF: ty_city_vs_gifts,
        city TYPE ymb11_city,
        gifts_counter TYPE i,
           END OF ty_city_vs_gifts,
      ty_cities_vs_gifts TYPE STANDARD TABLE OF ty_city_vs_gifts.

    TYPES: BEGIN OF ty_connection,
           src TYPE ymb11_city,
           dest TYPE ymb11_city,
           END OF ty_connection,
           ty_path TYPE STANDARD TABLE OF ty_connection WITH EMPTY KEY.

    DATA: path_max_depth TYPE i,
          path TYPE ty_path.

    METHODS find_city_gifts_qty
      IMPORTING i_city TYPE ymb11_city
      RETURNING VALUE(result) TYPE i.

  PRIVATE SECTION.
ENDCLASS.



CLASS ycl_mb11_nav_gifts_in_next_c IMPLEMENTATION.

  METHOD constructor.
    super->constructor( i_journal = i_journal i_scenario = i_scenario ).
    path_max_depth = i_path_max_depth.
  ENDMETHOD.


  METHOD select_city.
    DATA: cities_wth_gifts TYPE ty_cities_vs_gifts,
          found TYPE i.

    SELECT FROM @all_connections AS connections
      FIELDS src, dest, time
      WHERE src = @last_connection->dest
      INTO TABLE @data(available_trains).
    LOOP AT available_trains ASSIGNING FIELD-SYMBOL(<train>).
      found = find_city_gifts_qty( <train>-dest ).
      IF found > 0.
        APPEND INITIAL LINE TO cities_wth_gifts ASSIGNING FIELD-SYMBOL(<city>).
        <city>-city = <train>-dest.
        <city>-gifts_counter = found.
      ENDIF.
    ENDLOOP.
    IF cities_wth_gifts IS NOT INITIAL.
      SORT cities_wth_gifts BY gifts_counter DESCENDING.

      READ TABLE all_connections WITH TABLE KEY conn COMPONENTS src = last_connection->dest
                                                                dest = cities_wth_gifts[ 1 ]-city
                                 REFERENCE INTO new_connection.
    ELSE.
      select_randomly( ).
*      CATCH cx_abap_random..
    ENDIF.

    journal->set_next_city( new_connection->dest ).
  ENDMETHOD.


  METHOD find_city_gifts_qty.
    LOOP AT loaded_gifts ASSIGNING FIELD-SYMBOL(<gift>).
      IF i_city = calc_target_city( <gift>->gift ).
        result += 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
