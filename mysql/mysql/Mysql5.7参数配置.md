# Mysql5.7参数配置

  

log-error=/var/lib/mysql/galaxy.err

pid-file=/var/run/mysqld/mysqld.pid

  

general-log=1

general_log_file=/var/lib/mysql/galaxy.log

  

log-output=FILE

log-queries-not-using-indexes=1

  

slow_query_log=1

slow_query_log_file=/var/lib/mysql/galaxy-slow.log

  

log-bin=mysql-bin

server_id=1

  


---
### NOTE ATTRIBUTES
>Created Date: 2016-05-21 19:14:03  
>Last Evernote Update Date: 2016-06-20 21:43:55  
>author: Galaxy  
>source: desktop.win  
>source-application: evernote.win32  