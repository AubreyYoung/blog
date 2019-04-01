## MySQL5.7 字符集设置


[TOC]

## MySQL5.7 字符集设置
- character-set-client-handshake = FALSE
- character-set-server = utf8mb4
- collation-server = utf8mb4_unicode_ci
- init_connect=’SET NAMES utf8mb4’
## character-set-client-handshake
用来控制客户端声明使用字符集和服务端声明使用的字符集在不一致的情况下的兼容性.
```
character-set-client-handshake = false
# 设置为 False, 在客户端字符集和服务端字符集不同的时候将拒绝连接到服务端执行任何操作
# 默认为 true
character-set-client-handshake = true
# 设置为 True, 即使客户端字符集和服务端字符集不同, 也允许客户端连接
```
## character-set-server
声明服务端的字符编码, 推荐使用`utf8mb4` , 该字符虽然占用空间会比较大, 但是可以兼容 emoji 😈 表情的存储
```
character-set-server = utf8mb4
```
## collation-server
声明服务端的字符集, 字符编码和字符集一一对应, 既然使用了`utf8mb4`的字符集, 就要声明使用对应的字符编码
```
collation-server = utf8mb4_unicode_ci
```
## init_connect
`init_connect` 是用户登录到数据库上之后, 在执行第一次查询之前执行里面的内容. 如果 `init_connect` 的内容有语法错误, 导致执行失败, 会导致用户无法执行查询, 从mysql 退出
使用 `init_connect` 执行 `SET NAMES utf8mb4` 意为:
- 声明自己(客户端)使用的是 `utf8mb4` 的字符编码
- 希望服务器返回给自己 `utf8mb4` 的查询结果
```
init_connect = 'SET NAMES utf8mb4'
```
## 完整配置
```
character-set-client-handshake = FALSE
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci
init_connect = 'SET NAMES utf8mb4'
```
------
## 修改字符集

```
//对每一个数据库:
ALTER DATABASE 这里数据库名字 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
//对每一个表:
ALTER TABLE 这里是表名字 CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
//对每一个字段:
ALTER TABLE 这里是表名字 CHANGE 字段名字 重复字段名字 VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE 这里是表名字 modify 字段名字 VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '';
```

参考文章:

- <http://www.jb51.net/article/29576.htm>
- <http://www.jb51.net/article/52511.htm>
- <http://www.tuicool.com/articles/2IRVV3>
- <http://jbisbee.blogspot.com/2013/07/set-utf-8-as-default-mysql-encoding.html>