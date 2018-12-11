# Database Initialization Parameters for Oracle Applications Release 11i (文档
ID 216205.1)

  

|

|

# Database Initialization Parameters for Oracle Applications Release 11 _i_

### Introduction

This note lists and describes the database initialization parameter settings
for Oracle Applications Release 11 _i_ , Releases 11.5.1 through to 11.5.10.
The document consists of a _common section_ , which provides the common set of
database initialization parameters for all releases of the Oracle Database,
followed by several _release-specific sections_ , which list parameters and
settings specific to a particular release of the Oracle Database. Together,
the common section and release-specific section formulate the complete
database initialization parameter file.

Parameters that appear on a _removal list_ are those for which the default
value should be used. Removing such parameters from the database
initialization file ensures that the default values will be used
automatically.

The “X” notation used in the release-specific section, for example in 9.2.0.X,
refers to all patchset releases within that major version. For example, the
9.2.0.X section covers all releases of 9.2.0 including 9.2.0.5, 9.2.0.6, and
so on. The same applies for other versions, including 8iR3, 10gR1, 10gR2, and
11gR1. Note that Release 9iR1 was not supported with Oracle Applications.

| **_NOTE_** |

The _AutoConfig_ tool is used for configuration of an Oracle Applications
instance. This tool uses information from the database context file to
generate all the configuration files used on the database tier. Running
AutoConfig will not overwrite an existing initialization file. For further
details, see My Oracle Support Knowledge Document
[165195.1](http://metalink.oracle.com/metalink/plsql/ml2_documents.showNOT?p_id=165195.1),
_Using AutoConfig to Manage System Configurations with Oracle Applications
11i_.  
  
---|---  
  
### Table of Contents

  * [Section 1: Common Database Initialization Parameters](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153097281850763&id=216205.1&_adf.ctrl-state=11dph05qcs_129#common)
  * [Section 2: Introduction to Release-Specific Database Initialization Parameters](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153097281850763&id=216205.1&_adf.ctrl-state=11dph05qcs_129#releasespecific)
  * [Section 2.1: Release-Specific Database Initialization Parameters for 8iR3 (8.1.7.X)](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153097281850763&id=216205.1&_adf.ctrl-state=11dph05qcs_129#8iR3)
  * [Section 2.2: Release-Specific Database Initialization Parameters for 9iR2 (9.2.0.X)](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153097281850763&id=216205.1&_adf.ctrl-state=11dph05qcs_129#9iR2)
  * [Section 2.3: Release-Specific Database Initialization Parameters for 10gR1 (10.1.X)](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153097281850763&id=216205.1&_adf.ctrl-state=11dph05qcs_129#10gR1)
  * [Section 2.4: Release-Specific Database Initialization Parameters for 10gR2 (10.2.X)](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153097281850763&id=216205.1&_adf.ctrl-state=11dph05qcs_129#10gR2)
  * [Section 2.5: Release-Specific Database Initialization Parameters for 11gR1 (11.1.X)](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153097281850763&id=216205.1&_adf.ctrl-state=11dph05qcs_129#11gR1)
  * [Section 2.6: Release-Specific Database Initialization Parameters for 11gR2 (11.2.X)](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153097281850763&id=216205.1&_adf.ctrl-state=11dph05qcs_129#11gR2)
  * [Section 2.7: Release-Specific Database Initialization Parameters for 12cR1 (12.1.X)](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153097281850763&id=216205.1&_adf.ctrl-state=11dph05qcs_129#12cR1)
  * [Appendix A: Enabling System Managed Undo (SMU)](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153097281850763&id=216205.1&_adf.ctrl-state=11dph05qcs_129#smu)
  * [Appendix B: Temporary Tablespace Setup](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153097281850763&id=216205.1&_adf.ctrl-state=11dph05qcs_129#temptable)
  * [Appendix C: Applications Upgrade Section](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153097281850763&id=216205.1&_adf.ctrl-state=11dph05qcs_129#upgrade)
  * [Appendix D: Database Initialization Parameter Sizing](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153097281850763&id=216205.1&_adf.ctrl-state=11dph05qcs_129#sizing)
  * [Appendix E: Related Documentation ](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153097281850763&id=216205.1&_adf.ctrl-state=11dph05qcs_129#references)

The most current version of this document can be obtained in My Oracle Support
Knowledge Document
[216205.1](http://metalink.oracle.com/metalink/plsql/ml2_documents.showNOT?p_id=216205.1).

There is a [change
log](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153097281850763&id=216205.1&_adf.ctrl-
state=11dph05qcs_129#changelog) at the end of this document.

* * *

## Section 1: Common Database Initialization Parameters

Many of the database initialization parameters are common across releases. The
following section lists the common set of parameters. Release-specific
database initialization parameters are included in the respective release
sections. The release-specific parameters should be appended to the common
database initialization parameters.

The parameter values provided in this document reflect a development or test
instance configuration, and you should adjust the relevant parameters based on
the number of active Oracle Applications users. In addition, you should
investigate any parameters that are set but not mentioned in this note.

####################################################################  
#  
# Oracle Applications Release 11i common database initialization parameters  
#  
# The following represents the common database initialization  
# parameters file for Oracle Applications Release 11i.  
# Release-specific parameters are listed in the respective release  
# section. The release-specific parameters should be appended to the  
# common database initialization parameter file.  
#  
# There are numerous mandatory database initialization parameters,  
# the settings of which must not be altered. Use of values other than  
# those provided in this document will not be supported unless Oracle  
# Support has specifically instructed you to alter these parameters  
# from their mandatory settings.  
#  
# Mandatory parameters are denoted with the (MP) symbol as a  
# comment. They include parameters such as NLS and optimizer  
# related parameters.  
#  
# The remaining parameters relate to either sizing or configuration,  
# and the correct values will be specific to a particular environment  
# and system capacity. A sizing table provides recommendations and  
# guidelines based on the number of deployed and active Applications  
# users. Customers can adjust these parameters to suit their  
# environment and system resource capacity.  
#  
#####################################################################

#########  
#  
# Database parameters  
#  
# The database parameters define the name of the database and  
# the names of the control files.  
#  
# The database name is established when the database is built,  
# and for most customers matches the instance name. It should not  
# normally be necessary to change the database name, except for  
# the purposes of database cloning.  
#  
# There should be at least two control files, preferably three,  
# located on different volumes in case one of the volumes fails.  
# Control files can expand, hence you should allow at least 20M  
# per file for growth.  
#  
#########

db_name = prod11i

control_files = ('/disk1/prod11i_DB/cntrlprod11i_1.dbf',  
'/disk2/prod11i_DB/cntrlprod11i_2.dbf',  
'/disk3/prod11i_DB/cntrlprod11i_3.dbf')

  
#########  
#  
# Database block size  
#  
# The required block size for Oracle Applications Release 11 _i_ is 8K.  
# No other block size may be used.  
#  
#########

db_block_size = 8192 #MP

  
#########  
#  
# Compatible  
#  
# Compatibility should be set to the current release.  
# Refer to the release specific section for the appropriate  
# value.  
#  
#########

# compatible = 10.2.0 | 10.1.0 | 9.2.0 | 8.1.7 #MP

  
#########  
#  
# _system_trig_enabled  
#  
# The _system_trig_enabled must be set to TRUE.  
# If the _system_trig_enabled parameter is set to FALSE it will  
# prevent system triggers from being executed.  
#  
#########

_system_trig_enabled = true #MP

  
#########  
#  
# O7_DICTIONARY_ACCESSIBILITY  
#  
# O7_DICTIONARY_ACCESSIBILITY must be set to TRUE for Oracle  
# Applications release 11.5.9 or lower. For release 11.5.10  
# (or higher), O7_DICTIONARY_ACCESSIBILITY should be set to  
# FALSE. Uncomment the appropriate line below, based on your  
# Applications release level.  
#  
#########

# O7_DICTIONARY_ACCESSIBILITY = TRUE #MP 11.5.9 or lower  
# O7_DICTIONARY_ACCESSIBILITY = FALSE #MP 11.5.10 or higher

  
#########  
# NLS parameters  
#  
# Some NLS parameter values are marked as being required 11i settings.  
# These are the only supported settings for these parameters for  
# Applications Release 11i and must not be modified to other values.  
# Other NLS parameters have been given default values.  
#  
#########

nls_language = american  
nls_territory = america  
nls_date_format = DD-MON-RR #MP  
nls_numeric_characters = ".,"  
nls_sort = binary #MP  
nls_comp = binary #MP

  
#########  
#  
# Multi-threaded Server (MTS)  
#  
# Most Oracle Applications customers DO NOT need to use MTS,  
# and the default configuration disables MTS.  
#  
# If MTS is used, it can have a dramatic effect on the SGA, as  
# session memory, including sort and cursor areas, reside in the  
# SGA.  
#  
# Configuring MTS requires the large pool to be allocated. The  
# minimum size for the large pool is 50M.  
#  
#########

  
#########  
#  
# Auditing and Security  
#  
# There is a performance overhead for auditing. In addition,  
# the database administrator will need to implement a purge  
# policy for the SYS.AUD$ table.  
#  
# Statement level auditing should not be used.  
#  
# Some products require max_enabled_roles to be set.  
# The value should be set to 100.  
#  
#########

# audit_trail = true # Uncomment this line if you want to enable auditing  
max_enabled_roles = 100 #MP

  
########  
#  
# Dump parameters  
#  
# These specify the destination of the trace and core files, and  
# would normally point into the appropriate OFA trace  
# directories. The maximum size of a dump file can be changed at  
# the session level, and prevents a trace file using an excessive  
# amount of disk space.  
#  
########

user_dump_dest = ?/prod11i/udump  
background_dump_dest = ?/prod11i/bdump  
core_dump_dest = ?/prod11i/cdump

max_dump_file_size = 20480 # Limit default trace file size to 10 MB.

  
########  
#  
# Timed statistics  
#  
# On most platforms, enabling timed statistics has minimal effect  
# on performance. It can be enabled/disabled dynamically at  
# both the system and session level.  
#  
# Timed statistics is required for SQL trace and Statspack.  
#  
########

timed_statistics = true

  
########  
#  
# Trace parameters  
#  
#  
# _trace_files_public  
#  
# As the data server machine should be in a secure environment,  
# setting to true enables trace file analysis.  
########  
  
_trace_files_public = TRUE

  
########  
# Oracle Trace  
#  
# SQL trace should be disabled at the instance level and enabled  
# for specific sessions as needed via the Application or  
# profiles.  
#  
sql_trace=FALSE

########  
#  
# Fixed SGA  
#  
# The fixed SGA parameters represent resources that have their  
# sizes fixed on startup. If the maximum size is reached (e.g. no.  
# of sessions), then the resource is unavailable until freed by  
# the instance. Refer to Appendix D: Database Initialization  
# Parameter Sizing.  
#  
########

  
# Processes/sessions  
#  
# A database process can be associated with one or more database  
# sessions. For all technology stack components other than Oracle  
# Forms, there is a one-to-one mapping between sessions and  
# processes.  
#  
# For Forms processes, there will be one database session per  
# open form, with a minimum of two sessions per Forms user  
# (one for the navigator form, and one for the active form).  
#  
# Sessions should be set to twice the value of processes.

processes = 200 # Max. no. of users  
sessions = 400 # 2 x no. of processes  
db_files = 512 # Max. no. of database files  
dml_locks = 10000 # Database locks  
enqueue_resources = 32000 # Max. no. of concurrent

  
########  
#  
# Cursor-related settings.  
#  
########

cursor_sharing = EXACT #MP  
open_cursors = 600  
session_cached_cursors = 200

  
########  
#  
# Buffer Cache  
#  
# The buffer cache requires ( db_block_size x db_block_buffers )  
# bytes within the SGA. Its sizing can have a significant effect  
# on performance. Values less than 20,000 are unrealistic for  
# most customers, and can be increased as memory permits.  
#  
# The use of multiple buffer pools for Oracle Applications is not  
# supported. Only a single buffer pool should be used (i.e. the  
# default).  
#  
########

db_block_buffers = 20000  
db_block_checking = FALSE  
db_block_checksum = TRUE

  
########  
#  
# Log Writer  
#  
# The log writer parameters control the size of the log buffer  
# within the SGA and how frequently the redo logs are check  
# pointed (all dirty buffers written to disk to create a new  
# recovery point).  
#  
# A value of 10MB for the log buffer is a reasonable value for  
# Oracle Applications and it represents a balance between  
# concurrent programs and online users. The value of log_buffer  
# must be a multiple of redo block size, normally 512 bytes.  
#  
# The checkpoint interval and timeout control the frequency of  
# checkpoints.  
#  
########

log_checkpoint_timeout = 1200 # Checkpoint at least every 20 mins.  
log_checkpoint_interval = 100000  
log_buffer = 10485760  
log_checkpoints_to_alert = TRUE

  
#  
# Shared Pool  
#  
# It is important to tune the shared pool so as to minimize  
# contention for SQL and PL/SQL objects. A value of 400M is a  
# reasonable starting point for 11i with a 40M reserved area  
# (10%).  
#  
########

shared_pool_size = 400M  
shared_pool_reserved_size = 40M  
_shared_pool_reserved_min_alloc = 4100

  
# cursor_space_for_time  
#  
# Cursor space for time is an optimization which essentially  
# results in holding pins on cursors and their associated  
# frames/buffers for longer periods of time. The pins are held  
# until the cursor is closed as opposed to at the end-of-fetch  
# (normal behavior). This reduces library cache pin traffic  
# which reduces library cache latch gets. Cursor space for time  
# is useful for large Applications environments whereby library  
# cache latch contention, specifically due to pin gets, is an  
# issue (in terms of performance).  
#  
# Cursor space for time requires at least a 50% increase in the  
# size of the shared pool because of the frames/buffers. If the  
# Stats pack reports show that the waits for library cache latch  
# gets is significant, and the latch gets are due to pin  
# requests, then cursor space for time can be used to improve  
# performance.  
#  
# It is important to note that library cache latch contention can  
# be caused by numerous different factors including the use of  
# non-sharable SQL (i.e. literals), lack of space, frequent  
# loads/unloads, invalidation, patching, gathering statistics  
# frequently and during peak periods, pin requests, etc.  
# Cursor space for time is designed to optimize pin requests,  
# and will not reduce latch contention for the other issues.  
#  
# cursor_space_for_time = FALSE # disabled by default

  
########  
#  
# Java Pool  
#  
# 11i uses Java Stored Procedures, hence an initial setting of  
# 50M is used. The java pool size may need to be increased as  
# required.  
#  
########

java_pool_size = 50M

  
########  
#  
# PL/SQL parameters  
#  
# The utl_file_dir must be set as per the installation manuals.  
# utl_file_dir = , ...  
#  
########

utl_file_dir = ?/prod11i/utl_file_dir

  
########  
#  
# Advanced Queuing (AQ) and Job Queues  
#  
# AQ requires the TM process to handle delayed messages. A number  
# of Application modules use AQ, including Workflow. Job Queues  
# enable advanced queue to submit background jobs.  
#  
# The minimum (and recommended) value for aq_tm_processes is 1.  
# However, the value can be increased to meet specific needs.  
# For example, increasing the value to 2 can help reduce  
# excessive queue lengths.  
#  
########

aq_tm_processes = 1  
job_queue_processes = 2

  
########  
#  
# Archiving  
#  
# Archiving parameters, including destination (optionally,  
# multiple destinations in 9i) need to be specified.  
#  
########

# log_archive_start = true # Uncomment this line if you want to enable
automatic archiving

  
########  
#  
# Parallel Execution  
#  
# Some of the Applications Concurrent Programs use parallel  
# execution including DBI programs and Gathering Statistics.  
#  
# AD will also use parallel execution when creating large  
# indexes.  
#  
# Parallel execution uses the large_pool for message buffers  
# and the large_pool_size should be sized as per the guidelines  
# in the large pool section.  
#  
########

parallel_max_servers = 8 # Max. value should be 2 x no. of CPUs  
parallel_min_servers = 0

  
########  
#  
# Events  
#  
# Events are used by Oracle Support and Development. They should  
# only be set as requested.  
#  
# Refer to the data server release specific section for the  
# events which must be set.  
#  
########

  
#########  
#  
# Optimizer  
#  
# Release 11i uses the Cost Based Optimizer (CBO). The  
# following optimizer parameters must be set as below, and should  
# not be changed. Values other than the documented values below  
# are not supported.  
#  
# Refer also to the release specific section for additional  
# optimizer parameters which must be set.  
#  
#########

db_file_multiblock_read_count = 8 #MP  
optimizer_max_permutations = 2000 #MP  
query_rewrite_enabled = true #MP  
_sort_elimination_cost_ratio = 5 #MP  
_like_with_bind_as_equality = TRUE #MP  
_fast_full_scan_enabled = FALSE #MP  
_sqlexec_progression_cost = 2147483647 #MP

  
#########  
#  
# Oracle Real Application Clusters (Oracle RAC)  
#  
# The following parameters should be set when running  
# the E-Business Suite in an Oracle RAC environment.

max_commit_propagation_delay = 0 #MP  
cluster_database = TRUE #MP  
  
# Parallel Execution and Oracle RAC  
#  
# It is recommended to set the parameters PARALLEL_INSTANCE_GROUP  
# and INSTANCE_GROUPS appropriately on each instance to ensure that  
# parallel requests do not span instances. For example, on instance1,  
# set instance_groups=apps1 and parallel_instance_group=apps1. On  
# instance2, set instance_groups=apps2 and parallel_instance_group=apps2.  
#  
#########

* * *

## Section 2: Release-Specific Database Initialization Parameters

This section lists the database initialization parameters that apply to a
specific release of the Oracle Database. These parameters should be added to
the common database initialization parameters listed in Section 1. The
complete database initialization parameters file should therefore consist of
the common section and the relevant release-specific section.

* * *

### Section 2.1: Release-Specific Database Initialization Parameters for 8iR3
(8.1.7.X)

#####################################################################  
#  
# Oracle Applications Release 11i - database initialization parameters  
#  
# This section contains the release specific database  
# initialization parameters for 8.1.7.4  
#  
#########  
  
compatible = 8.1.7 #MP

  
########  
#  
# Rollback segments  
#  
# Rollback segments can be brought online, and taken offline on  
# demand. The number of rollback segments is dependent on the  
# number of concurrent transactions, but 6 to 12 rollback  
# segments is a typical profile.  
#  
# If rollback segment contention is observed via the Stats Pack  
# reports, then create additional rollback segments. It is  
# generally recommended to create private rather than public  
# rollback segments.  
#  
# Sizing the rollback segments largely depends on the workload  
# characteristics as well as the frequency and elapsed times of  
# the concurrent requests.  
#  
########  
  
rollback_segments = (rbs1,rbs2,rbs3,rbs4,rbs5,rbs6)

  
########  
#  
# Sort Area and Hash Area  
#  
# The sort area is allocated from process memory, unless MTS is  
# used. This parameter can have a dramatic effect on  
# performance. A low value results in excessive disk based  
# sorts and joins, and a high value may induce paging if  
# sufficient system memory does not exist.  
#  
# The recommended values for Oracle Applications are 1MB and 2 MB  
# for sort_area_size and hash_area_size respectively. The hash  
# area and sort area sizes can be increased, however, the hash  
# area size should always be 2x of sort area size. It is not  
# recommended to set hash_area_size larger than 8MB at the  
# instance level.  
#  
########  
  
sort_area_size = 1048576  
hash_area_size = 2097152

  
########  
#  
# Advanced Queuing (AQ) and Job Queues  
#  
# AQ requires the TM process to handle delayed messages. A number  
# of Application modules use AQ, including Workflow.  
#  
########  
  
job_queue_interval=90

  
#########  
#  
# Optimizer  
#  
# Release 11i uses the Cost Based Optimizer (CBO). The  
# following optimizer parameters must be set as below, and should  
# not be changed.  
#  
#  
########

optimizer_features_enable = 8.1.7 #MP  
_optimizer_undo_changes = FALSE #MP  
_optimizer_mode_force = TRUE #MP  
_complex_view_merging = TRUE #MP  
_push_join_predicate = TRUE #MP  
_use_column_stats_for_function = TRUE #MP  
_or_expand_nvl_predicate = TRUE #MP  
_push_join_union_view = TRUE #MP  
_table_scan_cost_plus_one = TRUE #MP  
_ordered_nested_loop = TRUE #MP  
_new_initial_join_orders = TRUE #MP  

* * *

#### Section 2.1.1 Removal List for Oracle Database 8iR3 (8.1.7.X)

If they exist, you should remove the following database initialization
parameters from your database initialization parameters file for 8iR3:

_b_tree_bitmap_plans  
_unnest_subquery  
_sortmerge_inequality_join_off  
_index_join_enabled  
always_anti_join  
always_semi_join  
event="10943 trace name context forever, level 2"  
event = "10929 trace name context forever"  
event = "10932 trace name context level 2"  
optimizer_percent_parallel  
optimizer_mode  
optimizer_index_caching  
optimizer_index_cost_adj

* * *

### Section 2.2: Release-Specific Database Initialization Parameters for 9iR2
(9.2.0.X)

#####################################################################  
# Oracle Applications Release 11i - database initialization parameters  
#  
# This section contains the release specific database  
# initialization parameters for 9.2.0.X.  
#

#########  
#  
# Compatible  
#  
# Compatibility should be set to the current release.  
#  
#########

compatible = 9.2.0 #MP

  
########  
#  
# Buffer Cache  
#  
# For 9i releases, the parameter db_cache_size should be used  
# to size the buffer cache in place of db_block_buffers.  
# The minimum size for the buffer cache (for Apps) is 156 MB.  
# The buffer cache should be tuned as per the recommendations  
# in the sizing table (in the section Database Initialization  
# parameter sizing).  
#  
# The use of multiple buffer pools for Oracle Applications is not  
# supported. Only a single buffer pool should be used (i.e.  
# default).  
#  
########  
  
db_cache_size = 156M

  
#########  
#  
# NLS and character sets.  
#  
#  
#########  
  
nls_length_semantics = BYTE #MP

  
########  
#  
# Rollback segments  
#  
# As of 9i, Oracle Applications requires the use of System Managed Undo  
# instead of rollback segments. System Managed Undo is more efficient,  
# easier to manage, and reduces the chances of snapshot too old errors.

#  
########

undo_management = AUTO #MP  
undo_retention = 1800  
undo_suppress_errors = FALSE #MP  
undo_tablespace = APPS_UNDOTS1 #MP

  
########  
#  
# Private Memory areas  
#  
# As of 9i, the automatic memory manager is used. This  
# avoids the need to manually tune sort_area_size and  
# hash_area_size.  
#  
# Automatic Memory Manager also improves performance and scalability  
# as the memory is released to the OS.  
#  
# The olap_page_pool_size parameter is used for the OLAP option  
# which is used by certain Application modules such as the  
# Enterprise Budget and Planning module.  
########  
  
pga_aggregate_target = 1G  
workarea_size_policy = AUTO #MP  
olap_page_pool_size = 4194304

  
########  
#  
# Events  
#  
# Events should not be set unless directed by Oracle Support,  
# or by instruction as per the Applications documentation.  
#  
# The following events should be set for PL/SQL backward  
# compatibility.  
#  
# These events should only be used if you are using Oracle  
# Applications release 11.5.7. For later releases (i.e. 11.5.8  
# or higher), you should remove these events.  
#  
########  

event="10932 trace name context level 32768"  
event="10933 trace name context level 512"  
event="10943 trace name context level 16384"

  
#########  
#  
# Optimizer  
#  
# Release 11i uses the Cost Based Optimizer (CBO). The  
# following optimizer parameters must be set as below, and should  
# not be changed.  
#  
##########

optimizer_features_enable = 9.2.0 #MP  
_index_join_enabled = FALSE #MP  
_b_tree_bitmap_plans = FALSE #MP

* * *

#### Section 2.2.1: Removal List for Oracle Database 9iR2 (9.2.0.X):

If they exist, you should remove the following database initialization
parameters from your database initialization parameters file for 9iR2:

always_anti_join  
always_semi_join  
db_block_buffers  
event="10943 trace name context forever, level 2"  
event="38004 trace name context forever, level 1"  
job_queue_interval  
optimizer_percent_parallel  
_complex_view_merging  
_new_initial_join_orders  
_optimizer_mode_force  
_optimizer_undo_changes  
_or_expand_nvl_predicate  
_ordered_nested_loop  
_push_join_predicate  
_push_join_union_view  
_use_column_stats_for_function  
_unnest_subquery  
_sortmerge_inequality_join_off  
_table_scan_cost_plus_one  
_always_anti_join  
_always_semi_join  
hash_area_size  
sort_area_size  
optimizer_mode  
optimizer_index_caching  
optimizer_index_cost_adj

Remove the following events only if you are using Oracle Applications release
11.5.8 or later.

event="10932 trace name context level 32768"  
event="10933 trace name context level 512"  
event="10943 trace name context level 16384"

* * *

### Section 2.3: Release-Specific Database Initialization Parameters for 10gR1
(10.1.X)

####################################################################  
#  
# Oracle Applications Release 11i - database initialization parameters  
#  
# This section contains the release specific database  
# initialization parameters for 10gR1.  
#  
# Oracle Applications requires a minimum of 10.1.0.4 for  
# 10gR1 certification with 11i.  
#

#########  
#  
# Compatible  
#  
# Compatibility should be set to the current release.  
#  
#########

compatible = 10.1.0 #MP

  
########  
#  
# Cache Sizes  
#  
# For 10g, the automatic SGA tuning option is required. Using this  
# feature avoids the need for individual tuning of the different SGA  
# caches such as the buffer cache, shared pool, and large pool. The  
# automatic SGA tuning option also improves overall performance and  
# improves manageability.  
#  
# SGA target refers to the total size of the SGA, including all the  
# sub-caches such as the buffer cache, shared pool, and large pool.  
# Refer to the sizing table in the section Database Initialization  
# Parameter Sizing for sizing recommendations for sga_target.  
#  
# When sga_target is being used, it is advisable to use a Server  
# Parameter file (SPFILE) to store the initialization parameter  
# values The Automatic SGA tuning option (sga_target) dynamically  
# sizes individual caches, such as the buffer cache and shared pool.  
# Using an SPFILE allows the dynamically-adjusted values to persist  
# across restarts. Refer to the Oracle Database Administrator's  
# Guide for information on how to create and maintain an SPFILE.  
#  
########

sga_target = 1G

  
########  
#  
# Shared Pool  
#  
# It is important to tune the shared pool so as to minimize  
# contention for SQL and PL/SQL objects. A value of 400M is a  
# reasonable starting point for 11i, and automatic SGA  
# tuning will adjust the caches as per the workload.  
# The values below for the shared pool related caches  
# are simply minimum values (i.e. starting values).  
#  
########

shared_pool_size = 400M  
shared_pool_reserved_size = 40M  

#########  
#  
# NLS and character sets.  
#  
#  
#########

nls_length_semantics = BYTE #MP

  
#########  
#  
# Rollback segments  
#  
# As of 9i, Oracle Applications requires the use of System Managed Undo  
# instead of rollback segments. System Managed Undo is more efficient,  
# easier to manage, and reduces the chances of snapshot too old errors.  
#  
########

undo_management = AUTO #MP  
undo_tablespace = APPS_UNDOTS1 #MP

  
########  
#  
# Private Memory Areas  
#  
# The Automatic Memory Manager is used to manage PGA memory.  
# This avoids the need to tune sort_area_size and hash_area_size  
# manually.  
#  
# The Automatic Memory Manager also improves performance and  
# scalability, as memory is released back to the operating system.  
#  
########

pga_aggregate_target = 1G  
workarea_size_policy = AUTO #MP  
olap_page_pool_size = 4194304

  
########  
#  
# Cursor-related Settings  
#  
# 10g changed the default behavior for the server side PL/SQL  
# cursor cache. Prior to 10g, PL/SQL (server side) used  
# open_cursors as the upper limit for caching PL/SQL  
# (server side) cursors. In 10g, the upper limit is now  
# controlled by the parameter session_cached_cursors.  
# For 10g environments, the parameters open_cursors and  
# session_cached_cursors should be set as follows, in  
# accordance with this change in behavior.  
#  
########

open_cursors = 600  
session_cached_cursors = 500

  
########  
#  
# Events  
#  
# Events should not be set unless directed by Oracle Support,  
# or by instruction as per the Applications documentation.  
#  
########

  
#########  
#  
# PL/SQL Parameters  
#  
# The following parameters are used to enable the PL/SQL global optimizer  
# and specify the compilation type.  
#  
# Release 11i environments that use Oracle Database 10g can employ either  
# interpreted or compiled (native) PL/SQL code. The default is interpreted.  
# While native PL/SQL compilation can improve runtime performance, this may  
# be at the expense of increased downtime, because of the need to generate  
# and compile the native shared libraries. If native compilation is to be
used,  
# the parameter plsql_native_library_dir should be set to the path of the  
# directory that will be used to store the shared libraries, and that line  
# and the plsql_native_library_subdir_count line below should be uncommented.  
#  
#########

plsql_optimize_level = 2 #MP  
plsql_code_type = INTERPRETED  
# plsql_native_library_dir = /prod11i/plsql_nativelib # Uncomment if using
native PL/SQL  
# plsql_native_library_subdir_count = 149 # Uncomment if using native PL/SQL  

#########  
#  
# Optimizer  
#  
# Release 11i uses the Cost Based Optimizer (CBO). The following optimizer  
# parameters must be set as below, and should not be changed.  
#  
#########

_b_tree_bitmap_plans = FALSE #MP

#########  
#  
# Advanced Queuing (AQ) and Job Queues  
#  
# In 10gR1 and higher, aq_tm_processes is auto-tuned and should no longer  
# need to be specified. However, omitting this setting has not been tested  
# with Oracle E-Business Suite. For optimum performance, the minimum (and  
# recommended) value is 1. The value can be increased to meet specific  
# needs. For example, increasing the value to 2 can help reduce excessive  
# queue lengths.  
########

aq_tm_processes = 1

* * *

#### Section 2.3.1: Removal List for Oracle Database 10gR1 (10.1.X):

If they exist, you should remove the following database initialization
parameters from your database initialization parameters file for 10gR1:

always_anti_join  
always_semi_join  
db_block_buffers  
db_cache_size  
large_pool_size  
row_locking  
max_enabled_roles  
_shared_pool_reserved_min_alloc  
java_pool_size  
event="10943 trace name context forever, level 2"  
event="38004 trace name context forever, level 1"  
event="10932 trace name context level 32768"  
event="10933 trace name context level 512"  
event="10943 trace name context level 16384"  
job_queue_interval  
optimizer_percent_parallel  
_complex_view_merging  
_new_initial_join_orders  
_optimizer_mode_force  
_optimizer_undo_changes  
_or_expand_nvl_predicate  
_ordered_nested_loop  
_push_join_predicate  
_push_join_union_view  
_use_column_stats_for_function  
_table_scan_cost_plus_one  
_unnest_subquery  
_sortmerge_inequality_join_off  
_index_join_enabled  
_always_anti_join  
_always_semi_join  
hash_area_size  
sort_area_size  
optimizer_mode  
optimizer_index_caching  
optimizer_index_cost_adj  
optimizer_max_permutations  
optimizer_dynamic_sampling  
optimizer_features_enable  
undo_suppress_errors  
plsql_compiler_flags  
query_rewrite_enabled  
_optimizer_cost_model  
_optimizer_cost_based_transformation

* * *

### Section 2.4: Release-Specific Database Initialization Parameters for 10gR2
(10.2.X)

####################################################################  
#  
# Oracle Applications Release 11i - database initialization parameters  
#  
# This section contains the release-specific database initialization
parameters  
# for 10gR2. Oracle Applications Release 11i requires a minimum of 10.2.0.2.  

#########  
#  
# Compatible  
#  
# Compatibility should be set to the current release.  
#  
#########

compatible = 10.2.0 #MP

  
#########  
#  
# Cache Sizes  
#  
# For 10g, the automatic SGA tuning option is required. Using this  
# feature avoids the need for individual tuning of the different SGA  
# caches such as the buffer cache, shared pool, and large pool. The  
# automatic SGA tuning option also improves overall performance and  
# improves manageability.  
#  
# SGA target refers to the total size of the SGA, including all the  
# sub-caches such as the buffer cache, shared pool, and large pool.  
# Refer to the sizing table in the section Database Initialization  
# Parameter Sizing for sizing recommendations for sga_target.  
#  
# When sga_target is being used, it is advisable to use a Server  
# Parameter file (SPFILE) to store the initialization parameter  
# values The Automatic SGA tuning option (sga_target) dynamically  
# sizes individual caches, such as the buffer cache and shared pool.  
# Using an SPFILE allows the dynamically-adjusted values to persist  
# across restarts. Refer to the Oracle Database Administrator's  
# Guide for information on how to create and maintain an SPFILE.  
#  
########

sga_target = 1G

  
########  
#  
# Shared Pool  
#  
# It is important to tune the shared pool so as to minimize  
# contention for SQL and PL/SQL objects. A value of 400M is a  
# reasonable starting point for 11i, and automatic SGA  
# tuning will adjust the caches as per the workload.  
# The values below for the shared pool related caches  
# are simply minimum values (i.e. starting values).  
#  
########

shared_pool_size = 400M  
shared_pool_reserved_size = 40M  
  
  
#########  
#  
# NLS and Character Sets.  
#  
#  
#########

nls_length_semantics = BYTE #MP

  
#########  
#  
# Rollback Segments  
#  
# As of 9i, Oracle Applications requires the use of System  
# Managed Undo. System Managed Undo is much more efficient, and  
# reduces the chances of snapshot too old errors. In addition,  
# it is much easier to manage and administer system managed undo  
# than manually managing rollback segments.  
#  
########

undo_management = AUTO #MP  
undo_tablespace = APPS_UNDOTS1 #MP

  
########  
#  
# Private Memory Areas  
#  
# The Automatic Memory Manager is used to manage PGA memory.  
# This avoids the need to tune sort_area_size and hash_area_size  
# manually.  
#  
# The Automatic Memory Manager also improves performance and  
# scalability, as memory is released back to the operating system.  
#  
########

pga_aggregate_target = 1G  
workarea_size_policy = AUTO #MP  
olap_page_pool_size = 4194304

  
########  
#  
# Cursor-related Settings  
#  
# 10g changed the default behavior for the server side PL/SQL  
# cursor cache. Prior to 10g, PL/SQL (server side) used  
# open_cursors as the upper limit for caching PL/SQL  
# (server side) cursors. In 10g, the upper limit is now  
# controlled by the parameter session_cached_cursors.  
# For 10g environments, the parameters open_cursors and  
# session_cached_cursors should be set as follows, in  
# accordance with this change in behavior.  
#  
########

open_cursors = 600  
session_cached_cursors = 500

  
########  
#  
# Events  
#  
# Events should not be set unless directed by Oracle Support,  
# or by instruction as per the Applications documentation.  
#  
########

  
#########  
#  
# PL/SQL Parameters  
#  
# The following parameters are used to enable the PL/SQL global optimizer  
# and specify the compilation type.  
#  
# Release 11i environments that use Oracle Database 10g can employ either  
# interpreted or compiled (native) PL/SQL code. The default is interpreted.  
# While native PL/SQL compilation can improve runtime performance, this may  
# be at the expense of increased downtime, because of the need to generate  
# and compile the native shared libraries. If native compilation is to be
used,  
# the parameter plsql_native_library_dir should be set to the path of the  
# directory that will be used to store the shared libraries, and that line  
# and the plsql_native_library_subdir_count line below should be uncommented.  
#  
#########

plsql_optimize_level = 2 #MP  
plsql_code_type = INTERPRETED  
# plsql_native_library_dir = /prod11i/plsql_nativelib # Uncomment if using
native PL/SQL  
# plsql_native_library_subdir_count = 149 # Uncomment if using native PL/SQL

  
#########  
#  
# Optimizer  
#  
# Release 11i uses the Cost Based Optimizer (CBO). The following optimizer  
# parameters must be set as below, and should not be changed.  
#  
#########

_b_tree_bitmap_plans = FALSE #MP  
optimizer_secure_view_merging = FALSE #MP  

#########  
# Other parameters  
#  
# _kks_use_mutex_pin  
#  
# 10gR2 facilitates the use of mutexes to lock resources in a lightweight  
# fashion with higher granularity. Therefore, this parameter does not need  
# to be set on most platforms. However, it must be set to FALSE on HP-UX.  
#  
#########  
  
_kks_use_mutex_pin=FALSE #HP-UX only  

#########  
#  
# Advanced Queuing (AQ) and Job Queues  
#  
# In 10gR1 and higher, aq_tm_processes is auto-tuned and should no longer  
# need to be specified. However, omitting this setting has not been tested  
# with Oracle E-Business Suite. For optimum performance, the minimum (and  
# recommended) value is 1. The value can be increased to meet specific  
# needs. For example, increasing the value to 2 can help reduce excessive  
# queue lengths.  
########

aq_tm_processes = 1

* * *

#### Section 2.4.1: Removal List for Oracle Database 10gR2 (10.2.X):

If they exist, you should remove the following database initialization
parameters from your database initialization parameters file for 10gR2:

_always_anti_join  
_always_semi_join  
_complex_view_merging  
_index_join_enabled  
_kks_use_mutex_pin #Unless using HP-UX - see "Other parameters" section above.  
_new_initial_join_orders  
_optimizer_cost_based_transformation  
_optimizer_cost_model  
_optimizer_mode_force  
_optimizer_undo_changes  
_or_expand_nvl_predicate  
_ordered_nested_loop  
_push_join_predicate  
_push_join_union_view  
_shared_pool_reserved_min_alloc  
_sortmerge_inequality_join_off  
_table_scan_cost_plus_one  
_unnest_subquery  
_use_column_stats_for_function  
always_anti_join  
always_semi_join  
db_block_buffers  
db_file_multiblock_read_count  
db_cache_size  
enqueue_resources  
event="10932 trace name context level 32768"  
event="10933 trace name context level 512"  
event="10943 trace name context forever, level 2"  
event="10943 trace name context level 16384"  
event="38004 trace name context forever, level 1"  
hash_area_size  
java_pool_size  
job_queue_interval  
large_pool_size  
max_enabled_roles  
optimizer_dynamic_sampling  
optimizer_features_enable  
optimizer_index_caching  
optimizer_index_cost_adj  
optimizer_max_permutations  
optimizer_mode  
optimizer_percent_parallel  
plsql_compiler_flags  
query_rewrite_enabled  
row_locking  
sort_area_size  
undo_retention  
undo_suppress_errors

* * *

### Section 2.5: Release-Specific Database Initialization Parameters for 11gR1
(11.1.X)

####################################################################  
#  
# Oracle Applications Release 11i - database initialization parameters  
#  
# This section contains the release-specific database initialization
parameters  
# for 11gR1. Oracle Applications Release 11i requires a minimum of 11.1.0.6.

#########  
#  
# Compatible  
#  
# Compatibility should be set to the current release.  
#  
#########  
  
compatible = 11.1.0

########  
#  
# Diagnostic Parameters  
#  
# As of Oracle Database 11g Release 1, the diagnostics for each database  
# instance are located in a dedicated directory that can be specified  
# via the DIAGNOSTIC_DEST initialization parameter. The format of  
# the directory specified by DIAGNOSTIC_DEST is as follows:  
# <diagnostic_dest>/diag/rdbms/<dbname>/<instname>  
#  
# Trace files -located in subdirectory
<diagnostic_dest>/diag/rdbms/<dbname>/<instname>/trace  
# Alert logs - located in subdirectory
<diagnostic_dest>/diag/rdbms/<dbname>/<instname>/alert  
# Core files - located in subdirectory
<diagnostic_dest>/diag/rdbms/<dbname>/<instname>/cdumd  
# Incident dump files - located
<diagnostic_dest>/diag/rdbms/<dbname>/<instname>/incident/<incdir#>  
  
diagnostic_dest = ?/prod11i

########  
#  
# Cache Sizes  
#  
# For 11g, the automatic SGA tuning option (sga_target) is required.  
# This avoids the need for individual tuning of the different  
# SGA caches, such as the buffer cache, shared pool, and large  
# pool. Use of the automatic SGA tuning option also improves  
# manageability and overall performance.  
#  
# sga_target refers to the total size of the SGA. This includes  
# all the sub-caches, such as the buffer cache, log buffer,  
# shared pool, and large pool. The sizing table in the  
# section Database Initialization Parameter Sizing contains  
# sizing recommendations for sga_target.  
#  
# When the automatic SGA tuning option is used to dynamically size  
# the individual caches, it is recommended to use a Server Parameter  
# file (SPFILE) to store the initialization parameter values.  
# Using an SPFILE allows the dynamically-adjusted values to persist  
# across restarts. Refer to the Oracle 11g Database Administrator's  
# Guide for information on how to create and maintain an SPFILE.  
#  
#  
########  
  
sga_target = 1G

########  
#  
# Shared Pool  
#  
# The shared pool should be tuned so as to minimize contention for SQL  
# and PL/SQL objects. A value of 400M is a reasonable starting point for  
# Release 11i, and automatic SGA tuning will adjust the caches as per  
# the workload. The values below for the shared pool related caches are  
# simply minimum (starting) values.  
#  
########  
  
shared_pool_size = 400M  
shared_pool_reserved_size = 40M

#########  
#  
# NLS and Character Sets  
#  
#########  
  
nls_length_semantics = BYTE #MP

########  
#  
# Rollback Segments  
#  
# From 9iR2, Oracle Applications requires the use of System Managed Undo.  
# This is straightforward to manage and administer, much more efficient  
# than manually managed rollback segments, and reduces the chances of  
# "snapshot too old" errors. To use System Managed Undo, you must create  
# an UNDO tablespace.  
#  
########  
  
undo_management=AUTO #MP  
undo_tablespace=apps_undots1 #MP

########  
#  
# Private Memory Areas  
#  
# The Automatic Memory Manager is used to manage PGA memory. This avoids  
# the need to tune sort_area_size and hash_area_size manually.  
#  
# The Automatic Memory Manager also improves performance and scalability,  
# as memory is released back to the operating system.  
#  
########  
  
pga_aggregate_target = 1G  
workarea_size_policy = AUTO #MP  
olap_page_pool_size = 4194304

########  
#  
# Cursor-Related Settings  
#  
# Prior to 10g, PL/SQL (server-side) used the setting of the open_cursors  
# parameter as the upper limit for caching PL/SQL (server-side) cursors.  
# In 10g, the upper limit was controlled by the parameter
session_cached_cursors.  
#  
# 11g changes the default behavior for the server side PL/SQL cursor cache.  
# For 11g environments, the parameters open_cursors and session_cached_cursors  
# should be set as follows, in accordance with this change in behavior.  
#  
########  
  
open_cursors = 600  
session_cached_cursors = 500

########  
#  
# Events  
#  
# Events should not be set unless specifically requested by Oracle Support,  
# or in Applications documentation.  
#  
########

#########  
#  
# PL/SQL Parameters  
#  
# The following parameters are used to enable the PL/SQL global optimizer  
# and specify the compilation type.  
#  
# Release 11i environments that use Oracle Database 11g can employ either  
# interpreted or compiled (native) PL/SQL code. The default is interpreted.  
# While native PL/SQL compilation can improve runtime performance, this may  
# be at the expense of increased downtime, because of the need to generate  
# and compile the native shared libraries.

# If native compilation is to be used, uncomment the plsql_code_type = NATIVE  
# line below. Note that in 11g, the parameters plsql_native_library_dir and  
# plsql_native_library_subdir_count have no effect and are are not needed, as  
# natively compiled code is now stored in the database, not a filesystem.  
  
# plsql_code_type = NATIVE # Uncomment if you want to use NATIVE compilation

#########  
#  
# Optimizer Parameters  
#  
# Release 11i uses the Cost Based Optimizer (CBO). The following optimizer  
# parameters must be set as shown, and should not be changed.  
#  
#########  
  
_b_tree_bitmap_plans = FALSE #MP  
optimizer_secure_view_merging = FALSE #MP  
_optimizer_autostats_job=false #MP Turn off automatic statistics

#########  
#  
# Database Password Case Sensitivity (new with Oracle Database 11g)  
#  
# Database password case sensitivity is a new feature available with 11g.  
# Oracle E-Business Suite does not currently integrate with this feature,  
# so the parameter must be set to FALSE.  
#  
#########  
  
sec_case_sensitive_logon = FALSE #MP

#########  
#  
# Advanced Queuing (AQ) and Job Queues  
#  
# In 10gR1 and higher, aq_tm_processes is auto-tuned and should no longer  
# need to be specified. However, omitting this setting has not been tested  
# with Oracle E-Business Suite. For optimum performance, the minimum (and  
# recommended) value is 1. The value can be increased to meet specific  
# needs. For example, increasing the value to 2 can help reduce excessive  
# queue lengths.  
########

aq_tm_processes = 1

* * *

#### Section 2.5.1: Removal List for Oracle Database 11g Release 1 (11.1.X):

If they exist, you should remove the following database initialization
parameters from your database initialization parameters file for Oracle
Database 11g Release 1 (11.1.0.6):

_always_anti_join  
_always_semi_join  
_complex_view_merging  
_index_join_enabled  
_kks_use_mutex_pin  
_new_initial_join_orders  
_optimizer_cost_based_transformation  
_optimizer_cost_model  
_optimizer_mode_force  
_optimizer_undo_changes  
_or_expand_nvl_predicate  
_ordered_nested_loop  
_push_join_predicate  
_push_join_union_view  
_shared_pool_reserved_min_alloc  
_sortmerge_inequality_join_off  
_sqlexec_progression_cost  
_table_scan_cost_plus_one  
_unnest_subquery  
_use_column_stats_for_function  
always_anti_join  
always_semi_join  
background_dump_dest  
core_dump_dest  
db_block_buffers  
db_file_multiblock_read_count  
db_cache_size  
enqueue_resources  
event="10932 trace name context level 32768"  
event="10933 trace name context level 512"  
event="10943 trace name context forever, level 2"  
event="10943 trace name context level 16384"  
event="38004 trace name context forever, level 1"  
hash_area_size  
java_pool_size  
job_queue_interval  
large_pool_size  
max_enabled_roles  
nls_language  
optimizer_dynamic_sampling  
optimizer_features_enable  
optimizer_index_caching  
optimizer_index_cost_adj  
optimizer_max_permutations  
optimizer_mode  
optimizer_percent_parallel  
plsql_compiler_flags  
plsql_optimize_level  
plsql_native_library_dir  
plsql_native_library_subdir_count  
query_rewrite_enabled  
rollback_segments  
row_locking  
sort_area_size  
sql_trace  
timed_statistics  
undo_retention  
undo_suppress_errors  
user_dump_dest

* * *

### Section 2.6: Release-Specific Database Initialization Parameters for 11gR2
(11.2.X)

####################################################################  
#  
# Oracle Applications Release 11i - database initialization parameters  
#  
# This section contains the release-specific database  
# initialization parameters for 11gR2.  

#########  
#  
# Compatible  
#  
# Compatibility should be set to the current release.  
#  
#########  
  
compatible = 11.2.0

########  
#  
# Diagnostic Parameters  
#  
# As of Oracle Database 11g Release 1, the diagnostics for each database  
# instance are located in a dedicated directory that can be specified  
# via the DIAGNOSTIC_DEST initialization parameter. The format of  
# the directory specified by DIAGNOSTIC_DEST is as follows:  
# <diagnostic_dest>/diag/rdbms/<dbname>/<instname>  
#  
# Trace files -located in subdirectory
<diagnostic_dest>/diag/rdbms/<dbname>/<instname>/trace  
# Alert logs - located in subdirectory
<diagnostic_dest>/diag/rdbms/<dbname>/<instname>/alert  
# Core files - located in subdirectory
<diagnostic_dest>/diag/rdbms/<dbname>/<instname>/cdumd  
# Incident dump files - located
<diagnostic_dest>/diag/rdbms/<dbname>/<instname>/incident/<incdir#>  
  
diagnostic_dest = ?/prod11i

########  
#  
# Cache Sizes  
#  
# For 11g, the automatic SGA tuning option (sga_target) is required.  
# This avoids the need for individual tuning of the different  
# SGA caches, such as the buffer cache, shared pool, and large  
# pool. Use of the automatic SGA tuning option also improves  
# manageability and overall performance.  
#  
# sga_target refers to the total size of the SGA. This includes  
# all the sub-caches, such as the buffer cache, log buffer,  
# shared pool, and large pool. The sizing table in the  
# section Database Initialization Parameter Sizing contains  
# sizing recommendations for sga_target.  
#  
# When the automatic SGA tuning option is used to dynamically size  
# the individual caches, it is recommended to use a Server Parameter  
# file (SPFILE) to store the initialization parameter values.  
# Using an SPFILE allows the dynamically-adjusted values to persist  
# across restarts. Refer to the Oracle 11g Database Administrator's  
# Guide for information on how to create and maintain an SPFILE.  
#  
#  
########  
  
sga_target = 1G

########  
#  
# Shared Pool  
#  
# The shared pool should be tuned so as to minimize contention for SQL  
# and PL/SQL objects. A value of 400M is a reasonable starting point for  
# Release 11i, and automatic SGA tuning will adjust the caches as per  
# the workload. The values below for the shared pool related caches are  
# simply minimum (starting) values.  
#  
########  
  
shared_pool_size = 400M  
shared_pool_reserved_size = 40M

#########  
#  
# NLS and Character Sets  
#  
#########  
  
nls_length_semantics = BYTE #MP

########  
#  
# Rollback Segments  
#  
# From 9iR2, Oracle Applications requires the use of System Managed Undo.  
# This is straightforward to manage and administer, much more efficient  
# than manually managed rollback segments, and reduces the chances of  
# "snapshot too old" errors. To use System Managed Undo, you must create  
# an UNDO tablespace.  
#  
########  
  
undo_management=AUTO #MP  
undo_tablespace=apps_undots1 #MP

########  
#  
# Private Memory Areas  
#  
# The Automatic Memory Manager is used to manage PGA memory. This avoids  
# the need to tune sort_area_size and hash_area_size manually.  
#  
# The Automatic Memory Manager also improves performance and scalability,  
# as memory is released back to the operating system.  
#  
########  
  
pga_aggregate_target = 1G  
workarea_size_policy = AUTO #MP  
olap_page_pool_size = 4194304

########  
#  
# Cursor-Related Settings  
#  
# Prior to 10g, PL/SQL (server-side) used the setting of the open_cursors  
# parameter as the upper limit for caching PL/SQL (server-side) cursors.  
# In 10g, the upper limit was controlled by the parameter
session_cached_cursors.  
#  
# 11g changes the default behavior for the server side PL/SQL cursor cache.  
# For 11g environments, the parameters open_cursors and session_cached_cursors  
# should be set as follows, in accordance with this change in behavior.  
#  
########  
  
open_cursors = 600  
session_cached_cursors = 500

########  
#  
# Events  
#  
# Events should not be set unless specifically requested by Oracle Support,  
# or in Applications documentation.  
#  
########

#########  
#  
# PL/SQL Parameters  
#  
# The following parameters are used to enable the PL/SQL global optimizer  
# and specify the compilation type.  
#  
# Release 11i environments that use Oracle Database 11g can employ either  
# interpreted or compiled (native) PL/SQL code. The default is interpreted.  
# While native PL/SQL compilation can improve runtime performance, this may  
# be at the expense of increased downtime, because of the need to generate  
# and compile the native shared libraries.

# If native compilation is to be used, uncomment the plsql_code_type = NATIVE  
# line below. Note that in 11g, the parameters plsql_native_library_dir and  
# plsql_native_library_subdir_count have no effect and are are not needed, as  
# natively compiled code is now stored in the database, not a filesystem.  
  
# plsql_code_type = NATIVE # Uncomment if you want to use NATIVE compilation

#########  
#  
# Optimizer Parameters  
#  
# Release 11i uses the Cost Based Optimizer (CBO). The following optimizer  
# parameters must be set as shown, and should not be changed.  
#  
#########  
  
_b_tree_bitmap_plans = FALSE #MP  
optimizer_secure_view_merging = FALSE #MP  
_optimizer_autostats_job=false #MP Turn off automatic statistics

#########  
#  
# Parallel Execution and Oracle RAC parameters  
#  
# It is recommended to set the parameters PARALLEL_FORCE_LOCAL  
# on each instance, to ensure that parallel requests do not span instances.  
# As of 11gR2, EBS customers must set the value of this parameter to TRUE  
# and then are no longer required to set parallel_instance_groups and  
# instance groups for the purpose of preventing inter-instance sql  
# parallelism in RAC environments.  
#  
#########

parallel_force_local=TRUE #MP

#########  
#  
# Database Password Case Sensitivity (new with Oracle Database 11g)  
#  
# Database password case sensitivity is a new feature available with 11g.  
# Oracle E-Business Suite does not currently integrate with this feature,  
# so the parameter must be set to FALSE.  
#  
#########  
  
sec_case_sensitive_logon = FALSE #MP

#########  
#  
# Advanced Queuing (AQ) and Job Queues  
#  
# In 10gR1 and higher, aq_tm_processes is auto-tuned and should no longer  
# need to be specified. However, omitting this setting has not been tested  
# with Oracle E-Business Suite. For optimum performance, the minimum (and  
# recommended) value is 1. The value can be increased to meet specific  
# needs. For example, increasing the value to 2 can help reduce excessive  
# queue lengths.  
  
########

aq_tm_processes = 1

* * *

#### Section 2.6.1: Removal List for Oracle Database 11g Release 2

If they exist, you should remove the following database initialization
parameters from your database initialization parameters file for Oracle
Database 11g Release 2 (11.2.0.1):

_always_anti_join  
_always_semi_join  
_complex_view_merging  
_index_join_enabled  
_kks_use_mutex_pin  
_new_initial_join_orders  
_optimizer_cost_based_transformation  
_optimizer_cost_model  
_optimizer_mode_force  
_optimizer_undo_changes  
_or_expand_nvl_predicate  
_ordered_nested_loop  
_push_join_predicate  
_push_join_union_view  
_shared_pool_reserved_min_alloc  
_sortmerge_inequality_join_off  
_sqlexec_progression_cost  
_table_scan_cost_plus_one  
_unnest_subquery  
_use_column_stats_for_function  
always_anti_join  
always_semi_join  
background_dump_dest  
core_dump_dest  
db_block_buffers  
db_file_multiblock_read_count  
db_cache_size  
enqueue_resources  
event="10932 trace name context level 32768"  
event="10933 trace name context level 512"  
event="10943 trace name context forever, level 2"  
event="10943 trace name context level 16384"  
event="38004 trace name context forever, level 1"  
hash_area_size  
java_pool_size  
job_queue_interval  
large_pool_size  
max_enabled_roles  
nls_language  
optimizer_dynamic_sampling  
optimizer_features_enable  
optimizer_index_caching  
optimizer_index_cost_adj  
optimizer_max_permutations  
optimizer_mode  
optimizer_percent_parallel  
plsql_compiler_flags  
plsql_optimize_level  
plsql_native_library_dir # Do not remove if using HP-UX (PA-RISC).  
plsql_native_library_subdir_count # Do not remove if using HP-UX (PA-RISC).  
query_rewrite_enabled  
row_locking  
rollback_segments  
row_locking  
sort_area_size  
sql_trace  
timed_statistics  
undo_retention  
undo_suppress_errors  
user_dump_dest  
DRS_START  
SQL_VERSION

* * *

### Section 2.7: Release-Specific Database Initialization Parameters for 12cR1
(12.1.X)

####################################################################  
#  
# Oracle Applications Release 11i - database initialization parameters  
#  
# This section contains the release-specific database  
# initialization parameters for 12cR1.

#########  
#  
# Compatible  
#  
# Compatibility should be set to the current release.  
#  
#########  
  
compatible = 12.1.0

########  
#  
# Diagnostic Parameters  
#  
# As of Oracle Database 11g Release 1, the diagnostics for each database  
# instance are located in a dedicated directory that can be specified  
# via the DIAGNOSTIC_DEST initialization parameter. The format of  
# the directory specified by DIAGNOSTIC_DEST is as follows:  
# <diagnostic_dest>/diag/rdbms/<dbname>/<instname>  
#  
# Trace files -located in subdirectory
<diagnostic_dest>/diag/rdbms/<dbname>/<instname>/trace  
# Alert logs - located in subdirectory
<diagnostic_dest>/diag/rdbms/<dbname>/<instname>/alert  
# Core files - located in subdirectory
<diagnostic_dest>/diag/rdbms/<dbname>/<instname>/cdumd  
# Incident dump files - located
<diagnostic_dest>/diag/rdbms/<dbname>/<instname>/incident/<incdir#>  
  
diagnostic_dest = ?/prod11i  

########  
#  
# Cache Sizes  
#  
# For 11g, the automatic SGA tuning option (sga_target) is required.  
# This avoids the need for individual tuning of the different  
# SGA caches, such as the buffer cache, shared pool, and large  
# pool. Use of the automatic SGA tuning option also improves  
# manageability and overall performance.  
#  
# sga_target refers to the total size of the SGA. This includes  
# all the sub-caches, such as the buffer cache, log buffer,  
# shared pool, and large pool. The sizing table in the  
# section Database Initialization Parameter Sizing contains  
# sizing recommendations for sga_target.  
#  
# When the automatic SGA tuning option is used to dynamically size  
# the individual caches, it is recommended to use a Server Parameter  
# file (SPFILE) to store the initialization parameter values.  
# Using an SPFILE allows the dynamically-adjusted values to persist  
# across restarts. Refer to the Oracle 11g Database Administrator's  
# Guide for information on how to create and maintain an SPFILE.  
#  
#  
########  
  
sga_target = 2G #MP

########  
#  
# Shared Pool  
#  
# The shared pool should be tuned so as to minimize contention for SQL  
# and PL/SQL objects. A value of 400M is a reasonable starting point for  
# Release 11i, and automatic SGA tuning will adjust the caches as per  
# the workload. The values below for the shared pool related caches are  
# simply minimum (starting) values.  
#  
########  
  
shared_pool_size = 400M  
shared_pool_reserved_size = 40M

#########  
#  
# NLS and Character Sets  
#  
#########  
  
nls_length_semantics = BYTE #MP

########  
#  
# Rollback Segments  
#  
# From 9iR2, Oracle Applications requires the use of System Managed Undo.  
# This is straightforward to manage and administer, much more efficient  
# than manually managed rollback segments, and reduces the chances of  
# "snapshot too old" errors. To use System Managed Undo, you must create  
# an UNDO tablespace.  
#  
########  
  
undo_management=AUTO #MP  
undo_tablespace=apps_undots1 #MP

########  
#  
# Private Memory Areas  
#  
# The Automatic Memory Manager is used to manage PGA memory. This avoids  
# the need to tune sort_area_size and hash_area_size manually.  
#  
# The Automatic Memory Manager also improves performance and scalability,  
# as memory is released back to the operating system.  
#  
########  
  
pga_aggregate_target = 1G  
workarea_size_policy = AUTO #MP  
olap_page_pool_size = 4194304

########  
#  
# Cursor-Related Settings  
#  
# Prior to 10g, PL/SQL (server-side) used the setting of the open_cursors  
# parameter as the upper limit for caching PL/SQL (server-side) cursors.  
# In 10g, the upper limit was controlled by the parameter
session_cached_cursors.  
#  
# 11g changes the default behavior for the server side PL/SQL cursor cache.  
# For 11g environments, the parameters open_cursors and session_cached_cursors  
# should be set as follows, in accordance with this change in behavior.  
#  
########  
  
open_cursors = 600  
session_cached_cursors = 500

########  
#  
# Events  
#  
# Events should not be set unless specifically requested by Oracle Support,  
# or in Applications documentation.  
#  
########

#########  
#  
# PL/SQL Parameters  
#  
# The following parameters are used to enable the PL/SQL global optimizer  
# and specify the compilation type.  
#  
# Release 11i environments that use Oracle Database 11g can employ either  
# interpreted or compiled (native) PL/SQL code. The default is interpreted.  
# While native PL/SQL compilation can improve runtime performance, this may  
# be at the expense of increased downtime, because of the need to generate  
# and compile the native shared libraries.

# If native compilation is to be used, uncomment the plsql_code_type = NATIVE  
# line below. Note that in 11g, the parameters plsql_native_library_dir and  
# plsql_native_library_subdir_count have no effect and are are not needed, as  
# natively compiled code is now stored in the database, not a filesystem.  
  
# plsql_code_type = NATIVE # Uncomment if you want to use NATIVE compilation

#########  
#  
# Optimizer Parameters  
#  
# Release 11i uses the Cost Based Optimizer (CBO). The following optimizer  
# parameters must be set as shown, and should not be changed.  
#  
#########  
  
_b_tree_bitmap_plans = FALSE #MP  
optimizer_secure_view_merging = FALSE #MP  
_optimizer_autostats_job=false #MP Turn off automatic statistics

#########  
#  
# Parallel Execution and Oracle RAC parameters  
#  
# It is recommended to set the parameters PARALLEL_FORCE_LOCAL  
# on each instance, to ensure that parallel requests do not span instances.  
# As of 11gR2, EBS customers must set the value of this parameter to TRUE  
# and then are no longer required to set parallel_instance_groups and  
# instance groups for the purpose of preventing inter-instance sql  
# parallelism in RAC environments.  
#  
#########

parallel_force_local=TRUE #MP

#########  
#  
# PGA_AGGREGATE_LIMIT feature in 12c limits PGA memory usage  
#  
# The default value of PGA_AGGREGATE_LIMIT is set to the greater of 2 GB,  
# 200% of PGA_AGGREGATE_TARGET, and 3 MB times the PROCESSES parameter.  
# It will not exceed 120% of the physical memory size minus the total SGA
size.  
#  
# PGA_AGGREGATE_LIMIT cannot be set below its default value. If a value of 0
is specified,  
# it means there is no limit to the aggregate PGA memory consumed by the
instance.  
# If total PGA memory usage is over PGA_AGGREGATE_LIMIT value. The sessions or
processes  
# that are consuming the most untunable PGA memory will be terminated.  
#  
# Recommended value for PGA_AGGREGATE_LIMIT is 0.  
#  
##########

pga_aggregate_limit = 0

#########  
#  
# TEMP_UNDO_ENABLED is a new feature in 12c. it helps in reducing the amount
of redo caused by DML  
# on global temporary tables. If this parameter is set to TRUE it eliminates
REDO on the permanent UNDO.  
# Recommended value for TEMP_UNDO_ENABLED is TRUE  
#  
##########

temp_undo_enabled = true

#########  
#  
# Database Password Case Sensitivity (new with Oracle Database 11g)  
#  
# Database password case sensitivity is a new feature available with 11g.  
# Oracle E-Business Suite does not currently integrate with this feature,  
# so the parameter must be set to FALSE.  
# Even though its deprecated in 12c, but the parameter is needed to default it
to false for Oracle E-Business Suite.  
#########  
  
sec_case_sensitive_logon = FALSE #MP

#########  
#  
# Advanced Queuing (AQ) and Job Queues  
#  
# In 10gR1 and higher, aq_tm_processes is auto-tuned and should no longer  
# need to be specified. However, omitting this setting has not been tested  
# with Oracle E-Business Suite. For optimum performance, the minimum (and  
# recommended) value is 1. The value can be increased to meet specific  
# needs. For example, increasing the value to 2 can help reduce excessive  
# queue lengths.  
  
########

aq_tm_processes = 1

* * *

#### Section 2.7.1: Removal List for Oracle Database 12c Release 1

If they exist, you should remove the following database initialization
parameters from your database initialization parameters file for Oracle
Database 12c Release 1 (12.1.X):

_always_anti_join  
_always_semi_join  
_complex_view_merging  
_index_join_enabled  
_kks_use_mutex_pin  
_new_initial_join_orders  
_optimizer_cost_based_transformation  
_optimizer_cost_model  
_optimizer_mode_force  
_optimizer_undo_changes  
_or_expand_nvl_predicate  
_ordered_nested_loop  
_push_join_predicate  
_push_join_union_view  
_shared_pool_reserved_min_alloc  
_sortmerge_inequality_join_off  
_sqlexec_progression_cost  
_table_scan_cost_plus_one  
_unnest_subquery  
_use_column_stats_for_function  
always_anti_join  
always_semi_join  
background_dump_dest  
core_dump_dest  
db_block_buffers  
db_file_multiblock_read_count  
db_cache_size  
enqueue_resources  
event="10932 trace name context level 32768"  
event="10933 trace name context level 512"  
event="10943 trace name context forever, level 2"  
event="10943 trace name context level 16384"  
event="38004 trace name context forever, level 1"  
hash_area_size  
java_pool_size  
job_queue_interval  
large_pool_size  
max_enabled_roles  
nls_language  
optimizer_dynamic_sampling  
optimizer_features_enable  
optimizer_index_caching  
optimizer_index_cost_adj  
optimizer_max_permutations  
optimizer_mode  
optimizer_percent_parallel  
plsql_compiler_flags  
plsql_optimize_level  
plsql_native_library_dir # Do not remove if using HP-UX (PA-RISC).  
plsql_native_library_subdir_count # Do not remove if using HP-UX (PA-RISC).  
query_rewrite_enabled  
row_locking  
rollback_segments  
row_locking  
sort_area_size  
sql_trace  
timed_statistics  
undo_retention  
undo_suppress_errors  
user_dump_dest  
DRS_START  
SQL_VERSION

* * *

## Appendix A: Enabling System Managed Undo (SMU)

As of 9iR2, Oracle Applications Release 11i supports only the use of system
managed undo (SMU). SMU is more efficient than traditional rollback segments
and reduces the possibilities of “snapshot too old errors.” The following
steps should be used to enable system managed undo. These steps should be
performed following the upgrade to releases 9iR2 or higher, but prior to
restarting the Applications services.

#### Step 1:

Capture the tablespace names being used for the existing rollback segments
from dba_rollback_segs. Capture the datafiles and sizes being used for the
rollback tablespaces from dba_data_files.

SQL> select segment_name, tablespace_name  
from dba_rollback_segs;

SQL> select file_name, tablespace_name, bytes  
from dba_data_files  
where tablespace_name = '';

where is the tablespace name used by a rollback segment.

#### Step 2:

Drop all the private and public rollback segments except for the SYSTEM
rollback segment.

SQL> alter rollback segment offline;  
SQL> drop rollback segment ;

#### Step 3:

Drop the corresponding tablespace(s) where the rollback segments reside.

SQL> alter tablespace offline;  
SQL> drop tablespace ;

#### Step 4:

Create a new System Managed Undo tablespace per instance as follows:

create undo tablespace APPS_UNDOTS1  
datafile '' size reuse  
extent management local ;

For the path and the size values, you should reuse the same files and sizes
which were used in the tablespaces which were dropped in step 2. The sizes and
file names were captured in step 1.

If you are not running Oracle Real Application Clusters (Oracle RAC), then
only one tablespace is needed. If you are using Oracle RAC, you will need to
create one undo tablespace per instance, and set undo_tablespace
appropriately.

For example:

For instance 1, set undo_tablespace=APPS_UNDOTS1  
For instance 2, set undo_tablespace=APPS_UNDOTS2  
etc...

#### Step 5:

Set the following database initialization parameters:

undo_management = AUTO  
undo_tablespace = APPS_UNDOTS1

Refer to the sizing table (Database Initialization Parameters Sizing section)
for the appropriate setting of undo_retention.

#### Step 6:

Remove the database initialization parameter rollback_segments.

#### Step 7:

Restart the database so that the system managed undo takes effect.

* * *

## Appendix B: Temporary Tablespace Setup

It is recommended that the temporary tablespace for Oracle Applications users
should be created using locally managed temp files with uniform extent sizes
of 128K. This extent size is recommended because many modules such as Pricing
and Planning make extensive use of global temporary tables that also reside in
the temporary tablespace. Since each user instantiates a temporary segment for
these tables, large extent sizes may result in space allocation failures.

The following is an example of creating a locally managed temporary tablespace
with temp files:

SQL> drop tablespace temp;  
SQL> create temporary tablespace temp  
tempfile '/d2/prod11i/dbf/temp01.dbf' size 2000M reuse  
extent management local  
uniform size 128K;

* * *

## Appendix C: Applications Upgrade Section

### Upgrading from Release 10.7 and 11.0.X to Release 11i

If upgrading from 10.7 or 11.0 to 11.5.9 or earlier including an RDBMS upgrade
to 8.1.7.X, you should review the section [“Database initialization parameters
for 8iR3
(8.1.7.X)”](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153097281850763&id=216205.1&_adf.ctrl-
state=11dph05qcs_129#8iR3) of this document to ensure that your database
initialization parameter settings are set correctly as per this document in
both the Category 1 and Category 3 phases. Following the migration to 8.1.7.X,
ensure that you remove the events listed in the section “Removal list for 8iR3
(8.1.7.X).”

If upgrading from 10.7 or 11.0 to 11.5.9 or later including an RDBMS upgrade
to 9iR2, the upgrade to 9iR2 is only possible in the Category 3 step. You
should review the section [“Database initialization parameters for 9iR2
(9.2.0.X)”](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153097281850763&id=216205.1&_adf.ctrl-
state=11dph05qcs_129#9iR2) of this document to ensure that your database
initialization parameter settings are set correctly as per this document.
Also, the following events should be set throughout the 11i upgrade process:

event="10932 trace name context level 32768"  
event="10933 trace name context level 512"  
event="10943 trace name context level 16384"

Refer to the Upgrading Oracle Applications Manual for more details on removing
these events following the completion of the upgrade.

### Support for Upgrading to Oracle Applications 11.5.7 (or higher) and Oracle
Database 9i

Oracle Applications Release 11.5.7 (and higher) is certified with 9iR2. For
customers upgrading from previous releases of Applications such as 10.7 or
11.0 to Release 11.5.7 (or higher), you must follow the instructions in the
Upgrading Oracle Applications Manual to first migrate to 8.1.7.X and 11.5.7
(or higher). Once the upgrade process is complete, use the appropriate
interoperability guide to migrate the RDBMS to 9iR2.

### Oracle Applications Support for Oracle Database 10gR1

Oracle Applications Release 11.5.9 (and higher) is certified with 10gR1
requiring a minimum of 10.1.0.4. Refer to My Oracle Support Knowledge Document
[282038.1](http://metalink.oracle.com/metalink/plsql/ml2_documents.showNOT?p_id=282038.1)
for details.

### Oracle Applications Support for Oracle Database 10gR2

Oracle Applications Release 11.5.9 (and higher) is certified with 10gR2
requiring a minimum of 10.2.0.2. Refer to My Oracle Support Knowledge Document
[362203.1](http://metalink.oracle.com/metalink/plsql/ml2_documents.showNOT?p_id=362203.1)
for details.

### Setting the hash area and sort area sizes for upgrades

Many of the Applications upgrade scripts result in large hash joins and sorts.
If you are upgrading Oracle Applications and the data server release is 8.1.7,
it is recommended to set the hash_area_size and sort_area_size to 100M and 50M
respectively. Following the upgrade, you should reset the values of these
parameters to the recommended defaults as per the 8.1.7.X database
initialization parameters section. These parameters should not be set for
releases 9iR2 or higher as the auto memory manager is used for 9iR2 and 10gR1
based configurations.

########  
#  
# Sort Area & Hash Area  
#  
# The recommended values for upgrades are 50MB and 100MB  
# for sort_area_size and hash_area_size respectively.  
#  
########

sort_area_size = 52428800  
hash_area_size = 104857600

* * *

## Appendix D: Database Initialization Parameter Sizing

This section provides sizing recommendations based on the number of active
Oracle Applications users. The following table should be used to help size the
relevant parameters:

Parameter Name | Development/Test Instance  | 11–100 Users  | 101–500 Users  |
501–1000 Users  | 1000–2000 Users  
---|---|---|---|---|---  
Processes  | 200  | 200  | 800  | 1200  | 2500  
Sessions  | 400  | 400  | 1600  | 2400  | 5000  
db_block_buffers  | 20000  | 50000  | 150000  | 250000  | 400000  
db_cache_size [[Footnote
1]](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153097281850763&id=216205.1&_adf.ctrl-
state=11dph05qcs_129#fn2) | 156 MB  | 400 MB  | 1 GB  | 2 GB  | 3 GB  
sga_target [[Footnote
2]](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153097281850763&id=216205.1&_adf.ctrl-
state=11dph05qcs_129#fn3) | 1 GB  | 1 GB | 2 GB  | 3 GB  | 14 GB  
undo_retention [[Footnote
3]](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153097281850763&id=216205.1&_adf.ctrl-
state=11dph05qcs_129#fn4) | 1800  | 3600  | 7200  | 10800  | 14400  
Shared_pool_size (csp)  | N/A  | N/A  | N/A  | 1800 MB | 3000 MB  
Shared_pool_reserved_size (csp)  | N/A  | N/A  | N/A  | 180 MB  | 300 MB  
Shared_pool_size (no csp)  | 400 MB  | 600 MB  | 800 MB  | 1000 MB  | 2000 MB  
Shared_pool_reserved_size (no csp)  | 40 MB  | 60 MB  | 80 MB  | 100 MB  | 100
MB  
pga_aggregate_target [[Footnote
4]](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153097281850763&id=216205.1&_adf.ctrl-
state=11dph05qcs_129#fn5) | 1GB  | 2 GB  | 4 GB  | 10 GB  | 20 GB  
Total Memory Required [[Footnote
5]](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153097281850763&id=216205.1&_adf.ctrl-
state=11dph05qcs_129#fn6) | ~2 GB  | ~3 GB  | ~6 GB  | ~13 GB  | ~25 GB  
  
[Footnote 1]

  * The parameter db_cache_size should be used for 9i based environments in place of db_block_buffers.

[Footnote 2]

  * The parameter sga_target should be used for Oracle 10g or 11g or 12c based environments such as Release 11i. This replaces the parameter db_cache_size, which was used in Oracle 9i based environments. Also, it is not necessary to set the parameter undo_retention for 10g or 11g or 12c-based systems, since undo retention is set automatically as part of automatic undo tuning.
  * Database version 12c requires minimum required SGA memory to be set as 2GB or greater.  

  * Enabling the 11g or 12c Automatic Memory Management (AMM) feature is supported in EBS, and has been found to be useful in scenarios where memory is limited, as it will dynamically adjust the SGA and PGA pool sizes. AMM is enabled by using the memory_target and memory_max_target initialization parameters. MEMORY_TARGET specifies the system-wide sharable memory for Oracle to use when dynamically controlling the SGA and PGA as workloads change. The memory_max_target parameter specifies the maximum size that memory_target may take. AMM has proven useful for small to mid-range systems as it simplifies both the configuration and management. However, many customers with large production systems have experienced better performance with manually sized pools (or large minimum values for the pools). On Linux, Hugepages has resulted in improved performance; however, this configuration is not compatible with AMM. For large mission-critical applications systems, it is advisable to set sga_target with a minimum fixed value for shared_pool_size and pga_aggregate_target. 

[Footnote 3]

  * The values for undo_retention are recommendations only and this parameter should be adjusted according to the elapsed times of the concurrent jobs and corresponding commit windows. It is not required to set undo_retention for 10g based systems as undo retention is automatically set as part of automatic undo tuning. This parameter may be safely removed if you have a value of 900 or less. Setting this parameter to a value higher than 900 (default) is recommended if you experience ORA-1555: snapshot errors. AUTO undo is not supported for LOBS. 

[Footnote 4]

  * pga_aggregate_target should only be used with database instances based on 9 _i_ or higher. This parameter should not be set in 8 _i_ -based instances.

[Footnote 5]

  * The total memory required refers to the amount of memory required for the data server instance and associated memory including the SGA and the PGA. You should ensure that your system has sufficient available memory in order to support the values provided above. The values provided above should be adjusted based on available memory so as to prevent swapping and paging.

**General Notes on Table**

  * "Development or Test instance" refers to a small instance used only for development or testing, with no more than 10 users.
  * The range of user counts provided above refers to active Oracle E-Business Suite users, not total or named users. For example, if you plan to support a maximum of 500 active Oracle E-Business Suite users, then you should use the sizing as per the range 101-500 users.
  * The parameter values provided in this document reflect a small instance configuration, and you should adjust the relevant parameters based on the Oracle E-Business Suite user counts as listed in the table above.
  * The "csp" and "no csp" options of the shared pool parameters refer to the use of cursor_space_for_time, which is documented in the common database initialization parameters section.  

> **Note:** Enabling cursor_space_for_time can result in significantly larger
shared pool requirements.  
>

* * *

## Appendix E: Related Documentation

  * [My Oracle Support Knowledge Document 165195.1, _Using AutoConfig to Manage System Configurations with Oracle Applications 11i_](http://metalink.oracle.com/metalink/plsql/ml2_documents.showDocument?p_database_id=NOT&p_id=165195.1)
  * [My Oracle Support Knowledge Document ](http://metalink.oracle.com/metalink/plsql/ml2_documents.showDocument?p_database_id=NOT&p_id=165195.1)[207159.1, _Oracle E-Business Suite Release 11i Technology Stack Documentation Roadmap_](http://metalink.oracle.com/metalink/plsql/ml2_documents.showDocument?p_database_id=NOT&p_id=207159.1)

* * *

## Change Log

**Date**

|

**Description**  
  
---|---  
20-Sep-2013 |

  * Added Section 2.7: Release-Specific Database Initialization Parameters for 12cR1 (12.1.X).
  * Added parallel_force_local to Section 2.6.
  * Modified "Appendix D: Database Initialization Parameter Sizing".
  * Fixed formatting issues.

  
08-Aug-2009 |

  * Updated Section 2 introduction. 
  * Renumbered sections such that the removal lists are now subordinate to their respective release-specific parameter lists. 
  * Reformatted table in Appendix D. 

  
05-Aug-2009 |

  * Updated text in the common section introduction, parameter comments, and Appendix D 
  * Updated undo_retention section in Appendix D. 
  * Added #MP to _optimizer_autostats_job=false. 

  
29-Jul-2009 |

  * Amended contents listing to match actual section headings. 
  * Updated references from "Oracle _MetaLink_ Note" to "My Oracle Support Knowledge Document", and added mssing links. 

  
20-Jul-2009 |

  * Added Oracle Database 11g Release 2 (11.2.0.1) section. 
  * Added removal list for Oracle Database 11g Release 1. 
  * Added Advanced Queuing (AQ) notes to 10gR1, 10gR2, and 11gR1 sections. 
  * Added diagnostic_dest to 11gR1 section. 
  * Added background_dump_dest, user_dump_dest, core_dump_dest to 11gR1 removal list. 
  * Added plsql_native_library_dir, plsql_native_library_subdir_count to 11gR1removal list. 
  * Added db_file_multiblock_read_count to 10gR2 (10.2.X) removal list. 

  
13-Oct-2008 |

  * Corrected refererences to parameter name _optimizer_cost_based_transformation by removing extraneous "s" at end. 

  
21-Jul-2008 |

  * Added references to related documentation. 

  
27-Jun-2008 |

  * Added _kks_use_mutex_pin to 10.2.X removal section, plus note that it should be set to FALSE on HP-UX. 

  
13-May-2008 |

  * Added explanatory text regarding purpose of the removal lists. 

  
20-Mar-2008 |

  * Added 11gR1 (11.1.0.6) section. 

  
18-Mar-2008 |

  * Removed undo_retention parameter from 9iR2 removal list. 

  
30-Aug-2007 |

  * Amended references to plsql_code_type default from NATIVE to INTERPRETED, and rewrote associated text. 

  
09-Apr-2006 |

  * Added 10gR2 MetaLink note reference. 

  
20-Mar-2006 |

  * Added 10gR2 (10.2.0.2) section. 

  
  
##### Note 216205.1 by Oracle E-Business Suite Development  
Copyright © 2006, 2013, Oracle

## References

  
  
  
  
  
  
  
  
  
  
  


---
### NOTE ATTRIBUTES
>Created Date: 2018-01-22 02:50:02  
>Last Evernote Update Date: 2018-10-01 15:44:49  
>author: YangKwong  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=153097281850763  
>source-url: &  
>source-url: id=216205.1  
>source-url: &  
>source-url: _adf.ctrl-state=11dph05qcs_129  