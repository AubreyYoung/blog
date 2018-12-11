# Document 2080965.1

  

|

|

 **In this Document**  

| |
[Goal](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=251926624720467&id=2080965.1&_adf.ctrl-
state=10wthajhli_72#GOAL)  
---|---  
|
[Solution](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=251926624720467&id=2080965.1&_adf.ctrl-
state=10wthajhli_72#FIX)  
---|---  
|
[References](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=251926624720467&id=2080965.1&_adf.ctrl-
state=10wthajhli_72#REF)  
---|---  
  
* * *

## Applies to:

Linux OS - Version Oracle Linux 7.0 and later  
Information in this document applies to any platform.  

## Goal

On Oracle Linux 7, a new naming scheme is introduced, check
[details](https://docs.oracle.com/cd/E52668_01/E54669/html/ol7-nic-names.html
"ol7-nic-names").

For instance:

# ip addr show  
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN  
link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00  
inet 127.0.0.1/8 scope host lo  
inet6 ::1/128 scope host  
valid_lft forever preferred_lft forever  
2: **eno1** : <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
state UP qlen 1000  
link/ether **6c:0b:84:6c:48:1c** brd ff:ff:ff:ff:ff:ff  
inet 10.10.10.11/24 brd 10.10.10.255 scope global eno1  
inet6 2606:b400:c00:48:6e0b:84ff:fe6c:481c/128 scope global dynamic  
valid_lft 2326384sec preferred_lft 339184sec  
inet6 fe80::6e0b:84ff:fe6c:481c/64 scope link  
valid_lft forever preferred_lft forever

This document describes how to revert to legacy naming scheme with Network
Interface names as eth0, eth1, etc.

## Solution

1\. Edit kernel boot parameter.  
Edit file _**/etc/default/grub**_ and append **net.ifnames=0** to line
**GRUB_CMDLINE_LINUX** , for instance:

GRUB_CMDLINE_LINUX=" crashkernel=auto **net.ifnames=0** rhgb quiet"

Regenerate a GRUB configuration file and overwrite existing one:

# grub2-mkconfig -o /boot/grub2/grub.cfg

2\. Edit udev network rule.  
Edit file _**/etc/udev/rules.d/70-persistent-net.rules** _ (create file if not
exist) with below line:

SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="
**6c:0b:84:6c:48:1c** ", ATTR{type}=="1", KERNEL=="eth*", NAME="eth0"

3\. Correct ifcfg file configuration:  
Edit **NAME** and **DEVICE** parameters in ifcfg file to new Network Interface
name.

# cat /etc/sysconfig/network-scripts/ifcfg-eno1  
(snip)  
NAME=eth0  
(snip)  
DEVICE=eth0  
(snip)

Edit ifcfg file name:

# mv /etc/sysconfig/network-scripts/ifcfg-eno1 /etc/sysconfig/network-
scripts/ifcfg-eth0

4\. Disable NetworkManager

# systemctl disable NetworkManager

5\. Reboot system.

## References

<https://docs.oracle.com/cd/E52668_01/E54669/html/ol7-nic-names.html>  
  
  
  



---
### TAGS
{network}

---
### NOTE ATTRIBUTES
>Created Date: 2017-08-29 02:39:09  
>Last Evernote Update Date: 2018-10-01 15:59:04  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=251926624720467  
>source-url: &  
>source-url: id=2080965.1  
>source-url: &  
>source-url: _adf.ctrl-state=10wthajhli_72  