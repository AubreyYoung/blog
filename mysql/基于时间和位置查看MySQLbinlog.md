## 基于时间和位置查看MySQL binlog

## 基于时间查看 binlog 日志

```
mysqlbinlog  --no-defaults --start-datetime="2016-10-31 23:08:03" mysql-bin.000214 |more
```

## 基于位置查看 binlog 日志

```
mysqlbinlog --no-defaults --start-position=690271 mysql-bin.000214 |more
```