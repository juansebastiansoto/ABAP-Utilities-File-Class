class ZCL_CA_FILE_UTILITIES definition
  public
  final
  create public .

public section.

  types:
    BEGIN OF ty_otf,
             copies TYPE num,
             otf    TYPE tsfotf,
           END OF ty_otf .
  types:
    ty_t_otf TYPE STANDARD TABLE OF ty_otf .

  class-methods CALCULATE_FILE_SIZE
    importing
      !TYPE type CHAR10 default 'ASC'
      !DATA type ANY TABLE
    preferred parameter TYPE
    returning
      value(SIZE) type I
    exceptions
      FORMAT_NOT_SUPPORTED .
  class-methods CREATE_ZIP_FILE_APP_SVR
    importing
      !ZIP_NAME type ESEFTAPPL
      !FILES type ZBCTPFILES
    exceptions
      FILES_IS_INITIAL .
  class-methods FILESOURCE_FROM_PATH
    importing
      !PATH type STRING
    exporting
      !DRIVE type STRING
      !DRIVE_UNIT type STRING
      !REAL_PATH type STRING
    exceptions
      PATH_ERROR .
  class-methods FIXEDTAB_TO_STANDARDTAB
    importing
      !INPUT type STRINGTAB
      !LENGTHS type INT4_TABLE
    exporting
      !OUTPUT type STANDARD TABLE
    exceptions
      ASSIGN_ERROR .
  class-methods FIXEDTAB_TO_STANDARDTAB_2
    importing
      !INPUT type STRINGTAB
    exporting
      !OUTPUT type STANDARD TABLE .
  class-methods GET_FILE_SEPARATOR
    importing
      !BATCH type SY-BATCH optional
    changing
      value(FILE_SEPARATOR) type C
    exceptions
      NOT_SUPPORTED_BY_GUI
      ERROR_NO_GUI
      CNTL_ERROR .
  class-methods MERGE_OTF_INTO_1_PDF
    importing
      !OTF_TABS type TY_T_OTF
    exporting
      !PDF type XSTRING
      !FILESIZE type SO_OBJ_LEN .
  class-methods STANDARDTAB_TO_STRINGTAB
    importing
      !INPUT type ANY TABLE
      !SPLITTER type ABAP_CHAR1 default CL_ABAP_CHAR_UTILITIES=>HORIZONTAL_TAB
      !ENCLOSED type ABAP_CHAR1 default ''
      !DECIMALS_FLOAT type QSTELLEN default 0
    exporting
      !OUTPUT type STRINGTAB .
  class-methods STRINGTAB_TO_STANDARDTAB
    importing
      !INPUT type STRINGTAB
      !SPLIT type ABAP_CHAR1 default CL_ABAP_CHAR_UTILITIES=>HORIZONTAL_TAB
    exporting
      value(OUTPUT) type STANDARD TABLE
    exceptions
      ASSIGN_ERROR .
  class-methods ARCHIVFILE_SERVER_TO_SERVER
    importing
      !SOURCE type ZBCDE0000
      !TARGET type ZBCDE0000
      !MOVE type ABAP_BOOL default ''
    raising
      CX_T100_MSG
      CX_SY_FILE_OPEN
      CX_SY_CODEPAGE_CONVERTER_INIT
      CX_SY_CONVERSION_CODEPAGE
      CX_SY_FILE_AUTHORITY
      CX_SY_FILE_IO
      CX_SY_FILE_OPEN_MODE
      CX_SY_FILE_CLOSE .
  class-methods ARCHIVFILE_CLIENT_TO_SERVER
    importing
      !SOURCE type ZBCDE0000
      !TARGET type ZBCDE0000
      !MOVE type ABAP_BOOL default ''
    raising
      CX_T100_MSG
      CX_SY_FILE_OPEN
      CX_SY_CODEPAGE_CONVERTER_INIT
      CX_SY_CONVERSION_CODEPAGE
      CX_SY_FILE_AUTHORITY
      CX_SY_FILE_IO
      CX_SY_FILE_OPEN_MODE
      CX_SY_FILE_CLOSE .
  class-methods CONVERT_GENERIC_TO_STRING
    importing
      !INPUT type ANY
      !OUTPUT_FORMAT type BOOLEAN default ''
    returning
      value(OUTPUT) type STRING .
