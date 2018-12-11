# 第四课（1）——MySQL体系结构 - 开始的第一步 - 博客园

  

##
[第四课（1）——MySQL体系结构](http://www.cnblogs.com/cjing2011/p/c46ebfb372476c625d5fbc23a56deb65.html)

# 学习目标

一、MySQL体系结构  
二、MySQL内存结构  
三、MySQL文件结构  
四、Innodb体系结构

* * *

# MySQL体系结构

### 一、MySQL体系结构图

#### 1、Mysql是由SQL接口，解析器，优化器，缓存，存储引擎组成的（SQL
Interface、Parser、Optimizer、Caches&Buffers、Pluggable Storage Engines）

#

（1） Connectors指的是不同语言中与SQL的交互  
（2）Management Serveices & Utilities： 系统管理和控制工具，例如备份恢复、Mysql复制、集群等  
（3）Connection Pool: 连接池：管理缓冲用户连接、用户名、密码、权限校验、线程处理等需要缓存的需求  
（4）SQL Interface: SQL接口：接受用户的SQL命令，并且返回用户需要查询的结果。比如select from就是调用SQL
Interface  
（5）Parser: 解析器，SQL命令传递到解析器的时候会被解析器验证和解析。解析器是由Lex和YACC实现的，是一个很长的脚本， 主要功能：  
a . 将SQL语句分解成数据结构，并将这个结构传递到后续步骤，以后SQL语句的传递和处理就是基于这个结构的  
b. 如果在分解构成中遇到错误，那么就说明这个sql语句是不合理的  
（6）Optimizer: 查询优化器，SQL语句在查询之前会使用查询优化器对查询进行优化。他使用的是“选取-投影-联接”策略进行查询。  
用一个例子就可以理解： select uid,name from user where gender = 1;  
这个select 查询先根据where 语句进行选取，而不是先将表全部查询出来以后再进行gender过滤  
这个select查询先根据uid和name进行属性投影，而不是将属性全部取出以后再进行过滤  
将这两个查询条件联接起来生成最终查询结果  

（7） Cache和Buffer（高速缓存区）： 查询缓存，如果查询缓存有命中的查询结果，查询语句就可以直接去查询缓存中取数据。  
通过LRU算法将数据的冷端溢出，未来得及时刷新到磁盘的数据页，叫脏页。  
这个缓存机制是由一系列小缓存组成的。比如表缓存，记录缓存，key缓存，权限缓存等  
（8）Engine ：存储引擎。存储引擎是MySql中具体的与文件打交道的子系统。也是Mysql最具有特色的一个地方。  
Mysql的存储引擎是插件式的。它根据MySql AB公司提供的文件访问层的一个抽象接口来定制一种文件访问机制（这种访问机制就叫存储引擎）  
现在有很多种存储引擎，各个存储引擎的优势各不一样，最常用的MyISAM,InnoDB,BDB  
默认下MySql是使用MyISAM引擎，它查询速度快，有较好的索引优化和数据压缩技术。但是它不支持事务。  
InnoDB支持事务，并且提供行级的锁定，应用也相当广泛。  
Mysql也支持自己定制存储引擎，甚至一个库中不同的表使用不同的存储引擎，这些都是允许的。

### 二、MySQL内存结构

Mysql 内存分配规则是：用多少给多少，最高到配置的值，不是立即分配  
  
_MySQL中内存大致分为：全局内存（Global buffer）、线程内存（Thread buffer）两大部分_

##### 1、全局内存（Global buffer）

  
（1）innodb_buffer_pool_size：

    
    
    （1.1） innodb高速缓冲data和索引，简称IBP，这个是Innodb引擎中影响性能最大的参数。建议将IBP设置的大一些，单实例下，建议设置为可用RAM的50%~80%。
    （1.2）innodb不依赖OS，而是自己缓存了所有数据，包括索引数据、行数据等等，这个和myisam有差别。
    （1.3）IBP有一块buffer用于插入缓冲，在插入时，先写入内存之后再合并后顺序写入磁盘；在合并到磁盘的时候会引发较大的IO操作，对实际操作造成影响。（看上去的表现是抖动，TPS变低）
    （1.4）show global status like ‘innodb_buffer_pool_%’ 查看IBP状态，单位是page(16kb),其中，Innodb_buffer_pool_wait_free 如果较大，需要加大IBP设置
    （1.5）InnoDB会定时（约每10秒）将脏页刷新到磁盘，默认每次刷新10页；要是脏页超过了指定数量（innodb_max_dirty_pages_pct），InnoDB则会每秒刷100页脏页
    （1.6）innodb_buffer_pool_instances可以设置pool的数量
    （1.7）show engine innodb status\G    可以查看innodb引擎状态
    

（2）innodb_additional_mem_pool_size:

    
    
    （2.1）指定InnoDB用来存储数据字典和其他内部数据结构的内存池大小。缺省值是8M（8388608）。通常不用太大，只要够用就行，应该与表结构的复杂度有关系。如果不够用，MySQL会在错误日志中写入一条警告信息。
    

（3）innodb_log_buffer_size：

    
    
    （3.1）innodb redo日志缓冲，提高redo写入效率。如果表操作中包含大量并发事务（或大规模事务），并且在事务提交前要求记录日志文件，请尽量调高此项值，以提高日志效率。
    （3.2）show global status 查看 Innodb_log_waits 是否大于0，是的话，就需要提高 innodb_log_buffer_size，否则维持原样。
    （3.3）show global stauts 查看30~60秒钟 Innodb_os_log_written 的间隔差异值，即可计算出 innodb_log_buffer_size 设置多大合适。
    

默认8M，一般设置为16 ~ 64M足够了。  
  
（4）key_buffer_size：

    
    
    （4.1）myisam引擎中表的索引 的缓存大小，默认值=16M；单个key_buffer_size最大只有4G（32-bit系统下最大4G，64-bit下可以超过）
    （4.2）若主要使用myisam存储引擎，则设置最高不超过物理内存的20%~50%，
    （4.4）即便全是innodb表,没用MyISAM，也有必要设置key_buffer_size用于缓存临时表的索引，推荐设置32MB
    （4.5）关于临时表，如果内存tmp_table_size（Created_tmp_tables）不够的话，内部的临时磁盘表是MyISAM表（Created_tmp_disk_tables）。show global status like 'Create%'; show variables like 'tmp%';
    

（5）query_cache_size ：

    
    
     查询高速缓冲，缓存结果，减少硬解析（建议关闭，如果真需要查询缓存可以借助redis等缓存）
         <img src="c5b9e726-adee-410e-9f6b-704d860aab12_files/6ce17d74-b783-4c7b-8f3c-4f99a6f53876.png" border="0" alt="" name="">
    

（6）table_definition_cache：

    
    
       （6.1）表定义文件描述缓存，提高表打开效率。是frm文件在内存中的映射。MySQL需要打开frm文件，并将其内容初始化为Table Share 对象。这里存放与存储引擎无关的，独立的表定义相关信息。
    

（7）table_open_cache：

    
    
    （7.1）表空间文件描述缓冲，提高表打开效率。
    （7.2）增加table_open_cache，会增加文件描述符（ulimit -a查看系统的文件描述符），当把table_open_cache设置的过大时，如果系统处理不了这么多文件描述符，那么就会出现客户端失效、连接不上。
    （7.3）table_open_cache，也就是平时说的table cache。存放当前已经打开的表句柄，与表创建时指定的存储引擎相关。请注意和table_define_cache参数的区别。
    

_为什么MySQL会出现table_open_cahce和table_define_cache这两个概念？_  
_是因为：MySQL支持不同的存储引擎，每种存储引擎，数据存储的格式都是不一样的，因此需要指定一个存储引擎相关的handler。这就有了table
cache的作用（table_open_cache参数）。另外表的定义也需要存放内存中，而表的定义frm文件每个存储引擎是通用的，需要另外独立开来，这就有了table
definition cache。_

（8）max_heap_table_size和tmp_table_size：

    
    
    （8.1）max_heap_table_size 参数：定义了MEMORY、HEAP表的最大容量，如果内存不够，则不允许写入数据
    （8.2）tmp_table_size参数：规定了内部内存临时表的最大值，每个线程都要分配。（实际起限制作用的是tmp_table_size和max_heap_table_size的最小值。）如果内存临时表超出了限制，MySQL就会自动地把它转化为基于磁盘的MyISAM表，存储在指定的tmpdir目录下。
    （8.3）优化查询语句的时候，要避免使用临时表，如果实在避免不了的话，要保证这些临时表是存在内存中的，否则临时表超过内存临时表的限制，会自动转化为基于磁盘的Myisam表。
    

##### 2、线程内存（Thread buffer）

_每个连接到MySQL服务器的线程都需要有自己的缓冲。大概需要立刻分配256K，甚至在线程空闲时，它们使用默认的线程堆栈，网络缓存等。_  
_事务开始之后，则需要增加更多的空间。运行较小的查询可能仅给指定的线程增加少量的内存消耗。_  
_如果对数据表做复杂的操作例如扫描、排序或者需要临时表，则需分配大约read_buffer_size、sort_buffer_size，read_rnd_buffer_size，tmp_table_size大小的内存空间_  
_不过它们只是在需要的时候才分配，并且在那些操作做完之后就释放了。_  
  
（1）read_buffer_size：

    
    
    是MySQL读入缓冲区大小。对表进行顺序扫描的请求将分配一个读入缓冲区，MySQL会为它分配一段内存缓冲区。read_buffer_size变量控制这一缓冲区的大小。如果对表的顺序扫描请求非常频繁，        并且你认为频繁扫描进行得太慢，可以通过增加该变量值以及内存缓冲区大小提高其性能。
    

（2）read_rnd_buffer_size：

    
    
    是MySQL的随机读缓冲区大小。当按任意顺序读取行时(例如，按照排序顺序)，将分配一个随机读缓存区。进行排序查询时，MySQL会首先扫描一遍该缓冲，以避免磁盘搜索，提高查询速度，如果需要排序大量数据，可适当调高该值。但MySQL会为每个客户连接发放该缓冲空间，所以应尽量适当设置该值，以避免内存开销过大。
    

（3）sort_buffer_size：

    
    
    是MySQL执行排序使用的缓冲大小。如果想要增加ORDER BY的速度，首先看是否可以让MySQL使用索引而不是额外的排序阶段。如果不能，可以尝试增加sort_buffer_size变量的大小。
    

（4）join_buffer_size：

    
    
    应用程序经常会出现一些两表（或多表）Join的操作需求，MySQL在完成某些 Join 需求的时候（all/index join），为了减少参与Join的“被驱动表”的读取次数以提高性能，需要使用到 Join Buffer 来协助完成 Join操作。当 Join Buffer 太小，MySQL 不会将该 Buffer 存入磁盘文件，而是先将Join Buffer中的结果集与需要 Join 的表进行 Join 操作，然后清空 Join Buffer 中的数据，继续将剩余的结果集写入此 Buffer 中，如此往复。这势必会造成被驱动表需要被多次读取，成倍增加 IO 访问，降低效率。
    

（5）binlog_cache_size：

    
    
    在事务过程中容纳二进制日志SQL 语句的缓存大小。二进制日志缓存是服务器支持事务存储引擎并且服务器启用了二进制日志(—log-bin 选项)的前提下为每个客户端分配的内存，注意，是每个Client 都可以分配设置大小的binlog cache 空间。如果系统中经常会出现多语句事务的话，可以尝试增加该值的大小，以获得更好的性能。当然，我们可以通过MySQL 的以下两个状态变量来判断当前的binlog_cache_size 的状况：Binlog_cache_use 和Binlog_cache_disk_use。“max_binlog_cache_size”：和"binlog_cache_size"相对应，但是所代表的是binlog 能够使用的最大cache 内存大小。当我们执行多语句事务的时候，max_binlog_cache_size 如果不够大的话，系统可能会报出“ Multi-statement transaction required more than 'max_binlog_cache_size' bytes ofstorage”的错误。
    其中需要注意的是：table_cache表示的是所有线程打开的表的数目，和内存无关。
    

（6）tmp_table_size：

    
    
    是MySQL的临时表缓冲大小。所有联合在一个DML指令内完成，并且大多数联合甚至可以不用临时表即可以完成。大多数临时表是基于内存的(HEAP)表。具有大的记录长度的临时表 (所有列的长度的和)或包含BLOB列的表存储在硬盘上。如果某个内部heap（堆积）表大小超过tmp_table_size，MySQL可以根据需要自动将内存中的heap表改为基于硬盘的MyISAM表。还可以通过设置tmp_table_size选项来增加临时表的大小。也就是说，如果调高该值，MySQL同时将增加heap表的大小，可达到提高联接查询速度的效果。
    

（7）thread_stack ：

    
    
    主要用来存放每一个线程自身的标识信息，如线程id，线程运行时基本信息等等，我们可以通过 thread_stack 参数来设置为每一个线程栈分配多大的内存。 
    

（8）thread_cache_size：

    
    
    如果我们在MySQL服务器配置文件中设置了thread_cache_size，当客户端断开之后，服务器处理此客户的线程将会缓存起来以响应下一个客户而不是销毁（前提是缓存数未达上限）。
    

（9）net_buffer_length：

    
    
    客户发出的SQL语句期望的长度。如果语句超过这个长度，缓冲区自动地被扩大，直到max_allowed_packet个字节。
    

（10）bulk_insert_buffer_size：

    
    
    如果进行批量插入，可以增加bulk_insert_buffer_size变量值的方法来提高速度，但是，这只能对myisam表使用。
    

##### 3、overhead

（1）自适应哈希索引（Adaptive index hash）

    
    
    （1.1）哈希索引是一种非常快的等值查找方法（注意：必须是等值，哈希索引对非等值查找方法无能为力），它查找的时间复杂度为常量，InnoDB采用自适用哈希索引技术，它会实时监控表上索引的使用情况，如果认为建立哈希索引可以提高查询效率，则自动在内存中的“自适应哈希索引缓冲区”中建立哈希索引。
    （1.2）之所以该技术称为“自适应”是因为完全由InnoDB自己决定，不需要DBA人为干预。它是通过缓冲池中的B+树构造而来，且不需要对整个表建立哈希索引，因此它的数据非常快。
    （1.3）InnoDB官方文档显示，启用自适应哈希索引后，读和写性能可以提高2倍，对于辅助索引的连接操作，性能可以提高5被，因此默认情况下为开启，可以通过参数innodb_adaptive_hash_index来禁用此特性。
    （1.4）哈希索引总是基于表上已存在的B树索引来建立的。InnoDB会在为该B树定义的键的一个前缀上建立哈希索引，不管该键有多长。哈希索引可以是部分的：它不要求整个B树索引被缓存在缓冲池中。InnoDB根据需要对被经常访问索引的那些页面建立哈希索引。
    

（2）System dictionary hash  
（3）Locking system  
（4）Sync_array  
（5）Os_events

### 三、MySQL文件结构

##### 1、参数文件

##### 2、错误日志文件

##### 3、二进制日志文件

    
    
    二进制日志的开启：log-bin=/httx/run/mysql/data/mysql-bin
    设置二进制日志模式为row模式：binlog_format=ROW 
    

查看row模式日志的方法：  
mysqlbinlog –base64-output=decode-rows -vv mysql-bin.000001
，其中–base64-output=decode-rows是将原编码过的日志转码；而-vv则时以注释形式显示做过的SQL操作

##### 4、慢查询日志

    
    
    show variables like 'long_query_time';默认的慢查询日志的阀值是10秒，也就是查询时长超过10秒就会记录到慢查询日志文件；
    慢查询日志的启动：mysql5.6开启慢日志需要同时设置两个参数：slow_query_log=ON，slow_query_log_file=/path to/slow.log。其中 slow_query_log表示开启慢日志，如果不设置slow_query_log而只是定义slow_query_log_file慢日志文件路径，慢日志设置是不生效的。
    

##### 5、Genaral日志

    
    
    启动general log和慢日志类似，需要同时设置两个参数：general_log=ON开启general日志；general_log_file=/path to/general.log设置general日志的文件路径。
    

##### 6、Redo log

    
    
    （1）redo log的作用简介：InnoDB有buffer pool（简称bp或IBP）。bp是数据库页面的缓存，对InnoDB的任何修改操作都会首先在bp的page上进行，然后这样的页面将被标记为dirty（脏页）并被放到专门的flush list上，后续将由master thread或专门的刷脏线程阶段性的将这些页面写入磁盘（disk or ssd）。这样的好处是避免每次写操作都操作磁盘导致大量的随机IO，阶段性的刷脏可以将多次对页面的修改merge成一次IO操作，同时异步写入也降低了访问的时延。
    然而，如果在dirty page还未刷入磁盘时，server非正常关闭，这些修改操作将会丢失，如果写入操作正在进行，甚至会由于损坏数据文件导致数据库不可用。为了避免上述问题的发生，Innodb将所有对页面的修改操作写入一个专门的文件，并在数据库启动时从此文件进行恢复操作，这个文件就是redo log file。这样的技术推迟了bp页面的刷新，从而提升了数据库的吞吐，有效的降低了访问时延。带来的问题是额外的写redo log操作的开销（顺序IO，当然很快），以及数据库启动时恢复操作所需的时间。
    （2）redo log相关的参数：
    
    innodb_log_file_size参数：定义ib_logfile*文件的大小，默认是50331648（48M），ib_logfile*就是redo log文件；
    innodb_log_files_in_group参数：定义redo log的个数，innodb_log_files_in_group=2时，则会有ib_logfile0、ib_logfile1两个redo log文件，这两个ib_logfile文件顺序写、循环写；
    innodb_log_group_home_dir参数：定义redo log的存放路径，也即是ib_logfile的存放路径。
    
    （3）binlog和redo log的关系（日志记录流程）：
    binlog和redo log的正常协同流程：mysql在接收一个SQL请求后，首先记录binlog，同时binlog会通知innodb准备变更数据（例如，修改t1表的id=100的记录），innodb在把id=100所在的page拉取到高速缓冲区，此时，redo log中会记录开始标签，日志记录完成后返回到server（此时跟engine没有关系了），在redo log中记录结束标签；
    主机宕机下binlog和redo log的协同流程：binlog完整记录了变更数据，redo log记录开始标签，但是日志记录还没来得及返回给server就宕机了，主机重启后，会比较binlog和redo log是否一致，由于redo log没有结束标签，数据库进行恢复操作。redo log根据开始标签将id=100的记录所在page拉取到高速缓冲区，然后返回给server，并记录结束标签。
    

##### 7、Pid文件

    
    
    mysql实例的进程ID文件
    

##### 8、Socket文件

    
    
    当用unix套接字方式进行连接时需要的文件
    

##### 9、MySQL表结构文件

    
    
    .frm后缀命名的文件都是表结构文件，和存储引擎类型无关。所有的表都会生成一个.frm文件；
    

##### 10、innodb数据文件

  
（1）共享表空间：共享表空间文件以.ibdata*来命名；
共享表空间下，innodb所有数据保存在一个单独的表空间里面，而这个表空间可以由很多个文件组成，一个表可以跨多个文件存在，所以其大小限制不再是文件大小的限制，而是其自身的限制。从Innodb的官方文档中可以看到，其表空间的最大限制为64TB，也就是说，Innodb的单表限制基本上也在64TB左右了，当然这个大小是包括这个表的所有索引等其他相关数据。  
_共享表空间主要存放double write、undo log（undo log没有独立的表空间，需要存放在共享表空间）_  
（2）独立表空间：每个表拥有自己独立的表空间用来存储数据和索引。  
（3）查看数据库是否启用独立表空间：  
show variables like
‘innodb_file_per_table’;查看，innodb_file_per_table=ON,表示启用了独立表空间；  
（4）使用独立表空间的优点：  
如果使用软链接将大表分配到不同的分区上，易于管理数据文件  
易于监控解决IO资源使用的问题；  
易于修复和恢复损坏的数据；  
相互独立的，不会影响其他innodb表；  
导出导入只针对单个表，而不是整个共享表空间；  
解决单个文件大小的限制；  
对于大量的delete操作，更易于回收磁盘空间；  
碎片较少，易于整理optimize table；  
易于安全审计；  
易于备份  
_如果在innodb表已创建后设置innodb_file_per_table，那么数据将不会迁移到单独的表空间上，而是续集使用之前的共享表空间。只有新创建的表才会分离到自己的表空间文件。_  
（5）共享表空间的数据文件配置：  
innodb_data_file_path参数：设置innoDB共享表空间数据文件的名字和大小，例如innodb_data_file_path=ibdata1:12M:autoextend（初始大小12M，不足自增）  
innodb_data_home_dir参数：innodb引擎的共享表空间数据文件的存放目录  
_目前主要是使用独立表空间，但是共享表空间也是需要的，共享表空间主要存放double write、undo log等_

##### 11、MYISAM文件

### 四、MySQL存储结构（Innodb存储结构）

    
    
    1、从物理意义上来讲，InnoDB表由共享表空间、日志文件组（redo log文件组）、表结构定义文件（.frm文件）组成。若将innodb_file_per_table设置为on，则系统将为每一个表单独的生成一个table_name.ibd的文件，在此文件中，存储与该表相关的数据、索引、表的内部数据字典信息。
    表结构文件则以.frm结尾，.frm文件和存储引擎无关。
    

  

    
    
    （1）每页=16Kb（页类型：数据页、undo页、系统页、事务数据页、插入缓冲位图页、插入缓冲空闲列表页、未压缩的二进制大对象页、压缩的二进制大对象页）
    （2）区=64个连续的页=64*16Kb=1MB
    

2、行模式类型：  
  
3、行溢出  

### 五、innodb体系结构

  
_上图中，没有画出purge thread和page cleaner thread，mysql5.6版本后，这2个线程从master
thread里独立出来，缓解master thread的压力_

#### 1、主要的后台线程

##### （1）master thread

master thread是一个非常核心的后台线程，主要负责将缓冲池中的数据异步刷新到磁盘，保证数据的一致性，包括：脏页（dirty
page）的刷新、合并插入缓冲（insert buffer merge）、回滚页回收（undo purge）等。  
  
1、Master thread线程的优先级最高，内部主要是4个循环loop组成：主循环、后台循环、刷新循环、暂停循环。  
2、在master
thread线程里，每1秒或每10秒会触发1oop（循环体）工作，loop为主循环，大多数情况下都运行在这个循环体。loop通过sleep()来实现定时的操作，所以操作时间不精准。负载高的情况下可能会有延迟；  
3、dirty page：当事务(Transaction)需要修改某条记录（row）时，InnoDB需要将该数据所在的page从disk读到buffer
pool中，事务提交后，InnoDB修改page中的记录(row)。这时buffer pool中的page就已经和disk中的不一样了，我们称buffer
pool中的被修改过的page为dirty page。Dirty page等待flush到disk上。  
4、insert buffer merge：  
innodb使用insert
buffer”欺骗”数据库:对于为非唯一索引，辅助索引的修改操作并非实时更新索引的叶子页,而是把若干对同一页面的更新缓存起来做合并（merge）为一次性更新操作,转化随机IO
为顺序IO,这样可以避免随机IO带来性能损耗，提高数据库的写性能。  
（1）Insert Buffer是Innodb处理非唯一索引更新操作时的一个优化。最早的Insert
Buffer，仅仅实现Insert操作的Buffer，这也是Insert Buffer名称的由来。在后续版本中，Innodb多次对Insert
Buffer进行增强，到Innodb 5.5版本，Insert
Buffer除了支持Insert，还新增了包括Update/Delete/Purge等操作的buffer功能，Insert
Buffer也随之更名为Change Buffer。  
（2）insert buffer merge分为主动给merge和被动merge。  
（2.1）master thread线程里的insert buffer
merge是主动merge，原理是：a、若过去1秒内发生的IO小于系统IO能力的5%，则主动进行一次insert buffer
merge（merge的页面数为系统IO能力的5%且读取page采用async io模式）。 b、每10秒，必须触发一次insert buffer
merge（merge的页面数仍旧为系统IO能力的5%）  
（2.2）被动Merge，则主要是指在用户线程执行的过程中，由于种种原因，需要将insert
buffer的修改merge到page之中。被动Merge由用户线程完成，因此用户能够感知到merge操作带来的性能影响。例如：a、Insert操作，导致页面空间不足，需要分裂。由于insert
buffer只能针对单页面，不能buffer page split，因此引起页面的被动Merge；  
b、insert操作，由于其他各种原因，insert buffer优化返回失败，需要真正读取page时，也需要进行被动Merge；c、在进行insert
buffer操作时，发现insert buffer已经太大，需要压缩insert buffer。  
5、check point：

    
    
    （1）checkpoint干的事情：将缓冲池中的脏页刷新到磁盘，不同之处在于每次从哪里取多少脏页刷新到磁盘，以及什么时候触发checkpoint。
    （2）checkpoint解决的问题：
    a、缩短数据库的恢复时间(数据库宕机时，不需要重做所有的日志，因checkpoint之前的页都已经刷新回磁盘啦)
    b、缓冲池不够用时，将脏页刷新到磁盘(缓冲池不够用时，根据LRU算法算出最近最少使用的页，若此页为脏页，需要强制执行checkpoint将脏也刷回磁盘)
    c、重做日志不可用时，刷新脏页(采用循环使用的，并不是无限增大。当重用时，此时的重做日志还需要使用，就必须强制执行checkpoint将脏页刷回磁盘)
    

##### （2）IO thread

在innodb存储引擎中大量使用AIO来处理IO请求，这样可以极大提高数据库的性能，而IO thread的工作就是负责这些IO请求的回调处理（call
back）;  
  
_小知识_  
1、聚集索引：  
聚集索引不是一种单独的索引类型，而是一种存储数据方式。其具体细节依赖于实现方式，但是InnoDB的聚集索引实际上在同样的结构中保存了B+Tree索引和数据行。  
InnoDB的索引属于聚集索引，就是说表数据文件和索引文件都是同一个，表数据的分布按照主键排序，以B+TREE数据格式存储;  
MyISAM引擎的索引属于非聚集索引，索引文件跟数据文件是分开的。而索引文件的所指向的是对应数据的物理地址。  
2、辅助索引：非聚集索引：  
3、innodb_change_buffer_max_size：如果是日志类服务，可以考虑把这把这个增值调到50  
4、innodb_change_buffering：默认即可

##### （3）lock monitor thread

##### （4）error monitor thread

##### （5）purge thread

1、事务被提交后，其所使用的undo log可能将不再需要，因此需要purge thread来回收已经使用并分配的undo页；  
2、从mysql5.5开始，purge操作不再做主线程的一部分，而作为独立线程。  
3、开启这个功能：innodb_purge_threads=1。调整innodb_purge_batch_size来优化purge操作，batch
size指一次处理多少undo log pages， 调大这个参数可以加块undo log清理(类似oracle的undo_retention)。  
从mysql5.6开始，innodb_purge_threads调整范围从0–1到0–32，支持多线程purge，innodb-purge-batch-
size会被多线程purge共享  

##### （6）page cleaner thread

page cleaner
thread是在innodb1.2.x中引用的，作用是将之前版本中脏页的刷新操作都放入到单独的线程中来完成，其目的是为了减轻master
thread的工作及对于用户查询线程的阻塞，进一步提高innodb存储引擎的性能。  
1、将dirty page刷新到磁盘。  
2、两种算法：

    
    
    （1）LRU算法：基于lru list（最后访问的时间排序）的刷新顺序；
    （2）adaptive算法：基于flush list（最后修改时间的顺序）的刷新顺序；
    

3、innodb_adaptive_flushing=1，该值影响每秒刷新脏页的操作，开启此配置后，刷新脏页会通过判断产生重做日志的速度来判断最合适的刷新脏页的数量；  
4、innodb_flush_neighbors=1，InnoDB存储引挚还提供了flush Neighbor
page（刷新邻接页）的特性。InnoDB存储引挚从1.2.x版本开始提供了参数innodb_flush_neighbors,用来控制是否开启这个特性。  
对于传统的机械硬盘建议开启该特性；  
对于固态硬盘有着超高的IOPS性能，则建议将该参数设置为0,即关闭此特性，因为使用顺序IO没有任何性能收益.
在使用RAID的某些硬件上也应该禁用此设置,因为逻辑上连续的块在物理磁盘上并不能保证也是连续的。  
其工作原理为：当刷新一个脏页时，InnoDB存储引挚会检测该页所在区（extent）的所有页，如果是脏页，那么一起进行刷新。这样做的好处显而易见，通过AIO可以将多个IO写入操作合并为一个IO操作，故该工作机制在传统的机械硬盘下有着显著的优势。

##### 其他注意小点

（1）adaptive hash index（AHI）：

    
    
    提高buffer pool遍历page的效率O(1) VS O(B+Tree高度)；AHI会自动对buffer pool热点数据创建AHI（非持久化）；只支持等值查询；加入AHI的条件是：索引是否被访问17次以上+索引中某个页已经被访问至少100次。
    

（2）double write：

    
    
    innodb的page size一般是16K，在极端情况下（例如断电）往往并不能保证这一操作的原子性，例如：16K数据，写入4K时突然发生系统断电/os crash，只有一部分写是成功的，这种情况下就是partial page write（部分页写入）；
    为了解决如上问题，当mysql将脏数据flush到data file的时候，先使用memcopy将脏数据复制到内存中的double write buffer,之后通过double wirte buffer再分2次，每次写入1M到共享表空间，然后马上调用fsync函数，同步到磁盘上，避免缓冲带来的问题，这个过程中double write是顺序写，开销并不大，在完成double write写入后，将double write buffer写入各表空间文件，这时是离散写入。
    
    
    doubule write在刷脏页过程中在哪个步骤？当有数据操作时，有如下简述过程：
    将数据页（page）加载到内存（innodb buffer）——>更新数据产生脏页（dirty page）——?>使用memcopy将脏数据复制到内存中的double write buffer（size=2M）
    ———>double wirte buffer再分2次，每次写入1M到共享表空间（ibdata文件）——>调用fsync函数，同步到磁盘.
    其中：使用memcopy将脏数据复制到内存中的double write buffer（size=2M）———>double wirte buffer再分2次，每次写入1M到共享表空间（ibdata文件）就是double的过程。
    

  

（3）缓冲池：

    
    
    （3.1）buffer pool：通过参数innodb_buffer_pool_size来设置buffer pool，是innodb参数优化最重要的参数，也是使用内存最大的区域。用来存放各种数据的缓存包括：索引页、数据页、undo页、插入缓冲、自适应哈希索引、innodb存储的锁信息、数据字典信息等。将数据库文件按页（page size=16K）读取到缓冲池，然后按LRU算法来保留在缓冲池中的缓存数据，如果数据文件需要修改，总是先修改在缓冲池中的页（修改后的即为dirty page），然后按照一定的频率将缓冲池的脏页刷新到文件（磁盘）。
    （3.2）日志缓存区（redo log buffer）：参数innodb_log_buffer_size来设置innodb的log缓存，将redo log日志信息先放入这个缓冲区，然后按照一定频率刷新到重做日志文件，刷新磁盘的算法由innodb_flush_log_at_trx_commit参数控制。
    （3.3）额外内存池（additional memory pool）：innodb_additional_mem_poop_size是innodb用来保存数据字典信息和其他内部数据结构的内存池的大小，单位是byte,默认值是8M。
    

====================================================================================================

# 补充

## undo redo

#### 1、undo

Undo Log 是为了实现事务的原子性（事物里的操作要么都完成，要么都不完成），在MySQL数据库InnoDB存储引擎中，还用Undo
Log来实现多版本并发控制(简称：MVCC)。

##### （1）undo的原理

为了满足事务的原子性，在操作任何数据之前，首先将数据备份到一个地方（也就是Undo
Log，undo日志存放在共享表空间里），然后进行数据的修改。如果出现了错误或者用户执行了ROLLBACK语句，系统可以利用Undo
Log中的备份将数据恢复到事务开始之前的状态。  
除了可以保证事务的原子性，Undo Log也可以用来辅助完成事务的持久化（事务一旦完成，该事务对数据库所做的所有修改都会持久的保存到数据库中）

##### （2）用Undo Log实现原子性和持久化的事务的简化过程

    
    
      假设有A、B两个数据，值分别为1,2。
      A.事务开始.
      B.记录A=1到undo log.
      C.修改A=3.
      D.记录B=2到undo log.
      E.修改B=4.
      F.将undo log写到磁盘。
      G.将数据写到磁盘。
      H.事务提交
      这里有一个隐含的前提条件：‘数据都是先读到内存中，然后修改内存中的数据，最后将数据写回磁盘’。
    

之所以能同时保证原子性和持久化，是因为以下特点：

    
    
      A. 更新数据前记录Undo log（undo log存放在共享表空间里）。
      B. 为了保证持久性，必须将数据在事务提交前写到磁盘。只要事务成功提交，数据必然已经持久化。
      C. Undo log必须先于数据持久化到磁盘。如果在G,H之间系统崩溃，undo log是完整的，可以用来回滚事务。
      D. 如果在A-F之间系统崩溃,因为数据没有持久化到磁盘。所以磁盘上的数据还是保持在事务开始前的状态。
    缺陷：每个事务提交前将数据和Undo Log写入磁盘，这样会导致大量的磁盘IO，因此性能很低。
    

#### 2、redo

如果能够将数据缓存一段时间，就能减少IO提高性能。但是这样就会丧失事务的持久性。因此引入了另外一种机制来实现持久化，即Redo Log.

###### （1）redo原理

和Undo Log相反，Redo Log记录的是新数据的备份,在事务提交前，只要将Redo
Log持久化即可，不需要将数据持久化。当系统崩溃时，虽然数据没有持久化，但是Redo Log已经持久化。系统可以根据Redo
Log的内容，将所有数据恢复到最新的状态。

###### （2）Undo + Redo事务的简化过程

    
    
      假设有A、B两个数据，值分别为1,2.
      A.事务开始.
      B.记录A=1到undo log.
      C.修改A=3.
      D.记录A=3到redo log.
      E.记录B=2到undo log.
      F.修改B=4.
      G.记录B=4到redo log.
      H.将redo log写入磁盘。
      I.事务提交
    
     Undo + Redo事务的特点：
      A. 为了保证持久性，必须在事务提交前将Redo Log持久化。
      B. 数据不需要在事务提交前写入磁盘，而是缓存在内存中。
      C. Redo Log 保证事务的持久性。
      D. Undo Log 保证事务的原子性。
      E. 有一个隐含的特点，数据必须要晚于redo log写入持久存储。
    

  * Undo + Redo的设计主要考虑的是：提升IO性能。虽说通过缓存数据，减少了写数据的IO，但是却引入了新的IO，即写Redo Log的IO。如果Redo Log的IO性能不好，就不能起 到提高性能的目的。*

为了保证Redo Log能够有比较好的IO性能，InnoDB 的 Redo Log的设计有以下几个特点：

    
    
      A. 尽量保持Redo Log存储在一段连续的空间上。因此在系统第一次启动时就会将日志文件的空间完全分配（也即是ib_logfile*文件，初始化实例时就分配好空间了）。以顺序追加的方式记录Redo Log,通过顺序IO来改善性能。
      B. 批量写入日志。日志并不是直接写入文件，而是先写入redo log buffer.当需要将日志刷新到磁盘时(如事务提交),将许多日志一起写入磁盘.
      C. 并发的事务共享Redo Log的存储空间，它们的Redo Log按语句的执行顺序，依次交替的记录在一起，以减少日志占用的空间。例如,Redo Log中的记录内容可能是这样    的：
         记录1: <trx1, insert …>
         记录2: <trx2, update …>
         记录3: <trx1, delete …>
         记录4: <trx3, update …>
         记录5: <trx2, insert …>
      D. 因为C的原因，当一个事务将Redo Log写入磁盘时，也会将其他未提交的事务的日志写入磁盘。
      E. Redo Log上只进行顺序追加的操作，当一个事务需要回滚时，它的Redo Log记录也不会从Redo Log中删除掉。
    

###### （3）、恢复(Recovery)

（3.1）恢复策略  
未提交的事务和回滚了的事务也会记录Redo Log，因此在进行恢复时,这些事务要进行特殊的处理。有2中不同的恢复策略：  
A. 进行恢复时，只重做已经提交了的事务。  
B. 进行恢复时，重做所有事务包括未提交的事务和回滚了的事务。然后通过Undo Log回滚那些未提交的事务。

（3.2）InnoDB存储引擎的恢复机制  
MySQL数据库InnoDB存储引擎使用了B策略（进行恢复时，重做所有事务包括未提交的事务和回滚了的事务。然后通过Undo Log回滚那些未提交的事务）,
InnoDB存储引擎中的恢复机制有几个特点：  
A. 在重做Redo Log时，并不关心事务性。
恢复时，没有BEGIN，也没有COMMIT,ROLLBACK的行为。也不关心每个日志是哪个事务的。尽管事务ID等事务相关的内容会记入Redo
Log，这些内容只是被当作要操作的数据的一部分。  
B. 使用B策略就必须要将Undo Log持久化，而且必须要在写Redo Log之前将对应的Undo Log写入磁盘。Undo和Redo
Log的这种关联，使得持久化变得复杂起来。为了降低复杂度，InnoDB将Undo Log看作数据，因此记录Undo Log的操作也会记录到redo
log中。这样undo log就可以象数据一样缓存起来，而不用在redo log之前写入磁盘了。  
包含Undo Log操作的Redo Log，看起来是这样的：  
记录1: <trx1, Undo log insert <undo_insert>>  
记录2:  
记录3: <trx2, Undo log insert <undo_update>>  
记录4:  
记录5: <trx3, Undo log insert <undo_delete>>  
记录6:  
C.
到这里，还有一个问题没有弄清楚。既然Redo没有事务性，那岂不是会重新执行被回滚了的事务？确实是这样。同时Innodb也会将事务回滚时的操作也记录到redo
log中。回滚操作本质上也是对数据进行修改，因此回滚时对数据的操作也会记录到Redo Log中。  
一个回滚了的事务的Redo Log，看起来是这样的：  
记录1: <trx1, Undo log insert <undo_insert>>  
记录2:  
记录3: <trx1, Undo log insert <undo_update>>  
记录4:  
记录5: <trx1, Undo log insert <undo_delete>>  
记录6:  
记录7:  
记录8:  
记录9:  
一个被回滚了的事务在恢复时的操作就是先redo再undo，因此不会破坏数据的一致性.

==================================================================================================

  


---
### ATTACHMENTS
[10e3b2b316441456791ad467f0f28729]: media/540235-20160927083856938-1869812172.png
[540235-20160927083856938-1869812172.png](media/540235-20160927083856938-1869812172.png)
>hash: 10e3b2b316441456791ad467f0f28729  
>source-url: https://images2015.cnblogs.com/blog/540235/201609/540235-20160927083856938-1869812172.png  
>file-name: 540235-20160927083856938-1869812172.png  

[127ac1c9929ef63aa1037c1fabd436c6]: media/540235-20160927083901188-466282006.png
[540235-20160927083901188-466282006.png](media/540235-20160927083901188-466282006.png)
>hash: 127ac1c9929ef63aa1037c1fabd436c6  
>source-url: https://images2015.cnblogs.com/blog/540235/201609/540235-20160927083901188-466282006.png  
>file-name: 540235-20160927083901188-466282006.png  

[184c368492c059dcc8d196830515ee5a]: media/540235-20160927083859219-1528570580.png
[540235-20160927083859219-1528570580.png](media/540235-20160927083859219-1528570580.png)
>hash: 184c368492c059dcc8d196830515ee5a  
>source-url: https://images2015.cnblogs.com/blog/540235/201609/540235-20160927083859219-1528570580.png  
>file-name: 540235-20160927083859219-1528570580.png  

[245984bd610abe45f9fa3f2277400706]: media/540235-20160927083902922-1472441740.png
[540235-20160927083902922-1472441740.png](media/540235-20160927083902922-1472441740.png)
>hash: 245984bd610abe45f9fa3f2277400706  
>source-url: https://images2015.cnblogs.com/blog/540235/201609/540235-20160927083902922-1472441740.png  
>file-name: 540235-20160927083902922-1472441740.png  

[2cba9191b3e1105e1b200a082cb81cea]: media/540235-20160927083905547-502417275.png
[540235-20160927083905547-502417275.png](media/540235-20160927083905547-502417275.png)
>hash: 2cba9191b3e1105e1b200a082cb81cea  
>source-url: https://images2015.cnblogs.com/blog/540235/201609/540235-20160927083905547-502417275.png  
>file-name: 540235-20160927083905547-502417275.png  

[3362d25fab05b14c8487e540e082fc06]: media/540235-20160927083855469-1048011438.png
[540235-20160927083855469-1048011438.png](media/540235-20160927083855469-1048011438.png)
>hash: 3362d25fab05b14c8487e540e082fc06  
>source-url: https://images2015.cnblogs.com/blog/540235/201609/540235-20160927083855469-1048011438.png  
>file-name: 540235-20160927083855469-1048011438.png  

[352b5aa391a245e09f482678b4793d2f]: media/540235-20160927083857735-1750450141.png
[540235-20160927083857735-1750450141.png](media/540235-20160927083857735-1750450141.png)
>hash: 352b5aa391a245e09f482678b4793d2f  
>source-url: https://images2015.cnblogs.com/blog/540235/201609/540235-20160927083857735-1750450141.png  
>file-name: 540235-20160927083857735-1750450141.png  

[477dd600445f74132dc6d8fc98de04c8]: media/540235-20160927083911063-34900401.png
[540235-20160927083911063-34900401.png](media/540235-20160927083911063-34900401.png)
>hash: 477dd600445f74132dc6d8fc98de04c8  
>source-url: https://images2015.cnblogs.com/blog/540235/201609/540235-20160927083911063-34900401.png  
>file-name: 540235-20160927083911063-34900401.png  

[5289c50ada3fb03d09b89922f9d3184a]: media/540235-20160927083911500-100406244.png
[540235-20160927083911500-100406244.png](media/540235-20160927083911500-100406244.png)
>hash: 5289c50ada3fb03d09b89922f9d3184a  
>source-url: https://images2015.cnblogs.com/blog/540235/201609/540235-20160927083911500-100406244.png  
>file-name: 540235-20160927083911500-100406244.png  

[591c61917f14041f9bba6af3bd81c7a3]: media/540235-20160927083900188-2078260159.png
[540235-20160927083900188-2078260159.png](media/540235-20160927083900188-2078260159.png)
>hash: 591c61917f14041f9bba6af3bd81c7a3  
>source-url: https://images2015.cnblogs.com/blog/540235/201609/540235-20160927083900188-2078260159.png  
>file-name: 540235-20160927083900188-2078260159.png  

[62b680b88a5bab7e549cbb2d941975da]: media/540235-20160927083856235-391201312.jpg
[540235-20160927083856235-391201312.jpg](media/540235-20160927083856235-391201312.jpg)
>hash: 62b680b88a5bab7e549cbb2d941975da  
>source-url: https://images2015.cnblogs.com/blog/540235/201609/540235-20160927083856235-391201312.jpg  
>file-name: 540235-20160927083856235-391201312.jpg  

[6c8ed6a18239fe0cf6f7f4b202193752]: media/540235-20160927083901844-899613258.png
[540235-20160927083901844-899613258.png](media/540235-20160927083901844-899613258.png)
>hash: 6c8ed6a18239fe0cf6f7f4b202193752  
>source-url: https://images2015.cnblogs.com/blog/540235/201609/540235-20160927083901844-899613258.png  
>file-name: 540235-20160927083901844-899613258.png  

[753817f99a0ea491afe98055febb16d6]: media/540235-20160927083908031-1657982954.png
[540235-20160927083908031-1657982954.png](media/540235-20160927083908031-1657982954.png)
>hash: 753817f99a0ea491afe98055febb16d6  
>source-url: https://images2015.cnblogs.com/blog/540235/201609/540235-20160927083908031-1657982954.png  
>file-name: 540235-20160927083908031-1657982954.png  

[7ed10e001667727aa75b77162360aa92]: media/540235-20160927083900828-1342835775.png
[540235-20160927083900828-1342835775.png](media/540235-20160927083900828-1342835775.png)
>hash: 7ed10e001667727aa75b77162360aa92  
>source-url: https://images2015.cnblogs.com/blog/540235/201609/540235-20160927083900828-1342835775.png  
>file-name: 540235-20160927083900828-1342835775.png  

[85fee641dc91fd508d9519599ddba2fa]: media/540235-20160927083907438-1534325613.png
[540235-20160927083907438-1534325613.png](media/540235-20160927083907438-1534325613.png)
>hash: 85fee641dc91fd508d9519599ddba2fa  
>source-url: https://images2015.cnblogs.com/blog/540235/201609/540235-20160927083907438-1534325613.png  
>file-name: 540235-20160927083907438-1534325613.png  

[8723586e712d51c6405ad15c97093ffb]: media/540235-20160927083858328-1491966219.png
[540235-20160927083858328-1491966219.png](media/540235-20160927083858328-1491966219.png)
>hash: 8723586e712d51c6405ad15c97093ffb  
>source-url: https://images2015.cnblogs.com/blog/540235/201609/540235-20160927083858328-1491966219.png  
>file-name: 540235-20160927083858328-1491966219.png  

[a94b26a47c13a2a6b170296bba38de2b]: media/540235-20160927083911922-1037835190.png
[540235-20160927083911922-1037835190.png](media/540235-20160927083911922-1037835190.png)
>hash: a94b26a47c13a2a6b170296bba38de2b  
>source-url: https://images2015.cnblogs.com/blog/540235/201609/540235-20160927083911922-1037835190.png  
>file-name: 540235-20160927083911922-1037835190.png  

[b03573797959b42ff720647a9e4cc48d]: media/540235-20160927083904344-263863130.png
[540235-20160927083904344-263863130.png](media/540235-20160927083904344-263863130.png)
>hash: b03573797959b42ff720647a9e4cc48d  
>source-url: https://images2015.cnblogs.com/blog/540235/201609/540235-20160927083904344-263863130.png  
>file-name: 540235-20160927083904344-263863130.png  

[bcc62c607095a3696cd3ca9396b8b670]: media/540235-20160927083908453-923000016.png
[540235-20160927083908453-923000016.png](media/540235-20160927083908453-923000016.png)
>hash: bcc62c607095a3696cd3ca9396b8b670  
>source-url: https://images2015.cnblogs.com/blog/540235/201609/540235-20160927083908453-923000016.png  
>file-name: 540235-20160927083908453-923000016.png  

[c0320caa358a350d50a8cfc7b902f41b]: media/540235-20160927083909328-1447369057.jpg
[540235-20160927083909328-1447369057.jpg](media/540235-20160927083909328-1447369057.jpg)
>hash: c0320caa358a350d50a8cfc7b902f41b  
>source-url: https://images2015.cnblogs.com/blog/540235/201609/540235-20160927083909328-1447369057.jpg  
>file-name: 540235-20160927083909328-1447369057.jpg  

[c6bbb3253547ed3acef7061c17681092]: media/540235-20160927083854563-2139392246.jpg
[540235-20160927083854563-2139392246.jpg](media/540235-20160927083854563-2139392246.jpg)
>hash: c6bbb3253547ed3acef7061c17681092  
>source-url: https://images2015.cnblogs.com/blog/540235/201609/540235-20160927083854563-2139392246.jpg  
>file-name: 540235-20160927083854563-2139392246.jpg  

[d946910c4a6b04bf08cd46598a4cf607]: media/540235-20160927083910031-1235419263.png
[540235-20160927083910031-1235419263.png](media/540235-20160927083910031-1235419263.png)
>hash: d946910c4a6b04bf08cd46598a4cf607  
>source-url: https://images2015.cnblogs.com/blog/540235/201609/540235-20160927083910031-1235419263.png  
>file-name: 540235-20160927083910031-1235419263.png  

[dc6e18d3ae9e6811bb694914f78455e5]: media/540235-20160927083906578-1147977557.png
[540235-20160927083906578-1147977557.png](media/540235-20160927083906578-1147977557.png)
>hash: dc6e18d3ae9e6811bb694914f78455e5  
>source-url: https://images2015.cnblogs.com/blog/540235/201609/540235-20160927083906578-1147977557.png  
>file-name: 540235-20160927083906578-1147977557.png  

[e0145b5b12ca619b9e93c4b06d5057a1]: media/540235-20160927083903594-1797573190.png
[540235-20160927083903594-1797573190.png](media/540235-20160927083903594-1797573190.png)
>hash: e0145b5b12ca619b9e93c4b06d5057a1  
>source-url: https://images2015.cnblogs.com/blog/540235/201609/540235-20160927083903594-1797573190.png  
>file-name: 540235-20160927083903594-1797573190.png  

[e49f625d07fda69ae2ca0332ac2a30c6]: media/540235-20160927083912360-1456175645.png
[540235-20160927083912360-1456175645.png](media/540235-20160927083912360-1456175645.png)
>hash: e49f625d07fda69ae2ca0332ac2a30c6  
>source-url: https://images2015.cnblogs.com/blog/540235/201609/540235-20160927083912360-1456175645.png  
>file-name: 540235-20160927083912360-1456175645.png  

[edde99d44d59447715135684f319f160]: media/540235-20160927083912985-1396864043.jpg
[540235-20160927083912985-1396864043.jpg](media/540235-20160927083912985-1396864043.jpg)
>hash: edde99d44d59447715135684f319f160  
>source-url: https://images2015.cnblogs.com/blog/540235/201609/540235-20160927083912985-1396864043.jpg  
>file-name: 540235-20160927083912985-1396864043.jpg  

[f07b5f541e4e80d1474c4dbf9c21fef3]: media/540235-20160927083912641-1885365115.jpg
[540235-20160927083912641-1885365115.jpg](media/540235-20160927083912641-1885365115.jpg)
>hash: f07b5f541e4e80d1474c4dbf9c21fef3  
>source-url: https://images2015.cnblogs.com/blog/540235/201609/540235-20160927083912641-1885365115.jpg  
>file-name: 540235-20160927083912641-1885365115.jpg  

[f518e940775daf679278eb333afdf0bf]: media/540235-20160927083857313-118642227.png
[540235-20160927083857313-118642227.png](media/540235-20160927083857313-118642227.png)
>hash: f518e940775daf679278eb333afdf0bf  
>source-url: https://images2015.cnblogs.com/blog/540235/201609/540235-20160927083857313-118642227.png  
>file-name: 540235-20160927083857313-118642227.png  


---
### TAGS
{体系结构}

---
### NOTE ATTRIBUTES
>Created Date: 2018-03-26 08:50:31  
>Last Evernote Update Date: 2018-10-01 15:35:37  
>author: YangKwong  
>source: web.clip  
>source-url: https://www.cnblogs.com/zhoubaojian/articles/7866292.html  