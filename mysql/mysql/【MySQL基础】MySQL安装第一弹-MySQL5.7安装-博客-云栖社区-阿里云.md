# 【MySQL基础】MySQL安装第一弹-MySQL5.7安装

  



# 【MySQL基础】MySQL安装第一弹-MySQL5.7安装

[tplinux](https://yq.aliyun.com/users/1673111694169886) 2017-09-01 15:50:25
浏览360 评论1

[mysql](https://yq.aliyun.com/tags/type_blog-tagid_389/)
[LOG](https://yq.aliyun.com/tags/type_blog-tagid_471/)
[配置](https://yq.aliyun.com/tags/type_blog-tagid_698/)
[操作系统](https://yq.aliyun.com/tags/type_blog-tagid_1060/)
[open](https://yq.aliyun.com/tags/type_blog-tagid_1467/)
[CPU](https://yq.aliyun.com/tags/type_blog-tagid_1913/)
[file](https://yq.aliyun.com/tags/type_blog-tagid_2235/)

摘要： MySQL基础 -MySQL安装第一弹-MySQL5.7安装

  

  

MySQL安装第一弹-MySQL5.7安装

## 一.操作系统选择

Centos/RHEL/ORACLE LIUNX 5.X/6.X/7.X x86_64 发行版

如果是其他操作系统 则参考官方文档

[](https://www.mysql.com/support/supportedplatforms/database.html)
_<https://www.mysql.com/support/supportedplatforms/database.html>_  MySQL支持的平台

## 二.操作系统参数调整

### 2.1 selinux设置

  

[root@localhost ~]# cat /etc/selinux/config

SELINUX=disabled

  

#关闭selinux

### 2.2 **调整最大文件数限制**

  

[root@localhost ~]# ulimit -a

core file size (blocks, -c) 0

data seg size (kbytes, -d) unlimited

scheduling priority (-e) 0

file size (blocks, -f) unlimited

pending signals (-i) 7861

max locked memory (kbytes, -l) 64

max memory size (kbytes, -m) unlimited

open files (-n) 1024

pipe size (512 bytes, -p) 8

POSIX message queues (bytes, -q) 819200

real-time priority (-r) 0

stack size (kbytes, -s) 8192

cpu time (seconds, -t) unlimited

max user processes (-u) 7861

virtual memory (kbytes, -v) unlimited

file locks (-x) unlimited

#open files   最大打开文件数限制

#max user processes 每个用户最大processes数量

  

vim /etc/security/limits.conf

* soft nofile 65535

* hard nofile 65535

* soft nproc 65535

* hard nproc 65535

[root@localhost ~]# ulimit -a

open files (-n) 65535

max user processes (-u) 65535

#每个操作系统修改方式可能不一样，参考一个操作系统的官方文档或google一下

### 2.3 io调度器修改

io调度器修改为deadline

  

echo “deadline” > /sys/block/sdb/queue/scheduler

这里的sdb 修改为实际的设备名称 例如 sda 或者sdc。 /data所在的设备名称

 B) 需要加入到 /etc/rc.local 中开启自动加载

###

###  

2.4系统内核参数修改

  

vm.swappiness =5 #控制linux物理RAM内存进行SWAP页交换的相对权重

vm.dirty_ratio =5 #脏页占整个内存的比例，开始刷新

vm.dirty_background_ratio = 10 #脏页占程序的百分比 ,开始刷新

  

###  **2.5 关闭NUMA特性**

新一代架构的NUMA不适用于跑数据库的场景。它本意是为了提高内存利用率，但实际效果不好，反而可能导致一个CPU的内存尚有剩余，但另一个不够用，发生SWAP的问题，因此建议直接关闭或者修改NUMA的调度机制。

a) 修改/etc/grub.conf，关闭NUMA，重启后生效

修改/etc/grub.conf 配置文件，在kernel 那行增加一个配置后重启生效，例如：

kernel /vmlinuz-2.6.18-308.el5 ro root=LABEL=/1elevator=deadlinenuma=off rhgb
quiet

b) 修改/etc/init.d/mysql 或者mysqld_safe 脚本，设定启动mysqld进程时的NUMA调度机制，例如：

numactl --interleave=all /usr/local/mysql/bin/mysqld_safe .......

c) BIOS硬件中关闭

#注 a b c 方法中任选其一。

###  **2.6 关闭CPU的节能模式 **

CPU启用节能模式后，会节约电量，但也可能带来CPU性能下降的问题。因此，运行数据库类业务时，建议关闭节能模式，发挥CPU的最大性能。

Aï¼BIOS硬件中关闭

# 如果不是非核心业务 并且不繁忙的情况下 可以不用调整

  

## 三 MySQL环境

###  **3.1 环境规范定义**

MySQL安装包下载地址：https://dev.mysql.com/downloads/mysql/

#选择MySQL5.7版本 最新的分支版本 已经GA的

 目录定义

 #/usr/local/mysql #MySQL程序目录

 #/data/mysql{端口号}/data 数据目录

 #/data/mysql{端口号}/log  binlog目录

### 3.2安装MySQL

a)创建MySQL用户

  

useradd mysql -s /sbin/nologin

b) 上传MySQL二进制包并解压

  

  

[root@localhost local]# tar -zxvf mysql-5.7.19-linux-glibc2.12-x86_64.tar.gz

  

  

c) 创建软链接

  

[root@localhost local]# ln -s mysql-5.7.19-linux-glibc2.12-x86_64 mysql

  

d）根据目录定义创建目录

e）修改权限

  

[root@localhost local]# chown mysql:mysql /data/

[root@localhost local]# chown mysql:mysql /data/* -R

[root@localhost local]# chown mysql:mysql /usr/local/mysql

[root@localhost local]# chown mysql:mysql /usr/local/mysql/* -R

  

f)安装需的软件包



yum groupinstall Development Tools

g) 修改MySQL配置文件

  

