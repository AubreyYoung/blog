# Complete Checklist for Manual Upgrades to 10gR2 (文档 ID 316889.1)

  

|

|

 **In this Document**  

| |
[Purpose](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153457284099074&id=316889.1&_adf.ctrl-
state=11dph05qcs_431#PURPOSE)  
---|---  
|
[Scope](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153457284099074&id=316889.1&_adf.ctrl-
state=11dph05qcs_431#SCOPE)  
---|---  
|
[Details](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153457284099074&id=316889.1&_adf.ctrl-
state=11dph05qcs_431#BODYTEXT)  
---|---  
| [Steps for Upgrading the Database to 10g Release
2](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153457284099074&id=316889.1&_adf.ctrl-
state=11dph05qcs_431#aref_section31)  
---|---  
| [Preparing to
Upgrade](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153457284099074&id=316889.1&_adf.ctrl-
state=11dph05qcs_431#aref_section32)  
---|---  
| [Useful
Hints](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153457284099074&id=316889.1&_adf.ctrl-
state=11dph05qcs_431#aref_section33)  
---|---  
| [Appendix A: Initialization Parameters Obsolete in
10g](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153457284099074&id=316889.1&_adf.ctrl-
state=11dph05qcs_431#aref_section34)  
---|---  
| [Appendix B: Initialization Parameters Deprecated in
10g](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153457284099074&id=316889.1&_adf.ctrl-
state=11dph05qcs_431#aref_section35)  
---|---  
| [Known
issues](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153457284099074&id=316889.1&_adf.ctrl-
state=11dph05qcs_431#aref_section36)  
---|---  
| [Community
Discussions](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153457284099074&id=316889.1&_adf.ctrl-
state=11dph05qcs_431#aref_section37)  
---|---  
| [Revision
History](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153457284099074&id=316889.1&_adf.ctrl-
state=11dph05qcs_431#aref_section38)  
---|---  
|
[References](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153457284099074&id=316889.1&_adf.ctrl-
state=11dph05qcs_431#REF)  
---|---  
  
* * *

## Applies to:

Oracle Database - Enterprise Edition - Version 8.1.7.4 to 10.2.0.5 [Release
8.1.7 to 10.2]  
Oracle Database - Standard Edition - Version 8.1.7.4 to 10.2.0.5 [Release
8.1.7 to 10.2]  
Information in this document applies to any platform.  

## Purpose

This document is created for use as a guideline and checklist when manually
upgrading Oracle 8i, Oracle 9i or Oracle 10gR1 to Oracle 10gR2 on a single
server.

If the database instance is being moved from one server to another as part of
the upgrade process, additional steps for that move may need to be performed
which are not included in this checklist.  
  
This document is divided into three major sections.  
\-- Preparing to Upgrade  
\-- Upgrading to the New Oracle Database 10g Release 2  
\-- After Upgrading a Database

Please read the whole article before starting to perform an upgrade.

Additional Note:

These instructions are incomplete for taking an 8i OPS cluster into a 10gR2
RAC cluster due to the differences in OPS vs RAC.

## Scope

Database administrators

## Details

**Prerequisites and recommendations**

  * Install Oracle 10g Release 2 in a new Oracle Home
  * Install JAccelerator (NCOMP) into the home from the Companion media, to avoid the issue in

>
[Note:293658.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=293658.1)
"10.1 or 10.2 Patchset Install Getting ORA-29558 JAccelerator (NCOMP) And
ORA-06512"

  * Download and install the latest available 10.2.0.x patchset. Review the following note for a list of available patchsets and details of any well known issues:

>
[Note:316900.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=316900.1)
"ALERT: Oracle 10g Release 2 (10.2) Support Status and Alerts"

  * Install the latest available Critical Patch Update:

> [Note
290738.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=290738.1)
"Oracle Critical Patch Update Program General FAQ"

  * If you are upgrading to 10.2.0.3, review the following alerts before performing the upgrade and apply any required patches:

> [Note
406472.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=406472.1)
"Mandatory Patch 5752399 for 10.2.0.3 on Solaris 64-bit and Filesystems
Managed By Veritas or Solstice Disk Suite software"

>

> [Note
412271.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=412271.1)
"ORA-600 [22635] and ORA-600 [KOKEIIX1] Reported While Upgrading or Patching
Databases to 10.2.0.3"

>

> **NOTE** : If your database was originally created as 32-bit, even if it is
64-bit now, apply the patches recommended in [Note
412271.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=412271.1)

  * If you are upgrading to 10.2.0.4, review the following notes and alerts before performing the upgrade and apply any required patches:

> [Note
565600.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=565600.1)
ERROR IN CATUPGRD: ORA-00904 IN DBMS_SQLPA  
>

  * If you are upgrading to **any** 10.2.0.x version, review the following alert before performing the upgrade and apply any required patch:

>
[Note:471479.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=471479.1)
"IOT Corruptions After Upgrade from COMPATIBLE <= 9.2 to COMPATIBLE >= 10.1"

  * If you are upgrading to **any** 10.2.0.x version on AIX5L, review the following note before upgrading:

>
[Note:557242.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=557242.1)
"Upgrade Gives Ora-29558 Error Despite of JAccelerator Has Been Installed"

  * If you are upgrading to 10.2.0.4, review the following notes before upgrading:  
  
[Note:565600.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=565600.1)
"Error in Catupgrd: ORA-00904 In DBMS_SQLPA"  
[Note:603714.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=603714.1)
"10.2.0.4 Catupgrd.sql Fails With ORA-03113 Creating SYS.KU$_XMLSCHEMA_VIEW"  
  

  * If you are upgrading a 32-bit database to 10.2.0.x 64-bit, review the following note and remove the "use_indirect_data_buffers=TRUE" parameter setting before performing the upgrade:

>
[Note:465951.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=465951.1)
"ORA-600 [kcbvmap_1] or Ora-600 [Kcliarq_2] On Startup Upgrade Moving From a
32-Bit To 64-Bit Release"

  * Either take a cold or hot backup for your database.
  * Make sure to take a backup of Oracle Home and Central Inventory. Central inventory can be located by the contents of oraInst.loc files. "oraInst.loc" is available in the following locations on various platforms:  
  
/var/opt/oracle/oraInst.loc -- Solaris  
/etc/oraInst.loc -- other operating systems  
HKEY_LOCAL_MACHINE\SOFTWARE\ORACLE\inst_loc -- On windows Platform.

  * Verify kernel parameters are set according to the 10gR2 Installation Guide.
  * Verify that all O/S packages and patches are installed as per the Installation Guide.

Please also note that Oracle have made an "Oracle10g Upgrade Companion"
available. For further information, please review:

>
[Note:466181.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=466181.1)
"10g Upgrade Companion"

The above document is continually updated as new information becomes
available.

**Compatibility Matrix**

Minimum Version of the database that can be directly upgraded to Oracle 10g
Release 2

> 8.1.7.4 -> 10.2.X.X.X  
> 9.0.1.4 or 9.0.1.5 -> 10.2.X.X.X  
> 9.2.0.4 or higher -> 10.2.X.X.X  
> 10.1.0.2 or higher -> 10.2.X.X.X

The following database version will require an indirect upgrade path.

> 7.3.3 (or lower) -> 7.3.4 -> 8.1.7 -> 8.1.7.4 -> 10.2.X.X.X  
> 7.3.4 -> 8.1.7 -> 8.1.7.4 -> 10.2.X.X.X  
> 8.0.n -> 8.1.7 -> 8.1.7.4 -> 10.2.X.X.X  
> 8.1.n -> 8.1.7 -> 8.1.7.4 -> 10.2.X.X.X

### Steps for Upgrading the Database to 10g Release 2

### Preparing to Upgrade

In this section all the steps need to be performed to the previous version of
Oracle. Please note that the database must be running in normal mode in the
old release.  
  
 **Step 1:**  
  
Log in to the system as the owner of the new 10gR2 ORACLE_HOME and copy the
following files from the 10gR2 ORACLE_HOME/rdbms/admin directory to a
directory outside of the Oracle home, such as the /tmp directory on your
system:  
  
ORACLE_HOME/rdbms/admin/utlu102i.sql  
  
Make a note of the new location of these files.  
 **  
Step 2:**  
  
Change to the temporary directory that you copied files to in Step 1.  
  
Start SQL*Plus and connect to the database instance you are intending to
upgrade (running from the original ORACLE_HOME) as a user with SYSDBA
privileges. Then run and spool the utlu102i.sql file.

$ sqlplus '/as sysdba'  
  
SQL> spool Database_Info.log  
SQL> @utlu102i.sql  
SQL> spool off

_Please note:_ _The instance can be running in normal mode and does not need
to be running in a restricted (migrate / upgrade) mode to run the script._
_Also, the instance must not be running in read-only mode. A few registry$
tables may be created, if they do not already exist, and some rows may be
inserted into existing Upgrade tables._

Then, check the spool file and examine the output of the upgrade information
tool. The sections which follow, describe the output of the Upgrade
Information Tool (utlu102i.sql).

NOTE: If you are upgrading from 8.1.7.4, the utlu102i.sql script will fail
with an ORA-1403 error. Please follow the workaround in
[Note:5640527.8](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=5640527.8)
(or
[Note:407031.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=407031.1))
to enable utlu102i.sql to run.

**Database:**  
  
This section displays global database information about the current database
such as the database name, release number, and compatibility level. A warning
is displayed if the COMPATIBLE initialization parameter needs to be adjusted
before the database is upgraded.  
  
**Logfiles:**  
  
This section displays a list of redo log files in the current database whose
size is less than 4 MB. For each log file, the file name, group number, and
recommended size is displayed. New files of at least 4 MB (preferably 10 MB)
need to be created in the current database. Any redo log files less than 4 MB
must be dropped before the database is upgraded.  
  
 **Tablespaces:**  
  
This section displays a list of tablespaces in the current database. For each
tablespace, the tablespace name and minimum required size is displayed. In
addition, a message is displayed if the tablespace is adequate for the
upgrade. If the tablespace does not have enough free space, then space must be
added to the tablespace in the current database. Tablespace adjustments need
to be made before the database is upgraded.  
  
 **Update Parameters:**  
  
This section displays a list of initialization parameters in the parameter
file of the current database that must be adjusted before the database is
upgraded. The adjustments need to be made to the parameter file after it is
copied to the new Oracle Database 10g release.  
  
 **Deprecated Parameters:**  
  
This section displays a list of initialization parameters in the parameter
file of the current database that are deprecated in the new Oracle Database
10g release.  
  
**Obsolete Parameters:**  
  
This section displays a list of initialization parameters in the parameter
file of the current database that are obsolete in the new Oracle Database 10g
release. Obsolete initialization parameters need to be removed from the
parameter file before the database is upgraded.  
  
 **Components:**  
  
This section displays a list of database components in the new Oracle Database
10g release that will be upgraded or installed when the current database is
upgraded.  
  
 **Miscellaneous Warnings:**  
  
This section provides warnings about specific situations that may require
attention before and/or after the upgrade.  
  
 **SYSAUX Tablespace:**  
  
This section displays the minimum required size for the SYSAUX tablespace,
which is required in Oracle Database 10g. The SYSAUX tablespace must be
created after the new Oracle Database 10g release is started and BEFORE the
upgrade scripts are invoked.  
  
**Step 3:**  
  
Check for the deprecated CONNECT Role  
  
After upgrading to 10gR2, the CONNECT role will only have the CREATE SESSION
privilege; the other privileges granted to the CONNECT role in earlier
releases will be revoked during the upgrade. To identify which users and roles
in your database are granted the CONNECT role, use the following query:  
  

SELECT grantee FROM dba_role_privs  
WHERE granted_role = 'CONNECT' and  
grantee NOT IN (  
'SYS', 'OUTLN', 'SYSTEM', 'CTXSYS', 'DBSNMP',  
'LOGSTDBY_ADMINISTRATOR', 'ORDSYS',  
'ORDPLUGINS', 'OEM_MONITOR', 'WKSYS', 'WKPROXY',  
'WK_TEST', 'WKUSER', 'MDSYS', 'LBACSYS', 'DMSYS',  
'WMSYS', 'OLAPDBA', 'OLAPSVR', 'OLAP_USER',  
'OLAPSYS', 'EXFSYS', 'SYSMAN', 'MDDATA',  
'SI_INFORMTN_SCHEMA', 'XDB', 'ODM');

  
If users or roles require privileges other than CREATE SESSION, then grant the
specific required privileges prior to upgrading. The upgrade scripts adjust
the privileges for the Oracle-supplied users.  
  
In Oracle 9.2.x and 10.1.x CONNECT role includes the following privileges:  
  
  

SELECT GRANTEE, PRIVILEGE FROM DBA_SYS_PRIVS  
WHERE GRANTEE='CONNECT'  
  
GRANTEE PRIVILEGE  
\------------------------------ ---------------------------  
CONNECT CREATE VIEW  
CONNECT CREATE TABLE  
CONNECT ALTER SESSION  
CONNECT CREATE CLUSTER  
CONNECT CREATE SESSION  
CONNECT CREATE SYNONYM  
CONNECT CREATE SEQUENCE  
CONNECT CREATE DATABASE LINK

  
  
In Oracle 10.2 the CONNECT role only includes CREATE SESSION privilege.  
  
If needed by some applications the previous privileges can be restored.  
Predefined Roles Evolution From 8i to 10gR2: CONNECT Role Change in 10gR2 (Doc
ID 317258.1)  
 **  
Step 4:**  
  
Create the script for dblink in case of downgrade of the database.  
  
During the upgrade to 10gR2, any passwords in database links will be
encrypted. To downgrade back to the original release, all of the database
links with encrypted passwords must be dropped prior to the downgrade.
Consequently, the database links will not exist in the downgraded database. If
you anticipate a requirement to be able to downgrade back to your original
release, then save the information about affected database links from the
SYS.LINK$ table, so that you can recreate the database links after the
downgrade.  
  
Following script can be used to construct the dblink.  
  

SELECT  
'create '||DECODE(U.NAME,'PUBLIC','public ')||'database link '||CHR(10)  
||DECODE(U.NAME,'PUBLIC',Null, U.NAME||'.')|| L.NAME||chr(10)  
||'connect to ' || L.USERID || ' identified by '''  
||L.PASSWORD||''' using ''' || L.host || ''''  
||chr(10)||';' TEXT  
FROM sys.link$ L,  
sys.user$ U  
WHERE L.OWNER# = U.USER# ;

**  
Step 5:**  
  
if you are upgrading from 8.1.7.4 skip to Step 6  
  
if you are upgrading from 9i or 10.1 to 10.2.0.4 or 10.2.0.5 then follow first
:  
  
[Note
553812.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=553812.1)
: Actions for the DSTv4 update in the 10.2.0.4 patchset  
[Note
1086400.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=1086400.1)
: Actions for the DSTv4 update in the 10.2.0.5 patchset  
  
and take note of needed actions listed in those notes.  
  
if you are upgrading from 9i or 10.1 to 10.2.0.1, 10.2.0.2 or 10.2.0.3 we
suggest strongly to consider to update to 10.2.0.4 or 10.2.0.5  
  
if you really want to upgrade 9i or 10.1 to 10.2.0.1, 10.2.0.2 or 10.2.0.3
then check the 9i or 10.1 DSt version ( Note 412160.1 Updated Time Zones in
Oracle Time Zone File patches )  
if this is 2 and you upgrade to 10.2.0.1 or 10.2.0.2 you can skip to Step 6  
if this is 3 and you upgrade to 10.2.0.3 you can skip to Step 6  
  
Other wise log an Sr  
  
**Step 6:**  
  
Starting in Oracle 9i the National Characterset (NLS_NCHAR_CHARACTERSET) will
be limited to UTF8 and AL16UTF16.  
Any other NLS_NCHAR_CHARACTERSET will no longer be supported.  
  
Check the current NLS_NCHAR_CHARACTERSET  
  
SQL> select * from nls_database_parameters where parameter
='NLS_NCHAR_CHARACTERSET';  
  
If you are upgrading from Oracle 9i or 10.1 and the value is UTF8 or AL16UTF16
, skip to step 7.  
If you are upgrading from Oracle 9i or 10.1 and the value is NOT UTF8 or
AL16UTF16 log an SR to get help and correct the NLS_NCHAR_CHARACTERSET  
If you are upgrading from Oracle 8.1.7 complete the following steps  
  
When upgrading from Oracle8i to 10g the value of NLS_NCHAR_CHARACTERSET is
based on value currently used in the Oracle8i version.  
  
If the NLS_NCHAR_CHARACTERSET is UTF8 then new it will stay UTF8. In all other
cases the NLS_NCHAR_CHARACTERSET is changed to AL16UTF16 and -if used- N-type
data (= data in columns using NCHAR, NVARCHAR2 or NCLOB ) may need to be
converted.  
  
The change itself is done in step 38 by running the upgrade script.  
  
To check whether there are any N-type objects in a database, run the following
query:  
select distinct OWNER, TABLE_NAME  
from DBA_TAB_COLUMNS  
where DATA_TYPE in ('NCHAR','NVARCHAR2', 'NCLOB')  
and OWNER not in ('SYS','SYSTEM','XDB');  
  
If no rows are returned it should mean that the database is not using N-type
columns for user data, so simply go to the next step.  
  
  
If you are using N-type columns AND your National Characterset is UTF8 OR is
in the following list:  
  
JA16SJISFIXED , JA16EUCFIXED , JA16DBCSFIXED , ZHT32TRISFIXED  
KO16KSC5601FIXED , KO16DBCSFIXED , US16TSTFIXED , ZHS16CGB231280FIXED  
ZHS16GBKFIXED , ZHS16DBCSFIXED , ZHT16DBCSFIXED , ZHT16BIG5FIXED  
ZHT32EUCFIXED  
  
then also simply go to the next step. The conversion of the user data itself
will then be done in step 38.  
  
If you are using N-type columns AND your National Characterset is NOT UTF8 or
NOT in the following list:  
  
JA16SJISFIXED , JA16EUCFIXED , JA16DBCSFIXED , ZHT32TRISFIXED  
KO16KSC5601FIXED , KO16DBCSFIXED , US16TSTFIXED , ZHS16CGB231280FIXED  
ZHS16GBKFIXED , ZHS16DBCSFIXED , ZHT16DBCSFIXED , ZHT16BIG5FIXED  
ZHT32EUCFIXED  
  
(your current NLS_NCHAR_CHARACTERSET is for example US7ASCII, WE8ISO8859P1,
CL8MSWIN1251 ...)  
  
then you have to:  
  
change the tables to use CHAR, VARCHAR2 or CLOB instead the N-type  
or  
export/import the table(s) containing N-type column and truncate those tables
before migrating to 10g  
  
The recommended NLS_LANG during export is simply the NLS_CHARACTERSET, not the
NLS_NCHAR_CHARACTERSET  
  
 **Step 7:**  
  
When upgrading to Oracle Database 10gR2, optimizer statistics are collected
for dictionary tables that lack statistics. This statistics collection can be
time consuming for databases with a large number of dictionary tables, but
statistics gathering only occurs for those tables that lack statistics or are
significantly changed during the upgrade.  
  
To decrease the amount of downtime incurred when collecting statistics, you
can collect statistics prior to performing the actual database upgrade.  
  
As of Oracle Database 10g Release 10.1, Oracle recommends that you use the
DBMS_STATS.GATHER_DICTIONARY_STATS procedure to gather these statistics. You
can enter the following:  
  

$ sqlplus '/as sysdba'  
  
SQL> EXEC DBMS_STATS.GATHER_DICTIONARY_STATS;

  
For Oracle8i and Oracle9i, use the DBMS_STATS.GATHER_SCHEMA_STATS procedure to
gather statistics.  
  
Current Statistics, if desired, can be backed up prior to gathering current
statistics and is useful if you want to revert back the statistics post
upgrade.  
Process to backup the existing statistics as follows:  
  

$ sqlplus '/as sysdba'  
SQL>spool sdict  
  
SQL>grant analyze any to sys;  
  
SQL>exec dbms_stats.create_stat_table('SYS','dictstattab');  
  
SQL>exec dbms_stats.export_schema_stats('WMSYS','dictstattab',statown =>
'SYS');  
SQL>exec dbms_stats.export_schema_stats('MDSYS','dictstattab',statown =>
'SYS');  
SQL>exec dbms_stats.export_schema_stats('CTXSYS','dictstattab',statown =>
'SYS');  
SQL>exec dbms_stats.export_schema_stats('XDB','dictstattab',statown => 'SYS');  
SQL>exec dbms_stats.export_schema_stats('WKSYS','dictstattab',statown =>
'SYS');  
SQL>exec dbms_stats.export_schema_stats('LBACSYS','dictstattab',statown =>
'SYS');  
SQL>exec dbms_stats.export_schema_stats('OLAPSYS','dictstattab',statown =>
'SYS');  
SQL>exec dbms_stats.export_schema_stats('DMSYS','dictstattab',statown =>
'SYS');  
SQL>exec dbms_stats.export_schema_stats('ODM','dictstattab',statown => 'SYS');  
SQL>exec dbms_stats.export_schema_stats('ORDSYS','dictstattab',statown =>
'SYS');  
SQL>exec dbms_stats.export_schema_stats('ORDPLUGINS','dictstattab',statown =>
'SYS');  
SQL>exec
dbms_stats.export_schema_stats('SI_INFORMTN_SCHEMA','dictstattab',statown =>
'SYS');  
SQL>exec dbms_stats.export_schema_stats('OUTLN','dictstattab',statown =>
'SYS');  
SQL>exec dbms_stats.export_schema_stats('DBSNMP','dictstattab',statown =>
'SYS');  
SQL>exec dbms_stats.export_schema_stats('SYSTEM','dictstattab',statown =>
'SYS');  
SQL>exec dbms_stats.export_schema_stats('SYS','dictstattab',statown => 'SYS');  
  
SQL>spool off

  
This data is useful if you want to revert back the statistics.  
For example, the following PL/SQL subprograms import the statistics for the
SYS schema after deleting the existing statistics:  
  

exec dbms_stats.delete_schema_stats('SYS');  
exec dbms_stats.import_schema_stats('SYS','dictstattab');

  
To gather statistics run this script, connect to the database AS SYSDBA using
SQL*Plus.  
  

$ sqlplus '/as sysdba'  
  
SQL>spool gdict  
  
SQL>grant analyze any to sys;  
  
SQL>exec dbms_stats.gather_schema_stats('WMSYS',options=>'GATHER',  
estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE,  
method_opt => 'FOR ALL COLUMNS SIZE AUTO', cascade => TRUE);  
SQL>exec dbms_stats.gather_schema_stats('MDSYS',options=>'GATHER',  
estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE,  
method_opt => 'FOR ALL COLUMNS SIZE AUTO', cascade => TRUE);  
SQL>exec dbms_stats.gather_schema_stats('CTXSYS',options=>'GATHER',  
estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE,  
method_opt => 'FOR ALL COLUMNS SIZE AUTO', cascade => TRUE);  
SQL>exec dbms_stats.gather_schema_stats('XDB',options=>'GATHER',  
estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE,  
method_opt => 'FOR ALL COLUMNS SIZE AUTO', cascade => TRUE);  
SQL>exec dbms_stats.gather_schema_stats('WKSYS',options=>'GATHER',  
estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE,  
method_opt => 'FOR ALL COLUMNS SIZE AUTO', cascade => TRUE);  
SQL>exec dbms_stats.gather_schema_stats('LBACSYS',options=>'GATHER',  
estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE,  
method_opt => 'FOR ALL COLUMNS SIZE AUTO', cascade => TRUE);  
SQL>exec dbms_stats.gather_schema_stats('OLAPSYS',options=>'GATHER',  
estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE,  
method_opt => 'FOR ALL COLUMNS SIZE AUTO', cascade => TRUE);  
SQL>exec dbms_stats.gather_schema_stats('DMSYS',options=>'GATHER',  
estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE,  
method_opt => 'FOR ALL COLUMNS SIZE AUTO', cascade => TRUE);  
SQL>exec dbms_stats.gather_schema_stats('ODM',options=>'GATHER',  
estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE,  
method_opt => 'FOR ALL COLUMNS SIZE AUTO', cascade => TRUE);  
SQL>exec dbms_stats.gather_schema_stats('ORDSYS',options=>'GATHER',  
estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE,  
method_opt => 'FOR ALL COLUMNS SIZE AUTO', cascade => TRUE);  
SQL>exec dbms_stats.gather_schema_stats('ORDPLUGINS',options=>'GATHER',  
estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE,  
method_opt => 'FOR ALL COLUMNS SIZE AUTO', cascade => TRUE);  
SQL>exec
dbms_stats.gather_schema_stats('SI_INFORMTN_SCHEMA',options=>'GATHER',  
estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE,  
method_opt => 'FOR ALL COLUMNS SIZE AUTO', cascade => TRUE);  
SQL>exec dbms_stats.gather_schema_stats('OUTLN',options=>'GATHER',  
estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE,  
method_opt => 'FOR ALL COLUMNS SIZE AUTO', cascade => TRUE);  
SQL>exec dbms_stats.gather_schema_stats('DBSNMP',options=>'GATHER',  
estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE,  
method_opt => 'FOR ALL COLUMNS SIZE AUTO', cascade => TRUE);  
SQL>exec dbms_stats.gather_schema_stats('SYSTEM',options=>'GATHER',  
estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE,  
method_opt => 'FOR ALL COLUMNS SIZE AUTO', cascade => TRUE);  
SQL>exec dbms_stats.gather_schema_stats('SYS',options=>'GATHER',  
estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE,  
method_opt => 'FOR ALL COLUMNS SIZE AUTO', cascade => TRUE);  
  
SQL>spool off

  
**  
Step 8:**  
  
Check for invalid objects in the database:  
  

spool invalid_pre.lst  
select substr(owner,1,12) owner,  
substr(object_name,1,30) object,  
substr(object_type,1,30) type, status from  
dba_objects where status <> 'VALID';  
spool off

Run the following script as a user with SYSDBA privs using SQL*Plus and then
requery invalid objects:

$ sqlplus '/as sysdba'  
SQL> @?/rdbms/admin/utlrp.sql

  
This last query will return a list of all objects that cannot be recompiled
before the upgrade in the file 'invalid_pre.lst'

If you are upgrading from Oracle9iR2 (9.2), verify that the view dba_registry
contains data. If the view is empty, run the following scripts from the 9.2
home:

$ sqlplus '/as sysdba'  
SQL> @?/rdbms/admin/catalog.sql  
SQL> @?/rdbms/admin/catproc.sql  
SQL> @?/rdbms/admin/utlrp.sql

and verify that the dba_registry view now contains data.

**Step 9:**  
  
Check for corruption in the dictionary useing the following commands in
SQL*Plus connected as sys:  
  

Set verify off  
Set space 0  
Set line 120  
Set heading off  
Set feedback off  
Set pages 1000  
Spool analyze.sql  
  
Select 'Analyze cluster "'||cluster_name||'" validate structure cascade;'  
from dba_clusters  
where owner='SYS'  
union  
Select 'Analyze table "'||table_name||'" validate structure cascade;'  
from dba_tables  
where owner='SYS' and partitioned='NO' and (iot_type='IOT' or iot_type is
NULL)  
union  
Select 'Analyze table "'||table_name||'" validate structure cascade into
invalid_rows;'  
from dba_tables  
where owner='SYS' and partitioned='YES';  
  
spool off

  
This creates a script called analyze.sql.  
Now execute the following steps.

$ sqlplus '/as sysdba'  
SQL> @$ORACLE_HOME/rdbms/admin/utlvalid.sql  
SQL> @analyze.sql

  
This script (analyze.sql) should not return any errors.

**Step 10:**  
  
Ensure that all Materialized views/Snapshot refreshes are successfully
completed, and that replication must be stopped (ie: quiesced).

$ sqlplus '/ as sysdba'  
SQL> select distinct(trunc(last_refresh)) from dba_snapshot_refresh_times;

You can also use:

SQL> select distinct owner, name mview, master_owner master_owner,
last_refresh from dba_mview_refresh_times;

  
**Step 11:**  
  
Stop the listener for the database:  
  

$ lsnrctl  
LSNRCTL> stop

  
Ensure no files need media recovery:  
  

$ sqlplus '/ as sysdba'  
SQL> select * from v$recover_file;

  
This should return no rows.  
**  
Step 12:**  
  
Ensure no files are in backup mode:  
  

SQL> select * from v$backup where status!='NOT ACTIVE';

  
This should return no rows.

**Step 13:**  
  
Resolve any outstanding unresolved distributed transactions:

SQL> select * from dba_2pc_pending;

  
If this returns rows you should do the following:  
  

SQL> select local_tran_id from dba_2pc_pending;  
SQL> execute dbms_transaction.purge_lost_db_entry('');  
SQL> commit;

  
**Step 14:**  
  
Disable all batch and cron jobs.  
  
**Step 15:**  
  
Ensure the users SYS and SYSTEM have 'SYSTEM' as their default tablespace.  
  

SQL> select username, default_tablespace from dba_users  
where username in ('SYS','SYSTEM');

  
To modify use:  
  

SQL> alter user sys default tablespace SYSTEM;  
SQL> alter user system default tablespace SYSTEM;

  
**Step 16:**  
  
Ensure that the aud$ is in the system tablespace when auditing is enabled.  
  

SQL> select tablespace_name from dba_tables where table_name='AUD$';

If the AUD$ table exists, and is in use, upgrade performance can be effected
depending on the number of records in the table.

Please refer to the following note for information on exporting and truncating
the AUD$ table:

[Note.979942.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=979942.1)
Ext/Pub Database upgrade appears to have halted at SYS.AUD$ Table

**Step 17:**  
  
Note down where all control files are located.

SQL> select * from v$controlfile;

  
**Step 18:**

XDB Verification Checks  
1: If table XDB.MIGR9202STATUS exists in the database, drop it before
upgrading the database (to avoid the issue described in
[Note:356082.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=356082.1))

2: Validate if XDB Install Triggers exists:

See Upgrading or Installing XDB could result in data loss if
XDB_INSTALLATION_TRIGGER exists (Doc ID 1573175.1)

**Step 19:**  
  
Shutdown the database.

$ sqlplus '/as sysdba'  
SQL> shutdown immediate;

  
**Step 20:** **  
**

Perform a full cold backup (or an online backup using RMAN).

You can either do this by manually copying the files or sign on to RMAN:  
  

$ rman "target / nocatalog"

  
And issue the following RMAN commands:  
  

RUN  
{  
ALLOCATE CHANNEL chan_name TYPE DISK;  
BACKUP DATABASE FORMAT 'some_backup_directory%U' TAG before_upgrade;  
BACKUP CURRENT CONTROLFILE TO 'save_controlfile_location';  
}

  
**Upgrading to the New Oracle Database 10g Release 2**

**Step 21:**  
  
Update the init.ora file:  
  
\- Make a backup of the old init.ora file

\- Copy it from the old (pre-10.2) ORACLE_HOME to the new (10.2) ORACLE_HOME  
  
On Unix/Linux, the default location of the file is the $ORACLE_HOME/dbs
directory  
  
\- Comment out any obsoleted parameters (listed in appendix A).  
  
\- Change all deprecated parameters (listed in appendix B).  
  
\- Set the COMPATIBLE initialization parameter to an appropriate value. If you
are  
upgrading from 8.1.7.4 then set the COMPATIBLE parameter to 9.2.0 until after
the  
upgrade has been completed successfully. If you are upgrading from 9.2.0 or
10.1.0  
then leave the COMPATIBLE parameter set to it's current value until the
upgrade  
has been completed successfully. This will avoid any unnecessary ORA-942
errors  
from being reported in SMON trace files during the upgrade (because the
upgrade  
is looking for 10.2 objects that have not yet been created)  
  
\- If you have the parameter NLS_LENGTH_SEMANTICS currently set to CHAR,
change the value  
to BYTE during the upgrade (to avoid the issue described in
[Note:4638550.8](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=4638550.8))  
  
\- Verify that the parameter DB_DOMAIN is set properly.  
  
\- Make sure the PGA_AGGREGATE_TARGET initialization parameter is set to  
at least 24 MB.  
  
\- Ensure that the SHARED_POOL_SIZE and the LARGE_POOL_SIZE are at least
150Mb.  
Please also the check the "KNOWN ISSUES" section  
  
\- Make sure the JAVA_POOL_SIZE initialization parameter is set to at least
150 MB.

\- Make sure the STREAMS_POOL_SIZE is set to at least 50 MB (200 MB is ideal)  
  
\- Ensure there is a value for DB_BLOCK_SIZE  
  
\- On Windows operating systems, change the BACKGROUND_DUMP_DEST and
USER_DUMP_DEST initialization parameters that point to RDBMS80 or any other
environment variable  
to point to the following directories instead:  
  
BACKGROUND_DUMP_DEST to ORACLE_BASE\oradata\DB_NAME  
and  
USER_DUMP_DEST to ORACLE_BASE\oradata\DB_NAME\archive  
  
\- Comment out any existing AQ_TM_PROCESSES and JOB_QUEUE_PROCESSES parameter
settings, and add new lines in the init.ora/spfile.ora that explicitly set
AQ_TM_PROCESSES=0 and JOB_QUEUE_PROCESSES=0 for the duration of the upgrade.
The "startup upgrade" command (see step 30) should ensure that these settings
are used, but it's worth making sure.

\- Disable the dbms_scheduler during the upgrade by:

SQL > Exec
dbms_scheduler.set_scheduler_attribute('SCHEDULER_DISABLED','TRUE');
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< To Disable  
Wait till the coordinator and slaves have exited.  
  

  
\- To re-enable the dbms_scheduler post upgrade use following command :

SQL > Exec
dbms_scheduler.set_scheduler_attribute('SCHEDULER_DISABLED','FALSE');
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< To Enable  
After this make sure that the jobs are enabled and set up to run as normal.

  
  
\- If you have defined an UNDO tablespace, set the parameter
UNDO_MANAGEMENT=AUTO (otherwise, either unset the parameter or explicitly set
it to MANUAL). See
[Note:135090.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=135090.1)
for further information about the Automatic Undo Management feature.  
  
\- Make sure all path names in the parameter file are fully specified. You
should not have relative path names in the parameter file.  
  
\- If you are using a cluster database, set the parameter
CLUSTER_DATABASE=FALSE during the upgrade.  
  
\- If you are upgrading a cluster database, then modify the initdb_name.ora
file in the same way that you modified the parameter file.

\- Verify the parameter FIXED_DATE is not set. If it set during the upgrade
catalog and catproc will report as invalid even if there are no invalid sys or
system objects. See [Note:
745183.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=745183.1)
for further information.  
  
 **Step 22 :**  
  
Check for adequate freespace on archive log destination file systems.  
  
 **Step 23 :**  
  
If needed in your environment, ensure the environment variable NLS_LANG
variable is set correctly:  
To verify the current setting:

$ env | grep $NLS_LANG

For additional information on NLS_LANG settings, please refer to the following
notes:

[Note
158577.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=158577.1)
NLS_LANG Explained (How does Client-Server Character Conversion Work?)  
[Note
179133.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=179133.1)
The correct NLS_LANG in a Windows Environment  
[Note
264157.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=264157.1)
The correct NLS_LANG setting in Unix Environments

  
  
**Step 24:**  
  
If needed copy the SQL*Net files like (listener.ora,tnsnames.ora etc) to the
new location (when no TNS_ADMIN env. Parameter is used).  
  

$ cp $OLD_ORACLE_HOME/network/admin/*.ora /network/admin

  
**Step 25:**  
  
If your Operating system is Windows (NT, 2000, XP or 2003) delete your
services with the ORADIM of your old oracle version.  
  
Stop the OracleServiceSID Oracle service of the database you are upgrading,
where SID is the instance name. For example, if your SID is ORCL, then enter
the following at a command prompt:  
  

C:\> NET STOP OracleServiceORCL

  
For Oracle 8.0 this is:

C:\ORADIM80 -DELETE -SID

  
For Oracle 8i or higher this is:

C:\ORADIM -DELETE -SID

  
Also create the new Oracle Database 10gR2 service at a command prompt using
the ORADIM command of the new Oracle Database release:  
  

C:\> ORADIM -NEW -SID SID -INTPWD PASSWORD -MAXUSERS USERS  
-STARTMODE AUTO -PFILE ORACLE_HOME\DATABASE\INITSID.ORA

  
**Step 26:**  
  
Copy configuration files from the ORACLE_HOME of the database being upgraded
to the new Oracle Database 10gR2 ORACLE_HOME:  
  
If your parameter file resides within the old environment's ORACLE_HOME, then
copy it to the new ORACLE_HOME. By default, Oracle looks for the parameter
file in ORACLE_HOME/dbs on UNIX platforms and in ORACLE_HOME\database on
Windows operating systems. The parameter file can reside anywhere you wish,
but it should not reside in the old environment's ORACLE_HOME after you
upgrade to Oracle Database 10g.  
  
If your parameter file is a text-based initialization parameter file with
either an IFILE (include file) or a SPFILE (server parameter file) entry, and
the file specified in the IFILE or SPFILE entry resides within the old
environment's ORACLE_HOME, then copy the file specified by the IFILE or SPFILE
entry to the new ORACLE_HOME. The file specified in the IFILE or SPFILE entry
contains additional initialization parameters.  
  
If you have a password file that resides within the old environments
ORACLE_HOME, then move or copy the password file to the new Oracle Database
10gR2 ORACLE_HOME.  
  
The name and location of the password file are operating system-specific.  
On UNIX platforms, the default password file is ORACLE_HOME/dbs/orapwsid.  
On Windows operating systems, the default password file is  
ORACLE_HOME\database\pwdsid.ora. In both cases, sid is your Oracle instance
ID.  
  
If you are upgrading a cluster database and your initdb_name.ora file resides
within the old environment's ORACLE_HOME, then move or copy the
initdb_name.ora file to the new ORACLE_HOME.  
  
**Note:**  
If you are upgrading a cluster database, then perform this step on all nodes  
in which this cluster database has instances configured.  
  
**Step 27:**  
  
Update the oratab entry, to set the new ORACLE_HOME and disable automatic
startup:  
  

SID:ORACLE_HOME: **N**

  
**Step 28:**  
  
Update the environment variables like ORACLE_HOME and PATH  
  

$. oraenv

**  
****Step 29:**  
  
Make sure the following environment variables point to the new release (10gR2)
directories:

\- ORACLE_HOME  
\- PATH  
\- ORA_NLS10  
\- ORACLE_BASE  
\- LD_LIBRARY_PATH  
\- LD_LIBRARY_PATH_64 (Solaris only)  
\- LIBPATH (AIX only)  
\- SHLIB_PATH (HPUX only)  
\- ORACLE_PATH

$ env | grep ORACLE_HOME  
$ env | grep PATH  
$ env | grep ORA_NLS10  
$ env | grep ORACLE_BASE  
$ env | grep LD_LIBRARY_PATH  
$ env | grep ORACLE_PATH

  
AIX:

$ env | grep LIBPATH

  
HP-UX:

$ env | grep SHLIB_PATH

  
Note that the ORA_NLS10 environment variable replaces the ORA_NLS33
environment variable, so you should unset ORA_NLS33 and set ORA_NLS10.

As per
[Note:77442.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=77442.1),
you should set ORA_NLS10 to point to $ORACLE_HOME/nls/data.  
  
 **Step 30:**  
  
Startup upgrade the database:

$ cd $ORACLE_HOME/rdbms/admin  
$ sqlplus / as sysdba  
Use Startup with the UPGRADE option:  
SQL> startup upgrade

  
**Step 31:**  
  
Create a SYSAUX tablespace. In Oracle Database 10gR2, the SYSAUX tablespace is
used to consolidate data from a number of tablespaces that were separate in
previous releases.  
  
The SYSAUX tablespace must be created with the following mandatory attributes:  
  
\- ONLINE  
\- PERMANENT  
\- READ WRITE  
\- EXTENT MANAGEMENT LOCAL  
\- SEGMENT SPACE MANAGEMENT AUTO  
  
The Upgrade Information Tool (utlu102i.sql in step 4) provides an estimate of
the minimum required size for the SYSAUX tablespace in the SYSAUX Tablespace
section.  
  
The following SQL statement would create a 500 MB SYSAUX tablespace for the
database:  
  

SQL> CREATE TABLESPACE sysaux DATAFILE 'sysaux01.dbf'  
SIZE 500M REUSE  
EXTENT MANAGEMENT LOCAL  
SEGMENT SPACE MANAGEMENT AUTO  
ONLINE;

  
**Step 32:**  
  
 **NOTE** : Before performing the next action, disable any third party
procedures that check the complexity of schema passwords. During the upgrade,
new schemas may be created and these may initially have an unsecure password
(but only for a very short period of time, because the SQL script that creates
the new schema will then immediately expire the password and lock the schema).
If procedures are in place to enforce password complexity, the "create user"
statement may fail and cause configuration of a component to fail.

Run the catupgrd.sql script, spooling the output so you can check whether any
errors occured and investigate them:

SQL> spool upgrade.log  
SQL> @catupgrd.sql

  
The catupgrd.sql script determines which upgrade scripts need to be run and
then runs each necessary script. You must run the script in the new release
10.2 environment.  
  
The upgrade script creates and alters certain data dictionary tables. It also
upgrades and configures the following database components in the new release
10.2 database (if the components were installed in the database before the
upgrade).  
  
Oracle Database Catalog Views  
Oracle Database Packages and Types  
JServer JAVA Virtual Machine  
Oracle Database Java Packages  
Oracle XDK  
Oracle Real Application Clusters  
Oracle Workspace Manager  
Oracle interMedia  
Oracle XML Database  
OLAP Analytic Workspace  
Oracle OLAP API  
OLAP Catalog  
Oracle Text  
Spatial  
Oracle Data Mining  
Oracle Label Security  
Messaging Gateway  
Expression Filter  
Oracle Enterprise Manager Repository  
  
Turn off the spooling of script results to the log file:  
  

SQL> SPOOL OFF

  
Then, check the spool file and verify that the packages and procedures
compiled successfully. You named the spool file earlier in this step; the
suggested name was upgrade.log. Correct any problems you find in this file and
rerun the appropriate upgrade script if necessary. You can rerun any of the
scripts described in this note as many times as necessary.  
 **  
Step 33:**  
  
Run utlu102s.sql, specifying the TEXT option:  
  

SQL> @utlu102s.sql TEXT

  
This is the Post-upgrade Status Tool that displays the status of the database
components in the upgraded database. The Upgrade Status Tool displays output
similar to the following:  
  
  
Oracle Database 10.2 Upgrade Status Utility 04-20-2005 05:18:40  
  
Component Status Version HH:MM:SS  
Oracle Database Server VALID 10.2.0.1.0 00:11:37  
JServer JAVA Virtual Machine VALID 10.2.0.1.0 00:02:47  
Oracle XDK VALID 10.2.0.1.0 00:02:15  
Oracle Database Java Packages VALID 10.2.0.1.0 00:00:48  
Oracle Text VALID 10.2.0.1.0 00:00:28  
Oracle XML Database VALID 10.2.0.1.0 00:01:27  
Oracle Workspace Manager VALID 10.2.0.1.0 00:00:35  
Oracle Data Mining VALID 10.2.0.1.0 00:15:56  
Messaging Gateway VALID 10.2.0.1.0 00:00:11  
OLAP Analytic Workspace VALID 10.2.0.1.0 00:00:28  
OLAP Catalog VALID 10.2.0.1.0 00:00:59  
Oracle OLAP API VALID 10.2.0.1.0 00:00:53  
Oracle interMedia VALID 10.2.0.1.0 00:08:03  
Spatial VALID 10.2.0.1.0 00:05:37  
Oracle Ultra Search VALID 10.2.0.1.0 00:00:46  
Oracle Label Security VALID 10.2.0.1.0 00:00:14  
Oracle Expression Filter VALID 10.2.0.1.0 00:00:16  
Oracle Enterprise Manager VALID 10.2.0.1.0 00:00:58  
Note - in RAC environments, this script may suggest that the status of the RAC
component is INVALID when in actual fact it is VALID (as shown in the output
from DBA_REGISTRY)  
  
**NOTE:** As per
[Note:456845.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=456845.1),
the output from the utlu102s.sql script may differ from the output from
DBA_REGISTRY. To check the current status of each component, run the following
SQL statement:  
  

SQL> select comp_name, status, version from dba_registry;

**Step 34:**  
  
Restart the database:

SQL> shutdown immediate (DO NOT use "shutdown abort" !!!)  
SQL> startup restrict

  
Executing this clean shutdown flushes all caches, clears buffers and performs
other database housekeeping tasks which is needed if you want to upgrade
specific components.  
  
 **Step 35:**  
  
Run olstrig.sql to re-create DML triggers on tables with Oracle Label Security
policies.  
This step is only necessary if Oracle Label Security is in your database.  
(Check from Step 33).  
  

SQL> @olstrig.sql

  
**Step 36:**  
  
Run utlrp.sql to recompile any remaining stored PL/SQL and Java code.  
  

SQL> @utlrp.sql

  
Verify that all expected packages and classes are valid:  
  
If there are still objects which are not valid after running the script run
the following:  
  

spool invalid_post.lst  
Select substr(owner,1,12) owner,  
substr(object_name,1,30) object,  
substr(object_type,1,30) type, status  
from  
dba_objects where status <>'VALID';  
spool off

  
Now compare the invalid objects in the file 'invalid_post.lst' with the
invalid objects in the file 'invalid_pre.lst' you created in step 9.  
  
NOTE: If you have upgraded from version 9.2 to version 10.2 and find that the
following views are invalid, the views can be safely ignored (or dropped):  
  
SYS.V_$KQRPD  
SYS.V_$KQRSD  
SYS.GV_$KQRPD  
SYS.GV_$KQRSD

You can also ignore or drop the following public synonyms:

V$KQRPD  
V$KQRSD  
GV$KQRPD  
GV$KQRSD

As they are based on:

SYS.V_$KQRPD  
SYS.V_$KQRSD  
SYS.GV_$KQRPD  
SYS.GV_$KQRSD

  
  
**NOTE** : If you have used OPatch to apply a CPU patch to the 10.2.0.x home,
you now need to review and follow the post-installation steps in the README
file of the CPU patch to apply the CPU patch to the upgraded database. This
may require running the catcpu.sql and other scripts and will vary depending
on the version of the CPU installed.

**NOTE** : After the upgrade there may be invalid views with the prefix x_$.
These views are created by third party applications and are pointing to non-
existent or modified x$ tables. Third parties should not create SYS owned
views, particularly not SYS owned views based on internal X$ tables. Since
these are not Oracle created objects, they should be dropped before upgrade,
since they cannot be validated or dropped after upgrade using normal methods.

Additional information can be found in:

[Note
361757.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=361757.1)
Invalid x_$ Objects After Upgrade.

  
**After Upgrading a Database**

**Step 37:**  
  
Shutdown the database and startup the database.

$ sqlplus '/as sysdba'  
SQL> shutdown  
SQL> startup restrict

  
**Step 38:**  
  
  
Complete the Step 38 only if you upgraded your database from release 8.1.7.  
Otherwise skip to Step 39.  
  
A) If you are not using N-type columns for **user data** , ie. the query  
  

select distinct OWNER, TABLE_NAME  
from DBA_TAB_COLUMNS  
where DATA_TYPE in ('NCHAR','NVARCHAR2', 'NCLOB')  
and OWNER not in ('SYS','SYSTEM','XDB');

did not return rows in Step 6 of this note then:

$ sqlplus '/as sysdba'  
SQL> shutdown immediate

and go to step 40.  
  
B) IF your version 8 NLS_NCHAR_CHARACTERSET was UTF8:  
  
You can look up your previous NLS_NCHAR_CHARACTERSET using this select:

select * from nls_database_parameters where parameter ='NLS_SAVED_NCHAR_CS';

  
then:  
  

$ sqlplus '/as sysdba'  
SQL> shutdown immediate

and go to step 40.  
  
C) IF you are using N-type columns for *user* data *AND* your previous
NLS_NCHAR_CHARACTERSET was in the following list:  
  
JA16SJISFIXED , JA16EUCFIXED , JA16DBCSFIXED , ZHT32TRISFIXED  
KO16KSC5601FIXED , KO16DBCSFIXED , US16TSTFIXED , ZHS16CGB231280FIXED  
ZHS16GBKFIXED , ZHS16DBCSFIXED , ZHT16DBCSFIXED , ZHT16BIG5FIXED  
ZHT32EUCFIXED  
  
then the N-type columns *data* need to be converted to AL16UTF16:  
  
To upgrade user tables with N-type columns to AL16UTF16 run the script
utlnchar.sql:

$ sqlplus '/as sysdba'  
SQL> @utlnchar.sql  
SQL> shutdown immediate;

go to step 40.  
  
D) IF you are using N-type columns for *user* data *AND * your previous
NLS_NCHAR_CHARACTERSET was *NOT* in the following list:  
  
JA16SJISFIXED , JA16EUCFIXED , JA16DBCSFIXED , ZHT32TRISFIXED  
KO16KSC5601FIXED , KO16DBCSFIXED , US16TSTFIXED , ZHS16CGB231280FIXED  
ZHS16GBKFIXED , ZHS16DBCSFIXED , ZHT16DBCSFIXED , ZHT16BIG5FIXED  
ZHT32EUCFIXED  
  
then import the data exported in point 8 of this note. The recommended
NLS_LANG during import is simply the NLS_CHARACTERSET, not the
NLS_NCHAR_CHARACTERSET  
  
After the import:

$ sqlplus '/as sysdba'  
SQL> shutdown immediate;

go to step 40.  
 **  
Step 39:**

  
if you are upgrading from 8.1.7.4 skip to Step 40  
  
If , while following,  
  
[Note
553812.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=553812.1)
Actions for the DSTv4 update in the 10.2.0.4 patchset  
[Note
1086400.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=1086400.1)
Actions for the DSTv4 update in the 10.2.0.5 patchset  
  
utltzpv4.sql found rows then restore the rows you backed up now.  
  
Check if a "select * from dba_scheduler_jobs;" from the sqlplus found in the
oracle_home on the server (!!! this is important !!! - do NOT use a remote
client) gives "ORA-01882: timezone region %s not found" , if so then you need
to run Fix1882.sql mentioned in Note 414590.1. This will not harm the
database.

**Step 40:**  
  
Now edit the init.ora:

\- If you changed the value for NLS_LENGTH_SEMANTICS from CHAR to BYTE prior
to the upgrade (see step 21), set it back to CHAR. Otherwise, do not change
the value of the parameter to CHAR without **careful** evaluation and testing.
Switching to CHAR semantics can break application code. See
[Note:144808.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=144808.1)
for further information about the usage of this parameter.

\- If you changed the value for CLUSTER_DATABASE from TRUE to FALSE prior to
the upgrade, set it back to TRUE  
 **  
Step 41:**  
  
Startup the database:

SQL> startup

  
Create a server parameter file with a initialization parameter file  
  

SQL> create spfile from pfile;

  
This will create a spfile as a copy of the init.ora file located in the  
$ORACLE_HOME/dbs directory.  
  
 **Step 42:**  
  
Modify the listener.ora file:  
For the upgraded intstance(s) modify the ORACLE_HOME parameter to point to the
new ORACLE_HOME.  
  
 **Step 43:**  
  
Start the listener  
  

$ lsnrctl  
LSNRCTL> start

  
**Step 44:**  
  
Enable cron and batch jobs.  
  
 **Step 45:**  
  
Change oratab entry to use automatic startup  
SID:ORACLE_HOME: **Y**  
**  
Step 46:**  
  
Upgrade the Oracle Cluster Registry (OCR) Configuration.  
If you are using Oracle Cluster Services, then you must upgrade the Oracle
Cluster Registry (OCR) keys for the database.  
  
* Use srvconfig from the 10g ORACLE_HOME. For example:  
  

$ srvconfig -upgrade -dbname <db_name> -orahome <pre-10g_Oracle_home>

If the output from the $ORACLE_HOME/bin/ocrdump command references the pre-10g
home, it may be necessary to do the following:

From the pre-10g home, run the command:

$ svrctl remove database -d <db_name>

From the 10g home, run the commands:

$ srvctl add database -d <db_name> -o <10g_Oracle_home>  
$ srvctl add instance -d <db_name> -i <instance1_name> -n <node1>  
$ srvctl add instance -d <db_name> -i <instance2_name> -n <node2>

**Step 47:**

Use the DBMS_STATS package to gather new statistics for your user objects.
Using statistics collected from a previous Oracle version may lead CBO to
generate less optimal execution plans.

SQL> EXEC DBMS_STATS.GATHER_DICTIONARY_STATS ;

  
References:  
  

[Note:114671.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=114671.1)
"Gathering Statistics for the Cost Based Optimizer"  
[Note:262592.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=262592.1)
"How to tune your Database after Migration/Upgrade"

**Step 48:**

Enterprise Manager Grid Control (EMGC) will show that the upgraded database
does not have an inventory. To re-discover the database, do the following:

1\. Go to EMGC => Targets => Databases

2\. Select the upgraded database and remove it

3\. Click "Add", enter the name of the host and click "Continue" to allow EMGC
to re-discover  
the database in the correct home with the correct inventory

### Useful Hints

** Upgrading With Read-Only and Offline Tablespaces (Database must be in
archive log mode)  
  
The Oracle database can read file headers created prior to Oracle 10g, so you
do not need to do anything to them during the upgrade. The only exception to
this is if you want to transport tablespaces created prior to Oracle 10g, to
another platform. In this case, the file headers must be made read-write at
some point before the transport. However, there are no special actions
required on them during the upgrade.  
  
The file headers of offline datafiles are updated later when they are brought
online, and the file headers of read-only tablespaces are updated if and when
they are made read-write sometime after the upgrade. In any other
circumstance, read-only tablespaces never have to be made read-write.  
  
To decrease the time needed for a recovery in case of issues with the
migration, users can OFFLINE NORMAL all user or application created
tablespaces prior to migration. This way if migration fails only the Oracle
created tablespaces and rollback datafiles need to be restored rather than the
entire database.

You can not OFFLINE any Oracle created tablespaces including those containing
rollback/UNDO tablespace prior to migration.

Note: You must OFFLINE the TABLESPACE as migrate does not allow OFFLINE files
in an ONLINE tablespace.

Note: If you are upgrading from Oracle9i, the CWMLITE tablespace (which
contains OLAP objects) will need to be ONLINE during the upgrade (so that the
OLAP objects can be upgraded to 10g and moved to the SYSAUX tablespace)  
  
** Converting Databases to 64-bit Oracle Database Software  
  
If you are installing 64-bit Oracle Database 10gR2 software but were
previously using a 32-bit Oracle Database installation, then the databases
will automatically be converted to 64-bit during the upgrade to Oracle
Database 10gR2 except when upgrading from Release 1 (10.1) to Release 2
(10.2).  
  
The process is not automatic for the release 1 to release 2 upgrade, but is
automatic for all other upgrades. This is because the utlip.sql script is not
run during the release 1 to release 2 upgrade to invalid all PL/SQL objects.
You must run the utlip.sql script as the last step in the release 10.1
environment, before upgrading to release 10.2.  
  
** If error occurs while executing the catupgrd.sql  
  
If an error occurs during the running of the catupgrd.sql script, once the
problem is fixed you can simply rerun the catupgrd.sql script to finish the
upgrade process and complete the upgrade process.

### Appendix A: Initialization Parameters Obsolete in 10g

ENQUEUE_RESOURCES  
DBLINK_ENCRYPT_LOGIN  
HASH_JOIN_ENABLED  
LOG_PARALLELISM  
MAX_ROLLBACK_SEGMENTS  
MTS_CIRCUITS  
MTS_DISPATCHERS  
MTS_LISTENER_ADDRESS  
MTS_MAX_DISPATCHERS  
MTS_MAX_SERVERS  
MTS_MULTIPLE_LISTENERS  
MTS_SERVERS  
MTS_SERVICE  
MTS_SESSIONS  
OPTIMIZER_MAX_PERMUTATIONS  
ORACLE_TRACE_COLLECTION_NAME  
ORACLE_TRACE_COLLECTION_PATH  
ORACLE_TRACE_COLLECTION_SIZE  
ORACLE_TRACE_ENABLE  
ORACLE_TRACE_FACILITY_NAME  
ORACLE_TRACE_FACILITY_PATH  
PARTITION_VIEW_ENABLED  
PLSQL_NATIVE_C_COMPILER  
PLSQL_NATIVE_LINKER  
PLSQL_NATIVE_MAKE_FILE_NAME  
PLSQL_NATIVE_MAKE_UTILITY  
ROW_LOCKING  
SERIALIZABLE  
TRANSACTION_AUDITING  
UNDO_SUPPRESS_ERRORS

### Appendix B: Initialization Parameters Deprecated in 10g

LOGMNR_MAX_PERSISTENT_SESSIONS  
MAX_COMMIT_PROPAGATION_DELAY  
REMOTE_ARCHIVE_ENABLE  
SERIAL_REUSE  
SQL_TRACE  
BUFFER_POOL_KEEP (replaced by DB_KEEP_CACHE_SIZE)  
BUFFER_POOL_RECYCLE (replaced by DB_RECYCLE_CACHE_SIZE)  
GLOBAL_CONTEXT_POOL_SIZE  
LOCK_NAME_SPACE  
LOG_ARCHIVE_START  
MAX_ENABLED_ROLES  
PARALLEL_AUTOMATIC_TUNING  
PLSQL_COMPILER_FLAGS (replaced by PLSQL_CODE_TYPE and PLSQL_DEBUG)

### Known issues

1) While doing a upgrade from 9iR2 to 10.2.0.X.X, on running the utlu102i.sql
script as directed in step 2  
Its output informs to add streams_pool_size=50331648 to the init.ora file.
While adding the parameter Oracle gives streams_pool_size as invalid
parameter.  
  
STREAMS_POOL_SIZE, was introduced in release 10gR1. This message may be
ignored for database version 9iR2 or less.  
  
2) One of the customer has reported on keeping the shared_pool_size at 150 MB,
catmeta.sql fails with insuffient shared memory during the processing of view
KU$_PHFTABLE_VI.  
  
Please set the shared_pool_size at 200M.  
  
3) While upgrade following error was encountered.  
create or replace  
*   
ERROR at line 1:  
ORA-06553: PLS-213: package STANDARD not accessible.  
ORA-00955: name is already used by an existing object  
  
Please make sure to set the following init parameters as below in the
spfile/init file or comment them out to their default values, at the time of
upgrading the database.  
  
PLSQL_V2_COMPATIBILITY = FALSE  
PLSQL_CODE_TYPE = INTERPRETED # Only applicable to 10gR1  
PLSQL_NATIVE_LIBRARY_DIR = ""  
PLSQL_NATIVE_LIBRARY_SUBDIR_COUNT = 0  
  
Refer to [Note
170282.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=170282.1)
PLSQL_V2_COMPATIBLITY=TRUE causes STANDARD and DBMS_STANDARD to Error at
Compile  
  
@  
  
Always disconnect from the session which issues the STARTUP and connect as a
fresh session before doing any further SQL. eg: On upgrade to 10.2 startup the
instance with the upgrade option, exit sqlplus , reconnect a fresh SQLPLUS
session as SYSDBA and then run the upgrade scripts.

If this is not a RAC instance, but DBA_REGISTRY shows the RAC component and it
is invalid the following bite can be used to remove the reference from
DBA_REGISTRY.

[NOTE:312071.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=312071.1)
\- RAC Option Invalid After Migration

5) Upgrade log shows process errors with ORA-28031 "maximum of 148 enabled
roles" when creating queue table.

The number of DEFINED roles (enabled and disabled) that SYS has must not
exceed the maximum number of roles defined for the database as defined by the
instance parameter max_enabled_roles.

To correct, reduce the number of DEFINED roles to less then 148 then re-run
the catupgrd.sql script.

### Community Discussions

Would you like to explore this topic further with other Oracle Customers and
Specialists? If so, we encourage you to participate in the friendly
discussions at the [Database Install
Community](https://community.oracle.com/community/support/oracle_database/database_install_upgrade_opatch
"Discuss DB Install Issues").  
  

### Revision History

Support have been asked to include this new section in the note. It is not
possible to provide a completely accurate revision history because many
changes have been made since the note was first created in 2005 but, now that
this section exists, Support will keep it up-to-date.  
  
**18-JUL-2005**

Article created  
  
**31-JUL-2005**

Article published  
  
**24-JAN-2007**

\- Explicitly set AQ_TM_PROCESSES=0 in init.ora (step 21)  
  
 **29-JAN-2007**

\- V_$ and GV_$ views can be dropped (step 36)  
  
**03-DEC-2007**

\- Drop table XDB.MIGR9202STATUS from the OLD home (step 18)  
\- Full cold backup OR an online backup using RMAN (step 20)  
  
**05-FEB-2008**

\- Added reference to
[Note:406472.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=406472.1)
in the list of prerequisites  
\- N-type columns in tables owned by XDB can be ignored (step 6)  
\- Add workaround to ORA-1403 from utlu102i.sql (step 2)  
\- Added reference to
[Note:471479.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=471479.1)
in the list of prerequisites  
  
**27-FEB-2008**

\- Added some further commands to step 46  
\- Added a step about gathering new statistics (step 47)  
\- Added a reference to
[Note:407031.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=407031.1)
in step 2  
\- Added advice regarding ORA_NLS10 (step 29)  
\- Skip step 6 if upgrading from 9.x to 10.2  
\- Keep CWMLITE tablespace online (useful hints)  
\- Check that DBA_REGISTRY contains data (step 8)  
\- Added reference to
[Note:465951.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=465951.1)
in the list of prerequisites  
\- Use GATHER_SCHEMA_STATS in 8i and 9i (step 7)  
  
**18-APR-2008**

\- Added this ÃÂÃÂ¢ÃÂÃÂÃÂÃÂRevision HistoryÃÂÃÂ¢ÃÂÃÂÃÂÃÂ section to the note  
\- Clarified when to set UNDO_MANAGEMENT=AUTO in step 21  
\- Added reference to
[Note:135090.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=135090.1)
in step 21  
\- Added reference to
[Note:293658.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=293658.1)
in the list of prerequisites  
\- Added reference to
[Note:316900.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=316900.1)
in the list of prerequisites  
\- Added reference to
[Note:466181.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=466181.1)
in the list of prerequisites  
\- Added reference to
[Note:557242.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=557242.1)
in the list of prerequisites  
\- Added some info to step 36 about running catcpu.sql if a CPU patch is
applied to the home  
\- Explicitly set JOB_QUEUE_PROCESSES=0 in init.ora (step 21)  
\- Added a step about discovering the upgraded database in EMGC (step 48)

**21-APR-2008**

\- Added a note suggesting that password complexity checking procedures are
disabled (step 32)  
\- Added a warning about using NLS_LENGTH_SEMANTICS=CHAR (step 40)  
  
**29-SEP-2008**  
  
\- Added reference to
[Note:565600.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=565600.1)
in the list of prerequisites  
\- Added reference to
[Note:603714.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=603714.1)
in the list of prerequisites  
\- Added reference to
[Note:456845.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=456845.1)
in step 33  
\- Clarified step 21

**29-APR-2009  
** \- Added reference to
[Note:312071.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=312071.1)
into known issues  
\- Added disclamer for movement of database instance form one system to
another  
\- Processed remarks and corrections for changes due to new patch versions.

**18-AUG-2009**  
\- Expanded information about invalid x_$ views, and removed comments about
[Note
361757.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=361757.1)
being restricted since it has been changed to published external

## References

[NOTE:312071.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=312071.1)
\- RAC Option Invalid After Migration  
[NOTE:316900.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=316900.1)
\- ALERT: Oracle 10g Release 2 (10.2) Support Status and Alerts  
[NOTE:317258.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=317258.1)
\- Predefined Roles Evolution From 8i to 10g R2: CONNECT Role Change in 10gR2  
  
[NOTE:356082.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=356082.1)
\- ORA-7445 [qmeLoadMetadata()+452] During 10.1 to 10.2 Upgrade  
[NOTE:361757.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=361757.1)
\- Invalid x_$ Objects After Upgrade  
[NOTE:466181.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=466181.1)
\- Oracle 10g Upgrade Companion  
[NOTE:471479.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=471479.1)
\- IOT Corruptions After Upgrade from COMPATIBLE <= 9.2 to COMPATIBLE >= 10.1  
[NOTE:553812.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=553812.1)
\- Actions for the DSTv4 update in the 10.2.0.4 patchset  
[NOTE:5640527.8](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=5640527.8)
\- Bug 5640527 - ORA-1403 running utlu102i.sql on an 8.1.7.4 database  
[NOTE:565600.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=565600.1)
\- ERROR IN CATUPGRD: ORA-00904 IN DBMS_SQLPA  
[NOTE:603714.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=603714.1)
\- 10.2.0.4 Catupgrd.sql Fails With ORA-03113 Creating SYS.KU$_XMLSCHEMA_VIEW  
[NOTE:745183.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=745183.1)
\- After upgrade CATPROC and CATALOG comps are INVALID even if only user
invalid objects are found  
[NOTE:77442.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=77442.1)
\- ORA_NLS (ORA_NLS32, ORA_NLS33, ORA_NLS10) Environment Variables explained.  
[NOTE:979942.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=979942.1)
\- Database Upgrade Appears To Have Halted At SYS.AUD$ Table  
[NOTE:1573175.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=1573175.1)
\- Upgrading or Installing XDB could result in data loss if
XDB_INSTALLATION_TRIGGER exists  
[NOTE:406472.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=406472.1)
\- Mandatory Patch 5752399 for 10.2.0.3 on Solaris 64-bit and Filesystems
Managed By Veritas or Solstice Disk Suite software  
[NOTE:407031.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=407031.1)
\- ORA-01403 no data found while running utlu102i.sql/utlu102x.sql on 8174
database  
[NOTE:412160.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=412160.1)
\- Updated DST Transitions and New Time Zones in Oracle RDBMS and OJVM Time
Zone File Patches  
[NOTE:412271.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=412271.1)
\- ORA-600 [22635] and ORA-600 [KOKEIIX1] Reported While Upgrading or Patching
Databases to 10.2.0.3  
[NOTE:414590.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=414590.1)
\- Time Zone IDs for 7 Time Zones Changed in Time Zone Files Version 3 and
Higher, Possible ORA-1882 After Upgrade  
[NOTE:443706.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=443706.1)
\- After Migrate From 9.2.0.7 To 10.2.0.3 We Get Ora-04065 On Plitblm  
[NOTE:456845.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=456845.1)
\- UTLU102S.SQL, UTLU111S.SQL, UTLU112S.SQL and UTLU121S.SQL May Show
Different Results Than Select From DBA_REGISTRY  
[NOTE:4638550.8](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=4638550.8)
\- Bug 4638550 - OERI[dmlsrvColLenChk_2:dty] during upgrade from 9.2 to 10.2  
[NOTE:465951.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=465951.1)
\- ORA-600 [kcbvmap_1] or ORA-600 [kcliarq_2] On Startup Upgrade Moving From a
32-Bit To 64-Bit Release  
[NOTE:557242.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=557242.1)
\- Upgrade Gives Ora-29558 Error Despite of JAccelerator Has Been Installed  
  
  
  
[NOTE:1086400.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=1086400.1)
\- Actions for the DSTv4 update in the 10.2.0.5 patchset  
[NOTE:114671.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=114671.1)
\- Gathering Statistics for the Cost Based Optimizer (Pre 10g)  
[NOTE:135090.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=135090.1)
\- Managing Rollback/Undo Segments in AUM (Automatic Undo Management)  
[NOTE:144808.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=144808.1)
\- Examples and limits of BYTE and CHAR semantics usage (NLS_LENGTH_SEMANTICS)  
[NOTE:158577.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=158577.1)
\- NLS_LANG Explained (How does Client-Server Character Conversion Work?)  
[BUG:4478139](https://support.oracle.com/epmos/faces/BugDisplay?parent=DOCUMENT&sourceId=316889.1&id=4478139)
\- ORA-28031 MAXIMUM OF 148 ENABLED ROLES WHEN CREATING MULTICONSUMER QUEUE
TABLE  
[BUG:4053185](https://support.oracle.com/epmos/faces/BugDisplay?parent=DOCUMENT&sourceId=316889.1&id=4053185)
\- REGISTRY SHOWS INVALID FOR ORACLE9I REAL APPLICATION CLUSTERS  
[NOTE:159657.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=159657.1)
\- Complete Upgrade Checklist for Manual Upgrades from 8.X / 9.0.1 to
Oracle9iR2 (9.2.0)  
[NOTE:170282.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=170282.1)
\- PLSQL_V2_COMPATIBLITY=TRUE causes STANDARD and DBMS_STANDARD to Error at
Compile  
[NOTE:179133.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=179133.1)
\- The Correct NLS_LANG in a Microsoft Windows Environment  
[NOTE:262592.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=262592.1)
\- How to tune your Database after Migration/Upgrade  
[NOTE:263809.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=263809.1)
\- Complete Checklist for Manual Upgrades to 10gR1 (10.1.0.x)  
[NOTE:264157.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=264157.1)
\- The Correct NLS_LANG Setting in Unix Environments  
[NOTE:290738.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=290738.1)
\- Oracle Critical Patch Update Program General FAQ  
[NOTE:293658.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=316889.1&id=293658.1)
\- 10.1 or 10.2 Patchset Install Getting ORA-29558 JAccelerator (NCOMP) And
ORA-06512 [VIDEO]  
  
  
  


---
### NOTE ATTRIBUTES
>Created Date: 2018-01-22 02:55:37  
>Last Evernote Update Date: 2018-10-01 15:44:49  
>author: YangKwong  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153457284099074  
>source-url: &  
>source-url: id=316889.1  
>source-url: &  
>source-url: _adf.ctrl-state=11dph05qcs_431  