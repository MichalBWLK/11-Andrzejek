CLASS ycl_mb112_navigator DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    DATA: all_connections TYPE ymb112_connections,
          last_connection TYPE REF TO ymb112_connection,
          next_connection TYPE REF TO ymb112_connection.

    DATA: gifts_mngr TYPE REF TO ycl_mb112_cargo.

    DATA: current_time  TYPE int4,
          targeted_city TYPE ymb11_city READ-ONLY,
          route         TYPE ycl_mb11_graph_d=>ty_steps READ-ONLY.


    METHODS constructor
      IMPORTING
        i_journal  TYPE REF TO ycl_mb11_journal
        i_scenario TYPE int2.

    METHODS set_gifts_manager
      IMPORTING i_mngr TYPE REF TO ycl_mb112_cargo.
    METHODS move_to_next_city.

    "! <p class="shorttext synchronized" lang="en">select nearest city</p>
    METHODS select_closest_city.

    "! <p class="shorttext synchronized" lang="en">select random city</p>
    METHODS select_random_city.

    "! <p class="shorttext synchronized" lang="en">set path to a city with most gifts packed for</p>
    METHODS set_rt_to_city_by_most_gifts.

    "! <p class="shorttext synchronized" lang="en">set path to the nearest city with available gifts</p>
    METHODS set_rt_closst_ct_wth_av_gift.

    "! <p class="shorttext synchronized" lang="en">follow path which is set</p>
    METHODS follow_path.

  PROTECTED SECTION.
    DATA journal TYPE REF TO ycl_mb11_journal.
    DATA toolset TYPE REF TO ycl_mb112_toolset.
    DATA dijkstra TYPE REF TO ycl_mb11_graph_d.
    DATA initial_connection TYPE ymb112_connection.

  PRIVATE SECTION.
    METHODS generate_seed
      RETURNING
        VALUE(result) TYPE i.
ENDCLASS.



CLASS ycl_mb112_navigator IMPLEMENTATION.
  METHOD constructor.
    toolset = NEW #( ).
    journal = i_journal.
    DATA(input) = NEW ycl_mb11_input_reader( i_scenario ).
    DATA(fetched_connections) = input->get_connections( ).
    MOVE-CORRESPONDING fetched_connections TO all_connections.
    dijkstra = NEW #(
      i_no_of_cities = 999
      i_connections  = all_connections
    ).
    initial_connection = VALUE #( src = 0 dest = 0 time = 0 ).
    last_connection = REF #( initial_connection ).
  ENDMETHOD.


  METHOD set_gifts_manager.
    gifts_mngr = i_mngr.
  ENDMETHOD.


  METHOD move_to_next_city.
    last_connection = next_connection.
    CLEAR: next_connection.
  ENDMETHOD.


  METHOD select_closest_city.
    DATA shortest_time TYPE int2 VALUE 1025.
    "loop over all available destinations without the one going back
    LOOP AT all_connections REFERENCE INTO DATA(connection) USING KEY binding WHERE src = last_connection->dest AND dest <> last_connection->src.
      IF connection->time < shortest_time.
        next_connection = connection.
        shortest_time = connection->time.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD select_random_city.
    SELECT FROM @all_connections AS connections
      FIELDS src, dest, time
      WHERE src = @last_connection->dest
      INTO TABLE @DATA(available_trains).

    DATA(size) = lines( available_trains ).
    DATA(seed) = generate_seed( ).

    DATA(prng) = cl_abap_random_int=>create(
      seed = seed
      min  = 1
      max  = size
    ).

    READ TABLE available_trains INDEX prng->get_next( ) INTO DATA(choosen_one).
    READ TABLE all_connections WITH TABLE KEY binding COMPONENTS src = choosen_one-src
                                              dest = choosen_one-dest
                               REFERENCE INTO next_connection.
  ENDMETHOD.


  METHOD generate_seed.
    DATA: timestamp TYPE abp_creation_tstmpl,
          trash     TYPE string,
          seed      TYPE string.

    GET TIME STAMP FIELD timestamp.
    DATA(stamp) = CONV string( timestamp ).

    SPLIT stamp AT '.' INTO trash seed .
    result = seed / 10.
  ENDMETHOD.


  METHOD follow_path.
    READ TABLE route WITH KEY from = last_connection->dest ASSIGNING FIELD-SYMBOL(<step>).
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE ycx_mb12_path_fail.
    ENDIF.
    READ TABLE all_connections WITH TABLE KEY binding COMPONENTS src = <step>-from
                                                                 dest = <step>-to
                               REFERENCE INTO next_connection.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE ycx_mb12_path_fail.
    ENDIF.

    IF next_connection->dest = targeted_city.
      CLEAR: targeted_city, route.
    ENDIF.
  ENDMETHOD.


  METHOD set_rt_to_city_by_most_gifts.
    gifts_mngr->get_loaded_gifts( IMPORTING result = DATA(loaded_gifts) ).
    targeted_city = toolset->get_city_wth_most_gifts( loaded_gifts ).
    IF targeted_city = toolset->co_city_not_existing.
      RETURN.
    ENDIF.
    route = dijkstra->find_shortest_path(
      i_from = last_connection->dest
      i_to   = targeted_city
    ).
*    follow_path( ).
  ENDMETHOD.


  METHOD set_rt_closst_ct_wth_av_gift.
    DATA paths TYPE STANDARD TABLE OF ycl_mb11_graph_d=>ty_path.
    paths = dijkstra->get_all_paths( last_connection->dest ).
    sort paths BY time ASCENDING.
    targeted_city = toolset->co_city_not_existing.
    LOOP AT paths ASSIGNING FIELD-SYMBOL(<path>).
      IF gifts_mngr->are_gifts_in_city( <path>-to ) = abap_true.
        route = <path>-steps.
        targeted_city = <path>-to.
        EXIT.
      ENDIF.
    ENDLOOP.
    IF targeted_city = toolset->co_city_not_existing.
      RETURN.
    ENDIF.
*    follow_path( ).
  ENDMETHOD.

ENDCLASS.
