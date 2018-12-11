# The Priority of NLS Parameters Explained (Where To Define NLS Parameters)
(文档 ID 241047.1)

  

|

|

 **In this Document**  

| |
[Purpose](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=360833296128194&parent=DOCUMENT&sourceId=251044.1&id=241047.1&_afrWindowMode=0&_adf.ctrl-
state=xdpz2dnb9_313#PURPOSE)  
---|---  
|
[Scope](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=360833296128194&parent=DOCUMENT&sourceId=251044.1&id=241047.1&_afrWindowMode=0&_adf.ctrl-
state=xdpz2dnb9_313#SCOPE)  
---|---  
|
[Details](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=360833296128194&parent=DOCUMENT&sourceId=251044.1&id=241047.1&_afrWindowMode=0&_adf.ctrl-
state=xdpz2dnb9_313#BODYTEXT)  
---|---  
|
[Introduction](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=360833296128194&parent=DOCUMENT&sourceId=251044.1&id=241047.1&_afrWindowMode=0&_adf.ctrl-
state=xdpz2dnb9_313#aref_section31)  
---|---  
| [A) The Session Parameters -
NLS_SESSION_PARAMETERS.](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=360833296128194&parent=DOCUMENT&sourceId=251044.1&id=241047.1&_afrWindowMode=0&_adf.ctrl-
state=xdpz2dnb9_313#aref_section32)  
---|---  
| [A1) Using alter session
.](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=360833296128194&parent=DOCUMENT&sourceId=251044.1&id=241047.1&_afrWindowMode=0&_adf.ctrl-
state=xdpz2dnb9_313#aref_section33)  
---|---  
| [A2) Using NLS_LANG on the client
side](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=360833296128194&parent=DOCUMENT&sourceId=251044.1&id=241047.1&_afrWindowMode=0&_adf.ctrl-
state=xdpz2dnb9_313#aref_section34)  
---|---  
| [A2a) NLS_LANG is specified with only the <NLS_Territory>
part.](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=360833296128194&parent=DOCUMENT&sourceId=251044.1&id=241047.1&_afrWindowMode=0&_adf.ctrl-
state=xdpz2dnb9_313#aref_section35)  
---|---  
| [A2b) NLS_LANG is specified with only the <NLS_Language>
part](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=360833296128194&parent=DOCUMENT&sourceId=251044.1&id=241047.1&_afrWindowMode=0&_adf.ctrl-
state=xdpz2dnb9_313#aref_section36)  
---|---  
| [A2c) NLS_LANG is specified with only the <clients
characterset>](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=360833296128194&parent=DOCUMENT&sourceId=251044.1&id=241047.1&_afrWindowMode=0&_adf.ctrl-
state=xdpz2dnb9_313#aref_section37)  
---|---  
| [A2d) Setting other NLS parameters on the client
side](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=360833296128194&parent=DOCUMENT&sourceId=251044.1&id=241047.1&_afrWindowMode=0&_adf.ctrl-
state=xdpz2dnb9_313#aref_section38)  
---|---  
| [A2e) Defaults values for settings in
NLS_SESSION_PARAMETERS:](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=360833296128194&parent=DOCUMENT&sourceId=251044.1&id=241047.1&_afrWindowMode=0&_adf.ctrl-
state=xdpz2dnb9_313#aref_section39)  
---|---  
| [A2f) If NLS_LANG is not
set](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=360833296128194&parent=DOCUMENT&sourceId=251044.1&id=241047.1&_afrWindowMode=0&_adf.ctrl-
state=xdpz2dnb9_313#aref_section310)  
---|---  
| [A3) Other things who are good to
know:](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=360833296128194&parent=DOCUMENT&sourceId=251044.1&id=241047.1&_afrWindowMode=0&_adf.ctrl-
state=xdpz2dnb9_313#aref_section311)  
---|---  
| [B) The Instance Parameters -
NLS_INSTANCE_PARAMETERS.](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=360833296128194&parent=DOCUMENT&sourceId=251044.1&id=241047.1&_afrWindowMode=0&_adf.ctrl-
state=xdpz2dnb9_313#aref_section312)  
---|---  
| [C) The Database Parameters -
NLS_DATABASE_PARAMETERS.](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=360833296128194&parent=DOCUMENT&sourceId=251044.1&id=241047.1&_afrWindowMode=0&_adf.ctrl-
state=xdpz2dnb9_313#aref_section313)  
---|---  
| [D) Other views containing NLS
information:](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=360833296128194&parent=DOCUMENT&sourceId=251044.1&id=241047.1&_afrWindowMode=0&_adf.ctrl-
state=xdpz2dnb9_313#aref_section314)  
---|---  
| [D1)
sys.props$](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=360833296128194&parent=DOCUMENT&sourceId=251044.1&id=241047.1&_afrWindowMode=0&_adf.ctrl-
state=xdpz2dnb9_313#aref_section315)  
---|---  
| [D2)
v$nls_parameters](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=360833296128194&parent=DOCUMENT&sourceId=251044.1&id=241047.1&_afrWindowMode=0&_adf.ctrl-
state=xdpz2dnb9_313#aref_section316)  
---|---  
| [D3) userenv language / sys_context
language](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=360833296128194&parent=DOCUMENT&sourceId=251044.1&id=241047.1&_afrWindowMode=0&_adf.ctrl-
state=xdpz2dnb9_313#aref_section317)  
---|---  
| [D4) userenv
('lang')](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=360833296128194&parent=DOCUMENT&sourceId=251044.1&id=241047.1&_afrWindowMode=0&_adf.ctrl-
state=xdpz2dnb9_313#aref_section318)  
---|---  
| [D5) show parameter
NLS%](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=360833296128194&parent=DOCUMENT&sourceId=251044.1&id=241047.1&_afrWindowMode=0&_adf.ctrl-
state=xdpz2dnb9_313#aref_section319)  
---|---  
| [D6)
v$parameter](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=360833296128194&parent=DOCUMENT&sourceId=251044.1&id=241047.1&_afrWindowMode=0&_adf.ctrl-
state=xdpz2dnb9_313#aref_section320)  
---|---  
| [D7)
v$system_parameter](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=360833296128194&parent=DOCUMENT&sourceId=251044.1&id=241047.1&_afrWindowMode=0&_adf.ctrl-
state=xdpz2dnb9_313#aref_section321)  
---|---  
| [D8)
database_properties](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=360833296128194&parent=DOCUMENT&sourceId=251044.1&id=241047.1&_afrWindowMode=0&_adf.ctrl-
state=xdpz2dnb9_313#aref_section322)  
---|---  
| [E) Other parameters with "NLS" in the
name:](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=360833296128194&parent=DOCUMENT&sourceId=251044.1&id=241047.1&_afrWindowMode=0&_adf.ctrl-
state=xdpz2dnb9_313#aref_section323)  
---|---  
| [F) What are valid values to use for NLS
parameters?](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=360833296128194&parent=DOCUMENT&sourceId=251044.1&id=241047.1&_afrWindowMode=0&_adf.ctrl-
state=xdpz2dnb9_313#aref_section324)  
---|---  
| [G) I'm the dba and have been asked to set a NLS parameter ( NLS_DATE_FORMAT
etc) "on database"
level.](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=360833296128194&parent=DOCUMENT&sourceId=251044.1&id=241047.1&_afrWindowMode=0&_adf.ctrl-
state=xdpz2dnb9_313#aref_section325)  
---|---  
|
[References](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=360833296128194&parent=DOCUMENT&sourceId=251044.1&id=241047.1&_afrWindowMode=0&_adf.ctrl-
state=xdpz2dnb9_313#REF)  
---|---  
  
* * *

## Applies to:

Oracle Database - Enterprise Edition - Version 8.0.3.0 and later  
Oracle Database - Standard Edition - Version 8.0.3.0 and later  
Information in this document applies to any platform.  

## Purpose

This note explains the order in which NLS parameters are taken into account in
the database client/server model using a standard client connection.

## Scope

Entry level DBA  
  

## Details

### Introduction

There are 3 levels at which you can set NLS parameters: Database, Instance and
Session. If a parameter is defined at more than one level then the rules on
which one takes precedence are quite straight forward:  
  
1\. NLS database settings are "overwritten" by NLS instance settings or in
other words, NLS instance settings take precedence over NLS database settings.  
2\. NLS database & NLS instance settings are "overwritten" by NLS session
settings or in other words, NLS session settings take precedence over NLS
instance and NLS database settings.  
  
In the remainder of this note all the different settings are documented in in
detail, assuming no explicit NLS setting is defined in the SQL syntax.

**Any setting explicit used in SQL will always take precedence about all other
settings, for example using "select TO_CHAR(hiredate, 'DD/MON/YYYY',
'NLS_DATE_LANGUAGE = FRENCH') from.." will always use DD/MON/YYYY as
NLS_DATE_FORMAT and FRENCH as NLS_DATE_LANGUAGE _for this select_ , no matter
what the SESSION, INSTANCE or DATABASE settings are.**

The categories A to C shown below indicate the order of precedence with A
being the highest and C the lowest.

For example, if you set NLS_NUMERIC_CHARACTERS in the init.ora (point B) and
in the environment (point A2d), then for a session the value defined in the
environment will take priority because point A2d comes before point B.

Most Sr's logged about this are " I have set the NLS parameter xx (like
NLS_DATE_FORMAT or so) in my init.ora to value zz and this is not used by my
application/session."  
  
Well, like this note explains, this is normal and not a bug . Client
configuration always take precedence on the database/server configuration for
NLS .  
For almost all connection methods (JDBC, ODBC..) and NLS parameters ( ex:
NLS_DATE_FORMAT, NLS_LANGUAGE, NLS_LANGUAGE, NLS_SORT ) the setting in the
"init.ora" (=NLS_INSTANCE_PARAMETERS) or NLS_DATABASE_PARAMETERS is simply
irrelvant.  
  
Note also that the defined NLS settings in the user environment or registry
_on the server_ have  no affect on a client (= different computer system
connecting through the listener).  
Only if the server itself is used as client (you run sqlplus in a telnet
session or start it on the console on the server) the environment or registry
settings of the server will be used since at that moment the "server" also
becomes "client".  
  
Oracle strongly recommends to **always** set the NLS_LANG on the client side
to the correct client OS encoding.  
 **  
Note that in 11.2.0.2 (and higher) the behaviour of "show parameter" or
selecting from v$parameter changed.**  
This is **NOT** a bug but the result of a **FIX**.  
See point D5 and D6 in this note or [NOTE
1368966.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=241047.1&id=1368966.1)
\- NLS settings like NLS_DATE_FORMAT in spfile or init.ora ignored, incorrect
or not as expected on Oracle 11.2.0.2 and higher

### A) The Session Parameters - NLS_SESSION_PARAMETERS.

SQL>select * from NLS_SESSION_PARAMETERS;

These are the settings used for the current sql session.  
It does not matter what the value (for the same parameter) is in
NLS_DATABASE_PARAMETERS or NLS_INSTANCE_PARAMETERS . The value in
NLS_SESSION_PARAMETERS is the one used.  
  
This is session specific or in other words, if you connect from one client
(like sqlplus on the server) and do this select then this does NOT mean these
values will be used for OTHER clients.  
  
These reflect (in this order):

#### A1) Using alter session .

The values of NLS parameters set by "alter session .... "

SQL>alter session set NLS_DATE_FORMAT='DD/MM/YYYY';

Note that an alter session can also issued by:  
* an application connecting, for example for Oracle SQLdeveloper the NLS session settings are specified in the preferences menu: "Tools" - "Preferences" - "database" - "NLS" and Oracle SQLdeveloper will do alter session based on these when connecting.  
* the driver (ODBC , JDBC etc), Oracle Thin JDBC drivers for example issue "alter session" statements when connecting based on the "locale" of the java runtime on the client side.-> [NOTE:115001.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=241047.1&id=115001.1)  
* an after logon trigger(!). [Note 251044.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=241047.1&id=251044.1) How to set a NLS session parameter at database level for all sessions   
* the sqlplus "login.sql" or "glogin.sql" scripts.  
This also means there is no point in checking in sqlplus on a server what the
NLS_SESSION_PARAMETERS are if your application connects using JDBC. This are 2
totally different client situations. You need to use the same client setup and
the same connection method.

Note: Instead of "alter session" one can also use DBMS_SESSION.SET_NLS

#### A2) Using NLS_LANG on the client side

If there are no explicit "alter sessions ..." statements done then
NLS_SESSION_PARAMETERS reflects the setting of the corresponding NLS parameter
derived from the NLS_LANG variable or from explicit defined parameter on the
client side (if NLS_LANG is set).  
  
NLS_LANG consist of: NLS_LANG=<NLS_Language>_<NLS_Territory>.<clients
characterset>  
  
For example: NLS_LANG=DUTCH_BELGIUM.WE8MSWIN1252  
  
For information on how to find the NLS_LANG your sqlplus session is using see
point "4.2 How can I Check the Client's NLS_LANG Setting?" in [Note
158577.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=241047.1&id=158577.1)
. The NLS_LANG used on the SERVER side is not relevant at all for a client.  
On Unix one need to put ' ' around values who use spaces, for example $ export
NLS_LANG='BRAZILIAN PORTUGUESE_BRAZIL.AL32UTF8'

##### A2a) NLS_LANG is specified with only the <NLS_Territory> part.

If NLS_LANG is specified with only the <NLS_Territory> part then AMERICAN is
used as default <NLS_Language>.  
  
So if you set NLS_LANG=_BELGIUM.WE8PC850 then you get this in
NLS_SESSION_PARAMETERS:

PARAMETER VALUE  
\------------------------------ --------------  
NLS_LANGUAGE AMERICAN  
NLS_TERRITORY BELGIUM  
NLS_CURRENCY €  
NLS_ISO_CURRENCY BELGIUM  
....

Note the difference between NLS_LANG=_BELGIUM.WE8PC850 (correct) and
NLS_LANG=BELGIUM.WE8PC850 (incorrect), you need to set the "_" as separator.

##### A2b) NLS_LANG is specified with only the <NLS_Language> part

If NLS_LANG is specified with only the <NLS_Language> part then the
<NLS_Territory> defaults to a setting based on <NLS_Language>.  
  
So if you set NLS_LANG=ITALIAN_.WE8PC850 then you get this in
NLS_SESSION_PARAMETERS:

PARAMETER VALUE  
\------------------------------ --------------  
NLS_LANGUAGE ITALIAN  
NLS_TERRITORY ITALY  
NLS_CURRENCY €  
NLS_ISO_CURRENCY ITALY  
.....

Note the difference between NLS_LANG=ITALIAN_.WE8PC850 (correct) and
NLS_LANG=ITALIAN.WE8PC850 (incorrect), you need to set the "_" as separator.

##### A2c) NLS_LANG is specified with only the <clients characterset>

If NLS_LANG is specified without the <NLS_Language>_<NLS_Territory> part then
the <NLS_Language>_<NLS_Territory> part defaults to AMERICAN_AMERICA.  
  
So if you set NLS_LANG=.WE8PC850 then you get this in NLS_SESSION_PARAMETERS:

PARAMETER VALUE  
\------------------------------ ----------  
NLS_LANGUAGE AMERICAN  
NLS_TERRITORY AMERICA  
NLS_CURRENCY $  
NLS_ISO_CURRENCY AMERICA  
....

Note the difference between NLS_LANG=.WE8PC850 (correct) and NLS_LANG=WE8PC850
(incorrect), you need to set the "." as separator.

##### A2d) Setting other NLS parameters on the client side

If the NLS_LANG parameter is set then parameters like NLS_SORT,
NLS_DATE_FORMAT,... can be set as a "standalone" setting as environment
variable (or registry entry on windows) and will overrule the defaults derived
from NLS_LANG <NLS_Language>_<NLS_Territory> part.  
  
So if you set NLS_LANG=AMERICAN_AMERICA.WE8PC850 and NLS_ISO_CURRENCY=FRANCE
then you get this in NLS_SESSION_PARAMETERS:

PARAMETER VALUE  
\------------------------------ -----------  
NLS_LANGUAGE AMERICAN  
NLS_TERRITORY AMERICA  
NLS_CURRENCY $  
NLS_ISO_CURRENCY FRANCE  
...

* Make sure that you set "NLS_ISO_CURRENCY=FRANCE", NLS_ISO_CURRENCY=<space>FRANCE (note the space) will not give an error but the parameter is just ignored and the default based on NLS_TERRITORY will be used.  
  
* if NLS_LANG is **not set** then any client setting for NLS_SORT, NLS_DATE_FORMAT, etc is IGNORED.

##### A2e) Defaults values for settings in NLS_SESSION_PARAMETERS:

* If NLS_DATE_LANGUAGE and/or NLS_SORT are not set then they are derived from NLS_LANGUAGE .  
  
* If NLS_CURRENCY, NLS_DUAL_CURRENCY, NLS_ISO_CURRENCY, NLS_DATE_FORMAT, NLS_TIMESTAMP_FORMAT, NLS_TIMESTAMP_TZ_FORMAT, NLS_NUMERIC_CHARACTERS are not set then they are derived from NLS_TERRITORY

Some NLS_LANGUAGE and NLS_TERRITORY defaults changed between 9i and 10g, see
[Note
292942.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=241047.1&id=292942.1)
Language and Territory definitions changed in 10g versus 9i and lower  
The easiest way to see the default is simply to connect with sqlplus using a
NLS_LANG set to <NLS_Language>_<NLS_Territory> you want to check and to then
select NLS_SESSION_PARAMETERS

* the NLS_CALENDAR default is always Gregorian and is not derived from a other parameter.

##### A2f) If NLS_LANG is not set

If the NLS_LANG is not set at all, then it defaults to
<NLS_Language>_<NLS_Territory>.US7ASCII and the values for the
<NLS_Language>_<NLS_Territory> part used are the ones found in
NLS_INSTANCE_PARAMETERS. Parameters like NLS_SORT defined as "standalone" on
the client side are ignored.

Oracle does **NOT** recommend to have the **NLS_LANG UNSET** , please always
define at least the proper <clients characterset> part for the NLS_LANG like
shown in point A2c). See [Note
158577.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=241047.1&id=158577.1)
NLS_LANG Explained (How does Client-Server Character Conversion Work?) and
[Note
179133.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=241047.1&id=179133.1)
The correct NLS_LANG in a Windows Environment  
This is **only** possible with "pure oci" clients like sqlplus, with ODBC or
JDBC for example this is not possible.

#### A3) Other things who are good to know:

* If set, client parameters (NLS_SESSION_PARAMETERS) take always precedence above NLS_INSTANCE_PARAMETERS and NLS_DATABASE_PARAMETERS.  
  
* This behaviour can not be disabled on/from the server, so a parameter set on the client always has precedence above an instance or database parameter.  
  
* This is session specific or in other words, if you connect from one client (like sqlplus on the server) and do this select then this does NOT mean these values will be used for OTHER clients.  
  
* The NLS_SESSION_PARAMETERS are NOT visible for other sessions since NLS session parameters are stored in session memory in UGA (User Global Area).   
If you need to trace the used session settings for OTHER sessions then you
have to use a logon trigger to create your own logging table based on
NLS_SESSION_PARAMETERS.  
An example is in point E.2 of [note
338832.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=241047.1&id=338832.1)
How to debug date related problems like (but not limited to) ORA-01843,
ORA-01821, ORA-1801  
  
* The <clients characterset> part of NLS_LANG is *NOT* shown in any system table or view (it is not known in the database) for versions lower then 11.1.0.6. If you require to know the current setting of a client's NLS_LANG then please see section 4.2 (How can I Check the Client's NLS_LANG Setting?) of [Note 158577.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=241047.1&id=158577.1) From 11g onwards you can see the <clients characterset> part of NLS_LANG in the CLIENT_CHARSET column of V$SESSION_CONNECT_INFO. You will see the value "Unknown" if the Oracle client is older than release 11.1 or the connection is through the JDBC thin driver  
  
