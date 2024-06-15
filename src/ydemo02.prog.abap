*&---------------------------------------------------------------------*
*& Report YDEMO02
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ydemo02.

SELECT * FROM sflight INTO TABLE @DATA(lt_sflight) WHERE CONNID = '0017'.
**********************************************************************
" exmple 1
TYPES: BEGIN OF ts_flight, " group
         airline   TYPE s_carrid,
         flight_no TYPE s_conn_id,
         currency  TYPE s_currcode,
         size      TYPE i,
       END OF ts_flight.
"
DATA ls_group TYPE ts_flight.
DATA lt_group TYPE TABLE OF ts_flight.
DATA lt_group_copy LIKE lt_group.
LOOP AT lt_sflight INTO DATA(flight)
GROUP BY ( airline = flight-carrid
flight_no = flight-connid
currency = flight-currency
size = GROUP SIZE )
ASCENDING ASSIGNING FIELD-SYMBOL(<group>).
  APPEND <group> TO lt_group.
  lt_group_copy = VALUE #( BASE lt_group_copy ( <group> ) ).
ENDLOOP.


BREAK-POINT.
**********************************************************************
" exmple 2
TYPES: BEGIN OF ts_flight2, " group
         airline    TYPE s_carrid,
         flight_no  TYPE s_conn_id,
         currency   TYPE s_currcode,
         paymentsum TYPE i,
         size       TYPE i,
       END OF ts_flight2.
"
DATA ls_group2 TYPE ts_flight2.
DATA lt_group2 TYPE TABLE OF ts_flight2.
LOOP AT lt_sflight INTO DATA(flight2)
GROUP BY ( airline = flight2-carrid
flight_no = flight2-connid
currency = flight2-currency
size = GROUP SIZE )
ASCENDING ASSIGNING FIELD-SYMBOL(<group2>).
  lt_group2 = VALUE #( BASE lt_group2 (
  airline = <group2>-airline
  flight_no = <group2>-flight_no
  currency = <group2>-currency
  size = <group2>-size
  paymentsum = REDUCE s_sum( INIT s = 0 FOR line IN GROUP <group2>
  NEXT s = s + line-paymentsum ) " reduce
  ) ). " value
ENDLOOP.
BREAK-POINT.


DATA ls_group3 TYPE ts_flight2.
DATA lt_group3 TYPE TABLE OF ts_flight2.

LOOP AT lt_sflight INTO DATA(flight3)
GROUP BY ( airline = flight3-carrid
flight_no = flight3-connid
currency = flight3-currency
size = GROUP SIZE )
ASCENDING ASSIGNING FIELD-SYMBOL(<group3>).
  lt_group3 = VALUE #( BASE lt_group3 (
  airline = <group3>-airline
  flight_no = <group3>-flight_no
  currency = <group3>-currency
  size = <group3>-size
  paymentsum = REDUCE s_sum( INIT s = 2 FOR line IN GROUP <group3>
                             NEXT s = s + line-paymentsum ) " reduce
  ) ). " value
ENDLOOP.

BREAK-POINT.
