# MySQL整理

###MySQL连接数

(root@localhost) [(none)]> show variables like '%max_connections%';

+-----------------+-------+

| Variable_name   | Value |

+-----------------+-------+

| max_connections | 800   |

+-----------------+-------+

1 row in set (0.00 sec)

  

###看你的mysql现在已提供什么存储引擎:

mysql> show engines;

  

###MySQL数据库查看、创建、删除

show databases;

  

drop database name;

  

create database name;

  

use name;

  

root@mysql 14:01:  [(none)]> show create database mytest;

+----------+--------------------------------------------------------------------+

| Database | Create Database
|

+----------+--------------------------------------------------------------------+

| mytest   | CREATE DATABASE `mytest` /*!40100 DEFAULT CHARACTER SET utf8mb4
*/ |

+----------+--------------------------------------------------------------------+

1 row in set (0.37 sec)

  

###MySQL查看表结构

describe mysql.user;

  

desc mysql.user;

  

###看你的mysql当前默认的存储引擎:

mysql> show variables like '%storage_engine%';

  

msyql>show engines

  

 ###你要看某个表用了什么引擎(在显示结果里参数engine后面的就表示该表当前用的存储引擎):

mysql> show create table 表名;

  

###查看MySQL连接超时

mysql> SHOW GLOBAL VARIABLES LIKE '%TIMEOUT';  

+-----------------------------+----------+

| Variable_name               | Value    |

+-----------------------------+----------+

| connect_timeout             | 10       |

| delayed_insert_timeout      | 300      |

| have_statement_timeout      | YES      |

| innodb_flush_log_at_timeout | 1        |

| innodb_lock_wait_timeout    | 50       |

| innodb_rollback_on_timeout  | OFF      |

| interactive_timeout         | 28800    |

| lock_wait_timeout           | 31536000 |

| net_read_timeout            | 30       |

| net_write_timeout           | 60       |

| rpl_stop_slave_timeout      | 31536000 |

| slave_net_timeout           | 60       |

|c               | 28800    |

+-----------------------------+----------+

13 rows in set (0.01 sec)

  

###查看MySQL运行多长时间

mysql> show global status like 'UPTIME';

+---------------+-------+

| Variable_name | Value |

+---------------+-------+

| Uptime        | 1030  |

+---------------+-------+

1 row in set (0.00 sec)

  

查看mysql请求链接进程被主动杀死

mysql> SHOW GLOBAL STATUS LIKE 'COM_KILL';  

+---------------+-------+

| Variable_name | Value |

+---------------+-------+

| Com_kill      | 0     |

+---------------+-------+

1 row in set (0.01 sec)

  

查看MySQL通信信息包最大值

mysql> SHOW GLOBAL VARIABLES LIKE 'MAX_ALLOWED_PACKET';

+--------------------+---------+

| Variable_name      | Value   |

+--------------------+---------+

| max_allowed_packet | 4194304 |

+--------------------+---------+

1 row in set (0.00 sec)

  

###如下脚本创建数据库yourdbname，并制定默认的字符集是utf8

CREATE DATABASE IF NOT EXISTS yourdbname DEFAULT CHARSET utf8 COLLATE
utf8_general_ci;

  

###如果要创建默认gbk字符集的数据库可以用下面的sql

create database yourdb DEFAULT CHARACTER SET gbk COLLATE gbk_chinese_ci;

  

###权限

show grants for 'root'@'localhost';

  

show privileges

  

###mysql常用参数

mysql --help

  

###create user和赋权、修改密码

create user 'root'@'%' identified by 'oracle';

  

GRANT ALL PRIVILEGES ON *.* TO 'root'@'%'  WITH GRANT OPTION;

GRANT ALL PRIVILEGES ON *.* TO 'root'@'*.mysql.com'  WITH GRANT OPTION;

GRANT ALL PRIVILEGES ON *.* TO 'root'@'192.168.45.0/255.255.255.0'  WITH GRANT
OPTION;

  

drop user 'root'@'192.168.45.52';

  

rename user  'system'@'192.168.45.52' to 'test'@'192.168.45.52';

  

set password for 'sys'@'192.168.45.52' = password('oracle');

set password = "oracle";       ###mysql5.7写法

  

###mysql字符集

root@mysql 14:00:  [(none)]> show variables like '%char%';

+--------------------------+----------------------------------------------------------------+

| Variable_name            | Value
|

+--------------------------+----------------------------------------------------------------+

| character_set_client     | utf8
|

| character_set_connection | utf8
|

| character_set_database   | utf8mb4
|

| character_set_filesystem | binary
|

| character_set_results    | utf8
|

| character_set_server     | utf8mb4
|

| character_set_system     | utf8
|

| character_sets_dir       | /usr/local/mysql-5.7.21-linux-
glibc2.12-x86_64/share/charsets/ |

+--------------------------+----------------------------------------------------------------+

8 rows in set (0.00 sec)

  

###mysql dual表

MySQL:

mysql> select 4*4 from dual;

+-----+

| 4*4 |

+-----+  

|  16 |

+-----+

1 row in set (0.07 sec)

  

mysql> select 4*4;

+-----+

| 4*4 |

+-----+

|  16 |

+-----+

1 row in set (0.00 sec)

  

mysql> select * from dual;  

ERROR 1096 (HY000): No tables used

  

Oracle:

sys@ORCL> select * from dual;

  

D

-

X

  

sys@ORCL> select 4*4;

select 4*4

         *

ERROR at line 1:

ORA-00923: FROM keyword not found where expected

  

  

sys@ORCL> select 4*4 from dual;

  

       4*4

\----------

  

###mysql快捷键

ctrl + l      ###清屏快捷键

  

###create、alter、drop  

alter table test rename test1;

  

alter table test1 add email varchar(100);

  

alter table test1 drop email;

alter table test1 drop column email;

  

alter table test1 modify email varchar(80);

  

alter table test1 change email link varchar(100);

  

insert into test1 values(13,'2018-02-27',NULL);

insert into test1(student_id,date) values(23,'2018-02-27');

  

select distinct event_id from score;

  

show create database sampdb;

  

show character set;

  

alter database sampdb character set utf8 collate utf8_general_ci;

  

show variables like 'character_set%';

show variables like 'collation%';

  

/etc/init.d/mysqld stop

  

mysqladmin -uroot -p shutdown

  

netstat -lntup|grep mysql

  

ps -elf|grep -v grep|grep mysql

  

  

histroy -c

history -d 2

\--不记录敏感命令

HIStCONTROL=ignorespace

  

prompt \u@centos \r:\m:\s->

  

help contents

  

  1. Option  Description  

  2.   

  3. \c  A counter that increments for each statement you issue  

  4. \D  The full current date  

  5. \d  The default database  

  6. \h  The server host  

  7. \l  The current delimiter (new in 5.0.25)  

  8. \m  Minutes of the current time  

  9. \n  A newline character  

  10. \O  The current month in three-letter format (Jan, Feb, …)  

  11. \o  The current month in numeric format  

  12. \P  am/pm  

  13. \p  The current TCP/IP port or socket file  

  14. \R  The current time, in 24-hour military time (0–23)  

  15. \r  The current time, standard 12-hour time (1–12)  

  16. \S  Semicolon  

  17. \s  Seconds of the current time  

  18. \t  A tab character  

  19. \U    

  20. Your full user_name@host_name account name  

  21.    

  22. \u  Your user name  

  23. \v  The server version  

  24. \w  The current day of the week in three-letter format (Mon, Tue, …)  

  25. \Y  The current year, four digits  

  26. \y  The current year, two digits  

  27. \\_  A space  

  28. \   A space (a space follows the backslash)  

  29. \'  Single quote  

  30. \"  Double quote  

  31. \\\  A literal “\” backslash character  

  32. \x    

  33. x, for any “x” not listed above  

  

mysqladmin  -uroot -p password "oracle"  

set password for 'root'@'localhost'=password('password');

update mysql.user set authentication_string=password('galaxy') where
user='root' and host='localhost';

mysqld_safe  \--skip-grant-tables --user=mysql &
###5.7 my.cnf文件中祛除validate-password = off

  

  

mysql版本升级

软连接重建

mysql_upgrade -s     ###只升级系统表

  

mysql免密码

[root@centos ~]# mysql_config_editor remove -G mysql5.7

[root@centos ~]# mysql_config_editor print --all

[client]

host = elp

[root@centos ~]# mysql_config_editor set -G mysql5.7 -hlocalhost -uroot -p  

Enter password:

[root@centos ~]# mysql_config_editor print --all

[client]

host = elp

[mysql5.7]

user = root

password = *****

host = localhost

[root@centos ~]# mysql --help|grep login

  -u, --user=name     User for login if not current user.

                        except for login file.

\--login-path=#          Read this path from the login file.

[root@centos ~]# mysql --login-path=mysql5.7

  

###mysql查看参数

mysql> select @@session.autocommit;

+----------------------+

| @@session.autocommit |

+----------------------+

|                    0 |

+----------------------+

1 row in set (0.00 sec)

  

mysql> select @@global.autocommit;  

+---------------------+

| @@global.autocommit |

+---------------------+

|                   0 |

+---------------------+

1 row in set (0.00 sec)

  

mysql> set global autocommit = 1;

Query OK, 0 rows affected (0.00 sec)

  

mysql> select @@global.autocommit;

+---------------------+

| @@global.autocommit |

+---------------------+

|                   1 |

+---------------------+

1 row in set (0.00 sec)

  

mysql> select @@session.autocommit;

+----------------------+

| @@session.autocommit |

+----------------------+

|                    0 |

+----------------------+

1 row in set (0.00 sec)

  

mysq>set session autocommit = 1;

  

![noteattachment1][f9327280641c0dccbbbe2520e830f4c0]

  

select * from mysql.user limit 1\G

select * from mysql.db limit 1\G

select * from mysql.tables_priv limit 1\G

select * from mysql.columns_priv limit 1\G

  

show warnings;

  

mysql> show grants;

+---------------------------------------------------------------------+

| Grants for root@localhost                                           |

+---------------------------------------------------------------------+

| GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION |

| GRANT PROXY ON ''@'' TO 'root'@'localhost' WITH GRANT OPTION        |

+---------------------------------------------------------------------+

2 rows in set (0.00 sec)

  

mysql> show grants for current_user;

+---------------------------------------------------------------------+

| Grants for root@localhost                                           |

+---------------------------------------------------------------------+

| GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION |

| GRANT PROXY ON ''@'' TO 'root'@'localhost' WITH GRANT OPTION        |

+---------------------------------------------------------------------+

2 rows in set (0.00 sec)

  

mysql> show grants for current_user();

+---------------------------------------------------------------------+

| Grants for root@localhost                                           |

+---------------------------------------------------------------------+

| GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION |

| GRANT PROXY ON ''@'' TO 'root'@'localhost' WITH GRANT OPTION        |

+---------------------------------------------------------------------+

2 rows in set (0.00 sec)

  

  

[root@centos sampdb]# mysqlfrm  \--diagnostic   absence.frm

# WARNING: Cannot generate character set or collation names without the
--server option.

# CAUTION: The diagnostic mode is a best-effort parse of the .frm file. As
such, it may not identify all of the components of the table correctly. This
is especially true for damaged files. It will also not read the default values
for the columns and the resulting statement may not be syntactically correct.

# Reading .frm file for absence.frm:

# The .frm file is a TABLE.

# CREATE TABLE Statement:

  

CREATE TABLE `absence` (

  `student_id` int(10) unsigned NOT NULL,

  `date` date NOT NULL,

PRIMARY KEY `PRIMARY` (`student_id`,`date`)

) ENGINE=InnoDB;

  

#...done.

  

![noteattachment2][c65eb56246a64df6da71409074f0e85a]

  

mysqldumpslow /data/slow.log

  

Reading mysql slow query log from /data/slow.log

Count: 1  Time=0.00s (0s)  Lock=0.00s (0s)  Rows=17.0 (17),
root[root]@[192.168.45.1]

  SELECT STATE AS `Status`, ROUND(SUM(DURATION),N) AS `Duration`,
CONCAT(ROUND(SUM(DURATION)/N.N*N,N), 'S') AS `Percentage` FROM
INFORMATION_SCHEMA.PROFILING WHERE QUERY_ID=N GROUP BY SEQ, STATE ORDER BY SEQ

  

Count: 1  Time=0.00s (0s)  Lock=0.00s (0s)  Rows=0.0 (0), 0users@0hosts

  bin/mysqld, Version: N.N.N-log (MySQL Community Server (GPL)). started with:

  

\--修改slow_log表存储引擎

set global slow_query_log=0;

alter table mysql.slow_log engine = myisam;

set global slow_query_log=1;

  

mysql> select concat("oracle","mysql") from dual;

+--------------------------+

| concat("oracle","mysql") |

+--------------------------+

| oraclemysql              |

+--------------------------+

1 row in set (0.00 sec)

  

mysql> select cast(232432432 as  char) from dual;

+--------------------------+

| cast(232432432 as  char) |

+--------------------------+

| 232432432                |

+--------------------------+

1 row in set (0.00 sec)

mysql>

  

  

mysql> select now(6);  

+----------------------------+

| now(6)                     |

+----------------------------+

| 2018-03-11 17:10:53.982080 |

+----------------------------+

1 row in set (0.00 sec)

  

mysql> select now();

+---------------------+

| now()               |

+---------------------+

| 2018-03-11 17:11:45 |

+---------------------+

1 row in set (0.00 sec)

  

mysql>  select now(6);

+----------------------------+

| now(6)                     |

+----------------------------+

| 2018-03-11 17:15:00.301739 |

+----------------------------+

1 row in set (0.00 sec)

mysql>  select current_timestamp(6);

+----------------------------+

| current_timestamp(6)       |

+----------------------------+

| 2018-03-11 17:15:12.392042 |

+----------------------------+

1 row in set (0.00 sec)

  

mysql> select now(),sysdate(),sleep(2),sysdate() from dual;

+---------------------+---------------------+----------+---------------------+

| now()               | sysdate()           | sleep(2) | sysdate()           |

+---------------------+---------------------+----------+---------------------+

| 2018-03-11 17:16:12 | 2018-03-11 17:16:12 |        0 | 2018-03-11 17:16:14 |

+---------------------+---------------------+----------+---------------------+

1 row in set (2.00 sec)

  

mysql> select sysdate(6) from dual;

+----------------------------+

| sysdate(6)                 |

+----------------------------+

| 2018-03-11 17:17:04.553088 |

+----------------------------+

1 row in set (0.00 sec)

  

mysql> select now(6),sysdate(6) from dual;

+----------------------------+----------------------------+

| now(6)                     | sysdate(6)                 |

+----------------------------+----------------------------+

| 2018-03-11 17:18:08.181805 | 2018-03-11 17:18:08.181906 |

+----------------------------+----------------------------+

1 row in set (0.00 sec)

  

  

mysql> select date_add(now(),interval -7 day);

+---------------------------------+

| date_add(now(),interval -7 day) |

+---------------------------------+

| 2018-03-04 17:18:58             |

+---------------------------------+

1 row in set (0.00 sec)

  

  

CREATE TABLE t1 ( ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE
CURRENT_TIMESTAMP, dt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE
CURRENT_TIMESTAMP );

  

  

  

mysql> select @@gtid_mode;

+-------------+

| @@gtid_mode |

+-------------+

| ON          |

+-------------+

1 row in set (0.00 sec)

  

  

select emp_no,first_name,last_name from employees where emp_no = any(select
emp_no from dept_manager);

select emp_no,first_name,last_name from employees where emp_no = all(select
emp_no from dept_manager);

select emp_no,first_name,last_name from employees where emp_no in (select
emp_no from dept_manager);

  

explain select emp_no,first_name,last_name from employees where emp_no in
(select emp_no from dept_manager);\G

  

explain extended select emp_no,first_name,last_name from employees where
emp_no in (select emp_no from dept_manager)\G

  

mysql> insert into a values (2);

Query OK, 1 row affected (0.00 sec)

  

