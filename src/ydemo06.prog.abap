*&---------------------------------------------------------------------*
*& Report YDEMO01
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ydemo06.


DATA: gr_table_1 TYPE REF TO cl_salv_table.
DATA: gt_outtab_1 TYPE STANDARD TABLE OF sflight.

DATA: gr_table_head TYPE REF TO cl_salv_table.
DATA: gr_table_det TYPE REF TO cl_salv_table.
DATA: gt_outtab_head TYPE STANDARD TABLE OF alv_t_t2.
DATA: gt_outtab_det TYPE STANDARD TABLE OF alv_t_t2.
DATA: lr_events TYPE REF TO cl_salv_events_table.

DATA: o_splitter_main TYPE REF TO cl_gui_splitter_container.

DATA: o_container_o   TYPE REF TO cl_gui_container.
* Splitter-Container unten
DATA: o_container_u   TYPE REF TO cl_gui_container.

CLASS lcl_handle_events DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_user_command FOR EVENT added_function OF cl_salv_events
        IMPORTING e_salv_function.
  PRIVATE SECTION.
    METHODS:
      call_next_table.

ENDCLASS.                    "lcl_handle_events DEFINITION

CLASS lcl_handle_events IMPLEMENTATION.
  METHOD on_user_command.
    CASE sy-ucomm.
      WHEN 'RESUMEN'.
        call_next_table( ).
    ENDCASE.
  ENDMETHOD.

  METHOD call_next_table.

    CALL SCREEN 2000.

  ENDMETHOD.


ENDCLASS.

CLASS ydemo01 DEFINITION.

  PUBLIC SECTION.
    METHODS: main.

ENDCLASS.

CLASS ydemo01 IMPLEMENTATION.

  METHOD main.

    TRY.

        SELECT * FROM sflight INTO CORRESPONDING FIELDS OF TABLE gt_outtab_1
         UP TO 15 ROWS.

        cl_salv_table=>factory(
           IMPORTING
            r_salv_table = gr_table_1
          CHANGING
            t_table      = gt_outtab_1 ).

        gr_table_1->set_screen_status( pfstatus = 'STANDARD'
                     report = sy-repid
                     set_functions = gr_table_1->c_functions_all ).

        DATA: gr_events TYPE REF TO lcl_handle_events.
*... select new data

        lr_events = gr_table_1->get_event( ).

        CREATE OBJECT gr_events.

*... §6.1 register to the event USER_COMMAND
        SET HANDLER gr_events->on_user_command FOR lr_events.


        gr_table_1->display( ).


      CATCH cx_salv_msg INTO DATA(lx_salv_msg).
        lx_salv_msg->get_longtext( ).                   "#EC NO_HANDLER
    ENDTRY.

  ENDMETHOD.

ENDCLASS.

START-OF-SELECTION.

  DATA(o_report) = NEW ydemo01( ).

  o_report->main( ).
*&---------------------------------------------------------------------*
*&      Module  STATUS_2000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_2000 OUTPUT.
  SET PF-STATUS 'STANDARD'.

  SELECT *
 INTO TABLE @DATA(it_scarr)
 FROM scarr.

* Daten für SALV-Grid unten
  SELECT *
    INTO TABLE @DATA(it_sflight)
    FROM sflight.

* Referenzen auf GUI-Objekte
* Splitter

* Splitter-Container oben
*  DATA: o_container_o   TYPE REF TO cl_gui_container.
** Splitter-Container unten
*  DATA: o_container_u   TYPE REF TO cl_gui_container.

* Splitter auf default_screen erzeugen
  o_splitter_main = NEW #( parent                  = cl_gui_container=>default_screen "default_screen
                           no_autodef_progid_dynnr = abap_true       " wichtig
                           rows                    = 2
                           columns                 = 1 ).

* Höhe oberer Splitter in %
  o_splitter_main->set_row_height( id = 1 height = 40 ).

* REF auf oberen und unteren Splitcontainer holen
  o_container_o = o_splitter_main->get_container( row = 1 column = 1 ).
  o_container_u = o_splitter_main->get_container( row = 2 column = 1 ).

* SALV-Table oben mit Fluggesellschaften
  DATA: o_salv_o TYPE REF TO cl_salv_table.

  cl_salv_table=>factory( EXPORTING
                            r_container  = o_container_o
                          IMPORTING
                            r_salv_table = o_salv_o
                          CHANGING
                            t_table      = it_scarr ).

* Grundeinstellungen
  o_salv_o->get_functions( )->set_all( abap_true ).
  o_salv_o->get_columns( )->set_optimize( abap_true ).
  o_salv_o->get_display_settings( )->set_list_header( 'Fluggesellschaften' ).
  o_salv_o->get_display_settings( )->set_striped_pattern( abap_true ).
  o_salv_o->get_selections( )->set_selection_mode( if_salv_c_selection_mode=>row_column ).

* Spaltenüberschriften: technischer Name und Beschreibungstexte
  LOOP AT o_salv_o->get_columns( )->get( ) ASSIGNING FIELD-SYMBOL(<so>).
    DATA(o_col_o) = <so>-r_column.
    o_col_o->set_short_text( || ).
    o_col_o->set_medium_text( || ).
    o_col_o->set_long_text( |{ o_col_o->get_columnname( ) }| ).
  ENDLOOP.

* SALV-Grid anzeigen
  o_salv_o->display( ).

* SALV-Table unten mit Flügen
  DATA: o_salv_u TYPE REF TO cl_salv_table.

  cl_salv_table=>factory( EXPORTING
                            r_container  = o_container_u
                          IMPORTING
                            r_salv_table = o_salv_u
                          CHANGING
                            t_table      = it_sflight ).

* Grundeinstellungen
  o_salv_u->get_functions( )->set_all( abap_true ).
  o_salv_u->get_columns( )->set_optimize( abap_true ).
  o_salv_u->get_display_settings( )->set_list_header( 'Flüge' ).
  o_salv_u->get_display_settings( )->set_striped_pattern( abap_true ).
  o_salv_u->get_selections( )->set_selection_mode( if_salv_c_selection_mode=>row_column ).

* Spaltenüberschriften: technischer Name und Beschreibungstexte
  LOOP AT o_salv_u->get_columns( )->get( ) ASSIGNING FIELD-SYMBOL(<su>).
    DATA(o_col_u) = <su>-r_column.
    o_col_u->set_short_text( || ).
    o_col_u->set_medium_text( || ).
    o_col_u->set_long_text( |{ o_col_u->get_columnname( ) }| ).
  ENDLOOP.

* SALV-Grid anzeigen
  o_salv_u->display( ).

* leere Toolbar ausblenden
  "cl_abap_list_layout=>suppress_toolbar( ).

* Erzwingen von cl_gui_container=>default_screen

* WRITE: space.



ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_2000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_2000 INPUT.

  IF sy-ucomm = '&F03'.

    CALL METHOD o_salv_o->refresh( ). "!free.

    CALL METHOD o_salv_u->refresh( ). "free.

    o_container_o->free( ).
    o_container_u->free( ).
    o_splitter_main->free( ).


    LEAVE TO SCREEN 0. "PROGRAM.

  ENDIF.

ENDMODULE.