protected section.

  class-methods ADD_FILE_TO_ZIP
    importing
      !XSTRING_DATA type XSTRING
      !FILE_NAME_IN_ZIP type ZBCSFILES-FILE_NAME_IN_ZIP
    changing
      value(ZIPPER) type ref to CL_ABAP_ZIP .
  class-methods CATCH_TOO_LONG
    importing
      !INPUT type STRING
      !AGGREGATE type I
    changing
      !LENGTH type I
      !FIELD type ANY .
  class-methods CONVERT_BIN_TO_XSTRING
    importing
      !LENGTH type I
    changing
      !XSTRING_DATA type XSTRING
      !FILE_DATA type SWFTLISTI1 .
  class-methods DOWNLOAD_ZIP_FILE
    importing
      !FILENAME type ESEFTAPPL
    exporting
      !FILE_TAB_ZIP type SWFTLISTI1 .
  class-methods READ_FILE
    importing
      !FILE type ZBCSFILES
    exporting
      !LENGTH type I
      !FILE_DATA type SWFTLISTI1 .
  class-methods SAVE_ZIP
    importing
      !ZIPPER type ref to CL_ABAP_ZIP
    exporting
      !ZIP type XSTRING
    changing
      !FILE_TAB_ZIP type SWFTLISTI1 .
private section.

  class-methods GET_LENGTH
    importing
      !INPUT type ANY
      !OUTPUT_FORMAT type BOOLEAN default ''
    returning
      value(LENGTH) type I .
ENDCLASS.



CLASS ZCL_CA_FILE_UTILITIES IMPLEMENTATION.


METHOD add_file_to_zip.

  DATA: vl_file_name TYPE string.

  vl_file_name = file_name_in_zip.

* Add the file into the ZIP
  CALL METHOD zipper->add
    EXPORTING
      name    = vl_file_name
      content = xstring_data.

ENDMETHOD.


METHOD archivfile_client_to_server.

  DATA: lt_asc TYPE stringtab.

  DATA: lv_asc TYPE string,
        lv_rc  TYPE i.

* Read the source file
  CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
      filename                = source
    CHANGING
      data_tab                = lt_asc
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      not_supported_by_gui    = 17
      error_no_gui            = 18
      OTHERS                  = 19.

  IF sy-subrc NE 0.

    RAISE EXCEPTION TYPE cx_t100_msg
      EXPORTING
        t100_msgid = '/BOBF/COM_GENERATOR'
        t100_msgno = 229
        t100_msgv1 = 'CL_GUI_FRONTEND_SERVICES'
        t100_msgv2 = 'GUI_UPLOAD'.

  ENDIF.

* Try open the target file
  OPEN DATASET target FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.

* Exit with false if can not open the file
  IF sy-subrc NE 0.

    RAISE EXCEPTION TYPE cx_t100_msg
      EXPORTING
        t100_msgid = 'HRPSGB_HER'
        t100_msgno = 044.

  ENDIF.

  LOOP AT lt_asc INTO lv_asc.
    TRANSFER lv_asc TO target.
  ENDLOOP.

  CLOSE DATASET target.

  IF move EQ abap_true.

    CALL METHOD cl_gui_frontend_services=>file_delete
      EXPORTING
        filename             = source
      CHANGING
        rc                   = lv_rc
      EXCEPTIONS
        file_delete_failed   = 1
        cntl_error           = 2
        error_no_gui         = 3
        file_not_found       = 4
        access_denied        = 5
        unknown_error        = 6
        not_supported_by_gui = 7
        wrong_parameter      = 8
        OTHERS               = 9.

    IF sy-subrc NE 0
    OR lv_rc    NE 0.

      RAISE EXCEPTION TYPE cx_t100_msg
        EXPORTING
          t100_msgid = '/BOBF/COM_GENERATOR'
          t100_msgno = 229
          t100_msgv1 = 'CL_GUI_FRONTEND_SERVICES'
          t100_msgv2 = 'FILE_DELETE'.

    ENDIF.

  ENDIF.

