CLASS ycl_mb112_cargo DEFINITION
  PUBLIC

  CREATE PUBLIC .

  PUBLIC SECTION.
    DATA: all_gifts         TYPE ymb112_gifts READ-ONLY,
          packed_for_cities TYPE ymb112_gifts_per_cities READ-ONLY.

    DATA: router TYPE REF TO ycl_mb112_navigator.

    DATA: unloading_happened TYPE abap_bool READ-ONLY,
          loading_happened   TYPE abap_bool READ-ONLY.

*    INTERFACES yif_mb112_gifts_mngr .
*    ALIASES:
*      unloading_happened FOR yif_mb112_gifts_mngr~unloading_happened,
*      loading_happened FOR yif_mb112_gifts_mngr~loading_happened,
*      all_gifts FOR yif_mb112_gifts_mngr~all_gifts,
*      packed_for_cities FOR yif_mb112_gifts_mngr~packed_for_cities.
*
*    ALIASES:
*      router FOR yif_mb112_gifts_mngr~router.


    METHODS set_router
      IMPORTING i_router TYPE REF TO ycl_mb112_navigator.
    METHODS clear_flags.
    METHODS get_loaded_gifts
      EXPORTING result TYPE ymb112_gifts.
    METHODS get_qty_of_remaining_gifts
      RETURNING VALUE(result) TYPE i.

*    ALIASES:
*      set_router FOR yif_mb112_gifts_mngr~set_router,
*      clear_flags FOR yif_mb112_gifts_mngr~clear_flags,
*      get_loaded_gifts FOR yif_mb112_gifts_mngr~get_loaded_gifts,
*      get_qty_of_remaining_gifts FOR yif_mb112_gifts_mngr~get_qty_of_remaining_gifts.

    METHODS constructor
      IMPORTING
        i_journal  TYPE REF TO ycl_mb11_journal
        i_scenario TYPE int2.


    "! <p class="shorttext synchronized" lang="en">unload gift when it's in target city</p>
    METHODS unload_simple.

    METHODS unload_all.

    "! <p class="shorttext synchronized" lang="en">load whichever gifts you have in hands</p>
    METHODS load_simple.

    "! <p class="shorttext synchronized" lang="en">load any gifts but to some level of capacity</p>
    "!
    "! @parameter i_max_weight | <p class="shorttext synchronized" lang="en">don't load above this limit</p>
    "! @parameter i_max_volume | <p class="shorttext synchronized" lang="en">don't load above this limit</p>
    METHODS load_simple_limited
      IMPORTING
        i_max_weight TYPE int2 DEFAULT 95
        i_max_volume TYPE int2 DEFAULT 140.

    "! <p class="shorttext synchronized" lang="en">load gifts destined for the "targetted city" of the router</p>
    METHODS load_for_targetted_city.

    "! <p class="shorttext synchronized" lang="en">load gifts for cities which are on the set path/route</p>
    METHODS load_for_path_cities_frm_1st.

    "! <p class="shorttext synchronized" lang="en">load gifts for cities, for which gifts are already picked</p>
    METHODS load_for_already_loaded.

    "! <p class="shorttext synchronized" lang="en">load for cities, who have most gifts available for one city</p>
    "!
    "! @parameter i_max_weight | <p class="shorttext synchronized" lang="en">don't load above this limit</p>
    "! @parameter i_max_volume | <p class="shorttext synchronized" lang="en">don't load above this limit</p>
    METHODS load_most_for_one_limited
      IMPORTING
        i_max_weight TYPE int2
        i_max_volume TYPE int2.


  PROTECTED SECTION.
    CONSTANTS: max_weight TYPE int2 VALUE 190,
               max_volume TYPE int2 VALUE 280.
    CONSTANTS: co_train TYPE ymb11_city VALUE 9999999.

    DATA: journal TYPE REF TO ycl_mb11_journal,
          toolset TYPE REF TO ycl_mb112_toolset.

    DATA: local_gifts TYPE TABLE OF REF TO ymb112_gift.

    DATA: loaded_weight TYPE int2,
          loaded_volume TYPE int2.


    "! <p class="shorttext synchronized" lang="en">get local gifts for algorithms of loading</p>
    "! It's needed to be called after each change of city
    METHODS fetch_local_gifts.

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

  PRIVATE SECTION.
ENDCLASS.



