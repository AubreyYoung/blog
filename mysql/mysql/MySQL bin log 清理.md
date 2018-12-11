# MySQL bin log 清理

  

Title: MySQL bin log 清理  
date: 2016-05-17  
comments: true  
category: DB  
tags: mysql

* * *

# MySQL bin log 清理

* * *

## 查看 MySQL binlog

    
    
    ## 查看第一个binlog文件的内容
    show binlog events;
    
    ## 查看指定binlog文件的内容
    show binlog events in 'mysql-bin.000008';
    
    ## 获取binlog文件列表
    show binary logs;
    
    ## 注意针对有主从同步的情况下
    ## 主机是 'master' 角色的（主库A的从库B，也可以是别的主机的master）
    
    ##查看'master' 正在写入的binlog文件
    show master status\G
    
    ##查看'slave' 正在使用那个二进制文件
    show slave status\G

* * *

## 清理 MySQL binlog

### 1，自动清理 - 重启数据库

    
    
    vim /etc/my.cnf
    ## 自动清理10天之前的
    expire_logs_days = 10

### 2，自动清理 - 不重启数据库

    
    
    ## 数据库中查询设置
    > show variables like 'expire_logs_days';
    > set global expire_logs_days = 10;

### 3，手动清理

    
    
    > PURGE MASTER LOGS BEFORE DATE_SUB(CURRENT_DATE, INTERVAL 10 DAY);

### Reference

    
    
    refer to: http://blog.sina.com.cn/s/blog_6741f2480100mz3u.html

  


---
### NOTE ATTRIBUTES
>Created Date: 2017-10-03 03:17:54  
>Last Evernote Update Date: 2018-10-01 15:35:39  
>author: YangKwong  
>source: web.clip  
>source-url: http://www.jianshu.com/p/a67fdefc748c  