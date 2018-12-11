# 硬件、OS及云计算技术讲解
[TOC]










## 一、软件架构及IT设计思想

### 1. 软件架构

### 2. IT思想

- 万物皆文件

  linux proc文件系统

- 处处皆缓存

  **硬件缓存**：CPU一级、二级缓存，内存、SWAP、硬盘缓存、存储缓存

  **软件缓存**：MongoDB、Redis、Memcached

  **buffer与cache**：

  buffer负责写、cache负责读

  buffer : 作为buffer cache的内存，是块设备的读写缓冲区

  cache: 作为page cache的内存，文件系统的cache

- 需求、目的

  [大型网站架构演化历程]: https://www.hollischuang.com/archives/728

- 分层、劳动分工、线性扩展

  闻道有先后、术业有专攻，让合适的人干合适的自己事

  **分层**：应用层、服务层、数据层

  ![计算机集群](C:\Users\galaxy\Desktop\OS\剪贴板图片 (3).jpg)

- 最小化原则

- 其他

  - 在数据产生的地方进行数据处理

  - 网络与硬盘使用相同的协议：网络与硬盘一样快

- 对比学习：
  - Oracle-MySQL（RC--SS）；RDB--NoSQL
  - Oracle--MySQL--MongoDB（堆表--有序表--cson、json）
  - Linux--Windows

少看中国人写的技术书，少用百度、搜狗、360，别安装360、腾讯管家。

拥抱新技术：关宁铁骑

CAP、BASE

贪多嚼不烂  -- 广博未必精通，精通必定广博

**参考文档**：

- 大型网站技术架构：核心原理与案例分析
- 人月神话（40周年中文纪念版）

## 二、硬件、OS

### 整体架构图

![1544065753942](C:\Users\galaxy\AppData\Roaming\Typora\typora-user-images\1544065753942.png)

### 1. 硬件

#### 1.1 服务器

##### 服务器分类

x86、小机、大型机、云主机-->服务器、云主机

zabbix、bmc patrol

SaltStack、ansible、puppet--堡垒机

NBU、commvault

#### 1.2 光纤交换机

##### 配置流程

设备上架(插入光模块)-->使用管理口连接光纤交换-->激活端口-->创建zone-->映射划分

#####  光纤交换机讲解

![1544065703347](C:\Users\galaxy\AppData\Roaming\Typora\typora-user-images\1544065703347.png)

![1544065734718](C:\Users\galaxy\AppData\Roaming\Typora\typora-user-images\1544065734718.png)

##### 光纤交换机级联

光纤网关、光闸

**堆叠**

通过XPAK端口将多台光纤交换机相连，称为光纤交换机的“堆叠”。

采用堆叠方式进行连接时，您需要额外购买堆叠线缆，且堆叠长度有限，堆叠线缆最长为2m；但相对于级联，堆叠具有更高的带宽，且不占用光纤交换机的FC端口。

2台光纤交换机进行堆叠的建议组网如

图11-1

所示，最多可激活和使用40个FC端口。