ENDMETHOD.


METHOD archivfile_server_to_server.

  DATA: lt_asc TYPE stringtab.

  DATA: lv_asc TYPE string.

* Try open the source file
  OPEN DATASET source FOR INPUT IN TEXT MODE ENCODING DEFAULT.

* Exit with false if can not open the file
  IF sy-subrc NE 0.

    RAISE EXCEPTION TYPE cx_t100_msg
      EXPORTING
        t100_msgid = '5M'
        t100_msgno = 314.

  ENDIF.

* Try open the target file
  OPEN DATASET target FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.

* Exit with false if can not open the file
  IF sy-subrc NE 0.

    RAISE EXCEPTION TYPE cx_t100_msg
      EXPORTING
        t100_msgid = 'HRPSGB_HER'
        t100_msgno = 044.

  ENDIF.

* Transfer the content
  DO.

    READ DATASET source INTO lv_asc.

    IF sy-subrc NE 0.
      EXIT.
    ENDIF.

    TRANSFER lv_asc TO target.

  ENDDO.

* Close files
  CLOSE DATASET source.
  CLOSE DATASET target.

* Delete source file if was wanted
  IF move EQ abap_true.
    DELETE DATASET source.
  ENDIF.

ENDMETHOD.


METHOD calculate_file_size.

  FIELD-SYMBOLS: <fsl_data> TYPE ANY.

  DATA: vl_size TYPE i,
        vl_data TYPE string.

  CASE type.
    WHEN 'ASC'.

      LOOP AT data ASSIGNING <fsl_data>.
        DESCRIBE FIELD <fsl_data> LENGTH vl_size IN CHARACTER MODE.
        size = size  + vl_size.
      ENDLOOP.

    WHEN 'BIN'.

      LOOP AT data INTO vl_data.
        ASSIGN vl_data TO <fsl_data>.
        vl_size = STRLEN( <fsl_data> ).
        size = size  + vl_size.
      ENDLOOP.

    WHEN OTHERS.

      MESSAGE e873(td) WITH type RAISING format_not_supported.
*     Format & not supported

  ENDCASE.

ENDMETHOD.


METHOD catch_too_long.

  TRY.

*     Try with 1 less length
      length  = length - 1.
      field = input+aggregate(length).

    CATCH cx_sy_range_out_of_bounds.

*     Try again
      CALL METHOD zcl_ca_file_utilities=>catch_too_long
        EXPORTING
          input     = input
          aggregate = aggregate
        CHANGING
          length    = length
          field     = field.

  ENDTRY.

ENDMETHOD.


METHOD convert_bin_to_xstring.

  CLEAR xstring_data.

  CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
    EXPORTING
      input_length = length
    IMPORTING
      buffer       = xstring_data
    TABLES
      binary_tab   = file_data.

ENDMETHOD.


METHOD convert_generic_to_string.

  DATA: lo_handle TYPE REF TO cl_abap_structdescr,
        lo_charlike TYPE REF TO data.

  DATA: lw_components TYPE LINE OF abap_compdescr_tab.

  DATA: lv_all     TYPE i,
        lv_length  TYPE i.

  FIELD-SYMBOLS: <fsl_field> TYPE any,
                 <fsl_charlike>   TYPE any.

* Inspecciono la definición del input
  lo_handle ?= cl_abap_datadescr=>describe_by_data( input ).

  LOOP AT lo_handle->components INTO lw_components.

    ASSIGN COMPONENT sy-tabix OF STRUCTURE input TO <fsl_field>.

*   Recupero el largo máximo definido en <FSL_FIELD>
    lv_length = zcl_ca_file_utilities=>get_length( <fsl_field> ).

