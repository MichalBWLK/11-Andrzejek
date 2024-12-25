CLASS ycl_mb11_run_console DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS populate_connections.
    METHODS populate_gifts.
    METHODS read_gifts
      IMPORTING
        i_out TYPE REF TO if_oo_adt_classrun_out.
ENDCLASS.



CLASS ycl_mb11_run_console IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
*    populate_connections( ).
*    populate_gifts( ).
*    read_gifts( out ).
*    DATA(andrzejek) = new ycl_mb11_andrzejek( i_scenario = 1 ).
*    DATA(descr) = CONV ymb11_scenario_description( 'I, 100 k, navi gifts in next city' ).
*    DATA(time) = andrzejek->execute( i_scenario = 10105 i_scenario_descr = descr i_no_of_steps = 100000 ).
*    DATA(to_go) = lines( andrzejek->get_remaining_gifts( ) ).
**    DATA(journal) = andrzejek->get_journal( ).
*    out->write( descr )->write( `time: ` && time )->write( `left gifts: ` && to_go )."->write( journal ).

    DATA(andy) = new ycl_mb112_andy( i_scenario = 1 ).
    DATA(descr) = CONV ymb11_scenario_description( 'I, 700k, Andy: city closest or random' ).
    DATA(time) = andy->execute( i_scenario = 10111 i_scenario_descr = descr i_no_of_steps = 700000 ).
    DATA(to_go) = andy->get_qty_of_remaining_gifts( ).
    DATA(delivered) = 33300 - to_go.
    out->write( descr )->write( `time: ` && time ).
    out->write( `delivered ` && delivered && ` out of 33300 ` ).

  ENDMETHOD.


  METHOD populate_connections.

    DATA connections TYPE STANDARD TABLE OF ymb11connections.

    connections = VALUE #(
      ( client = 100 src = 0 dest = 1 time = 4 )
      ( client = 100 src = 0 dest = 2 time = 6 )
      ( client = 100 src = 0 dest = 4 time = 4 )
      ( client = 100 src = 2 dest = 3 time = 4 )
      ( client = 100 src = 2 dest = 5 time = 9 )
      ( client = 100 src = 3 dest = 4 time = 4 )
      ( client = 100 src = 3 dest = 5 time = 11 )
    ).

    INSERT ymb11connections FROM TABLE @connections.


  ENDMETHOD.


  METHOD populate_gifts.
    DATA gifts TYPE STANDARD TABLE OF ymb11gifts.

    gifts = VALUE #(
      ( client = 100 gift = 0  weight = 5 volume = 12 location = 5 )
      ( client = 100 gift = 1  weight = 2 volume = 2  location = 4 )
      ( client = 100 gift = 2  weight = 3 volume = 1  location = 5 )
      ( client = 100 gift = 3  weight = 4 volume = 15 location = 1 )
      ( client = 100 gift = 4  weight = 5 volume = 6  location = 5 )
      ( client = 100 gift = 5  weight = 5 volume = 12 location = 2 )
      ( client = 100 gift = 6  weight = 7 volume = 12 location = 3 )
      ( client = 100 gift = 7  weight = 9 volume = 1  location = 4 )
      ( client = 100 gift = 8  weight = 1 volume = 2  location = 2 )
      ( client = 100 gift = 9  weight = 9 volume = 3  location = 3 )
      ( client = 100 gift = 10 weight = 3 volume = 4  location = 4 )
      ( client = 100 gift = 11 weight = 7 volume = 5  location = 1 )
      ( client = 100 gift = 12 weight = 2 volume = 5  location = 0 )
      ( client = 100 gift = 13 weight = 7 volume = 8  location = 0 )
      ( client = 100 gift = 14 weight = 5 volume = 12 location = 3 )
      ( client = 100 gift = 15 weight = 5 volume = 11 location = 2 )
      ( client = 100 gift = 16 weight = 2 volume = 2  location = 0 )
      ( client = 100 gift = 17 weight = 6 volume = 6  location = 5 )

    ).



  ENDMETHOD.


  METHOD read_gifts.
    DATA: gifts     TYPE SORTED TABLE OF ymb11gifts WITH UNIQUE KEY gift,
          reference TYPE REF TO data.

    TRY.
        SELECT SINGLE
          FROM yr_mb11files
          FIELDS Attachment
          WHERE FilePurpose = 'GFT'
          INTO @DATA(file)
        .
        DATA(content) = cl_abap_conv_codepage=>create_in( )->convert( file ).
        DATA(parser) = NEW ycl_mb_csv_parser(
          i_target_structure = 'YMB11GIFTS'
*         i_line_separator   = CL_ABAP_CHAR_UTILITIES=>CR_LF
*         i_value_separator  = ';'
          i_value_delimiter  = ''
*         i_remove_header    = abap_true
        ).

        reference = parser->convert_csv2tab( content ).
        gifts = reference->*.


        i_out->write( gifts[ 5 ] ).
        i_out->write( 'finito' ).
      CATCH cx_sy_conversion_codepage cx_parameter_invalid_range INTO DATA(exception).
        i_out->write( exception->get_text( ) ).
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
