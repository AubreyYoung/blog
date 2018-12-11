# Location Of Logs For OPatch And OUI (文档 ID 403212.1)

  

|

|

 **In this Document**  

| |
[Goal](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=178498073052448&id=403212.1&_afrWindowMode=0&_adf.ctrl-
state=144uoegb17_92#GOAL)  
---|---  
|
[Solution](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=178498073052448&id=403212.1&_afrWindowMode=0&_adf.ctrl-
state=144uoegb17_92#FIX)  
---|---  
|
[References](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=178498073052448&id=403212.1&_afrWindowMode=0&_adf.ctrl-
state=144uoegb17_92#REF)  
---|---  
  
* * *

## Applies to:

Oracle Database - Enterprise Edition - Version 9.2.0.1 to 12.1.0.2 [Release
9.2 to 12.1]  
Oracle Database - Standard Edition - Version 9.2.0.1 to 12.1.0.2 [Release 9.2
to 12.1]  
Oracle Universal Installer - Version 2.2.0.18 to 12.1.0.2  
Information in this document applies to any platform.  
  

## Goal

How to find the log files for OPatch and OUI ( Oracle Universal Installer) ?

## Solution

**OPatch (Common for Windows and Unix)**

**OPatch version - 1.0.0.0.XX. (Oracle RDBMS -9.2.0.X.X and 10.1.0.X.X )**  
  
In the list below, locate the command you executed. The location of the log is
listed after the command.

1) **opatch lsinventory -detail**  
<ORACLE_HOME>/.patch_storage/LsInventory__<timestamp>.log

2) **opatch lsinventory -all**  
<ORACLE_HOME>/.patch_storage/LsInventory__<timestamp>.log

3) **opatch apply**  
<ORACLE_HOME>/.patch_storage/<ID of patch>/Apply_<ID of patch>_<timestamp>.log

4) **opatch rollback -id <ID of patch>**  
<ORACLE_HOME>/.patch_storage/<ID of patch>/RollBack__<ID of
patch>_<timestamp>.log

  
  
**OPatch version -10.2.0.X.X and 11.2.0.1.x  
**

Every OPatch command that is executed is recorded in the file
<ORACLE_HOME>/cfgtoollogs/opatch/opatch_history.txt.

**Example :**

Date & Time : Mon Mar 24 15:41:00 EST 2008  
Oracle Home : /u03/app/oracle/product/10.2.0.3  
OPatch Ver. : 10.2.0.3.4  
Current Dir : /cpu/10203/apr/6864068  
Command : napply -skip_subset -skip_duplicate  
Log File :
/u03/app/oracle/product/10.2.0.3/cfgtoollogs/opatch/opatch2008-03-24_15-41-00PM.log  
  
Date & Time : Mon Mar 24 16:08:42 EST 2008  
Oracle Home : /u03/app/oracle/product/10.2.0.3  
OPatch Ver. : 10.2.0.3.4  
Current Dir : /cpu/10203/apr/6864068  
Command : nrollback -id
6121183,6121242,6121243,6121244,6121245,6121246,6121249,6121250  
Log File :
/u03/app/oracle/product/10.2.0.3/cfgtoollogs/opatch/opatch2008-03-24_16-08-42PM.log  
  
Date & Time : Mon Mar 24 16:14:13 EST 2008  
Oracle Home : /u03/app/oracle/product/10.2.0.3  
OPatch Ver. : 10.2.0.3.4  
Current Dir : /cpu/10203/apr/6864068  
Command : lsinventory  
Log File :
/u03/app/oracle/product/10.2.0.3/cfgtoollogs/opatch/opatch2008-03-24_16-14-13PM.log

This data should be used to locate the correct Log File.  
The file is appended, so the current information is located at the end of the
file.  
It is also recommended that if a log file is uploaded to Oracle, this file is
also uploaded.

In the list below, locate the command you executed. The location of the log is
listed after the command.

1) **opatch lsinventory -detail  
** <ORACLE_HOME>/cfgtoollogs/opatch/lsinv/lsinventory-<timestamp>.txt  
<ORACLE_HOME>/cfgtoollogs/opatch/opatch-<timestamp>.log

2) **opatch lsinventory -all  
** <ORACLE_HOME>/cfgtoollogs/opatch/lsinv/lsinventory-<timestamp>.txt  
<ORACLE_HOME>/cfgtoollogs/opatch/opatch-<timestamp>.log

3) **opatch apply  
** <ORACLE_HOME>/cfgtoollogs/opatch/opatch-<timestamp>.log

4) **opatch rollback -id <ID of patch>**  
<ORACLE_HOME>/ cfgtoollogs/opatch/opatch-<timestamp>.log

**  
**

**OPatch version 11.1.0.9.x (x >=7) and 11.2.0.3.x  
**

**11GR1 :**

  
From version 11.1.0.9.7 of OPatch the location of .log for the apply and
rollback operations are no more the same  
as with previous versions of OPatch (this change does not apply to lsinventory
and n-apply operations) :  
  
instead of  
$ORACLE_HOME/cfgtoollogs/opatch/opatch<timestamp>.log  
it is now  
$ORACLE_HOME/cfgtoollogs/opatch/<ID of
patch>_<timestamp>/<action><timestamp>.log  
  
<action> being "apply" or "rollback"

**11.2.0.3.x :**  
  
With last version of OPatch (11.2.0.3.3) :  
  
\- location of .log for apply, lsinventory, n-apply operations remain the same
as for **10.2.0.x** i.e  
  
$ORACLE_HOME/cfgtoollogs/opatch  
  
\- location of .log for rollback operations is the same as for last **11GR1**
versions (11.1.0.9.x (x>=7)) i.e :  
  