* NLS_LANG cannot be changed by alter session, NLS_LANGUAGE and NLS_TERRITORY can. However NLS_LANGUAGE and /or NLS_TERRITORY cannot be set as a "standalone" parameters in the enviroment or registry on the client.  
  
* In an Multitenant (PCB/PDB) context the "alter session set container=" does not make a new connection, so the current NLS_SESSION settings, before doing the "alter session set container=" , will be kept.  
  
* On Windows systems the Oracle installer always set the nls_lang <NLS_Language>_<NLS_Territory> part to the locale of the windows system during installation (!).  
You can disable this by copying the cdrom to a disk and edit the
\install\oraparm.ini file and set the NLS_ENABLED=TRUE parameter to
NLS_ENABLED=FALSE.  
With this set to FALSE only US (English) message files will be installed and
(on windows) the NLS_LANG added to the registry will also default to
AMERICAN_AMERICA instead of the <NLS_Language>_<NLS_Territory> who match the
LOCALE of the windows installation.  
  
* On Windows you have two possible options, normally the NLS_LANG is set in the registry, but it can also be set in the environment, however this is not often done and generally not recommended to do so. The value in the environment takes precedence over the value in the registry and is used for ALL Oracle_Homes on the client (!) if defined as a system environment variable. See [Note 179133.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=241047.1&id=179133.1) The correct NLS_LANG in a Windows Environment  
  
