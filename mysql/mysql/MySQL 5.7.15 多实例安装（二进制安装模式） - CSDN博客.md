# MySQL 5.7.15 多实例安装（二进制安装模式） - CSDN博客

  

#  [ MySQL 5.7.15 多实例安装（二进制安装模式）
](http://blog.csdn.net/kk185800961/article/details/53810019)

2016年12月22日 10:12:25 2352人阅读 评论(1) 收藏 举报

.

分类：

MYSQL _（37）_ MYSQL 安装升级 _（5）_

.

单实例安装请参考 [MySQL 5.7.15
安装（二进制安装模式）](http://blog.csdn.net/kk185800961/article/details/53170055)

当前安装两个实例，更多实例参考一样。

  

**# 操作系统**  
CentOS release 6.5 (Linux version 2.6.32-431.el6.x86_64)

  
**# 数据库 mysql 5.7.17 下载 (623.7MB)**<http://dev.mysql.com/downloads/mysql/>  
mysql-5.7.17-linux-glibc2.5-x86_64.tar.gz  
>> linux generic  
>> Linux - Generic (glibc 2.5) (x86, 64-bit), Compressed TAR Archive  

  

**官网安装参考**<http://dev.mysql.com/doc/refman/5.7/en/binary-installation.html>  

  

**安装前准备：**

**[plain]** [view plain](http://csdnimg.cn/release/phoenix/# "view plain")
[copy](http://csdnimg.cn/release/phoenix/# "copy")

  1. # Linux查看系统版本 
  2. shell> uname -a 
  3. shell> lsb_release -a 
  4. shell> cat /proc/version 
  5. shell> cat /etc/redhat-release 
  6. shell> cat /etc/issue 
  7.   8.   9. # 安装相关包 
  10. shell> yum -y install gcc glibc libaio libstdc++ libstdc ncurses-libs 
  11.   12.   13. # 如有则卸载自带mysql （手动删除 /etc/my.cnf或者/etc/mysql） 
  14. rpm -qa | grep mysql 
  15. rpm -e mysql #普通删除模式 
  16. rpm -e --nodeps mysql #强力删除模式 

  
**# 基本配置**  

**[plain]** [view plain](http://csdnimg.cn/release/phoenix/# "view plain")
[copy](http://csdnimg.cn/release/phoenix/# "copy")

  1. shell> groupadd mysql 
  2. shell> useradd -r -g mysql -s /bin/false mysql 
  3. shell> ll /root/mysql-5.7.15-linux-glibc2.5-x86_64.tar.gz 
  4. shell> cd /root 
  5. shell> tar -zxvf mysql-5.7.15-linux-glibc2.5-x86_64.tar.gz 
  6. shell> mv /root/mysql-5.7.15-linux-glibc2.5-x86_64 /usr/local/mysql 
  7. shell> cd /usr/local/mysql 
  8. shell> mkdir -p /var/run/mysqld 
  9. shell> mkdir -p /usr/local/mysql/data3306 /usr/local/mysql/binlog3306 
  10. shell> mkdir -p /usr/local/mysql/data3307 /usr/local/mysql/binlog3307 
  11. shell> chmod 750 /var/run/mysqld /usr/local/mysql/data* /usr/local/mysql/binlog* 
  12. shell> chown -R mysql:mysql /usr/local/mysql/ /var/run/mysqld 

  
**# 配置参数文件**  

**[plain]** [view plain](http://csdnimg.cn/release/phoenix/# "view plain")
[copy](http://csdnimg.cn/release/phoenix/# "copy")

  1. shell> vi /etc/my.cnf 
  2.   3. [mysqld_multi] 
  4. mysqld = /usr/local/mysql/bin/mysqld_safe 
  5. mysqladmin = /usr/local/mysql/bin/mysqladmin 
  6. #user = root 
  7. #password = rootpwd 
  8.   9. [mysqld3306] 
  10. port = 3306 
  11. server_id = 3306 
  12. basedir =/usr/local/mysql 
  13. datadir =/usr/local/mysql/data3306 
  14. log-bin=/usr/local/mysql/binlog3306/mysql-bin 
  15. socket =/tmp/mysql3306.sock 
  16. log-error =/var/log/mysqld3306.log 
  17. pid-file =/var/run/mysqld/mysqld3306.pid 
  18.   19. [mysqld3307] 
  20. port = 3307 
  21. server_id = 3307 
  22. basedir =/usr/local/mysql 
  23. datadir =/usr/local/mysql/data3307 
  24. log-bin=/usr/local/mysql/binlog3307/mysql-bin 
  25. socket =/tmp/mysql3307.sock 
  26. log-error =/var/log/mysqld3307.log 
  27. pid-file =/var/run/mysqld/mysqld3307.pid 

  
**# 添加环境变量**  

**[plain]** [view plain](http://csdnimg.cn/release/phoenix/# "view plain")
[copy](http://csdnimg.cn/release/phoenix/# "copy")

  1. shell> echo "PATH=$PATH:/usr/local/mysql/bin " >> /etc/profile 
  2. shell> source /etc/profile 

  
**# 安装,完成后记住root密码**  

**[plain]** [view plain](http://csdnimg.cn/release/phoenix/# "view plain")
[copy](http://csdnimg.cn/release/phoenix/# "copy")

  1. shell> bin/mysqld --initialize --user=mysql --datadir=/usr/local/mysql/data3306 --explicit_defaults_for_timestamp 
  2. shell> bin/mysqld --initialize --user=mysql --datadir=/usr/local/mysql/data3307 --explicit_defaults_for_timestamp 

  
**# 启动实例服务**  

**[plain]** [view plain](http://csdnimg.cn/release/phoenix/# "view plain")
[copy](http://csdnimg.cn/release/phoenix/# "copy")

  1. shell> mysqld_multi report 
  2. shell> mysqld_multi start 3306,3307 
  3.   4. shell> netstat -ntlp | grep mysql 
  5. shell> ll /tmp/mysql*.sock 

  
**# 访问管理**

**[plain]** [view plain](http://csdnimg.cn/release/phoenix/# "view plain")
[copy](http://csdnimg.cn/release/phoenix/# "copy")

  1. # 访问数据库(进入后要求更改root密码) 
  2. shell> mysql -u root -p -S /tmp/mysql3306.sock 
  3. Enter password: 
  4.   5. shell> mysql -u root -p -S /tmp/mysql3307.sock 
  6. Enter password: 
  7.   8. mysql> ALTER USER 'root'@'localhost' IDENTIFIED BY 'rootpwd'; 
  9. mysql> select Host,User from mysql.user; 
  10.   11.   12. # 超级管理员 
  13. mysql> create user root@'192.168.1.%' IDENTIFIED by 'rootpwd'; 
  14. mysql> grant all privileges on *.* to root@'192.168.1.%'; 
  15. mysql> flush privileges; 
  16.   17.   18. # 可用端口登录了(此时登录账户为: root@'192.168.1.%') 
  19. shell> mysql -h 192.168.1.110 -u root -p -P3306 
  20. shell> mysql -h 192.168.1.110 -u root -p -P3306 

  

**# 关闭某个实例**

**[plain]** [view plain](http://csdnimg.cn/release/phoenix/# "view plain")
[copy](http://csdnimg.cn/release/phoenix/# "copy")

  1. shell> mysqladmin -uroot -prootpwd -S /tmp/mysql3306.sock shutdown 

  

**# 添加自启动**

**[plain]** [view plain](http://csdnimg.cn/release/phoenix/# "view plain")
[copy](http://csdnimg.cn/release/phoenix/# "copy")

  1. shell> cat /etc/rc.local 
  2. shell> echo "/usr/local/mysql/bin/mysqld_multi --defaults-extra-file=/etc/my.cnf start 3306,3307" >> /etc/rc.local 

  

**# 添加防火墙规则 (贴在 icmp-host-prohibited 的上面)**  

**[plain]** [view plain](http://csdnimg.cn/release/phoenix/# "view plain")
[copy](http://csdnimg.cn/release/phoenix/# "copy")

  1. shell> vi /etc/sysconfig/iptables 
  2. -A INPUT -p tcp -m state --state NEW -m tcp --dport 3306 -j ACCEPT 
  3. -A INPUT -p tcp -m state --state NEW -m tcp --dport 3307 -j ACCEPT 
  4.   5. shell> service iptables restart 
  6.   7.   8. /*防火墙基本命令: 
  9.   10. 0）查看当前规则 
  11. iptables -L -n --line-number 
  12. service iptables status 
  13.   14. 1） 临时生效，重启后复原 
  15. 保存: service iptables save 
  16. 开启： service iptables start 
  17. 关闭： service iptables stop 
  18. 重启: service iptables restart 
  19.   20. 2） 永久性生效，重启后不会复原 
  21. 开启： chkconfig iptables on 
  22. 关闭： chkconfig iptables off 
  23. */ 

  
  

**参考：**

[MySQL多实例配置](http://blog.csdn.net/leshami/article/details/40339167)  

[mysql多实例的安装和管理(一台服务器上运行两个mysql实例)](http://blog.csdn.net/ying1989920/article/details/49520921)  

  

  * 上一篇 [一张图看懂数据库高可用扩展](http://blog.csdn.net/kk185800961/article/details/53554549)
  * 下一篇 [MySQL 5.7.15 两台服务器双实例相互复制](http://blog.csdn.net/kk185800961/article/details/53818364)

  


---
### ATTACHMENTS
[3d323e68560a89a87c34d6ca9208bc6b]: media/category_icon.jpg
[category_icon.jpg](media/category_icon.jpg)
>hash: 3d323e68560a89a87c34d6ca9208bc6b  
>source-url: http://csdnimg.cn/release/phoenix/images/category_icon.jpg  
>file-name: category_icon.jpg  

[f30265b383f13b79b97a6c2d060e1888]: media/arrow_triangle__down.jpg
[arrow_triangle__down.jpg](media/arrow_triangle__down.jpg)
>hash: f30265b383f13b79b97a6c2d060e1888  
>source-url: http://csdnimg.cn/release/phoenix/images/arrow_triangle%20_down.jpg  
>file-name: arrow_triangle _down.jpg  

---
### NOTE ATTRIBUTES
>Created Date: 2018-02-27 08:11:08  
>Last Evernote Update Date: 2018-10-01 15:35:38  
>author: YangKwong  
>source: web.clip  
>source-url: http://blog.csdn.net/kk185800961/article/details/53810019  