[client]

port = 3306

socket = /tmp/mysql.sock

  

[mysql]

prompt="\\\u@\\\h:\\\p [\\\d]>

#pager="less -i -n -S"

##tee=/home/mysql/query.log

no-auto-rehash

  

[mysqld]

#misc

user = mysql

basedir = /usr/local/mysql

datadir = /data/mysql3306/data

port = 3306

socket = /tmp/mysql.sock

event_scheduler = 0

binlog_format = row

server-id = 63306

log-bin = /data/mysql3306/log/mysql-bin

#一个最基础的配置文件 ，后续会针对做讲解和配置优化



k）初始化MySQL

`/usr/local/mysql/bin/mysqld --initialize --user=mysql
--basedir=/usr/local/mysql`

  

h）启动MySQL

`/usr/local/mysql/bin/mysqld_safe --defaults-file=/etc/my.cnf &`

  

i）密码

  

  

2017-08-31T10:00:15.372625Z 1 [Note] A temporary password is generated for
root@localhost: Nw!,dJKwa3)3

  

#初始化成功后屏幕会输出密码，或者errorlog中也会打印

登录后

  

  

  

  

  

本文为云栖社区原创内容，未经允许不得转载，如需转载请发送邮件至yqeditor@list.alibaba-
inc.com；如果您发现本社区中有涉嫌抄袭的内容，欢迎发送邮件至：yqgroup@service.aliyun.com
进行举报，并提供相关证据，一经查实，本社区将立刻删除涉嫌侵权内容。

![noteattachment1][e77cd6c7dd7335ca7d21a57bb14a19db]

用云栖社区APP，舒服~

