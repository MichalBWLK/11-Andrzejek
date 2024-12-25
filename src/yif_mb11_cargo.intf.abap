INTERFACE yif_mb11_cargo
  PUBLIC .
  TYPES: ty_gift  TYPE REF TO ymb11gifts,
         ty_gifts TYPE TABLE OF ty_gift WITH EMPTY KEY,
         BEGIN OF ty_packed_per_city,
           city          TYPE ymb11_city,
           gifts_counter TYPE i,
         END OF ty_packed_per_city,
         ty_packed_for_cities TYPE STANDARD TABLE OF ty_packed_per_city WITH EMPTY KEY.

  DATA: unloading_happened TYPE abap_bool READ-ONLY,
        loading_happened TYPE abap_bool READ-ONLY,
        cities_packed TYPE ty_packed_for_cities READ-ONLY.

  DATA: navigator TYPE REF TO yif_mb11_navigator READ-ONLY.

  METHODS load.
  METHODS unload.
  METHODS set_location
    IMPORTING
      i_location TYPE ymb11_city .
  METHODS get_remaining_gifts
    RETURNING value(result) TYPE ycl_mb11_input_reader=>ty_gifts.
  METHODS get_loaded_gifts
    RETURNING VALUE(result) TYPE ty_gifts.
  METHODS clear_flags.
  METHODS set_navigator
    IMPORTING i_navigator TYPE REF TO yif_mb11_navigator.

ENDINTERFACE.