mysql> select * from a;

+------+

| a    |

+------+

|    1 |

|    2 |

+------+

2 rows in set (0.00 sec)

  

mysql> insert into a values (3);

Query OK, 1 row affected (0.10 sec)

  

mysql> insert into a values (3),(4),(5);

Query OK, 3 rows affected (0.01 sec)

Records: 3  Duplicates: 0  Warnings: 0

  

mysql> insert into a select 8;

Query OK, 1 row affected (0.00 sec)

Records: 1  Duplicates: 0  Warnings: 0

  

  

![noteattachment3][56313609b13add132c9effbf65e4f86e]

  

mysql> set @rn:=0;

Query OK, 0 rows affected (0.00 sec)

  

mysql> select @rn;

+------+

| @rn  |

+------+

|    0 |

+------+

1 row in set (0.00 sec)

  

mysql> select @rn:=@rn+1,e.* from employees e limit 10;

+------------+--------+------------+------------+-----------+--------+------------+

| @rn:=@rn+1 | emp_no | birth_date | first_name | last_name | gender |
hire_date  |

+------------+--------+------------+------------+-----------+--------+------------+

|          1 |  10001 | 1953-09-02 | Georgi     | Facello   | M      |
1986-06-26 |

|          2 |  10002 | 1964-06-02 | Bezalel    | Simmel    | F      |
1985-11-21 |

|          3 |  10003 | 1959-12-03 | Parto      | Bamford   | M      |
1986-08-28 |

|          4 |  10004 | 1954-05-01 | Chirstian  | Koblick   | M      |
1986-12-01 |

|          5 |  10005 | 1955-01-21 | Kyoichi    | Maliniak  | M      |
1989-09-12 |

|          6 |  10006 | 1953-04-20 | Anneke     | Preusig   | F      |
1989-06-02 |

|          7 |  10007 | 1957-05-23 | Tzvetan    | Zielinski | F      |
1989-02-10 |

|          8 |  10008 | 1958-02-19 | Saniya     | Kalloufi  | M      |
1994-09-15 |

|          9 |  10009 | 1952-04-19 | Sumant     | Peac      | F      |
1985-02-18 |

|         10 |  10010 | 1963-06-01 | Duangkaew  | Piveteau  | F      |
1989-08-24 |

+------------+--------+------------+------------+-----------+--------+------------+

10 rows in set (0.00 sec)

  

  

mysql> select @rn:=@rn+1,e.* from employees e,(select @rn:=0) t limit 10,5;

+------------+--------+------------+------------+-----------+--------+------------+

| @rn:=@rn+1 | emp_no | birth_date | first_name | last_name | gender |
hire_date  |

+------------+--------+------------+------------+-----------+--------+------------+

|          1 |  10011 | 1953-11-07 | Mary       | Sluis     | F      |
1990-01-22 |

|          2 |  10012 | 1960-10-04 | Patricio   | Bridgland | M      |
1992-12-18 |

|          3 |  10013 | 1963-06-07 | Eberhardt  | Terkki    | M      |
1985-10-20 |

|          4 |  10014 | 1956-02-12 | Berni      | Genin     | M      |
1987-03-11 |

|          5 |  10015 | 1959-08-19 | Guoxiang   | Nooteboom | M      |
1987-07-02 |

+------------+--------+------------+------------+-----------+--------+------------+

5 rows in set (0.00 sec)

  

mysql> select (select count(1) from employees b where b.emp_no <= a.emp_no) as
rn,  emp_no,CONCAT(last_name," ",first_name) name,gender,hire_date from
employees a limit 10,5;

+------+--------+--------------------+--------+------------+

| rn   | emp_no | name               | gender | hire_date  |

+------+--------+--------------------+--------+------------+

|   11 |  10011 | Sluis Mary         | F      | 1990-01-22 |

|   12 |  10012 | Bridgland Patricio | M      | 1992-12-18 |

|   13 |  10013 | Terkki Eberhardt   | M      | 1985-10-20 |

|   14 |  10014 | Genin Berni        | M      | 1987-03-11 |

|   15 |  10015 | Nooteboom Guoxiang | M      | 1987-07-02 |

+------+--------+--------------------+--------+------------+

5 rows in set (0.27 sec)

  

mysql>

  

###EXPLAIN/DESC JSON

mysql> desc FORMAT = JSON select * from employees where emp_no = 23344\G

*************************** 1. row ***************************

EXPLAIN: {

  "query_block": {

    "select_id": 1,

    "cost_info": {

      "query_cost": "1.00"

    },

    "table": {

      "table_name": "employees",

      "access_type": "const",

      "possible_keys": [

        "PRIMARY"

      ],

      "key": "PRIMARY",

      "used_key_parts": [

        "emp_no"

      ],

      "key_length": "4",

      "ref": [

        "const"

      ],

      "rows_examined_per_scan": 1,

      "rows_produced_per_join": 1,

      "filtered": "100.00",

      "cost_info": {

        "read_cost": "0.00",

        "eval_cost": "0.20",

        "prefix_cost": "0.00",

        "data_read_per_join": "136"

      },

      "used_columns": [

        "emp_no",

        "birth_date",

        "first_name",

        "last_name",

        "gender",

        "hire_date"

      ]

    }

  }

}

1 row in set, 1 warning (0.00 sec)

  

  

mysql> explain FORMAT = JSON select * from employees where emp_no = 23344;

+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

| EXPLAIN
|

+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

| {

  "query_block": {

    "select_id": 1,

    "cost_info": {

      "query_cost": "1.00"

    },

    "table": {

      "table_name": "employees",

      "access_type": "const",

      "possible_keys": [

        "PRIMARY"

      ],

      "key": "PRIMARY",

      "used_key_parts": [

        "emp_no"

      ],

      "key_length": "4",

      "ref": [

        "const"

      ],

      "rows_examined_per_scan": 1,

      "rows_produced_per_join": 1,

      "filtered": "100.00",

      "cost_info": {

        "read_cost": "0.00",

        "eval_cost": "0.20",

        "prefix_cost": "0.00",

        "data_read_per_join": "136"

      },

      "used_columns": [

        "emp_no",

        "birth_date",

        "first_name",

        "last_name",

        "gender",

        "hire_date"

      ]

    }

  }

} |

+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

1 row in set, 1 warning (0.00 sec)

  

  

use sys

select * from  x$schema_index_statistics limit 1 \G

  

USE information_schema;

  

SELECT

     t.TABLE_SCHEMA,t.TABLE_NAME,INDEX_NAME, CARDINALITY, TABLE_ROWS,

     CARDINALITY/TABLE_ROWS AS SELETIVITY

FROM

    TABLES t,

    STATISTICS s

WHERE

    t.table_schema = s.table_schema

        AND t.table_name = s.table_name

        AND t.table_schema = 'dbt3';

  

SELECT

     t.TABLE_SCHEMA,t.TABLE_NAME,INDEX_NAME, CARDINALITY, TABLE_ROWS, CARDINALITY/TABLE_ROWS AS SELETIVITY

FROM

    TABLES t,

    (SELECT table_schema,table_name,index_name,CARDINALITY,MAX(seq_in_index) FROM STATISTICS GROUP BY table_schema,table_name,index_name) s

WHERE

    t.table_schema = s.table_schema

        AND t.table_name = s.table_name

        AND t.table_schema = 'dbt3'

ORDER BY SELETIVITY;

  

SELECT

     t.TABLE_SCHEMA,t.TABLE_NAME,INDEX_NAME, CARDINALITY, TABLE_ROWS, CARDINALITY/TABLE_ROWS AS SELETIVITY

FROM

    TABLES t,

    (

        SELECT     

            table_schema,

            table_name,

            index_name,

            cardinality

        FROM STATISTICS

        WHERE (table_schema,table_name,index_name,seq_in_index) IN (

        SELECT

            table_schema,

            table_name,

            index_name,

            MAX(seq_in_index)

        FROM

            STATISTICS

        GROUP BY table_schema , table_name , index_name )

    ) s

WHERE

    t.table_schema = s.table_schema

        AND t.table_name = s.table_name

        AND t.table_schema = 'employees'

ORDER BY SELETIVITY;

  

  

ANALYZE TABLE employees;

  

mysql> select * from employees force index(idx_birth_date) where emp_no=10002;

+--------+------------+------------+-----------+--------+------------+

| emp_no | birth_date | first_name | last_name | gender | hire_date  |

+--------+------------+------------+-----------+--------+------------+

|  10002 | 1964-06-02 | Bezalel    | Simmel    | F      | 1985-11-21 |

+--------+------------+------------+-----------+--------+------------+

1 row in set (0.11 sec)

  

mysql> desc format=json select * from employees force index(idx_birth_date)
where emp_no=10002;

+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

| EXPLAIN
|

+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

| {

  "query_block": {

    "select_id": 1,

    "cost_info": {

      "query_cost": "358394.20"

    },

    "table": {

      "table_name": "employees",

      "access_type": "ALL",

      "rows_examined_per_scan": 298661,

      "rows_produced_per_join": 0,

      "filtered": "0.00",

      "cost_info": {

        "read_cost": "358394.00",

        "eval_cost": "0.20",

        "prefix_cost": "358394.20",

        "data_read_per_join": "135"

      },

      "used_columns": [

        "emp_no",

        "birth_date",

        "first_name",

        "last_name",

        "gender",

        "hire_date"

      ],

      "attached_condition": "(`employees`.`employees`.`emp_no` = 10002)"

    }

  }

} |

+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

1 row in set, 1 warning (0.00 sec)

  

  

creata table a(1 int) data directory='/test';

  

drop table sbtest6,sbtest7,sbtest8,sbtest9,sbtest10;

  

###soft link

  

###general tablespace

create tablespace ts1 add datafile '/test/test01.ibd' file block size=8192;

creata table a(1 int) tablespace=ts1;

  

###只创建表结构

create table test like employees;

  

mysql> select database();

+------------+

| database() |

+------------+

| sampdb     |

+------------+

1 row in set (0.00 sec)

  

  

mysql> set global innodb_cmp_per_index_enabled = 1;

Query OK, 0 rows affected (0.00 sec)

mysql> show variables like 'innodb_%index%';

+----------------------------------+-------+

| Variable_name                    | Value |

+----------------------------------+-------+

| innodb_adaptive_hash_index       | ON    |

| innodb_adaptive_hash_index_parts | 8     |

| innodb_cmp_per_index_enabled     | ON    |

+----------------------------------+-------+

3 rows in set (0.00 sec)

  

  

mysql> create table t3 (a int) compression="zlib";

Query OK, 0 rows affected (5.48 sec)

  

(root@localhost) [mytest]> show variables like '%join%buffer%';

+------------------+-----------+

| Variable_name    | Value     |

+------------------+-----------+

| join_buffer_size | 134217728 |

+------------------+-----------+

1 row in set (0.00 sec)

  

(root@localhost) [mytest]> select 134217728/1024/1024;

+---------------------+

| 134217728/1024/1024 |

+---------------------+

|        128.00000000 |

+---------------------+

1 row in set (0.00 sec)

  

(root@localhost) [employees]> set global
optimizer_switch='mrr_cost_based=off';

  

(root@localhost) [employees]> show variables like 'optimizer_switch';

+------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

| Variable_name    | Value
|

+------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

| optimizer_switch |
index_merge=on,index_merge_union=on,index_merge_sort_union=on,index_merge_intersection=on,engine_condition_pushdown=on,index_condition_pushdown=on,mrr=on,mrr_cost_based=on,block_nested_loop=on,batched_key_access=off,materialization=on,semijoin=on,loosescan=on,firstmatch=on,duplicateweedout=on,subquery_materialization_cost_based=on,use_index_extensions=on,condition_fanout_filter=on,derived_merge=on
|

+------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

1 row in set (0.00 sec)

  

  

(root@localhost) [employees]> desc salaries;

+-----------+---------+------+-----+---------+-------+

| Field     | Type    | Null | Key | Default | Extra |

+-----------+---------+------+-----+---------+-------+

| emp_no    | int(11) | NO   | PRI | NULL    |       |

| salary    | int(11) | NO   |     | NULL    |       |

| from_date | date    | NO   | PRI | NULL    |       |

| to_date   | date    | NO   |     | NULL    |       |

+-----------+---------+------+-----+---------+-------+

4 rows in set (0.00 sec)

  

(root@localhost) [employees]> explain select /*+ MRR(salaries) */ * from
salaries where salary>1000 and salary <40000\G

*************************** 1. row ***************************

           id: 1

  select_type: SIMPLE

        table: salaries

   partitions: NULL

         type: ALL

possible_keys: NULL

          key: NULL

      key_len: NULL

          ref: NULL

         rows: 2648578

     filtered: 11.11

        Extra: Using where

1 row in set, 1 warning (0.00 sec)

  

(root@localhost) [employees]> alter table salaries add index
idx_salary(salary);

Query OK, 0 rows affected (11.08 sec)

Records: 0  Duplicates: 0  Warnings: 0

  

(root@localhost) [employees]> desc salaries;  

+-----------+---------+------+-----+---------+-------+

| Field     | Type    | Null | Key | Default | Extra |

+-----------+---------+------+-----+---------+-------+

| emp_no    | int(11) | NO   | PRI | NULL    |       |

| salary    | int(11) | NO   | MUL | NULL    |       |

| from_date | date    | NO   | PRI | NULL    |       |

| to_date   | date    | NO   |     | NULL    |       |

+-----------+---------+------+-----+---------+-------+

4 rows in set (0.00 sec)

  

(root@localhost) [employees]> explain select /*+ MRR(salaries) */ * from
salaries where salary>1000 and salary <40000\G

*************************** 1. row ***************************

           id: 1

  select_type: SIMPLE

        table: salaries

   partitions: NULL

         type: range

possible_keys: idx_salary

          key: idx_salary

      key_len: 4

          ref: NULL

         rows: 23606

     filtered: 100.00

        Extra: Using index condition; Using MRR

1 row in set, 1 warning (0.00 sec)

  

(root@localhost) [employees]>

  

  

(root@localhost) [employees]> show engine innodb mutex;

+--------+-----------------------------+------------+

| Type   | Name                        | Status     |

+--------+-----------------------------+------------+

| InnoDB | rwlock: dict0dict.cc:1183   | waits=3    |

| InnoDB | rwlock: log0log.cc:838      | waits=17   |

| InnoDB | sum rwlock: buf0buf.cc:1460 | waits=1386 |

+--------+-----------------------------+------------+

3 rows in set (0.14 sec)

  

  

set  tx_isolation='read-uncommitted';

  

select @@tx_isolation

select @@transaction_isolation;

  

show processlist;

  

(root@localhost) [sys]> select @@tx_isolation;

+----------------+

| @@tx_isolation |

+----------------+

| READ-COMMITTED |

+----------------+

1 row in set, 1 warning (0.00 sec)

  

一个事务所作的修改对其他事务是不可见的，好似是串行执行的

  

(root@localhost) [mytest]> show variables like '%autoinc%';

+--------------------------+-------+

| Variable_name            | Value |

+--------------------------+-------+

| innodb_autoinc_lock_mode | 1     |

+--------------------------+-------+

1 row in set (0.00 sec)

  

(root@localhost) [(none)]> show variables like '%max_connections%';

+-----------------+-------+

| Variable_name   | Value |

+-----------------+-------+

| max_connections | 800   |

+-----------------+-------+

1 row in set (0.00 sec)

  

(root@localhost) [(none)]> show status like '%connect%';

+-----------------------------------------------+---------------------+

| Variable_name                                 | Value               |

+-----------------------------------------------+---------------------+

| Aborted_connects                              | 0                   |

| Connection_errors_accept                      | 0                   |

| Connection_errors_internal                    | 0                   |

| Connection_errors_max_connections             | 0                   |

| Connection_errors_peer_address                | 0                   |

| Connection_errors_select                      | 0                   |

| Connection_errors_tcpwrap                     | 0                   |

| Connections                                   | 3                   |

| Locked_connects                               | 0                   |

| Max_used_connections                          | 1                   |

