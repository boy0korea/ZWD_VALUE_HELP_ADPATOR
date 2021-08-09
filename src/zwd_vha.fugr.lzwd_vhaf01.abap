*----------------------------------------------------------------------*
***INCLUDE LZWD_VHAF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form do_init
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM do_init .

  DATA: lo_parent TYPE REF TO cl_gui_container,
        lt_event  TYPE cntl_simple_events,
        ls_event  TYPE cntl_simple_event,
        lv_is_its TYPE flag.

  CREATE OBJECT go_event_handler.

  " full screen
  CREATE OBJECT go_gui_full_screen
    EXPORTING
      side      = cl_gui_docking_container=>dock_at_bottom
      extension = cl_gui_docking_container=>ws_maximizebox
      caption   = CONV text1000( gv_title ).
  lo_parent = go_gui_full_screen.

  " html viewer
  CREATE OBJECT go_gui_html_viewer
    EXPORTING
      parent               = lo_parent
      query_table_disabled = abap_true.
  ls_event-eventid = cl_gui_html_viewer=>m_id_sapevent.
  ls_event-appl_event = abap_true.
  APPEND ls_event TO lt_event.
  go_gui_html_viewer->set_registered_events( lt_event ).
  SET HANDLER go_event_handler->on_sapevent FOR go_gui_html_viewer.

  CALL FUNCTION 'GUI_IS_ITS'
    IMPORTING
      return = lv_is_its.

  IF lv_is_its EQ abap_false.
    PERFORM load_wd USING space.
  ELSE.
    PERFORM load_for_webgui.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form do_free_and_back
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM do_free_and_back .
  IF go_gui_html_viewer IS NOT INITIAL.
    go_gui_html_viewer->free( ).
  ENDIF.
  IF go_gui_full_screen IS NOT INITIAL.
    go_gui_full_screen->free( ).
  ENDIF.

  FREE: go_gui_html_viewer, go_gui_full_screen, go_event_handler.

  LEAVE TO SCREEN 0.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form on_sapevent
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ACTION
*&      --> POSTDATA
*&---------------------------------------------------------------------*
FORM on_sapevent  USING    iv_action
                           it_postdata TYPE cnht_post_data_tab.
  DATA: lv_param TYPE string.

  CONCATENATE LINES OF it_postdata INTO lv_param.

  CASE iv_action.
    WHEN 'START'.
      PERFORM load_wd USING lv_param.

    WHEN 'RETURN'.
      lv_param = lv_param+7.
      gv_value = cl_http_utility=>unescape_url( lv_param ).
      PERFORM do_free_and_back.

    WHEN OTHERS.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form load_wd
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_PARAM
*&---------------------------------------------------------------------*
FORM load_wd  USING    iv_param.
  DATA: lt_parameter TYPE tihttpnvp,
        ls_parameter TYPE ihttpnvp,
        lv_protocol  TYPE string,
        lv_string    TYPE string,
        lv_url       TYPE bxurlg-gen_url.

  IF iv_param CP 'url=https:*'.
    lv_protocol = 'https'.
  ENDIF.

  ls_parameter-name = 'GV_VALUE'.
  ls_parameter-value = gv_value.
  APPEND ls_parameter TO lt_parameter.

  ls_parameter-name = 'GV_COMPONENT_NAME'.
  ls_parameter-value = gv_component_name.
  APPEND ls_parameter TO lt_parameter.

  CALL FUNCTION 'WDY_CONSTRUCT_URL'
    EXPORTING
      protocol            = lv_protocol    " Predefined Type
      internalmode        = abap_false
      application         = 'ZWD_VHA' " Web Dynpro: Application Name
      parameters          = lt_parameter  " HTTP Framework (iHTTP) Table Name/Value Pairs
    IMPORTING
      out_url             = lv_string     " Predefined Type
    EXCEPTIONS
      invalid_application = 1           " DE-EN-LANG-SWITCH-NO-TRANSLATION
      OTHERS              = 2.

  lv_url = lv_string && '&' && iv_param.
  go_gui_html_viewer->enable_sapsso( abap_true ).
  go_gui_html_viewer->show_url( lv_url ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form load_for_webgui
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM load_for_webgui .
  DATA: lv_string TYPE string,
        lt_html   TYPE TABLE OF w3html,
        lv_url    TYPE bxurlg-gen_url.

  lv_string = '<html><body onload="z()">'
           && '<form id="start" method="post" action="SAPEVENT:START">'
           &&   '<input id="url" type="hidden" name="url" value="" />'
           && '</form>'
           && '<form id="post" method="post" action="SAPEVENT:RETURN">'
           &&   '<input id="return" type="hidden" name="return" value="" />'
           && '</form>'
           && '<script>'
           && 'function z() {'
           && 'if (window.location.search == "") {'
           &&   'document.getElementById("url").value = window.location.href;'
           &&   'document.getElementById("start").submit();'
           && '} else {'
           &&   'document.getElementById("return").value = window.location.search.substr(1);'
           &&   'document.getElementById("post").submit();'
           && '}'
           && '};'
           && '</script>'
           && '</body></html>'.

  CALL FUNCTION 'SCMS_STRING_TO_FTEXT'
    EXPORTING
      text      = lv_string
    TABLES
      ftext_tab = lt_html.
  go_gui_html_viewer->load_data(
    EXPORTING
      size                   = strlen( lv_string )                " Length of Data
    IMPORTING
      assigned_url           = lv_url     " URL
    CHANGING
      data_table             = lt_html       " data table
    EXCEPTIONS
      dp_invalid_parameter   = 1                " invalid parameter in a DP call
      dp_error_general       = 2                " gerneral error in a DP call
      cntl_error             = 3                " error
      html_syntax_notcorrect = 4                " HTML data is invalid and check all the tags' syntax
      OTHERS                 = 5
  ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  go_gui_html_viewer->show_url( lv_url ).

ENDFORM.
