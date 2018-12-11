# ow To Set a NLS Session Parameter At Database Or Schema Level For All
Connections? (文档 ID 251044.1)

  

|

|

 **In this Document**  

| |
[Purpose](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=360049641145956&id=251044.1&displayIndex=3&_afrWindowMode=0&_adf.ctrl-
state=xdpz2dnb9_141#PURPOSE)  
---|---  
|
[Scope](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=360049641145956&id=251044.1&displayIndex=3&_afrWindowMode=0&_adf.ctrl-
state=xdpz2dnb9_141#SCOPE)  
---|---  
|
[Details](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=360049641145956&id=251044.1&displayIndex=3&_afrWindowMode=0&_adf.ctrl-
state=xdpz2dnb9_141#BODYTEXT)  
---|---  
| [Why to set a NLS session parameter at Database or Schema level for all
connections?](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=360049641145956&id=251044.1&displayIndex=3&_afrWindowMode=0&_adf.ctrl-
state=xdpz2dnb9_141#aref_section31)  
---|---  
| [How to set a NLS session parameter at database level for all connections
?](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=360049641145956&id=251044.1&displayIndex=3&_afrWindowMode=0&_adf.ctrl-
state=xdpz2dnb9_141#aref_section32)  
---|---  
| [How to set a NLS session parameter at schema level for all connections
?](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=360049641145956&id=251044.1&displayIndex=3&_afrWindowMode=0&_adf.ctrl-
state=xdpz2dnb9_141#aref_section33)  
---|---  
| [What NLS parameters can be set using logon
triggers?](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=360049641145956&id=251044.1&displayIndex=3&_afrWindowMode=0&_adf.ctrl-
state=xdpz2dnb9_141#aref_section34)  
---|---  
| [How to see if there are logon
triggers?](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=360049641145956&id=251044.1&displayIndex=3&_afrWindowMode=0&_adf.ctrl-
state=xdpz2dnb9_141#aref_section35)  
---|---  
|
[References](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=360049641145956&id=251044.1&displayIndex=3&_afrWindowMode=0&_adf.ctrl-
state=xdpz2dnb9_141#REF)  
---|---  
  
* * *

## Applies to:

Oracle Database - Enterprise Edition - Version 8.0.3.0 to 11.2.0.3 [Release
8.0.3 to 11.2]  
Oracle Database - Enterprise Edition - Version 11.2.0.4 to 11.2.0.4 [Release
11.2]  
Information in this document applies to any platform.  

## Purpose

How to define some NLS session parameters for all clients, regardless of the
used NLS_LANG (or other NLS parameter) setting on the client side

## Scope

Anyone who want to control NLS settings from the server side.

## Details

### Why to set a NLS session parameter at Database or Schema level for all
connections?

The client side NLS setting will override the instance NLS settings like
documented in [Note
241047.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=251044.1&id=241047.1)
The Priority of NLS Parameters Explained.  
  
So you have no "server side" control on the used NLS session settings as they
are derived from the client side.  
  
However, if you like to overwrite some NLS session parameters for all clients,
regardless of the used NLS_LANG (or other NLS parameter) setting on the client
side then you can do that, for most environments, in the way described in this
note.  

Please note that:  
  
* Oracle recommends you to define always the (correct) NLS_LANG.  
The <characterset> part of the NLS_LANG is a (very important) client only
parameter and cannot be set or defined from server side for a session.  
Why this is so important is documented in [Note
158577.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=251044.1&id=158577.1)
and [note
179133.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=251044.1&id=179133.1)  
  
* This is *not* working for some JDBC drivers , see [Note 115001.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=251044.1&id=115001.1) NLS_LANG Client Settings and JDBC Drivers  
And may also not work for other 3the party connection methods,if the connector
issues from the driver itself alter sessions after the logon procedure of
Oracle is done then they will override the trigger.  
  
* When using a PL/SQL package procedure called by the logon trigger and this has any unhandled exceptions or raises any exceptions, then the logon trigger fails. When the logon trigger fails, the logon fails, that is, the user is denied permission to log in to the database  
  
* We do NOT recommend to have several "after logon" triggers, for setting NLS parameters seen the execution order may differ. See [Note 121196.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=251044.1&id=121196.1) Fire Sequence of Database Triggers

### How to set a NLS session parameter at database level for all connections ?

Create an event trigger like this:  
(Example for the NLS_TIMESTAMP_TZ_FORMAT parameter)

CREATE OR REPLACE TRIGGER sys.global_nls_session_settings AFTER LOGON ON
DATABASE  
BEGIN  
execute immediate 'alter session set NLS_TIMESTAMP_TZ_FORMAT =''DD/MM/YYYY
HH24:MI:SS TZR TZD''';  
END;  
/

### How to set a NLS session parameter at schema level for all connections ?

You can also create a logon trigger for one schema:  
(Example for the NLS_DATE_FORMAT and NLS_NUMERIC_CHARACTERS parameter for the
scott schema)  

CREATE OR REPLACE TRIGGER sys.schema_nls_session_settings AFTER LOGON ON
SCOTT.SCHEMA  
BEGIN  
execute immediate 'alter session set NLS_DATE_FORMAT=''DD/MM/YYYY
HH24:MI:SS''';  
execute immediate 'alter session set NLS_NUMERIC_CHARACTERS=''.,''';  
END;  
/

### What NLS parameters can be set using logon triggers?

The parameters which can be set like this, are all the NLS parameters you can
do an alter session for:

8i and up:  
  
NLS_CALENDAR  
NLS_COMP  
NLS_CREDIT  
NLS_CURRENCY  
NLS_DATE_FORMAT  
NLS_DATE_LANGUAGE  
NLS_DEBIT  
NLS_ISO_CURRENCY  
NLS_LANGUAGE  
NLS_LIST_SEPARATOR  
NLS_MONETARY_CHARACTERS  
NLS_NUMERIC_CHARACTERS  
NLS_SORT  
NLS_TERRITORY  
NLS_DUAL_CURRENCY  
NLS_TIMESTAMP_FORMAT  
NLS_TIMESTAMP_TZ_FORMAT  
  
new in 9i/10g:  
NLS_LENGTH_SEMANTICS  
NLS_NCHAR_CONV_EXCP

note: NLS_TIME_FORMAT and NLS_TIME_TZ_FORMAT are used internally only and
should NOT be set or altered  
  
**Again, the client character set CANNOT be set or defined this way.**  

### How to see if there are logon triggers?

This select gives you all defined after logon triggers:

conn / as sysdba  
select OWNER, TRIGGER_NAME, TRIGGER_BODY from DBA_TRIGGERS where  
trim(TRIGGERING_EVENT) = 'LOGON'  
/  
select OWNER, TRIGGER_NAME, TRIGGER_BODY from DBA_TRIGGERS where  
upper(TRIGGER_NAME) = 'LOGON_PROC'  
/

  

## References

[NOTE:115001.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=251044.1&id=115001.1)
\- NLS_LANG Client Settings and JDBC Drivers  
[NOTE:241047.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=251044.1&id=241047.1)
\- The Priority of NLS Parameters Explained (Where To Define NLS Parameters)  
  
  
  


---
### NOTE ATTRIBUTES
>Created Date: 2017-12-27 08:59:48  
>Last Evernote Update Date: 2018-10-01 15:59:04  
>author: YangKwong  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=360049641145956  
>source-url: &  
>source-url: id=251044.1  
>source-url: &  
>source-url: displayIndex=3  
>source-url: &  
>source-url: _afrWindowMode=0  
>source-url: &  
>source-url: _adf.ctrl-state=xdpz2dnb9_141  