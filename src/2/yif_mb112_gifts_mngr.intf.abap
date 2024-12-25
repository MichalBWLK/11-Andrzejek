INTERFACE yif_mb112_gifts_mngr
  PUBLIC .

    DATA: all_gifts TYPE ymb112_gifts READ-ONLY,
          packed_for_cities TYPE ymb112_gifts_per_cities READ-ONLY.

    DATA: router TYPE REF TO yif_mb112_router.

    DATA: unloading_happened TYPE abap_bool READ-ONLY,
          loading_happened TYPE abap_bool READ-ONLY.

    METHODS load.
    METHODS unload.
    METHODS set_router
      IMPORTING i_router TYPE REF TO yif_mb112_router.
    METHODS clear_flags.
    METHODS get_qty_of_remaining_gifts
      RETURNING VALUE(result) TYPE i.

ENDINTERFACE.
