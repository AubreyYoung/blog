# Redis5.0之12项新特性

## 1. Redis5.0之12项新特性

- 新的Stream数据类型:

  - Binary-safe ==strings==.
  - ==Lists==: collections of string elements sorted according to the order of insertion. They are basically *linked lists*.
  - ==Sets==: collections of unique, unsorted string elements.
  - ==Sorted sets====, similar to Sets but where every string element is associated to a floating number value, called *score*. The elements are always taken sorted by their score, so unlike Sets it is possible to retrieve a range of elements (for example you may ask: give me the top 10, or the bottom 10).
  - ==Hashes==, which are maps composed of fields associated with values. Both the field and the value are strings. This is very similar to Ruby or Python hashes.
  - Bit arrays (or simply bitmaps): it is possible, using special commands, to handle String values like an array of bits: you can set and clear individual bits, count all the bits set to 1, find the first set or unset bit, and so forth.
  - HyperLogLogs: this is a probabilistic data structure which is used in order to estimate the cardinality of a set. Don't be scared, it is simpler than it seems... See later in the HyperLogLog section of this tutorial.
  - ==Streams==: append-only collections of map-like entries that provide an abstract log data type. They are covered in depth in the [Introduction to Redis Streams](https://redis.io/topics/streams-intro).

- 新的Redis模块API:Timers and Cluster API

- RDB现在存储LFU(最近最不常用页面置换算法)和LRU信息

- 集群管理器从Ruby(redis-trib.rb)移植到C代码

- 新的sorted set命令:ZPOPMIN/MAX和阻塞变种

- 主动碎片整理V2增强

- 增强HyperLogLogs实现

- 更好的内存统计报告

- 许多带有子命令的命令现在都有一个HELP子命令

- 客户经常连接和断开时性能提升

- 错误修复和改进

- Jemalloc升级到5.1版本

  ## 2. Stream类型概述

  ### 2.1 什么是Stream数据类型

  

