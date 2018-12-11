# MySQL资料大全-博客-云栖社区-阿里云

  

  1. 云栖社区>
  2. [博客列表](https://yq.aliyun.com/articles?spm=5176.100239.blogcont52879.1.tlOh6M)>
  3. 正文

#  MySQL资料大全

[readygo](https://yq.aliyun.com/users/1997958006223678?spm=5176.100239.blogcont52879.2.tlOh6M)
2016-05-26 22:09:31 浏览13353 评论1

[服务器](https://yq.aliyun.com/tags/type_blog-
tagid_372/?spm=5176.100239.blogcont52879.3.tlOh6M)
[mysql](https://yq.aliyun.com/tags/type_blog-
tagid_389/?spm=5176.100239.blogcont52879.4.tlOh6M)
[github](https://yq.aliyun.com/tags/type_blog-
tagid_2740/?spm=5176.100239.blogcont52879.5.tlOh6M)
[关系型数据库](https://yq.aliyun.com/tags/type_blog-
tagid_12889/?spm=5176.100239.blogcont52879.6.tlOh6M)
[云数据库RDS](https://yq.aliyun.com/tags/type_blog-
tagid_13730/?spm=5176.100239.blogcont52879.7.tlOh6M)

_摘要：_ 为了让开发者更好的了解使用MySQL，充分发挥其灵活性的优势。云栖社区组织翻译了GitHub Awesome MySQL
资源，其中不仅涵盖MySQL部署、开发、性能测试等操作中使用的工具包和库，还包括MySQL相关的会议、多媒体等资源。

MySQL是一种关联数据库管理系统，关联数据库将数据保存在不同的表中，而不是将所有数据放在一个大仓库内，这样就增加了速度并提高了灵活性。MySQL 所使用的
SQL 语言是用于访问数据库的最常用标准化语言。MySQL
软件采用了双授权政策，它分为社区版和商业版，由于其体积小、速度快、总体拥有成本低，尤其是开放源码这一特点，一般中小型网站的开发都选择 MySQL
作为网站数据库。

为了让开发者更好的了解使用MySQL，充分发挥其灵活性的优势。云栖社区组织翻译了GitHub Awesome MySQL
资源，其中不仅涵盖MySQL部署、开发、性能测试等操作中使用的工具包和库，还包括MySQL相关的会议、多媒体等资源。

# 目录

###

  * [MySQL](https://yq.aliyun.com/articles/preview/?spm=5176.100239.blogcont52879.8.tlOh6M#awesome-mysql)  

    * 分析
    * 备份
    * 性能测试
    * 聊天工具
    * 配置
    * 连接器
    * 部署
    * 开发
    * [GUI](https://yq.aliyun.com/articles/preview/?spm=5176.100239.blogcont52879.9.tlOh6M#gui)
    * [HA](https://yq.aliyun.com/articles/preview/?spm=5176.100239.blogcont52879.10.tlOh6M#ha)
    * 代理
    * 复制
    * 模式
    * 服务器
    * 分片
    * 工具包
  * 资源  

    * 会议
    * 电子书
    * 多媒体
    * 新闻周刊

## 分析

性能、结构和数据分析工具

  * [Anemometer](https://github.com/box/Anemometer?spm=5176.100239.blogcont52879.11.tlOh6M) \- Box SQL慢查询监控器  

  * [innodb-ruby](https://github.com/jeremycole/innodb_ruby?spm=5176.100239.blogcont52879.12.tlOh6M) \- Ruby中的InnoDB文件格式分析器
  * [innotop](https://github.com/innotop/innotop?spm=5176.100239.blogcont52879.13.tlOh6M) \- innotop是一个MySQL的顶级克隆品，其功能多样化并兼具灵活性
  * [pstop](https://github.com/sjmudd/ps-top?spm=5176.100239.blogcont52879.14.tlOh6M) \- MySQL中的一个顶级应用程序，用于搜集、汇总和显示来自performance_schema中的信息  

  * [mysql-statsd](https://github.com/db-art/mysql-statsd?spm=5176.100239.blogcont52879.15.tlOh6M) \- 一个Python进程，用于从MySQL中收集信息，然后将其通过 StatsD发送到Graphite中  

  * [MySQLTuner-perl](http://mysqltuner.com/?spm=5176.100239.blogcont52879.16.tlOh6M) \- 一个用于使用者快速回顾MySQL的安装过程，然后做出相应的调整以提高性能和稳定性的脚本

## 备份

备份/还原/恢复工具

  * [MyDumper](https://launchpad.net/mydumper?spm=5176.100239.blogcont52879.17.tlOh6M) \- MySQL中逻辑、并行备份/转存工具  

  * [MySQLDumper](http://www.mysqldumper.net/?spm=5176.100239.blogcont52879.18.tlOh6M) \- 基于Web的开源备份工具-对共享虚拟主机很有帮助  

  * [Percona Xtrabackup](http://www.percona.com/doc/percona-xtrabackup?spm=5176.100239.blogcont52879.19.tlOh6M) \- MySQL中的一个基于服务器的开源的热备份实用程序-在备份过程中不锁定你的数据库  

## 性能测试

用于服务器压测的工具

  * [iibench-mysql](https://github.com/tmcallaghan/iibench-mysql?spm=5176.100239.blogcont52879.20.tlOh6M) \- MySQL/Percona/MariaDB中基于 Java 版本的索引插入性能测试工具  

  * [Sysbench](https://github.com/akopytov/sysbench?spm=5176.100239.blogcont52879.21.tlOh6M) \-  一个模块化、跨平台以及多线程的性能测试工具  

## 聊天工具

集成到聊天室的脚本

  * [Hubot MySQL ChatOps](https://github.com/samlambert/hubot-mysql-chatops?spm=5176.100239.blogcont52879.22.tlOh6M)  

## 配置

MySQL 配置实例及指导

  * [mysql-compatibility-config](https://github.com/morgo/mysql-compatibility-config?spm=5176.100239.blogcont52879.23.tlOh6M) \- 让MySQL的配置更像是新的（或老版本）的MySQL 版本  

## 连接器

多种编程语言的MySQL连接器

  * [Connector/Python](https://dev.mysql.com/downloads/connector/python/?spm=5176.100239.blogcont52879.24.tlOh6M) \- Python平台和开发的标准化数据库驱动程序  

  * [go-sql-driver](https://github.com/go-sql-driver/mysql?spm=5176.100239.blogcont52879.25.tlOh6M) \- 一个面向Go 语言的数据库/SQL包的轻量级极速的 MySQL 驱动程序  

  * [libAttachSQL](http://libattachsql.org/?spm=5176.100239.blogcont52879.26.tlOh6M) \- libAttachSQL 是MySQL 服务器的一个轻量级、非阻塞的C语言API  

  * [MariaDB Java Client](https://mariadb.com/kb/en/mariadb/mariadb-connector-j/?spm=5176.100239.blogcont52879.27.tlOh6M) \- \- 针对 Java 应用的 MariaDB 客户端库，满足LGPL协议许可  

  * [MySQL-Python](http://sourceforge.net/projects/mysql-python/?spm=5176.100239.blogcont52879.28.tlOh6M) \- 用于连接 Python 程序的 MySQL 数据库连接器  

  * [PHP mysqlnd](https://dev.mysql.com/downloads/connector/php-mysqlnd/?spm=5176.100239.blogcont52879.29.tlOh6M) \- MySQL的本地驱动，摒弃了过时的 libmysql 基础驱动  

## 部署

MySQL 部署工具

  * [MySQL Docker](https://hub.docker.com/_/mysql/?spm=5176.100239.blogcont52879.30.tlOh6M) \- Docker官方镜像  

  * [MySQL Sandbox](http://mysqlsandbox.net/?spm=5176.100239.blogcont52879.31.tlOh6M) \- 可秒级安装一个或多个MySQL服务器的工具，该工具方便、安全且全控制  

## 开发

MySQL相关的开发工具

  * [Flywaydb](http://flywaydb.org/getstarted/?spm=5176.100239.blogcont52879.32.tlOh6M) \- 数据库与迁移；任何情况下都可轻松可靠地演进数据库版本；[Liquibase](http://www.liquibase.org/?spm=5176.100239.blogcont52879.33.tlOh6M) \- 用于数据库的源码控制  

  * [Propagator](https://github.com/outbrain/propagator?spm=5176.100239.blogcont52879.34.tlOh6M) 一个用于多维拓扑上集中模式和数据部署的工具  

##
[](https://yq.aliyun.com/articles/preview/?spm=5176.100239.blogcont52879.35.tlOh6M#gui)GUI

GUI前端和应用

  * [Adminer](https://www.adminer.org/?spm=5176.100239.blogcont52879.36.tlOh6M) \- 用于单个PHP文件中的数据库管理  

  * [HeidiSQL](http://www.heidisql.com/?spm=5176.100239.blogcont52879.37.tlOh6M) \- Windows系统中的MySQL GUI前端  

  * [MySQL Workbench](http://dev.mysql.com/downloads/workbench/?spm=5176.100239.blogcont52879.38.tlOh6M) \- 为数据库管理员和开发者对数据库设计和建模提供了集成工具环境  

  * [phpMyAdmin](https://www.phpmyadmin.net/?spm=5176.100239.blogcont52879.39.tlOh6M) \- 一个由PHP语言编写的免费软件工具，目的是在Web上提供对MySQL的管理功能  

  * [SequelPro](https://github.com/sequelpro/sequelpro?spm=5176.100239.blogcont52879.40.tlOh6M) - Mac版本的MySQL 的数据库管理应用程序  

  * [mycli](https://github.com/dbcli/mycli?spm=5176.100239.blogcont52879.41.tlOh6M) \- 一个带自动补全和语法高亮的终端版 MySQL 客户端  

##
[](https://yq.aliyun.com/articles/preview/?spm=5176.100239.blogcont52879.42.tlOh6M#ha)HA

高可用性解决方案

  * [Galera Cluster](http://galeracluster.com/products/?spm=5176.100239.blogcont52879.43.tlOh6M) \- 一个基于同步复制的真正的多主机集群方案  

  * [MHA](http://code.google.com/p/mysql-master-ha/?spm=5176.100239.blogcont52879.44.tlOh6M) \-  针对 MySQL 的优秀的高可用管理器及工具  

  * [MySQL Fabric](https://www.mysql.com/products/enterprise/fabric.html?spm=5176.100239.blogcont52879.45.tlOh6M) \- 一个用于管理MySQL服务器集群的可扩展框架  

  * [Percona Replication Manager](https://github.com/percona/percona-pacemaker-agents/?spm=5176.100239.blogcont52879.46.tlOh6M) \- MySQL 的异步复制管理代理。支持以文件和 GTID 为基础的复制，同时使用Booth 实现的地理位置分布式集群  

## 代理

MySQL中的代理

  * [MaxScale](https://github.com/mariadb-corporation/MaxScale?spm=5176.100239.blogcont52879.47.tlOh6M) \- 开源的、以数据库为中心的代理  

  * [Mixer](https://github.com/siddontang/mixer?spm=5176.100239.blogcont52879.48.tlOh6M) \- 由GO语言编写的MySQL代理，其目的是为MySQL分片提供一个简单的解决方案  

  * [MySQL Proxy](https://launchpad.net/mysql-proxy?spm=5176.100239.blogcont52879.49.tlOh6M) \- 一个处于你的客户端和MySQL服务器之间的简单应用程序，可以用于监控、分析或者转变二者的通信方式  

  * [ProxySQL](https://github.com/renecannao/proxysql?spm=5176.100239.blogcont52879.50.tlOh6M) \- MySQL中的高性能代理  

  * [MySQL Router](https://dev.mysql.com/doc/mysql-router/en/?spm=5176.100239.blogcont52879.51.tlOh6M) -MySQL Router是一个轻量级的中间件，为应用程序和后端MySQL服务器提供透明的路由路径  

## 复制

与复制相关的软件

  * [orchestrator](https://github.com/outbrain/orchestrator?spm=5176.100239.blogcont52879.52.tlOh6M) \- MySQL复制拓扑管理和可视化工具  

  * [Tungsten Replicator](http://code.google.com/p/tungsten-replicator/?spm=5176.100239.blogcont52879.53.tlOh6M) \- MySQL的一个高性能、开源的数据复制引擎  

## 模式

附加模式

  * [common_schema](http://code.google.com/p/common-schema/?spm=5176.100239.blogcont52879.54.tlOh6M) \- MySQL的数据库管理员框架，提供了一个具有函数库、视图库和查询脚本的解释器  

  * [sys](https://github.com/mysql/mysql-sys?spm=5176.100239.blogcont52879.55.tlOh6M) \- 一个视图、函数和过程的集合，用来帮助 MySQL 管理人员更加深入理解 MySQL 数据库如何使用的  

## 服务器

MySQL服务器

  * [MariaDB](https://github.com/MariaDB/server?spm=5176.100239.blogcont52879.56.tlOh6M) \- MariaDB是一个由社区开发的MySQL服务器的分支  

  * [MySQL Server & MySQL Cluster](https://github.com/mysql/mysql-server?spm=5176.100239.blogcont52879.57.tlOh6M) \- Oracle官方的 MySQL 服务器和MySQL 集群分布  

  * [Percona Server](https://launchpad.net/percona-server?spm=5176.100239.blogcont52879.58.tlOh6M) \- 一个加强版、可替代MySQL的新生服务器  

  * [WebScaleSQL](https://github.com/webscalesql/webscalesql-5.6?spm=5176.100239.blogcont52879.59.tlOh6M&file=webscalesql-5.6) \- WebScaleSQL 的5.6版本，其基于 MySQL 5.6 社区版本  

## 分片

分片解决方案和框架

  * [vitess](https://github.com/youtube/vitess?spm=5176.100239.blogcont52879.60.tlOh6M) \- 针对大规模的 web 服务，vitess 同时提供了服务和工具以便于 MySQL 数据库的缩放  

  * [jetpants](https://github.com/tumblr/jetpants?spm=5176.100239.blogcont52879.61.tlOh6M) \- jetpants是由一个Tumblr 开发的自动化套件，用于管理大规模分片集群  

## 工具包

工具包、通用脚本

  * [go-mysql](https://github.com/siddontang/go-mysql?spm=5176.100239.blogcont52879.62.tlOh6M) \- 一个纯 Go语言的库，用于处理 MySQL 中的网络协议和复制  

  * [MySQL Utilities](https://dev.mysql.com/downloads/utilities/?spm=5176.100239.blogcont52879.63.tlOh6M) \- 一系列由Python编写的命令行工具，用于维护和管理单一或多层的MySQL服务器  

  * [Percona Toolkit](https://www.percona.com/software/mysql-tools/percona-toolkit?spm=5176.100239.blogcont52879.64.tlOh6M) - 一个先进的命令行工具集，用于处理 MySQL 服务器和系统中一些任务，这些任务如果采用手动处理的话过于困难或复杂  

  * [openark kit](http://code.openark.org/forge/openark-kit?spm=5176.100239.blogcont52879.65.tlOh6M) \- 一组实用的工具，用于日常的维护工作，包括一些复杂的或需徒手操作的操作，该工具用 Python 语言编写  

  * [UnDROP](https://twindb.com/undrop-tool-for-innodb/?spm=5176.100239.blogcont52879.66.tlOh6M) \- 该工具用于恢复 InnoDB 表中删除或损坏的数据

# 资源

本节所述的资源不包括网站、博客、幻灯片、演示视频等

## 会议

围绕MySQL及其相关议题周期性的、公开的会议

  * [FOSDEM](https://fosdem.org/?spm=5176.100239.blogcont52879.67.tlOh6M) \- 一个免费的见面会活动，旨在帮助软件开发人员互相熟悉、交流思想与相互协作。每年在Brussels 举办，为MySQL和它的伙伴提供了场地  

  * [MySQL Central](https://www.oracle.com/openworld/mysql/index.html?spm=5176.100239.blogcont52879.68.tlOh6M) \- Oracle年度MySQL大会，同时是 Oracle Open World的一部分  

  * [Percona Live](https://www.percona.com/live/conferences?spm=5176.100239.blogcont52879.69.tlOh6M) \- MySQL 和 OpenStack 的重要会议  

  * [SCALE](https://www.socallinuxexpo.org/?spm=5176.100239.blogcont52879.70.tlOh6M) \- 一个每年在California南部召开，由 社区举办的Linux 和 开源软件大会。当地MySQL社区会以MySQL Community Day之名举办一次游行活动   

## 电子书

MySQL相关的电子书及其他资料

  * [SQL-exercise](https://github.com/XD-DENG/SQL-exercise?spm=5176.100239.blogcont52879.71.tlOh6M) \- 包含多个SQL练习实例，包括架构描述、采用SQL语法去建立模式、SQL中的常见问题和解决方案。这些实例以 [wikibook SQL](https://en.wikibooks.org/wiki/SQL_Exercises?spm=5176.100239.blogcont52879.72.tlOh6M) 练习为基础  

## 媒体

本节主要涵盖公开、持续的视频和音频转播，不包括多如牛毛的会议演讲

  * [DBHangOps](http://dbhangops.github.io/?spm=5176.100239.blogcont52879.73.tlOh6M) \- 由来自MySQL社区成员参加的Goole聚集大会，大会两周举办一次，大会的日常就是探讨一切与 MySQL 的相关事物  

  * [OurSQL Podcast](http://www.oursql.com/?spm=5176.100239.blogcont52879.74.tlOh6M) \- MySQL 数据库社区播客  

## 新闻周刊

顾名思义，订阅新闻周刊需要一个 email 地址。下表所列的资源也仅需一个Email 地址就可以搞定

  * [Weekly MySQL News](http://mysqlnewsletter.com/?spm=5176.100239.blogcont52879.75.tlOh6M) \- 包括任何关于 MySQL 的消息的非官方新闻周刊  

  
以上为“MySQL资料大全”所有内容，更多精彩敬请期待。

* * *

编译自： _[https://github.com/shlomi-noach/awesome-mysql/blob/gh-
pages/index.md](https://github.com/shlomi-noach/awesome-mysql/blob/gh-
pages/index.md?spm=5176.100239.blogcont52879.76.tlOh6M&file=index.md)_

译者：刘崇鑫 校对：王殿进 毛鹤

  

如果发现原文翻译有误，请邮件通知云栖社区（yqeditor@list.alibaba-inc.com），感谢您的支持。

  

【相关资料】阿里云RDS
MySQL经过多年的积累，不断的进行性能优化，并定制了适合不同行业需求的功能，同时也向官方和社区贡献力量。云栖社区也组织了两场关于MySQL的两场在线培训，相关资料如下：

[《
阿里云赵建伟：深度定制的高性能阿里云MySQL》](https://yq.aliyun.com/edu/lesson/69?spm=5176.100239.blogcont52879.77.tlOh6M)

  * [《淘宝丁奇：如何解决影响MySQL使用的9大问题》](https://yq.aliyun.com/edu/lesson/play/91?spm=5176.100239.blogcont52879.78.tlOh6M)

版权声明：本文内容由互联网用户自发贡献，本社区不拥有所有权，也不承担相关法律责任。如果您发现本社区中有涉嫌抄袭的内容，欢迎发送邮件至：[yqgroup@service.aliyun.com](https://yq.aliyun.com/articles/52879?utm_campaign=wenzhang&utm_medium=article&utm_source=QQ-
qun&utm_content=m_10255mailto:yqgroup@service.aliyun.com)
进行举报，并提供相关证据，一经查实，本社区将立刻删除涉嫌侵权内容。

用云栖社区APP，舒服~

【云栖快讯】浅析混合云和跨地域网络构建实践，分享高性能负载均衡设计，9月21日阿里云专家和你说说网络那些事儿，足不出户看直播，赶紧预约吧！
[详情请点击](https://yq.aliyun.com/promotion/340?spm=5176.100239.blogcont52879.80.tlOh6M)

[评论文章 ( _1_
)](https://yq.aliyun.com/articles/52879?utm_campaign=wenzhang&utm_medium=article&utm_source=QQ-
qun&utm_content=m_10255#comment) (7) (18)

分享到:

     [](http://service.weibo.com/share/share.php?spm=5176.100239.blogcont52879.82.tlOh6M&title=MySQL%E8%B5%84%E6%96%99%E5%A4%A7%E5%85%A8+%E4%B8%BA%E4%BA%86%E8%AE%A9%E5%BC%80%E5%8F%91%E8%80%85%E6%9B%B4%E5%A5%BD%E7%9A%84%E4%BA%86%E8%A7%A3%E4%BD%BF%E7%94%A8MySQL%EF%BC%8C%E5%85%85%E5%88%86%E5%8F%91%E6%8C%A5%E5%85%B6%E7%81%B5%E6%B4%BB%E6%80%A7%E7%9A%84%E4%BC%98%E5%8A%BF%E3%80%82%E4%BA%91%E6%A0%96%E7%A4%BE%E5%8C%BA%E7%BB%84%E7%BB%87%E7%BF%BB%E8%AF%91%E4%BA%86GitHub+Awesome+MySQL+%E8%B5%84%E6%BA%90%EF%BC%8C%E5%85%B6%E4%B8%AD%E4%B8%8D%E4%BB%85%E6%B6%B5%E7%9B%96MySQL%E9%83%A8%E7%BD%B2%E3%80%81%E5%BC%80%E5%8F%91%E3%80%81%E6%80%A7%E8%83%BD%E6%B5%8B%E8%AF%95%E7%AD%89%E6%93%8D%E4%BD%9C%E4%B8%AD%E4%BD%BF%E7%94%A8%E7%9A%84%E5%B7%A5%E5%85%B7%E5%8C%85%E5%92%8C%E5%BA%93%EF%BC%8C%E8%BF%98%E5%8C%85%E6%8B%ACMySQL%E7%9B%B8%E5%85%B3%E7%9A%84%E4%BC%9A%E8%AE%AE%E3%80%81%E5%A4%9A%E5%AA%92%E4%BD%93%E7%AD%89%E8%B5%84%E6%BA%90%E3%80%82&url=https%3A%2F%2Fyq.aliyun.com%2Farticles%2F52879)

__

  * [上一篇：Hadoop学习资源集合](https://yq.aliyun.com/articles/47860?spm=5176.100239.blogcont52879.83.tlOh6M)
  * [下一篇：Google、Unity等公司专家深度解读VR平台Daydream](https://yq.aliyun.com/articles/54066?spm=5176.100239.blogcont52879.84.tlOh6M)

### 相关文章

  * [ CentOS6.5下安装MySQL5.7 ](https://yq.aliyun.com/articles/7894?spm=5176.100239.blogcont52879.85.tlOh6M)
  * [ MySql常用命令大全集合 ](https://yq.aliyun.com/articles/2932?spm=5176.100239.blogcont52879.86.tlOh6M)
  * [ MySQL slow query [慢查询] 资料整理 ](https://yq.aliyun.com/articles/52239?spm=5176.100239.blogcont52879.87.tlOh6M)
  * [ 【资料整理】MySQL -- SHOW TABLE ST… ](https://yq.aliyun.com/articles/41875?spm=5176.100239.blogcont52879.88.tlOh6M)
  * [ 【资料整理】MySQL 错误号含义 ](https://yq.aliyun.com/articles/41897?spm=5176.100239.blogcont52879.89.tlOh6M)
  * [ like 和 contains 和match() aga… ](https://yq.aliyun.com/articles/42441?spm=5176.100239.blogcont52879.90.tlOh6M)
  * [ Web程序连接MySql提示表找不到问题的分析（大小写配… ](https://yq.aliyun.com/articles/68576?spm=5176.100239.blogcont52879.91.tlOh6M)
  * [ Linux mysql 5.6： ERROR 1045 … ](https://yq.aliyun.com/articles/34370?spm=5176.100239.blogcont52879.92.tlOh6M)
  * [ Mysql 查看端口号的几种方式 ](https://yq.aliyun.com/articles/52243?spm=5176.100239.blogcont52879.93.tlOh6M)
  * [ 修改mysql的root用户密码为空 ](https://yq.aliyun.com/articles/42973?spm=5176.100239.blogcont52879.94.tlOh6M)

### 网友评论

[
](https://yq.aliyun.com/users/1808118435184064?spm=5176.100239.blogcont52879.95.tlOh6M)
1F

[shaonbean](https://yq.aliyun.com/users/1808118435184064?spm=5176.100239.blogcont52879.96.tlOh6M)
2016-12-19 20:04:32

这个好

(来自[社区APP](https://promotion.aliyun.com/ntms/mobile.html?spm=5176.100239.blogcont52879.98.tlOh6M))

[  0
](https://yq.aliyun.com/articles/52879?utm_campaign=wenzhang&utm_medium=article&utm_source=QQ-
qun&utm_content=m_10255#modal-login "赞") [  0
](https://yq.aliyun.com/articles/52879?utm_campaign=wenzhang&utm_medium=article&utm_source=QQ-
qun&utm_content=m_10255#modal-login "评论")

登录后可评论，请
[登录](https://account.aliyun.com/login/login.htm?spm=5176.100239.blogcont52879.102.tlOh6M&from_type=yqclub&oauth_callback=https%3A%2F%2Fyq.aliyun.com%2Farticles%2F52879%3Futm_campaign%3Dwenzhang%26utm_medium%3Darticle%26utm_source%3DQQ-
qun%26utm_content%3Dm_10255%26do%3Dlogin) 或
[注册](https://account.aliyun.com/register/register.htm?spm=5176.100239.blogcont52879.103.tlOh6M&from_type=yqclub&oauth_callback=https%3A%2F%2Fyq.aliyun.com%2Farticles%2F52879%3Futm_campaign%3Dwenzhang%26utm_medium%3Darticle%26utm_source%3DQQ-
qun%26utm_content%3Dm_10255%26do%3Dlogin)

[评论](https://yq.aliyun.com/articles/52879?utm_campaign=wenzhang&utm_medium=article&utm_source=QQ-
qun&utm_content=m_10255#modal-login)

  


---
### ATTACHMENTS
[08b72edbb4f6d07ef5aeb1949831976e]: media/img_b78e8a6af3f99aba2eeb29377f173fc3.JPG64h_64w_2e.jpg
[img_b78e8a6af3f99aba2eeb29377f173fc3.JPG64h_64w_2e.jpg](media/img_b78e8a6af3f99aba2eeb29377f173fc3.JPG64h_64w_2e.jpg)
>hash: 08b72edbb4f6d07ef5aeb1949831976e  
>source-url: https://yqfile.alicdn.com/img_b78e8a6af3f99aba2eeb29377f173fc3.JPG@64h_64w_2e  
>file-name: img_b78e8a6af3f99aba2eeb29377f173fc3.JPG@64h_64w_2e.jpg  

[e77cd6c7dd7335ca7d21a57bb14a19db]: media/e77cd6c7dd7335ca7d21a57bb14a19db-3.png
[e77cd6c7dd7335ca7d21a57bb14a19db-3.png](media/e77cd6c7dd7335ca7d21a57bb14a19db-3.png)
>hash: e77cd6c7dd7335ca7d21a57bb14a19db  
>source-url: https://yqfile.alicdn.com/e77cd6c7dd7335ca7d21a57bb14a19db.png  
>file-name: e77cd6c7dd7335ca7d21a57bb14a19db.png  

---
### NOTE ATTRIBUTES
>Created Date: 2017-09-18 02:47:51  
>Last Evernote Update Date: 2018-10-01 15:35:39  
>author: YangKwong  
>source: web.clip  
>source-url: https://yq.aliyun.com/articles/52879  