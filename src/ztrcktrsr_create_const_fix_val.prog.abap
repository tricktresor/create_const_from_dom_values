*&---------------------------------------------------------------------*
*& Create Coding for structured constants of domains fixed values
*& with ABAPdoc description
*&---------------------------------------------------------------------*
REPORT ztrcktrsr_create_const_fix_val.

PARAMETERS p_const TYPE c LENGTH 30 DEFAULT 'C_CONS_STRUC' OBLIGATORY.
PARAMETERS p_prefix TYPE c LENGTH 20 DEFAULT 'C_'.

PARAMETERS p_rollnm TYPE rollname DEFAULT 'VBTYP' OBLIGATORY.
PARAMETERS p_langu  TYPE sylangu DEFAULT sy-langu OBLIGATORY.

PARAMETERS p_clpbd  AS CHECKBOX DEFAULT space.

START-OF-SELECTION.

  PERFORM create.


FORM create.

  DATA rollname_info TYPE dd04v.
  DATA fixed_values TYPE STANDARD TABLE OF dd07v WITH DEFAULT KEY.

  CALL FUNCTION 'DDIF_DTEL_GET'
    EXPORTING
      name          = p_rollnm
      state         = 'A'
      langu         = p_langu
    IMPORTING
      dd04v_wa      = rollname_info
    EXCEPTIONS
      illegal_input = 1
      OTHERS        = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    STOP.
  ENDIF.

  CALL FUNCTION 'DDIF_DOMA_GET'
    EXPORTING
      name          = rollname_info-domname
      state         = 'A'
      langu         = p_langu
    TABLES
      dd07v_tab     = fixed_values
    EXCEPTIONS
      illegal_input = 1
      OTHERS        = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    STOP.
  ENDIF.

  IF fixed_values IS INITIAL.
    STOP.
  ENDIF.


  TYPES _line TYPE c LENGTH 255.
  DATA lines TYPE STANDARD TABLE OF _line WITH EMPTY KEY.

  DATA line    TYPE _line.
  DATA comment TYPE _line.
  DATA doc     TYPE _line.

  line = |CONSTANTS: BEGIN OF { p_const },|.
  WRITE / line.
  APPEND line TO lines.


  LOOP AT fixed_values INTO DATA(dom_value).
    doc = dom_value-ddtext.
    REPLACE ALL OCCURRENCES OF '<' IN doc WITH '&lt;'.
    REPLACE ALL OCCURRENCES OF '>' IN doc WITH '&gt;'.
    comment = |"! { doc }|.
    APPEND comment TO lines.
    WRITE: /10 comment.
    line = |{ p_prefix }{ dom_value-domvalue_l } TYPE { p_rollnm } VALUE '{ dom_value-domvalue_l }',|.
    APPEND line TO lines.
    WRITE: /10 line.
  ENDLOOP.


  line = |           END OF { p_const }.|.
  APPEND line TO lines.
  WRITE / line.

  IF p_clpbd = abap_true.
    DATA lv_rc TYPE sysubrc.
    cl_gui_frontend_services=>clipboard_export(
      IMPORTING
        data                 = lines
      CHANGING
        rc                   = lv_rc ).

  ENDIF.
ENDFORM.
