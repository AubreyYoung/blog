# 【原创】mysqlslap 使用总结 - 摩云飞的个人页面 - 开源中国

#  【原创】mysqlslap 使用总结

原原创

荐推荐

[ 摩云飞](https://my.oschina.net/moooofly) 发布于 2013/08/14 10:24

字数 3640

阅读 10212

收藏 235

点赞 4

[__ 评论  5](https://my.oschina.net/moooofly/blog/152547#comments)

[mysqlslap](https://my.oschina.net/moooofly?q=mysqlslap)

  
mysqlslap 可以用于模拟服务器的负载，并输出计时信息。其被包含在 MySQL 5.1 的发行包中。测试时，可以指定并发连接数，可以指定 SQL
语句。如果没有指定 SQL 语句，mysqlslap 会自动生成查询 schema 的 SELECT 语句。  
  
  
1\. 查看帮助信息。  

    
    
    [root@Betty libmysql]# mysqlslap --help
    mysqlslap  Ver 1.0 Distrib 5.6.10, for Linux (x86_64)
    Copyright (c) 2005, 2013, Oracle and/or its affiliates. All rights reserved.
    
    Oracle is a registered trademark of Oracle Corporation and/or its
    affiliates. Other names may be trademarks of their respective
    owners.
    
    Run a query multiple times against the server.
    
    Usage: mysqlslap [OPTIONS]
    
    Default options are read from the following files in the given order:
    /etc/my.cnf /etc/mysql/my.cnf /usr/local/mysql/etc/my.cnf ~/.my.cnf 
    The following groups are read: mysqlslap client
    The following options may be given as the first argument:
    --print-defaults        Print the program argument list and exit.
    --no-defaults           Don't read default options from any option file,
                            except for login file.
    --defaults-file=#       Only read default options from the given file #.
    --defaults-extra-file=# Read this file after the global files are read.
    --defaults-group-suffix=#
                            Also read groups with concat(group, suffix)
    --login-path=#          Read this path from the login file.
      -?, --help          Display this help and exit.
      -a, --auto-generate-sql 自动生成测试表和数据
                          Generate SQL where not supplied by file or command line.
      --auto-generate-sql-add-autoincrement 增加auto_increment一列
                          Add an AUTO_INCREMENT column to auto-generated tables.
      --auto-generate-sql-execute-number=# 自动生成的查询的个数
                          Set this number to generate a set number of queries to
                          run.
      --auto-generate-sql-guid-primary 增加基于GUID的主键
                          Add GUID based primary keys to auto-generated tables.
      --auto-generate-sql-load-type=name 测试语句的类型。取值包括：read，key，write，update和mixed(默认)
                          read:查询 write:插入 key:读主键 update:更新主键 mixed:一半插入一半查询
                          Specify test load type: mixed, update, write, key, or
                          read; default is mixed.
      --auto-generate-sql-secondary-indexes=# 增加二级索引的个数，默认是0
                          Number of secondary indexes to add to auto-generated
                          tables.
      --auto-generate-sql-unique-query-number=# 不同查询的数量，默认值是10
                          Number of unique queries to generate for automatic tests.
      --auto-generate-sql-unique-write-number=# 不同插入的数量，默认是100
                          Number of unique queries to generate for
                          auto-generate-sql-write-number.
      --auto-generate-sql-write-number=# 
                          Number of row inserts to perform for each thread (default
                          is 100).
      --commit=#          多少条DML后提交一次
                          Commit records every X number of statements.
      -C, --compress      如果服务器和客户端支持都压缩，则压缩信息传递
                          Use compression in server/client protocol.
      -c, --concurrency=name 模拟N个客户端并发执行select。可指定多个值，以逗号或者 --delimiter 参数指定的值做为分隔符
                          Number of clients to simulate for query to run.
      --create=name       指定用于创建表的.sql文件或者字串
                          File or string to use create tables.
      --create-schema=name 指定待测试的数据库名，MySQL中schema也就是database，默认是mysqlslap
                          Schema to run tests in.
      --csv[=name]        Generate CSV output to named file or to stdout if no file
                          is named.
      -#, --debug[=#]     This is a non-debug version. Catch this and exit.
      --debug-check       Check memory and open file usage at exit.
      -T, --debug-info    打印内存和CPU的信息
                          Print some debug info at exit.
      --default-auth=name Default authentication client-side plugin to use.
      -F, --delimiter=name 文件中的SQL语句使用分割符号
                          Delimiter to use in SQL statements supplied in file or
                          command line.
      --detach=#          每执行完N个语句，先断开再重新打开连接
                          Detach (close and reopen) connections after X number of
                          requests.
      --enable-cleartext-plugin 
                          Enable/disable the clear text authentication plugin.
      -e, --engine=name   创建测试表所使用的存储引擎，可指定多个
                          Storage engine to use for creating the table.
      -h, --host=name     Connect to host.
      -i, --iterations=#  迭代执行的次数
                          Number of times to run the tests.
      --no-drop           Do not drop the schema after the test.
      -x, --number-char-cols=name 自动生成的测试表中包含多少个字符类型的列，默认1
                          Number of VARCHAR columns to create in table if
                          specifying --auto-generate-sql.
      -y, --number-int-cols=name 自动生成的测试表中包含多少个数字类型的列，默认1
                          Number of INT columns to create in table if specifying
                          --auto-generate-sql.
      --number-of-queries=# 总的测试查询次数(并发客户数×每客户查询次数)
                          Limit each client to this number of queries (this is not
                          exact).
      --only-print        只输出模拟执行的结果，不实际执行
                          Do not connect to the databases, but instead print out
                          what would have been done.
      -p, --password[=name] 
                          Password to use when connecting to server. If password is
                          not given it's asked from the tty.
      --plugin-dir=name   Directory for client-side plugins.
      -P, --port=#        Port number to use for connection.
      --post-query=name   测试完成以后执行的SQL语句的文件或者字符串 这个过程不影响时间计算
                          Query to run or file containing query to execute after
                          tests have completed.
      --post-system=name  测试完成以后执行的系统语句 这个过程不影响时间计算
                          system() string to execute after tests have completed.
      --pre-query=name    测试执行之前执行的SQL语句的文件或者字符串 这个过程不影响时间计算
                          Query to run or file containing query to execute before
                          running tests.
      --pre-system=name   测试执行之前执行的系统语句 这个过程不影响时间计算
                          system() string to execute before running tests.
      --protocol=name     The protocol to use for connection (tcp, socket, pipe,
                          memory).
      -q, --query=name    指定自定义.sql脚本执行测试。例如可以调用自定义的一个存储过程或者sql语句来执行测试
                          Query to run or file containing query to run.
      -s, --silent        不输出
                          Run program in silent mode - no output.
      -S, --socket=name   The socket file to use for connection.
      --ssl               Enable SSL for connection (automatically enabled with
                          other flags).
      --ssl-ca=name       CA file in PEM format (check OpenSSL docs, implies
                          --ssl).
      --ssl-capath=name   CA directory (check OpenSSL docs, implies --ssl).
      --ssl-cert=name     X509 cert in PEM format (implies --ssl).
      --ssl-cipher=name   SSL cipher to use (implies --ssl).
      --ssl-key=name      X509 key in PEM format (implies --ssl).
      --ssl-crl=name      Certificate revocation list (implies --ssl).
      --ssl-crlpath=name  Certificate revocation list path (implies --ssl).
      --ssl-verify-server-cert 
                          Verify server's "Common Name" in its cert against
                          hostname used when connecting. This option is disabled by
                          default.
      -u, --user=name     User for login if not current user.
      -v, --verbose       输出更多的信息
                          More verbose output; you can use this multiple times to
                          get even more verbose output.
      -V, --version       Output version information and exit.
    [root@Betty libmysql]#

  
2\. 以自动生成测试表和数据的形式，分别模拟 50 和 100 个客户端并发连接处理 1000 个 query 的情况。  

    
    
    [root@Betty libmysql]# mysqlslap -a --concurrency=50,100 --number-of-queries=1000             
    Benchmark
            Average number of seconds to run all queries: 0.148 seconds
            Minimum number of seconds to run all queries: 0.148 seconds
            Maximum number of seconds to run all queries: 0.148 seconds
            Number of clients running queries: 50
            Average number of queries per client: 20
    
    Benchmark
            Average number of seconds to run all queries: 0.246 seconds
            Minimum number of seconds to run all queries: 0.246 seconds
            Maximum number of seconds to run all queries: 0.246 seconds
            Number of clients running queries: 100
            Average number of queries per client: 10
    
    [root@Betty libmysql]#

  
3\.  增加 --debug-info 选项，可以输出内存和CPU信息。  

    
    
    [root@Betty libmysql]# mysqlslap -a --concurrency=50,100 --number-of-queries=1000 --debug-info
    Benchmark
            Average number of seconds to run all queries: 0.202 seconds
            Minimum number of seconds to run all queries: 0.202 seconds
            Maximum number of seconds to run all queries: 0.202 seconds
            Number of clients running queries: 50
            Average number of queries per client: 20
    
    Benchmark
            Average number of seconds to run all queries: 0.193 seconds
            Minimum number of seconds to run all queries: 0.193 seconds
            Maximum number of seconds to run all queries: 0.193 seconds
            Number of clients running queries: 100
            Average number of queries per client: 10
    
    
    User time 0.09, System time 0.05
    Maximum resident set size 7848, Integral resident set size 0
    Non-physical pagefaults 4221, Physical pagefaults 0, Swaps 0
    Blocks in 0 out 0, Messages in 0 out 0, Signals 0
    Voluntary context switches 7314, Involuntary context switches 1400

  
4\. 增加 --iterations 选项，可以 重复执行 5 次  

    
    
    [root@Betty libmysql]# 
    [root@Betty libmysql]# mysqlslap -a --concurrency=50,100 --number-of-queries=1000 --iterations=5 --debug-info
    Benchmark
            Average number of seconds to run all queries: 0.168 seconds
            Minimum number of seconds to run all queries: 0.147 seconds
            Maximum number of seconds to run all queries: 0.217 seconds
            Number of clients running queries: 50
            Average number of queries per client: 20
    
    Benchmark
            Average number of seconds to run all queries: 0.209 seconds
            Minimum number of seconds to run all queries: 0.156 seconds
            Maximum number of seconds to run all queries: 0.280 seconds
            Number of clients running queries: 100
            Average number of queries per client: 10
    
    
    User time 0.47, System time 0.25
    Maximum resident set size 9848, Integral resident set size 0
    Non-physical pagefaults 16880, Physical pagefaults 0, Swaps 0
    Blocks in 0 out 0, Messages in 0 out 0, Signals 0
    Voluntary context switches 35954, Involuntary context switches 6583
    [root@Betty libmysql]#

  
5\. 可以 针对远程主机上的 mysql 进行测试。  

    
    
    [root@Betty Shell]# mysqlslap -a --concurrency=50,100 --number-of-queries=1000 -h 172.16.81.99 -P 3306 -p
    Enter password: 
    Benchmark
            Average number of seconds to run all queries: 2.009 seconds
            Minimum number of seconds to run all queries: 2.009 seconds
            Maximum number of seconds to run all queries: 2.009 seconds
            Number of clients running queries: 50
            Average number of queries per client: 20
    
    Benchmark
            Average number of seconds to run all queries: 4.519 seconds
            Minimum number of seconds to run all queries: 4.519 seconds
            Maximum number of seconds to run all queries: 4.519 seconds
            Number of clients running queries: 100
            Average number of queries per client: 10
    
    [root@Betty Shell]#

  
6\. 使用 --only-print 选项，可以查看 mysqlslap 在测试过程中如何执行的 sql
语句。在这种方式下，仅会对数据库进行模拟操作。如下显示的自动产生测试表和数据的情况下，mysqlslap 的执行过程： 创建一个临时的库 mysqlslap
，并在测试结束是会将其删除。  

    
    
    [root@Betty libmysql]# mysqlslap -a --only-print                                              
    DROP SCHEMA IF EXISTS `mysqlslap`;
    CREATE SCHEMA `mysqlslap`;
    use mysqlslap;
    CREATE TABLE `t1` (intcol1 INT(32) ,charcol1 VARCHAR(128));
    INSERT INTO t1 VALUES (1804289383,'mxvtvmC9127qJNm06sGB8R92q2j7vTiiITRDGXM9ZLzkdekbWtmXKwZ2qG1llkRw5m9DHOFilEREk3q7oce8O3BEJC0woJsm6uzFAEynLH2xCsw1KQ1lT4zg9rdxBL');
    INSERT INTO t1 VALUES (822890675,'97RGHZ65mNzkSrYT3zWoSbg9cNePQr1bzSk81qDgE4Oanw3rnPfGsBHSbnu1evTdFDe83ro9w4jjteQg4yoo9xHck3WNqzs54W5zEm92ikdRF48B2oz3m8gMBAl11W');
    INSERT INTO t1 VALUES (1308044878,'50w46i58Giekxik0cYzfA8BZBLADEg3JhzGfZDoqvQQk0Akcic7lcJInYSsf9wqin6LDC1vzJLkJXKn5onqOy04MTw1WksCYqPl2Jg2eteqOqTLfGCvE4zTZwWvgMz');
    INSERT INTO t1 VALUES (964445884,'DPh7kD1E6f4MMQk1ioopsoIIcoD83DD8Wu7689K6oHTAjD3Hts6lYGv8x9G0EL0k87q8G2ExJjz2o3KhnIJBbEJYFROTpO5pNvxgyBT9nSCbNO9AiKL9QYhi0x3hL9');
    INSERT INTO t1 VALUES (1586903190,'lwRHuWm4HE8leYmg66uGYIp6AnAr0BDd7YmuvYqCfqp9EbhKZRSymA4wx6gpHlJHI53DetH9j7Ixar90Jey5outd1ZIAJdJTjMaD7rMiqYXHFhHaB7Xr1HKuqe51GG');
    INSERT INTO t1 VALUES (962033002,'rfw4egILWisfxPwOc3nJx4frnAwgI539kr5EXFbupSZelM2MHqZEmD6ZNuEZzHib8fqYuHQbdrDND8lXqIdcNbAeWOBLZlpZOX5AoNlQFzpK7QjxcLP0wbWIriYGJL');
    INSERT INTO t1 VALUES (1910858270,'ksnug3YyANnWWDEJiRkiFC4a3e6KyJ2i3hSjksiuFLHlRXw9yhjDtnfoQd0OouyrcIbCB9zQWG4pf0yTZhaIT67nj7BY21FWJqaWrZxEh13Kt2hRbGl4MsrxsuLmvd');
    INSERT INTO t1 VALUES (63299708,'FJid3GaHpRC2L6jgirPm5AW3uGGgCloJ5Ww0eNHSiLWvS5bAxto23AxxR6TXr9qofeoAtxWcJsXnxzxmsdhvoekFc5mSES8tyxvsuPK5Hjs7ihtaJaLz5xEh2s1GCA');
    INSERT INTO t1 VALUES (737703662,'2zxutF6rOqjXYHHzSrKRwAhWCPXTdhNXYKQIRO9sEkFf1YeTGqw40Ta5u6QNfpvC1DWTTXDkFSFHtte9bbDSwgZjmryHglLhqjAKEF4MkJfT49eXcjzZNOG1F6BnsY');
    INSERT INTO t1 VALUES (1348361729,'i8X2EnycNH7sDHMltxcILtQE0ZPoPq9zyg24J0hiAgQNpg8jedtrWK5WtXIALR9B03FJ4ou6TCTAtWtN7fETzBzkiAmvTv6LrEZn2RtNfMaOkJfjytCp54ZfEJbb7Z');
    INSERT INTO t1 VALUES (1804289383,'mxvtvmC9127qJNm06sGB8R92q2j7vTiiITRDGXM9ZLzkdekbWtmXKwZ2qG1llkRw5m9DHOFilEREk3q7oce8O3BEJC0woJsm6uzFAEynLH2xCsw1KQ1lT4zg9rdxBL');
    INSERT INTO t1 VALUES (822890675,'97RGHZ65mNzkSrYT3zWoSbg9cNePQr1bzSk81qDgE4Oanw3rnPfGsBHSbnu1evTdFDe83ro9w4jjteQg4yoo9xHck3WNqzs54W5zEm92ikdRF48B2oz3m8gMBAl11W');
    INSERT INTO t1 VALUES (1308044878,'50w46i58Giekxik0cYzfA8BZBLADEg3JhzGfZDoqvQQk0Akcic7lcJInYSsf9wqin6LDC1vzJLkJXKn5onqOy04MTw1WksCYqPl2Jg2eteqOqTLfGCvE4zTZwWvgMz');
    INSERT INTO t1 VALUES (964445884,'DPh7kD1E6f4MMQk1ioopsoIIcoD83DD8Wu7689K6oHTAjD3Hts6lYGv8x9G0EL0k87q8G2ExJjz2o3KhnIJBbEJYFROTpO5pNvxgyBT9nSCbNO9AiKL9QYhi0x3hL9');
    INSERT INTO t1 VALUES (1586903190,'lwRHuWm4HE8leYmg66uGYIp6AnAr0BDd7YmuvYqCfqp9EbhKZRSymA4wx6gpHlJHI53DetH9j7Ixar90Jey5outd1ZIAJdJTjMaD7rMiqYXHFhHaB7Xr1HKuqe51GG');
    INSERT INTO t1 VALUES (962033002,'rfw4egILWisfxPwOc3nJx4frnAwgI539kr5EXFbupSZelM2MHqZEmD6ZNuEZzHib8fqYuHQbdrDND8lXqIdcNbAeWOBLZlpZOX5AoNlQFzpK7QjxcLP0wbWIriYGJL');
    INSERT INTO t1 VALUES (1910858270,'ksnug3YyANnWWDEJiRkiFC4a3e6KyJ2i3hSjksiuFLHlRXw9yhjDtnfoQd0OouyrcIbCB9zQWG4pf0yTZhaIT67nj7BY21FWJqaWrZxEh13Kt2hRbGl4MsrxsuLmvd');
    INSERT INTO t1 VALUES (63299708,'FJid3GaHpRC2L6jgirPm5AW3uGGgCloJ5Ww0eNHSiLWvS5bAxto23AxxR6TXr9qofeoAtxWcJsXnxzxmsdhvoekFc5mSES8tyxvsuPK5Hjs7ihtaJaLz5xEh2s1GCA');
    INSERT INTO t1 VALUES (737703662,'2zxutF6rOqjXYHHzSrKRwAhWCPXTdhNXYKQIRO9sEkFf1YeTGqw40Ta5u6QNfpvC1DWTTXDkFSFHtte9bbDSwgZjmryHglLhqjAKEF4MkJfT49eXcjzZNOG1F6BnsY');
    INSERT INTO t1 VALUES (1348361729,'i8X2EnycNH7sDHMltxcILtQE0ZPoPq9zyg24J0hiAgQNpg8jedtrWK5WtXIALR9B03FJ4ou6TCTAtWtN7fETzBzkiAmvTv6LrEZn2RtNfMaOkJfjytCp54ZfEJbb7Z');
    INSERT INTO t1 VALUES (1804289383,'mxvtvmC9127qJNm06sGB8R92q2j7vTiiITRDGXM9ZLzkdekbWtmXKwZ2qG1llkRw5m9DHOFilEREk3q7oce8O3BEJC0woJsm6uzFAEynLH2xCsw1KQ1lT4zg9rdxBL');
    INSERT INTO t1 VALUES (822890675,'97RGHZ65mNzkSrYT3zWoSbg9cNePQr1bzSk81qDgE4Oanw3rnPfGsBHSbnu1evTdFDe83ro9w4jjteQg4yoo9xHck3WNqzs54W5zEm92ikdRF48B2oz3m8gMBAl11W');
    INSERT INTO t1 VALUES (1308044878,'50w46i58Giekxik0cYzfA8BZBLADEg3JhzGfZDoqvQQk0Akcic7lcJInYSsf9wqin6LDC1vzJLkJXKn5onqOy04MTw1WksCYqPl2Jg2eteqOqTLfGCvE4zTZwWvgMz');
    INSERT INTO t1 VALUES (964445884,'DPh7kD1E6f4MMQk1ioopsoIIcoD83DD8Wu7689K6oHTAjD3Hts6lYGv8x9G0EL0k87q8G2ExJjz2o3KhnIJBbEJYFROTpO5pNvxgyBT9nSCbNO9AiKL9QYhi0x3hL9');
    INSERT INTO t1 VALUES (1586903190,'lwRHuWm4HE8leYmg66uGYIp6AnAr0BDd7YmuvYqCfqp9EbhKZRSymA4wx6gpHlJHI53DetH9j7Ixar90Jey5outd1ZIAJdJTjMaD7rMiqYXHFhHaB7Xr1HKuqe51GG');
    INSERT INTO t1 VALUES (962033002,'rfw4egILWisfxPwOc3nJx4frnAwgI539kr5EXFbupSZelM2MHqZEmD6ZNuEZzHib8fqYuHQbdrDND8lXqIdcNbAeWOBLZlpZOX5AoNlQFzpK7QjxcLP0wbWIriYGJL');
    INSERT INTO t1 VALUES (1910858270,'ksnug3YyANnWWDEJiRkiFC4a3e6KyJ2i3hSjksiuFLHlRXw9yhjDtnfoQd0OouyrcIbCB9zQWG4pf0yTZhaIT67nj7BY21FWJqaWrZxEh13Kt2hRbGl4MsrxsuLmvd');
    INSERT INTO t1 VALUES (63299708,'FJid3GaHpRC2L6jgirPm5AW3uGGgCloJ5Ww0eNHSiLWvS5bAxto23AxxR6TXr9qofeoAtxWcJsXnxzxmsdhvoekFc5mSES8tyxvsuPK5Hjs7ihtaJaLz5xEh2s1GCA');
    INSERT INTO t1 VALUES (737703662,'2zxutF6rOqjXYHHzSrKRwAhWCPXTdhNXYKQIRO9sEkFf1YeTGqw40Ta5u6QNfpvC1DWTTXDkFSFHtte9bbDSwgZjmryHglLhqjAKEF4MkJfT49eXcjzZNOG1F6BnsY');
    INSERT INTO t1 VALUES (1348361729,'i8X2EnycNH7sDHMltxcILtQE0ZPoPq9zyg24J0hiAgQNpg8jedtrWK5WtXIALR9B03FJ4ou6TCTAtWtN7fETzBzkiAmvTv6LrEZn2RtNfMaOkJfjytCp54ZfEJbb7Z');
    INSERT INTO t1 VALUES (1804289383,'mxvtvmC9127qJNm06sGB8R92q2j7vTiiITRDGXM9ZLzkdekbWtmXKwZ2qG1llkRw5m9DHOFilEREk3q7oce8O3BEJC0woJsm6uzFAEynLH2xCsw1KQ1lT4zg9rdxBL');
    INSERT INTO t1 VALUES (822890675,'97RGHZ65mNzkSrYT3zWoSbg9cNePQr1bzSk81qDgE4Oanw3rnPfGsBHSbnu1evTdFDe83ro9w4jjteQg4yoo9xHck3WNqzs54W5zEm92ikdRF48B2oz3m8gMBAl11W');
    INSERT INTO t1 VALUES (1308044878,'50w46i58Giekxik0cYzfA8BZBLADEg3JhzGfZDoqvQQk0Akcic7lcJInYSsf9wqin6LDC1vzJLkJXKn5onqOy04MTw1WksCYqPl2Jg2eteqOqTLfGCvE4zTZwWvgMz');
    INSERT INTO t1 VALUES (964445884,'DPh7kD1E6f4MMQk1ioopsoIIcoD83DD8Wu7689K6oHTAjD3Hts6lYGv8x9G0EL0k87q8G2ExJjz2o3KhnIJBbEJYFROTpO5pNvxgyBT9nSCbNO9AiKL9QYhi0x3hL9');
    INSERT INTO t1 VALUES (1586903190,'lwRHuWm4HE8leYmg66uGYIp6AnAr0BDd7YmuvYqCfqp9EbhKZRSymA4wx6gpHlJHI53DetH9j7Ixar90Jey5outd1ZIAJdJTjMaD7rMiqYXHFhHaB7Xr1HKuqe51GG');
    INSERT INTO t1 VALUES (962033002,'rfw4egILWisfxPwOc3nJx4frnAwgI539kr5EXFbupSZelM2MHqZEmD6ZNuEZzHib8fqYuHQbdrDND8lXqIdcNbAeWOBLZlpZOX5AoNlQFzpK7QjxcLP0wbWIriYGJL');
    INSERT INTO t1 VALUES (1910858270,'ksnug3YyANnWWDEJiRkiFC4a3e6KyJ2i3hSjksiuFLHlRXw9yhjDtnfoQd0OouyrcIbCB9zQWG4pf0yTZhaIT67nj7BY21FWJqaWrZxEh13Kt2hRbGl4MsrxsuLmvd');
    INSERT INTO t1 VALUES (63299708,'FJid3GaHpRC2L6jgirPm5AW3uGGgCloJ5Ww0eNHSiLWvS5bAxto23AxxR6TXr9qofeoAtxWcJsXnxzxmsdhvoekFc5mSES8tyxvsuPK5Hjs7ihtaJaLz5xEh2s1GCA');
    INSERT INTO t1 VALUES (737703662,'2zxutF6rOqjXYHHzSrKRwAhWCPXTdhNXYKQIRO9sEkFf1YeTGqw40Ta5u6QNfpvC1DWTTXDkFSFHtte9bbDSwgZjmryHglLhqjAKEF4MkJfT49eXcjzZNOG1F6BnsY');
    INSERT INTO t1 VALUES (1348361729,'i8X2EnycNH7sDHMltxcILtQE0ZPoPq9zyg24J0hiAgQNpg8jedtrWK5WtXIALR9B03FJ4ou6TCTAtWtN7fETzBzkiAmvTv6LrEZn2RtNfMaOkJfjytCp54ZfEJbb7Z');
    INSERT INTO t1 VALUES (1804289383,'mxvtvmC9127qJNm06sGB8R92q2j7vTiiITRDGXM9ZLzkdekbWtmXKwZ2qG1llkRw5m9DHOFilEREk3q7oce8O3BEJC0woJsm6uzFAEynLH2xCsw1KQ1lT4zg9rdxBL');
    INSERT INTO t1 VALUES (822890675,'97RGHZ65mNzkSrYT3zWoSbg9cNePQr1bzSk81qDgE4Oanw3rnPfGsBHSbnu1evTdFDe83ro9w4jjteQg4yoo9xHck3WNqzs54W5zEm92ikdRF48B2oz3m8gMBAl11W');
    INSERT INTO t1 VALUES (1308044878,'50w46i58Giekxik0cYzfA8BZBLADEg3JhzGfZDoqvQQk0Akcic7lcJInYSsf9wqin6LDC1vzJLkJXKn5onqOy04MTw1WksCYqPl2Jg2eteqOqTLfGCvE4zTZwWvgMz');
    INSERT INTO t1 VALUES (964445884,'DPh7kD1E6f4MMQk1ioopsoIIcoD83DD8Wu7689K6oHTAjD3Hts6lYGv8x9G0EL0k87q8G2ExJjz2o3KhnIJBbEJYFROTpO5pNvxgyBT9nSCbNO9AiKL9QYhi0x3hL9');
    INSERT INTO t1 VALUES (1586903190,'lwRHuWm4HE8leYmg66uGYIp6AnAr0BDd7YmuvYqCfqp9EbhKZRSymA4wx6gpHlJHI53DetH9j7Ixar90Jey5outd1ZIAJdJTjMaD7rMiqYXHFhHaB7Xr1HKuqe51GG');
    INSERT INTO t1 VALUES (962033002,'rfw4egILWisfxPwOc3nJx4frnAwgI539kr5EXFbupSZelM2MHqZEmD6ZNuEZzHib8fqYuHQbdrDND8lXqIdcNbAeWOBLZlpZOX5AoNlQFzpK7QjxcLP0wbWIriYGJL');
    INSERT INTO t1 VALUES (1910858270,'ksnug3YyANnWWDEJiRkiFC4a3e6KyJ2i3hSjksiuFLHlRXw9yhjDtnfoQd0OouyrcIbCB9zQWG4pf0yTZhaIT67nj7BY21FWJqaWrZxEh13Kt2hRbGl4MsrxsuLmvd');
    INSERT INTO t1 VALUES (63299708,'FJid3GaHpRC2L6jgirPm5AW3uGGgCloJ5Ww0eNHSiLWvS5bAxto23AxxR6TXr9qofeoAtxWcJsXnxzxmsdhvoekFc5mSES8tyxvsuPK5Hjs7ihtaJaLz5xEh2s1GCA');
    INSERT INTO t1 VALUES (737703662,'2zxutF6rOqjXYHHzSrKRwAhWCPXTdhNXYKQIRO9sEkFf1YeTGqw40Ta5u6QNfpvC1DWTTXDkFSFHtte9bbDSwgZjmryHglLhqjAKEF4MkJfT49eXcjzZNOG1F6BnsY');
    INSERT INTO t1 VALUES (1348361729,'i8X2EnycNH7sDHMltxcILtQE0ZPoPq9zyg24J0hiAgQNpg8jedtrWK5WtXIALR9B03FJ4ou6TCTAtWtN7fETzBzkiAmvTv6LrEZn2RtNfMaOkJfjytCp54ZfEJbb7Z');
    INSERT INTO t1 VALUES (1804289383,'mxvtvmC9127qJNm06sGB8R92q2j7vTiiITRDGXM9ZLzkdekbWtmXKwZ2qG1llkRw5m9DHOFilEREk3q7oce8O3BEJC0woJsm6uzFAEynLH2xCsw1KQ1lT4zg9rdxBL');
    INSERT INTO t1 VALUES (822890675,'97RGHZ65mNzkSrYT3zWoSbg9cNePQr1bzSk81qDgE4Oanw3rnPfGsBHSbnu1evTdFDe83ro9w4jjteQg4yoo9xHck3WNqzs54W5zEm92ikdRF48B2oz3m8gMBAl11W');
    INSERT INTO t1 VALUES (1308044878,'50w46i58Giekxik0cYzfA8BZBLADEg3JhzGfZDoqvQQk0Akcic7lcJInYSsf9wqin6LDC1vzJLkJXKn5onqOy04MTw1WksCYqPl2Jg2eteqOqTLfGCvE4zTZwWvgMz');
    INSERT INTO t1 VALUES (964445884,'DPh7kD1E6f4MMQk1ioopsoIIcoD83DD8Wu7689K6oHTAjD3Hts6lYGv8x9G0EL0k87q8G2ExJjz2o3KhnIJBbEJYFROTpO5pNvxgyBT9nSCbNO9AiKL9QYhi0x3hL9');
    INSERT INTO t1 VALUES (1586903190,'lwRHuWm4HE8leYmg66uGYIp6AnAr0BDd7YmuvYqCfqp9EbhKZRSymA4wx6gpHlJHI53DetH9j7Ixar90Jey5outd1ZIAJdJTjMaD7rMiqYXHFhHaB7Xr1HKuqe51GG');
    INSERT INTO t1 VALUES (962033002,'rfw4egILWisfxPwOc3nJx4frnAwgI539kr5EXFbupSZelM2MHqZEmD6ZNuEZzHib8fqYuHQbdrDND8lXqIdcNbAeWOBLZlpZOX5AoNlQFzpK7QjxcLP0wbWIriYGJL');
    INSERT INTO t1 VALUES (1910858270,'ksnug3YyANnWWDEJiRkiFC4a3e6KyJ2i3hSjksiuFLHlRXw9yhjDtnfoQd0OouyrcIbCB9zQWG4pf0yTZhaIT67nj7BY21FWJqaWrZxEh13Kt2hRbGl4MsrxsuLmvd');
    INSERT INTO t1 VALUES (63299708,'FJid3GaHpRC2L6jgirPm5AW3uGGgCloJ5Ww0eNHSiLWvS5bAxto23AxxR6TXr9qofeoAtxWcJsXnxzxmsdhvoekFc5mSES8tyxvsuPK5Hjs7ihtaJaLz5xEh2s1GCA');
    INSERT INTO t1 VALUES (737703662,'2zxutF6rOqjXYHHzSrKRwAhWCPXTdhNXYKQIRO9sEkFf1YeTGqw40Ta5u6QNfpvC1DWTTXDkFSFHtte9bbDSwgZjmryHglLhqjAKEF4MkJfT49eXcjzZNOG1F6BnsY');
    INSERT INTO t1 VALUES (1348361729,'i8X2EnycNH7sDHMltxcILtQE0ZPoPq9zyg24J0hiAgQNpg8jedtrWK5WtXIALR9B03FJ4ou6TCTAtWtN7fETzBzkiAmvTv6LrEZn2RtNfMaOkJfjytCp54ZfEJbb7Z');
    INSERT INTO t1 VALUES (1804289383,'mxvtvmC9127qJNm06sGB8R92q2j7vTiiITRDGXM9ZLzkdekbWtmXKwZ2qG1llkRw5m9DHOFilEREk3q7oce8O3BEJC0woJsm6uzFAEynLH2xCsw1KQ1lT4zg9rdxBL');
    INSERT INTO t1 VALUES (822890675,'97RGHZ65mNzkSrYT3zWoSbg9cNePQr1bzSk81qDgE4Oanw3rnPfGsBHSbnu1evTdFDe83ro9w4jjteQg4yoo9xHck3WNqzs54W5zEm92ikdRF48B2oz3m8gMBAl11W');
    INSERT INTO t1 VALUES (1308044878,'50w46i58Giekxik0cYzfA8BZBLADEg3JhzGfZDoqvQQk0Akcic7lcJInYSsf9wqin6LDC1vzJLkJXKn5onqOy04MTw1WksCYqPl2Jg2eteqOqTLfGCvE4zTZwWvgMz');
    INSERT INTO t1 VALUES (964445884,'DPh7kD1E6f4MMQk1ioopsoIIcoD83DD8Wu7689K6oHTAjD3Hts6lYGv8x9G0EL0k87q8G2ExJjz2o3KhnIJBbEJYFROTpO5pNvxgyBT9nSCbNO9AiKL9QYhi0x3hL9');
    INSERT INTO t1 VALUES (1586903190,'lwRHuWm4HE8leYmg66uGYIp6AnAr0BDd7YmuvYqCfqp9EbhKZRSymA4wx6gpHlJHI53DetH9j7Ixar90Jey5outd1ZIAJdJTjMaD7rMiqYXHFhHaB7Xr1HKuqe51GG');
    INSERT INTO t1 VALUES (962033002,'rfw4egILWisfxPwOc3nJx4frnAwgI539kr5EXFbupSZelM2MHqZEmD6ZNuEZzHib8fqYuHQbdrDND8lXqIdcNbAeWOBLZlpZOX5AoNlQFzpK7QjxcLP0wbWIriYGJL');
    INSERT INTO t1 VALUES (1910858270,'ksnug3YyANnWWDEJiRkiFC4a3e6KyJ2i3hSjksiuFLHlRXw9yhjDtnfoQd0OouyrcIbCB9zQWG4pf0yTZhaIT67nj7BY21FWJqaWrZxEh13Kt2hRbGl4MsrxsuLmvd');
    INSERT INTO t1 VALUES (63299708,'FJid3GaHpRC2L6jgirPm5AW3uGGgCloJ5Ww0eNHSiLWvS5bAxto23AxxR6TXr9qofeoAtxWcJsXnxzxmsdhvoekFc5mSES8tyxvsuPK5Hjs7ihtaJaLz5xEh2s1GCA');
    INSERT INTO t1 VALUES (737703662,'2zxutF6rOqjXYHHzSrKRwAhWCPXTdhNXYKQIRO9sEkFf1YeTGqw40Ta5u6QNfpvC1DWTTXDkFSFHtte9bbDSwgZjmryHglLhqjAKEF4MkJfT49eXcjzZNOG1F6BnsY');
    INSERT INTO t1 VALUES (1348361729,'i8X2EnycNH7sDHMltxcILtQE0ZPoPq9zyg24J0hiAgQNpg8jedtrWK5WtXIALR9B03FJ4ou6TCTAtWtN7fETzBzkiAmvTv6LrEZn2RtNfMaOkJfjytCp54ZfEJbb7Z');
    INSERT INTO t1 VALUES (1804289383,'mxvtvmC9127qJNm06sGB8R92q2j7vTiiITRDGXM9ZLzkdekbWtmXKwZ2qG1llkRw5m9DHOFilEREk3q7oce8O3BEJC0woJsm6uzFAEynLH2xCsw1KQ1lT4zg9rdxBL');
    INSERT INTO t1 VALUES (822890675,'97RGHZ65mNzkSrYT3zWoSbg9cNePQr1bzSk81qDgE4Oanw3rnPfGsBHSbnu1evTdFDe83ro9w4jjteQg4yoo9xHck3WNqzs54W5zEm92ikdRF48B2oz3m8gMBAl11W');
    INSERT INTO t1 VALUES (1308044878,'50w46i58Giekxik0cYzfA8BZBLADEg3JhzGfZDoqvQQk0Akcic7lcJInYSsf9wqin6LDC1vzJLkJXKn5onqOy04MTw1WksCYqPl2Jg2eteqOqTLfGCvE4zTZwWvgMz');
    INSERT INTO t1 VALUES (964445884,'DPh7kD1E6f4MMQk1ioopsoIIcoD83DD8Wu7689K6oHTAjD3Hts6lYGv8x9G0EL0k87q8G2ExJjz2o3KhnIJBbEJYFROTpO5pNvxgyBT9nSCbNO9AiKL9QYhi0x3hL9');
    INSERT INTO t1 VALUES (1586903190,'lwRHuWm4HE8leYmg66uGYIp6AnAr0BDd7YmuvYqCfqp9EbhKZRSymA4wx6gpHlJHI53DetH9j7Ixar90Jey5outd1ZIAJdJTjMaD7rMiqYXHFhHaB7Xr1HKuqe51GG');
    INSERT INTO t1 VALUES (962033002,'rfw4egILWisfxPwOc3nJx4frnAwgI539kr5EXFbupSZelM2MHqZEmD6ZNuEZzHib8fqYuHQbdrDND8lXqIdcNbAeWOBLZlpZOX5AoNlQFzpK7QjxcLP0wbWIriYGJL');
    INSERT INTO t1 VALUES (1910858270,'ksnug3YyANnWWDEJiRkiFC4a3e6KyJ2i3hSjksiuFLHlRXw9yhjDtnfoQd0OouyrcIbCB9zQWG4pf0yTZhaIT67nj7BY21FWJqaWrZxEh13Kt2hRbGl4MsrxsuLmvd');
    INSERT INTO t1 VALUES (63299708,'FJid3GaHpRC2L6jgirPm5AW3uGGgCloJ5Ww0eNHSiLWvS5bAxto23AxxR6TXr9qofeoAtxWcJsXnxzxmsdhvoekFc5mSES8tyxvsuPK5Hjs7ihtaJaLz5xEh2s1GCA');
    INSERT INTO t1 VALUES (737703662,'2zxutF6rOqjXYHHzSrKRwAhWCPXTdhNXYKQIRO9sEkFf1YeTGqw40Ta5u6QNfpvC1DWTTXDkFSFHtte9bbDSwgZjmryHglLhqjAKEF4MkJfT49eXcjzZNOG1F6BnsY');
    INSERT INTO t1 VALUES (1348361729,'i8X2EnycNH7sDHMltxcILtQE0ZPoPq9zyg24J0hiAgQNpg8jedtrWK5WtXIALR9B03FJ4ou6TCTAtWtN7fETzBzkiAmvTv6LrEZn2RtNfMaOkJfjytCp54ZfEJbb7Z');
    INSERT INTO t1 VALUES (1804289383,'mxvtvmC9127qJNm06sGB8R92q2j7vTiiITRDGXM9ZLzkdekbWtmXKwZ2qG1llkRw5m9DHOFilEREk3q7oce8O3BEJC0woJsm6uzFAEynLH2xCsw1KQ1lT4zg9rdxBL');
    INSERT INTO t1 VALUES (822890675,'97RGHZ65mNzkSrYT3zWoSbg9cNePQr1bzSk81qDgE4Oanw3rnPfGsBHSbnu1evTdFDe83ro9w4jjteQg4yoo9xHck3WNqzs54W5zEm92ikdRF48B2oz3m8gMBAl11W');
    INSERT INTO t1 VALUES (1308044878,'50w46i58Giekxik0cYzfA8BZBLADEg3JhzGfZDoqvQQk0Akcic7lcJInYSsf9wqin6LDC1vzJLkJXKn5onqOy04MTw1WksCYqPl2Jg2eteqOqTLfGCvE4zTZwWvgMz');
    INSERT INTO t1 VALUES (964445884,'DPh7kD1E6f4MMQk1ioopsoIIcoD83DD8Wu7689K6oHTAjD3Hts6lYGv8x9G0EL0k87q8G2ExJjz2o3KhnIJBbEJYFROTpO5pNvxgyBT9nSCbNO9AiKL9QYhi0x3hL9');
    INSERT INTO t1 VALUES (1586903190,'lwRHuWm4HE8leYmg66uGYIp6AnAr0BDd7YmuvYqCfqp9EbhKZRSymA4wx6gpHlJHI53DetH9j7Ixar90Jey5outd1ZIAJdJTjMaD7rMiqYXHFhHaB7Xr1HKuqe51GG');
    INSERT INTO t1 VALUES (962033002,'rfw4egILWisfxPwOc3nJx4frnAwgI539kr5EXFbupSZelM2MHqZEmD6ZNuEZzHib8fqYuHQbdrDND8lXqIdcNbAeWOBLZlpZOX5AoNlQFzpK7QjxcLP0wbWIriYGJL');
    INSERT INTO t1 VALUES (1910858270,'ksnug3YyANnWWDEJiRkiFC4a3e6KyJ2i3hSjksiuFLHlRXw9yhjDtnfoQd0OouyrcIbCB9zQWG4pf0yTZhaIT67nj7BY21FWJqaWrZxEh13Kt2hRbGl4MsrxsuLmvd');
    INSERT INTO t1 VALUES (63299708,'FJid3GaHpRC2L6jgirPm5AW3uGGgCloJ5Ww0eNHSiLWvS5bAxto23AxxR6TXr9qofeoAtxWcJsXnxzxmsdhvoekFc5mSES8tyxvsuPK5Hjs7ihtaJaLz5xEh2s1GCA');
    INSERT INTO t1 VALUES (737703662,'2zxutF6rOqjXYHHzSrKRwAhWCPXTdhNXYKQIRO9sEkFf1YeTGqw40Ta5u6QNfpvC1DWTTXDkFSFHtte9bbDSwgZjmryHglLhqjAKEF4MkJfT49eXcjzZNOG1F6BnsY');
    INSERT INTO t1 VALUES (1348361729,'i8X2EnycNH7sDHMltxcILtQE0ZPoPq9zyg24J0hiAgQNpg8jedtrWK5WtXIALR9B03FJ4ou6TCTAtWtN7fETzBzkiAmvTv6LrEZn2RtNfMaOkJfjytCp54ZfEJbb7Z');
    INSERT INTO t1 VALUES (1804289383,'mxvtvmC9127qJNm06sGB8R92q2j7vTiiITRDGXM9ZLzkdekbWtmXKwZ2qG1llkRw5m9DHOFilEREk3q7oce8O3BEJC0woJsm6uzFAEynLH2xCsw1KQ1lT4zg9rdxBL');
    INSERT INTO t1 VALUES (822890675,'97RGHZ65mNzkSrYT3zWoSbg9cNePQr1bzSk81qDgE4Oanw3rnPfGsBHSbnu1evTdFDe83ro9w4jjteQg4yoo9xHck3WNqzs54W5zEm92ikdRF48B2oz3m8gMBAl11W');
    INSERT INTO t1 VALUES (1308044878,'50w46i58Giekxik0cYzfA8BZBLADEg3JhzGfZDoqvQQk0Akcic7lcJInYSsf9wqin6LDC1vzJLkJXKn5onqOy04MTw1WksCYqPl2Jg2eteqOqTLfGCvE4zTZwWvgMz');
    INSERT INTO t1 VALUES (964445884,'DPh7kD1E6f4MMQk1ioopsoIIcoD83DD8Wu7689K6oHTAjD3Hts6lYGv8x9G0EL0k87q8G2ExJjz2o3KhnIJBbEJYFROTpO5pNvxgyBT9nSCbNO9AiKL9QYhi0x3hL9');
    INSERT INTO t1 VALUES (1586903190,'lwRHuWm4HE8leYmg66uGYIp6AnAr0BDd7YmuvYqCfqp9EbhKZRSymA4wx6gpHlJHI53DetH9j7Ixar90Jey5outd1ZIAJdJTjMaD7rMiqYXHFhHaB7Xr1HKuqe51GG');
    INSERT INTO t1 VALUES (962033002,'rfw4egILWisfxPwOc3nJx4frnAwgI539kr5EXFbupSZelM2MHqZEmD6ZNuEZzHib8fqYuHQbdrDND8lXqIdcNbAeWOBLZlpZOX5AoNlQFzpK7QjxcLP0wbWIriYGJL');
    INSERT INTO t1 VALUES (1910858270,'ksnug3YyANnWWDEJiRkiFC4a3e6KyJ2i3hSjksiuFLHlRXw9yhjDtnfoQd0OouyrcIbCB9zQWG4pf0yTZhaIT67nj7BY21FWJqaWrZxEh13Kt2hRbGl4MsrxsuLmvd');
    INSERT INTO t1 VALUES (63299708,'FJid3GaHpRC2L6jgirPm5AW3uGGgCloJ5Ww0eNHSiLWvS5bAxto23AxxR6TXr9qofeoAtxWcJsXnxzxmsdhvoekFc5mSES8tyxvsuPK5Hjs7ihtaJaLz5xEh2s1GCA');
    INSERT INTO t1 VALUES (737703662,'2zxutF6rOqjXYHHzSrKRwAhWCPXTdhNXYKQIRO9sEkFf1YeTGqw40Ta5u6QNfpvC1DWTTXDkFSFHtte9bbDSwgZjmryHglLhqjAKEF4MkJfT49eXcjzZNOG1F6BnsY');
    INSERT INTO t1 VALUES (100669,'qnMdipW5KkXdTjGCh2PNzLoeR0527frpQDQ8uw67Ydk1K06uuNHtkxYBxT5w8plb2BbpzhwYBgPNYX9RmICWGkZD6fAESvhMzH3yqzMtXoH4BQNylbK1CmEIPGYlC6');
    SELECT intcol1,charcol1 FROM t1;
    INSERT INTO t1 VALUES (73673339,'BN3152Gza4GW7atxJKACYwJqDbFynLxqc0kh30YTwgz3FktQ43XTrqJ4PQ25frn7kXhfXD8RuzN1j8Rf3y8ugKy6es3IbqPJM6ylCyD6xS7YcQCfHKZxYNvB7yTahm');
    SELECT intcol1,charcol1 FROM t1;
    INSERT INTO t1 VALUES (1759592334,'3lkoxjtvgLu5xKHSTTtJuGE5F5QqmCcppCTmvFZScRZQgim93gSxwb24gKmIPEzEQStMjQiCu7WapGbkw4ilXch3xRLMhKSzgLDOovSi2qGj6rKvnuYAWDDJgaZDu2');
    SELECT intcol1,charcol1 FROM t1;
    INSERT INTO t1 VALUES (95275444,'bNIrBDBl81tjzdvuOpQRCXgX37xGtzLKEXBIcE3k7xK7aFtqxC99jqYnpTviK83bf6lGDgsKd4R3KLmHPnI8TqnIKj1gjw7N2sXFZNS2Svyg8cpZN7atxL39w4igsp');
    SELECT intcol1,charcol1 FROM t1;
    INSERT INTO t1 VALUES (866596855,'naQuzhMt1IrZIJMkbLAKBNNKKK2sCknzI5uHeGAgQuDd5SLgpN0smODyc7qorTo1QaI5qLl97qmCIzl0Mds81x7TxpIoJyqlY0iEDRNKA1PS0AKEn5NhuMAr3KgEIM');
    SELECT intcol1,charcol1 FROM t1;
    INSERT INTO t1 VALUES (364531492,'qMa5SuKo4M5OM7ldvisSc6WK9rsG9E8sSixocHdgfa5uiiNTGFxkDJ4EAwWC2e4NL1BpAgWiFRcp1zIH6F1BayPdmwphatwnmzdwgzWnQ6SRxmcvtd6JRYwEKdvuWr');
    DROP SCHEMA IF EXISTS `mysqlslap`;
    [root@Betty libmysql]#

  
7\. 实际测试中的复杂情况。  
使用 --defaults-file 选项，指定从配置文件中读取选项配置。  
使用 --number-int-cols 选项，指定表中会包含 4 个 int 型的列。  
使用 --number-char-cols 选项，指定表中会包含 35 个 char 型的列。  
使用 --engine 选项，指定针对何种存储引擎进行测试。  

    
    
    [root@Betty ~]# mysqlslap --defaults-file=/etc/my.cnf --concurrency=50,100,200 --iterations=1 --number-int-cols=4 --number-char-cols=35 --auto-generate-sql --auto-generate-sql-add-autoincrement --auto-generate-sql-load-type=mixed --engine=myisam,innodb --number-of-queries=200 --debug-info -S /tmp/mysql.sock
    Benchmark
            Running for engine myisam
            Average number of seconds to run all queries: 0.015 seconds
            Minimum number of seconds to run all queries: 0.015 seconds
            Maximum number of seconds to run all queries: 0.015 seconds
            Number of clients running queries: 50
            Average number of queries per client: 4
    
    Benchmark
            Running for engine myisam
            Average number of seconds to run all queries: 0.024 seconds
            Minimum number of seconds to run all queries: 0.024 seconds
            Maximum number of seconds to run all queries: 0.024 seconds
            Number of clients running queries: 100
            Average number of queries per client: 2
    
    Benchmark
            Running for engine myisam
            Average number of seconds to run all queries: 0.028 seconds
            Minimum number of seconds to run all queries: 0.028 seconds
            Maximum number of seconds to run all queries: 0.028 seconds
            Number of clients running queries: 200
            Average number of queries per client: 1
    
    Benchmark
            Running for engine innodb
            Average number of seconds to run all queries: 0.112 seconds
            Minimum number of seconds to run all queries: 0.112 seconds
            Maximum number of seconds to run all queries: 0.112 seconds
            Number of clients running queries: 50
            Average number of queries per client: 4
    
    Benchmark
            Running for engine innodb
            Average number of seconds to run all queries: 0.042 seconds
            Minimum number of seconds to run all queries: 0.042 seconds
            Maximum number of seconds to run all queries: 0.042 seconds
            Number of clients running queries: 100
            Average number of queries per client: 2
    
    Benchmark
            Running for engine innodb
            Average number of seconds to run all queries: 0.105 seconds
            Minimum number of seconds to run all queries: 0.105 seconds
            Maximum number of seconds to run all queries: 0.105 seconds
            Number of clients running queries: 200
            Average number of queries per client: 1
    
    
    User time 0.05, System time 0.06
    Maximum resident set size 8332, Integral resident set size 0
    Non-physical pagefaults 5388, Physical pagefaults 0, Swaps 0
    Blocks in 0 out 0, Messages in 0 out 0, Signals 0
    Voluntary context switches 7484, Involuntary context switches 2839
    [root@Betty ~]#

  
8\. 使用存储过程进行测试。  
略  
  
  
========== 我是分割线 =============  
  
mysqlslap 运行分三个阶段:  

  1. 创建 schema，table 和任何用来测试的已经存储了的程序和数据。这个阶段使用单客户端连接；
  2. 进行负载测试。这个阶段使用多客户端连接；
  3. 清除（断开连接，删除指定表）。这个阶段使用单客户端连接。

  
例子：  
  
a. 提供你自己的创建 SQL 语句和查询 SQL 语句，有 50 个客户端查询，每个查询 200 次（在单行上输入命令）：  

    
    
    [root@Betty ~]# mysqlslap --delimiter=";" --create="CREATE TABLE a (b int);INSERT INTO a VALUES (23)" --query="SELECT * FROM a" --concurrency=50 --iterations=200
    Benchmark
            Average number of seconds to run all queries: 0.005 seconds
            Minimum number of seconds to run all queries: 0.003 seconds
            Maximum number of seconds to run all queries: 0.007 seconds
            Number of clients running queries: 50
            Average number of queries per client: 1
    
    [root@Betty ~]#

  
b. 让 mysqlslap 创建查询的 SQL 语句，使用的表有 2 个 INT 行和 3 个 VARCHAR 行。使用 5 个客户端，每一个查询 20
次！不要创建表或插入数据。(换言之，用之前测试的模式和数据):  

    
    
    [root@Betty ~]# mysqlslap --concurrency=5 --iterations=20 --number-int-cols=2 --number-char-cols=3 --auto-generate-sql
    
    Benchmark
            Average number of seconds to run all queries: 0.025 seconds
            Minimum number of seconds to run all queries: 0.012 seconds
            Maximum number of seconds to run all queries: 0.084 seconds
            Number of clients running queries: 5
            Average number of queries per client: 0
    
    [root@Betty ~]#

  
c. 告诉程序从指定的 create.sql 文件去加载 create，insert 和查询等 SQL 语句。该文件有多个表的 create 和insert
语句, 它们都是通过“；”分隔开的。query.sql 文件则有 多个查询语句,
分隔符也是“；”。执行所有的加载语句，然后通过查询文件执行所有的查询语句，分别在 5 个客户端上每个执行 5 次：  

    
    
    [root@Betty ~]# mysqlslap --concurrency=5 --iterations=5 --query=query.sql --create=create.sql --delimiter=";"

  
========== 我是分割线 =============  
  
mysqlslap 对于模拟多个用户同时对 MySQL 发起“进攻”提供了方便。同时详细的提供了“高负荷攻击 MySQL”的详细数据报告。  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  

© 著作权归作者所有


---
### ATTACHMENTS
[80334caafb8380614c70ea10cd9817c6]: media/617889_50.png
[617889_50.png](media/617889_50.png)
>hash: 80334caafb8380614c70ea10cd9817c6  
>source-url: https://static.oschina.net/uploads/user/308/617889_50.png?t=1401433541000  
>file-name: 617889_50.png  

---
### NOTE ATTRIBUTES
>Created Date: 2018-08-29 02:27:45  
>Last Evernote Update Date: 2018-10-01 15:35:36  
>source: web.clip7  
>source-url: https://my.oschina.net/moooofly/blog/152547  
>source-application: WebClipper 7  