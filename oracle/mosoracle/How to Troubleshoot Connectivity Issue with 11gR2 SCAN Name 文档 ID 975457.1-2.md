# How to Troubleshoot Connectivity Issue with 11gR2 SCAN Name (文档 ID 975457.1)

|

|

**In this Document**  

| |
[Goal](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=435882619424328&id=975457.1&_afrWindowMode=0&_adf.ctrl-
state=15brtznhh_219#GOAL)  
---|---  
|
[Solution](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=435882619424328&id=975457.1&_afrWindowMode=0&_adf.ctrl-
state=15brtznhh_219#FIX)  
---|---  
| [Troubleshooting
Steps](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=435882619424328&id=975457.1&_afrWindowMode=0&_adf.ctrl-
state=15brtznhh_219#aref_section21)  
---|---  
| [Example
Output](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=435882619424328&id=975457.1&_afrWindowMode=0&_adf.ctrl-
state=15brtznhh_219#aref_section22)  
---|---  
|
[Configuration](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=435882619424328&id=975457.1&_afrWindowMode=0&_adf.ctrl-
state=15brtznhh_219#aref_section23)  
---|---  
| [**SCAN name and
VIP:**](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=435882619424328&id=975457.1&_afrWindowMode=0&_adf.ctrl-
state=15brtznhh_219#aref_section24)  
---|---  
| [**Node Public Name/IP
Address**](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=435882619424328&id=975457.1&_afrWindowMode=0&_adf.ctrl-
state=15brtznhh_219#aref_section25)  
---|---  
| [**Nodes VIP Name/IP
Address**](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=435882619424328&id=975457.1&_afrWindowMode=0&_adf.ctrl-
state=15brtznhh_219#aref_section26)  
---|---  
| [**Database Name:
b2no**](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=435882619424328&id=975457.1&_afrWindowMode=0&_adf.ctrl-
state=15brtznhh_219#aref_section27)  
---|---  
| [**Service Name:
sno**](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=435882619424328&id=975457.1&_afrWindowMode=0&_adf.ctrl-
state=15brtznhh_219#aref_section28)  
---|---  
| [**TNS Connection
String**](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=435882619424328&id=975457.1&_afrWindowMode=0&_adf.ctrl-
state=15brtznhh_219#aref_section29)  
---|---  
| [1\. Checklist on RAC Cluster
Nodes](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=435882619424328&id=975457.1&_afrWindowMode=0&_adf.ctrl-
state=15brtznhh_219#aref_section210)  
---|---  
| [ A. SCAN Listener Resource
Status](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=435882619424328&id=975457.1&_afrWindowMode=0&_adf.ctrl-
state=15brtznhh_219#aref_section211)  
---|---  
| [**A1. SCAN
Configuration:**](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=435882619424328&id=975457.1&_afrWindowMode=0&_adf.ctrl-
state=15brtznhh_219#aref_section212)  
---|---  
| [**A2. SCAN Listener
Configuration:**](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=435882619424328&id=975457.1&_afrWindowMode=0&_adf.ctrl-
state=15brtznhh_219#aref_section213)  
---|---  
| [**A3. SCAN Listener Resource
Status:**](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=435882619424328&id=975457.1&_afrWindowMode=0&_adf.ctrl-
state=15brtznhh_219#aref_section214)  
---|---  
| [ B. SCAN Listener Status and
Service](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=435882619424328&id=975457.1&_afrWindowMode=0&_adf.ctrl-
state=15brtznhh_219#aref_section215)  
---|---  
| [**B1. SCAN Listener
Status:**](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=435882619424328&id=975457.1&_afrWindowMode=0&_adf.ctrl-
state=15brtznhh_219#aref_section216)  
---|---  
| [**B2. SCAN Listener
Service:**](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=435882619424328&id=975457.1&_afrWindowMode=0&_adf.ctrl-
state=15brtznhh_219#aref_section217)  
---|---  
| [ C. Node Listener Status and
Service](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=435882619424328&id=975457.1&_afrWindowMode=0&_adf.ctrl-
state=15brtznhh_219#aref_section218)  
---|---  
| [**C1. Node Listener
Status:**](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=435882619424328&id=975457.1&_afrWindowMode=0&_adf.ctrl-
state=15brtznhh_219#aref_section219)  
---|---  
| [**C2. Node Listener
Service:**](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=435882619424328&id=975457.1&_afrWindowMode=0&_adf.ctrl-
state=15brtznhh_219#aref_section220)  
---|---  
| [ D. Database Service
Status](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=435882619424328&id=975457.1&_afrWindowMode=0&_adf.ctrl-
state=15brtznhh_219#aref_section221)  
---|---  
| [**D1. Service Resource
Configuration**](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=435882619424328&id=975457.1&_afrWindowMode=0&_adf.ctrl-
state=15brtznhh_219#aref_section222)  
---|---  
| [**D2. Service Resource
Status:**](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=435882619424328&id=975457.1&_afrWindowMode=0&_adf.ctrl-
state=15brtznhh_219#aref_section223)  
---|---  
| [ E. Instance Listener Parameter
Setting:](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=435882619424328&id=975457.1&_afrWindowMode=0&_adf.ctrl-
state=15brtznhh_219#aref_section224)  
---|---  
| [**E1. remote_listener
setting:**](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=435882619424328&id=975457.1&_afrWindowMode=0&_adf.ctrl-
state=15brtznhh_219#aref_section225)  
---|---  
| [**E2. local_listener
setting:**](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=435882619424328&id=975457.1&_afrWindowMode=0&_adf.ctrl-
state=15brtznhh_219#aref_section226)  
---|---  
| [2\. Checklist on
Client](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=435882619424328&id=975457.1&_afrWindowMode=0&_adf.ctrl-
state=15brtznhh_219#aref_section227)  
---|---  
| [ A. SCAN Name
Resolution](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=435882619424328&id=975457.1&_afrWindowMode=0&_adf.ctrl-
state=15brtznhh_219#aref_section228)  
---|---  
| [ B. Node VIP
name:](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=435882619424328&id=975457.1&_afrWindowMode=0&_adf.ctrl-
state=15brtznhh_219#aref_section229)  
---|---  
|
[References](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=435882619424328&id=975457.1&_afrWindowMode=0&_adf.ctrl-
state=15brtznhh_219#REF)  
---|---  
  
* * *

  

## Applies to:

Oracle Database - Enterprise Edition - Version 11.2.0.1 and later  
Oracle Net Services - Version 11.2.0.4 to 11.2.0.4 [Release 11.2]  
Information in this document applies to any platform.  

## Goal

The goal of this document is to provide checklist when connection through
11gR2 Grid Infrastructure (CRS) SCAN name to database fails.

## Solution

### Troubleshooting Steps

When client program connects to RAC database through SCAN name, SCAN listener
will accept t he request and redirect the connection to local listener. To
identify connection issue, first try to connect to each local listener through
node VIP, then try each SCAN listener through each SCAN VIP.  
  
To test through node VIP:

> sqlplus <username>/<password>@<nodename-vip.domain>:<local-listener-
port>/<service-name>  
>  
>  **Example:**  
>  
>  sqlplus scott/tiger@racnode1-vip.us.eot.com:1521/testsvc

>

>  
> Repeat the same test for all local listener/node VIP in the cluster.  
>  
> If GNS is used, node VIP name will be in the format of nodename
**-vip**.gnssubdomain (example racnode1-vip.us.eot.com)  
>  
>  If connection through local listener fails, check whether service/instance
is registered properly to that local listener with "lsnrctl service <local-
listener-name>".

  
To test through SCAN VIP address:

> sqlplus <username>/<password>@<scan-ip ** _n_** >:<scan-listener-
port>/<service-name>  
>  
>  **Example:**  
>  
>  sqlplus scott/tiger@120.0.0.205:1521/testsvc  
>  
>  **Note it's IP address instead of SCAN name**

>

>  
>  Repeat the same command for all SCAN IP

> If connection through SCAN listener fails, check whether service/instance is
registered properly to that SCAN listener with "lsnrctl service <SCAN-
listener-name>".

For a quick check, execute CVU scan check: <GI_HOME>/bin/cluvfy comp scan
-verbose

Other client tool (JDBC or such) can also be used to test connection though
sqlplus is preferred for the purpose of testing.  
  

### Example Output

#### Configuration

Below is an example output from a 2-node cluster with the following
configuration:

##### **SCAN name and VIP:**

> nslookup eotcs.us.oracle.com  
> ..  
> Name: eotcs.us.oracle.com  
> Address: 120.0.0.207  
> Name: eotcs.us.oracle.com  
> Address: 120.0.0.205  
> Name: eotcs.us.oracle.com  
> Address: 120.0.0.206

> Ping doesn't have to go through if ICMP is disabled but should return
correct IP for corresponding name.  
>

>

> **ping -c 1 eotcs.us.oracle.com**  
>  PING eotcs.us.oracle.com (120.0.0.207) 56(84) bytes of data.  
> 64 bytes from 120.0.0.207: icmp_seq=1 ttl=64 time=3.37 ms  
> ..  
>  
>  **ping -c 1 eotcs.us.oracle.com**  
>  PING eotcs.us.oracle.com (120.0.0.206) 56(84) bytes of data.  
> 64 bytes from 120.0.0.206: icmp_seq=1 ttl=64 time=1.85 ms  
> ..  
>  
>  **ping -c 1 eotcs.us.oracle.com**  
>  PING eotcs.us.oracle.com (120.0.0.205) 56(84) bytes of data.  
> 64 bytes from 120.0.0.205: icmp_seq=1 ttl=64 time=2.45 ms  
> ..  
>  
>  **ping -c 1 eotcs**  
>  PING eotcs.us.oracle.com (120.0.0.207) 56(84) bytes of data.  
> 64 bytes from eotcs.us.oracle.com (120.0.0.207): icmp_seq=1 ttl=64 time=3.18
ms

##### **Node Public Name/IP Address**

> **Name: eyrac1f.us.oracle.com Address: 120.0.0.111  
>  Name: eyrac2f.us.oracle.com Address: 120.0.0.112**  
>  
>  **ping -c 1 eyrac1f.us.oracle.com**  
>  PING eyrac1f.us.oracle.com (120.0.0.111) 56(84) bytes of data.  
> 64 bytes from eyrac1f.us.oracle.com (120.0.0.111): icmp_seq=1 ttl=64
time=3.36 ms  
> ..  
>  
>  **ping -c 1 eyrac2f.us.oracle.com**  
>  PING eyrac2f.us.oracle.com (120.0.0.112) 56(84) bytes of data.  
> 64 bytes from eyrac2f.us.oracle.com (120.0.0.112): icmp_seq=1 ttl=64
time=3.37 ms  
> ..

##### **Nodes VIP Name/IP Address**

> **Name: eyrac1fv.us.oracle.com Address: 120.0.0.211  
>  Name: eyrac2fv.us.oracle.com Address: 120.0.0.212**  
>  
>  **nslookup eyrac1fv.us.oracle.com**  
>  
> ..  
>  Name: eyrac1fv.us.oracle.com  
> Address: 120.0.0.211  
>  
>  **nslookup eyrac2fv.us.oracle.com**  
>  
> ..  
>  Name: eyrac2fv.us.oracle.com  
> Address: 120.0.0.212  
>  
>  
>  **ping -c 1 eyrac1fv.us.oracle.com**  
>  PING eyrac1fv.us.oracle.com (120.0.0.211) 56(84) bytes of data.  
> 64 bytes from eyrac1fv.us.oracle.com (120.0.0.211): icmp_seq=1 ttl=64
time=4.04 ms  
> ..  
>  
>  **ping -c 1 eyrac2fv.us.oracle.com**  
>  PING eyrac2fv.us.oracle.com (120.0.0.212) 56(84) bytes of data.  
> 64 bytes from eyrac2fv.us.oracle.com (120.0.0.212): icmp_seq=1 ttl=64
time=1.98 ms  
> ..

##### **Database Name: b2no**

##### **Service Name: sno**

##### **TNS Connection String**

> sno =  
>  (DESCRIPTION =  
>  (ADDRESS = (PROTOCOL = TCP)(HOST = **eotcs.us.oracle.com** )(PORT = 1521))  
>  (CONNECT_DATA =  
>  (SERVICE_NAME = **sno** )  
>  )  
>  )

### 1\. Checklist on RAC Cluster Nodes

Prior to the following checking, please set environment variable GRID_HOME to
home of 11.2 Grid Infrastructure installation, for example:  
  

GRID_HOME=/ogrid/gbase  
export GRID_HOME

  
Please note:  
  
* Oracle Network related files (sqlnet.ora, tnsnames.ora, listener.ora etc) are in $TNS_ADMIN or $ORACLE_HOME/network/admin if TNS_ADMIN is not set.   
* This note assumes SCAN VIP and node VIP are all up and running (can be verified through "srvctl status nodeapps" and "srvctl status scan" or "crsctl stat res"), troubleshooting of SCAN VIP or node VIP startup issue is out of scope of this note.

####  A. SCAN Listener Resource Status

##### **A1. SCAN Configuration:**

> **$GRID_HOME/bin/srvctl config scan**  
>  
>  SCAN name: eotcs.us.oracle.com, Network: 1/120.0.0.0/255.255.255.0/eth3  
> SCAN VIP name: scan1, IP: /120.0.0.206/120.0.0.206  
> SCAN VIP name: scan2, IP: /120.0.0.207/120.0.0.207  
> SCAN VIP name: scan3, IP: /120.0.0.205/120.0.0.205

##### **A2. SCAN Listener Configuration:**

> **$GRID_HOME/bin/srvctl config scan_listener**  
>  SCAN Listener LISTENER_SCAN1 exists. Port: TCP:1521  
> SCAN Listener LISTENER_SCAN2 exists. Port: TCP:1521  
> SCAN Listener LISTENER_SCAN3 exists. Port: TCP:1521

##### **A3. SCAN Listener Resource Status:**

> **$GRID_HOME/bin/crsctl stat res -w "TYPE = ora.scan_listener.type"**  
>  NAME=ora.LISTENER_SCAN1.lsnr  
> TYPE=ora.scan_listener.type  
> TARGET=ONLINE  
> STATE=ONLINE on eyrac1f  
>  
> NAME=ora.LISTENER_SCAN2.lsnr  
> TYPE=ora.scan_listener.type  
> TARGET=ONLINE  
> STATE=ONLINE on eyrac2f  
>  
> NAME=ora.LISTENER_SCAN3.lsnr  
> TYPE=ora.scan_listener.type  
> TARGET=ONLINE  
> STATE=ONLINE on eyrac2f

####  B. SCAN Listener Status and Service

> Log on to corresponding RAC node to find out SCAN listener status and
service once SCAN listener resource status is confirmed. All SCAN listener
should have same service served. Please set ORACLE_HOME environment variable
prior to run any lsnrctl command, for example:  
>  
>

>

> ORACLE_HOME=$GRID_HOME  
> export ORACLE_HOME

##### **B1. SCAN Listener Status:**

> **$GRID_HOME/bin/lsnrctl status LISTENER_SCAN2**  
> ..  
>  Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=IPC)(KEY=LISTENER_SCAN2)))  
> STATUS of the LISTENER  
> \------------------------  
> ..  
> Listener Parameter File /ogrid/gbase/network/admin/listener.ora  
> Listener Log File
/ogrid/gbase/log/diag/tnslsnr/eyrac2f/listener_scan2/alert/log.xml  
> Listening Endpoints Summary...  
>  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=LISTENER_SCAN2)))  
>  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=120.0.0.207)(PORT=1521)))  
> ..

##### **B2. SCAN Listener Service:**

> **$GRID_HOME/bin/lsnrctl service LISTENER_SCAN2**  
> ..  
>  Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=IPC)(KEY=LISTENER_SCAN2)))  
> Services Summary...  
> Service "b2no" has 2 instance(s).  
>  Instance "b2no1", status READY, has 1 handler(s) for this service...  
>  Handler(s):  
>  "DEDICATED" established:0 refused:0 state:ready  
>  REMOTE SERVER  
>  (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=eyrac1fv)(PORT=1521)))  
>  Instance "b2no2", status READY, has 1 handler(s) for this service...  
>  Handler(s):  
>  "DEDICATED" established:0 refused:0 state:ready  
>  REMOTE SERVER  
>  (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=eyrac2fv)(PORT=1521)))  
> Service "sno" has 2 instance(s).  
>  Instance "b2no1", status READY, has 1 handler(s) for this service...  
>  Handler(s):  
>  "DEDICATED" established:0 refused:0 state:ready  
>  REMOTE SERVER  
>  (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=eyrac1fv)(PORT=1521)))  
>  Instance "b2no2", status READY, has 1 handler(s) for this service...  
>  Handler(s):  
>  "DEDICATED" established:0 refused:0 state:ready  
>  REMOTE SERVER  
>  (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=eyrac2fv)(PORT=1521)))

####  C. Node Listener Status and Service

##### **C1. Node Listener Status:**

> **$GRID_HOME/bin/lsnrctl status LISTENER**  
> ..  
>  Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=IPC)(KEY=LISTENER)))  
> STATUS of the LISTENER  
> \------------------------  
> ..  
> Listener Parameter File /ogrid/gbase/network/admin/listener.ora  
> Listener Log File
/home/oracle/app/oracle/diag/tnslsnr/eyrac2f/listener/alert/log.xml  
> Listening Endpoints Summary...  
>  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=LISTENER)))  
>  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=120.0.0.112)(PORT=1521)))  
>  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=120.0.0.212)(PORT=1521)))  
> Services Summary...  
> Service "b2no" has 1 instance(s).  
>  Instance "b2no2", status READY, has 1 handler(s) for this service...  
> Service "sno" has 1 instance(s).  
>  Instance "b2no2", status READY, has 1 handler(s) for this service...

