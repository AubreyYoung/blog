# Partitioning Tables with User-Defined Types and LOBs (文档 ID 74181.1)

  

|

|

## Applies to:

Oracle Server - Enterprise Edition - Version 8.1.5.0 and later  
Information in this document applies to any platform.  

## Purpose

This bulletin will go through how to partition a table with a user-defined
datatype or LOB datatype and what to look out for.

## Scope

Any users requiring the above functionality.

## Details

The ability to partition a table with an object type, tables that contain
collection types, tables with REF data types, and tables with LOB  
data types is available. The steps to partition a table with user-defined
datatypes and LOB datatypes is very similar to partitioning a  
relational table. The same partitioning methods of Range, Hash, and Composite
can be applied to partitioning relational tables as  
well as object tables. This bulletin will go through how to partition a table
with a user-defined datatype or LOB datatype and what to  
look out for.

Column Objects

A column object is an object that appears only in table columns or as
attributes of other objects. In the following example, an object  
type called shipping_address is created. The object type shipping_address
consists of customer information. A table called packing_list  
is created with a column called shipping with a datatype of shipping_address.
The table is partitioned using the range partition method.  
The partition key is made up of product_id and shipping.state. Since the
column shipping is to be included in the partition key its scalar  
attribute, state, must be used. When a table column has an object datatype you
need to take the scalar attribute of that column if  
you want to use it for partitioning.  
  
For example:

CREATE TYPE shipping_address AS OBJECT  
( customer_name VARCHAR2(40),  
address VARCHAR2(20),  
city VARCHAR2(20),  
state CHAR(2),  
zip NUMBER)  
/  
  
CREATE TABLE packing_list  
( product_id NUMBER,  
product_name VARCHAR2(20),  
shipping SHIPPING_ADDRESS)  
PARTITION BY RANGE (product_id, shipping.state)  
( PARTITION partition_1 VALUES LESS THAN (100, 'CO')  
TABLESPACE ts1  
STORAGE (INITIAL 10m NEXT 15m),  
PARTITION partition_2 VALUES LESS THAN (300, 'NY'),  
PARTITION partition_3 VALUES LESS THAN (400, 'WA'))  
/

To insert into a table that contains a column with an object datatype certain
steps are required. Since the column shipping has an object  
datatype, the constructor for the object type shipping_address must be used
when inserting values into it.

INSERT INTO packing_list VALUES  
(250, 'Computer', shipping_address('Angie', '1234 Weeping Willow',  
'Rockledge', 'FL',32935))  
/

In order to view the data in the table you can just issue a select on the
table. In order to select individual attributes from the shipping  
column, PL/SQL needs to be used instead of SQL.  
  
  
Row Objects  
  
A row object is a table that is made up of an object type. A row object can
function as if it were a relational table. Since a row object is  
based off an object, the object type needs to be created first. Next, to
create the row object table, the syntax CREATE TABLE tablename  
OF objectname is used. This syntax will create a table based off an object
type. When partitioning a row object, the partition declaration  
is specified immediately after the create statement.  
  

CREATE TYPE Books AS OBJECT  
(Book_Name VARCHAR2(20),  
Author VARCHAR2(20),  
ISBN NUMBER)  
/  
  
CREATE TABLE Lib_Books OF Books  
PARTITION BY HASH(ISBN)  
(PARTITION Lib_Books_P1  
TABLESPACE ts1,  
PARTITION Lib_Books_P2  
TABLESPACE ts2)  
/

DML and DDL can be performed on a row object table in the same manner as a
relational table with a few exceptions. Adding a column  
to a row object is not possible since the table is made up of an object type.
Adding a row to a row object can be accomplished in two ways.  
A row can be added in the same manner as a relational table or by using the
object type constructor.

INSERT INTO Lib_Books VALUES('Partitions','Brian Garrett', 9834);

Or

