# Oracle作业指导书-Oracle job/scheduler指导书

# 瀚高技术支持管理平台

## 1、介绍

Oracle
job有定时执行的功能，可以在指定的时间点或每天的某个时间点自行执行任务。在10G及更新的环境中，ORACLE明确建议使用Scheduler替换普通的job，来管理任务的执行。

参考<https://docs.oracle.com/en/database/oracle/oracle-
database/12.2/arpls/DBMS_JOB.html>

The DBMS_JOB package has been superseded by the DBMS_SCHEDULER package. In
particular, if you are administering jobs to manage system load, you should
consider disabling DBMS_JOB by revoking the package execution privilege for
users.

本文着重介绍对job和Scheduler的管理。为一些升级、OGG和HVR的部署等操作提供支持。

## 2、创建job

创建job语法：

DBMS_JOB.SUBMIT(

job OUT BINARY_INTEGER,

what IN VARCHAR2,

next_date IN DATE DEFAULT SYSDATE,

interval IN VARCHAR2 DEFAULT 'NULL',

no_parse IN BOOLEAN DEFAULT FALSE,

instance IN BINARY_INTEGER DEFAULT ANY_INSTANCE,

force IN BOOLEAN DEFAULT FALSE);

创建scheduler语法：

DBMS_SCHEDULER.CREATE_JOB (

job_name IN VARCHAR2,

job_type IN VARCHAR2,

job_action IN VARCHAR2,

number_of_arguments IN PLS_INTEGER DEFAULT 0,

start_date IN TIMESTAMP WITH TIME ZONE DEFAULT NULL,

repeat_interval IN VARCHAR2 DEFAULT NULL,

end_date IN TIMESTAMP WITH TIME ZONE DEFAULT NULL,

job_class IN VARCHAR2 DEFAULT 'DEFAULT_JOB_CLASS',

enabled IN BOOLEAN DEFAULT FALSE,

auto_drop IN BOOLEAN DEFAULT TRUE,

comments IN VARCHAR2 DEFAULT NULL,

credential_name IN VARCHAR2 DEFAULT NULL,

destination_name IN VARCHAR2 DEFAULT NULL);

## 3、查询运行的job

查询运行中job。

select * from dba_jobs_running;

查询运行中scheduler。

select * from dba_scheduler_running_jobs;

官方表示：

 **Stopping a Job**

Note that, once a job is started and running, there is no easy way to stop the
job.

停止运行的job可以直接通过kill session的方式进行。

## 3、禁用job

查询job。

select job,what,failures,broken from user_jobs;

禁用job

exec dbms_job.broken( _job_ ,true);

commit;

查询scheduler。

select job_name,job_type,state from user_scheduler_jobs;

禁用scheduler

exec dbms_scheduler.disable(' _job_name_ ');

Ø通过参数控制数据库全局的job和scheduler的启用和禁用。

JOB_QUEUE_PROCESSES初始化参数定义了可以为job创建的最大进程数。从Oracle数据库11gR2开始，JOB_QUEUE_PROCESSES适用于DBMS_SCHEDULER。将此参数设置为0也将禁用DBMS_SCHEDULER作业。

12C中该参数仅能在CDB级别设置，job co-ordinator也只能在CDB级别使用。

禁用所有job运行。

alter system set JOB_QUEUE_PROCESSES=0;

注意：这将不会停止运行中的job和scheduler。

## 4、删除job

查询job。

select job,what,failures,broken from user_jobs;

删除job

exec dbms_job.remove( _job_ );

commit;

查询scheduler。

select job_name,job_type,state from user_scheduler_jobs;

删除scheduler

exec dbms_scheduler.drop_job(' _job_name_ ');

## 5、job日志的清理

查询scheduler日志。

select * from dba_scheduler_job_log;

或

select * from dba_scheduler_job_run_details;

删除scheduler日志

delete from dba_scheduler_job_run_details where owner=' _USERNAME_ ' and
job_name=' _XXX_ ';

commit;

## 6、参考文章

<https://docs.oracle.com/en/database/oracle/oracle-
database/12.2/admin/administering-oracle-scheduler.html>

<https://docs.oracle.com/en/database/oracle/oracle-
database/12.2/arpls/DBMS_JOB.html>

<https://docs.oracle.com/en/database/oracle/oracle-
database/12.2/arpls/DBMS_SCHEDULER.html>

<https://docs.oracle.com/en/database/oracle/oracle-
database/12.2/admin/support-for-DBMS_JOB.html>

Measure

Measure



---
### TAGS
{Support20180830}

---
### NOTE ATTRIBUTES
>Created Date: 2018-08-30 01:35:47  
>Last Evernote Update Date: 2018-10-01 15:33:59  
>source: web.clip7  
>source-url: https://47.100.29.40/highgo_admin/#/index/docSearchDetail/d6041104694a85  
>source-application: WebClipper 7  