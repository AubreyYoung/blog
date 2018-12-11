## 配置详解 | performance_schema全方位介绍（二）

## 导语
在上一篇 [《初相识 | performance_schema全方位介绍》](http://mp.weixin.qq.com/s?__biz=MzU0MTczNzA1OA==&mid=2247483711&idx=1&sn=aef31942ae6294053cddc0ba83630597&chksm=fb242832cc53a12477febfb309aa5ed9c4c5652a7dafee28ac32ce81a214a0fd72758ff045e9&scene=21#wechat_redirect) 中粗略介绍了如何配置与使用performance_schema，相信大家对performance_schema能够为我们提供什么样的性能数据已经有一个初步的认识，今天将带领大家一起踏上系列第二篇的征程(全系共7个篇章)，在这一期里，我们将为大家全面讲解performance_schema配置方式以及各个配置表的作用。下面，请跟随我们一起开始performance_schema系统的学习之旅吧。

## 基本概念
**instruments**：生产者，用于采集MySQL 中各种各样的操作产生的事件信息，对应配置表中的配置项我们可以称为监控采集配置项，以下提及生产者均统称为instruments

**consumers**：消费者，对应的消费者表用于存储来自instruments采集的数据，对应配置表中的配置项我们可以称为消费存储配置项，以下提及消费者均统称为consumers

------
**友情提示**：以下内容阅读起来可能比较烧脑，内容也较长，建议大家端好板凳，坐下来，点上一支烟，细细品读，这也是学习performance_schema路上不得不过的火焰山，坚持下去，"翻过这座山，你就可以看到一片海！"

## 编译时配置

在以往，我们认为自行编译安装MySQL其性能要优于官方编译好的二进制包、rpm包等。可能在MySQL早期的版本中有这样的情况， 但随着MySQL版本不断迭代，业界不少人亲测证实，目前的MySQL版本并不存在自行编译安装性能比官方编译好的二进制包性能高，所以，通常情况下，我们不建议去耗费数十分钟来编译安装MySQL，因为在大规模部署的场景，此举十分浪费时间(需要通过编译安装的方式精简模块的场景除外) 
可以使用cmake的编译选项来自行决定你的MySQL实例是否支持performance_schema的某个等待事件类别，如下：

```
shell> cmake . \
    -DDISABLE_PSI_STAGE=1 \   #关闭STAGE事件监视器
    -DDISABLE_PSI_STATEMENT=1  #关闭STATEMENT事件监视器
```
注意：虽然我们可以通过cmake的编译选项关闭掉某些performance_schema的功能模块，但是，通常我们不建议这么做，除非你非常清楚后续不可能使用到这些功能模块，否则后续想要使用被编译时关闭的模块，还需要重新编译。 
当我们接手一个别人安装的MySQL数据库服务器时，或者你并不清楚自己安装的MySQL版本是否支持performance_schema时，我们可以通过mysqld命令查看是否支持Performance Schema

```
# 如果发现performance_schema开头的几个选项，则表示当前mysqld支持performance_schema，如果没有发现performance_schema相关的选项，说明当前数据库版本不支持performance_schema，你可能需要升级mysql版本：
shell> mysqld --verbose --help
...
--performance_schema
                  Enable the performance schema.
--performance_schema_events_waits_history_long_size=#
                  Number of rows in events_waits_history_long.
```
还可以登录到MySQL实例中使用SQL命令查看是否支持performance_schema：
```
# Support列值为YES表示数据库支持，否则你可能需要升级mysql版本：
mysql> SHOW ENGINES\G
...
admin@localhost : (none) 12:54:00> show engines;
*************************** 6. row ***************************
  Engine: PERFORMANCE_SCHEMA
Support: YES
Comment: Performance Schema
Transactions: NO
      XA: NO
Savepoints: NO
9 rows in set (0.00 sec)
```
注意：在mysqld选项或show engines语句输出的结果中，如果看到有performance_schema相关的信息，并不代表已经启用了performance_schema，仅仅只是代表数据库支持，如果需要启用它，还需要在服务器启动时使用系统参数performance_schema=on(MySQL 5.7之前的版本默认关闭)显式开启

## 启动时配置

performance_schema中的配置是保存在内存中的，是易失的，也就是说保存在performance_schema配置表(本章后续内容会讲到)中的配置项在MySQL实例停止时会全部丢失。所以，如果想要把配置项持久化，就需要在MySQL的配置文件中使用启动选项来持久化配置项，让MySQL每次重启都自动加载配置项，而不需要每次重启都再重新配置。

### (1) 启动选项

performance_schema有哪些启动选项呢？我们可以通过如下命令行命令进行查看:
```
[root@localhost ~]# mysqld --verbose --help |grep performance-schema |grep -v '\-\-' |sed '1d' |sed '/[0-9]\+/d'
......
performance-schema-consumer-events-stages-current FALSE
performance-schema-consumer-events-stages-history FALSE
performance-schema-consumer-events-stages-history-long FALSE
performance-schema-consumer-events-statements-current TRUE
performance-schema-consumer-events-statements-history TRUE
performance-schema-consumer-events-statements-history-long FALSE
performance-schema-consumer-events-transactions-current FALSE
performance-schema-consumer-events-transactions-history FALSE
performance-schema-consumer-events-transactions-history-long FALSE
performance-schema-consumer-events-waits-current FALSE
performance-schema-consumer-events-waits-history FALSE
performance-schema-consumer-events-waits-history-long FALSE
performance-schema-consumer-global-instrumentation TRUE
performance-schema-consumer-statements-digest TRUE
performance-schema-consumer-thread-instrumentation TRUE
performance-schema-instrument  
......
```
下面将对这些启动选项进行简单描述(这些启动选项是用于指定consumers和instruments配置项在MySQL启动时是否跟随打开的，之所以叫做启动选项，是因为这些需要在mysqld启动时就需要通过命令行指定或者需要在my.cnf中指定，启动之后通过show variables命令无法查看，因为他们不属于system variables)

- performance_schema_consumer_events_statements_current=TRUE

是否在mysql server启动时就开启events_statements_current表的记录功能(该表记录当前的语句事件信息)，启动之后也可以在setup_consumers表中使用UPDATE语句进行动态更新setup_consumers配置表中的events_statements_current配置项，默认值为TRUE

- performance_schema_consumer_events_statements_history=TRUE

与performance_schema_consumer_events_statements_current选项类似，但该选项是用于配置是否记录语句事件短历史信息，默认为TRUE

- performance_schema_consumer_events_stages_history_long=FALSE

与performance_schema_consumer_events_statements_current选项类似，但该选项是用于配置是否记录语句事件长历史信息，默认为FALSE

- 除了statement(语句)事件之外，还支持：wait(等待)事件、state(阶段)事件、transaction(事务)事件，他们与statement事件一样都有三个启动项分别进行配置，但这些等待事件默认未启用，如果需要在MySQL Server启动时一同启动，则通常需要写进my.cnf配置文件中
- performance_schema_consumer_global_instrumentation=TRUE

是否在MySQL Server启动时就开启全局表（如：mutex_instances、rwlock_instances、cond_instances、file_instances、users、hostsaccounts、socket_summary_by_event_name、file_summary_by_instance等大部分的全局对象计数统计和事件汇总统计信息表 ）的记录功能，启动之后也可以在setup_consumers表中使用UPDATE语句进行动态更新全局配置项

默认值为TRUE

- performance_schema_consumer_statements_digest=TRUE

是否在MySQL Server启动时就开启events_statements_summary_by_digest 表的记录功能，启动之后也可以在setup_consumers表中使用UPDATE语句进行动态更新digest配置项

默认值为TRUE

- performance_schema_consumer_thread_instrumentation=TRUE

是否在MySQL Server启动时就开启

events_xxx_summary_by_yyy_by_event_name表的记录功能，启动之后也可以在setup_consumers表中使用UPDATE语句进行动态更新线程配置项

默认值为TRUE

- performance_schema_instrument[=name]

是否在MySQL Server启动时就启用某些采集器，由于instruments配置项多达数千个，所以该配置项支持key-value模式，还支持%号进行通配等，如下:

```
# [=name]可以指定为具体的Instruments名称（但是这样如果有多个需要指定的时候，就需要使用该选项多次），也可以使用通配符，可以指定instruments相同的前缀+通配符，也可以使用%代表所有的instruments
## 指定开启单个instruments
--performance-schema-instrument='instrument_name=value'
## 使用通配符指定开启多个instruments
--performance-schema-instrument='wait/synch/cond/%=COUNTED'
## 开关所有的instruments
--performance-schema-instrument='%=ON'
--performance-schema-instrument='%=OFF'
```
注意，这些启动选项要生效的前提是，需要设置performance_schema=ON。另外，这些启动选项虽然无法使用show variables语句查看，但我们可以通过setup_instruments和setup_consumers表查询这些选项指定的值。

###  (2) system variables

与performance_schema相关的system variables可以使用如下语句查看，这些variables用于限定consumers表的存储限制，它们都是只读变量，需要在MySQL启动之前就设置好这些变量的值。

```
root@localhost : (none) 11:43:29> show variables like '%performance_schema%';
.....
42 rows in set (0.01 sec)
```
下面，我们将对这些system variables(以下称为变量)中几个需要关注的进行简单解释(其中大部分变量是-1值，代表会自动调整，无需太多关注，另外，大于-1值的变量在大多数时候也够用，如果无特殊需求，不建议调整，调整这些参数会增加内存使用量)

- performance_schema=ON

- - 控制performance_schema功能的开关，要使用MySQL的performance_schema，需要在mysqld启动时启用，以启用事件收集功能
  - 该参数在5.7.x之前支持performance_schema的版本中默认关闭，5.7.x版本开始默认开启
  - 注意：如果mysqld在初始化performance_schema时发现无法分配任何相关的内部缓冲区，则performance_schema将自动禁用，并将performance_schema设置为OFF

- performance_schema_digests_size=10000

- - 控制events_statements_summary_by_digest表中的最大行数。如果产生的语句摘要信息超过此最大值，便无法继续存入该表，此时performance_schema会增加状态变量

- performance_schema_events_statements_history_long_size=10000

- - 控制events_statements_history_long表中的最大行数，该参数控制所有会话在events_statements_history_long表中能够存放的总事件记录数，超过这个限制之后，最早的记录将被覆盖
  - 全局变量，只读变量，整型值，5.6.3版本引入 
    \* 5.6.x版本中，5.6.5及其之前的版本默认为10000，5.6.6及其之后的版本默认值为-1，通常情况下，自动计算的值都是10000 
    \* 5.7.x版本中，默认值为-1，通常情况下，自动计算的值都是10000

- performance_schema_events_statements_history_size=10

- - 控制events_statements_history表中单个线程（会话）的最大行数，该参数控制单个会话在events_statements_history表中能够存放的事件记录数，超过这个限制之后，单个会话最早的记录将被覆盖
  - 全局变量，只读变量，整型值，5.6.3版本引入 
    \* 5.6.x版本中，5.6.5及其之前的版本默认为10，5.6.6及其之后的版本默认值为-1，通常情况下，自动计算的值都是10 
    \* 5.7.x版本中，默认值为-1，通常情况下，自动计算的值都是10

- 除了statement(语句)事件之外，wait(等待)事件、state(阶段)事件、transaction(事务)事件，他们与statement事件一样都有三个参数分别进行存储限制配置，有兴趣的同学自行研究，这里不再赘述

- performance_schema_max_digest_length=1024

- - 用于控制标准化形式的SQL语句文本在存入performance_schema时的限制长度，该变量与max_digest_length变量相关(max_digest_length变量含义请自行查阅相关资料)
  - 全局变量，只读变量，默认值1024字节，整型值，取值范围0~1048576，5.6.26和5.7.8版本中引入

- performance_schema_max_sql_text_length=1024

- - 控制存入events_statements_current，events_statements_history和events_statements_history_long语句事件表中的SQL_TEXT列的最大SQL长度字节数。 超出系统变量performance_schema_max_sql_text_length的部分将被丢弃，不会记录，一般情况下不需要调整该参数，除非被截断的部分与其他SQL比起来有很大差异
  - 全局变量，只读变量，整型值，默认值为1024字节，取值范围为0~1048576，5.7.6版本引入
  - 降低系统变量performance_schema_max_sql_text_length值可以减少内存使用，但如果汇总的SQL中，被截断部分有较大差异，会导致没有办法再对这些有较大差异的SQL进行区分。 增加该系统变量值会增加内存使用，但对于汇总SQL来讲可以更精准地区分不同的部分。

## 运行时配置

在MySQL启动之后，我们就无法使用启动选项来开关相应的consumers和instruments了，此时，我们如何根据自己的需求来灵活地开关performance_schema中的采集信息呢？(例如：默认配置下很多配置项并未开启，我们可能需要即时去修改配置，再如：高并发场景，大量的线程连接到MySQL，执行各种各样的SQL时产生大量的事件信息，而我们只想看某一个会话产生的事件信息时，也可能需要即时去修改配置)，我们可以通过修改performance_schema下的几张配置表中的配置项实现
这些配置表中的配置项之间存在着关联关系，按照配置影响的先后顺序，可整理为如下图(该表仅代表个人理解)： 

![img](data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQImWNgYGBgAAAABQABh6FO1AAAAABJRU5ErkJggg==)

### (1)  performance_timers表

performance_timers表中记录了server中有哪些可用的事件计时器（注意：该表中的配置项不支持增删改，是只读的。有哪些计时器就表示当前的版本支持哪些计时器），setup_timers配置表中的配置项引用此表中的计时器

每个计时器的精度和数量相关的特征值会有所不同，可以通过如下查询语句查看performance_timers表中记录的计时器和相关的特征信息：

```
mysql> SELECT * FROM performance_timers;
+-------------+-----------------+------------------+----------------+
| TIMER_NAME | TIMER_FREQUENCY | TIMER_RESOLUTION | TIMER_OVERHEAD |
+-------------+-----------------+------------------+----------------+
| CYCLE | 2389029850 | 1 | 72 |
| NANOSECOND | 1000000000 | 1 | 112 |
| MICROSECOND | 1000000 | 1 | 136 |
| MILLISECOND | 1036 | 1 | 168 |
| TICK | 105 | 1 | 2416 |
+-------------+-----------------+------------------+----------------+
```
**performance_timers****表中的字段含义如下****：**

- TIMER_NAME：表示可用计时器名称，CYCLE是指基于CPU（处理器）周期计数器的定时器。在setup_timers表中可以使用performance_timers表中列值不为null的计时器（如果performance_timers表中有某字段值为NULL，则表示该定时器可能不支持当前server所在平台）
- TIMER_FREQUENCY：表示每秒钟对应的计时器单位的数量（即，相对于每秒时间换算为对应的计时器单位之后的数值，例如：每秒=1000毫秒=1000000微秒=1000000000纳秒）。对于CYCLE计时器的换算值，通常与CPU的频率相关。对于performance_timers表中查看到的CYCLE计时器的TIMER_FREQUENCY列值 ，是根据2.4GHz处理器的系统上获得的预设值（在2.4GHz处理器的系统上，CYCLE可能接近2400000000）。NANOSECOND 、MICROSECOND 、MILLISECOND 计时器是基于固定的1秒换算而来。对于TICK计时器，TIMER_FREQUENCY列值可能会因平台而异（例如，某些平台使用100个tick/秒，某些平台使用1000个tick/秒）
- TIMER_RESOLUTION：计时器精度值，表示在每个计时器被调用时额外增加的值（即使用该计时器时，计时器被调用一次，需要额外增加的值）。如果计时器的分辨率为10，则其计时器的时间值在计时器每次被调用时，相当于TIMER_FREQUENCY值+10
- TIMER_OVERHEAD：表示在使用定时器获取事件时开销的最小周期值（performance_schema在初始化期间调用计时器20次，选择一个最小值作为此字段值），每个事件的时间开销值是计时器显示值的两倍，因为在事件的开始和结束时都调用计时器。注意：计时器代码仅用于支持计时事件，对于非计时类事件（如调用次数的统计事件），这种计时器统计开销方法不适用
- PS：对于performance_timers表，不允许使用TRUNCATE TABLE语句
### (2)setup_timers表

setup_timers表中记录当前使用的事件计时器信息（注意：该表不支持增加和删除记录，只支持修改和查询）

可以通过UPDATE语句来更改setup_timers.TIMER_NAME列值，以给不同的事件类别选择不同的计时器，setup_timers.TIMER_NAME列有效值来自performance_timers.TIMER_NAME列值。

对setup_timers表的修改会立即影响监控。正在执行的事件可能会使用修改之前的计时器作为开始时间，但可能会使用修改之后的新的计时器作为结束时间，为了避免计时器更改后可能产生时间信息收集到不可预测的结果，请在修改之后使用TRUNCATE TABLE语句来重置performance_schema中相关表中的统计信息。

```
mysql> SELECT * FROM setup_timers;
+-------------+-------------+
| NAME        | TIMER_NAME  |
+-------------+-------------+
| idle        | MICROSECOND |
| wait        | CYCLE      |
| stage      | NANOSECOND  |
| statement  | NANOSECOND  |
| transaction | NANOSECOND  |
+-------------+-------------+
```
**setup_timers表字段含义如下：**

- NAME：计时器类型，对应着某个事件类别(事件类别详见 3.3.4 节)
- TIMER_NAME：计时器类型名称。此列可以修改，有效值参见performance_timers.TIMER_NAME列值
- PS：对于setup_timers表，不允许使用TRUNCATE TABLE语句

### (3) setup_consumers表

setup_consumers表列出了consumers可配置列表项(注意：该表不支持增加和删除记录，只支持修改和查询)，如下：

```
mysql> SELECT * FROM setup_consumers;
+----------------------------------+---------+
| NAME                            | ENABLED |
+----------------------------------+---------+
| events_stages_current            | NO      |
| events_stages_history            | NO      |
| events_stages_history_long      | NO      |
| events_statements_current        | YES    |
| events_statements_history        | YES    |
| events_statements_history_long  | NO      |
| events_transactions_current      | NO      |
| events_transactions_history      | NO      |
| events_transactions_history_long | NO      |
| events_waits_current            | NO      |
| events_waits_history            | NO      |
| events_waits_history_long        | NO      |
| global_instrumentation          | YES    |
| thread_instrumentation          | YES    |
| statements_digest                | YES    |
+----------------------------------+---------+
```
**对setup_consumers表的修改会立即影响监控，setup_consumers字段含义如下：**

- NAME：consumers配置名称
- ENABLED：consumers是否启用，有效值为YES或NO，此列可以使用UPDATE语句修改。如果需要禁用consumers就设置为NO，设置为NO时，server不会维护这些consumers表的内容新增和删除，且也会关闭consumers对应的instruments（如果没有instruments发现采集数据没有任何consumers消费的话）
- PS：对于setup_consumers表，不允许使用TRUNCATE TABLE语句

setup_consumers表中的consumers配置项具有层级关系，具有从较高级别到较低级别的层次结构，按照优先级顺序，可列举为如下层次结构（你可以根据这个层次结构，关闭你可能不需要的较低级别的consumers，这样有助于节省性能开销，且后续查看采集的事件信息时也方便进行筛选）： 
![img](data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQImWNgYGBgAAAABQABh6FO1AAAAABJRU5ErkJggg==)
从上图中的信息中可以看到，**setup_consumers****表中consumers配置层次结构中：**

- global_instrumentation处于顶级位置，优先级最高。 
  \* 当global_instrumentation为YES时，会检查setup_consumers表中的statements_digest和thread_instrumentation的配置，会附带检查setup_instruments、setup_objects、setup_timers配置表 
  \* 当global_instrumentation为YES时（无论setup_consumers表中的statements_digest和thread_instrumentation如何配置，只依赖于global_instrumentation的配置），会维护全局events输出表：mutex_instances、rwlock_instances、cond_instances、file_instances、users、hostsaccounts、socket_summary_by_event_name、file_summary_by_instance、file_summary_by_event_name、objects_summary_global_by_type、memory_summary_global_by_event_name、table_lock_waits_summary_by_table、table_io_waits_summary_by_index_usage、table_io_waits_summary_by_table、events_waits_summary_by_instance、events_waits_summary_global_by_event_name、events_stages_summary_global_by_event_name、events_statements_summary_global_by_event_name、events_transactions_summary_global_by_event_name 
  \* 当global_instrumentation为NO时，不会检查任何更低级别的consumers配置，不会维护任何events输出表(memory_%开头的events输出表除外，这些表维护只受setup_instruments配置表控制)  
- statements_digest和thread_instrumentation处于同一级别，优先级次于global_instrumentation，且依赖于global_instrumentation为YES时配置才会被检测 
  * 当statements_digest为YES时，statements_digest consumers没有更低级别的配置，依赖于global_instrumentation为YES时配置才会被检测，会维护events输出表：events_statements_summary_by_digest 
  * 当statements_digest为NO时，不维护events输出表：events_statements_summary_by_digest 
  * 当thread_instrumentation为YES时，会检查setup_consumers表中的events_xxx_current配置（xxx表示：waits、stages、statements、transactions），会附带检查setup_actors、threads配置表。会维护events输出表 events_xxx_summary_by_yyy_by_event_name，其中： xxx含义同上; yyy表示：thread、user、host、account 
  * 当thread_instrumentation为NO时，不检查setup_consumers表中的events_xxx_current配置，不维护events_xxx_current及其更低级别的events输出表
- events_xxx_current系列(xxx含义同上)consumers处于同一级别。且依赖于thread_instrumentation为YES时配置才会被检测 
  \* 当events_xxx_current为YES时，会检测setup_consumers配置表中的events_xxx_history和events_xxx_history_long系列 consumers配置，会维护events_xxx_current系列表 
  \* 当events_xxx_current为NO时，不检测setup_consumers配置表中的events_xxx_history和events_xxx_history_long系列 consumers配置，不维护events_xxx_current系列表
- events_xxx_history和events_xxx_history_long系列（同events_xxx_current中的xxx）consumers处于同一级别，优先级次于events_xxx_current 系列consumers(xxx含义同上)，依赖于events_xxx_current 系列consumers为YES时才会被检测 
  \* 当events_xxx_history为YES时，没有更低级别的conosumers配置需要检测，但会附带检测setup_actors、threads配置表中的HISTORY列值，会维护events_xxx_history系列表，反之不维护 
  \* 当events_xxx_history_long为YES时，没有更低级别的conosumers配置需要检测，但会附带检测setup_actors、threads配置表中的HISTORY列值，会维护events_xxx_history_long系列表，反之不维护

**注意：**

- events 输出表

  events_xxx_summary_by_yyy_by_event_name的开关由global_instrumentation控制，且表中是有固定数据行，不可清理，truncate或者关闭相关的consumers时只是不统计相关的instruments收集的events数据，相关字段为0值

- 如果performance_schema在对setup_consumers表做检查时发现某个consumers配置行的ENABLED 列值不为YES，则与这个consumers相关联的events输出表中就不会接收存储任何事件记录

- 高级别的consumers设置不为YES时，依赖于这个consumers配置为YES时才会启用的那些更低级别的consumers将一同被禁用

**配置项修改示例：**

```
# 打开events_waits_current表当前等待事件记录功能
mysql> UPDATE setup_consumers SET ENABLED ='NO' WHERE NAME ='events_waits_current';
# 关闭历史事件记录功能
mysql> UPDATE setup_consumers SET ENABLED ='NO' where name like '％history％';
# where条件 ENABLED ='YES' 即为打开对应的记录表功能
......
```

### (4) setup_instruments表

setup_instruments 表列出了instruments 列表配置项，即代表了哪些事件支持被收集：
```
mysql> SELECT * FROM setup_instruments;
+------------------------------------------------------------+---------+-------+
| NAME                                                      | ENABLED | TIMED |
+------------------------------------------------------------+---------+-------+
...
| wait/synch/mutex/sql/LOCK_global_read_lock                | YES    | YES  |
| wait/synch/mutex/sql/LOCK_global_system_variables          | YES    | YES  |
| wait/synch/mutex/sql/LOCK_lock_db                          | YES    | YES  |
| wait/synch/mutex/sql/LOCK_manager                          | YES    | YES  |
...
| wait/synch/rwlock/sql/LOCK_grant                          | YES    | YES  |
| wait/synch/rwlock/sql/LOGGER::LOCK_logger                  | YES    | YES  |
| wait/synch/rwlock/sql/LOCK_sys_init_connect                | YES    | YES  |
| wait/synch/rwlock/sql/LOCK_sys_init_slave                  | YES    | YES  |
...
| wait/io/file/sql/binlog                                    | YES    | YES  |
| wait/io/file/sql/binlog_index                              | YES    | YES  |
| wait/io/file/sql/casetest                                  | YES    | YES  |
| wait/io/file/sql/dbopt                                    | YES    | YES  |
...
```
instruments具有树形结构的命名空间，从setup_instruments表中的NAME字段上可以看到，instruments名称的组成从左到右，最左边的是顶层instruments类型命名，最右边是一个具体的instruments名称，有一些顶层instruments没有其他层级的组件（如：transaction和idle，那么这个顶层类型既是类型又是具体的instruments），有一些顶层instruments具有下层instruments（如：wait/io/file/myisam/log），一个层级的instruments名称对应的组件数量取决于instruments的类型。

一个给定instruments名称的含义，需要看instruments名称的左侧命名而定，例如下边两个myisam相关名称的instruments含义各不相同： 
名称中给定组件的解释取决于其左侧的组件。例如，myisam显示在以下两个名称：

```
# 第一种instruments表示myisam引擎的文件IO相关的instruments
wait/io/file/myisam/log
# 第二种instruments表示myisam引擎的磁盘同步相关的instruments
wait/synch/cond/myisam/MI_SORT_INFO::cond
```
instruments的命名格式组成：performance_schema实现的一个前缀结构（如：wait/io/file/myisam/log中的wait+由开发人员实现的instruments代码定义的一个后缀名称组成（如：wait/io/file/myisam/log中的io/file/myisam/log）

- instruments名称前缀表示instruments的类型(如wait/io/file/myisam/log中的wait)，该前缀名称还用于在setup_timers表中配置某个事件类型的定时器，也被称作顶层组件
- instruments名称后缀部分来自instruments本身的代码。后缀可能包括以下层级的组件： 
  \* 主要组件的名称（如：myisam，innodb，mysys或sql，这些都是server的子系统模块组件）或插件名称 
  \* 代码中变量的名称，格式为XXX（全局变量）或CCC::MMM（CCC表示一个类名，MMM表示在类CCC作用域中的一个成员对象），如：'wait/synch/cond/sql/COND_thread_cache' instruments中的COND_thread_cache，'wait/synch/mutex/mysys/THR_LOCK_myisam' instruments中的THR_LOCK_myisam，'wait/synch/mutex/sql/MYSQL_BIN_LOG::LOCK_index' instruments中的MYSQL_BIN_LOG::LOCK_index

在源代码中每一个实现的instruments，如果该源代码被加载到server中，那么在该表中就会有一行对应的配置，当启用或执行instruments时，会创建对应的instruments实例，这些实例在* _instances表中可以查看到

大多数setup_instruments配置行修改会立即影响监控，但对于某些instruments，运行时修改不生效（配置表可以修改，但不生效），只有在启动之前修改才会生效（使用system variables写到配置文件中），不生效的instruments主要有mutexes, conditions, and rwlocks

**setup_instruments表字段详解如下：**

- NAME：instruments名称，instruments名称可能具有多个部分并形成层次结构(详见下文)。当instruments被执行时，产生的事件名称就取自instruments的名称，事件没有真正的名称，直接使用instruments来作为事件的名称，可以将instruments与产生的事件进行关联
- ENABLED：instrumetns是否启用，有效值为YES或NO，此列可以使用UPDATE语句修改。如果设置为NO，则这个instruments不会被执行，不会产生任何的事件信息
- TIMED：instruments是否收集时间信息，有效值为YES或NO，此列可以使用UPDATE语句修改，如果设置为NO，则这个instruments不会收集时间信息

对于内存instruments，setup_instruments中的TIMED列将被忽略（使用update语句对这些内存instruments设置timed列为YES时可以执行成功，但是你会发现执行update之后select这些instruments的timed列还是NO），因为内存操作没有定时器信息

如果某个instruments的enabled设置为YES（表示启用这个instruments），但是timed列未设置为YES（表示计时器功能禁用），则instruments会产生事件信息，但是事件信息对应的TIMER_START，TIMER_END和TIMER_WAIT定时器值都为NULL。后续汇总表中计算sum，minimum，maximum和average时间值时会忽略这些null值

PS：setup_instruments表不允许使用TRUNCATE TABLE语句

**setup_instruments中的instruments name层级结构图如下：**



![img](data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQImWNgYGBgAAAABQABh6FO1AAAAABJRU5ErkJggg==)



**在setup_instruments表中的instruments顶级instruments 组件分类如下：**

- Idle Instrument 组件：用于检测空闲事件的instruments，该instruments没有其他层级的组件，空闲事件收集时机如下： 
  * 依据socket_instances表中的STATE字段而定，STATE字段有ACTIVE和IDLE两个值，如果STATE字段值为ACTIVE，则performance_schema使用与socket类型相对应的instruments跟踪活跃的socket连接的等待时间（监听活跃的socket的instruments有wait/io/socket/sql/server_tcpip_socket、wait/io/socket/sql/server_unix_socket、wait/io/socket/sql/client_connection），如果STATE字段值为IDLE，则performance_schema使用idle instruments跟踪空闲socket连接的等待时间 
  * 如果socket连接在等待来自客户端的请求，则此时套接字处于空闲状态，socket_instances表中处于空闲的套接字行的STATE字段会从ACTIVE变为IDLE。 EVENT_NAME列值保持不变，instruments的定时器被暂停。 并在events_waits_current表中生成一个EVENT_NAME值为idle的事件记录行 
  * 当套接字接收到客户端的下一个请求时，空闲事件被终止，套接字实例从空闲状态切换到活动状态，并恢复套接字instruments的定时器工作 
  * socket_instances表不允许使用TRUNCATE TABLE语句 
  * 表字段含义详见后续socket_instances表介绍章节
- transaction instrument 组件：用于检测transactions 事件的instruments，该instruments没有其他层级的组件
- Memory Instrument 组件：用于检测memorys 事件的instruments 
  \* 默认情况下禁用了大多数memory instruments，但可以在server启动时在my.cnf中启用或禁用，或者在运行时更新setup_instruments表中相关instruments配置来动态启用或禁用。memory instruments的命名格式为：memory/code_area/instrument_name，其中code_area是一个server组件字符串值（如：sql、client、vio、mysys、partition和存储引擎名称：performance_schema、myisam、innodb、csv、myisammrg、memory、blackhole、archive等），而instrument_name是具体的instruments名称 
  \* 以前缀'memory/performance_schema'命名的instruments显示为performance_schem内部缓冲区分配了多少内存。'memory/performance_schema' 开头的instruments'是内置的，无法在启动时或者运行时人为开关，内部始终启用。这些instruments采集的events事件记录仅存储在memory_summary_global_by_event_name表中。详细信息详见后续章节
- Stage Instrument 组件：用于检测stages事件的instruments 
  \* stage instruments命名格式为：'stage/code_area/stage_name' 格式，其中code_area是一个server组件字符串值（与memory instruments类似），stage_name表示语句的执行阶段，如'Sorting result' 和 'Sending data'。这些执行阶段字符串值与SHOW PROCESSLIST的State列值、INFORMATION_SCHEMA.PROCESSLIST表的STATE列值类似。
- Statement Instrument 组件：用于检测statements事件的instruments，包含如下几个子类 
  * statement/abstract/：statement操作的抽象 instruments。抽象 instruments用于语句没有确定语句类型的早期阶段，在语句类型确定之后使用对应语句类型的instruments代替，详细信息见后续章节 
  * statement/com/：command操作相关的instruments。这些名称对应于COM_xxx操作命令（详见mysql_com.h头文件和sql/sql_parse.cc文件。例如：statement/com/Connect和statement/com/Init DB instruments分别对应于COM_CONNECT和COM_INIT_DB命令） 
  * statement/scheduler/event：用于跟踪一个事件调度器执行过程中的所有事件的instruments，该类型instruments只有一个 
  * statement/sp/：用于检测存储程序执行过程中的内部命令的instruemnts，例如，statement/sp/cfetch和statement/sp/freturn instruments表示检测存储程序内部使用游标提取数据、函数返回数据等相关命令 
  * statement/sql/：SQL语句操作相关的instruments。例如，statements/sql/create_db和statement/sql/select instruments，表示检测CREATE DATABASE和SELECT语句的instruments
- Wait Instrument 组件：用于检测waits事件的instruments，包含如下几个子类 
  \* wait/io：用于检测I/O操作的instruments，包含如下几个子类 
  \* 1）、wait/io/file：用于检测文件I/O操作的instruments，对于文件来说，表示等待文件相关的系统调用完成，如fwrite（）系统调用。由于缓存的存在，在数据库中的相关操作时不一定需要在磁盘上做读写操作。 
  \* 2）、wait/io/socket：用于检测socket操作的instruments，socket instruments的命名形式为：'wait/io/socket/sql/socket_type'，server在支持的每一种网络通讯协议上监听socket。socket instruments监听TCP/IP、Unix套接字文件连接的socket_type有server_tcpip_socket、server_unix_socket值。当监听套接字检测到有客户端连接进来时，server将客户端连接转移到被单独线程管理的新套接字来处理。新连接线程对应的socket_type值为client_connection。使用语句select * from setup_instruments where name like 'wait/io/socket%';可以查询这三个socket_type对应的instruments

**wait/io/table/sql/handler：** 

1). 表I/O操作相关的instruments。这个类别包括了对持久基表或临时表的行级访问（对数据行获取，插入，更新和删除），对于视图来说，instruments检测时会参照被视图引用的基表访问情况 

