# Mysql常用命令

  

1、连接到本机上的MYSQL。

首先打开DOS窗口，然后进入目录mysql\bin，再键入命令

mysql -u root -p

回车后提示你输密码.注意用户名前可以有空格也可以没有空格，但是密码前必须没有空格，否则让你重新输入密码.

如果刚安装好MYSQL，超级用户root是没有密码的，故直接回车即可进入到MYSQL中了，MYSQL的提示符是： mysql>

  

2、连接到远程主机上的MYSQL。假设远程主机的IP为：110.110.110.110，用户名为root,密码为abcd123。则键入以下命令：

mysql -h110.110.110.110 -u root -p 123

注:u与root之间可以不用加空格，其它也一样

  

3、退出MYSQL命令： exit （回车）

  

4、修改密码。

格式：mysqladmin -u用户名 -p旧密码 password 新密码

给root加个密码ab12。首先在DOS下进入目录mysql\bin，然后键入以下命令

mysqladmin -u root -password ab12

注：因为开始时root没有密码，所以-p旧密码一项就可以省略了。

  

5、再将root的密码改为djg345。

mysqladmin -u root -p ab12 password djg345

  

6、显示当前数据库服务器中的数据库列表：

mysql> SHOW DATABASES;

mysql> SHOW SHCHEMAS;

注意：mysql库里面有MYSQL的系统信息，我们改密码和新增用户，实际上就是用这个库进行操作。

  

7、显示数据库中的数据表：

mysql> USE 库名；

mysql> SHOW TABLES;

mysql>SHOW TABLES FROM 库名

s

8、显示数据表的结构：

mysql> DESCRIBE 表名;

  

9、显示use的数据库名：

mysql> SELECT DATABASE();

  

10、显示当前的user：

mysql> SELECT USER();

  

11、查看服务器版本和当前日期

 mysql>select version()、current_date;

 mysql>select version();

 mysql>select now();

  

12、把mysql作为一个简单的计算器

 mysql>select pi();

 mysql>select pi()*10;

  

13、显示表格状态

Mysql>SHOW TABLE STATUS;

  

15、显示创建表:

mysql> show create table quote;

  

16、显示用户权限:

mysql> SHOW GRANTS FOR 'test'@'localhost';

mysql>SHOW GRANTS;

mysql>SHOW GRANTS FOR CURRENT_USER;  mysql>SHOW GRANTS FOR CURRENT_USER();

  

17、显示index:

mysql>SHOW INDEX FROM mydb.mytable;

  

18、显示函数

mysql>Select * from mysql.func;

  

19、显示存储过程

mysql>Select * from mysql.proc;

  

20、显示存储引擎

mysql> SHOW ENGINES;

  

21、显示变量:

mysql>SHOW VARIABLES;

  

22、显示状态:

Mysql> SHOW STATUS;

  

23、显示进程

Mysql>SHOW PROCESSLIST

24、显示INNODB 状态

Mysql>SHOW INNODB STATUS

  

25、显示连接状态

Mysql>SHOW STATUS LIKE '%CONNECT%';

  

26、显示线程状态

Mysql>SHOW STATUS LIKE '%THREAD%';

  

Mysql安装目录

数据库目录

/var/lib/mysql/

配置文件

/usr/share/mysql（mysql.server命令及配置文件）

相关命令

/usr/bin(mysqladmin mysqldump等命令)

启动脚本

/etc/init.d/mysql（启动脚本文件mysql的目录）

系统管理

连接MySQL

格式: mysql -h 主机地址 -u用户名 -p用户密码

例 1:连接到本机上的 MySQL。

hadoop@ubuntu:~$ mysql -uroot -pmysql;

  

例 2:连接到远程主机上的 MYSQL。

hadoop@ubuntu:~$ mysql -h 127.0.0.1 -uroot -pmysql;

  

修改新密码

在终端输入：mysql -u用户名 -p密码，回车进入Mysql。

> use mysql;

> update user set password=PASSWORD('新密码') where user='用户名';

> flush privileges; #更新权限

> quit; #退出

增加新用户

格式:grant select on 数据库.* to 用户名@登录主机 identified by '密码'

举例:

例 1:增加一个用户 test1 密码为 abc,让他可以在任何主机上登录,并对所有数据库有

查询、插入、修改、删除的权限。首先用以 root 用户连入 MySQL,然后键入以下命令:

mysql>grant select,insert,update,delete on *.* to root@localhost identified by
'mysql';

或者

grant all privileges on *.* to root@localhost identified by 'mysql';

然后刷新权限设置。

flush privileges;

  

例 2:如果你不想 root 有密码操作数据库“mydb”里的数据表,可以再打一个命令将密码消掉。

grant select,insert,update,delete on mydb.* to root@localhost identified by
'';

  

删除用户

hadoop@ubuntu:~$ mysql -u用户名 -p密码

mysql>delete from user where user='用户名' and host='localhost';

mysql>flush privileges;

