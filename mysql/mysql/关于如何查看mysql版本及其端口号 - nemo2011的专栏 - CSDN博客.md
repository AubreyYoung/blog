# 关于如何查看mysql版本及其端口号 - nemo2011的专栏 - CSDN博客

  

#  [ 关于如何查看mysql版本及其端口号
](http://blog.csdn.net/nemo2011/article/details/8990871)

2013-05-29 19:33 82915人阅读
[评论](http://blog.csdn.net/nemo2011/article/details/8990871#comments)(2) 收藏
[举报](http://blog.csdn.net/nemo2011/article/details/8990871#report "举报")

.

![](http://static.blog.csdn.net/images/category_icon.jpg) 分类：

数据库 _（13）_ ![](http://static.blog.csdn.net/images/arrow_triangle%20_down.jpg)

.

版权声明：本文为博主原创文章，未经博主允许不得转载。

关于如何查看[MySQL](http://lib.csdn.net/base/mysql "MySQL知识库")版本：

方法一：

进入[mysql](http://lib.csdn.net/base/mysql "MySQL知识库") cmd，

**[cpp]** [view plain](http://blog.csdn.net/nemo2011/article/details/8990871#
"view plain") [copy](http://blog.csdn.net/nemo2011/article/details/8990871#
"copy")

  1. status; 

将显示当前mysql的version的各种信息。  

  

方法二：

还是在mysql的cmd下，输入：

**[cpp]** [view plain](http://blog.csdn.net/nemo2011/article/details/8990871#
"view plain") [copy](http://blog.csdn.net/nemo2011/article/details/8990871#
"copy")

  1. select version(); 

  

查看MySQL端口号：

**[cpp]** [view plain](http://blog.csdn.net/nemo2011/article/details/8990871#
"view plain") [copy](http://blog.csdn.net/nemo2011/article/details/8990871#
"copy")

  1. show global variables like 'port'; 

  

[](http://blog.csdn.net/nemo2011/article/details/8990871#)
[](http://blog.csdn.net/nemo2011/article/details/8990871# "分享到QQ空间")
[](http://blog.csdn.net/nemo2011/article/details/8990871# "分享到新浪微博")
[](http://blog.csdn.net/nemo2011/article/details/8990871# "分享到腾讯微博")
[](http://blog.csdn.net/nemo2011/article/details/8990871# "分享到人人网")
[](http://blog.csdn.net/nemo2011/article/details/8990871# "分享到微信") .

顶

    6

踩

    1

  * 上一篇[在.cpp文件中，memset struct类型 所引发的segmentation fault](http://blog.csdn.net/nemo2011/article/details/8980397)
  * 下一篇[安装perl和DBI-mysql出现的一些问题](http://blog.csdn.net/nemo2011/article/details/8996415)

####

相关文章推荐

  * _•_ [如何查看mysql 默认端口号和修改端口号](http://blog.csdn.net/yangzongzhuan/article/details/50516269 "如何查看mysql 默认端口号和修改端口号")
  * _•_ [查看本地mysql端口号](http://blog.csdn.net/u010289053/article/details/50758847 "查看本地mysql端口号")
  * _•_ [mysql怎么查看端口号](http://blog.csdn.net/u012427311/article/details/12679687 "mysql怎么查看端口号")
  * _•_ [mysql操作指南-----如何查看mysql 端口号](http://blog.csdn.net/u014796999/article/details/48395727 "mysql操作指南-----如何查看mysql 端口号")
  * _•_ [查看MySQL端口号](http://blog.csdn.net/bingtingabc/article/details/20921757 "查看MySQL端口号")

  * _•_ [如何查看MySQL数据库的端口](http://blog.csdn.net/bjhk00/article/details/54946963 "如何查看MySQL数据库的端口")
  * _•_ [关于如何查看mysql版本及其端口号](http://blog.csdn.net/qi_ruihua/article/details/40074253 "关于如何查看mysql版本及其端口号")
  * _•_ [[Mysql] mac下查看并修改端口号方法](http://blog.csdn.net/xiaohaoyao/article/details/51202322 "\[Mysql\] mac下查看并修改端口号方法")
  * _•_ [解决MAC下安装MySQL查看端口为0的问题](http://blog.csdn.net/lixingqiao01/article/details/50956849 "解决MAC下安装MySQL查看端口为0的问题")
  * _•_ [开放端口个人经验图解（这里以MySQL端口开放为例）](http://blog.csdn.net/Jacy_Lee_LDF/article/details/52611768 "开放端口个人经验图解（这里以MySQL端口开放为例）")

  



---
### TAGS
{端口}

---
### NOTE ATTRIBUTES
>Created Date: 2017-08-14 06:58:19  
>Last Evernote Update Date: 2018-10-01 15:35:39  
>source: web.clip  
>source-url: http://blog.csdn.net/nemo2011/article/details/8990871  