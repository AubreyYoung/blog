## MongoDB的概念

* Mongodb
* mongo
* 索引
* 集合
* 复制集
* 分片
* 数据均衡

## MongoDB的搭建

* 搭建简单的单机服务
* 搭建具有冗余容错功能的复制集
* 搭建大规模数据集群
* 完成集群的自动部署

## MongoDB的使用

* 最基本的文档的读写更新删除
* 各种不同类型索引的创建与使用
* 复杂的聚合查询
* 对数据集合进行分片，在不同分片间维持数据均衡
* 数据备份与恢复
* 数据迁移

## MongoDB运维

- 部署MongoDB集群
- 处理多种常见的故障
  - 单节点失效，如何恢复工作
  - 数据库意外被杀死如何进行数据恢复
  - 数据库拒绝服务时如何排查原因
  - 数据库磁盘快满时如何处理

## 几个重要的网站

1. MongoDB官网: www.mongodb.org

   - 安装包下载
   - 使用文档
2. MongoDB国内官方网站: www.mongoing.com
3. 中文MongoDB文档地址: docs.mongoing.com
4. MongoDB的github: https//github.com/mongodb
5. mongoDB的jira：<https://jira.mongodb.org/secure/Dashboard.jspa>  bug提交

![数据库的概念](D:\Git\blog\nosql\MongoDB\Pictures\数据库的概念.png)

![数据库分类](D:\Git\blog\nosql\MongoDB\Pictures\数据库分类.png)

![SQL数据库与NoSQL数据库区别](Pictures/SQL数据库与NoSQL数据库区别.png)

![无表结构限制](Pictures/无表结构限制.png)

![完全的索引支持](Pictures/完全的索引支持.png)

![方便的冗余与扩展](Pictures/方便的冗余与扩展.png)

![良好的支持](Pictures/良好的支持.png)

![编译安装MongoDB](D:\Git\blog\nosql\MongoDB\Pictures\编译安装MongoDB.png)

## MongoDB常用命令

```
mongo
mongod
mongoexport
mongoimport
mongodump
mongorestore
mongostat
mongooplog
```

```
//登陆
mongo 127.0.0.1:27017/test
//切换db
use admin
//关闭mongo
db.shutdownServer()
```

```
[root@mongodb ~]# mongo --help
MongoDB shell version v3.6.2
usage: mongo [options] [db address] [file names (ending in .js)]
db address can be:
  foo                   foo database on local machine
  192.168.0.5/foo       foo database on 192.168.0.5 machine
  192.168.0.5:9999/foo  foo database on 192.168.0.5 machine on port 9999
Options:
  --shell                             run the shell after executing files
  --nodb                              don't connect to mongod on startup - no 
                                      'db address' arg expected
  --norc                              will not run the ".mongorc.js" file on 
                                      start up
  --quiet                             be less chatty
  --port arg                          port to connect to
  --host arg                          server to connect to
  --eval arg                          evaluate javascript
  -h [ --help ]                       show this usage information
  --version                           show version information
  --verbose                           increase verbosity
  --ipv6                              enable IPv6 support (disabled by default)
  --disableJavaScriptJIT              disable the Javascript Just In Time 
                                      compiler
  --disableJavaScriptProtection       allow automatic JavaScript function 
                                      marshalling
  --ssl                               use SSL for all connections
  --sslCAFile arg                     Certificate Authority file for SSL
  --sslPEMKeyFile arg                 PEM certificate/key file for SSL
  --sslPEMKeyPassword arg             password for key in PEM file for SSL
  --sslCRLFile arg                    Certificate Revocation List file for SSL
  --sslAllowInvalidHostnames          allow connections to servers with 
                                      non-matching hostnames
  --sslAllowInvalidCertificates       allow connections to servers with invalid
                                      certificates
  --sslFIPSMode                       activate FIPS 140-2 mode at startup
  --retryWrites                       automatically retry write operations upon
                                      transient network errors
  --jsHeapLimitMB arg                 set the js scope's heap size limit

Authentication Options:
  -u [ --username ] arg               username for authentication
  -p [ --password ] arg               password for authentication
  --authenticationDatabase arg        user source (defaults to dbname)
  --authenticationMechanism arg       authentication mechanism
  --gssapiServiceName arg (=mongodb)  Service name to use when authenticating 
                                      using GSSAPI/Kerberos
  --gssapiHostName arg                Remote host name to use for purpose of 
                                      GSSAPI/Kerberos authentication

file names: a list of files to run. files have to end in .js and will exit after unless --shell is specified
```

