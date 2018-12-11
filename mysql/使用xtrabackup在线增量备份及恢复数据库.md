## 使用xtrabackup在线增量备份及恢复数据库

### **一、**Percona **Xtrabackup 简介**

1、Xtrabackup  bin目录文件 **介绍**

#### 1）innobackupex

innobackupex 是xtrabackup的一个符号链接 . innobackupex still supports all features and syntax as 2.2 version did, but is now deprecated and will be removed in next major release.

#### 2）xtrabackup

一个由C编译而来的二进制文件，可以整备MySQL database instance with MyISAM, InnoDB, and XtraDB tables

#### 3）xbcrypt

用来加密或解密备份的数据

#### 4）xbstream

用来解压或压缩xbstream格式的压缩文件

#### 5）xbcloud

utility used for downloading and uploading full or part of xbstream archive from/to cloud.

### 2、Percona XtraBackup info

是开源免费的MySQL数据库热备份软件，它能对InnoDB和XtraDB存储引擎的数据库非阻塞地备份（对于MyISAM的备份同样需要加表锁）

you can achieve the following benefits: （https://www.percona.com/doc/percona-xtrabackup/2.3/intro.html）

- Backups that complete quickly and reliably
- Uninterrupted transaction processing during backups
- Savings on disk space and network bandwidth
- Automatic backup verification
- Higher uptime due to faster restore time

#### features  

无需停止数据库进行InnoDB热备
- 无需停止数据库进行InnoDB热备
- 增量备份MySQL
- 流压缩到传输到其它服务器
- 在线移动表
- 能比较容易地创建主从同步
- 备份MySQL时不会增大服务器负载

#### 3、Xtrabackup工具支持对InnoDB存储引擎的增量备份，工作原理如下

1、在InnoDB内部会维护一个redo/undo日志文件，也可以叫做事务日志文件。事务日志会存储每一个InnoDB表数据的记录修改。当InnoDB启动时，InnoDB会检查数据文件和事务日志，并执行两个步骤：它应用（前滚）已经提交的事务日志到数据文件，并将修改过但没有提交的数据进行回滚操作。

2、Xtrabackup在启动时会记住log sequence number（LSN），并且复制所有的数据文件。复制过程需要一些时间，所以这期间如果数据文件有改动，那么将会使数据库处于一个不同的时间点。这时，xtrabackup会运行一个后台进程，用于监视事务日志，并从事务日志复制最新的修改。Xtrabackup必须持续的做这个操作，是因为事务日志是会轮转重复的写入，并且事务日志可以被重用。所以xtrabackup自启动开始，就不停的将事务日志中每个数据文件的修改都记录下来。

3、上面就是xtrabackup的备份过程。接下来是准备（prepare）过程，在这个过程中，xtrabackup使用之前复制的事务日志，对各个数据文件执行灾难恢复（就像mysql刚启动时要做的一样）。当这个过程结束后，数据库就可以做恢复还原了，这个过程在xtrabackup的编译二进制程序中实现。程序innobackupex可以允许我们备份MyISAM表和frm文件从而增加了便捷和功能。Innobackupex会启动xtrabackup，直到xtrabackup复制数据文件后，然后执行FLUSH TABLES WITH READ LOCK来阻止新的写入进来并把MyISAM表数据刷到硬盘上，之后复制MyISAM数据文件，最后释放锁。

4、备份MyISAM和InnoDB表最终会处于一致，在准备（prepare）过程结束后，InnoDB表数据已经前滚到整个备份结束的点，而不是回滚到xtrabackup刚开始时的点。这个时间点与执行FLUSH TABLES WITH READ LOCK的时间点相同，所以myisam表数据与InnoDB表数据是同步的。类似oracle的，InnoDB的prepare过程可以称为recover（恢复），myisam的数据复制过程可以称为restore（还原）。

5、Xtrabackup 和 innobackupex这两个工具都提供了许多前文没有提到的功能特点。手册上有对各个功能都有详细的介绍。简单介绍下，这些工具提供了如流（streaming）备份，增量（incremental）备份等，通过复制数据文件，复制日志文件和提交日志到数据文件（前滚）实现了各种复合备份方式。

### **二、安装xtrabackup**

**1、安装**

