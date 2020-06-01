# Oracle问题处理指导

## 一、指导思想

### 1.1 搞明白问题

会问问题、会反馈问题、有效沟通

**忌猜**

​		时（时间）空（地点 服务器）史（症状）论（问题）

常用术语、指标

### 1.2 信息收集

操作日志、常用指标、状态/配置查看、日志、监控工具/软件

**故障范围判定**

硬件/OS/软件/应用/架构

故障类型分类：故障类，性能类，监控类

CPU、内存、网络、IO、文件系统

### 1.3 需求、目的

- 需求--模块/功能

- 分层、劳动分工、线性扩展

  闻道有先后、术业有专攻，让合适的人干合适的自己事

  **分层**：应用层、服务层、数据层

### 1.4 客观原则

- 尊重客观事实

- 万物皆文件

- 处处皆缓存

  - 硬件缓存：CPU一级、二级缓存，内存、SWAP、硬盘缓存、存储缓存
  
  - 软件缓存：MongoDB、Redis、Memcached
  - CDN加速

- 一个事务所作的修改对其他事务是不可见的，好似是串行执行的；
- 大型网站架构演化历程 https://www.hollischuang.com/archives/728
- 对比/对照 

## 二、“三板斧”之Oracle报告

“三板斧”之Oracle报告主要用于发现，诊断Oracle性能类问题;针对整体性能问题进行分析，诊断。

### 2.1 AWR、ASH、ADDM、AWRSQRPT

#### 1.  生成脚本

```plsql
脚本目录 $ORACLE_HOME/rdbms/admin
@?/rdbms/admin/addmrpt.sql
@?/rdbms/admin/awrrpt.sql
@?/rdbms/admin/ashrpt.sql
@?/rdbms/admin/awrsqrpt.sql
```

#### 2.  快照、基线

```plsql
-- 查看快照保留期限，11g默认为8天
 SELECT retention FROM dba_hist_wr_control;
 -- 修改快照时间间隔
 EXEC DBMS_WORKLOAD_REPOSITORY.MODIFY_SNAPSHOT_SETTINGS( interval => 30);
 -- 手动生成快照
 EXEC DBMS_WORKLOAD_REPOSITORY.CREATE_SNAPSHOT('TYPICAL');
 或
 BEGIN 
 DBMS_WORKLOAD_REPOSITORY.create_snapshot(); 
 END; 
 /
```

#### 3. AWR查看

![image-20200526142520695](Oracle%E6%95%85%E9%9A%9C%E5%A4%84%E7%90%86%E6%8C%87%E5%AF%BC.assets/image-20200526142520695.png)

![image-20200526142815169](Oracle%E6%95%85%E9%9A%9C%E5%A4%84%E7%90%86%E6%8C%87%E5%AF%BC.assets/image-20200526142815169.png)

![image-20200526142913624](Oracle%E6%95%85%E9%9A%9C%E5%A4%84%E7%90%86%E6%8C%87%E5%AF%BC.assets/image-20200526142913624.png)

![image-20200522161456216](Oracle%E6%95%85%E9%9A%9C%E5%A4%84%E7%90%86%E6%8C%87%E5%AF%BC.assets/image-20200522161456216.png)

![image-20200522161650278](Oracle%E6%95%85%E9%9A%9C%E5%A4%84%E7%90%86%E6%8C%87%E5%AF%BC.assets/image-20200522161650278.png)

![image-20200522161720659](Oracle%E6%95%85%E9%9A%9C%E5%A4%84%E7%90%86%E6%8C%87%E5%AF%BC.assets/image-20200522161720659.png)

![image-20200522161600842](Oracle%E6%95%85%E9%9A%9C%E5%A4%84%E7%90%86%E6%8C%87%E5%AF%BC.assets/image-20200522161600842.png)


#### 4. ADDM/ASH

![image-20200526142209989](Oracle%E6%95%85%E9%9A%9C%E5%A4%84%E7%90%86%E6%8C%87%E5%AF%BC.assets/image-20200526142209989.png)

![image-20200526142358210](Oracle%E6%95%85%E9%9A%9C%E5%A4%84%E7%90%86%E6%8C%87%E5%AF%BC.assets/image-20200526142358210.png)

### 2.2 MOS/Google

​		搜索等待事件,关键字,错误代码

## 三、“三板斧”之日志

“三板斧”之日志主要用于发现，诊断Oracle维护类问题

### 3.1 数据库日志、OS日志

```plsql
-- Oracle日志
select * from v$diag_info;

-- OS日志收集(/var/log)
sosreport
sosreport -a --report

supportconfig 
//以最小选项搜集所需的信息
# supportconfig -m
//在输出中包含附加的联系人信息
# supportconfig -E tux@example.org -N "Tux Penguin" -O "Penguin Inc." ...
//要查看完整的功能列表
# supportconfig -F
//仅收集某个模块的用法，如LVM相的信息
# supportconfig -i LVM
//-x 的功能与-i刚好相反，是排除某个模块不收集
# supportconfig -x LVM
//使用-U url 可以将收集的结果上传到服务器上，直接的服务有ftp, scp, http, https,如：
# supportconfig -A -U http://www.361way.com/files/
```
**Oracle日志**

