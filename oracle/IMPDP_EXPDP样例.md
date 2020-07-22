# IMPDP/EXPDP样例

# 1. 导出导入dblink

```sh
# 只导出导入dblink
# 整个库的dblink
expdp dumpfile=dblink.dmp directory=test full=y include=db_link userid=\"/ as sysdba\"

# 只导出导入某些schema dblink
expdp dumpfile=dblink.dmp directory=test schemas=user1,... include=db_link userid=\"/ as sysdba\"

# 导出公共dblink
expdp dumpfile=dblink.dmp directory=test full=y include=db_link:"IN (select db_link from dba_db_links where owner='PUBLIC')" userid=\"/ as sysdba\"
```

# 2. 数据泵处理大量分区

数据泵在处理大量分区时确实存在很多问题，特别是11204以下的版本存在一些BUG。
可以做如下尝试：

- 找到导入时数据库执行的SQL（活动会话或者AWR），定位问题或者BUG
- 尝试加并行
- 尝试exp/imp
- 将metadata和dataonly分开

# 3. EXPDP命令示例
```plsql
-- 导出一张表，例：
expdp system/oracle directory=my_dir dumpfile=expdp.dmp   logfile=expdp.log tables=scott.emp

-- 导出多张表，例：
expdp system/oracle directory=my_dir dumpfile=expdp.dmp   logfile=expdp.log tables=\(scott.emp,scott.dept\)

-- 导出一个用户(导出这个用户的所有对象)，例：
expdp system/oracle directory=my_dir dumpfile=expdp.dmp   logfile=expdp.log schemas=scott

-- 导出多个用户，例：
expdp system/oracle directory=my_dir dumpfile=expdp.dmp   logfile=expdp.log schemas=\(scott,hr\)

-- 导出整个数据库（sys、ordsys、mdsys的用户数据不会被导出）例：
expdp system/oracle directory=my_dir dumpfile=expdp.dmp   logfile=expdp.log full=yes

-- 并行导出：
expdp system/oracle directory=my_dir dumpfile=expdp%U.dmp logfile=expdp.log schemas=scott parallel=5

-- 导出用户元数据(包含表定义、存储过程、函数等等):
expdp system/oracle directory=my_dir dumpfile=expdp.dmp   logfile=expdp.log schemas=scott content=metadata_only

-- 导出用户存储过程,例：
expdp system/oracle directory=my_dir dumpfile=expdp.dmp   logfile=expdp.log schemas=scott include=procedure

-- 导出用户函数和视图，例：
expdp system/oracle directory=my_dir dumpfile=expdp.dmp   logfile=expdp.log schemas=scott include=\(function,view\)

-- 导出一个用户，但不包括索引，例：
expdp system/oracle directory=my_dir dumpfile=expdp.dmp   logfile=expdp.log schemas=scott exclude=index
```

# 4. EXPDP常用参数

```sh
attach=[schema_name.]job_name
说明：nodefault。连接到作业，进入交互模式。

导出模式，以下五个参数互斥。
full=[yes|no]
说明：nodefault。导出所有数据和元数据。要执行完全导出，需要具有datapump_exp_full_database角色。

schemas=schema_name[,...]
说明：default current user's schema。导出用户。

tables=[schema_name.]table_name[:partition_name][,...]
说明：nodefault。导出表。

tablespaces=tablespace_name[,...]
说明：nodefault。导出表空间。

transport_tablespaces=tablespace_name[,...]
说明：nodefault。导出可移动表空间/传输表空间。

过滤条件，以下三个参数互斥:
query=[schema.][table_name:] query_clause
说明：nodefault。按查询条件导出。

exclude=object_type[:name_clause][,...]
说明：nodefault。排除特定的对象类型。

include=object_type[:name_clause][,...]
说明：nodefault。包括特定的对象类型。

其他参数:
directory=directory_object
说明：default:data_pump_dir。导出路径。

dumpfile=[directory_object:]file_name[,...]
说明：default:expdat.dmp。导出的文件名。

logfile=[directory_object:]file_name
说明：default:export.log。导出的日志文件名。

content=[all|data_only|metadata_only]
说明：default:all。指定要导出的数据。

parallel=integer
说明：default:1。并行度，该值应小于等于dmp文件数量，或可以为'dumpfile='使用替换变量'%U'。
         RAC环境中，并行度大于1时，注意目录应该为共享目录。

compression=[all|data_only|metadata_only|none]
说明：default:metadata_only。压缩。

parfile=[directory_path]file_name
说明：nodefault。指定导出参数文件名称。

network_link=source_database_link
说明：nodefault。连接到源数据库进行导出。

filesize=integer[b|kb|mb|gb|tb]
说明：default:0不限制大小。指定每个dmp文件的最大大小。
      如果此参数小于将要导出的数据大小，将报错ORA-39095。

job_name=jobname_string
说明：default:system-generated name of the form SYS_EXPORT_<mode>_NN。指定job名称。

version=[compatilble|latest|version_string]
说明：default:compatible。默认兼容模式，可以指定导出dmp文件的版本。

cluster=[yes|no]
说明：default:yes。Utilize cluster resources and distribute workers across the Oracle RAC。需要特别注意的是，当处于多节点环境下时，若导出目录不在共享存储上，不添加cluster=no参数将会报ORA-31693等错误，原因是其他节点对导出目录无权限。
```

