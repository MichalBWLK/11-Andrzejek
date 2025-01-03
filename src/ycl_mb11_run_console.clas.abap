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
    DATA(res_scenario) = CONV int2( 10153 ).

    DO 1 TIMES.
      DATA(andy) = NEW ycl_mb112_andy_II( i_scenario = 1 ).
      DATA(descr) = CONV ymb11_scenario_description( 'AndyII: pack again after route, no rand' ).
      DATA(time) = andy->execute( i_scenario = res_scenario i_scenario_descr = descr i_no_of_steps = 200000 ).
      DATA(delivered) = 33300 - andy->get_qty_of_remaining_gifts( ).
      out->write( descr )->write( `scenario ` && res_scenario && ` time: ` && time ).
      out->write( `delivered ` && delivered && ` out of 33300 ` ).
      out->write( andy->get_times_report( ) ).
      res_scenario += 1.
    ENDDO.
  ENDMETHOD.

ENDCLASS.