//删除用户的数据库

mysql>drop database dbname;

  

数据库操作

显示所有的数据库

mysql> show databases;(注意:最后有个 s)

  

创建数据库

mysql> create database test;

  

连接数据库

mysql> use test;

  

查看当前使用的数据库

mysql> select database();

  

当前数据库包含的表信息

mysql> show tables; (注意:最后有个 s)

  

删除数据库

mysql> drop database test;

  

表操作

备注:操作之前使用“use <数据库名>”应连接某个数据库。

建表

命令:create table <表名> (<字段名 1> <类型 1> [,..<字段名 n> <类型 n>]);

例子：

mysql> create table MyClass(

> id int(4) not null primary key auto_increment,

> name char(20) not null,

> sex int(4) not null default '0',

> degree double(16,2));

  

获取表结构

命令: desc 表名，或者show columns from 表名

例子：

mysql> describe MyClass

mysql> desc MyClass;

mysql> show columns from MyClass;

  

删除表

命令:drop table <表名>

例如:删除表名为 MyClass 的表

mysql> drop table MyClass;

  

插入数据

命令:insert into <表名> [( <字段名 1>[,..<字段名 n > ])] values ( 值 1 )[, ( 值 n )]

例子：

mysql> insert into MyClass values(1,'Tom',96.45),(2,'Joan',82.99), (2,'Wang',
96.59);

  

查询表中的数据

查询所有行

mysql> select * from MyClass;

  

查询前几行数据

例如:查看表 MyClass 中前 2 行数据

mysql> select * from MyClass order by id limit 0,2;

或者

mysql> select * from MyClass limit 0,2;

  

删除表中数据

命令:delete from 表名 where 表达式

例如:删除表 MyClass 中编号为 1 的记录

mysql> delete from MyClass where id=1;

  

修改表中数据

命令:update 表名 set 字段=新值,... where 条件

mysql> update MyClass set name='Mary' where id=1;

  

在表中增加字段

命令:alter table 表名 add 字段 类型 其他;

例如:在表 MyClass 中添加了一个字段 passtest,类型为 int(4),默认值为 0

mysql> alter table MyClass add passtest int(4) default '0'

  

更改表名

命令:rename table 原表名 to 新表名;

例如:在表 MyClass 名字更改为 YouClass

mysql> rename table MyClass to YouClass;

  

更新字段内容

命令:update 表名 set 字段名 = 新内容

update 表名 set 字段名 = replace(字段名, '旧内容', '新内容');

例如:文章前面加入 4 个空格

update article set content=concat('    ', content);

  

数据库导入导出

从数据库导出数据库文件

使用“mysqldump”命令

首先进入 DOS 界面,然后进行下面操作。

1)导出所有数据库

格式:mysqldump -u [数据库用户名] -p -A>[备份文件的保存路径]

  

2)导出数据和数据结构

格式:mysqldump -u [数据库用户名] -p [要备份的数据库名称]>[备份文件的保存路径]

举例:

例 1:将数据库 mydb 导出到 e:\MySQL\mydb.sql 文件中。

打开开始->运行->输入“cmd”,进入命令行模式。

c:\> mysqldump -h localhost -u root -p mydb >e:\MySQL\mydb.sql

然后输入密码,等待一会导出就成功了,可以到目标文件中检查是否成功。

  

例 2:将数据库 mydb 中的 mytable 导出到 e:\MySQL\mytable.sql 文件中。

c:\> mysqldump -h localhost -u root -p mydb mytable>e:\MySQL\mytable.sql

  

例 3:将数据库 mydb 的结构导出到 e:\MySQL\mydb_stru.sql 文件中。

c:\> mysqldump -h localhost -u root -p mydb --add-drop-table
>e:\MySQL\mydb_stru.sql

备注:-h localhost 可以省略,其一般在虚拟主机上用。

  

3)只导出数据不导出数据结构

格式:

mysqldump -u [数据库用户名] -p -t [要备份的数据库名称]>[备份文件的保存路径]

  

4)导出数据库中的Events

格式:mysqldump -u [数据库用户名] -p -E [数据库用户名]>[备份文件的保存路径]

  

5)导出数据库中的存储过程和函数

格式:mysqldump -u [数据库用户名] -p -R [数据库用户名]>[备份文件的保存路径]

  

从外部文件导入数据库中

1)使用“source”命令

首先进入“mysql”命令控制台,然后创建数据库,然后使用该数据库。最后执行下面操作。

mysql>source [备份文件的保存路径]

  

2)使用“<”符号

首先进入“mysql”命令控制台,然后创建数据库,然后退出 MySQL,进入 DOS 界面。最后执行下面操作。

mysql -u root –p < [备份文件的保存路径]


---
### NOTE ATTRIBUTES
>Created Date: 2015-02-27 01:28:42  
>Last Evernote Update Date: 2016-06-08 08:58:23  
>source-url: http://www.jb51.net/article/18667.htm  