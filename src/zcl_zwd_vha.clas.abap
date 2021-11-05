CLASS zcl_zwd_vha DEFINITION
  PUBLIC
  INHERITING FROM cl_wd_component_assistance
  CREATE PUBLIC .

  PUBLIC SECTION.

    DATA mv_attribute_changed TYPE flag READ-ONLY .
    CONSTANTS gc_return_exit TYPE string VALUE '*"eXiT==|*' ##NO_TEXT.

    METHODS on_attribute_changed
      FOR EVENT on_attribute_changed OF cl_wdr_context_element
      IMPORTING
        !attribute_name
        !controller
        !node
        !element
        !element_index
        !node_name
        !property .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_ZWD_VHA IMPLEMENTATION.


  METHOD on_attribute_changed.
    CHECK: controller->component->component_name EQ 'ZWD_VHA'.
    mv_attribute_changed = abap_true.
  ENDMETHOD.
ENDCLASS.