图11-1  2台光纤交换机堆叠 
![img](http://download.huawei.com/mdl/imgDownload?uuid=b4065b570c6940fa82085da22c384e61.png)

3台光纤交换机进行堆叠的建议组网如

图11-2

，最多可激活和使用60个FC端口。

图11-2  3台光纤交换机堆叠 
![img](http://download.huawei.com/mdl/imgDownload?uuid=6f7af80241c943bc8db6fa041e7ce2df.png)

**级联**

通过任意激活的FC端口将多台光纤交换机相连，称为光纤交换机的“级联”。

采用级联方式进行连接时，光纤交换机部分FC端口将被占用；但相对于堆叠，级联采用的光纤具有更长走线距离。

2台光纤交换机进行级联的建议组网如

图11-3

所示，最多可激活和使用32个FC端口。

图11-3  2台光纤交换机级联 
![img](http://download.huawei.com/mdl/imgDownload?uuid=7a254af29ca9421c87b53cb3a534ec24.png)

3台光纤交换机进行级联的建议组网如

图11-4

，最多可激活和使用48个FC端口。

图11-4  3台光纤交换机级联 
![img](http://download.huawei.com/mdl/imgDownload?uuid=742b8d51f998402d9c8dcbf97b0e525e.png)

#### 1.3 存储

##### 硬盘

SATA --> SAS -->SSD

##### 存储讲解

![存储前视图](C:\Users\galaxy\Desktop\OS\2017-07-27_165628.png)
![存储后视图](C:\Users\galaxy\Desktop\OS\2017-07-27_170313.png)
![储控制器](C:\Users\galaxy\Desktop\OS\2017-07-27_170313.png)

![连接存储](C:\Users\galaxy\Desktop\OS\2017-07-27_170118.png)

![1544065631928](C:\Users\galaxy\AppData\Roaming\Typora\typora-user-images\1544065631928.png)

![1544065473633](C:\Users\galaxy\AppData\Roaming\Typora\typora-user-images\1544065473633.png)

![1544065506358](C:\Users\galaxy\AppData\Roaming\Typora\typora-user-images\1544065506358.png)

![1544065525401](C:\Users\galaxy\AppData\Roaming\Typora\typora-user-images\1544065525401.png)

![1544065579958](C:\Users\galaxy\AppData\Roaming\Typora\typora-user-images\1544065579958.png)

![1544065561364](C:\Users\galaxy\AppData\Roaming\Typora\typora-user-images\1544065561364.png)

![1544065600799](C:\Users\galaxy\AppData\Roaming\Typora\typora-user-images\1544065600799.png)

![存储监控视图](C:\Users\galaxy\Desktop\OS\2017-07-27_170425.png)

##### 虚拟存储

![1544080198278](C:\Users\galaxy\AppData\Roaming\Typora\typora-user-images\1544080198278.png)

#### 1.4 网络交换机

二层交换机：没有路由功能

三层交换机：路由功能、地址转发

### 2.OS

#### 2.1 OS分类

| Linux  |        |        |                 |
| ------ | ------ | ------ | --------------- |
| Redhat | CentOS | Fedora | *Oracle  Linux* |
| Debian | SuSE   | Ubuntu |                 |

| Unix  |               |
| ----- | ------------- |
| Aix   | *Power Linux* |
| HP-UX |               |

#### 2.2 OS知识点

linux目录结构

![img](http://img1.51cto.com/attachment/201309/230817424.jpg)

| 目录                                                         | 描述                                                         |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| /                                                            | 第一层次结构的根、整个文件系统层次结构的[根目录](http://zh.wikipedia.org/wiki/%E6%A0%B9%E7%9B%AE%E5%BD%95)。 |
| /bin/                                                        | 需要在[单用户模式](http://zh.wikipedia.org/w/index.php?title=%E5%8D%95%E7%94%A8%E6%88%B7%E6%A8%A1%E5%BC%8F&action=edit&redlink=1)可用的必要命令（[可执行文件](http://zh.wikipedia.org/wiki/%E5%8F%AF%E6%89%A7%E8%A1%8C%E6%96%87%E4%BB%B6)）；面向所有用户，例如：[cat](http://zh.wikipedia.org/wiki/Cat_(Unix))、[ls](http://zh.wikipedia.org/wiki/Ls)、[cp](http://zh.wikipedia.org/wiki/Cp_(Unix))，和/usr/bin类似。 |
| [/boot/](http://zh.wikipedia.org/w/index.php?title=/boot/&action=edit&redlink=1) | [引导程序](http://zh.wikipedia.org/wiki/%E5%BC%95%E5%AF%BC%E7%A8%8B%E5%BA%8F)文件，例如：[kernel](http://zh.wikipedia.org/wiki/%E5%86%85%E6%A0%B8)、[initrd](http://zh.wikipedia.org/wiki/Initrd)；时常是一个单独的分区[[6\]](http://zh.wikipedia.org/wiki/%E6%96%87%E4%BB%B6%E7%B3%BB%E7%BB%9F%E5%B1%82%E6%AC%A1%E7%BB%93%E6%9E%84%E6%A0%87%E5%87%86#cite_note-6) |
| **/dev/**                                                    | 必要[设备](http://zh.wikipedia.org/wiki/%E8%AE%BE%E5%A4%87%E6%96%87%E4%BB%B6%E7%B3%BB%E7%BB%9F), 例如：, [/dev/null](http://zh.wikipedia.org/wiki/dev/null). |
| **/etc/**                                                    | 特定主机，系统范围内的[配置文件](http://zh.wikipedia.org/w/index.php?title=%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6&action=edit&redlink=1)。关于这个名称目前有争议。在贝尔实验室关于UNIX实现文档的早期版本中，/etc 被称为[/etcetra 目录](http://zh.wikipedia.org/w/index.php?title=Et_cetera&action=edit&redlink=1)，[[7\]](http://zh.wikipedia.org/wiki/%E6%96%87%E4%BB%B6%E7%B3%BB%E7%BB%9F%E5%B1%82%E6%AC%A1%E7%BB%93%E6%9E%84%E6%A0%87%E5%87%86#cite_note-7)这是由于过去此目录中存放所有不属于别处的所有东西（然而，FHS限制/etc存放静态配置文件，不能包含二进制文件）。[[8\]](http://zh.wikipedia.org/wiki/%E6%96%87%E4%BB%B6%E7%B3%BB%E7%BB%9F%E5%B1%82%E6%AC%A1%E7%BB%93%E6%9E%84%E6%A0%87%E5%87%86#cite_note-8)自从早期文档出版以来，目录名称已被以各种方式重新称呼。最近的解释包括[反向缩略语](http://zh.wikipedia.org/w/index.php?title=%E5%8F%8D%E5%90%91%E7%BC%A9%E7%95%A5%E8%AF%AD&action=edit&redlink=1)如："可编辑的文本配置"（英文 "Editable Text Configuration"）或"扩展工具箱"（英文 "Extended Tool Chest")。[[9\]](http://zh.wikipedia.org/wiki/%E6%96%87%E4%BB%B6%E7%B3%BB%E7%BB%9F%E5%B1%82%E6%AC%A1%E7%BB%93%E6%9E%84%E6%A0%87%E5%87%86#cite_note-9) |
| /etc/opt/                                                    | /opt/的配置文件                                              |
| /etc/X11/                                                    | [X_Window系统](http://zh.wikipedia.org/wiki/X_Window%E7%B3%BB%E7%BB%9F)(版本11)的配置文件 |
| /etc/sgml/                                                   | [SGML](http://zh.wikipedia.org/wiki/SGML)的配置文件          |
| /etc/xml/                                                    | [XML](http://zh.wikipedia.org/wiki/XML)的配置文件            |
| **/home/**                                                   | 用户的[家目录](http://zh.wikipedia.org/wiki/%E5%AE%B6%E7%9B%AE%E5%BD%95)，包含保存的文件、个人设置等，一般为单独的分区。 |
| /lib/                                                        | /bin/ and /sbin/中二进制文件必要的[库](http://zh.wikipedia.org/wiki/%E5%BA%93)文件。 |
| /media/                                                      | 可移除媒体(如[CD-ROM](http://zh.wikipedia.org/wiki/CD-ROM))的挂载点 (在FHS-2.3中出现)。 |
| /lost+found                                                  | 在ext3文件系统中，当系统意外崩溃或机器意外关机，会产生一些文件碎片在这里。当系统在开机启动的过程中fsck工具会检查这里，并修复已经损坏的文件系统。当系统发生问题。可能会有文件被移动到这个目录中，可能需要用手工的方式来修复，或移到文件到原来的位置上。 |
| /mnt/                                                        | 临时[挂载](http://zh.wikipedia.org/w/index.php?title=%E6%8C%82%E8%BD%BD&action=edit&redlink=1)的文件系统。比如cdrom,u盘等，直接插入光驱无法使用，要先挂载后使用 |
| /opt/                                                        | 可选[应用软件](http://zh.wikipedia.org/wiki/%E5%BA%94%E7%94%A8%E8%BD%AF%E4%BB%B6)[包](http://zh.wikipedia.org/wiki/%E8%BD%AF%E4%BB%B6%E5%8C%85)。 |
| **/proc/**                                                   | 虚拟[文件系统](http://zh.wikipedia.org/wiki/%E6%96%87%E4%BB%B6%E7%B3%BB%E7%BB%9F)，将[内核](http://zh.wikipedia.org/wiki/%E5%86%85%E6%A0%B8)与[进程](http://zh.wikipedia.org/wiki/%E8%BF%9B%E7%A8%8B)状态归档为文本文件（系统信息都存放这目录下）。例如：uptime、 network。在Linux中，对应[Procfs](http://zh.wikipedia.org/wiki/Procfs)格式挂载。该目录下文件只能看不能改（包括root） |
| /root/                                                       | [超级用户](http://zh.wikipedia.org/wiki/%E8%B6%85%E7%BA%A7%E7%94%A8%E6%88%B7)的[家目录](http://zh.wikipedia.org/wiki/%E5%AE%B6%E7%9B%AE%E5%BD%95) |
| **/sbin/**                                                   | 必要的系统二进制文件，例如： init、 ip、 mount。sbin目录下的命令，普通用户都执行不了。 |
| /srv/                                                        | 站点的具体[数据](http://zh.wikipedia.org/wiki/%E6%95%B0%E6%8D%AE)，由系统提供。 |
| /tmp/                                                        | 临时文件(参见 /var/tmp)，在系统重启时目录中文件不会被保留。  |
| /usr/                                                        | 默认软件都会存于该目录下。用于存储只读用户数据的第二层次；包含绝大多数的([多](http://zh.wikipedia.org/wiki/%E5%A4%9A%E7%94%A8%E6%88%B7))用户工具和应用程序。 |
| **/var/**                                                    | 变量文件——在正常运行的系统中其内容不断变化的文件，如日志，脱机文件和临时电子邮件文件。有时是一个单独的分区。如果不单独分区，有可能会把整个分区充满。如果单独分区，给大给小都不合适。 |

**3****、****/etc/****目录**

特定主机系统范围内的[配置文件](http://zh.wikipedia.org/w/index.php?title=%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6&action=edit&redlink=1)。

| 目录                                                 | 描述                                                         |
| ---------------------------------------------------- | ------------------------------------------------------------ |
| **/etc/rc /etc/rc.d****/etc/rc\*.d**                 | 启动、或改变运行级时运行的scripts或scripts的目录.            |
| /etc/hosts                                           | 本地域名解析文件                                             |
| **/etc/sysconfig/network**                           | IP、掩码、网关、主机名配置                                   |
| **/etc/resolv.conf**                                 | DNS服务器配置                                                |
| **/etc/fstab**                                       | 开机自动挂载系统，所有分区开机都会自动挂载                   |
| **/etc/inittab**                                     | 设定系统启动时Init进程将把系统设置成什么样的runlevel及加载相关的启动文件配置 |
| **/etc/exports**                                     | 设置NFS系统用的配置文件路径                                  |
| **/etc/init.d**                                      | 这个目录来存放系统启动脚本                                   |
| **/etc/profile****,**/etc/csh.login,  /etc/csh.cshrc | **全局系统环境配置变量**                                     |
| **/etc/issue**                                       | 认证前的输出信息，默认输出版本内核信息                       |
| /etc/motd                                            | 设置认证后的输出信息，                                       |
| /etc/mtab                                            | 当前安装的文件系统列表.由scripts初始化，并由mount 命令自动更新.需要一个当前安装的文件系统的列表时使用，例如df 命令 |
| **/etc/group**                                       | 类似/etc/passwd ，但说明的不是用户而是组.                    |
| **/etc/passwd**                                      | 用户数据库，其中的域给出了用户名、真实姓名、家目录、加密的口令和用户的其他信息. |
| **/etc/shadow**                                      | 在安装了影子口令软件的系统上的影子口令文件.影子口令文件将/etc/passwd 文件中的加密口令移动到/etc/shadow 中，而后者只对root可读.这使破译口令更困难. |
| **/etc/sudoers**                                     | 可以sudo命令的配置文件                                       |
| **/etc/syslog.conf**                                 | 系统日志参数配置                                             |
| /etc/login.defs                                      | 设置用户帐号限制的文件                                       |
| /etc/securetty                                       | 确认安全终端，即哪个终端允许root登录.一般只列出虚拟控制台，这样就不可能(至少很困难)通过modem或网络闯入系统并得到超级用户特权. |
| /etc/printcap                                        | 类似/etc/termcap ，但针对打印机.语法不同.                    |
| /etc/shells                                          | 列出可信任的shell.chsh 命令允许用户在本文件指定范围内改变登录shell.提供一台机器FTP服务的服务进程ftpd 检查用户shell是否列在 /etc/shells 文件中，如果不是将不允许该用户登录. |
| /etc/xinetd.d                                        | 如果服务器是通过xinetd模式运行的，它的脚本要放在这个目录下。有些系统没有这个目录，比如Slackware，有些老的版本也没有。在Redhat Fedora中比较新的版本中存在。 |
| /etc/opt/                                            | /opt/的配置文件                                              |
| /etc/X11/                                            | [X_Window系统](http://zh.wikipedia.org/wiki/X_Window%E7%B3%BB%E7%BB%9F)(版本11)的配置文件 |
| /etc/sgml/                                           | [SGML](http://zh.wikipedia.org/wiki/SGML)的配置文件          |
| /etc/xml/                                            | [XML](http://zh.wikipedia.org/wiki/XML)的配置文件            |
| **/etc/skel/**                                       | 默认创建用户时，把该目录拷贝到家目录下                       |

**4****、****/usr/****目录**

默认软件都会存于该目录下。用于存储只读用户数据的第二层次；包含绝大多数的用户工具和应用程序。

| 目录         | 描述                                                         |
| ------------ | ------------------------------------------------------------ |
| /usr/X11R6   | 存放X-Windows的目录；                                        |
| /usr/games   | 存放着XteamLinux自带的小游戏；                               |
| /usr/doc     | Linux技术文档；                                              |
| /usr/include | 用来存放Linux下开发和编译应用程序所需要的头文件；            |
| /usr/lib     | 存放一些常用的动态链接共享库和静态档案库；                   |
| /usr/man     | 帮助文档所在的目录；                                         |
| /usr/src     | Linux开放的源代码，就存在这个目录，爱好者们别放过哦；        |
| /usr/bin/    | 非必要[可执行文件](http://zh.wikipedia.org/wiki/%E5%8F%AF%E6%89%A7%E8%A1%8C%E6%96%87%E4%BB%B6) (在[单用户模式](http://zh.wikipedia.org/w/index.php?title=%E5%8D%95%E7%94%A8%E6%88%B7%E6%A8%A1%E5%BC%8F&action=edit&redlink=1)中不需要)；面向所有用户。 |
| /usr/lib/    | /usr/bin/和/usr/sbin/中二进制文件的[库](http://zh.wikipedia.org/wiki/%E5%BA%93)。 |
| /usr/sbin/   | 非必要的系统二进制文件，例如：大量[网络服务](http://zh.wikipedia.org/wiki/%E7%BD%91%E7%BB%9C%E6%9C%8D%E5%8A%A1)的[守护进程](http://zh.wikipedia.org/wiki/%E5%AE%88%E6%8A%A4%E8%BF%9B%E7%A8%8B)。 |
| /usr/share/  | 体系结构无关（共享）数据。                                   |
| /usr/src/    | [源代码](http://zh.wikipedia.org/wiki/%E6%BA%90%E4%BB%A3%E7%A0%81),例如:内核源代码及其头文件。 |
| /usr/X11R6/  | [X Window系统](http://zh.wikipedia.org/wiki/X_Window%E7%B3%BB%E7%BB%9F)版本 11, Release 6. |
| /usr/local/  | 本地数据的第三层次，具体到本台主机。通常而言有进一步的子目录，例如：bin/、lib/、share/.这是提供给一般用户的/usr目录，在这里安装一般的应用软件； |

**5****、****/var/****目录**

/var 包括系统一般运行时要改变的数据.每个系统是特定的，即不通过网络与其他计算机共享.

| 目录                     | 描述                                                         |
| ------------------------ | ------------------------------------------------------------ |
| /var/log/message         | 日志信息，按周自动轮询                                       |
| /var/spool/cron/root     | 定时器配置文件目录，默认按用户命名                           |
| /var/log/secure          | 记录登陆系统存取信息的文件，不管认证成功还是认证失败都会记录 |
| /var/log/wtmp            | 记录登陆者信息的文件，last,who,w命令信息来源于此             |
| /var/spool/clientmqueue/ | 当邮件服务未开启时，所有应发给系统管理员的邮件都将堆放在此   |
| /var/spool/mail/         | 邮件目录                                                     |
| /var/tmp                 | 比/tmp 允许的大或需要存在较长时间的临时文件. (虽然系统管理员可能不允许/var/tmp 有很旧的文件.) |
| /var/lib                 | 系统正常运行时要改变的文件.                                  |
| /var/local               | /usr/local 中安装的程序的可变数据(即系统管理员安装的程序).注意，如果必要，即使本地安装的程序也会使用其他/var 目录，例如/var/lock . |
| /var/lock                | 锁定文件.许多程序遵循在/var/lock 中产生一个锁定文件的约定，以支持他们正在使用某个特定的设备或文件.其他程序注意到这个锁定文件，将不试图使用这个设备或文件. |
| /var/log/                | 各种程序的Log文件，特别是login   (/var/log/wtmp log所有到系统的登录和注销) 和syslog (/var/log/messages 里存储所有核心和系统程序信息. /var/log 里的文件经常不确定地增长，应该定期清除. |
| /var/run                 | 保存到下次引导前有效的关于系统的信息文件.例如，/var/run/utmp 包含当前登录的用户的信息. |
| /var/cache/              | 应用程序缓存数据。这些数据是在本地生成的一个耗时的I/O或计算结果。应用程序必须能够再生或恢复数据。缓存的文件可以被删除而不导致数据丢失。 |

**6****、****/proc/****目录**

虚拟[文件系统](http://zh.wikipedia.org/wiki/%E6%96%87%E4%BB%B6%E7%B3%BB%E7%BB%9F)，将[内核](http://zh.wikipedia.org/wiki/%E5%86%85%E6%A0%B8)与[进程](http://zh.wikipedia.org/wiki/%E8%BF%9B%E7%A8%8B)状态归档为文本文件（系统信息都存放这目录下）。

例如：uptime、 network。在Linux中，对应[Procfs](http://zh.wikipedia.org/wiki/Procfs)格式挂载。该目录下文件只能看不能改（包括root）

| 目录              | 描述                                                         |
| ----------------- | ------------------------------------------------------------ |
| **/proc/meminfo** | 查看内存信息                                                 |
| **/proc/loadavg** | 还记得 top 以及 uptime 吧？没错！上头的三个平均数值就是记录在此！ |
| **/proc/uptime**  | 就是用 uptime 的时候，会出现的资讯啦！                       |
| **/proc/cpuinfo** | 关于处理器的信息，如类型、厂家、型号和性能等。               |
| /proc/cmdline     | 加载 kernel 时所下达的相关参数！查阅此文件，可了解系统是如何启动的！ |
| /proc/filesystems | 目前系统已经加载的文件系统罗！                               |
| /proc/interrupts  | 目前系统上面的 IRQ 分配状态。                                |
| /proc/ioports     | 目前系统上面各个装置所配置的 I/O 位址。                      |
| /proc/kcore       | 这个就是内存的大小啦！好大对吧！但是不要读他啦！             |
| /proc/modules     | 目前我们的 Linux 已经加载的模块列表，也可以想成是驱动程序啦！ |
| /proc/mounts      | 系统已经挂载的数据，就是用 mount 这个命令呼叫出来的数据啦！  |
| /proc/swaps       | 到底系统挂加载的内存在哪里？呵呵！使用掉的 partition 就记录在此啦！ |
| /proc/partitions  | 使用 fdisk -l 会出现目前所有的 partition 吧？在这个文件当中也有纪录喔！ |
| /proc/pci         | 在 PCI 汇流排上面，每个装置的详细情况！可用 lspci 来查阅！   |
| /proc/version     | 核心的版本，就是用 uname -a 显示的内容啦！                   |
| /proc/bus/*       | 一些汇流排的装置，还有 U盘的装置也记录在此喔！               |

**7****、****/dev/****目录**

设备文件分为两种：块设备文件(b)和字符设备文件(c)
设备文件一般存放在/dev目录下，

对常见设备文件作如下说明：

| 目录           | 描述                        |
| -------------- | --------------------------- |
| /dev/hd[a-t]   | IDE设备                     |
| /dev/sd[a-z]   | SCSI设备                    |
| /dev/fd[0-7]   | 标准软驱                    |
| /dev/md[0-31]  | 软raid设备                  |
| /dev/loop[0-7] | 本地回环设备                |
| /dev/ram[0-15] | 内存                        |
| /dev/null      | 无限数据接收设备,相当于黑洞 |
| /dev/zero      | 无限零资源                  |
| /dev/tty[0-63] | 虚拟终端                    |
| /dev/ttyS[0-3] | 串口                        |
| /dev/lp[0-3]   | 并口                        |
| /dev/console   | 控制台                      |
| /dev/fb[0-31]  | framebuffer                 |
| /dev/cdrom     | => /dev/hdc                 |
| /dev/modem     | => /dev/ttyS[0-9]           |
| /dev/pilot     | => /dev/ttyS[0-9]           |
| /dev/random    | 随机数设备                  |
| /dev/urandom   | 随机数设备                  |

#### 2.3 命令参数

```
umount -lf  /mnt
mount |column -t
ls -lrt
ps -elf
netstat -lntup
ss -lntup
!export
cd $_
echo $?
iostat -x 1 10
statue
yum provides/yum whatprovide
;; && ||
>/dev/null 2>＆1
fuse -- tasklist /m shell32.dll
ctrl+z --> jobs -->bg %1 --> fg %1
lsof
strace、ltrace
sync
```

#### 2.4 常见知识点

来源协议：

![开源许可证](./pictures/开源协议.png)

##### vim使用技巧

#### 2.5 常用资源、办公效率提升

SecretCRT

Vmware

Notepad++/UE

Typora/Atom

Git/SourceTree

Chrome

Windows

**参考文档**：

- [Linux性能调优指南]: https://legacy.gitbook.com/book/lihz1990/transoflptg/details

- 性能之巅 洞悉系统、企业与云计算

## 三、云计算

### 1. 云计算概念

计算资源像电一样自由随需获取

Oracle12c资源限定

- cgroup
- namespace
- chroot 
- cpu 指令集

### 2. 云计算技术

#### 2.1 docker

docker --> kubenotes(k8s)

#### 2.2 openstack

AWS --> OpenStack/OpenCloud

#### 2.3 VMware vSphere

私有云

### 3.公有云平台

**国际**

AWS、谷歌云、Azure

**国内**

阿里云、华为云、腾讯云、七牛云

**参考文档**

- docker实力经典
- 官方文档
