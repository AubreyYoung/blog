# mysql远程登陆设置

  

  

>use mysql

  

>GRANT ALL ON *.* to root@'%' IDENTIFIED BY '111111';

或

> grant all privileges on *.* to 'root'@'%' identified by '111111' with grant
option;

  

>FLUSH PRIVILEGES;

  

![noteattachment1][decaa3c34ffd6ba496faeda8c71f3a76]

  


---
### ATTACHMENTS
[decaa3c34ffd6ba496faeda8c71f3a76]: media/mysql远程登陆设置.png
[mysql远程登陆设置.png](media/mysql远程登陆设置.png)

---
### TAGS
{Error 1130}

---
### NOTE ATTRIBUTES
>Created Date: 2016-05-21 19:52:02  
>Last Evernote Update Date: 2018-01-03 08:44:30  
>source: web.clip  
>source-url: http://stackoverflow.com/questions/2857446/error-1130-in-mysql  