*   Creo un tipo de dato de character con el largo máximo
    CREATE DATA lo_charlike TYPE c LENGTH lv_length.

    ASSIGN lo_charlike->* TO <fsl_charlike>.

*   Convierto a character el valor
    IF output_format EQ abap_true.
      WRITE <fsl_field> TO <fsl_charlike>.
    ELSE.
      <fsl_charlike> = <fsl_field>.
    ENDIF.

*   Agrego al string
    CONCATENATE output(lv_all)
                <fsl_charlike>
    INTO output
    RESPECTING BLANKS.

    ADD lv_length TO lv_all.

  ENDLOOP.

ENDMETHOD.


METHOD create_zip_file_app_svr.

  DATA: ol_zipper       TYPE REF TO cl_abap_zip.

  DATA: tl_file_data    TYPE STANDARD TABLE OF solisti1,
        tl_file_tab_zip TYPE STANDARD TABLE OF solisti1.

  DATA: wl_file         TYPE zbcsfiles.

  DATA: vl_bin_filesize TYPE i,
        vl_xstring_data TYPE xstring,
        vl_zip          TYPE xstring.

***
* 1.- Create ZIP file
***
  CREATE OBJECT ol_zipper.

***
* 2.- Each file to compress
***
  LOOP AT files INTO wl_file.

***
* 3.- Read the file
***
    CALL METHOD zcl_ca_file_utilities=>read_file
      EXPORTING
        file      = wl_file
      IMPORTING
        length    = vl_bin_filesize
        file_data = tl_file_data.


***
* 4.- Convert to XString
***
    CALL METHOD zcl_ca_file_utilities=>convert_bin_to_xstring
      EXPORTING
        length       = vl_bin_filesize
      CHANGING
        xstring_data = vl_xstring_data
        file_data    = tl_file_data.

****
** 5.- Add the file in the ZIP
****

    CALL METHOD zcl_ca_file_utilities=>add_file_to_zip
      EXPORTING
        xstring_data     = vl_xstring_data
        file_name_in_zip = wl_file-file_name_in_zip
      CHANGING
        zipper           = ol_zipper.

    AT LAST.

***
* 6.- Save the ZIP file
***

      CALL METHOD zcl_ca_file_utilities=>save_zip
        EXPORTING
          zipper       = ol_zipper
        IMPORTING
          zip          = vl_zip
        CHANGING
          file_tab_zip = tl_file_tab_zip.

***
* 7.- Download ZIP
***

      CALL METHOD zcl_ca_file_utilities=>download_zip_file
        EXPORTING
          filename     = zip_name
        IMPORTING
          file_tab_zip = tl_file_tab_zip.

    ENDAT.

  ENDLOOP.

  IF sy-subrc NE 0.
    MESSAGE e021(earc) RAISING files_is_initial.
*   No archive files exist that can be opened
  ENDIF.

ENDMETHOD.


METHOD download_zip_file.

  DATA: wl_file_tab_zip TYPE solisti1.

  OPEN DATASET filename FOR OUTPUT IN BINARY MODE.

  IF sy-subrc EQ 0.
    LOOP AT file_tab_zip INTO wl_file_tab_zip.
      TRANSFER wl_file_tab_zip TO filename.
    ENDLOOP.
  ELSE.
    MESSAGE i012(ba) WITH filename.
*   Cannot open archive file &
  ENDIF.

  CLOSE DATASET filename.

ENDMETHOD.


METHOD filesource_from_path.

  DATA: t_string      TYPE STANDARD TABLE OF string.

  DATA: vl_type       TYPE string,
        vl_reg_value  TYPE string,
        vl_key        TYPE string,
        vl_drive      TYPE string.

  IF path IS INITIAL OR STRLEN( path ) LE 1.
    RAISE path_error.
  ENDIF.

  real_path = path.
  vl_drive = path(2).

