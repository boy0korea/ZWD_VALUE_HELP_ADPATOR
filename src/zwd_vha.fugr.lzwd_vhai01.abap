*----------------------------------------------------------------------*
***INCLUDE LZWD_VHAI01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_1000 INPUT.
  CASE sy-ucomm.
    WHEN 'BACK'.
      gv_value = zcl_zwd_vha=>gc_return_exit.
      PERFORM do_free_and_back.
    WHEN OTHERS.
      CALL METHOD cl_gui_cfw=>dispatch.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_1000  INPUT
