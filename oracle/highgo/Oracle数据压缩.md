# Oracle数据压缩

# 一、关于Oracle数据压缩

Oracle 11g EE版本中只有： Basic Table Compression ，而 AdvanceCompression
Feature需要单独购买。

Oracle 是数据压缩技术的先驱，在Oracle 9i中就引入了Basic Table Compression。 9i中是使用bulk
进行装载时进行压缩。 到Oracle 11g，Table Compress特性进一步增强。

Oracle 表压缩使用一个唯一的压缩算法。 该算法用来消除一个database block中的重复值，该重复值甚至可以跨多个列。
被压缩的blocks包含一个叫作symbol table的structure，该structure 用来维护压缩的元素。 当一个block
被压缩时，字段值第一次该被copy到symbol table中，然后每次的重复值都是被一个short reference 代替，该reference
指向symbol table 中对应的entry。

#  **二、数据压缩的优点**

压缩率由被压缩的数据性质决定，特别是重复值的数量。重复值越多，压缩率越高。 一般来说，通过压缩，可以降低2x 到
4x的空间的消耗。但是在uncompress时，还是需要增加原来的空间。OLTP Table Compression
的好处不仅仅是存储空间的节省，另一个重要的影响Oracle 直接读压缩数据块的能力，因为不需要读uncompress的block，
在重复值越多的情况下，读compress 会降低I/O，从而提高性能，并且buffer cache因为存储更多的数据而更高效。

Table Compression 对read 没有不利的影响。 但对write 操作时需要做一些附加的操作，正因如此， **对compress block
不适合进行写操作。**

Oracle 批处理的compress要优于每次写操作时进行压缩。当一个block 初始化时会保持uncompress状态，直到数据接近block
控制阀值，当某个事务导致数据达到这个threshold，block 里的所有数据都会被compressed。
随后，又更多的数据被添加进来，再次接近阀值，在次被压缩，直到整个block 达到最高的compression。

#  **三、** **压缩分类**

## 1、表级别的压缩

可以在创建表时使用compress选项

SQL> create table tab_041702 compress as select * from dba_objects;

也可以将修改普通表为压缩表

Alter table tab1 move compress;

取消表的压缩

Alter table tab1 move nocompress

查看是否使用了表级别的压缩

SQL> select table_name,compression from user_tables wheretable_name= ' ';

SQL> select table_name,compression from user_tables where table_name = 'TAB1'

TABLE_NAME COMPRESS

\------------------------------ --------

TAB1 ENABLED

## 2、表空间级别的压缩

在表空间级别上定义COMPRESS属性，既可以在生成时利用CREATE TABLESPACE来定义，也可以稍后时间利用ALTERTABLESPACE来定义。

COMPRESS属性具有继承特性。当在一个表空间中创建一个表时，它从该表空间继承COMPRESS属性。

 **注意：修改表空间的compress属性后，该表空间已经存在的表不会继承compress属性**

SQL> create tablespace tbs2 datafile '/u01/app/oracle/oradata/orcl/tbs2.dbf'
size 100m autoextend off default compress;

https://docs.oracle.com/cd/E11882_01/server.112/e41084/statements_7003.htm#i2132654

使用alter tablespace命令修改表空间的compress属性

SQL> alter tablespace tbs0417 default compress;

Tablespace altered.

SQL> alter tablespace tbs0417 default nocompress;

Tablespace altered.

确定是否已经利用COMPRESS对一个表空间进行了定义，可查询DBA_TABLESPACES数据字典视图并查看DEF_TAB_COMPRESSION列

select tablespace_name,def_tab_compression from dba_tablespaces where
tablespace_name='TBS2'

SQL> select tablespace_name,def_tab_compression from dba_tablespaces where
tablespace_name='TBS2'

TABLESPACE_NAME DEF_TAB_

\------------------------------ --------

TBS2 ENABLED

Measure

Measure



---
### TAGS
{Support20180830}

---
### NOTE ATTRIBUTES
>Created Date: 2018-08-30 01:30:48  
>Last Evernote Update Date: 2018-10-01 15:33:59  
>source: web.clip7  
>source-url: https://47.100.29.40/highgo_admin/#/index/docSearchDetail/878f12ae0147cd51  
>source-application: WebClipper 7  