# 625某电商网站数据库宕机故障解决实录（上）-老男孩linux培训-51CTO博客

  

[老男孩linux培训](http://blog.51cto.com/oldboy) _>_ 正文

# 625某电商网站数据库宕机故障解决实录（上） __推荐

原创 [老男孩oldboy](http://blog.51cto.com/oldboy) 2014-06-26 14:04:41
[评论(33)](http://blog.51cto.com/oldboy/1431161#comment) 18749人阅读

**博客编辑器越来越用不好了，伙伴们将就看，需要排版更好的文档请加Q群 246054962。**  
  
 **625某电商网站数据库特大故障解决实录(上)**

这是一次，惊心动魄的企业级电商网站数据库在线故障解决实录，故障解决的过程遇到了很多问题，思想的碰撞，解决方案的决策，及实际操作的问题困扰，老男孩尽量原汁原味的描述恢复的全部过程及思想思维过程！
**老男孩教育版权所有** ，本内容禁止商业用途。

目录：

[625某电商网站数据库特大故障解决实录...
1](http://oldboy.blog.51cto.com/addblog.php#_Toc391554296)

[1接到电商客户报警... 1](http://oldboy.blog.51cto.com/addblog.php#_Toc391554297)

[1.1与客户初步沟通... 1](http://oldboy.blog.51cto.com/addblog.php#_Toc391554298)

[1.2深入沟通确定故障恢复方案... 2](http://oldboy.blog.51cto.com/addblog.php#_Toc391554299)

[1.3开始故障恢复准备... 4](http://oldboy.blog.51cto.com/addblog.php#_Toc391554300)

[1.4开始进行故障恢复*****. 6](http://oldboy.blog.51cto.com/addblog.php#_Toc391554301)

[1.5数据库故障恢复后扫尾工作...
15](http://oldboy.blog.51cto.com/addblog.php#_Toc391554302)

## **1 接到电商客户报警**

###  **1.1 与客户初步沟通**

昨日接到某电商网站客户电话，说搞秒杀赠送活动，数据库遇到问题了，结果启动起不来了。

1

2

|

`[root@etiantian etc]``# /etc/init.d/mysqld start`

`Starting MySQL. ERROR! The server quit without updating PID ``file`
`(``/var/run/mysqld/mysqld``.pid).`  
  
---|---  
  
提示：此部分客户给的是截图，是后期老男孩根据SSH日志整理而来。

由于时间紧急，本能的提示客户看看/var/run/mysqld/mysqld.pid存在否，如果存在，删除再启动，客户说没有这个PID文件，提示用户用mysqld_safe
--user=mysql &启动看看，结果可以启动成功done，但是，端口服务依然起不来。让客户查下mysql启动日志，报错如下：

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

|

`[root@etiantian etc]``# cat /var/log/mysqld.log`

`140624 18:51:58 mysqld_safe Starting mysqld daemon with databases from
``/data/mysql/`

`140624 18:51:58 InnoDB: The InnoDB memory heap is disabled`

`140624 18:51:58 InnoDB: Mutexes and rw_locks use GCC atomic builtins`

`140624 18:51:58 InnoDB: Compressed tables use zlib 1.2.3`

`140624 18:51:58 InnoDB: Initializing buffer pool, size = 768.0M`

`140624 18:51:58 InnoDB: Completed initialization of buffer pool`

`InnoDB: Error: auto-extending data ``file` `.``/ibdata1` `is of a different
size`

`InnoDB: 2176 pages (rounded down to MB) than specified ``in` `the .cnf
``file``:`

`InnoDB: initial 65536 pages, max 0 (relevant ``if` `non-zero) pages!`

`140624 18:51:58 InnoDB: Could not ``open` `or create data files.`

`140624 18:51:58 InnoDB: If you tried to add new data files, and it failed
here,`

`140624 18:51:58 InnoDB: you should now edit innodb_data_file_path ``in`
`my.cnf back`

`140624 18:51:58 InnoDB: to what it was, and remove the new ibdata files
InnoDB created`

`140624 18:51:58 InnoDB: ``in` `this failed attempt. InnoDB only wrote those
files full of`

`140624 18:51:58 InnoDB: zeros, but did not yet use them ``in` `any way. But
be careful: ``do` `not`

`140624 18:51:58 InnoDB: remove old data files ``which` `contain your precious
data!`

`140624 18:51:58 [ERROR] Plugin ``'InnoDB'` `init ``function` `returned
error.`

`140624 18:51:58 [ERROR] Plugin ``'InnoDB'` `registration as a STORAGE ENGINE
failed.`

`140624 18:51:58 [ERROR] Unknown``/unsupported` `storage engine: InnoDB`

`140624 18:51:58 [ERROR] Aborting`

` `

`140624 18:51:58 [Note] ``/install/mysql/bin/mysqld``: Shutdown complete`

` `

`140624 18:51:58 mysqld_safe mysqld from pid ``file`
`/var/run/mysqld/mysqld``.pid ended`  
  
---|---  
  
提示：此部分客户给的是截图，是后期老男孩根据SSH日志整理而来。

红色部分为错误。  
InnoDB: Error: auto-extending data file ./ibdata1 is of a different size140624
18:51:58 [ERROR] Plugin 'InnoDB' init function returned error.  
140624 18:51:58 [ERROR] Plugin 'InnoDB' registration as a STORAGE ENGINE
failed.  
140624 18:51:58 [ERROR] Unknown/unsupported storage engine: InnoDB  
140624 18:51:58 [ERROR] Aborting

根据客户的信息和自身的经验基本定位了客户有可能强制终止了进程或者改变了数据文件！

于是，询问客户故障前和故障后，都做了啥操作，得到的回答如下：

1

2

3

4

5

6

|

`XXXX 18:53:41 `

`数据库之前停止响应，killall之前已经没办法做restart重启了`

`XXXX 18:53:32`

`我觉得有问题，然后killall掉了，然后就起不来了，别的没做。`

`根据日志以及客户的描述，基本上断定是强制关闭服务导致innodb表空间或文件异常。`

`至此问题原因及故障现象已经确定。`  
  
---|---  
  
###  **1.2** 深入沟通确定故障恢复方案

由于客户比较着急，人很紧张，且恢复网站提供服务迫在眉睫，老板就在旁边紧盯着客户。。，压力比较大，因此，客户要求老男孩项目团队远程连接介入，代为操作解决。

和客户确认了责任和风险后！

立即连接服务器，着手进行了一系列的抢救措施，没有结果。抢救措施有：

1、杀掉服务重启。2.调整my.cnf相关参数发现某些参数比较大，特别innodb_buffer，调整后依然无法启动。3.调整innodby
recover参数。

由于此前就知道客户是近期刚上线的一个电商网站业务。

因此和客户沟通。询问客户是否有全量备份及增量备份？得到的回答是客户做了全量备份了。增量没做任何处理。

问完了客户，我们自己登陆服务器检查客户提供的信息看看是否都是正确的。

由于时间极其紧迫，客户比较慌张，很多内容自己无法一下说清楚，和老男孩团队又不在一个城市。

于是我们直接登录服务器，根据常规判断及历史记录（history命令行及/root/.mysql_history文件）找到数据库的配置文件/etc/my.cnf，进而找到了数据库安装路径/install/mysql，数据文件路径/data/mysql。binlog的路径/data/mysql，db备份路径/home/xx/。

此时急需要确定的是两件事：第一个就是binlog是否完整，第二个就是全备是否有效。于是根据客户描述以及我们自己登陆服务器查看，结果如下。

第一个binlog数据内容：

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

`<span style=``"font-size:16px;"``><span style=``"font-family:'宋体';font-
size:16px;"``>[root@etiantianmysql]``# ll`

`total118576`

`-rw-rw----1 mysql mysql 356515840 Jun 24 18:33 ibdata1`

`-rw-rw----1 mysql mysql 5242880 Jun 24 18:33ib_logfile0`

`-rw-rw----1 mysql mysql 5242880 Jun 24 18:33ib_logfile1`

`drwx------2 mysql mysql 4096 Jun 18 16:39 mysql`

`......`

`-rw-rw----1 mysql mysql 126 May 21 10:24mysql-bin.000012`

`-rw-rw---- 1 mysql mysql 1356022 May 21 10:35 mysql-bin.000013`

`-rw-rw---- 1 mysql mysql 14935771 Jun 18 16:35mysql-bin.000014`

`-rw-rw---- 1 mysql mysql 56588034 Jun 24 18:33mysql-bin.000015`

`-rw-rw----1 mysql mysql 285 Jun 18 16:39mysql-bin.index`

`drwx------2 mysql mysql 4096 May 20 21:22performance_schema`

`drwx------2 mysql mysql 20480 May 21 10:28eshop_ett`

`drwx------2 mysql mysql 12288 Jun 18 13:53eshop_ett100`

`drwx------2 mysql mysql 4096 May 20 21:13 ``test``<``/span``><``/span``>`  
  
---|---  
  
根据上述结果，确定binlog内容是正常的。

开始查看数据库的全备是不是OK的。

1

2

|

` ``[root@etiantian backup]``# ll /home/xxx/eshop_ett100.0624.sql `

`-rw-r--r-- 1 root root 55769500 Jun 24 02:21
``/home/xxx/eshop_ett100``.0624.sql`  
  
---|---  
  
结论：全备也是OK的。而且，根据binlog日志的时间以及全备的时间看，数据是对应的。

实际调查完毕后，和客户进行沟通恢复方案：

1、如果继续修复数据文件可能时间会比较长，暂时还没头绪。因此，询问客户是不是尽快恢复数据库服务非常重要？得到的答复：“是”。

由于客户非常着急恢复网站业务（活动广告早都打出去了），也就是立刻提供服务非常重要，但是作为一个DBA来讲，数据也是同样重要的。

于是老男孩和客户紧急沟通，给出了一个解决方案：由于当时事情紧急，内容简化，原话如下：

根据你们业务刚上线不久，数据量不是很大，比较好的故障解决方案，就是重建数据库，然后导入备份及增量！我预计整个恢复时间大约10-30分钟左右，数据基本可以做到0损失。也就是说数据不会丢失，最快10分钟可提供服务。

客户对这个方案的回复是：“很满意”，立刻爽快的答应了我们的数据库故障解决方案。原文如下：

1

2

3

4

|

`xxx 19:10:09`

`你说的我都同意`

`老男孩 19:10:15 `

`那我开整了`  
  
---|---  
  
###  **1.3 开始故障恢复准备**

1、关闭web服务

 **目的：关闭 web** **的考虑是，防止数据库启动后恢复前用户写入脏数据。**

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

|

`[root@etiantian data]``# ps -ef|grep httpd`

`root 28697 1 0 19:15 ? 00:00:00 ``/install/httpd//bin/httpd` `-k start`

`www 28699 28697 1 19:15 ? 00:00:02 ``/install/httpd//bin/httpd` `-k start`

`www 28702 28697 0 19:15 ? 00:00:00 ``/install/httpd//bin/httpd` `-k start`

`www 28703 28697 0 19:15 ? 00:00:00 ``/install/httpd//bin/httpd` `-k start`

`www 28704 28697 0 19:15 ? 00:00:00 ``/install/httpd//bin/httpd` `-k start`

`www 28707 28697 0 19:15 ? 00:00:00 ``/install/httpd//bin/httpd` `-k start`

`www 28709 28697 0 19:15 ? 00:00:00 ``/install/httpd//bin/httpd` `-k start`

`www 28711 28697 0 19:15 ? 00:00:00 ``/install/httpd//bin/httpd` `-k start`

`www 28712 28697 0 19:15 ? 00:00:00 ``/install/httpd//bin/httpd` `-k start`

`www 28713 28697 0 19:15 ? 00:00:00 ``/install/httpd//bin/httpd` `-k start`

`www 28714 28697 0 19:15 ? 00:00:00 ``/install/httpd//bin/httpd` `-k start`

`www 28715 28697 0 19:15 ? 00:00:00 ``/install/httpd//bin/httpd` `-k start`

`www 28716 28697 0 19:15 ? 00:00:00 ``/install/httpd//bin/httpd` `-k start`

`www 28720 28697 0 19:15 ? 00:00:00 ``/install/httpd//bin/httpd` `-k start`

`root 28850 26341 0 19:17 pts``/5` `00:00:00 ``grep` `httpd`

`[root@etiantian data]``# /etc/init.d/httpd stop`

`[root@etiantian data]``# ps -ef|grep httpd`

`root 28855 26341 0 19:17 pts``/5` `00:00:00 ``grep` `httpd`

`[root@etiantian data]``# ps -ef|grep httpd`

`root 28857 26341 0 19:17 pts``/5` `00:00:00 ``grep` `httpd`

`[root@etiantian data]``# ps -ef|grep httpd`

`root 28877 26341 0 19:18 pts``/5` `00:00:00 ``grep` `httpd`

`[root@etiantian data]``# lsof -i :80`  
  
---|---  
  
2、备份当前正在跑得所有线上数据库数据

 **目的：不能对客户的数据进行二次破坏数据**

1

2

3

4

5

6

|

`[root@etiantian mysql]``# cd ../`

`[root@etiantian data]``# tar zcvf /server/backup/mysql.tar.gz ./mysql/`

`[root@etiantian data]``# cp -ap mysql /server/backup/`

`[root@etiantian data]``# du -sh /server/backup/*`

`1230M ``/server/backup/mysql`

`150M ``/server/backup/mysql``.``tar``.gz`  
  
---|---  
  
3、确认全备数据是正常的。手动检查查看

 **目的：验证备份的数据确实是 OK** **的，否则后果不堪设想。**

1

2

3

4

|

`[root@etiantian data]``# ll /data/eshop_ett100.0624.sql `

`-rw-r--r-- 1 root root 55769500 Jun 24 19:04 ``/data/eshop_ett100``.0624.sql`

`[root@etiantian data]``# less /data/eshop_ett100.0624.sql `

`-- MySQL dump 10.13 Distrib 5.5.33, ``for` `Linux (x86_64)`  
  
---|---  
  
4、搜集db增量日志

彻底杀掉mysql服务

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

|

`[root@etiantian data]``# killall mysqld`

`mysqld: no process killed`

`[root@etiantian data]``# killall mysqld`

`mysqld: no process killed`

`[root@etiantian data]``# mv mysql /opt/`

`[root@etiantian opt]``# cd mysql/`

`[root@etiantian mysql]``# ll`

`total 118576`

` ``-rw-r----- 1 mysql mysql 0 Jun 24 18:53 AY1405201820416899ebZ.err`

`-rw-rw---- 1 mysql mysql 35651584 Jun 24 18:33 ibdata1`

`-rw-rw---- 1 mysql mysql 5242880 Jun 24 18:33 ib_logfile0`

`-rw-rw---- 1 mysql mysql 5242880 Jun 24 18:33 ib_logfile1`

`drwx------ 2 mysql mysql 4096 Jun 18 16:39 mysql `

`......`

`-rw-rw---- 1 mysql mysql 126 May 21 10:24 mysql-bin.000012`

`-rw-rw---- 1 mysql mysql 1356022 May 21 10:35 mysql-bin.000013`

`-rw-rw---- 1 mysql mysql 14935771 Jun 18 16:35 mysql-bin.000014`

`-rw-rw---- 1 mysql mysql 56588034 Jun 24 18:33 mysql-bin.000015`

`-rw-rw---- 1 mysql mysql 285 Jun 18 16:39 mysql-bin.index`

`drwx------ 2 mysql mysql 4096 May 20 21:22 performance_schema`

`drwx------ 2 mysql mysql 24576 May 21 10:28 eshop_ett`

`drwx------ 2 mysql mysql 12288 Jun 18 13:53 eshop_ett100`

`drwx------ 2 mysql mysql 4096 May 20 21:13 ``test`  
  
---|---  
  
拷贝增量日志，防止被二次破坏。等待恢复。

1

|

`[root@etiantian mysql]``# cp mysql-bin.000014 mysql-bin.000015
/server/backup/`  
  
---|---  
  
至此全部故障修复的全部准备工作完毕。

 **欲知后事如何，请看下集。**

版权声明：原创作品，如需转载，请注明出处。否则将追究法律责任

[故障](http://blog.51cto.com/search/result?q=%E6%95%85%E9%9A%9C)
[数据库](http://blog.51cto.com/search/result?q=%E6%95%B0%E6%8D%AE%E5%BA%93)
[电商](http://blog.51cto.com/search/result?q=%E7%94%B5%E5%95%86)

48

分享

收藏

[上一篇：老男孩为网友工作疑难问题解答一例](http://blog.51cto.com/oldboy/1429349
"老男孩为网友工作疑难问题解答一例")
[下一篇：625某电商网站数据库宕机故障解决实录（下）](http://blog.51cto.com/oldboy/1431172
"625某电商网站数据库宕机故障解决实录（下）")

## 发表评论

Ctrl+Enter 发布

发布

取消

33条评论

按时间倒序 按时间正序

[](http://blog.51cto.com/chenguang)

[李晨光](http://blog.51cto.com/chenguang)

1楼 2014-06-26 15:40:57

不错的案例分析！

0

0人回复

[](http://blog.51cto.com/tech110)

[zhangzj1030](http://blog.51cto.com/tech110)

2楼 2014-06-26 17:12:02

不错，写的和有思路，老男孩强悍！

0

0人回复

[](http://blog.51cto.com/fyywzl)

[dougsonmo](http://blog.51cto.com/fyywzl)

3楼 2014-06-26 18:18:12

对于真实的线上项目的错误恢复，我个人没什么经验，但看完老师的博文之后，思路变得清晰多了！|@|果断赞一个！！~~

0

0人回复

[](http://blog.51cto.com/jishuweiwang)

[博弈帅哥哥](http://blog.51cto.com/jishuweiwang)

4楼 2014-06-26 18:19:01

这个案例反应出一个问题：第一，电商公司的这个运维太坑，编译参数都能写错 第二：电商数据库怎么就提及从库呢？
第三：数据库为什么不进行分库...|@|从中我学到的就是线上环境数据库恢复时步骤必须有的是，1.切断数据库请求. 2.停掉数据库 3. 备份灾难现场 4.
备份关键文件，防止二次破坏 5.数据恢复...（全量＋增量等等）

0

1人回复

  * 作者[老男孩oldboy](http://blog.51cto.com/oldboy)[:@博弈帅哥哥 ](http://blog.51cto.com/jishuweiwang)他们应该自己做过故障处理，慌张时刻，出这个问题是正常的，别忘了，老大紧盯着呢。

2014-06-26 18:26:16

回复

添加新回复

[](http://blog.51cto.com/liujianzuo)

[liujianzuo](http://blog.51cto.com/liujianzuo)

5楼 2014-06-26 18:43:24

通过老师的这个案例，学到了几点内容：|@|1、遇事冷静处理，不慌张--
最重要。|@|2、平时的一些小习惯，好的可以成就你，坏的可以在关键时刻摧毁你。|@|3、有一个清晰的解决思路。|@|这些将会是我就下来要不断去学习的方向！

0

0人回复

[](http://blog.51cto.com/jiandan)

[hel1960050004](http://blog.51cto.com/jiandan)

6楼 2014-06-26 20:04:45

老男孩老师，你好。看完了这两篇博文。有疑问如下：对方的mysql是双机、HA或者单节点，这个有利于灾难模拟

0

1人回复

  * 作者[老男孩oldboy](http://blog.51cto.com/oldboy)[:@hel1960050004 ](http://blog.51cto.com/jiandan)刚起步的小电商，没那么大，技术人员也不足。但是业务做的比较好。

2014-06-27 10:15:24

回复

添加新回复

[](http://blog.51cto.com/rocdk890)

[rocdk890](http://blog.51cto.com/rocdk890)

7楼 2014-06-26 21:43:20

我想说电商的数据库不可能就一个撒,还有为什么重建数据库之后,不把原来的数据库单独拷进去,反而要用备份的,难道备份的比原来的数据库更新?

0

1人回复

  * 作者[老男孩oldboy](http://blog.51cto.com/oldboy)[:@rocdk890 ](http://blog.51cto.com/rocdk890)原来的数据文件顺坏了。备份加增量 是完整最新的。这是一家刚上线不久的小型电商网站。

2014-06-27 10:14:16

回复

添加新回复

[](http://blog.51cto.com/edmyingxiao)

[EDMyingxiao](http://blog.51cto.com/edmyingxiao)

8楼 2014-06-26 22:01:25

思路很清晰哈，沟通也很高效啊！

0

0人回复

[](http://blog.51cto.com/815632410)

[815632410](http://blog.51cto.com/815632410)

9楼 2014-06-26 23:17:43

1、操作一定要规范，养成良好习惯。|@| 例如：停止数据库服务，不要强制禁止mysql进程|@| 例如备份数据库时的-B参数，如果备份时有-
B参数，老男孩老师恢复数据时就不用重新建库了。|@|2、才知道my.cnf相关参数，也会影响数据库启动；对配置文件参数必须相当明白。|@|
以前一直以为配置文件有语法错误可能导致无法启动，原来参数的值设置不合适也会有影响。|@|3、老师在这么高压的情况下，思路还能如此清晰，证明老师经验确实很丰富啊。说实话看这篇博文时，心里一直扑腾。。|@|
（想想本人以前在机房值班时，核心路由器挂了的情景，历历在目啊）|@|4、老师在很短时间内就能够找到故障原因，并权衡利弊给出最终解决方案。（思想很重要，做技术不仅要有技术，还要有思想，思想比技术更重要。）|@|5、像这种情况，如果数据库没有全备，下面是不是就没法玩了？|@|6、老师，像在大公司里（新浪、搜狐等），是否有定期或者不定期的故障演练？大公司是不是都有故障处理的流程？以便出现故障时可以最短时间内恢复业务。|@|7、老师的故障处理过程，完美地诠释了老男孩教学和培训的核心思想：重目标、重思路、重方法、重实践、重习惯、重总结。

0

0人回复

[](http://blog.51cto.com/sunday208)

[sunday208](http://blog.51cto.com/sunday208)

10楼 2014-06-27 09:17:05

不错的案例分析！

0

0人回复

  * 上一页
  * 1
  * 2
  * 3
  * 下一页

  


---
### ATTACHMENTS
[20351ec048451f423530805cab280fdb]: media/wKioL1MxAgHxAN4JAABnk0ugb98686_middle.jpg
[wKioL1MxAgHxAN4JAABnk0ugb98686_middle.jpg](media/wKioL1MxAgHxAN4JAABnk0ugb98686_middle.jpg)
>hash: 20351ec048451f423530805cab280fdb  
>source-url: https://s3.51cto.com//wyfs02/M00/23/16/wKioL1MxAgHxAN4JAABnk0ugb98686_middle.jpg  
>file-name: wKioL1MxAgHxAN4JAABnk0ugb98686_middle.jpg  

[2994da32d070b4c7171dfe6582413596]: media/wKioL1LOA-iSvMRvAAAcFmmAMSo298_middle.jpg
[wKioL1LOA-iSvMRvAAAcFmmAMSo298_middle.jpg](media/wKioL1LOA-iSvMRvAAAcFmmAMSo298_middle.jpg)
>hash: 2994da32d070b4c7171dfe6582413596  
>source-url: https://s3.51cto.com//wyfs02/M00/0C/A0/wKioL1LOA-iSvMRvAAAcFmmAMSo298_middle.jpg  
>file-name: wKioL1LOA-iSvMRvAAAcFmmAMSo298_middle.jpg  

[7b2ec1e72084c4ed85bfba41e0e353c4]: media/noavatar_middle.gif.png
[noavatar_middle.gif.png](media/noavatar_middle.gif.png)
>hash: 7b2ec1e72084c4ed85bfba41e0e353c4  
>source-url: http://ucenter.51cto.com/images/noavatar_middle.gif  
>file-name: noavatar_middle.gif.png  

[93cc0d7101894923032a202524f92feb]: media/wKioL1cYLUTx7exVAAAp9jh-0hA624_middle.jpg
[wKioL1cYLUTx7exVAAAp9jh-0hA624_middle.jpg](media/wKioL1cYLUTx7exVAAAp9jh-0hA624_middle.jpg)
>hash: 93cc0d7101894923032a202524f92feb  
>source-url: https://s1.51cto.com//wyfs02/M01/7F/40/wKioL1cYLUTx7exVAAAp9jh-0hA624_middle.jpg  
>file-name: wKioL1cYLUTx7exVAAAp9jh-0hA624_middle.jpg  

[c00667fe9e1e5dbf918459ff8efe19df]: media/wKiom1MStBLhbsWvAAAR7Ev37Ak195_middle.jpg
[wKiom1MStBLhbsWvAAAR7Ev37Ak195_middle.jpg](media/wKiom1MStBLhbsWvAAAR7Ev37Ak195_middle.jpg)
>hash: c00667fe9e1e5dbf918459ff8efe19df  
>source-url: https://s3.51cto.com//wyfs02/M00/18/4D/wKiom1MStBLhbsWvAAAR7Ev37Ak195_middle.jpg  
>file-name: wKiom1MStBLhbsWvAAAR7Ev37Ak195_middle.jpg  

[dddeeeca6a86e05dfeee560b61406b4c]: media/wKioL1SzmTmh5trvAABpx3JdTZ0186_middle.jpg
[wKioL1SzmTmh5trvAABpx3JdTZ0186_middle.jpg](media/wKioL1SzmTmh5trvAABpx3JdTZ0186_middle.jpg)
>hash: dddeeeca6a86e05dfeee560b61406b4c  
>source-url: https://s3.51cto.com//wyfs02/M02/58/87/wKioL1SzmTmh5trvAABpx3JdTZ0186_middle.jpg  
>file-name: wKioL1SzmTmh5trvAABpx3JdTZ0186_middle.jpg  

[e9757cccb2599160f519dfc21e314c24]: media/wKioL1j1wsiiahdZAAAWq1-JJR4588_middle.jpg
[wKioL1j1wsiiahdZAAAWq1-JJR4588_middle.jpg](media/wKioL1j1wsiiahdZAAAWq1-JJR4588_middle.jpg)
>hash: e9757cccb2599160f519dfc21e314c24  
>source-url: https://s4.51cto.com//wyfs02/M00/91/63/wKioL1j1wsiiahdZAAAWq1-JJR4588_middle.jpg  
>file-name: wKioL1j1wsiiahdZAAAWq1-JJR4588_middle.jpg  

[f0e97b0d620b12a90f8d9432c001f0df]: media/wKioL1WwqzXS54W1AABB8mkBXbk047_middle.jpg
[wKioL1WwqzXS54W1AABB8mkBXbk047_middle.jpg](media/wKioL1WwqzXS54W1AABB8mkBXbk047_middle.jpg)
>hash: f0e97b0d620b12a90f8d9432c001f0df  
>source-url: https://s3.51cto.com//wyfs02/M02/70/10/wKioL1WwqzXS54W1AABB8mkBXbk047_middle.jpg  
>file-name: wKioL1WwqzXS54W1AABB8mkBXbk047_middle.jpg  

[fd1f202af1e7148b6c4f9894660590e7]: media/wKiom1ShKb7h3AckAABHjRu8gds687_middle.jpg
[wKiom1ShKb7h3AckAABHjRu8gds687_middle.jpg](media/wKiom1ShKb7h3AckAABHjRu8gds687_middle.jpg)
>hash: fd1f202af1e7148b6c4f9894660590e7  
>source-url: https://s3.51cto.com//wyfs02/M02/5  
>source-url: 7/A8/wKiom1ShKb7h3AckAABHjRu8gds687_middle.jpg  
>file-name: wKiom1ShKb7h3AckAABHjRu8gds687_middle.jpg  

[ff24e015339076c097b1984047268348]: media/wKioL1cxVH3w9uE8AAA1o2r2xXQ416_middle.jpg
[wKioL1cxVH3w9uE8AAA1o2r2xXQ416_middle.jpg](media/wKioL1cxVH3w9uE8AAA1o2r2xXQ416_middle.jpg)
>hash: ff24e015339076c097b1984047268348  
>source-url: https://s4.51cto.com//wyfs02/M00/7F/E4/wKioL1cxVH3w9uE8AAA1o2r2xXQ416_middle.jpg  
>file-name: wKioL1cxVH3w9uE8AAA1o2r2xXQ416_middle.jpg  

---
### NOTE ATTRIBUTES
>Created Date: 2018-03-02 01:10:55  
>Last Evernote Update Date: 2018-10-01 15:35:37  
>author: YangKwong  
>source: web.clip  
>source-url: http://blog.51cto.com/oldboy/1431161  