* DBMS_SCHEDULER or DBMS_JOB store the SESSION values of the SUBMITTING session for each job. This is visible in the NLS_ENV column of DBA_SCHEDULER_JOBS or DBA_JOBS  
  
* For information on the "date" datatype please see [Note 338832.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=241047.1&id=338832.1) How to debug date related problems like (but not limited to) ORA-01843, ORA-01821, ORA-1801 and [Note 227334.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=241047.1&id=227334.1) Dates & Calendars - Frequently Asked Questions   
  
* For timezone behavior please [Note 340512.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=241047.1&id=340512.1) Timestamps & time zones - Frequently Asked Questions and [Note 412160.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=241047.1&id=412160.1) Updated DST transitions and new Time Zones in Oracle Time Zone File patches.  
  
* In 8i and 9i NLS_COMP *cannot* be set as environment variable (unlike documented in the documentation set). All Oracle8i and Oracle9 versions use NLS_COMP from NLS_INSTANCE_PARAMETERS or from explicit ALTER SESSION. [Bug 2155062](https://support.oracle.com/epmos/faces/BugDisplay?parent=DOCUMENT&sourceId=241047.1&id=2155062) NLS_COMP cannot be set in the client ENVIRONMENT  
  
* From 10g onward you can set NLS_COMP as client variable, NLS_COMP will then also default to BINARY (when NLS_LANG is used - which is recommended) in the session parameters if not set explicitly as client variable and will NOT be derived from a other NLS_PARAMETER or from NLS_INSTANCE_PARAMETERS. If you want to set NLS_COMP to LINGUISTIC for example you need to set it explicit at the client side or use an after logon trigger.

* For more information on using NLS_COMP and NLS_SORT please see [Note 227335.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=241047.1&id=227335.1) Linguistic Sorting - Frequently Asked Questions  
  
* NLS_LENGTH_SEMANTICS *cannot* be set as environment variable in 9i, from 10g onwards it can be. Please note that it needs to be set as UPPERCASE. It is however possible to do a ALTER SESSION. If not defined explicit using alter session or in the environment it will use the NLS_INSTANCE_PARAMETER setting. Note that Oracle recommends to not set NLS_LENGTH_SEMANTICS to CHAR on instance level but use it on session level [Note 144808.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=241047.1&id=144808.1) Examples and limits of BYTE and CHAR semantics usage  
  
* NLS_NCHAR_CONV_EXCP *cannot* be set as environment variable. It is however possible to do a ALTER SESSION.  
  
* NLS_LANGUAGE in the session parameters also declares the language for the error messages, see [Note 985974.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=241047.1&id=985974.1) Changing the Language of RDBMS (Error) Messages   
  
  
* You cannot "set" a NLS parameter in an SQL script, you need to use alter session.  
  
* NLS_TIME_FORMAT and NLS_TIME_TZ_FORMAT, who are visible in the session settings, are currently used for internal purposes only. Do not change, set or define them on the client side.  
  
* The ORA_NLSxx is not seen in the session parameters. There is normally no need to set this parameter . [Note:77442.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=241047.1&id=77442.1) ORA_NLS (ORA_NLS32, ORA_NLS33, ORA_NLS10) Environment Variables explained.  
  
* The ORA_SDTZ parameter is not seen in the session parameters, it is used to set the SESSIONTIMEZONE . [Note 340512.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=241047.1&id=340512.1) Timestamps & time zones - Frequently Asked Questions  
  
* The ORA_TZFILE parameter is not seen in the session parameters, it is used to change between the large and the basic time zone files. In general there is no need to define this. [Note 340512.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=241047.1&id=340512.1) Timestamps & time zones - Frequently Asked Questions  
  
* The NLS_OS_CHARSET characterset is a pure client side setting and introduced in 11.2 to enable conversion of some V$SESSION information to the database characterset. It has no impact on any user data. See [Note 759325.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=241047.1&id=759325.1) Non US7ASCII characters may not be seen correctly in V$Session OSUSER, MACHINE and PROGRAM fields.

### B) The Instance Parameters - NLS_INSTANCE_PARAMETERS.

SQL>select * from NLS_INSTANCE_PARAMETERS;

These are the settings in the init.ora / spfile of the database at the moment
that the database was started

Up to 11.2.0.2 this did not reflect always the current NLS instance parameters
but in same cases session parameters .  
This has been corrected trough [Bug
8722860](https://support.oracle.com/epmos/faces/BugDisplay?parent=DOCUMENT&sourceId=241047.1&id=8722860)
From 11.2.0.2 onwards it reflects the instance NLS settings as it should, for
lower versions check v$system_parameter if needed (see point D7)

You can change them in the init.ora or , when using a spfile, use ALTER
SYSTEM.

SQL> alter system set NLS_LANGUAGE='DUTCH' scope=spfile;

After changing this you need to restart the database.  
  
If the parameter is not explicitly set in the init.ora / spfile then it's
value is NOT derived from a "higher" parameter .

For example NLS_SORT derives a default from NLS_LANGUAGE in
NLS_SESSION_PARAMETERS, this is NOT the case for NLS_INSTANCE_PARAMETERS.

Other things who are good to know:  
  
* NLS_LANG is not a init.ora parameter, NLS_LANGUAGE and NLS_TERRITORY are. So you need to set NLS_LANGUAGE and NLS_TERRITORY separated.  
  
* You cannot define the <clients characterset> or NLS_LANG in the init.ora. The clients characterset is defined by the NLS_LANG on client side (see above).  
  
* You cannot define the database characterset in the init.ora. The database characterset is defined by the "Create Database" command (see point c)).  
  
* These settings take precedence above the NLS_DATABASE_PARAMETERS.  
  
* These values are used for the NLS_SESSION_PARAMETERS if on the client the NLS_LANG is NOT set. Oracle *strongly* recommends that you set the NLS_LANG on the client at least to NLS_LANG=.<clients characterset>  
  
* ALTER SYSTEM SET NLS_LENGTH_SEMANTICS does not change the SESSION parameters (who take precedence) due to [Bug 1488174](https://support.oracle.com/epmos/faces/BugDisplay?parent=DOCUMENT&sourceId=241047.1&id=1488174) until the database is restarted. However it can be set in the init.ora or Spfile -> see [Note 144808.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=241047.1&id=144808.1)  
  
* ALTER SYSTEM SET NLS_NCHAR_CONV_EXCP does not change the SESSION parameters (who take precedence).. workaround: use a init.ora parameter.  
  
* NLS_TIME_FORMAT and NLS_TIME_TZ_FORMAT, are currently used for internal purposes only. We strongly suggest to NOT define them. If they are visible in the NLS_INSTANCE_PARAMETERS then please DO remove them and bounce the database. If set they may cause errors like ORA-1821: date format not recognized, ORA-6512: at "SYS.DBMS_SCHEDULER" when submitting / running DBMS_SCHEDULER jobs.  
  
Examples:

ORA-01821: date format not recognized  
ORA-06512: at "SYS.DBMS_ISCHED", line 150  
ORA-06512: at "SYS.DBMS_SCHEDULER", line 441  
ORA-06512: at "ORACLE_OCM.MGMT_CONFIG", line 106

ORA-31626: job does not exist  
ORA-31637: cannot create job SYS_EXPORT_SCHEMA_01 for user SYS  
ORA-06512: at "SYS.DBMS_SYS_ERROR", line 95  
ORA-06512: at "SYS.KUPV$FT", line 1569  
ORA-39062: error creating master process DM00  
ORA-39107: Master process DM00 violated startup protocol. Master error:  
ORA-01821: date format not recognized

* The NLS_LANGUAGE in the instance parameters also declares the language for the server side error messages in alert.log and in trace files, see [Note 985974.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=241047.1&id=985974.1) Changing the Language of RDBMS (Error) Messages  
  
* Note that Oracle _recommends_ to not set NLS_LENGTH_SEMANTICS to CHAR on instance level but use it on session level [Note 144808.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=241047.1&id=144808.1) Examples and limits of BYTE and CHAR semantics usage

### C) The Database Parameters - NLS_DATABASE_PARAMETERS.

SQL>select * from NLS_DATABASE_PARAMETERS;

This are the NLS setting that where used **_during database creation time_**  
If there were parameters set in the init.ora during database creation you see
them here.  
These are always defaulting to AMERICAN AMERICA if there were no parameters
explicitly set in the init.ora **_during database creation time_** (!).  
  
There is no way to change these after the database creation (except the
NLS_(NCHAR)_CHARACTERSET).  
**_Do NOT update systemtables to change these values!_**  
  
These settings are used to give the database a default if the INSTANCE and
SESSION parameters are not set.  
Since NLS_INSTANCE_PARAMETERS and NLS_SESSION_PARAMETERS take precedence this
is not a problem at all and _**changing them is not needed.**_  
  
Or in other words, if you have an application that requires that a certain NLS
setting need to be set "on database level" and it is seen in
NLS_INSTANCE_PARAMETERS then all is fine even if the value in
NLS_DATABASE_PARAMETERS is different, there is NO need to "see" this also in
NLS_DATABASE_PARAMETERS.  
  
Other things who are good to know:  
  
* These parameters are "overruled" by NLS_INSTANCE_PARAMETERS and NLS_SESSION_PARAMETERS. The only exception are the NLS_CHARACTERSET and NLS_NCHAR_CHARACTERSET settings.  
  
* A real "create database" is needed to set the NLS_DATABASE_PARAMETERS , when using the DBCA and a "seed" database (=template has "includes datafiles" set to YES in page 2 of the DBCA) then the NLS_DATABASE_PARAMETERS will be AMERICAN AMERICA since this is actually a clone operation of a existing database (who is using AMERICAN AMERICA), not a real "create database". Since NLS_INSTANCE_PARAMETERS take precedence this is not a problem at all and simply irrelevant.  
To define the NLS_DATABASE_PARAMETERS using DBCA choose a template that has
"includes datafiles" set to NO in page 2 of the DBCA and in step 9 click on
"all initialization parameters" and then "show advanced parameters" there you
can then set NLS_SORT , NLS_LANGUAGE etc etc for the NLS DATABASE PARAMETERS  
  
* NLS_LANG is not an init.ora parameter, NLS_LANGUAGE and NLS_TERRITORY are. NLS_LANGUAGE and NLS_TERRITORY need to be set separately.  
  
* the <clients characterset> or NLS_LANG is NOT defined in the init.ora , the clients characterset is defined by the NLS_LANG on client side (see above).  
  
* the database characterset is NOT defined in the init.ora. The database (national) characterset (NLS_(NCHAR)_CHARACTERSET) is defined by the "Create Database ..." command.  
  
* The NLS_CHARACTERSET and NLS_NCHAR_CHARACTERSET parameters cannot be overruled by instance or session parameters. They are defined by the value specified in "create database ..." and are not intended to be changed afterwards dynamically. See [Note 225912.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=241047.1&id=225912.1) Changing the Database Character Set ( NLS_CHARACTERSET ) if you want to change the database characterset. **_Do NOT update systemtables like props$ to change the characterset_**.See point D1).  
  
* Setting the NLS_LANG during the creation of the database does not influence the NLS_DATABASE_PARAMETERS or the NLS_(NCHAR)_CHARACTERSET.  
  
* NLS_DATABASE_PARAMETERS are used in evaluation of CHECK constraints if TO_CHAR/TO_DATE without a date format is used in the CHECK condition. Writing CHECK constraints without explicit date formats is a bad habit, you should use explicit formats and this setting becomes irrelevant.

### D) Other views containing NLS information:

#### D1) sys.props$

SQL>select name,value$ from sys.props$ where name like '%NLS%';

This gives the same info as NLS_DATABASE_PARAMETERS. You should use
NLS_DATABASE_PARAMETERS instead of props$. Note the UPPERCASE '%NLS%'.

**There are still dba's out there who try to change the NLS_CHARACTERSET or
NLS_NCHAR_CHARACTERSET by updating props$ . This is NOT supported and WILL
corrupt your database. This is one of the best way's to destroy a complete
dataset. Oracle Support will TRY to help you out of this but Oracle will NOT
warrant that the data can be recovered or recovered data is correct. Most
likely you WILL be asked to do a FULL export and a COMPLETE rebuild of the
database. To change the database characterset please see [Note
225912.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=241047.1&id=225912.1)
Changing the Database Character Set ( NLS_CHARACTERSET ).**

#### D2) v$nls_parameters

SQL>select * from v$nls_parameters;

A view that shows the current **session** parameters and the *DATABASE*
characterset as seen in the NLS_DATABASE_PARAMETERS view.

#### D3) userenv language / sys_context language

SQL>select userenv ('language') from dual;  
SQL>select sys_context('userenv','language') from dual;

Both these select statements give the **session's** <Language>_<territory> and
the *DATABASE* character set. The database character set is not the same as
the character set of the NLS_LANG that you started this connection with! So
don't be fooled, although the output of this query looks like the value of a
NLS_LANG variable - it is NOT.  
  
For more info on SYS_CONTEXT please see [Note
120797.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=241047.1&id=120797.1)

#### D4) userenv ('lang')

SQL>select userenv ('lang') from dual;

This select gives the short code that Oracle uses for the Language defined by
NLS_LANGUAGE setting for this session.  
If NLS_LANGUAGE is set to French then this will return "F",  
if NLS_LANGUAGE is set to English then this will return "GB"  
If NLS_LANGUAGE is set to American then this will return "US", and so on...

#### D5) show parameter NLS%

SQL>show parameter NLS%

  
This SQL*Plus command displays the values of initialization parameters in
effect for the current **session.**  
This will give the same as v$parameter.  
  
For NLS use NLS_SESSION_PARAMETERS instead.  
  
Up to 11.2.0.2 this did not reflect the current NLS session parameters but the
instance parameters.  
This has been corrected trough [Bug
8722860](https://support.oracle.com/epmos/faces/BugDisplay?parent=DOCUMENT&sourceId=241047.1&id=8722860)
From 11.2.0.2 onwards it reflects the session NLS settings as it should.  
[NOTE
1368966.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=241047.1&id=1368966.1)
\- NLS settings like NLS_DATE_FORMAT in spfile or init.ora ignored, incorrect
or not as expected on Oracle 11.2.0.2 and higher

#### D6) v$parameter

SQL>select name,value from v$parameter where name like '%nls%';

V$PARAMETER displays information about the initialization parameters that are
currently in effect for the **session**. Note the LOWERCASE '%nls%'.  
If the value is null it means the parameter is not changed in this session.  
  
For NLS use NLS_SESSION_PARAMETERS instead.  
  
Up to 11.2.0.2 this view was not updated by alter sessions of most NLS
parameters and did not reflect the current NLS session parameters but the
instance parameters.  
This has been corrected trough [Bug
8722860](https://support.oracle.com/epmos/faces/BugDisplay?parent=DOCUMENT&sourceId=241047.1&id=8722860)
From 11.2.0.2 onwards it reflects the session NLS settings as it should.  
[NOTE
1368966.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=241047.1&id=1368966.1)
\- NLS settings like NLS_DATE_FORMAT in spfile or init.ora ignored, incorrect
or not as expected on Oracle 11.2.0.2 and higher

Note: the view was however updated for **session** changes of
NLS_LENGTH_SEMANTICS prior to 11.2.0.2

#### D7) v$system_parameter

SQL>select name,value from v$system_parameter where name like '%nls%';

  
V$SYSTEM_PARAMETER displays information about the initialization parameters
that are currently in effect for **the instance.** Note the LOWERCASE '%nls%'.  
If the value is null it means the parameter is not defined in the pfile or
spfile.  
  

#### D8) database_properties

SQL>SELECT PROPERTY_NAME, PROPERTY_VALUE FROM database_properties;

This gives the same info as NLS_DATABASE_PARAMETERS.  

### E) Other parameters with "NLS" in the name:

* ORA_NCHAR_LITERAL_REPLACE introduced in 10.2, see point 14 in [Note 227330.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=241047.1&id=227330.1)  
  
* NLS_CHAR and NLS_LOCAL are Precompiler variables, they have NO usage/effect unless you are actually writing your own code using the precompilers.  
  
* OI_NLS32 is a parameter used by the Oracle Universal Installer and should NOT be alterd or set.  
  

### F) What are valid values to use for NLS parameters?

That depends on the parameter and is also depending on the used Oracle RDBMS
version  
Most common asked are:  
  
The list of valid values for NLS_LANGUAGE and NLS_DATE_LANGUAGE can be found
issuing

select VALUE from V$NLS_VALID_VALUES where PARAMETER ='LANGUAGE' and
ISDEPRECATED = 'FALSE' order by VALUE  
/

The list of valid values for NLS_TERRITORY can be found issuing

select VALUE from V$NLS_VALID_VALUES where PARAMETER ='TERRITORY' and
ISDEPRECATED = 'FALSE' order by VALUE  
/

The list of valid values for the client characterset (3 the part of NLS_LANG)
and NLS_CHARACTERSET ( AL16UTF16 is not a valid NLS_CHARACTERSET, some cannot
be used on certain platforms like EBCDIC charactersets on ASCII platforms) can
be found issuing

select VALUE from V$NLS_VALID_VALUES where PARAMETER ='CHARACTERSET' and
ISDEPRECATED = 'FALSE' order by VALUE  
/

The list of valid values for NLS_SORT can be found issuing

select VALUE from V$NLS_VALID_VALUES where PARAMETER ='SORT' and ISDEPRECATED
= 'FALSE' order by VALUE  
/

* for NLS_COMP: BINARY, ANSI or LINGUISTIC [Note 227335.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=241047.1&id=227335.1) Linguistic Sorting - Frequently Asked Questions  
* for NLS_LENGTH_SEMANTICS : BYTE or CHAR [Note 144808.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=241047.1&id=144808.1) Examples and limits of BYTE and CHAR semantics usage  
* for NLS_DATE_FORMAT, NLS_TIMESTAMP_FORMAT, NLS_TIMESTAMP_TZ_FORMAT see[ Oracle Database SQL Language Reference 11g Release 2 (11.2) "Datetime Format Models"](http://docs.oracle.com/cd/E11882_01/server.112/e41084/sql_elements004.htm#CDEHIFJA)  
* for NLS_CALENDAR see [Oracle® Database Reference 11g Release 2 (11.2) "NLS_CALENDAR" ](http://docs.oracle.com/cd/E11882_01/server.112/e40402/initparams144.htm#REFRN10116)

For other NLS parameters see [Oracle® Database Globalization Support Guide 11g
Release 2 (11.2), "3 Setting Up a Globalization Support
Environment](http://docs.oracle.com/cd/E11882_01/server.112/e10729/ch3globenv.htm#NLSPG003)["
](http://docs.oracle.com/cd/E11882_01/server.112/e10729/ch3globenv.htm#g1012703)

### G) I'm the dba and have been asked to set a NLS parameter (
NLS_DATE_FORMAT etc) "on database" level.

As documented here above this normally does not make much sense , the actual
values used for an application are defined on the application client side or
should be done by the application itself using "alter session" when
connecting.

It's however quite often an application "requires" to have an certain setting
"on database level", in that case we would simply suggest to set the parameter
in the init.ora/spfile (=seen in NLS_INSTANCE_PARAMETERS).

  
  

## References

  
[NOTE:412160.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=241047.1&id=412160.1)
\- Updated DST Transitions and New Time Zones in Oracle RDBMS and OJVM Time
Zone File Patches  
[NOTE:340512.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=241047.1&id=340512.1)
\- Timestamps & time zones - Frequently Asked Questions  
[NOTE:338832.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=241047.1&id=338832.1)
\- How to Debug Date Related Problems Like (but not Limited to) ORA-01843,
ORA-01821, ORA-1801  
[NOTE:115001.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=241047.1&id=115001.1)
\- NLS_LANG Client Settings and JDBC Drivers  
[NOTE:158577.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=241047.1&id=158577.1)
\- NLS_LANG Explained (How does Client-Server Character Conversion Work?)  
  
[NOTE:292942.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=241047.1&id=292942.1)
\- NLS_LANGUAGE and NLS_TERRITORY Definitions Changed in 10g, 11g and 12c
Versus 9i and lower  
[NOTE:77442.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=241047.1&id=77442.1)
\- ORA_NLS (ORA_NLS32, ORA_NLS33, ORA_NLS10) Environment Variables explained.  
[NOTE:1368966.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=241047.1&id=1368966.1)
\- NLS settings like NLS_DATE_FORMAT in spfile or init.ora ignored, incorrect
or not as expected on Oracle 11.2.0.2 and higher  
[NOTE:759325.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=241047.1&id=759325.1)
\- Non US7ASCII characters may not be seen correctly in V$Session OSUSER,
MACHINE and PROGRAM fields.  
[NOTE:229786.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=241047.1&id=229786.1)
\- NLS_LANG and webservers explained.  
[NOTE:251044.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=241047.1&id=251044.1)
\- How To Set a NLS Session Parameter At Database Or Schema Level For All
Connections?  
[BUG:2155062](https://support.oracle.com/epmos/faces/BugDisplay?parent=DOCUMENT&sourceId=241047.1&id=2155062)
\- NLS_COMP CANNOT BE SET AS ENVIRONMENT VARIABLE  
[NOTE:132090.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=241047.1&id=132090.1)
\- Changing the Language of RDBMS Error Messages on Windows  
[NOTE:120797.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=241047.1&id=120797.1)
\- How to Determine Client IP-address,Language & Territory and Username for
Current Session  
[NOTE:227334.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=241047.1&id=227334.1)
\- Dates & Calendars - Frequently Asked Questions  
[NOTE:144808.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=241047.1&id=144808.1)
\- Examples and limits of BYTE and CHAR semantics usage (NLS_LENGTH_SEMANTICS)  
[NOTE:985974.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=241047.1&id=985974.1)
\- Changing the Language of RDBMS (Error) Messages  
[NOTE:225912.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=241047.1&id=225912.1)
\- Changing Or Choosing the Database Character Set ( NLS_CHARACTERSET )  
[NOTE:227330.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=241047.1&id=227330.1)
\- Character Sets & Conversion - Frequently Asked Questions  
[NOTE:179133.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=241047.1&id=179133.1)
\- The Correct NLS_LANG in a Microsoft Windows Environment  
  
  
  


---
### NOTE ATTRIBUTES
>Created Date: 2017-12-27 09:03:23  
>Last Evernote Update Date: 2018-10-01 15:44:50  
>author: YangKwong  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=360833296128194  
>source-url: &  
>source-url: parent=DOCUMENT  
>source-url: &  
>source-url: sourceId=251044.1  
>source-url: &  
>source-url: id=241047.1  
>source-url: &  
>source-url: _afrWindowMode=0  
>source-url: &  
>source-url: _adf.ctrl-state=xdpz2dnb9_313  