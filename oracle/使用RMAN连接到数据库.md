#使用RMAN连接到数据库

## RMAN 使用时需要考虑的问题
- 资源：共享内存，更多的进程
- 权限：授予用户 sysdba 权限，OS 访问设备的权限
- 远程操作
- 设置密码文件
- 确保密码文件被备份
- 全球化环境变量设置
- 在RMAN命令行格式化时间参数

##     连接类型

- 目标数据库
- 恢复目录数据库，缺省情况下 RMAN 运行在非恢复目录数据库
- 辅助数据库
- Standby database
- Duplicate database
- TSPITR instance
- 连接目标数据库或恢复目录
###     不连接数据库仅启动 rman
$ rman
###    使用操作系统认证连接到目标数据库
$ rman target /
### 从命令行连接到目标数据库和恢复目录
rman target / catalog rman/cat@catdb  	//使用 OS 认证, 第二个 rman 为恢复目录的 schema
rman target sys/oracle@trgt catalog rman/cat@catdb  -- 使用 Oracle Net 认证
### 从 rman 提示符连接到目标数据库和恢复目录
% rman
RMAN> connect target /         -- 使用 OS 认证
RMAN> connect catalog rman/cat@catdb
% rman
RMAN> connect target sys/oracle@trgt     -- 使用 Oracle Net 认证
RMAN> connect catalog rman/cat@catdb
### 命令行连接到辅助数据库
rman auxiliary sys/aux@auxdb
rman target sys/oracle@trgt auxiliary sys/aux@auxdb catalog rman/cat@catdb
###  从 rman 提示符连接辅助数据库
```
%rman
RMAN> connect auxiliary sys/aux@auxdb
% rman
RMAN> connect target sys/oracle@trgt
RMAN> connect catalog rman/cat@catdb
RMAN> connect auxiliary sys/aux@auxdb
```
### 远程连接
 rman target sys/oracle@trgt
 rman target / nocatalog   等同于 rman target /
### 执行命名文件
```
rman target sys/oracle cmdfile = $ORACLE_HOME/scirpts/my_rman_script.rcv
或
rman target sys/oracle@prod @'$ORACLE_HOME/scirpts/my_rman_script.rcv'
```