# 编译安装MySQL-5.7.13 - goozgk - 博客园

  

编译安装MySQL-5.7

cmake的重要特性之一是其独立于源码(out-of-
source)的编译功能，即编译工作可以在另一个指定的目录中而非源码目录中进行，这可以保证源码目录不受任何一次编译的影响，因此在同一个源码树上可以进行多次不同的编译，如针对于不同平台编译。

编译安装MySQL-5.7

+++++++++++++++++++++++++
OS:centos7 & 3.10.0-327.el7.x86_64  
MySQL:mysql-boost-5.7.13.tar.gz  
+++++++++++++++++++++++++

一、安装cmake

跨平台编译器

https://cmake.org/download/


​    
    # wget https://cmake.org/files/v3.5/cmake-3.5.2.tar.gz
    
    # tar xf cmake-3.5.2.tar.gz
    # cd cmake-3.5.2
    
    # yum install -y make gcc gcc-c++ ncurses-devel
    
    # ./bootstrap
    # gmake 
    # gmake install

二、编译安装mysql

0\. 下载MySQL


​    
    # wget http://cdn.mysql.com//Downloads/MySQL-5.7/mysql-boost-5.7.13.tar.gz

1、使用cmake编译mysql-5.7  
cmake指定编译选项的方式不同于make，其实现方式对比如下：


​    
    make                 |cmake
    ---------------------|--------------------------
    ./configure          |cmake .
    ./configure --help   |cmake . -LH or ccmake .

-L[A][H]

List non-advanced cached variables.  
List cache variables will run CMake and list all the variables from the CMake
cache that are not marked as INTERNAL or ADVANCED. This will effectively
display current CMake settings, which can then be changed with -D option.
Changing some of the variables may result in more variables being created. If
A is specified, then it will display also advanced variables. If H is
specified, it will also display help for each variable.

指定安装文件的安装路径时常用的选项：  
-DCMAKE_INSTALL_PREFIX=/usr/local/mysql  
-DMYSQL_DATADIR=/data/mysql  
-DSYSCONFDIR=/etc


默认编译的存储引擎包括：csv、myisam、myisammrg和heap。若要安装其它存储引擎，可以使用类似如下编译选项：  
-DWITH_INNOBASE_STORAGE_ENGINE=1  
-DWITH_ARCHIVE_STORAGE_ENGINE=1  
-DWITH_BLACKHOLE_STORAGE_ENGINE=1  
-DWITH_FEDERATED_STORAGE_ENGINE=1

若要明确指定不编译某存储引擎，可以使用类似如下的选项：  
-DWITHOUT_<ENGINE>_STORAGE_ENGINE=1  
比如：  
-DWITHOUT_EXAMPLE_STORAGE_ENGINE=1  
-DWITHOUT_FEDERATED_STORAGE_ENGINE=1  
-DWITHOUT_PARTITION_STORAGE_ENGINE=1

如若要编译进其它功能，如SSL等，则可使用类似如下选项来实现编译时使用某库或不使用某库：  
-DWITH_READLINE=1  
-DWITH_SSL=system  
-DWITH_ZLIB=system  
-DWITH_LIBWRAP=0

其它常用的选项：  
-DMYSQL_TCP_PORT=3306  
-DMYSQL_UNIX_ADDR=/tmp/mysql.sock  
-DENABLED_LOCAL_INFILE=1  
-DEXTRA_CHARSETS=all  
-DDEFAULT_CHARSET=utf8  
-DDEFAULT_COLLATION=utf8_general_ci  
-DWITH_DEBUG=0  
-DENABLE_PROFILING=1

如果想清理此前的编译所生成的文件，则需要使用如下命令：


​    
    make clean
    rm CMakeCache.txt

  

2、编译安装

从MySQL 5.7.5开始Boost库是必需的  
下载 mysql-boost-5.7.12.tar.g 在 cmake 指定参数 -DWITH_BOOST=boost/boost_1_59_0/  
或直接cmake指定参数 -DDOWNLOAD_BOOST=1 -DWITH_BOOST=<directory> 系统会下载 boost


