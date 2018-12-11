# 如何设置MySql默认的日期格式 - CSDN博客

  

# 如何设置MySql默认的日期格式

转载  2014年12月23日 09:52:57

  * 
.

    
    
    通过sql语句查询下 看看现在的值
    
    show variables like '%date%';
    默认的值是：
    date_format= %Y-%m-%d
    datetime_format=%Y-%m-%d %H:%i:%s
    
    然后在mysql的配置文件my.cnf 或者 my.ini中 加入  
    [mysqld]
    date_format= %Y/%m/%d
    datetime_format=%Y/%m/%d %H:%i:%s
    最后mysql服务器重启即可。
    
    
    from http://zhidao.baidu.com/question/155033826.html

  



---
### TAGS
{date}

---
### NOTE ATTRIBUTES
>Created Date: 2018-02-27 02:14:56  
>Last Evernote Update Date: 2018-10-01 15:35:38  
>author: YangKwong  
>source: web.clip  
>source-url: http://blog.csdn.net/u012307002/article/details/42098951  