CLASS ycl_mb11_run_console DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.



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





ENDCLASS.