​    
    # mkdir -p /usr/local/mysql /mydata/data
    # groupadd -r mysql
    # useradd -g mysql -r -d /data/mydata mysql
    # chown -R mysql.mysql /usr/local/mysql /mydata/data
    
    # wget http://sourceforge.net/projects/boost/files/boost/1.59.0/boost_1_59_0.tar.gz
    # tar xf mysql-boost-5.7.13.tar.gz
    # cd mysql-5.7.13
    # yum install -y openssl openssl-devel
    
    # cmake . -DCMAKE_INSTALL_PREFIX=/usr/local/mysql \
    -DMYSQL_DATADIR=/mydata/data \
    -DSYSCONFDIR=/etc \
    -DWITH_INNOBASE_STORAGE_ENGINE=1 \
    -DWITH_ARCHIVE_STORAGE_ENGINE=1 \
    -DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
    -DWITH_READLINE=1 \
    -DWITH_LIBWRAP=0 \
    -DMYSQL_UNIX_ADDR=/tmp/mysql.sock \
    -DWITH_SSL=system \
    -DWITH_ZLIB=system \
    -DWITH_BOOST=/home/alex/Downloads/boost_1_59_0 \
    -DDEFAULT_CHARSET=utf8 \
    -DDEFAULT_COLLATION=utf8_general_ci

提示错误，需要安装bison*


​    
    CMake Warning at cmake/bison.cmake:20 (MESSAGE):
    Bison executable not found in PATH
    Call Stack (most recent call first):
    sql/CMakeLists.txt:527 (INCLUDE)
    
    CMake Warning at cmake/bison.cmake:20 (MESSAGE):
    Bison executable not found in PATH
    Call Stack (most recent call first):
    libmysqld/CMakeLists.txt:159 (INCLUDE)
    # yum -y install bison*


​    
    # make 
    # make install

配置MySQL并启动。


​    
    # cp ./support-files/mysql.server /etc/init.d/mysqld
    # chmod +x /etc/init.d/mysqld
    # chkconfig --add mysqld
    # chkconfig mysqld on
    # chkconfig | grep mysql
    mysqld          0:off   1:off   2:on    3:on    4:on    5:on    6:off
    
    # usermod -d /home/mysql -p mysql -s /bin/bash mysql
    
    # pwd
    /usr/local/mysql
    # mkdir mysql-files
    # chmod 750 mysql-files
    # chown -R mysql.mysql ../mysql/


​    
    # ./bin/mysqld --initialize --user=mysql
    2016-07-04T12:45:16.885226Z 0 [Warning] TIMESTAMP with implicit DEFAULT value is deprecated. Please use --explicit_defaults_for_timestamp server option (see documentation for more details).
    2016-07-04T12:45:18.765474Z 0 [Warning] InnoDB: New log files created, LSN=45790
    2016-07-04T12:45:19.029232Z 0 [Warning] InnoDB: Creating foreign key constraint system tables.
    2016-07-04T12:45:19.165514Z 0 [Warning] No existing UUID has been found, so we assume that this is the first time that this server has been started. Generating a new UUID: 2a23590f-41e5-11e6-822e-000c29d052cc.
    2016-07-04T12:45:19.168762Z 0 [Warning] Gtid table is not ready to be used. Table 'mysql.gtid_executed' cannot be opened.
    2016-07-04T12:45:20.935023Z 0 [Warning] CA certificate ca.pem is self signed.
    2016-07-04T12:45:21.242525Z 1 [Note] A temporary password is generated for root@localhost: YwSv2mg(tryr
    # ./bin/mysql_ssl_rsa_setup
    
    # chown mysql.mysql ./mysql-files/


​    
    #  mysql -u root -p
    Enter password:YwSv2mg(tryr
    mysql> set password for 'root'@'localhost'=password('root');
    Query OK, 0 rows affected, 1 warning (0.00 sec)
    
    mysql>


​    
    [root@localhost mysql]# mysql -u root -p
    Enter password:
    Welcome to the MySQL monitor.  Commands end with ; or \g.
    Your MySQL connection id is 5
    Server version: 5.7.13 Source distribution
    
    Copyright (c) 2000, 2016, Oracle and/or its affiliates. All rights reserved.
    
    Oracle is a registered trademark of Oracle Corporation and/or its
    affiliates. Other names may be trademarks of their respective
    owners.
    
    Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
    
    mysql>