INSERT INTO Lib_Books VALUES(Books('Adv Partition','John Smith',2349));

  
Selecting from a row object table can be accomplished as if it were a  
relational table.  
  
REF  
  
A REF encapsulates a reference to a row object of a specified object type.
When a relational table has a column with a REF datatype the  
REF will store the Object ID (OID) of a particular row from a row object
table. Since a REF references a row object, the object type must  
first be created followed by the row object table.  
  

CREATE TYPE Books AS OBJECT  
(Book_Name VARCHAR2(20),  
Author VARCHAR2(20),  
ISBN NUMBER)  
/  
  
CREATE TABLE Lib_Books OF BOOKS  
PARTITION BY HASH(ISBN)  
(PARTITION Lib_Books_P1  
TABLESPACE ts1,  
PARTITION Lib_Books_P2  
TABLESPACE ts2)  
/  
  
INSERT INTO Lib_Books VALUES('Partitions','Brian Garrett', 9834);

  
Once the row object table is created then the tables that will reference it
can be created. The table Lib_Card has a column called  
Checked_Books which has a REF datatype that references the object type Books.

CREATE TABLE Lib_Card  
(First_Name varchar2(20),  
Last_Name varchar2(20),  
Checked_Books REF Books)  
PARTITION BY RANGE(Last_Name)  
(PARTITION Lib_Card_P1 VALUES LESS THAN ('Cook'),  
PARTITION Lib_Card_P2 VALUES LESS THAN ('Miller'),  
PARTITION Lib_Card_P3 VALUES LESS THAN (MAXVALUE))  
/

When using a REF datatype in a partitioned table, the REF datatype cannot be
part of the partition key. The Checked_Books column will  
contain an Object ID, which cannot be partitioned on, to where the row exists.
To insert a value into the Lib_Card table we need to select  
a particular row from a row object, Lib_Books. This will place the Object ID
for the row in the Checked_Books column.

INSERT INTO Lib_Card  
SELECT 'Angie', 'Garrett', ref(a)  
FROM Lib_Books a  
WHERE Book_Name = 'Partitions'  
/

When you select on a column with a REF datatype you will received the Object
ID of the row and not the data. In order to view the actual  
data within a column with a REF datatype you need to use the DEREF function.
The following is an example of using the DEREF function.

SELECT First_Name, Last_Name, DEREF(Checked_Books)  
FROM Lib_Card  
/

Collections (VARRAY and Nested Tables)  
  
A collection type describes data units made up of the same datatypes.
Collections are stored in a separate table from the base table  
where the column with a collection type is declared. First, create an object
type called Books. Next, a nested table type based off the  
object type Books is created.  
  

CREATE TYPE Books AS OBJECT  
(Book_Name VARCHAR2(20),  
Author VARCHAR2(20),  
ISBN NUMBER)  
/  
  
CREATE TYPE Books_NT AS TABLE OF Books  
/

In the table Lib_Card, the column Checked_Books has a nested table datatype,
Books_NT. The physical nested table is created next as Books_NT_TAB along with
its storage parameter. When the partition declaration is specified, the column
with the nested table datatype  
cannot be a part of the partition key. The actual data for the column
Checked_Books is stored in a nested table, Books_NT_TAB, which is  
stored separately from the partitioned table and is not partitioned. The
column with the nested table datatype will point to the column in  
the nested table.

Create table Lib_Card  
(First_Name varchar2(20),  
Last_Name varchar2(20),  
Card_No number,  
Checked_Books Books_NT)  
NESTED TABLE Checked_Books STORE AS Books_NT_TAB  
STORAGE(INITIAL 10M NEXT 15M)  
PARTITION BY RANGE(Card_No)  
(PARTITION Lib_Card_P1 VALUES LESS THAN (450),  
PARTITION Lib_Card_P2 VALUES LESS THAN (625),  
PARTITION Lib_Card_P3 VALUES LESS THAN (MAXVALUE))  
/

