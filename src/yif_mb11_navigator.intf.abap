INTERFACE yif_mb11_navigator
  PUBLIC .
  DATA: last_connection TYPE REF TO ymb11connections READ-ONLY,
        new_connection  TYPE REF TO ymb11connections READ-ONLY,
        preferred_city TYPE ymb11_city READ-ONLY.

  DATA: cargo_mngr TYPE REF TO yif_mb11_cargo READ-ONLY,
        all_connections TYPE ycl_mb11_input_reader=>ty_connections READ-ONLY.

    METHODS select_city.
    METHODS move_to_next_city.
    METHODS set_loaded_gifts
      IMPORTING i_gifts TYPE yif_mb11_cargo=>ty_gifts.
    METHODS set_current_time
      IMPORTING i_time type int4.
    METHODS set_cargo_mngr
      IMPORTING i_cargo_mngr TYPE REF TO yif_mb11_cargo.
ENDINTERFACE.