## CURD

```
//查看db
> show dbs
admin   0.000GB
config  0.000GB
local   0.000GB
//切换db
> use mongo
switched to db mongo
//插入
> db.mongo_collection.insert({x:1})
WriteResult({ "nInserted" : 1 })
//插入后数据库即创建
> show dbs
admin   0.000GB
config  0.000GB
local   0.000GB
mongo   0.000GB
//查看collection
> show collections;
mongo_collection
//find查询全部
> db.mongo_collection.find()
{ "_id" : ObjectId("5c418c37f6bc46fdc6b2d6e7"), "x" : 1 }
//插入指定id
> db.mysql_collection.insert({x:2,_id:1})
WriteResult({ "nInserted" : 1 })
> db.mysql_collection.find()
{ "_id" : ObjectId("5c418c37f6bc46fdc6b2d6e7"), "x" : 1 }
{ "_id" : 1, "x" : 2 }
//条件查询
> db.mysql_collection.find({x:1})
{ "_id" : ObjectId("5c418c37f6bc46fdc6b2d6e7"), "x" : 1 }
> db.mysql_collection.find({x:2})
{ "_id" : 1, "x" : 2 }
//for循环insert
> for(i=3;i<100;i++)db.mongo_collection.insert({x:i})
WriteResult({ "nInserted" : 1 })
> db.mongo_collection.find().count()
99
//find skip limit用法
> db.mongo_collection.find().skip(3).limit(5)
{ "_id" : ObjectId("5c418febf6bc46fdc6b2d86e"), "x" : 3 }
{ "_id" : ObjectId("5c418febf6bc46fdc6b2d86f"), "x" : 4 }
{ "_id" : ObjectId("5c418febf6bc46fdc6b2d870"), "x" : 5 }
{ "_id" : ObjectId("5c418febf6bc46fdc6b2d871"), "x" : 6 }
{ "_id" : ObjectId("5c418febf6bc46fdc6b2d872"), "x" : 7 }
//排序
> db.mongo_collection.find().skip(3).limit(5).sort({x:1})
{ "_id" : ObjectId("5c418febf6bc46fdc6b2d86e"), "x" : 3 }
{ "_id" : ObjectId("5c418febf6bc46fdc6b2d86f"), "x" : 4 }
{ "_id" : ObjectId("5c418febf6bc46fdc6b2d870"), "x" : 5 }
{ "_id" : ObjectId("5c418febf6bc46fdc6b2d871"), "x" : 6 }
{ "_id" : ObjectId("5c418febf6bc46fdc6b2d872"), "x" : 7 }
//倒叙
> db.mongo_collection.find().skip(3).limit(5).sort({x:-1})
{ "_id" : ObjectId("5c418febf6bc46fdc6b2d8cb"), "x" : 96 }
{ "_id" : ObjectId("5c418febf6bc46fdc6b2d8ca"), "x" : 95 }
{ "_id" : ObjectId("5c418febf6bc46fdc6b2d8c9"), "x" : 94 }
{ "_id" : ObjectId("5c418febf6bc46fdc6b2d8c8"), "x" : 93 }
{ "_id" : ObjectId("5c418febf6bc46fdc6b2d8c7"), "x" : 92 }
//更新
> db.mongo_collection.find({x:1})
{ "_id" : ObjectId("5c418f2ff6bc46fdc6b2d80b"), "x" : 1 }
> db.mongo_collection.update({x:1},{x:000})
WriteResult({ "nMatched" : 1, "nUpserted" : 0, "nModified" : 1 })
> db.mongo_collection.find({x:1})
> db.mongo_collection.find({x:000})
{ "_id" : ObjectId("5c418f2ff6bc46fdc6b2d80b"), "x" : 0 }
//条件更新
> db.mongo_collection.find({x:100})
{ "_id" : ObjectId("5c419191f6bc46fdc6b2d8cf"), "x" : 100, "y" : 100, "z" : 100 }
> db.mongo_collection.update({z:100},{$set:{y:99}})
WriteResult({ "nMatched" : 1, "nUpserted" : 0, "nModified" : 1 })
> db.mongo_collection.find({x:100})
{ "_id" : ObjectId("5c419191f6bc46fdc6b2d8cf"), "x" : 100, "y" : 99, "z" : 100 }
//更新,如不存在便插入
> db.mongo_collection.find({y:100})
> db.mongo_collection.update({y:100},{y:999})
WriteResult({ "nMatched" : 0, "nUpserted" : 0, "nModified" : 0 })
> db.mongo_collection.find({y:100})
> db.mongo_collection.find({y:999})
> db.mongo_collection.update({y:100},{y:999},true)
WriteResult({
        "nMatched" : 0,
        "nUpserted" : 1,
        "nModified" : 0,
        "_id" : ObjectId("5c41973c9ff93c45faa4f3a7")
})
> db.mongo_collection.find({y:999})
{ "_id" : ObjectId("5c41973c9ff93c45faa4f3a7"), "y" : 999 }
//批量更新
> db.mongo_collection.insert({c:1})
WriteResult({ "nInserted" : 1 })
> db.mongo_collection.insert({c:1})
WriteResult({ "nInserted" : 1 })
> db.mongo_collection.insert({c:1})
WriteResult({ "nInserted" : 1 })
> db.mongo_collection.find({c:1})
{ "_id" : ObjectId("5c4197e30c32fefce1f94b45"), "c" : 1 }
{ "_id" : ObjectId("5c4197e50c32fefce1f94b46"), "c" : 1 }
{ "_id" : ObjectId("5c4197e60c32fefce1f94b47"), "c" : 1 }
> 
> db.mongo_collection.update({c:1},{c:2})
WriteResult({ "nMatched" : 1, "nUpserted" : 0, "nModified" : 1 })
> db.mongo_collection.find({c:1})
{ "_id" : ObjectId("5c4197e50c32fefce1f94b46"), "c" : 1 }
{ "_id" : ObjectId("5c4197e60c32fefce1f94b47"), "c" : 1 }
> db.mongo_collection.find({c:2})
{ "_id" : ObjectId("5c4197e30c32fefce1f94b45"), "c" : 2 }
> db.mongo_collection.update({c:1},{$set:{c:2}},false,true)
WriteResult({ "nMatched" : 2, "nUpserted" : 0, "nModified" : 2 })
> db.mongo_collection.find({c:2})
{ "_id" : ObjectId("5c4197e30c32fefce1f94b45"), "c" : 2 }
{ "_id" : ObjectId("5c4197e50c32fefce1f94b46"), "c" : 2 }
{ "_id" : ObjectId("5c4197e60c32fefce1f94b47"), "c" : 2 }
> db.mongo_collection.find({c:1})
//删除
> db.mongo_collection.remove()
2019-01-18T17:14:45.292+0800 E QUERY    [thread1] Error: remove needs a query :
DBCollection.prototype._parseRemove@src/mongo/shell/collection.js:357:1
DBCollection.prototype.remove@src/mongo/shell/collection.js:382:18
@(shell):1:1
> db.mongo_collection.find({c:2})
{ "_id" : ObjectId("5c4197e30c32fefce1f94b45"), "c" : 2 }
{ "_id" : ObjectId("5c4197e50c32fefce1f94b46"), "c" : 2 }
{ "_id" : ObjectId("5c4197e60c32fefce1f94b47"), "c" : 2 }
> db.mongo_collection.remove({c:2})
WriteResult({ "nRemoved" : 3 })
> db.mongo_collection.find({c:2})
//dropcollection
> db.mongo_collection.drop()
true
//查看表
> show tables
mysql_collection
```

