CLASS ycl_mb11_navigator DEFINITION
  PUBLIC
  ABSTRACT
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES yif_mb11_navigator ABSTRACT METHODS select_city.

    ALIASES: last_connection FOR yif_mb11_navigator~last_connection,
             new_connection FOR yif_mb11_navigator~new_connection,
             preferred_city FOR yif_mb11_navigator~preferred_city,
             all_connections FOR yif_mb11_navigator~all_connections,
             cargo_mngr FOR yif_mb11_navigator~cargo_mngr.

    ALIASES:
             select_city FOR yif_mb11_navigator~select_city,
             move_to_next_city FOR yif_mb11_navigator~move_to_next_city,
             set_loaded_gifts FOR yif_mb11_navigator~set_loaded_gifts,
             set_current_time FOR yif_mb11_navigator~set_current_time,
             set_cargo_mngr FOR yif_mb11_navigator~set_cargo_mngr.


    METHODS constructor
      IMPORTING
        i_journal  TYPE REF TO ycl_mb11_journal
        i_scenario TYPE int2.

  PROTECTED SECTION.
    DATA: journal TYPE REF TO ycl_mb11_journal.

    DATA: initial_connection TYPE ymb11connections.

    DATA: loaded_gifts TYPE yif_mb11_cargo=>ty_gifts,
          current_time TYPE int4.

     METHODS calc_target_city
      IMPORTING
        i_gift        TYPE int4
      RETURNING
        VALUE(result) TYPE ymb11_city.

  PRIVATE SECTION.
ENDCLASS.



CLASS ycl_mb11_navigator IMPLEMENTATION.

  METHOD constructor.
    journal = i_journal.
    DATA(input) = NEW ycl_mb11_input_reader( i_scenario ).
    all_connections = input->get_connections( ).
    initial_connection = VALUE #( src = 0 dest = 0 time = 0 ).
    last_connection = REF #( initial_connection ).
  ENDMETHOD.

  METHOD move_to_next_city.
    last_connection = new_connection.
    clear: new_connection.
  ENDMETHOD.


  METHOD set_loaded_gifts.
    loaded_gifts = i_gifts.
  ENDMETHOD.


  METHOD set_current_time.
    current_time = i_time.
  ENDMETHOD.


  METHOD set_cargo_mngr.
     cargo_mngr = i_cargo_mngr.
  ENDMETHOD.


  METHOD calc_target_city.
    result = floor( i_gift / 100 ).
  ENDMETHOD.

ENDCLASS.