* Get the source drive type
  CALL METHOD cl_gui_frontend_services=>get_drive_type
    EXPORTING
      drive                = vl_drive
    CHANGING
      drive_type           = vl_type
    EXCEPTIONS
      cntl_error           = 1
      bad_parameter        = 2
      error_no_gui         = 3
      not_supported_by_gui = 4
      OTHERS               = 5.
  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CALL METHOD cl_gui_cfw=>flush
    EXCEPTIONS
      cntl_system_error = 1
      cntl_error        = 2
      OTHERS            = 3.
  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  drive = vl_type.

  CHECK path(2) NE '\\'.
  drive_unit = path(1).

* IF is a REMOTE conection, read the windows registry to know the destination
  CHECK vl_type EQ 'REMOTE'.

  CONCATENATE 'Network\' vl_drive(1) INTO vl_key.

  drive_unit = vl_drive(1).

  CALL METHOD cl_gui_frontend_services=>registry_get_value
    EXPORTING
      root                 = cl_gui_frontend_services=>hkey_current_user
      key                  = vl_key
      value                = 'RemotePath'
    IMPORTING
      reg_value            = vl_reg_value
    EXCEPTIONS
      get_regvalue_failed  = 1
      cntl_error           = 2
      error_no_gui         = 3
      not_supported_by_gui = 4
      OTHERS               = 5.

  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  IF STRLEN( real_path ) GE 2.
    real_path = real_path+2.
  ENDIF.

  IF STRLEN( real_path ) GE 1 AND real_path(1) EQ '\'.
    real_path = real_path+1.
  ENDIF.

  CONCATENATE vl_reg_value real_path INTO real_path SEPARATED BY '\'.

ENDMETHOD.


METHOD fixedtab_to_standardtab.

  DATA: ol_t_reference TYPE REF TO data,
        ol_w_reference TYPE REF TO data.

  DATA: vl_input    TYPE string,
        vl_len      TYPE int4,
        vl_quan_len TYPE i,
        vl_sum      TYPE int4.

  FIELD-SYMBOLS: <fsl_t_output> TYPE ANY TABLE,
                 <fsl_w_output> TYPE ANY,
                 <fsl_v_field>  TYPE ANY.

***
* 1.- Create the data object like the output
***
  CREATE DATA ol_t_reference LIKE output.

  CHECK ol_t_reference IS BOUND.
  ASSIGN ol_t_reference->* TO <fsl_t_output>.
  IF sy-subrc NE 0.
    MESSAGE e011(saplwspo) WITH 'OUTPUT' ''.
  ENDIF.

  CREATE DATA ol_w_reference LIKE LINE OF <fsl_t_output>.

***
* 2.- How many splits
***
  vl_quan_len = LINES( lengths ).

***
* 3.- Read the input data
***
  LOOP AT input INTO vl_input.

***
* 3.1- Create a work area like the output table
***
    ASSIGN ol_w_reference->* TO <fsl_w_output>.

    DO vl_quan_len TIMES.

***
* 3.2- Assign the fields
***
      ASSIGN COMPONENT sy-index OF STRUCTURE <fsl_w_output> TO <fsl_v_field>.
      IF sy-subrc <> 0.
        MESSAGE e036(afwbm_main) RAISING assign_error.
*       Internal error in the tool for assigning characteristic values
      ENDIF.

      READ TABLE lengths
      INTO vl_len
      INDEX sy-index.

      IF vl_sum IS INITIAL.
        <fsl_v_field> = vl_input(vl_len).
        vl_sum = vl_len.
      ELSE.
        <fsl_v_field> = vl_input+vl_sum(vl_len).
        vl_sum = vl_sum + vl_len.
      ENDIF.

    ENDDO.

***
* 4.- Fill the output reference
***
    CHECK ol_w_reference IS BOUND.
    ASSIGN ol_w_reference->* TO <fsl_w_output>.
    IF sy-subrc <> 0.
      MESSAGE e011(saplwspo) WITH '<FSL_W_OUTPUT>' ''.
    ENDIF.

    INSERT <fsl_w_output> INTO TABLE <fsl_t_output>.

    CLEAR vl_sum.

  ENDLOOP.

