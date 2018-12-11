## Liunx下更改MySQL用户密码
## 方法1： 用SET PASSWORD命令

------

```
mysql -u root
mysql> SET PASSWORD FOR 'root'@'localhost' = PASSWORD('newpass');
```

## 方法2：用mysqladmin

------

```
mysqladmin -u root password "newpass"
#如果root已经设置过密码，采用如下方法
mysqladmin -u root password oldpass "newpass"
```

## 方法3： 用UPDATE直接编辑user表

------

```
mysql -u root
mysql> use mysql;
mysql> UPDATE user SET Password = PASSWORD('newpass') WHERE user = 'root';
mysql> FLUSH PRIVILEGES;
```

## 在丢失root密码的时候

## 方法一

------

```
mysqld_safe --skip-grant-tables &
mysql -u root mysql
mysql> UPDATE user SET password=PASSWORD("new password") WHERE user='root';
mysql> FLUSH PRIVILEGES;
```

## 方法二
----
## Step1 修改配置文件

修改MySQL的配置文件（默认为/etc/my.cnf）,在[mysqld]下添加一行skip-grant-tables

```
[root@PolarSnow hexo]# cat /etc/my.cnf 
[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
user=mysql
# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0
character-set-server=utf8
innodb_file_per_table=1
skip-grant-tables
```

## Step2 重启MySQL服务

```
service mysqld restart
```

## Step3 再次进入MySQL命令行

`mysql -uroot -p` 输入密码时直接回车，就会进入MySQL数据库了

接下来按照常规流程修改root密码即可