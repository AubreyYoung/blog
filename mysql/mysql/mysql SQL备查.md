# mysql SQL备查

  

  

停用mysql5.7复杂密码

validate-password = off

  

  

ALTER USER 'root'@'localhost' IDENTIFIED BY 'oracle';

  

delete from mysql.user where User = 'userguy';

delete from mysql.db where User = 'userguy';

  

set global sql_slave_skip_counter=1;

  

mysqlbinlog  -v --base64-output=DECODE-ROWS mysql-bin.000001

  

CREATE USER 'repl'@'192.168.45.33' IDENTIFIED BY 'oracle';

GRANT REPLICATION SLAVE ON *.* TO 'repl'@'192.168.45.33';  



mysqldump -uroot -p --databases sampdb --master-data > sampdbdump.db  



CHANGE MASTER TO  

MASTER_HOST='192.168.45.32',  

MASTER_USER='repl',  

MASTER_PASSWORD='oracle',  

MASTER_LOG_FILE='mysql-bin.000001',  

MASTER_LOG_POS=0;  

  

REVOKE ALL ON sampdb.*  FROM sampadm@'localhost '  

  



---
### TAGS
{5.7}  {mysql复杂密码}

---
### NOTE ATTRIBUTES
>Created Date: 2017-08-14 06:42:42  
>Last Evernote Update Date: 2017-09-07 05:01:55  
>source: web.clip  
>source-url: https://opvps.com:2368/mysql-validate_password/  