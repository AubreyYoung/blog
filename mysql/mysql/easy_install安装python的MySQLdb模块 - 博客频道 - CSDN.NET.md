# easy_install安装python的MySQLdb模块 - 博客频道 - CSDN.NET

  

    

原

###
[easy_install安装python的MySQLdb模块](http://blog.csdn.net/a657941877/article/details/8944683)

分类： _ubuntu_ _python_ _mysql_

__ （9601） __ （0）

# 1.首先要安装easy_install

**[html]** [view
plain](http://blog.csdn.net/a657941877/article/details/8944683# "view plain")
[copy](http://blog.csdn.net/a657941877/article/details/8944683# "copy")

[](https://code.csdn.net/snippets/160913
"在CODE上查看代码片")[](https://code.csdn.net/snippets/160913/fork "派生到我的代码片")

  1. apt-get install python-setuptools 

或者

**[plain]** [view
plain](http://blog.csdn.net/a657941877/article/details/8944683# "view plain")
[copy](http://blog.csdn.net/a657941877/article/details/8944683# "copy")

[](https://code.csdn.net/snippets/160913
"在CODE上查看代码片")[](https://code.csdn.net/snippets/160913/fork "派生到我的代码片")

  1. yum install python-setuptools 

  
  

# 2.接着安装MySQLdb模块

**[html]** [view
plain](http://blog.csdn.net/a657941877/article/details/8944683# "view plain")
[copy](http://blog.csdn.net/a657941877/article/details/8944683# "copy")

[](https://code.csdn.net/snippets/160913
"在CODE上查看代码片")[](https://code.csdn.net/snippets/160913/fork "派生到我的代码片")

  1. easy_install mysql-python 

  

## 1.如果报错

**[html]** [view
plain](http://blog.csdn.net/a657941877/article/details/8944683# "view plain")
[copy](http://blog.csdn.net/a657941877/article/details/8944683# "copy")

[](https://code.csdn.net/snippets/160913
"在CODE上查看代码片")[](https://code.csdn.net/snippets/160913/fork "派生到我的代码片")

  1. EnvironmentError: mysql_config not found 

这是因为缺少libmysqlclient-dev  

以Ubuntu为例：  
假如已经安装debian / ubuntu:sudo apt-get install mysql  
mysql-config是在不同的模块，并不在mysql里面。  

执行

**[html]** [view
plain](http://blog.csdn.net/a657941877/article/details/8944683# "view plain")
[copy](http://blog.csdn.net/a657941877/article/details/8944683# "copy")

[](https://code.csdn.net/snippets/160913
"在CODE上查看代码片")[](https://code.csdn.net/snippets/160913/fork "派生到我的代码片")

  1. sudo apt-get install libmysqlclient-dev 

  

centos则执行

**[plain]** [view
plain](http://blog.csdn.net/a657941877/article/details/8944683# "view plain")
[copy](http://blog.csdn.net/a657941877/article/details/8944683# "copy")

[](https://code.csdn.net/snippets/160913
"在CODE上查看代码片")[](https://code.csdn.net/snippets/160913/fork "派生到我的代码片")

  1. yum install mysql-devel 

  
  

## 2.如果报错

**[html]** [view
plain](http://blog.csdn.net/a657941877/article/details/8944683# "view plain")
[copy](http://blog.csdn.net/a657941877/article/details/8944683# "copy")

[](https://code.csdn.net/snippets/160913
"在CODE上查看代码片")[](https://code.csdn.net/snippets/160913/fork "派生到我的代码片")

  1. _mysql.c:29:20: 致命错误： Python.h：没有那个文件或目录 

执行

**[html]** [view
plain](http://blog.csdn.net/a657941877/article/details/8944683# "view plain")
[copy](http://blog.csdn.net/a657941877/article/details/8944683# "copy")

[](https://code.csdn.net/snippets/160913
"在CODE上查看代码片")[](https://code.csdn.net/snippets/160913/fork "派生到我的代码片")

  1. sudo apt-get install python-dev 

  
  

  


---
### ATTACHMENTS
[02725c4f62b67dc23f2b87e776850078]: media/ico_fork.svg
[ico_fork.svg](media/ico_fork.svg)
>hash: 02725c4f62b67dc23f2b87e776850078  
>source-url: https://code.csdn.net/assets/ico_fork.svg  
>file-name: ico_fork.svg  

[ba3acbf6d7a3420d26db10207385a617]: media/CODE_ico.png
[CODE_ico.png](media/CODE_ico.png)
>hash: ba3acbf6d7a3420d26db10207385a617  
>source-url: https://code.csdn.net/assets/CODE_ico.png  
>file-name: CODE_ico.png  


---
### TAGS
{mysqldb}  {python}

---
### NOTE ATTRIBUTES
>Created Date: 2017-07-02 08:31:57  
>Last Evernote Update Date: 2018-10-01 15:35:39  
>source: web.clip  
>source-url: http://blog.csdn.net/a657941877/article/details/8944683  