CLASS ycl_mb11_graph_d DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        i_connections TYPE REF TO ycl_mb11_input_reader=>ty_connections.

  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA: connections TYPE REF TO ycl_mb11_input_reader=>ty_connections.
ENDCLASS.



CLASS ycl_mb11_graph_d IMPLEMENTATION.
  METHOD constructor.
    connections = i_connections.
  ENDMETHOD.

ENDCLASS.