# 5. IMPDP导入注意事项

**注意事项：**

1. expdp导出的文件不能使用imp导入，只能通过impdp导入数据库
2. 导入时遇到已存在的对象，默认会跳过这个对象，继续导入其他对象
3. 导入时应确认dmp文件和目标数据库的tablespace、schema是否对应
4. 导入dmp文件时，应确定dmp文件导出时的命令，以便顺利导入数据

# 6. 确认DMP导出命令

拿到一个dmp文件，如果忘记了导出命令，可以通过以下方法确认(非官方，生产数据勿使用)：

确认dmp文件是exp导出还是expdp导出

1）xxd test.dmp | more

```
expdp导出的文件开头为0301，exp导出的文件开头为0303
```

2）文件头信息

```
strings test.dmp | more

expdp导出的dmp文件头信息：
"SYS"."SYS_EXPORT_TABLE_01"  -----job名称
x86_64/Linux 2.4.xx   -----操作系统版本
bjdb  -----数据库名称
ZHS16GBK  -----数据库字符集
11.02.00.04.00  -----数据库版本

exp导出的dmp文件头信息：
iEXPORT:V11.02.00  -----版本
USCOTT  -----用户
RTABLES  -----对象
```

3) 确认expdp导出的dmp文件的导出命令

```plsql
strings test.dmp | grep CLIENT_COMMAND
```

# 7.  IMPDP命令示例

```plsql
-- 导入dmp文件中的所有数据，例：
impdp system/oracle directory=my_dir dumpfile=expdp.dmp   logfile=impdp.log full=yes

-- 导入一张表，例：
impdp system/oracle directory=my_dir dumpfile=expdp.dmp   logfile=impdp.log tables=scott.emp

-- 导入多张表，例：
impdp system/oracle directory=my_dir dumpfile=expdp.dmp   logfile=impdp.log tables=\(scott.emp,scott.dept\)

-- 导入一个用户，例：
impdp system/oracle directory=my_dir dumpfile=expdp.dmp   logfile=impdp.log schemas=scott

-- 导入多个用户，例：
impdp system/oracle directory=my_dir dumpfile=expdp.dmp   logfile=impdp.log schemas=\(scott,hr\)

-- 以导入dmp文件中的所有数据为例
-- 并行导入： 
impdp system/oracle directory=my_dir dumpfile=expdp%U.dmp logfile=impdp.log parallel=5

-- 导入元数据(包含表定义、存储过程、函数等等):
impdp system/oracle directory=my_dir dumpfile=expdp.dmp   logfile=impdp.log content=metadata_only

-- 导入存储过程,例：
impdp system/oracle directory=my_dir dumpfile=expdp.dmp   logfile=impdp.log include=procedure

-- 导入函数和视图，例：
impdp system/oracle directory=my_dir dumpfile=expdp.dmp   logfile=impdp.log include=\(function,view\)

-- 导入数据，但不包括索引，例：
impdp system/oracle directory=my_dir dumpfile=expdp.dmp   logfile=impdp.log exclude=index

-- 重命名表名导入，例：
impdp system/oracle directory=my_dir dumpfile=expdp.dmp   logfile=impdp.log remap_table=scott.emp:emp1

-- 重命名schema名导入，例：	
impdp system/oracle directory=my_dir dumpfile=expdp.dmp   logfile=impdp.log remap_schema=scott:tim

-- 重命名表空间名导入，例：
impdp system/oracle directory=my_dir dumpfile=expdp.dmp   logfile=impdp.log remap_tablespace=users:apptbs

-- 导入时，忽略所有对象的段属性，这样导入时对象都创建在目标数据库用户默认的表空间上。
impdp system/oracle directory=my_dir dumpfile=expdp.dmp   logfile=impdp.log transform=segment_attributes:n

-- 将dmp文件的ddl语句导入到一个文件，不导入数据库，例：
impdp system/oracle directory=my_dir dumpfile=expdp.dmp   logfile=impdp.log sqlfile=import.sql
```

# 8. IMPDP参数说明

