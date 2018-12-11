# MySQL 表空间

**环境** ：MySQL 5.6.27, Ubuntu 15.10 64-bit

引擎为 InnoDB，不考虑 MyISAM。MySQL 5.6 版之前的 InnoDB 不支持独立表空间。

 **查看当前设置是共享表空间，还是独立表空间**

mysql> show variables like '%per_table%';

+-----------------------+-------+

| Variable_name         | Value |

+-----------------------+-------+

| innodb_file_per_table | ON    |

+-----------------------+-------+

1 row in set (0.00 sec)

`innodb_file_per_table` 为 `ON`，所以为独立表空间。

  

 **MySQL数据库文件的位置**

/var/lib/mysql/

但是发现一般用户无法访问：

$ cd //lib/mysql

: : //lib/mysql: 权限不够

可以为当前用户添加权限：

sudo chmod +rx - mysql

但是感觉这样不太好。还是切换到 root 用户吧：

sudo su

## 查看数据库文件目录

数据库 `menagerie` 里有两个表，`user` 和 `pet`。查看数据库文件：

root@t450s:/var/lib/mysql/menagerie

总用量

drwx------ mysql mysql 月 ./

drwxr-xr-x mysql mysql 月 ../

-rw-rw---- mysql mysql 月 db.opt

-rw-rw---- mysql mysql 月 pet.frm

-rw-rw---- mysql mysql 98304 月 pet.ibd

-rw-rw---- mysql mysql 月 user.frm

-rw-rw---- mysql mysql 98304 月 user.ibd

可见 `user` 和 `pet` 各有一个 `.ibd` 文件，即表空间为独立的。

 **切换至共享表空间**

首先停掉 MySQL 服务（好像旧版名为 `mysqld`）：

adam@t450ssudo /etc/init.d/mysql stop

[ ok ] Stopping mysql (via systemctl) mysql.service.

添加如下配置到 `/etc/mysql/my.cnf`：

[mysqld]

innodb_file_per_table =

再启动 MySQL 服务：

adam@t450s/etc/init.d/mysql start

[ ok ] Starting mysql (via systemctl) mysql.service.

在 MySQL 客户端里看一下：

mysql> show variables like '%per_table%';  
+-----------------------+-------+  
| Variable_name        | Value |  
+-----------------------+-------+  
| innodb_file_per_table | OFF  |  
+-----------------------+-------+

1 row in set (0.00 sec)

现在配置确实为共享表空间。

重新创建数据库 `menagerie` 及两张表。然后查看数据库文件：

root@t450s:/var/lib/mysql/menagerie  
总用量  
drwx------  mysql mysql  月    ./  
drwxr-xr-x  mysql mysql  月    ../  
-rw-rw----  mysql mysql    月    db.opt  
-rw-rw----  mysql mysql  月    pet.frm

-rw-rw----  mysql mysql  月    user.frm

新建的表为共享表空间。

 **再转换成独立表空间**

mysql> set global innodb_file_per_table=;  
mysql> alter table user engine=InnoDB;

mysql> alter table pet engine=InnoDB;

查看数据库文件。

root@t450s:/var/lib/mysql/menagerie  
总用量  
drwx------  mysql mysql  月    ./  
drwxr-xr-x  mysql mysql  月    ../  
-rw-rw----  mysql mysql    月    db.opt  
-rw-rw----  mysql mysql  月    pet.frm  
-rw-rw----  mysql mysql 98304 月    pet.ibd  
-rw-rw----  mysql mysql  月    user.frm  
-rw-rw----  mysql mysql 98304 月    user.ibd

改表空间还可以用 `ALTER TABLE ... TABLESPACE`，详见：[Enabling and Disabling File-Per-
Table Tablespaces](http://dev.mysql.com/doc/refman/5.6/en/tablespace-
enabling.html)

  



---
### TAGS
{表空间}

---
### NOTE ATTRIBUTES
>Created Date: 2016-05-18 07:37:10  
>Last Evernote Update Date: 2016-06-20 22:03:54  
>source: Clearly  
>source-url: https://segmentfault.com/a/1190000003956663  