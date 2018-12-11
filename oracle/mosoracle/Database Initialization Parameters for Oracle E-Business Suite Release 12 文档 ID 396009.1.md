# Database Initialization Parameters for Oracle E-Business Suite Release 12
(文档 ID 396009.1)

  

|

|

#### In This Document

  * [Section 1: Common Database Initialization Parameters For All Releases](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=152880042070510&id=396009.1&_adf.ctrl-state=11dph05qcs_72#commonparams)
  * [Section 2: Release-Specific Database Initialization Parameters For Oracle 10g Release 2](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=152880042070510&id=396009.1&_adf.ctrl-state=11dph05qcs_72#specificparams10gR2)
  * [Section 3: Release-Specific Database Initialization Parameters For Oracle 11g Release 1](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=152880042070510&id=396009.1&_adf.ctrl-state=11dph05qcs_72#specificparams11gR1)
  * [Section 4: Release-Specific Database Initialization Parameters For Oracle 11g Release 2](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=152880042070510&id=396009.1&_adf.ctrl-state=11dph05qcs_72#specificparams11gR2)
  * [Section 5: Release-Specific Database Initialization Parameters For Oracle 12c Release 1 ](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=152880042070510&id=396009.1&_adf.ctrl-state=11dph05qcs_72#specificparams12c)
  * [Section 6: Additional Database Initialization Parameters For Oracle E-Business Suite Release 12.2 ](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=152880042070510&id=396009.1&_adf.ctrl-state=11dph05qcs_72#specificparams12.2)
  * [Section 7: Using System Managed Undo (SMU)](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=152880042070510&id=396009.1&_adf.ctrl-state=11dph05qcs_72#smu)
  * [Section 8: Temporary Tablespace Setup](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=152880042070510&id=396009.1&_adf.ctrl-state=11dph05qcs_72#temptablespace)
  * [Section 9: Database Initialization Parameter Sizing](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=152880042070510&id=396009.1&_adf.ctrl-state=11dph05qcs_72#initsizing)

The most current version of this document can be obtained in My Oracle Support
< Document 396009.1 >.

There is a [change
log](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=152880042070510&id=396009.1&_adf.ctrl-
state=11dph05qcs_72#changelog) at the end of this document.

#### Key Points

  * The document consists of a common section, which provides a common set of database initialization parameters used for all releases of the Oracle Database, followed by several release-specific sections, which list parameters and settings required for a particular release of the Oracle Database.
  * Put together, the parameters from the common section and appropriate release-specific section formulate a complete set of database initialization parameters.
  * Parameters may appear on a "removal list" because they are obsolete; because the default value is required and no other value may be set; or to cater for certain special cases where a non-default value has to be set to meet specific needs (currently, there is only one such case, which is described in Section 7). 
  * In the various parameter lists, check for comments giving any platform-specific exceptions. Such comments will apply only to the exact platform mentioned: for example, a reference to HP-UX (PA-RISC) will not apply to HP-UX (Itanium IA-64).
  * The "X" notation used in the release-specific section denotes all patchset releases within that major version. For example, "10.2.0.X" refers to all releases of 10.2.0, such as 10.2.0.2 and 10.2.0.3.
  * Oracle E-Business Suite Release 12 requires Oracle Database 10g Release 2 (10.2.0.2) Enterprise Edition as a minimum release level and edition. No earlier releases, or other editions of any release, may be used.
  * Oracle E-Business Suite Release 12.2 requires Oracle Database 11g Release 2 (11.2.0.3) Enterprise Edition as a minimum release level and edition. No earlier releases, or other editions of any release, may be used. Refer to [Section 6: Additional Database Initialization Parameters For Oracle E-Business Suite Release 12.2](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=152880042070510&id=396009.1&_adf.ctrl-state=11dph05qcs_72#specificparams12.2). 
  * Oracle E-Business Suite Release 12.1.3 and 12.2 customers with Oracle Database 12c Release 1 Version 12.1.0.2 implementing Oracle Database In-Memory should refer to [Oracle Database Administrator's Guide 12c Release 1 (12.1) E41484](http://docs.oracle.com/database/121/ADMIN/toc.htm) for the required set of database initialization parameters.
  * Oracle E-Business Suite Exadata customers with any of the certified combinations listed in the [Certifications database on My Oracle Support](https://support.oracle.com/epmos/faces/CertifyHome), implementing Oracle E-Business Suite on Exadata machine should refer to [Oracle E-Business Suite and Oracle Maximum Availability Architecture Best Practices white paper](http://www.oracle.com/technetwork/database/availability/ebs-maa-2158952.pdf) for the required set of EXA specific database initialization parameters and Exadata best practices.

## **Section 1:** Common Database Initialization Parameters For All Releases

This section lists the database initialization parameters that are common
across releases of the Oracle Database. You should refer to it in conjunction
with the relevant release-specific section.

**Note:** All parameters listed in this section should be set as stated,
unless your particular release-specific section instructs otherwise.

The parameter values provided in this document reflect a small instance
configuration (see Section 9). You should adjust the relevant parameters based
on the number of active Oracle E-Business Suite users. In addition, you should
investigate any parameters that are set but not mentioned in this document.

`##############################################################################  
#  
# Oracle E-Business Suite Release 12  
# Common Database Initialization Parameters  
#  
# The following represents the common database initialization  
# parameters file for Oracle E-Business Suite Release 12.  
# Release-specific parameters are included in the respective release  
# section. The release-specific parameters should be appended to the  
# common database initialization parameter file.  
#  
# There are numerous mandatory database initialization parameters.  
# Their settings must not be altered. The use of values other than  
# those provided in this document will not be supported unless Oracle  
# Support has specifically instructed you to alter these parameters  
# from their mandatory settings.  
#  
# Mandatory parameters are denoted with the #MP symbol as a  
# comment. This includes parameters such as NLS and optimizer  
# related parameters.  
#  
# The remaining (non-mandatory) parameters relate to either sizing or  
# configuration requirements that are specific to customer environments  
# or system capacity. A sizing table provides recommendations and  
# guidelines based on the number of deployed and active Oracle  
# E-Business Suite users. Customers can adjust these parameters as per  
# their environment and system resource capacity.  
#  
##############################################################################  
  
  
##########  
#  
# Database identification parameters  
#  
# The database identification parameters define the name of the  
# `database `and the names of the database control files.  
#  
# The database name is established when the database is built, `and`  
# for most customers it matches the instance name. It should not  
# normally be necessary to change the database name, except for  
# the purposes of database cloning.  
#  
# There should be at least two control files, preferably three,  
# located on different volumes in case one of the volumes fails.  
# Control files can expand, hence you should allow at least 20M  
# per file for growth.  
#  
#########  
  
db_name = prodr12  
control_files = ('/disk1/prodr12_DB/cntrlprodr12_1.dbf',  
'/disk2/prodr12_DB/cntrlprodr12_2.dbf',  
'/disk3/prodr12_DB/cntrlprodr12_3.dbf')  
  
  
#########  
#  
# Database block size parameter  
#  
# The required block size for Oracle E-Business Suite is 8K. No other value
may be used.  
#  
#########  
  
db_block_size = 8192 #MP  
  
  
#########  
#  
# Compatibility parameter  
#  
# See the appropriate release-specific section of this document for details of
setting compatibility.  
#  
#########  
  
  
#########  
#  
# _system_trig_enabled  
#  
# The _system_trig_enabled parameter must be set to TRUE.  
# If _system_trig_enabled parameter is set to FALSE it will  
# prevent system triggers from being executed.  
#  
#########  
  
_system_trig_enabled = TRUE #MP  
  
  
#########  
#  
# o7_dictionary_accessibility parameter  
#  
# This parameter must be set to FALSE for Oracle E-Business Suite Release 12.  
#  
########  
  
o7_dictionary_accessibility = FALSE #MP  
  
  
#########  
#  
# NLS and character set parameters  
#  
# Some NLS parameter values are marked as being mandatory settings.  
# These are the only supported settings for these parameters for  
# Oracle E-Business Suite Release 12. They must not be changed to other
values.  
# Other NLS parameters have been given default values, which can  
# be changed as required.  
#  
#########  
  
nls_language = american  
nls_territory = america  
nls_date_format = DD-MON-RR #MP  
nls_numeric_characters = ".,"  
nls_sort = binary #MP  
nls_comp = binary #MP  
nls_length_semantics = BYTE #MP  
  
  
#########  
#  
# Multi-Threaded Server (MTS) parameters  
#  
# Most Oracle E-Business Suite customers do not need to use MTS,  
# and the default configuration disables MTS.  
#  
# If MTS is used, it can have a dramatic effect on the SGA, as  
# session memory, including sort and cursor areas, resides in the  
# SGA.  
#  
#########  
  
  
#########  
#  
# Auditing parameter  
#  
# There is a performance overhead for enabling the audit_trail  
# parameter. In addition, the database administrator will need  
# to implement a purge policy for the SYS.AUD$ table.  
#  
# Statement-level auditing should not be used.  
#  
#########  
  
# audit_trail = TRUE # Uncomment if you want to enable audit_trail.  
  
  
########  
#  
# Dump parameters  
#  
# The main dump parameters specify the location of the trace and core  
# files, and will normally point to the appropriate trace directories.  
# The max_dump_file_size parameter can be used to specify the maximum  
# size of a dump file, to prevent a trace file using an excessive  
# amount of disk space. (This can also be changed at session level.)  
#  
########  
  
user_dump_dest = /ebiz/prodr12/udump  
background_dump_dest = /ebiz/prodr12/bdump  
core_dump_dest = /ebiz/prodr12/cdump  
max_dump_file_size = 20480 #Limit default trace file size to 10 MB.  
  
  
########  
#  
# Timed statistics  
#  
# On most platforms, enabling timed statistics has minimal effect  
# on performance. It can be enabled or disabled dynamically at  
# both system and session level.  
#  
# Timed statistics is required for use of SQL Trace and Statspack.  
#  
########  
#  
timed_statistics = TRUE  
  
  
########  
# Trace file accessibility parameter  
#  
# Setting this parameter to FALSE is recommended, but it can be enabled  
# on non-production databases to facilitate easier trace file analysis.  
# **Warning:**  
# Consider the security implications of setting this to TRUE  
# as trace files may include secure data in BIND variables.  
#  
########  
  
_trace_files_public = FALSE  
  
  
#########  
#  
# Processes and sessions parameters  
#  
# A database process can be associated with one or more database  
# sessions. For all technology stack components other than Oracle  
# Forms, there is a one-to-one mapping between sessions and processes.  
#  
# For Forms processes, there will be one database session per  
# open form, with a minimum of two sessions per Forms user (one  
# for the navigator form, and one for the active form).  
#  
# The sessions parameter should be set to twice the value of the  
# processes parameter.  
#  
#########  
  
processes = 200 # Max. no. of users.  
sessions = 400 # 2 x no. of processes.  
db_files = 512 # Max. no. of database files.  
dml_locks = 10000 # Database locks.  
  
  
########  
#  
# Cursor-related parameters  
#  
########  
  
cursor_sharing = EXACT #MP  
open_cursors = 600  
session_cached_cursors = 500  
  
  
########  
#  
# Cache parameters  
#  
# For Oracle 10g and 11g, the automatic SGA tuning option (sga_target)  
# is required. This avoids the need for individual tuning of the different  
# caches, such as the buffer cache, shared pool, and large pool. Use  
# of the automatic SGA tuning option also improves manageability and  
# overall performance.  
#  
# sga_target refers to the total size of the SGA. This includes  
# all the sub-caches, such as the buffer cache, log buffer,  
# shared pool, and large pool. The sizing table in the  
# section Database Initialization Parameter Sizing contains  
# sizing recommendations for sga_target.  
#  
# # When the automatic SGA tuning option is used to dynamically size  
# the individual caches, it is recommended to use a Server Parameter  
# file (SPFILE) to store the initialization parameter values.  
# Using an SPFILE allows the dynamically-adjusted values to persist  
# across restarts. Refer to the Oracle Database Administrator's  
# Guide for information on how to create and maintain an SPFILE.  
#  
``# db_block_checking can be enabled and set to LOW, MEDIUM or FULL``.  
# Note this may incur an overhead of 1% - 10%.  
  
sga_target = 2G #MP  
db_block_checking = FALSE  
db_block_checksum = TRUE  
  
  
########  
#  
# Log Writer parameters  
#  
# The log writer parameters control the size of the log buffer  
# within the SGA, and how frequently the redo logs are checkpointed  
# (when all dirty buffers written to disk and a new recovery point  
# is created).  
#  
# A size of 10MB for the log buffer is a reasonable value for  
# Oracle E-Business Suite. This represents a balance between  
# concurrent programs and online users. The value of log_buffer  
# must be a multiple of redo block size (normally 512 bytes).  
#  
# The checkpoint interval and timeout control the frequency of  
# checkpoints.  
#  
########  
  
log_checkpoint_timeout = 1200 # Checkpoint at least every 20 mins.  
log_checkpoint_interval = 100000  
log_buffer = 10485760  
log_checkpoints_to_alert = TRUE  
  
  
#########  
#  
# Shared pool parameters  
#  
# The shared pool should be tuned to minimize contention for SQL  
# and PL/SQL objects. For Release 12, a reasonable starting point  
# is a size of 600M and a 60M reserved area (10%).  
#  
########  
  
shared_pool_size = 600M  
shared_pool_reserved_size = 60M  
_shared_pool_reserved_min_alloc = 4100  
  
  
########  
#  
# cursor_space_for_time parameter  
#  
# Cursor space for time is an optimization strategy that  
# results in holding pins on cursors and their associated  
# frames/buffers for longer periods of time. The pins are held  
# until the cursor is closed, instead of at the end-of-fetch  
# (normal behavior). This reduces library cache pin traffic,  
# which reduces library cache latch gets. Setting cursor space  
# for time to TRUE can be useful for large Oracle E-Business  
# Suite environments, where library cache latch contention`  
`# (specifically due to pin gets) can be a performance issue.  
#  
# Cursor space for time requires at least a 50% increase in the  
# size of the shared pool because of the frames/buffers. If AWR  
# or Statspack reports show that the waits for library cache latch  
# gets are significant, and the latch gets are due to pin  
# requests, then cursor space for time can be used to improve  
# performance.  
#  
# It is important to note that library cache latch contention can  
# be caused by numerous different factors, including the use of  
# non-sharable SQL (i.e. literals), lack of space, frequent  
# loads/unloads, invalidation, patching, gathering statistics  
# frequently and during peak periods, and pin requests.  
# Cursor space for time is designed to optimize the pin requests  
# only, and will not reduce latch contention for other issues.  
#  
########  
  
# cursor_space_for_time = FALSE # Disabled by default.  
  
  
#########  
#  
# PL/SQL parameters  
#  
# The utl_file_dir parameter must be set as:  
# utl_file_dir = `

` <directory> ...  
#  
########  
  
utl_file_dir = /ebiz/prodr12/utl_file_dir  
  
  
########  
#  
# Advanced Queuing (AQ) and Job Queue parameters  
#  
# AQ requires the TM process to handle delayed messages. A number  
# of Application modules use AQ, including Workflow. Job Queues  
# enable advanced queue to submit background jobs.  
#  
# Starting from 10gR1, aq_tm_processes is auto-tuned.  
# Omitting this parameter has not, however, been tested with  
# Oracle E-Business Suite. The minimum required value is 1 and  
# should be increased to resolve lengthy queues.  
#  
# Usually, job_queue_processes should typically be set to a value of 2  
# for optimal performance. However, the value can be tuned to meet the  
# specific requirements of the Workflow module and customer needs,  
# based on the number of job queue processes needed to handle AQ  
# event messages and for Workflow notification mailers.  
#  
########  
  
aq_tm_processes = 1  
job_queue_processes = 2  
  
  
########  
#  
# Archiving parameters  
#  
# Archiving parameters, including destination (optionally,  
# multiple destinations in 10gR2 or 11g) may be specified.  
#  
########  
  
LOG_ARCHIVE_DEST_1 = 'LOCATION=/disk1/arc'  
LOG_ARCHIVE_DEST_2 = 'SERVICE=standby1'  
  
  
########  
#  
# Parallel execution parameters  
#  
# Parallel execution is used by some Oracle E-Business Suite concurrent
programs,  
# including DBI programs and Gathering Statistics. AD will also use parallel  
# execution when creating large indexes.  
#  
########  
  
parallel_max_servers = 8 # Max. value should be 2 x no. of CPUs.  
parallel_min_servers = 0  
  
  
########  
#  
# Events parameters  
#  
# Events should only be set when explicitly requested by Oracle Support or
Development.  
# Refer to the appropriate release-specific section for events that may be
set.  
#  
########  
  
  
#########  
#  
# Optimizer parameters  
#  
# The following optimizer parameters must be set as below, and may  
# not be changed. No other values are supported.  
#  
# Refer also to the release-specific section for any additional  
# optimizer parameters which must be set.  
#  
#########  
  
_sort_elimination_cost_ratio =5 #MP  
_like_with_bind_as_equality = TRUE #MP  
_fast_full_scan_enabled = FALSE #MP  
_b_tree_bitmap_plans = FALSE #MP  
optimizer_secure_view_merging = FALSE #MP  
_sqlexec_progression_cost = 2147483647 #MP  
  
  
#########  
#  
# Oracle Real Application Clusters ( **Oracle RAC** ) parameters  
#  
# The following Oracle RAC related parameters should be set when running  
# E-Business Suite in an Oracle RAC environment.  
# Set cluster_database = FALSE if not using RAC  
#########  
  
cluster_database = TRUE #MP  
  
  
#########  
#  
# Parallel Execution and Oracle RAC parameters  
#  
# It is recommended to set the parameters instance_groups and  
# parallel_instance_group on each instance, to ensure that parallel  
# requests do not span instances.  
# For example, on instance1, set instance_groups=apps1 and  
# parallel_instance_group=apps1. On instance2, set  
# instance_groups=apps2 and parallel_instance_group=apps2, and so on.  
#  
#########  
  
  
#########  
#  
# Private memory area parameters  
#  
# The automatic memory manager is used to manage the PGA memory. This  
# avoids the need to manually tune the settings of sort_area_size and  
# hash_area_size.  
# The automatic memory manager also improves performance and scalability,  
# as memory is released back to the operating system.  
#  
#########  
  
pga_aggregate_target = 1G  
workarea_size_policy = AUTO #MP  
olap_page_pool_size = 4194304`

`#########  
#  
# Direct I/O and Asynchronous I/O  
#  
# Direct I/O bypasses OS layer caching. If Direct I/O and asynchronous are
enabled on your OS  
# and your Linux version kernel is uek-2.6.39-200.29.3.el6uek or higher (see
note 1487957.1)  
# use SETALL for optimal performance otherwise use the value that matches your  
# system: none | directIO | asynch.  
#`` **Note:** SETALL is mandatory for EBS on Oracle Public Cloud.``  
``#  
#########  
  
filesystemio_options = SETALL  
``  
###############################################################################  
#  
# End of Common Database Initialization Parameters Section  
#  
###############################################################################`

## Section 2: Release-Specific Database Initialization Parameters For Oracle
10 _g_ Release 2

This section discusses database initialization parameters and specific
releases of Oracle Database 10g Release 2, first describing required
parameters, then listing any parameters that should not be used.

### 2.1 Required Parameters

The following list describes database initialization parameters required for
this specific release of the Oracle Database. These parameters should be added
to the common database initialization parameters provided in Section 1, so
that the final database initialization parameters file includes the common
section plus the contents of this release-specific section.

`#############################################################################  
#  
# Oracle E-Business Suite Release 12  
# Release-Specific Database Initialization Parameters for 10gR2  
#  
#############################################################################  
  
#########  
#  
# Compatibility parameter  
#  
# Compatibility should be set to the current release.  
#  
##########  
  
compatible = 10.2.0 #MP  
  
  
#########  
#  
# System-managed undo parameters  
#  
# Oracle E-Business Suite Release 12 requires the use of system managed undo.  
# This is much more efficient than rollback segments, and reduces the chances  
# of snapshot too old errors. In addition, it is much easier to manage and  
# administer system managed undo than manually managing rollback segments.  
#  
########  
  
undo_management = AUTO #MP  
undo_tablespace = APPS_UNDOTS1  
  
  
#########  
#  
# PL/SQL parameters  
#  
# The following parameters are used to enable the PL/SQL global  
# optimizer as well as native compilation.  
#  
# PL/SQL native compilation is recommended for Oracle Database 10g-based  
# Oracle E-Business Suite environments such as Release 12. Interpreted mode is
supported,  
# and can be used with Oracle E-Business Suite. However, native compilation is  
# recommended in order to maximize runtime performance and scalability.  
# Compiling PL/SQL units with native compilation takes longer than using  
# interpreted mode, because of the need to generate and compile the native  
# shared libraries.  
#  
#########  
  
plsql_optimize_level = 2 #MP  
plsql_code_type = native  
plsql_native_library_dir = /ebiz/prodr12/plsql_nativelib  
``plsql_native_library_subdir_count = 149  
  
  
#########  
#  
``# Other parameters  
#  
# _kks_use_mutex_pin  
#  
# 10gR2 ``facilitates the use of mutexes to lock resources in a lightweight  
# fashion with higher granularity.  
#  
# On the HP-UX (PA-RISC) platform only, this parameter must be set to FALSE if
using 10gR2.  
#  
#########  
  
_kks_use_mutex_pin=FALSE # Set to FALSE on HP-UX (PA-RISC) only; otherwise,
remove this parameter.  
  
  
``###############################################################################  
#  
# End of Release-Specific Database Initialization Parameters Section for 10gR2  
#  
###############################################################################`

### 2.2 Parameter Removal List for Oracle Database 10 _g_ Release 2

If they exist, you should remove the following parameters from your database
initialization parameters file for Oracle Database 10 _g_ Release 2.

**Note:** Parameters may appear on a "removal list" because they are obsolete;
because the default value is required and no other value may be set; or to
cater for certain special cases where a non-default value has to be set to
meet specific needs (currently, there is only one such case, which is
described in Section 7).

` _always_anti_join  
_always_semi_join  
_complex_view_merging  
_index_join_enabled  
_kks_use_mutex_pin # Unless using HP-UX (PA-RISC) - see "Other parameters"
section above.  
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
undo_suppress_errors`

## Section 3: Release-Specific Database Initialization Parameters for Oracle
11 _g_ Release 1

### 3.1 Required Parameters

The following list describes database initialization parameters required for
this specific release of the Oracle Database. These parameters should be added
to the common database initialization parameters provided in Section 1, so
that the final database initialization parameters file includes the common
section plus the contents of this release-specific section.

`####################################################################  
#  
# Oracle E-Business Suite Release 12  
# Release-Specific Database Initialization Parameters for 11gR1  
#  
####################################################################  
  
#########  
#  
# Compatible  
#  
# Set compatibility to the current release.  
#  
#########  
  
compatible = 11.1.0  
  
  
#######  
#  
# Diagnostic Parameters  
#  
# As of Oracle Database 11g Release 1, the diagnostics for each database  
# instance are located in a dedicated directory that can be specified  
# via the DIAGNOSTIC_DEST initialization parameter. The format of  
# the directory specified by DIAGNOSTIC_DEST is as follows:  
#  
#  
# Diagnostic files are located in their own subdirectories of the  
# DIAGNOSTIC_DEST directory, according to type:  
#  
# Trace files - <diagnostic_dest>/diag/rdbms/<dbname>/<instname>/trace  
# Alert logs - <diagnostic_dest>/diag/rdbms/<dbname>/<instname>/alert  
# Core files - <diagnostic_dest>/diag/rdbms/<dbname>/<instname>/cdumd  
# Incident dump files -
<diagnostic_dest>/diag/rdbms/<dbname>/<instname>/incident/<incdir#>  
  
diagnostic_dest = ?/prod12  
  
# System-Managed Undo Parameters  
#  
# Oracle E-Business Suite requires the use of System Managed Undo (SMU).  
# This is more efficient than manually managed rollback segments,  
# and reduces the chances of "snapshot too old" errors. It is also  
# easier to manage SMU than the rollback segments it replaces.  
#  
# ########  
  
undo_management=AUTO #MP  
undo_tablespace=APPS_UNDOTS1  
  
  
#########  
# PL/SQL parameters  
#  
# The following parameters are used to enable the PL/SQL global  
# optimizer as well as native compilation.  
#  
# PL/SQL native compilation is recommended for Oracle Database 10g or 11g
based  
# Oracle E-Business Suite environments such as Release 12. Interpreted mode is
supported,  
# and can be used with Oracle E-Business Suite. However, native compilation is  
# recommended in order to maximize runtime performance and scalability.  
# Compiling PL/SQL units with native compilation takes longer than using  
# interpreted mode, because of the need to generate and compile the native  
# shared libraries.  
#  
# If native compilation is to be used, uncomment the plsql_code_type = NATIVE  
# line below. Note that in 11g, the parameters plsql_native_library_dir and  
# plsql_native_library_subdir_count have no effect and are not needed, as  
# natively compiled code is now stored in the database, not a filesystem.  
#  
##########  
  
#plsql_code_type = NATIVE #Uncomment if you want to use NATIVE compilation.  
  
  
#########  
#  
# Optimizer Parameters  
#  
# Release 12 uses the Cost Based Optimizer (CBO). The following optimizer  
# parameters must be set as shown, and should not be changed.  
#  
#########  
  
_optimizer_autostats_job=FALSE #MP Turn off automatic statistics.  
  
`

`#########  
#  
# Database Password Case Sensitivity  
#  
# The default for Oracle E-Business Suite databases is FALSE i.e. passwords
are case-insensitive  
# Oracle E-Business Suite now supports Oracle Database 11g case-sensitive
database passwords  
# This feature is available in E-Business Suite 12.1.1 or higher  
# To enable this feature apply patch 12964564 and set SEC_CASE_SENSITIVE_LOGON
to TRUE  
#  
##########`

`sec_case_sensitive_logon = FALSE  
  
  
###############################################################################  
#  
# End of Release-Specific Database Initialization Parameters Section for 11gR1  
#  
###############################################################################  
`

### 3.2 Parameter Removal List for Oracle Database 11 _g_ Release 1

If they exist, you should remove the following parameters from your database
initialization parameters file for Oracle Database 11 _g_ Release 1 (11.1.X).

**Note:** Parameters may appear on a "removal list" because they are obsolete;
because the default value is required and no other value may be set; or to
cater for certain special cases where a non-default value has to be set to
meet specific needs (currently, there is only one such case, which is
described in Section 7).

` _always_anti_join  
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
`db_cache_size  
`db_file_multiblock_read_count  
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
`plsql_native_library_dir  
plsql_native_library_subdir_count``  
plsql_optimize_level  
`query_rewrite_enabled  
rollback_segments  
row_locking  
sort_area_size  
sql_trace  
`timed_statistics  
`undo_retention  
undo_suppress_errors  
user_dump_dest `

## Section 4: Release-Specific Database Initialization Parameters for Oracle
11 _g_ Release 2

### 4.1 Required Parameters

The following list describes database initialization parameters required for
this specific release of the Oracle Database. These parameters should be added
to the common database initialization parameters provided in Section 1, so
that the final database initialization parameters file includes the common
section plus the contents of this release-specific section.

`####################################################################  
#  
# Oracle E-Business Suite Release 12  
# Release-Specific Database Initialization Parameters for 11gR2  
#  
####################################################################  
  
#########  
#  
# Compatible  
#  
# Compatibility should be set to the current release.  
#  
#########  
  
compatible = 11.2.0 #MP  
  
  
#######  
#  
# Diagnostic Parameters  
#  
# As of Oracle Database 11g Release 1, the diagnostics for each database  
# instance are located in a dedicated directory that can be specified  
# via the DIAGNOSTIC_DEST initialization parameter. The format of  
# the directory specified by DIAGNOSTIC_DEST is as follows:  
#  
# <diagnostic_dest><diagnostic_dest>/diag/rdbms/<dbname>/<instname>  
#  
# Diagnostic files are located in their own subdirectories of the  
# DIAGNOSTIC_DEST directory, according to type:  
#  
# Trace files - <diagnostic_dest>/diag/rdbms/<dbname>/<instname>/trace  
# Alert logs - <diagnostic_dest>/diag/rdbms/<dbname>/<instname>/alert  
# Core files - <diagnostic_dest>/diag/rdbms/<dbname>/<instname>/cdumd  
# Incident dump files -
<diagnostic_dest>/diag/rdbms/<dbname>/<instname>/incident/<incdir#>  
  
diagnostic_dest = ?/prod12  
  
  
#########  
#  
# System-Managed Undo Parameters  
#  
# Oracle E-Business Suite requires the use of System Managed Undo (SMU).  
# This is more efficient than manually managed rollback segments,  
# and reduces the chances of "snapshot too old" errors. It is also  
# easier to manage SMU than the rollback segments it replaces.  
  
# ########  
  
undo_management=AUTO #MP  
undo_tablespace=APPS_UNDOTS1  
  
  
#########  
# PL/SQL parameters  
#  
# The following parameters are used to enable the PL/SQL global  
# optimizer as well as native compilation.  
#  
# PL/SQL native compilation is recommended for Oracle Database 10g or 11g
based  
# Oracle E-Business Suite environments such as Release 12. Interpreted mode is
supported,  
# and can be used with Oracle E-Business Suite. However, native compilation is  
# recommended in order to maximize runtime performance and scalability.  
# Compiling PL/SQL units with native compilation takes longer than using  
# interpreted mode, because of the need to generate and compile the native  
# shared libraries.  
#  
# If native compilation is to be used, uncomment the plsql_code_type = NATIVE  
# line below. Note that in 11g, the parameters plsql_native_library_dir and  
# plsql_native_library_subdir_count have no effect and are are not needed, as  
# natively compiled code is now stored in the database, not a filesystem.  
#  
#########  
  
#plsql_code_type = NATIVE #Uncomment if you want to use NATIVE compilation.  
  
  
#########  
#  
# Optimizer Parameters  
#  
# Release 12 uses cost based optimization. The following optimizer  
# parameters must be set as shown, and should not be changed.  
#  
#########  
  
_optimizer_autostats_job=FALSE #MP Turn off automatic statistics.  
  
`

`#########  
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
#########`

`parallel_force_local=TRUE #MP`

`#########  
#  
# Database Password Case Sensitivity  
#  
# The default for Oracle E-Business Suite databases is FALSE i.e. passwords
are case-insensitive  
# Oracle E-Business Suite now supports Oracle Database 11g case-sensitive
database passwords  
# This feature is available in E-Business Suite 12.1.1 or higher  
# To enable case-sensitivity, please follow the steps in MOS Doc ID 1581584.1  
# and if on a release prior to EBS 12.2 also apply patch 12964564.  
##########`

`sec_case_sensitive_logon = FALSE``  
  
  
###############################################################################  
#  
# End of Release-Specific Database Initialization Parameters Section for 11gR2  
#  
###############################################################################`

### 4.2 Parameter Removal List for Oracle Database 11 _g_ Release 2

If they exist, you should remove the following parameters from your database
initialization parameters file for Oracle Database 11 _g_ Release 2 (11.2.X).

**Note:** Parameters may appear on a "removal list" because they are obsolete;
because the default value is required and no other value may be set; or to
cater for certain special cases where a non-default value has to be set to
meet specific needs (currently, there is only one such case, which is
described in Section 7).

` _always_anti_join  
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
db_cache_size  
db_file_multiblock_read_count  
DRS_START  
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
`parallel_instance_group  
instance_groups`  
plsql_compiler_flags  
`plsql_native_library_dir  
plsql_native_library_subdir_count``  
plsql_optimize_level  
`query_rewrite_enabled  
rollback_segments  
row_locking  
sort_area_size  
sql_trace  
SQL_VERSION  
timed_statistics  
undo_retention  
undo_suppress_errors  
user_dump_dest `

## Section 5: Release-Specific Database Initialization Parameters for Oracle
12c Release 1

### 5.1 Required Parameters

The following list describes database initialization parameters required for
this specific release of the Oracle Database. These parameters should be added
to the common database initialization parameters provided in Section 1, so
that the final database initialization parameters file includes the common
section plus the contents of this release-specific section.

`####################################################################  
#  
# Oracle E-Business Suite Release 12  
# Release-Specific Database Initialization Parameters for 12c Release 1  
#  
####################################################################  
  
#########  
#  
# Compatible  
#  
# Compatibility should be set to the current release.  
#  
#########  
  
compatible = 12.1.0 #MP  
  
#######  
#  
# Diagnostic Parameters  
#  
# As of Oracle Database 11g Release 1, the diagnostics for each database  
# instance are located in a dedicated directory that can be specified  
# via the DIAGNOSTIC_DEST initialization parameter. The format of  
# the directory specified by DIAGNOSTIC_DEST is as follows:  
#  
# <diagnostic_dest><diagnostic_dest>/diag/rdbms/<dbname>/<instname>  
#  
# Diagnostic files are located in their own subdirectories of the  
# DIAGNOSTIC_DEST directory, according to type:  
#  
# Trace files - <diagnostic_dest>/diag/rdbms/<dbname>/<instname>/trace  
# Alert logs - <diagnostic_dest>/diag/rdbms/<dbname>/<instname>/alert  
# Core files - <diagnostic_dest>/diag/rdbms/<dbname>/<instname>/cdumd  
# Incident dump files -
<diagnostic_dest>/diag/rdbms/<dbname>/<instname>/incident/<incdir#>  
  
diagnostic_dest = ?/prod12  
  
#########  
#  
# System-Managed Undo Parameters  
#  
# Oracle E-Business Suite requires the use of System Managed Undo (SMU).  
# This is more efficient than manually managed rollback segments,  
# and reduces the chances of "snapshot too old" errors. It is also  
# easier to manage SMU than the rollback segments it replaces.  
  
# ########  
  
undo_management=AUTO #MP  
undo_tablespace=APPS_UNDOTS1  
  
#########  
# PL/SQL parameters  
#  
# The following parameters are used to enable the PL/SQL global  
# optimizer as well as native compilation.  
#  
# PL/SQL native compilation is recommended for Oracle Database 10g or 11g or
12c based  
# Oracle E-Business Suite environments such as Release 12. Interpreted mode is
supported,  
# and can be used with Oracle E-Business Suite. However, native compilation is  
# recommended in order to maximize runtime performance and scalability.  
# Compiling PL/SQL units with native compilation takes longer than using  
# interpreted mode, because of the need to generate and compile the native  
# shared libraries.  
#  
# If native compilation is to be used, uncomment the plsql_code_type = NATIVE  
# line below. Note that in 11g, the parameters plsql_native_library_dir and  
# plsql_native_library_subdir_count have no effect and are are not needed, as  
# natively compiled code is now stored in the database, not a filesystem.  
#  
#########  
  
#plsql_code_type = NATIVE #Uncomment if you want to use NATIVE compilation.  
  
#########  
#  
# Optimizer Parameters  
#  
# Release 12 uses cost based optimization. The following optimizer  
# parameters must be set as shown, and should not be changed.  
# It is recommended to disable the adaptive optimizer features: ``adaptive
plans,  
# automatic re-optimization, and SQL plan directives.  
#  
#########  
  
_optimizer_autostats_job=FALSE #MP Turn off automatic statistics.  
optimizer_adaptive_features = FALSE #MP  
``  
``#########  
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
#########`

`parallel_force_local=TRUE #MP`

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

pga_aggregate_limit = 0 #MP

#########  
#  
# TEMP_UNDO_ENABLED helps to reduce the amount of redo caused by DML on global
temporary tables.  
# Setting to TRUE may cause serious issues, such as ORA-55526, for distributed
transactions (Ref. Bug 20712819).  
# The recommended value for systems using distributed transactions is
currently FALSE (Pending ER 24286334).  
# If not using distributed transactions, TRUE will improve performance by
eliminating REDO on permanent UNDO.  
#  
##########

temp_undo_enabled = FALSE

`#########  
#  
# Database Password Case Sensitivity  
#  
``# The default value of this parameter is TRUE, i.e. passwords are case-
sensitive at the database level.  
``# Although the parameter is deprecated in Database 12c, it still needs to be
explicitly set for Oracle E-Business Suite.  
# To enable case-sensitivity of database passwords in Oracle E-Business
Suite``  
# (supported with Oracle E-Business Suite Release 12.1.1 or higher), set the
parameter to TRUE  
# and follow the steps in Doc ID 1581584.1. Also, if on a release prior to
Release 12.2,  
# apply patch 12964564. To disable case-sensitivity, set the parameter to
FALSE.  
#  
##########`

`sec_case_sensitive_logon = FALSE`

`  
###############################################################################  
#  
# End of Release-Specific Database Initialization Parameters Section for 12c  
#  
###############################################################################`

### 5.2 Parameter Removal List for Oracle Database 12c Release 1

If they exist, you should remove the following parameters from your database
initialization parameters file for Oracle Database 12c Release 1.

**Note:** Parameters may appear on a "removal list" because they are obsolete;
because the default value is required and no other value may be set; or to
cater for certain special cases where a non-default value has to be set to
meet specific needs (currently, there is only one such case, which is
described in Section 7).

` _always_anti_join  
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
db_cache_size  
db_file_multiblock_read_count  
DRS_START  
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
`parallel_instance_group  
instance_groups`  
plsql_compiler_flags  
`plsql_native_library_dir  
plsql_native_library_subdir_count``  
plsql_optimize_level  
`query_rewrite_enabled  
rollback_segments  
row_locking  
sort_area_size  
sql_trace  
SQL_VERSION  
timed_statistics  
undo_retention  
undo_suppress_errors  
user_dump_dest `

## Section 6: Additional Database Initialization Parameters For Oracle
E-Business Suite Release 12.2

The parameters in this section only apply to Oracle E-Business Suite Release
12.2 on Oracle Database 11g Release 2 (11.2.0.3 and higher), and should be
used in addition to the parameters in the other relevant sections of this
document.

`#########  
#  
# recyclebin parameter  
#  
# The database recyclebin must be turned off to allow the cleanup phase of the  
# online patching cycle to be performed without having to connect as SYS``.  
#``  
# This feature may still be used at other times.  
#  
#########`

`recyclebin=off `

`  
``#########  
#  
# service_names, local_listener parameter  
#  
# To support online patching, Oracle E-Business Suite Release 12.2 introduces
a  
# new database service.  
#  
# The service_names parameter specifies one or more names by which clients can  
# connect to an instance. The instance registers its service names with the  
# listener. When a client requests a service, the listener determines which  
# instances offer the requested service and then routes the client to the most  
# appropriate instance.  
#  
# On codelevels lower than AD-TXK Delta 9, the service name is always
'ebs_patch'.  
# From the AD-TXK Delta 9 codelevel, the service name is defined by the the
value  
# of the context variable 's_patch_service_name'.  
#  
# The local_listener setting is part of the AutoConfig templates, and required  
# for listener registration of any non-default (1521) ports.  
#  
#########`

`service_names=%s_dbSid%, <s_patch_service_name or ebs_patch> # Based on
AD/TXK Code level`

`local_listener=%s_dbSid%_LOCAL`

## Section 7: Using System Managed Undo (SMU)

As mentioned for the parameters related to system undo, the database releases
certified for use with Oracle E-Business Suite Release 12 only support the use
of system managed undo (SMU). SMU is more efficient than traditional rollback
segments and reduces the possibility of snapshot too old (ORA-1555) errors.

Note the following points about the undo_retention parameter:

  * The values given for undo_retention are for guidance only. This parameter should be adjusted according to the elapse times of the concurrent jobs, and corresponding commit windows. 
  * There is no need to specify a value for undo_retention on Oracle 10g or 11g or 12c based systems, because it is set automatically as part of automatic undo tuning.
  * Setting this parameter to a value higher than 900 (the default) is recommended if you experience "ORA-1555: Snapshot too old" errors. 
  * Automatic undo is not supported for LOBS.

## Section 8: Temporary Tablespace Setup

It is recommended that the temporary tablespace for Oracle E-Business Suite
users be created using locally managed temp files with uniform extent sizes of
128K. The 128K extent size is recommended because numerous modules, such as
Pricing and Planning, make extensive use of global temporary tables which also
reside in the temporary tablespace. Since each user instantiates a temporary
segment for these tables, large extent sizes may result in space allocation
failures.

The following is an example of creating a locally managed temporary tablespace
with temp files:

`SQL>drop tablespace temp;  
SQL>create temporary tablespace temp  
tempfile '/d2/prodr12/dbf/temp01.dbf' size 2000M reuse  
extent management local  
uniform size 128K;`

## Section 9: Database Initialization Parameter Sizing

This section provides sizing recommendations based on the active Oracle
E-Business Suite user counts. The following table should be used to size the
relevant parameters:

| Parameter Name | Development or Test Instance  | 11-100 Users | 101-500
Users | 501-1000 Users | **1001-2000 Users**  
---|---|---|---|---|---  
**processes** |  200  | 200 | 800 | 1200 | 2500  
**sessions** |  400 | 400 | 1600 | 2400 | 5000  
**sga_target[ Footnote 1
](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=152880042070510&id=396009.1&_adf.ctrl-
state=11dph05qcs_72#aref8)** | 1G | 1G | 2G | 3G | 14G  
**shared_pool_size (csp)** |  N/A | N/A | N/A | 1800M | 3000M  
**shared_pool_reserved_size (csp)** |  N/A | N/A | N/A | 180M | 300M  
**shared_pool_size (no csp)** |  400M | 600M | 800M | 1000M | 2000M  
**shared_pool_reserved_size (no csp)** |  40M | 60M | 80M | 100M | 100M  
**pga_aggregate_target** |  1G | 2G | 4G | 10G | 20G  
**Total Memory Required[ Footnote
2](https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=152880042070510&id=396009.1&_adf.ctrl-
state=11dph05qcs_72#aref9)** | **~ 2 GB** | **~ 3 GB** | **~ 6 GB** | **~ 13
GB** | **~ 34 GB**  
  
### Footnote 1

  * The parameter _sga_target_ should be used for Oracle 10g or 11g or 12c based environments such as Release 12. This replaces the parameter _db_cache_size_ , which was used in Oracle 9 _i_ based environments. Also, it is not necessary to set the parameter _undo_retention_ for 10g or 11g or 12c-based systems, since undo retention is set automatically as part of automatic undo tuning.

  * Enabling the 11g or 12c Automatic Memory Management (AMM) feature is supported in EBS, and has been found to be useful in scenarios where memory is limited, as it will dynamically adjust the SGA and PGA pool sizes. AMM is enabled by using the memory_target and memory_max_target initialization parameters. MEMORY_TARGET specifies the system-wide sharable memory for Oracle to use when dynamically controlling the SGA and PGA as workloads change. The memory_max_target parameter specifies the maximum size that memory_target may take. AMM has proven useful for small to mid-range systems as it simplifies both the configuration and management. However, many customers with large production systems have experienced better performance with manually sized pools (or large minimum values for the pools). On Linux, Hugepages has resulted in improved performance; however, this configuration is not compatible with AMM. For large mission-critical applications systems, it is advisable to set sga_target with a minimum fixed value for shared_pool_size and pga_aggregate_target.

### Footnote 2

  * The total memory required refers to the amount of memory required for the database instance and associated memory, including the SGA and the PGA. You should ensure that your system has sufficient available memory in order to support the values provided above. The values provided above should be adjusted based on available memory so as to prevent paging and swapping.

### General Notes on Table

  * "Development or Test instance" refers to a small instance used only for development or testing, with no more than 10 users.  
  

  * The range of user counts provided above refers to _active_ Oracle E-Business Suite users, not total or named users. For example, if you plan to support a maximum of 500 active Oracle E-Business Suite users, then you should use the sizing as per the range 101-500 users.  
  

  * The parameter values provided in this document reflect a small instance configuration, and you should adjust the relevant parameters based on the Oracle E-Business Suite user counts as listed in the table above.  
  

  * The "csp" and "no csp" options of the shared pool parameters refer to the use of _cursor_space_for_time_ , which is documented in the common database initialization parameters section.  

**Note:** Enabling cursor_space_for_time can result in significantly larger
shared pool requirements.

## Change Log

Date | Description  
---|---  
May 10, 2017 |

  * Updated service_names parameter for AD-TXK Delta 9.

  
Aug 17, 2016 |

  * Updated recommendation for TEMP_UNDO_ENABLED

  
Jul 26, 2016 |

  * Added filesystemio_options.

  
Jul 12, 2016 |

  * Added optimizer_adaptive_features = false #MP

  
Dec 09, 2015 |

  * Updated _TRACE_FILES_PUBLIC parameter and comment

  
Aug 10, 2015 |

  * Updated case-sensitivity to point to MOS Doc ID 1581584.1
  * Added notes regarding db_block_checking

  
Jan 08, 2015  |

  * In Key Points, added notes for EBS 12.2 certification with Oracle 12c Release 1 Ver. 12.1.0.2 
  * In Key Points, added notes for Exadata 

  
Sep 28, 2014  |

  * In Key Points, added notes for Oracle 12c Release 1 Ver. 12.1.0.2 

  
Aug 22, 2014  |

  * Added #MP to pga_aggregate_limit = 0 in Section 5 as Oracle E-Business Suite 12.2 ADOP ACTUALIZE_ALL phase would require no limit to be set on PGA memory usage. (Ref. BUG 19139794)

  
Sep 20, 2013  |

  * Added #MP to compatible = 11.2.0 in Section 4 as Oracle E-Business Suite 12.2 EBR would require DB to be on 11.2.0.0.0 or greater. 
  * Added Section 5 and Section 6. 
  * Few edits to include 12c Release 1 specific changes. 
  * Added local_listener parameter to the Section 6. 

  
June 03, 2013 |

  * Added explanatory note at the start of each removal list.

  
May 23, 2013 |

  * In Key Points, added the case where a parameter may appear on the removal list if a non-default needs to be set to meet specific needs.
  * Deleted the bullet "This parameter may be safely removed if you are using a value of 900 or less." from Section 9.

  
Feb 02, 2012 |

  * In Section 1, made sga_target a mandatory parameter (with same value, 2G, as before).
  * Changed all occurrences of "(#MP)" to "#MP", to better denote that these are comments.

  
Dec 29, 2011 |

  * Added SEC_CASE_SENSITIVE_LOGON support for R12.1.1 (patch 12964564) or higher to Sections 3.1 and 4.1. 
  * Re-worded comments for AQ_TM_PROCESSES parameter in Section 1.
  * Added comments for _trace_files_public parameter in Section 1.
  * Commented line "Private memory area parameters" in Section 1 by adding '#' character.
  * Removed max_commit_propagation_delay parameter from Section 1, as it is deprecated from 10gR2 onwards.
  * Added comments in Section 1 for cluster_database parameter for non-RAC environment.
  * Added 11g Automatic Memory Management (AMM) note to Section 9 - Footnote 1.
  * Removed log_archive_start from Archiving Parameters section in Section 1, as it is deprecated from 10G onwards.
  * Added LOG_ARCHIVE_DEST_n parameters to Archiving Parameters section in Section 1.
  * Corrected "Total Memory Required" for 1001-2000 Users in Section 9 sizing table.
  * Added parallel_force_local parameter to Section 4.1.
  * Added parallel_instance_group and instance_groups to 11gR2 removal list in Section 4.2.

  
Oct 04, 2011 |

  * Fixed small formatting issue in Section 4.2.

  
Apr 14, 2010  |

  * Reworded introductory section to provide key points about document structure as bulleted list.

  
Jan 08, 2010  |

  * Fixed several formatting issues.

  
Dec 24, 2009 |

  * Added 11gR2 section.

  
Sep 04, 2009  |

  * Made various edits in readiness for re-publication.
  * Removed Application Upgrade Considerations section.
  * Added Advanced Queuing (AQ) note to common parameters (Section 1).
  * Added note to job_queue_processes (Section 1).
  * Added diagnostic_dest to 11gR1-specific parameters (Section 3).
  * Added background_dump_dest, user_dump_dest, core_dump_dest to 11gR1 removal list. 
  * Added plsql_native_library_dir, plsql_native_library_subdir_count, plsql_optimize_level to 11gR1 removal list.
  * Added #MP to _optimizer_autostats_job=FALSE.
  * Updated undo_retention section (Section 9).
  * Added Timed_Statistics to Section 1.
  * Added nls_language, nls_length_semantics, _sqlexec_progression_cost to Section 1.
  * Removed nls_length_semantics from Section 3.
  * Removed sga_target from Sections 2, 3, and 4, as this is in the common parameters (Section 1)
  * Removed db_block_buffers row from sizing table (Section 9).
  * Updated "Specific Notes on Table" (Section 9).
  * Updated common parameters introduction (Section 1).

  
Feb 09, 2009  |

  * Removed db_cache_size and java_pool_size from Section 1.
  * Added sga_target to Section 1.
  * Removed "#MP" from plsql_code_type in Sections 2.1 and 3.1, as this is a recommended parameter. 

  
Oct 13, 2008  |

  * Corrected refererences to parameter name _optimizer_cost_based_transformation by removing extraneous "s" at end.

  
Aug 21, 2008  |

  * Added distinction between HP-UX (PA-RISC) and HP-UX (Itanium IA-64).

  
Aug 20, 2008 |

  * Added 11gR1 section.

  
May 13, 2008  |

  * Added explanatory text regarding purpose of the removal lists.

  
Mar 27, 2008  |

  * Added pga_aggregate_target row to table in Section 9.

  
Mar 18, 2008  |

  * Added _kks_use_mutex_pin as a required parameter in 9iR2.

  
Apr 23, 2007  |

  * Updated for database versions.

  
Feb 06, 2007  |

  * Minor edits.

  
Jan 24, 2007 |

  * Initial creation.

  
  
My Oracle Support Knowledge [Document
396009.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=396009.1&id=396009.1)
by Oracle E-Business Suite Development

[Copyright © 2016, Oracle and/or its affiliates. All rights reserved
](https://mosemp.us.oracle.com/epmos/main/downloadattachmentprocessor?parent=DOCUMENT&sourceId=1491855.1&attachid=1320300.1:COPY&clickstream=no
"Copyright 2015")  
  
  


---
### NOTE ATTRIBUTES
>Created Date: 2018-01-22 02:46:15  
>Last Evernote Update Date: 2018-10-01 15:44:50  
>author: YangKwong  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=152880042070510  
>source-url: &  
>source-url: id=396009.1  
>source-url: &  
>source-url: _adf.ctrl-state=11dph05qcs_72  