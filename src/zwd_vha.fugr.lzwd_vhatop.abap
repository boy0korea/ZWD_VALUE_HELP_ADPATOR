FUNCTION-POOL zwd_vha.                      "MESSAGE-ID ..

CLASS lcl_event_handler DEFINITION DEFERRED.
DATA: gv_value           TYPE string,
      gv_title           TYPE string,
      gv_component_name  TYPE string,
      go_gui_full_screen TYPE REF TO cl_gui_docking_container,
      go_gui_html_viewer TYPE REF TO cl_gui_html_viewer,
      go_event_handler   TYPE REF TO lcl_event_handler.

*----------------------------------------------------------------------*
*       CLASS lcl_event_handler DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_event_handler DEFINITION.
  PUBLIC SECTION.
    METHODS on_sapevent
      FOR EVENT sapevent OF cl_gui_html_viewer
      IMPORTING
        !action
        !frame
        !getdata
        !postdata
        !query_table .
ENDCLASS.                    "lcl_event_handler DEFINITION
*----------------------------------------------------------------------*
*       CLASS lcl_event_handler IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_event_handler IMPLEMENTATION.
  METHOD on_sapevent.
    PERFORM on_sapevent USING action postdata.
  ENDMETHOD.
ENDCLASS.                    "lcl_event_handler IMPLEMENTATION


CLASS lcl_on_close_wdr_f4_elementary DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS on_close
      FOR EVENT on_controller_exit OF cl_wdr_controller
      IMPORTING controller.
ENDCLASS.
CLASS lcl_on_close_wdr_f4_elementary IMPLEMENTATION.
  METHOD on_close.
    DATA: lo_m TYPE REF TO if_wd_message_manager,
          lt_m TYPE if_wd_message_manager=>ty_t_messages,
          ls_m TYPE if_wd_message_manager=>ty_s_message.

    IF controller->component->component_name EQ 'WDR_F4_ELEMENTARY'.
      lo_m = controller->component->if_wd_controller~get_message_manager( ).
      lt_m = lo_m->get_messages( ).
      LOOP AT lt_m INTO ls_m.
        IF ls_m-msg_object IS INSTANCE OF cx_wdr_value_help.
          lo_m->remove_message( ls_m-msg_id ).
        ENDIF.
      ENDLOOP.
      SET HANDLER lcl_on_close_wdr_f4_elementary=>on_close ACTIVATION abap_false.
    ENDIF.
  ENDMETHOD.
ENDCLASS.



CLASS lcl_sh_context DEFINITION INHERITING FROM cl_wdr_default_shlp_context.
  PUBLIC SECTION.
    CLASS-METHODS open
      IMPORTING io_sh_context TYPE REF TO cl_wdr_default_shlp_context.
ENDCLASS.
CLASS lcl_sh_context IMPLEMENTATION.
  METHOD open.
*    eo_context = io_sh_context->m_context_element.
    DATA: lv_comp_usage_name TYPE string.
    lv_comp_usage_name = 'ZWD_VHA_' && gv_component_name.

    " regist reuse
    cl_wdr_runtime_services=>get_component_usage(
      EXPORTING
        component            = io_sh_context->view->if_wd_controller~get_component( )
        used_component_name  = gv_component_name
        component_usage_name = lv_comp_usage_name
        create_component     = abap_true
        do_create            = abap_true
    ).

    " open WD
    cl_wdr_value_help_handler=>handle_application_def_vh(
      EXPORTING
        context_element      = io_sh_context->m_context_element
        component_usage_name = lv_comp_usage_name
        context_attribute    = io_sh_context->attribute_name
        is_read_only         = io_sh_context->if_wdr_shlp_context_manager~read_only
        label_text           = gv_title
        view                 = io_sh_context->view
    ).

  ENDMETHOD.
ENDCLASS.

CLASS lcl_wd_sh DEFINITION INHERITING FROM cl_wdr_ddic_search_help.
  PUBLIC SECTION.
    CLASS-METHODS open.
    METHODS get_short_title REDEFINITION.
    METHODS get_name REDEFINITION.
    METHODS display REDEFINITION.
    METHODS get_disponly REDEFINITION.
    METHODS get_has_dependend_fields REDEFINITION.
    METHODS get_searches REDEFINITION.
    METHODS get_metadata REDEFINITION.
ENDCLASS.
CLASS lcl_wd_sh IMPLEMENTATION.
  METHOD open.
    DATA: lo_component_d TYPE REF TO object,
          lo_sh_context  TYPE REF TO cl_wdr_default_shlp_context.
    FIELD-SYMBOLS: <lo_search_help> TYPE REF TO cl_wdr_elementary_search_help.

    lo_component_d = wdr_task=>application->get_component_for_name( 'WDR_F4_ELEMENTARY' )->component->get_delegate( ).
    ASSIGN lo_component_d->('IG_COMPONENTCONTROLLER~SEARCH_HELP') TO <lo_search_help>.
    lo_sh_context ?= <lo_search_help>->context_manager.

    lcl_sh_context=>open( lo_sh_context ).

  ENDMETHOD.
  METHOD get_short_title.ENDMETHOD.
  METHOD get_name.ENDMETHOD.
  METHOD display.ENDMETHOD.
  METHOD get_disponly.ENDMETHOD.
  METHOD get_has_dependend_fields.ENDMETHOD.
  METHOD get_searches.ENDMETHOD.
  METHOD get_metadata.ENDMETHOD.
ENDCLASS.
