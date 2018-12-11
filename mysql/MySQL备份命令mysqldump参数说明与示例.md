## MySQL备份命令mysqldump参数说明与示例

### 1. 语法选项说明

```sql
#mysqldump --help                                                                                                                         

mysqldump  Ver 10.13 Distrib 5.7.21, for linux-glibc2.12 (x86_64)                                                                                         
Copyright (c) 2000, 2018, Oracle and/or its affiliates. All rights reserved.                                                                              
                                                                                                                                                          
Oracle is a registered trademark of Oracle Corporation and/or its                                                                                         
affiliates. Other names may be trademarks of their respective                                                                                             
owners.                                                                                                                                                   
                                                                                                                                                          
Dumping structure and contents of MySQL databases and tables.                                                                                             
Usage: mysqldump [OPTIONS] database [tables]                                                                                                              
OR     mysqldump [OPTIONS] --databases [OPTIONS] DB1 [DB2 DB3...]                                                                                         
OR     mysqldump [OPTIONS] --all-databases [OPTIONS]                                                                                                      
                                                                                                                                                          
Default options are read from the following files in the given order:                                                                                     
/etc/my.cnf /etc/mysql/my.cnf /usr/local/mysql/etc/my.cnf ~/.my.cnf                                                                                       
The following groups are read: mysqldump client                                                                                                           
The following options may be given as the first argument:                                                                                                 
--print-defaults        Print the program argument list and exit.                                                                                         
--no-defaults           Don't read default options from any option file,                                                                                  
                        except for login file.                                                                                                            
--defaults-file=#       Only read default options from the given file #.                                                                                  
--defaults-extra-file=# Read this file after the global files are read.                                                                                   
--defaults-group-suffix=#                                                                                                                                 
                        Also read groups with concat(group, suffix)                                                                                       
--login-path=#          Read this path from the login file.                                                                                               
  -A, --all-databases Dump all the databases. This will be same as --databases                                                                            
                      with all databases selected.                                                                                                        
  -Y, --all-tablespaces                                                                                                                                   
                      Dump all the tablespaces.                                                                                                           
  -y, --no-tablespaces                                                                                                                                    
                      Do not dump any tablespace information.                                                                                             
  --add-drop-database Add a DROP DATABASE before each create.                                                                                             
  --add-drop-table    Add a DROP TABLE before each create.                                                                                                
                      (Defaults to on; use --skip-add-drop-table to disable.)                                                                             
  --add-drop-trigger  Add a DROP TRIGGER before each create.                                                                                              
  --add-locks         Add locks around INSERT statements.                                                                                                 
                      (Defaults to on; use --skip-add-locks to disable.)                                                                                  
  --allow-keywords    Allow creation of column names that are keywords.                                                                                   
  --apply-slave-statements                                                                                                                                
                      Adds 'STOP SLAVE' prior to 'CHANGE MASTER' and 'START                                                                               
                      SLAVE' to bottom of dump.                                                                                                           
  --bind-address=name IP address to bind to.                                                                                                              
  --character-sets-dir=name                                                                                                                               
                      Directory for character set files.                                                                                                  
  -i, --comments      Write additional information.                                                                                                       
                      (Defaults to on; use --skip-comments to disable.)                                                                                   
  --compatible=name   Change the dump to be compatible with a given mode. By                                                                              
                      default tables are dumped in a format optimized for                                                                                 
                      MySQL. Legal modes are: ansi, mysql323, mysql40,                                                                                    
                      postgresql, oracle, mssql, db2, maxdb, no_key_options,                                                                              
                      no_table_options, no_field_options. One can use several                                                                             
                      modes separated by commas. Note: Requires MySQL server                                                                              
                      version 4.1.0 or higher. This option is ignored with                                                                                
                      earlier server versions.                                                                                                            
  --compact           Give less verbose output (useful for debugging). Disables                                                                           
                      structure comments and header/footer constructs.  Enables                                                                           
                      options --skip-add-drop-table --skip-add-locks                                                                                      
                      --skip-comments --skip-disable-keys --skip-set-charset.                                                                             
  -c, --complete-insert                                                                                                                                   
                      Use complete insert statements.                                                                                                     
  -C, --compress      Use compression in server/client protocol.                                                                                          
  -a, --create-options                                                                                                                                    
                      Include all MySQL specific create options.                                                                                          
                      (Defaults to on; use --skip-create-options to disable.)                                                                             
  -B, --databases     Dump several databases. Note the difference in usage; in                                                                            
                      this case no tables are given. All name arguments are                                                                               
                      regarded as database names. 'USE db_name;' will be                                                                                  
                      included in the output.                                                                                                             
  -#, --debug[=#]     This is a non-debug version. Catch this and exit.                                                                                   
  --debug-check       This is a non-debug version. Catch this and exit.                                                                                   
  --debug-info        This is a non-debug version. Catch this and exit.                                                                                   
  --default-character-set=name                                                                                                                            
                      Set the default character set.                                                                                                      
  --delete-master-logs                                                                                                                                    
                      Delete logs on master after backup. This automatically                                                                              
                      enables --master-data. 
                      备份完成后删除主库上的日志。这个选项会自动打开–master-data。
  -K, --disable-keys  '/*!40000 ALTER TABLE tb_name DISABLE KEYS */; and                                                                                  
                      '/*!40000 ALTER TABLE tb_name ENABLE KEYS */; will be put                                                                           
                      in the output.                                                                                                                      
                      (Defaults to on; use --skip-disable-keys to disable.)                                                                               
  --dump-slave[=#]    This causes the binary log position and filename of the                                                                             
                      master to be appended to the dumped data output. Setting                                                                            
                      the value to 1, will printit as a CHANGE MASTER command                                                                             
                      in the dumped data output; if equal to 2, that command                                                                              
                      will be prefixed with a comment symbol. This option will                                                                            
                      turn --lock-all-tables on, unless --single-transaction is                                                                           
                      specified too (in which case a global read lock is only                                                                             
                      taken a short time at the beginning of the dump - don't                                                                             
                      forget to read about --single-transaction below). In all                                                                            
                      cases any action on logs will happen at the exact moment                                                                            
                      of the dump.Option automatically turns --lock-tables off.                                                                           
  -E, --events        Dump events.                                                                                                                        
  -e, --extended-insert                                                                                                                                   
                      Use multiple-row INSERT syntax that include several                                                                                 
                      VALUES lists.                                                                                                                       
                      (Defaults to on; use --skip-extended-insert to disable.)                                                                            
  --fields-terminated-by=name                                                                                                                             
                      Fields in the output file are terminated by the given                                                                               
                      string.                                                                                                                             
  --fields-enclosed-by=name                                                                                                                               
                      Fields in the output file are enclosed by the given                                                                                 
                      character.                                                                                                                          
  --fields-optionally-enclosed-by=name                                                                                                                    
                      Fields in the output file are optionally enclosed by the                                                                            
                      given character.                                                                                                                    
  --fields-escaped-by=name                                                                                                                                
                      Fields in the output file are escaped by the given                                                                                  
                      character.                                                                                                                          
  -F, --flush-logs    Flush logs file in server before starting dump. Note that                                                                           
                      if you dump many databases at once (using the option                                                                                
                      --databases= or --all-databases), the logs will be                                                                                  
                      flushed for each database dumped. The exception is when                                                                             
                      using --lock-all-tables or --master-data: in this case                                                                              
                      the logs will be flushed only once, corresponding to the                                                                            
                      moment all tables are locked. So if you want your dump                                                                              
                      and the log flush to happen at the same exact moment you                                                                            
                      should use --lock-all-tables or --master-data with                                                                                  
                      --flush-logs. 
                      在开始导出前刷新服务器的日志文件。注意，如果你一次性导出很多数据库（使用 						 -databases=或--all-databases选项），导出每个库时都会触发日志刷新。						 例外是当使用了--lock-all-tables或--master-data时：日志只会被刷新一   					次，那个时候所有表都会被锁住。所以如果你希望你的导出和日志刷新发生在同一					  个确定的时刻，你需要使用--lock-all-tables，或者--master-data配合-						-flush-logs。
  --flush-privileges  Emit a FLUSH PRIVILEGES statement after dumping the mysql                                                                           
                      database.  This option should be used any time the dump                                                                             
                      contains the mysql database and any other database that                                                                             
                      depends on the data in the mysql database for proper                                                                                
                      restore.                                                                                                                            
  -f, --force         Continue even if we get an SQL error.                                                                                               
  -?, --help          Display this help message and exit.                                                                                                 
  --hex-blob          Dump binary strings (BINARY, VARBINARY, BLOB) in                                                                                    
                      hexadecimal format.                                                                                                                 
  -h, --host=name     Connect to host. 
                      主机名                                                                                                                   
  --ignore-error=name A comma-separated list of error numbers to be ignored if                                                                            
                      encountered during dump.                                                                                                            
  --ignore-table=name Do not dump the specified table. To specify more than one                                                                           
                      table to ignore, use the directive multiple times, once                                                                             
                      for each table.  Each table must be specified with both                                                                             
                      database and table names, e.g.,                                                                                                     
                      --ignore-table=database.table.                                                                                                      
  --include-master-host-port                                                                                                                              
                      Adds 'MASTER_HOST=<host>, MASTER_PORT=<port>' to 'CHANGE                                                                            
                      MASTER TO..' in dump produced with --dump-slave.                                                                                    
  --insert-ignore     Insert rows with INSERT IGNORE.                                                                                                     
  --lines-terminated-by=name                                                                                                                              
                      Lines in the output file are terminated by the given                                                                                
                      string.                                                                                                                             
  -x, --lock-all-tables                                                                                                                                   
                      Locks all tables across all databases. This is achieved                                                                             
                      by taking a global read lock for the duration of the                                                                                
                      whole dump. Automatically turns --single-transaction and                                                                            
                      --lock-tables off. 
                      锁定所有库中所有的表。这是通过在整个dump的过程中持有全局读锁来实现的。                       会自动关闭--single-transaction和--lock-tables。
                                                          
  -l, --lock-tables   Lock all tables for read.                                                                                                           
                      (Defaults to on; use --skip-lock-tables to disable.)  
                      对所有表加读锁。（默认是打开的，用--skip-lock-tables来关闭，上面的					  选项会把关闭-l选项）
  --log-error=name    Append warnings and errors to given file.                                                                                           
  --master-data[=#]   This causes the binary log position and filename to be                                                                              
                      appended to the output. If equal to 1, will print it as a                                                                           
                      CHANGE MASTER command; if equal to 2, that command will                                                                             
                      be prefixed with a comment symbol. This option will turn                                                                            
                      --lock-all-tables on, unless --single-transaction is                                                                                
                      specified too (in which case a global read lock is only                                                                             
                      taken a short time at the beginning of the dump; don't                                                                              
                      forget to read about --single-transaction below). In all                                                                            
                      cases, any action on logs will happen at the exact moment                                                                           
                      of the dump. Option automatically turns --lock-tables                                                                               
                      off. 
                      这个选项可以把binlog的位置和文件名添加到输出中，如果等于1，将会打印成                       一个CHANGE MASTER命令；如果等于2，会加上注释前缀。并且这个选项会自动					  打开--lock-all-tables，除非同时设置了--single-transaction（这种					  情况下，全局读锁只会在开始dump的时候加上一小段时间，不要忘了阅读--						  single-transaction的部分）。在任何情况下，所有日志中的操作都会发生在   					导出的准确时刻。这个选项会自动关闭--lock-tables。
                                     
  --max-allowed-packet=#                                                                                                                                  
                      The maximum packet length to send to or receive from                                                                                
                      server.                                                                                                                             
  --net-buffer-length=#                                                                                                                                   
                      The buffer size for TCP/IP and socket communication.                                                                                
  --no-autocommit     Wrap tables with autocommit/commit statements.                                                                                      
  -n, --no-create-db  Suppress the CREATE DATABASE ... IF EXISTS statement that                                                                           
                      normally is output for each dumped database if                                                                                      
                      --all-databases or --databases is given.                                                                                            
  -t, --no-create-info                                                                                                                                    
                      Don't write table creation info.                                                                                                    
  -d, --no-data       No row information.                                                                                                                 
  -N, --no-set-names  Same as --skip-set-charset.                                                                                                         
  --opt               Same as --add-drop-table, --add-locks, --create-options,                                                                            
                      --quick, --extended-insert, --lock-tables, --set-charset,                                                                           
                      and --disable-keys. Enabled by default, disable with                                                                                
                      --skip-opt.   
                      同-add-drop-table, --add-locks, --create-options, --quick, -					   -extended-insert, --lock-tables, --set-charset, --disable-					   keys。（默认已开启，--skip-opt关闭表示这些选项保持它的默认值）应该给					  你为读入一个MySQL服务器的尽可能最快的导出，--compact差不多是禁用上面						  的选项。
  --order-by-primary  Sorts each table's rows by primary key, or first unique                                                                             
                      key, if such a key exists.  Useful when dumping a MyISAM                                                                            
                      table to be loaded into an InnoDB table, but will make                                                                              
                      the dump itself take considerably longer.                                                                                           
  -p, --password[=name]                                                                                                                                   
                      Password to use when connecting to server. If password is                                                                           
                      not given it's solicited on the tty.                                                                                                
  -P, --port=#        Port number to use for connection.
  					  用于连接MySQL服务器的的TCP/IP端口号                                                                                                 
  --protocol=name     The protocol to use for connection (tcp, socket, pipe,                                                                              
                      memory).                                                                                                                            
  -q, --quick         Don't buffer query, dump directly to stdout.                                                                                        
                      (Defaults to on; use --skip-quick to disable.)                                                                                      
  -Q, --quote-names   Quote table and column names with backticks (`).                                                                                    
                      (Defaults to on; use --skip-quote-names to disable.)                                                                                
  --replace           Use REPLACE INTO instead of INSERT INTO.                                                                                            
  -r, --result-file=name                                                                                                                                  
                      Direct output to a given file. This option should be used                                                                           
                      in systems (e.g., DOS, Windows) that use carriage-return                                                                            
                      linefeed pairs (\r\n) to separate text lines. This option                                                                           
                      ensures that only a single newline is used.                                                                                         
  -R, --routines      Dump stored routines (functions and procedures).                                                                                    
  --set-charset       Add 'SET NAMES default_character_set' to the output.                                                                                
                      (Defaults to on; use --skip-set-charset to disable.)                                                                                
  --set-gtid-purged[=name]                                                                                                                                
                      Add 'SET @@GLOBAL.GTID_PURGED' to the output. Possible                                                                              
                      values for this option are ON, OFF and AUTO. If ON is                                                                               
                      used and GTIDs are not enabled on the server, an error is                                                                           
                      generated. If OFF is used, this option does nothing. If                                                                             
                      AUTO is used and GTIDs are enabled on the server, 'SET                                                                              
                      @@GLOBAL.GTID_PURGED' is added to the output. If GTIDs                                                                              
                      are disabled, AUTO does nothing. If no value is supplied                                                                            
                      then the default (AUTO) value will be considered.                                                                                   
  --single-transaction                                                                                                                                    
                      Creates a consistent snapshot by dumping all tables in a                                                                            
                      single transaction. Works ONLY for tables stored in                                                                                 
                      storage engines which support multiversioning (currently                                                                            
                      only InnoDB does); the dump is NOT guaranteed to be                                                                                 
                      consistent for other storage engines. While a                                                                                       
                      --single-transaction dump is in process, to ensure a                                                                                
                      valid dump file (correct table contents and binary log                                                                              
                      position), no other connection should use the following                                                                             
                      statements: ALTER TABLE, DROP TABLE, RENAME TABLE,                                                                                  
                      TRUNCATE TABLE, as consistent snapshot is not isolated                                                                              
                      from them. Option automatically turns off --lock-tables.  
                      通过将导出操作封装在一个事务内来使得导出的数据是一个一致性快照。只有当					   表使用支持MVCC的存储引擎（目前只有InnoDB）时才可以工作；其他引擎不能保						 证导出是一致的。当导出开启了--single-transaction选项时，要确保导出文					   件有效（正确的表数据和二进制日志位置），就要保证没有其他连接会执行如下语						 句：ALTER TABLE, DROP TABLE, RENAME TABLE, TRUNCATE TABLE，这                       会导致一致性快照失效。这个选项开启后会自动关闭--lock-tables。
  --dump-date         Put a dump date to the end of the output.                                                                                           
                      (Defaults to on; use --skip-dump-date to disable.)                                                                                  
  --skip-opt          Disable --opt. Disables --add-drop-table, --add-locks,                                                                              
                      --create-options, --quick, --extended-insert,                                                                                       
                      --lock-tables, --set-charset, and --disable-keys.                                                                                   
  -S, --socket=name   The socket file to use for connection.                                                                                              
  --secure-auth       Refuse client connecting to server if it uses old                                                                                   
                      (pre-4.1.1) protocol. Deprecated. Always TRUE                                                                                       
  --ssl-mode=name     SSL connection mode.                                                                                                                
  --ssl               Deprecated. Use --ssl-mode instead.                                                                                                 
                      (Defaults to on; use --skip-ssl to disable.)                                                                                        
  --ssl-verify-server-cert                                                                                                                                
                      Deprecated. Use --ssl-mode=VERIFY_IDENTITY instead.                                                                                 
  --ssl-ca=name       CA file in PEM format.                                                                                                              
  --ssl-capath=name   CA directory.                                                                                                                       
  --ssl-cert=name     X509 cert in PEM format.                                                                                                            
  --ssl-cipher=name   SSL cipher to use.                                                                                                                  
  --ssl-key=name      X509 key in PEM format.                                                                                                             
  --ssl-crl=name      Certificate revocation list.                                                                                                        
  --ssl-crlpath=name  Certificate revocation list path.                                                                                                   
  --tls-version=name  TLS version to use, permitted values are: TLSv1, TLSv1.1                                                                            
  -T, --tab=name      Create tab-separated textfile for each table to given                                                                               
                      path. (Create .sql and .txt files.) NOTE: This only works                                                                           
                      if mysqldump is run on the same machine as the mysqld                                                                               
                      server.                                                                                                                             
  --tables            Overrides option --databases (-B).                                                                                                  
  --triggers          Dump triggers for each dumped table.                                                                                                
                      (Defaults to on; use --skip-triggers to disable.)                                                                                   
  --tz-utc            SET TIME_ZONE='+00:00' at top of dump to allow dumping of                                                                           
                      TIMESTAMP data when a server has data in different time                                                                             
                      zones or data is being moved between servers with                                                                                   
                      different time zones.                                                                                                               
                      (Defaults to on; use --skip-tz-utc to disable.)                                                                                     
  -u, --user=name     User for login if not current user.                                                                                                 
  -v, --verbose       Print info about the various stages.                                                                                                
  -V, --version       Output version information and exit.                                                                                                
  -w, --where=name    Dump only selected records. Quotes are mandatory.                                                                                   
  -X, --xml           Dump a database as well formed XML.                                                                                                 
  --plugin-dir=name   Directory for client-side plugins.                                                                                                  
  --default-auth=name Default authentication client-side plugin to use.                                                                                   
  --enable-cleartext-plugin                                                                                                                               
                      Enable/disable the clear text authentication plugin.                                                                                
                                                                                                                                                          
