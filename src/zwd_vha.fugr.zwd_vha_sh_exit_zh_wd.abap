FUNCTION zwd_vha_sh_exit_zh_wd .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      SHLP_TAB TYPE  SHLP_DESCT
*"      RECORD_TAB STRUCTURE  SEAHLPRES
*"  CHANGING
*"     VALUE(SHLP) TYPE  SHLP_DESCR
*"     VALUE(CALLCONTROL) LIKE  DDSHF4CTRL STRUCTURE  DDSHF4CTRL
*"----------------------------------------------------------------------
* https://github.com/boy0korea/ZWD_VALUE_HELP_ADPATOR
  DATA: ls_selopt         TYPE ddshselopt,
        ls_fieldprop      TYPE ddshfprop,
        ls_fielddescr     TYPE dfies,
        ls_fieldiface     TYPE ddshiface,
        lv_component_name TYPE wdy_component_name,
        lv_value          TYPE text1000,
        BEGIN OF ls_select_list,
          ev_value TYPE text1000,
        END OF ls_select_list,
        lt_select_list LIKE TABLE OF ls_select_list,
        lv_index       TYPE i.


  CHECK: callcontrol-step EQ 'SELECT'.
  CLEAR: record_tab[].

  " shlp-selopt
  LOOP AT shlp-selopt INTO ls_selopt.
    CASE ls_selopt-shlpfield.
      WHEN 'IV_COMPONENT_NAME'.
        lv_component_name = ls_selopt-low.
      WHEN 'EV_VALUE'.
        lv_value = ls_selopt-low.
    ENDCASE.
  ENDLOOP.

  " shlp-fieldprop
  IF lv_component_name IS INITIAL.
    READ TABLE shlp-fieldprop INTO ls_fieldprop WITH KEY fieldname = 'IV_COMPONENT_NAME'.
    IF ls_fieldprop-defaultval IS NOT INITIAL.
      lv_component_name = ls_fieldprop-defaultval.
      REPLACE ALL OCCURRENCES OF `'` IN lv_component_name WITH ''.
    ENDIF.
  ENDIF.

  " shlp-interface
  IF lv_component_name IS INITIAL.
    READ TABLE shlp-interface INTO ls_fieldiface WITH KEY shlpfield = 'IV_COMPONENT_NAME'.
    IF ls_fieldiface-value IS NOT INITIAL.
      lv_component_name = ls_fieldiface-value.
    ENDIF.
  ENDIF.

  IF lv_value IS INITIAL.
    READ TABLE shlp-interface INTO ls_fieldiface WITH KEY shlpfield = 'EV_VALUE'.
    IF ls_fieldiface-value IS NOT INITIAL.
      lv_value = ls_fieldiface-value.
    ENDIF.
  ENDIF.

  IF lv_component_name IS INITIAL.
    callcontrol-step = 'EXIT'.
    RETURN.
  ENDIF.

  gv_title = shlp-intdescr-title.
  gv_component_name = lv_component_name.
  gv_value = lv_value.

  IF wdr_task=>application IS INITIAL.
    CALL SCREEN 1000.
    lv_value = gv_value.
  ELSE.
    lcl_wd_sh=>open( ).
    callcontrol-step = 'EXIT'.
    SET HANDLER lcl_on_close_wdr_f4_elementary=>on_close. " remove cancel message
    RETURN.
  ENDIF.

  IF lv_value EQ zcl_zwd_vha=>gc_return_exit.
    callcontrol-step = 'EXIT'.
    RETURN.
  ENDIF.

  callcontrol-step = 'RETURN'.
  ls_select_list-ev_value = lv_value.
  APPEND ls_select_list TO lt_select_list.

* map
  CALL FUNCTION 'F4UT_RESULTS_MAP'
    TABLES
      shlp_tab    = shlp_tab
      record_tab  = record_tab
      source_tab  = lt_select_list
    CHANGING
      shlp        = shlp
      callcontrol = callcontrol.


ENDFUNCTION.
