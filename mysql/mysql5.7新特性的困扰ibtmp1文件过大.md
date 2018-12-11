## mysql5.7新特性的困扰ibtmp1文件过大
在一台 MySQL5.7 的服务器上磁盘使用空间突然爆满, 查看 mysql 数据目录下的文件发现,有个叫`ibtmp1`的文件大小达到了160GB.后经过查询得知, `ibtmp1`文件是 MySQL5.7的新特性,MySQL5.7使用了独立的临时表空间来存储临时表数据，但不能是压缩表。临时表空间在实例启动的时候进行创建，shutdown的时候进行删除。即为所有非压缩的innodb临时表提供一个独立的表空间，默认的临时表空间文件为ibtmp1，位于数据目录。我们可通过innodb_temp_data_file_path参数指定临时表空间的路径和大小，默认12M。只有重启实例才能回收临时表空间文件ibtmp1的大小。create temporary table和using temporary table将共用这个临时表空间
```
mysql> show variables like 'innodb_temp_data_file_path';
+----------------------------+-----------------------+
| Variable_name              | Value                 |
+----------------------------+-----------------------+
| innodb_temp_data_file_path | ibtmp1:12M:autoextend |
+----------------------------+-----------------------+
1 row in set (0.00 sec)
```
物理文件
```
➜  ~ du -sh ibtmp1 
160G    ibtmp1
```
**释放这个临时表空间的唯一办法是重启数据库**