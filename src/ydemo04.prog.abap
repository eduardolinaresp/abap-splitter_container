*&---------------------------------------------------------------------*
*& Report YDEMO04
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ydemo04.

DATA: gr_container TYPE REF TO cl_gui_docking_container.   "The carrier for the split container
DATA: lv_splitter TYPE REF TO cl_gui_splitter_container.  "The splitter itself
DATA: lv_parent1 TYPE REF TO cl_gui_container.           "parent 1 and 2
DATA: lv_parent2 TYPE REF TO cl_gui_container.

DATA ref_grid1 TYPE REF TO cl_gui_alv_grid.
DATA ref_grid2 TYPE REF TO cl_gui_alv_grid.
DATA: gr_table1 TYPE REF TO cl_salv_table.
DATA: gr_table2 TYPE REF TO cl_salv_table.

"Some data used for DB query
DATA: gt_mara TYPE STANDARD TABLE OF mara.
DATA: gt_mard TYPE STANDARD TABLE OF mard.


START-OF-SELECTION.

  SELECT * FROM mara INTO TABLE gt_mara UP TO 200 ROWS.
  SELECT * FROM mard INTO TABLE gt_mard UP TO 200 ROWS.

  CALL SCREEN 2000.
*&---------------------------------------------------------------------*
*&      Module  STATUS_2000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_2000 OUTPUT.
  SET PF-STATUS 'STANDARD'.
*  SET TITLEBAR 'xxx'.

  CREATE OBJECT gr_container
    EXPORTING
*     parent                      = g_grid_main
      repid                       = sy-repid                                  "needs report id
      dynnr                       = sy-dynnr                                  "need dynpro number
      side                        = cl_gui_docking_container=>dock_at_bottom  "we want to add the docking on the bottom of the screen 2000
      extension                   = cl_gui_docking_container=>ws_maximizebox "The Dockingcontainer should use the hole screen
*     style                       =
*     lifetime                    = lifetime_default
*     caption                     =
*     metric                      = 0
*     ratio                       = 70
*     no_autodef_progid_dynnr     =
*     name                        =
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5
      OTHERS                      = 6.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


**   create splitter container in which we'll place the alv table
  CREATE OBJECT lv_splitter
    EXPORTING
      parent  = gr_container
      rows    = 2
      columns = 1
      align   = 15. " (splitter fills the hole custom container)
**   get part of splitter container for 1st table
  CALL METHOD lv_splitter->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = lv_parent1.
**   get part of splitter container for 2nd table
  CALL METHOD lv_splitter->get_container
    EXPORTING
      row       = 2
      column    = 1
    RECEIVING
      container = lv_parent2.

***  Display first ALV
  PERFORM set_display.
***  Display second ALV
  PERFORM set_display1.


ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_2000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_2000 INPUT.

  IF sy-ucomm = '&F03'.
    LEAVE PROGRAM.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Form  SET_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_display .

  CALL METHOD cl_salv_table=>factory
    EXPORTING
      r_container  = lv_parent1
    IMPORTING
      r_salv_table = gr_table1
    CHANGING
      t_table      = gt_mara.

*... Display table
  gr_table1->display( ).
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_DISPLAY1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_display1 .

  CALL METHOD cl_salv_table=>factory
    EXPORTING
      r_container  = lv_parent2
    IMPORTING
      r_salv_table = gr_table2
    CHANGING
      t_table      = gt_mard.

*... Display table
  gr_table2->display( ).


ENDFORM.
