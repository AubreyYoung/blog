# Heartbeat+DRBD+MySQL高可用架构方案与实施过程细节-老男孩linux培训-51CTO博客

  

[老男孩linux培训](http://blog.51cto.com/oldboy) _>_
[实战](http://blog.51cto.com/oldboy/category8.html) _>_ 正文

# Heartbeat+DRBD+MySQL高可用架构方案与实施过程细节

转载 [老男孩oldboy](http://blog.51cto.com/oldboy) 2013-07-02 22:09:25
[评论(15)](http://blog.51cto.com/oldboy/1240412#comment) 19233人阅读

**恭喜郑东旭同学51CTO博客大赛获奖，特转载此文与博友们分享！  
[](http://blog.51cto.com/attachment/201309/183837250.jpg)  
Heartbeat+DRBD+MySQL高可用架构方案与实施过程细节  
**

 **互联网公司从初期到后期的数据库架构拓展**

[](http://blog.51cto.com/attachment/201305/124150957.jpg)

 **Heartbeat介绍**

官方站点：http://linux-ha.org/wiki/Main_Page

heartbeat可以资源(VIP地址及程序服务)从一台有故障的服务器快速的转移到另一台正常的服务器提供服务，heartbeat和keepalived相似，heartbeat可以实现failover功能，但不能实现对后端的健康检查

 **DRBD介绍**

官方站点：<http://www.drbd.org/>

DRBD(DistributedReplicatedBlockDevice)是一个基于块设备级别在远程服务器直接同步和镜像数据的软件，用软件实现的、无共享的、服务器之间镜像块设备内容的存储复制解决方案。它可以实现在网络中两台服务器之间基于块设备级别的实时镜像或同步复制(两台服务器都写入成功)/异步复制(本地服务器写入成功)，相当于网络的RAID1，由于是基于块设备(磁盘，LVM逻辑卷)，在文件系统的底层，所以数据复制要比cp命令更快

DRBD已经被MySQL官方写入文档手册作为推荐的高可用的方案之一

 **MySQL介绍**

官方站点：<http://www.mysql.com/>

MySQL是一个开放源码的小型关联式数据库管理[系统](http://baike.baidu.com/view/25302.htm)。目前MySQL被广泛地[应用](http://baike.baidu.com/view/220910.htm)在Internet上的中小型网站中。由于其[体积](http://baike.baidu.com/view/274417.htm)小、速度快、总体拥有成本低，尤其是开放源码这一特点，许多中小型网站为了降低网站总体拥有成本而选择了MySQL作为网站[数据库](http://baike.baidu.com/view/1088.htm)。

 **heartbeat和keepalived应用场景及区别**

很多网友说为什么不使用keepalived而使用长期不更新的heartbeat，下面说一下它们之间的应用场景及区别

1、对于web，db，负载均衡(lvs,haproxy,nginx)等，heartbeat和keepalived都可以实现

2、lvs最好和keepalived结合，因为keepalived最初就是为lvs产生的，(heartbeat没有对RS的健康检查功能，heartbeat可以通过ldircetord来进行健康检查的功能)

3、mysql双主多从，NFS/MFS存储，他们的特点是需要数据同步，这样的业务最好使用heartbeat，因为heartbeat有自带的drbd脚本

总结：无数据同步的应用程序高可用可选择keepalived，有数据同步的应用程序高可用可选择heartbeat

# 1、Heartbeat+DRBD+MySQL安装部署

## (1)、架构拓扑

[](http://blog.51cto.com/attachment/201305/124150265.jpg)

架构说明：

一主多从最常用的架构，多个从库可以使用lvs来提供读的负载均衡

解决一主单点的问题，当主库宕机后，可以实现主库宕机后备节点自动接管，所有的从库会自动和新的主库进行同步，实现了mysql主库的热备方案

## (2)、系统环境

系统环境  
  
---  
  
系统

|

CentOSrelease5.8  
  
系统位数

|

X86  
  
内核版本

|

2.6.18  
  
软件环境  
  
heartbeat

|

heartbeat-2.1.3-3  
  
drbd

|

drbd83-8.3.13-2  
  
mysql

|

5.5.27  
  
## (3)、部署环境

角色

|

IP  
  
---|---  
  
VIP

|

192.168.4.1(内网提供服务的地址)  
  
master1

|

eth0:(数据库无公网地址)

eth1:192.168.4.2/16(内网)

eth2:172.16.4.2/16(心跳线)

eth3:172.168.4.2/16(DRBD千兆数据传输)  
  
master2

|

eth0:(数据库无公网地址)

eth1:192.168.4.3/16(内网)

eth2:172.16.4.3/16(心跳线)

eth3:172.168.4.3/16(DRBD千兆数据传输)  
  
slave1

|

eth1:192.168.4.4/16(外网)  
  
说明：从库通过主库的VIP进行主从同步replication  
  
需求：

1、主库master1宕机后master2自动接管VIP以及所有从库

2、在master2接管时，不影响从库的主从同步replication  
  
## (4)、主库服务器数据分区信息

磁盘

|

容量

|

分区

|

挂载点

|

说明  
  
---|---|---|---|---  
  
/dev/sdb

|

1G

|

/dev/sdb1

|

/data/

|

存放数据  
  
/dev/sdb2

| |

存放drbd同步的状态信息  
  
注意

1、metadata分区一定不能格式化建立文件系统(sdb2存放drbd同步的状态信息)

2、分好的分区不要进行挂载

3、生产环境DRBDmetadata分区一般可设置为1-2G，数据分区看需求给最大

4、在生产环境中两块硬盘一样大  
  
# 2、heartbeat安装部署

## (1)、配置服务器间心跳连接路由

主节点

1

2

|

`[root@master1 ~]``# route add -host 172.16.4.3 dev eth2<==到对端的心跳路由`

`[root@master1 ~]``# route add -host 172.168.4.3 dev eth3<==到对端的DRBD数据路由`  
  
---|---  
  
备节点

1

2

|

`[root@master2 ~]``# route add -host 172.16.4.2 dev eth2`

`[root@master2 ~]``# route add -host 172.168.4.2 dev eth3`  
  
---|---  
  
## (2)、安装heartbeat

1

2

3

|

`[root@master1 ~]``# yum install heartbeat -y`

`[root@master1 ~]``# yum install heartbeat -y`

`提示：需要执行两遍安装heartbeat操作`  
  
---|---  
  
## (3)、配置heartbeat

主备节点两端的配置文件(ha.cfauthkeysharesources)完全相同

### 1)、ha.cf

1

2

3

4

5

6

7

8

9

10

11

12

13

14

15

16

17

|

`[root@master1 ~]# vim /etc/ha.d/ha.cf`

`#log configure`

`debugfile /var/``log``/ha-debug`

`logfile /var/``log``/ha-``log`

`logfacility local1`

`#options configure`

`keepalive 2`

`deadtime 30`

`warntime 10`

`initdead 120`

`#bcast eth2`

`mcast eth2 225.0.0.7 694 1 0`

`#node configure`

`auto_failback on`

`node master1 <==主节点主机名`

`node master2 <==备节点主机名`

`crm no`  
  
---|---  
  
### 2)、配置authkeys

1

2

3

|

`[root@master1 ~]``# vim /etc/ha.d/authkeys`

`auth 1`

`1 sha1 47e9336850f1db6fa58bc470bc9b7810eb397f04`  
  
---|---  
  
### 3)、配置haresources

1

2

3

4

5

6

7

|

`[root@master1 ~]# vim /etc/ha.d/haresources`

`master1 IPaddr::192.168.4.1/16/eth1`

`#master1 IPaddr::192.168.4.1/16/eth1 drbddisk::data
Filesystem::/dev/drbd1::/data::ext3 mysqld`

`说明：`

`drbddisk::data <==启动drbd data资源，相当于执行/etc/ha.d/resource.d/drbddisk data
stop/start操作`

`Filesystem::/dev/drbd1::/data::ext3
<==drbd分区挂载到/data目录，相当于执行/etc/ha.d/resource.d/Filesystem /dev/drbd1 /data ext3
stop/start <==相当于系统中执行mount /dev/drbd1 /data`

`mysql <==启动mysql服务脚本，相当于/etc/init.d/mysql stop/start`  
  
---|---  
  
## (4)、启动heartbeat

1

2

3

|

`[root@master1 ~]# /etc/init.d/heartbeat start`

`[root@master1 ~]# chkconfig heartbeat off`

`说明：关闭开机自启动，当服务器重启时，需要人工去启动`  
  
---|---  
  
## (5)、测试heartbeat

正常状态

1

2

3

4

5

6

7

8

|

`[root@master1 ~]``# ip addr|grep eth1`

`3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast qlen
1000`

`inet 192.168.4.2``/16` `brd 192.168.255.255 scope global eth1`

`inet 192.168.4.1``/16` `brd 192.168.255.255 scope global secondary eth1:0`

`[root@master2 ~]``# ip addr|grep eth1`

`3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast qlen
1000`

`inet 192.168.4.3``/16` `brd 192.168.255.255 scope global eth1`

`说明：master1节点拥有vip地址，master2节点没有`  
  
---|---  
  
模拟主节点宕机后的状态

1

2

3

4

5

6

|

`[root@master1 ~]``# /etc/init.d/heartbeat stop`

`[root@master2 ~]``# ip addr|grep eth1`

`3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast qlen
1000`

`inet 192.168.4.3``/16` `brd 192.168.255.255 scope global eth1`

`inet 192.168.4.1``/16` `brd 192.168.255.255 scope global secondary eth1:0`

`说明：master1宕机后，vip地址漂移到master2节点上，master2成为主节点`  
  
---|---  
  
模拟主节点故障恢复后的状态

1

2

3

4

5

6

|

`[root@master1 ~]``# /etc/init.d/heartbeat start`

`[root@master1 ~]``# ip addr|grep eth1`

`3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast qlen
1000`

`inet 192.168.4.2``/16` `brd 192.168.255.255 scope global eth1`

`inet 192.168.4.1``/16` `brd 192.168.255.255 scope global secondary eth1:0`

`说明：master1抢占vip资源`  
  
---|---  
  
# 3、DRBD安装部署

## (1)、新添加硬盘

1

2

3

4

5

6

7

|

`[root@master1 ~]``# fdisk /dev/sdb`

`说明：sdb磁盘分两个分区sdb1和sdb2`

`[root@master1 ~]``# partprobe`

`[root@master1 ~]``# mkfs.ext3 /dev/sdb1`

`说明：sdb2分区为meta data分区，不需要格式化操作`

`[root@master1 ~]``# tune2fs -c -1 /dev/sdb1`

`说明：设置最大挂载数为-1`  
  
---|---  
  
## (2)、安装DRBD

1

2

3

|

`[root@master1 ~]``# yum install kmod-drbd83 drbd83 -y`

`[root@master1 ~]``# modprobe drbd`

`注意：不要设置``echo` `'modprobe drbd'`
`>>``/etc/rc``.loca开机自动加载drbd模块，如果drbd服务是开机自启动的，会先启动drbd服务在加载drbd的顺序，导致drbd启动不了出现的问题`  
  
---|---  
  
## (3)、配置DRBD

主备节点两端配置文件完全一致

1

2

3

4

5

6

7

8

9

10

11

12

13

14

15

16

17

18

19

20

21

22

23

24

25

26

27

28

29

30

31

32

33

34

35

36

37

38

39

40

41

42

43

44

45

46

47

48

49

50

51

52

53

54

|

`[root@master1 ~]``# cat /etc/drbd.conf`

`global {`

`# minor-count 64;`

`# dialog-refresh 5; # 5 seconds`

`# disable-ip-verification;`

`usage-count no;`

`}`

`common {`

`protocol C;`

`disk {`

`on-io-error detach;`

`#size 454G;`

`no-disk-flushes;`

`no-md-flushes;`

`}`

`net {`

`sndbuf-size 512k;`

`# timeout 60; # 6 seconds (unit = 0.1 seconds)`

`# connect-int 10; # 10 seconds (unit = 1 second)`

`# ping-int 10; # 10 seconds (unit = 1 second)`

`# ping-timeout 5; # 500 ms (unit = 0.1 seconds)`

`max-buffers 8000;`

`unplug-watermark 1024;`

`max-epoch-size 8000;`

`# ko-count 4;`

`# allow-two-primaries;`

`cram-hmac-alg ``"sha1"``;`

`shared-secret ``"hdhwXes23sYEhart8t"``;`

`after-sb-0pri disconnect;`

`after-sb-1pri disconnect;`

`after-sb-2pri disconnect;`

`rr-conflict disconnect;`

`# data-integrity-alg "md5";`

`# no-tcp-cork;`

`}`

`syncer {`

`rate 120M;`

`al-extents 517;`

`}`

`}`

`resource data {`

`on master1 {`

`device ``/dev/drbd1``;`

`disk ``/dev/sdb1``;`

`address 192.168.4.2:7788;`

`meta-disk ``/dev/sdb2` `[0];`

`}`

`on master2 {`

`device ``/dev/drbd1``;`

`disk ``/dev/sdb1``;`

`address 192.168.4.3:7788;`

`meta-disk ``/dev/sdb2` `[0];`

`}`

`}`  
  
---|---  
  
## (4)、初始化meta分区

1

2

3

4

5

|

`[root@master1 ~]``# drbdadm create-md data`

`Writing meta data...`

`initializing activity log`

`NOT initialized bitmap`

`New drbd meta data block successfully created.`  
  
---|---  
  
## (5)、初始化设备同步(覆盖备节点，保持数据一致)

1

|

`[root@master1 ~]``# drbdadm -- --overwrite-data-of-peer primary data`  
  
---|---  
  
## (6)、启动drbd

1

2

|

`[root@master1 ~]# drbdadm up all`

`[root@master1 ~]# chkconfig drbd off`  
  
---|---  
  
## (7)、挂载drbd分区到data数据目录

1

2

3

|

`[root@master1 ~]``# drbdadm primary all`

`[root@master1 ~]``# mount /dev/drbd1 /data`

`说明：``/data``目录为数据库的数据目录`  
  
---|---  
  
## (8)、测试DRBD

正常状态

1

2

3

4

5

6

7

8

9

10

11

|

`[root@master1 ~]``# cat /proc/drbd`

`version: 8.3.13 (api:88``/proto``:86-96)`

`GIT-``hash``: 83ca112086600faacab2f157bc5a9324f7bd7f77 build by
mockbuild@builder10.centos.org, 2012-05-07 11:56:36`

`1: cs:Connected ro:Primary``/Secondary` `ds:UpToDate``/UpToDate` `C r-----`

`ns:497984 nr:0 dw:1 dr:498116 al:1 bm:31 lo:0 pe:0 ua:0 ap:0 ep:1 wo:b oos:0`

`[root@master2 ~]``# cat /proc/drbd`

`version: 8.3.13 (api:88``/proto``:86-96)`

`GIT-``hash``: 83ca112086600faacab2f157bc5a9324f7bd7f77 build by
mockbuild@builder10.centos.org, 2012-05-07 11:56:36`

`1: cs:Connected ro:Secondary``/Primary` `ds:UpToDate``/UpToDate` `C r-----`

`ns:0 nr:497984 dw:497984 dr:0 al:0 bm:30 lo:0 pe:0 ua:0 ap:0 ep:1 wo:b oos:0`

`说明：master1为主节点，master为备节点`  
  
---|---  
  
模拟master1宕机

1

2

3

4

5

6

7

8

9

10

11

12

13

14

15

16

|

`[root@master1 ~]# umount /dev/drbd1`

`[root@master1 ~]# drbdadm down all`

`[root@master2 ~]# cat /proc/drbd`

`version: ``8.3``.``13` `(api:``88``/proto:``86``-``96``)`

`GIT-hash: 83ca112086600faacab2f157bc5a9324f7bd7f77 build by
mockbuild@builder10.centos.org, ``2012``-``05``-``07` `11``:``56``:``36`

`1``: cs:WFConnection ro:Secondary/Unknown ds:UpToDate/DUnknown C r-----`

`ns:``0` `nr:``497985` `dw:``497985` `dr:``0` `al:``0` `bm:``30` `lo:``0`
`pe:``0` `ua:``0` `ap:``0` `ep:``1` `wo:b oos:``0`

`[root@master2 ~]# drbdadm primary all`

`[root@master2 ~]# mount /dev/drbd1 /data`

`[root@master2 ~]# df -h`

`Filesystem Size Used Avail Use% Mounted on`

`/dev/sda3 19G ``5``.1G 13G ``29``% /`

`/dev/sda1 190M 18M 163M ``10``% /boot`

`tmpfs 60M ``0` `60M ``0``% /dev/shm`

`/dev/drbd1 471M 11M 437M ``3``% /data`

`说明：master1宕机后，master2可以升级为主节点，可挂载drbd分区继续使用`  
  
---|---  
  
# 4、MySQL安装部署

注意：三台数据库都安装mysql服务，master2只安装到makeinstall即可，mysqld服务不要设置为开机自启动

## (1)、解决perl编译问题

1

2

|

`echo` `'export LC_ALL=C'``>> ``/etc/profile`

`source` `/etc/profile`  
  
---|---  
  
## (2)、安装CAMKE

1

2

3

4

5

6

|

`cd` `/home/xu/tools`

`wget http:``//www``.cmake.org``/files/v2``.8``/cmake-2``.8.4.``tar``.gz`

`tar` `zxf cmake-2.8.4.``tar``.gz`

`cd` `cmake-2.8.4`

`.``/configure`

`make` `& ``make` `install`  
  
---|---  
  
## (3)、创建用户

1

2

|

`groupadd mysql`

`useradd` `-g mysql mysql`  
  
---|---  
  
## (4)、编译安装mysql

1

2

3

4

5

6

7

8

9

10

11

12

|

`wget
http:``//mysql``.ntu.edu.tw``/Downloads/MySQL-5``.5``/mysql-5``.5.27.``tar``.gz`

`tar` `zxf mysql-5.5.27.``tar``.gz`

`cd` `mysql-5.5.27`

`cmake -DCMAKE_INSTALL_PREFIX=``/usr/local/mysql` `\`

`-DMYSQL_UNIX_ADDR=``/tmp/mysql``.sock \`

`-DDEFAULT_CHARSET=utf8 \`

`-DDEFAULT_COLLATION=utf8_general_ci \`

`-DWITH_EXTRA_CHARSETS=complex \`

`-DWITH_READLINE=1 \`

`-DENABLED_LOCAL_INFILE=1`

`make` `-j 4`

`make` `install`  
  
---|---  
  
## (5)、设置mysql环境变量

1

2

|

`[root@master1 ~]``# echo 'PATH=$PATH:/usr/local/mysql/bin' >>/etc/profile`

`[root@master1 ~]``# source /etc/profile`  
  
---|---  
  
## (6)、初始化数据库

1

2

3

4

|

`[root@master1 ~]``# mount /dev/drbd1 /data`

`说明：数据库存放数据的目录是drbd分区`

`[root@master1 ~]``# cd /usr/local/mysql/`

`[root@master1 ~]``# ./scripts/mysql_install_db --datadir=/data/ --user=mysql`  
  
---|---  
  
## (7)、启动数据库

1

2

3

4

5

|

`[root@master1 ~]``# vim /etc/init.d/mysqld`

`datadir=``/data`

`说明：修改mysql启动脚本，指定数据库的目录为``/data`

`[root@master1 ~]``# /etc/init.d/mysqld start`

`[root@master1 ~]``# chkconfig mysqld off`  
  
---|---  
  
## (8)、测试数据库

1

2

3

4

5

6

7

8

|

`[root@master1 ~]``# mysql -uroot -e "show databases;"`

`+--------------------+`

`| Database |`

`+--------------------+`

`| information_schema |`

`| mysql |`

`| performance_schema |`

`+--------------------+`  
  
---|---  
  
# 5、故障切换测试

## (1)、架构正常状态

master1主节点正常状态

1

2

3

4

5

6

7

8

9

10

11

12

13

14

15

16

17

|

`[root@master1 ~]``# ip addr|grep eth1`

`3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast qlen
1000`

`inet 192.168.4.2``/16` `brd 192.168.255.255 scope global eth1`

`inet 192.168.4.1``/16` `brd 192.168.255.255 scope global secondary eth1:0`

`[root@master1 ~]``# cat /proc/drbd`

`version: 8.3.13 (api:88``/proto``:86-96)`

`GIT-``hash``: 83ca112086600faacab2f157bc5a9324f7bd7f77 build by
mockbuild@builder10.centos.org, 2012-05-07 11:56:36`

`1: cs:Connected ro:Primary``/Secondary` `ds:UpToDate``/UpToDate` `C r-----`

`ns:39558 nr:12 dw:39570 dr:151 al:16 bm:1 lo:0 pe:0 ua:0 ap:0 ep:1 wo:b
oos:0`

`[root@master1 ~]``# mysql -uroot -e "create database coral;"`

`[root@master1 ~]``# mysql -uroot -e "show databases like 'coral';"`

`+------------------+`

`| Database (coral) |`

`+------------------+`

`| coral |`

`+------------------+`

`说明：master1为主节点，拥有VIP地址，为drbd的主节点`  
  
---|---  
  
master2备节点正常状态

1

2

3

4

5

6

7

8

9

|

`[root@master2 ~]``# ip addr|grep eth1`

`3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast qlen
1000`

`inet 192.168.4.3``/16` `brd 192.168.255.255 scope global eth1`

`[root@master2 ~]``# cat /proc/drbd`

`version: 8.3.13 (api:88``/proto``:86-96)`

`GIT-``hash``: 83ca112086600faacab2f157bc5a9324f7bd7f77 build by
mockbuild@builder10.centos.org, 2012-05-07 11:56:36`

`1: cs:Connected ro:Secondary``/Primary` `ds:UpToDate``/UpToDate` `C r-----`

`ns:0 nr:48 dw:48 dr:0 al:0 bm:0 lo:0 pe:0 ua:0 ap:0 ep:1 wo:b oos:0`

`说明：master2备节点没有VIP地址，为drbd备节点`  
  
---|---  
  
## (2)、模拟master1宕机故障状态

1

2

3

4

5

6

7

8

9

10

11

12

13

14

15

16

17

18

19

20

21

22

23

24

25

26

27

28

29

30

31

32

33

34

35

36

37

38

39

40

41

42

43

44

45

46

47

48

49

50

|

`[root@master1 ~]``# /etc/init.d/heartbeat stop <==模拟master1故障宕机`

`[root@master2 ~]``# tailf /var/log/ha-log <==查看备节点接管日志`

`heartbeat[13209]: 2013``/01/23_04``:09:36 info: Received ``shutdown` `notice
from ``'master1'``.`

`heartbeat[13209]: 2013``/01/23_04``:09:36 info: Resources being acquired from
master1.`

`heartbeat[15293]: 2013``/01/23_04``:09:36 info: acquire ``local` `HA
resources (standby).`

`heartbeat[15294]: 2013``/01/23_04``:09:37 info: No ``local` `resources
[``/usr/share/heartbeat/ResourceManager` `listkeys master2] to acquire.`

`heartbeat[15293]: 2013``/01/23_04``:09:37 info: ``local` `HA resource
acquisition completed (standby).`

`heartbeat[13209]: 2013``/01/23_04``:09:37 info: Standby resource acquisition
``done` `[foreign].`

`harc[15319]: 2013``/01/23_04``:09:37 info: Running
``/etc/ha``.d``/rc``.d``/status` `status`

`mach_down[15335]: 2013``/01/23_04``:09:37 info: Taking over resource group
IPaddr::192.168.4.1``/16/eth1`

`ResourceManager[15361]: 2013``/01/23_04``:09:37 info: Acquiring resource
group: master1 IPaddr::192.168.4.1``/16/eth1` `drbddisk::data
Filesystem::``/dev/drbd1``::``/data``::ext3 mysqld`

`IPaddr[15388]: 2013``/01/23_04``:09:37 INFO: Resource is stopped`

`ResourceManager[15361]: 2013``/01/23_04``:09:37 info: Running
``/etc/ha``.d``/resource``.d``/IPaddr` `192.168.4.1``/16/eth1` `start`

`IPaddr[15486]: 2013``/01/23_04``:09:38 INFO: Using calculated netmask ``for`
`192.168.4.1: 255.255.0.0`

`IPaddr[15486]: 2013``/01/23_04``:09:38 INFO: ``eval` `ifconfig` `eth1:0
192.168.4.1 netmask 255.255.0.0 broadcast 192.168.255.255`

`IPaddr[15457]: 2013``/01/23_04``:09:38 INFO: Success`

`ResourceManager[15361]: 2013``/01/23_04``:09:38 info: Running
``/etc/ha``.d``/resource``.d``/drbddisk` `data start`

`Filesystem[15636]: 2013``/01/23_04``:09:39 INFO: Resource is stopped`

`ResourceManager[15361]: 2013``/01/23_04``:09:39 info: Running
``/etc/ha``.d``/resource``.d``/Filesystem` `/dev/drbd1` `/data` `ext3 start`

`Filesystem[15717]: 2013``/01/23_04``:09:39 INFO: Running start ``for`
`/dev/drbd1` `on ``/data`

`Filesystem[15706]: 2013``/01/23_04``:09:39 INFO: Success`

`ResourceManager[15361]: 2013``/01/23_04``:09:40 info: Running
``/etc/init``.d``/mysqld` `start`

`mach_down[15335]: 2013``/01/23_04``:09:44 info:
``/usr/share/heartbeat/mach_down``: nice_failback: foreign resources acquired`

`mach_down[15335]: 2013``/01/23_04``:09:44 info: mach_down takeover complete
``for` `node master1.`

`heartbeat[13209]: 2013``/01/23_04``:09:44 info: mach_down takeover complete.`

`heartbeat[13209]: 2013``/01/23_04``:10:09 WARN: node master1: is dead`

`heartbeat[13209]: 2013``/01/23_04``:10:09 info: Dead node master1 gave up
resources.`

`heartbeat[13209]: 2013``/01/23_04``:10:09 info: Link master1:eth2 dead.`

`说明：当备节点无法检测到主节点的心跳时，自动接管资源，启动VIP地址、drbd服务，自动挂载drbd，启动mysqld服务，备节点接管后，数据依然存在，检测启动的服务如下：`

`[root@master2 ~]``# ip addr|grep eth1`

`3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast qlen
1000`

`inet 192.168.4.3``/16` `brd 192.168.255.255 scope global eth1`

`inet 192.168.4.1``/16` `brd 192.168.255.255 scope global secondary eth1:0`

`[root@master2 ~]``# cat /proc/drbd`

`version: 8.3.13 (api:88``/proto``:86-96)`

`GIT-``hash``: 83ca112086600faacab2f157bc5a9324f7bd7f77 build by
mockbuild@builder10.centos.org, 2012-05-07 11:56:36`

`1: cs:Connected ro:Primary``/Secondary` `ds:UpToDate``/UpToDate` `C r-----`

`ns:3 nr:95 dw:98 dr:10 al:1 bm:0 lo:0 pe:0 ua:0 ap:0 ep:1 wo:b oos:0`

`[root@master2 ~]``# df -h`

`Filesystem Size Used Avail Use% Mounted on`

`/dev/sda3` `19G 4.7G 14G 26% /`

`/dev/sda1` `190M 18M 163M 10% ``/boot`

`tmpfs 60M 0 60M 0% ``/dev/shm`

`/dev/drbd1` `471M 40M 408M 9% ``/data`

`[root@master2 ~]``# mysql -uroot -e "show databases like 'coral';"`

`+------------------+`

`| Database (coral) |`

`+------------------+`

`| coral |`

`+------------------+`  
  
---|---  
  
## (3)、模拟master1宕机恢复状态

启动的顺序是：先启动VIP--启动drbd资源--挂载drbd分区--启动mysqld服务，日志如下：

1

2

3

4

5

6

7

8

9

10

11

12

13

14

15

16

17

18

19

20

21

22

23

24

25

26

27

28

29

30

31

32

33

34

35

36

37

38

39

40

|

`[root@master1 ~]``# /etc/init.d/heartbeat start`

`[root@master1 ~]``# tailf /var/log/ha-log`

`heartbeat[27970]: 2013``/01/09_17``:34:14 info: Version 2 support: no`

`heartbeat[27970]: 2013``/01/09_17``:34:14 WARN: Logging daemon is disabled
--enabling logging daemon is recommended`

`heartbeat[27970]: 2013``/01/09_17``:34:14 info: **************************`

`heartbeat[27970]: 2013``/01/09_17``:34:14 info: Configuration validated.
Starting heartbeat 2.1.3`

`heartbeat[27971]: 2013``/01/09_17``:34:14 info: heartbeat: version 2.1.3`

`heartbeat[27971]: 2013``/01/09_17``:34:14 info: Heartbeat generation:
1351554533`

`heartbeat[27971]: 2013``/01/09_17``:34:14 info: glib: UDP multicast heartbeat
started ``for` `group 225.0.0.7 port 694 interface eth2 (ttl=1 loop=0)`

`heartbeat[27971]: 2013``/01/09_17``:34:14 info: G_main_add_TriggerHandler:
Added signal manual handler`

`heartbeat[27971]: 2013``/01/09_17``:34:14 info: G_main_add_TriggerHandler:
Added signal manual handler`

`heartbeat[27971]: 2013``/01/09_17``:34:14 info: G_main_add_SignalHandler:
Added signal handler ``for` `signal 17`

`heartbeat[27971]: 2013``/01/09_17``:34:14 info: Local status now ``set` `to:
``'up'`

`heartbeat[27971]: 2013``/01/09_17``:34:16 info: Link master2:eth2 up.`

`heartbeat[27971]: 2013``/01/09_17``:34:16 info: Status update ``for` `node
master2: status active`

`harc[27978]: 2013``/01/09_17``:34:16 info: Running
``/etc/ha``.d``/rc``.d``/status` `status`

`heartbeat[27971]: 2013``/01/09_17``:34:17 info: Comm_now_up(): updating
status to active`

`heartbeat[27971]: 2013``/01/09_17``:34:17 info: Local status now ``set` `to:
``'active'`

`heartbeat[27971]: 2013``/01/09_17``:34:17 info: remote resource transition
completed.`

`heartbeat[27971]: 2013``/01/09_17``:34:17 info: remote resource transition
completed.`

`heartbeat[27971]: 2013``/01/09_17``:34:17 info: Local Resource acquisition
completed. (none)`

`heartbeat[27971]: 2013``/01/09_17``:34:18 info: master2 wants to go standby
[foreign]`

`heartbeat[27971]: 2013``/01/09_17``:34:20 info: standby: acquire [foreign]
resources from master2`

`heartbeat[27997]: 2013``/01/09_17``:34:20 info: acquire ``local` `HA
resources (standby).`

`ResourceManager[28010]: 2013``/01/09_17``:34:20 info: Acquiring resource
group: master1 IPaddr::192.168.4.1``/16/eth1` `drbddisk::data
Filesystem::``/dev/drbd1``::``/data``::ext3 mysqld`

`IPaddr[28037]: 2013``/01/09_17``:34:21 INFO: Resource is stopped`

`ResourceManager[28010]: 2013``/01/09_17``:34:21 info: Running
``/etc/ha``.d``/resource``.d``/IPaddr` `192.168.4.1``/16/eth1` `start`

`IPaddr[28135]: 2013``/01/09_17``:34:21 INFO: Using calculated netmask ``for`
`192.168.4.1: 255.255.0.0`

`IPaddr[28135]: 2013``/01/09_17``:34:21 INFO: ``eval` `ifconfig` `eth1:0
192.168.4.1 netmask 255.255.0.0 broadcast 192.168.255.255`

`IPaddr[28106]: 2013``/01/09_17``:34:21 INFO: Success`

`ResourceManager[28010]: 2013``/01/09_17``:34:21 info: Running
``/etc/ha``.d``/resource``.d``/drbddisk` `data start`

`Filesystem[28286]: 2013``/01/09_17``:34:21 INFO: Resource is stopped`

`ResourceManager[28010]: 2013``/01/09_17``:34:21 info: Running
``/etc/ha``.d``/resource``.d``/Filesystem` `/dev/drbd1` `/data` `ext3 start`

`Filesystem[28367]: 2013``/01/09_17``:34:21 INFO: Running start ``for`
`/dev/drbd1` `on ``/data`

`Filesystem[28356]: 2013``/01/09_17``:34:21 INFO: Success`

`ResourceManager[28010]: 2013``/01/09_17``:34:22 info: Running
``/etc/init``.d``/mysqld` `start`

`heartbeat[27997]: 2013``/01/09_17``:34:25 info: ``local` `HA resource
acquisition completed (standby).`

`heartbeat[27971]: 2013``/01/09_17``:34:25 info: Standby resource acquisition
``done` `[foreign].`

`heartbeat[27971]: 2013``/01/09_17``:34:25 info: Initial resource acquisition
complete (auto_failback)`

`heartbeat[27971]: 2013``/01/09_17``:34:25 info: remote resource transition
completed.`  
  
---|---  
  
备节点释放资源顺序：停止mysqld服务--卸载drbd1分区--设置drbd为备节点--关闭VIP地址，日志如下：

1

2

3

4

5

6

7

8

9

10

11

12

13

14

15

16

17

18

19

20

21

22

23

24

25

26

27

28

29

30

31

32

|

`[root@master2 ~]``# tailf /var/log/ha-log`

`heartbeat[13209]: 2013``/01/23_04``:26:53 info: Heartbeat restart on node
master1`

`heartbeat[13209]: 2013``/01/23_04``:26:53 info: Link master1:eth2 up.`

`heartbeat[13209]: 2013``/01/23_04``:26:53 info: Status update ``for` `node
master1: status init`

`heartbeat[13209]: 2013``/01/23_04``:26:53 info: Status update ``for` `node
master1: status up`

`harc[16151]: 2013``/01/23_04``:26:53 info: Running
``/etc/ha``.d``/rc``.d``/status` `status`

`harc[16167]: 2013``/01/23_04``:26:53 info: Running
``/etc/ha``.d``/rc``.d``/status` `status`

`heartbeat[13209]: 2013``/01/23_04``:26:53 info: all clients are now paused`

`heartbeat[13209]: 2013``/01/23_04``:26:55 info: Status update ``for` `node
master1: status active`

`harc[16183]: 2013``/01/23_04``:26:55 info: Running
``/etc/ha``.d``/rc``.d``/status` `status`

`heartbeat[13209]: 2013``/01/23_04``:26:55 info: all clients are now resumed`

`heartbeat[13209]: 2013``/01/23_04``:26:55 info: remote resource transition
completed.`

`heartbeat[13209]: 2013``/01/23_04``:26:55 info: master2 wants to go standby
[foreign]`

`heartbeat[13209]: 2013``/01/23_04``:26:55 info: standby: master1 can take our
foreign resources`

`heartbeat[16199]: 2013``/01/23_04``:26:55 info: give up foreign HA resources
(standby).`

`ResourceManager[16212]: 2013``/01/23_04``:26:55 info: Releasing resource
group: master1 IPaddr::192.168.4.1``/16/eth1` `drbddisk::data
Filesystem::``/dev/drbd1``::``/data``::ext3 mysqld`

`ResourceManager[16212]: 2013``/01/23_04``:26:55 info: Running
``/etc/init``.d``/mysqld` `stop`

`ResourceManager[16212]: 2013``/01/23_04``:26:57 info: Running
``/etc/ha``.d``/resource``.d``/Filesystem` `/dev/drbd1` `/data` `ext3 stop`

`Filesystem[16297]: 2013``/01/23_04``:26:57 INFO: Running stop ``for`
`/dev/drbd1` `on ``/data`

`Filesystem[16297]: 2013``/01/23_04``:26:57 INFO: Trying to unmount ``/data`

`Filesystem[16297]: 2013``/01/23_04``:26:57 INFO: unmounted ``/data`
`successfully`

`Filesystem[16286]: 2013``/01/23_04``:26:57 INFO: Success`

`ResourceManager[16212]: 2013``/01/23_04``:26:57 info: Running
``/etc/ha``.d``/resource``.d``/drbddisk` `data stop`

`ResourceManager[16212]: 2013``/01/23_04``:26:57 info: Running
``/etc/ha``.d``/resource``.d``/IPaddr` `192.168.4.1``/16/eth1` `stop`

`IPaddr[16445]: 2013``/01/23_04``:26:58 INFO: ``ifconfig` `eth1:0 down`

`IPaddr[16416]: 2013``/01/23_04``:26:58 INFO: Success`

`heartbeat[16199]: 2013``/01/23_04``:26:58 info: foreign HA resource release
completed (standby).`

`heartbeat[13209]: 2013``/01/23_04``:26:58 info: Local standby process
completed [foreign].`

`heartbeat[13209]: 2013``/01/23_04``:27:02 WARN: 1 lost packet(s) ``for`
`[master1] [15:17]`

`heartbeat[13209]: 2013``/01/23_04``:27:02 info: remote resource transition
completed.`

`heartbeat[13209]: 2013``/01/23_04``:27:02 info: No pkts missing from
master1!`

`heartbeat[13209]: 2013``/01/23_04``:27:02 info: Other node completed standby
takeover of foreign resources.`  
  
---|---  
  
# 6、从库同VIP同步

## (1)、master配置

### 1)、设置server-id值并开启Binlog参数

1

2

3

4

5

|

`[root@master1 ~]``# vim /etc/my.cnf`

`log-bin=``/usr/local/mysql/mysql-bin`

`server-``id` `= 3`

`[root@master1 ~]``# /etc/init.d/mysqld restart`

`注意：只有master1有重启操作，master2无需重启操作，因为备节点的mysql是未启动状态，备节点只有heartbeat才能启动mysql`  
  
---|---  
  
### 2)、授权并建立同步账户rep

1

2

|

`[root@master1 ~]``# mysql -uroot -p`

`mysql> GRANT REPLICATION SLAVE ON *.* TO ``'rep'``@``'192.168.4.%'`
`IDENTIFIED BY ``'rep'``;`  
  
---|---  
  
## (2)、slave配置

### 1)、设置server-id值并关闭binlog设置

1

2

3

4

5

|

`[root@slave1 ~]``# vim /etc/my.cnf`

`#log-bin=mysql-bin`

`server-``id` `= 4`

`[root@slave1 ~]``# /etc/init.d/mysqld restart`

`说明：从库无需开启binlog日志功能，除非有需求做级联复制架构或对mysql增量备份操作才开启`  
  
---|---  
  
### 2)、配置同步参数

1

2

3

4

5

6

7

8

|

`[root@Slave ~]``# mysql -uroot`

`CHANGE MASTER TO`

`MASTER_HOST=``'192.168.4.1'``,`

`MASTER_PORT=3306,`

`MASTER_USER=``'rep'``,`

`MASTER_PASSWORD=``'rep'``,`

`MASTER_LOG_FILE=``'mysql-bin.000001'``,`

`MASTER_LOG_POS=0;`  
  
---|---  
  
### 3)、检查是否主从同步

1

2

3

4

5

6

|

`[root@Slave ~]``# mysql -uroot`

`mysql> show slave status\G`

`...`

`Slave_IO_Running: Yes`

`Slave_SQL_Running: Yes`

`...`  
  
---|---  
  
## (3)、模拟高可用宕机切换是否影响从库同步

### 1)、主从正常状态

1

2

3

4

5

6

7

8

9

10

11

12

|

`[root@master1 ~]``# mysql -uroot`

`mysql> create database coral1;`

`Query OK, 1 row affected (0.02 sec)`

`[root@slave1 ~]``# mysql -uroot -e "show slave status\G"|egrep
"Slave_IO_Running|Slave_SQL_Running"`

`Slave_IO_Running: Yes`

`Slave_SQL_Running: Yes`

`[root@slave1 ~]``# mysql -uroot -e "show databases like 'coral%';"`

`+-------------------+`

`| Database (coral%) |`

`+-------------------+`

`| coral1 |`

`+-------------------+`  
  
---|---  
  
### 2)、模拟高可用主节点宕机

1

2

3

4

5

6

7

8

9

10

11

12

13

14

15

16

17

18

19

20

21

22

|

`[root@master1 ~]``# /etc/init.d/heartbeat stop`

`说明：模拟主节点宕机`

`[root@master2 ~]``# ip addr|grep eth1`

`3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast qlen
1000`

`inet 192.168.4.3``/16` `brd 192.168.255.255 scope global eth1`

`inet 192.168.4.1``/16` `brd 192.168.255.255 scope global secondary eth1:0`

`[root@master2 ~]``# mysql -uroot`

`mysql> create database coral2;`

`Query OK, 1 row affected (0.08 sec)`

`说明：VIP地址已经漂移到master2上面`

`[root@slave1 ~]``# mysql -uroot -e "show slave status\G"|egrep
"Slave_IO_Running|Slave_SQL_Running"`

`Slave_IO_Running: Yes`

`Slave_SQL_Running: Yes`

`[root@slave1 ~]``# mysql -uroot -e "show databases like 'coral%'"`

`+-------------------+`

`| Database (coral%) |`

`+-------------------+`

`| coral1 |`

`| coral2 |`

`+-------------------+`

`注意：高可用主备节点切换过程中，会有一段时间从库才能连接上，大于在60秒内`

`说明：此时主从同步是正常的`  
  
---|---  
  
### 3)、模拟高可用主节点宕机恢复

1

2

3

4

5

6

7

8

9

10

11

12

13

14

15

|

`[root@master1 ~]``# /etc/init.d/heartbeat start`

`[root@master1 ~]``# mysql -uroot`

`mysql> create database coral3;`

`[root@slave1 ~]``# mysql -uroot -e "show slave status\G"|egrep
"Slave_IO_Running|Slave_SQL_Running"`

`Slave_IO_Running: Yes`

`Slave_SQL_Running: Yes`

`[root@slave1 ~]``# mysql -uroot -e "show databases like 'coral%'"`

`+-------------------+`

`| Database (coral%) |`

`+-------------------+`

`| coral1 |`

`| coral2 |`

`| coral3 |`

`+-------------------+`

`说明：高可用主节点故障恢复后也不影响主从库的同步`  
  
---|---  
  
# 6、高可用脑裂问题及解决方案

## (1)、导致裂脑发生的原因

1、高可用服务器之间心跳链路故障，导致无法相互检查心跳

2、高可用服务器上开启了防火墙，阻挡了心跳检测

3、高可用服务器上网卡地址等信息配置不正常，导致发送心跳失败

4、其他服务配置不当等原因，如心跳方式不同，心跳广播冲突，软件BUG等

## (2)、防止裂脑一些方案

1、加冗余线路

2、检测到裂脑时，强行关闭心跳检测(远程关闭主节点，控制电源的电路fence)

3、做好脑裂的监控报警

4、报警后，备节点在接管时设置比较长的时间去接管，给运维人员足够的时间去处理(人为处理)

5、启动磁盘锁，正在服务的一方锁住磁盘，裂脑发生时，让对方完全抢不走"共享磁盘资源"

磁盘锁存在的问题：

使用锁磁盘会有死锁的问题，如果占用共享磁盘的一方不主动"解锁"另一方就永远得不到共享磁盘，假如服务器节点突然死机或崩溃，就不可能执行解锁命令，备节点也就无法接管资源和服务了，有人在HA中设计了智能锁，正在提供服务的一方只在发现心跳全部断开时才会启用磁盘锁，平时就不上锁

BTW：如果大家认为我写的还可以，希望能给我的博文投个票，谢谢！O(∩_∩)O  

[http://blog.51cto.com/contest/college2013/1293405](http://blog.51cto.com/contest/college2013/1293405)  

[MySQL高可用方案](http://blog.51cto.com/search/result?q=MySQL%E9%AB%98%E5%8F%AF%E7%94%A8%E6%96%B9%E6%A1%88)
[生产搭建过程](http://blog.51cto.com/search/result?q=%E7%94%9F%E4%BA%A7%E6%90%AD%E5%BB%BA%E8%BF%87%E7%A8%8B)

38

分享

收藏

[上一篇：IT人技术交流沙龙活动分享（第三期）7月6日](http://blog.51cto.com/oldboy/1239084
"IT人技术交流沙龙活动分享（第三期）7月6日")
[下一篇：老男孩教育中高级linux运维高薪就业班精品课程12月开班了](http://blog.51cto.com/oldboy/1241554
"老男孩教育中高级linux运维高薪就业班精品课程12月开班了")

  


---
### ATTACHMENTS
[0336f08fdef50b4994c07544ec95607b]: media/124150957.jpg
[124150957.jpg](media/124150957.jpg)
>hash: 0336f08fdef50b4994c07544ec95607b  
>source-url: http://blog.51cto.com/attachment/201305/124150957.jpg  
>file-name: 124150957.jpg  

[cc6631983f2856121741219e692da2c3]: media/183837250.jpg
[183837250.jpg](media/183837250.jpg)
>hash: cc6631983f2856121741219e692da2c3  
>source-url: http://blog.51cto.com/attachment/201309/183837250.jpg  
>file-name: 183837250.jpg  

[df7d3bbdde70a26af31e3ede9397e4a1]: media/124150265.jpg
[124150265.jpg](media/124150265.jpg)
>hash: df7d3bbdde70a26af31e3ede9397e4a1  
>source-url: http://blog.51cto.com/attachment/201305/124150265.jpg  
>file-name: 124150265.jpg  


---
### TAGS
{DRBD}

---
### NOTE ATTRIBUTES
>Created Date: 2018-02-13 02:15:58  
>Last Evernote Update Date: 2018-10-01 15:35:38  
>author: YangKwong  
>source: web.clip  
>source-url: http://blog.51cto.com/oldboy/1240412  