```sh
# ASM日志：
 $ORACLE_BASE/diag/asm/+ASMX/trace/alert_+ASMX.log
# CRS日志：
 $ORACLE_HOME/log/主机名/alert主机名.logexit
# Oracle日志
 $ORACLE_BASE/diag/rdbms/数据库名/主机名/trace/alert_acrosspm1.log
 
 # Find日志
find / -name "*listener*.log*" | xargs du -m
find / -name "alert*.log*" | xargs du -m
```

![image-20200518153733617](Oracle%E6%95%85%E9%9A%9C%E5%A4%84%E7%90%86%E6%8C%87%E5%AF%BC.assets/image-20200518153733617.png)

### 3.2 nmon/osw/TFA

![image-20200526095452831](Oracle%E6%95%85%E9%9A%9C%E5%A4%84%E7%90%86%E6%8C%87%E5%AF%BC.assets/image-20200526095452831.png)

![image-20200526153417651](Oracle%E6%95%85%E9%9A%9C%E5%A4%84%E7%90%86%E6%8C%87%E5%AF%BC.assets/image-20200526153417651.png)

### 3.3 资料搜索

> 1. 官方文档/MOS
>
>    https://docs.oracle.com/en/
>
>    https://support.oracle.com/portal/
>
> 2. 指导手册
>
> 3. 谷歌百度

<img src="Oracle%E6%95%85%E9%9A%9C%E5%A4%84%E7%90%86%E6%8C%87%E5%AF%BC.assets/image-20200526094101995.png" alt="image-20200526094101995" style="zoom:150%;" />

![image-20200526094441399](Oracle%E6%95%85%E9%9A%9C%E5%A4%84%E7%90%86%E6%8C%87%E5%AF%BC.assets/image-20200526094441399.png)

## 四、 “三板斧”之SQLDeveoper

### 4.1 SQL Developer

**实时SQL监控**

![image-20200526141839370](Oracle%E6%95%85%E9%9A%9C%E5%A4%84%E7%90%86%E6%8C%87%E5%AF%BC.assets/image-20200526141839370.png)

**监视回话**

![image-20200526142037236](Oracle%E6%95%85%E9%9A%9C%E5%A4%84%E7%90%86%E6%8C%87%E5%AF%BC.assets/image-20200526142037236.png)

![image-20200526143051663](Oracle%E6%95%85%E9%9A%9C%E5%A4%84%E7%90%86%E6%8C%87%E5%AF%BC.assets/image-20200526143051663.png)

**实例查看器**

![image-20200526143201056](Oracle%E6%95%85%E9%9A%9C%E5%A4%84%E7%90%86%E6%8C%87%E5%AF%BC.assets/image-20200526143201056.png)

**SQL优化**

![image-20200526143424237](Oracle%E6%95%85%E9%9A%9C%E5%A4%84%E7%90%86%E6%8C%87%E5%AF%BC.assets/image-20200526143424237.png)

![image-20200526143546531](Oracle%E6%95%85%E9%9A%9C%E5%A4%84%E7%90%86%E6%8C%87%E5%AF%BC.assets/image-20200526143546531.png)

![image-20200526143641311](Oracle%E6%95%85%E9%9A%9C%E5%A4%84%E7%90%86%E6%8C%87%E5%AF%BC.assets/image-20200526143641311.png)

![image-20200526143906951](Oracle%E6%95%85%E9%9A%9C%E5%A4%84%E7%90%86%E6%8C%87%E5%AF%BC.assets/image-20200526143906951.png)

### 4.2 动态性能视图

```plsql
-- 基表
select * from v$fixed_table;
-- 动态性能视图定义
select * from v$fixed_view_definition;
-- 数据字典
select * from dba_views;
select * from dict where table_name like 'DBA_HIST_%';

--按组分的几组重要的性能视图
1.System的overview
v$sysstat,v$system_event,v$parameter
2.某个session 的当前情况
v$process,v$session,v$session_wait,v$session_event,v$sesstat
3.SQL 的情况
v$sql,v$sqlarea,v$SQL_PLAN,V$SQL_PLAN_STATISTICS,v$sqltext_with_newlines
4.Latch/lock/ENQUEUE
v$latch,v$latch_children,v$latch_holder,v$lock,V$ENQUEUE_STAT,V$ENQUEUE_LOCK,v$locked_object
5.IO 方面的
v$segstat,v$filestat,v$tempstat,v$datafile,v$tempfile
6.shared pool/Library cache
v$Librarycache,v$rowcache,x$ksmsp
7.advice也不错
v$db_cache_advice,v$PGA_TARGET_ADVICE,v$SHARED_POOL_ADVICE
```

## 五、问题处理总结

![1566868028969](Oracle故障处理指导.assets/1566868028969.png)