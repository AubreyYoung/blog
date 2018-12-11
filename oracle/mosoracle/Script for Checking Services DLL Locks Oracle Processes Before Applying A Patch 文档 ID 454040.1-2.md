# Script for Checking Services, DLL Locks, Oracle Processes Before Applying A
Patch (文档 ID 454040.1)

  

|

|

**In this Document**  
[Purpose](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=171714217902600&id=454040.1&_adf.ctrl-
state=bdsj1p3d3_72#PURPOSE)  
[Software
Requirements/Prerequisites](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=171714217902600&id=454040.1&_adf.ctrl-
state=bdsj1p3d3_72#SWREQS)  
[Configuring the
Script](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=171714217902600&id=454040.1&_adf.ctrl-
state=bdsj1p3d3_72#CONFIG)  
[Running the
Script](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=171714217902600&id=454040.1&_adf.ctrl-
state=bdsj1p3d3_72#RUNSTEPS)  
[_Caution_](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=171714217902600&id=454040.1&_adf.ctrl-
state=bdsj1p3d3_72#ADDINFO)  
[Script](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=171714217902600&id=454040.1&_adf.ctrl-
state=bdsj1p3d3_72#CODE)  
[Script
Output](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=171714217902600&id=454040.1&_adf.ctrl-
state=bdsj1p3d3_72#OUTPUT)  
[References](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=171714217902600&id=454040.1&_adf.ctrl-
state=bdsj1p3d3_72#REF)  

* * *

## Applies to:

Oracle Server - Enterprise Edition - Version: 9.2.0 to 10.2.0  
Oracle Server - Standard Edition - Version: 9.2.0 to 10.2.0  
Microsoft Windows XP  
Microsoft Windows Server 2003  
  

## Purpose

This script, prepatch.bat, is used to check the following before applying a
patch:  
1) Check if any services are running from the oracle Home.  
2) Check if any DLL's in the Oracle Home are locked by any process  
  
This script also checks for Oracle processes running from the oracle home.  
This script also checks the value of the inventory pointer.  
This script also checks for services that may also lock the DLL's)  
1) Internet Information Server (IIS) Admin Service  
2) Network Associates service (Network Associates McShied)  
3) McAfee service (McAfee Framework Service)  
4) Symantec service  
This script can also be used to find the DLL lock if a patch apply fails
"Couldn't copy ../../*.dll" errors during patching.  
This script can be also used to check if any particular DLL is locked.  
This script can be also used to check the processor information.  
This script can be also used to check for Montecito Processors

## Software Requirements/Prerequisites

This script can be invoked from the command prompt in Windows.  

## Configuring the Script

The name of the batch file is "prepatch.bat"  
You can download and keep the script in any location.  

## Running the Script

When executing, the script promps the following :

1) ORACLE_SID (Specifies name of database instance on host computer. The value
of this parameter is the SID for the instance). ORACLE_SID should be set in
upper case.  
**Enter The ORACLE_SID [ ] :  
**  
NOTE: The value of ORACLE_SID will be taken from the Environment by default.  
  

2) ORACLE_HOME (Specifies Oracle home directory in which Oracle products are
installed)  
**Enter The ORACLE_HOME [ ] :  
  
** NOTE: The value of ORACLE_HOME will be taken from the Environment by
default.

3) ORACLE_HOME_NAME (Specifies home name of Oracle home directory in which
Oracle products are installed)  
**Enter The ORACLE_HOME_NAME [ ] :  
  
** The ORACLE_HOME_NAME can be found from the file  
"C:\Program Files\Oracle\Inventory\ContentsXML\inventory.xml ( by default)  
For example the entry will be :  
<HOME NAME=" **OraDb10g_home1** " LOC="D:\10GR2\db_1" TYPE="O" IDX="1" />  
  
Here ORACLE_HOME_NAME will be **OraDb10g_home1  
  
** NOTE : The value of ORACLE_HOME_NAME will be taken from the Environment by
default  

## _Caution_