2). 与大多数等待事件不同，表I/O等待可以包括其他等待。例如，表I/O可能包括文件I/O或内存操作。因此，表I/O等待的事件在events_waits_current表中的记录通常有两行（除了wait/io/table/sql/handler的事件记录之外，可能还包含一行wait/io/file/myisam/dfile的事件记录）。这种可以叫做表IO操作的原子事件

3). 某些行操作可能会导致多个表I/O等待。例如，如果有INSERT的触发器，那么插入操作可能导致触发器更新操作。

**wait/lock：锁操作相关的instruments** 

1). wait/lock/table：表锁操作相关的instruments 

2). wait/lock/metadata/sql/mdl：MDL锁操作相关的instruments



**wait/synch**：磁盘同步object相关的instruments， performance_schema.events_waits_xxx表中的TIMER_WAIT时间列包括了在尝试获取某个object上的锁（如果这个对象上已经存在锁）的时候被阻塞的时长。

1). wait/synch/cond：一个线程使用一个状态来向其他线程发信号通知他们正在等待的事情已经发生了。如果一个线程正在等待这个状态，那么它可以被这个状态唤醒并继续往下执行。如果是几个线程正在等待这个状态，则这些线程都会被唤醒，并竞争他们正在等待的资源，该instruments用于采集某线程等待这个资源时被阻塞的事件信息。 

