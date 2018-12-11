# MySQL 5.7.19 编译安装与配置

  

# MySQL 5.7.19 编译安装与配置

[ ](https://www.jianshu.com/u/6196900dec0f)

[pijh](https://www.jianshu.com/u/6196900dec0f) __ 关注

2017.09.24 11:53* 字数 1994 阅读 702评论 0喜欢 3

>
背景：[本人博客](https://link.jianshu.com/?t=http://pijunhui.com)自2014年上线以来，一直使用阿里云`ECS`最低配的实例，由于最近阿里云`ECS`进行了升级迁移，原来的低配实例已经不存在了，升级后实例的配置有所提升，当然价格更高了，为了更好的发挥服务器性能，所以就想利用空闲时间对整站进行升级，包含`阿里云ecs更换系统盘`，`MySQL
5.7.19 编译安装与配置`, `Nginx 1.12.1 编译安装与配置`, `PHP 7.1.9 编译安装与配置`等。

> 服务器环境  
>  `CentOS 6.3 64位 全新纯净的系统` / `1核1GB` / `经典网络 1MB`

#####
进入MySQL官网下载页面，地址[`https://www.mysql.com/downloads/`](https://link.jianshu.com/?t=https://www.mysql.com/downloads/)，如果你想使用MySQL
5.7.19的源码版本，[点此处](https://link.jianshu.com/?t=https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-
boost-5.7.19.tar.gz)直接下载!

##### 进入MySQL Community Edition下载页面

点击进入MySQL Community Edition下载页面

  

点击DOWNLOAD

##### 选择操作系统为`Source Code`，选择操作系统版本为`Generic Linux`，选择`Compressed TAR Archive,
Includes Boost Headers`版本或`Compressed TAR Archive`版本，暂未研究两个版本的区别，开始以为Includes
Boost Headers不用再去下载Boost库，然而安装时发现还是需要，所以此处先任意选择一个版本，选择点击 **Download** 进行下载

选择源码下载

点击下载，此处并不需要注册

##### 进入`/usr/local/src`目录，一般我喜欢把下载的文件放在此目录，根据自己的喜好设定

`[root@iZ2864f6btwZ src]# cd /usr/local/src`

##### 下载MySQL文件，如果wget没有安装，`yum -y install wget`即可安装

`[root@iZ2864f6btwZ src]# wget
https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-boost-5.7.19.tar.gz`

> **问题错误：**  
>  如果此处下载遇到如下问题，说明你没有安装openssl，此问题一般只会出现在全新的机器上  
>  `[root@iZ2864f6btwZ src]# wget
https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-boost-5.7.19.tar.gz--
2017-09-22 16:20:26-- https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-
boost-5.7.19.tar.gz Resolving dev.mysql.com (dev.mysql.com)... 137.254.60.11
Connecting to dev.mysql.com (dev.mysql.com)|137.254.60.11|:443... connected.
Unable to establish SSL connection.`

> **解决方案：**  
>  安装opensll，`yum -y install openssl` 再次执行下载命令即可

##### 由于MySQL 5.7需要boost
1.59以及以上版本，所以还需要下载boost库，根据本人测试1.59版本的最为适合，其它高版本在安装的时候遇到了一些问题，目前未解决；[下载地址](https://link.jianshu.com/?t=http://www.boost.org/users/history/version_1_59_0.html)，你也可以点击[此处](https://link.jianshu.com/?t=http://sourceforge.net/projects/boost/files/boost/1.59.0/boost_1_59_0.tar.gz)直接下载`boost_1_59_0.tar.gz`，如果wget无法下载，建议使用迅雷下载后再上传到服务器目录

`[root@iZ2864f6btwZ src]# wget
http://sourceforge.net/projects/boost/files/boost/1.59.0/boost_1_59_0.tar.gz`

##### 解压 boost并拷贝 boost 到 /usr/local/boost 目录

    
    
    [root@iZ2864f6btwZ src] # tar zxvf boost_1_59_0.tar.gz
    [root@iZ2864f6btwZ src]# cp -r boost_1_59_0 /usr/local/boost
    

##### 安装编译所需的常用组件和依赖包 **[ 参考于网络博客 ]**

`[root@iZ2864f6btwZ src]# yum -y install gcc gcc-c++ ncurses ncurses-devel
bison libgcrypt perl make cmake`

##### 创建mysql用户组和用户，用来运行mysql服务器， `-g`指定用户组, `-r`创建系统用户

    
    
    [root@iZ2864f6btwZ src] # groupadd mysql
    [root@iZ2864f6btwZ src]# useradd -r -g mysql -s /bin/false -M mysql
    

##### 解压MySQL，进入 mysql-5.7.19 目录

    
    
    [root@iZ2864f6btwZ src]# tar zxvf mysql-boost-5.7.19.tar.gz 
    [root@iZ2864f6btwZ src]# cd mysql-5.7.19/
    

##### 新建MySQL安装所需要目录

`[root@iZ2864f6btwZ mysql-5.7.19]# mkdir -p /usr/local/mysql
/usr/local/mysql/{data,logs,pids}`

##### 修改 /usr/local/mysql 目录所有者权限

`[root@iZ2864f6btwZ mysql-5.7.19]# chown -R mysql:mysql /usr/local/mysql`

##### 使用cmake命令进行编译

`[root@iZ2864f6btwZ mysql-5.7.19]# cmake .
-DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DMYSQL_DATADIR=/usr/local/mysql/data
-DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci
-DMYSQL_TCP_PORT=3306 -DMYSQL_USER=mysql -DWITH_MYISAM_STORAGE_ENGINE=1
-DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_ARCHIVE_STORAGE_ENGINE=1
-DWITH_BLACKHOLE_STORAGE_ENGINE=1 -DWITH_MEMORY_STORAGE_ENGINE=1
-DENABLE_DOWNLOADS=1 -DDOWNLOAD_BOOST=1 -DWITH_BOOST=/usr/local/boost`  

cmake执行完的结果

##### 使用make命令进行编译，接下来你将经历漫长的等待~

`[root@iZ2864f6btwZ mysql-5.7.19]# make`

> **问题错误：**  
>  编译出现错误，查询得知可能是由于内存不足导致的  
>

>

> c++编译出错

> **解决方案：**  
>  临时增加交换空间 ( 虚拟内存 )

>  
>  
>     [root@iZ2864f6btwZ mysql- 5.7.19]# dd if=/dev/zero of=/swapfile bs=1k
count=2048000

>     2048000+0 records in

>     2048000+0 records out

>     2097152000 bytes (2.1 GB) copied, 34.6782 s, 60.5 MB/s

>     [root@iZ2864f6btwZ mysql-5.7.19]# mkswap /swapfile

>     Setting up swapspace version 1, size = 2047996 KiB

>     no label, UUID=56026239-26e6-40d9-b080-b95acd9db058

>     [root@iZ2864f6btwZ mysql-5.7.19]# swapon /swapfile

>     swapon: /swapfile: insecure permissions 0644, 0600 suggested.

>     [root@iZ2864f6btwZ mysql-5.7.19]# chmod 600 /swapfile

>  
>

> 查看创建的交换空间

>  
>  
>     [root@iZ2864f6btwZ mysql-5.7.19]# free -m

>                  total   used  free  shared  buff/cache  available

>     Mem:         992     51    70    0       869         789

>     Swap:        1999    0     1999

>  
>

> 继续执行`make`命令

>  
>  
>     [root@iZ2864f6btwZ mysql-5.7.19]# make clean

>     [root@iZ2864f6btwZ mysql-5.7.19]# make

>  
>

> 如果你编译完成后不再想要此交换空间，你可以执行如下命令：

>  
>  
>     [root@iZ2864f6btwZ mysql-5.7.19]# swapoff /swapfile

>     [root@iZ2864f6btwZ mysql-5.7.19]# rm /swapfile

>  

> **温馨提示：**  
>
_MySQL编译过程等待时间会比较久，有时都以为是“卡”住了，你可以使用`top`命令查看资源状态，看看cc1plus、make等进程是否在跳动，如果有跳动说明安装还在继续，由于我的
ecs 配置较低，此过程大约经历了几个小时，特别是在29%和74%的时候，几乎都要快放弃了， 如果有经济的能力的话，建议服务器配置还是尽量买高一点。_  
>  `[root@iZ2864f6btwZ mysql-5.7.19]# top`

##### make编译完成

编译完成

##### 编译完成后执行 `make install` 进行安装

`[root@iZ2864f6btwZ mysql-5.7.19]# make install`

##### 将mysql添加到环境变量，修改/etc/profile文件，在文件最末尾添加`export
PATH=/usr/local/mysql/bin:/usr/local/mysql/lib:$PATH`

    
    
    [root@iZ2864f6btwZ mysql-5.7.19]# vim /etc/profile
    ...
    unset i
    unset -f pathmunge
    # mysql执行路径
    export PATH=/usr/local/mysql/bin:/usr/local/mysql/lib:$PATH
    

##### 更新配置文件

`[root@iZ2864f6btwZ mysql-5.7.19]# source /etc/profile`

##### 初始化数据库， –initialize 表示默认生成一个安全的密码，–initialize-insecure 表示不生成密码

`[root@iZ2864f6btwZ mysql-5.7.19]# mysqld --initialize-insecure --user=mysql
--basedir=/usr/local/mysql --datadir=/usr/local/mysql/data`

##### 将mysql服务文件拷贝到`/etc/init.d/`目录，并给出执行权限

    
    
    [root@iZ2864f6btwZ mysql-5.7.19]# cp support-files/mysql.server /etc/init.d/mysqld
    [root@iZ2864f6btwZ mysql-5.7.19]# chmod a+x /etc/init.d/mysqld
    

##### 将MySQL并加入开机自动启动

    
    
    [root@iZ2864f6btwZ mysql-5.7.19]# chkconfig --add mysqld
    [root@iZ2864f6btwZ mysql-5.7.19]# chkconfig mysqld on
    [root@iZ2864f6btwZ mysql-5.7.19]# chkconfig --list | grep mysqld
    
    Note: This output shows SysV services only and does not include native
          systemd services. SysV configuration data might be overridden by native
          systemd configuration.
    
          If you want to list systemd services use 'systemctl list-unit-files'.
          To see services enabled on particular target use
          'systemctl list-dependencies [target]'.
    
    mysqld          0:off   1:off   2:on    3:on    4:on    5:on    6:off
    

##### 修改`/etc/my.cnf`文件，编辑配置文件如下，仅供参考

    
    
    [root@iZ2864f6btwZ mysql-5.7.19]# vim /etc/my.cnf 
    
    [mysqld]
    datadir=/usr/local/mysql/data
    socket=/usr/local/mysql/mysql.sock
    
    [mysqld_safe]
    log-error=/usr/local/mysql/logs/mysqld.log
    pid-file=/usr/local/mysql/pids/mysqld.pid
    
    # Disabling symbolic-links is recommended to prevent assorted security risks
    symbolic-links=0
    # Settings user and group are ignored when systemd is used.
    # If you need to run mysqld under a different user or group,
    # customize your systemd unit file for mariadb according to the
    # instructions in http://fedoraproject.org/wiki/Systemd
    
    [client]
    default-character-set=utf8
    socket=/usr/local/mysql/mysql.sock
    
    [mysql]
    default-character-set=utf8
    socket=/usr/local/mysql/mysql.sock
    
    #
    # include all files from the config directory
    #
    !includedir /etc/my.cnf.d
    

##### 启动MySQL

    
    
    [root@iZ2864f6btwZ local]# service mysqld start
    Starting MySQL.2017-09-23T16:13:16.049373Z mysqld_safe error: log-error set to '/usr/local/mysql/logs/mysqld.log', however file don't exists. Create writable for user 'mysql'.
    The server quit without updating PID file (/usr/local/mysql[FAILED]2864f6btwZ.pid).
    

> **问题错误：**  
>  由于缺少 `mysqld.log` 和 `mysqld.pid` 文件导致无法正常启动

> **解决方案：**  
>  创建 `mysqld.log` 和 `mysqld.pid` 文件

>  
>  
>     [root@iZ2864f6btwZ mysql- 5.7.19]# touch
/usr/local/mysql/logs/mysqld.log

>     [root@iZ2864f6btwZ mysql-5.7.19]# touch /usr/local/mysql/pids/mysqld.pid

>  
>

> 修改 /usr/local/mysql 的权限  
>  `[root@iZ2864f6btwZ mysql-5.7.19]# chown mysql.mysql -R /usr/local/mysql/`

>

> 再次启动MySQL  
>  `[root@iZ2864f6btwZ local]# service mysqld start`

##### 查看MySQL运行状态

    
    
    [root@iZ2864f6btwZ local]# service mysqld status
    MySQL is not running, but lock file (/var/lock/subsys/mysql[FAILED]
    

> **问题错误：**  
>  `MySQL is not running, but lock file (/var/lock/subsys/mysql[FAILED]`

> **解决方案：**  
>  删除`/var/lock/subsys/mysql`文件，重新启动MySQL

>  
>  
>     [root@iZ2864f6btwZ  local]# rm -f /var/lock/subsys/mysql

>     [root@iZ2864f6btwZ local]# service mysqld start

>     Starting MySQL.                                            [  OK  ]

>  

##### 连接MySQL

    
    
    [root@iZ2864f6btwZ mysql-5.7.19]# mysql -u root
    ERROR 2002 (HY000): Can't connect to local MySQL server through socket '/tmp/mysql.sock' (2)
    [root@iZ2864f6btwZ mysql-5.7.19]#
    

> **问题错误：**  
>  /etc/my.cnf 文件配置不正确  
>  `ERROR 2002 (HY000): Can't connect to local MySQL server through socket
'/tmp/mysql.sock' (2)`

> **解决方案：**  
>  参考上述步骤 **修改 /etc/my.cnf 文件**

    
    
    [root@iZ2864f6btwZ local] # mysql -u root
    Welcome to the MySQL monitor.  Commands end with ; or \g.
    Your MySQL connection id is 6
    Server version: 5.7.19 Source distribution
    
    Copyright (c) 2000, 2017, Oracle and/or its affiliates. All rights reserved.
    
    Oracle is a registered trademark of Oracle Corporation and/or its
    affiliates. Other names may be trademarks of their respective
    owners.
    
    Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
    
    mysql>
    

##### 查看数据库，如果看到以下几个数据库说明数据库初始化成功

    
    
    mysql> show databases;
    +--------------------+
    | Database           |
    +--------------------+
    | information_schema |
    | mysql              |
    | performance_schema |
    | sys                |
    +--------------------+
    4 rows in set (0.00 sec)
    
    mysql>
    

##### 进入mysql库，查看用户表信息

    
    
    mysql> use mysql
    Reading table information for completion of table and column names
    You can turn off this feature to get a quicker startup with -A
    
    Database changed
    mysql>
    mysql> select host,user,password from user;
    ERROR 1054 (42S22): Unknown column 'password' in 'field list'
    mysql>
    

> **问题错误：**  
>  `ERROR 1054 (42S22): Unknown column 'password' in 'field list'`

> **解决方案：**  
>  由于MySQL
5.7版本下的mysql数据库下已经没有password这个字段了，password字段改成了authentication_string，查询时使用authentication_string字段即可

>  
>  
>     mysql> select host,user,authentication_string from user;

>
+-----------+---------------+-------------------------------------------+

>      | host      | user          | authentication_string
|

>
+-----------+---------------+-------------------------------------------+

>     | localhost | root          |
|

>     | localhost | mysql.session | *THISISNOTAVALIDPASSWORDTHATCANBEUSEDHERE
|

>     | localhost | mysql.sys     | *THISISNOTAVALIDPASSWORDTHATCANBEUSEDHERE
|

>
+-----------+---------------+-------------------------------------------+

>     3 rows in set (0.00 sec)

>  

##### 设置密码（推荐），注意此方法必须使用`flush privileges`命令刷新一下权限才能生效

    
    
    mysql> UPDATE user SET authentication_string=PASSWORD('newpassword') WHERE user='root';
    Query OK, 1 row affected, 1 warning (0.00 sec)
    Rows matched: 1  Changed: 1  Warnings: 1
    
    mysql>
    mysql> flush privileges;
    Query OK, 0 rows affected (0.00 sec)
    
    mysql>
    

##### 另外一种方法可以快速密码，但此方法设置的密码使用`history`命令可以看到，所以不太推荐

    
    
    [root@iZ2864f6btwZ ~]# mysqladmin -u root password 'newpassword'
    mysqladmin: [Warning] Using a password on the command line interface can be insecure.
    Warning: Since password will be sent to server in plain text, use ssl connection to ensure password safety.
    

> 结尾：  
>  至此，MySQL 5.7.19 编译安装及配置已经全部完成，有疑问的朋友可以给我留言，若有毛病，欢迎指正。

  


---
### ATTACHMENTS
[2ee032c05622418864fd2c3151a116cb]: media/96-2.jpg
[96-2.jpg](media/96-2.jpg)
>hash: 2ee032c05622418864fd2c3151a116cb  
>source-url: https://upload.jianshu.io/users/upload_avatars/7351260/047bb37f-7f00-44e0-a26a-021d5c7e4aed.jpg?imageMogr2/auto-orient/strip|imageView2/1/w/96/h/96  
>file-name: 96.jpg  

[3dfa79e861adb0624d3976ddc21847af]: media/650.png
[650.png](media/650.png)
>hash: 3dfa79e861adb0624d3976ddc21847af  
>source-url: https://upload-images.jianshu.io/upload_images/7351260-1fb71fb926ff6bf6.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/650  
>file-name: 650.png  

[9b929f37940b661b749476823e107522]: media/650-2.png
[650-2.png](media/650-2.png)
>hash: 9b929f37940b661b749476823e107522  
>source-url: https://upload-images.jianshu.io/upload_images/7351260-c16babd56ba68463.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/650  
>file-name: 650.png  

[d40736f65101179c7374ba146e9a9b20]: media/650-3.png
[650-3.png](media/650-3.png)
>hash: d40736f65101179c7374ba146e9a9b20  
>source-url: https://upload-images.jianshu.io/upload_images/7351260-a790f533ae3325dd.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/650  
>file-name: 650.png  

---
### NOTE ATTRIBUTES
>Created Date: 2018-01-12 03:12:41  
>Last Evernote Update Date: 2018-10-01 15:35:38  
>author: YangKwong  
>source: web.clip  
>source-url: https://www.jianshu.com/p/4416792750c7  