_This script is provided for educational purposes only and not supported by
Oracle Support Services. It has been tested internally, however, and works as
documented. We do not guarantee that it will work for you, so be sure to test
it in your environment before relying on it._

 _Proofread this script before using it! Due to the differences in the way
text editors, e-mail packages and operating systems handle text formatting
(spaces, tabs and carriage returns), this script may not be in an executable
state when you first receive it. Check over the script to ensure that errors
of this type are corrected._

## Script

The script can be downloaded from
[here](https://support.oracle.com/epmos/main/downloadattachmentprocessor?parent=DOCUMENT&sourceId=454040.1&attachid=454040.1:PREPATCH&clickstream=yes).  
The menu displays the following options :  
1) CHECK THE WINDOWS INVENTORY POINTER LOCATION  
2) CHECK THE ORACLE SERVICES  
3) CHECK IF ANY DLLS IN THE ORACLE_HOME IS LOCKED  
4) LIST ALL THE ORACLE PROCESS  
5) CHECK IF A PARTICULAR DLL IS LOCKED  
6) CHECK THE PROCESSOR INFROMATION  
7) CHECK FOR MONTECITO PROCESSOR  
8) EXIT  
  
If option 1 is selected :  

`This displays the Windows inventory pointer. The inventory pointer is the
registry key "inst_loc" in "HKEY_LOCAL_MACHINE\SOFTWARE\ORACLE". The value of
this key will be the location of the Central inventory (oraInventory)  
Example :  
`

THE VALUE OF INST_LOC IS :  
C:\Program Files\Oracle\Inventory

  

  
If option 2 is selected :  

`This checks if any services are running for the Oracle Home.  
If any services are running in the Oracle Home, the name of the service is
displayed.  
Example :  
`

THE FOLLOWING SERVICES ARE RUNNING.  
==========================  
Oracle Services  
\---------------  
SERVICE_NAME: OracleServiceORCL102  
DISPLAY_NAME: OracleServiceORCL102

  
  
This option also checks for the following services, which may also lock the
DLL's  
1) Internet Information Server (IIS) Admin Service  
2) Network Associates service (Network Associates McShied)  
3) McAfee service (McAfee Framework Service)  
4) Symantec service  
  
Example :  
  

Symantec  
\--------  
DISPLAY_NAME: Symantec Event Manager  
DISPLAY_NAME: Symantec Settings Manager  
DISPLAY_NAME: Symantec AntiVirus Definition Watcher

  

  
If option 3 is selected :  

`This checks if any DLL's in the Oracle Home are locked by any process.  
If the DLL's are locked, then the name and id of the process is displayed.  
Example :  
`

CHECKING FOR DLL LOCKS  
\---------------------------------------  
Image Name PID Modules  
========= === =======  
emagent.exe 384 orageneric10.dll  

  
If the DLL's are not locked, then the following message is displayed for each
DLLs in the ORACLE_HOME/bin  
  

INFO: No tasks running with the specified criteria.  

  
This checking may take some time to complete as the checking is done on each
".dll" file in the ORACLE_HOME/bin  
  
You can use the following command to kill the process which is locking the
Dll.  

> taskkill /PID <Process_Id>  
OR  
> taskkill /F /PID <Process_Id> (This forcefully terminates the process)  

  
 **Contact your System Administrator before killing any process because this
may cause unexpected results or may reboot the system as well**  
  

  
  
If option 4 is selected :  

`This option checks for Oracle processes running on the server.  
Oracle Process  
---------------   
  
`

Image Name PID Session Name Session# MemUsage  
========== === =========== ======= =========  
oracle.exe 1752 Console 0 613,976 K

  

  
If option 5 is selected :

`This option will check if any particular DLL file is locked. DLL can be
Oracle DLL or System DLL.  
Example : (The following shows the processes using the DLL, kernel32.dll and
their process IDs)  
  
Image Name PID Modules  
========= ==== =========  
csrss.exe 916 KERNEL32.dll  
winlogon.exe 940 kernel32.dll  
services.exe 984 kernel32.dll  
lsass.exe 996 kernel32.dll  
svchost.exe 1156 kernel32.dll  
svchost.exe 1240 kernel32.dll  
svchost.exe 1360 kernel32.dll  
svchost.exe 1408 kernel32.dll  
svchost.exe 1556 kernel32.dll  
ccEvtMgr.exe 1732 kernel32.dll  
spoolsv.exe 1848 kernel32.dll  
cvpnd.exe 1972 kernel32.dll  
.  
.  
`

