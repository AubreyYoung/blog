# How to Configure DG4MSQL (Oracle Database Gateway for MS SQL Server) 64bit
Unix OS (Linux, Solaris, AIX,HP-UX) post install (文档 ID 562509.1)

|

|

**In this Document**  

| |
[Goal](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=324647766660081&id=562509.1&displayIndex=2&_afrWindowMode=0&_adf.ctrl-
state=c5d94p5sg_126#GOAL)  
---|---  
|
[Solution](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=324647766660081&id=562509.1&displayIndex=2&_afrWindowMode=0&_adf.ctrl-
state=c5d94p5sg_126#FIX)  
---|---  
| [How to Setup DG4MSQL (Oracle Database Gateway for MS SQL Server) on 64bit
Unix operating systems like Sparc Solaris, AIX, HP-UX RISC, HP-UX Itanium and
Linux
x86-64bit](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=324647766660081&id=562509.1&displayIndex=2&_afrWindowMode=0&_adf.ctrl-
state=c5d94p5sg_126#aref_section21)  
---|---  
|
[References](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=324647766660081&id=562509.1&displayIndex=2&_afrWindowMode=0&_adf.ctrl-
state=c5d94p5sg_126#REF)  
---|---  
  
* * *

## Applies to:

Oracle Database Gateway for SQL Server - Version 11.1.0.6 to 12.1.0.2 [Release
11.1 to 12.1]  
Oracle Database - Enterprise Edition - Version 12.1.0.2 to 12.1.0.2 [Release
12.1]  
Oracle Solaris on SPARC (64-bit)  
HP-UX Itanium  
Linux x86-64  
IBM AIX on POWER Systems (64-bit)  
HP-UX PA-RISC (64-bit)  
Oracle Transparent Gateway for Microsoft SQL Server - Version: 11.1.0.6 to
12.1.0.1  
  
  

## Goal

Starting with 11g Oracle now provides a Database Gateway for MS SQL Server for
64bit Unix operating systems.  
  
The gateway is certified with Oracle database release 10.1.0.5, 10.2.0.3 after
applying the gateway compatibility patch bug <> or you can directly use it
with Oracle RDBMS 10.2.0.4, 10.2.0.5, 11.1 and 11.2.

  
  
It might work with 9.2.0.8 after applying patch bug <> but there's no
guarantee as the 11.2 gateway was never officially certified with 9.2.0.8
Oracle database release.

## Solution

### How to Setup DG4MSQL (Oracle Database Gateway for MS SQL Server) on 64bit
Unix operating systems like Sparc Solaris, AIX, HP-UX RISC, HP-UX Itanium and
Linux x86-64bit

SIDE NOTE: HP-UX RISC DG4MSQL is 32bit and instead of the LD_LIBRARY_PATH the
SHLIB_PATH setting is requires.

The Oracle Database Gateway for MS SQL Server for Linux platforms comes on a
separate CD. It can be installed into an existing 11g database Oracle_Home
(please pay attention that if the Oracle_Home contains an already patched
release of the database; then you **MUST** apply this patchset again. The
reason for this is that the gateway installation might overwrite already
patched libraries with the base version as delivered on the CD. To get a
proper environment again an already applied patchset needs to be reapplied).

  
After the installation the following items must be configured:

> 1) listener (in the ORACLE_HOME where the gateway software is installed)  
> 2) tnsnames (in the ORACLE_HOME where the Oracle database software is
installed)  
> 3) init<SID>.ora of the hs subsystem (in the ORACLE_HOME where the gateway
software is installed)  
> 4) Oracle database

1) The listener needs a new SID entry like the following:

(SID_NAME=dg4msql)  
(ORACLE_HOME=/home/oracle/oracle/product/11.1)  
(ENV="LD_LIBRARY_PATH=/home/oracle/product/11.1/dg4msql/driver/lib:/home/oracle/product/11.1/lib")  
(PROGRAM=dg4msql)

  

Please correct the ORACLE_HOME entry and the ENV entry according to your
installation.  
We strongly recommend to add the LD_LIBARARY_PATH to the listener.ora file to
avoid any conflicts with already existing ODBC driver managers.  
The LD_LIBRARY_PATH must contain the full qualified path to the
$ORACLE_HOME/lib and $ORACLE_HOME/dg4msql/driver/lib directory. Please do NOT
use $ORACLE_HOME variable in the ENV path.

