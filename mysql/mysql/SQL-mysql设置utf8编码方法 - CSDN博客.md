# SQL-mysql设置utf8编码方法 - CSDN博客

  

# SQL-mysql设置utf8编码方法

原创 2015年09月04日 09:44:31

标签：

[SQL](http://so.csdn.net/so/search/s.do?q=SQL&t=blog) /

[mysql](http://so.csdn.net/so/search/s.do?q=mysql&t=blog) /

[设置utf8编码](http://so.csdn.net/so/search/s.do?q=%E8%AE%BE%E7%BD%AEutf8%E7%BC%96%E7%A0%81&t=blog)
/

[方法](http://so.csdn.net/so/search/s.do?q=%E6%96%B9%E6%B3%95&t=blog)

.

.

mysql> SHOW VARIABLES LIKE 'character_set_%';

+--------------------------+----------------------------+

| Variable_name | Value |

+--------------------------+----------------------------+

| character_set_client | latin1 |

| character_set_connection | latin1 |

| character_set_database | latin1 |

| character_set_results | latin1 |

| character_set_server | latin1 |

| character_set_system | utf8 |

| character_sets_dir | /usr/share/mysql/charsets/ |

+--------------------------+----------------------------+

7 rows in set (0.00 sec)

  

  

mysql> SHOW VARIABLES LIKE 'collation_%';

+----------------------+-------------------+

| Variable_name | Value |

+----------------------+-------------------+

| collation_connection | latin1_swedish_ci |

| collation_database | latin1_swedish_ci |

| collation_server | latin1_swedish_ci |

+----------------------+-------------------+

3 rows in set (0.00 sec)

默认就是瑞典latin1,一下是换成我们自己的编码，如utf8:

外部访问数据乱码的问题就出在这个connection连接层上,解决方法是在发送查询前执行一下下面这句：

  

  

1\. SET NAMES 'utf8';

  

  

它相当于下面的三句指令：

SET character_set_client = utf8;

SET character_set_results = utf8;

SET character_set_connection = utf8;

  

  

一般只有在访问之前执行这个代码就解决问题了，下面是创建数据库和数据表的，设置为我们自己的编码格式。

2\. 创建数据库

mysql> create database name character set utf8;

  

  

3\. 创建表

CREATE TABLE `type` (

`id` int(10) unsigned NOT NULL auto_increment,

`flag_deleted` enum('Y','N') character set utf8 NOT NULL default 'N',

`flag_type` int(5) NOT NULL default '0',

`type_name` varchar(50) character set utf8 NOT NULL default '',

PRIMARY KEY (`id`)

) DEFAULT CHARSET=utf8;

  

  

4\. 修改数据库成utf8的.

mysql> alter database name character set utf8;

  

  

5\. 修改表默认用utf8.

mysql> alter table type character set utf8;

  

  

6\. 修改字段用utf8

mysql> alter table type modify type_name varchar(50) CHARACTER SET utf8;

===================================================================

  

  

  

设置步骤：

  

  

一、编辑MySql的配置文件

MySql的配置文件Windows下一般在系统目录下或者在MySql的安装目录下名字叫my.ini，可以搜索，Linux下一般是 /etc/my.cnf

  

  

\--在 [mysqld] 标签下加上三行

character_set_server = utf8

lower_case_table_names = 1 //表名不区分大小写（此与编码无关）

  

  

\--在 [mysql] 标签下加上一行

default-character-set = utf8

  

  

\--在 [mysql.server]标签下加上一行

default-character-set = utf8

  

  

\--在 [mysqld_safe]标签下加上一行

default-character-set = utf8

  

  

\--在 [client]标签下加上一行

default-character-set = utf8

  

  

  

二、重新启动MySql服务

Windows可在服务管理器中操作，也可使用命令行：

net stop mysql 回车

net start mysql 回车

服务名可能不一定为mysql，请按自己的设置

  

  

Linux下面可是用 service mysql restart

  

  

如果出现启动失败，请检查配置文件有没有设置错误

  

  

  

  

三、查看设置结果

登录MySql命令行客户端：打开命令行

mysql –uroot –p 回车

输入密码

进入mysql后 执行 ：show variables like "%char%";

显示结果应该类似如下：

  

  

| character_set_client | utf8 |

| character_set_connection | utf8 |

| character_set_database | utf8 |

| character_set_results | utf8 |

| character_set_server | utf8 |

| character_set_system | utf8 |

| character_sets_dir | /usr/share/mysql/charsets/ |

  

  

如果仍有编码不是utf8的，请检查配置文件，也可使用mysql命令设置：

set character_set_client = utf8;

set character_set_server = utf8;

set character_set_connection = utf8;

set character_set_database = utf8;

set character_set_results = utf8;

set collation_connection = utf8_general_ci;

set collation_database = utf8_general_ci;

set collation_server = utf8_general_ci;

以上命令有部分只对当前登录有效，所以不是很管用。

  

  

四、建库导入数据

导入sql脚本文件前，先确保该脚本文件及内容格式为UTF-8编码格式，

同以上方法登入mysql命令行，use 库名 进入相应数据库

set names utf8;

source sql脚本文件名;

  

  

五、程序连接字符串（此项与mysql设置无关，为程序开发使用）

对于较老的jdbc版本的驱动，连接字符创可使用一下相似格式：

jdbc:mysql://127.0.1:3306/test?useUnicode=true&characterEncoding=utf-8

  

  

  

  

六、附录

如果无法更改数据库配置文件，可以采取一下方法(不保证全部有效)：

1、建数据库时设置数据库编码为utf-8

例如 create database `test` default character set utf8;

  

  

  

  

2、导入数据库sql的时候，请确保sql文件为utf-8编码

进入mysql命令行后 输入 set names utf8;

再进入数据库 use test;

在导入sql脚本 source test.sql;

  

  

  



---
### TAGS
{character set}

---
### NOTE ATTRIBUTES
>Created Date: 2018-02-27 03:00:41  
>Last Evernote Update Date: 2018-02-27 03:12:53  
>author: YangKwong  
>source: web.clip  
>source-url: http://blog.csdn.net/u014657752/article/details/48206885  