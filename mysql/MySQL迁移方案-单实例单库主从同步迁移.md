## MySQL迁移方案-单实例单库主从同步迁移


## 迁库&同步

```
# 在主库锁库
mysql> flush tables with read lock;
# dump主库数据库
$ mysqldump -uroot -p OcrManagement > OcrManagement.sql
#查看主库位置
mysql> show master status;
+------------------+------------+--------------+------------------+-------------------+
| File             | Position   | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+------------------+------------+--------------+------------------+-------------------+
| mysql-bin.000014 | 1058718197 |              | mysql            |                   |
+------------------+------------+--------------+------------------+-------------------+
# 解锁主库
mysql> unlock tables;
# 将dump出来的sql文件传送到从库
$ tar -cvzf OcrManagement.sql.tar.gz OcrManagement.sql
$ scp OcrManagement.sql ps@192.168.3.11:/data/
# 查看主库数据库建库参数
mysql> show create database OcrManagement;

----------------------------------------------------------------------------------------
# 根据主库建库参数，在从库预先建立数据库
mysql> create database OcrManagement;
# 在从库中解压文件
$ tar -xvzf OcrManagement.sql.tar.gz
# 导入数据
$ mysql -uroot -p OcrManagement < OcrManagement.sql
# 设置主库信息
mysql> change master to MASTER_HOST='192.168.168.149',MASTER_PORT=33306,MASTER_USER='repl',MASTER_PASSWORD='xxxxxxxx',MASTER_LOG_FILE='mysql-bin.000014',MASTER_LOG_POS=1058718197;
# 启动从库线程
mysql> start slave;
# 检查同步状态
mysql> show slave status\G
```

## 切换主从
