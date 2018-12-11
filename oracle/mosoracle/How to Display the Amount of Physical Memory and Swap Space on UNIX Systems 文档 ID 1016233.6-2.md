# How to Display the Amount of Physical Memory and Swap Space on UNIX Systems
(文档 ID 1016233.6)

|

|

|  | |  
|

#

|  
|  
  
---|---|---|---  
  
  
|

提供反馈...

|

![noteattachment1][5a563b0be47c59aae95d23dce91a7309]  
  
---|---  
|  ![noteattachment2][5a563b0be47c59aae95d23dce91a7309]|  
|  ![noteattachment2][5a563b0be47c59aae95d23dce91a7309]  
---|---|---  
  
  
  
![noteattachment4][5a563b0be47c59aae95d23dce91a7309]

|

![noteattachment5][5a563b0be47c59aae95d23dce91a7309]

|  
  
---  
  
[![单击此项可添加到收藏夹](https://support.oracle.com/epmos/common/images/favorites_qualifier_notsel.png)](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=359060114205632&parent=DOCUMENT&sourceId=224176.1&id=1016233.6&_afrWindowMode=0&_adf.ctrl-
state=eo5vegt72_714# "单击此项可添加到收藏夹")|
![noteattachment6][5a563b0be47c59aae95d23dce91a7309]| How to Display the
Amount of Physical Memory and Swap Space on UNIX Systems (文档 ID 1016233.6)| [
![noteattachment7][d74f4ac5869665cf665a5feb44d0f627]转到底部](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=359060114205632&parent=DOCUMENT&sourceId=224176.1&id=1016233.6&_afrWindowMode=0&_adf.ctrl-
state=eo5vegt72_714# "转到底部")|
![noteattachment8][5a563b0be47c59aae95d23dce91a7309]  
---|---|---|---|---  
  
* * *

![noteattachment5][5a563b0be47c59aae95d23dce91a7309]

    
    
    PURPOSE
    =====================================================================
    This document outlines the commands to issue on various UNIX platforms 
    to check the amount of physical memory and swap space on the system.
     
    
    SCOPE & APPLICATION
    =====================================================================
    For DBAs and system administrators tasked with correcting memory or swap
    related issues in an Oracle UNIX environment.
    
    
    How Much Swap Space Should Be Configured?
    ======================================================================
    Unless otherwise specified, the most sensible rule of thumb is to have 
    enough swap allocated to equal 2-3 times your amount of physical memory.
    If you have more than 1Gig of memory, this rule can be reduced to swap 
    equaling 1.5 times the amount of physical memory.
    
    Considering the relatively inexpensive prices of physical storage versus
    physical memory, there really isn't any justification for not having 
    adequate swap space configured on a UNIX system.
    
    
    OS Specific Commands:
    ======================================================================
    AIX:
    /usr/sbin/lsattr -E -l sys0 -a realmem
    /usr/sbin/lsps -s
    
    HP-UX:
    grep Physical /var/adm/syslog/syslog.log
    /usr/sbin/swapinfo -t
    
    Linux:
    cat /proc/meminfo | grep MemTotal
    /sbin/swapon -s
    
    Solaris:
    /usr/sbin/prtconf | grep "Memory size"
    /usr/sbin/swap -s
    
    Tru64: 
    vmstat -P| grep -i "Total Physical Memory ="
    /sbin/swapon -s  
  
---


---
### ATTACHMENTS
[5a563b0be47c59aae95d23dce91a7309]: media/How_to_Display_the_Amount_of_Physical_Memory_and_Swap_Space_on_UNIX_Systems_文档_ID_1016233-3.6)
[How_to_Display_the_Amount_of_Physical_Memory_and_Swap_Space_on_UNIX_Systems_文档_ID_1016233-3.6)](media/How_to_Display_the_Amount_of_Physical_Memory_and_Swap_Space_on_UNIX_Systems_文档_ID_1016233-3.6))
[d74f4ac5869665cf665a5feb44d0f627]: media/How_to_Display_the_Amount_of_Physical_Memory_and_Swap_Space_on_UNIX_Systems_文档_ID_1016233-4.6)
[How_to_Display_the_Amount_of_Physical_Memory_and_Swap_Space_on_UNIX_Systems_文档_ID_1016233-4.6)](media/How_to_Display_the_Amount_of_Physical_Memory_and_Swap_Space_on_UNIX_Systems_文档_ID_1016233-4.6))

---
### TAGS
{AIX}  {HP-UX}

---
### NOTE ATTRIBUTES
>Created Date: 2017-04-26 08:22:23  
>Last Evernote Update Date: 2017-05-31 08:35:18  
>author: YangKwong  
>source: desktop.win  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=359060114205632  
>source-url: &  
>source-url: parent=DOCUMENT  
>source-url: &  
>source-url: sourceId=224176.1  
>source-url: &  
>source-url: id=1016233.6  
>source-url: &  
>source-url: _afrWindowMode=0  
>source-url: &  
>source-url: _adf.ctrl-state=eo5vegt72_714  
>source-application: evernote.win32  