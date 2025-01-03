CLASS ycl_mb11_graph_d DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES: BEGIN OF ty_step,
             from TYPE ymb11_city,
             to   TYPE ymb11_city,
           END OF ty_step,
           ty_steps TYPE STANDARD TABLE OF ty_step WITH EMPTY KEY.

    TYPES: BEGIN OF ty_path,
             from  TYPE ymb11_city,
             to    TYPE ymb11_city,
             time  TYPE int4,
             steps TYPE ty_steps,
           END OF ty_path,
           ty_paths TYPE SORTED TABLE OF ty_path WITH UNIQUE KEY from to.

    METHODS constructor
      IMPORTING
        i_no_of_cities TYPE i
        i_connections  TYPE ymb112_connections.

    METHODS find_shortest_path
      IMPORTING
        i_from        TYPE ymb11_city
        i_to          TYPE ymb11_city
      RETURNING
        VALUE(result) TYPE ty_steps
      .
    METHODS get_all_paths
      IMPORTING
        i_from TYPE ymb11_city
      RETURNING
        VALUE(result) TYPE ty_paths
      .



  PROTECTED SECTION.
    DATA: no_of_cities TYPE ymb11_city.
    DATA: connections TYPE ymb112_connections.
    DATA: paths TYPE ty_paths.

  PRIVATE SECTION.
*    algorithm based on this source:https://www.tutorialspoint.com/dijkstra-s-algorithm-to-compute-the-shortest-path-through-a-graph

    "cities (nodes) are from 0 to 332.
    TYPES: BEGIN OF ty_dij_distance,
             city    TYPE ymb11_city,
             time_to TYPE i,
             visited TYPE abap_bool,
             steps   TYPE ty_steps,
           END OF ty_dij_distance.

    METHODS calculate_dijkstra
      IMPORTING
        i_from TYPE ymb11_city.

ENDCLASS.



CLASS ycl_mb11_graph_d IMPLEMENTATION.

  METHOD constructor.
    no_of_cities = i_no_of_cities.
    connections = i_connections.
  ENDMETHOD.


  METHOD find_shortest_path.
    FIELD-SYMBOLS: <path> TYPE ycl_mb11_graph_d=>ty_path.

    READ TABLE paths WITH TABLE KEY from = i_from to = i_to ASSIGNING <path>.
    IF sy-subrc = 0.
      result = <path>-steps.
      RETURN.
    ENDIF.
    calculate_dijkstra(
      i_from = i_from
    ).
    READ TABLE paths WITH TABLE KEY from = i_from to = i_to ASSIGNING <path>.
    IF sy-subrc = 0.
      result = <path>-steps.
      RETURN.
    ENDIF.
  ENDMETHOD.


  METHOD get_all_paths.
    FIELD-SYMBOLS: <path> TYPE ycl_mb11_graph_d=>ty_path.
    LOOP AT paths ASSIGNING <path> WHERE from = i_from .
      APPEND <path> TO result.
    ENDLOOP.

    IF sy-subrc <> 0.
      calculate_dijkstra(
        i_from = i_from
      ).
      LOOP AT paths ASSIGNING <path> WHERE from = i_from .
        APPEND <path> TO result.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD calculate_dijkstra.
    DATA: dij_distances TYPE STANDARD TABLE OF ty_dij_distance WITH NON-UNIQUE SORTED KEY city COMPONENTS city.
    DATA: steps TYPE ty_steps.

    " first step: calculate distances from first node. That's why we add distance to itself
    dij_distances = VALUE #( BASE dij_distances ( city = i_from time_to = 0 visited = abap_false ) ).

    " now do the Dijkstra:
    DO no_of_cities TIMES.
      SORT dij_distances BY visited time_to ASCENDING.
      READ TABLE dij_distances ASSIGNING FIELD-SYMBOL(<current_city>) INDEX 1. "get the not-visited city with smallest distance
      IF <current_city>-visited = abap_true. "we've wisited all cities?
        EXIT.
      ENDIF.
      <current_city>-visited = abap_true.
      LOOP AT connections ASSIGNING FIELD-SYMBOL(<neighbour>) USING KEY binding WHERE src = <current_city>-city.
         READ TABLE dij_distances WITH KEY city COMPONENTS city = <neighbour>-dest ASSIGNING FIELD-SYMBOL(<distance>).
         IF sy-subrc = 0.
          IF <distance>-visited = abap_true.
            CONTINUE. "don't recalculate for visited
          ENDIF.

          DATA(time_to) = <current_city>-time_to + <neighbour>-time.
          IF <distance>-time_to > time_to.
            <distance>-time_to = time_to.
            steps = <current_city>-steps.
            steps = VALUE #( base steps ( from = <current_city>-city to = <neighbour>-dest ) ).
            <distance>-steps = steps.
          ENDIF.
        ELSE.
          steps = <current_city>-steps.
          steps = VALUE #( base steps ( from = <current_city>-city to = <neighbour>-dest ) ).
          time_to = <current_city>-time_to + <neighbour>-time.
          dij_distances = VALUE #( BASE dij_distances ( city = <neighbour>-dest time_to = time_to  steps = steps ) ).
        ENDIF.
      ENDLOOP.
    ENDDO.
    DELETE TABLE dij_distances WITH TABLE KEY city COMPONENTS city = i_from.
    "store permanent data

    LOOP AT dij_distances ASSIGNING FIELD-SYMBOL(<result>).
      paths = VALUE #( BASE paths ( from = i_from
                                    to = <result>-city
                                    time = <result>-time_to
                                    steps = <result>-steps )
                     ).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
