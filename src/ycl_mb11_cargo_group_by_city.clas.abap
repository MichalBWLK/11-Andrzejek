CLASS ycl_mb11_cargo_group_by_city DEFINITION
  PUBLIC
  INHERITING FROM ycl_mb11_cargo_simple
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS: yif_mb11_cargo~load REDEFINITION,
      yif_mb11_cargo~unload REDEFINITION.
  PROTECTED SECTION.
    METHODS load_grouping_by_city.





  PRIVATE SECTION.

ENDCLASS.



CLASS ycl_mb11_cargo_group_by_city IMPLEMENTATION.

  METHOD yif_mb11_cargo~load.
    load_grouping_by_city( ).
  ENDMETHOD.


  METHOD yif_mb11_cargo~unload.
    unload_simple( ).
  ENDMETHOD.


  METHOD load_grouping_by_city.
    "Dobierz tak, żeby bylo jak najwiecej dla jednego miasta
    IF is_fully_loaded( ) = abap_true.
      RETURN.
    ENDIF.

    SELECT
      FROM @all_gifts AS all_gifts
      FIELDS gift, weight, volume, location
      WHERE location = @current_location
      INTO TABLE @DATA(local_gifts).
    "First take gifts for the cities, for which we already have some
    LOOP AT cities_packed ASSIGNING FIELD-SYMBOL(<city_packed>).
      LOOP AT local_gifts ASSIGNING FIELD-SYMBOL(<local_gift>) WHERE gift BETWEEN <city_packed>-city * 100 AND <city_packed>-city * 100 + 99 .
        IF <local_gift>-weight <= max_weight - loaded_weight AND <local_gift>-volume <= max_volume - loaded_volume.
          READ TABLE all_gifts REFERENCE INTO DATA(gift) WITH TABLE KEY gifts COMPONENTS gift = <local_gift>-gift.
          load_gift( gift ).
        ENDIF.
        IF is_fully_loaded( ) = abap_true.
          RETURN.
        ENDIF.
      ENDLOOP.
    ENDLOOP.


  ENDMETHOD.

ENDCLASS.