$ORACLE_HOME/cfgtoollogs/opatch/<ID of
patch>_<timestamp>/rollback<timestamp>.log  
  
This rule won't apply for new composite PSU as "opatch apply" is in fact
generating a N-Apply statement for composite patches,  
so for new composite patches the location of OPatch .log will remain the same
i.e  
$ORACLE_HOME/cfgtoollogs/opatch/opatch<timestamp>.log **  
**  
  

**ATTENTION :**  
  
With first 11.2.0.3.x versions (ex.: 11.2.0.3.0) the location of .log for
apply operations will be the same as for last **11GR1** versions (11.1.0.9.x
(x>=7)).

For example here is the difference when applying PSU 11.2.0.2.6 (patch
13696224) with 11.2.0.3.0 OPatch and  
when applying PSU 11.2.0.3.4 (14275605) with 11.2.0.3.3 OPatch :  
  
  
with 11.2.0.3.0 OPatch the .log for PSU 11.2.0.2.6 will show :

  
OPatch version : 11.2.0.3.0  
OUI version : 11.2.0.2.0  
Log file location :
<ORACLE_HOME>/cfgtoollogs/opatch/13696224_Apr_04_2012_18_52_54/apply2012-04-04_18-52-54PM_1.log

with 11.2.0.3.3 OPatch the .log for PSU 11.2.0.3.4 will show :  
  

OPatch version : 11.2.0.3.3  
OUI version : 11.2.0.3.0  
Log file location :
<ORACLE_HOME>/cfgtoollogs/opatch/opatch2012-12-28_16-10-54PM_1.log

  
(<ORACLE_HOME> being value for $ORACLE_HOME)

**12.1.0.1.x :**  
  
Location of .log for apply, lsinventory, n-apply operations is

$ORACLE_HOME/cfgtoollogs/opatch

  
Location of .log for rollback operations is

$ORACLE_HOME/cfgtoollogs/opatch/<ID of
patch>_<timestamp>/rollback<timestamp>.log

  
This rule won't apply for new composite PSU as "opatch apply" is in fact
generating a N-Apply statement for composite patches, so for new composite
patches the location of OPatch .log is

$ORACLE_HOME/cfgtoollogs/opatch/opatch<timestamp>.log

**  
**

**Oracle Universal Installer (OUI)**  
  
**9.2.0.X.X, 10.1.0.X.X, 10.2.0.X.X and 11.2.0.X.X  
**  
The logs are found in <central_inventory>/logs directory.  
From 10gr2 version , the logs are also found in <ORACLE_HOME>/cfgtoollogs/oui  
  
In Windows the location of the central inventory can be found from the value
of the pointer orainst_loc that can be found from the
HKEY_LOCAL_MACHINE\SOFTWARE\ORACLE\ key in the registry. By default the
central inventory exists in C:\Program Files\Oracle\Inventory.  
  
In Unix the location of central inventory (oraInventory) can be found from the
oraInst.loc file, which exists in the /var/opt/oracle or /etc/ (By default).  
  
**The logs will be as below:**

**9.2.0.X.X, 10.1.0.X.X, 10.2.0.X.X, 11.1.0.X.X , 11.2.0.X.X and 12.1.0.X.X  
**

<Central_Inventory>/logs/InstallActions<timestamp>.log  
<Central_Inventory>/logs/oraInstall<timestamp>.out  
<Central_Inventory>/logs/oraInstall<timestamp>.err  
<Central_Inventory>/logs/silentInstall<timestamp>.log (only for Silent
installations)

**10.2.0.X.X to 12.1.0.X.X only**

<ORACLE_HOME>/cfgtoollogs/oui/InstallActions<timestamp>.log  
<ORACLE_HOME>/cfgtoollogs/oui/oraInstall<timestamp>.out  
<ORACLE_HOME>/cfgtoollogs/oui/oraInstall<timestamp>.err  
<ORACLE_HOME>/cfgtoollogs/oui/silentInstall<timestamp>.log (only for Silent
installations)

The logs for Cloning can be found in under central inventory and Oracle Home
as below :

**Logfiles in Central Inventory:**

<Central_Inventory>/logs/cloneActions timestamp.log  
Contains a detailed log of the actions that occur during the OUI part of the
cloning.  
  
<Central_Inventory>/logs/oraInstall timestamp.err  
Contains information about errors that occur when OUI is running.  
  
<Central_Inventory>/logs/oraInstall timestamp.out  
Contains other miscellaneous messages generated by OUI.

  
**Logfiles in $ORACLE_HOME:**

$ORACLE_HOME/clone/logs/clone timestamp.log  
Contains a detailed log of the actions that occur during the pre-cloning and
cloning operations.  
  
$ORACLE_HOME/clone/logs/error timestamp.log  
Contains information about errors that occur during the pre-cloning and
cloning operations.

## References

[NOTE:1156586.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=403212.1&id=1156586.1)
\- Master Note For Oracle Database Server Installation  
[NOTE:1351051.2](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=403212.1&id=1351051.2)
\- Information Center: Install and Configure Database Server/Client
Installations  
[NOTE:224346.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=403212.1&id=224346.1)
\- OPatch - Where Can I Find the Latest Version of OPatch? [Video]  
[NOTE:1351428.2](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=403212.1&id=1351428.2)
\- Information Center: Patching and Maintaining Oracle Database Server/Client
Installations  
  
  
  



---
### TAGS
{opatch}  {PSU}  {upgrade}

---
### NOTE ATTRIBUTES
>Created Date: 2017-06-28 10:21:46  
>Last Evernote Update Date: 2018-10-01 15:59:05  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=178498073052448  
>source-url: &  
>source-url: id=403212.1  
>source-url: &  
>source-url: _afrWindowMode=0  
>source-url: &  
>source-url: _adf.ctrl-state=144uoegb17_92  