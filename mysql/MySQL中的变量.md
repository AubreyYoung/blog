## MySQL中的变量
# 用户变量
用户变量与数据库连接有关, 这某个连接中声明变量, 在断开连接时这个变量就会消失, 且在这个连接中声明的变量无法在另一个连接中使用.
```
# 用户变量语法
set @varName=value
```
声明一个变量 `varName`, 并将它赋值为 `value`
*mysql 中的变量是动态数据类型, 它的数据类型会根据它的值的类型而变化*

# 系统变量
系统变量中, 又分为 `全局变量` 和 `会话变量`
全局变量与会话变量的区别在于, 对全局变量的修改会影响到整个MySQL服务 (所有会话) 而对局部变量的修改只会影响到当前会话的连接
利用select语句我们可以查询单个会话变量或者全局变量的值：
```
select @@session.sort_buffer_size
select @@global.sort_buffer_size
select @@global.tmpdir
```
凡是上面提到的session，都可以用local这个关键字来代替。
比如： `select @@local.sort_buffer_size`
*local 是 session的近义词*
```
无论是在设置系统变量还是查询系统变量值的时候，只要没有指定到底是全局变量还是会话变量, 都当做会话变量来处理。
比如：
set @@sort_buffer_size = 50000;
select @@sort_buffer_size;
上面都没有指定是GLOBAL还是SESSION，所以全部当做SESSION处理。
```
## 全局变量
全局变量在 MySQL 启动的时候由服务器自动初始化他们的值, 这些默认的值可以在 `/etc/my.cnf` 中修改
### 查看全局变量
```
show global variables;
```
### 修改全局变量
```
set global varname = value;` 或 `set @@global.varname = value;
```
## 会话变量
会话变量在每一个数据库连接建立后, 由 MySQL 来初始化. MySQL 会将当前所有的全局变量都复制一份作为会话变量
### 查看会话变量
```
show session variables;` 或 `show variables;
```
### 修改会话变量
```
set session varname = value;` 或 `set @@session.varname = value;
```
# 只读变量
有些系统变量的值是可以利用语句来动态进行更改的，但是有些系统变量的值却是只读的