Variables (--variable-name=value)                                                                                                                         
and boolean options {FALSE|TRUE}  Value (after reading options)                                                                                           

--------------------------------- ----------------------------------------
all-databases                     FALSE                                                                                                                   
all-tablespaces                   FALSE                                                                                                                   
no-tablespaces                    FALSE                                                                                                                   
add-drop-database                 FALSE                                                                                                                   
add-drop-table                    TRUE                                                                                                                    
add-drop-trigger                  FALSE                                                                                                                   
add-locks                         TRUE                                                                                                                    
allow-keywords                    FALSE                                                                                                                   
apply-slave-statements            FALSE                                                                                                                   
bind-address                      (No default value)                                                                                                      
character-sets-dir                (No default value)                                                                                                      
comments                          TRUE                                                                                                                    
compatible                        (No default value)                                                                                                      
compact                           FALSE                                                                                                                   
complete-insert                   FALSE                                                                                                                   
compress                          FALSE                                                                                                                   
create-options                    TRUE                                                                                                                    
databases                         FALSE                                                                                                                   
default-character-set             utf8                                                                                                                    
delete-master-logs                FALSE                                                                                                                   
disable-keys                      TRUE                                                                                                                    
dump-slave                        0                                                                                                                       
events                            FALSE                                                                                                                   
extended-insert                   TRUE                                                                                                                    
fields-terminated-by              (No default value)                                                                                                      
fields-enclosed-by                (No default value)                                                                                                      
fields-optionally-enclosed-by     (No default value)                                                                                                      
fields-escaped-by                 (No default value)                                                                                                      
flush-logs                        FALSE                                                                                                                   
flush-privileges                  FALSE                                                                                                                   
force                             FALSE                                                                                                                   
hex-blob                          FALSE                                                                                                                   
host                              (No default value)                                                                                                      
ignore-error                      (No default value)                                                                                                      
include-master-host-port          FALSE                                                                                                                   
insert-ignore                     FALSE                                                                                                                   
lines-terminated-by               (No default value)                                                                                                      
lock-all-tables                   FALSE                                                                                                                   
lock-tables                       TRUE                                                                                                                    
log-error                         (No default value)                                                                                                      
master-data                       0                                                                                                                       
max-allowed-packet                25165824                                                                                                                
net-buffer-length                 1046528                                                                                                                 
no-autocommit                     FALSE                                                                                                                   
no-create-db                      FALSE                                                                                                                   
no-create-info                    FALSE                                                                                                                   
no-data                           FALSE                                                                                                                   
order-by-primary                  FALSE                                                                                                                   
port                              0                                                                                                                       
quick                             TRUE                                                                                                                    
quote-names                       TRUE                                                                                                                    
replace                           FALSE                                                                                                                   
routines                          FALSE                                                                                                                   
set-charset                       TRUE                                                                                                                    
single-transaction                FALSE                                                                                                                   
dump-date                         TRUE                                                                                                                    
socket                            (No default value)                                                                                                      
secure-auth                       TRUE                                                                                                                    
ssl                               TRUE                                                                                                                    
ssl-verify-server-cert            FALSE                                                                                                                   
ssl-ca                            (No default value)                                                                                                      
ssl-capath                        (No default value)                                                                                                      
ssl-cert                          (No default value)                                                                                                      
ssl-cipher                        (No default value)                                                                                                      
ssl-key                           (No default value)                                                                                                      
ssl-crl                           (No default value)                                                                                                      
ssl-crlpath                       (No default value)                                                                                                      
tls-version                       (No default value)                                                                                                      
tab                               (No default value)                                                                                                      
triggers                          TRUE                                                                                                                    
tz-utc                            TRUE                                                                                                                    
user                              root                                                                                                                    
verbose                           FALSE                                                                                                                   
where                             (No default value)                                                                                                      
plugin-dir                        (No default value)                                                                                                      
default-auth                      (No default value)                                                                                                      
enable-cleartext-plugin           FALSE 
    