##### **C2. Node Listener Service:**

> **$GRID_HOME/bin/lsnrctl service LISTENER**  
> ..  
>  Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=IPC)(KEY=LISTENER)))  
> Services Summary...  
> Service "b2no" has 1 instance(s).  
>  Instance "b2no2", status READY, has 1 handler(s) for this service...  
>  Handler(s):  
>  "DEDICATED" established:0 refused:0 state:ready  
>  LOCAL SERVER  
> Service "sno" has 1 instance(s).  
>  Instance "b2no2", status READY, has 1 handler(s) for this service...  
>  Handler(s):  
>  "DEDICATED" established:0 refused:0 state:ready  
>  LOCAL SERVER

####  D. Database Service Status

##### **D1. Service Resource Configuration**

> **$GRID_HOME/bin/srvctl config service -d b2no -s sno -a**  
>  
>  Service name: sno  
> Service is enabled  
> Server pool: b2no_sno  
> Cardinality: 2  
> Disconnect: false  
> Service role: PRIMARY  
> Management policy: AUTOMATIC  
> DTP transaction: false  
> AQ HA notifications: false  
> Failover type: SELECT  
> Failover method: BASIC  
> TAF failover retries: 2  
> TAF failover delay: 20  
> Connection Load Balancing Goal: LONG  
> Runtime Load Balancing Goal: NONE  
> TAF policy specification: BASIC  
> Preferred instances: b2no1,b2no2  
> Available instances:

