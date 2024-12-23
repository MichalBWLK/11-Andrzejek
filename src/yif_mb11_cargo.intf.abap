INTERFACE yif_mb11_cargo
  PUBLIC .
  DATA: unloading_happened TYPE abap_bool READ-ONLY,
        loading_happened TYPE abap_bool READ-ONLY.

  METHODS load.
  METHODS unload.
  METHODS set_location
    IMPORTING
      i_location TYPE ymb11_city .
  METHODS get_remaining_gifts
    RETURNING value(result) TYPE ycl_mb11_input_reader=>ty_gifts.
  METHODS clear_flags.

ENDINTERFACE.
