## MySQL的主从切换

> 本篇文章不再赘述 MySQL 主从搭建的过程, 只介绍主从切换的过程

MySQL 的主从切换分成两种情况

- 一种情况是主从高可用, 主从切换后, 原主库还要继续同步原从库的数据
- 另一种情况是一主一从, 主从切换后, 主库下线, 不需要原主库再去同步原从库

## 第一种情况的主从切换

## 分别查看主从状态

```
# slave 中查看从库的状态
mysql> show slave status\G
# master 中查看主库的状态
mysql> show slave hosts;
```

## 停止从库的 IO_THREAD 线程

先停止 IO_THREAD 线程, 即断开了从主库的 sql 消息接收, 有利于当前数据库完成剩余的数据同步

```
# slave
mysql> stop slave IO_THREAD;
mysql> show slave status\G
```

检查是否是如下状态;

```
Slave_IO_Running: No
Slave_SQL_Running: Yes
```

## 激活从库

在停止 IO_THREAD 线程后, 看到 `Slave_SQL_Running_State: Slave has read all relay log; waiting for the slave I/O thread to update it`这个状态后, 就可以操作完全停止从库,并激活为主库啦

```
mysql> stop slave;  # 完全停止 slave 复制 
mysql> reset slave all; # 完全清空 slave 复制信息
msyql> reset master; # 清空本机上 master 的位置信息(给原主库同步此原从库做准备)
mysql> show binary logs; # 查看当前数据库的 binlog 信息
+----------------+-----------+
| Log_name       | File_size |
+----------------+-----------+
| bin-log.000001 |       120 |
+----------------+-----------+
```

## 将原主库变为从库

```
# master
mysql> CHANGE MASTER TO
   MASTER_HOST='192.168.10.59',
   MASTER_PORT=3306,
   MASTER_USER='repl',
   MASTER_PASSWORD='12345678',
   MASTER_LOG_FILE='bin-log.000001',
   MASTER_LOG_POS=120;
mysql> start slave;
mysql> show slave status\G
```

------

## 第二种情况的主从切换

第二种情况的主从切换, 切换后, 主库不需要再去同步之前的从库(新主库), 有下线的需求, 这种情况下, 操作流程跟以上差不多, 只不过可以省去如下步骤:

- 从库中不需要执行`reset master`了, 因为原主库(现从库)不要再找点啦(Position)
- 主库直接下线就行了, 不需要执行最后把主库变为从库的操作了