【云栖快讯】浅析混合云和跨地域网络构建实践，分享高性能负载均衡设计，9月21日阿里云专家和你说说网络那些事儿，足不出户看直播，赶紧预约吧！
[详情请点击](https://yq.aliyun.com/promotion/340)

[评论文章
(](https://yq.aliyun.com/articles/188260?spm=5176.100240.searchblog.8.0vymFP#comment)[1](https://yq.aliyun.com/articles/188260?spm=5176.100240.searchblog.8.0vymFP#comment))
(0) (1)


分享到:


    [](http://service.weibo.com/share/share.php?title=%E3%80%90MySQL%E5%9F%BA%E7%A1%80%E3%80%91MySQL%E5%AE%89%E8%A3%85%E7%AC%AC%E4%B8%80%E5%BC%B9-MySQL5.7%E5%AE%89%E8%A3%85+MySQL%E5%9F%BA%E7%A1%80+-MySQL%E5%AE%89%E8%A3%85%E7%AC%AC%E4%B8%80%E5%BC%B9-MySQL5.7%E5%AE%89%E8%A3%85&url=https%3A%2F%2Fyq.aliyun.com%2Farticles%2F188260)[](http://service.weibo.com/share/share.php?title=%E3%80%90MySQL%E5%9F%BA%E7%A1%80%E3%80%91MySQL%E5%AE%89%E8%A3%85%E7%AC%AC%E4%B8%80%E5%BC%B9-MySQL5.7%E5%AE%89%E8%A3%85+MySQL%E5%9F%BA%E7%A1%80+-MySQL%E5%AE%89%E8%A3%85%E7%AC%AC%E4%B8%80%E5%BC%B9-MySQL5.7%E5%AE%89%E8%A3%85&url=https%3A%2F%2Fyq.aliyun.com%2Farticles%2F188260)

 __

​    

[上一篇：【开篇】自我介绍和博客未来规划](https://yq.aliyun.com/articles/187987)

[下一篇：【MySQL基础】MySQL安装第二弹-Percona5.7安装](https://yq.aliyun.com/articles/188293)

###  相关文章

[【MySQL基础】MySQL安装第二弹-Percona5…](https://yq.aliyun.com/articles/188293)

[【MySQL基础】MySQL安装第三弹-mariadb-…](https://yq.aliyun.com/articles/188307)

[MySQL5.7.10下载及安装及配置](https://yq.aliyun.com/articles/14324)

[VirturalBox中搭建CentOS开发环境实录（二…](https://yq.aliyun.com/articles/40390)

[迄今最安全的MySQL？细数5.7那些惊艳与鸡肋的新特性…](https://yq.aliyun.com/articles/79612)

[CentOS6.5下安装MySQL5.7](https://yq.aliyun.com/articles/7894)

[mysql 5.7版本安装问题](https://yq.aliyun.com/articles/70149)

[阿里云ECS CentOs7.3下搭建LAMP环境（Ap…](https://yq.aliyun.com/articles/106387)

[CentOS6 安装并破解Jira 7](https://yq.aliyun.com/articles/141089)

[MySQL 5.7新特性](https://yq.aliyun.com/articles/60616)

### 网友评论

[
![noteattachment2][a9e7e14b62dca2244b65e6eba33bb071]](https://yq.aliyun.com/users/1216041734171346)
1F

[liups](https://yq.aliyun.com/users/1216041734171346) 2017-09-02 20:45:58

yum groupinstall Development Tools 没必要 安装整个 group吧

[](https://yq.aliyun.com/articles/188260?spm=5176.100240.searchblog.8.0vymFP#modal-
login
"赞")[](https://yq.aliyun.com/articles/188260?spm=5176.100240.searchblog.8.0vymFP#modal-
login) 0
[](https://yq.aliyun.com/articles/188260?spm=5176.100240.searchblog.8.0vymFP#modal-
login
"评论")[](https://yq.aliyun.com/articles/188260?spm=5176.100240.searchblog.8.0vymFP#modal-
login)
[2](https://yq.aliyun.com/articles/188260?spm=5176.100240.searchblog.8.0vymFP#modal-
login)

[
![noteattachment3][8aaaadc3bbd792a59ce7a10bbdb1ce66]](https://yq.aliyun.com/users/1673111694169886)

[tplinux](https://yq.aliyun.com/users/1673111694169886) 2017-09-05 10:33:58

为什么没必要嘛 系统是最小化安装还是需要一些依赖包的

[](https://yq.aliyun.com/articles/188260?spm=5176.100240.searchblog.8.0vymFP#modal-
login
"赞")[](https://yq.aliyun.com/articles/188260?spm=5176.100240.searchblog.8.0vymFP#modal-
login) 0

[
![noteattachment4][0f7dfe61b257703b6c4dd88521bb6db1]](https://yq.aliyun.com/users/1216041734171346)

[liups](https://yq.aliyun.com/users/1216041734171346) 2017-09-21 04:45:02

是需要一些依赖，但不是整个 Development Tools group都依赖哦，本着够用原则，只yum install 需要的软件包就可以了呀

[](https://yq.aliyun.com/articles/188260?spm=5176.100240.searchblog.8.0vymFP#modal-
login
"赞")[](https://yq.aliyun.com/articles/188260?spm=5176.100240.searchblog.8.0vymFP#modal-
login) 0

登录后可评论，请
[登录](https://account.aliyun.com/login/login.htm?from_type=yqclub&oauth_callback=https%3A%2F%2Fyq.aliyun.com%2Farticles%2F188260%3Fspm%3D5176.100240.searchblog.8.0vymFP%26do%3Dlogin)
或
[注册](https://account.aliyun.com/register/register.htm?from_type=yqclub&oauth_callback=https%3A%2F%2Fyq.aliyun.com%2Farticles%2F188260%3Fspm%3D5176.100240.searchblog.8.0vymFP%26do%3Dlogin)

[评论](https://yq.aliyun.com/articles/188260?spm=5176.100240.searchblog.8.0vymFP#modal-
login)

  

---
### ATTACHMENTS
[0f7dfe61b257703b6c4dd88521bb6db1]: media/avatar3.jpg64h_64w_2e.jpg
[avatar3.jpg64h_64w_2e.jpg](media/avatar3.jpg64h_64w_2e.jpg)
>hash: 0f7dfe61b257703b6c4dd88521bb6db1  
>source-url: https://yqfile.alicdn.com/avatar3.jpg@64h_64w_2e  
>file-name: avatar3.jpg@64h_64w_2e.jpg  

[8aaaadc3bbd792a59ce7a10bbdb1ce66]: media/img_6585f13d936cd97715e7692dd7830116.jpg64h_64w_2e.jpg
[img_6585f13d936cd97715e7692dd7830116.jpg64h_64w_2e.jpg](media/img_6585f13d936cd97715e7692dd7830116.jpg64h_64w_2e.jpg)
>hash: 8aaaadc3bbd792a59ce7a10bbdb1ce66  
>source-url: https://yqfile.alicdn.com/img_6585f13d936cd97715e7692dd7830116.jpg@64h_64w_2e  
>file-name: img_6585f13d936cd97715e7692dd7830116.jpg@64h_64w_2e.jpg  

[a9e7e14b62dca2244b65e6eba33bb071]: media/avatar3.jpg64h_64w_2e-2.jpg
[avatar3.jpg64h_64w_2e-2.jpg](media/avatar3.jpg64h_64w_2e-2.jpg)
>hash: a9e7e14b62dca2244b65e6eba33bb071  
>source-url: https://yqfile.alicdn.com/avatar3.jpg@64h_64w_2e  
>file-name: avatar3.jpg@64h_64w_2e.jpg  

[e77cd6c7dd7335ca7d21a57bb14a19db]: media/e77cd6c7dd7335ca7d21a57bb14a19db.png
[e77cd6c7dd7335ca7d21a57bb14a19db.png](media/e77cd6c7dd7335ca7d21a57bb14a19db.png)
>hash: e77cd6c7dd7335ca7d21a57bb14a19db  
>source-url: https://yqfile.alicdn.com/e77cd6c7dd7335ca7d21a57bb14a19db.png  
>file-name: e77cd6c7dd7335ca7d21a57bb14a19db.png  

---
### NOTE ATTRIBUTES
>Created Date: 2017-09-25 09:15:08  
>Last Evernote Update Date: 2018-01-09 03:38:04  
>author: YangKwong  
>source: web.clip  
>source-url: https://yq.aliyun.com/articles/188260  