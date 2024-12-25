CLASS ycl_mb112_router DEFINITION
  PUBLIC
  ABSTRACT
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES yif_mb112_router ABSTRACT METHODS select_next_city.
    ALIASES:
      all_connections FOR yif_mb112_router~all_connections,
      last_connection FOR yif_mb112_router~last_connection,
      next_connection FOR yif_mb112_router~next_connection,
      current_time FOR yif_mb112_router~current_time.
    ALIASES:
      gifts_mngr FOR yif_mb112_router~gifts_mngr.
    ALIASES:
      select_next_city FOR yif_mb112_router~select_next_city,
      set_a_route FOR yif_mb112_router~set_a_route,
      move_to_next_city FOR yif_mb112_router~move_to_next_city,
      set_gifts_manager FOR yif_mb112_router~set_gifts_manager.

    METHODS constructor
      IMPORTING
        i_journal  TYPE REF TO ycl_mb11_journal
        i_scenario TYPE int2.

  PROTECTED SECTION.
    DATA journal TYPE REF TO ycl_mb11_journal.
    DATA toolset TYPE REF TO ycl_mb112_gift_city_tools.
    DATA initial_connection TYPE ymb112_connection.

    METHODS select_closest_city.
    METHODS select_random_city.

PRIVATE SECTION.
    METHODS generate_seed
      RETURNING
        value(result) TYPE i.

ENDCLASS.



CLASS ycl_mb112_router IMPLEMENTATION.

  METHOD constructor.
    toolset = new #( ).
    journal = i_journal.
    DATA(input) = NEW ycl_mb11_input_reader( i_scenario ).
    DATA(fetched_connections) = input->get_connections( ).
    MOVE-CORRESPONDING fetched_connections TO all_connections.
    initial_connection = VALUE #( src = 0 dest = 0 time = 0 ).
    last_connection = REF #( initial_connection ).
  ENDMETHOD.


  METHOD move_to_next_city.
    last_connection = next_connection.
    clear: next_connection.
  ENDMETHOD.


  METHOD set_a_route.
##TODO
  ENDMETHOD.


  METHOD set_gifts_manager.
    gifts_mngr = i_mngr.
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
    READ TABLE all_connections WITH TABLE KEY BINDING COMPONENTS src = choosen_one-src
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

ENDCLASS.
