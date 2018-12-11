
#  Why does traceroute timeout(*) if re-run in less than 3 seconds in RHEL?

## 环境

- Red Hat Enterprise Linux

## 问题

- Running **traceroute** the first time works normally:
```
# traceroute 192.168.10.10 
traceroute to 192.168.10.10 (192.168.10.10), 30 hops max, 60 byte packets
 1  192.168.10.10 (192.168.10.10)  0.118 ms  0.114 ms  0.110 ms
# 
```

- Re-running the command immediately(in less than 3 seconds) returns "*":

```
# traceroute 192.168.10.10 
traceroute to 192.168.10.10 (192.168.10.10), 30 hops max, 60 byte packets
 1  * * *
 2  * * *
 3  * * *
 4  * * *
 5  * * *
 6  * 192.168.10.10 (192.168.10.10)  0.095 ms  0.084 ms
```

- The Oracle RAC installations does this test during the setup. If the test fails, the set up won't start.

## 决议

**traceroute** is used to find out the number of hops or routers/gateway between the source and destination. In this case, the source and destination both lie on the same subnet or VLAN

In such cases, either of the following options will help:

- sends out ICMP packets instead of the default UDP using the option '-I' :

```
# traceroute 192.168.10.10  -I
```

- slow down the program’s work by '-z' option, for example use -z 0.5 for half-second pause between probes:

```
# traceroute 192.168.10.10 -z 0.5
```

- restrict the number of probe sent out simultaneously to 1 using the option '-N':

```
# traceroute 192.168.10.10  -N 1
```

## 根源

This is what the traceroute does when executed:

- To speed up work, normally several probes are sent simultaneously; it sends a total of 16 probes(3 per TTL 1 to 5; and 1 for TTL 6) simultaneously
- This creates a storm of UDP packets to the destination that lies on the same subnet. As a result, the target host will drop some of the simultaneous probes, and might even answer only the latest ones. It can lead to extra "looks like expired" hops near the final hop.