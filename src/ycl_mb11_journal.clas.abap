CLASS ycl_mb11_journal DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS add_gift_left
      IMPORTING gift TYPE int4.
    METHODS add_gift_picked
      IMPORTING gift TYPE int4.
    METHODS set_next_city
      IMPORTING city TYPE ymb11_city.
    METHODS save_to_journal.
    METHODS get_journal
      RETURNING VALUE(result) TYPE string.
    METHODS persist_journal
      IMPORTING
        i_scenario TYPE int2
        i_description TYPE ymb11_scenario_description
        i_time TYPE int4 OPTIONAL.

  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA: gifts_left   TYPE string,
          gifts_picked TYPE string,
          next_city    TYPE string.
    DATA: journal_file TYPE string.


ENDCLASS.



CLASS ycl_mb11_journal IMPLEMENTATION.

  METHOD add_gift_left.
    gifts_left = gifts_left && `;` && gift.
  ENDMETHOD.


  METHOD add_gift_picked.
    gifts_picked = gifts_picked && `;` && gift.
  ENDMETHOD.


  METHOD set_next_city.
    next_city = city.
  ENDMETHOD.


  METHOD save_to_journal.
    IF gifts_left IS INITIAL.
      gifts_left = `-1`.
    ELSE.
      SHIFT gifts_left BY 1 PLACES LEFT.  "get rid of initial separator
    ENDIF.

    IF gifts_picked IS INITIAL.
      gifts_picked = `-1`.
    ELSE.
      SHIFT gifts_picked BY 1 PLACES LEFT.
    ENDIF.

    journal_file = journal_file && gifts_left && cl_abap_char_utilities=>cr_lf
                && gifts_picked && cl_abap_char_utilities=>cr_lf
                && next_city && cl_abap_char_utilities=>cr_lf.

    CLEAR: gifts_left, gifts_picked, next_city.
  ENDMETHOD.


  METHOD get_journal.
    result = journal_file.
  ENDMETHOD.

  METHOD persist_journal.

    DATA timestamp TYPE abp_creation_tstmpl.

    GET TIME STAMP FIELD timestamp.

    DATA(attachment) = cl_abap_conv_codepage=>create_out( )->convert( shift_right( val = journal_file sub = cl_abap_char_utilities=>cr_lf ) ).

    DATA(solution) = VALUE ymb11files(
*      client               =
      scenario             = i_scenario
      file_purpose         = 'RES'
      scenario_description = i_description
      time                 = i_time
      attachment           = attachment
      mimetype             = 'text/csv'
      filename             = |output_steps_Vault_Boy{ i_scenario }.csv|
      createdby            = cl_abap_context_info=>get_user_technical_name( )
      createdat            = timestamp
      lastchangedby        = cl_abap_context_info=>get_user_technical_name( )
      lastchangedat        = timestamp
    ).

    SELECT SINGLE *
      FROM ymb11files
      WHERE scenario = @i_scenario
        AND file_purpose = 'RES'
      INTO @solution.
    IF sy-subrc = 0.
      solution-scenario_description = i_description.
      solution-time           = i_time.
      solution-attachment     = attachment.
      solution-lastchangedby  = cl_abap_context_info=>get_user_technical_name( ).
      solution-lastchangedat  = timestamp.
      UPDATE ymb11files FROM @solution.
    ELSE.
      INSERT ymb11files FROM @solution.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
