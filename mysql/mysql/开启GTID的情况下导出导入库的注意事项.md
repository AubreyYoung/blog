# 开启GTID的情况下导出导入库的注意事项

## 开启GTID的情况下导出导入库的注意事项

__ 发表于 2016-10-28 | __ 更新于: 2016-10-28 | __ 分类于
[MySQL](https://docs.lvrui.io/categories/MySQL/) | __ [ 0
](https://docs.lvrui.io/2016/10/28/%E5%BC%80%E5%90%AFGTID%E7%9A%84%E6%83%85%E5%86%B5%E4%B8%8B%E5%AF%BC%E5%87%BA%E5%AF%BC%E5%85%A5%E5%BA%93%E7%9A%84%E6%B3%A8%E6%84%8F%E4%BA%8B%E9%A1%B9/#comments)
| __ 阅读次数: 1731 | __

__ 字数统计: 2k | __ 阅读时长 ≈ 0:02

> 在开启了 GTID 功能的 MySQL 数据库中, 不论是否使用了 GTID 的方式做了主从同步, 导出导入时都需要特别注意数据库中的 GTID 信息.

#
[](https://docs.lvrui.io/2016/10/28/%E5%BC%80%E5%90%AFGTID%E7%9A%84%E6%83%85%E5%86%B5%E4%B8%8B%E5%AF%BC%E5%87%BA%E5%AF%BC%E5%85%A5%E5%BA%93%E7%9A%84%E6%B3%A8%E6%84%8F%E4%BA%8B%E9%A1%B9/#%E5%AF%BC%E5%87%BA
"导出")导出

    
    
    1  
    2  
    

|

    
    
    ➜  mysqldump -uroot -p userdb > userdb.sql  
    Warning: A partial dump from a server that has GTIDs will by default include the GTIDs of all transactions, even those that changed suppressed parts of the database. If you don't want to restore GTIDs, pass --set-gtid-purged=OFF. To make a complete dump, pass --all-databases --triggers --routines --events  
      
  
---|---  
  
mysql提示: 当前数据库实例中开启了 GTID 功能, 在开启有 GTID 功能的数据库实例中, 导出其中任何一个库, 如果没有显示地指定`--set-
gtid-purged`参数, 都会提示这一行信息. 意思是默认情况下, 导出的库中含有 GTID 信息, 如果不想导出包含有 GTID 信息的数据库,
需要显示地添加`--set-gtid-purged=OFF`参数. 于是乎, dump 变成了如下样子

`➜ mysqldump -uroot -p --set-gtid-purged=OFF userdb > userdb.sql`

使用以上这条命令 dump 出来的库是不包含 GTID 信息的

#
[](https://docs.lvrui.io/2016/10/28/%E5%BC%80%E5%90%AFGTID%E7%9A%84%E6%83%85%E5%86%B5%E4%B8%8B%E5%AF%BC%E5%87%BA%E5%AF%BC%E5%85%A5%E5%BA%93%E7%9A%84%E6%B3%A8%E6%84%8F%E4%BA%8B%E9%A1%B9/#%E5%AF%BC%E5%85%A5
"导入")导入

导入的时候也分两种, 一种是导入带有 GTID 的信息的库, 一种是导入不带有 GTID 信息的库

##
[](https://docs.lvrui.io/2016/10/28/%E5%BC%80%E5%90%AFGTID%E7%9A%84%E6%83%85%E5%86%B5%E4%B8%8B%E5%AF%BC%E5%87%BA%E5%AF%BC%E5%85%A5%E5%BA%93%E7%9A%84%E6%B3%A8%E6%84%8F%E4%BA%8B%E9%A1%B9/#%E4%B8%8D%E5%B8%A6%E6%9C%89-GTID-%E4%BF%A1%E6%81%AF
"不带有 GTID 信息")不带有 GTID 信息

不带有 GTID 信息的 dump 文件, 不管目标数据库实例是否开启了 GTID 功能, 且不管数据库实例是否已有其他 GTID 信息, 都可以顺利导入

##
[](https://docs.lvrui.io/2016/10/28/%E5%BC%80%E5%90%AFGTID%E7%9A%84%E6%83%85%E5%86%B5%E4%B8%8B%E5%AF%BC%E5%87%BA%E5%AF%BC%E5%85%A5%E5%BA%93%E7%9A%84%E6%B3%A8%E6%84%8F%E4%BA%8B%E9%A1%B9/#%E5%B8%A6%E6%9C%89-GTID-%E4%BF%A1%E6%81%AF
"带有 GTID 信息")带有 GTID 信息

带有 GTID 信息的 dump 文件, 要求目标数据库实例必须开启 GTID 功能, 且当前数据库中无其他 GTID 信息.
如果目标数据库中已经记录了一条或一条以上的 GTID 信息, 那么在导入数据库时会报出类似如下的错误❌

    
    
    1  
    2  
    3  
    

|

    
    
    ➜  mysql -uroot -p userdb < userdb.sql  
    Password:xxxxxxxx  
    ERROR 1840 (HY000) at line 24: @@GLOBAL.GTID_PURGED can only be set when @@GLOBAL.GTID_EXECUTED is empty.  
      
  
---|---  
  
在 mysql5.7版本中加入了多 channel 的特性, 一台数据库实例可以同时与多个主库同步, 实现多主一从架构, 但是假如现在数据库实例中开启了
GTID, 并以 GTID 的方式与 A 主库和 B 主库同步,那么现在的 slave 中就记录有两条 GTID 信息. 在导入带有新 GTID
信息的库时, 会报错, 要求你清除掉目标数据库实例中所有的 GTID 信息. 在这种情况下, 问题就比较严重了,
因为我的这台数据库已经和两台主库建立主从关系, 现在为了导入一个新库, 需要 reset 掉所有同步信息(GTID 信息)

这个时候你有两个选择:

  1. 重新 dump 数据库, 使用`--set-gtid-purged=OFF`的参数禁止导出 GTID 信息,再 load 进目标数据库
  2. 在目标数据库中执行`mysql> reset slave all;` `mysql> reset master;` 清空所有 GTID 信息之后就可以导入了

  * **本文作者：** 极地瑞雪 
  * **本文链接：** [https://docs.lvrui.io/2016/10/28/开启GTID的情况下导出导入库的注意事项/](https://docs.lvrui.io/2016/10/28/%E5%BC%80%E5%90%AFGTID%E7%9A%84%E6%83%85%E5%86%B5%E4%B8%8B%E5%AF%BC%E5%87%BA%E5%AF%BC%E5%85%A5%E5%BA%93%E7%9A%84%E6%B3%A8%E6%84%8F%E4%BA%8B%E9%A1%B9/ "开启GTID的情况下导出导入库的注意事项")
  * **版权声明：** 本博客所有文章除特别声明外，均采用 [CC BY-NC-SA 3.0](https://creativecommons.org/licenses/by-nc-sa/3.0/) 许可协议。转载请注明出处！ 

[# mysqldump](https://docs.lvrui.io/tags/mysqldump/) [#
GTID](https://docs.lvrui.io/tags/GTID/) [# --set-gtid-
purged](https://docs.lvrui.io/tags/set-gtid-purged/)

__

[ __ mysql修改sql_mode
](https://docs.lvrui.io/2016/10/12/mysql%E4%BF%AE%E6%94%B9sql-mode/
"mysql修改sql_mode")

[ Docker动态扩容Pool大小与container大小 __
](https://docs.lvrui.io/2016/12/12/Docker%E5%8A%A8%E6%80%81%E6%89%A9%E5%AE%B9Pool%E5%A4%A7%E5%B0%8F%E4%B8%8Econtainer%E5%A4%A7%E5%B0%8F/
"Docker动态扩容Pool大小与container大小")

Emoji | Preview

[](https://segmentfault.com/markdown)

快来做第一个评论的人吧~

Powered By [Valine](https://valine.js.org/)  
v1.3.1


---
### NOTE ATTRIBUTES
>Created Date: 2018-09-05 05:01:52  
>Last Evernote Update Date: 2018-10-01 15:35:35  
>source: web.clip7  
>source-url: https://docs.lvrui.io/2016/10/28/%E5%BC%80%E5%90%AFGTID%E7%9A%84%E6%83%85%E5%86%B5%E4%B8%8B%E5%AF%BC%E5%87%BA%E5%AF%BC%E5%85%A5%E5%BA%93%E7%9A%84%E6%B3%A8%E6%84%8F%E4%BA%8B%E9%A1%B9/  
>source-application: WebClipper 7  