##### **D2. Service Resource Status:**

> **$GRID_HOME/bin/srvctl status service -d b2no -s sno -v**  
>  
>  Service sno is running on instance(s) b2no1,b2no2

####  E. Instance Listener Parameter Setting:

##### **E1. remote_listener setting:**

> **For 11gR2 database**  
>

>

> SQL> **show parameter remote_listener**  
>  
>  NAME TYPE VALUE  
> \------------------------------------ -----------
------------------------------  
> remote_listener string eotcs.us.oracle.com:1521

>

> **  
> For pre-11gR2 database**

> SQL> **show parameter remote_listener**  
>  
>  NAME TYPE VALUE  
> \------------------------------------ -----------
------------------------------  
> remote_listener string (ADDRESS_LIST =(ADDRESS = (PROTOCOL = TCP)(HOST =
120.0.0.206)(PORT = 1521))(ADDRESS = (PROTOCOL = TCP)(HOST = 120.0.0.207)(PORT
= 1521))(ADDRESS = (PROTOCOL = TCP)(HOST = 120.0.0.205)(PORT = 1521)))  
>  
>  **OR**  
>  
>  remote_listener string LISTENERS_SCAN  
>  
>  **Note tnsnames.ora must have the following entry for LISTENERS_SCAN**  
>  
>  LISTENERS_SCAN =  
>  (ADDRESS_LIST =  
>  (ADDRESS = (PROTOCOL = TCP)(HOST = 120.0.0.206)(PORT = 1521))  
>  (ADDRESS = (PROTOCOL = TCP)(HOST = 120.0.0.207)(PORT = 1521))  
>  (ADDRESS = (PROTOCOL = TCP)(HOST = 120.0.0.205)(PORT = 1521))  
>  )

