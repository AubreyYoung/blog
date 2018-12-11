# MySQL数据库常用架构设计 - MySQL及其它开源数据库 - ITPUB论坛－中国最专业的IT技术社区

  

电梯直达

**[ _1_ #](http://www.itpub.net/thread-2091675-1-1.html) **

_发表于 2017-8-31 11:23_ |
[只看该作者](http://www.itpub.net/forum.php?mod=viewthread&tid=2091675&page=1&authorid=31485369)
|[只看大图](http://www.itpub.net/forum.php?mod=viewthread&tid=2091675&from=album)

| ****

本文来源于： **IT 摆渡网（http://www.itbaiduwang.com）**\---一个IT实时问答系统快速解决你的任何IT问题，无需等待！

**一、MySQL引擎**

MySQL提供了两种存储引擎：MyISAM和
InnoDB，MySQL4和5使用默认的MyISAM存储引擎。从MySQL5.5开始，MySQL已将默认存储引擎从MyISAM更改为InnoDB。

MyISAM没有提供事务支持，而InnoDB提供了事务支持。

 **二、常用的MySQL调优策略**

1、硬件层相关优化

修改服务器[BI](http://www.itpub.net/tree/index_339/)OS设置

选择Performance Per Watt Optimized(DAPC)模式，发挥CPU最大性能。

Memory Frequency(内存频率)选择Maximum Performance(最佳性能)

内存设置菜单中，启用Node Interleaving，避免NUMA问题

2、磁盘I/O相关

使用SSD硬盘

如果是磁盘阵列存储，建议阵列卡同时配备CACHE及BBU模块，可明显提升IOPS。

raid级别尽量选择raid10，而不是raid5。

3、文件系统层优化

使用deadline/noop这两种I/O调度器，千万别用cfq

使用xfs文件系统，千万别用ext3;ext4勉强可用，但业务量很大的话，则一定要用xfs；文件系统mount参数中增加：noatime,
nodiratime, nobarrier几个选项(nobarrier是xfs文件系统特有的)。

4、内核参数优化

修改vm.swappiness参数，降低swap使用率。RHEL7/CentOS7以上则慎重设置为0，可能发生OOM。

调整vm.dirty_background_ratio、vm.dirty_ratio内核参数，以确保能持续将脏数据刷新到磁盘，避免瞬间I/O写。产生等待。

调整net.ipv4.tcp_tw_recycle、net.ipv4.tcp_tw_reuse都设置为1，减少TIME_WAIT，提高TCP效率。

5、MySQL参数优化建议

建议设置default-storage-engine=InnoDB，强烈建议不要再使用MyISAM引擎。

调整innodb_buffer_pool_size的大小，如果是单实例且绝大多数是InnoDB引擎表的话，可考虑设置为物理内存的50% -70%左右。

设置innodb_file_per_table = 1，使用独立表空间。

调整innodb_data_file_path = ibdata1:1G:autoextend，不要用默认的10M,在高并发场景下，性能会有很大提升。

设置innodb_log_file_size=256M，设置innodb_log_files_in_group=2，基本可以满足大多数应用场景。

调整max_connection(最大连接数)、max_connection_error(最大错误数)设置，根据业务量大小进行设置。

另外，open_files_limit、innodb_open_files、table_open_cache、table_definition_cache可以设置大约为max_connection的10倍左右大小。

key_buffer_size建议调小，32M左右即可，另外建议关闭query cache。

mp_table_size和max_heap_table_size设置不要过大，另外sort_buffer_size、join_buffer_size、read_buffer_size、read_rnd_buffer_size等设置也不要过大。

 **三、 MySQL常见的应用架构分享**

1、主从复制解决方案

这是MySQL自身提供的一种高可用解决方案，数据同步方法采用的是MySQL replication技术。MySQL
replication就是从服务器到主服务器拉取二进制日志文件，然后再将日志文件解析成相应的SQL在从服务器上重新执行一遍主服务器的操作，通过这种方式保证数据的一致性。

为了达到更高的可用性，在实际的应用环境中，一般都是采用MySQL
replication技术配合高可用集群软件keepalived来实现自动failover，这种方式可以实现95.000%的SLA。

2、MMM/MHA高可用解决方案

MMM提供了MySQL主主复制配置的监控、故障转移和管理的一套可伸缩的脚本套件。在MMM高可用方案中，典型的应用是双主多从架构，通过MySQL
replication技术可以实现两个服务器互为主从，且在任何时候只有一个节点可以被写入，避免了多点写入的数据冲突。同时，当可写的主节点故障时，MMM套件可以立刻监控到，然后将服务自动切换到另一个主节点，继续提供服务，从而实现MySQL的高可用。

3、Heartbeat/SAN高可用解决方案

在这个方案中，处理failover的方式是高可用集群软件Heartbeat，它监控和管理各个节点间连接的网络，并监控集群服务，当节点出现故障或者服务不可用时，自动在其他节点启动集群服务。在数据共享方面，通过SAN(Storage
Area Network)存储来共享数据，这种方案可以实现99.990%的SLA。

4、Heartbeat/DRBD高可用解决方案

此方案处理failover的方式上依旧采用Heartbeat，不同的是，在数据共享方面，采用了基于块级别的数据同步软件DRBD来实现。

DRBD是一个用软件实现的、无共享的、服务器之间镜像块设备内容的存储复制解决方案。和SAN网络不同，它并不共享存储，而是通过服务器之间的网络复制数据。

 **四、MySQL经典应用架构**

其中：

Dbm157是MySQL主，dbm158是MySQL主的备机，dbs159/160/161是MySQL从。

MySQL写操作一般采用基于heartbeat+DRBD+MySQL搭建高可用集群的方案。通过heartbeat实现对MySQL主进行状态监测，而DRBD实现dbm157数据同步到dbm158。

读操作普遍采用基于LVS+Keepalived搭建高可用高扩展集群的方案。前端AS应用通过提高的读VIP连接LVS，LVS有keepliaved做成高可用模式，实现互备。

最后，MySQL主的从节点dbs159/160/161通过MySQL主从复制功能同步MySQL主的数据，通过lvs功能提供给前端AS应用进行读操作，并实现负载均衡。

  
  
---  
  
[本主题由 〇〇 于 2017-8-31 11:55
移动](http://www.itpub.net/forum.php?mod=misc&action=viewthreadmod&tid=2091675
"帖子模式")  
  
  


---
### ATTACHMENTS
[07f90c82e1f6d2c035b7c6252c71fb60]: media/wKioL1j5xzTi9mswAAAwafwrvME309.jpg
[wKioL1j5xzTi9mswAAAwafwrvME309.jpg](media/wKioL1j5xzTi9mswAAAwafwrvME309.jpg)
>hash: 07f90c82e1f6d2c035b7c6252c71fb60  
>source-url: http://s4.51cto.com/wyfs02/M01/91/F8/wKioL1j5xzTi9mswAAAwafwrvME309.jpg  
>file-name: wKioL1j5xzTi9mswAAAwafwrvME309.jpg  

[14134beddca9416bc65a4fbb0c03298a]: media/wKiom1j5y8rgIv3JAAAxkEsaZh8112.jpg
[wKiom1j5y8rgIv3JAAAxkEsaZh8112.jpg](media/wKiom1j5y8rgIv3JAAAxkEsaZh8112.jpg)
>hash: 14134beddca9416bc65a4fbb0c03298a  
>source-url: http://s1.51cto.com/wyfs02/M01/91/FA/wKiom1j5y8rgIv3JAAAxkEsaZh8112.jpg  
>file-name: wKiom1j5y8rgIv3JAAAxkEsaZh8112.jpg  

[1d2e8a6576e6d547fbc39faa95935f04]: media/wKioL1j5x0-Rt7usAAAtC9WNeBM419.jpg
[wKioL1j5x0-Rt7usAAAtC9WNeBM419.jpg](media/wKioL1j5x0-Rt7usAAAtC9WNeBM419.jpg)
>hash: 1d2e8a6576e6d547fbc39faa95935f04  
>source-url: http://s2.51cto.com/wyfs02/M02/91/F8/wKioL1j5x0-Rt7usAAAtC9WNeBM419.jpg  
>file-name: wKioL1j5x0-Rt7usAAAtC9WNeBM419.jpg  

[593446c6b97b3c4212d64bc38ed4392f]: media/wKioL1j5y-CBwqenAABcNZGGaqI097.jpg
[wKioL1j5y-CBwqenAABcNZGGaqI097.jpg](media/wKioL1j5y-CBwqenAABcNZGGaqI097.jpg)
>hash: 593446c6b97b3c4212d64bc38ed4392f  
>source-url: http://s5.51cto.com/wyfs02/M01/91/F9/wKioL1j5y-CBwqenAABcNZGGaqI097.jpg  
>file-name: wKioL1j5y-CBwqenAABcNZGGaqI097.jpg  

[9c78185bd7a37edc626b9c2fdb62f480]: media/arw_r.gif
[arw_r.gif](media/arw_r.gif)
>hash: 9c78185bd7a37edc626b9c2fdb62f480  
>source-url: http://www.itpub.net/template/itpub/image/arw_r.gif  
>file-name: arw_r.gif  

[9d60a49f59017478ed7e89a2fd3896bc]: media/MySQL数据库常用架构设计_-_MySQL及其它开源数据库_-_ITPUB论坛－中国最专业的IT技术社区.png
[MySQL数据库常用架构设计_-_MySQL及其它开源数据库_-_ITPUB论坛－中国最专业的IT技术社区.png](media/MySQL数据库常用架构设计_-_MySQL及其它开源数据库_-_ITPUB论坛－中国最专业的IT技术社区.png)
[a53d5c44342d538b1e318403c84b104e]: media/wKiom1j5xqOyqprmAAA4W5Syh94335.jpg-wh_651x-s_3230881932.jpg
[wKiom1j5xqOyqprmAAA4W5Syh94335.jpg-wh_651x-s_3230881932.jpg](media/wKiom1j5xqOyqprmAAA4W5Syh94335.jpg-wh_651x-s_3230881932.jpg)
>hash: a53d5c44342d538b1e318403c84b104e  
>source-url: http://s2.51cto.com/wyfs02/M02/91/F8/wKiom1j5xqOyqprmAAA4W5Syh94335.jpg-wh_651x-s_3230881932.jpg  
>file-name: wKiom1j5xqOyqprmAAA4W5Syh94335.jpg-wh_651x-s_3230881932.jpg  

[bd532db907f78a4a3dfc13e31277b767]: media/112302hvfmv7gfa7crricv.j.png
[112302hvfmv7gfa7crricv.j.png](media/112302hvfmv7gfa7crricv.j.png)
>hash: bd532db907f78a4a3dfc13e31277b767  
>source-url: http://file.itpub.net/forum/201708/31/112302hvfmv7gfa7crricv.jpg  
>file-name: 112302hvfmv7gfa7crricv.jpg.png  

[e679735ca6f5ed898ba98e4433565003]: media/online_member.gif
[online_member.gif](media/online_member.gif)
>hash: e679735ca6f5ed898ba98e4433565003  
>source-url: http://www.itpub.net/static/image/common/online_member.gif  
>file-name: online_member.gif  

---
### NOTE ATTRIBUTES
>Created Date: 2018-02-13 02:20:15  
>Last Evernote Update Date: 2018-10-01 15:35:38  
>author: YangKwong  
>source: web.clip  
>source-url: http://www.itpub.net/thread-2091675-1-1.html  