2). wait/synch/mutex：一个线程在访问某个资源时，使用互斥对象防止其他线程同时访问这个资源。该instruments用于采集发生互斥时的事件信息 

3). wait/synch/rwlock：一个线程使用一个读写锁对象对某个特定变量进行锁定，以防止其他线程同时访问，对于使用共享读锁锁定的资源，多个线程可以同时访问，对于使用独占写锁锁定的资源，只有一个线程能同时访问，该instruments用于采集发生读写锁锁定时的事件信息 

4). wait/synch/sxlock：shared-exclusive(SX)锁是一种rwlock锁 object，它提供对公共资源的写访问的同时允许其他线程的不一致读取。sxlocks锁object可用于优化数据库读写场景下的并发性和可扩展性。



要控制这些instruments的起停，将ENABLED列设置为YES或NO，要配置instruments是否收集计时器信息，将TIMED列值设置为YES或NO

setup_instruments表，对大多数instruments的修改会立即影响监控。但对于某些instruments，修改需要在mysql server重启才生效，运行时修改不生效。因为这些可能会影响mutexes、conditions和rwlocks，下面我们来看一些setup_instruments表修改示例：



```
# 禁用所有instruments，修改之后，生效的instruments修改会立即产生影响，即立即关闭收集功能：
mysql> UPDATE setup_instruments SET ENABLED = 'NO';
# 禁用所有文件类instruments，使用NAME字段结合like模糊匹配：
mysql> UPDATE setup_instruments SET ENABLED = 'NO' WHERE NAME LIKE 'wait/io/file/%';
# 仅禁用文件类instruments，启用所有其他instruments，使用NAME字段结合if函数，LIKE模糊匹配到就改为NO，没有匹配到的就改为YES：
mysql> UPDATE setup_instruments SET ENABLED = IF(NAME LIKE 'wait/io/file/%', 'NO', 'YES');
# 启用所有类型的events的mysys子系统的instruments：
mysql> UPDATE setup_instruments SET ENABLED = CASE WHEN NAME LIKE '%/mysys/%' THEN 'YES' ELSE 'NO' END;
# 禁用指定的某一个instruments：
mysql> UPDATE setup_instruments SET ENABLED = 'NO' WHERE NAME = 'wait/synch/mutex/mysys/TMPDIR_mutex';
# 切换instruments开关的状态，“翻转”ENABLED值，使用ENABLED字段值+ if函数， IF(ENABLED = 'YES', 'NO', 'YES')表示，如果ENABLED值为YES，则修改为NO，否则修改为YES：
mysql> UPDATE setup_instruments SET ENABLED = IF(ENABLED = 'YES', 'NO', 'YES') WHERE NAME = 'wait/synch/mutex/mysys/TMPDIR_mutex';
# 禁用所有instruments的计时器：
mysql> UPDATE setup_instruments SET TIMED = 'NO';
```

