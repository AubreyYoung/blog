# mysql修改root密码和设置权限 - 小往 - 博客园

  

  

## [mysql修改root密码和设置权限](http://www.cnblogs.com/wangs/p/3346767.html)

Posted on 2013-09-30 09:54 [小往](http://www.cnblogs.com/wangs/) 阅读(18719) 评论(0)
[编辑](https://i.cnblogs.com/EditPosts.aspx?postid=3346767)
[收藏](http://www.cnblogs.com/wangs/p/3346767.html#)

整理了以下四种在MySQL中修改root密码的方法,可能对大家有所帮助!

方法1： 用SET PASSWORD命令

mysql -u root

mysql> SET PASSWORD FOR
['root'@'localhost'](http://www.cnblogs.com/wangs/p/3346767.htmlmailto:'root'@'localhost')
= PASSWORD('newpass');

方法2：用mysqladmin

mysqladmin -u root password "newpass"

如果root已经设置过密码，采用如下方法

mysqladmin -u root password oldpass "newpass"

方法3： 用UPDATE直接编辑user表

mysql -u root

mysql> use mysql;

mysql> UPDATE user SET Password = PASSWORD('newpass') WHERE user = 'root';

mysql> FLUSH PRIVILEGES;

在丢失root密码的时候，可以这样

mysqld_safe --skip-grant-tables&

mysql -u root mysql

mysql> UPDATE user SET password=PASSWORD("new password") WHERE user='root';

mysql> FLUSH PRIVILEGES;



设置权限：

 GRANT ALL PRIVILEGES ON *.* TO
['root'@'%'](http://www.cnblogs.com/wangs/p/3346767.htmlmailto:'root'@'%')
IDENTIFIED BY 'admin123' WITH GRANT OPTION; flush privileges;

root默认是不支持远程登录的,用外网连接你必须给权限呢？GRANT ALL PRIVILEGES ON *.* TO
['username'@'](http://www.uzzf.com/cr5577/mailto:'username'@') %' IDENTIFIED
BY 'password' WITH GRANT OPTION;你先创建一个远程登录的账号然后给它远程登录的权限

mysql的root账户,我在连接时通常用的是localhost或127.0.0.1,公司的测试服务器上的mysql也是localhost所以我想访问无法访问,测试暂停.

解决方法如下:

1,修改表,登录mysql数据库,切换到mysql数据库,使用sql语句查看"select host,user from user ;" mysql -u
root -pvmwaremysql>use mysql; mysql>update user set host = '%' where user
='root'; mysql>select host, user from user; mysql>flush privileges;
注意:最后一句很重要,目的是使修改生效.如果没有写,则还是不能进行远程连接.

2,授权用户,你想root使用密码从任何主机连接到mysql服务器 GRANT ALL PRIVILEGES ON *.* TO 'root'@'%'
IDENTIFIED BY 'admin123' WITH GRANT OPTION; flush privileges;
如果你想允许用户root从ip为192.168.1.104的主机连接到mysql服务器 GRANT ALL PRIVILEGES ON *.* TO
'myuser'@'192.168.1.104' IDENTIFIED BY 'admin123' WITH GRANT OPTION; flush
privileges;

路由器外网访问mysql数据库

1.符合以下条件

公网IP 无论动态还是静态 静态更好 动态如果嫌麻烦可以用DDNS服务 如花生壳

2.开放端口

无论你是否是路由连入 还是拨号连入 路由需要在路由器中做3306端口映射 拨号宽带需要在防火墙中允许3306端口访问 可以用telnet命令测试

3.MYSQL用户权限 （这里比较重要）

在安装MYSQL是 ROOT默认是只有本地访问权限 localhost可以在安装的时候改成可以远程remote安装的最后一步 有个选项框要勾
这是WINDOWS版本的 如果是LINUX版本用命令加权限

如果建立新用户 一定要要有%远程权限才可以

4测试

在自带命令行中测试 mysql -h（IP地址） -u用户名 -p（密码） 回车后如果出现mysql>

即OK



以前只会用

mysql> select * from mysql.user where user='username';

  

今天发现这个更方便：

mysql> show grants for username@localhost;

  

show可以看到很多东西

show create database dbname;  这个可以看到创建数据库时用到的一些参数。

show create table tickets;    可以看到创建表时用到的一些参数





1、修改表,登录mysql数据库,切换到mysql数据库,使用sql语句查看

"select host,user from user ;"

\mysql -u root -pvmwaremysql>use mysql;

\mysql>update user set host = '%' where user ='root';

\mysql>select host, user from user;

\mysql>flush privileges;

  

注意:最后一句很重要,目的是使修改生效.如果没有写,则还是不能进行远程连接.

  

2、授权用户,你想root使用密码从任何主机连接到mysql服务器

\GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'admin123' WITH GRANT
OPTION;flush privileges;

  

如果你想允许用户root从ip为192.168.12.16的主机连接到mysql服务器

\GRANT ALL PRIVILEGES ON *.* TO 'root'@'192.168.1.16'   IDENTIFIED BY '123456'
WITH GRANT OPTION;





可以通过对某个用户授权来限制这个连接帐号的访问，比如：

grant select on db.table1 to user1@'1.2.3.%' identified by 'password';

  

这样user1只能在1.2.3.% 这个范围内来访问你的mysql server .

  

lz 是这个意思否 ？

好文要顶 关注我 收藏该文 ![noteattachment1][c5fd93bfefed3def29aa5f58f5173174]
![noteattachment2][24de3321437f4bfd69e684e353f2b765]

[
![noteattachment3][2e5cdf5a2b4a166fe92206ca35bbfc6e]](http://home.cnblogs.com/u/wangs/)

[小往](http://home.cnblogs.com/u/wangs/)

[关注 - 0](http://home.cnblogs.com/u/wangs/followees)

[粉丝 - 6](http://home.cnblogs.com/u/wangs/followers)

+加关注

1

0

[«](http://www.cnblogs.com/wangs/p/3341399.html)
上一篇：[eclipse快捷键](http://www.cnblogs.com/wangs/p/3341399.html "发布于2013-09-26
19:36")

[»](http://www.cnblogs.com/wangs/p/3358524.html) 下一篇：[eclipse
@override错误](http://www.cnblogs.com/wangs/p/3358524.html "发布于2013-10-09
09:35")  
  
---  
  
  

  


---
### ATTACHMENTS
[24de3321437f4bfd69e684e353f2b765]: media/wechat-2.png
[wechat-2.png](media/wechat-2.png)
>hash: 24de3321437f4bfd69e684e353f2b765  
>source-url: http://common.cnblogs.com/images/wechat.png  
>file-name: wechat.png  

[2e5cdf5a2b4a166fe92206ca35bbfc6e]: media/u54516.pn.jpg
[u54516.pn.jpg](media/u54516.pn.jpg)
>hash: 2e5cdf5a2b4a166fe92206ca35bbfc6e  
>source-url: http://pic.cnblogs.com/face/u54516.png  
>file-name: u54516.png.jpg  

[c5fd93bfefed3def29aa5f58f5173174]: media/icon_weibo_24-2.png
[icon_weibo_24-2.png](media/icon_weibo_24-2.png)
>hash: c5fd93bfefed3def29aa5f58f5173174  
>source-url: http://common.cnblogs.com/images/icon_weibo_24.png  
>file-name: icon_weibo_24.png  

---
### NOTE ATTRIBUTES
>Created Date: 2018-03-02 02:03:26  
>Last Evernote Update Date: 2018-03-14 01:07:04  
>author: YangKwong  
>source: web.clip  
>source-url: http://www.cnblogs.com/wangs/p/3346767.html  