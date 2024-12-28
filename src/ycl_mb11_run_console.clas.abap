CLASS ycl_mb11_run_console DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.


    METHODS read_gifts
      IMPORTING
        i_out TYPE REF TO if_oo_adt_classrun_out.
ENDCLASS.



CLASS ycl_mb11_run_console IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
*    read_gifts( out ).
*    DATA(andrzejek) = new ycl_mb11_andrzejek( i_scenario = 1 ).
*    DATA(descr) = CONV ymb11_scenario_description( 'I, 100 k, navi gifts in next city' ).
*    DATA(time) = andrzejek->execute( i_scenario = 10105 i_scenario_descr = descr i_no_of_steps = 100000 ).
*    DATA(to_go) = lines( andrzejek->get_remaining_gifts( ) ).
**    DATA(journal) = andrzejek->get_journal( ).
*    out->write( descr )->write( `time: ` && time )->write( `left gifts: ` && to_go )."->write( journal ).

    DATA(res_scenario) = CONV int2( 10129 ).

    DO 3 TIMES.
      res_scenario += 1.

      DATA(andy) = NEW ycl_mb112_andy( i_scenario = 1 ).
      DATA(descr) = CONV ymb11_scenario_description( 'I, Andy; complex + cond. unload_all' ).
      DATA(time) = andy->execute( i_scenario = res_scenario i_scenario_descr = descr i_no_of_steps = 200000 ).
      DATA(to_go) = andy->get_qty_of_remaining_gifts( ).
      DATA(delivered) = 33300 - to_go.
      out->write( descr )->write( `scenario ` && res_scenario && ` time: ` && time ).
      out->write( `delivered ` && delivered && ` out of 33300 ` ).

    ENDDO.
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