查找innodb存储引擎的文件相关的instruments，可以用如下语句查询:



```
admin@localhost : performance_schema 09:16:59> select * from setup_instruments where name like 'wait/io/file/innodb/%';
+--------------------------------------+---------+-------+
| NAME                                 | ENABLED | TIMED |
+--------------------------------------+---------+-------+
| wait/io/file/innodb/innodb_data_file | YES     | YES   |
| wait/io/file/innodb/innodb_log_file  | YES     | YES   |
| wait/io/file/innodb/innodb_temp_file | YES     | YES   |
+--------------------------------------+---------+-------+
3 rows in set (0.00 sec)
```



PS：

- 官方文档中没有找到每一个instruments具体的说明文档，官方文档中列出如下几个原因： 
  \* instruments是服务端代码，所以代码可能经常变动 
  \* instruments总数量有数百种，全部列出不现实 
  \* instruments会因为你安装的版本不同而有所不同，每一个版本所支持的instruments可以通过查询setup_instruments表获取

**一些可能常用的场景相关的设置 :**

\* metadata locks监控需要打开'wait/lock/metadata/sql/mdl' instruments才能监控，开启这个instruments之后在表performance_schema.metadata_locks表中可以查询到MDL锁信息 
\* profiing探针功能即将废弃，监控探针相关的事件信息需要打开语句：select * from setup_instruments where name like '%stage/sql%' and name not like '%stage/sql/Waiting%' and name not like '%stage/sql/%relay%' and name not like '%stage/sql/%binlog%' and name not like '%stage/sql/%load%' ;返回结果集中的instruments，开启这些instruments之后，可以在performance_schema.events_stages_xxx表中查看原探针相关的事件信息。 
\* 表锁监控需要打开'wait/io/table/sql/handler' instruments，开启这个instruments之后在表performance_schema.table_handles中会记录了当前打开了哪些表(执行flush tables强制关闭打开的表时，该表中的信息会被清空)，哪些表已经被加了表锁（某会话持有表锁时，相关记录行中的OWNER_THREAD_ID和OWNER_EVENT_ID列值会记录相关的thread id和event id），表锁被哪个会话持有（释放表锁时，相关记录行中的OWNER_THREAD_ID和OWNER_EVENT_ID列值会被清零） 
\* 查询语句top number监控，需要打开'statement/sql/select' instruments，然后打开events_statements_xxx表，通过查询performance_schema.events_statements_xxx表的SQL_TEXT字段可以看到原始的SQL语句，查询TIMER_WAIT字段可以知道总的响应时间，LOCK_TIME字段可以知道加锁时间（注意时间单位是皮秒，需要除以1000000000000才是单位秒）