```
$ yum -y install perl perl-devel libaio libaio-devel
$ yum -y install  perl-DBI  perl-DBD-MySQL  perl-TermReadKey perl-devel perl-Time-HiRes
$ cd /usr/local/src
$ wget -c https://www.percona.com/downloads/XtraBackup/Percona-XtraBackup-2.3.2/binary/tarball/percona-xtrabackup-2.3.2-Linux-x86_64.tar.gz
$ tar -zxf percona-xtrabackup-2.3.2-Linux-x86_64.tar.gz
$ cd percona-xtrabackup-2.3.2-Linux-x86_64/
$ mkdir  /usr/local/xtrabackup
$ mv bin  /usr/local/xtrabackup/
$ ln -s /usr/local/xtrabackup/bin/* /usr/bin/
```

**2、修改my.cnf**

```
[mysqld] 
datadir=/var/lib/mysql
 
innodb_data_home_dir = /data/mysql/ibdata
innodb_log_group_home_dir = /data/mysql/iblogs
innodb_data_file_path=ibdata1:10M;ibdata2:10M:autoextend
innodb_log_files_in_group = 2
innodb_log_file_size = 1G
```

### **三、全部数据库备份与还原**

#### **1、备份**

```
//全部数据库备份
innobackupex  --user=root --password=oracle --host=192.168.45.12 /backup
innobackupex  --user=backuser --password=kkk123456  /u02/mysql_backup/full/
innobackupex  --user=root --password=123456  /u02/mysql_backup/full/
innobackupex --defaults-file=/usr/my.cnf --user=backuser --password=kkk123456  /u02/mysql_backup/full
innobackupex --defaults-file=/usr/my.cnf --socket=/var/lib/mysql/mysql.sock --user=backuser --password=kkk123456  /u02/mysql_backup/full

//指定--defaults-file
xtrabackup --defaults-file=/etc/mysql/my.cnf --user=root --password=123  --backup --target-dir=/home/zhoujy/xtrabackup/

//用--datadir取代--defaults-file
xtrabackup --user=root --password=123  --backup --datadir=/var/lib/mysql/ --target-dir=/home/zhoujy/xtrabackup/

//参数--no-timestamp 表示不生成带时间戳的目录
innobackupex  --user=backuser --password=kkk123456  /u02/mysql_backup/full/ --no-timestamp

//单数据库备份
innobackupex  --user=root --password=oracle --host=192.168.45.12 --databases=sampdb /backup/sampdb
 
//多库
innobackupex  --user=root --password=oracle --host=192.168.45.12 --include=sampdb.*,employees.* /backup/sampdb_employees 
innobackupex  --user=root --password=oracle --host=192.168.45.12 --databases="sampdb employees" /backup/sampdb_employees
innobackupex  --user=root --password=oracle --host=192.168.45.12 --include='sampdb.*|employees.*' /backup/sampdb_employees
//多表
innobackupex  --user=root --password=oracle --host=192.168.45.12 --include='sampdb.absence|employees.departments' /backup/sampdb_employees
 
//数据库备份并压缩
log=sampdb_`date +%F_%H-%M-%S`.log
db=sampdb_`date +%F_%H-%M-%S`.tar.gz
innobackupex --user=root --stream=tar --databases='sampdb' --host=192.168.45.12  /backup  2>/backup/$log | gzip 1> /backup/$db

//不过注意解压需要手动进行，并加入 -i 的参数，否则无法解压出所有文件,疑惑了好长时间
//如果有错误可以加上  --defaults-file=/etc/my.cnf
```

#### 2、还原

```
service mysqld stop
mv /data/mysql /data/mysql_bak && mkdir -p /data/mysql
//先prepare，利用--apply-log的作用是通过回滚未提交的事务及同步已经提交的事务至数据文件使数据文件处于一致性状态
innobackupex --defaults-file=/etc/my.cnf --user=root --apply-log /backup/
//copy：需要数据目录为空
innobackupex --defaults-file=/etc/my.cnf --user=root --copy-back /backup/
//改权限
chown -R mysql.mysql /data/ /redolog/ /undolog 
service mysqld start


1：(关闭mysql)先prepare
xtrabackup --prepare --target-dir=/home/zhoujy/xtrabackup/

2：再copy
rsync -avrP /home/zhoujy/xtrabackup/* /var/lib/mysql/

3：改权限、启动
chown -R mysql.mysql *
```

### 四、增量备份与还原

