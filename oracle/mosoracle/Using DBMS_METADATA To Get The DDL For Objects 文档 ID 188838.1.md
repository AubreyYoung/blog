# Using DBMS_METADATA To Get The DDL For Objects (文档 ID 188838.1)

  

|

|

## Applies to:

PL/SQL - Version 9.0.1.0 and later  
Oracle Database - Enterprise Edition - Version 9.0.1.0 to 11.1.0.7 [Release
9.0.1 to 11.1]  
Information in this document applies to any platform.  
*** Checked for relevance on 22-Mar-2016 ***

## Goal

The purpose of this document is to illustrate the usage of **dbms_metadata**
to generate the DDL for objects.

## Solution

**Oracle 9 and Oracle 9i:**  
  
The DBMS_METADATA package is a powerful tool for obtaining the complete
definition of a schema object. It enables you to obtain all of the attributes  
of an object in one pass. The object is described as DDL that can be used to
(re)create it.  
  
The GET_DDL function is used to fetch the DDL for all tables in the current
schema, filtering out nested tables and overflow segments.  
The SET_TRANSFORM_PARAM (with the handle value equal to
DBMS_METADATA.SESSION_TRANSFORM meaning "for the current session") is used to  
specify that storage clauses are not to be returned in the SQL DDL.  
  
Afterwards, the session-level transform parameters are reset to their
defaults. Once set, transform parameter values remain in effect until
specifically reset  
to their defaults.  
  
  
Note: Please note that you would be required to run catmeta.sql for the
creation of the views related to DBMS_METADATA.  
This Script is available under $ORACLE_HOME/rdbms/admin directory.  
  
  
For E.g if you have created a table :

create table idx3_tab (  
name varchar2(30),  
id number,  
addr varchar2(100),  
phone varchar2(30)) tablespace users;

  
And then wanted to generate the table creation script, run the following
query:

select dbms_metadata.get_ddl('TABLE','IDX3_TAB') from dual;

  
The output would be:  

CREATE TABLE "SCOTT"."IDX3_TAB"  
( "NAME" VARCHAR2(30),  
"ID" NUMBER,  
"ADDR" VARCHAR2(100),  
"PHONE" VARCHAR2(30)  
) PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 LOGGING  
STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645  
PCTINCREASE 0  
FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT) TABLESPACE "USERS"

  
To get the create table definition without the storage clause you could do as
follows:

EXECUTE
DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'STORAGE',false);

  
The output should be PL/SQL procedure successfully completed.  
  
And then if you run

set long 100000  
select dbms_metadata.get_ddl('TABLE','IDX3_TAB') from dual;

would return:

CREATE TABLE "SCOTT"."IDX3_TAB"  
( "NAME" VARCHAR2(30),  
"ID" NUMBER,  
"ADDR" VARCHAR2(100),  
"PHONE" VARCHAR2(30)  
) PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 LOGGING TABLESPACE "USERS"

  
Another example would be:

create type person as object (  
name varchar2(20),  
age number);  
/  
create type v0 as varray(5) of person;  
/  
create type n1 as table of v0;  
/  
create type n2 as object (n2_c1 n1);  
/  
  
create table tab11 (  
c1 n2)  
nested table c1.n2_c1 store as tab11_c1_n1 (  
varray column_value store as lob tab11_c1_v1)  
RETURN AS LOCATOR;

set long 100000  
select dbms_metadata.get_ddl('TABLE','TAB11') from dual;

would show an output like

CREATE TABLE "SCOTT"."TAB11"  
( "C1" "SCOTT"."N2"  
) PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 LOGGING TABLESPACE "USERS"  
NESTED TABLE "C1"."N2_C1" STORE AS "TAB11_C1_N1"  
(PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 LOGGING  
VARRAY "COLUMN_VALUE" STORE AS LOB "TAB11_C1_V1"  
(ENABLE STORAGE IN ROW CHUNK 4096 PCTVERSION 10  
CACHE )) RETURN AS LOCATOR

  
This tool would avoid the work of writing a select statement which would
combine data dictionary views to get the desired output.  
If we want the definition of all the objects in the database we could get the
definition from the export dump.  
  
  
 **Oracle 10.1.0.X:**  
  
The information above is essentially the same on 10g, However, in 10g the  
file to be run is catdp.sql as it is part of Data Pump.  
  
If you run catmeta in 10g, you will get errors :  
  
ERROR:  
ORA-06502: PL/SQL: numeric or value error  
ORA-31605: the following was returned from LpxXSLResetAllVars in routine  
kuxslResetParams:  
LPX-1: NULL pointer  
  
 **Oracle 10.2.0.X and in 11.1.0.X:**  
  
The information above is essentially the same on 10.2 and 11g. However, in
10.2 and 11g the file to be run is catdph.sql as it is part of Data Pump.  
  

## References

[NOTE:1016836.6](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=188838.1&id=1016836.6)
\- How to Capture Table Constraints onto a SQL Script  
  
  
---  
  
  



---
### TAGS
{DBMS_METADATA}

---
### NOTE ATTRIBUTES
>Created Date: 2017-07-04 09:34:05  
>Last Evernote Update Date: 2018-10-01 15:44:51  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=266470146052657  
>source-url: &  
>source-url: id=188838.1  
>source-url: &  
>source-url: _afrWindowMode=0  
>source-url: &  
>source-url: _adf.ctrl-state=p3nalz4px_4  