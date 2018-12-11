# CentOS 上 编译MySQL-5.7.x 或者 MySQL-8.0 源码 及 多实例安装

  

# CentOS 上 编译MySQL-5.7.x 或者 MySQL-8.0 源码 及 多实例安装

[ ](https://www.jianshu.com/u/23e30eecba15)

[zagnix](https://www.jianshu.com/u/23e30eecba15) __ 关注

2017.06.03 23:44* 字数 346 阅读 43评论 0喜欢 1

## 1.依赖包安装

    
    
    yum install gdb gcc gcc-c++ ncurses-devel cmake libaio bison zlib-devel openssl openssl-devel patch
    
    

## 2.下载mysql源码包和boost库

  * 下载最新mysql源码

    
    
    https://cdn.mysql.com//Downloads/MySQL-5.7/mysql-boost-5.7.18.tar.gz
    
    

  * 下载boost库，版本 boost_1_59_0

    
    
    http://sourceforge.net/projects/boost/files/boost/1.59.0/boost_1_59_0.tar.bz2
    
    

**mysql-8.0需要boost_1_63_0版本**

## 3.上传并解压

上传并解压安装包：

[root@localhost MySQL]# tar -xzvf mysql-boost-5.7.18.tar.gz

[root@localhost MySQL]# tar -xzvf boost_1_59_0.tar.bz2

## 4 建立mysql用户和组，建立相关目录

    
    
    /usr/sbin/groupadd mysql
    
    /usr/sbin/useradd mysql -g mysql -d /home/mysql -s /sbin/nologin
    
    mkdir /home/mysql/data/3306/data
    
    mkdir /home/mysql/data/3306/log
    
    mkdir /home/mysql/data/3306/tmp
    
    mkdir /home/mysql/data/3306/binlog
    
    

**三实例部署的话，可以同时创建以下目录**

    
    
    mkdir /home/mysql/data/3307/data
    
    mkdir /home/mysql/data/3307/ log
    
    mkdir /home/mysql/data/3307/tmp
    
    mkdir /home/mysql/data/3307/binlog
    
    mkdir /home/mysql/data/3308/data
    
    mkdir /home/mysql/data/3308/log
    
    mkdir /home/mysql/data/3308/tmp
    
    mkdir /home/mysql/data/3308/binlog
    
    

**创建mysql安装目录**

    
    
    mkdir /usr/ local/mysql
    
    chown -R mysql.mysql /usr/local/mysql
    
    chown -R mysql.mysql /home/mysql
    
    

## 5 编译MySQL源码&安装mysql

**生成makefile文件**

    
    
    cmake \
    
    -DCMAKE_INSTALL_PREFIX=/usr/ local/mysql \
    
    -DMYSQL_DATADIR=/home/mysql/data \
    
    -DSYSCONFDIR=/etc \
    
    -DWITH_MYISAM_STORAGE_ENGINE=1 \
    
    -DWITH_INNOBASE_STORAGE_ENGINE=1 \
    
    -DWITH_EDITLINE=bundled \
    
    -DMYSQL_UNIX_ADDR=/home/mysql/mysql.sock \
    
    -DMYSQL_TCP_PORT=3306 \
    
    -DENABLED_LOCAL_INFILE=1 \
    
    -DWITH_PARTITION_STORAGE_ENGINE=1 \
    
    -DEXTRA_CHARSETS=all \
    
    -DDEFAULT_CHARSET=utf8mb4 \
    
    -DDEFAULT_COLLATION=utf8mb4_general_ci \
    
    -DWITH_DEBUG=0  \
    
    -DDOWNLOAD_BOOST=1 -DWITH_BOOST=/xxx/xxx/boost_1_59_0 -DDOWNLOAD_BOOST_TIMEOUT=60000
    
    

**如果日后需要调试mysql源码，在cmake时候设置 -DWITH_DEBUG=1，即编译为带调试信息的mysql目标文件 **

**编译**

    
    
    make
    
    

**根据机器配置等待一段时间，看到100%字样，则说明编译成功**

**安装到 /usr/local/mysql 目录下**

    
    
    make install
    
    

## 6.配置mysql环境变量

在/etc/profile中添加/usr/local/mysql/bin到PATH变量中

    
    
    PATH=/usr/local/mysql/bin:$PATH
    
    执行source /etc/profile 生效
    
    

## 7.初始化mysql数据库

初始化data文件

    
    
    mysqld --defaults-file=/home/mysql/data/3306/my.cnf --initialize-insecure --user=mysql --basedir=/usr/local/mysql --datadir=/home/mysql/data/3306/data
    
    

切换到mysql用户

    
    
    su - mysql
    
    

生成ssl所需文件

    
    
    mysql_ssl_rsa_setup --user=mysql --basedir=/usr/local/mysql --datadir=/home/mysql/data/3306/data
    
    

启动mysql

    
    
    mysqld --defaults-file=/home/mysql/data/3306/my.cnf --user=mysql
    
    

先通过unix socket修改mysql root用户密码

    
    
    mysql -uroot -p -S /home/mysql/data/3306/mysql.sock
    
    UPDATE mysql.user SET authentication_string = PASSWORD('mysql') WHERE USER LIKE '%root%';
    
    grant all privileges on *.* to 'root'@'%' identified by 'mysql' with grant option;
    
    flush privileges;
    
    

验证通过tcp/ip协议登陆mysql

    
    
    mysql -h127.0.0.1 -uroot -p -P3306
    
    

## 8.配置数据库配置文件

    
    
    cd /usr/local/mysql/
    
    cp support-files/my-default.cnf  /etc/my.cnf
    
    >/etc/my.cnf
    
    vi /etc/my.cnf
    
    [client]
    
    socket=/home/mysql/mysql.sock
    
    [mysqld]
    
    symbolic-links=0
    
    server_id                  = 120
    
    default_storage_engine    = Innodb
    
    user                      = mysql
    
    port                      = 3306
    
    basedir                    = /usr/local/mysq
    
    datadir                    = /home/mysql/data
    
    tmpdir                    = /home/mysql/tmp
    
    socket                    = /home/mysql/mysql.sock
    
    pid_file                  = /home/mysql/mysql.pid
    
    character_set_server      = utf8
    
    collation_server          = utf8_general_ci
    
    open_files_limit          = 10240
    
    explicit_defaults_for_timestamp
    
    max_allowed_packet        = 256M
    
    max_heap_table_size        = 256M
    
    net_buffer_length          = 8K
    
    sort_buffer_size          = 2M
    
    join_buffer_size          = 4M
    
    read_buffer_size          = 2M
    
    read_rnd_buffer_size      = 16M
    
    log_error                  = /home/mysql/log/error.log
    
    log_bin                    = /home/mysql/binlog/mysql-bin
    
    binlog_cache_size          = 32M
    
    max_binlog_cache_size      = 2G
    
    max_binlog_size            = 500M
    
    binlog_format              = mixed
    
    log_output                = FILE
    
    expire_logs_days          = 5
    
    slow_query_log            = 1
    
    long_query_time            = 3
    
    slow_query_log_file        = /home/mysql/log/slow-query.log
    
    innodb_buffer_pool_size    = 500M
    
    innodb_log_file_size      = 200M
    
    innodb_log_files_in_group  = 3
    
    innodb_lock_wait_timeout  = 20
    
    [mysql]
    
    no_auto_rehash
    
    [mysqld_safe]
    
    log-error=/home/mysql/log/error.log
    
    

## 9 配置mysql成功centos服务（可以不做）

配置mysql系统服务：

    
    
    cd /usr/local/mysql
    
    cp support-files/mysql.server  /etc/init.d/mysql
    
    chkconfig --add mysql
    
    chkconfig mysql on
    
    

启动数据库：

    
    
    service mysql start
    
    

**如果想部署多实例情况，重复步骤7到8即可**

我的多实例启动脚本：

    
    
    mysqld_safe --defaults-file=/home/mysql/data/3306/my.cnf --user=mysql &
    
    mysqld_safe --defaults-file=/home/mysql/data/3307/my.cnf --user=mysql &
    
    mysqld_safe --defaults-file=/home/mysql/data/3308/my.cnf --user=mysql &
    
    

  


---
### ATTACHMENTS
[3397163ecdb3855a0a4139c34a695885]: media/96.jpg
[96.jpg](media/96.jpg)
>hash: 3397163ecdb3855a0a4139c34a695885  
>source-url: https://cdn2.jianshu.io/assets/default_avatar/4-3397163ecdb3855a0a4139c34a695885.jpg?imageMogr2/auto-orient/strip|imageView2/1/w/96/h/96  
>file-name: 96.jpg  

---
### NOTE ATTRIBUTES
>Created Date: 2018-01-12 03:12:51  
>Last Evernote Update Date: 2018-10-01 15:35:38  
>author: YangKwong  
>source: web.clip  
>source-url: https://www.jianshu.com/p/329ca66272f3  