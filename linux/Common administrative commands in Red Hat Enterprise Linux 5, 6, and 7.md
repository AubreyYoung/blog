# Common administrative commands in Red Hat Enterprise Linux 5, 6, and 7

Updated April 12 2017 at 11:20 AM - [English](https://access.redhat.com/articles/1189123)

## System basics

| Task                          | RHEL5                                                        | RHEL6                                                    | RHEL7                                                        |
| ----------------------------- | ------------------------------------------------------------ | -------------------------------------------------------- | ------------------------------------------------------------ |
| View subscription information | /etc/sysconfig/rhn/systemid                                  | /etc/sysconfig/rhn/systemidsubscription-manager identity | subscription-manager identity                                |
| Configure subscription        | rhn_registersubscription-manager [1](https://access.redhat.com/articles/1189123#fn:1) | rhn_registerrhnreg_kssubscription-manager                | subscription-manager[2](https://access.redhat.com/articles/1189123#fn:2)rhn_register [3](https://access.redhat.com/articles/1189123#fn:3) |
| View RHEL version information | /etc/redhat-release                                          |                                                          |                                                              |
| View system profile           | sosreportdmidecodehwbrowser                                  | sosreportdmidecodelstopolscpu                            |                                                              |

## Basic configuration

| Task                           | RHEL5                                                        | RHEL6                              | RHEL7 |
| ------------------------------ | ------------------------------------------------------------ | ---------------------------------- | ----- |
| Graphical configuration tools  | system-config-*                                              | gnome-control-center               |       |
| Text-based configuration tools | system-config-*-tui                                          |                                    |       |
| Configure printer              | system-config-printer                                        |                                    |       |
| Configure network              | system-config-network                                        | nmclinmtuinm-connection-editor     |       |
| Configure system language      | system-config-language                                       | localectl                          |       |
| Configure time and date        | system-config-datedate                                       | timedatectldate                    |       |
| Synchronize time and date      | ntpdate/etc/ntp.conf                                         | timedatectl/etc/chrony.confntpdate |       |
| Configure keyboard             | system-config-keyboard                                       | localectl                          |       |
| Configure SSH                  | /etc/ssh/ssh_config/etc/ssh/sshd_config~/.ssh/config ssh-keygen |                                    |       |

## Jobs and services

| Task                                            | RHEL5                                                        | RHEL6                                                        | RHEL7                                                        |
| ----------------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| List all services                               | chkconfig --listls /etc/init.d/                              | systemctl -at servicels /etc/systemd/system/*.servicels /usr/lib/systemd/system/*.service |                                                              |
| List running services                           | service --status-all                                         | systemctl -t service --state=active                          |                                                              |
| Start/stop service                              | service name startservice name stop                          | systemctl start name.servicesystemctl stop name.service      |                                                              |
| Enable/disable service                          | chkconfig name onchkconfig name off                          | systemctl enable name.servicesystemctl disable name.service  |                                                              |
| View service status                             | service name status                                          | systemctl status name.service                                |                                                              |
| Check if service is enabled                     | chkconfig name --list                                        | systemctl is-enabled name                                    |                                                              |
| Create new service file or modify configuration | chkconfig --add                                              | systemctl daemon-reload/etc/systemd/system/*.service         |                                                              |
| View run level/target                           | runlevelwho -r                                               | systemctl get-defaultwho -r                                  |                                                              |
| Change run level/target                         | /etc/inittabinit run_level                                   | systemctl isolate name.targetsystemctl set-default           |                                                              |
| Configure logging                               | /etc/syslog.conf                                             | /etc/rsyslog.conf                                            | /etc/rsyslog.conf/etc/rsyslog.d/*.conf/var/log/journalsystemd-journald.service |
| View logs                                       | /var/log                                                     | /var/logjournalctl                                           |                                                              |
| Configure system audit                          | add audit=1 to kernel cmdlineauditctl/etc/audit/auditd.conf/etc/audit/audit.rulesauthconfig/etc/pam.d/system-authpam_tty_audit kernel module |                                                              |                                                              |
| View audit output                               | aureport /var/log/faillog                                    |                                                              |                                                              |
| Schedule/batch tasks                            | cronatbatch                                                  |                                                              |                                                              |
| Find file by name                               | locate                                                       |                                                              |                                                              |
| Find file by characteristic                     | find                                                         |                                                              |                                                              |
| Create archive                                  | tarcpiozip                                                   |                                                              |                                                              |

## Kernel, boot, and hardware

| Task                               | RHEL5                                             | RHEL6                                               | RHEL7 |
| ---------------------------------- | ------------------------------------------------- | --------------------------------------------------- | ----- |
| Single user/rescue mode            | append 1 or s or init=/bin/bash to kernel cmdline | append rd.break or init=/bin/bash to kernel cmdline |       |
| Shut down system                   | shutdown                                          |                                                     |       |
| Power off system                   | poweroff                                          | poweroffsystemctl poweroff                          |       |
| Halt system                        | halt                                              | haltsystemctl halt                                  |       |
| Reboot system                      | reboot                                            | rebootsystemctl reboot                              |       |
| Configure default run level/target | /etc/inittab                                      | systemctl set-default                               |       |
| Configure GRUB bootloader          | /boot/grub/grub.conf                              | /etc/default/grubgrub2-mkconfiggrub-set-default     |       |
| Configure kernel module            | modprobe                                          |                                                     |       |
| View hardware configured           | hwbrowser                                         | lshw (in EPEL)                                      |       |
| Configure hardware device          | udev                                              |                                                     |       |
| View kernel parameters             | sysctl -acat /proc/cmdline                        |                                                     |       |
| Load kernel module                 | modprobe                                          |                                                     |       |
| Remove kernel module               | modprobe -r                                       |                                                     |       |
| View kernel version                | rpm -q kerneluname -r                             |                                                     |       |

## Software management

| Task                          | RHEL5                                             | RHEL6                        | RHEL7 |
| ----------------------------- | ------------------------------------------------- | ---------------------------- | ----- |
| Install software              | yum installyum groupinstall                       | yum installyum group install |       |
| View software info            | yum infoyum groupinfo                             | yum infoyum group info       |       |
| Update software               | yum update                                        |                              |       |
| Upgrade software              | yum upgrade                                       |                              |       |
| Configure software repository | subscription-manager repos/etc/yum.repos.d/*.repo |                              |       |
| Find package owning file      | rpm -qf filenameyum provides filename-glob        |                              |       |
| View software version         | rpm -q packagename                                |                              |       |
| View installed software       | rpm -qayum list installed                         |                              |       |

## User management

| Task                             | RHEL5                    | RHEL6 | RHEL7 |
| -------------------------------- | ------------------------ | ----- | ----- |
| Graphical user management        | system-config-users      |       |       |
| Create user account              | useradd                  |       |       |
| Delete user account              | userdel                  |       |       |
| View/change user account details | usermod/etc/passwdvipwid |       |       |
| Create user group                | groupadd                 |       |       |
| Delete user group                | groupdel                 |       |       |
| Change group details             | groupmod/etc/group       |       |       |
| Change user password             | passwd                   |       |       |
| Change user permissions          | usermodvisudo            |       |       |
| Change group permissions         | groupmodvisudo           |       |       |
| Change password policy           | chage                    |       |       |
| View user sessions               | w                        |       |       |

## File systems, volumes, and disks

| Task                                               | RHEL5                                                        | RHEL6                                                        | RHEL7 |
| -------------------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | ----- |
| Default file system                                | ext3                                                         | ext4                                                         | xfs   |
| Create/modify disk partitions                      | fdiskparted                                                  | fdiskgdiskpartedssm create                                   |       |
| Format disk partition                              | mkfs.filesystem_type (ext4, xfs)mkswap                       | mkfs.filesystem_type (ext4, xfs)mkswapssm create             |       |
| Defragment disk space                              | copy data to new file systemfsck (look for 'non-contiguous inodes') | copy data to new file systemfsck (look for 'non-contiguous inodes')xfs_fsr |       |
| Mount storage                                      | mount/etc/fstab                                              | mount/etc/fstabssm mount                                     |       |
| Mount and activate swap                            | /etc/fstabswapon -a                                          |                                                              |       |
| Configure static mounts                            | /etc/fstab                                                   |                                                              |       |
| View free disk space                               | df                                                           |                                                              |       |
| View logical volume info                           | lvdisplaylvsvgdisplayvgspvdisplaypvs                         |                                                              |       |
| Create physical volume                             | pvcreate                                                     | pvcreatessm create (if backend is lvm)                       |       |
| Create volume group                                | vgcreate                                                     | vgcreatessm create (if backend is lvm)                       |       |
| Create logical volume                              | lvcreate                                                     | lvcreatessm create (if backend is lvm)                       |       |
| Enlarge volumes formatted with default file system | vgextendlvextendresize2fs                                    | vgextendlvextendxfs_growfsssm resize                         |       |
| Shrink volumes formatted with default file system  | resize2fslvreducevgreduce                                    | XFS cannot currently be shrunk; copy desired data to a smaller file system. |       |
| Check/repair file system                           | fsck                                                         | fsckssm check                                                |       |
| View NFS share                                     | showmount -emount                                            |                                                              |       |
| Configure NFS share                                | /etc/exportsservice nfs reload                               | /etc/exportssystemctl reload nfs.service                     |       |
| Configure on-demand auto-mounts                    | /etc/auto.master.d/*.autofs/etc/auto.*                       |                                                              |       |
| Change file permissions                            | chmodchownchgrpumask (future file creation)                  |                                                              |       |
| Change file attributes                             | chattr                                                       |                                                              |       |
| Change access control list                         | setfacl                                                      |                                                              |       |

## Networking

| Task                        | RHEL5                                                       | RHEL6                                                        | RHEL7                       |
| --------------------------- | ----------------------------------------------------------- | ------------------------------------------------------------ | --------------------------- |
| Configure name resolution   | /etc/hosts/etc/resolv.conf                                  | /etc/hosts/etc/resolv.confnmcli con mod                      |                             |
| Configure hostname          | /etc/sysconfig/network                                      | hostnamectl/etc/hostnamenmtui                                |                             |
| View network interface info | ip addrifconfigbrctl                                        | ip addrnmcli dev showteamdctlbrctlbridge                     |                             |
| Configure network interface | /etc/sysconfig/network-scripts/ifcfg-*                      | /etc/sysconfig/network-scripts/ifcfg-*nmcli con [add\|mod\|edit]nmtuinm-connection-editor |                             |
| View routes                 | ip route                                                    |                                                              |                             |
| Configure routes            | ip route addsystem-config-network/etc/sysconfig/route-iface | ip route addnmclinmtuinm-connection-editor/etc/sysconfig/route-iface |                             |
| Configure firewall          | iptables and ip6tables/etc/sysconfig/ip*tables              | iptables and ip6tables/etc/sysconfig/ip*tablessystem-config-firewall | firewall-cmdfirewall-config |
| View ports/sockets          | sslsofnetstat                                               | sslsof                                                       |                             |

## Security and identity

| Task                      | RHEL5                                                        | RHEL6 | RHEL7 |
| ------------------------- | ------------------------------------------------------------ | ----- | ----- |
| Configure system security | /etc/selinux/configchconrestoreconsemanagesetseboolsystem-config-selinux |       |       |
| Report on system security | sealert                                                      |       |       |
| LDAP, SSSD, Kerberos      | authconfigauthconfig-tuiauthconfig-gtk                       |       |       |
| Network users             | getent                                                       |       |       |

## Resource management

| Task                        | RHEL5                                     | RHEL6                                           | RHEL7                                    |
| --------------------------- | ----------------------------------------- | ----------------------------------------------- | ---------------------------------------- |
| Trace system calls          | strace                                    |                                                 |                                          |
| Trace library calls         | ltrace                                    |                                                 |                                          |
| Change process priority     | nicerenice                                |                                                 |                                          |
| Change process run location | taskset                                   |                                                 |                                          |
| Kill a process              | killpkillkillall                          |                                                 |                                          |
| View system usage           | toppssariostatnetstatvmstatmpstatnumastat | toppssariostatnetstatssvmstatmpstatnumastattuna | toppssariostatssvmstatmpstatnumastattuna |
| View disk usage             | df                                        | dfiostat                                        |                                          |

1. Be aware of potential issues when using subscription-manager on Red Hat Enterprise Linux 5: <https://access.redhat.com/solutions/129003>. [↩](https://access.redhat.com/articles/1189123#fnref:1)
2. subscription-manager is used for Satellite 6, Satellite 5.6 with SAM and newer, and Red Hat's CDN. [↩](https://access.redhat.com/articles/1189123#fnref:2)
3. RHN tools are deprecated on Red Hat Enterprise Linux 7. rhn_register should be used for Satellite server 5.6 and newer only. For details, see: [What's the difference between management services provided by Red Hat Network (RHN) Classic and Red Hat Customer Portal Subscription Management/RHSM?](https://access.redhat.com/articles/63269), [Transition of Red Hat Network Classic Hosted to Red Hat Subscription Management](https://access.redhat.com/rhn-to-rhsm), and [Satellite 5.6 unable to register RHEL 7 client system due to rhn-setup package not included in Minimal installation](https://access.redhat.com/solutions/737373)[↩](https://access.redhat.com/articles/1189123#fnref:3)

## Attachments

\- [rhel_5_6_7_cheatsheet_24x36_0417_jcs.pdf](https://access.redhat.com/node/1189123/40/0)

\- [rhel_5_6_7_cheatsheet_11x17_0417_jcs.pdf](https://access.redhat.com/node/1189123/40/1)

\- [rhel_5_6_7_cheatsheet_8.5x11_0417_jcs.pdf](https://access.redhat.com/node/1189123/40/2)

\- [rhel_5_6_7_cheatsheet_a3_0417_jcs.pdf](https://access.redhat.com/node/1189123/40/3)

\- [rhel_5_6_7_cheatsheet_a4_0417_jcs.pdf](https://access.redhat.com/node/1189123/40/4)

Product(s) [Red Hat Enterprise Linux](https://access.redhat.com/taxonomy/products/red-hat-enterprise-linux) Category [Migrate](https://access.redhat.com/category/migrate) Tags [rhel](https://access.redhat.com/tags/rhel) [rhel_5](https://access.redhat.com/tags/rhel_5) [rhel_6](https://access.redhat.com/tags/rhel_6) [rhel_7](https://access.redhat.com/taxonomy/tags/rhel7) Article Type [General](https://access.redhat.com/article-type/general)