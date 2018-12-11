# phpadmin安装教程_析句_新浪博客

  

## phpadmin安装教程

(2012-08-16 15:22:58)

转载 _▼_

标签：

### [php](http://search.sina.com.cn/?c=blog&q=php&by=tag)

### [数据库](http://search.sina.com.cn/?c=blog&q=%CA%FD%BE%DD%BF%E2&by=tag)

|  
---|---  
  
phpMyAdmin 就是一种 MySQL 数据库的管理工具，安装该工具后，即可以通过 web 形式直接管理 MySQL
数据，而不需要通过执行系统命令来管理，非常适合对数据库操作命令不熟悉的数据库管理者，下面详细说明该工具的安装方法。

**一、下载**

先到互联网上下载 phpMyAdmin，也可以到 phpMyAdmin
官方网站下载，地址为：<http://www.phpmyadmin.net/home_page/index.php> 再解压到 web
可以访问的目录下，如果是虚拟空间，可以解压后通过 ftp 工具上传到 web 目录下，同时您可以修改解压后该文件的名称。

**二、配置**

打开 libraries 目录下的 config.default.php 文件，依次找到下面各项，按照说明配置即可。

1、访问网址

  * CODE: [[COPY]](http://faq.comsenz.com/viewnews-484)

  * $cfg['PmaAbsoluteUri'] = '';这里填写 phpMyAdmin 的访问网址。<P></P>

2、MySQL 主机信息

  * CODE: [[COPY]](http://faq.comsenz.com/viewnews-484)

  * $cfg['Servers'][$i]['host'] = 'localhost'; // MySQL hostname or IP address<P></P>

填写 localhost  或 MySQL  所在服务器的 ip 地址，如果 MySQL 和该 phpMyAdmin 在同一服务器，则按默认
localhost

  * CODE: [[COPY]](http://faq.comsenz.com/viewnews-484)

  * $cfg['Servers'][$i]['port'] = ''; // MySQL port \- leave blank for default port<P></P>

MySQL 端口，默认为 3306，保留为空即可，如果您安装 MySQL 时使用了其它的端口，需要在这里填写。

3、MySQL 用户名和密码

  * CODE: [[COPY]](http://faq.comsenz.com/viewnews-484)

  * $cfg['Servers'][$i]['user'] = 'root'; // 填写 MySQL 访问 phpMyAdmin 使用的 MySQL 用户名，默认为 root。<P></P>

  * CODE: [[COPY]](http://faq.comsenz.com/viewnews-484)

  * fg['Servers'][$i]['password'] = ''; // 填写对应上述 MySQL 用户名的密码。<P></P>

4、认证方法

  * CODE: [[COPY]](http://faq.comsenz.com/viewnews-484)

  * $cfg['Servers'][$i]['auth_type'] = 'cookie';考虑到安全的因素，建议这里填写 cookie。<P></P>

在此有四种模式可供选择，cookie，http，HTTP，config

config 方式即输入 phpMyAdmin 的访问网址即可直接进入，无需输入用户名和密码，是不安全的，不推荐使用。

当该项设置为 cookie，http 或 HTTP 时，登录 phpMyAdmin 需要数据用户名和密码进行验证，具体如下：

PHP 安装模式为 Apache，可以使用 http 和 cookie；

PHP 安装模式为 CGI，可以使用 cookie。

5、短语密码（blowfish_secret）的设置

  * CODE: [[COPY]](http://faq.comsenz.com/viewnews-484)

  * $cfg['blowfish_secret'] = '';<P></P>

如果认证方法设置为 cookie，就需要设置短语密码，设置为什么密码，由您自己决定，这里不能留空，否则会在登录 phpMyAdmin
时提示如下图所示的错误。

[![phpadmin安装教程]()](http://faq.comsenz.com/batch.download.php?aid=1242)

安装完成后，我们可以在浏览器进行访问，如下图所示：

[![phpadmin安装教程]()](http://faq.comsenz.com/batch.download.php?aid=1243)

**说明：**

该文档说明的只是安装 phpMyAdmin 的基本配置，关于 config.default.php 文件中各个配置参数的详细说明可以参考：

<http://www.discuz.net/viewthread.php?tid=50789>

**三、在什么情况下会用到 phpMyAdmin**

1、需要修复数据库的时候，参考：<http://faq.comsenz.com/viewnews-378>

2、设置数据库用户权限的时候，参考：<http://faq.comsenz.com/viewnews-164>

3、检查和浏览数据库的时候

4、执行 SQL  语句的时候

5、恢复和备份数据库的时候

6、还会用到一些常见问题上

  

分享：

9

喜欢

2

赠金笔

阅读(23045) _┊_
[评论](http://blog.sina.com.cn/s/blog_625e702801012xoo.html#commonComment) (0)
_┊_ 收藏 (0)
_┊_[转载](http://blog.sina.com.cn/s/blog_625e702801012xoo.html#)[(4)](http://blog.sina.com.cn/s/blog_625e702801012xoo.html#)
_┊_ 喜欢 **▼**
_┊_[打印](http://blog.sina.com.cn/main_v5/ria/print.html?blog_id=blog_625e702801012xoo)
_┊_[举报](http://blog.sina.com.cn/s/blog_625e702801012xoo.html#)

已投稿到： |

[排行榜](http://blog.sina.com.cn/lm/114/117/day.html)  
  
---|---  
  
前一篇：[mysql 主从设置](http://blog.sina.com.cn/s/blog_625e702801012r2x.html)

后一篇：[php时间](http://blog.sina.com.cn/s/blog_625e70280101364k.html)

.

**评论** [重要提示：警惕虚假中奖信息](http://blog.sina.com.cn/lm/8/2009/0325/105340.html)

[[ 发评论]](http://blog.sina.com.cn/s/blog_625e702801012xoo.html#post)

  * 做第一个评论者吧！ [抢沙发>>](http://blog.sina.com.cn/s/blog_625e702801012xoo.html#post)

**发评论**

China慕黎：您还未开通博客，点击一秒开通。

[](http://blog.sina.com.cn/s/blog_625e702801012xoo.html#)[](http://blog.sina.com.cn/s/blog_625e702801012xoo.html#)[](http://blog.sina.com.cn/s/blog_625e702801012xoo.html#)[](http://blog.sina.com.cn/s/blog_625e702801012xoo.html#)[](http://blog.sina.com.cn/s/blog_625e702801012xoo.html#)[](http://blog.sina.com.cn/s/blog_625e702801012xoo.html#)

[更多>>](http://blog.sina.com.cn/s/blog_625e702801012xoo.html#)

  * [](http://blog.sina.com.cn/s/blog_625e702801012xoo.html#)
  * [](http://blog.sina.com.cn/s/blog_625e702801012xoo.html#)
  * [](http://blog.sina.com.cn/s/blog_625e702801012xoo.html#)
  * [](http://blog.sina.com.cn/s/blog_625e702801012xoo.html#)
  * [](http://blog.sina.com.cn/s/blog_625e702801012xoo.html#)
  * [](http://blog.sina.com.cn/s/blog_625e702801012xoo.html#)
  * [](http://blog.sina.com.cn/s/blog_625e702801012xoo.html#)
  * [](http://blog.sina.com.cn/s/blog_625e702801012xoo.html#)

评论并转载此博文

发评论

以上网友发言只代表其个人观点，不代表新浪网的观点或立场。

< 前一篇[mysql 主从设置](http://blog.sina.com.cn/s/blog_625e702801012r2x.html)

后一篇 >[php时间](http://blog.sina.com.cn/s/blog_625e70280101364k.html)

.

  


---
### ATTACHMENTS
[06dfc7a6a4443a362fe59241b00fa296]: media/308-25.gif
[308-25.gif](media/308-25.gif)
>hash: 06dfc7a6a4443a362fe59241b00fa296  
>source-url: http://www.sinaimg.cn/uc/myshow/blog/misc/gif/308-25.gif  
>file-name: 308-25.gif  

[1246dc01cceba5a12b602b9ad8180514]: media/E___0317EN00SIGT.gif
[E___0317EN00SIGT.gif](media/E___0317EN00SIGT.gif)
>hash: 1246dc01cceba5a12b602b9ad8180514  
>source-url: http://www.sinaimg.cn/uc/myshow/blog/misc/gif/E___0317EN00SIGT.gif  
>file-name: E___0317EN00SIGT.gif  

[2eaf5759c624bb739aca2622e148700a]: media/302-25.gif
[302-25.gif](media/302-25.gif)
>hash: 2eaf5759c624bb739aca2622e148700a  
>source-url: http://www.sinaimg.cn/uc/myshow/blog/misc/gif/302-25.gif  
>file-name: 302-25.gif  

[3b240d0e9eae4b7c6197f8fab10b1702]: media/E___0314EN00SIGT.gif
[E___0314EN00SIGT.gif](media/E___0314EN00SIGT.gif)
>hash: 3b240d0e9eae4b7c6197f8fab10b1702  
>source-url: http://www.sinaimg.cn/uc/myshow/blog/misc/gif/E___0314EN00SIGT.gif  
>file-name: E___0314EN00SIGT.gif  

[3d045b93716ed28dc745e648b3428a26]: media/sg_trans.gif
[sg_trans.gif](media/sg_trans.gif)
>hash: 3d045b93716ed28dc745e648b3428a26  
>source-url: http://simg.sinajs.cn/blog7style/images/common/sg_trans.gif  
>file-name: sg_trans.gif  

[51d95c625d8c5610f45d58dc37d280b8]: media/316-25.gif
[316-25.gif](media/316-25.gif)
>hash: 51d95c625d8c5610f45d58dc37d280b8  
>source-url: http://www.sinaimg.cn/uc/myshow/blog/misc/gif/316-25.gif  
>file-name: 316-25.gif  

[611a51114d7c6eff84fc818f65970912]: media/351-25.gif
[351-25.gif](media/351-25.gif)
>hash: 611a51114d7c6eff84fc818f65970912  
>source-url: http://www.sinaimg.cn/uc/myshow/blog/misc/gif/351-25.gif  
>file-name: 351-25.gif  

[7181d90928f071d1156b7847de371df6]: media/E___0319EN00SIGT.gif
[E___0319EN00SIGT.gif](media/E___0319EN00SIGT.gif)
>hash: 7181d90928f071d1156b7847de371df6  
>source-url: http://www.sinaimg.cn/uc/myshow/blog/misc/gif/E___0319EN00SIGT.gif  
>file-name: E___0319EN00SIGT.gif  

[7e7e50e134c12151f97f7242c5c95f28]: media/315-25.gif
[315-25.gif](media/315-25.gif)
>hash: 7e7e50e134c12151f97f7242c5c95f28  
>source-url: http://www.sinaimg.cn/uc/myshow/blog/misc/gif/315-25.gif  
>file-name: 315-25.gif  

[923143c5761d4f7b43fc2d7d5c2f63bd]: media/E___0318EN00SIGT.gif
[E___0318EN00SIGT.gif](media/E___0318EN00SIGT.gif)
>hash: 923143c5761d4f7b43fc2d7d5c2f63bd  
>source-url: http://www.sinaimg.cn/uc/myshow/blog/misc/gif/E___0318EN00SIGT.gif  
>file-name: E___0318EN00SIGT.gif  

[ad9a93062d7b8da99f27c895735e5444]: media/331-25.gif
[331-25.gif](media/331-25.gif)
>hash: ad9a93062d7b8da99f27c895735e5444  
>source-url: http://www.sinaimg.cn/uc/myshow/blog/misc/gif/331-25.gif  
>file-name: 331-25.gif  

[d793e328a982caaf891b0548b0214ee7]: media/E___0316EN00SIGT.gif
[E___0316EN00SIGT.gif](media/E___0316EN00SIGT.gif)
>hash: d793e328a982caaf891b0548b0214ee7  
>source-url: http://www.sinaimg.cn/uc/myshow/blog/misc/gif/E___0316EN00SIGT.gif  
>file-name: E___0316EN00SIGT.gif  

[df1ba34d18674813621b3023b74c8e15]: media/E___0320EN00SIGT.gif
[E___0320EN00SIGT.gif](media/E___0320EN00SIGT.gif)
>hash: df1ba34d18674813621b3023b74c8e15  
>source-url: http://www.sinaimg.cn/uc/myshow/blog/misc/gif/E___0320EN00SIGT.gif  
>file-name: E___0320EN00SIGT.gif  

[df452b0e424d6354a7d70699357ba1d4]: media/E___0315EN00SIGT.gif
[E___0315EN00SIGT.gif](media/E___0315EN00SIGT.gif)
>hash: df452b0e424d6354a7d70699357ba1d4  
>source-url: http://www.sinaimg.cn/uc/myshow/blog/misc/gif/E___0315EN00SIGT.gif  
>file-name: E___0315EN00SIGT.gif  

[fefa0a53ca8c0637966c3def0e9ccd5a]: media/E___0321EN00SIGT.gif
[E___0321EN00SIGT.gif](media/E___0321EN00SIGT.gif)
>hash: fefa0a53ca8c0637966c3def0e9ccd5a  
>source-url: http://www.sinaimg.cn/uc/myshow/blog/misc/gif/E___0321EN00SIGT.gif  
>file-name: E___0321EN00SIGT.gif  


---
### TAGS
{phpadmin}

---
### NOTE ATTRIBUTES
>Created Date: 2018-01-08 04:54:17  
>Last Evernote Update Date: 2018-10-01 15:35:39  
>author: YangKwong  
>source: web.clip  
>source-url: http://blog.sina.com.cn/s/blog_625e702801012xoo.html  