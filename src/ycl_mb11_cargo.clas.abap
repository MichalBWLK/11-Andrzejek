CLASS ycl_mb11_cargo DEFINITION
  PUBLIC
  ABSTRACT
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES yif_mb11_cargo
      ABSTRACT METHODS: load unload.

    ALIASES: unloading_happened FOR yif_mb11_cargo~unloading_happened,
             loading_happened FOR yif_mb11_cargo~loading_happened,
             load FOR yif_mb11_cargo~load,
             unload FOR yif_mb11_cargo~unload,
             set_location FOR yif_mb11_cargo~set_location,
             get_remaining_gifts FOR yif_mb11_cargo~get_remaining_gifts,
             clear_flags FOR yif_mb11_cargo~clear_flags.

    METHODS constructor
      IMPORTING
        i_journal  TYPE REF TO ycl_mb11_journal
        i_scenario TYPE int2.

  PROTECTED SECTION.
    TYPES: ty_gift  TYPE REF TO ymb11gifts,
           ty_gifts TYPE TABLE OF ty_gift.

    CONSTANTS: max_weight TYPE int2 VALUE 190,
               max_volume TYPE int2 VALUE 280.

    DATA: journal TYPE REF TO ycl_mb11_journal.

    DATA: current_location TYPE ymb11_city .

    DATA: all_gifts       TYPE ycl_mb11_input_reader=>ty_gifts.

    DATA: loaded_gifts  TYPE ty_gifts,
          loaded_weight TYPE int2,
          loaded_volume TYPE int2.

    METHODS calc_target_city
      IMPORTING
        i_gift        TYPE int4
      RETURNING
        VALUE(result) TYPE ymb11_city.


  PRIVATE SECTION.

ENDCLASS.



CLASS ycl_mb11_cargo IMPLEMENTATION.

  METHOD constructor.
    journal = i_journal.
    DATA(input) = NEW ycl_mb11_input_reader( i_scenario ).
    all_gifts = input->get_gifts( ).

  ENDMETHOD.


  METHOD set_location.
    current_location = i_location.
  ENDMETHOD.


  METHOD get_remaining_gifts.
    result = me->all_gifts.
  ENDMETHOD.


  METHOD calc_target_city.
    result = floor( i_gift / 100 ).
  ENDMETHOD.

  METHOD yif_mb11_cargo~clear_flags.
    clear: loading_happened, unloading_happened.
  ENDMETHOD.

ENDCLASS.