| Max_used_connections_time                     | 2018-03-27 13:32:03 |

| Performance_schema_session_connect_attrs_lost | 0                   |

| Ssl_client_connects                           | 0                   |

| Ssl_connect_renegotiates                      | 0                   |

| Ssl_finished_connects                         | 0                   |

| Threads_connected                             | 1                   |

+-----------------------------------------------+---------------------+

16 rows in set (0.00 sec)

  

(root@localhost) [(none)]> show variables like '%double%';

+--------------------+-------+

| Variable_name      | Value |

+--------------------+-------+

| innodb_doublewrite | ON    |

+--------------------+-------+

1 row in set (0.00 sec)

  

(root@localhost) [(none)]> show status like  "%InnoDB_dblwr%";

+----------------------------+-------+

| Variable_name              | Value |

+----------------------------+-------+

| Innodb_dblwr_pages_written | 2     |

| Innodb_dblwr_writes        | 1     |

+----------------------------+-------+

2 rows in set (0.00 sec)

  

  

(root@localhost) [(none)]> show master status;

+------------+----------+--------------+------------------+--------------------------------------------+

| File       | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set
|

+------------+----------+--------------+------------------+--------------------------------------------+

| bin.000044 |      194 |              |                  |
1cb93d00-21ba-11e8-937b-000c29b8e623:1-395 |

+------------+----------+--------------+------------------+--------------------------------------------+

1 row in set (0.00 sec)

  

(root@localhost) [(none)]> show binlog events in 'bin.000044';

+------------+-----+----------------+-----------+-------------+--------------------------------------------+

| Log_name   | Pos | Event_type     | Server_id | End_log_pos | Info
|

+------------+-----+----------------+-----------+-------------+--------------------------------------------+

| bin.000044 |   4 | Format_desc    |        11 |         123 | Server ver:
5.7.21-log, Binlog ver: 4      |

| bin.000044 | 123 | Previous_gtids |        11 |         194 |
1cb93d00-21ba-11e8-937b-000c29b8e623:1-395 |

+------------+-----+----------------+-----------+-------------+--------------------------------------------+

2 rows in set (0.00 sec)

(root@localhost) [(none)]> flush binary logs;

Query OK, 0 rows affected (0.35 sec)

  

mysql> purge binary logs before sysdate();

Query OK, 0 rows affected, 1 warning (0.00 sec)

  

mysql>  purge binary logs before "2018-04-04 13:58:14";

Query OK, 0 rows affected, 1 warning (0.00 sec)

  

(root@localhost) [(none)]> show master status;

+------------+----------+--------------+------------------+--------------------------------------------+

| File       | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set
|

+------------+----------+--------------+------------------+--------------------------------------------+

| bin.000045 |      194 |              |                  |
1cb93d00-21ba-11e8-937b-000c29b8e623:1-395 |

+------------+----------+--------------+------------------+--------------------------------------------+

1 row in set (0.00 sec)

+------------+-----+----------------+-----------+-------------+--------------------------------------------+

| Log_name   | Pos | Event_type     | Server_id | End_log_pos | Info
|

+------------+-----+----------------+-----------+-------------+--------------------------------------------+

| bin.000044 |   4 | Format_desc    |        11 |         123 | Server ver:
5.7.21-log, Binlog ver: 4      |

| bin.000044 | 123 | Previous_gtids |        11 |         194 |
1cb93d00-21ba-11e8-937b-000c29b8e623:1-395 |

| bin.000044 | 194 | Rotate         |        11 |         235 |
bin.000045;pos=4                           |

+------------+-----+----------------+-----------+-------------+--------------------------------------------+

3 rows in set (0.00 sec)

  

(root@localhost) [(none)]> SHOW GLOBAL STATUS like 'binlog%';

+----------------------------+-------+

| Variable_name              | Value |

+----------------------------+-------+

| Binlog_cache_disk_use      | 0     |

| Binlog_cache_use           | 0     |

| Binlog_stmt_cache_disk_use | 0     |

| Binlog_stmt_cache_use      | 0     |

+----------------------------+-------+

4 rows in set (0.00 sec)

  

mysqlbinlog  -v --base64-output=DECODE-ROWS /data/bin.000029

  

(root@localhost) [information_schema]> show variables like 'max_heap%';

+---------------------+----------+

| Variable_name       | Value    |

+---------------------+----------+

| max_heap_table_size | 16777216 |

+---------------------+----------+

1 row in set (0.00 sec)

  

(root@localhost) [information_schema]> show table status like 'TABLES%'\G

*************************** 1. row ***************************

           Name: TABLES

         Engine: MEMORY

        Version: 10

     Row_format: Fixed

           Rows: NULL

Avg_row_length: 9441

    Data_length: 0

Max_data_length: 16757775

   Index_length: 0

      Data_free: 0

Auto_increment: NULL

    Create_time: 2018-03-29 10:44:18

    Update_time: NULL

     Check_time: NULL

      Collation: utf8_general_ci

       Checksum: NULL

Create_options: max_rows=1777

        Comment:

  

(root@localhost) [mytest]> show engines;

+--------------------+---------+----------------------------------------------------------------+--------------+------+------------+

| Engine             | Support | Comment
| Transactions | XA   | Savepoints |

+--------------------+---------+----------------------------------------------------------------+--------------+------+------------+

| MEMORY             | YES     | Hash based, stored in memory, useful for
temporary tables      | NO           | NO   | NO         |

| CSV                | YES     | CSV storage engine
| NO           | NO   | NO         |

| MRG_MYISAM         | YES     | Collection of identical MyISAM tables
| NO           | NO   | NO         |

| BLACKHOLE          | YES     | /dev/null storage engine (anything you write
to it disappears) | NO           | NO   | NO         |

| InnoDB             | DEFAULT | Supports transactions, row-level locking, and
foreign keys     | YES          | YES  | YES        |

| PERFORMANCE_SCHEMA | YES     | Performance Schema
| NO           | NO   | NO         |

| ARCHIVE            | YES     | Archive storage engine
| NO           | NO   | NO         |

| MyISAM             | YES     | MyISAM storage engine
| NO           | NO   | NO         |

| FEDERATED          | NO      | Federated MySQL storage engine
| NULL         | NULL | NULL       |

+--------------------+---------+----------------------------------------------------------------+--------------+------+------------+

9 rows in set (0.00 sec)

  

mysql> create table remote_fed(id int auto_increment not null,c1 varchar(10)
not null default '',c2 char(10) not null default '',primary
key(id))engine=innodb;

Query OK, 0 rows affected (0.59 sec)

  

mysql> show create table remote_fed;

+------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

| Table      | Create Table
|

+------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

