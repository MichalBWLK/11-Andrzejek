CLASS ycl_mb11_cargo_simple DEFINITION
  PUBLIC
  INHERITING FROM ycl_mb11_cargo
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS: yif_mb11_cargo~load REDEFINITION,
             yif_mb11_cargo~unload REDEFINITION.
  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS ycl_mb11_cargo_simple IMPLEMENTATION.

  METHOD yif_mb11_cargo~load.
    clear: loading_happened.
    IF loaded_volume + 5 >= max_volume OR loaded_weight + 5 >= max_weight.
      RETURN.
    ENDIF.

    LOOP AT all_gifts REFERENCE INTO DATA(gift) USING KEY city WHERE location = current_location.
      IF gift->weight <= max_weight - loaded_weight AND gift->volume <= max_volume - loaded_volume.
        APPEND gift TO loaded_gifts.
        journal->add_gift_picked( gift->gift ).
        loaded_volume += gift->volume.
        loaded_weight += gift->weight.
        loading_happened = abap_true.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD yif_mb11_cargo~unload.
    DATA: gifts_2b_deleted TYPE TABLE OF int4.

    clear: unloading_happened.
    LOOP AT loaded_gifts ASSIGNING FIELD-SYMBOL(<gift>).
      IF calc_target_city( <gift>->gift ) = current_location.
        "we're home, unload and delete from gifts.
        journal->add_gift_left( <gift>->gift ).
        loaded_volume -= <gift>->volume.
        loaded_weight -= <gift>->weight.
        APPEND <gift>->gift TO gifts_2b_deleted.
        DELETE loaded_gifts.
      ENDIF.
    ENDLOOP.
    IF sy-subrc = 0.
      unloading_happened = abap_true.
    ENDIF.

    LOOP AT gifts_2b_deleted ASSIGNING FIELD-SYMBOL(<gift_2b_del>).
      DELETE TABLE all_gifts WITH TABLE KEY gift = <gift_2b_del>.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
