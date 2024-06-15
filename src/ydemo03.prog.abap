*&---------------------------------------------------------------------*
*& Report YDEMO03
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ydemo03.

DATA: gr_table_head TYPE REF TO cl_salv_table.
DATA: gr_table_det TYPE REF TO cl_salv_table.
DATA: gt_outtab_head TYPE STANDARD TABLE OF alv_t_t2.
DATA: gt_outtab_det TYPE STANDARD TABLE OF alv_t_t2.
DATA: lr_events TYPE REF TO cl_salv_events_table.

CLASS ydemo01 DEFINITION.

  PUBLIC SECTION.
    METHODS: main.

ENDCLASS.

CLASS ydemo01 IMPLEMENTATION.

  METHOD main.


    DATA gr_splitter TYPE REF TO cl_gui_splitter_container.
    DATA gr_container_1 TYPE REF TO cl_gui_container.
    DATA gr_container_2 TYPE REF TO cl_gui_container.


    SELECT * FROM alv_chck INTO CORRESPONDING FIELDS OF TABLE gt_outtab_head
      UP TO 15 ROWS.

    SELECT * FROM alv_chck INTO CORRESPONDING FIELDS OF TABLE gt_outtab_det
    UP TO 2 ROWS.



    TRY.


        gr_splitter = NEW #( parent = cl_gui_container=>default_screen
                                   no_autodef_progid_dynnr = abap_true
                                   rows = 2
                                   columns = 1 ).

        gr_container_1 = gr_splitter->get_container( row = 1
                                                     column = 1 ).

        gr_container_2 = gr_splitter->get_container( row = 2
                                                     column = 1 ).


        cl_salv_table=>factory(
          EXPORTING
            r_container = gr_container_1
          IMPORTING
            r_salv_table = gr_table_head
          CHANGING
            t_table      = gt_outtab_head ).

*Set ALVfunctions - should you wish to include any

        gr_table_head->get_functions( )->set_all( abap_true ).



*Set displaysettings as usual

        DATA(lr_display_1) = gr_table_head->get_display_settings( ).

*Selection - set as usual

        gr_table_head->get_selections( )->set_selection_mode( if_salv_c_selection_mode=>multiple ).

*Layout - set as usual

        DATA(ls_key_1) = VALUE salv_s_layout_key( report = sy-cprog handle = '0001' ).

        DATA(lr_layout_1) = gr_table_head->get_layout( ).

        lr_layout_1->set_key( ls_key_1 ).

*        gr_table_head->set_screen_status( pfstatus = 'STANDARD'
*                            report = sy-repid
*                            set_functions = gr_table_head->c_functions_all ).


*
        cl_salv_table=>factory(
        EXPORTING
          r_container = gr_container_2
        IMPORTING
          r_salv_table = gr_table_det
        CHANGING
          t_table      = gt_outtab_det ).


        gr_table_det->get_functions( )->set_all( abap_true ).

        DATA(lr_display_2) = gr_table_det->get_display_settings( ).

* Layout - set as usual

        DATA(ls_key_2) = VALUE salv_s_layout_key( report = sy-cprog  handle = '0002').


        gr_table_head->display( ).

        gr_table_det->display( ).

      CATCH cx_salv_msg INTO DATA(lx_salv_msg).
        WRITE lx_salv_msg->get_longtext( ).             "#EC NO_HANDLER

      CATCH cx_root INTO DATA(lx_cx_root).
        WRITE lx_cx_root->get_longtext( ).              "#EC NO_HANDLER

    ENDTRY.

  ENDMETHOD.

ENDCLASS.

START-OF-SELECTION.

  DATA(o_report) = NEW ydemo01( ).

  o_report->main( ).
