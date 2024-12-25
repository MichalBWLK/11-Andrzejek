CLASS ycl_mb11_cargo DEFINITION
  PUBLIC
  ABSTRACT
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES yif_mb11_cargo
      ABSTRACT METHODS: load unload.

    ALIASES: ty_gift FOR yif_mb11_cargo~ty_gift,
             ty_gifts FOR yif_mb11_cargo~ty_gifts.

    ALIASES: ty_packed_per_city FOR yif_mb11_cargo~ty_packed_per_city,
             ty_packed_for_cities FOR yif_mb11_cargo~ty_packed_for_cities,
             cities_packed FOR yif_mb11_cargo~cities_packed.

    ALIASES: unloading_happened FOR yif_mb11_cargo~unloading_happened,
             loading_happened FOR yif_mb11_cargo~loading_happened,
             navigator FOR yif_mb11_cargo~navigator.

    ALIASES: load FOR yif_mb11_cargo~load,
             unload FOR yif_mb11_cargo~unload,
             set_location FOR yif_mb11_cargo~set_location,
             get_remaining_gifts FOR yif_mb11_cargo~get_remaining_gifts,
             clear_flags FOR yif_mb11_cargo~clear_flags,
             get_loaded_gifts FOR yif_mb11_cargo~get_loaded_gifts,
             set_navigator FOR yif_mb11_cargo~set_navigator.



    METHODS constructor
      IMPORTING
        i_journal  TYPE REF TO ycl_mb11_journal
        i_scenario TYPE int2.

  PROTECTED SECTION.


    CONSTANTS: max_weight TYPE int2 VALUE 190,
               max_volume TYPE int2 VALUE 280.

    DATA: journal TYPE REF TO ycl_mb11_journal.

    DATA: current_location TYPE ymb11_city .

    DATA: all_gifts       TYPE ycl_mb11_input_reader=>ty_gifts.

    DATA: loaded_gifts  TYPE ty_gifts,
          loaded_weight TYPE int2,
          loaded_volume TYPE int2.

    METHODS check_packed_cities
      RETURNING VALUE(result) TYPE yif_mb11_cargo=>ty_packed_for_cities.

    METHODS calc_target_city
      IMPORTING
        i_gift        TYPE int4
      RETURNING
        VALUE(result) TYPE ymb11_city.

    METHODS is_fully_loaded
      RETURNING VALUE(result) TYPE abap_bool.
    METHODS load_gift
      IMPORTING
        i_gift TYPE REF TO ymb11gifts.
    METHODS unload_gift
      IMPORTING
        i_gift TYPE REF TO ymb11gifts
        i_line TYPE sy-tabix.


  PRIVATE SECTION.

ENDCLASS.



CLASS ycl_mb11_cargo IMPLEMENTATION.


  METHOD constructor.
    journal = i_journal.
    DATA(input) = NEW ycl_mb11_input_reader( i_scenario ).
    all_gifts = input->get_gifts( ).
  ENDMETHOD.


  METHOD load_gift.
    APPEND i_gift TO loaded_gifts.
    i_gift->location = 999999999.
    journal->add_gift_picked( i_gift->gift ).
    loaded_volume += i_gift->volume.
    loaded_weight += i_gift->weight.
    loading_happened = abap_true.
  ENDMETHOD.


  METHOD unload_gift.
    i_gift->location = current_location.
    journal->add_gift_left( i_gift->gift ).
    loaded_volume -= i_gift->volume.
    loaded_weight -= i_gift->weight.
    DELETE loaded_gifts INDEX i_line.
    unloading_happened = abap_true.
  ENDMETHOD.


  METHOD set_location.
    current_location = i_location.
  ENDMETHOD.


  METHOD set_navigator.
    navigator = i_navigator.
  ENDMETHOD.


  METHOD get_remaining_gifts.
    result = me->all_gifts.
  ENDMETHOD.


  METHOD calc_target_city.
    result = floor( i_gift / 100 ).
  ENDMETHOD.


  METHOD clear_flags.
    clear: loading_happened, unloading_happened.
  ENDMETHOD.


  METHOD get_loaded_gifts.
    result = loaded_gifts.
  ENDMETHOD.

  METHOD is_fully_loaded.
    IF loaded_volume + 5 >= max_volume OR loaded_weight + 5 >= max_weight.
      result = abap_true.
    ENDIF.
  ENDMETHOD.


  METHOD check_packed_cities.
    LOOP AT loaded_gifts ASSIGNING FIELD-SYMBOL(<gift>).
      DATA(target_city) = me->calc_target_city( <gift>->gift ).
      READ TABLE result WITH KEY city = target_city ASSIGNING FIELD-SYMBOL(<packed>).
      IF sy-subrc = 0.
        <packed>-gifts_counter += 1.
      ELSE.
        DATA(packed_city) = VALUE ty_packed_per_city( city = target_city  gifts_counter = 1 ).
        INSERT packed_city INTO result INDEX 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
