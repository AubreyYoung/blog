## mysqldump unknown table 'column_statistics' in information_schema

## 问题
如果使用MySQL 8.0+版本提供的命令行工具mysqldump来导出低于8.0版本的MySQL数据库到SQL文件，会出现`Unknown table 'column_statistics' in information_schema`的错误，因为早期版本的MySQL数据库的information_schema数据库中没有名为COLUMN_STATISTICS的数据表。

## 解决方法

使用8.0以前版本MySQL附带的mysqldump工具，最好使用待备份的MySQL服务器版本对应版本号的mysqldump工具.