CLASS ycl_mb112_cargo IMPLEMENTATION.
  METHOD constructor.
    toolset = NEW #( ).
    journal = i_journal.
    DATA(input) = NEW ycl_mb11_input_reader( i_scenario ).
    DATA(fetched_gifts) = input->get_gifts( ).
    MOVE-CORRESPONDING fetched_gifts TO all_gifts.
  ENDMETHOD.


  METHOD set_router.
    router = i_router.
  ENDMETHOD.


  METHOD clear_flags.
    CLEAR: loading_happened, unloading_happened.
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
    CONSTANTS: co_max_margin TYPE int2 VALUE 2. "a lot of gifts are bigger than 2, so if only 2 is left, there's no point of trying to fit another gift
    IF loaded_volume + co_max_margin >= max_volume OR loaded_weight + co_max_margin >= max_weight.
      result = abap_true.
    ENDIF.
  ENDMETHOD.


  METHOD load_a_gift.
    i_gift->location = co_train.
    i_gift->picked = abap_true.
    journal->add_gift_picked( gift = i_gift->gift ).
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


  METHOD fetch_local_gifts.
    CLEAR local_gifts.
    LOOP AT all_gifts REFERENCE INTO DATA(gift) USING KEY local_gifts WHERE location = router->last_connection->dest AND picked = abap_false.
      APPEND gift TO local_gifts.
    ENDLOOP.
  ENDMETHOD.


  METHOD unload_simple.
    LOOP AT all_gifts REFERENCE INTO DATA(gift) WHERE picked = abap_true.
      IF toolset->calc_target_city( gift->gift ) = router->last_connection->dest.
        "we're home, unload and delete from gifts (deleting happens automatically, if we unload into the right city
        unload_a_gift( gift ).
      ENDIF.
    ENDLOOP.
    fetch_local_gifts( ).
  ENDMETHOD.


  METHOD unload_all.
    LOOP AT all_gifts REFERENCE INTO DATA(gift) WHERE picked = abap_true.
      unload_a_gift( gift ).
    ENDLOOP.
    fetch_local_gifts( ).
  ENDMETHOD.


  METHOD load_simple.
    LOOP AT local_gifts INTO DATA(gift).
      IF gift->weight <= max_weight - loaded_weight AND gift->volume <= max_volume - loaded_volume.
        load_a_gift( gift ).
        DELETE local_gifts.
      ENDIF.
      IF is_fully_loaded( ) = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.

    "loop over all un-picked in current location
*    LOOP AT all_gifts REFERENCE INTO DATA(gift) WHERE location = router->last_connection->dest AND picked = abap_false.
*      IF gift->weight <= max_weight - loaded_weight AND gift->volume <= max_volume - loaded_volume.
*        load_a_gift( gift ).
*      ENDIF.
*      IF is_fully_loaded( ) = abap_true.
*        RETURN.
*      ENDIF.
*    ENDLOOP.
  ENDMETHOD.


  METHOD load_simple_limited.
    IF loaded_volume >= i_max_volume OR loaded_weight >= i_max_weight.
      RETURN.
    ENDIF.
    LOOP AT local_gifts INTO DATA(gift).
      IF gift->weight <= max_weight - loaded_weight AND gift->volume <= max_volume - loaded_volume.
        load_a_gift( gift ).
        DELETE local_gifts.
      ENDIF.
      IF loaded_volume >= i_max_volume OR loaded_weight >= i_max_weight.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD load_for_targetted_city.
    LOOP AT local_gifts INTO DATA(gift).
      IF toolset->calc_target_city( gift->gift ) = router->targeted_city.
        IF gift->weight <= max_weight - loaded_weight AND gift->volume <= max_volume - loaded_volume.
          load_a_gift( gift ).
          DELETE local_gifts.
        ENDIF.
        IF is_fully_loaded( ) = abap_true.
          RETURN.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD load_for_path_cities_frm_1st.
    LOOP AT router->route ASSIGNING FIELD-SYMBOL(<step>).
      LOOP AT local_gifts INTO DATA(gift).
        IF toolset->calc_target_city( gift->gift ) = <step>-to.
          IF gift->weight <= max_weight - loaded_weight AND gift->volume <= max_volume - loaded_volume.
            load_a_gift( gift ).
            DELETE local_gifts.
          ENDIF.
          IF is_fully_loaded( ) = abap_true.
            RETURN.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.


  METHOD load_for_already_loaded.
    DATA loaded_gifts TYPE ymb112_gifts.

    IF is_fully_loaded( ) = abap_true.
      RETURN.
    ENDIF.

    SELECT * FROM @all_gifts AS gifts
      WHERE picked = @abap_true
      INTO TABLE @loaded_gifts
    .
    DATA(cities) = toolset->get_cities_wth_most_gifts( loaded_gifts ).

    LOOP AT cities ASSIGNING FIELD-SYMBOL(<city>).
      LOOP AT local_gifts ASSIGNING FIELD-SYMBOL(<gift>).
        IF <city>-city = toolset->calc_target_city( <gift>->gift ).
          IF <gift>->weight <= max_weight - loaded_weight AND <gift>->volume <= max_volume - loaded_volume.
            load_a_gift( <gift> ).
            DELETE local_gifts.
          ENDIF.
          IF is_fully_loaded( ) = abap_true.
            RETURN.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.


  METHOD load_most_for_one_limited.
    DATA gifts_for_loading TYPE ymb112_gifts.

    IF loaded_volume >= i_max_volume OR loaded_weight >= i_max_weight.
      RETURN.
    ENDIF.

    SELECT * FROM @all_gifts AS gifts
      WHERE picked = @abap_false
        AND location = @router->last_connection->dest
      INTO TABLE @gifts_for_loading.
    .
    DATA(cities) = toolset->get_cities_wth_most_gifts( gifts_for_loading ).

    LOOP AT cities ASSIGNING FIELD-SYMBOL(<city>).
      LOOP AT local_gifts ASSIGNING FIELD-SYMBOL(<gift>).
        IF <city>-city = toolset->calc_target_city( <gift>->gift ).
          IF <gift>->weight <= max_weight - loaded_weight AND <gift>->volume <= max_volume - loaded_volume.
            load_a_gift( <gift> ).
            DELETE local_gifts.
          ENDIF.
          IF loaded_volume >= i_max_volume OR loaded_weight >= i_max_weight.
            RETURN.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
