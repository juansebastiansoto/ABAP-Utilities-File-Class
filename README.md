# ABAP-Utilities-File-Class
Utilities to handle files

## How to use it:

### CALCULATE_FILE_SIZE

_Calculate File Size_

#### INPUT
* TYPE: ASC (ASCII File) or BIN (Binary File)
* DATA: File Content

#### OUTPUT
* SIZE: File size in MegaBytes

### CREATE_ZIP_FILE_APP_SVR

_Create a ZIP file in the application server_

#### INPUT
* ZIP_NAME: Name of the ZIP file to create in the Application Server
* FILES: Content of the ZIP file.

FILES:

1. FILE_NAME: File to add into the ZIP
2. FILE_NAME_IN_ZIP: Name of the file into the ZIP

### FILESOURCE_FROM_PATH

_Return the real path (UNC) and the resource type_

REQUIREMENTS:

SAPGUI to access the Windows Registry

#### INPUT 
* PATH: Logical Path (Example: Z:\test1.txt)

#### OUTPUT
* DRIVE: Drive Type (Example: REMOTE)
* DRIVE_UNIT: Letter of the drive (Example: Z)
* REAL_PATH: Real path to access in backend (Example: \\DOMAIN\SERVER\RESOURCE\test1.txt)

### FIXEDTAB_TO_STANDARDTAB

_Convert a Fixed length table to a Standard Table_

#### INPUT 
* INPUT: String tab with fixed field lengths (Example: AA BBBBCCCCC)
* LENGTHS: Table with the length list (Example: 3, 4, 5)

#### OUTPUT
* OUTPUT: A standard table with the fields splitted (Example: FIELD1: AA ; FIELD2: BBBB ; FIELD3: CCCCC)

### FIXEDTAB_TO_STANDARDTAB_2

_Convert a Fixed length table to a Standard Table without set the fields lenght_

#### INPUT
* INPUT: String tab with fixed field lengths (Example: AA BBBBCCCCC)

#### OUTPUT
* OUTPUT: A standard table with the fields splitted (Example: FIELD1: AA ; FIELD2: BBBB ; FIELD3: CCCCC)

### MERGE_OTF_INTO_1_PDF

_Merge multiple OTF into one PDF_

#### INPUT
* OTF_TABS: OTF tables with the copy quantity

#### OUTPUT
* PDF: The PDF file in binary format
* FILESIZE: The PDF file size

### STANDARDTAB_TO_STRINGTAB

_Convert a Standard Table to a String table_

#### INPUT 
* INPUT: A standard table (Example: FIELD1: AA ; FIELD2: BBBB ; FIELD3: CCCCC)
* SPLITTER: Split by... Default: Horizontal Tab
* ENCLOSED: Enclose character. (Example: '"' => "DATA1";"DATA2";"DATAN")
* DECIMALS_FLOAT: Number of decimals to convert Float data

#### OUTPUT
* OUTPUT: The string table

### STRINGTAB_TO_STANDARDTAB

_Convert a String Table to a Standard Table_

#### INPUT 
* INPUT: A string table (Example: AA ;BBBB;CCCCC)
* SPLITTER: Split by... Default: Horizontal Tab

#### OUTPUT
* OUTPUT: A standard table (Example: FIELD1: AA ; FIELD2: BBBB ; FIELD3: CCCCC)

### ARCHIVFILE_CLIENT_TO_SERVER

_Copy or Move a file from the presentation sever to the application server_

#### INPUT
* SOURCE: Source full path
* TARGET: Full path destination
* MOVE: Move the file ('X' => True; Default => ' ')

### ARCHIVFILE_SERVER_TO_SERVER

_Copy or Move a file into de application server_

#### INPUT
* SOURCE: Source full path
* TARGET: Full path destination
* MOVE: Move the file ('X' => True; Default => ' ')

### GET_FILE_SEPARATOR

_Get the OS file separator_

#### INPUT
* BATCH: Get the Application Server file separator. Default => ' '

#### OUTPUT
* FILE_SEPARATOR: OS File Separator. Example: Windows NT => \

### CONVERT_GENERIC_TO_STRING

_Convert a generic structure to a string respecting blanks_

#### INPUT
* INPUT: Any defined structure
* OUTPUT_FORMAT: Convert data to the output format. Example: VBELN 0000012345 => 12345

#### OUTPUT
* OUTPUT: String with the values concatenated
