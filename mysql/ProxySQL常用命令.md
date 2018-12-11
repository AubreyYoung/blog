## ProxySQL常用命令

### 启动、停止、查看状态

```
/etc/init.d/proxysql start 
/etc/init.d/proxysql stop
/etc/init.d/proxysql status 
```

### 连接

```
export MYSQL_PS1="(\u@\h:\p) [\d]> "   
mysql -uadmin -padmin -h127.0.0.1 -P6032
```