**ATTENTION** :  
1\. Installing on HP-UX RISC platform please set SHLIB_PATH instead of
LD_LIBRARY_PATH as the gateway on HP-UX RISC is still 32bit and thus requires
the SHLIB_PATH setting.

2\. For AIX platforms please use LIBPATH instead of LD_LIBRARY_PATH.

  
So a listener.ora file with a listener called "LISTENER" listening on port
1511 might look like:

> SID_LIST_LISTENER =  
>  (SID_LIST =  
>  (SID_DESC =  
>  (SID_NAME=dg4msql)  
>  (ORACLE_HOME=/home/oracle/oracle/product/11.1)  
>
(ENV="LD_LIBRARY_PATH=/home/oracle/product/11.1/dg4msql/driver/lib:/home/oracle/product/11.1/lib")  
>  (PROGRAM=dg4msql)  
>  )  
>  )  
>  
> LISTENER =  
>  (DESCRIPTION_LIST =  
>  (DESCRIPTION =  
>  (ADDRESS_LIST =  
>  (ADDRESS = (PROTOCOL = TCP)(HOST = <hostname of the Oracle Gateway Server>)
(PORT = 1511))  
>  )  
>  )  
>  )

>

>  
>

>

> SIDE NOTE: If you have to change the name of the listener as there's already
a listener with that name active in your environment, please make sure to have
the same name in for the address and SID section.

Once the listener.ora is changed, the listener must be stopped and started to
taker affect!

  
2) The tnsnames.ora needs an entry for the DG4MSQL alias:

> dg4msql.de.oracle.com =  
>  (DESCRIPTION=  
>  (ADDRESS=(PROTOCOL=tcp)(HOST=<hostname of the Oracle Gateway
Server>)(PORT=1511))  
>  (CONNECT_DATA=(SID=dg4msql))  
>  (HS=OK)  
>  )

The domain of the tns alias can differ from the one used above
(de.oracle.com), depending on the parameter in the sqlnet.ora:  
NAMES.DEFAULT_DOMAIN = de.oracle.com  
  
But the important entry is the (HS=OK) key word. (HS=) is also a valid entry,
but DBCA and NetCA will only recognize (HS=OK) entries and remove any (HS=)
entries.

After adding the tnsnames alias and restarting the listener, a  
connectivity check is to use tnsping <alias>.

tnsping dg4msql

  
should come back with a successful message.  
The tnsnames.ora file must reside in the ORACLE_HOME where the Oracle database
software is installed and not in the gateway ORACLE_HOME.

3) init.ora of the gateway:

There are some restrictions how to name the SID (described in the Net
Administrators Guide in detail).  
At this place only a short note: don't use dots in the SID and keep it short!  
  
The SID is also relevant for the initialiastion file of the gateway. The name
of the  
file is init<SID>.ora. In this example it is called initdg4msql.ora.  
The file is located at $ORACLE_HOME/dg4msql/admin.  
It should contain at least the connect details:

> #  
> HS_FDS_CONNECT_INFO=<SQL Server>:<port>//<database>  
> # alternate connect format is hostname/serverinstance/databasename

Short explanation of the parameter HS_FDS_CONNECT_INFO:  
It can be configured to use a SQL Server port# or to work with instances:

HS_FDS_CONNECT_INFO=<SQL Server>:<port>//<database>  
HS_FDS_CONNECT_INFO=<SQL Server>/<instance>/<database>

  
  
<SQL Server> is the hostname where the SQL Server resides  
<port> is the port number of the SQL Server (default is 1433)  
<instance> is the name of a dedicated instance you want to connect to; leave
it blank if your SQL Server setup does not use SQL Server instances (when
using a named instance, please make sure the "SQL Browser Service" is started
on the Microsoft SQL Server machine)  
<database> is the name of the database DG4MSQL should connect to; for example
Northwind

Example:  
To connect to a Northwind database on a SQL Server (w2k3) with IP Address
192.168.0.1 using the default instance you can use:

