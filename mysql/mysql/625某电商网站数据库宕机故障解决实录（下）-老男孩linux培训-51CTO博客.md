# 625某电商网站数据库宕机故障解决实录（下）-老男孩linux培训-51CTO博客

  

[老男孩linux培训](http://blog.51cto.com/oldboy) _>_ 正文

# 625某电商网站数据库宕机故障解决实录（下）

原创 [老男孩oldboy](http://blog.51cto.com/oldboy) 2014-06-26 14:29:37
[评论(43)](http://blog.51cto.com/oldboy/1431172#comment) 14136人阅读

### 1.4开始进行故障恢复*****

1、重新初始化建库

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

`[root@etiantian data]``# mkdir mysql`

`[root@etiantian data]``# chown -R mysql.mysql mysql`

`[root@etiantian data]``# /install/mysql/scripts/mysql_install_db--
basedir=/install/mysql/ --datadir=/data/mysql/ --user=mysql`

`Installing MySQL system tables...`

`OK`

`Filling help tables...`

`OK`

`To start mysqld at boot ``time` `you have to copy`

`support-files``/mysql``.server to the right place ``for` `your system`

` `

`PLEASE REMEMBER TO SET A PASSWORD FOR THE MySQL root USER !`

`To ``do` `so, start the server, ``then` `issue the following commands:`

` `

`/install/mysql//bin/mysqladmin` `-u root password ``'new-password'`

`/install/mysql//bin/mysqladmin` `-u root -h etiantian.cn password``'new-
password'`

`Alternatively you can run:`

`/install/mysql//bin/mysql_secure_installation`

` `

`which` `will also give you the option of removing the ``test`

`databases and anonymous user created by default. This is`

`strongly recommended ``for` `production servers.`

` `

`See the manual ``for` `more` `instructions.`

` `

`You can start the MySQL daemon with:`

`cd` `/install/mysql/` `; ``/install/mysql//bin/mysqld_safe` `& `

`You can ``test` `the MySQL daemon with mysql-``test``-run.pl`

`cd` `/install/mysql//mysql-test` `; perl mysql-``test``-run.pl`

` `

`Please report any problems with the
``/install/mysql//scripts/mysqlbugscript``!`  
  
---|---  
  
2、启动数据库测试登录

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

|

`[root@etiantian data]``# /etc/init.d/mysqld start`

`Starting MySQL.......................... SUCCESS! `

`[root@etiantian data]``# mysql`

`mysql:Collation``'utf8-general_ci'` `is not a compiled collation and is not
specifiedin the ``'/install/mysql/share/charsets/Index.xml'` `file`

`Welcome to the MySQL monitor. Commands end with ; or \g.`

`Your MySQL connection ``id` `is 1`

`Server version: 5.5.33-log Source distribution `

`Copyright (c) 2000, 2013, Oracle and``/or` `its affiliates. All
rightsreserved.`

` `

`Oracle is a registered trademark of Oracle Corporation and``/or` `its`

`affiliates. Other names may be trademarks of their respective`

`owners.`

` `

`Type ``'help;'` `or ``'\h'` `for` `help. Type ``'\c'` `to ``clear` `the
current inputstatement.`

` `

`mysql> quit`

` ``-> Ctrl-C -- ``exit``!`

`Aborted`  
  
---|---  
  
提示：可以登录但是报了一个错误。 **Collation'utf8-general_ci' is not a compiled collation**

 **字符集校对规则没有编译进去。奇怪了。由于着急这块当时没有询问客户，浪费了一点时间。只询问了客户数据库备份的命令，因为涉及到建库问题：**

 ****

老男孩 19:07:07

你当时的备份命令

XX 19:07:10

好

XX 19:07:12

稍等

XX 19:07:40

mysqldump -u root -ptest110oldboyeshop_ett100 >eshop_ett100.0624.sql

XX 19:08:49

是的

老男孩 19:09:29

以后加 -B

老男孩 19:09:43

mysql库的用户你知道吧。

XX 19:09:46

哦，就是这个选项是吗

XX 19:09:48

知道

老男孩 19:09:51

就是web用户连接的用户及密码

XX 19:10:00

etiantian,test110oldboy

老男孩 19:18:18

由于你备份没有加-B，所以需要建库，整个命令及字符集呢

XX 19:18:28

utf-8

XX 19:18:34

没任何别的东西

XX 19:19:18

create database eshop_ett100 utf8

老男孩 19:19:44

你这是完整命令么

XX 19:20:18

不是，那个utf-8是这个db的默认字符集，没其他任何选项

XX 19:20:22

完整的等下我找找

老男孩 19:21:35

我写好了，create database eshop_ett100 CHARACTER SET utf8 COLLATE utf8_general_ci;

XX 19:21:43

create database test2 DEFAULT CHARACTER SET utf8

 **询问完毕**

 ****

下面是老男孩操作的过程，查看建库字符集

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

` ``[root@etiantian data]``# cat /root/.mysql_history |grep create`

`create\040database\040eshop_ett100\040DEFAULT\040CHARACTER\040SET\040utf8\040COLLATE\040utf8_general_ci;确定建库的命令。`

`[root@etiantian data]``# mysql`

`mysql: Collation ``'utf8-general_ci'` `is not a compiled collation andis not
specified ``in` `the ``'/install/mysql/share/charsets/Index.xml'` `file`

`Welcome to the MySQL monitor. Commands end with ; or \g.`

`Your MySQL connection ``id` `is 2`

`Server version: 5.5.33-log Source distribution `

`Copyright (c) 2000, 2013, Oracle and``/or` `its affiliates. All
rightsreserved.`

` `

`Oracle is a registered trademark of Oracle Corporation and``/or` `its`

`affiliates. Other names may be trademarks of their respective`

`owners. `

`Type ``'help;'` `or ``'\h'` `for` `help. Type ``'\c'` `to ``clear` `the
current inputstatement.`

` `

`mysql> create database eshop_ett100 CHARACTER SET utf8 COLLATE
utf8_general_ci;`

`Query OK, 1 row affected (0.00 sec)`

` `

`mysql> quit`

`Bye`  
  
---|---  
  
3、开始正式尝试恢复故障数据库。

1

2

3

|

`[root@etiantian data]``# mysql eshop_ett100 </home/xxx/eshop_ett100.0624.sql`

`mysql: Collation ``'utf8-general_ci'` `is not acompiled collation and is not
specified ``in` `the``'/install/mysql/share/charsets/Index.xml'` `file`

`ERROR 1030 (HY000) at line 46: Got error -1from storage engine`  
  
---|---  
  
 **我晕，报错！看来这个字符集校对规则必须重编了。于是询问客户：**

老男孩 19:22:16

mysql: Collation 'utf8-general_ci' is not a compiled collation andis not
specified in the '/install/mysql/share/charsets/Index.xml' file

XX 19:22:19

utf8_general_ci这个东西我编译myhsql的时候写错了，写成utf8-general_ci

XX 19:23:15

下划线写成中线了

XX 19:23:23

我重编安装下，你觉得好不好

老男孩 19:24:28

确实提示不支持

XX 19:24:43

应该是下划线

老男孩 19:24:55

你重编吧

XX 19:24:56

utf8_general_ci

老男孩 19:25:01

我等你

老男孩 19:25:18

也可以免编译

老男孩 19:25:52

mysql-5.5.32-linux2.6-x86_64.tar.gz 没下载地址上传太慢

老男孩 19:26:00

你还是重新编译吧

XX 19:26:07

马上重编好了

老男孩 19:26:09

删掉安装目录我都备好了

XX 19:26:26

好，/data需要不需要删除

老男孩 19:29:22

都删掉

老男孩 19:29:28

安装目录都删掉

老男孩 19:29:32

配置文件不要动

XX 19:29:45

装好了

老男孩 19:29:47

到了make install即可

XX 19:29:51

配置文件没动，我cp了一下

XX 19:29:55

好了

老男孩 19:30:28

OK

4、数据库重新编译后，老男孩开始进行二次故障恢复。

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

|

`[root@etiantian data]``# pwd`

`/data`

`[root@etiantian data]``# rm -fr mysql`

`[root@etiantian data]``# mkdir mysql`

`[root@etiantian data]``# chown -R mysql.mysql <==这是着急的杰作，连目标都没加，偶也紧张啊。`

`chown``: missing operand after `mysql.mysql'`

`Try ```chown` `--help' ``for` `more` `information.`

`[root@etiantian data]``# chown -R mysql.mysql mysql`

`[root@etiantian data]``# /install/mysql/scripts/mysql_install_db--
basedir=/install/mysql/ --datadir=/data/mysql/ --user=mysql`

`Installing MySQL system tables...`

`OK`

`Filling help tables...`

`OK`

`To start mysqld at boot ``time` `you have to copy`

`support-files``/mysql``.server to the right place ``for` `your system`

` `

`PLEASE REMEMBER TO SET A PASSWORD FOR THE MySQL root USER !`

`To ``do` `so, start the server, ``then` `issue the following commands:`

` `

`/install/mysql//bin/mysqladmin` `-u root password ``'new-password'`

`/install/mysql//bin/mysqladmin` `-u root -h etiantian.cn password``'new-
password'`

` `

`Alternatively you can run:`

`/install/mysql//bin/mysql_secure_installation`

` `

`which` `will also give you the option of removing the ``test`

`databases and anonymous user created by default. This is`

`strongly recommended ``for` `production servers.`

` `

`See the manual ``for` `more` `instructions.`

` `

`You can start the MySQL daemon with:`

`cd` `/install/mysql/` `; ``/install/mysql//bin/mysqld_safe` `&`

` `

`You can ``test` `the MySQL daemon with mysql-``test``-run.pl`

`cd` `/install/mysql//mysql-test` `; perl mysql-``test``-run.pl`

` `

`Please report any problems with the
``/install/mysql//scripts/mysqlbugscript``!`  
  
---|---  
  
重新初始化完毕

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

|

`[root@etiantian data]``# /etc/init.d/mysqld start`

`Starting MySQL......................... SUCCESS! `

`[root@etiantian data]``# mysql`

`Welcome to the MySQL monitor. Commands end with ; or \g.`

`Your MySQL connection ``id` `is 1`

`Server version: 5.5.33-log Source distribution`

` `

`Copyright (c) 2000, 2013, Oracle and``/or` `its affiliates. All
rightsreserved.`

` `

`Oracle is a registered trademark of Oracle Corporation and``/or` `its`

`affiliates. Other names may be trademarks of their respective`

`owners.`

` `

`Type ``'help;'` `or ``'\h'` `for` `help. Type ``'\c'` `to ``clear` `the
current inputstatement.`  
  
---|---  
  
启动成功，并且数据库的登录也完全正常了。

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

|

`mysql> show databases;`

`+--------------------+`

`| Database |`

`+--------------------+`

`| information_schema |`

`| mysql |`

`| performance_schema |`

`| ``test` `|`

`+--------------------+`

`4 rows ``in` `set` `(0.00 sec)`  
  
---|---  
  
建库

1

2

3

4

5

|

`mysql> create database eshop_ett100 CHARACTER SET utf8 COLLATE
utf8_general_ci;`

`Query OK, 1 row affected (0.00 sec)`

` `

`mysql> quit`

`Bye`  
  
---|---  
  
命令行数据全备恢复：

1

2

|

`[root@etiantian data]``# mysql eshop_ett100</home/xxx/eshop_ett100.0624.sql`

`ERROR 1030 (HY000) at line 46: Got error -1 from storage engine`  
  
---|---  
  
晕，报错。到这里，说实话，当时心里突然一凉，本来很自信的答应客户，100%可以恢复。现在全备有问题。。。。。。完蛋了。这是当时真心的想法。伙伴们勿笑。

停顿了一下，马上冷静，下意识的看看数据库备份内容没发现异常。

1

2

3

|

`[root@etiantian data]``# less /home/xxx/eshop_ett100.0624.sql`

`-- MySQL dump 10.13 Distrib5.5.33, ``for` `Linux (x86_64)`

`......`  
  
---|---  
  
停顿一下，下意识的感觉这个错误很熟悉，曾经遇到过。然后谷歌了下，找到了答案。解决过程如下：

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

`[root@etiantian data]``# mysql eshop_ett100 </home/xxx/eshop_ett100.0624.sql`

`ERROR 1030 (HY000) at line 46: Got error -1 from storage engine`

`[root@etiantian data]``# /etc/init.d/mysqld stop`

`Shutting down MySQL. SUCCESS! `

`[root@etiantian data]``# vi /etc/my.cnf <==此处顺便调整相关其他参数`

`innodb_force_recovery= 0 调整这个参数为0`

`skip-external-locking`

`key_buffer_size = 256M`

`max_allowed_packet = 1M`

`table_open_cache = 614`

`sort_buffer_size = 1M`

`read_buffer_size = 1M`

`read_rnd_buffer_size = 4M`

`myisam_sort_buffer_size = 64M`

`thread_cache_size = 8`

`query_cache_size= 16M`

`query_cache_limit = 1M`

`query_cache_min_res_unit = 2k`

`# Try number of CPU's*2 for thread_concurrency`

`thread_concurrency = 8`

`........`

`"/etc/my.cnf"` `159L, 4948C written`  
  
---|---  
  
重启服务

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

|

`[root@etiantian data]``# /etc/init.d/mysqld start`

`Starting MySQL.`

`. SUCCESS! `

`[root@etiantian data]``# `

`[root@etiantian data]``# mysql`

`Welcome to the MySQL monitor. Commands end with ; or \g.`

`Your MySQL connection ``id` `is 1`

`Server version: 5.5.33-log Source distribution`

` `

`Copyright (c) 2000, 2013, Oracle and``/or` `its affiliates. All
rightsreserved.`

` `

`Oracle is a registered trademark of Oracle Corporation and``/or` `its`

`affiliates. Other names may be trademarks of their respective`

`owners.`

` `

`Type ``'help;'` `or ``'\h'` `for` `help. Type ``'\c'` `to ``clear` `the
current inputstatement.`

` `

`mysql> show databases;`

`+--------------------+`

`| Database |`

`+--------------------+`

`| information_schema |`

`| mysql |`

`| performance_schema |`

`| eshop_ett100 |`

`| ``test` `|`

`+--------------------+`

`5 rows ``in` `set` `(0.00 sec)`  
  
---|---  
  
5、为了防止数据问题，重新建库。

1

2

3

4

5

6

7

8

|

`mysql> drop database eshop_ett100;`

`Query OK, 1 row affected (0.01 sec)`

` `

`mysql> create database eshop_ett100 CHARACTER SET utf8 COLLATE
utf8_general_ci;`

`Query OK, 1 row affected (0.00 sec)`

` `

`mysql> quit`

`Bye`  
  
---|---  
  
最后一击。

1

|

`[root@etiantian data]``# mysql eshop_ett100 </home/xxx/eshop_ett100.0624.sql`  
  
---|---  
  
到此，全备恢复成功。心里终于舒坦了。亲们。。。

接下来开始准备增量数据的恢复。

1、检查备份好的用于恢复的增量文件

1

2

3

4

5

6

7

|

`[root@etiantian data]``# cd /server/backup/`

`[root@etiantian backup]``# ll`

`total 84832`

`drwxr-xr-x 7 mysql mysql 4096 Jun 24 19:09 mysql`

`-rw-r----- 1 root root 14935771 Jun 24 19:27 mysql-bin.000014`

`-rw-r----- 1 root root 56588034 Jun 24 19:27 mysql-bin.000015`

`-rw-r--r-- 1 root root 15331635 Jun 24 19:06 mysql.``tar``.gz`  
  
---|---  
  
2、根据全备的时间点设置增量恢复条件（这里要看全备的时间点）

1

2

3

4

5

6

7

8

|

`[root@etiantian backup]``# mysqlbinlog mysql-bin.000014mysql-bin.000015
--start-datetime='2014-06-24 02:23:00' >bin.sql`

`mysqlbinlog: unknown variable ``'default-character-set=utf8'`

`[root@etiantian backup]``# which mysqlbinlog`

`/install/mysql/bin/mysqlbinlog`

`[root@etiantian backup]``# /install/mysql/bin/mysqlbinlogmysql-bin.000014
mysql-bin.000015 --start-datetime='2014-06-24 02:23:00'>bin.sql`

`/install/mysql/bin/mysqlbinlog``: unknown variable``'default-character-
set=utf8'`

`[root@etiantian backup]``# /install/mysql/bin/mysqlbinlogmysql-bin.000014
mysql-bin.000015 --start-datetime='2014-06-24 02:23:00'>bin.sql`

`/install/mysql/bin/mysqlbinlog``: unknown variable``'default-character-
set=utf8'`  
  
---|---  
  
我晕，又报错，定了定神一看，你X，这个错误瞒不了我，老男孩给学生讲课常遇到。

添加 **\--no-defaults** **参数开始增量恢复。**

1

2

3

|

`[root@etiantian backup]``# /install/mysql/bin/mysqlbinlog --no-defaultsmysql-
bin.000014 mysql-bin.000015 --start-datetime='2014-06-24 02:23:00'>bin.sql`

`[root@etiantian backup]``# less bin.sql`

`[root@etiantian backup]``# mysql eshop_ett100 < bin.sql`  
  
---|---  
  
到此，增量恢复完毕，即数据库故障问题全部恢复完成。

### 1.5数据库故障恢复后扫尾工作

1、登录数据库查看

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

|

`[root@etiantian backup]``# mysql`

`Welcome to the MySQL monitor. Commands end with ; or \g.`

`Your MySQL connection ``id` `is 4`

`Server version: 5.5.33-log Source distribution`

` `

`Copyright (c) 2000, 2013, Oracle and``/or` `its affiliates. All
rightsreserved.`

` `

`Oracle is a registered trademark of Oracle Corporation and``/or` `its`

`affiliates. Other names may be trademarks of their respective`

`owners.`

` `

`Type ``'help;'` `or ``'\h'` `for` `help. Type ``'\c'` `to ``clear` `the
current inputstatement.`

` `

`mysql> showdatabases; 看到了多紧张了吧。`

`ERROR 1064 (42000): You have an error ``in` `your SQL syntax; check themanual
that corresponds to your MySQL server version ``for` `the right syntax touse
near ``'showdatabases'` `at line 1`

`mysql> show databases;`

`+--------------------+`

`| Database |`

`+--------------------+`

`| information_schema |`

`| mysql |`

`| performance_schema |`

`| eshop_ett100 |`

`| ``test` `|`

`+--------------------+`

`5 rows ``in` `set` `(0.00 sec)`

` `

`mysql> use eshop_ett100`

`Reading table information ``for` `completion of table and column names`

`You can turn off this feature to get a quicker startup with -A`

` `

`Database changed`

`mysql> show tables;`

`+-----------------------------+`

`| Tables_in_eshop_ett100 |`

`+-----------------------------+`

`| eshop_ett_activity |`

`......`

`| eshop_ett_web |`

`| eshop_ett_web_code |`

`+-----------------------------+`

`185 rows ``in` `set` `(0.00 sec)`  
  
---|---  
  
所有的表都存在。退出，对恢复完毕的数据库做全备，这块非常关键，不要让恢复过程付诸东流。

1

2

3

|

`mysql> quit`

`Bye`

`[root@etiantian backup]``# mysql -B –F eshop_ett100|gzip>new.sql.gz`  
  
---|---  
  
<==我晕忙中出错，恢复命令开始都搞错了，结果，处于等待状态，回车也不结束。

正确恢复命令如下：

1

|

`[root@etiantian backup]``# mysqldump -B -F eshop_ett100|gzip>new.sql.gz`  
  
---|---  
  
2、通知客户，先改web端口，开启web服务内部测试看看

目的：该端口目的是不让用户访问，内部先看下是否恢复正常。与客户回报原话：

老男孩 19:41:53

亲，恢复完毕了。

老男孩 19:42:00

先别起WEB

老男孩 19:42:04

你等进去

老男孩 19:42:15

等进去设置下连接账号吧

XX 19:42:17

好

老男孩 19:42:28

root没密码

XX 19:42:44

好

老男孩 19:43:39

需要我帮忙你就提供用户和密码

XX 19:43:41

客户端进不去mysql

XX 19:43:51

哦，没密码

XX 19:43:57

etiantian，test110oldboy

XX 19:44:14

权限是本机增删查改eshop_ett

老男孩 19:45:28

grant select,insert,update,delete on eshop_ett100.* to'etiantian'@'localhost'
identified by 'test110oldboy'

XX 19:45:39

yes

老男孩 19:46:30

WEB目录在哪

XX 19:46:36

/www

老男孩 19:46:37

我们改个端口起来

XX 19:46:44

好

XX 19:46:47

用多少端口

XX 19:46:51

我在web里面改

老男孩 19:46:53

9000

3、测试web服务，居然403，有连续调整了web目录许可，以及首页文件，最后成功打开网站，经过客户仔细测试。

提示：在老男孩恢复期间，还有客户公司的2个人，添乱，一直在改东西。所以导致了web也403。

老男孩 19:47:05

你改吧就是不让用户登录

老男孩 19:47:10

我们看下数据是否正常

老男孩 19:47:21

一切OK了 就可以改回端口用了

XX 19:47:30

好

XX 19:47:40

你说的是httpd的端口是吗

老男孩 19:47:49

对的

老男孩 19:47:59

数据库密码改了？

XX 19:47:59

我以为mysql的端口

XX 19:48:19

好了

XX 19:48:21

改了

XX 19:48:23

全是那个密码

老男孩 19:48:33

哪个

XX 19:48:35

今天在网上暴露了，回头我得改密码

XX 19:48:40

test110oldboy

XX 19:48:46

root，etiantian都这个

XX 19:48:56

我现在起web？

老男孩 19:50:04

改过的HTTP的端口 就重启吧

XX 19:50:29

好

老男孩 19:51:05

**登录web检查点**

 **1、看看乱码不。**

 **2、看看用户注册记录量, 够不够,是不是连续的,订单对不对 包括白天有没有**

XX 19:51:42

恩

XX 19:53:10

说的没权限访问根目录，我看看

老男孩 19:54:24

提示呢

XX 19:54:36

[Tue Jun 24 19:53:57 2014] [error] [client 110.75.102.99] Directoryindex
forbidden by Options directive: /www/

XX 19:54:38

httpd

XX 19:54:43

没事这个，我能搞定

老男孩 19:56:16

还是80 了？

XX 19:56:31

恩

XX 19:56:39

有领导来了要看，擦

老男孩 19:57:00

不行目录给我 403 我来帮你

老男孩 19:57:21

站点目录 http配置路径告诉我

XX 19:57:36

httpd安装目录 /install/httpd

XX 19:57:43

其余全是默认

XX 19:59:32

你等下，我大约知道什么问题了

老男孩 20:00:00

首页文件是哪个

老男孩 20:00:03

赶紧告诉我

XX 20:00:17

改掉了，等下，我替换回来看看

老男孩 20:00:36

我改好好了

老男孩 20:00:41

你别乱改了。

老男孩 20:00:45

直接打开网站就行了

老男孩 20:00:54

测试好了以后你再弄

老男孩 20:00:59

我这个打开了

老男孩 20:01:04

你登录检查数据库吧

XX 20:01:07

好了

老男孩 20:01:14

之前你们都改错了

XX 20:01:16

我从别的主机上拿了个文件来了

老男孩 20:01:23

站点目录和许可的不一致还没首页文件

XX 20:01:44

有个人改了这个东西

XX 20:01:46

是的

老男孩 20:01:56

赶紧检查数据库吧

XX 20:02:01

我们经理一直在旁边看着，太撑面子了

XX 20:02:02

哈哈

老男孩 20:02:15

赶紧检查 没事 我就下了，下课了，我还没吃饭呢，有朋友等着呢。

老男孩 20:02:20

必须支持你们啊。

老男孩 20:02:26

不支持你们支持谁

老男孩 20:02:45

整个恢复过程应该是数据无损失

XX 20:02:54

哈哈，太感谢了

老男孩 20:04:05

刚才我写了个备份脚本 被删了。

老男孩 20:04:23

改天你让运维都搞好写个优化文档 回头我给你审核下。

XX 20:04:33

我只删了install/mysql

老男孩 20:04:34

备份容灾措施

XX 20:04:42

等下，我看看你说的有个文件许可

老男孩 20:05:11

看看都正常了不

XX 20:05:27

都正常了

老男孩 20:05:34

ll /server/backup/

老男孩 20:05:40

恢复之后的全备目录

老男孩 20:05:45

你们赶紧全备吧

XX 20:05:58

全备就还是我那个命令对吧

老男孩 20:07:05

!#/bin/sh

bakpath=/server/scripts

[ ! -d $bakpath ] &&mkdir $bakpath

mysqldump -uroot -ptest110oldboy -B
eshop_ett100|gzip>$bakpath/eshop_ett100_$(date +%F).sql.gz

mysqldump -uroot -ptest110oldboy -B mysql --events |gzip>$bakpath/mysql_$(date
+%F).sql.gz

老男孩 20:07:20

一定要加-B 不然恢复麻烦

XX 20:08:16

我把全备就放在那个/server/backup/下面就行了是吧

XX 20:08:44

好，我按你这个备

老男孩 20:08:51

mysqldump -uroot -ptest110oldboy **-B -F --single-transaction**
eshop_ett100|gzip >$bakpath/eshop_ett100_$(date +%F).sql.gz

老男孩 20:09:01

最后这个吧。

XX 20:09:04

好

老男孩 20:09:19

备好写个定时任务，然后头几天检查报警看。

老男孩 20:09:44

增量直接本地rsync 推就可以

老男孩 20:09:52

对

老男孩 20:10:02

注意目录是变量要定义

老男孩 20:10:07

我要下了

老男孩 20:10:11

还有事么？

XX 20:10:11

本地没其他虚拟机，其他的都在我内网，像我刚拽index文件过去

XX 20:10:14

好的，你休息

XX 20:10:24

我写备份脚本+cron

XX 20:10:26

没事了

XX 20:10:28

太感谢了

老男孩 20:10:59

我下了。有事电话。

XX 20:11:02

好的

XX 20:11:04

你先下吧

XX 20:11:09

我慢慢研究会

XX 20:11:10

呵呵

老男孩 20:11:12

不注意规范

XX 20:11:14

水平如此噻

老男孩 20:11:23

恢复的过程有空我给你

XX 20:11:23

手还是太糙

老男孩 20:11:26

我都保留了

XX 20:11:28

好的

老男孩 20:11:33

你是开发大拿

老男孩 20:11:43

各有专攻

XX 20:11:46

哎，现在开发少了，主要靠这个

XX 20:11:57

你抓紧时间休息吧

老男孩 20:12:02

好 88

XX 20:12:06

上一天课也累了

XX 20:12:08

好，88哦

老男孩 20:12:56

另外以后不要killall杀库，我估计你是参数给大了，特别是innodb buffer。停库时间较长是正常的，多等，另外要做好主从复制，为恢复争取时间。

后记：整个恢复过程持续了将近1个小时。比计划解决时间多出了半小时，看来很多时间还是始料不及的，特别是作为第三方公司，老男孩对客户的业务不了解也是故障恢复进度慢的一个原因，好多要和客户沟通交流的，另外，不在一个城市，靠QQ聊天解决问题，效率确实还是低了一些，幸好客户的配合还是不错。  
  
 **解决问题容易，写故障报告难，能主动写报告给客户更难，老男孩做到了。**  
1、ssh事先配好记录LOG，便于事后总结。  
2、服务于客户，要尽可能超越客户的期待。  
老男孩和大家一起努力。。。谢谢大家观看。

LINUX技术交流群 246054962 208160987(标明51CTO)  

版权声明：原创作品，如需转载，请注明出处。否则将追究法律责任

[故障](http://blog.51cto.com/search/result?q=%E6%95%85%E9%9A%9C)
[数据库](http://blog.51cto.com/search/result?q=%E6%95%B0%E6%8D%AE%E5%BA%93)
[解决案例](http://blog.51cto.com/search/result?q=%E8%A7%A3%E5%86%B3%E6%A1%88%E4%BE%8B)

68

分享

收藏

[上一篇：625某电商网站数据库宕机故障解决实录（上）](http://blog.51cto.com/oldboy/1431161
"625某电商网站数据库宕机故障解决实录（上）")
[下一篇：解答网友shell问题一例20140702](http://blog.51cto.com/oldboy/1433688
"解答网友shell问题一例20140702")

  


---
### NOTE ATTRIBUTES
>Created Date: 2018-03-02 01:11:06  
>Last Evernote Update Date: 2018-10-01 15:35:37  
>author: YangKwong  
>source: web.clip  
>source-url: http://blog.51cto.com/oldboy/1431172  