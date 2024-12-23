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
    TYPES: ty_gift  TYPE REF TO ymb11gifts,
           ty_gifts TYPE TABLE OF ty_gift.

    CONSTANTS: max_weight TYPE int2 VALUE 190,
               max_volume TYPE int2 VALUE 280.

    DATA: cargo_manager TYPE REF TO yif_mb11_cargo,
          journal TYPE REF TO ycl_mb11_journal.

    DATA: all_gifts       TYPE ycl_mb11_input_reader=>ty_gifts,
          all_connections TYPE ycl_mb11_input_reader=>ty_connections.

    DATA: loaded_gifts  TYPE ty_gifts,
          loaded_weight TYPE int2,
          loaded_volume TYPE int2.

    DATA: initial_connection TYPE ymb11connections,
          last_connection TYPE REF TO ymb11connections,
          new_connection  TYPE REF TO ymb11connections,
          next_city       TYPE ymb11_city.

    DATA: current_time TYPE int4,
          loading_happened TYPE abap_bool,
          unloading_happened TYPE abap_bool.


    METHODS call_algorithms.
    METHODS select_city.
    METHODS unload.
    METHODS load.

    METHODS calc_target_city
      IMPORTING
        i_gift        TYPE int4
      RETURNING
        VALUE(result) TYPE ymb11_city.

    METHODS simple_unload.
    METHODS simple_load.
    METHODS simple_select_city.
    METHODS make_move.
    METHODS generate_seed
      RETURNING
        value(result) TYPE i.
ENDCLASS.



CLASS ycl_mb11_andrzejek IMPLEMENTATION.

  METHOD constructor.
    journal = new ycl_mb11_journal( ).
    cargo_manager = new ycl_mb11_cargo_simple(
      i_journal  = journal
      i_scenario = i_scenario
    ).
    DATA(input) = NEW ycl_mb11_input_reader( i_scenario ).
    all_connections = input->get_connections( ).
    initial_connection = VALUE #( src = 0 dest = 0 time = 0 ).
    last_connection = REF #( initial_connection ).
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
    result = me->all_gifts.
  ENDMETHOD.


  METHOD call_algorithms.
    unload( ).
    load( ).
    select_city( ).
    make_move( ).



    journal->save_to_journal( ).
  ENDMETHOD.


  METHOD select_city.
    simple_select_city( ).
  ENDMETHOD.


  METHOD unload.
*    cargo_manager->set_location( i_location =  ).
    simple_unload( ).
  ENDMETHOD.


  METHOD load.
    simple_load( ).
  ENDMETHOD.


  METHOD make_move.
    IF loading_happened = abap_true.
      current_time += 2.
    ENDIF.
    IF unloading_happened = abap_true.
      current_time += 2.
    ENDIF.

    "calculate waiting time and transfer time:
    DATA(departure_type) = ( new_connection->src + new_connection->dest ) MOD 3.
    CASE departure_type.
      WHEN 0.
        DATA(interval) = 2.
      WHEN 1.
        interval = 3.
      WHEN 2.
        interval = 5.
    ENDCASE.
    DATA(waiting_time) = interval - ( current_time MOD interval ).

    current_time = current_time + waiting_time + new_connection->time.

    last_connection = new_connection.
    CLEAR: new_connection, loading_happened, unloading_happened.

  ENDMETHOD.


  METHOD calc_target_city.

    result = floor( i_gift / 100 ).
  ENDMETHOD.


  METHOD simple_unload.
    DATA: gifts_2b_deleted TYPE TABLE OF int4.

    LOOP AT loaded_gifts ASSIGNING FIELD-SYMBOL(<gift>).
      IF calc_target_city( <gift>->gift ) = last_connection->dest.
        "we're home, unload and delete from gifts.
        journal->add_gift_left( <gift>->gift ).
        loaded_volume -= <gift>->volume.
        loaded_weight -= <gift>->weight.
        APPEND <gift>->gift TO gifts_2b_deleted.
        DELETE loaded_gifts.
      ENDIF.
    ENDLOOP.
    IF sy-subrc = 0.
      unloading_happened = abap_true.
    ENDIF.

    LOOP AT gifts_2b_deleted ASSIGNING FIELD-SYMBOL(<gift_2b_del>).
      DELETE TABLE all_gifts WITH TABLE KEY gift = <gift_2b_del>.
    ENDLOOP.
  ENDMETHOD.


  METHOD simple_load.
    IF loaded_volume + 5 >= max_volume OR loaded_weight + 5 >= max_weight.
      RETURN.
    ENDIF.

    LOOP AT all_gifts REFERENCE INTO DATA(gift) USING KEY city WHERE location = last_connection->dest.
      IF gift->weight <= max_weight - loaded_weight AND gift->volume <= max_volume - loaded_volume.
        APPEND gift TO loaded_gifts.
        journal->add_gift_picked( gift->gift ).
        loaded_volume += gift->volume.
        loaded_weight += gift->weight.
        loading_happened = abap_true.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD simple_select_city.

    SELECT FROM @all_connections AS connections
      FIELDS src, dest, time
      WHERE src = @last_connection->dest
      INTO TABLE @data(available_trains).

    data(size) = lines( available_trains ).
    DATA(seed) = generate_seed( ).

    DATA(prng) = cl_abap_random_int=>create(
                   seed = seed
                   min  = 1
                   max  = size
                 ).

    READ TABLE available_trains INDEX prng->get_next( ) INTO DATA(choosen_one).
    ##TODO "error handling
    READ TABLE all_connections WITH TABLE KEY conn COMPONENTS src = choosen_one-src
                                        dest = choosen_one-dest
                               REFERENCE INTO new_connection.
    ##TODO "error handling
    journal->set_next_city( new_connection->dest ).

*    LOOP AT all_connections REFERENCE INTO DATA(connection) USING KEY source WHERE src = last_connection->dest.
*      IF connection->dest <> last_connection->src. "avoid loop
*        new_connection = connection.
*        journal->set_next_city( new_connection->dest ).
*        EXIT.
*      ENDIF.
*    ENDLOOP.
  ENDMETHOD.


  METHOD generate_seed.
    DATA: timestamp TYPE abp_creation_tstmpl,
          trash TYPE string,
          seed TYPE string.

          GET TIME STAMP FIELD timestamp.
          DATA(stamp) = CONV string( timestamp ).

          SPLIT stamp AT '.' INTO trash seed .
          result = seed / 10.
  ENDMETHOD.

ENDCLASS.
