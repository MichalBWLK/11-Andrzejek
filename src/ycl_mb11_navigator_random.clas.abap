CLASS ycl_mb11_navigator_random DEFINITION
  PUBLIC
  INHERITING FROM ycl_mb11_navigator
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS: yif_mb11_navigator~select_city REDEFINITION.

  PROTECTED SECTION.
    METHODS select_randomly
      RAISING
        cx_abap_random.

  PRIVATE SECTION.
    METHODS generate_seed
      RETURNING
        value(result) TYPE i.

ENDCLASS.



CLASS ycl_mb11_navigator_random IMPLEMENTATION.

  METHOD yif_mb11_navigator~select_city.
    select_randomly( ).
    journal->set_next_city( new_connection->dest ).
  ENDMETHOD.


  METHOD select_randomly.

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
    ##TODO "error handling
    READ TABLE all_connections WITH TABLE KEY conn COMPONENTS src = choosen_one-src
                                              dest = choosen_one-dest
                               REFERENCE INTO new_connection.
    ##TODO "error handling
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