| remote_fed | CREATE TABLE `remote_fed` (

  `id` int(11) NOT NULL AUTO_INCREMENT,

  `c1` varchar(10) NOT NULL DEFAULT '',

  `c2` char(10) NOT NULL DEFAULT '',

  PRIMARY KEY (`id`)

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 |

+------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

1 row in set (0.13 sec)

  

mysql> insert into remote_fed(c1,c2) values ('aaa','bbb'),('ccc','ddd');

Query OK, 2 rows affected (0.61 sec)

Records: 2  Duplicates: 0  Warnings: 0

  

mysql> commit;

Query OK, 0 rows affected (0.00 sec)

  

mysql> select * from remote_fed;

+----+-----+-----+

| id | c1  | c2  |

+----+-----+-----+

|  1 | aaa | bbb |

|  2 | ccc | ddd |

+----+-----+-----+

2 rows in set (0.00 sec)

  

mysql> grant select,update,insert,delete on mytest.remote_fed to
fed_link@'192.168.45.%' identified by 'oracle';

Query OK, 0 rows affected, 1 warning (0.34 sec)

  

(root@localhost) [mytest]> CREATE TABLE `remote_fed` (

    ->   `id` int(11) NOT NULL AUTO_INCREMENT,

    ->   `c1` varchar(10) NOT NULL DEFAULT '',

    ->   `c2` char(10) NOT NULL DEFAULT '',

    ->   PRIMARY KEY (`id`)

    -> ) ENGINE=^C

(root@localhost) [mytest]> CREATE TABLE `local_fed` (

    ->   `id` int(11) NOT NULL AUTO_INCREMENT,

    ->   `c1` varchar(10) NOT NULL DEFAULT '',

    ->   `c2` char(10) NOT NULL DEFAULT '',

    ->   PRIMARY KEY (`id`)

    -> ) ENGINE=federated connection='<mysql://fed_link:oracle@192.168.45.84:3306/mytest/remote_fed>';

Query OK, 0 rows affected (5.37 sec)

  

(root@localhost) [mytest]> show create table local_fed;

+-----------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

| Table     | Create Table
|

+-----------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

| local_fed | CREATE TABLE `local_fed` (

  `id` int(11) NOT NULL AUTO_INCREMENT,

  `c1` varchar(10) NOT NULL DEFAULT '',

  `c2` char(10) NOT NULL DEFAULT '',

  PRIMARY KEY (`id`)

) ENGINE=FEDERATED DEFAULT CHARSET=utf8mb4
CONNECTION='<mysql://fed_link:oracle@192.168.45.84:3306/mytest/remote_fed>' |

+-----------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

1 row in set (0.00 sec)

  

(root@localhost) [mytest]> show variables like '%autocommit%';

+---------------+-------+

| Variable_name | Value |

+---------------+-------+

| autocommit    | ON    |

+---------------+-------+

1 row in set (0.00 sec)

  

(root@localhost) [mytest]> show variables like '%iso%';  

+-----------------------+----------------+

| Variable_name         | Value          |

+-----------------------+----------------+

| transaction_isolation | READ-COMMITTED |

| tx_isolation          | READ-COMMITTED |

+-----------------------+----------------+

2 rows in set (0.00 sec)

  

  

[root@centos mytest]# mysqld --help --verbose|grep my.cnf

/etc/my.cnf /etc/mysql/my.cnf /usr/local/mysql/etc/my.cnf ~/.my.cnf

                      my.cnf, $MYSQL_TCP_PORT, /etc/services, built-in default

  

![noteattachment4][347ace51f5942a59bcca2ec63e42eb4f]

  

(root@localhost) [mytest]> show variables where variable_name='wait_timeout'
or variable_name='interactive_timeout';

+---------------------+-------+

| Variable_name       | Value |

+---------------------+-------+

| interactive_timeout | 1800  |

| wait_timeout        | 1800  |

+---------------------+-------+

2 rows in set (0.00 sec)

  

  

(root@localhost) [mytest]> set global wait_timeout=3600;set global
interactive_timeout=3600;

Query OK, 0 rows affected (0.00 sec)

  

Query OK, 0 rows affected (0.00 sec)

  

(root@localhost) [mytest]> show variables where variable_name='wait_timeout'
or variable_name='interactive_timeout';
###这两个参数需同时修改，否则mysql选择其中大的参数，这两个参数只对新建链接有效

+---------------------+-------+

| Variable_name       | Value |

+---------------------+-------+

| interactive_timeout | 1800  |

| wait_timeout        | 1800  |

+---------------------+-------+

2 rows in set (0.00 sec)

  

  

  

[root@centos mytest]# mysql

Welcome to the MySQL monitor.  Commands end with ; or \g.

Your MySQL connection id is 3

Server version: 5.7.21-log MySQL Community Server (GPL)

  

Copyright (c) 2000, 2018, Oracle and/or its affiliates. All rights reserved.

  

Oracle is a registered trademark of Oracle Corporation and/or its

affiliates. Other names may be trademarks of their respective

owners.

  

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

  

(root@localhost) [(none)]> show variables where variable_name='wait_timeout'
or variable_name='interactive_timeout';

+---------------------+-------+

| Variable_name       | Value |

+---------------------+-------+

| interactive_timeout | 3600  |

| wait_timeout        | 3600  |

+---------------------+-------+

2 rows in set (0.00 sec)

  

(root@localhost) [mytest]> show variables like 'sort_buffer_size';

ERROR 2006 (HY000): MySQL server has gone away

No connection. Trying to reconnect...

Connection id:    4

Current database: mytest

  

+------------------+----------+

| Variable_name    | Value    |

+------------------+----------+

| sort_buffer_size | 33554432 |

+------------------+----------+

1 row in set (0.01 sec)

  

(root@localhost) [mytest]> show variables like 'join_buffer_size';  

+------------------+-----------+

| Variable_name    | Value     |

+------------------+-----------+

| join_buffer_size | 134217728 |

+------------------+-----------+

1 row in set (0.00 sec)

  

(root@localhost) [mytest]> show variables like 'read_buffer_size';  

+------------------+----------+

| Variable_name    | Value    |

+------------------+----------+

| read_buffer_size | 16777216 |

+------------------+----------+

1 row in set (0.00 sec)

  

(root@localhost) [mytest]> show variables like 'read_rnd_buffer_size';

+----------------------+----------+

| Variable_name        | Value    |

+----------------------+----------+

| read_rnd_buffer_size | 33554432 |

+----------------------+----------+

1 row in set (0.00 sec)

  

![noteattachment5][a112e7db8cd73e6303fc2e12e994fb6c]

  

(root@localhost) [mytest]> show variables like 'innodb_buffer_pool_size';  

+-------------------------+------------+

| Variable_name           | Value      |

+-------------------------+------------+

| innodb_buffer_pool_size | 6442450944 |

+-------------------------+------------+

1 row in set (0.00 sec)

(root@localhost) [mytest]> select sum(index_length) from
information_schema.tables where engine='myisam';

+-------------------+

| sum(index_length) |

+-------------------+

|             44032 |

+-------------------+

1 row in set (0.73 sec)

  

(root@localhost) [mytest]> show variables like 'key_buffer_size';

+-----------------+---------+

| Variable_name   | Value   |

+-----------------+---------+

| key_buffer_size | 8388608 |

+-----------------+---------+

1 row in set (0.00 sec)

  

(root@localhost) [mytest]> show variables like 'innodb_log_file_size';

+----------------------+------------+

| Variable_name        | Value      |

+----------------------+------------+

| innodb_log_file_size | 8589934592 |

+----------------------+------------+

1 row in set (0.00 sec)

  

(root@localhost) [mytest]> show variables like 'innodb_log_files_in_group';

+---------------------------+-------+

| Variable_name             | Value |

+---------------------------+-------+

| innodb_log_files_in_group | 2     |

+---------------------------+-------+

1 row in set (0.00 sec)

(root@localhost) [mytest]> show variables like 'innodb_log_buffer_size';

+------------------------+----------+

| Variable_name          | Value    |

+------------------------+----------+

| innodb_log_buffer_size | 33554432 |

+------------------------+------\----+

1 row in set (0.00 sec)

  

(root@localhost) [mytest]> show variables like
'innodb_flush_log_at_trx_commit';

+--------------------------------+-------+

| Variable_name                  | Value |

+--------------------------------+-------+

| innodb_flush_log_at_trx_commit | 1     |

+--------------------------------+-------+

1 row in set (0.00 sec)

  

(root@localhost) [mytest]> show variables like 'innodb_flush_method';

+---------------------+----------+

| Variable_name       | Value    |

+---------------------+----------+

| innodb_flush_method | O_DIRECT |

+---------------------+----------+

1 row in set (0.00 sec)

  

(root@localhost) [mytest]> show variables like 'innodb_file_per_table';

+-----------------------+-------+

| Variable_name         | Value |

+-----------------------+-------+

| innodb_file_per_table | ON    |

+-----------------------+-------+

1 row in set (0.00 sec)

  

(root@localhost) [mytest]> show variables like 'innodb_doublewrite';

+--------------------+-------+

| Variable_name      | Value |

+--------------------+-------+

| innodb_doublewrite | ON    |

+--------------------+-------+

1 row in set (0.00 sec)

###myisam

(root@localhost) [mytest]> show variables like 'delay_key_write';   ###OFF ON
ALL

+-----------------+-------+

| Variable_name   | Value |

+-----------------+-------+

| delay_key_write | ON    |

+-----------------+-------+

1 row in set (0.00 sec)

  

(root@localhost) [mytest]> show variables like 'expire_logs_days';

+------------------+-------+

| Variable_name    | Value |

+------------------+-------+

| expire_logs_days | 90    |

+------------------+-------+

1 row in set (0.00 sec)

(root@localhost) [mytest]> show variables like 'max_allowed_packet';
###需主从一致

+--------------------+----------+

| Variable_name      | Value    |

+--------------------+----------+

| max_allowed_packet | 16777216 |

+--------------------+----------+

1 row in set (0.00 sec)

  

(root@localhost) [mytest]> show variables like 'skip_name_resolve';

+-------------------+-------+

| Variable_name     | Value |

+-------------------+-------+

| skip_name_resolve | ON    |

+-------------------+-------+

1 row in set (0.00 sec)

  

![noteattachment6][77da206d31cce314446656cfc6a5ebdb]

  

(root@localhost) [mytest]> show global variables like 'read_only';   ###从库启用

+---------------+-------+

| Variable_name | Value |

+---------------+-------+

| read_only     | OFF   |

+---------------+-------+

1 row in set (0.00 sec)

![noteattachment7][2740b287b97860159ede48d784b76dc5]

  

(root@localhost) [mytest]> show global variables like 'sync_binlog';

+---------------+-------+

| Variable_name | Value |

+---------------+-------+

| sync_binlog   | 1     |

+---------------+-------+

1 row in set (0.00 sec)

![noteattachment8][99f991e341667f0c8067d64f6795a42e]

  

  

(root@localhost) [mytest]> show global variables like '%_table_size';

+---------------------+----------+

| Variable_name       | Value    |

+---------------------+----------+

| max_heap_table_size | 16777216 |

| tmp_table_size      | 67108864 |

+---------------------+----------+

2 rows in set (0.00 sec)

(root@localhost) [mytest]> show global variables like 'max_connections';

+-----------------+-------+

| Variable_name   | Value |

+-----------------+-------+

| max_connections | 800   |

+-----------------+-------+

1 row in set (0.00 sec)

![noteattachment9][d91edde81572cfb976a2e2abbd29ad64]

  

![noteattachment10][9374b5b462e91fefde58174446708acd]

  

![noteattachment11][d6218f5e9be1083999ad238751ebd6a1]

  

![noteattachment12][52d56f231bfd97c73d5dd9fe4630f553]

  

![noteattachment13][1208e5d9710256c4e829f8e0500c4fcf]

  

[root@centos ~]# mysqlslap --concurrency=1,50,100,200 --iterations=3 --number-
int-cols=5 --number-char-cols=5 --auto-generate-sql --auto-generate-sql-add-
autoincrement --engine=myisam,innodb --number-of-queries=10 --create-
schema=sbtest;

Benchmark

        Running for engine myisam

        Average number of seconds to run all queries: 0.017 seconds

        Minimum number of seconds to run all queries: 0.012 seconds

        Maximum number of seconds to run all queries: 0.029 seconds

        Number of clients running queries: 1

        Average number of queries per client: 10

  

Benchmark

        Running for engine myisam

        Average number of seconds to run all queries: 2.206 seconds

        Minimum number of seconds to run all queries: 1.302 seconds

        Maximum number of seconds to run all queries: 3.151 seconds

        Number of clients running queries: 50

        Average number of queries per client: 0

  

Benchmark

        Running for engine myisam

        Average number of seconds to run all queries: 3.641 seconds

        Minimum number of seconds to run all queries: 2.936 seconds

        Maximum number of seconds to run all queries: 4.780 seconds

        Number of clients running queries: 100

        Average number of queries per client: 0

  

Benchmark

        Running for engine myisam

        Average number of seconds to run all queries: 6.584 seconds

        Minimum number of seconds to run all queries: 5.821 seconds

        Maximum number of seconds to run all queries: 8.078 seconds

        Number of clients running queries: 200

        Average number of queries per client: 0

  

Benchmark

        Running for engine innodb

        Average number of seconds to run all queries: 0.012 seconds

        Minimum number of seconds to run all queries: 0.012 seconds

        Maximum number of seconds to run all queries: 0.013 seconds

        Number of clients running queries: 1

        Average number of queries per client: 10

  

Benchmark

        Running for engine innodb

        Average number of seconds to run all queries: 0.375 seconds

        Minimum number of seconds to run all queries: 0.223 seconds

        Maximum number of seconds to run all queries: 0.622 seconds

        Number of clients running queries: 50

        Average number of queries per client: 0

  

Benchmark

        Running for engine innodb

        Average number of seconds to run all queries: 0.958 seconds

        Minimum number of seconds to run all queries: 0.855 seconds

        Maximum number of seconds to run all queries: 1.123 seconds

        Number of clients running queries: 100

        Average number of queries per client: 0

  

Benchmark

        Running for engine innodb

        Average number of seconds to run all queries: 1.355 seconds

        Minimum number of seconds to run all queries: 0.984 seconds

        Maximum number of seconds to run all queries: 1.836 seconds

        Number of clients running queries: 200

        Average number of queries per client: 0

  

  

[root@centos ~]# mysqlslap --concurrency=1,50,100,200 --iterations=3 --number-
int-cols=5 --number-char-cols=5 --auto-generate-sql --auto-generate-sql-add-
autoincrement --engine=myisam,innodb --number-of-queries=10 --create-
schema=sbtest --only-print|more

DROP SCHEMA IF EXISTS `sbtest`;

CREATE SCHEMA `sbtest`;

use sbtest;

set default_storage_engine=`myisam`;

CREATE TABLE `t1` (id serial,intcol1 INT(32) ,intcol2 INT(32) ,intcol3 INT(32)
,intcol4 INT(32) ,intcol5 INT(32) ,charcol1 VARCHAR(128),charcol2 VARCHAR(128

),charcol3 VARCHAR(128),charcol4 VARCHAR(128),charcol5 VARCHAR(128));

INSERT INTO t1 VALUES
(NULL,1804289383,846930886,1681692777,1714636915,1957747793,'vmC9127qJNm06sGB8R92q2j7vTiiITRDGXM9ZLzkdekbWtmXKwZ2qG1llkRw5m9DHOFilEREk

3q7oce8O3BEJC0woJsm6uzFAEynLH2xCsw1KQ1lT4zg9rdxBLb97R','GHZ65mNzkSrYT3zWoSbg9cNePQr1bzSk81qDgE4Oanw3rnPfGsBHSbnu1evTdFDe83ro9w4jjteQg4yoo9xHck3WNqzs54W5zEm9

2ikdRF48B2oz3m8gMBAl11Wy50','w46i58Giekxik0cYzfA8BZBLADEg3JhzGfZDoqvQQk0Akcic7lcJInYSsf

  

###sysbench

<https://github.com/akopytov/sysbench#linux>

  

[root@centos tools]# sysbench --test=cpu --cpu-max-prime=10000 run

WARNING: the --test option is deprecated. You can pass a script name or path
on the command line without any options.

sysbench 1.0.13 (using bundled LuaJIT 2.1.0-beta2)

  

Running the test with following options:

Number of threads: 1

Initializing random number generator from current time

  

  

Prime numbers limit: 10000

  

Initializing worker threads...

  

Threads started!

  

CPU speed:

    events per second:   914.21

  

General statistics:

    total time:                          10.0004s

    total number of events:              9144

  

Latency (ms):

         min:                                    1.04

         avg:                                    1.09

         max:                                    2.30

         95th percentile:                        1.16

         sum:                                 9993.36

  

Threads fairness:

    events (avg/stddev):           9144.0000/0.00

    execution time (avg/stddev):   9.9934/0.00

  

sysbench /usr/share/sysbench/oltp_read_only.lua --mysql-host=127.0.0.1
--mysql-port=3306 --mysql-user=root --mysql-password='oracle' \--mysql-
db=mytest --db-driver=mysql --tables=10 --table-size=1000000 --report-
interval=10 --threads=128 --time=120 prepare

  

sysbench /usr/share/sysbench/oltp_read_only.lua --mysql-host=127.0.0.1
--mysql-port=3306 --mysql-user=root --mysql-password='oracle' \--mysql-
db=mytest --db-driver=mysql --tables=10 --table-size=1000000 --report-
interval=10 --threads=128 --time=120 run

  

![noteattachment14][3c0c87b337fc0b0df4ae812b88911bed]

![noteattachment15][c6661830b9ac60a3df4fb6951cb966ee]

  

  

![noteattachment16][c40eeafa74d6bf1b3b71b77d88d7b411]

![noteattachment17][a28dc7856eaa6399f54306e55d13bf7d]

  

![noteattachment18][cddae9341ffd7e14d741f01a8023d192]

  

![noteattachment19][4db2a11199d92278f5e4fbb7653e9635]

![noteattachment20][5e9baa424ae4f033a55fea6ea478c77d]

  

![noteattachment21][0a64f7d75a182db132b1a5acf9e5536f]

![noteattachment22][f30745ce3dd6df1f1477d5161aed5c6e]

  

![noteattachment23][edc31deeb57a91ea649afc51141abd30]

![noteattachment24][aaa9d4ece925d8e840cafda88a0f7934]

![noteattachment25][bb3fb69a89836aed51f80301862cd45a]

  

(root@localhost) [(none)]> show variables like 'binlog_format';

+---------------+-------+

| Variable_name | Value |

+---------------+-------+

| binlog_format | ROW   |

+---------------+-------+

1 row in set (0.00 sec)

  

(root@localhost) [(none)]> show binary logs;

+------------+------------+

| Log_name   | File_size  |

+------------+------------+

| bin.000001 |        177 |

| bin.000002 |        421 |

| bin.000003 |        217 |

| bin.000004 |        217 |

| bin.000005 |        217 |

| bin.000006 |        217 |

| bin.000007 |     120299 |

| bin.000008 |        217 |

| bin.000009 |        217 |

| bin.000010 |        217 |

| bin.000011 |        217 |

| bin.000012 |        217 |

| bin.000013 |        217 |

| bin.000014 |        217 |

| bin.000015 |        217 |

| bin.000016 |        217 |

| bin.000017 |        217 |

| bin.000018 |        217 |

| bin.000019 |        217 |

| bin.000020 |        217 |

| bin.000021 |       6678 |

| bin.000022 |        382 |

| bin.000023 |        217 |

| bin.000024 |        194 |

| bin.000025 |       4613 |

| bin.000026 |       9167 |

| bin.000027 |        217 |

| bin.000028 |       4453 |

| bin.000029 |   66376295 |

| bin.000030 |   10674999 |

| bin.000031 |        217 |

| bin.000032 |        217 |

| bin.000033 |       1960 |

| bin.000034 |        659 |

| bin.000035 |       3174 |

| bin.000036 |        416 |

| bin.000037 |        217 |

| bin.000038 |    2049281 |

| bin.000039 |        217 |

| bin.000040 |        217 |

| bin.000041 |        217 |

| bin.000042 |        217 |

| bin.000043 |        217 |

| bin.000044 |        235 |

| bin.000045 |        217 |

| bin.000046 |        217 |

| bin.000047 |        939 |

| bin.000048 |        217 |

| bin.000049 |        217 |

| bin.000050 | 1075207675 |

| bin.000051 |  848370257 |

| bin.000052 |        194 |

+------------+------------+

52 rows in set (0.00 sec)

  

(root@localhost) [(none)]> flush logs;

Query OK, 0 rows affected (0.35 sec)

  

(root@localhost) [(none)]> show variables like 'binlog_row_image';   ###FULL
NOBOL  MIN

+------------------+-------+

| Variable_name    | Value |

+------------------+-------+

| binlog_row_image | FULL  |

+------------------+-------+

1 row in set (0.00 sec)

  

mysqlbinlog -vv

  

mysql> show variables like 'log_bin';

+---------------+-------+

| Variable_name | Value |

+---------------+-------+

| log_bin       | ON    |

+---------------+-------+

1 row in set (0.00 sec)

mysql> show variables like 'server_id';

+---------------+-------+

| Variable_name | Value |

+---------------+-------+

| server_id     | 2     |

+---------------+-------+

1 row in set (0.00 sec)

  

  

log-bin=mysql-bin

server-id=2

relay_log=mysql-relay-bin

log_slave_updates = 1

read_only = 1

skip-slave-start

  

mysql> show processlist;

+----+------+-------------+------+-------------+------+---------------------------------------------------------------+------------------+

| Id | User | Host        | db   | Command     | Time | State
| Info             |

+----+------+-------------+------+-------------+------+---------------------------------------------------------------+------------------+

| 14 | root | localhost   | NULL | Query       |    0 | starting
| show processlist |

| 15 | repl | slave:50408 | NULL | Binlog Dump |   88 | Master has sent all
binlog to slave; waiting for more updates | NULL             |

+----+------+-------------+------+-------------+------+---------------------------------------------------------------+------------------+

2 rows in set (0.00 sec)

  

mysql> show processlist;

+----+-------------+-----------+------+---------+------+--------------------------------------------------------+------------------+

| Id | User        | Host      | db   | Command | Time | State
| Info             |

+----+-------------+-----------+------+---------+------+--------------------------------------------------------+------------------+

|  3 | root        | localhost | NULL | Sleep   |  157 |
| NULL             |

|  4 | root        | localhost | NULL | Query   |    0 | starting
| show processlist |

|  5 | system user |           | NULL | Connect |   81 | Waiting for master to
send event                       | NULL             |

|  6 | system user |           | NULL | Connect |   81 | Slave has read all
relay log; waiting for more updates | NULL             |

+----+-------------+-----------+------+---------+------+--------------------------------------------------------+------------------+

4 rows in set (0.00 sec)

  

mysql>  system perror 1872

MySQL error code 1872 (ER_SLAVE_RLI_INIT_REPOSITORY): Slave failed to
initialize relay log info structure from the repository

  

  

  

mysql> show variables like 'gtid_mode';

+---------------+-------+

| Variable_name | Value |

+---------------+-------+

| gtid_mode     | OFF   |

+---------------+-------+

1 row in set (0.00 sec)

![noteattachment26][553c7b70eb66c1b289297d72cfd90bbd]

![noteattachment27][06e70a4f1a6d1ee1abf065602e54b109]

  

gtid dump

mysqldump --single-transaction --master-data=2 --triggers --routines --events
--all-databases -uroot -p> all_gtid.sql  

  

![noteattachment28][3b4ce80c5cea6ab4f760521e2b7a8674]

![noteattachment29][98b50f6da23710c319b94ba82be81a5e]

  

![noteattachment30][5d513401d052ce6d5a2caa1153f4651a]

  

#多线程复制

mysql> stop slave;

Query OK, 0 rows affected (0.00 sec)

  

mysql> set global slave_parallel_type= 'logical_clock';

Query OK, 0 rows affected (0.00 sec)

  

mysql> set global slave_parallel_workers=2;

Query OK, 0 rows affected (0.00 sec)

  

mysql> start slave;

Query OK, 0 rows affected (0.01 sec)

mysql> show processlist;

+----+-------------+-----------+------+---------+------+--------------------------------------------------------+------------------+

| Id | User        | Host      | db   | Command | Time | State
| Info             |

+----+-------------+-----------+------+---------+------+--------------------------------------------------------+------------------+

|  4 | root        | localhost | NULL | Query   |    0 | starting
| show processlist |

|  7 | system user |           | NULL | Connect |   54 | Waiting for master to
send event                       | NULL             |

|  8 | system user |           | NULL | Connect |   54 | Slave has read all
relay log; waiting for more updates | NULL             |

|  9 | system user |           | NULL | Connect |   54 | Waiting for an event
from Coordinator                  | NULL             |

| 10 | system user |           | NULL | Connect |   54 | Waiting for an event
from Coordinator                  | NULL             |

+----+-------------+-----------+------+---------+------+--------------------------------------------------------+------------------+

5 rows in set (0.00 sec)

  

  

  

mysql> show slave hosts;

+-----------+------+------+-----------+--------------------------------------+

| Server_id | Host | Port | Master_id | Slave_UUID                           |

+-----------+------+------+-----------+--------------------------------------+

|        13 |      | 3306 |        11 | 25b8bfec-35b3-11e8-9657-000c29653458 |

|        12 |      | 3306 |        11 | 23eeb92b-35b3-11e8-94db-000c29b85972 |

+-----------+------+------+-----------+--------------------------------------+

2 rows in set (0.00 sec)

  

create index index_name on table(col_name(n));

  

optimize table table_name;

  

![noteattachment31][923cd4af9ecb22786f91f0aeb0307e56]

  

![noteattachment32][1c9d3b43bfd15c94f5f37bacf5f8f3a4]

  

  

![noteattachment33][95ceeae0b1b2cff025e8c049f7f914f6]

![noteattachment34][4073f4ea77d6c63c68a39c725c297694]

(root@localhost) [sakila]> set profiling =1;

Query OK, 0 rows affected, 1 warning (0.00 sec)

  

(root@localhost) [sakila]> select count(*) from film;

+----------+

| count(*) |

+----------+

|     1000 |

+----------+

1 row in set (0.00 sec)

  

(root@localhost) [sakila]> show profiles;

+----------+------------+---------------------------+

| Query_ID | Duration   | Query                     |

+----------+------------+---------------------------+

|        1 | 0.00037100 | select count(*) from film |

+----------+------------+---------------------------+

1 row in set, 1 warning (0.00 sec)

  

(root@localhost) [sakila]> show profile for query 1;

+----------------------+----------+

| Status               | Duration |

+----------------------+----------+

| starting             | 0.000051 |

| checking permissions | 0.000005 |

| Opening tables       | 0.000015 |

| init                 | 0.000012 |

| System lock          | 0.000007 |

| optimizing           | 0.000003 |

| statistics           | 0.000011 |

| preparing            | 0.000009 |

| executing            | 0.000002 |

| Sending data         | 0.000224 |

| end                  | 0.000004 |

| query end            | 0.000007 |

| closing tables       | 0.000006 |

| freeing items        | 0.000009 |

| cleaning up          | 0.000008 |

+----------------------+----------+

15 rows in set, 1 warning (0.00 sec)

  

(root@localhost) [sakila]> show profile cpu for query 1;

+----------------------+----------+----------+------------+

| Status               | Duration | CPU_user | CPU_system |

+----------------------+----------+----------+------------+

| starting             | 0.000051 | 0.000000 |   0.000000 |

| checking permissions | 0.000005 | 0.000000 |   0.000000 |

| Opening tables       | 0.000015 | 0.000000 |   0.000000 |

| init                 | 0.000012 | 0.000000 |   0.000000 |

| System lock          | 0.000007 | 0.000000 |   0.000000 |

| optimizing           | 0.000003 | 0.000000 |   0.000000 |

| statistics           | 0.000011 | 0.000000 |   0.000000 |

| preparing            | 0.000009 | 0.000000 |   0.000000 |

| executing            | 0.000002 | 0.000000 |   0.000000 |

| Sending data         | 0.000224 | 0.000000 |   0.000000 |

| end                  | 0.000004 | 0.000000 |   0.000000 |

| query end            | 0.000007 | 0.000000 |   0.000000 |

| closing tables       | 0.000006 | 0.000000 |   0.000000 |

| freeing items        | 0.000009 | 0.000000 |   0.000000 |

| cleaning up          | 0.000008 | 0.000000 |   0.000000 |

+----------------------+----------+----------+------------+

15 rows in set, 1 warning (0.00 sec)

  

(root@localhost) [sakila]> SELECT @@profiling;

+-------------+

| @@profiling |

+-------------+

|           1 |

+-------------+

1 row in set, 1 warning (0.00 sec)

  

(root@localhost) [sakila]> SHOW PROFILE;

+----------------------+----------+

| Status               | Duration |

+----------------------+----------+

| starting             | 0.000056 |

| checking permissions | 0.000003 |

| Opening tables       | 0.000004 |

| init                 | 0.000010 |

| optimizing           | 0.000004 |

| executing            | 0.000007 |

| end                  | 0.000003 |

| query end            | 0.000004 |

| closing tables       | 0.000003 |

| freeing items        | 0.000008 |

| cleaning up          | 0.000010 |

+----------------------+----------+

11 rows in set, 1 warning (0.00 sec)

  

(root@localhost) [sakila]> set profiling = 0;

Query OK, 0 rows affected, 1 warning (0.00 sec)

  

(root@localhost) [sakila]> SHOW VARIABLES LIKE 'performance_schema';

+--------------------+-------+

| Variable_name      | Value |

+--------------------+-------+

| performance_schema | ON    |

+--------------------+-------+

1 row in set (0.00 sec)

  

![noteattachment35][1aa4314bdb9c45f80250b6859b5d7dd9]

![noteattachment36][c4aaab7faa785e8d46ec450e90f07fd1]

  

![noteattachment37][91e8b380fc85c8bc288fec470f1ae9e8]

![noteattachment38][c92a163b99b125387c44cd9b06771374]

![noteattachment39][53f09f8036e88884dbb1aca2143925fe]

![noteattachment40][e2f5e18f4b745dff09fa3a0e9db7dcee]

  

![noteattachment41][9bf964d5e1c3720867e427496325488d]
![noteattachment42][ccb44931a0b06009c1d0006374e1d9e5]

  

![noteattachment43][7a49ac2b54f956a7f304e0780285361b]

  

(root@localhost) [(none)]> select connection_id();

ERROR 2006 (HY000): MySQL server has gone away

No connection. Trying to reconnect...

Connection id:    14

Current database: *** NONE ***

  

+-----------------+

| connection_id() |

+-----------------+

|              14 |

+-----------------+

1 row in set (0.00 sec)

  

![noteattachment44][48d30344b30a6e7fb79b172ed703aba7]

![noteattachment45][edad13e944bffb0bdaa83ac0147d3237]

  

  ![noteattachment46][48ee2bf1829890c64095cfeb1dd99b59]

  

![noteattachment47][5a6b5addad7329a324ee47c9f4e1fcb8]

  

(root@localhost) [mytest]> begin;

Query OK, 0 rows affected (0.00 sec)

  

(root@localhost) [mytest]> insert into t5 (i) values (2),(3);

Query OK, 2 rows affected (0.39 sec)

Records: 2  Duplicates: 0  Warnings: 0

  

(root@localhost) [mytest]> savepoint s1;

Query OK, 0 rows affected (0.00 sec)

  

(root@localhost) [mytest]> insert into t5 (i) values (4),(5);

Query OK, 2 rows affected (0.00 sec)

Records: 2  Duplicates: 0  Warnings: 0

  

(root@localhost) [mytest]> savepoint s2;

Query OK, 0 rows affected (0.00 sec)

  

(root@localhost) [mytest]> insert into t5 (i) values (6),(7);

Query OK, 2 rows affected (0.00 sec)

Records: 2  Duplicates: 0  Warnings: 0

  

(root@localhost) [mytest]> select * from t5;

+---+

| i |

+---+

| 2 |

| 3 |

| 4 |

| 5 |

| 6 |

| 7 |

+---+

6 rows in set (0.00 sec)

  

(root@localhost) [mytest]> rollback to savepoint s2;

Query OK, 0 rows affected (0.00 sec)

  

(root@localhost) [mytest]> select * from t5;

+---+

| i |

+---+

| 2 |

| 3 |

| 4 |

| 5 |

+---+

4 rows in set (0.00 sec)

  

(root@localhost) [mytest]> rollback;

Query OK, 0 rows affected (0.00 sec)

  

(root@localhost) [mytest]> select * from t5;

Empty set (0.00 sec)

  

  

SHOW GLOBAL STATUS like '%binlog%';

  

  

###/etc/sysctl.cnf

vm.swappiness ≤ 10

vm.dirty_ratio ≤ 5

vm.dirty_background_ratio ≤ 10

  

or

  

echo 5 >/proc/sys/vm/swappiness

  

  

  

  

  

![noteattachment48][5798d978937ad396b6022f5d7210bcff]

![noteattachment49][b89e7f270bf06eb0decd192cd3fe683c]

![noteattachment50][ec7492a8d44456fe39b1644d5506fce3]

![noteattachment51][f6d737bf9283a8838628d37ba10a0eb9]

  

  

[root@centos tpcc-mysql]# mysql tpcc1000 -e "show tables";

+--------------------+

| Tables_in_tpcc1000 |

+--------------------+

| customer           |

| district           |

| history            |

| item               |

| new_orders         |

| order_line         |

| orders             |

| stock              |

| warehouse          |

+--------------------+

  

[root@centos tpcc-mysql]# ./tpcc_start  -h localhost -P 3306 -d tpcc1000 -u
root -p oracle -S /tmp/mysql.sock -w 10 -c 10 -r 2 -l 5 -i 5 -f
tpcc_20180408_01 -t trx_20180408

***************************************

*** ###easy### TPC-C Load Generator ***

***************************************

option h with value 'localhost'

option P with value '3306'

option d with value 'tpcc1000'

option u with value 'root'

option p with value 'oracle'

option S (socket) with value '/tmp/mysql.sock'

option w with value '10'

option c with value '10'

option r with value '2'

option l with value '5'

option i with value '5'

option f with value 'tpcc_20180408_01'

option t with value 'trx_20180408'

<Parameters>

     [server]: localhost

     [port]: 3306

     [DBname]: tpcc1000

       [user]: root

       [pass]: oracle

  [warehouse]: 10

[connection]: 10

     [rampup]: 2 (sec.)

    [measure]: 5 (sec.)

  

RAMP-UP TIME.(2 sec.)

  

MEASURING START.

  

   5, trx: 179, 95%: 681.363, 99%: 886.175, max_rt: 1107.724, 177|739.591,
18|58.454, 16|1517.137, 17|285.032

  

STOPPING THREADS..........

  

<Raw Results>

  [0] sc:0 lt:179  rt:0  fl:0 avg_rt: 203.9 (5)

  [1] sc:0 lt:177  rt:0  fl:0 avg_rt: 105.3 (5)

  [2] sc:15 lt:3  rt:0  fl:0 avg_rt: 7.5 (5)

  [3] sc:0 lt:16  rt:0  fl:0 avg_rt: 765.0 (80)

  [4] sc:8 lt:9  rt:0  fl:0 avg_rt: 55.3 (20)

in 5 sec.

  

<Raw Results2(sum ver.)>

  [0] sc:0  lt:179  rt:0  fl:0

  [1] sc:0  lt:177  rt:0  fl:0

  [2] sc:15  lt:3  rt:0  fl:0

  [3] sc:0  lt:16  rt:0  fl:0

  [4] sc:8  lt:9  rt:0  fl:0

  

<Constraint Check> (all must be [OK])

[transaction percentage]

        Payment: 43.49% (>=43.0%) [OK]

   Order-Status: 4.42% (>= 4.0%) [OK]

       Delivery: 3.93% (>= 4.0%) [NG] *

    Stock-Level: 4.18% (>= 4.0%) [OK]

[response time (at least 90% passed)]

      New-Order: 0.00%  [NG] *

        Payment: 0.00%  [NG] *

   Order-Status: 83.33%  [NG] *

       Delivery: 0.00%  [NG] *

    Stock-Level: 47.06%  [NG] *

  

<TpmC>

                 2148.000 TpmC

  

root@mysql 14:07:  [(none)]> select substring(md5(rand()) from 1 for 16);

+--------------------------------------+

| substring(md5(rand()) from 1 for 16) |

+--------------------------------------+

| 7bbd122c1797d1ef                     |

+--------------------------------------+

1 row in set (0.43 sec)

  

root@mysql 14:07:  [(none)]> select length(substring(md5(rand()) from 1 for
16));

+----------------------------------------------+

| length(substring(md5(rand()) from 1 for 16)) |

+----------------------------------------------+

|                                           16 |

+----------------------------------------------+

1 row in set (0.00 sec)

  

root@mysql 14:09:  [(none)]>  select substring(md5(rand()) from 1 for
round(8+rand()*32));  

+------------------------------------------------------+

| substring(md5(rand()) from 1 for round(8+rand()*32)) |

+------------------------------------------------------+

| 97d24318bfc90a264fc5afb                              |

+------------------------------------------------------+

1 row in set (0.00 sec)

  

root@mysql 14:09:  [(none)]>  select substring(md5(rand()) from 1 for
round(8+rand()*32));

+------------------------------------------------------+

| substring(md5(rand()) from 1 for round(8+rand()*32)) |

+------------------------------------------------------+

| 98607f7d3ef0e55b9df2e6957                            |

+------------------------------------------------------+

1 row in set (0.00 sec)

  

root@mysql 14:09:  [(none)]>  select substring(md5(rand()) from 1 for
round(8+rand()*32));

+------------------------------------------------------+

| substring(md5(rand()) from 1 for round(8+rand()*32)) |

+------------------------------------------------------+

| 819d9b13a1d955                                       |

+------------------------------------------------------+

1 row in set (0.00 sec)

  

root@mysql 14:50:  [mysql]> set global log_output='table';  

Query OK, 0 rows affected (0.00 sec)

  

root@mysql 14:50:  [mysql]> show global variables like '%log_out%';

+---------------+-------+

| Variable_name | Value |

+---------------+-------+

| log_output    | TABLE |

+---------------+-------+

1 row in set (0.00 sec)

  

root@mysql 14:50:  [mysql]> show global variables like '%general%';  

+------------------+-------+

| Variable_name    | Value |

+------------------+-------+

| general_log      | OFF   |

| general_log_file | table |

+------------------+-------+

2 rows in set (0.00 sec)

  

root@mysql 14:51:  [mysql]> set global  general_log = on;

Query OK, 0 rows affected (0.00 sec)

  

root@mysql 14:51:  [mysql]> show global variables like '%general%';

+------------------+-------+

| Variable_name    | Value |

+------------------+-------+

| general_log      | ON    |

| general_log_file | table |

+------------------+-------+

2 rows in set (0.00 sec)

  

root@mysql 14:51:  [mysql]> select event_time,thread_id,argument from
general_log;

+----------------------------+-----------+-------------------------------------------------------+

| event_time                 | thread_id | argument
|

+----------------------------+-----------+-------------------------------------------------------+

| 2018-04-08 14:51:21.187833 |        28 | show global variables like
'%general%'                |

| 2018-04-08 14:51:28.267054 |        28 | select
event_time,thread_id,argument from general_log |

+----------------------------+-----------+-------------------------------------------------------+

2 rows in set (0.00 sec)

  

  

mysqldump --single-transaction --databases sampdb > mysqltest.sql

  

root@mysql 14:54:  [mysql]> select event_time,thread_id,argument from
general_log;

+----------------------------+-----------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

| event_time                 | thread_id | argument
|

+----------------------------+-----------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

| 2018-04-08 14:54:41.253220 |        40 | root@localhost on  using Socket
|

| 2018-04-08 14:54:41.255585 |        40 | /*!40100 SET @@SQL_MODE='' */
|

| 2018-04-08 14:54:41.257029 |        40 | /*!40103 SET TIME_ZONE='+00:00' */
|

| 2018-04-08 06:54:41.257163 |        40 | SET SESSION TRANSACTION ISOLATION
LEVEL REPEATABLE READ
|

| 2018-04-08 06:54:41.257224 |        40 | START TRANSACTION /*!40100 WITH
CONSISTENT SNAPSHOT */
|

| 2018-04-08 06:54:41.257296 |        40 | SHOW VARIABLES LIKE 'gtid\\_mode'  

  

[root@centos ~]# mysqlpump  \--single-transaction --parallel-
schemas=4:tpcc1000 --parallel-schemas=2sampdb >sampdb.sql  

Dump progress: 1/6 tables, 0/3718559 rows

Dump progress: 2/25 tables, 376250/3721637 rows

Dump progress: 4/25 tables, 666877/3721637 rows

Dump progress: 4/25 tables, 1201877/3721637 rows

mysqlpump: [WARNING] (1429) Unable to connect to foreign data source: Can't
connect to MySQL server on '192.168.45.84' (113)

Dump progress: 4/63 tables, 1564377/13259663 rows

Dump progress: 24/75 tables, 1985580/18220983 rows

Dump progress: 24/75 tables, 2579330/18220983 rows

Dump progress: 24/75 tables, 2964080/18220983 rows

Dump progress: 24/75 tables, 3373330/18220983 rows

Dump progress: 24/75 tables, 3705330/18220983 rows

  

xtrabackup --target-dir=/path/20110427/ --backup --throttle=100

  

root@mysql 15:44:  [(none)]> flush engine logs;

Query OK, 0 rows affected (0.29 sec)

  

root@mysql 17:24:  [(none)]> show global variables like 'binlog%image';

+------------------+-------+

| Variable_name    | Value |

+------------------+-------+

| binlog_row_image | FULL  |

+------------------+-------+

1 row in set (0.00 sec)

root@mysql 17:27:  [(none)]> set global binlog_row_image='minimal';

Query OK, 0 rows affected (0.00 sec)

  

root@mysql 17:27:  [(none)]> show global variables like 'binlog%image';

+------------------+---------+

| Variable_name    | Value   |

+------------------+---------+

| binlog_row_image | MINIMAL |

+------------------+---------+

1 row in set (0.00 sec)

  

  

root@mysql 17:38:  [(none)]> show binlog events in 'bin.000067' from 2 limit
5,5;  

+------------+------+------------+-----------+-------------+-----------------------------------+

| Log_name   | Pos  | Event_type | Server_id | End_log_pos | Info
|

+------------+------+------------+-----------+-------------+-----------------------------------+

| bin.000067 |  440 | Write_rows |        11 |        1101 | table_id: 368
flags: STMT_END_F   |

| bin.000067 | 1101 | Table_map  |        11 |        1167 | table_id: 369
(tpcc1000.history)  |

| bin.000067 | 1167 | Write_rows |        11 |        1240 | table_id: 369
flags: STMT_END_F   |

| bin.000067 | 1240 | Table_map  |        11 |        1345 | table_id: 368
(tpcc1000.customer) |

| bin.000067 | 1345 | Write_rows |        11 |        1991 | table_id: 368
flags: STMT_END_F   |

+------------+------+------------+-----------+-------------+-----------------------------------+

5 rows in set (0.13 sec)

  

  

mysqlbinlog \--start-position=27284 binlog.001002 binlog.001003 binlog.001004
| mysql \--host=host_name -u root -p

  

mysql> flush logs;

Query OK, 0 rows affected (0.01 sec)

  

mysql> show master status;

+------------------+----------+--------------+------------------+------------------------------------------+

| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB |
Executed_Gtid_Set                        |

+------------------+----------+--------------+------------------+------------------------------------------+

| mysql-bin.000018 |      194 |              |                  |
7d0e42b6-0c89-11e8-90d8-000c292c7e58:1-6 |

+------------------+----------+--------------+------------------+------------------------------------------+

1 row in set (0.00 sec)

  

mysql> show variables like '%skip%';

+------------------------+-------+

| Variable_name          | Value |

+------------------------+-------+

| skip_external_locking  | ON    |

| skip_name_resolve      | OFF   |

| skip_networking        | OFF   |

| skip_show_database     | OFF   |

| slave_skip_errors      | OFF   |

| sql_slave_skip_counter | 0     |

+------------------------+-------+

6 rows in set (0.00 sec)

  

mysql> set global sql_slave_skip_counter=1;

![noteattachment52][e738356935492d6a7505b5e07e7a6171]

  

mysql> show variables like '%skip%';

+------------------------+-------+

| Variable_name          | Value |

+------------------------+-------+

| skip_external_locking  | ON    |

| skip_name_resolve      | OFF   |

| skip_networking        | OFF   |

| skip_show_database     | OFF   |

| slave_skip_errors      | OFF   |

| sql_slave_skip_counter | 0     |

+------------------------+-------+

6 rows in set (0.00 sec)

  

mysql> show variables like '%sync_relay%';

+---------------------+-------+

| Variable_name       | Value |

+---------------------+-------+

| sync_relay_log      | 10000 |

| sync_relay_log_info | 10000 |

+---------------------+-------+

2 rows in set (0.00 sec)

  

mysql> show variables like '%relay%';  

+---------------------------+--------------------------------------+

| Variable_name             | Value                                |

+---------------------------+--------------------------------------+

| max_relay_log_size        | 0                                    |

| relay_log                 | /var/lib/mysql/mysql-relay-bin       |

| relay_log_basename        | /var/lib/mysql/mysql-relay-bin       |

| relay_log_index           | /var/lib/mysql/mysql-relay-bin.index |

| relay_log_info_file       | relay-log.info                       |

| relay_log_info_repository | TABLE                                |

| relay_log_purge           | ON                                   |

| relay_log_recovery        | OFF                                  |

| relay_log_space_limit     | 0                                    |

| sync_relay_log            | 10000                                |

| sync_relay_log_info       | 10000                                |

+---------------------------+--------------------------------------+

11 rows in set (0.00 sec)

  

mysql> show variables like '%master%';

+------------------------+-------+

| Variable_name          | Value |

+------------------------+-------+

| master_info_repository | TABLE |

| master_verify_checksum | OFF   |

| sync_master_info       | 10000 |

+------------------------+-------+

3 rows in set (0.00 sec)

  

###

root@mysql 10:24:  [(none)]> show variables like '%super%';

+-----------------+-------+

| Variable_name   | Value |

+-----------------+-------+

| super_read_only | OFF   |

+-----------------+-------+

1 row in set (0.00 sec)

root@mysql 10:26:  [(none)]> show variables like 'read_only';

+---------------+-------+

| Variable_name | Value |

+---------------+-------+

| read_only     | OFF   |

+---------------+-------+

1 row in set (0.00 sec)

  

  

mysql> show slave hosts;

+-----------+------+------+-----------+--------------------------------------+

| Server_id | Host | Port | Master_id | Slave_UUID                           |

+-----------+------+------+-----------+--------------------------------------+

|         2 |      | 3306 |         1 | 7657c51c-0c89-11e8-8d27-000c29e60559 |

+-----------+------+------+-----------+--------------------------------------+

1 row in set (0.00 sec)

  

#mysqldump:mysql备份

 mysqldump -uroot -poracle -B -A --events -x |gzip>/app/mysqlbak_$(date
+%F_%T).sql.gz

  

 mysqldump -uroot -poracle -B -A --events -x |gzip>/app/mysqlbak_`date
+%F_%T`.sql.gz

  

 mysqldump -uroot -poracle -B  \--events -x
wordpress|gzip>/app/mysqlbak_`date +%F_%T`.sql.gz

  

#mysql刷新权限

flush privileges;  

  

![noteattachment53][81f57e3c142623922304fe54f1051fe9]
![noteattachment54][03cb9aa9c9cc549aec4cb2847f1377df]

  

  

mysql> show engine innodb status\G

*************************** 1. row ***************************

  Type: InnoDB

  Name:

Status:

=====================================

2018-04-13 08:32:48 0x7fdfde5fa700 INNODB MONITOR OUTPUT

=====================================

Per second averages calculated from the last 4 seconds

\-----------------

BACKGROUND THREAD

\-----------------

srv_master_thread loops: 5 srv_active, 0 srv_shutdown, 486 srv_idle

srv_master_thread log flush and writes: 491

\----------

SEMAPHORES

\----------

OS WAIT ARRAY INFO: reservation count 135

OS WAIT ARRAY INFO: signal count 133

RW-shared spins 0, rounds 12, OS waits 6

RW-excl spins 0, rounds 60, OS waits 2

RW-sx spins 0, rounds 0, OS waits 0

Spin rounds per wait: 12.00 RW-shared, 60.00 RW-excl, 0.00 RW-sx

\------------

TRANSACTIONS

\------------

Trx id counter 15238

Purge done for trx's n:o < 15237 undo n:o < 0 state: running but idle

History list length 18

LIST OF TRANSACTIONS FOR EACH SESSION:

\---TRANSACTION 422074637217392, not started

0 lock struct(s), heap size 1136, 0 row lock(s)

\---TRANSACTION 422074637216480, not started

0 lock struct(s), heap size 1136, 0 row lock(s)

\---TRANSACTION 422074637215568, not started

0 lock struct(s), heap size 1136, 0 row lock(s)

\--------

FILE I/O

\--------

I/O thread 0 state: waiting for completed aio requests (insert buffer thread)

I/O thread 1 state: waiting for completed aio requests (log thread)

I/O thread 2 state: waiting for completed aio requests (read thread)

I/O thread 3 state: waiting for completed aio requests (read thread)

I/O thread 4 state: waiting for completed aio requests (read thread)

I/O thread 5 state: waiting for completed aio requests (read thread)

I/O thread 6 state: waiting for completed aio requests (write thread)

I/O thread 7 state: waiting for completed aio requests (write thread)

I/O thread 8 state: waiting for completed aio requests (write thread)

I/O thread 9 state: waiting for completed aio requests (write thread)

Pending normal aio reads: [0, 0, 0, 0] , aio writes: [0, 0, 0, 0] ,

ibuf aio reads:, log i/o's:, sync i/o's:

Pending flushes (fsync) log: 0; buffer pool: 0

459 OS file reads, 219 OS file writes, 86 OS fsyncs

0.00 reads/s, 0 avg bytes/read, 0.00 writes/s, 0.00 fsyncs/s

\-------------------------------------

INSERT BUFFER AND ADAPTIVE HASH INDEX

\-------------------------------------

Ibuf: size 1, free list len 0, seg size 2, 0 merges

merged operations:

insert 0, delete mark 0, delete 0

discarded operations:

insert 0, delete mark 0, delete 0

Hash table size 34673, node heap has 0 buffer(s)

Hash table size 34673, node heap has 0 buffer(s)

Hash table size 34673, node heap has 0 buffer(s)

Hash table size 34673, node heap has 0 buffer(s)

Hash table size 34673, node heap has 0 buffer(s)

Hash table size 34673, node heap has 0 buffer(s)

Hash table size 34673, node heap has 0 buffer(s)

Hash table size 34673, node heap has 0 buffer(s)

0.00 hash searches/s, 0.00 non-hash searches/s

\---

LOG

\---

Log sequence number 5543009

Log flushed up to   5543009

Pages flushed up to 5543009

Last checkpoint at  5543000

0 pending log flushes, 0 pending chkp writes

80 log i/o's done, 0.00 log i/o's/second

\----------------------

BUFFER POOL AND MEMORY

\----------------------

Total large memory allocated 137428992

Dictionary memory allocated 145206

Buffer pool size   8191

Free buffers       7733

Database pages     458

Old database pages 0

Modified db pages  0

Pending reads      0

Pending writes: LRU 0, flush list 0, single page 0

Pages made young 0, not young 0

0.00 youngs/s, 0.00 non-youngs/s

Pages read 420, created 38, written 129

0.00 reads/s, 0.00 creates/s, 0.00 writes/s

No buffer pool page gets since the last printout

Pages read ahead 0.00/s, evicted without access 0.00/s, Random read ahead
0.00/s

LRU len: 458, unzip_LRU len: 0

I/O sum[0]:cur[0], unzip sum[0]:cur[0]

\--------------

ROW OPERATIONS

\--------------

0 queries inside InnoDB, 0 queries in queue

0 read views open inside InnoDB

Process ID=1591, Main thread ID=140599331071744, state: sleeping

Number of rows inserted 45, updated 112, deleted 0, read 186

0.00 inserts/s, 0.00 updates/s, 0.00 deletes/s, 0.00 reads/s

\----------------------------

END OF INNODB MONITOR OUTPUT

============================

  

1 row in set (0.00 sec)

  

  

  

mysql> INSTALL PLUGIN rpl_semi_sync_slave SONAME 'semisync_slave.so';

Query OK, 0 rows affected (0.41 sec)

  

  

mysql> INSTALL PLUGIN rpl_semi_sync_master SONAME 'semisync_master.so';

  

  

mysql> show plugins;

+----------------------------+----------+--------------------+----------------------+---------+

| Name                       | Status   | Type               | Library
| License |

+----------------------------+----------+--------------------+----------------------+---------+

| binlog                     | ACTIVE   | STORAGE ENGINE     | NULL
| GPL     |

| mysql_native_password      | ACTIVE   | AUTHENTICATION     | NULL
| GPL     |

| sha256_password            | ACTIVE   | AUTHENTICATION     | NULL
| GPL     |

| CSV                        | ACTIVE   | STORAGE ENGINE     | NULL
| GPL     |

| MyISAM                     | ACTIVE   | STORAGE ENGINE     | NULL
| GPL     |

| MRG_MYISAM                 | ACTIVE   | STORAGE ENGINE     | NULL
| GPL     |

| PERFORMANCE_SCHEMA         | ACTIVE   | STORAGE ENGINE     | NULL
| GPL     |

| MEMORY                     | ACTIVE   | STORAGE ENGINE     | NULL
| GPL     |

| InnoDB                     | ACTIVE   | STORAGE ENGINE     | NULL
| GPL     |

| INNODB_TRX                 | ACTIVE   | INFORMATION SCHEMA | NULL
| GPL     |

| INNODB_LOCKS               | ACTIVE   | INFORMATION SCHEMA | NULL
| GPL     |

| INNODB_LOCK_WAITS          | ACTIVE   | INFORMATION SCHEMA | NULL
| GPL     |

| INNODB_CMP                 | ACTIVE   | INFORMATION SCHEMA | NULL
| GPL     |

| INNODB_CMP_RESET           | ACTIVE   | INFORMATION SCHEMA | NULL
| GPL     |

| INNODB_CMPMEM              | ACTIVE   | INFORMATION SCHEMA | NULL
| GPL     |

| INNODB_CMPMEM_RESET        | ACTIVE   | INFORMATION SCHEMA | NULL
| GPL     |

| INNODB_CMP_PER_INDEX       | ACTIVE   | INFORMATION SCHEMA | NULL
| GPL     |

| INNODB_CMP_PER_INDEX_RESET | ACTIVE   | INFORMATION SCHEMA | NULL
| GPL     |

| INNODB_BUFFER_PAGE         | ACTIVE   | INFORMATION SCHEMA | NULL
| GPL     |

| INNODB_BUFFER_PAGE_LRU     | ACTIVE   | INFORMATION SCHEMA | NULL
| GPL     |

| INNODB_BUFFER_POOL_STATS   | ACTIVE   | INFORMATION SCHEMA | NULL
| GPL     |

| INNODB_TEMP_TABLE_INFO     | ACTIVE   | INFORMATION SCHEMA | NULL
| GPL     |

| INNODB_METRICS             | ACTIVE   | INFORMATION SCHEMA | NULL
| GPL     |

| INNODB_FT_DEFAULT_STOPWORD | ACTIVE   | INFORMATION SCHEMA | NULL
| GPL     |

| INNODB_FT_DELETED          | ACTIVE   | INFORMATION SCHEMA | NULL
| GPL     |

| INNODB_FT_BEING_DELETED    | ACTIVE   | INFORMATION SCHEMA | NULL
| GPL     |

| INNODB_FT_CONFIG           | ACTIVE   | INFORMATION SCHEMA | NULL
| GPL     |

| INNODB_FT_INDEX_CACHE      | ACTIVE   | INFORMATION SCHEMA | NULL
| GPL     |

| INNODB_FT_INDEX_TABLE      | ACTIVE   | INFORMATION SCHEMA | NULL
| GPL     |

| INNODB_SYS_TABLES          | ACTIVE   | INFORMATION SCHEMA | NULL
| GPL     |

| INNODB_SYS_TABLESTATS      | ACTIVE   | INFORMATION SCHEMA | NULL
| GPL     |

| INNODB_SYS_INDEXES         | ACTIVE   | INFORMATION SCHEMA | NULL
| GPL     |

| INNODB_SYS_COLUMNS         | ACTIVE   | INFORMATION SCHEMA | NULL
| GPL     |

| INNODB_SYS_FIELDS          | ACTIVE   | INFORMATION SCHEMA | NULL
| GPL     |

| INNODB_SYS_FOREIGN         | ACTIVE   | INFORMATION SCHEMA | NULL
| GPL     |

| INNODB_SYS_FOREIGN_COLS    | ACTIVE   | INFORMATION SCHEMA | NULL
| GPL     |

| INNODB_SYS_TABLESPACES     | ACTIVE   | INFORMATION SCHEMA | NULL
| GPL     |

| INNODB_SYS_DATAFILES       | ACTIVE   | INFORMATION SCHEMA | NULL
| GPL     |

| INNODB_SYS_VIRTUAL         | ACTIVE   | INFORMATION SCHEMA | NULL
| GPL     |

| partition                  | ACTIVE   | STORAGE ENGINE     | NULL
| GPL     |

| ARCHIVE                    | ACTIVE   | STORAGE ENGINE     | NULL
| GPL     |

| FEDERATED                  | DISABLED | STORAGE ENGINE     | NULL
| GPL     |

| BLACKHOLE                  | ACTIVE   | STORAGE ENGINE     | NULL
| GPL     |

| ngram                      | ACTIVE   | FTPARSER           | NULL
| GPL     |

| validate_password          | DISABLED | VALIDATE PASSWORD  |
validate_password.so | GPL     |

| rpl_semi_sync_master       | ACTIVE   | REPLICATION        |
semisync_master.so   | GPL     |

+----------------------------+----------+--------------------+----------------------+---------+

46 rows in set (0.00 sec)

  

root@mysql 13:46:  [(none)]> show variables like
'slave_rows_search_algorithms';

+------------------------------+-----------------------+

| Variable_name                | Value                 |

+------------------------------+-----------------------+

| slave_rows_search_algorithms | TABLE_SCAN,INDEX_SCAN |

+------------------------------+-----------------------+

1 row in set (0.00 sec)

  

root@mysql 13:50:  [(none)]> show global status like '%rpl%';

+--------------------------------------------+-------+

| Variable_name                              | Value |

+--------------------------------------------+-------+

| Rpl_semi_sync_master_clients               | 0     |

| Rpl_semi_sync_master_net_avg_wait_time     | 0     |

| Rpl_semi_sync_master_net_wait_time         | 0     |

| Rpl_semi_sync_master_net_waits             | 0     |

| Rpl_semi_sync_master_no_times              | 0     |

| Rpl_semi_sync_master_no_tx                 | 0     |

| Rpl_semi_sync_master_status                | ON    |

| Rpl_semi_sync_master_timefunc_failures     | 0     |

| Rpl_semi_sync_master_tx_avg_wait_time      | 0     |

| Rpl_semi_sync_master_tx_wait_time          | 0     |

| Rpl_semi_sync_master_tx_waits              | 0     |

| Rpl_semi_sync_master_wait_pos_backtraverse | 0     |

| Rpl_semi_sync_master_wait_sessions         | 0     |

| Rpl_semi_sync_master_yes_tx                | 0     |

| Rpl_semi_sync_slave_status                 | OFF   |

+--------------------------------------------+-------+

15 rows in set (0.00 sec)

  

  

mysql> stop slave io_thread;

Query OK, 0 rows affected, 1 warning (0.00 sec)

  

mysql> stop slave sql_thread;  

Query OK, 0 rows affected, 1 warning (0.00 sec)

  

  

###针对某个DB复制

[\--replicate-do-db=](https://dev.mysql.com/doc/refman/5.7/en/replication-
options-slave.html#option_mysqld_replicate-do-
db)[db_name](https://dev.mysql.com/doc/refman/5.7/en/replication-options-
slave.html#option_mysqld_replicate-do-db)

  

###mysql

[root@master ~]#  mysqlreplicate --master=root:oracle@192.168.45.32:3306
--slave=root:oracle@192.168.45.33:3306 --rpl-user=repl:oracle

WARNING: Using a password on the command line interface can be insecure.

# master on 192.168.45.32: ... connected.

# slave on 192.168.45.33: ... connected.

# Checking for binary logging on master...

# Setting up replication...

# ...done.

  

#mysqlreplicate --master=root:oracle@192.168.45.32:3306
--slave=root:oracle@192.168.45.33:3306 --rpl-user=repl:oracle for channel
'ch1'

  

mysql> reset slave all;

Query OK, 0 rows affected (0.02 sec)

  

[root@master ~]# mysqlrplcheck --master=root:oracle@localhost:3306
--slave=root:oracle@192.168.45.33:3306

WARNING: Using a password on the command line interface can be insecure.

# master on localhost: ... connected.

# slave on 192.168.45.33: ... connected.

Test Description                                                     Status

\---------------------------------------------------------------------------

Checking for binary logging on master                                [pass]

Are there binlog exceptions?                                         [pass]

Replication user exists?                                             [pass]

Checking server_id values                                            [pass]

Checking server_uuid values                                          [pass]

Is slave connected to master?                                        [pass]

Check master information file                                        [pass]

Checking InnoDB compatibility                                        [pass]

Checking storage engines compatibility                               [pass]

Checking lower_case_table_names settings                             [pass]

Checking slave delay (seconds behind master)                         [pass]

# ...done.

  

###需备份二进制日志

mysql> show master status;

+------------------+----------+--------------+------------------+----------------------------------------------+

| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB |
Executed_Gtid_Set                            |

+------------------+----------+--------------+------------------+----------------------------------------------+

| mysql-bin.000020 |  8533959 |              |                  |
7d0e42b6-0c89-11e8-90d8-000c292c7e58:1-23949 |

+------------------+----------+--------------+------------------+----------------------------------------------+

1 row in set (0.00 sec)

  

  

mysql> reset master;

Query OK, 0 rows affected (0.03 sec)

  

mysql> show master status;

+------------------+----------+--------------+------------------+------------------------------------------+

| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB |
Executed_Gtid_Set                        |

+------------------+----------+--------------+------------------+------------------------------------------+

| mysql-bin.000001 |     1694 |              |                  |
7d0e42b6-0c89-11e8-90d8-000c292c7e58:1-4 |

+------------------+----------+--------------+------------------+------------------------------------------+

1 row in set (0.00 sec)

  

start slave for channel ch1

  

###计算列

root@mysql 16:31:  [mytest]> create table t4 (id int auto_increment not
null,c1 int,c2 int,c3 int,primary key (id));

Query OK, 0 rows affected (5.62 sec)

  

  

root@mysql 16:33:  [mytest]> create trigger inst_t4 before insert on t4 for
each row set new.c3=new.c1+new.c2;

Query OK, 0 rows affected (0.38 sec)

  

root@mysql 16:35:  [mytest]> show triggers;

+---------+--------+-------+--------------------------+--------+------------------------+------------------------------------------------------------------------------------------------------------------------+----------------+----------------------+----------------------+--------------------+

| Trigger | Event  | Table | Statement                | Timing | Created
| sql_mode
| Definer        | character_set_client | collation_connection | Database
Collation |

+---------+--------+-------+--------------------------+--------+------------------------+------------------------------------------------------------------------------------------------------------------------+----------------+----------------------+----------------------+--------------------+

| inst_t4 | INSERT | t4    | set new.c3=new.c1+new.c2 | BEFORE | 2018-04-16
16:35:51.20 |
STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION
| root@localhost | utf8                 | utf8_general_ci      |
utf8mb4_general_ci |

+---------+--------+-------+--------------------------+--------+------------------------+------------------------------------------------------------------------------------------------------------------------+----------------+----------------------+----------------------+--------------------+

1 row in set (0.00 sec)

  

root@mysql 16:36:  [mytest]> insert into t(c1,c2) values (1,2);

ERROR 1146 (42S02): Table 'mytest.t' doesn't exist

root@mysql 16:37:  [mytest]> insert into t4(c1,c2) values (1,2);

Query OK, 1 row affected (0.01 sec)

  

root@mysql 16:37:  [mytest]> select * from t4;

+----+------+------+------+

| id | c1   | c2   | c3   |

+----+------+------+------+

|  1 |    1 |    2 |    3 |

+----+------+------+------+

1 row in set (0.00 sec)

  

root@mysql 16:37:  [mytest]> insert into t4(c1,c2) values (2,3);

Query OK, 1 row affected (0.34 sec)

  

root@mysql 16:37:  [mytest]> select * from t4;

+----+------+------+------+

| id | c1   | c2   | c3   |

+----+------+------+------+

|  1 |    1 |    2 |    3 |

|  2 |    2 |    3 |    5 |

+----+------+------+------+

2 rows in set (0.00 sec)

  

root@mysql 16:39:  [mytest]> create trigger upd_t4 before update on t4 for
each row set new.c3=new.c1+new.c2;  

Query OK, 0 rows affected (0.00 sec)

  

root@mysql 16:41:  [mytest]> show triggers;

+---------+--------+-------+--------------------------+--------+------------------------+------------------------------------------------------------------------------------------------------------------------+----------------+----------------------+----------------------+--------------------+

| Trigger | Event  | Table | Statement                | Timing | Created
| sql_mode
| Definer        | character_set_client | collation_connection | Database
Collation |

+---------+--------+-------+--------------------------+--------+------------------------+------------------------------------------------------------------------------------------------------------------------+----------------+----------------------+----------------------+--------------------+

| inst_t4 | INSERT | t4    | set new.c3=new.c1+new.c2 | BEFORE | 2018-04-16
16:35:51.20 |
STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION
| root@localhost | utf8                 | utf8_general_ci      |
utf8mb4_general_ci |

| upd_t4  | UPDATE | t4    | set new.c3=new.c1+new.c2 | BEFORE | 2018-04-16
16:40:40.44 |
STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION
| root@localhost | utf8                 | utf8_general_ci      |
utf8mb4_general_ci |

+---------+--------+-------+--------------------------+--------+------------------------+------------------------------------------------------------------------------------------------------------------------+----------------+----------------------+----------------------+--------------------+

2 rows in set (0.00 sec)

  

root@mysql 16:42:  [mytest]> update t4 set c1=5 where id=2;  

Query OK, 1 row affected (0.00 sec)

Rows matched: 1  Changed: 1  Warnings: 0

  

root@mysql 16:43:  [mytest]> select * from t4;

+----+------+------+------+

| id | c1   | c2   | c3   |

+----+------+------+------+

|  1 |    1 |    2 |    3 |

|  2 |    5 |    3 |    8 |

+----+------+------+------+

2 rows in set (0.00 sec)

  

root@mysql 16:45:  [mytest]> create view vw_t4 as select id,c1,c2,c1+c2 as c3
from t4;

Query OK, 0 rows affected (0.34 sec)

  

root@mysql 16:45:  [mytest]> select * from  vw_t4;

+----+------+------+------+

| id | c1   | c2   | c3   |

+----+------+------+------+

|  1 |    1 |    2 |    3 |

|  2 |    5 |    3 |    8 |

+----+------+------+------+

2 rows in set (0.00 sec)

  

root@mysql 16:47:  [mytest]> create table t6 (id int auto_increment not
null,c1 int,c2 int,c3 int as (c1+c2),primary key (id));  

Query OK, 0 rows affected (0.55 sec)

  

root@mysql 16:48:  [mytest]> show create table t6;

+-------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

| Table | Create Table
|

+-------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

| t6    | CREATE TABLE `t6` (

  `id` int(11) NOT NULL AUTO_INCREMENT,

  `c1` int(11) DEFAULT NULL,

  `c2` int(11) DEFAULT NULL,

  `c3` int(11) GENERATED ALWAYS AS ((`c1` + `c2`)) VIRTUAL,

  PRIMARY KEY (`id`)

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 |

+-------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

1 row in set (0.00 sec)

root@mysql 16:49:  [mytest]> insert into t6(c1,c2) values(1,2);

Query OK, 1 row affected (0.34 sec)

  

root@mysql 16:49:  [mytest]> select * from t6;

+----+------+------+------+

| id | c1   | c2   | c3   |

+----+------+------+------+

|  1 |    1 |    2 |    3 |

+----+------+------+------+

1 row in set (0.00 sec)

  

root@mysql 16:50:  [mytest]> select * from t6;

+----+------+------+------+

| id | c1   | c2   | c3   |

+----+------+------+------+

|  1 |    5 |    2 |    7 |

+----+------+------+------+

1 row in set (0.00 sec)

  

root@mysql 16:50:  [mytest]> show triggers;

+---------+--------+-------+--------------------------+--------+------------------------+------------------------------------------------------------------------------------------------------------------------+----------------+----------------------+----------------------+--------------------+

| Trigger | Event  | Table | Statement                | Timing | Created
| sql_mode
| Definer        | character_set_client | collation_connection | Database
Collation |

+---------+--------+-------+--------------------------+--------+------------------------+------------------------------------------------------------------------------------------------------------------------+----------------+----------------------+----------------------+--------------------+

| inst_t4 | INSERT | t4    | set new.c3=new.c1+new.c2 | BEFORE | 2018-04-16
16:35:51.20 |
STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION
| root@localhost | utf8                 | utf8_general_ci      |
utf8mb4_general_ci |

| upd_t4  | UPDATE | t4    | set new.c3=new.c1+new.c2 | BEFORE | 2018-04-16
16:40:40.44 |
STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION
| root@localhost | utf8                 | utf8_general_ci      |
utf8mb4_general_ci |

+---------+--------+-------+--------------------------+--------+------------------------+------------------------------------------------------------------------------------------------------------------------+----------------+----------------------+----------------------+--------------------+

2 rows in set (0.00 sec)

  

  

###json

root@mysql 16:54:  [mytest]> select json_array('a','b',now());

+------------------------------------------+

| json_array('a','b',now())                |

+------------------------------------------+

| ["a", "b", "2018-04-16 16:54:11.000000"] |

+------------------------------------------+

1 row in set (0.13 sec)

root@mysql 16:55:  [mytest]> select json_object('key1',1,'key2',2);

+--------------------------------+

| json_object('key1',1,'key2',2) |

+--------------------------------+

| {"key1": 1, "key2": 2}         |

+--------------------------------+

1 row in set (0.00 sec)

root@mysql 16:57:  [mytest]> create table t7(jdoc json);

Query OK, 0 rows affected (0.38 sec)

  

root@mysql 16:57:  [mytest]> show create table t7;

+-------+----------------------------------------------------------------------------------------+

| Table | Create Table
|

+-------+----------------------------------------------------------------------------------------+

| t7    | CREATE TABLE `t7` (

  `jdoc` json DEFAULT NULL

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 |

+-------+----------------------------------------------------------------------------------------+

1 row in set (0.00 sec)

  

root@mysql 16:57:  [mytest]> insert into t7(jdoc)
values(json_array('a','b',now()));

Query OK, 1 row affected (0.34 sec)

  

root@mysql 16:59:  [mytest]> select * from t7;

+------------------------------------------+

| jdoc                                     |

+------------------------------------------+

| ["a", "b", "2018-04-16 16:59:04.000000"] |

+------------------------------------------+

1 row in set (0.00 sec)

  

  

![noteattachment55][b22837f1fc10d4d01bce5866dedbe5cc]

![noteattachment56][213df5c006b80d812c7da94f57fad247]

root@mysql 17:07:  [mytest]> show variables like 'innodb_buffer_pool%';

+-------------------------------------+----------------+

| Variable_name                       | Value          |

+-------------------------------------+----------------+

| innodb_buffer_pool_chunk_size       | 134217728      |

| innodb_buffer_pool_dump_at_shutdown | ON             |

| innodb_buffer_pool_dump_now         | OFF            |

| innodb_buffer_pool_dump_pct         | 40             |

| innodb_buffer_pool_filename         | ib_buffer_pool |

| innodb_buffer_pool_instances        | 8              |

| innodb_buffer_pool_load_abort       | OFF            |

| innodb_buffer_pool_load_at_startup  | ON             |

| innodb_buffer_pool_load_now         | OFF            |

| innodb_buffer_pool_size             | 6442450944     |

+-------------------------------------+----------------+

10 rows in set (0.00 sec)

  

root@mysql 17:07:  [mytest]> select  134217728/1024/1024

    -> ;

+---------------------+

| 134217728/1024/1024 |

+---------------------+

|        128.00000000 |

+---------------------+

1 row in set (0.00 sec)

  

  

![noteattachment57][54e200c0d9c867cab2a1c165ce8c8906]

  

root@mysql 17:07:  [mytest]> show variables like 'innodb_buffer_pool%';

+-------------------------------------+----------------+

| Variable_name                       | Value          |

+-------------------------------------+----------------+

| innodb_buffer_pool_chunk_size       | 134217728      |

| innodb_buffer_pool_dump_at_shutdown | ON             |

| innodb_buffer_pool_dump_now         | OFF            |

| innodb_buffer_pool_dump_pct         | 40             |

| innodb_buffer_pool_filename         | ib_buffer_pool |

| innodb_buffer_pool_instances        | 8              |

| innodb_buffer_pool_load_abort       | OFF            |

| innodb_buffer_pool_load_at_startup  | ON             |

| innodb_buffer_pool_load_now         | OFF            |

| innodb_buffer_pool_size             | 6442450944     |

+-------------------------------------+----------------+

10 rows in set (0.00 sec)

  

root@mysql 17:07:  [mytest]> select  134217728/1024/1024

    -> ;

+---------------------+

| 134217728/1024/1024 |

+---------------------+

|        128.00000000 |

+---------------------+

1 row in set (0.00 sec)

  

root@mysql 17:08:  [mytest]> set global innodb_buffer_pool_dump_now=on;

Query OK, 0 rows affected (0.00 sec)

  

#ll /data

-rw-r----- 1 mysql mysql       1869 Apr 16 17:12 ib_buffer_pool

  

  

root@mysql 17:14:  [mytest]> create tablespace ts1 add datafile 'ts1.ibd'
engine=innodb;

Query OK, 0 rows affected (0.39 sec)

  

root@mysql 17:23:  [mytest]> create table t8 (c1 int,primary key(c1))
tablespace ts1 ;

Query OK, 0 rows affected (0.64 sec)

root@mysql 17:23:  [mytest]> show create table t8;

+-------+----------------------------------------------------------------------------------------------------------------------------------------+

| Table | Create Table
|

+-------+----------------------------------------------------------------------------------------------------------------------------------------+

| t8    | CREATE TABLE `t8` (

  `c1` int(11) NOT NULL,

  PRIMARY KEY (`c1`)

) /*!50100 TABLESPACE `ts1` */ ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 |

+-------+----------------------------------------------------------------------------------------------------------------------------------------+

1 row in set (0.00 sec)

  

###密码有效期

root@mysql 15:17:  [mytest]>  show variables like 'default_password_lifetime';

+---------------------------+-------+

| Variable_name             | Value |

+---------------------------+-------+

| default_password_lifetime | 0     |

+---------------------------+-------+

1 row in set (0.00 sec)

  

###numa

[root@centos ~]# numactl --hardware

available: 1 nodes (0)

node 0 cpus: 0 1

node 0 size: 4095 MB

node 0 free: 2645 MB

node distances:

node   0

  0:  10

  

  

###innodb buffer pool hit rate

That's the Hit Rate since [Uptime (Last MySQL
Startup)](http://dev.mysql.com/doc/refman/5.6/en/server-status-
variables.html#statvar_Uptime)

There are two things you can do to get the Last 10 Minutes

# METHOD #1

Flush all Status Values, Sleep 10 min, Run Query

FLUSH STATUS;SELECT SLEEP(600) INTO @x;SELECT round ((P2.variable_value /
P1.variable_value),4),

P2.variable_value, P1.variable_value

FROM information_schema.GLOBAL_STATUS P1,

information_schema.GLOBAL_STATUS P2

WHERE P1. variable_name = 'innodb_buffer_pool_read_requests'AND P2.
variable_name = 'innodb_buffer_pool_reads';

# METHOD #2

Capture
[innodb_buffer_pool_read_requests](http://dev.mysql.com/doc/refman/5.6/en/server-
status-variables.html#statvar_Innodb_buffer_pool_read_requests),
[innodb_buffer_pool_reads](http://dev.mysql.com/doc/refman/5.6/en/server-
status-variables.html#statvar_Innodb_buffer_pool_reads), Sleep 10 minutes, Run
Query with Differences in innodb_buffer_pool_read_requests and
innodb_buffer_pool_reads

SELECT

P1.variable_value,P2.variable_value

INTO

@rqs,@rds

FROM information_schema.GLOBAL_STATUS P1,

information_schema.GLOBAL_STATUS P2

WHERE P1.variable_name = 'innodb_buffer_pool_read_requests'AND
P2.variable_name = 'innodb_buffer_pool_reads';

SELECT SLEEP(600) INTO @x;SELECT round (((P2.variable_value - @rds) /
(P1.variable_value - @rqs)),4),

P2.variable_value, P1.variable_value

FROM information_schema.GLOBAL_STATUS P1,

information_schema.GLOBAL_STATUS P2

WHERE P1.variable_name = 'innodb_buffer_pool_read_requests'AND
P2.variable_name = 'innodb_buffer_pool_reads';

  

###

验证唯一性

Oracle null可以多个

mysql  null只能一个

  

  

###

oracle mysql 5.7.22，去掉--flush-logs，只使用mysqldump -uroot -proot --default-
character-set=utf8  \--single-transaction --master-data=2 备份，也是会发出FLUSH TABLES
WITH READ LOCK

  

  

###

今日讨论，你都用了什么方法防止误删数据？

  

答：

根据白天大家的讨论，总结共有以下几个措施，供参考：

1\. 生产环境中，业务代码尽量不明文保存数据库连接账号密码信息；

2\. 重要的DML、DDL通过平台型工具自动实施，减少人工操作；

3\. 部署延迟复制从库，万一误删除时用于数据回档。且从库设置为read-only；

4\. 确认备份制度及时有效；

5\. 启用SQL审计功能，养成良好SQL习惯；

6\. 启用 sql_safe_updates 选项，不允许没 WHERE 条件的更新/删除；

7\. 将系统层的 rm 改为 mv；

8\. 线上不进行物理删除，改为逻辑删除（将row data标记为不可用）；

9\. 启用堡垒机，屏蔽高危SQL；

10\. 降低数据库中普通账号的权限级别；

11\. 务必开启binlog。

  


---
### ATTACHMENTS
[f9327280641c0dccbbbe2520e830f4c0]: media/MySQL整理.png
[MySQL整理.png](media/MySQL整理.png)
[c65eb56246a64df6da71409074f0e85a]: media/MySQL整理-2.png
[MySQL整理-2.png](media/MySQL整理-2.png)
[56313609b13add132c9effbf65e4f86e]: media/MySQL整理-3.png
[MySQL整理-3.png](media/MySQL整理-3.png)
[347ace51f5942a59bcca2ec63e42eb4f]: media/MySQL整理-4.png
[MySQL整理-4.png](media/MySQL整理-4.png)
[a112e7db8cd73e6303fc2e12e994fb6c]: media/MySQL整理-5.png
[MySQL整理-5.png](media/MySQL整理-5.png)
[77da206d31cce314446656cfc6a5ebdb]: media/MySQL整理-6.png
[MySQL整理-6.png](media/MySQL整理-6.png)
[2740b287b97860159ede48d784b76dc5]: media/MySQL整理-7.png
[MySQL整理-7.png](media/MySQL整理-7.png)
[99f991e341667f0c8067d64f6795a42e]: media/MySQL整理-8.png
[MySQL整理-8.png](media/MySQL整理-8.png)
[d91edde81572cfb976a2e2abbd29ad64]: media/MySQL整理-9.png
[MySQL整理-9.png](media/MySQL整理-9.png)
[9374b5b462e91fefde58174446708acd]: media/MySQL整理-10.png
[MySQL整理-10.png](media/MySQL整理-10.png)
[d6218f5e9be1083999ad238751ebd6a1]: media/MySQL整理-11.png
[MySQL整理-11.png](media/MySQL整理-11.png)
[52d56f231bfd97c73d5dd9fe4630f553]: media/MySQL整理-12.png
[MySQL整理-12.png](media/MySQL整理-12.png)
[1208e5d9710256c4e829f8e0500c4fcf]: media/MySQL整理-13.png
[MySQL整理-13.png](media/MySQL整理-13.png)
[3c0c87b337fc0b0df4ae812b88911bed]: media/MySQL整理-14.png
[MySQL整理-14.png](media/MySQL整理-14.png)
[c6661830b9ac60a3df4fb6951cb966ee]: media/MySQL整理-15.png
[MySQL整理-15.png](media/MySQL整理-15.png)
[c40eeafa74d6bf1b3b71b77d88d7b411]: media/MySQL整理-16.png
[MySQL整理-16.png](media/MySQL整理-16.png)
[a28dc7856eaa6399f54306e55d13bf7d]: media/MySQL整理-17.png
[MySQL整理-17.png](media/MySQL整理-17.png)
[cddae9341ffd7e14d741f01a8023d192]: media/MySQL整理-18.png
[MySQL整理-18.png](media/MySQL整理-18.png)
[4db2a11199d92278f5e4fbb7653e9635]: media/MySQL整理-19.png
[MySQL整理-19.png](media/MySQL整理-19.png)
[5e9baa424ae4f033a55fea6ea478c77d]: media/MySQL整理-20.png
[MySQL整理-20.png](media/MySQL整理-20.png)
[0a64f7d75a182db132b1a5acf9e5536f]: media/MySQL整理-21.png
[MySQL整理-21.png](media/MySQL整理-21.png)
[f30745ce3dd6df1f1477d5161aed5c6e]: media/MySQL整理-22.png
[MySQL整理-22.png](media/MySQL整理-22.png)
[edc31deeb57a91ea649afc51141abd30]: media/MySQL整理-23.png
[MySQL整理-23.png](media/MySQL整理-23.png)
[aaa9d4ece925d8e840cafda88a0f7934]: media/MySQL整理-24.png
[MySQL整理-24.png](media/MySQL整理-24.png)
[bb3fb69a89836aed51f80301862cd45a]: media/MySQL整理-25.png
[MySQL整理-25.png](media/MySQL整理-25.png)
[553c7b70eb66c1b289297d72cfd90bbd]: media/MySQL整理-26.png
[MySQL整理-26.png](media/MySQL整理-26.png)
[06e70a4f1a6d1ee1abf065602e54b109]: media/MySQL整理-27.png
[MySQL整理-27.png](media/MySQL整理-27.png)
[3b4ce80c5cea6ab4f760521e2b7a8674]: media/MySQL整理-28.png
[MySQL整理-28.png](media/MySQL整理-28.png)
[98b50f6da23710c319b94ba82be81a5e]: media/MySQL整理-29.png
[MySQL整理-29.png](media/MySQL整理-29.png)
[5d513401d052ce6d5a2caa1153f4651a]: media/MySQL整理-30.png
[MySQL整理-30.png](media/MySQL整理-30.png)
[923cd4af9ecb22786f91f0aeb0307e56]: media/MySQL整理-31.png
[MySQL整理-31.png](media/MySQL整理-31.png)
[1c9d3b43bfd15c94f5f37bacf5f8f3a4]: media/MySQL整理-32.png
[MySQL整理-32.png](media/MySQL整理-32.png)
[95ceeae0b1b2cff025e8c049f7f914f6]: media/MySQL整理-33.png
[MySQL整理-33.png](media/MySQL整理-33.png)
[4073f4ea77d6c63c68a39c725c297694]: media/MySQL整理-34.png
[MySQL整理-34.png](media/MySQL整理-34.png)
[1aa4314bdb9c45f80250b6859b5d7dd9]: media/MySQL整理-35.png
[MySQL整理-35.png](media/MySQL整理-35.png)
[c4aaab7faa785e8d46ec450e90f07fd1]: media/MySQL整理-36.png
[MySQL整理-36.png](media/MySQL整理-36.png)
[91e8b380fc85c8bc288fec470f1ae9e8]: media/MySQL整理-37.png
[MySQL整理-37.png](media/MySQL整理-37.png)
[53f09f8036e88884dbb1aca2143925fe]: media/MySQL整理-38.png
[MySQL整理-38.png](media/MySQL整理-38.png)
[c92a163b99b125387c44cd9b06771374]: media/MySQL整理-39.png
[MySQL整理-39.png](media/MySQL整理-39.png)
[e2f5e18f4b745dff09fa3a0e9db7dcee]: media/MySQL整理-40.png
[MySQL整理-40.png](media/MySQL整理-40.png)
[9bf964d5e1c3720867e427496325488d]: media/MySQL整理-41.png
[MySQL整理-41.png](media/MySQL整理-41.png)
[ccb44931a0b06009c1d0006374e1d9e5]: media/MySQL整理-42.png
[MySQL整理-42.png](media/MySQL整理-42.png)
[7a49ac2b54f956a7f304e0780285361b]: media/MySQL整理-43.png
[MySQL整理-43.png](media/MySQL整理-43.png)
[48d30344b30a6e7fb79b172ed703aba7]: media/MySQL整理-44.png
[MySQL整理-44.png](media/MySQL整理-44.png)
[edad13e944bffb0bdaa83ac0147d3237]: media/MySQL整理-45.png
[MySQL整理-45.png](media/MySQL整理-45.png)
[48ee2bf1829890c64095cfeb1dd99b59]: media/MySQL整理-46.png
[MySQL整理-46.png](media/MySQL整理-46.png)
[5a6b5addad7329a324ee47c9f4e1fcb8]: media/MySQL整理-47.png
[MySQL整理-47.png](media/MySQL整理-47.png)
[5798d978937ad396b6022f5d7210bcff]: media/2018-03-29_222741.png
[2018-03-29_222741.png](media/2018-03-29_222741.png)
>hash: 5798d978937ad396b6022f5d7210bcff  
>file-name: 2018-03-29_222741.png  

[b89e7f270bf06eb0decd192cd3fe683c]: media/03-29_222727.png
[03-29_222727.png](media/03-29_222727.png)
>hash: b89e7f270bf06eb0decd192cd3fe683c  
>file-name: 2018-  
>file-name: 03-29_222727.png  

[ec7492a8d44456fe39b1644d5506fce3]: media/2018-03-29_222419.png
[2018-03-29_222419.png](media/2018-03-29_222419.png)
>hash: ec7492a8d44456fe39b1644d5506fce3  
>file-name: 2018-03-29_222419.png  

[f6d737bf9283a8838628d37ba10a0eb9]: media/2018-03-28_220731.png
[2018-03-28_220731.png](media/2018-03-28_220731.png)
>hash: f6d737bf9283a8838628d37ba10a0eb9  
>file-name: 2018-03-28_220731.png  

[e738356935492d6a7505b5e07e7a6171]: media/MySQL整理-48.png
[MySQL整理-48.png](media/MySQL整理-48.png)
[81f57e3c142623922304fe54f1051fe9]: media/MySQL整理-49.png
[MySQL整理-49.png](media/MySQL整理-49.png)
[03cb9aa9c9cc549aec4cb2847f1377df]: media/MySQL整理-50.png
[MySQL整理-50.png](media/MySQL整理-50.png)
[b22837f1fc10d4d01bce5866dedbe5cc]: media/MySQL整理-51.png
[MySQL整理-51.png](media/MySQL整理-51.png)
[213df5c006b80d812c7da94f57fad247]: media/MySQL整理-52.png
[MySQL整理-52.png](media/MySQL整理-52.png)
[54e200c0d9c867cab2a1c165ce8c8906]: media/MySQL整理-53.png
[MySQL整理-53.png](media/MySQL整理-53.png)
---
### NOTE ATTRIBUTES
>Created Date: 2018-01-13 03:08:05  
>Last Evernote Update Date: 2018-09-13 02:06:37  
>author: YangKwong  
>source: desktop.win  
>source-url: http://www.cnblogs.com/zhming26/p/6322353.html  
>source-application: evernote.win32  