To insert data into the Lib_Card table the nested table type, Books_NT
constructor must be used. Also within the Books_NT constructor  
the Books' object constructor must be used. More than one value can be entered
into a column with the nested table datatype.

INSERT INTO Lib_Card VALUES  
('Jim', 'Smith', 536,  
Books_NT(  
Books('Into to Oracle', 'May Bee', 23456),  
Books('Scuba Diving', 'Melvin Myers', 65432)))  
/

Selecting from the Lib_Card table can be done by simply selecting the columns
from the table. In order to select individual attributes from  
the nested table column PL/SQL is necessary.

LOB Datatypes  
  
LOB datatypes provide the ability to store large amounts of structured or non-
structured data. LOB datatypes can hold up to four gigabytes  
of data. When a table is partitioned that contains a LOB datatype, the LOB can
be stored in a separate location. The LOB will be  
equi-partitioned with the partitioned table. In the following example there is
a table called Library that contains two columns called Book_Description and
Book_Audio with CLOB and BFILE datatypes respectively.

CREATE TABLE Library  
( Card_Holder VARCHAR2(20),  
Book_Name VARCHAR2(20),  
Author VARCHAR2(20),  
Book_Number NUMBER,  
Book_Description CLOB,  
Book_Audio BFILE)  
LOB (Book_Description) STORE AS (STORAGE (INITIAL 2m NEXT 5m))  
PARTITION BY HASH(Book_Number)  
(PARTITION Library_P1  
TABLESPACE ts1  
LOB (Book_Description) STORE AS (TABLESPACE t3),  
PARTITION Library_P2  
TABLESPACE ts2  
LOB (Book_Description) STORE AS (TABLESPACE t1))  
/

The storage parameters for LOBs can be stored in either the table declaration
or the partition declaration. Since Hash partition method is  
being used no other storage parameters besides tablespace location can be
provided in the partition declaration. If any other storage  
parameters are specified, then an ORA-22877 error will be returned to the
user. The Library_P1 partition will be stored in the ts1 tablespace  
while the LOB, Book_Description, will be stored in tablespace t3. Since
Book_Audio is a BFILE datatype a "BFILE locator" is stored in the  
partitioned table which points to the physical file that is stored at the
operating system. The "BFILE locator" stores the location of the  
file along with other controlling information. To insert into a table that
contains LOB datatypes the following syntax can be used.

INSERT INTO Library VALUES  
('Erin Robinson', 'Intro to Oracle', 'John Doe', 34567,  
'An introduction to how Oracle works',  
BFILENAME('Audio_Dir', 'Int_Oracle.aud'))  
/

The BFILENAME function uses two parameters: The Directory name and the BFILE
name. Before inserting into the BFILE, the directory where  
the file resides must already exists on the system. Using the CREATE DIRECTORY
syntax, the directory where the file resides can be recorded  
in the Oracle Dictionary with the following syntax:

CREATE DIRECTORY Audio_Dir as '<directory name complete path>';

In order to view the data within a partitioned table that contains columns
with LOB datatypes, you can simply select the columns you would  
like to view in sqlplus with the exception of BFILE datatypes. The DBMS_LOB
package must be used to do any manipulation to a BFILE  
datatype.  
  
The following is an example of selecting from the Library table:  
  

SELECT Card_Holder, Book_Name, Author, Book_Number, Book_Description  
FROM Library;  
  
---  
  
  



---
### TAGS
{partition table}

---
### NOTE ATTRIBUTES
>Created Date: 2017-06-27 06:27:32  
>Last Evernote Update Date: 2018-10-01 15:59:05  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=78005519825545  
>source-url: &  
>source-url: id=74181.1  
>source-url: &  
>source-url: displayIndex=7  
>source-url: &  
>source-url: _afrWindowMode=0  
>source-url: &  
>source-url: _adf.ctrl-state=jskza6s8s_288#BODYTEXT  