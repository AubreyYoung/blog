### **mysqlslap** — Load Emulation Client

[**mysqlslap**](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html) is a diagnostic program designed to emulate client load for a MySQL server and to report the timing of each stage. It works as if multiple clients are accessing the server.

Invoke [**mysqlslap**](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html) like this:

```terminal
shell> mysqlslap [options]
```

Some options such as [`--create`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_create) or [`--query`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_query) enable you to specify a string containing an SQL statement or a file containing statements. If you specify a file, by default it must contain one statement per line. (That is, the implicit statement delimiter is the newline character.) Use the [`--delimiter`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_delimiter) option to specify a different delimiter, which enables you to specify statements that span multiple lines or place multiple statements on a single line. You cannot include comments in a file; [**mysqlslap**](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html) does not understand them.

[**mysqlslap**](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html) runs in three stages:

1. Create schema, table, and optionally any stored programs or data to use for the test. This stage uses a single client connection.
2. Run the load test. This stage can use many client connections.
3. Clean up (disconnect, drop table if specified). This stage uses a single client connection.


Examples:

Supply your own create and query SQL statements, with 50 clients querying and 200 selects for each (enter the command on a single line):

```
[root@centos ~]# mysqlslap --delimiter=";" --create="CREATE TABLE a (b int);INSERT INTO a VALUES (23)"   --query="SELECT * FROM a" --concurrency=50 --iterations=200

Benchmark
        Average number of seconds to run all queries: 0.006 seconds
        Minimum number of seconds to run all queries: 0.005 seconds
        Maximum number of seconds to run all queries: 0.020 seconds
        Number of clients running queries: 50
        Average number of queries per client: 1
```

