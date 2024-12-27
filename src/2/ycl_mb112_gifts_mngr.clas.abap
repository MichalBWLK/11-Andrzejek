CLASS ycl_mb112_gifts_mngr DEFINITION
  PUBLIC
  ABSTRACT
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES yif_mb112_gifts_mngr ABSTRACT METHODS load unload.
    ALIASES:
      unloading_happened FOR yif_mb112_gifts_mngr~unloading_happened,
      loading_happened FOR yif_mb112_gifts_mngr~loading_happened,
      all_gifts FOR yif_mb112_gifts_mngr~all_gifts,
      packed_for_cities FOR yif_mb112_gifts_mngr~packed_for_cities.

    ALIASES:
      router FOR yif_mb112_gifts_mngr~router.

    ALIASES:
      load FOR yif_mb112_gifts_mngr~load,
      unload FOR yif_mb112_gifts_mngr~unload,
      set_router FOR yif_mb112_gifts_mngr~set_router,
      clear_flags FOR yif_mb112_gifts_mngr~clear_flags,
      get_loaded_gifts FOR yif_mb112_gifts_mngr~get_loaded_gifts,
      get_qty_of_remaining_gifts FOR yif_mb112_gifts_mngr~get_qty_of_remaining_gifts.

    METHODS constructor
      IMPORTING
        i_journal  TYPE REF TO ycl_mb11_journal
        i_scenario TYPE int2.

  PROTECTED SECTION.
    CONSTANTS: max_weight TYPE int2 VALUE 190,
               max_volume TYPE int2 VALUE 280.
    CONSTANTS: co_train TYPE ymb11_city VALUE 9999999.

    DATA: journal TYPE REF TO ycl_mb11_journal,
          toolset TYPE REF TO ycl_mb112_toolset.


    DATA: loaded_weight TYPE int2,
          loaded_volume TYPE int2.

    METHODS is_fully_loaded
      RETURNING VALUE(result) TYPE abap_bool.

    "! <p class="shorttext synchronized" lang="en">load one gift to the santa's bag</p>
    METHODS load_a_gift
      IMPORTING
        i_gift TYPE REF TO ymb112_gift.

    "! <p class="shorttext synchronized" lang="en">unload one gift from santa's bag and leave in town</p>
    METHODS unload_a_gift
      IMPORTING
        i_gift TYPE REF TO ymb112_gift.

    "! <p class="shorttext synchronized" lang="en">unload gift when it's in target city</p>
    METHODS unload_simple.

    "! <p class="shorttext synchronized" lang="en">load whichever gifts you have in hands</p>
    METHODS load_simple.

  PRIVATE SECTION.
ENDCLASS.



CLASS ycl_mb112_gifts_mngr IMPLEMENTATION.

  METHOD constructor.
    toolset = new #( ).
    journal = i_journal.
    DATA(input) = NEW ycl_mb11_input_reader( i_scenario ).
    DATA(fetched_gifts) = input->get_gifts( ).
    MOVE-CORRESPONDING fetched_gifts TO all_gifts.
  ENDMETHOD.


  METHOD set_router.
    router = i_router.
  ENDMETHOD.


  METHOD clear_flags.
    clear: loading_happened, unloading_happened.
  ENDMETHOD.


  METHOD get_loaded_gifts.
    SELECT * FROM @all_gifts AS all_gifts
      WHERE picked = @abap_true
      INTO TABLE @result.
  ENDMETHOD.


  METHOD get_qty_of_remaining_gifts.
    result = lines( all_gifts ).
  ENDMETHOD.


  METHOD is_fully_loaded.
    IF loaded_volume + 5 >= max_volume OR loaded_weight + 5 >= max_weight.
      result = abap_true.
    ENDIF.
  ENDMETHOD.


  METHOD load_simple.
    "loop over all un-picked in current location
    LOOP AT all_gifts REFERENCE INTO DATA(gift) WHERE location = router->last_connection->dest AND picked = abap_false.
      IF gift->weight <= max_weight - loaded_weight AND gift->volume <= max_volume - loaded_volume.
        load_a_gift( gift ).
      ENDIF.
      IF is_fully_loaded( ) = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD unload_simple.
    LOOP AT all_gifts REFERENCE INTO DATA(gift) WHERE picked = abap_true.
      IF toolset->calc_target_city( gift->gift ) = router->last_connection->dest.
        "we're home, unload and delete from gifts (deleting happens automatically, if we unload into the right city
        unload_a_gift( gift ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD load_a_gift.
    i_gift->location = co_train.
    i_gift->picked = abap_true.
    loaded_volume += i_gift->volume.
    loaded_weight += i_gift->weight.
    loading_happened = abap_true.
  ENDMETHOD.


  METHOD unload_a_gift.
    i_gift->location = router->last_connection->dest.
    i_gift->picked = abap_false.
    journal->add_gift_left( i_gift->gift ).
    loaded_volume -= i_gift->volume.
    loaded_weight -= i_gift->weight.
    unloading_happened = abap_true.
    IF i_gift->location = toolset->calc_target_city( i_gift->gift ).
      "we're home, time to delete the gift
      DELETE all_gifts  WHERE gift = i_gift->gift.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