If option 6 is selected :

`The information regarding the Processors are displayed.  
  
`

NUMBER_OF_PROCESSORS=2  
PROCESSOR_ARCHITECTURE=x86  
PROCESSOR_IDENTIFIER=x86 Family 15 Model 6 Stepping 4, GenuineIntel  
PROCESSOR_LEVEL=15  
PROCESSOR_REVISION=0604

  
If option 7 is selected :  

`This option will check if Montecito Processor is installed or not  
  
`

If Montecito Processor is installed then the following output will be
displayed.  
**This Server Has Intel Montecito Processors Installed**

  
  

If Montecito Processor not is installed then the following output will be
displayed.  
**This Server Has No Intel Montecito Processors Installed**  

  
If option 8 is selected :

`This will exit from the script. By default the option is 8.`

  

## Script Output

**For option 1:**  
Example :

`THE VALUE OF INST_LOC IS :  
C:\Program Files\Oracle\Inventory  
`

**  
For option 2:**  
Example

`THE FOLLOWING SERVICES ARE RUNNING.  
==========================  
Oracle Services  
---------------   
SERVICE_NAME: OracleServiceORCL102  
DISPLAY_NAME: OracleServiceORCL102`

**For option 3:**  
Example :  

` 1) If the DLL file "orageneric10.dll" is locked  
Image Name PID Modules  
========= === =======  
emagent.exe 384 orageneric10.dll `

` 2) If the Dlls are not locked  
INFO: No tasks running with the specified criteria.`

**For option 4:  
** Example :  

`Oracle Process  
---------------   
Image Name PID Session Name Session# MemUsage  
========== === =========== ======= =========  
oracle.exe 1752 Console 0 613,976 K  
`

**For option 5:  
** Example :

`Image Name PID Modules  
========= ==== =========  
csrss.exe 916 KERNEL32.dll  
winlogon.exe 940 kernel32.dll  
services.exe 984 kernel32.dll  
lsass.exe 996 kernel32.dll  
svchost.exe 1156 kernel32.dll  
svchost.exe 1240 kernel32.dll  
svchost.exe 1360 kernel32.dll  
svchost.exe 1408 kernel32.dll  
svchost.exe 1556 kernel32.dll  
ccEvtMgr.exe 1732 kernel32.dll  
spoolsv.exe 1848 kernel32.dll  
cvpnd.exe 1972 kernel32.dll  
.  
.`

  
**For option 6 :**  
Example :  

`NUMBER_OF_PROCESSORS=2  
PROCESSOR_ARCHITECTURE=x86  
PROCESSOR_IDENTIFIER=x86 Family 15 Model 6 Stepping 4, GenuineInte  
PROCESSOR_LEVEL=15  
PROCESSOR_REVISION=0604`

**For option 7 :  
** Example :

`If Montecito Processor is installed then the following output will be
displayed.  
**This Server Has Intel Montecito Processors Installed  
**  
If Montecito Processor not is installed then the following output will be
displayed.  
**This Server Has No Intel Montecito Processors Installed  
**`

## References

[NOTE:453014.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=454040.1&id=453014.1)
\- Script For Checking The Environment Before Opatch Operations  
[NOTE:443813.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=454040.1&id=443813.1)
\- Check List For Oracle On Windows.  

* * *

  
  
  
---  
  
  



---
### TAGS
{upgrade}

---
### NOTE ATTRIBUTES
>Created Date: 2017-06-28 08:36:50  
>Last Evernote Update Date: 2018-10-01 15:59:05  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=171714217902600  
>source-url: &  
>source-url: id=454040.1  
>source-url: &  
>source-url: _adf.ctrl-state=bdsj1p3d3_72  