# How to use two sqlnet.ora files for two different Databases but in one Home?
(文档 ID 2331259.1)

  

|

|

 **In this Document**  

| |
[Goal](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=361251870734656&id=2331259.1&displayIndex=11&_afrWindowMode=0&_adf.ctrl-
state=mzlygqug5_161#GOAL)  
---|---  
|
[Solution](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=361251870734656&id=2331259.1&displayIndex=11&_afrWindowMode=0&_adf.ctrl-
state=mzlygqug5_161#FIX)  
---|---  
|
[References](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=361251870734656&id=2331259.1&displayIndex=11&_afrWindowMode=0&_adf.ctrl-
state=mzlygqug5_161#REF)  
---|---  
  
* * *

  

## Applies to:

Oracle Net Services - Version 8.1.7.4 and later  
Information in this document applies to any platform.  

## Goal

You may have a requirement to use a different sqlnet.ora file parameter, for a
second Database within a single ORACLE_HOME.  
For example, the current sqlnet.ora may have the parameter
SQLNET.ALLOWED_LOGON_VERSION_SERVER = 11.  
However, on one database we may need to use
SQLNET.ALLOWED_LOGON_VERSION_SERVER = 8 (older application authentication).  
  
So is it possible to use the value "8" but only for one database, not for all
the databases in the Oracle Home ?  
  

## Solution

Yes, this can be done.  
  
If you do have these Databases all on the one machine, then do the following:  
  
1\. Create (or use) a sqlnet.ora file for this one special Database (call it
Database "S") and include your Authentication setting that is different.  
  
2\. Place all the TNS files into a DIFFERENT location than the existing files
but under the Oracle Home (best to maintain under the same home for control).  
That means the following files will be copied over to the new location:  
sqlnet.ora  
listener.ora  
tnsnames.ora  
  
3\. Now for this ONE Database "S" only, you will need to add a new environment
variable (or edit the one that exists if you already use this:  
$TNS_ADMIN [value]  
  
* This value will be the DIFFERENT location of the copied TNS files, so for example:  
u01/oracle/12.2.0.1/network/special  
  
4\. Now you start both the Listener and Database "S" with this newly created /
edited $TNS_ADMIN environment variable.  
What this environment variable does, is allows the processes starting (and
running) like the Listener, to find it's listener.ora file settings in this
new location as well as the Listener and Database will find the special
sqlnet.ora file settings.  
In fact, you can do this for any Database or Listener which needs to have
specific settings which are not shared.  
  
5\. Do not use this different $TNS_ADMIN setting for the other Databases and
they will continue to use their own files (basically, be unaffected).  
  
  
Reference -->  
Setting TNS_ADMIN Environment Variable (Doc ID 111942.1)  
  

## References

[NOTE:111942.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=2331259.1&id=111942.1)
\- Setting TNS_ADMIN Environment Variable  
  
  
  



---
### TAGS
{sqlnet.ora}

---
### NOTE ATTRIBUTES
>Created Date: 2018-01-03 09:44:22  
>Last Evernote Update Date: 2018-10-01 15:59:04  
>author: YangKwong  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=361251870734656  
>source-url: &  
>source-url: id=2331259.1  
>source-url: &  
>source-url: displayIndex=11  
>source-url: &  
>source-url: _afrWindowMode=0  
>source-url: &  
>source-url: _adf.ctrl-state=mzlygqug5_161  