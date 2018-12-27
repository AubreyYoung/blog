# Oracle并行

并行执行的本质就是==以额外的硬件资源消耗来换取执行时间的缩短==。

并行处理的机制实际上就是把一个要扫描的数据集分成很多小数据集，Oracle 会启动几个并行服务进程同时处理这些小数据集，最后将这些结果汇总，作为最终的处理结果返回给用户。

并行执行并不一定会缩短执行时间，它并不适合所有的场景。

**开启并行的注意事项**：并行需额外的CPU、内存、IO资源开销！

## 1. 并行的种类
1. 并行查询
    使用多个操作系统进程/线程执行一个查询。优化器会创建新的执行计划来处理语句。

```
select /* serial_execution_demo_1 */ from t1;
select /* parallel_execution_demo_1 */count(*) from t1;

select /* serial_execution_demo_1 */t1.owner,t1.object_name,t2.status from t1, t2 where t1.object_id=t2.object_id and t1.owner='SCOTT';
select /* parallel_execution_demo_1 */t1.owner,t1.object_name,t2.status from t1, t2 where t1.object_id=t2.object_id and t1.owner='SCOTT';
```

2. 并行DML
   并行处理INSERT、DELETE、UPDATE和MERGE操作；
   如果DML找那个包括查询（类似insert into table select）类操作，也可以并行处理。

```
update /* parallel(t1) */t1 set object_name='SCOTT';
```
注：仅仅修改表的并行读和仅使用并行Hint，都不能真正并行执行DML。

3. 并行DDL
   并行执行DDL类操作：如索引重建、数据加载、大表重组等

```
create index idx_t3 on t3(object_name,object_id,data_object_id) parallel;
```

4. 其他
   如数据加载、统计信息收集、事务回滚、数据库备份恢复、数据导入导出等

```
sqlldr USERID=scott/tiger CONTROL=load1.ctl DIRECT=TRUE PARALLEL=true

//rman参数parallelism
configure device type disk parallelism 3;

//并行实例恢复参数
SQL> show parameter recovery_parallelism
NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
recovery_parallelism                 integer     0

//并行事务回滚
SQL> show parameter fast_start_parallel_rollback
NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
fast_start_parallel_rollback         string      LOW

//并行收集统计信息
exec dbms_stats.gather_table_stats(ownname=>'SCOTT',tabname=>'T1',CASCADE=>true,estimate=>100,degree=>4);
```

## 2. 并行的控制
​	在Oracle 11gR2 中，自动并行的开启受参数`parallel_degree_policy`的控制，其默认值为MANUAL,即自动并行在默认情况下并没有被开启。如果通过更改 `parallel_degree_policy`的值而开启了自动并行，那么后面所执行的SQL的执行方式是串行还是并行，以及并行执行的并行度是多少等，就都是有Oracle数据库自动来决定了。

### 2.1 数据库级

**数据库级启用并行**

```
设置 PARALLEL_MAX_SERVERS = N。

其中 N 是默认值，可以根据以下推荐的公式得出：
默认值 = PARALLEL_THREADS_PER_CPU * CPU_COUNT * concurrent_parallel_users * 5
```
> 在实例中，以默认并行度运行的 concurrent_parallel_users 的数量取决于实例的内存初始化参数设置。
>
> 例如，如果设置了 MEMORY_TARGET 或 SGA_TARGET 初始化参数，则 concurrent_parallel_users = 4。
>
> 如果未设置 MEMORY_TARGET 或 SGA_TARGET，则检查 PGA_AGGREGATE_TARGET。
>
> 如果为 PGA_AGGREGATE_TARGET 设置了值，则 concurrent_parallel_users = 2。
>
> 如果没有为 PGA_AGGREGATE_TARGET 设置值，则 concurrent_parallel_users = 1。

**要在数据库级别禁用并行**

```
PARALLEL_MIN_SERVERS = 0
PARALLEL_MAX_SERVERS = 0
```
### 2.2 会话级	

**在会话级别为 DML、DDL 和 QUERY 操作启用并行**