#### 1、创建测试数据库和表

```
//创建库
create database backup_test;
//创建表
 CREATE TABLE backup (
    id INT(11) NOT NULL AUTO_INCREMENT,
    name VARCHAR(20) NOT NULL DEFAULT '',
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    del TINYINT(1) NOT NULL DEFAULT 0,
    PRIMARY KEY (id)
)  ENGINE=MYISAM DEFAULT CHARSET=UTF8 AUTO_INCREMENT=1
```

#### 2、增量备份

```
#--incremental：增量备份的文件夹
#--incremental-dir：针对哪个做增量备份
//插入数据
mysql>INSERT INTO backup (name) VALUES ('xx'),('xxxx'); 
//第一次备份
innobackupex  --user=root --host=192.168.45.12 --incremental-basedir=/backup/full/2018-09-11_10-04-38/  --incremental /backup/incr1 
//在插入数据
mysql> INSERT INTO backup (name) VALUES ('test'),('testd'); 
//再次备份
innobackupex  --user=root --host=192.168.45.12 --incremental-basedir=/backup/incr1/2018-09-11_11-19-13/ --incremental /backup/incr2
```

#### 3、查看增量备份记录文件

```
//全备目录下的文件
#cat xtrabackup_checkpoints 
backup_type = full-prepared
from_lsn = 0 //全备起始为0
to_lsn = 23853959
last_lsn = 23853959
compact = 0
//第一次增量备份目录下的文件
#cat xtrabackup_checkpoints
backup_type = incremental
from_lsn = 23853959
to_lsn = 23854112
last_lsn = 23854112
compact = 0
//第二次增量备份目录下的文件
#cat xtrabackup_checkpoints
backup_type = incremental
from_lsn = 23854112
to_lsn = 23854712
last_lsn = 23854712
compact = 0
```

增量备份做完后，把backup_test这个数据库删除掉，drop database backup_test;这样可以对比还原后

#### 4、增量还原

分为两个步骤

a.prepare

```
innobackupex --apply-log /path/to/BACKUP-DIR
```

此时数据可以被程序访问使用；可使用—use-memory选项指定所用内存以加快进度，默认100M；

b.recover

```
innobackupex --copy-back /path/to/BACKUP-DIR
```

从my.cnf读取datadir/innodb_data_home_dir/innodb_data_file_path等变量

先复制MyISAM表，然后是innodb表，最后为logfile；--data-dir目录必须为空

#### 恢复数据

```
1.先prepare全备
innobackupex --incremental --apply-log --redo-only /home/zhoujy/xtrabackup
2.再prepare第一个增量
innobackupex --incremental --apply-log --redo-only /home/zhoujy/xtrabackup/ --user-memory=1G  --incremental-dir=/home/zhoujy/increment_data/
3.然后prepare最后一个增量
innobackupex --incremental --apply-log --redo-only /home/zhoujy/xtrabackup/ --user-memory=1G  --incremental-dir=/home/zhoujy/increment_data1/

通过上面额可以看到全量备份里xtrabackup_checkpoints文件的to_lsn是最新的lsn。
#/etc/init.d/mysql.server stop
4.最后再prepare全量备份
innobackupex --apply-log /home/zhoujy/xtrabackup/

5.copy
因为是部分备份，不是所有库备份，所以和上面介绍的一样，先手动复制需要的文件再修改权限即可恢复数据。
#/etc/init.d/mysql.server start
```
打包压缩备份，**注意**：--compress不能和--stream=tar一起使用

#### 压缩备份
```
innobackupex --defaults-file=/etc/mysql/my.cnf --user=root --password=123 --compress --compress-threads=8 --no-timestamp --databases="xtra_test.I" /home/zhoujy/xtrabackup/
#在perpare之前需要decompress，需要安装qpress
innobackupex --decompress /home/zhoujy/xtrabackup/
#prepare
innobackupex --apply-log /home/zhoujy/xtrabackup/
最后还原方法和上面一致

#打包备份
innobackupex --defaults-file=/etc/mysql/my.cnf --user=root --password=123 --stream=tar --no-timestamp --databases="xtra_test" /home/zhoujy/xtrabackup/ 1>/home/zhoujy/xtrabackup/xtra_test.tar

#解包
tar ixvf xtra_test.tar
最后还原方法和上面一致

#第三方压缩备份：
innobackupex --defaults-file=/etc/mysql/my.cnf --user=root --password=123 --compress --compress-threads=8 --parallel=4 --stream=tar --no-timestamp --databases="xtra_test" /home/zhoujy/xtrabackup/ | gzip >/home/zhoujy/xtrabackup/xtra_test.tar.gz

#prepare之前先解压
tar izxvf xtra_test.tar.gz 

#prepare
innobackupex --apply-log /home/zhoujy/xtrabackup/
```

