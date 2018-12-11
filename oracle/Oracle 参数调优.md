# Oracle 参数调优

ALTER SYSTEM SET "_buffer_busy_wait_timeout"=2     SCOPE=SPFILE;
ALTER SYSTEM SET "_kill_diagnostics_timeout"=140   SCOPE=SPFILE;
ALTER SYSTEM SET "_lm_rcvr_hang_allow_time"=140    SCOPE=SPFILE;
ALTER SYSTEM SET "_optim_peek_user_binds"=FALSE    SCOPE=SPFILE;
ALTER SYSTEM SET "_use_adaptive_log_file_sync"=FALSE SCOPE=SPFILE;
ALTER SYSTEM SET "_PX_use_large_pool"=TRUE SCOPE=SPFILE;
ALTER SYSTEM SET "deferred_segment_creation"=FALSE SCOPE=SPFILE;
ALTER SYSTEM SET log_buffer=512000000 SCOPE=SPFILE;
ALTER SYSTEM SET parallel_force_local=false;
ALTER SYSTEM SET parallel_max_servers=20;    默认480
ALTER SYSTEM SET open_cursors=3000 SCOPE=SPFILE;             
open_cursors设定每个session（会话）最多能同时打开多少个cursor（游标）。session_cached_cursor设定每个session（会话）最多可以缓存多少个关闭掉的cursor
ALTER SYSTEM SET session_cached_cursors=3000 SCOPE=SPFILE;
ALTER SYSTEM SET "_kgl_hot_object_copies"=2 SCOPE=SPFILE;
ALTER SYSTEM SET audit_trail='none' SCOPE=SPFILE;
ALTER SYSTEM SET shared_pool_size=10g SCOPE=SPFILE;
ALTER SYSTEM SET db_cache_size=56g SCOPE=SPFILE;
ALTER SYSTEM SET pga_aggregate_target=10g SCOPE=SPFILE;   ？
ALTER SYSTEM SET processes=5000 SCOPE=SPFILE;
ALTER SYSTEM SET "_enable_NUMA_support"=false;
ALTER SYSTEM SET PLSQL_CODE_TYPE=NATIVE SCOPE=SPFILE;    ---把plsql存储过程编译成本地代码的过程，不会导致任何解释器开销
ALTER SYSTEM SET PLSQL_OPTIMIZE_LEVEL=2 SCOPE=SPFILE;
alter system set use_large_pages='ONLY' SCOPE=SPFILE;
先备份一下spfile，
alter system set recyclebin='OFF' scope=spfile;
alter system set commit_write='immediate,nowait';    异步提交
将可选的 vm.hugetlb_shm_group 参数设置为有权使用 HugePages 的操作系统组。默认情况下，此参数设置为 0，从而允许所有组使用 HugePages。可以将此参数设置为 Oracle 数据库进程所属的操作系统组PARALLEL_FORCE_LOCAL如果指定为TRUE， 并行操作只会在当前instance里面并行，而不会垮多节点。 
PARALLEL_MAX_SEVERS参数设置并行执行可用的最大进程数量，该参数的缺省值如下得出：
1. 当PGA_AGGREGATE_TARGET >0时
PARALLEL_MAX_SERVERS= (CPU_COUNT x PARALLEL_THREADS_PER_CPU x 10)
2. 当PARALLEL_MAX_SERVERS未设置PARALLEL_MAX_SERVERS=(CPU_COUNT x PARALLEL_THREADS_PER_CPU x 5)缺省设置可能并不足够，通常我们根据最高的并行度（DOP）来设置PARALLEL_MAX_SERVERS参数