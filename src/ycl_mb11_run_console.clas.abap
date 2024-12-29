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
    DATA(res_scenario) = CONV int2( 10136 ).

    DO 1 TIMES.
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