> HS_FDS_CONNECT_INFO=x2kx.de.oracle.com:1433//Northwind  
> or  
> HS_FDS_CONNECT_INFO=192.168.0.1:1433//Northwind

To connect to a SQL Server 2k5 named instance msql2k5 on this machine
listening on port 4025 either use:

> HS_FDS_CONNECT_INFO=x2kx.de.oracle.com:4025//Northwind  
> or  
> HS_FDS_CONNECT_INFO=192.168.2.1:4025//Northwind  
> or  
> HS_FDS_CONNECT_INFO=x2kx.de.oracle.com/MSQL2k5/Northwind  
> or  
> HS_FDS_CONNECT_INFO=192.168.2.1/MSQL2k5/Northwind

SIDE NOTE:  
To find the name of a SQL server instance, check out the registry key on the
SQL Server:  
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names  
When using HS_FDS_CONNECT_INFO=<SQL Server>/<instance>/<database> and
connections of the gateway fail although using port and host connections are
working, then make sure on te SQL Server machine the "SQL Server Browser"
service which provides SQL Server connection information to client computers
is started.  
When connections using the named instance connect method continue to fail
(even with the "SQL Browser Service" being started option of using the port
number is a suitable workaround.  
You can find the port number by accessing SQL Server's Server Network Utility
program, choosing the Instance you want to connect to, highlighting tcp/ip
under Enabled Protocols, and clicking the Properties button. A window should
open with the port number that the instance is listening on.

4) Configuring the Oracle database

The only thing that must be done here is to create a database link:  
connect with the username/password that has sufficient rights to create a  
database link (i.e. system).  
The syntax is:

> create [public] database link <name>  
> connect to <UID> identified by <pwd> using '<tnsalias>';

In other words, to connect to the MS SQL Server configured in the last steps,  
the syntax must be:

CREATE DATABASE LINK sqlserver  
CONNECT TO "sa" IDENTIFIED BY "sa" USING 'dg4msql';

  
  
The db link name is sqlserver. Username and password must be in double quotes,  
because the username and password are case sensitive in SQL Server. 'dg4msql'
points to  
the alias in the tnsnames.ora file that calls the HS subsystem.  
The tnsnames.ora file must reside in the ORACLE_HOME where the Oracle database
software is installed and not in the gateway ORACLE_HOME.  
  
If everything is configured well, a select of a SQL Server table should be
successful:  
  
select * from
["systables"@sqlserver](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=324647766660081&id=562509.1&displayIndex=2&_afrWindowMode=0&_adf.ctrl-
state=c5d94p5sg_126#aref_section21mailto:%22systablesP%22@sqlserver);  
...  
  
Side note: The systables table name at the MS SQL Server is in small letters.
As the MS SQL Server is case sensitive this table name must be surrounded by
double quotes.  

**Would you like to explore this topic further with other Oracle Customers,
Oracle Employees, and Industry Experts?**  
  
[Click here to join the discussion where you can ask questions, get help from
others, and share your experiences with this specific
article.](https://community.oracle.com/message/11887286)  
Discover discussions about other articles and helpful subjects by clicking
[here](https://community.oracle.com/community/support/oracle_database/gateways__oracle_lite__oracle_db_mob._server__timesten
"My Oracle Support Community - Database Gateway") to access the main _My
Oracle Support Community_ page for Database Gateways.

This is the actual Gateway MOS Community thread to discuss this note. It is
not a screen shot and to join the discussion click on 'Reply' in any of the
threads -

* * *

## References

[NOTE:1083703.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=562509.1&id=1083703.1)
\- Master Note for Oracle Gateway Products  


---
### NOTE ATTRIBUTES
>Created Date: 2018-07-25 01:34:11  
>Last Evernote Update Date: 2018-10-01 15:40:46  
>source: web.clip7  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=324647766660081  
>source-url: &  
>source-url: id=562509.1  
>source-url: &  
>source-url: displayIndex=2  
>source-url: &  
>source-url: _afrWindowMode=0  
>source-url: &  
>source-url: _adf.ctrl-state=c5d94p5sg_126#aref_section21  
>source-application: WebClipper 7  