> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 https://blog.csdn.net/newhappy2008/article/details/2313237 <link rel="stylesheet" href="https://csdnimg.cn/release/phoenix/template/css/ck_htmledit_views-d7e2a68c7c.css">

SQL_TRACE 是 Oracle 提供的用于进行 SQL 跟踪的手段，是强有力的辅助诊断工具. 在日常的数据库问题诊断和解决中，SQL_TRACE 是非常常用的方法。
本文就 SQL_TRACE 的使用作简单探讨，并通过具体案例对 sql_trace 的使用进行说明.

一、 基础介绍

(a) SQL_TRACE 说明

SQL_TRACE 可以作为初始化参数在全局启用，也可以通过命令行方式在具体 session 启用。
**1． 在全局启用**
在参数文件 (pfile/spfile) 中指定:

| 

<pre>sql_trace =true</pre>

 |

在全局启用 SQL_TRACE 会导致所有进程的活动被跟踪，包括后台进程及所有用户进程，这通常会导致比较严重的性能问题，所以在生产环境
中要谨慎使用.
提示: 通过在全局启用 sql_trace，我们可以跟踪到所有后台进程的活动，很多在文档中的抽象说明，通过跟踪文件的实时变化，我们可以清晰
的看到各个进程之间的紧密协调.

**2． 在当前 session 级设置**
大多数时候我们使用 sql_trace 跟踪当前进程. 通过跟踪当前进程可以发现当前操作的后台数据库递归活动 (这在研究数据库新特性时尤其有效)，
研究 SQL 执行，发现后台错误等.
在 session 级启用和停止 sql_trace 方式如下:

| 

<pre>启用当前session的跟踪:
SQL> alter session set sql_trace=true;

Session altered.

此时的SQL操作将被跟踪:
SQL> select count(*) from dba_users;

  COUNT(*)
----------
        34
结束跟踪:
SQL> alter session set sql_trace=false;

Session altered.
       </pre>

 |

**3． 跟踪其他用户进程**
在很多时候我们需要跟踪其他用户的进程，而不是当前用户，这可以通过 Oracle 提供的系统包 DBMS_SYSTEM. SET_SQL_TRACE_IN_SESSION
来完成

SET_SQL_TRACE_IN_SESSION 过程序要提供三个参数:

| 

<pre>SQL> desc dbms_system
…
PROCEDURE SET_SQL_TRACE_IN_SESSION
 Argument Name                     Type                    In/Out Default?
 ------------------------------           -----------------------   ------ --------
 SID                               NUMBER                  IN
 SERIAL#                          NUMBER                  IN
 SQL_TRACE                        BOOLEAN                 IN
…</pre>

 |

通过 v$session 我们可以获得 sid、serial# 等信息:

| 

<pre>获得进程信息，选择需要跟踪的进程:

SQL> select sid,serial#,username from v$session
  2  where username is not null;

       SID    SERIAL#  USERNAME
---------- ---------- ------------------------------
         8       2041  SYS
         9        437  EYGLE

设置跟着:
SQL> exec dbms_system.set_sql_trace_in_session(9,437,true)

PL/SQL procedure successfully completed.

….
可以等候片刻，跟踪session执行任务,捕获sql操作…
….

停止跟踪:
SQL> exec dbms_system.set_sql_trace_in_session(9,437,false)

PL/SQL procedure successfully completed.
      </pre>

 |

**(b) 10046 事件说明**
10046 事件是 Oracle 提供的内部事件，是对 SQL_TRACE 的增强.
10046 事件可以设置以下四个级别:
1 - 启用标准的 SQL_TRACE 功能, 等价于 sql_trace
4 - Level 1 加上绑定值 (bind values)
8 - Level 1 + 等待事件跟踪
12 - Level 1 + Level 4 + Level 8
类似 sql_trace，10046 事件可以在全局设置，也可以在 session 级设置。
**1． 在全局设置**
在参数文件中增加:

| 

event="10046 trace name context forever,level 12"

 |

此设置对所有用户的所有进程生效、包括后台进程.

**2． 对当前 session 设置**
通过 alter session 的方式修改，需要 alter session 的系统权限:

| 

<pre>SQL> alter session set events '10046 trace name context forever';

Session altered.

SQL> alter session set events '10046 trace name context forever, level 8';

Session altered.

SQL> alter session set events '10046 trace name context off';

Session altered.

      </pre>

 |

**3． 对其他用户 session 设置**
通过 DBMS_SYSTEM.SET_EV 系统包来实现:

| 

<pre>SQL> desc dbms_system
...
PROCEDURE SET_EV
 Argument Name                  Type                    In/Out Default?
 ------------------------------ ----------------------- ------ --------
 SI                             BINARY_INTEGER          IN
 SE                             BINARY_INTEGER          IN
 EV                             BINARY_INTEGER          IN
 LE                             BINARY_INTEGER          IN
 NM                             VARCHAR2                IN

...

                      </pre>

 |

其中的参数 SI、SE 来自 v$session 视图:

| 

SID SERIAL# USERNAME
---------- ---------- ------------------------------
8 2041 SYS
9 437 EYGLE

执行跟踪:
SQL> exec dbms_system.set_ev(9,437,10046,8,'eygle');

PL/SQL procedure successfully completed.

结束跟踪:
SQL> exec dbms_system.set_ev(9,437,10046,0,'eygle');

PL/SQL procedure successfully completed.

 |

**(c) 获取跟踪文件**
以上生成的跟踪文件位于 user_dump_dest 目录中，位置及文件名可以通过以下 SQL 查询获得:

| 

TRACE_FILE_NAME
--------------------------------------------------------------------------------
/opt/oracle/admin/hsjf/udump/hsjf_ora_1026.trc

 |

**(d) 读取当前 session 设置的参数**
当我们通过 alter session 的方式设置了 sql_trace, 这个设置是不能通过 show parameter 的方式得到的, 我们需要通过 dbms_system.read_ev 来获取：

| 

SQL> declare
2 event_level number;
3 begin
4 for event_number in 10000..10999 loop
5 sys.dbms_system.read_ev(event_number, event_level);
6 if (event_level> 0) then
7 sys.dbms_output.put_line(
8 'Event' ||
9 to_char(event_number) ||
10 'is set at level' ||
11 to_char(event_level)
12 );
13 end if;
14 end loop;
15 end;
16 /
Event 10046 is set at level 1

 |