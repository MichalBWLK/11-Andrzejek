CLASS ycl_mb11_input_reader DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES ty_gifts TYPE SORTED TABLE OF ymb11gifts WITH UNIQUE KEY gift WITH NON-UNIQUE SORTED KEY city COMPONENTS location .
    TYPES ty_connections TYPE STANDARD TABLE OF ymb11connections WITH EMPTY KEY WITH UNIQUE SORTED KEY conn COMPONENTS src dest." WITH EMPTY KEY WITH NON-UNIQUE SORTED KEY source COMPONENTS src.

    METHODS constructor
      IMPORTING i_scenario TYPE int2.
    METHODS get_gifts
      RETURNING VALUE(result) TYPE ty_gifts.
    METHODS get_connections
      RETURNING VALUE(result) TYPE ty_connections.


  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA: scenario TYPE int2,
          connections TYPE REF TO data,
          gifts type ref to data.
    METHODS read_input_files.
    METHODS read_gifts
              RAISING
                cx_parameter_invalid_range
                cx_sy_conversion_codepage.
    METHODS read_connections.
ENDCLASS.



CLASS ycl_mb11_input_reader IMPLEMENTATION.

  METHOD constructor.
    scenario = i_scenario.
    read_input_files( ).
  ENDMETHOD.


  METHOD get_gifts.
    result = me->gifts->*.
  ENDMETHOD.


  METHOD get_connections.
    result = me->connections->*.
  ENDMETHOD.


  METHOD read_input_files.
    TRY.
        read_gifts( ).
        read_connections( ).

      CATCH cx_sy_conversion_codepage cx_parameter_invalid_range INTO DATA(exception).
  ##TODO
    ENDTRY.
  ENDMETHOD.


  METHOD read_gifts.
    SELECT SINGLE
      FROM yr_mb11files
      FIELDS Attachment
      WHERE FilePurpose = 'GFT'
      INTO @DATA(file)
    .
    DATA(content) = cl_abap_conv_codepage=>create_in( )->convert( file ).
    DATA(parser) = NEW ycl_mb_csv_parser(
      i_target_structure = 'YMB11GIFTS'
      i_value_delimiter  = ''
    ).
    me->gifts = parser->convert_csv2tab( content ).
  ENDMETHOD.


  METHOD read_connections.
    SELECT SINGLE
      FROM yr_mb11files
      FIELDS Attachment
      WHERE FilePurpose = 'CON'
      INTO @DATA(file)
    .
    DATA(content) = cl_abap_conv_codepage=>create_in( )->convert( file ).
    DATA(parser) = NEW ycl_mb_csv_parser(
      i_target_structure = 'YMB11CONNECTIONS'
      i_value_delimiter  = ''
    ).
    me->connections = parser->convert_csv2tab( content ).
  ENDMETHOD.

ENDCLASS.