- 有关setup_instruments字段详解

### (5)setup_actors表

setup_actors用于配置是否为新的前台server线程（与客户端连接相关联的线程）启用监视和历史事件日志记录。默认情况下，此表的最大行数为100。可以使用系统变量performance_schema_setup_actors_size在server启动之前更改此表的最大配置行数

- 对于每个新的前台server线程，perfromance_schema会匹配该表中的User,Host列进行匹配，如果匹配到某个配置行，则继续匹配该行的ENABLED和HISTORY列值，ENABLED和HISTORY列值也会用于生成threads配置表中的行INSTRUMENTED和HISTORY列。如果用户线程在创建时在该表中没有匹配到User,Host列，则该线程的INSTRUMENTED和HISTORY列将设置为NO，表示不对这个线程进行监控，不记录该线程的历史事件信息。
- 对于后台线程（如IO线程，日志线程，主线程，purged线程等），没有关联的用户， INSTRUMENTED和HISTORY列值默认为YES，并且后台线程在创建时，不会查看setup_actors表的配置，因为该表只能控制前台线程，后台线程也不具备用户、主机属性

setup_actors表的初始内容是匹配任何用户和主机，因此对于所有前台线程，默认情况下启用监视和历史事件收集功能，如下：

```
mysql> SELECT * FROM setup_actors;
+------+------+------+---------+---------+
| HOST | USER | ROLE | ENABLED | HISTORY |
+------+------+------+---------+---------+
| %    | %    | %    | YES    | YES    |
+------+------+------+---------+---------+
```

**setup_actors表字段含义如下：**

- HOST：与grant语句类似的主机名，一个具体的字符串名字，或使用“％”表示“任何主机”
- USER：一个具体的字符串名称，或使用“％”表示“任何用户”
- ROLE：当前未使用，MySQL 8.0中才启用角色功能
- ENABLED：是否启用与HOST，USER，ROLE匹配的前台线程的监控功能，有效值为：YES或NO
- HISTORY：是否启用与HOST， USER，ROLE匹配的前台线程的历史事件记录功能，有效值为：YES或NO
- PS：setup_actors表允许使用TRUNCATE TABLE语句清空表，或者DELETE语句删除指定行

