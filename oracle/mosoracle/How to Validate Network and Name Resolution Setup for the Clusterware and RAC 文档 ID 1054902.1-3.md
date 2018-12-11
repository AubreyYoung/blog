# How to Validate Network and Name Resolution Setup for the Clusterware and
RAC (文档 ID 1054902.1)

|

|

**In this Document**  

| |
[Purpose](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=174541678371239&id=1054902.1&displayIndex=1&_afrWindowMode=0&_adf.ctrl-
state=wpalmzgn_224#PURPOSE)  
---|---  
|
[Scope](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=174541678371239&id=1054902.1&displayIndex=1&_afrWindowMode=0&_adf.ctrl-
state=wpalmzgn_224#SCOPE)  
---|---  
|
[Details](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=174541678371239&id=1054902.1&displayIndex=1&_afrWindowMode=0&_adf.ctrl-
state=wpalmzgn_224#BODYTEXT)  
---|---  
| [A.
Requirement](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=174541678371239&id=1054902.1&displayIndex=1&_afrWindowMode=0&_adf.ctrl-
state=wpalmzgn_224#aref_section31)  
---|---  
| [B. Example of what we
expect](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=174541678371239&id=1054902.1&displayIndex=1&_afrWindowMode=0&_adf.ctrl-
state=wpalmzgn_224#aref_section32)  
---|---  
| [C. Syntax
reference](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=174541678371239&id=1054902.1&displayIndex=1&_afrWindowMode=0&_adf.ctrl-
state=wpalmzgn_224#aref_section33)  
---|---  
| [D.
Multicast](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=174541678371239&id=1054902.1&displayIndex=1&_afrWindowMode=0&_adf.ctrl-
state=wpalmzgn_224#aref_section34)  
---|---  
| [E. Runtime network
issues](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=174541678371239&id=1054902.1&displayIndex=1&_afrWindowMode=0&_adf.ctrl-
state=wpalmzgn_224#aref_section35)  
---|---  
| [F. Symptoms of network
issues](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=174541678371239&id=1054902.1&displayIndex=1&_afrWindowMode=0&_adf.ctrl-
state=wpalmzgn_224#aref_section36)  
---|---  
| [G. Basics of
Subnet](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=174541678371239&id=1054902.1&displayIndex=1&_afrWindowMode=0&_adf.ctrl-
state=wpalmzgn_224#aref_section37)  
---|---  
|
[References](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=174541678371239&id=1054902.1&displayIndex=1&_afrWindowMode=0&_adf.ctrl-
state=wpalmzgn_224#REF)  
---|---  
  
* * *

## Applies to:

Oracle Database - Enterprise Edition - Version 10.1.0.2 and later  
Oracle Database - Standard Edition - Version 12.1.0.2 and later  
Generic UNIX  
Generic Linux  

## Purpose

[](https://support.oracle.com/epmos/faces/DocumentDisplay?&id=1268927.2&cid=ocdbgeneric-
ad-%E6%96%87%E6%A1%A3-1054902.1&parent=KM-Advert&sourceId=ocdbgeneric-
ad-%E6%96%87%E6%A1%A3-1054902.1)

Cluster Verification Utility (aka CVU, command runcluvfy.sh or cluvfy) does
very good checking on the network and name resolution setup, but it may not
capture all issues. If the network and name resolution is not setup properly
before installation, it is likely the installation will fail; if network or
name resolution is malfunctioning, likely the clusterware and/or RAC will have
issues. The goal of this note is to provide a list of things to verify
regarding the network and name resolution setup for Grid Infrastructure
(clusterware) and RAC.

## Scope

This document is intended for Oracle Clusterware/RAC Database Administrators
and Oracle Support engineers.

## Details

### A. Requirement

o Network ping with package size of Network Adapter (NIC) MTU should work on
all public and private network and the time of ping should be small (sub-
second).

o IP address 127.0.0.1 should only map to localhost and/or
localhost.localdomain, not anything else.

o 127.*.*.* should not be used by any network interface.

o Public NIC name must be same on all nodes.  
  
o Private NIC name should be same in 11gR2 and must be same for pre-11gR2 on
all nodes

o Public and private network must not be in link local subnet (169.254.*.*),
should be in non-related separate subnet.

o MTU should be the same for corresponding network on all nodes.  
  
o Network size should be same for corresponding network on all nodes.  
  
o As the private network needs to be directly attached, traceroute should work
with a packet size of NIC MTU without fragmentation or going through the
routing table on all private networks in 1 hop.  
  
o Firewall needs to be turned off on the private network.  
  
o For 10.1 to 11.1, name resolution should work for the public, private and
virtual names.  
  
o For 11.2 without Grid Naming Service (aka GNS), name resolution should work
for all public, virtual, and SCAN names; and if SCAN is configured in DNS, it
should not be in local hosts file.

o For 11.2.0.2 and above, multicast group 230.0.1.0 should work on private
network; with [patch
9974223](https://support.oracle.com/epmos/faces/ui/patch/PatchDetail.jspx?parent=DOCUMENT&sourceId=1054902.1&patchId=9974223),
both group 230.0.1.0 and 224.0.0.251 are supported. With [patch
10411721](https://support.oracle.com/epmos/faces/ui/patch/PatchDetail.jspx?parent=DOCUMENT&sourceId=1054902.1&patchId=10411721)
(fixed in 11.2.0.3), broadcast will be supported. See Multicast/Broadcast
section to verify.

o For 11.2.0.1-11.2.0.3, Installer may report a warning if reverse lookup is
not setup correctly for pubic IP, node VIP, and SCAN VIP, with [bug
9574976](https://support.oracle.com/epmos/faces/BugDisplay?parent=DOCUMENT&sourceId=1054902.1&id=9574976)
fix in 11.2.0.4, the warning shouldn't be there any more.

o OS level bonding is recommended for the private network for pre-11.2.0.2.
Depending on the platform, you may implement bonding, teaming, Etherchannel,
IPMP, MultiPrivNIC etc, please consult with your OS vendor for details.
Started from 11.2.0.2, Redundant Interconnect and HAIP is introduced to
provide native support for multiple private network, refer to [note
1210883.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1054902.1&id=1210883.1)
for details.  
  
o The commands verifies jumbo frames if it's configured. To know more about
jumbo frames, refer to [note
341788.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1054902.1&id=341788.1)  

### B. Example of what we expect

Example below shows what we expect while validating the network and name
resolution setup. As the network setup is slightly different for 11gR2 and
11gR1 or below, we have both case in the below example. The difference between
11gR1 or below and 11gR2 is for 11gR1, we need a public name, VIP name,
private hostname, and we rely on the private name to find out the private IP
for cluster communication. For 11gR2, we do not rely on the private name
anymore, rather the private network is selected based on the GPnP profile
while the clusterware comes up. Assuming a 3-node cluster with the following
node information:  
  

    
    
    11gR1 or below cluster:
    
    
    Nodename |Public IP |VIP name |VIP        |Private |private IP1 |private IP2           
    
    
             |NIC/MTU   |         |           |Name1   |NIC/MTU     |
    
    
    ---------|----------|---------|-----------|--------|----------------------
    
    
    rac1     |120.0.0.1 |rac1v    |120.0.0.11 |rac1p   |10.0.0.1    |
    
    
             |eth0/1500 |         |           |        |eth1/1500   |
    
    
    ---------|----------|---------|-----------|--------|----------------------
    
    
    rac2     |120.0.0.2 |rac2v    |120.0.0.12 |rac2p   |10.0.0.2    |
    
    
             |eth0/1500 |         |           |        |eth1/1500   |
    
    
    ---------|----------|---------|-----------|--------|----------------------
    
    
    rac3     |120.0.0.3 |rac3v    |120.0.0.13 |rac3p   |10.0.0.3    |
    
    
             |eth0/1500 |         |           |        |eth1/1500   |
    
    
    ---------|----------|---------|-----------|--------|----------------------
    
    
    11gR2 cluster
    
    
    Nodename |Public IP |VIP name |VIP        |private IP1 |           
    
    
             |NIC/MTU   |         |           |NIC/MTU     |
    
    
    ---------|----------|---------|-----------|------------|----------
    
    
    rac1     |120.0.0.1 |rac1v    |120.0.0.11 |10.0.0.1    | 
    
    
             |eth0/1500 |         |           |eth1/1500   |
    
    
    ---------|----------|---------|-----------|------------|----------
    
    
    rac2     |120.0.0.2 |rac2v    |120.0.0.12 |10.0.0.2    |
    
    
             |eth0/1500 |         |           |eth1/1500   |
    
    
    ---------|----------|---------|-----------|------------|----------
    
    
    rac3     |120.0.0.3 |rac3v    |120.0.0.13 |10.0.0.3    |
    
    
             |eth0/1500 |         |           |eth1/1500   |
    
    
    ---------|----------|---------|-----------|------------|----------
    
    
     
    
    
    SCAN name |SCAN IP1   |SCAN IP2   |SCAN IP3   
    
    
    ----------|-----------|-----------|--------------------
    
    
    scancl1   |120.0.0.21 |120.0.0.22 |120.0.0.23 
    
    
    ----------|-----------|-----------|--------------------

  
  
Below is what is needed to be verify on each node - please note the example is
from a Linux platform:  
  
1\. To find out the MTU

**/bin/netstat -in**  
Kernel Interface table  
Iface **MTU** Met RX-OK RX-ERR RX-DRP RX-OVR TX-OK TX-ERR TX-DRP TX-OVR Flg  
 **eth0** **1500** 0 203273 0 0 0 2727 0 0 0 BMRU

In above example MTU is set to 1500 for eth0.  
  
  
2\. To find out the IP address and subnet, compare Broadcast and Netmask on
all nodes

**/sbin/ifconfig**  
 **eth0** Link encap:Ethernet HWaddr 00:16:3E:11:11:11  
**inet addr:120.0.0.1 Bcast:120.0.0.127 Mask:255.255.255.128**  
inet6 addr: fe80::216:3eff:fe11:1111/64 Scope:Link  
**UP** BROADCAST **RUNNING** MULTICAST **MTU:1500** Metric:1  
RX packets:203245 errors:0 dropped:0 overruns:0 frame:0  
TX packets:2681 errors:0 dropped:0 overruns:0 carrier:0  
collisions:0 txqueuelen:1000  
RX bytes:63889908 (60.9 MiB) TX bytes:319837 (312.3 KiB)  
..

  
In the above example, the IP address for eth0 is 120.0.0.1, broadcast is
120.0.0.127, and net mask is 255.255.255.128, which is subnet of 120.0.0.0
with a maximum of 126 IP addresses. Refer to Section "Basics of Subnet" for
more details.  
  
Note: An active NIC must have both "UP" and "RUNNING" flag; on Solaris,
"PHYSRUNNING" will indicate whether the physical interface is running  
  
3\. Run all ping commands twice to make sure result is consistent  
  
Below is an example ping output from node1 public IP to node2 public hostname:

PING rac2 (120.0.0.2) from 120.0.0.1 : 1500(1528) bytes of data.  
1508 bytes from rac1 (120.0.0.2): icmp_seq=1 ttl=64 time=0.742 ms  
1508 bytes from rac1 (120.0.0.2): icmp_seq=2 ttl=64 time=0.415 ms  
  
\--- rac2 ping statistics ---  
2 packets transmitted, 2 received, **0% packet loss** , **time 1000ms**  
rtt min/avg/max/mdev = 0.415/0.578/0.742/0.165 ms

Please pay attention to the packet loss and time. If it is not 0% packet loss,
or if it is not sub-second time, then it indicates there is a problem in the
network. Please engage network administrator to check further.

  
3.1 Ping all public nodenames from the local public IP with packet size of MTU

/bin/ping -s <MTU> -c 2 -I 120.0.0.1 rac1  
/bin/ping -s <MTU> -c 2 -I 120.0.0.1 rac1  
/bin/ping -s <MTU> -c 2 -I 120.0.0.1 rac2  
/bin/ping -s <MTU> -c 2 -I 120.0.0.1 rac2  
/bin/ping -s <MTU> -c 2 -I 120.0.0.1 rac3  
/bin/ping -s <MTU> -c 2 -I 120.0.0.1 rac3

  
3.2.1 Ping all private IP(s) from all local private IP(s) with packet size of
MTU  
applies to 11gR2 example, private name is optional

/bin/ping -s <MTU> -c 2 -I 10.0.0.1 10.0.0.1  
/bin/ping -s <MTU> -c 2 -I 10.0.0.1 10.0.0.1  
/bin/ping -s <MTU> -c 2 -I 10.0.0.1 10.0.0.2  
/bin/ping -s <MTU> -c 2 -I 10.0.0.1 10.0.0.2  
/bin/ping -s <MTU> -c 2 -I 10.0.0.1 10.0.0.3  
/bin/ping -s <MTU> -c 2 -I 10.0.0.1 10.0.0.3

  
3.2.2 Ping all private nodename from local private IP with packet size of MTU  
applies to 11gR1 and earlier example

/bin/ping -s <MTU> -c 2 -I 10.0.0.1 rac1p  
/bin/ping -s <MTU> -c 2 -I 10.0.0.1 rac1p  
/bin/ping -s <MTU> -c 2 -I 10.0.0.1 rac2p  
/bin/ping -s <MTU> -c 2 -I 10.0.0.1 rac2p  
/bin/ping -s <MTU> -c 2 -I 10.0.0.1 rac3p  
/bin/ping -s <MTU> -c 2 -I 10.0.0.1 rac3p

  
4\. Traceroute private network  
  
Example below shows traceroute from node1 private IP to node2 private hostname  
  
 **# Packet size of MTU - on Linux packet length needs to be MTU - 28 bytes
otherwise error send: Message too long is reported.  
# For example with MTU value of 1500 we would use 1472 :**

traceroute to rac2p (10.0.0.2), 30 hops max, 1472 byte packets  
 **1 rac2p (10.0.0.2) 0.626 ms 0.567 ms 0.529 ms**

** ** MTU size packet traceroute complete in 1 hop without going through the
routing table. Output other than above indicates issue, i.e. when "*" or "!H"
presents.  
  
Note: traceroute option "-F" may not work on RHEL3/4 OEL4 due to OS bug, refer
to [note:
752844.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1054902.1&id=752844.1)
for details.  
  
4.1 Traceroute all private IP(s) from all local private IP(s) with :  
applies to 11gR2 onwards

/bin/traceroute -s 10.0.0.1 -r -F 10.0.0.1 <MTU-28>  
/bin/traceroute -s 10.0.0.1 -r -F 10.0.0.2 <MTU-28>  
/bin/traceroute -s 10.0.0.1 -r -F 10.0.0.3 <MTU-28>

If "-F" option does not work, then traceroute without the "-F" parameter but
with packet that's triple the MTU size, i.e.:

/bin/traceroute -s 10.0.0.1 -r 10.0.0.1 <3 x MTU>

  
4.2 Traceroute all private nodename from local private IP with packet size of
MTU  
applies to 11gR1 and earlier example

/bin/traceroute -s 10.0.0.1 -r -F rac1p <MTU-28>  
/bin/traceroute -s 10.0.0.1 -r -F rac2p <MTU-28>  
/bin/traceroute -s 10.0.0.1 -r -F rac3p <MTU-28>

If "-F" option does not work, then run traceroute without the "-F" parameter
but with packet that's triple MTU size, i.e.:

/bin/traceroute -s 10.0.0.1 -r rac1p <3 x MTU>

  
5\. Ping VIP hostname  
# Ping of all VIP nodename should resolve to correct IP  
# Before the clusterware is installed, ping should be able to resolve VIP
nodename but  
# should fail as VIP is managed by the clusterware  
# After the clusterware is up and running, ping should succeed

/bin/ping -c 2 rac1v  
/bin/ping -c 2 rac1v  
/bin/ping -c 2 rac2v  
/bin/ping -c 2 rac2v  
/bin/ping -c 2 rac3v  
/bin/ping -c 2 rac3v

  
6\. Ping SCAN name  
# applies to 11gR2  
# Ping of SCAN name should resolve to correct IP  
# Before the clusterware is installed, ping should be able to resolve SCAN
name but  
# should fail as SCAN VIP is managed by the clusterware  
# After the clusterware is up and running, ping should succeed

/bin/ping -s <MTU> -c 2 -I 120.0.0.1 scancl1  
/bin/ping -s <MTU> -c 2 -I 120.0.0.1 scancl1  
/bin/ping -s <MTU> -c 2 -I 120.0.0.1 scancl1

  
7\. Nslookup VIP hostname and SCAN name  
# applies to 11gR2  
# To check whether VIP nodename and SCAN name are setup properly in DNS

/usr/bin/nslookup rac1v  
/usr/bin/nslookup rac2v  
/usr/bin/nslookup rac3v  
/usr/bin/nslookup scancl1

  
8\. To check name resolution order  
# /etc/nsswitch.conf on Linux, Solaris and hp-ux, /etc/netsvc.conf on AIX

/bin/grep ^hosts /etc/nsswitch.conf  
hosts: dns files

  
9\. To check local hosts file  
# If local files is in naming switch setting (nsswitch.conf), to make sure  
# hosts file doesn't have typo or misconfiguration, grep all nodename and IP  
# 127.0.0.1 should not map to SCAN name, public, private and VIP hostname

Public and node VIP:

/bin/grep rac1 /etc/hosts  
/bin/grep rac2 /etc/hosts  
/bin/grep rac3 /etc/hosts  
/bin/grep rac1v /etc/hosts  
/bin/grep rac2v /etc/hosts  
/bin/grep rac3v /etc/hosts  
/bin/grep 120.0.0.1 /etc/hosts  
/bin/grep 120.0.0.2 /etc/hosts  
/bin/grep 120.0.0.3 /etc/hosts  
/bin/grep 120.0.0.11 /etc/hosts  
/bin/grep 120.0.0.12 /etc/hosts  
/bin/grep 120.0.0.13 /etc/hosts  
  
# pre-11gR2 private example  
/bin/grep rac1p /etc/hosts  
/bin/grep rac2p /etc/hosts  
/bin/grep rac3p /etc/hosts  
/bin/grep 10.0.0.1 /etc/hosts  
/bin/grep 10.0.0.2 /etc/hosts  
/bin/grep 10.0.0.3 /etc/hosts

# 11gR2 private example  
/bin/grep 10.0.0.1 /etc/hosts  
/bin/grep 10.0.0.2 /etc/hosts  
/bin/grep 10.0.0.3 /etc/hosts  
  
  
# SCAN example  
# If SCAN name is setup in DNS, it should not be in local hosts file  
/bin/grep scancl1 /etc/hosts  
/bin/grep 120.0.0.21 /etc/hosts  
/bin/grep 120.0.0.22 /etc/hosts  
/bin/grep 120.0.0.23 /etc/hosts

### C. Syntax reference

Please refer to below for command syntax on different platform  
  
Linux:  
/bin/netstat -in  
/sbin/ifconfig  
/bin/ping -s <MTU> -c 2 -I source_IP nodename  
/bin/traceroute -s source_IP -r -F nodename-priv <MTU-28>  
/usr/bin/nslookup  
  
Solaris:  
/bin/netstat -in  
/usr/sbin/ifconfig -a  
/usr/sbin/ping -i source_IP -s nodename <MTU> 2  
/usr/sbin/traceroute -s source_IP -r -F nodename-priv <MTU>  
/usr/sbin/nslookup  
  
HP-UX:  
/usr/bin/netstat -in  
/usr/sbin/ifconfig NIC  
/usr/sbin/ping -i source_IP nodename <MTU> -n 2  
/usr/contrib/bin/traceroute -s source_IP -r -F nodename-priv <MTU>  
/bin/nslookup  
  
AIX:  
/bin/netstat -in  
/usr/sbin/ifconfig -a  
/usr/sbin/ping -S source_IP -s <MTU> -c 2 nodename  
/bin/traceroute -s source_IP -r nodename-priv <MTU>  
/bin/nslookup  
  
Windows:  
MTU:  
Windows XP: netsh interface ip show interface  
Windows Vista/7: netsh interface ipv4 show subinterfaces  
ipconfig /all  
ping -n 2 -l <MTU-28> -f nodename  
tracert  
nslookup

### D. Multicast

Started with 11.2.0.2, multicast group 230.0.1.0 should work on private
network for bootstrapping. [patch
9974223](https://support.oracle.com/epmos/faces/ui/patch/PatchDetail.jspx?parent=DOCUMENT&sourceId=1054902.1&patchId=9974223)
introduces support for another group 224.0.0.251  
  
Please refer to [note
1212703.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1054902.1&id=1212703.1)
to verify whether multicast is working fine.  
  
As fix for [bug
10411721](https://support.oracle.com/epmos/faces/BugDisplay?parent=DOCUMENT&sourceId=1054902.1&id=10411721)
is included in 11.2.0.3, broadcast is supported for bootstrapping as well as
multicast. When 11.2.0.3 Grid Infrastructure starts up, it will try broadcast,
multicast group 230.0.1.0 and 224.0.0.251 simultaneously, if anyone succeeds,
it will be able to start.  
  
  
On hp-ux, if 10 Gigabit Ethernet is used as private network adapter, without
driver revision B.11.31.1011 or later of the 10GigEthr-02 software bundle,
multicast may not work. Run "swlist 10GigEthr-02" command to identify the
current version on your HP server.  
  

  
  

### E. Runtime network issues

[OSWatcher](https://support.oracle.com/epmos/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1054902.1&id=301137.1)
or [Cluster Health
Monitor(IPD/OS)](https://support.oracle.com/epmos/otn.oracle.com/rac) can be
deployed to capture runtime network issues.  
  

### F. Symptoms of network issues

o ping doesn't work, ping packet loss or ping time is too long (not sub-
second)  
  
o traceroute doesn't work  
  
o name resolution doesn't work  
  
o traceroute output like:

1 racnode1 (192.168.30.2) 0.223 ms !X 0.201 ms !X 0.193 ms !X

o gipcd.log shows:

2010-11-21 13:00:44.455: [ GIPCNET][1252870464]gipcmodNetworkProcessConnect:
[network] failed connect attempt endp 0xc7c5590 [0000000000000356] {
gipcEndpoint : localAddr
'gipc://racnode3:08b1-c475-a88e-8387#10.10.10.23#27573', remoteAddr
'gipc://racnode2:nm_rac-cluster#192.168.0.22#26869', numPend 0, numReady 1,
numDone 0, numDead 0, numTransfer 0, objFlags 0x0, pidPeer 0, flags 0x80612,
usrFlags 0x0 }, req 0xc7c5310 [000000000000035f] { gipcConnectRequest : addr
'gipc://racnode2:nm_rac-cluster#192.168.0.22#26869', parentEn  
2010-11-21 13:00:44.455: [ GIPCNET][1252870464]gipcmodNetworkProcessConnect:
slos op : sgipcnTcpConnect  
2010-11-21 13:00:44.455: [ GIPCNET][1252870464]gipcmodNetworkProcessConnect:
slos dep : No route to host (113)

or

2010-11-04 12:33:22.133: [ GIPCNET][2314] gipcmodNetworkProcessSend: slos op :
sgipcnUdpSend  
2010-11-04 12:33:22.133: [ GIPCNET][2314] gipcmodNetworkProcessSend: slos dep
: Message too long (59)  
2010-11-04 12:33:22.133: [ GIPCNET][2314] gipcmodNetworkProcessSend: slos loc
: sendto  
2010-11-04 12:33:22.133: [ GIPCNET][2314] gipcmodNetworkProcessSend: slos info
: dwRet 4294967295, addr '19

o ocssd.log shows:

2010-02-03 23:26:25.804:
[GIPCXCPT][1206540320]gipcmodGipcPassInitializeNetwork: failed to find any
interfaces in clsinet, ret gipcretFail (1)  
2010-02-03 23:26:25.804:
[GIPCGMOD][1206540320]gipcmodGipcPassInitializeNetwork: EXCEPTION[ ret
gipcretFail (1) ] failed to determine host from clsinet, using default  
..  
2010-02-03 23:26:25.810: [ CSSD][1206540320]clsssclsnrsetup: gipcEndpoint
failed, rc 39  
2010-02-03 23:26:25.811: [ CSSD][1206540320]clssnmOpenGIPCEndp: failed to
listen on gipc addr gipc://rac1:nm_eotcs- ret 39  
2010-02-03 23:26:25.811: [ CSSD][1206540320]clssscmain: failed to open gipc
endp

or

2010-09-20 11:52:54.014: [ CSSD][1103055168]clssnmvDHBValidateNCopy: node 1,
racnode1, has a disk HB, but no network HB, DHB has rcfg 180441784, wrtcnt,
453, LATS 328297844, lastSeqNo 452, uniqueness 1284979488, timestamp
1284979973/329344894  
2010-09-20 11:52:54.016: [ CSSD][1078421824]clssgmWaitOnEventValue: after
CmInfo State val 3, eval 1 waited 0  
.. >>>> after a long delay  
2010-09-20 12:02:39.578: [ CSSD][1103055168]clssnmvDHBValidateNCopy: node 1,
racnode1, has a disk HB, but no network HB, DHB has rcfg 180441784, wrtcnt,
1037, LATS 328883434, lastSeqNo 1036, uniqueness 1284979488, timestamp
1284980558/329930254  
2010-09-20 12:02:39.895: [ CSSD][1107286336]clssgmExecuteClientRequest: MAINT
recvd from proc 2 (0xe1ad870)

o crsd.log shows:

2010-11-29 10:52:38.603: [GIPCHALO][2314] gipchaLowerProcessNode: no valid
interfaces found to node for 2614824036 ms, node 111ea99b0 { host
'aixprimusrefdb1', haName '1e0b-174e-37bc-a515', srcLuid 2612fa8e-3db4fcb7,
dstLuid 00000000-00000000 numInf 0, contigSeq 0, lastAck 0, lastValidAck 0,
sendSeq [55 : 55], createTime 2614768983, flags 0x4 }  
2010-11-29 10:52:42.299: [ CRSMAIN][515] Policy Engine is not initialized yet!  
2010-11-29 10:52:43.554: [ OCRMAS][3342]proath_connect_master:1: could not yet
connect to master retval1 = 203, retval2 = 203  
2010-11-29 10:52:43.554: [ OCRMAS][3342]th_master:110': Could not yet connect
to new master [1]

or

2009-12-10 06:28:31.974: [ OCRMAS][20]proath_connect_master:1: could not
connect to master clsc_ret1 = 9, clsc_ret2 = 9  
2009-12-10 06:28:31.974: [ OCRMAS][20]th_master:11: Could not connect to the
new master  
2009-12-10 06:29:01.450: [ CRSMAIN][2] Policy Engine is not initialized yet!  
2009-12-10 06:29:31.489: [ CRSMAIN][2] Policy Engine is not initialized yet!

or

2009-12-31 00:42:08.110: [ COMMCRS][10]clsc_receive: (102b03250) Error
receiving, ns (12535, 12560), transport (505, 145, 0)

o octssd.log shows:

2011-04-16 02:59:46.943: [ CTSS][1]clsu_get_private_ip_addresses:
clsinet_GetNetData failed (). Return [7]  
[ CTSS][1](:ctss_init6:): Failed to call clsu_get_private_ip_addr [7]  
gipcmodGipcPassInitializeNetwork: failed to find any interfaces in clsinet,
ret gipcretFail (1)  
gipcmodGipcPassInitializeNetwork: EXCEPTION[ ret gipcretFail (1) ] failed to
determine host from clsinet, using default  
[ CRSCCL][2570585920]No private IP addresses found.  
(:CSSNM00008:)clssnmCheckDskInfo: Aborting local node to avoid splitbrain.
Cohort of 1 nodes with leader 2, dc4sftestdb02, is smaller than cohort of 1
nodes led by node 1, dc4sftestdb01, based on map type 2

### G. Basics of Subnet

Refer to [note
1386709.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1054902.1&id=1386709.1)
for details  
  

## References

[NOTE:1212703.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1054902.1&id=1212703.1)
\- Grid Infrastructure Startup During Patching, Install or Upgrade May Fail
Due to Multicasting Requirement  
[NOTE:301137.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1054902.1&id=301137.1)
\- OSWatcher (Includes: [Video])  
  
  
[NOTE:1210883.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1054902.1&id=1210883.1)
\- Grid Infrastructure Redundant Interconnect and
ora.cluster_interconnect.haip  
[NOTE:341788.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1054902.1&id=341788.1)
\- Recommendation for the Real Application Cluster Interconnect and Jumbo
Frames  
[NOTE:1386709.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1054902.1&id=1386709.1)
\- The Basics of IPv4 Subnet and Oracle Clusterware  
[NOTE:1507482.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1054902.1&id=1507482.1)
\- Oracle Clusterware Cannot Start on all Nodes: Network communication with
node  missing for 90% of timeout interval  
[NOTE:752844.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1054902.1&id=752844.1)
\- RHEL3, RHEL4, OEL4: traceroute Fails with -F (do not fragment bit) Argument  
[NOTE:1056322.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=1054902.1&id=1056322.1)
\- Troubleshoot Grid Infrastructure/RAC Database installer/runInstaller Issues  
  
  


---
### ATTACHMENTS
[3eef892b44f1ef05d46f23d87bb10759]: media/How_to_Validate_Network_and_Name_Resolution_Setup_for_the_Clusterware_and_RAC_文档_ID_1054902-3.1)
[How_to_Validate_Network_and_Name_Resolution_Setup_for_the_Clusterware_and_RAC_文档_ID_1054902-3.1)](media/How_to_Validate_Network_and_Name_Resolution_Setup_for_the_Clusterware_and_RAC_文档_ID_1054902-3.1))
---
### NOTE ATTRIBUTES
>Created Date: 2018-09-17 05:17:22  
>Last Evernote Update Date: 2018-10-01 15:55:03  
>source: web.clip7  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=174541678371239  
>source-url: &  
>source-url: id=1054902.1  
>source-url: &  
>source-url: displayIndex=1  
>source-url: &  
>source-url: _afrWindowMode=0  
>source-url: &  
>source-url: _adf.ctrl-state=wpalmzgn_224#aref_section31  
>source-application: WebClipper 7  