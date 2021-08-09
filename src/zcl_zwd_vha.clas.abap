class ZCL_ZWD_VHA definition
  public
  inheriting from CL_WD_COMPONENT_ASSISTANCE
  create public .

public section.

  data MV_ATTRIBUTE_CHANGED type FLAG read-only .
  constants GC_RETURN_EXIT type STRING value '*"eXiT==|*' ##NO_TEXT.

  methods ON_ATTRIBUTE_CHANGED
    for event ON_ATTRIBUTE_CHANGED of CL_WDR_CONTEXT_ELEMENT
    importing
      !ATTRIBUTE_NAME
      !CONTROLLER
      !NODE
      !ELEMENT
      !ELEMENT_INDEX
      !NODE_NAME
      !PROPERTY .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZWD_VHA IMPLEMENTATION.


  METHOD on_attribute_changed.
    CHECK: controller->component->component_name EQ 'ZWD_VHA'.
    mv_attribute_changed = abap_true.
  ENDMETHOD.
ENDCLASS.
