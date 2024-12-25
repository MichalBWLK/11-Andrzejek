CLASS ycl_mb11_andrzejek DEFINITION
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
    METHODS get_remaining_gifts
      RETURNING VALUE(result) TYPE ycl_mb11_input_reader=>ty_gifts.

  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA: cargo_manager TYPE REF TO yif_mb11_cargo,
          navigator TYPE REF TO yif_mb11_navigator,
          journal TYPE REF TO ycl_mb11_journal.

*    DATA: all_connections TYPE ycl_mb11_input_reader=>ty_connections.

    DATA: current_time TYPE int4.


    METHODS call_algorithms.
    METHODS select_city.
    METHODS unload.
    METHODS load.

    METHODS calc_target_city
      IMPORTING
        i_gift        TYPE int4
      RETURNING
        VALUE(result) TYPE ymb11_city.




    METHODS make_move.

ENDCLASS.



CLASS ycl_mb11_andrzejek IMPLEMENTATION.

  METHOD constructor.
    journal = new ycl_mb11_journal( ).
    cargo_manager = new ycl_mb11_cargo_simple(
      i_journal  = journal
      i_scenario = i_scenario
    ).
    navigator = new ycl_mb11_nav_gifts_in_next_c(
      i_journal        = journal
      i_scenario       = i_scenario
      i_path_max_depth = 1
    ).
    cargo_manager->set_navigator( navigator ).
    navigator->set_cargo_mngr( cargo_manager ).
  ENDMETHOD.


  METHOD execute.
    do i_no_of_steps TIMES.
      call_algorithms( ).
    ENDDO.
    journal->persist_journal( i_scenario = i_scenario
                              i_description = i_scenario_descr ).
    r_time = current_time.
  ENDMETHOD.


  METHOD get_journal.
    result = journal->get_journal( ).
  ENDMETHOD.


  METHOD get_remaining_gifts.
    result = cargo_manager->get_remaining_gifts( ).
  ENDMETHOD.


  METHOD call_algorithms.
    unload( ).
    load( ).
    select_city( ).
    make_move( ).

    journal->save_to_journal( ).
  ENDMETHOD.


  METHOD select_city.
    navigator->set_loaded_gifts( cargo_manager->get_loaded_gifts( ) ).
    navigator->set_current_time( current_time ).
    navigator->select_city( ).
  ENDMETHOD.


  METHOD unload.
    cargo_manager->set_location( i_location = navigator->last_connection->dest ).
    cargo_manager->unload( ).
  ENDMETHOD.


  METHOD load.
    cargo_manager->set_location( i_location = navigator->last_connection->dest ).
    cargo_manager->load( ).
  ENDMETHOD.


  METHOD make_move.
    IF cargo_manager->loading_happened = abap_true.
      current_time += 2.
    ENDIF.
    IF cargo_manager->unloading_happened = abap_true.
      current_time += 2.
    ENDIF.

    "calculate waiting time and transfer time:
    DATA(departure_type) = ( navigator->new_connection->src + navigator->new_connection->dest ) MOD 3.
    CASE departure_type.
      WHEN 0.
        DATA(interval) = 2.
      WHEN 1.
        interval = 3.
      WHEN 2.
        interval = 5.
    ENDCASE.
    DATA(waiting_time) = interval - ( current_time MOD interval ).

    current_time = current_time + waiting_time + navigator->new_connection->time.

    navigator->move_to_next_city( ).
    cargo_manager->clear_flags( ).
  ENDMETHOD.


  METHOD calc_target_city.
    result = floor( i_gift / 100 ).
  ENDMETHOD.


ENDCLASS.