Let mysqlslap build the query SQL statement with a table of two INT columns and three VARCHAR columns. Use five clients querying 20 times each. Do not create the table or insert the data (that is, use the previous test's schema and data):

```
[root@centos ~]# mysqlslap --concurrency=5 --iterations=20  --number-int-cols=2 --number-char-cols=3   --auto-generate-sql
Benchmark
        Average number of seconds to run all queries: 0.022 seconds
        Minimum number of seconds to run all queries: 0.011 seconds
        Maximum number of seconds to run all queries: 0.070 seconds
        Number of clients running queries: 5
        Average number of queries per client: 0
```

Tell the program to load the create, insert, and query SQL statements from the specified files, where the create.sql file has multiple table creation statements delimited by ';' and multiple insert statements delimited by ';'. The --query file will have multiple queries delimited by ';'. Run all the load statements, then run all the queries in the query file with five clients (five times each):

```
[root@centos ~]# mysqlslap --concurrency=5  --iterations=5 --query=query.sql --create=create.sql   --delimiter=";"
Benchmark
        Average number of seconds to run all queries: 0.002 seconds
        Minimum number of seconds to run all queries: 0.000 seconds
        Maximum number of seconds to run all queries: 0.007 seconds
        Number of clients running queries: 5
```



**Table 4.15 mysqlslap Options**

| Format                                                       | Description                                                  | Introduced | Removed |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ---------- | ------- |
| [--auto-generate-sql](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_auto-generate-sql) | Generate SQL statements automatically when they are not supplied in files or using command options |            |         |
| [--auto-generate-sql-add-autoincrement](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_auto-generate-sql-add-autoincrement) | Add AUTO_INCREMENT column to automatically generated tables  |            |         |
| [--auto-generate-sql-execute-number](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_auto-generate-sql-execute-number) | Specify how many queries to generate automatically           |            |         |
| [--auto-generate-sql-guid-primary](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_auto-generate-sql-guid-primary) | Add a GUID-based primary key to automatically generated tables |            |         |
| [--auto-generate-sql-load-type](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_auto-generate-sql-load-type) | Specify the test load type                                   |            |         |
| [--auto-generate-sql-secondary-indexes](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_auto-generate-sql-secondary-indexes) | Specify how many secondary indexes to add to automatically generated tables |            |         |
| [--auto-generate-sql-unique-query-number](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_auto-generate-sql-unique-query-number) | How many different queries to generate for automatic tests.  |            |         |
| [--auto-generate-sql-unique-write-number](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_auto-generate-sql-unique-write-number) | How many different queries to generate for --auto-generate-sql-write-number |            |         |
| [--auto-generate-sql-write-number](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_auto-generate-sql-write-number) | How many row inserts to perform on each thread               |            |         |
| [--commit](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_commit) | How many statements to execute before committing.            |            |         |
| [--compress](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_compress) | Compress all information sent between client and server      |            |         |
| [--concurrency](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_concurrency) | Number of clients to simulate when issuing the SELECT statement |            |         |
| [--create](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_create) | File or string containing the statement to use for creating the table |            |         |
| [--create-schema](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_create-schema) | Schema in which to run the tests                             |            |         |
| [--csv](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_csv) | Generate output in comma-separated values format             |            |         |
| [--debug](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_debug) | Write debugging log                                          |            |         |
| [--debug-check](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_debug-check) | Print debugging information when program exits               |            |         |
| [--debug-info](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_debug-info) | Print debugging information, memory, and CPU statistics when program exits |            |         |
| [--default-auth](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_default-auth) | Authentication plugin to use                                 |            |         |
| [--defaults-extra-file](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_defaults-extra-file) | Read named option file in addition to usual option files     |            |         |
| [--defaults-file](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_defaults-file) | Read only named option file                                  |            |         |
| [--defaults-group-suffix](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_defaults-group-suffix) | Option group suffix value                                    |            |         |
| [--delimiter](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_delimiter) | Delimiter to use in SQL statements                           |            |         |
| [--detach](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_detach) | Detach (close and reopen) each connection after each N statements |            |         |
| [--enable-cleartext-plugin](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_enable-cleartext-plugin) | Enable cleartext authentication plugin                       |            |         |
| [--engine](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_engine) | Storage engine to use for creating the table                 |            |         |
| [--get-server-public-key](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_get-server-public-key) | Request RSA public key from server                           | 8.0.3      |         |
| [--help](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_help) | Display help message and exit                                |            |         |
| [--host](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_host) | Connect to MySQL server on given host                        |            |         |
| [--iterations](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_iterations) | Number of times to run the tests                             |            |         |
| [--login-path](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_login-path) | Read login path options from .mylogin.cnf                    |            |         |
| [--no-defaults](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_no-defaults) | Read no option files                                         |            |         |
| [--no-drop](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_no-drop) | Do not drop any schema created during the test run           |            |         |
| [--number-char-cols](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_number-char-cols) | Number of VARCHAR columns to use if --auto-generate-sql is specified |            |         |
| [--number-int-cols](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_number-int-cols) | Number of INT columns to use if --auto-generate-sql is specified |            |         |
| [--number-of-queries](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_number-of-queries) | Limit each client to approximately this number of queries    |            |         |
| [--only-print](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_only-print) | Do not connect to databases. mysqlslap only prints what it would have done |            |         |
| [--password](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_password) | Password to use when connecting to server                    |            |         |
| [--pipe](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_pipe) | On Windows, connect to server using named pipe               |            |         |
| [--plugin-dir](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_plugin-dir) | Directory where plugins are installed                        |            |         |
| [--port](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_port) | TCP/IP port number for connection                            |            |         |
| [--post-query](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_post-query) | File or string containing the statement to execute after the tests have completed |            |         |
| [--post-system](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_post-system) | String to execute using system() after the tests have completed |            |         |
| [--pre-query](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_pre-query) | File or string containing the statement to execute before running the tests |            |         |
| [--pre-system](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_pre-system) | String to execute using system() before running the tests    |            |         |
| [--print-defaults](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_print-defaults) | Print default options                                        |            |         |
| [--protocol](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_protocol) | Connection protocol to use                                   |            |         |
| [--query](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_query) | File or string containing the SELECT statement to use for retrieving data |            |         |
| [--secure-auth](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_secure-auth) | Do not send passwords to server in old (pre-4.1) format      |            | 8.0.3   |
| [--server-public-key-path](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_server-public-key-path) | Path name to file containing RSA public key                  | 8.0.4      |         |
| [--shared-memory-base-name](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_shared-memory-base-name) | The name of shared memory to use for shared-memory connections |            |         |
| [--silent](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_silent) | Silent mode                                                  |            |         |
| [--socket](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_socket) | For connections to localhost, the Unix socket file to use    |            |         |
| [--sql-mode](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_sql-mode) | Set SQL mode for client session                              |            |         |
| [--ssl-ca](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_ssl) | File that contains list of trusted SSL Certificate Authorities |            |         |
| [--ssl-capath](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_ssl) | Directory that contains trusted SSL Certificate Authority certificate files |            |         |
| [--ssl-cert](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_ssl) | File that contains X.509 certificate                         |            |         |
| [--ssl-cipher](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_ssl) | List of permitted ciphers for connection encryption          |            |         |
| [--ssl-crl](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_ssl) | File that contains certificate revocation lists              |            |         |
| [--ssl-crlpath](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_ssl) | Directory that contains certificate revocation list files    |            |         |
| [--ssl-fips-mode](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_ssl-fips-mode) | Whether to enable FIPS mode on the client side               | 8.0.11     |         |
| [--ssl-key](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_ssl) | File that contains X.509 key                                 |            |         |
| [--ssl-mode](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_ssl) | Security state of connection to server                       |            |         |
| [--tls-version](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_tls-version) | Protocols permitted for encrypted connections                |            |         |
| [--user](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_user) | MySQL user name to use when connecting to server             |            |         |
| [--verbose](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_verbose) | Verbose mode                                                 |            |         |
| [--version](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_version) | Display version information and exit                         |            |         |

- [`--help`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_help), `-?`

  Display a help message and exit.

- [`--auto-generate-sql`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_auto-generate-sql), `-a`

  Generate SQL statements automatically when they are not supplied in files or using command options.

- [`--auto-generate-sql-add-autoincrement`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_auto-generate-sql-add-autoincrement)

  Add an `AUTO_INCREMENT` column to automatically generated tables.

- [`--auto-generate-sql-execute-number=*N*`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_auto-generate-sql-execute-number)

  Specify how many queries to generate automatically.

- [`--auto-generate-sql-guid-primary`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_auto-generate-sql-guid-primary)

  Add a GUID-based primary key to automatically generated tables.

- [`--auto-generate-sql-load-type=*type*`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_auto-generate-sql-load-type)

  Specify the test load type. The permissible values are `read` (scan tables), `write` (insert into tables), `key` (read primary keys), `update` (update primary keys), or `mixed` (half inserts, half scanning selects). The default is `mixed`.

- [`--auto-generate-sql-secondary-indexes=*N*`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_auto-generate-sql-secondary-indexes)

  Specify how many secondary indexes to add to automatically generated tables. By default, none are added.

- [`--auto-generate-sql-unique-query-number=*N*`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_auto-generate-sql-unique-query-number)

  How many different queries to generate for automatic tests. For example, if you run a `key` test that performs 1000 selects, you can use this option with a value of 1000 to run 1000 unique queries, or with a value of 50 to perform 50 different selects. The default is 10.

- [`--auto-generate-sql-unique-write-number=*N*`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_auto-generate-sql-unique-write-number)

  How many different queries to generate for [`--auto-generate-sql-write-number`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_auto-generate-sql-write-number). The default is 10.

- [`--auto-generate-sql-write-number=*N*`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_auto-generate-sql-write-number)

  How many row inserts to perform. The default is 100.

- [`--commit=*N*`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_commit)

  How many statements to execute before committing. The default is 0 (no commits are done).

- [`--compress`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_compress), `-C`

  Compress all information sent between the client and the server if both support compression.

- [`--concurrency=*N*`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_concurrency), `-c *N*`

  The number of parallel clients to simulate.

- [`--create=*value*`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_create)

  The file or string containing the statement to use for creating the table.

- [`--create-schema=*value*`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_create-schema)

  The schema in which to run the tests.

  Note

  If the [`--auto-generate-sql`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_auto-generate-sql) option is also given, [**mysqlslap**](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html) drops the schema at the end of the test run. To avoid this, use the [`--no-drop`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_no-drop) option as well.

- [`--csv[=*file_name*\]`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_csv)

  Generate output in comma-separated values format. The output goes to the named file, or to the standard output if no file is given.

- [`--debug[=*debug_options*\]`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_debug), `-# [*debug_options*]`

  Write a debugging log. A typical *debug_options* string is `d:t:o,*file_name*`. The default is`d:t:o,/tmp/mysqlslap.trace`.

- [`--debug-check`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_debug-check)

  Print some debugging information when the program exits.

- [`--debug-info`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_debug-info), `-T`

  Print debugging information and memory and CPU usage statistics when the program exits.

- [`--default-auth=*plugin*`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_default-auth)

  A hint about the client-side authentication plugin to use. See [Section 6.3.10, “Pluggable Authentication”](https://dev.mysql.com/doc/refman/8.0/en/pluggable-authentication.html).

- [`--defaults-extra-file=*file_name*`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_defaults-extra-file)

  Read this option file after the global option file but (on Unix) before the user option file. If the file does not exist or is otherwise inaccessible, an error occurs. *file_name* is interpreted relative to the current directory if given as a relative path name rather than a full path name.

- [`--defaults-file=*file_name*`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_defaults-file)

  Use only the given option file. If the file does not exist or is otherwise inaccessible, an error occurs. *file_name* is interpreted relative to the current directory if given as a relative path name rather than a full path name.

  Exception: Even with [`--defaults-file`](https://dev.mysql.com/doc/refman/8.0/en/option-file-options.html#option_general_defaults-file), client programs read `.mylogin.cnf`.

- [`--defaults-group-suffix=*str*`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_defaults-group-suffix)

  Read not only the usual option groups, but also groups with the usual names and a suffix of *str*. For example,[**mysqlslap**](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html) normally reads the `[client]` and `[mysqlslap]` groups. If the [`--defaults-group-suffix=_other`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_defaults-group-suffix)option is given, [**mysqlslap**](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html) also reads the `[client_other]` and `[mysqlslap_other]` groups.

- [`--delimiter=*str*`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_delimiter), `-F *str*`

  The delimiter to use in SQL statements supplied in files or using command options.

- [`--detach=*N*`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_detach)

  Detach (close and reopen) each connection after each *N* statements. The default is 0 (connections are not detached).

- [`--enable-cleartext-plugin`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_enable-cleartext-plugin)

  Enable the `mysql_clear_password` cleartext authentication plugin. (See [Section 6.5.1.4, “Client-Side Cleartext Pluggable Authentication”](https://dev.mysql.com/doc/refman/8.0/en/cleartext-pluggable-authentication.html).)

- [`--engine=*engine_name*`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_engine), `-e *engine_name*`

  The storage engine to use for creating tables.

- [`--get-server-public-key`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_get-server-public-key)

  Request from the server the RSA public key that it uses for key pair-based password exchange. This option applies to clients that connect to the server using an account that authenticates with the `caching_sha2_password`authentication plugin. For connections by such accounts, the server does not send the public key to the client unless requested. The option is ignored for accounts that do not authenticate with that plugin. It is also ignored if RSA-based password exchange is not needed, as is the case when the client connects to the server using a secure connection.

  If [`--server-public-key-path=*file_name*`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_server-public-key-path) is given and specifies a valid public key file, it takes precedence over [`--get-server-public-key`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_get-server-public-key).

  For information about the `caching_sha2_password` plugin, see [Section 6.5.1.3, “Caching SHA-2 Pluggable Authentication”](https://dev.mysql.com/doc/refman/8.0/en/caching-sha2-pluggable-authentication.html).

- [`--host=*host_name*`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_host), `-h *host_name*`

  Connect to the MySQL server on the given host.

- [`--iterations=*N*`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_iterations), `-i *N*`

  The number of times to run the tests.

- [`--login-path=*name*`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_login-path)

  Read options from the named login path in the `.mylogin.cnf` login path file. A “login path” is an option group containing options that specify which MySQL server to connect to and which account to authenticate as. To create or modify a login path file, use the [**mysql_config_editor**](https://dev.mysql.com/doc/refman/8.0/en/mysql-config-editor.html) utility. See [Section 4.6.7, “**mysql_config_editor** — MySQL Configuration Utility”](https://dev.mysql.com/doc/refman/8.0/en/mysql-config-editor.html).

- [`--no-drop`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_no-drop)

  Prevent [**mysqlslap**](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html) from dropping any schema it creates during the test run.

- [`--no-defaults`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_no-defaults)

  Do not read any option files. If program startup fails due to reading unknown options from an option file, [`--no-defaults`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_no-defaults) can be used to prevent them from being read.

  The exception is that the `.mylogin.cnf` file, if it exists, is read in all cases. This permits passwords to be specified in a safer way than on the command line even when [`--no-defaults`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_no-defaults) is used. (`.mylogin.cnf` is created by the[**mysql_config_editor**](https://dev.mysql.com/doc/refman/8.0/en/mysql-config-editor.html) utility. See [Section 4.6.7, “**mysql_config_editor** — MySQL Configuration Utility”](https://dev.mysql.com/doc/refman/8.0/en/mysql-config-editor.html).)

- [`--number-char-cols=*N*`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_number-char-cols), `-x *N*`

  The number of [`VARCHAR`](https://dev.mysql.com/doc/refman/8.0/en/char.html) columns to use if [`--auto-generate-sql`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_auto-generate-sql) is specified.

- [`--number-int-cols=*N*`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_number-int-cols), `-y *N*`

  The number of [`INT`](https://dev.mysql.com/doc/refman/8.0/en/integer-types.html) columns to use if [`--auto-generate-sql`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_auto-generate-sql) is specified.

- [`--number-of-queries=*N*`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_number-of-queries)

  Limit each client to approximately this many queries. Query counting takes into account the statement delimiter. For example, if you invoke [**mysqlslap**](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html) as follows, the `;` delimiter is recognized so that each instance of the query string counts as two queries. As a result, 5 rows (not 10) are inserted.

  ```terminal
  shell> mysqlslap --delimiter=";" --number-of-queries=10
           --query="use test;insert into t values(null)"
  ```

- [`--only-print`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_only-print)

  Do not connect to databases. [**mysqlslap**](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html) only prints what it would have done.

- [`--password[=*password*\]`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_password), `-p[*password*]`

  The password to use when connecting to the server. If you use the short option form (`-p`), you *cannot* have a space between the option and the password. If you omit the *password* value following the [`--password`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_password) or `-p` option on the command line, [**mysqlslap**](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html) prompts for one.

  Specifying a password on the command line should be considered insecure. See [Section 6.1.2.1, “End-User Guidelines for Password Security”](https://dev.mysql.com/doc/refman/8.0/en/password-security-user.html). You can use an option file to avoid giving the password on the command line.

- [`--pipe`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_pipe), `-W`

  On Windows, connect to the server using a named pipe. This option applies only if the server supports named-pipe connections.

- [`--plugin-dir=*dir_name*`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_plugin-dir)

  The directory in which to look for plugins. Specify this option if the [`--default-auth`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_default-auth) option is used to specify an authentication plugin but [**mysqlslap**](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html) does not find it. See [Section 6.3.10, “Pluggable Authentication”](https://dev.mysql.com/doc/refman/8.0/en/pluggable-authentication.html).

- [`--port=*port_num*`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_port), `-P *port_num*`

  The TCP/IP port number to use for the connection.

- [`--post-query=*value*`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_post-query)

  The file or string containing the statement to execute after the tests have completed. This execution is not counted for timing purposes.

- [`--post-system=*str*`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_post-system)

  The string to execute using `system()` after the tests have completed. This execution is not counted for timing purposes.

- [`--pre-query=*value*`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_pre-query)

  The file or string containing the statement to execute before running the tests. This execution is not counted for timing purposes.

- [`--pre-system=*str*`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_pre-system)

  The string to execute using `system()` before running the tests. This execution is not counted for timing purposes.

- [`--print-defaults`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_print-defaults)

  Print the program name and all options that it gets from option files.

- [`--protocol={TCP|SOCKET|PIPE|MEMORY}`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_protocol)

  The connection protocol to use for connecting to the server. It is useful when the other connection parameters normally would cause a protocol to be used other than the one you want. For details on the permissible values, see[Section 4.2.2, “Connecting to the MySQL Server”](https://dev.mysql.com/doc/refman/8.0/en/connecting.html).

- [`--query=*value*`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_query), `-q *value*`

  The file or string containing the [`SELECT`](https://dev.mysql.com/doc/refman/8.0/en/select.html) statement to use for retrieving data.

- [`--secure-auth`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_secure-auth)

  This option was removed in MySQL 8.0.3.

- [`--server-public-key-path=*file_name*`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_server-public-key-path)

  The path name to a file containing a client-side copy of the public key required by the server for RSA key pair-based password exchange. The file must be in PEM format. This option applies to clients that authenticate with the`sha256_password` or `caching_sha2_password` authentication plugin. This option is ignored for accounts that do not authenticate with one of those plugins. It is also ignored if RSA-based password exchange is not used, as is the case when the client connects to the server using a secure connection.

  If [`--server-public-key-path=*file_name*`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_server-public-key-path) is given and specifies a valid public key file, it takes precedence over [`--get-server-public-key`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_get-server-public-key).

  For `sha256_password`, this option applies only if MySQL was built using OpenSSL.

  For information about the `sha256_password` and `caching_sha2_password` plugins, see [Section 6.5.1.2, “SHA-256 Pluggable Authentication”](https://dev.mysql.com/doc/refman/8.0/en/sha256-pluggable-authentication.html), and [Section 6.5.1.3, “Caching SHA-2 Pluggable Authentication”](https://dev.mysql.com/doc/refman/8.0/en/caching-sha2-pluggable-authentication.html).

- [`--shared-memory-base-name=*name*`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_shared-memory-base-name)

  On Windows, the shared-memory name to use, for connections made using shared memory to a local server. This option applies only if the server supports shared-memory connections.

- [`--silent`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_silent), `-s`

  Silent mode. No output.

- [`--socket=*path*`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_socket), `-S *path*`

  For connections to `localhost`, the Unix socket file to use, or, on Windows, the name of the named pipe to use.

- [`--sql-mode=*mode*`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_sql-mode)

  Set the SQL mode for the client session.

- `--ssl*`

  Options that begin with [`--ssl`](https://dev.mysql.com/doc/refman/8.0/en/encrypted-connection-options.html#option_general_ssl) specify whether to connect to the server using SSL and indicate where to find SSL keys and certificates. See [Section 6.4.2, “Command Options for Encrypted Connections”](https://dev.mysql.com/doc/refman/8.0/en/encrypted-connection-options.html).

- [`--ssl-fips-mode={OFF|ON|STRICT}`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_ssl-fips-mode)



  Controls whether to enable FIPS mode on the client side. The [`--ssl-fips-mode`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_ssl-fips-mode) option differs from other `--ssl-*xxx*` options in that it is not used to establish encrypted connections, but rather to affect which cryptographic operations are permitted. See [Section 6.6, “FIPS Support”](https://dev.mysql.com/doc/refman/8.0/en/fips-mode.html).

  These [`--ssl-fips-mode`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_ssl-fips-mode) values are permitted:

  - `OFF`: Disable FIPS mode.
  - `ON`: Enable FIPS mode.
  - `STRICT`: Enable “strict” FIPS mode.

  Note

  If the OpenSSL FIPS Object Module is not available, the only permitted value for [`--ssl-fips-mode`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_ssl-fips-mode) is `OFF`. In this case, setting [`--ssl-fips-mode`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_ssl-fips-mode) to `ON` or `STRICT` causes the client to produce a warning at startup and to operate in non-FIPS mode.

- [`--tls-version=*protocol_list*`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_tls-version)

  The protocols permitted by the client for encrypted connections. The value is a comma-separated list containing one or more protocol names. The protocols that can be named for this option depend on the SSL library used to compile MySQL. For details, see [Section 6.4.6, “Encrypted Connection Protocols and Ciphers”](https://dev.mysql.com/doc/refman/8.0/en/encrypted-connection-protocols-ciphers.html).

- [`--user=*user_name*`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_user), `-u *user_name*`

  The MySQL user name to use when connecting to the server.

- [`--verbose`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_verbose), `-v`

  Verbose mode. Print more information about what the program does. This option can be used multiple times to increase the amount of information.

- [`--version`](https://dev.mysql.com/doc/refman/8.0/en/mysqlslap.html#option_mysqlslap_version), `-V`

  Display version information and exit.