>

>  
> If sqlnet.ora does not contain EZCONNECT in _NAMES.DIRECTORY_PATH_ list,
remote_listener should set to LISTENERS_SCAN as in above example.

##### **E2. local_listener setting:**

**For Instance1:**

> SQL> **show parameter local_listener**  
>  
>  NAME TYPE VALUE  
> \------------------------------------ -----------
------------------------------  
> local_listener string (DESCRIPTION=(ADDRESS_LIST=(AD  
>  DRESS=(PROTOCOL=TCP)(HOST=eyra  
>  c1fv)(PORT=1521))))

  
**For Instance2:**

> SQL> **show parameter local_listener**  
>  
>  NAME TYPE VALUE  
> \------------------------------------ -----------
------------------------------  
> local_listener string (DESCRIPTION=(ADDRESS_LIST=(AD  
>  DRESS=(PROTOCOL=TCP)(HOST=eyra  
>  c2fv)(PORT=1521))))

### 2\. Checklist on Client

A successful tnsping to TNS connection string for SCAN doesn't necessarily
mean the connection will be successful, client should be able to resolve to
SCAN name, node VIP name  
  
For supported client version, refer to section "VERSION AND BACKWARD
COMPATIBILITY" of the following:  
  
http://www.oracle.com/technetwork/database/clustering/overview/scan-129069.pdf  
  

