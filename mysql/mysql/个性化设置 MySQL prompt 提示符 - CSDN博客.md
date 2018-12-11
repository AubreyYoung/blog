# 个性化设置 MySQL prompt 提示符 - CSDN博客

  

# 个性化设置 MySQL prompt 提示符

原创  2013年04月09日 20:27:02

  * 
.

**下 面谈 4 种方法**  
  
  

**㈠ 在 Bash 层修改 MYSQL_PS1 变量**

  

 **[plain]** [view
plain](http://blog.csdn.net/dba_waterbin/article/details/8779502# "view
plain") [copy](http://blog.csdn.net/dba_waterbin/article/details/8779502#
"copy")

  1. [root@localhost ~]# export MYSQL_PS1="(\u@\h) [\d]> " 
  2. [root@localhost ~]# mysql -u root -p 
  3. Enter password: 
  4. Welcome to the MySQL monitor. Commands end with ; or \g. 
  5. Your MySQL connection id is 73 
  6. Server version: 5.5.28 MySQL Community Server (GPL) 
  7.   8. Copyright (c) 2000, 2012, Oracle and/or its affiliates. All rights reserved. 
  9.   10. Oracle is a registered trademark of Oracle Corporation and/or its 
  11. affiliates. Other names may be trademarks of their respective 
  12. owners. 
  13.   14. Type 'help;' or '\h' for help. Type '\c' to clear the current input statement. 
  15.   16. (root@localhost) [(none)]> use test; 
  17. Database changed 
  18. (root@localhost) [test]>

  
  

**㈡ MySQL 命令行参数**  

  

 **[plain]** [view
plain](http://blog.csdn.net/dba_waterbin/article/details/8779502# "view
plain") [copy](http://blog.csdn.net/dba_waterbin/article/details/8779502#
"copy")

  1. [root@localhost ~]# mysql -u root -p --prompt="(\u@\h) [\d]> " 
  2. Enter password: 
  3. Welcome to the MySQL monitor. Commands end with ; or \g. 
  4. Your MySQL connection id is 74 
  5. Server version: 5.5.28 MySQL Community Server (GPL) 
  6.   7. Copyright (c) 2000, 2012, Oracle and/or its affiliates. All rights reserved. 
  8.   9. Oracle is a registered trademark of Oracle Corporation and/or its 
  10. affiliates. Other names may be trademarks of their respective 
  11. owners. 
  12.   13. Type 'help;' or '\h' for help. Type '\c' to clear the current input statement. 
  14.   15. (root@localhost) [(none)]>

  
  

**㈢ 配置文件 /etc/my.cnf**  

  

 **[plain]** [view
plain](http://blog.csdn.net/dba_waterbin/article/details/8779502# "view
plain") [copy](http://blog.csdn.net/dba_waterbin/article/details/8779502#
"copy")

  1. [mysql] 
  2. prompt=(\\\u@\\\h) [\\\d]>\\\\_ 
  3.   4. 又或者： 
  5. [mysql] 
  6. prompt="\\\r:\\\m:\\\s> " 
  7.   8. 要多加一个反斜线\\. 

  
  

**㈣ 在 MySQL 中使用 prompt 命令**  

  

 **[sql]** [view
plain](http://blog.csdn.net/dba_waterbin/article/details/8779502# "view
plain") [copy](http://blog.csdn.net/dba_waterbin/article/details/8779502#
"copy")

  1. mysql> prompt \r:\m:\s\P>\\_ 
  2. PROMPT set to '\r:\m:\s\P>\\_'
  3. 08:20:42pm> prompt 
  4. Returning to default PROMPT of mysql>
  5. mysql>

  
  

**附录：**  

  

 **[plain]** [view
plain](http://blog.csdn.net/dba_waterbin/article/details/8779502# "view
plain") [copy](http://blog.csdn.net/dba_waterbin/article/details/8779502#
"copy")

  1. Option Description 
  2.   3. \c A counter that increments for each statement you issue 
  4. \D The full current date 
  5. \d The default database 
  6. \h The server host 
  7. \l The current delimiter (new in 5.0.25) 
  8. \m Minutes of the current time 
  9. \n A newline character 
  10. \O The current month in three-letter format (Jan, Feb, …) 
  11. \o The current month in numeric format 
  12. \P am/pm 
  13. \p The current TCP/IP port or socket file 
  14. \R The current time, in 24-hour military time (0–23) 
  15. \r The current time, standard 12-hour time (1–12) 
  16. \S Semicolon 
  17. \s Seconds of the current time 
  18. \t A tab character 
  19. \U 
  20. Your full user_name@host_name account name 
  21.   22. \u Your user name 
  23. \v The server version 
  24. \w The current day of the week in three-letter format (Mon, Tue, …) 
  25. \Y The current year, four digits 
  26. \y The current year, two digits 
  27. \\_ A space 
  28. \ A space (a space follows the backslash) 
  29. \' Single quote 
  30. \" Double quote 
  31. \\\ A literal “\” backslash character 
  32. \x 
  33. x, for any “x” not listed above 

  
  

  


---
### NOTE ATTRIBUTES
>Created Date: 2018-03-19 01:39:51  
>Last Evernote Update Date: 2018-10-01 15:35:37  
>author: YangKwong  
>source: web.clip  
>source-url: http://blog.csdn.net/dba_waterbin/article/details/8779502  