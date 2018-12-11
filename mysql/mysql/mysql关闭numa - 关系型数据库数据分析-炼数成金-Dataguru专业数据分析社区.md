# mysql关闭numa - 关系型数据库数据分析-炼数成金-Dataguru专业数据分析社区

  

电梯直达

**[ _1_ #](http://f.dataguru.cn/thread-612587-1-1.html) **

_发表于 2016-4-3 22:16_ |
[只看该作者](http://f.dataguru.cn/forum.php?mod=viewthread&tid=612587&page=1&authorid=27876)

|  
  
都说my[SQL](http://www.dataguru.cn/article-8711-1.html?union_site=innerlink)数据库使用的时候需要关闭numa，那么什么原因呢，请见下文：  
  
  
**[MySQL单机多实例方案](http://www.hellodb.net/2011/06/mysql_multi_instance.html)**  
<http://www.hellodb.net/tag/numa>  
  

MySQL单机多实例方案，是指在一台物理的PC服务器上运行多个MySQL数据库实例，为什么要这样做？这样做的好处是什么？  
1.存储技术飞速发展，IO不再是瓶颈  
普通PC服务器的CPU与IO资源不均衡，因为磁盘的IO能力非常有限，为了满足应用的需要，往往需要配置大量的服务器，这样就造成CPU资源的大量浪费。但是，Flash存储技术的出现改变了这一切，单机的IO能力不再是瓶颈，可以在单机运行多个MySQL实例提升CPU利用率。  
2.MySQL对多核CPU利用率低  
MySQL对多核CPU的利用率不高，一直是个问题，5.1版本以前的MySQL，当CPU超过4个核时，性能无法线性扩展。虽然MySQL后续版本一直在改进这个问题，包括Innodb
plugin和Percona XtraDB都对多核CPU的利用率改进了很多，但是依然无法实现性能随着CPU
core的增加而提升。我们现在常用的双路至强服务器，单颗CPU有4-8个core，在操作系统上可以看到16-32
CPU(每个core有两个线程)，四路服务器可以达到64
core甚至更多，所以提升MySQL对于多核CPU的利用率是提升性能的重要手段。下图是Percona的一份测试数据：

3.NUMA对MySQL性能的影响  
我们现在使用的PC服务器都是NUMA架构的，下图是Intel 5600 CPU的架构：

NUMA的内存分配策略有四种：  
1.缺省(default)：总是在本地节点分配（分配在当前进程运行的节点上）；  
2.绑定(bind)：强制分配到指定节点上；  
3.交叉(interleave)：在所有节点或者指定的节点上交织分配；  
4.优先(preferred)：在指定节点上分配，失败则在其他节点上分配。  
因为NUMA默认的内存分配策略是优先在进程所在CPU的本地内存中分配，会导致CPU节点之间内存分配不均衡，当某个CPU节点的内存不足时，会导致swap产生，而不是从远程节点分配内存。这就是所谓的swap
insanity现象。  
**MySQL采用了线程模式，对于NUMA特性的支持并不好，如果单机只运行一个MySQL实例，我们可以选择关闭NUMA**
，关闭的方法有三种：1.硬件层，在BIOS中设置关闭；2.OS内核，启动时设置numa=off；3.可以用numactl命令将内存分配策略修改为interleave（交叉），有些硬件可以在BIOS中设置。  
如果单机运行多个MySQL实例，我们可以将MySQL绑定在不同的CPU节点上，并且采用绑定的内存分配策略，强制在本节点内分配内存，这样既可以充分利用硬件的NUMA特性，又避免了单实例MySQL对多核CPU利用率不高的问题。

资源隔离方案  
1.CPU，Memory  
numactl –cpubind=0
–localalloc，此命令将MySQL绑定在不同的CPU节点上，cpubind是指NUMA概念中的CPU节点，可以用numactl
–hardware查看，localalloc参数指定内存为本地分配策略。  
2.IO  
我们在机器中内置了fusionio卡(320G)，配合flashcache技术，单机的IO不再成为瓶颈，所以IO我们采用了多实例共享的方式，并没有对IO做资源限制。多个MySQL实例使用相同的物理设备，不同的目录的来进行区分。  
3.Network  
因为单机运行多个实例，必须对网络进行优化，我们通过多个的IP的方式，将多个MySQL实例绑定在不同的网卡上，从而提高整体的网络能力。还有一种更高级的做法是，将不同网卡的中断与CPU绑定，这样可以大幅度提升网卡的效率。  
4.为什么不采用虚拟机  
虚拟机会耗费额外的资源，而且MySQL属于IO类型的应用，采用虚拟机会大幅度降低IO的性能，而且虚拟机的管理成本比较高。所以，我们的数据库都不采用虚拟机的方式。  
5.性能  
下图是Percona的测试数据，可以看到运行两个实例的提升非常明显。

高可用方案  
因为单机运行了多个MySQL实例，所以不能采用主机层面的HA策略，比如heartbeat。因为当一个MySQL实例出现问题时，无法将整个机器切换。所以必须改为MySQL实例级别的HA策略，我们采用了自己开发的MySQL访问层来解决HA的问题，当某个实例出问题时，只切换一个实例，对于应用来说，这一层是透明的。  
MySQL单机多实例方案的优点  
1.节省成本，虽然采用Flash存储的成本比较高，但是如果可以缩减机器的数量，考虑到节省电力和机房使用的成本，还是比单机单实例的方案更便宜。  
2.提升利用率，利用NUMA特性，将MySQL实例绑定在不同的CPU节点，不仅提高了CPU利用率，同时解决了MySQL对多核CPU的利用率问题。  
3.提升用户体验，采用Flash存储技术，大幅度降低IO响应时间，有助于提升用户的体验。  
–EOF–  
关于NUMA可以参考这篇文章：NUMA与Intel新一代Xeon处理器

  
  
  
---  
  
  


---
### ATTACHMENTS
[9c78185bd7a37edc626b9c2fdb62f480]: media/arw_r-2.gif
[arw_r-2.gif](media/arw_r-2.gif)
>hash: 9c78185bd7a37edc626b9c2fdb62f480  
>source-url: http://f.dataguru.cn/static/image/common/arw_r.gif  
>file-name: arw_r.gif  

[9d60a49f59017478ed7e89a2fd3896bc]: media/mysql关闭numa_-_关系型数据库数据分析-炼数成金-Dataguru专业数据分析社区.png
[mysql关闭numa_-_关系型数据库数据分析-炼数成金-Dataguru专业数据分析社区.png](media/mysql关闭numa_-_关系型数据库数据分析-炼数成金-Dataguru专业数据分析社区.png)
[e679735ca6f5ed898ba98e4433565003]: media/online_member-2.gif
[online_member-2.gif](media/online_member-2.gif)
>hash: e679735ca6f5ed898ba98e4433565003  
>source-url: http://f.dataguru.cn/static/image/common/online_member.gif  
>file-name: online_member.gif  


---
### TAGS
{numa}

---
### NOTE ATTRIBUTES
>Created Date: 2018-01-09 02:56:15  
>Last Evernote Update Date: 2018-10-01 15:35:39  
>author: YangKwong  
>source: web.clip  
>source-url: http://f.dataguru.cn/thread-612587-1-1.html  