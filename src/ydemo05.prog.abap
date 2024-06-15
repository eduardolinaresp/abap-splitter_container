*&---------------------------------------------------------------------*
*& Report YDEMO05
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT YDEMO05.

SELECT *
  INTO TABLE @DATA(it_scarr)
  FROM scarr.

* Daten für SALV-Grid unten
SELECT *
  INTO TABLE @DATA(it_sflight)
  FROM sflight.

* Referenzen auf GUI-Objekte
* Splitter
DATA: o_splitter_main TYPE REF TO cl_gui_splitter_container.
* Splitter-Container oben
DATA: o_container_o   TYPE REF TO cl_gui_container.
* Splitter-Container unten
DATA: o_container_u   TYPE REF TO cl_gui_container.

* Splitter auf default_screen erzeugen
o_splitter_main = NEW #( parent                  = cl_gui_container=>default_screen
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
cl_abap_list_layout=>suppress_toolbar( ).

* Erzwingen von cl_gui_container=>default_screen
WRITE: space.