####  A. SCAN Name Resolution

> nslookup and ping of SCAN name should return correct SCAN VIP(s), ORA-12545
could be reported if client can't resolve SCAN name properly

> If the client is in different domain, it may not resolve the short SCAN
name; i.e. client erpclient1.uk.oracle.com may not resolve SCAN name
"scanerp", however, it's able to resolve FQDN name "scanerp.us.oracle.com"; in
this case, specify the FQDN SCAN name in connection string (tnsnames.ora etc)

####  B. Node VIP name:

> By default, pfile/spfile parameter local_listener is set to short node VIP
name instead of FQDN name, client need to be able to resolve to short VIP name
as well as FQDN name; for example with following local_listener setting,
client should be able to resolve short VIP name:

>

> SQL> **show parameter local_listener**  
>  
>  NAME TYPE VALUE  
> \------------------------------------ -----------
------------------------------  
> local_listener string (DESCRIPTION=(ADDRESS_LIST=(AD  
>  DRESS=(PROTOCOL=TCP)(HOST=eyra  
>  c1fv)(PORT=1521))))  
>  
>  **ping -c 1 eyrac1fv**  
>  PING eyrac1fv.us.oracle.com (120.0.0.211) 56(84) bytes of data.  
> 64 bytes from eyrac1fv.us.oracle.com (120.0.0.211): icmp_seq=1 ttl=64
time=4.04 ms  
> ..  
>  
>  **ping -c 1 eyrac2fv**  
>  PING eyrac2fv.us.oracle.com (120.0.0.212) 56(84) bytes of data.  
> 64 bytes from eyrac2fv.us.oracle.com (120.0.0.212): icmp_seq=1 ttl=64
time=1.98 ms  
> ..