```sh
attach=[schema_name.]job_name
说明：nodefault。连接到作业，进入交互模式。

导入模式，以下五个参数互斥。
full=[yes|no]
说明：default:yes。导入dmp文件的所有数据和元数据。

schemas=schema_name[,...]
说明：nodefault。导入用户。

tables=[schema_name.]table_name[:partition_name][,...]
说明：nodefault。导入表。

tablespaces=tablespace_name[,...]
说明：nodefault。导入表空间。

transport_tablespaces=tablespace_name[,...]
说明：nodefault。导入可移动表空间。

过滤条件，以下三个参数互斥:
query=[schema.][table_name:] query_clause
说明：nodefault。按查询条件导入。

exclude=object_type[:name_clause][,...]
说明：nodefault。排除特定的对象类型。

include=object_type[:name_clause][,...]
说明：nodefault。包括特定的对象类型。

其他参数:
directory=directory_object
说明：default:data_pump_dir。导入路径。

dumpfile=[directory_object:]file_name[,...]
说明：default:expdat.dmp。导入的文件名。

logfile=[directory_object:]file_name
说明：default:export.log。导入的日志文件名。

content=[all|data_only|metadata_only]
说明：default:all。指定要导入的数据。

parallel=integer
说明：default:1。并行度，该值应小于等于dmp文件数量，或可以为'dumpfile='使用替换变量'%U'。

compression=[all|data_only|metadata_only|none]
说明：default:metadata_only。压缩。

parfile=[directory_path]file_name
说明：nodefault。指定导入参数文件名称。

network_link=source_database_link
说明：nodefault。连接到源数据库进行导入。

job_name=jobname_string
说明：default:system-generated name of the form SYS_EXPORT_<mode>_NN。指定job名称。

version=[compatilble|latest|version_string]
说明：default:compatible。默认兼容模式，可以指定导入dmp文件的版本。

REMAP_TABLE=[schema.]old_tablename[.partition]:new_tablename
说明：nodefault。允许导入期间重命名表名。

REMAP_SCHEMA=source_schema:target_schema
说明：nodefault。允许导入期间重命名schema名。

REMAP_TABLESPACE=source_tablespace:target_tablespace
说明：nodefault。允许导入期间重命名表空间名。

TRANSFORM = transform_name:value[:object_type]
说明：nodefault。允许改正正在导入的对象的DDL。

SQLFILE=[directory_object:]file_name
说明：nodefault。根据其他参数，将所有的 SQL DDL 写入指定的文件。

TABLE_EXISTS_ACTION=[SKIP | APPEND | TRUNCATE | REPLACE]
说明：default:skip(if content=data_only is specified,then the default is append)
```

# 9. 交互模式

进入交互可以操作导入导出作业。

```sh
进入交互模式的方法：
导入导出命令行执行期间按Ctrl + c
expdp attach=jobname或impdp attach=jobname
查看导入导出日志可以看到jobname，也可以通过查询dba_datapump_jobs找到jobname。
```

# 10. 报错总结

## 10.1 目录未建立

```
ORA-39002: invalid operation
ORA-39070: Unable to open the log file.
ORA-29283: invalid file operation
ORA-06512: at "SYS.UTL_FILE", line 536
ORA-29283: invalid file operation
```

## 10.2 dmp文件报错

```
ORA-39000: bad dump file specification
ORA-39143: dump file "/u01/20161031/bjh02.dmp" may be an original export dump file
```

## 10.3 版本不一致

如果导出的数据库版本比导入的数据版本高，需要在导出时加上参数version=要导入的数据库版本。否则报错：

```
ORA-39001: invalid argument value
ORA-39000: bad dump file specification
ORA-31640: unable to open dump file "/home/oracle/EXPDP20161024_1.DMP" for read
ORA-27037: unable to obtain file status
```

## 10.4 导出用户元数据

文末再附加一条导出用户元数据的sqlfile命令，这个是之前一个朋友问我的，因为之前做的db2的工作，最近才开始和oracle打交道，数据泵了解的很少，所以被问到这块的时候犹豫了片刻，第一个想到的自然是使用oracle自带的数据泵工具expdp：

```
expdp system/oracle schemas=scott directory=my_dir dumpfile=scott.dmp logfile=scott.log content=metadata_only
```

但是问题来了，朋友要的是sqlfile不是dumpfile，经过百度得知可以通过plsql developer工具把元数据导出成sqlfile的形式，但是导出的sqlfile还是不符合朋友的需求，后经指点得知，在导出元数据之后，只需要在导入的时候加上sqlfile参数，就可以生成sqlfile文件，具体命令如下：

```
impdp system/oracle directory=my_dir schemas=scott dumpfile=scott.dmp logfile=scott_imp.log sqlfile=scott.sql 
```

impdp工具里对sqlfile的描述如下

```
[oracle@Yukki tmp]$ impdp -help
SQLFILE
Write all the SQL DDL to a specified file.
```

将所有的 SQL DDL 写入指定的文件。

# 11.南非迁移问题总结

 