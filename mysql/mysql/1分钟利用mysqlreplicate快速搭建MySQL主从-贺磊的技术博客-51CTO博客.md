# 1分钟利用mysqlreplicate快速搭建MySQL主从-贺磊的技术博客-51CTO博客

[贺磊的技术博客](http://blog.51cto.com/suifu) _>_
[MySQL](http://blog.51cto.com/suifu/category7.html) _>_ 正文

# 1分钟利用mysqlreplicate快速搭建MySQL主从 __推荐

原创 [dbapower](http://blog.51cto.com/suifu) 2016-12-01 13:41:01
[评论(7)](http://blog.51cto.com/suifu/1878443#comment) 1519人阅读

  
[](http://s3.51cto.com/wyfs02/M02/8A/ED/wKioL1g_tGyxSl_9AAA4eVx2Dz8754.jpg)

## 利用mysqlreplicate快速搭建MySQL主从环境

### 简介

mysql-
utilities工具集是一个集中了多种工具的合集，可以理解为是DBA的工具箱，本文介绍利用其中的mysqlreplicate工具来快速搭建MySQL主从环境。

  

HE1:192.168.1.248 slave

HE3:192.168.1.250 master

  

  

### 实战

 **Part1:** **安装mysql-utilities**

[root@HE1 ~]# tar xvf mysql-utilities-1.5.4.tar.gz

[root@HE1 ~]# cd mysql-utilities-1.5.4

[root@HE1 mysql-utilities-1.5.4]# python setup.py build

[root@HE1 mysql-utilities-1.5.4]# python setup.py install

  

如何安装MySQL可参考

MySQL5.6生产库自动化安装部署

<http://suifu.blog.51cto.com/9167728/1846671>

1分钟完成MySQL5.7安装部署

<http://suifu.blog.51cto.com/9167728/1855415>

  

**Part2:** **基本使用方式**

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

|

`[root@HE1 ~]``# mysqlreplicate --help`

`MySQL Utilities mysqlreplicate version 1.5.4 `

`License ``type``: GPLv2`

`Usage: mysqlreplicate --master=root@localhost:3306
--slave=root@localhost:3310 --rpl-user=rpl:``passwd`

`mysqlreplicate - establish replication with a master`

`Options:`

` ``--version show program's version number and ``exit`

` ``--help display a help message and ``exit`

` ``--license display program's license and ``exit`

` ``--master=MASTER connection information ``for` `master server ``in` `the
form:`

` ``<user>[:<password>]@<host>[:<port>][:<socket>] or`

` ``<login-path>[:<port>][:<socket>] or <config-`

` ``path>[<[group]>].`

` ``--slave=SLAVE connection information ``for` `slave server ``in` `the
form:`

` ``<user>[:<password>]@<host>[:<port>][:<socket>] or`

` ``<login-path>[:<port>][:<socket>] or <config-`

` ``path>[<[group]>].`

` ``--rpl-user=RPL_USER the user and password ``for` `the replication user`

` ``requirement, ``in` `the form: <user>[:<password>] or`

` ``<login-path>. E.g. rpl:``passwd`

` ``-p, --pedantic fail ``if` `storage engines differ among master and slave.`

` ``--``test``-db=TEST_DB database name to use ``in` `testing replication
setup`

` ``(optional)`

` ``--master-log-``file``=MASTER_LOG_FILE`

` ``use this master log ``file` `to initiate the slave.`

` ``--master-log-pos=MASTER_LOG_POS`

` ``use this position ``in` `the master log ``file` `to initiate`

` ``the slave.`

` ``-b, --start-from-beginning`

` ``start replication from the first event recorded ``in` `the`

` ``binary logging of the master. Not valid with --master-`

` ``log-``file` `or --master-log-pos.`

` ``--ssl-ca=SSL_CA The path to a ``file` `that contains a list of trusted
SSL`

` ``CAs.`

` ``--ssl-cert=SSL_CERT The name of the SSL certificate ``file` `to use ``for`

` ``establishing a secure connection.`

` ``--ssl-key=SSL_KEY The name of the SSL key ``file` `to use ``for`
`establishing a`

` ``secure connection.`

` ``--ssl=SSL Specifies ``if` `the server connection requires use of`

` ``SSL. If an encrypted connection cannot be established,`

` ``the connection attempt fails. By default 0 (SSL not`

` ``required).`

` ``-``v``, --verbose control how much information is displayed. e.g., -``v`
`=`

` ``verbose, -vv = ``more` `verbose, -vvv = debug`

` ``-q, --quiet turn off all messages ``for` `quiet execution.`  
  
---|---  
  
  

  

 **Part3:** **主库准备**

主库创建复制用户  

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

`[root@HE3 ~]``# mysql -uroot -p`

`Enter password: `

`Welcome to the MySQL monitor. Commands end with ; or \g.`

`Your MySQL connection ``id` `is 23329`

`Server version: 5.7.16-log MySQL Community Server (GPL)`

`Copyright (c) 2000, 2016, Oracle and``/or` `its affiliates. All rights
reserved.`

`Oracle is a registered trademark of Oracle Corporation and``/or` `its`

`affiliates. Other names may be trademarks of their respective`

`owners.`

`Type ``'help;'` `or ``'\h'` `for` `help. Type ``'\c'` `to ``clear` `the
current input statement.`

`mysql> grant replication client,replication slave on *.* to
``'mysync'``@``'%'` `identified by ``'MANAGER'``;`

`Query OK, 0 rows affected, 1 warning (0.01 sec)`

`mysql> flush privileges;`

`Query OK, 0 rows affected (0.01 sec)`  
  
---|---  
  
  

  

 **Part4:** **一** **键配置**

1

2

3

4

5

6

7

8

|

`从库进行配置主从执行如下命令`

`[root@HE1 ~]``# mysqlreplicate --master=sys_admin:MANAGER@192.168.1.250:3306
--slave=sys_admin:MANAGER@192.168.1.248:3306 --rpl-user=mysync:MANAGER -b`

`WARNING: Using a password on the ``command` `line interface can be insecure.`

`# master on 192.168.1.250: ... connected.`

`# slave on 192.168.1.248: ... connected.`

`# Checking for binary logging on master...`

`# Setting up replication...`

`# ...done.`  
  
---|---  
  
  

  

### 检查

 **Part1:** **mysqlrplcheck检查**

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

55

56

57

58

59

60

61

62

63

64

65

66

67

68

69

70

71

72

73

74

75

76

77

78

79

|

`[root@HE1 ~]``# mysqlrplcheck --master=sys_admin:MANAGER@192.168.1.250:3306
--slave=sys_admin:MANAGER@192.168.1.248:3306 -s`

`WARNING: Using a password on the ``command` `line interface can be insecure.`

`# master on 192.168.1.250: ... connected.`

`# slave on 192.168.1.248: ... connected.`

`Test Description Status`

`---------------------------------------------------------------------------`

`Checking ``for` `binary logging on master [pass]`

`Are there binlog exceptions? [pass]`

`Replication user exists? [pass]`

`Checking server_id values [pass]`

`Checking server_uuid values [pass]`

`Is slave connected to master? [pass]`

`Check master information ``file` `[pass]`

`Checking InnoDB compatibility [pass]`

`Checking storage engines compatibility [pass]`

`Checking lower_case_table_names settings [pass]`

`Checking slave delay (seconds behind master) [pass]`

`#`

`# Slave status: `

`#`

` ``Slave_IO_State : Waiting ``for` `master to send event`

` ``Master_Host : 192.168.1.250`

` ``Master_User : mysync`

` ``Master_Port : 3306`

` ``Connect_Retry : 60`

` ``Master_Log_File : mysql-bin.000003`

` ``Read_Master_Log_Pos : 384741`

` ``Relay_Log_File : HE1-relay-bin.000004`

` ``Relay_Log_Pos : 384954`

` ``Relay_Master_Log_File : mysql-bin.000003`

` ``Slave_IO_Running : Yes`

` ``Slave_SQL_Running : Yes`

` ``Replicate_Do_DB : `

` ``Replicate_Ignore_DB : `

` ``Replicate_Do_Table : `

` ``Replicate_Ignore_Table : `

` ``Replicate_Wild_Do_Table : `

` ``Replicate_Wild_Ignore_Table : `

` ``Last_Errno : 0`

` ``Last_Error : `

` ``Skip_Counter : 0`

` ``Exec_Master_Log_Pos : 384741`

` ``Relay_Log_Space : 1743112`

` ``Until_Condition : None`

` ``Until_Log_File : `

` ``Until_Log_Pos : 0`

` ``Master_SSL_Allowed : No`

` ``Master_SSL_CA_File : `

` ``Master_SSL_CA_Path : `

` ``Master_SSL_Cert : `

` ``Master_SSL_Cipher : `

` ``Master_SSL_Key : `

` ``Seconds_Behind_Master : 0`

` ``Master_SSL_Verify_Server_Cert : No`

` ``Last_IO_Errno : 0`

` ``Last_IO_Error : `

` ``Last_SQL_Errno : 0`

` ``Last_SQL_Error : `

` ``Replicate_Ignore_Server_Ids : `

` ``Master_Server_Id : 1250`

` ``Master_UUID : 1b1daad8-b501-11e6-aa21-000c29c6361d`

` ``Master_Info_File : ``/data/mysql/master``.info`

` ``SQL_Delay : 0`

` ``SQL_Remaining_Delay : None`

` ``Slave_SQL_Running_State : Slave has ``read` `all relay log; waiting ``for`
`more` `updates`

` ``Master_Retry_Count : 86400`

` ``Master_Bind : `

` ``Last_IO_Error_Timestamp : `

` ``Last_SQL_Error_Timestamp : `

` ``Master_SSL_Crl : `

` ``Master_SSL_Crlpath : `

` ``Retrieved_Gtid_Set : `

` ``Executed_Gtid_Set : `

` ``Auto_Position : 0`

` ``Replicate_Rewrite_DB : `

` ``Channel_Name : `

` ``Master_TLS_Version : `

`# ...done.`  
  
---|---  
  
  

  

  

 ****

### 其他常用工具

 **** **Part1:** **mysqldiskusage检查数据库空间大小**

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

`[root@HE1 ~]``# mysqldiskusage --server=sys_admin:MANAGER@localhost`

`WARNING: Using a password on the ``command` `line interface can be insecure.`

`# Source on localhost: ... connected.`

`# Database totals:`

`+---------------------+--------------+`

`| db_name | total |`

`+---------------------+--------------+`

`| maxscale_schema | 14,906 |`

`| mysql | 14,250,013 |`

`| performance_schema | 818,071 |`

`| sys | 500,802 |`

`| wms | 925,929,868 |`

`+---------------------+--------------+`

`Total database disk usage = 941,513,660 bytes or 897.90 MB`

`#...done.`  
  
---|---  
  
  

  

 **Part2:** **mysqlindexcheck检查冗余索引**

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

|

`[root@HE1 ~]``# mysqlindexcheck --server=sys_admin:MANAGER@localhost wms`

`WARNING: Using a password on the ``command` `line interface can be insecure.`

`# Source on localhost: ... connected.`

`# The following index is a duplicate or redundant for table wms.auth_user:`

`#`

`CREATE UNIQUE INDEX `index_user_name` ON `wms`.`auth_user` (`user_name`)
USING BTREE`

`# may be redundant or duplicate of:`

`CREATE INDEX `user_name` ON `wms`.`auth_user` (`user_name`, `state`) USING
BTREE`

`# The following index is a duplicate or redundant for table
wms.basic_storeage_sapce:`

`#`

`CREATE INDEX `idx_store_district_space_no` ON `wms`.`basic_storeage_sapce`
(`store_id`, `district_id`, `store_space_no`) USING BTREE`

`# may be redundant or duplicate of:`

`CREATE UNIQUE INDEX `idx_store_district_space_no_un` ON
`wms`.`basic_storeage_sapce` (`store_id`, `district_id`, `store_space_no`)
USING BTREE`  
  
---|---  
  
 **  
**

 **  
**

 **  
**

 **—— 总结** **——**

 **可以看到利用mysql-
utilities工具集中的mysqlreplicate来配置MySQL主从非常简单，mysqlreplicate也提供了各类参数，本文中**
**的-b是指使复制从主二进制日志中的第一个** **事件开始。mysqlrplcheck 中的-s是指输出show slave
status\G的内容。由于笔** **者的水平有限，编写时间也很仓促，文中难免会出现一些错误或者不准确的地方，不妥之处恳请读者批评指正。**

  

版权声明：原创作品，如需转载，请注明出处。否则将追究法律责任

[mysql](http://blog.51cto.com/search/result?q=mysql)
[replicate](http://blog.51cto.com/search/result?q=replicate)

11

分享

收藏

[上一篇：51CTO WOT2016大数据峰会有感](http://blog.51cto.com/suifu/1877183 "51CTO
WOT2016大数据峰会有感") [下一篇：MaxScale Binlog
Server实践](http://blog.51cto.com/suifu/1878847 "MaxScale Binlog Server实践")


---
### ATTACHMENTS
[8907af9baa0bca79b4f0a3ca745df19b]: media/wKioL1g_tGyxSl_9AAA4eVx2Dz8754.jpg
[wKioL1g_tGyxSl_9AAA4eVx2Dz8754.jpg](media/wKioL1g_tGyxSl_9AAA4eVx2Dz8754.jpg)
>hash: 8907af9baa0bca79b4f0a3ca745df19b  
>source-url: http://s3.51cto.com/wyfs02/M02/8A/ED/wKioL1g_tGyxSl_9AAA4eVx2Dz8754.jpg  
>timestamp: 20160930T100329Z  
>file-name: wKioL1g_tGyxSl_9AAA4eVx2Dz8754.jpg  

---
### NOTE ATTRIBUTES
>Created Date: 2018-04-13 08:52:13  
>Last Evernote Update Date: 2018-10-01 15:35:37  
>source: web.clip7  
>source-url: http://blog.51cto.com/suifu/1878443  
>source-application: WebClipper 7  