>

> If client can resolve FQDN node VIP name but not short node VIP name (client
in different domain), ORA-12537 could be reported and pfile/spfile
local_listener need to be adjusted with FQDN node VIP name:  
>

>

> SQL> alter system set
local_listener='(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=
**eyrac1fv.us.oracle.com** )(PORT=1521))))' sid='b2no1';  
>  
> SQL> **show parameter local_listener**  
>  
>  NAME TYPE VALUE  
> \------------------------------------ -----------
------------------------------  
> local_listener string (DESCRIPTION=(ADDRESS_LIST=(AD  
>  DRESS=(PROTOCOL=TCP)(HOST= **eyra  
>  c1fv.us.oracle.com** )(PORT=1521))))

>

>  
> Once instance updated local_listener setting to listeners, SCAN listener
should have similar output like following:  
>

>

> **$GRID_HOME/bin/lsnrctl service LISTENER_SCAN2**  
> ..  
>  Services Summary...  
> Service "b2no" has 2 instance(s).  
>  Instance "b2no1", status READY, has 1 handler(s) for this service...  
>  Handler(s):  
>  "DEDICATED" established:4 refused:0 state:ready  
>  REMOTE SERVER  
>  (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST= **eyrac1fv.us.oracle.com**
)(PORT=1521)))  
>  Instance "b2no2", status READY, has 1 handler(s) for this service...  
>  Handler(s):  
>  "DEDICATED" established:3 refused:0 state:ready  
>  REMOTE SERVER  
>  (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST= **eyrac2fv** )(PORT=1521)))  
> Service "sno" has 2 instance(s).  
>  Instance "b2no1", status READY, has 1 handler(s) for this service...  
>  Handler(s):  
>  "DEDICATED" established:4 refused:0 state:ready  
>  REMOTE SERVER  
>  (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST= **eyrac1fv.us.oracle.com**
)(PORT=1521)))  
>  Instance "b2no2", status READY, has 1 handler(s) for this service...  
>  Handler(s):  
>  "DEDICATED" established:3 refused:0 state:ready  
>  REMOTE SERVER  
>  (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST= **eyrac2fv** )(PORT=1521)))  
>  
>  **Note for node1 it's FQDN name but for node2 it's still short name as
node2 is not updated yet**