-q, --quick
不缓冲查询，直接导出至stdout。（默认打开，用--skip-quick来关闭）该选项用于转储大的表。
--set-charset
将SET NAMES default_character_set加到输出中。该选项默认启用。要想禁用SET NAMES语句，使用--skip-set-charset。
--add-drop-tables
在每个CREATE TABLE语句前添加DROP TABLE语句。默认开启。
--add-locks
在每个表导出之前增加LOCK TABLES并且之后UNLOCK TABLE。(为了使得更快地插入到MySQL)。默认开启。
--create-option
在CREATE TABLE语句中包括所有MySQL表选项。默认开启，使用--skip-create-options来关闭。
-e, --extended-insert
使用全新多行INSERT语法，默认开启（给出更紧缩并且更快的插入语句）

-d, --no-data
不写入表的任何行信息。如果你只想得到一个表的结构的导出，这是很有用的。

--add-drop-database
在create数据库之前先DROP DATABASE，默认关闭，所以一般在导入时需要保证数据库已存在。

--default-character-set=
使用的默认字符集。如果没有指定，mysqldump使用utf8。

-B, --databases
转储几个数据库。通常情况，mysqldump将命令行中的第1个名字参量看作数据库名，后面的名看作表名。使用该选项，它将所有名字参量看作数据库名。CREATE DATABASE IF NOT EXISTS db_name和USE db_name语句包含在每个新数据库前的输出中。

