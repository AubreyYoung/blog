# 走进大数据之Hive

1. ## 前言

Hive是基于Hadoop之上的数据仓库.

- Hive和一般意义上的数据库有什么区别?
- 如何搭建数据库
- 创建的过程是什么
- 如何把数据导入到数据仓库

- Hive是构建在Hadoop HDFS上的一个数据仓库
- Hive的体系结构
- Hive如何与Hadoop HDFS进行相互操作
- Hive的数据与Hadoop 中的文件之间的关系
- Hive的安装与管理:3方式
- Hive的数据模型与操作

基础知识

- 了解Hadoop:HDFS,MapReduce

## 2.数据仓库

是一个面向主题的、集成的、不可更新的、随时间不变化的数据集合，它用于支持企业或组织的决策分析处理

- 数据仓库的结构和建立过程

  - 数据源----业务数据系统，档案资料，其他数据

  - 数据存储及管理：抽取（Extract）转换（Transform）装载（load）
  - 数据仓库引擎
  - 前段展示：数据查询，数据报表，数据分析，各类应用-

- OLTP应用和OLAP应用

- 数据仓库中的数据模型

  - 星型模型

    ![星型模型](d:\Github\blog\nosql\pictures\数据仓库模型_星型模型.png)

  - 雪花模型

    ![雪花模型](D:\Github\blog\nosql\pictures\数据仓库模型_雪花模型.png)

## 什么是Hive

- Hive是构建在Hadoop HDFS上的数据仓库基础架构
- Hive可以用来进行数据提取转化加载(ETL)
- Hive定义了简单的类似SQL查询语言,称为HQL,他允许熟悉SQL的用户查询数据
- Hive允许熟悉MapReduce卡发者开发自定义的mapper和reduce来处理内建的mapper和reduce无法完成的复杂分析工作
- Hive是SQL解析引擎,它将SQL语句转移成M/R Job然后在Hadoop执行
- Hive的表其实就是HDFS的目录/文件

## Hive的体系结构

### Hive的元数据

类似Oracle数据库的数据字典

- Hive将元数据存储在数据库中(metastore),支持mysql,derby,oracle等数据库
- hive中的元数据包括表的名字,表的列和分区及其属性,表的属性(是否为外部表等),表的数据所在目录等

![Hive的元数据](d:\Github\blog\nosql\pictures\Hived的元数据.png)

### HQL的执行过程

解释器,编译器,优化器完成HQL查询语句从词法分析,语法分析,编译,优化以及查询计划的生成.生成的查询计划存储在HDFS中,并在随后由MapReduce调用执行

![HQL执行过程](d:\Github\blog\nosql\pictures\HQL执行过程.png)

### Hive的体系结构

- Hadoop
  - 用HDFS进行存储,利用MapReduce进行计算

- 元数据存储(MetaStore)
  - 通常是存储在关系数据库如MySQL,derby中

![Hive的体系结构](d:\Github\blog\nosql\pictures\Hive的体系结构.png)