#### [加密备份](https://www.percona.com/doc/percona-xtrabackup/2.4/innobackupex/encrypted_backups_innobackupex.html)

```
说明：在参数说明里看到加密备份的几个参数：--encrypt、--encrypt-threads、--encrypt-key、--encryption-key-file。其中encrypt-key和encryption-key-file不能一起使用，encryption-key需要把加密的密码写到命令行，不推荐。

#加密备份：
先生成key:
openssl rand -base64 24
把Key写到文件：
echo -n "Ue2Wp6dIDWszpI76HQ1u57exyjAdHpRO" > keyfile 
最后备份：
innobackupex --defaults-file=/etc/mysql/my.cnf --user=root --password=123 --compress --compress-threads=3 --no-timestamp --encrypt=AES256 --encrypt-key-file=/home/zhoujy/keyfile ----encrypt-threads=3 --parallel=5 /home/zhoujy/xtrabackup2/

#解密：
for i in `find . -iname "*\.xbcrypt"`; do xbcrypt -d --encrypt-key-file=/home/zhoujy/keyfile --encrypt-algo=AES256 < $i > $(dirname $i)/$(basename $i .xbcrypt) && rm $i; done

#解压：
innobackupex --decompress /home/zhoujy/xtrabackup2/

#prepare：
innobackupex --apply-log /home/zhoujy/xtrabackup2/

#还原copy
innobackupex --defaults-file=/etc/mysql/my.cnf --move-back /home/zhoujy/xtrabackup2/
```

⑤.复制环境中的备份：一般生产环境大部分都是主从模式，主提供服务，从提供备份。

```
#备份 5个线程备份2个数据库，并且文件xtrabackup_slave_info记录GTID和change的信息
innobackupex --defaults-file=/etc/mysql/my.cnf --user=root --password=123 --no-timestamp --slave-info --safe-slave-backup --parallel=5 --databases='xtra_test dba_test' /home/zhoujy/xtrabackup/

#还原
还原方法同上
```

