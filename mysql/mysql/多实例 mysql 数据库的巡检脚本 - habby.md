# 多实例 mysql 数据库的巡检脚本 - habby

  

[root@mysql-back ~]# cat mysql_check.sh

#!/bin/bash  
TXT=system_check_$(date +%F-%H:%M).txt  
echo '  
memory  
' >> $TXT  
free -m >> $TXT  
  
echo '  
  
disks information  
' >> $TXT  
df -h >> $TXT  
  
echo '  
  
mysql status  
' >> $TXT  
netstat -nlp|grep mysql >> $TXT  
  
echo '  
  
3306  
' >> $TXT  
mysql -t -S /data/mysql/mysqldata3306/sock/mysql.sock -phabby -e "SHOW
VARIABLES LIKE '%connection%';select
substring_index(host,':',1),time,count(*)from INFORMATION_SCHEMA.processlist
group by substring_index(host,':',1);SHOW STATUS LIKE '%connection%';" >> $TXT  
  
echo '  
  
3307  
' >> $TXT  
mysql -t -S /data/mysql/mysqldata3307/sock/mysql.sock -phabby -e "SHOW
VARIABLES LIKE '%connection%';select
substring_index(host,':',1),time,count(*)from INFORMATION_SCHEMA.processlist
group by substring_index(host,':',1);SHOW STATUS LIKE '%connection%';" >> $TXT  
  
echo '  
  
3308  
' >> $TXT  
mysql -t -S /data/mysql/mysqldata3308/sock/mysql.sock -phabby -e "SHOW
VARIABLES LIKE '%connection%';select
substring_index(host,':',1),time,count(*)from INFORMATION_SCHEMA.processlist
group by substring_index(host,':',1);SHOW STATUS LIKE '%connection%';" >> $TXT  
  
echo '  
  
3309  
' >> $TXT  
mysql -t -S /data/mysql/mysqldata3309/sock/mysql.sock -phabby -e "SHOW
VARIABLES LIKE '%connection%';select
substring_index(host,':',1),time,count(*)from INFORMATION_SCHEMA.processlist
group by substring_index(host,':',1);SHOW STATUS LIKE '%connection%';" >> $TXT  

  

cat $TXT

  


---
### NOTE ATTRIBUTES
>Created Date: 2017-10-02 00:25:05  
>Last Evernote Update Date: 2018-10-01 15:35:39  
>author: YangKwong  
>source: web.clip  
>source-url: https://my.oschina.net/u/1403438/blog/177495  