# 如何生成 AWR 报告和 AWR 基线 (文档 ID 2331572.1)

  

|

|

 **文档内容**  

| | [目标](https://support.oracle.com/epmos/faces/DocumentDisplay?_adf.ctrl-
state=p6khmztw8_589&id=2331572.1&_afrLoop=444880964378342#GOAL)  
---|---  
| [解决方案](https://support.oracle.com/epmos/faces/DocumentDisplay?_adf.ctrl-
state=p6khmztw8_589&id=2331572.1&_afrLoop=444880964378342#FIX)  
---|---  
| [生成一个最基本的 AWR
报告](https://support.oracle.com/epmos/faces/DocumentDisplay?_adf.ctrl-
state=p6khmztw8_589&id=2331572.1&_afrLoop=444880964378342#aref_section21)  
---|---  
| [生成多种类型的 AWR
报告](https://support.oracle.com/epmos/faces/DocumentDisplay?_adf.ctrl-
state=p6khmztw8_589&id=2331572.1&_afrLoop=444880964378342#aref_section22)  
---|---  
| [AWR 快照](https://support.oracle.com/epmos/faces/DocumentDisplay?_adf.ctrl-
state=p6khmztw8_589&id=2331572.1&_afrLoop=444880964378342#aref_section23)  
---|---  
| [如何修改 AWR
快照的设置：](https://support.oracle.com/epmos/faces/DocumentDisplay?_adf.ctrl-
state=p6khmztw8_589&id=2331572.1&_afrLoop=444880964378342#aref_section24)  
---|---  
| [手工创建一个 AWR
快照：](https://support.oracle.com/epmos/faces/DocumentDisplay?_adf.ctrl-
state=p6khmztw8_589&id=2331572.1&_afrLoop=444880964378342#aref_section25)  
---|---  
| [按照范围删除 AWR
快照：](https://support.oracle.com/epmos/faces/DocumentDisplay?_adf.ctrl-
state=p6khmztw8_589&id=2331572.1&_afrLoop=444880964378342#aref_section26)  
---|---  
| [AWR 基线](https://support.oracle.com/epmos/faces/DocumentDisplay?_adf.ctrl-
state=p6khmztw8_589&id=2331572.1&_afrLoop=444880964378342#aref_section27)  
---|---  
| [生成 AWR
基线：](https://support.oracle.com/epmos/faces/DocumentDisplay?_adf.ctrl-
state=p6khmztw8_589&id=2331572.1&_afrLoop=444880964378342#aref_section28)  
---|---  
| [删除 AWR
基线：](https://support.oracle.com/epmos/faces/DocumentDisplay?_adf.ctrl-
state=p6khmztw8_589&id=2331572.1&_afrLoop=444880964378342#aref_section29)  
---|---  
| [我们也可以基于重复时间周期来制定用于创建和删除 AWR
基线的模板：](https://support.oracle.com/epmos/faces/DocumentDisplay?_adf.ctrl-
state=p6khmztw8_589&id=2331572.1&_afrLoop=444880964378342#aref_section210)  
---|---  
| [AWR
相关的视图](https://support.oracle.com/epmos/faces/DocumentDisplay?_adf.ctrl-
state=p6khmztw8_589&id=2331572.1&_afrLoop=444880964378342#aref_section211)  
---|---  
| [自动创建 AWR
报告?](https://support.oracle.com/epmos/faces/DocumentDisplay?_adf.ctrl-
state=p6khmztw8_589&id=2331572.1&_afrLoop=444880964378342#aref_section212)  
---|---  
| [使用 AWR 需要的
License](https://support.oracle.com/epmos/faces/DocumentDisplay?_adf.ctrl-
state=p6khmztw8_589&id=2331572.1&_afrLoop=444880964378342#aref_section213)  
---|---  
| [参考](https://support.oracle.com/epmos/faces/DocumentDisplay?_adf.ctrl-
state=p6khmztw8_589&id=2331572.1&_afrLoop=444880964378342#REF)  
---|---  
  
* * *

## 适用于:

Oracle Database - Enterprise Edition - 版本 10.1.0.2 和更高版本  
Oracle Net Services - 版本 10.2.0.5 到 10.2.0.5 [发行版 10.2]  
本文档所含信息适用于所有平台  

## 目标

本文概括了如何通过 DBMS_WORKLOAD_REPOSITORY 提供的脚本和功能来创建AWR报告和基线。本文介绍了如何生成各种类型的 AWR
报告和手工创建 AWR 快照，也介绍了一些关于 AWR 基线的内容。

## 解决方案

AWR 是被 sys 用户拥有的一个存放系统性能指标的集合。  
它存放于 SYSAUX 表空间. 默认情况下每60分钟产生一个 AWR 快照并且保留8天, 这样能确保捕获一周的性能指标数据（注意在 10g
中保留期是7天）。  
  
AWR 报告输出一系列指标在两个快照之间的差值，用于研究数据库性能以及其他问题。

### 生成一个最基本的 AWR 报告

如果您拥有了相应的 AWR License 授权，那么您可以通过如下脚本来选择两个您想采用的快照，生成一个 AWR 报告：

$ORACLE_HOME/rdbms/admin/awrrpt.sql

  
基于不同的原因，通常可以采用默认的设置来产生 AWR 快照，但如果需要更精确的报告，那么可能需要采用更短的比如10-15分钟的快照。  
  
在生成 AWR 报告的过程中，会要求提供产生的 AWR 报告格式（text 或者 html）以及报告的名称。

### 生成多种类型的 AWR 报告

可以通过不同脚本来产生不同类型的 AWR 用于满足不同的需求，所有的 AWR 报告都可以是 HTML 或者 TXT 格式：

  * **awrrpt.sql**  
展示一段时间范围两个快照之间的数据库性能指标。

  * **awrrpti.sql**  
展示一段时间范围两个快照之间的特定数据库和特定实例的性能指标。

  * **awrsqrpt.sql**  
展示特定 SQL 在一段时间范围两个快照之间的性能指标，运行这个脚本来检查和诊断一个特定 SQL 的性能问题。

  * **awrsqrpi.sql**   
展示特定 SQL 在特定数据库和特定实例的一段时间范围内两个快照之间的性能指标。

  * **awrddrpt.sql**  
用于比较两个指定的时间段之间数据库详细性能指标和配置情况。

  * **awrddrpi.sql**  
用于在特定的数据库和特定实例上，比较两个指定的时间段之间的数据库详细性能指标和配置情况。

### AWR 快照

#### 如何修改 AWR 快照的设置：

BEGIN  
DBMS_WORKLOAD_REPOSITORY.modify_snapshot_settings(  
retention => 43200, -- 单位是分钟 (43200 = 30 Days)。  
\-- 设置成 NULL 代表保持原来设置。  
interval => 30); -- 单位是分钟, 设置成 NULL 代表保持原来设置。  
END;  
/

#### 手工创建一个 AWR 快照：

BEGIN  
DBMS_WORKLOAD_REPOSITORY.create_snapshot();  
END;  
/

#### 按照范围删除 AWR 快照：

BEGIN  
DBMS_WORKLOAD_REPOSITORY.drop_snapshot_range(  
low_snap_id=>40,  
High_snap_id=>80);  
END;  
/

### AWR 基线

#### 生成 AWR 基线：

BEGIN  
DBMS_WORKLOAD_REPOSITORY.create_baseline (  
start_snap_id => 10,  
end_snap_id => 100,  
baseline_name => 'AWR First baseline');  
END;  
/

  
  

_**注意：**_ 在 11g 中引入了一个新的存储过程 DBMS_WORKLOAD_REPOSITORY.CREATE_BASELINE_TEMPLATE
可以制定一个模板来管理在未来时间怎样创建 AWR 基线：

BEGIN  
DBMS_WORKLOAD_REPOSITORY.CREATE_BASELINE_TEMPLATE (  
start_time => to_date('&start_date_time','&start_date_time_format'),  
end_time => to_date('&end_date_time','&end_date_time_format'),  
baseline_name => 'MORNING',  
template_name => 'MORNING',  
expiration => NULL ) ;  
END;  
/

  
"expiration => NULL" 代表这个基线将被永远保留。

#### 删除 AWR 基线：

BEGIN  
DBMS_WORKLOAD_REPOSITORY.DROP_BASELINE (baseline_name => 'AWR First
baseline');  
END;  
/

  
您也可以删除一个在其他数据库或者旧数据库中创建的 AWR 基线：

  
BEGIN  
DBMS_WORKLOAD_REPOSITORY.DROP_BASELINE (baseline_name => 'peak
baseline',cascade => FALSE, dbid => 3310949047);  
END;  
/

#### 我们也可以基于重复时间周期来制定用于创建和删除 AWR 基线的模板：

BEGIN  
DBMS_WORKLOAD_REPOSITORY.CREATE_BASELINE_TEMPLATE (  
day_of_week => 'MONDAY',  
hour_in_day => 9,  
duration => 3,  
start_time => to_date('&start_date_time','&start_date_time_format'),  
end_time => to_date('&end_date_time','&end_date_time_format'),  
baseline_name_prefix => 'MONDAY_MORNING'  
template_name => 'MONDAY_MORNING',  
expiration => 30 );  
END;  
/[Insert code here]

  
这样会在指定的时间'&start_date_time' 到 '&end_date_time'期间的每个周一产生一个 AWR 基线

### AWR 相关的视图

如下系统视图与 AWR 相关：

  * V$ACTIVE_SESSION_HISTORY - 展示每秒采样的 active session history (ASH)。
  * V$METRIC - 展示度量信息。
  * V$METRICNAME - 展示每个度量组的度量信息。
  * V$METRIC_HISTORY - 展示历史度量信息。
  * V$METRICGROUP - 展示所有的度量组。
  * DBA_HIST_ACTIVE_SESS_HISTORY - 展示 active session history 的历史信息。
  * DBA_HIST_BASELINE - 展示 AWR 基线信息。
  * DBA_HIST_DATABASE_INSTANCE - 展示数据库环境信息。
  * DBA_HIST_SNAPSHOT - 展示 AWR 快照信息。
  * DBA_HIST_SQL_PLAN - 展示 SQL 执行计划信息。
  * DBA_HIST_WR_CONTROL - 展示 AWR 设置信息。

### 自动创建 AWR 报告?

Oracle 没有提供自动产生 AWR 报告的功能，AWR 报告的生成是一个手工过程，但是可以通过调度（比如 UNIX 的 crontab）在脚本（比如一些
UNIX 的 bash 脚本）中调用 dbms_workload_repository.awr_report_text
并且传入awr_report_text 的参数来实现自动产生 AWR 报告的目的。可以在互联网上找到这些脚本，但是 Oracle
官方并没有作为产品的一部分来提供这样的脚本。

### 使用 AWR 需要的 License

请注意使用 AWR 需要特定的 License，如果没有 AWR License，可以使用 statspack，参见：

[Document
1490798.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=2331572.1&id=1490798.1)
AWR Reporting - Licensing Requirements Clarification

## 参考

[NOTE:1490798.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=2331572.1&id=1490798.1)
\- AWR Reporting - Licensing Requirements Clarification  
[NOTE:1363422.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=2331572.1&id=1363422.1)
\- Automatic Workload Repository (AWR) Reports - Main Information Sources  
  
  
  



---
### TAGS
{AWR}

---
### NOTE ATTRIBUTES
>Created Date: 2018-01-18 09:29:36  
>Last Evernote Update Date: 2018-10-01 15:59:04  
>author: YangKwong  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_adf.ctrl-state=p6khmztw8_589  
>source-url: &  
>source-url: id=2331572.1  
>source-url: &  
>source-url: _afrLoop=444880964378342  