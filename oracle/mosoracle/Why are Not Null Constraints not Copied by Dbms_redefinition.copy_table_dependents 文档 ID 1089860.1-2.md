# Why are Not Null Constraints not Copied by
Dbms_redefinition.copy_table_dependents? (文档 ID 1089860.1)

  

|

|

 **In this Document**  

| |
[Symptoms](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=341221763773881&id=1089860.1&_afrWindowMode=0&_adf.ctrl-
state=196nln8uol_190#SYMPTOM)  
---|---  
|
[Cause](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=341221763773881&id=1089860.1&_afrWindowMode=0&_adf.ctrl-
state=196nln8uol_190#CAUSE)  
---|---  
|
[Solution](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=341221763773881&id=1089860.1&_afrWindowMode=0&_adf.ctrl-
state=196nln8uol_190#FIX)  
---|---  
|
[References](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=341221763773881&id=1089860.1&_afrWindowMode=0&_adf.ctrl-
state=196nln8uol_190#REF)  
---|---  
  
* * *

_This document is being delivered to you via Oracle Support's Rapid Visibility
(RaV) process and therefore has not been subject to an independent technical
review. ___  
---  
  
## Applies to:

Oracle Database - Enterprise Edition - Version 10.2.0.1 and later  
Information in this document applies to any platform.  
  

## Symptoms

After redefining a table using DBMS_REDEFINITION it is found that a describe
of the table no longer shows the NOT NULL constraints

## Cause

The cause of this condition is two fold  
  
1) The constraint really was not copied ... due to COMPATIBLE not being 10.2
or higher  
  
2) The constraint was copied ... but appears to not have been ... (ie a
describe shows a <null> for the 'Null?' column) The cause is due to the
constraint not being enabled for VALIDATE  
  
These are discussed in the INTERNAL ONLY bug  
  
[Bug:4396234](https://support.oracle.com/epmos/faces/BugDisplay?parent=DOCUMENT&sourceId=1089860.1&id=4396234)
ET10.2OREDEF: NULLABLE COL OF *_TAB_COLUMNS TABLE NOT UPDATED AFTER ONLINE
REDEF  
  
"In order to copy Not Null constraints, COMPATIBLE must be set to 10.2 or
higher. "  
  
"Not null/Primary key constraints are copied in NOVALIDATE mode in order to
speed up the redefinition process."

## Solution

1) If COMPATIBLE < 10.2 then NOT NULL constraints must be manually copied or
the redefinition restarted with compatible set to 10.2 or higher  
  
2) If COMPATIBLE => 10.2 the constraints will be copied ... but will be in
NOVALIDATE mode  
  
The not null constraint CAN be reenabled for VALIDATE using the ALTER TABLE
... ENABLE VALIDATE CONSTRAINT ... command  
  
  
**CASE STUDY**  
  
create user test identified by test;  
grant dba to test;  
alter user test default tablespace users;  
connect test/test;  
  
SHOW PARAMETER COMPATIBLE  
  
\-- NAME TYPE VALUE  
\-- ------------------------------------ -----------
------------------------------  
\-- compatible string 11.2.0.0.0  
  
  
  
**\-- CREATE THE TABLE TO BE REDEFINED  
**  
CREATE TABLE ORIGINAL (COL1 VARCHAR2(10) NOT NULL);  
  
\-- Table created.  
  
  
**\-- CREATE THE INTERIM TABLE FOR THE REDEFINITION  
**  
CREATE TABLE INTERIM (COL1 VARCHAR2(20));  
  
\-- Table created.  
  
  
**\-- DESCRIBE THE TWO TABLES JUST CREATED  
**  
DESC ORIGINAL

\-- Name Null? Type  
\-- ---------------- -------- ----------------------------  
\-- COL1 NOT NULL VARCHAR2(10)

  
  
DESC INTERIM

\-- Name Null? Type  
\-- ---------------- -------- ----------------------------  
\-- COL1 VARCHAR2(20)

  
  
  
**\-- PROVE THAT THE REDEFINITION CAN WORK**  
  
exec dbms_redefinition.can_redef_table('TEST','ORIGINAL',
dbms_redefinition.cons_use_rowid);  
  
\-- PL/SQL procedure successfully completed.  
  
  
**\-- START THE REDEFINITION**  
  
exec dbms_redefinition.start_redef_table('TEST','ORIGINAL','INTERIM','COL1
COL1',dbms_redefinition.cons_use_rowid);  
  
\-- PL/SQL procedure successfully completed.  
  
  
**\-- COPY THE CONSTRIANTS FROM THE ORIGINAL TABLE TO THE INTERIM TABLE**  
  
SET SERVEROUTPUT ON  
  
DECLARE  
error_count pls_integer := 0;  
BEGIN  
DBMS_REDEFINITION.COPY_TABLE_DEPENDENTS('TEST',  
'ORIGINAL',  
'INTERIM',  
dbms_redefinition.cons_orig_params ,  
TRUE,  
TRUE,  
TRUE,  
FALSE,  
error_count);  
DBMS_OUTPUT.PUT_LINE('errors := ' || TO_CHAR(error_count));  
END;  
/  
  
\-- PL/SQL procedure successfully completed.  
  
  
  
**\-- FINISH THE REDEFINITION (THIS IS WHERE THE ROWS GET COPIED)**  
  
exec dbms_redefinition.finish_redef_table('TEST','ORIGINAL','INTERIM');  
  
\-- PL/SQL procedure successfully completed.  
  
  
**\--LOOK AT THE DESCRIPTION OF THE NEWLY REDFINED TABLE**  
  
DESC ORIGINAL  
  
\-- Name Null? Type  
\-- ----------------------------------------- --------
----------------------------  
\-- COL1 VARCHAR2(20)

\-- Name Null? Type  
\-- ---------------- -------- ----------------------------  
\-- COL1 VARCHAR2(20)

  
**\-- NOTICE THAT OUR 'Null?' column no longer says 'NOT NULL'  
\-- this would imply that our constraint is gone  
**  
  
  
  
**\-- PROVE THAT THE CONSTRAINT STILL EXISTS**  
  
SELECT CONSTRAINT_NAME, VALIDATED FROM USER_CONSTRAINTS WHERE TABLE_NAME =
'ORIGINAL';

\-- CONSTRAINT_NAME VALIDATED  
\-- ------------------------------ -------------  
\-- SYS_C0011548 NOT VALIDATED

  
\-- THE CONSTRAINT EXISTS BUT IS 'NOT VALIDATED'  
  
  
**\-- ALTER THE TABLE SO THAT THE NOT NULL CONSTRAINT IS NOW VALIDATED**  
  
ALTER TABLE ORIGINAL ENABLE VALIDATE CONSTRAINT SYS_C0011548;  
  
\-- Table altered.  
  
  
**\-- REEXAMINE THE TABLE**  
  
DESC ORIGINAL

\-- Name Null? Type  
\-- ---------------- -------- ----------------------------  
\-- COL1 NOT NULL VARCHAR2(20)

  
  
SELECT CONSTRAINT_NAME, VALIDATED FROM USER_CONSTRAINTS WHERE TABLE_NAME =
'ORIGINAL';  
  
\-- CONSTRAINT_NAME VALIDATED  
\-- ------------------------------ -------------  
\-- SYS_C0011548 VALIDATED

\-- CONSTRAINT_NAME VALIDATED  
\-- ------------------------------ -------------  
\-- SYS_C0011548 VALIDATED

  

## References

  
  
  
  



---
### TAGS
{DBMS_METADATA}

---
### NOTE ATTRIBUTES
>Created Date: 2017-07-05 06:28:47  
>Last Evernote Update Date: 2018-10-01 15:59:05  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=341221763773881  
>source-url: &  
>source-url: id=1089860.1  
>source-url: &  
>source-url: _afrWindowMode=0  
>source-url: &  
>source-url: _adf.ctrl-state=196nln8uol_190  