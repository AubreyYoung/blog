### Percona-Toolkit：pt-find

<!--区分大小写-->pt-find参数区分大小写

```
# pt-find --config find.cnf --ctime -2 --engine InnoDB --noquote --printf "this is res->>> tab_name:%D.%N\tsize:%T\n"
this is res->>> tab_name:mytest.t1      size:16384

# pt-find --config find.cnf --ctime -2 --engine innodb --noquote --printf "this is res->>> tab_name:%D.%N\tsize:%T\n"

# pt-find --config find.cnf --ctime -2000 --engine InnoDB --noquote --printf "this is res->>> tab_name:%D.%N\tsize:%T\n" 
this is res->>> tab_name:mysql.engine_cost      size:16384
this is res->>> tab_name:mysql.gtid_executed    size:16384
this is res->>> tab_name:mysql.help_category    size:32768
this is res->>> tab_name:mysql.help_keyword     size:180224
this is res->>> tab_name:mysql.help_relation    size:65536
this is res->>> tab_name:mysql.help_topic       size:1671168
this is res->>> tab_name:mysql.innodb_index_stats       size:16384
this is res->>> tab_name:mysql.innodb_table_stats       size:16384
this is res->>> tab_name:mysql.plugin   size:16384
this is res->>> tab_name:mysql.server_cost      size:16384
this is res->>> tab_name:mysql.servers  size:16384
this is res->>> tab_name:mysql.slave_master_info        size:16384
this is res->>> tab_name:mysql.slave_relay_log_info     size:16384
this is res->>> tab_name:mysql.slave_worker_info        size:16384
this is res->>> tab_name:mysql.time_zone        size:16384
this is res->>> tab_name:mysql.time_zone_leap_second    size:16384
this is res->>> tab_name:mysql.time_zone_name   size:16384
this is res->>> tab_name:mysql.time_zone_transition     size:16384
this is res->>> tab_name:mysql.time_zone_transition_type        size:16384
this is res->>> tab_name:mytest.t1      size:16384
this is res->>> tab_name:sys.sys_config size:16384

# pt-find --config find.cnf --ctime -2000 --engine MyISAM --noquote --printf "this is res->>> tab_name:%D.%N\tsize:%T\n"       
this is res->>> tab_name:mysql.columns_priv     size:4096
this is res->>> tab_name:mysql.db       size:6096
this is res->>> tab_name:mysql.event    size:2048
this is res->>> tab_name:mysql.func     size:1024
this is res->>> tab_name:mysql.ndb_binlog_index size:1024
this is res->>> tab_name:mysql.proc     size:304624
this is res->>> tab_name:mysql.procs_priv       size:4096
this is res->>> tab_name:mysql.proxies_priv     size:10053
this is res->>> tab_name:mysql.tables_priv      size:11110
this is res->>> tab_name:mysql.user     size:4480
```
```
# pt-find --help
pt-find searches for MySQL tables and executes actions, like GNU find.  The
default action is to print the database and table name.  For more details,
please use the --help option, or try 'perldoc /usr/bin/pt-find' for complete
documentation.

Usage: pt-find [OPTIONS] [DATABASES]

Options:

  --ask-pass            Prompt for a password when connecting to MySQL
  --case-insensitive    Specifies that all regular expression searches are case-
                        insensitive
  --charset=s       -A  Default character set
  --config=A            Read this comma-separated list of config files; if
                        specified, this must be the first option on the command
                        line
  --database=s      -D  Connect to this database
  --day-start           Measure times (for --mmin, etc) from the beginning of
                        today rather than from the current time
  --defaults-file=s -F  Only read mysql options from the given file
  --help                Show help and exit
  --host=s          -h  Connect to host
  --or                  Combine tests with OR, not AND
  --password=s      -p  Password to use when connecting
  --pid=s               Create the given PID file
  --port=i          -P  Port number to use for connection
  --[no]quote           Quotes MySQL identifier names with MySQL's standard
                        backtick character (default yes)
  --set-vars=A          Set the MySQL variables in this comma-separated list of
                        variable=value pairs
  --socket=s        -S  Socket file to use for connection
  --user=s          -u  User for login if not current user
  --version             Show version and exit
  --[no]version-check   Check for the latest version of Percona Toolkit, MySQL,
                        and other programs (default yes)

Actions:

  --exec=s              Execute this SQL with each item found
  --exec-dsn=s          Specify a DSN in key-value format to use when executing
                        SQL with --exec and --exec-plus
  --exec-plus=s         Execute this SQL with all items at once
  --print               Print the database and table name, followed by a newline
  --printf=s            Print format on the standard output, interpreting '\'
                        escapes and '%' directives

Tests:

  --autoinc=s           Table's next AUTO_INCREMENT is n
  --avgrowlen=z         Table avg row len is n bytes
  --checksum=s          Table checksum is n
  --cmin=z              Table was created n minutes ago
  --collation=s         Table collation matches pattern
  --column-name=s       A column name in the table matches pattern
  --column-type=s       A column in the table matches this type (case-
                        insensitive)
  --comment=s           Table comment matches pattern
  --connection-id=s     Table name has nonexistent MySQL connection ID
  --createopts=s        Table create option matches pattern
  --ctime=z             Table was created n days ago
  --datafree=z          Table has n bytes of free space
  --datasize=z          Table data uses n bytes of space
  --dblike=s            Database name matches SQL LIKE pattern
  --dbregex=s           Database name matches this pattern
  --empty               Table has no rows
  --engine=s            Table storage engine matches this pattern
  --function=s          Function definition matches pattern
  --indexsize=z         Table indexes use n bytes of space
  --kmin=z              Table was checked n minutes ago
  --ktime=z             Table was checked n days ago
  --mmin=z              Table was last modified n minutes ago
  --mtime=z             Table was last modified n days ago
  --procedure=s         Procedure definition matches pattern
  --rowformat=s         Table row format matches pattern
  --rows=z              Table has n rows
  --server-id=s         Table name contains the server ID
  --tablesize=z         Table uses n bytes of space
  --tbllike=s           Table name matches SQL LIKE pattern
  --tblregex=s          Table name matches this pattern
  --tblversion=z        Table version is n
  --trigger=s           Trigger action statement matches pattern
  --trigger-table=s     --trigger is defined on table matching pattern
  --view=s              CREATE VIEW matches this pattern

Option types: s=string, i=integer, f=float, h/H/a/A=comma-separated list, d=DSN, z=size, m=time

Rules:

  This tool accepts additional command-line arguments. Refer to the SYNOPSIS and usage information for details.

DSN syntax is key=value[,key=value...]  Allowable DSN keys:

  KEY  COPY  MEANING
  ===  ====  =============================================
  A    yes   Default character set
  D    yes   Default database
  F    yes   Only read default options from the given file
  P    yes   Port number to use for connection
  S    yes   Socket file to use for connection
  h    yes   Connect to host
  p    yes   Password to use when connecting
  u    yes   User for login if not current user

  If the DSN is a bareword, the word is treated as the 'h' key.

Options and values after processing arguments:

  --ask-pass            FALSE
  --autoinc             (No value)
  --avgrowlen           (No value)
  --case-insensitive    FALSE
  --charset             (No value)
  --checksum            (No value)
  --cmin                (No value)
  --collation           (No value)
  --column-name         (No value)
  --column-type         (No value)
  --comment             (No value)
  --config              /etc/percona-toolkit/percona-toolkit.conf,/etc/percona-toolkit/pt-find.conf,/root/.percona-toolkit.conf,/root/.pt-find.conf
  --connection-id       (No value)
  --createopts          (No value)
  --ctime               (No value)
  --database            (No value)
  --datafree            (No value)
  --datasize            (No value)
  --day-start           FALSE
  --dblike              (No value)
  --dbregex             (No value)
  --defaults-file       (No value)
  --empty               FALSE
  --engine              (No value)
  --exec                (No value)
  --exec-dsn            (No value)
  --exec-plus           (No value)
  --function            (No value)
  --help                TRUE
  --host                (No value)
  --indexsize           (No value)
  --kmin                (No value)
  --ktime               (No value)
  --mmin                (No value)
  --mtime               (No value)
  --or                  FALSE
  --password            (No value)
  --pid                 (No value)
  --port                (No value)
  --print               FALSE
  --printf              (No value)
  --procedure           (No value)
  --quote               TRUE
  --rowformat           (No value)
  --rows                (No value)
  --server-id           (No value)
  --set-vars            
  --socket              (No value)
  --tablesize           (No value)
  --tbllike             (No value)
  --tblregex            (No value)
  --tblversion          (No value)
  --trigger             (No value)
  --trigger-table       (No value)
  --user                (No value)
  --version             FALSE
  --version-check       TRUE
  --view                (No value)
```