>

>  
>  If for some reason, client can't resolve FQDN node VIP name nor short node
VIP name, pfile/spfile local_listener need to be adjusted with IP of VIP name:  
>

>

> SQL> alter system set
local_listener='(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=
**120.0.0.211** )(PORT=1521))))' sid='b2no1';  
>  
> SQL> **show parameter local_listener**  
>  
>  NAME TYPE VALUE  
> \------------------------------------ -----------
------------------------------  
> local_listener string (DESCRIPTION=(ADDRESS_LIST=(AD  
>  DRESS=(PROTOCOL=TCP)(HOST= **120.  
>  0.0.211** )(PORT=1521))))

  
On Windows, please change syntax accordingly, for example:  
  

set GRID_HOME=c:\oracle\crs  
%GRID_HOME%\bin\srvctl config scan

## References

[NOTE:970619.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=975457.1&id=970619.1)
\- ORA-12545 or ORA-12537 While Connecting to RAC through SCAN name  
[NOTE:1058646.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=975457.1&id=1058646.1)
\- How to integrate a 10g/11gR1 RAC database with 11gR2 clusterware (SCAN)  
[NOTE:1448717.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=975457.1&id=1448717.1)
\- 11gR2 PMON Issue: Services Fail to Register to SCAN Listeners  
[NOTE:1340831.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=975457.1&id=1340831.1)
\- Using Class of Secure Transport (COST) to Restrict Instance Registration in
Oracle RAC  
[NOTE:114085.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=975457.1&id=114085.1)
\- Troubleshooting Guide for ORA-12154 / TNS-12154 TNS:could not resolve
service name  


---
### NOTE ATTRIBUTES
>Created Date: 2018-08-02 06:11:01  
>Last Evernote Update Date: 2018-10-01 15:55:03  
>source: web.clip7  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=435882619424328  
>source-url: &  
>source-url: id=975457.1  
>source-url: &  
>source-url: _afrWindowMode=0  
>source-url: &  
>source-url: _adf.ctrl-state=15brtznhh_219  
>source-application: WebClipper 7  