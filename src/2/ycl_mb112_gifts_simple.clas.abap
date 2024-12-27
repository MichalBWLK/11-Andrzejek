CLASS ycl_mb112_gifts_simple DEFINITION
  PUBLIC
  INHERITING FROM ycl_mb112_gifts_mngr
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS: yif_mb112_gifts_mngr~load REDEFINITION,
             yif_mb112_gifts_mngr~unload REDEFINITION.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ycl_mb112_gifts_simple IMPLEMENTATION.

  METHOD yif_mb112_gifts_mngr~load.
    me->load_simple( ).
  ENDMETHOD.

  METHOD yif_mb112_gifts_mngr~unload.
    me->unload_simple( ).
    me->fetch_local_gifts( ).
  ENDMETHOD.

ENDCLASS.