***
* 5.- Fill the output table
***
  output = <fsl_t_output>.

ENDMETHOD.


METHOD fixedtab_to_standardtab_2.

  DATA: ol_t_reference TYPE REF TO data,
        ol_w_reference TYPE REF TO data.

  DATA: vl_input   TYPE string,
        vl_length  TYPE int4,
        vl_cant_long TYPE i,
        vl_aggregate TYPE int4.

  FIELD-SYMBOLS: <fsl_t_output> TYPE ANY TABLE,
                 <fsl_w_output> TYPE ANY,
                 <fsl_v_field>  TYPE ANY.

***
* 1.- Create a data object like the output table structure
***
  CREATE DATA ol_t_reference LIKE output.

  CHECK ol_t_reference IS BOUND.
  ASSIGN ol_t_reference->* TO <fsl_t_output>.
  IF sy-subrc <> 0.
    MESSAGE e011(saplwspo) WITH 'OUTPUT' ''.
  ENDIF.

  CREATE DATA ol_w_reference LIKE LINE OF <fsl_t_output>.

***
* 2.- Loop the input table
***
  LOOP AT input INTO vl_input.

***
* 2.1- Create a structure.
***
    ASSIGN ol_w_reference->* TO <fsl_w_output>.

    DO.

***
* 2.2- Asigno los componentes
***
      ASSIGN COMPONENT sy-index OF STRUCTURE <fsl_w_output> TO <fsl_v_field>.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.

***
* 2.3- Get the destination length
***
      DESCRIBE FIELD <fsl_v_field> LENGTH vl_length IN BYTE MODE.

      IF vl_aggregate IS INITIAL.
        <fsl_v_field> = vl_input(vl_length).
        vl_aggregate = vl_length.
      ELSE.

        TRY.
            <fsl_v_field> = vl_input+vl_aggregate(vl_length).
          CATCH cx_sy_range_out_of_bounds.
***
*      This exception raise when the last field length is less long
* 2.4- at the field in the destination structure.
*      With a recursive method to reduce at 1 the length by each try.
            CALL METHOD zcl_ca_file_utilities=>catch_too_long
              EXPORTING
                input     = vl_input
                aggregate = vl_aggregate
              CHANGING
                length    = vl_length
                field     = <fsl_v_field>.

        ENDTRY.

        vl_aggregate = vl_aggregate + vl_length.
      ENDIF.

    ENDDO.

***
* 3.- Move the data
***
    CHECK ol_w_reference IS BOUND.
    ASSIGN ol_w_reference->* TO <fsl_w_output>.
    IF sy-subrc <> 0.
      MESSAGE e011(saplwspo) WITH '<FSL_W_OUTPUT>' ''.
    ENDIF.

    INSERT <fsl_w_output> INTO TABLE <fsl_t_output>.

    CLEAR vl_aggregate.

  ENDLOOP.

***
* 4.- Fill the output table
***
  output = <fsl_t_output>.

ENDMETHOD.


METHOD get_file_separator.

  IF batch EQ abap_false.

    CALL METHOD cl_gui_frontend_services=>get_file_separator
      CHANGING
        file_separator       = file_separator
      EXCEPTIONS
        not_supported_by_gui = 1
        error_no_gui         = 2
        cntl_error           = 3
        OTHERS               = 4.

    CASE sy-subrc.
      WHEN 1.
        RAISE not_supported_by_gui.
      WHEN 2.
        RAISE error_no_gui.
      WHEN 3.
        RAISE cntl_error.
    ENDCASE.

  ELSE.

    CASE sy-opsys.
      WHEN 'Windows NT'.
        file_separator = '\'.
      WHEN 'Linux'.
        file_separator = '/'.
      WHEN 'HP-UX'.
        file_separator = '/'.
      WHEN 'OS400'.
        file_separator = '/'.
      WHEN OTHERS.
        file_separator = '/'.
    ENDCASE.

  ENDIF.