#### 总结：关于更多的innobackupex的备份可以看
[官方文档](https://www.percona.com/doc/percona-xtrabackup/2.4/innobackupex/innobackupex_script.html)和[xtrabackup 安装使用](http://www.cnblogs.com/zhoujinyi/p/4088866.html)，参数可以参考本文上面的介绍说明，通过上面的几个说明看到innobackupex可以实现：全量、增量、压缩、打包、加密备份，并且支持多线程的备份，并且也提供了长查询超过阀值自动kill的方法，大大提升备份效率。

### 五、innobackup 常用参数说明

```
--apply-log-only：prepare备份的时候只执行redo阶段，用于增量备份。
--backup：创建备份并且放入--target-dir目录中
--close-files：不保持文件打开状态，xtrabackup打开表空间的时候通常不会关闭文件句柄，目的是为了正确处理DDL操作。如果表空间数量非常巨大并且不适合任何限制，一旦文件不在被访问的时候这个选项可以关闭文件句柄.打开这个选项会产生不一致的备份。
--compact：创建一份没有辅助索引的紧凑备份
--compress：压缩所有输出数据，包括事务日志文件和元数据文件，通过指定的压缩算法，目前唯一支持的算法是quicklz.结果文件是qpress归档格式，每个xtrabackup创建的*.qp文件都可以通过qpress程序提取或者解压缩
--compress-chunk-size=#：压缩线程工作buffer的字节大小，默认是64K
--compress-threads=#：xtrabackup进行并行数据压缩时的worker线程的数量，该选项默认值是1，并行压缩（'compress-threads'）可以和并行文件拷贝('parallel')一起使用。例如:'--parallel=4 --compress --compress-threads=2'会创建4个IO线程读取数据并通过管道传送给2个压缩线程。
--create-ib-logfile：这个选项目前还没有实现，目前创建Innodb事务日志，你还是需要prepare两次。
--datadir=DIRECTORY：backup的源目录，mysql实例的数据目录。从my.cnf中读取，或者命令行指定。
--defaults-extra-file=[MY.CNF]：在global files文件之后读取，必须在命令行的第一选项位置指定。
--defaults-file=[MY.CNF]：唯一从给定文件读取默认选项，必须是个真实文件，必须在命令行第一个选项位置指定。
--defaults-group=GROUP-NAME：从配置文件读取的组，innobakcupex多个实例部署时使用。
--export：为导出的表创建必要的文件
--extra-lsndir=DIRECTORY：(for --bakcup):在指定目录创建一份xtrabakcup_checkpoints文件的额外的备份。
--incremental-basedir=DIRECTORY：创建一份增量备份时，这个目录是增量别分的一份包含了full bakcup的Base数据集。
--incremental-dir=DIRECTORY：prepare增量备份的时候，增量备份在DIRECTORY结合full backup创建出一份新的full backup。
--incremental-force-scan：创建一份增量备份时，强制扫描所有增在备份中的数据页即使完全改变的page bitmap数据可用。
--incremetal-lsn=LSN：创建增量备份的时候指定lsn。
--innodb-log-arch-dir：指定包含归档日志的目录。只能和xtrabackup --prepare选项一起使用。
--innodb-miscellaneous：从My.cnf文件读取的一组Innodb选项。以便xtrabackup以同样的配置启动内置的Innodb。通常不需要显示指定。
--log-copy-interval=#：这个选项指定了log拷贝线程check的时间间隔（默认1秒）。
--log-stream：xtrabakcup不拷贝数据文件，将事务日志内容重定向到标准输出直到--suspend-at-end文件被删除。这个选项自动开启--suspend-at-end。
--no-defaults：不从任何选项文件中读取任何默认选项,必须在命令行第一个选项。
--databases=#：指定了需要备份的数据库和表。
--database-file=#：指定包含数据库和表的文件格式为databasename1.tablename1为一个元素，一个元素一行。
--parallel=#：指定备份时拷贝多个数据文件并发的进程数，默认值为1。
--prepare：xtrabackup在一份通过--backup生成的备份执行还原操作，以便准备使用。
--print-default：打印程序参数列表并退出，必须放在命令行首位。
--print-param：使xtrabackup打印参数用来将数据文件拷贝到datadir并还原它们。
--rebuild_indexes：在apply事务日志之后重建innodb辅助索引，只有和--prepare一起才生效。
--rebuild_threads=#：在紧凑备份重建辅助索引的线程数，只有和--prepare和rebuild-index一起才生效。
--stats：xtrabakcup扫描指定数据文件并打印出索引统计。
--stream=name：将所有备份文件以指定格式流向标准输出，目前支持的格式有xbstream和tar。
--suspend-at-end：使xtrabackup在--target-dir目录中生成xtrabakcup_suspended文件。在拷贝数据文件之后xtrabackup不是退出而是继续拷贝日志文件并且等待知道xtrabakcup_suspended文件被删除。这项可以使xtrabackup和其他程序协同工作。
--tables=name：正则表达式匹配database.tablename。备份匹配的表。
--tables-file=name：指定文件，一个表名一行。
--target-dir=DIRECTORY：指定backup的目的地，如果目录不存在，xtrabakcup会创建。如果目录存在且为空则成功。不会覆盖已存在的文件。
--throttle=#：指定每秒操作读写对的数量。
--tmpdir=name：当使用--print-param指定的时候打印出正确的tmpdir参数。
--to-archived-lsn=LSN：指定prepare备份时apply事务日志的LSN，只能和xtarbackup --prepare选项一起用。
--user-memory = #：通过--prepare prepare备份时候分配多大内存，目的像innodb_buffer_pool_size。默认值100M如果你有足够大的内存。1-2G是推荐值，支持各种单位(1MB,1M,1GB,1G)。
--version：打印xtrabackup版本并退出。
--xbstream：支持同时压缩和流式化。需要客服传统归档tar,cpio和其他不允许动态streaming生成的文件的限制，例如动态压缩文件，xbstream超越其他传统流式/归档格式的的优点是，并发stream多个文件并且更紧凑的数据存储（所以可以和--parallel选项选项一起使用xbstream格式进行streaming）。
```