```plsql
ALTER SESSION ENABLE PARALLEL DML;

ALTER SESSION ENABLE PARALLEL DDL;

ALTER SESSION ENABLE PARALLEL QUERY;

//Degree 的值可以是 2,4,8 或者 16 等等...
ALTER SESSION FORCE PARALLEL [DML|DDL|QUERY] PARALLEL <DEGREE>; 

ALTER SESSION FORCE PARALLEL [DML|DDL|QUERY];
```
> ​	**仅仅在当前Session中强制开启并行查询是不能实现真正并行执行DML操作的，要想真正以并行的方式执行DML语句，要么使用 alter session force parallel dml，要么联合使用alter session enable parallel dml和加了并行Hint的DML语句。**



**在会话级别为 DML、DDL 和 QUERY 操作禁用并行**

```plsql
ALTER SESSION DISABLE PARALLEL DML;

ALTER SESSION DISABLE PARALLEL DDL;

ALTER SESSION DISABLE PARALLEL QUERY;
```
### 2.3 语句级

**Parallel Hint **可以像下面这样使用：

For a statement-level PARALLEL hint:

![Description of parallel_hint_statement.gif follows](https://docs.oracle.com/cd/E11882_01/server.112/e41084/img/parallel_hint_statement.gif)

- `PARALLEL`: The statement always is run parallel, and the database computes the degree of parallelism, which can be 2 or greater.
- `PARALLEL` (`DEFAULT`): The optimizer calculates a degree of parallelism equal to the number of CPUs available on all participating instances times the value of the `PARALLEL_THREADS_PER_CPU` initialization parameter.
- `PARALLEL` (`AUTO`): The database computes the degree of parallelism, which can be 1 or greater. If the computed degree of parallelism is 1, then the statement runs serially.
- `PARALLEL` (`MANUAL`): The optimizer is forced to use the parallel settings of the objects in the statement.
- `PARALLEL` (`integer`): The optimizer uses the degree of parallelism specified by `integer`.

```plsql
/*+ PARALLEL */ - 如果在对象级别没有设置 DOP，则会使用默认 DOP
SELECT /*+ PARALLEL */ last_name FROM employees;
SELECT /*+ PARALLEL (AUTO) */ last_name FROM employees;

CREATE TABLE parallel_table (col1 number, col2 VARCHAR2(10)) PARALLEL 5; 
SELECT /*+ PARALLEL (MANUAL) */ col2  FROM parallel_table;

(或者) /*+ PARALLEL(4) */

12c 中的新 Hint：ENABLE_PARALLEL_DML。这适用于 12c 或更高版本。
/*+ enable_parallel_dml parallel(x) */ -- （x）是可选的，其中 x 是所请求的并行度
例如：insert /*+ parallel(8) enable_parallel_dml */ into t1 select * from t1_1;

注意：Hint “enable_parallel_dml”可以在/*+ */分隔符中以任何顺序出现。
```
For an object-level PARALLEL hint:

![Description of parallel_hint_object.gif follows](https://docs.oracle.com/cd/E11882_01/server.112/e41084/img/parallel_hint_object.gif)

- `PARALLEL`: The query coordinator should examine the settings of the initialization parameters to determine the default degree of parallelism.
- `PARALLEL` (`integer`): The optimizer uses the degree of parallelism specified by `integer`.
- `PARALLEL` (`DEFAULT`): The optimizer calculates a degree of parallelism equal to the number of CPUs available on all participating instances times the value of the `PARALLEL_THREADS_PER_CPU` initialization parameter.

**PARALLEL Hint**

/*+ PARALLEL(table[,degree]) */

```plsql
/*+ PARALLEL(emp, 4) */
SELECT /*+ FULL(hr_emp) PARALLEL(hr_emp, 5) */ last_name FROM employees hr_emp;
SELECT /*+ FULL(hr_emp) PARALLEL(hr_emp, DEFAULT) */ last_name FROM employees hr_emp;
```
**PARALLEL_INDEX Hint**

/*+ PARALLEL_INDEX(table[,index[,degree]]) */

```plsql
SELECT /*+ PARALLEL_INDEX(table1, index1, 3) */
```

**NO_PARALLEL Hint 取消并行**

/*+ NO_PARALLEL(table) */

```plsql
ALTER TABLE employees PARALLEL 8;
SELECT /*+ NO_PARALLEL(hr_emp) */ last_name FROM employees hr_emp;
```
**NO_PARALLEL_INDEX Hint 取消并行**

/*+ NO_PARALLEL_INDEX(table[,index]) */

**指定表以out/in的方式传递数据**

out/in的值可以使HASH/NONE/BROADCAST/PARTITION的任意一种。

/* +PQ_DISTRIBUTE(table,out,in) */

```plsql
select /* +pq_distribute(t6,none,partition) ordered */t4.owner,t4.object_name,t6.status from scott.t4,scott.t6 where t4.region=t6.region and t4.object_id=t6.object_id and t4.owner='SCOTT';
```

***NOPARALLEL Hint|NOPARALLEL_INDEX***

> 在11.2中，
>
> NOPARALLEL Hint
>
> The `NOPARALLEL` hint has been deprecated. Use the `NO_PARALLEL` hint instead.
>
> NOPARALLEL_INDEX Hint
>
> The `NOPARALLEL_INDEX` hint has been deprecated. Use the `NO_PARALLEL_INDEX` hint instead.

### 2.4 对象级

**在对象级别启用并行**

```plsql
ALTER TABLE <TABLE_NAME> PARALLEL <n>;

ALTER INDEX <INDEX_NAME> PARALLEL <n>;
```
当在并行访问的多个对象的并行度不相等的情况下，一般来说Oracle会取其中最大的并行度来作为整个查询的并行度。

**禁用对象级别的并行**

```plsql
ALTER TABLE <TABLE_NAME> PARALLEL 1;

ALTER INDEX <INDEX_NAME> PARALLEL 1;

或
alter table <TABLE_NAME> NOPARALLEL;

alter INDEX <INDEX_NAME> NOPARALLEL;
```

## 3. 并行相关参数

​	因为Oracle可能会启用两组Query Slave Set，所以在实际并行执行时并行子进程的总数可能会是并行度的两倍。

![1545898767660](C:\Users\galaxy\AppData\Roaming\Typora\typora-user-images\1545898767660.png)

在Oracle 11gR2并行执行被开启的情况下:

- Oracle是否启动并行取决于目标SQL的预估执行时间是否小于参数`PARALLEL_MIN_TIME_THRESHOLD`的值。
- 在Oracle已决定采用并行的情况下，并行的实际并行度为Oracle根据并行执行计划计算出来的理想并行度和参数`PARALLEL_DEGREE_LIMIT`中的最小值，即 Actual DOP = min(Idel DOP,PARALLEL_DEGREE_LIMIT).

在Oracle 11gR2之前，Oracle使用的自适应并行。

- 所谓的自适应并行是指Oracle会根据当前系统的负载情况来决定目标SQL在并行执行时的实际并行度。

```
SQL> show parameter parallel_adaptive_multi_user

parallel_adaptive_multi_user         boolean     TRUE

```



### PARALLEL_DEGREE_POLICY

- `MANUAL`

  表示自动并行没有开启

- `LIMITED`

  表示自动并行被有限开启

  仅仅会将SQL语句中的表/索引的并行度，或没有指定具体并行度的并行hint 的并行度设置为默认值。

  在`PARALLEL_DEGREE_POLICY`为limited，同时指定具体并行度的并行hint 或指定SQL语句中的表/索引的并行度为具体值`PARALLEL_DEGREE_LIMIT`将不起作用。

- `AUTO`

  Enables automatic degree of parallelism, statement queuing, and in-memory parallel execution.

  在Oralce 11.2.0.2以上的版本里，除设置PARALLEL_DEGREE_POLICY为AUTO,还需使用`DBMS_RESOURCE_MANAGER.CALIBRATE`收集I/O Calibrate统计信息。

  ```
  SET SERVEROUTPUT ON
  DECLARE
    lat  INTEGER;
    iops INTEGER;
    mbps INTEGER;
  BEGIN
     DBMS_RESOURCE_MANAGER.CALIBRATE_IO (1, 10, iops, mbps, lat);
     DBMS_OUTPUT.PUT_LINE ('max_iops = ' || iops);
     DBMS_OUTPUT.PUT_LINE ('latency  = ' || lat);
     DBMS_OUTPUT.PUT_LINE ('max_mbps = ' || mbps);
  end;
  /
  ```

- `ADAPTIVE`

  This value enables automatic degree of parallelism, statement queuing and in-memory parallel execution, similar to the `AUTO` value. In addition, performance feedback is enabled. Performance feedback helps to improve the degree of parallelism automatically chosen for repeated SQL statements. After the initial execution of a statement, the degree of parallelism chosen by the optimizer is compared to the degree of parallelism computed based on the actual execution performance. If they vary significantly, then the statement is marked for re-parse and the initial execution performance statistics (for example, CPU-time) are provided as feedback for subsequent executions. The optimizer uses the initial execution performance statistics to better determine a degree of parallelism for subsequent executions.

### PARALLEL_MIN_SERVERS

在初始化参数中设置了这个值，Oracle 在启动的时候就会预先启动N个并行服务进程，当SQL执行并行操作时，并行协调进程首先根据并行度的值，在当前已经启动的并行服务中条用n个并行服务进程，当并行度大于n时，Oracle将启动额外的并行服务进程以满足并行度要求的并行服务进程数量。

###  PARALLEL_MAX_SERVERS

如果并行度的值大于parallel_min_servers或者当前可用的并行服务进程不能满足SQL的并行执行要求，Oracle将额外创建新的并行服务进程，当前实例总共启动的并行服务进程不能超过这个参数的设定值。

###  PARALLEL_ADAPTIVE_MULTI_USER
Oracle 10g R2下，并行执行默认是启用的。 这个参数的默认值为true，它让Oracle根据SQL执行时系统的负载情况，动态地调整SQL的并行度，以取得最好的SQL    执行性能。

###  PARALLEL_MIN_PERCENT
这个参数指定并行执行时，申请并行服务进程的最小值，它是一个百分比，比如我们设定这个值为50. 当一个SQL需要申请20个并行进程时，如果当前并行服务进程不足，按照这个参数的要求，这个SQL比如申请到20*50%=10个并行服务进程，如果不能够申请到这个数量的并行服务，SQL 将报出一个ORA-12827的错误。
当这个值设为Null时，表示所有的SQL在做并行执行时，至少要获得两个并行服务进程。

### PARALLEL_DEGREE_LIMIT

在并行度自动调整的情况下，Oracle自动决定一个语句是否并行执行和用什么并行度执行。优化器基于语句的资源需求自动决定一个语句的并行度。然而，为了确保并行服务器进程不会导致系统过载，优化器会限制使用的并行度。这个限制通过`PARALLEL_DEGREE_LIMIT`来强制实施。
值：

- CPU
  最大并行度被系统CPU数限制。计算限制的公式为`PARALLEL_THREADS_PER_CPU` *`CPU_COUNT` * 可用实例数（默认为簇中打开的所有实例，但也能通过`PARALLEL_INSTANCE_GROUP`或service定义来约束），这是默认的。
-  IO
  优化器能用的最大并行度被系统的IO容量限制。系统总吞吐除以每个进程的最大IO带宽计算出。为了使用该IO设置，你必须在系统上运行`DBMS_RESOURCE_MANAGER.CALIBRATE_IO`过程。该过程将计算系统总吞吐和单个进程的最大IO带宽。
- integer
  当自动并行度被激活时，该参数的数字值确定优化器为一个SQL语句能选择的最大并行度。PARALLEL_DEGREE_POLICY被设置为AUTO或LIMITED时，自动并行度才可以使用。

### PARALLEL_FORCE_LOCAL

​	`PARALLEL_FORCE_LOCAL`控制Oracle RAC环境下的并行执行。默认情况，被选择执行一个SQL语句的并行服务器进程能在簇中任何或所有Oracle RAC节点上操作。通过设置`PARALLEL_FORCE_LOCAL`为true，并行服务器进程被限制从而都在查询协调器驻留的同一个Oracle RAC节点上操作（语句被执行的节点上） 

### PARALLEL_EXECUTION_MESSAGE_SIZE

`PARALLEL_EXECUTION_MESSAGE_SIZE`确定并行执行（前面指并行查询，PDML，并行恢复，复制）所用信息的大小。
在大多数平台上，默认值如下：

- 16384字节，如果COMPATIBLE被设置为11.2.0或更高
- 4096字节如果COMPATIBLE被设置为小于11.2.0并且`PARALLEL_AUTOMATIC_TUNING`被设置为true
- 2148字节如果COMPATIBLE被设置为小于11.2.0并且`PARALLEL_AUTOMATIC_TUNING`被设置为false

默认值对大多数应用来说是足够的。值越大，要求共享池越大。较大的值会带来较好的性能，但会消耗较多的内存。因此，复制并不能从增加该值中受益。

注意：当PARALLEL_AUTOMATIC_TUNING被设置为TRUE时，信息缓冲在大池（large pool）中分配。这种情况下，默认值一般是较高的。注意参数PARALLEL_AUTOMATIC_TUNING已经被废弃。

### PARALLEL_AUTOMATIC_TUNING

注意: PARALLEL_AUTOMATIC_TUNING已经被废弃。保留它仅仅是为了向后兼容。
当该参数设置为true时，[Oracle](http://www.linuxidc.com/topicnews.aspx?tid=12)决定控制并行执行的所有参数的默认值。除了设置这个参数，你必须确定系统中目标表的PARALLEL子句。Oracle于是就会自动调整所有后续的并行操作。
如果你在之前的版本里用了并行执行且现在该参数为true，那么你将会因减少了共享池中分配的内存需求，而导致对共享池需求的减少。目前，这些内存会从large pool中分配，如果large_pool_size没被确定，那么，系统会自动计算出来。作为自动调整的一部分，Oracle将会使parallel_adaptive_multi_user参数可用。如果需要，你也可以修改系统提供的默认值。

## 4. 查看并行状态

**Script to Report the Degree of Parallelism DOP on Tables and Indexes (文档 ID 270837.1)**

```plsql
Check Script
-------------
col name format a30
col value format a20
Rem How many CPU does the system have?
Rem Default degree of parallelism is
Rem Default = parallel_threads_per_cpu * cpu_count
Rem -------------------------------------------------; 
select substr(name,1,30) Name , substr(value,1,5) Value 
from v$parameter 
where name in ('parallel_threads_per_cpu' , 'cpu_count' ); 

col owner format a30
col degree format a10
col instances format a10
Rem Normally DOP := degree * Instances
Rem See the following Note for the exact formula. 
Rem Note:260845.1 Old and new Syntax for setting Degree of Parallelism 
Rem How many tables a user have with different DOPs
Rem -------------------------------------------------------;
select * from (
select substr(owner,1,15) Owner , ltrim(degree) Degree, 
ltrim(instances) Instances, 
count(*) "Num Tables" , 'Parallel' 
from all_tables
where ( trim(degree) != '1' and trim(degree) != '0' ) or 
( trim(instances) != '1' and trim(instances) != '0' )
group by owner, degree , instances
union
select substr(owner,1,15) owner , '1' , '1' , 
count(*) , 'Serial' 
from all_tables
where ( trim(degree) = '1' or trim(degree) = '0' ) and 
( trim(instances) = '1' or trim(instances) = '0' )
group by owner
)
order by owner;


Rem How many indexes a user have with different DOPs
Rem ---------------------------------------------------;
select * from (
select substr(owner,1,15) Owner ,
substr(trim(degree),1,7) Degree , 
substr(trim(instances),1,9) Instances ,
count(*) "Num Indexes",
'Parallel' 
from all_indexes
where ( trim(degree) != '1' and trim(degree) != '0' ) or 
( trim(instances) != '1' and trim(instances) != '0' )
group by owner, degree , instances
union
select substr(owner,1,15) owner , '1' , '1' , 
count(*) , 'Serial' 
from all_indexes
where ( trim(degree) = '1' or trim(degree) = '0' ) and 
( trim(instances) = '1' or trim(instances) = '0' )
group by owner
)
order by owner;


col table_name format a35
col index_name format a35
Rem Tables that have Indexes with not the same DOP
Rem !!!!! This command can take some time to execute !!!
Rem ---------------------------------------------------;
set lines 150
select substr(t.owner,1,15) Owner ,
t.table_name ,
substr(trim(t.degree),1,7) Degree , 
substr(trim(t.instances),1,9) Instances, 
i.index_name ,
substr(trim(i.degree),1,7) Degree , 
substr(trim(i.instances),1,9) Instances 
from all_indexes i,
all_tables t
where ( trim(i.degree) != trim(t.degree) or
trim(i.instances) != trim(t.instances) ) and
i.owner = t.owner and
i.table_name = t.table_name;
```

## 参考文档

- Script to Report the Degree of Parallelism DOP on Tables and Indexes (文档 ID 270837.1)
- 如何启用和禁用并行 (文档 ID 2471049.1)
- 基于Oracle的SQL优化
- [Using Parallel Execution](https://docs.oracle.com/cd/B28359_01/server.111/b28313/usingpe.htm#i1007196)
- [How Parallel Execution Works](https://docs.oracle.com/cd/E11882_01/server.112/e25523/parallel002.htm)