对setup_actors表的修改仅影响修改之后新创建的前台线程，对于修改之前已经创建的前台线程没有影响，如果要修改已经创建的前台线程的监控和历史事件记录功能，可以修改threads表行的INSTRUMENTED和HISTORY列值：

当一个前台线程初始化连接mysql server时，performance_schema会对表setup_actors执行查询，在表中查找每个配置行，首先尝试使用USER和HOST列（ROLE未使用）依次找出匹配的配置行，然后再找出最佳匹配行并读取匹配行的ENABLED和HISTORY列值，用于填充threads表中的ENABLED和HISTORY列值。

- 示例，假如setup_actors表中有如下HOST和USER值： 
  * USER ='literal' and HOST ='literal' 
  * USER ='literal' and HOST ='％' 
  * USER ='％' and HOST ='literal' 
  * USER ='％' and HOST ='％'
- 匹配顺序很重要，因为不同的匹配行可能具有不同的USER和HOST值（mysql中对于用户帐号是使用user@host进行区分的），根据匹配行的ENABLED和HISTORY列值来决定对每个HOST，USER或ACCOUNT（USER和HOST组合，如：user@host）对应的线程在threads表中生成对应的匹配行的ENABLED和HISTORY列值 ，以便决定是否启用相应的instruments和历史事件记录，类似如下： 
  * 当在setup_actors表中的最佳匹配行的ENABLED = YES时，threads表中对应线程的配置行中INSTRUMENTED列值将变为YES，HISTORY 列同理 
  * 当在setup_actors表中的最佳匹配行的ENABLED = NO时，threads表中对应线程的配置行中INSTRUMENTED列值将变为NO，HISTORY 列同理 
  * 当在setup_actors表中找不到匹配时，threads表中对应线程的配置行中INSTRUMENTED和HISTORY值值将变为NO 
  * setup_actors表配置行中的ENABLED和HISTORY列值可以相互独立设置为YES或NO，互不影响，一个是是否启用线程对应的instruments，一个是是否启用线程相关的历史事件记录的consumers
