CLASS ycl_mb112_andy DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        i_scenario TYPE int2.
    METHODS execute
      IMPORTING
        i_scenario TYPE int2
        i_scenario_descr TYPE ymb11_scenario_description
        i_no_of_steps TYPE i
      RETURNING
        VALUE(r_time) TYPE i.
    METHODS get_journal
      RETURNING VALUE(result) TYPE string.
    METHODS get_qty_of_remaining_gifts
      RETURNING VALUE(result) TYPE i.

  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA: gifts TYPE REF TO yif_mb112_gifts_mngr,
          router TYPE REF TO yif_mb112_router,
          journal TYPE REF TO ycl_mb11_journal.

*    DATA: all_connections TYPE ycl_mb11_input_reader=>ty_connections.

    DATA: current_time TYPE int4.


    METHODS call_algorithms.
    METHODS select_city.
    METHODS unload.
    METHODS load.

    METHODS make_move.

ENDCLASS.



CLASS ycl_mb112_andy IMPLEMENTATION.

  METHOD constructor.
    journal = new ycl_mb11_journal( ).
    gifts = new ycl_mb112_gifts_group_by_city(
      i_journal  = journal
      i_scenario = i_scenario
    ).
    router = new ycl_mb112_rout_go2_most_gifts(
      i_journal        = journal
      i_scenario       = i_scenario
    ).
    gifts->set_router( router ).
    router->set_gifts_manager( gifts ).
  ENDMETHOD.


  METHOD execute.
    do i_no_of_steps TIMES.
      call_algorithms( ).
      IF gifts->all_gifts IS INITIAL.
        EXIT.
      ENDIF.
    ENDDO.
    journal->persist_journal( i_scenario = i_scenario
                              i_description = i_scenario_descr
                              i_time = current_time ).
    r_time = current_time.
  ENDMETHOD.


  METHOD get_journal.
    result = journal->get_journal( ).
  ENDMETHOD.


  METHOD get_qty_of_remaining_gifts.
    result = gifts->get_qty_of_remaining_gifts( ).
  ENDMETHOD.


  METHOD call_algorithms.
    unload( ).
    load( ).
    select_city( ).

    IF gifts->all_gifts IS INITIAL.
      journal->save_to_journal( ).
      RETURN.
    ENDIF.

    make_move( ).
    journal->save_to_journal( ).
  ENDMETHOD.


  METHOD select_city.
    router->select_next_city( ).
  ENDMETHOD.


  METHOD unload.
    gifts->unload( ).
  ENDMETHOD.


  METHOD load.
    gifts->load( ).
  ENDMETHOD.


  METHOD make_move.

    IF gifts->loading_happened = abap_true.
      current_time += 2.
    ENDIF.
    IF gifts->unloading_happened = abap_true.
      current_time += 2.
    ENDIF.

    "calculate waiting time and transfer time:
    DATA(departure_type) = ( router->next_connection->src + router->next_connection->dest ) MOD 3.
    CASE departure_type.
      WHEN 0.
        DATA(interval) = 2.
      WHEN 1.
        interval = 3.
      WHEN 2.
        interval = 5.
    ENDCASE.
    DATA(waiting_time) = interval - ( current_time MOD interval ).

    current_time = current_time + waiting_time + router->next_connection->time.

    router->move_to_next_city( ).
    gifts->clear_flags( ).
  ENDMETHOD.

ENDCLASS.
