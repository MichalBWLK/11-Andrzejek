INTERFACE yif_mb112_router
  PUBLIC .
  DATA: all_connections TYPE ymb112_connections,
        last_connection TYPE REF TO ymb112_connection,
        next_connection TYPE REF TO ymb112_connection.

  DATA: gifts_mngr TYPE REF TO ycl_mb112_cargo.

  DATA: current_time TYPE int4,
        targeted_city TYPE ymb11_city READ-ONLY,
        route TYPE ycl_mb11_graph_d=>ty_steps READ-ONLY.

  METHODS move_to_next_city.
  METHODS set_gifts_manager
    IMPORTING i_mngr TYPE REF TO ycl_mb112_cargo.
ENDINTERFACE.