--tables
覆盖--database选项。选项后面的所有参量被看作表名。

-u[ name], --user=
连接服务器时使用的MySQL用户名。

-p[password], --password[=password]
连接服务器时使用的密码。如果你使用短选项形式(-p)，不能在选项和密码之间有一个空格。如果在命令行中，忽略了--password或-p选项后面的 密码值，将提示你输入一个。
```

### 2. 示例

导出一个数据库：

```
$mysqldump -h localhost -uroot -poracle \
--master-data=2 --single-transaction --add-drop-table --create-options --quick \
--extended-insert --default-character-set=utf8 --set-gtid-purged=OFF \
--databases sampdb > sampdb.sql
```

导出一个表：

```
$ mysqldump -usampadm -p --opt --flush-logs --set-gtid-purged=OFF sampdb absence > absence.sql
```

将备份文件压缩：

```
$ mysqldump -uroot -p --opt --flush-logs --set-gtid-purged=OFF sampdb absence  | gzip > absence.sql.gz   
对应的还原动作为
gunzip < backup-file.sql.gz | mysql -uusername -ppassword dbname
```

同时备份多个MySQL数据库

```
mysqldump -hhostname -uusername -ppassword –databases databasename1 databasename2 databasename3 > multibackupfile.sql
```

仅备份份数据库结构
```
mysqldump –no-data –databases databasename1 databasename2 databasename3 > structurebackupfile.sql
```
备份服务器上所有数据库

```
mysqldump –all-databases > allbackupfile.sql
```
导入数据库：

```
mysql> use target_dbname
mysql> source /mysql/backup/path/backup-file.sql
或
$ mysql target_dbname <backup-file.sql
```

导入还有一个`mysqlimport`命令，暂未研究。

直接从一个数据库向另一个数据库转储：

```
mysqldump -u用户名 -p --opt dbname | mysql --host remote_host -C dbname2
```

关于增量备份与恢复请参考：[MySQL增量备份与恢复实例](http://seanlook.com/2014/12/05/mysql_incremental_backup_example/)。

## 参考

- [4.5.4 mysqldump — A Database Backup Program](http://dev.mysql.com/doc/refman/5.5/en/mysqldump.html)
- [总结：MySQL备份与恢复的三种方法](http://laoguang.blog.51cto.com/6013350/1078820)
- [mysql备份与还原（含增量）](http://www.cnblogs.com/Cherie/p/3309456.html)
- [开启GTID的情况下导出导入库的注意事项](https://docs.lvrui.io/2016/10/28/%E5%BC%80%E5%90%AFGTID%E7%9A%84%E6%83%85%E5%86%B5%E4%B8%8B%E5%AF%BC%E5%87%BA%E5%AF%BC%E5%85%A5%E5%BA%93%E7%9A%84%E6%B3%A8%E6%84%8F%E4%BA%8B%E9%A1%B9/)