ENDMETHOD.


METHOD get_length.

  DATA: lo_data TYPE REF TO cl_abap_elemdescr.

  lo_data ?= cl_abap_elemdescr=>describe_by_data( input ).

  IF output_format EQ abap_true.
    length = lo_data->output_length.
    RETURN.
  ENDIF.

  length = lo_data->decimals + lo_data->length.

  CASE lo_data->type_kind.
    WHEN lo_data->typekind_packed.
      ADD 1 TO length.

    WHEN OTHERS.
  ENDCASE.

ENDMETHOD.


METHOD merge_otf_into_1_pdf.

  DATA: tl_final_otf TYPE tsfotf,
        tl_lines     TYPE STANDARD TABLE OF tline.

  DATA: wl_otf_tabs  TYPE LINE OF ty_t_otf.

  DATA: vl_tabix     TYPE sy-tabix.

  LOOP AT otf_tabs INTO wl_otf_tabs.

    IF wl_otf_tabs-copies EQ 0.
      wl_otf_tabs-copies = 1.
    ENDIF.

    DO wl_otf_tabs-copies TIMES.

      IF tl_final_otf IS INITIAL.
        tl_final_otf = wl_otf_tabs-otf.
        CONTINUE.
      ENDIF.

*     Find the end of page in the OTF
      LOOP AT tl_final_otf TRANSPORTING NO FIELDS WHERE tdprintcom = 'EP'.
      ENDLOOP.
      vl_tabix = sy-tabix + 1.

*     Remove the begin and end marks
      DELETE wl_otf_tabs-otf WHERE tdprintcom = '//'.

*     Add the partial OTF to the final
      INSERT LINES OF wl_otf_tabs-otf INTO tl_final_otf INDEX vl_tabix.

    ENDDO.

  ENDLOOP.

* Convert OTF to PDF
  CALL FUNCTION 'CONVERT_OTF'
    EXPORTING
      format                = 'PDF'
      max_linewidth         = 132
    IMPORTING
      bin_filesize          = filesize
      bin_file              = pdf
    TABLES
      otf                   = tl_final_otf
      lines                 = tl_lines
    EXCEPTIONS
      err_max_linewidth     = 1
      err_format            = 2
      err_conv_not_possible = 3
      err_bad_otf           = 4
      OTHERS                = 5.

  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDMETHOD.


METHOD read_file.

  DATA: wl_file_data TYPE solisti1,
        vl_length    TYPE i.

  CLEAR file_data.
  CLEAR length.

  OPEN DATASET file-file_name FOR INPUT IN BINARY MODE.
  IF sy-subrc EQ 0.
    DO.
      READ DATASET file-file_name INTO wl_file_data LENGTH vl_length.
      IF sy-subrc NE 0.
        IF vl_length GT 0.
          APPEND wl_file_data TO file_data.
          ADD vl_length TO length.
        ENDIF.
        EXIT.
      ELSE.
        APPEND wl_file_data TO file_data.
        ADD vl_length TO length.
      ENDIF.
    ENDDO.
  ELSE.
    MESSAGE i012(ba) WITH file-file_name.
*   Cannot open archive file &
  ENDIF.

  CLOSE DATASET file-file_name.

ENDMETHOD.


METHOD save_zip.

  DATA: vl_bin_filesize TYPE i.

* Save the ZIP
  CALL METHOD zipper->save
    RECEIVING
      zip = zip.

* Create the binary file
  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING
      buffer        = zip
    IMPORTING
      output_length = vl_bin_filesize
    TABLES
      binary_tab    = file_tab_zip.

ENDMETHOD.


