> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 https://blog.csdn.net/newhappy2008/article/details/6864284 版权声明：本文为博主原创文章，未经博主允许不得转载。 https://blog.csdn.net/newhappy2008/article/details/6864284 <link rel="stylesheet" href="https://csdnimg.cn/release/phoenix/template/css/ck_htmledit_views-d7e2a68c7c.css">

**一、**[](http://hi.baidu.com/maydayuiui/blog/item/:;)**Oracle** **跟踪文件**         Oracle 跟踪文件分为三种类型：

        一种是后台报警日志文件，记录[](http://hi.baidu.com/maydayuiui/blog/item/:;)**数据库**在启动、关闭和运行期间后台进程的活动情况, 如表空间创建、回滚段创建、某些 alter 命令、日志切换、错误消息等。在数据库出现故障时，应首先查看该文件，但文件中的信息与任何错误状态没有必然的联系。后台报警日志文件保存 BACKGROUND_DUMP_DEST 参数指定的目录中，文件格式为 SIDALRT.LOG。

       另一种类型是 DBWR、LGWR、SMON 等后台进程创建的后台跟踪文件。后台跟踪文件根据后台进程运行情况产生，后台跟踪文件也保存在 BACKGROUND_DUMP_DEST 参数指定的目录中，文件格式为 siddbwr.trc、sidsmon.trc 等。

       还有一种类型是由连接到 Oracle 的用户进程 ([](http://hi.baidu.com/maydayuiui/blog/item/:;)**Server** Processes) 生成的用户跟踪文件。这些文件仅在用户会话期间遇到错误时产生。此外，用户可以通过执行 oracle 跟踪事件（见后面）来生成该类文件，用户跟踪文件保存在 USER_DUMP_DEST 参数指定的目录中，文件格式为 oraxxxxx.trc，xxxxx 为创建文件的进程号（或线程号）。

**二、Oracle 跟踪事件**         Oracle 提供了一类命令，可以将 Oracle 各类内部结构中所包含的信息转储 (dump) 到跟踪文件中，以便用户能根据文件内容来解决各种故障。设置跟踪事件有两种方法，一种是在 init.ora 文件中设置事件，这样 open 数据库后，将影响到所有的会话。设置格式如下：
        EVENT="eventnumber trace name eventname [forever,] [level levelnumber] : ......."
通过: 符号，可以连续设置多个事件，也可以通过连续使用 event 来设置多个事件。
另一种方法是在会话过程中使用 alter session set events 命令，只对当前会话有影响。设置格式如下：
        alter session set events '[eventnumber|immediate] trace name eventname [forever] [, level levelnumber] : .......'
   通过: 符号，可以连续设置多个事件，也可以通过连续使用 alter session set events 来设置多个事件。    格式说明：eventnumber 指触发 dump 的事件号，事件号可以是 Oracle 错误号（出现相应错误时跟踪指定的事件）或 oralce 内部事件号，内部事件号在 10000 到 10999 之间，不能与 immediate 关键字同用。
             immediate 关键字表示命令发出后，立即将指定的结构 dump 到跟踪文件中，这个关键字只用在 alter session 语句中，并且不能与 eventnumber、forever 关键字同用。
             trace name 是关键字。
             eventname 指事件名称（见后面），即要进行 dump 的实际结构名。若 eventname 为 context，则指根据内部事件号进行跟踪。
             forever 关键字表示事件在实例或会话的周期内保持有效状态，不能与 immediate 同用。
             level 为事件级别关键字。但在 dump 错误栈 (errorstack) 时不存在级别。
             levelnumber 表示事件级别号，一般从 1 到 10，1 表示只 dump 结构头部信息，10 表示 dump 结构的所有信息。 1、buffers 事件：dump SGA 缓冲区中的 db buffer 结构
   alter session set events 'immediate trace name buffers level 1'; -- 表示 dump 缓冲区的头部。 2、blockdump 事件：dump 数据文件、索引文件、回滚段文件结构
   alter session set events 'immediate trace name blockdump level 66666'; -- 表示 dump 块地址为 6666 的数据块。
   在 Oracle 8 以后该命令已改为：
   alter system dump datafile 11 block 9; -- 表示 dump 数据文件号为 11 中的第 9 个数据块。 3、controlf 事件：dump 控制文件结构
   alter session set events 'immediate trace name controlf level 10'; -- 表示 dump 控制文件的所有内容。 4、locks 事件：dump LCK 进程的锁信息
   alter session set events 'immediate trace name locks level 5'; 5、redohdr 事件：dump redo 日志的头部信息
   alter session set events 'immediate trace name redohdr level 1'; -- 表示 dump redo 日志头部的控制文件项。
   alter session set events 'immediate trace name redohdr level 2'; -- 表示 dump redo 日志的通用文件头。
   alter session set events 'immediate trace name redohdr level 10'; -- 表示 dump redo 日志的完整文件头。    注意：redo 日志的内容 dump 可以采用下面的语句:
   alter system dump logfile 'logfilename'; 6、loghist 事件：dump 控制文件中的日志历史项
   alter session set events 'immediate trace name loghist level 1'; -- 表示只 dump 最早和最迟的日志历史项。
   levelnumber 大于等于 2 时，表示 2 的 levelnumber 次方个日志历史项。
   alter session set events 'immediate trace name loghist level 4'; -- 表示 dump 16 个日志历史项。 7、file_hdrs 事件：dump 所有数据文件的头部信息
   alter session set events 'immediate trace name file_hdrs level 1'; -- 表示 dump 所有数据文件头部的控制文件项。
   alter session set events 'immediate trace name file_hdrs level 2'; -- 表示 dump 所有数据文件的通用文件头。
   alter session set events 'immediate trace name file_hdrs level 10'; -- 表示 dump 所有数据文件的完整文件头。 8、errorstack 事件：dump 错误栈信息，通常 Oracle 发生错误时前台进程将得到一条错误信息，但某些情况下得不到错误信息，可以采用这种方式得到 Oracle 错误。
   alter session set events '604 trace name errorstack forever'; -- 表示当出现 604 错误时，dump 错误栈和进程栈。 9、systemstate 事件：dump 所有系统状态和进程状态
   alter session set events 'immediate trace name systemstate level 10'; -- 表示 dump 所有系统状态和进程状态。 10、coalesec 事件：dump 指定表空间中的自由区间
    levelnumber 以十六进制表示时，两个高位字节表示自由区间数目，两个低位字节表示表空间号，如 0x00050000 表示 dump 系统表空间中的 5 个自由区间，转换成十进制就是 327680，即：
    alter session set events 'immediate trace name coalesec level 327680'; 11、processsate 事件：dump 进程状态
    alter session set events 'immediate trace name processsate level 10'; 12、library_cache 事件：dump library cache 信息
    alter session set events 'immediate trace name library_cache level 10'; 13、heapdump 事件：dump PGA、SGA、UGA 中的信息
    alter session set events 'immediate trace name heapdump level 1'; 14、row_cache 事件：dump 数据字典缓冲区中的信息
    alter session set events 'immediate trace name row_cache level 1';
**三、内部事件号** 1、10013：用于监视事务**恢复** 2、10015：转储 UNDO SEGMENT 头部
        event = "10015 trace name context forever" 3、10029：用于给出会话期间的登陆信息 4、10030：用于给出会话期间的注销信息 5、10032：转储排序的统计信息 6、10033：转储排序增长的统计信息 7、10045：跟踪 Freelist 管理操作 8、10046：跟踪 ****SQL**** 语句
   alter session set events '10046 trace name context forever, level 4'; -- 跟踪 SQL 语句并显示绑定变量
   alter session set events '10046 trace name context forever, level 8'; -- 跟踪 SQL 语句并显示等待事件 9、10053：转储优化策略 10、10059：模拟 redo 日志中的创建和清除错误 11、10061：阻止 SMON 进程在启动时清除临时段 12、10079：转储 SQL*NET 统计信息 13、10081：转储高水标记变化 14、10104：转储 Hash 连接统计信息 15、10128：转储分区休整信息 16、10200：转储一致性读信息 17、10201：转储一致性读中 Undo 应用 18、10209：允许在控制文件中模拟错误 19、10210：触发数据块检查事件
        event = "10210 trace name context forever, level 10" 20、10211：触发索引检查事件 21、10213：模拟在写控制文件后崩溃 22、10214：模拟在控制文件中的写错误
   levelnumber 从 1-9 表示产生错误的块号，大于等于 10 则每个控制文件将出错 23、10215：模拟在控制文件中的读错误 24、10220：转储 Undo 头部变化 25、10221；转储 Undo 变化 26、10224：转储索引的分隔与删除 27、10225：转储基于字典****管理****的区间的变化 28、10229：模拟在数据文件上的 I/O 错误 29、10231：设置在全表扫描时忽略损坏的数据块
         alter session set events '10231 trace name context off'; -- 关闭会话期间的数据块检查
         event = "10231 trace name context forever, level 10" -- 对任何进程读入 SGA 的数据块进行检查 30、10232：将设置为软损坏（DBMS_REPAIR 包设置或 DB_BLOCK_CHECKING 为 TRUE 时设置）的数据块 dump 到跟踪文件 31、10235：用于内存堆检查
   alter session set events '10235 trace name context forever, level 1'; 32、10241：转储远程 SQL 执行 33、10246：跟踪 PMON 进程 34、10248：跟踪 dispatch 进程 35、10249：跟踪 MTS 进程 36、10252：模拟写数据文件头部错误 37、10253：模拟写 redo 日志文件错误 38、10262：允许连接时存在内存泄漏
   alter session set events '10262 trace name context forever, level 300'; -- 允许存在 300 个字节的内存泄漏 39、10270：转储共享游标 40、10285：模拟控制文件头部损坏 41、10286：模拟控制文件打开错误 42、10287：模拟归档出错 43、10357：调试直接路径机制 44、10500：跟踪 SMON 进程 45、10608：跟踪位图索引的创建 46、10704：跟踪 enqueues 47、10706：跟踪全局 enqueues 48、10708：跟踪 ****RAC**** 的 buffer cache 49、10710：跟踪对位图索引的访问 50、10711：跟踪位图索引合并操作 51、10712：跟踪位图索引 OR 操作 52、10713：跟踪位图索引 AND 操作 53、10714：跟踪位图索引 MINUS 操作 54、10715：跟踪位图索引向 ROWID 的转化 55、10716：跟踪位图索引的压缩与解压 56、10719：跟踪位图索引的修改 57、10731：跟踪游标声明 58、10928：跟踪 PL/SQL 执行 59、10938：转储 PL/SQL 执行统计信息    由于版本不同以上语法可能有些变化，但大多数还是可用的。