- 默认情况下，所有新的前台线程启用instruments和历史事件收集，因为setup_actors表中的预设值是host='%'，user='%',ENABLED='YES',HISTORY='YES'的。如果要执行更精细的匹配(例如仅对某些前台线程进行监视），那就必须要对该表中的默认值进行修改，如下：

```
# 首先使用UPDATE语句把默认配置行禁用
UPDATE setup_actors SET ENABLED = 'NO', HISTORY = 'NO' WHERE HOST = '%' AND USER = '%';
# 插入用户joe@'localhost'对应ENABLED和HISTORY都为YES的配置行
INSERT INTO setup_actors (HOST,USER,ROLE,ENABLED,HISTORY) VALUES('localhost','joe','%','YES','YES');
# 插入用户joe@'hosta.example.com'对应ENABLED=YES、HISTORY=NO的配置行
INSERT INTO setup_actors (HOST,USER,ROLE,ENABLED,HISTORY) VALUES('hosta.example.com','joe','%','YES','NO');
# 插入用户sam@'%'对应ENABLED=NO、HISTORY=YES的配置行
INSERT INTO setup_actors (HOST,USER,ROLE,ENABLED,HISTORY) VALUES('%','sam','%','NO','YES');
# 此时，threads表中对应用户的前台线程配置行中INSTRUMENTED和HISTORY列生效值如下
## 当joe从localhost连接到mysql server时，则连接符合第一个INSERT语句插入的配置行，threads表中对应配置行的INSTRUMENTED和HISTORY列值变为YES
## 当joe从hosta.example.com连接到mysql server时，则连接符合第二个INSERT语句插入的配置行，threads表中对应配置行的INSTRUMENTED列值为YES，HISTORY列值为NO
## 当joe从其他任意主机(%匹配除了localhost和hosta.example.com之外的主机)连接到mysql server时，则连接符合第三个INSERT语句插入的配置行，threads表中对应配置行的INSTRUMENTED和HISTORY列值变为NO
## 当sam从任意主机(%匹配)连接到mysql server时，则连接符合第三个INSERT语句插入的配置行，threads表中对应配置行的INSTRUMENTED列值变为NO，HISTORY列值为YES
## 除了joe和sam用户之外，其他任何用户从任意主机连接到mysql server时，匹配到第一个UPDATE语句更新之后的默认配置行，threads表中对应配置行的INSTRUMENTED和HISTORY列值变为NO
## 如果把UPDATE语句改成DELETE，让未明确指定的用户在setup_actors表中找不到任何匹配行，则threads表中对应配置行的INSTRUMENTED和HISTORY列值变为NO
```

对于后台线程，对setup_actors表的修改不生效，如果要干预后台线程默认的设置，需要查询threads表找到相应的线程，然后使用UPDATE语句直接修改threads表中的INSTRUMENTED和HISTORY列值。

### (6)setup_objects表

setup_objects表控制performance_schema是否监视特定对象。默认情况下，此表的最大行数为100行。要更改表行数大小，可以在server启动之前修改系统变量performance_schema_setup_objects_size的值。

setup_objects表初始内容如下所示：

```
mysql> SELECT * FROM setup_objects;
+-------------+--------------------+-------------+---------+-------+
| OBJECT_TYPE | OBJECT_SCHEMA      | OBJECT_NAME | ENABLED | TIMED |
+-------------+--------------------+-------------+---------+-------+
| EVENT      | mysql              | %          | NO      | NO    |
| EVENT      | performance_schema | %          | NO      | NO    |
| EVENT      | information_schema | %          | NO      | NO    |
| EVENT      | %                  | %          | YES    | YES  |
| FUNCTION    | mysql              | %          | NO      | NO    |
| FUNCTION    | performance_schema | %          | NO      | NO    |
| FUNCTION    | information_schema | %          | NO      | NO    |
| FUNCTION    | %                  | %          | YES    | YES  |
| PROCEDURE  | mysql              | %          | NO      | NO    |
| PROCEDURE  | performance_schema | %          | NO      | NO    |
| PROCEDURE  | information_schema | %          | NO      | NO    |
| PROCEDURE  | %                  | %          | YES    | YES  |
| TABLE      | mysql              | %          | NO      | NO    |
| TABLE      | performance_schema | %          | NO      | NO    |
| TABLE      | information_schema | %          | NO      | NO    |
| TABLE      | %                  | %          | YES    | YES  |
| TRIGGER    | mysql              | %          | NO      | NO    |
| TRIGGER    | performance_schema | %          | NO      | NO    |
| TRIGGER    | information_schema | %          | NO      | NO    |
| TRIGGER    | %                  | %          | YES    | YES  |
+-------------+--------------------+-------------+---------+-------+
```

对setup_objects表的修改会立即影响对象监控

在setup_objects中列出的监控对象类型，在进行匹配时，performance_schema基于OBJECT_SCHEMA和OBJECT_NAME列依次往后匹配，如果没有匹配的对象则不会被监视

默认配置中开启监视的对象不包含mysql，INFORMATION_SCHEMA和performance_schema数据库中的所有表（从上面的信息中可以看到这几个库的enabled和timed字段都为NO，注意：对于INFORMATION_SCHEMA数据库，虽然该表中有一行配置，但是无论该表中如何设置，都不会监控该库，在setup_objects表中information_schema.%的配置行仅作为一个缺省值）

当performance_schema在setup_objects表中进行匹配检测时，会尝试首先找到最具体（最精确）的匹配项。例如，在匹配db1.t1表时，它会从setup_objects表中先查找“db1”和“t1”的匹配项，然后再查找“db1”和“％”，然后再查找“％”和“％”。匹配的顺序很重要，因为不同的匹配行可能具有不同的ENABLED和TIMED列值

如果用户对该表具有INSERT和DELETE权限，则可以对该表中的配置行进行删除和插入新的配置行。对于已经存在的配置行，如果用户对该表具有UPDATE权限，则可以修改ENABLED和TIMED列，有效值为：YES和NO

**setup_objects表列含义如下：**

- OBJECT_TYPE：instruments类型，有效值为：“EVENT”（事件调度器事件）、“FUNCTION”（存储函数）、“PROCEDURE”（存储过程）、“TABLE”（基表）、“TRIGGER”（触发器），TABLE对象类型的配置会影响表I/O事件（wait/io/table/sql/handler instrument）和表锁事件（wait/lock/table/sql/handler instrument）的收集
- OBJECT_SCHEMA：某个监视类型对象涵盖的数据库名称，一个字符串名称，或“％”(表示“任何数据库”)
- OBJECT_NAME：某个监视类型对象涵盖的表名，一个字符串名称，或“％”(表示“任何数据库内的对象”)
- ENABLED：是否开启对某个类型对象的监视功能，有效值为：YES或NO。此列可以修改
- TIMED：是否开启对某个类型对象的时间收集功能，有效值为：YES或NO，此列可以修改
- PS：对于setup_objects表，允许使用TRUNCATE TABLE语句

setup_objects配置表中默认的配置规则是不启用对mysql、INFORMATION_SCHEMA、performance_schema数据库下的对象进行监视的（ENABLED和TIMED列值全都为NO）

performance_schema在setup_objects表中进行查询匹配时，如果发现某个OBJECT_TYPE列值有多行，则会尝试着匹配更多的配置行，如下（performance_schema按照如下顺序进行检查）：

- OBJECT_SCHEMA ='literal' and OBJECT_NAME ='literal'
- OBJECT_SCHEMA ='literal' and OBJECT_NAME ='％'
- OBJECT_SCHEMA ='％' and OBJECT_NAME ='％'
- 例如，要匹配表对象db1.t1，performance_schema在setup_objects表中先查找“OBJECT_SCHEMA = db1”和“OBJECT_NAME = t1”的匹配项，然后查找“OBJECT_SCHEMA = db1”和“OBJECT_NAME =％”，然后查找“OBJECT_SCHEMA = ％”和“OBJECT_NAME = ％”。匹配顺序很重要，因为不同的匹配行中的ENABLED和TIMED列可以有不同的值，最终会选择一个最精确的匹配项

对于表对象相关事件，instruments是否生效需要看setup_objects与setup_instruments两个表中的配置内容相结合，以确定是否启用instruments以及计时器功能（例如前面说的I/O事件：wait/io/table/sql/handler instrument和表锁事件：wait/lock/table/sql/handler instrument，在setup_instruments配置表中也有明确的配置选项）：

- 只有在Setup_instruments和setup_objects中的ENABLED列都为YES时，表的instruments才会生成事件信息
- 只有在Setup_instruments和setup_objects中的TIMED列都为YES时，表的instruments才会启用计时器功能（收集时间信息） 
- 例如：要监视db1.t1、db1.t2、db2.%、db3.%这些表，setup_instruments和setup_objects两个表中有如下配置项

```
# setup_instruments表
admin@localhost : performance_schema 03:06:01> select * from setup_instruments where name like '%/table/%';
+-----------------------------+---------+-------+
| NAME                        | ENABLED | TIMED |
+-----------------------------+---------+-------+
| wait/io/table/sql/handler   | YES     | YES   |
| wait/lock/table/sql/handler | YES     | YES   |
+-----------------------------+---------+-------+
2 rows in set (0.00 sec)
# setup_objects表
+-------------+---------------+-------------+---------+-------+
| OBJECT_TYPE | OBJECT_SCHEMA | OBJECT_NAME | ENABLED | TIMED |
+-------------+---------------+-------------+---------+-------+
| TABLE       | db1           | t1          | YES     | YES   |
| TABLE       | db1           | t2          | NO      | NO    |
| TABLE       | db2           | %           | YES     | YES   |
| TABLE       | db3           | %           | NO      | NO    |
| TABLE       | %             | %           | YES     | YES   |
+-------------+---------------+-------------+---------+-------+
# 以上两个表中的配置项综合之后，只有db1.t1、db2.%、%.%的表对象的instruments会被启用，db1.t2和db3.%不会启用，因为这两个对象在setup_objects配置表中ENABLED和TIMED字段值为NO
```

对于存储程序对象相关的事件，performance_schema只需要从setup_objects表中读取配置项的ENABLED和TIMED列值。因为存储程序对象在setup_instruments表中没有对应的配置项

如果持久性表和临时表名称相同，则在setup_objects表中进行匹配时，针对这两种类型的表的匹配规则都同时生效（不会发生一个表启用监控，另外一个表不启用）

### (7)threads表

threads表对于每个server线程生成一行包含线程相关的信息，例如：显示是否启用监视，是否启用历史事件记录功能，如下：

```
admin@localhost : performance_schema 04:25:55> select * from threads where TYPE='FOREGROUND' limit 2\G;
*************************** 1. row ***************************
      THREAD_ID: 43
          NAME: thread/sql/compress_gtid_table
          TYPE: FOREGROUND
PROCESSLIST_ID: 1
PROCESSLIST_USER: NULL
PROCESSLIST_HOST: NULL
PROCESSLIST_DB: NULL
PROCESSLIST_COMMAND: Daemon
PROCESSLIST_TIME: 27439
PROCESSLIST_STATE: Suspending
PROCESSLIST_INFO: NULL
PARENT_THREAD_ID: 1
          ROLE: NULL
  INSTRUMENTED: YES
        HISTORY: YES
CONNECTION_TYPE: NULL
  THREAD_OS_ID: 3652
*************************** 2. row ***************************
............
2 rows in set (0.00 sec)
```

当performance_schema初始化时，它根据当时存在的线程每个线程生成一行信息记录在threads表中。此后，每新建一个线程在该表中就会新增一行对应线程的记录

新线程信息的INSTRUMENTED和HISTORY列值由setup_actors表中的配置决定。有关setup_actors表的详细信息参见3.3.5. 节

当某个线程结束时，会从threads表中删除对应行。对于与客户端会话关联的线程，当会话结束时会删除threads表中与客户端会话关联的线程配置信息行。如果客户端自动重新连接，则也相当于断开一次（会删除断开连接的配置行）再重新创建新的连接，两次连接创建的PROCESSLIST_ID值不同。新线程初始INSTRUMENTED和HISTORY值可能与断开之前的线程初始INSTRUMENTED和HISTORY值不同：setup_actors表在此期间可能已更改，并且如果一个线程在创建之后，后续再修改了setup_actors表中的INSTRUMENTED或HISTORY列值，那么后续修改的值不会影响到threads表中已经创建好的线程的INSTRUMENTED或HISTORY列值

PROCESSLIST_*开头的列提供与INFORMATION_SCHEMA.PROCESSLIST表或SHOW PROCESSLIST语句类似的信息。但threads表中与其他两个信息来源有所不同：

- 对threads表的访问不需要互斥体，对server性能影响最小。 而使用INFORMATION_SCHEMA.PROCESSLIST和SHOW PROCESSLIST查询线程信息的方式会损耗一定性能，因为他们需要互斥体
- threads表为每个线程提供附加信息，例如：它是前台还是后台线程，以及与线程相关联的server内部信息
- threads表提供有关后台线程的信息，而INFORMATION_SCHEMA.PROCESSLIST和SHOW PROCESSLIST不能提供
- 可以通过threads表中的INSTRUMENTED字段灵活地动态开关某个线程的监视功能、HISTORY字段灵活地动态开关某个线程的历史事件日志记录功能。要控制新的前台线程的初始INSTRUMENTED和HISTORY列值，通过setup_actors表的HOST、 USER对某个主机、用户进行配置。要控制已创建线程的采集和历史事件记录功能，通过threads表的INSTRUMENTED和HISTORY列进行设置
- 对于INFORMATION_SCHEMA.PROCESSLIST和SHOW PROCESSLIST，需要有PROCESS权限，对于threads表只要有SELECT权限就可以查看所有用户的线程信息

**threads表字段含义如下：**

- THREAD_ID：线程的唯一标识符（ID）

- NAME：与server中的线程检测代码相关联的名称(注意，这里不是instruments名称)。例如，thread/sql/one_connection对应于负责处理用户连接的代码中的线程函数名，thread/sql/main表示server的main（）函数名称

- TYPE：线程类型，有效值为：FOREGROUND、BACKGROUND。分别表示前台线程和后台线程，如果是用户创建的连接或者是复制线程创建的连接，则标记为前台线程（如：复制IO和SQL线程，worker线程，dump线程等），如果是server内部创建的线程（不能用户干预的线程），则标记为后台线程，如：innodb的后台IO线程等

- PROCESSLIST_ID：对应INFORMATION_SCHEMA.PROCESSLIST表中的ID列。该列值与show processlist语句、INFORMATION_SCHEMA.PROCESSLIST表、connection_id()函数返回的线程ID值相等。另外，threads表中记录了内部线程，而processlist表中没有记录内部线程，所以，对于内部线程，在threads表中的该字段显示为NULL，因此在threads表中NULL值不唯一（可能有多个后台线程）

- PROCESSLIST_USER：与前台线程相关联的用户名，对于后台线程为NULL。

- PROCESSLIST_HOST：与前台线程关联的客户端的主机名，对于后台线程为NULL。与INFORMATION_SCHEMA PROCESSLIST表的HOST列或SHOW PROCESSLIST输出的主机列不同，PROCESSLIST_HOST列不包括TCP/IP连接的端口号。要从performance_schema中获取端口信息，需要查询socket_instances表（关于socket的instruments wait/io/socket/sql/*默认关闭）：

- PROCESSLIST_DB：线程的默认数据库，如果没有，则为NULL。

- PROCESSLIST_COMMAND：对于前台线程，该值代表着当前客户端正在执行的command类型，如果是sleep则表示当前会话处于空闲状态。有关线程command的详细说明，参见链接：

  https://dev.mysql.com/doc/refman/5.7/en/thread-information.html。对于后台线程不会执行这些command，因此此列值可能为NULL

- PROCESSLIST_TIME：当前线程已处于当前线程状态的持续时间（秒）

- PROCESSLIST_STATE：表示线程正在做什么事情。有关PROCESSLIST_STATE值的说明，详见链接：

  https://dev.mysql.com/doc/refman/5.7/en/thread-information.html。如果列值为NULL，则该线程可能处于空闲状态或者是一个后台线程。大多数状态值停留的时间非常短暂。如果一个线程在某个状态下停留了非常长的时间，则表示可能有性能问题需要排查

- PROCESSLIST_INFO：线程正在执行的语句，如果没有执行任何语句，则为NULL。该语句可能是发送到server的语句，也可能是某个其他语句执行时内部调用的语句。例如：如果CALL语句执行存储程序，则在存储程序中正在执行SELECT语句，那么PROCESSLIST_INFO值将显示SELECT语句

- PARENT_THREAD_ID：如果这个线程是一个子线程（由另一个线程生成），那么该字段显示其父线程ID

- ROLE：暂未使用

- INSTRUMENTED： 
  * 线程执行的事件是否被检测。有效值：YES、NO 
  * 1)、对于前台线程，初始INSTRUMENTED值还需要看控制前台线程的setup_actors表中的INSTRUMENTED字段值。如果在setup_actors表中找到了对应的用户名和主机行，则会用该表中的INSTRUMENTED字段生成theads表中的INSTRUMENTED字段值，setup_actors表中的USER和HOST字段值也会一并写入到threads表的PROCESSLIST_USER和PROCESSLIST_HOST列。如果某个线程产生一个子线程，则子线程会再次与setup_actors表进行匹配 
  * 2)、对于后台线程，INSTRUMENTED默认为YES。 初始值无需查看setup_actors表，因为该表不控制后台线程，因为后台线程没有关联的用户 
  * 3)、对于任何线程，其INSTRUMENTED值可以在线程的生命周期内更改 
  * 要监视线程产生的事件，如下条件需满足： 
  * 1)、setup_consumers表中的thread_instrumentation consumers必须为YES 
  * 2)、threads.INSTRUMENTED列必须为YES 
  * 3)、setup_instruments表中线程相关的instruments配置行的ENABLED列必须为YES 
  * 4)、如果是前台线程，那么setup_actors中对应主机和用户的配置行中的INSTRUMENTED列必须为YES

- HISTORY： 
  * 是否记录线程的历史事件。有效值：YES、NO 
  * 1)、对于前台线程，初始HISTORY值还需要看控制前台线程的setup_actors表中的HISTORY字段值。如果在setup_actors表中找到了对应的用户名和主机行，则会用该表中的HISTORY字段生成theads表中的HISTORY字段值，setup_actors表中的USER和HOST字段值也会一并写入到threads表的PROCESSLIST_USER和PROCESSLIST_HOST列。如果某个线程产生一个子线程，则子线程会再次与setup_actors表进行匹配 
  * 2)、对于后台线程，HISTORY默认为YES。初始值无需查看setup_actors表，因为该表不控制后台线程，因为后台线程没有关联的用户 
  * 3)、对于任何线程，其HISTORY值可以在线程的生命周期内更改 
  * 要记录线程产生的历史事件，如下条件需满足： 
  * 1)、setup_consumers表中相关联的consumers配置必须启用，如：要记录线程的等待事件历史记录，需要启用events_waits_history和events_waits_history_long consumers 
  * 2)、threads.HISTORY列必须为YES 
  * 3)、setup_instruments表中相关联的instruments配置必须启用 
  * 4)、如果是前台线程，那么setup_actors中对应主机和用户的配置行中的HISTORY列必须为YES

- CONNECTION_TYPE：用于建立连接的协议，如果是后台线程则为NULL。有效值为：TCP/IP（不使用SSL建立的TCP/IP连接）、SSL/TLS（与SSL建立的TCP/IP连接）、Socket（Unix套接字文件连接）、Named Pipe（Windows命名管道连接）、Shared Memory(Windows共享内存连接）

- THREAD_OS_ID： 
  * 由操作系统层定义的线程或任务标识符（ID）： 
  * 1)、当一个MySQL线程与操作系统中与某个线程关联时，那么THREAD_OS_ID字段可以查看到与这个mysql线程相关联的操作系统线程ID 
  * 2)、当一个MySQL线程与操作系统线程不关联时，THREAD_OS_ID列值为NULL。例如：用户使用线程池插件时 
  * 对于Windows，THREAD_OS_ID对应于Process Explorer中可见的线程ID 
  * 对于Linux，THREAD_OS_ID对应于gettid（）函数获取的值。例如：使用perf或ps -L命令或proc文件系统（/proc/[pid]/task/[tid]）可以查看此值。

- PS：threads表不允许使用TRUNCATE TABLE语句

**关于线程类对象，前台线程与后台线程还有少许差别**

- 对于前台线程（由客户端连接产生的连接，可以是用户发起的连接，也可以是不同server之间发起的连接），当用户或者其他server与某个server创建了一个连接之后（连接方式可能是socket或者TCP/IP），在threads表中就会记录一条这个线程的配置信息行，此时，threads表中该线程的配置行中的INSTRUMENTED和HISTORY列值的默认值是YES还是NO，还需要看与线程相关联的用户帐户是否匹配setup_actors表中的配置行(查看某用户在setup_actors表中配置行的ENABLED和HISTORY列配置为YES还是NO，threads表中与setup_actors表关联用户帐号的线程配置行中的ENABLED和HISTORY列值以setup_actors表中的值为准)
- 对于后台线程，不可能存在关联的用户，所以threads表中的 INSTRUMENTED和HISTORY在线程创建时的初始配置列值默认值为YES，不需要查看setup_actors表

**关闭与开启所有后台线程的监控采集功能**

```
# 关闭所有后台线程的事件采集
root@localhost : performance_schema 05:46:17> update threads set INSTRUMENTED='NO' where TYPE='BACKGROUND';
Query OK, 40 rows affected (0.00 sec)
Rows matched: 40  Changed: 40  Warnings: 0
# 开启所有后台线程的事件采集
root@localhost : performance_schema 05:47:08> update threads set INSTRUMENTED='YES' where TYPE='BACKGROUND';
Query OK, 40 rows affected (0.00 sec)
Rows matched: 40  Changed: 40  Warnings: 0
```

**关闭与开启除了当前连接之外的所有线程的事件采集（不包括后台线程）**

```
# 关闭除了当前连接之外的所有前台线程的事件采集
root@localhost : performance_schema 05:47:44> update threads set INSTRUMENTED='NO' where PROCESSLIST_ID!=connection_id();
Query OK, 2 rows affected (0.00 sec)
Rows matched: 2  Changed: 2  Warnings: 0
# 开启除了当前连接之外的所有前台线程的事件采集
root@localhost : performance_schema 05:48:32> update threads set INSTRUMENTED='YES' where PROCESSLIST_ID!=connection_id();
Query OK, 2 rows affected (0.00 sec)
Rows matched: 2  Changed: 2  Warnings: 0
# 当然，如果要连后台线程一起操作，请带上条件PROCESSLIST_ID is NULL
update ... where PROCESSLIST_ID!=connection_id() or PROCESSLIST_ID is NULL;
```

------

## 本文小结

本篇内容到这里就接近尾声了，如果阅读了本章内容之后，感觉对performance_schema仍然比较迷糊，那么建议按照如下步骤动动手、看一看： 

- 使用命令行命令 mysqld --verbose --help |grep performance-schema |grep -v '--' |sed '1d' |sed '/[0-9]+/d'; 查看完整的启动选项列表 
- 登录到数据库中使用 show variables like '%performance_schema%';语句查看完整的system variables列表 
- 登录到数据库中使用 use performance_schema;语句切换到schema下，然后使用show tables;语句查看一下完整的table列表，并手工执行show create table tb_xxx;查看表结构，select * from xxx;查看表中的内容

performance_schema配置部分为整个performance_schema的难点，为了后续更好地学习performance_schema，建议初学者本章内容多读两遍。