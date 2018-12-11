# Troubleshooting gc block lost and Poor Network Performance in a RAC
Environment (文档 ID 563566.1)

|

|

**In this Document**  

| |
[Symptoms](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=174546188118179&id=563566.1&displayIndex=2&_afrWindowMode=0&_adf.ctrl-
state=wpalmzgn_265#SYMPTOM)  
---|---  
|
[Summary](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=174546188118179&id=563566.1&displayIndex=2&_afrWindowMode=0&_adf.ctrl-
state=wpalmzgn_265#aref_section11)  
---|---  
|
[Symptoms:](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=174546188118179&id=563566.1&displayIndex=2&_afrWindowMode=0&_adf.ctrl-
state=wpalmzgn_265#aref_section12)  
---|---  
|
[Cause:](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=174546188118179&id=563566.1&displayIndex=2&_afrWindowMode=0&_adf.ctrl-
state=wpalmzgn_265#aref_section13)  
---|---  
| [Global Cache Block Loss Diagnostic
Guide](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=174546188118179&id=563566.1&displayIndex=2&_afrWindowMode=0&_adf.ctrl-
state=wpalmzgn_265#aref_section14)  
---|---  
|
[Changes](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=174546188118179&id=563566.1&displayIndex=2&_afrWindowMode=0&_adf.ctrl-
state=wpalmzgn_265#CHANGE)  
---|---  
|
[Cause](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=174546188118179&id=563566.1&displayIndex=2&_afrWindowMode=0&_adf.ctrl-
state=wpalmzgn_265#CAUSE)  
---|---  
|
[Solution](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=174546188118179&id=563566.1&displayIndex=2&_afrWindowMode=0&_adf.ctrl-
state=wpalmzgn_265#FIX)  
---|---  
| [Community Discussions  
  
](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=174546188118179&id=563566.1&displayIndex=2&_afrWindowMode=0&_adf.ctrl-
state=wpalmzgn_265#aref_section41)  
---|---  
|
[References](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=174546188118179&id=563566.1&displayIndex=2&_afrWindowMode=0&_adf.ctrl-
state=wpalmzgn_265#REF)  
---|---  
  
* * *

## Applies to:

Oracle Database - Enterprise Edition - Version 9.2.0.1 and later  
Information in this document applies to any platform.  
Oracle Clusterware & Oracle Real Application Clusters  
  
  

## Symptoms

### Summary

In Oracle RAC environments, RDBMS gathers global cache work load statistics
which are reported in STATSPACK, AWRs and GRID CONTROL. Global cache lost
blocks statistics ("gc cr block lost" and/or "gc current block lost") for each
node in the cluster as well as aggregate statistics for the cluster represent
a problem or inefficiencies in packet processing for the interconnect traffic.
These statistics should be monitored and evaluated regularly to guarantee
efficient interconnect Global Cache and Enqueue Service (GCS/GES) and cluster
processing. Any block loss indicates a problem in network packet processing
and should be investigated.  
  
The vast majority of escalations attributed to RDBMS global cache lost blocks
can be directly related to faulty or mis-configured interconnects. This
document serves as guide for evaluating and investigating common (and
sometimes obvious) causes.  
  
Even though much of the discussion focuses on Performance issues, it is
possible to get a node/instance eviction due to these problems. Oracle
Clusterware & Oracle RAC instances rely on heartbeats for node memberships. If
network Heartbeats are consistently dropped, Instance/Node eviction may occur.
The Symptoms below are therefore relevant for Node/Instance evictions.

### Symptoms:

> Primary:

>   * "gc cr block lost" / "gc current block lost" in top 5 or significant
wait event

>

> Secondary:

>   * SQL traces report multiple gc cr requests / gc current request /

>   * gc cr multiblock requests with long and uniform elapsed times

>   * Poor application performance / throughput

>   * Packet send/receive errors as displayed in ifconfig or vendor supplied
utility

>   * Netstat reports errors/retransmits/reassembly failures

>   * Node failures and node integration failures

>   * Abnormal cpu consumption attributed to network processing

>

NOTE: lost block problems often occur with gc cr multiblock waits, i.e. waits
for scans of consecutive blocks

### Cause:

  * Probable causes are noted in the Diagnostic Guide below (ordered by most likely to least likely cause)

### Global Cache Block Loss Diagnostic Guide

    1. **Faulty or poorly seated cables/cards/Switches**  
  
 **Description** : Faulty network cable connections, the wrong cable, poorly
constructed cables, excessive length and wrong port assignments, faulty switch
can result in inferior bit rates, corrupt frames, dropped packets and poor
performance.  
  
 **Action:** Engage network vendor to perform physical network checking,
replace faulty network parts. CAT 5 grade cables or better should be deployed
for interconnect links. All cables should be securely seated and labeled
according to LAN/port and aggregation, if applicable. Cable lengths should
conform to vendor ethernet specifics.

    2. **Poorly sized UDP receive (rx) buffer sizes / UDP buffer socket overflows**

**Description:** Oracle RAC Global cache block processing is bursty in nature
and, consequently, the OS may need to buffer receive(rx) packets while waiting
for CPU. Unavailable buffer space may lead to silent packet loss and global
cache block loss. 'netstat -s' or 'netstat -su' on most UNIX will help
determine UDPInOverflows, packet receive errors, dropped frames, or packets
dropped due to buffer full errors.  
  
 **Action:** Packet loss is often attributed to inadequate( rx) UDP buffer
sizing on the recipient server, resulting in buffer overflows and global cache
block loss. The UDP receive (rx) buffer size for a socket is set to 128k when
Oracle opens the socket when the OS setting is less than 128k. If the OS
setting is larger than 128k Oracle respects the value and leaves it unchanged.
The UDP receive buffer size will automatically increase according to database
block sizes greater than 8k, but will not increase beyond the OS dependent
limit. UDP buffer overflows, packet loss and lost blocks may be observed in
environments where there are excessive timeouts on "global cache cr requests"
due to inadequate buffer setting when DB_FILE_MULTIBLOCK_READ_COUNT is greater
than 4. To alleviate this problem, increase the UDP buffer size and decrease
the DB_FILE_MULTIBLOCK_READ_COUNT for the system or active session.  
  
To determine if you are experiencing UDP socket buffer overflow and packet
loss, on most UNIX platforms, execute  
  

'netstat -s' or 'netstat -su' and look for either
"udpInOverflowsudpInOverflows", "packet receive errors", "fragments dropped"
or "outgoing packet drop" depending on the platform.

  

NOTE: UDP packet loss usually results in increased latencies, decreased
bandwidth, increased cpu utilization (kernel and user), and memory consumption
to deal with packet retransmission.  
  
If there is a significant increases in "outgoing packets dropped" in the TCP
section of netstat -s output on the nodes remote to where the workload is
running, increase the wmem_default and wmem_max both to 4MB (Linux) could
resolve the issue.  
  
UDP send and receive buffere parameters are OS dependent, they can be modified
in rolling fashion (eg: 1 node at a time).

    3. **Poor interconnect performance and high cpu utilization. `netstat -s` reports packet reassembly failures**

**Description:** Large UDP datagrams may be fragmented and sent in multiple
frames based on Maximum Transmission Unit (MTU) size. These fragmented packets
need to be reassembled on the receiving node. High CPU utilization (sustained
or frequent spikes), inadequate reassembly buffers and UDP buffer space can
cause packet reassembly failures. `netstat -s` reports a large number of
Internet Protocol (IP) "reassembles failed" and "fragments dropped after
timeout" in the "IP Statistics" section of the output on the receiving node.
Fragmented packets have a time-to-live for reassembly. Packets that are not
reassembled are dropped and requested again. Fragments that arrive and there
is no space for reassembly are silently dropped

  

`netstat -s` IP stat counters:  
3104582 fragments dropped after timeout  
34550600 reassemblies required  
8961342 packets reassembled ok  
3104582 packet reassembles failed.

  
**Action:** Increase fragment reassembly buffers, allocating more space for
reassembly. Increase the time to reassemble packet fragment., increase udp
receive buffers to accommodate network processing latencies that aggravate
reassembly failures and identify CPU utilization that negatively impacts
network stack processing.  
**Note** , increase the following settings will also increase the memory
usage.  
  

On LINUX:  
To modify reassembly buffer space, change the following thresholds:  
  
/proc/sys/net/ipv4/ipfrag_low_thresh (default = 196608)  
/proc/sys/net/ipv4/ipfrag_high_thresh (default = 262144)  
  
To modify packet fragment reassembly times, modify:  
/proc/sys/net/ipv4/ipfrag_time (default = 30)  
  
see your OS for the equivalent command syntax. Please note, above is not
applicable for RHEL 6.6. Please refer to "RHEL 6.6: IPC Send timeout/node
eviction etc with high packet reassembles failure" [Note
2008933.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=563566.1&id=2008933.1).

    4. **Network packet corruption resulting from UDP checksum errors and/or send (tx) / receive (rx) transmission errors**

**Description:** UDP includes a checksum field in the packet header which is
read on receipt. Any corruption of the checksum results in silent dropped
packets. Checksum corruptions result in packet retransmissions, additional cpu
overhead for the additional request and latencies in packet processing.

**Action:** Use tcpdump/snoop/network utilities sniffer utility to capture
packet dumps to identify checksum errors and confirm checksum corruption.
Engage sysadmins and network engineers for root cause. Checksum offloading on
NICs have been known to create checksum errors. Consider disabling the NIC
checksum offloading, if configured, and test. On LINUX **ethtool -K <IF> rx
off tx off **disables the checksum offloading.

    5. **Mismatched MTU sizes in the communication path**

**Description:** Mismatched MTU sizes cause "packet too big" failures and
silent packet loss resulting in global cache block loss and excessive packet
retransmission requests.  
 **Action:** The MTU is the "Maximum Transmission Unit" or frame size
configured for the interconnect interfaces. The default standard for most UNIX
is 1500 bytes for Ethernet. MTU definitions should be identical for all
devices in the interconnect communication path. Identify and monitor all
devices in the interconnect communication path. Use large, non-default sized,
ICMP probe packets for` ping`, `tracepath` or `traceroute` to detect
mismatched MTUs in the path. Use `ifconfig` or vendor recommended utilities to
determine and set MTU sizes for the server NICS. See Jumbo Frames #12 below.
Note: Mismatched MTU sizes for the interconnect will inhibit nodes joining the
cluster in 10g and 11g.

    6. **Interconnect LAN non-dedicated**

**Description:** Shared public IP traffic and/or shared NAS IP traffic,
configured on the interconnect LAN will result in degraded application
performance, network congestion and, in extreme cases, global cache block
loss.  
 **Action:** The interconnect/clusterware traffic should be on a dedicated LAN
defined by a non-routed subnet. Interconnect traffic should be isolated to the
adjacent switch(es), e.g. interconnect traffic should not extend beyond the
access layer switch(es) to which the links are attached. The interconnect
traffic should not be shared with public or NAS traffic. If Virtual LANs
(VLANS) are used, the interconnect should be on a single, dedicated VLAN
mapped to a dedicated, non-routed subnet, which is isolated from public or NAS
traffic.

    7. **Lack of Server/Switch Adjacency**

**Description:** Network devices are said to be "adjacent" if they can reach
each other with a single hop across a link layer. Multiple hops add latency
and introduce unnecessary complexity and risk when other network devices are
in the communication path.  
 **Action:** All GbE server interconnect links should be (OSI) layer 2 direct
attach to the switch or switches (if redundant switches are configured). There
should be no intermediary network device, such as a router, in the
interconnect communication path. The unix command `traceroute` will help
identify adjacency issues.

    8. **IPFILTER configured**

**Description** :IPFILTER (IPF) is a host based firewall or Network Address
Translation (NAT) software package that has been identified to create problems
for interconnect traffic. IPF may contribute to severe application performance
degradation, packet loss and global cache block loss.  
 **Action:** disable IPFILTER

    9. **Outdated Network driver or NIC firmware**

**Description:** Outdated NIC drivers or firmware have been known to cause
problems in packet processing across the interconnect. Incompatible NIC
drivers in inter-node communication may introduce packet processing latencies,
skewed latencies and packet loss.  
 **Action:** Server NICs should be the same make/model and have identical
performance characteristics on all nodes and should be symmetrical in slot id.
Firmware and NIC drivers should be at the same (latest) rev. for all server
interconnect NICs in the cluster.

    10. **Proprietary interconnect link transport and network protocol**

**Description:** Non-standard, proprietary protocols, such as LLT, HMP,etc,
have proven to be unreliable and difficult to debug. Miss-configured
proprietary protocols have caused application performance degradation, dropped
packets and node outages.  
 **Action:** Oracle has standardized on 1GbE UDP as the transport and
protocol. This has proven stable, reliable and performant. Proprietary
protocols and substandard transports should be avoided. IP and RDS on
Infiniband are available and supported for interconnect network deployment and
10GbE has been certified for some platforms (see OTN for details) -
certification in this area is ongoing.

    11. **Misconfigured bonding/link aggregation**

**Description:** Failure to correctly configure NIC Link Aggregation or
Bonding on the servers or failure to configure aggregation on the adjacent
switch for interconnect communication can result in degraded performance and
block loss due to "port flapping", interconnect ports on the switch forming an
aggregated link frequently change "UP"/"DOWN" state.  
 **Action:** If using link aggregation on the clustered servers, the ports on
the switch should also support and be configured for link aggregation for the
interconnect links. Failure to correctly configure aggregation for
interconnect ports on the switch would result in 'port flapping', switch ports
randomly dropping, resulting in packet loss.  
Bonding/Aggregation should be correctly configured per driver documentation
and tested under load. There are a number of public domain utilities that help
to test and measure link bandwidth and latency performance (see iperf). OS,
network and network driver statistics should be evaluated to determine
efficiency of bonding.

    12. **Misconfigured Jumbo Frames**

**Description:** Misconfigured Jumbo Frames may create mismatched MTU sizes
described above.  
 **Action:** Jumbo Frames are IEEE non-standard and as a consequence, care
should be taken when configuring. A Jumbo Frame is a frame size around
9000bytes. Frame size may vary depending on network device vendor and may not
be consistent between communicating devices. An identical maximum transport
unit (MTU) size should be configured for all devices in the communication path
if the default is not 9000 bytes. All the network devices , switches/NICS/line
cards, in operation must be configured to support the same frame size (MTU
size). Mismatched MTU sizes, where the switch may be configured to be MTU:1500
but the server interconnect interfaces are configured to be MTU:9000 will lead
to packet loss, packet fragmentation and reassembly errors which cause severe
performance degradation and cluster node outages. The IP stats in `netstat -s`
on most platforms will identify frame fragmentation and reassembly errors. The
command `ifconfig -a`, on most platforms, will identify the frame size in use
(MTU:1500). See the switch vendors documentation to identify Jumbo Frames
support.

    13. **NIC force full duplex and duplex mode mismatch**

**Description:** Duplex mode mismatch is when two nodes in a communication
channel are operating at half-duplex on one end and full duplex on the other.
This may be manually misconfigured duplex modes or, one end configured
manually to be half-duplex while the communication partner is autonegotiate.
Duplex mode mismatch results in severely degraded interconnect communication.  
 **Action:** Duplex mode should be set to autonegotiate for all Server NICs in
the cluster *and* line cards on the switch(es) servicing the interconnect
links. Gigabit ethernet standards require autonegotiation set to "on" in order
to operate. Duplex mismatches can cause severe network degradation, collisions
and dropped packets. Autonegotiate duplex modes should be confirmed after
every hardware/software upgrade affecting the network interfaces.
Autonegotiate on all interfaces will operate at 1000 full duplex.

    14. **Flow-control mismatch in the interconnect communication path**

**Description:** Flow control is the situation when a server may be
transmitting data faster than a network peer (or network device in the path)
can accept it. The receiving device may send a PAUSE frame requesting the
sender to temporarily stop transmitting.  
 **Action:** Flow-control mismatches between switches and NICs on Servers, can
result in lost packets and severe interconnect network performance
degradation. In most cases the default setting of "ON" will yield best
results, e.g:  
  

tx flow control should be turned on  
rx flow control should be turned on  
tx/rx flow control should be turned on for the switch(es)

  
However, in some specific cases (e.g. [Note
400959.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=563566.1&id=400959.1)),
such as bugs in OS drivers or switch firmware, a setting of OFF (on all
network path) will yield better results.  

NOTE: Flow control definitions may change after firmware/network driver
upgrades. NIC & Switch settings should be verified after any upgrade. Use
default settings unless hardware vendor suggests otherwise.

    15. **Packet drop at the OS, NIC or switch layer**

**Description:** Any packet drop as reported by OS, NIC or switch should be
thoroughly investigated and resolved. Packet loss can result in degraded
interconnect performance, cpu overhead and network/node outages.  
 **Action:** Specific tools will help identify which layer you are
experiencing the packet/frame loss (process/OS/Network/NIC/switch). netstat,
ifconfig, ethtool, kstat (depending on the OS) and switch port stats would be
the first diagnostics to evaluate.You may need to use a network sniffer to
trace end-to-end packet communication to help isolate the problem (see public
domain tools such as snoop/wireshare/ethereal). Note, understanding packet
loss at the lower layers may be essential to determining root cause. Under
sized ring buffers or receive queues on a network interface are known to cause
silent packet loss, e.g. packet loss that is not reported at any layer. See
NIC Driver Issues and Kernel queue lengths below. Engage your systems
administrator and network engineers to determine root cause.  
For system using multiple private interconnects and Linux Kernel 2.6.32+,
please check out [Note
1286796.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=563566.1&id=1286796.1).

    16. **NIC Driver/Firmware Configuration**

**Description:** Misconfigured or inadequate default settings for tunable NIC
public properties may result in silent packet loss and increased
retransmission requests.  
 **Action:** Default factory settings should be satisfactory for the majority
of network deployments. However, there have been issues with some vendor NICs
and the nature of interconnect traffic that have required modifying interrupt
coalescence settings and the number of descriptors in the ring buffers
associated with the device. Interrupt coalescence is the CPU interrupt rate
for send (tx) and receive (rx) packet processing. The ring buffers hold rx
packets for processing between CPU interrupts. Misconfiguration at this layer
often results in silent packet loss. Diagnostics at this layer require
sysadmin and OS/Vendor intervention.

    17. **NIC send (tx) and receive (rx) queue lengths**

**Description:** Inadequately sized NIC tx/rx queue lengths may silently drop
packets when queues are full. This results in gc block loss, increased packet
retransmission and degraded interconnect performance.  
 **Action:** As packets move between the kernel network subsystem and the
network interface device driver, send (tx) and receive (rx) queues are
implemented to manage packet transport and processing. The size of these
queues are configurable. If these queues are underconfigured or misconfigured
for the amount of network traffic generated or MTU size configured, full
queues will cause overflow and packet loss. Depending on the driver and
quality of statistics gathered for the device, this packet loss may not be
easy to detect. Diagnostics at this layer require sysadmin and OS/Vendor
intervention. (c.f. iftxtqueue and netdev_max_backlog on linux)

    18. **Limited capacity and over-saturated bandwidth**

**Description:** Oversubscribed network usage will result in interconnect
performance degradation and packet loss.  
 **Action:** An interconnect deployment best practice is to know your
interconnect usage and bandwidth. This should be monitored regularly to
identify usage trends, transient or constant. Increasing demands on the
interconnect may be attributed to scaling the application or aberrant usage
such a bad sql or unexpected traffic skew. Assess the cause of bandwidth
saturation and address it.

    19. **Over subscribed CPU and scheduling latencies**

**Description:** Sustained high load averages and network stack scheduling
latencies can negatively effect interconnect packet processing and result in
interconnect performance degradation, packet loss, gc block loss and potential
node outages.  
 **Action:** Scheduling delays when the system is under high CPU utilization
can cause delays in network packet processing. Excessive, sustained latencies
will cause severe performance degradation and may cause cluster node failure.
It is critical that sustained elevated CPU utilization be investigated. The
`uptime` command will display load average information on most platforms.
Excessive CPU interrupts associated with network stack processing may be
mitigated through NIC interrupt coalescence and/or binding network interrupts
to a single CPU. Please work with NIC vendors for these types of
optimizations. Scheduling latencies can result in reassembly errors. See #2
above.

    20. **Switch related packet processing problems**

**Description:** Buffer overflows on the switch port, switch congestion and
switch misconfiguration such as MTU size, aggregation and Virtual Land
definitions (VLANs) can lead to inefficiencies in packet processing resulting
in performance degradation or cluster node outage.  
 **Action:** The Oracle interconnect requires a switched Ethernet network. The
switch is a critical component in end-to-end packet communication of
interconnect traffic. As a network device, the switch may be subject to many
factors or conditions that can negatively impact interconnect performance and
availability. It is critical that the switch be monitored for abnormal, packet
processing events, temporary or sustained traffic congestion and efficient
throughput. Switch statistics should be evaluated at regular intervals to
assess trends in interconnect traffic and to identify anomalies.

    21. **QoS which negatively impacts the interconnect packet processing**

**Description:** Quality of Service definitions on the switch which shares
interconnect traffic may negatively impact interconnect network processing
resulting in severe performance degradation  
 **Action:** If the interconnect is deployed on a shared switch segmented by
VLANs, any QoS definitions on the shared switch should be configured such that
prioritization of service does not negatively impact interconnect packet
processing. Any QoS definitions should be evaluated prior to deployment and
impact assessed.

    22. **Spanning tree brownouts during reconvergence** **.**

**Description:** Ethernet networks use a Spanning Tree Protocol (STP) to
ensure a loop-free topology where there are redundant routes to hosts. An
outage of any network device participating in an STP topology is subject to a
reconvergence of the topology which recalculates routes to hosts. If STP is
enabled in the LAN and misconfigured or unoptimized, a network reconvergence
event can take up to 1 minute or more to recalculate (depending on size of
network and participating devices). Such latencies can result in interconnect
failure and cluster wide outage.  
 **Action:** Many switch vendors provide optimized extensions to STP enabling
faster network reconvergence times. Optimizations such as Rapid Spanning Tree
(RSTP), Per-VLAN Spanning Tree (PVST), and Multi-Spanning Tree (MSTP) should
be deployed to avoid a cluster wide outage.

    23. **sq_max_size inadequate for STREAMS queuing**

**Description:** AWR reports high waits for "gc cr block lost" and/or "gc
current block lost". netstat output does not reveal any packet processing
errors. `kstat -p -s '*nocanput*` returns non-zero values. nocanput indicates
that queues for streaming messages are full and packets are dropped. Customer
is running STREAMS in a RAC in a Solaris env.  
 **Action:** Increasing the udp max buffer space and defining unlimited
STREAMS queuing should relieve the problem and eliminate "nocanput" lost
messages. The following are the Solaris commands to make these changes:  
  

`ndd -set /dev/udp udp_max_buf <NUMERIC VALUE>`  
set sq_max_size to 0 (unlimited) in /etc/system. Default = 2

  
udp_max_buf controls how large send and receive buffers (in bytes) can be for
a UDP socket. The default setting, 262,144 bytes, may be inadequate for
STREAMS applications. sq_max_size is the depth of the message queue.  
  

    24. **For AIX platform only, VIPA and DGD setting incorrect**  
  
If Virtual IP Address (VIPA) is used for cluster_interconnect for AIX
platform, then Dead Gateway Detection (DGD) must be configed to allow UDP
failover.  
The default DGD parameters are recommended as a starting point, but may need
to be tuned based on customer environment, however in all cases must be set to
a value greater than one. The default settings are:  
dgd_packets_lost = 3  
dgd_ping_time = 5  
dgd_retry_time = 5  
  
Refer to Using VIPA and Dead Gateway Detection on AIX for High Availability
Networks, including Oracle RAC  
http://www-01.ibm.com/support/docview.wss?uid=tss1wp102177 for more
information.  
  

    25. **For Solaris + Veritas LLT environment, misconfigured switch  
  
** It is observed from VCS command lltstat, whenever "Snd retransmit data"
increases, gc block lost count also increases.  
Change the interconnect switch speed from fixed to auto-negotiate and in the
interconnect switch, distribute the cables more evenly to each modules, helps
to stop the "gc blocks lost". **  
  
  
**

    26. **For 12.1.0.2,[Bug 20922010](https://support.oracle.com/epmos/faces/BugDisplay?parent=DOCUMENT&sourceId=563566.1&id=20922010) FALSE 'GC BLOCKS LOST' REPORTED ON 12.1 AFTER UPGRADING FROM 11.2.0.3**   
  
It has been fixed in 12.1.0.2.161018 and 12.2.0.1, please refer to the
following documents for more information:  
[Note
20922010.8](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=563566.1&id=20922010.8)
Bug 20922010 - False 'gc blocks lost' reported on 12.1 after upgrading from
11.2  
[Note
2096299.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=563566.1&id=2096299.1)
False increase of 'Global Cache Blocks Lost' or 'gc blocks lost' after upgrade
to 12c

  
  

## Changes

As explained above, Lost blocks are generally caused by unreliable Private
network. This can be caused by a bad patch or faulty network configuration or
hardware issue.

## Cause

In most cases, gc block lost has been attributed to (a) A missing OS patch (b)
Bad network card (c) Bad cable (d) Bad switch (e) One of the network settings.
Customer should open a ticket with their OS vendor and provide them the
OSwatcher output.

## Solution

Customers should start collecting OSwatcher data (see [Note
301137.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=563566.1&id=301137.1)).

This data should be shared with OS vendor to find root cause of the problem.

KEYWORDS: GC_BLOCKS_LOST, block loss, interconnect, eviction  
RAC, node failure, poor performance, evictions, gc_blocks_lost, RAC
Performance

### Community Discussions  
  

Still have questions? Use the communities window below to search for similar
discussions or start a new discussion on this subject.  
  
Note: Window is the **LIVE** community not a screenshot.  
  
Click
[here](https://community.oracle.com/community/support/oracle_database/database_-
_rac_scalability "Database - RAC/Scalability Community") to open in main
browser window.  
  

## References

[NOTE:400959.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=563566.1&id=400959.1)
\- LINUX: POOR RAC-INTERCONNECT PERFORMANCE AFTER UPGRADE FROM RHEL3 TO
RHEL4/OEL4  
[NOTE:1286796.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=563566.1&id=1286796.1)
\- rp_filter for multiple private interconnects and Linux Kernel 2.6.32+  
[NOTE:301137.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=563566.1&id=301137.1)
\- OSWatcher (Includes: [Video])  


---
### NOTE ATTRIBUTES
>Created Date: 2018-09-17 05:22:08  
>Last Evernote Update Date: 2018-10-01 15:40:46  
>source: web.clip7  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=174546188118179  
>source-url: &  
>source-url: id=563566.1  
>source-url: &  
>source-url: displayIndex=2  
>source-url: &  
>source-url: _afrWindowMode=0  
>source-url: &  
>source-url: _adf.ctrl-state=wpalmzgn_265#aref_section14  
>source-application: WebClipper 7  