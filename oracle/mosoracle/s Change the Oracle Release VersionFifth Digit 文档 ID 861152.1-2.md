# s) Change the Oracle Release Version/Fifth Digit? (文档 ID 861152.1)

  
![noteattachment1][5a563b0be47c59aae95d23dce91a7309]

|  
  
---  
  
[![单击此项可添加到收藏夹](https://support.oracle.com/epmos/common/images/favorites_qualifier_notsel.png)](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=501558129658315&id=861152.1&_afrWindowMode=0&_adf.ctrl-
state=oob5eg71a_151# "单击此项可添加到收藏夹")|
![noteattachment2][5a563b0be47c59aae95d23dce91a7309]| Do Patchset Updates
(PSU's) Change the Oracle Release Version/Fifth Digit? (文档 ID 861152.1)| [
![noteattachment3][d74f4ac5869665cf665a5feb44d0f627]转到底部](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=501558129658315&id=861152.1&_afrWindowMode=0&_adf.ctrl-
state=oob5eg71a_151# "转到底部")|
![noteattachment4][5a563b0be47c59aae95d23dce91a7309]  
---|---|---|---|---  
  
* * *

![noteattachment1][5a563b0be47c59aae95d23dce91a7309]

 **In this Document**  

|  
|
[Goal](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=501558129658315&id=861152.1&_afrWindowMode=0&_adf.ctrl-
state=oob5eg71a_151#GOAL)  
---|---  
  
|
[Solution](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=501558129658315&id=861152.1&_afrWindowMode=0&_adf.ctrl-
state=oob5eg71a_151#FIX)  
---|---  
  
|
[References](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=501558129658315&id=861152.1&_afrWindowMode=0&_adf.ctrl-
state=oob5eg71a_151#REF)  
---|---  
  
* * *

##  APPLIES TO:

Oracle Database - Enterprise Edition - Version 10.2.0.4 to 12.1.0.2 [Release
10.2 to 12.1]  
Information in this document applies to any platform.  

## GOAL

This article helps to find whether PSU released for Oracle Database Server
10gR2 ( 10.2.0.x ) and 11gR1 (11.1.0.x) ,11g R2 (11.2.0.x ) and 12c R1
(12.1.0.1) change the database version.

## SOLUTION

Do Patchset Updates (PSU's) Change the Oracle Release Version/Fifth Digit?

Answer: NO.  
  
The PSU i.e 10.2.0.4.x or higher , 11.1.0.7.x and 11.2.0.1.x or higher and
12.1.0.x released for Oracle Database Server version 10.2.0.4.x or higher ,
11.1..0.7.0 ,11.2.0.1 or higher and 12.1.0.x respectively does NOT change the
database version . That means PSU 10.2.0.4.x /10.2.0.5.x, 11.1.0.7.x,
11.2.0.1.x /11.2.0.2.x/11.2.0.3.x/11.2.0.4.x and 12.1.0.1. x ( where x is the
fifth digit ) does NOT change the 5th digit of the Oracle Database Server
version.  
  
After applying the PSU "opatch lsinventory" still shows the version as
10.2.0.4.0/10.2.0.5.0 for Oracle 10g R2, 11.1.0.7 for Oracle 11g R1 , 11.2.0.1
/11.2.0.2/11.2.0.3/11.2.0.4 for Oracle 11g R2 and 12.1.0.1 for Oracle 12c R1  
  
PSU's also will not change the version of oracle binaries (like sqlplus,
exp/imp etc.)

Note : It is also applicable for the Oracle Enterprise Manager Grid Control
and EM Agent  
  
Although Patch Set Updates are referenced by their 5-place version number,
with the 10.2 , 11.1 and 11.2 PSUs the product banners and Oracle Universal
Installer (OUI) information are not updated with the new version number. For
the 10.2 ,11.1 ,11.2 and 12.1 PSUs, use the OPatch inventory information to
determine the PSU version currently installed.

example:

> opatch lsinventory

And compare it to the version table listed in

[Note
854428.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=861152.1&id=854428.1)
Patch Set Updates for Oracle Products  
  
Section 7, "Determining the Patch Set Update Version"

or

1\. Make sure your opatch version is at or above

  * 10.2.0.5.1 for version 10.2 ORACLE_HOMEs
  * 11.1.0.12.9 for version 11.1 ORACLE_HOMEs
  * 11.2.0.3.15 for version 11.2 ORACLE_HOMEs
  * 12.2.0.1.8 for version 12.1 ORACLE_HOMEs

> $ opatch version  
>  Invoking OPatch 10.2.0.4.8  
>  
>  OPatch Version: 10.2.0.4.8

2\. Verify if PSU is installed in the ORACLE_HOME

>  **$ opatch lsinventory -bugs_fixed | egrep 'PSU|PATCH SET UPDATE'  
>  
>  ...  
> ** 12827740 13343461 Wed Feb 22 07:11:36 GMT 2012 DATABASE PSU 11.1.0.7.9
(INCLUDES CPUOCT2011)  
>  13343461 13343461 Wed Feb 22 07:11:36 GMT 2012 DATABASE PATCH SET UPDATE
11.1.0.7.10 (INCLUDES **  
>  
>  
> **

  
3\. Verify the PSU Post Install steps were run in the DB

> select substr(action_time,1,30) action_time,  
>  substr(id,1,10) id,  
>  substr(action,1,10) action,  
>  substr(version,1,8) version,  
>  substr(BUNDLE_SERIES,1,6) bundle,  
>  substr(comments,1,20) comments  
>  from registry$history;

>

> ACTION_TIME ID ACTION VERSION BUNDLE COMMENTS  
>  \---------------------------- -- ------ -------- ------ --------------  
>  23-AUG-10 07.28.02.856762 AM 4 APPLY 10.2.0.4 PSU PSU 10.2.0.4.3  
>  23-AUG-10 07.31.48.001892 AM 1 APPLY 10.2.0.4 PSU PSU 10.2.0.4.4

>

> For Oracle database server 12c R1 and later

>

> SQL> select PATCH_ID,ACTION,STATUS,ACTION_TIME,DESCRIPTION from
registry$sqlpatch;  
>

>

>  
>

>

>  **For Windows** : You get the output as mentioned below  
>

>

> Example output :  
>

>

> ACTION_TIME ID ACTION VERSION BUNDLE COMMENTS  
>  \---------------------------- -- ------ -------- ------ --------------

>

> 30-JUL-12 10.28.44.656000 PM 20 APPLY 11.2.0.2 WINBUN Patch 20

>

> For Oracle database server 12c R1 and later

>

>  
>  SQL> select PATCH_ID,ACTION,STATUS,ACTION_TIME,DESCRIPTION from
registry$sqlpatch;  
>  
>  PATCH_ID ACTION STATUS ACTION_TIME DESCRIPTION  
>  \---------- --------- ------- ------------ -----------------------  
>  
>  19542943 APPLY SUCCESS 30-OCT-14 11.31.36.948000 PM bundle:PSU


---
### ATTACHMENTS
[5a563b0be47c59aae95d23dce91a7309]: media/s_Change_the_Oracle_Release_VersionFifth_Digit_文档_ID_861152-3.1)
[s_Change_the_Oracle_Release_VersionFifth_Digit_文档_ID_861152-3.1)](media/s_Change_the_Oracle_Release_VersionFifth_Digit_文档_ID_861152-3.1))
[d74f4ac5869665cf665a5feb44d0f627]: media/s_Change_the_Oracle_Release_VersionFifth_Digit_文档_ID_861152-4.1)
[s_Change_the_Oracle_Release_VersionFifth_Digit_文档_ID_861152-4.1)](media/s_Change_the_Oracle_Release_VersionFifth_Digit_文档_ID_861152-4.1))
---
### NOTE ATTRIBUTES
>Created Date: 2017-04-21 00:52:51  
>Last Evernote Update Date: 2017-05-05 08:02:12  
>author: YangKwong  
>source: desktop.win  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=501558129658315  
>source-url: &  
>source-url: id=861152.1  
>source-url: &  
>source-url: _afrWindowMode=0  
>source-url: &  
>source-url: _adf.ctrl-state=oob5eg71a_151  
>source-application: evernote.win32  