METHOD standardtab_to_stringtab.

  DATA: ol_data_float   TYPE REF TO data.

  DATA: wl_line         TYPE string,
        vl_field        TYPE i VALUE 0,
        vl_type         TYPE c LENGTH 1,
        vl_charlike_aux TYPE c LENGTH 12.

  FIELD-SYMBOLS: <fsl_input>  TYPE any,
                 <fsl_field>  TYPE any,
                 <fsl_packed> TYPE any.

  CREATE DATA ol_data_float TYPE p DECIMALS decimals_float.
  ASSIGN ol_data_float->* TO <fsl_packed>.

  LOOP AT input ASSIGNING <fsl_input>.

    DO.

      vl_field = vl_field + 1.
      ASSIGN COMPONENT vl_field OF STRUCTURE <fsl_input> TO <fsl_field>.
      IF sy-subrc NE 0.
        APPEND wl_line TO output.
        EXIT.
      ENDIF.

      IF wl_line IS INITIAL.
        CONCATENATE enclosed
                    <fsl_field>
                    enclosed
        INTO wl_line.
      ELSE.

        DESCRIBE FIELD <fsl_field> TYPE vl_type.

        IF vl_type CA 'IPsb'.

          vl_charlike_aux = <fsl_field>.
          CONDENSE vl_charlike_aux.
          CONCATENATE wl_line
                      splitter
                      enclosed
                      vl_charlike_aux
                      enclosed
          INTO wl_line.

        ELSEIF vl_type EQ 'F'. " Float

          CALL FUNCTION 'MURC_ROUND_FLOAT_TO_PACKED'
            EXPORTING
              if_float  = <fsl_field>
            IMPORTING
              ef_packed = <fsl_packed>
            EXCEPTIONS
              OTHERS    = 0.

          vl_charlike_aux = <fsl_packed>.
          CONDENSE vl_charlike_aux.
          CONCATENATE wl_line
                      splitter
                      enclosed
                      vl_charlike_aux
                      enclosed
          INTO wl_line.

        ELSE.

          CONCATENATE wl_line
                      splitter
                      enclosed
                      <fsl_field>
                      enclosed
                 INTO wl_line.

        ENDIF.

      ENDIF.

    ENDDO.

    CLEAR: wl_line,
           vl_field.

  ENDLOOP.

ENDMETHOD.


METHOD stringtab_to_standardtab.

  DATA: ol_t_reference TYPE REF TO data,
        ol_w_reference TYPE REF TO data.

  DATA: tl_split       TYPE stringtab.

  DATA: vl_input       TYPE string,
        vl_split       TYPE string.

  FIELD-SYMBOLS: <fsl_t_output> TYPE ANY TABLE,
                 <fsl_w_output> TYPE ANY,
                 <fsl_v_field>  TYPE ANY.

***
* 1.- Create a data object like the output
***
  CREATE DATA ol_t_reference LIKE output.

  CHECK ol_t_reference IS BOUND.
  ASSIGN ol_t_reference->* TO <fsl_t_output>.
  IF sy-subrc <> 0.
    MESSAGE e011(saplwspo) WITH 'OUTPUT' ''.
  ENDIF.

  CREATE DATA ol_w_reference LIKE LINE OF <fsl_t_output>.

***
* 2.- Loop the input data
***
  LOOP AT input INTO vl_input.

***
* 2.1- Split the string line
***
    SPLIT vl_input AT split INTO TABLE tl_split.

***
* 2.2- Create a structure like line of output table.
***
    ASSIGN ol_w_reference->* TO <fsl_w_output>.

    LOOP AT tl_split INTO vl_split.

      ASSIGN COMPONENT sy-tabix
      OF STRUCTURE <fsl_w_output>
      TO <fsl_v_field>.

      IF <fsl_v_field> IS NOT ASSIGNED.
        MESSAGE e036(afwbm_main) RAISING assign_error.
*       Internal error in the tool for assigning characteristic values
      ENDIF.

      <fsl_v_field> = vl_split.

    ENDLOOP.

    INSERT <fsl_w_output> INTO TABLE <fsl_t_output>.

  ENDLOOP.

***
* 3.- Fill output table
***
  output = <fsl_t_output>.

ENDMETHOD.
ENDCLASS.
