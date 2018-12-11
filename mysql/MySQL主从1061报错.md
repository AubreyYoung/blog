## MySQL主从1061报错

MySQL主从 1061 报错, 键冲突, 产生的原因一般为用户在主库上建立索引导致, 可以通过在从库手动删除冲突的索引解决

```
# 先暂停主从同步
mysql> stop slave for channel "dbtest";  # MySQL5.7多源复制语法
mysql> stop slave;  # 单主复制语法

# 删除冲突的索引
ALTER TABLE `tableNmae` DROP INDEX `indexName`;

# 开启主从同步
mysql> start slave for channel "dbtest"; # MySQL5.7多源复制语法
mysql> start slave;  # 单主复制语法
```