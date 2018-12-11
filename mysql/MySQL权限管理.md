## MySQL权限管理

## 语法

```
grant 权限 on 数据库.数据表 to '用户'@'主机';
```

## 主机的表示方式

- 192.168.10.85 单主机授权方式
- localhost 本地授权 方式
- % 不限制远程主机的 IP 地址
- 192.168.10.% 网段批量授权

## 权限列表

| 权限                    | 说明                                                         |
| ----------------------- | ------------------------------------------------------------ |
| usage                   | 连接(登录)MySQL 的权限, 每建立一个用户, 就会自动授予`usage`权限. 该权限只能用于数据库登录, 不能执行任何操作, 且 usage 权限不能被回收♻️ |
| file                    | 拥有 file 权限才可以执行 `select ... into outfile`和 `load data infile…` 操作, 但是不要把 `file`, `process`, `super` 权限授予管理员以外的账号, 否则存在严重的安全隐患 |
| super                   | 该权限允许用户终止任何查询; 修改全局变量的 SET 语句; 使用 `change master` `purge master logs` |
| select                  | 必须拥有 select 权限才可以使用 `select`查询数据              |
| insert                  | 必须拥有 insert 权限才可以使用`insert`向表中插入数据         |
| update                  | 必须拥有 update 权限才可以使用`update`更新表中的记录📝        |
| delete                  | 必须拥有 delete 权限才可以使用`delete`删除表中的数据         |
| alter                   | 必须拥有 alter 权限才可以使用`alter`命令更改表的属性         |
| alter routine           | 必须拥有 alter routine 权限才可以执行 `alter/drop procedure/function`命令 |
| create                  | 必须拥有 create 权限才可以使用`create`命令建表               |
| create routine          | 必须拥有 create routine 权限才可以执行 `create/alter/drop procedure/function` |
| create temporary tables | 必须有create temporary tables的权限，才可以使用`create temporary tables` |
| create view             | 执行`create view`创建视图的权限                              |
| create user             | 执行`create user`创建用户的权限(拥有 insert 权限也可以通过直接向 mysql.user 表中插入数据来创建用户) |
| show database           | 通过 `show database` 只能看到你拥有的某些权限的数据库, 除非你拥有全局`show database`权限 |
| show view               | 必须拥有`show view`权限才可以执行`show create view`查询已经创建的视图 |
| index                   | 必须拥有 index 权限才能创建和删除索引 `create/drop index`    |
| excute                  | 必须拥有 excute 权限才可以执行存在的函数(Function)和存储过程(Procedures) |
| event                   | 如果event 的使用频率较低, 建议使用 root 用户进行管理和维护. (要使event 起作用, MySQL 的常量 `global event_scheduler`必须为`on`或者`1`) |
| lock tables             | 锁表🔐权限                                                    |
| references              | 创建外键约束权限                                             |
| reload                  | flush talbes/logs/privileges 权限                            |
| replication client      | 拥有此权限可以查询`master` `slave`状态                       |
| replication slave       | 拥有此权限可以从主库读取二进制日志                           |
| shutdown                | 关闭 mysql 的权限                                            |
| grant option            | 可以将自己拥有的权限授权给其他用户(仅限于自己拥有的权限)     |
| process                 | 拥有此权限可以执行`show processlist`和`kill`命令. 默认情况下, 每个用户都可以执行该命令, 但是只能查看本用户的进程 |
| all privileges          | 所有权限. 使用`with grant option`可以连带授权 `grant all privileges on *.* to 'polarsnow'@'%' with grant option;` |
| truncate                | truncate 权限其实就是 create+drop 权限的组合                 |
| drop                    | 删库删表删索引删视图等权限                                   |

**注意:** 管理权限(如 super, process, file 等) 不能指定某个数据库授权, `on`关键字之后必须跟 `*.*`

## 查看用户授权

```
mysql> show grants for username;
```

## 回收权限

```
mysql> revoke select,update,insert,delete on *.* from username;
```

## 刷新权限

```
mysql> flush privileges;
```