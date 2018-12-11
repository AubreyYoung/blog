# Oracle-指导手册-Oracle全文索引

# 瀚高技术支持管理平台

## 一、全文索引概述

Oracle Text使Oracle9i具备了强大的文本检索能力和智能化的文本管理能力,Oracle Text 是 Oracle9i 采用的新名称,

在 oracle8/8i 中被称为 oracle intermedia text,oracle8 以前是 oracle context
cartridge。Oracle Text 的索引和查找功能并不局限于存储在数据库中的数据。 它可以对存储于文件系统中的文档进行检索和查找,并可检索超过
150 种文档类型,包括 Microsoft Word、PDF和XML。Oracle Text查找功能包括模糊查找、词干查找(搜索mice 和查找
mouse)、通配符、相近性等查找方式,以及结果分级和关键词突出显示等。你甚至 可以增加一个词典,以查找搭配词,并找出包含该搭配词的文档。

Oracle Text支持的文档的存储位置包括：

直接存储在列中；

文档存储在操作系统中，列中存储文档的路径和名称；

文档存储在互联网上，列中存储文档的URLs。

Oracle Text支持的列的类型：VARCHAR2、CHAR、CLOB、BLOB、BFILE、XMLTYPE和URITYPE。

二、 配置全文索引

### 1、检查是否存在相关用户以及角色

首先检查数据库中是否有CTXSYS用户和CTXAPP脚色。如果没有这个用户和角色，意味着你的数据库创建时未安装intermedia功能，如果存在该用户，请将该用户解锁

SQL> select username,account_status from dba_users where username like 'CTX%';

USERNAME                       ACCOUNT_STATUS

\------------------------------ --------------------------------

CTXSYS                         EXPIRED & LOCKED

SQL> alter user ctxsys identified by oracle account unlock;

SQL> select role from dba_roles    where role like 'CTX%';

ROLE

\------------------------------

CTXAPP

### 2、创建全文索引（文章只存储在表中的一列的情况）

Oracle的全文索引不要求被索引的文章一定存储在数据库中，不过如果文章存储在数据库的一列中，那么这种情况建立索引是最简单的。这种方式称为DIRECT
DATASTORE类型

执行如下语句

GRANT resource, CONNECT, ctxapp TO highgo;

GRANT EXECUTE ON ctxsys.ctx_cls TO highgo;

GRANT EXECUTE ON ctxsys.ctx_ddl TO highgo;

GRANT EXECUTE ON ctxsys.ctx_doc TO highgo;

GRANT EXECUTE ON ctxsys.ctx_output TO highgo;

GRANT EXECUTE ON ctxsys.ctx_query TO highgo;

GRANT EXECUTE ON ctxsys.ctx_report TO highgo;

GRANT EXECUTE ON ctxsys.ctx_thes TO highgo;

GRANT EXECUTE ON ctxsys.ctx_ulexer TO highgo;

新建一张表并插入两行数据

create table highgo0314 (id number,docs varchar2(4000));

INSERT INTO highgo0314 VALUES (1, 'This is a sample for Oracle TEXT.');

INSERT INTO highgo0314 VALUES (2, 'This is a direct database store sample');

commit;

创建docs列的全文索引

CREATE INDEX IND_HIGHGO_DOCS ON highgo0314 (DOCS) INDEXTYPE IS CTXSYS.CONTEXT;

进行查询

SELECT * FROM highgo0314 WHERE CONTAINS(DOCS, 'DATABASE') > 0;

查看相关执行计划

SQL> explain plan for SELECT * FROM highgo0314 WHERE CONTAINS(DOCS,
'DATABASE') > 0;

SQL> select * from table(dbms_xplan.display());

PLAN_TABLE_OUTPUT

\------------------------------------------------------------------------------------------------------------------------

Plan hash value: 2830405086

\-----------------------------------------------------------------------------------------------

| Id  | Operation                | Name            | Rows  | Bytes | Cost
(%CPU)  | Time     |

\-----------------------------------------------------------------------------------------------

|   0 | SELECT STATEMENT     |                 |     1 |  2027 |     4
(0)| 00:00:01 |

|   1 | TABLE ACCESS BY INDEX ROWID| HIGHGO0314 |   1 |  2027 |     4   (0)|
00:00:01 |

|*  2 |   DOMAIN INDEX     | IND_HIGHGO_DOCS |     |       |     4   (0)|
00:00:01 |

\-----------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):

PLAN_TABLE_OUTPUT

\------------------------------------------------------------------------------------------------------------------------

   2 - access("CTXSYS"."CONTAINS"("DOCS",'DATABASE')>0)

Note

\-----

   \- dynamic sampling used for this statement (level=2)

18 rows selected.

### 3、创建全文索引（分布在多个表的多个列中）

如果被索引的文章是保存在数据库中，但是内容分布在多个列中，那么可以通过建立一个MULTI_COLUMN_DATASTORE来索引完整的文章：

新建表并插入数据

CREATE TABLE highgo031402 (ID NUMBER, DOC1 VARCHAR2(4000), DOC2
VARCHAR2(4000), DOC3 VARCHAR2(4000));

SQL> INSERT INTO highgo031402 VALUES (1,

'The first paragraph of article in doc1.',

'The second partments is the doc2.',

'The last content is in the doc3.');

已创建 1 行。

SQL> INSERT INTO highgo031402 VALUES (2,

 'This example create a multi-column datastore preference',

 'called test_multicol on three text columns',

 'to be concatenated and indexed.');

已创建 1 行。

SQL> COMMIT;

下面创建索引，由于需要建立一个多列存储的全文索引，需要将多个列的列名作为参数传给Oracle。这个过程通过建立一个PREFERENCE，并设置属性来完成。

注意，下面的代码需要由CTXSYS用户执行，这点是文档上没有明确说明的。

https://docs.oracle.com/cd/E11882_01/text.112/e24436/cdatadic.htm#CCREF1905

Use the MULTI_COLUMN_DATASTORE datastore when your text is stored in more than
one column. During indexing, the system concatenates the text columns, tags
the column text, and indexes the text as a single document.

 The XML-like tagging is optional. You can also set the system to filter and
concatenate binary columns.

SQL> CONN CTXSYS/CTXSYS

已连接。

SQL> BEGIN

 CTX_DDL.CREATE_PREFERENCE('TEST_MULTICOL', 'MULTI_COLUMN_DATASTORE');

 CTX_DDL.SET_ATTRIBUTE('TEST_MULTICOL', 'COLUMNS', 'DOC1, DOC2, DOC3');

 END;

 /

PL/SQL 过程已成功完成。

下面在建立索引的时候指定DATASTORE参数为新建的TEST_MULTICOL参数：

SQL> CONN highgo/highgo

已连接。

SQL> CREATE INDEX IND_HIGHGO031402_DOCS ON highgo031402 (DOC1) INDEXTYPE IS
CTXSYS.CONTEXT PARAMETERS ('DATASTORE CTXSYS.TEST_MULTICOL');

索引已创建

SELECT * FROM highgo031402 WHERE CONTAINS(DOC1, 'CONTENT') > 0;

SQL> /

        ID DOC1                                     DOC2                                     DOC3

\---------- ----------------------------------------
----------------------------------------

         1 The first paragraph of article in doc1.  The second partments is the doc2.        The last content is in the doc3.

SQL> explain plan for SELECT * FROM highgo031402 WHERE CONTAINS(DOC1,
'CONTENT') > 0;

Explained.

SQL> select * from table(dbms_xplan.display());

PLAN_TABLE_OUTPUT

\-------------------------------------------------------------------------------------------------------------------------------

Plan hash value: 432827260

\-----------------------------------------------------------------------------------------------------

| Id  | Operation            | Name                  | Rows  | Bytes | Cost
(%CPU)| Time     |

\-----------------------------------------------------------------------------------------------------

|   0 | SELECT STATEMENT  |                     |     1 |  6031 |     4   (0)|
00:00:01 |

|   1 |  TABLE ACCESS BY INDEX ROWID| HIGHGO031402  1 |  6031 |     4   (0)|
00:00:01 |

|*  2 |   DOMAIN INDEX  | IND_HIGHGO031402_DOCS |     |       |     4   (0)|
00:00:01 |

\-----------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):

PLAN_TABLE_OUTPUT

\-------------------------------------------------------------------------------------------------------------------------------

   2 - access("CTXSYS"."CONTAINS"("DOC1",'CONTENT')>0)

Note

\-----

   \- dynamic sampling used for this statement (level=2)

18 rows selected.

对于多列的全文索引可以建立在多个列的任意一列上,在查询时指定的列必须与索引时指定的列保持一致。

最后注意一点，只有索引指定的列发生修改，Oracle才会认为被索引数据发生了变化，仅仅修改其他列而没有修改索引列，即使同步索引也不会将修改同步到索引中。

### 4、全文索引的lexer属性

#### 4.1 BASIC_LEXER

Oracle全文索引的LEXER属性用于处理各种不同的语言。最基本的英文使用BASE_FILTER，而如果需要使用中文则可以使用CHINESE_VGRAM_LEXER或CHINESE_LEXER

BASIC_LEXER属性支持多种语言，比如英语、德语、荷兰语、挪威语、瑞典语等等。

BASIC_LEXER除了支持多种语言，还可以设置多种属性,比如索引大小写设置MIXED_CASE,默认basic_laxer，具体示例如下

CREATE TABLE T (ID NUMBER, DOCS VARCHAR2(1000));

 INSERT INTO T VALUES (1, 'This is a example for the basic lexer');

INSERT INTO T VALUES (2, 'And we make a example for a mixed spell indexs.');

 INSERT INTO T VALUES (3, 'So the word in UPPER format must be query in
UPPER');

INSERT INTO T VALUES (4, 'And Mixed Spell Word must be Query in Mixed.');

commit;

CREATE INDEX IND_T_DOCS ON T (DOCS) INDEXTYPE IS CTXSYS.CONTEXT PARAMETERS
('LEXER CTXSYS.BASIC_LEXER');

SELECT ID FROM T WHERE CONTAINS(DOCS, 'MIXED') > 0;

PLAN_TABLE_OUTPUT

\-------------------------------------------------------------------------------------------------------------------------------

Plan hash value: 3282600506

\------------------------------------------------------------------------------------------

| Id  | Operation                   | Name       | Rows  | Bytes | Cost
(%CPU)| Time     |

\------------------------------------------------------------------------------------------

|   0 | SELECT STATEMENT            |            |     1 |   527 |     4
(0)| 00:00:01 |

|   1 |  TABLE ACCESS BY INDEX ROWID| T          |     1 |   527 |     4
(0)| 00:00:01 |

|*  2 |   DOMAIN INDEX             | IND_T_DOCS |       |       |     4   (0)|
00:00:01 |

\------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):

PLAN_TABLE_OUTPUT

\-------------------------------------------------------------------------------------------------------------------------------

   2 - access("CTXSYS"."CONTAINS"("DOCS",'MIXED')>0)

Note

\-----

   \- dynamic sampling used for this statement (level=2)

BEGIN

 CTX_DDL.CREATE_PREFERENCE('TEST_BASIC_LEXER', 'BASIC_LEXER');

 CTX_DDL.SET_ATTRIBUTE('TEST_BASIC_LEXER', 'MIXED_CASE', 'YES');

 END;

 /

CREATE INDEX IND_T_DOCS ON T (DOCS) INDEXTYPE IS CTXSYS.CONTEXT PARAMETERS
('LEXER CTXSYS.TEST_BASIC_LEXER');

SQL>  SELECT ID FROM T WHERE CONTAINS(DOCS, 'MIXED') > 0;

no rows selected

SQL>  SELECT ID FROM T WHERE CONTAINS(DOCS, 'Mixed') > 0;

        ID

\----------

         4

如果不进行设置，Oracle在建立索引时会将所有的字母变为大写。如果进行了设置，可以使索引区分大小写。

#### 4.2 CHINESE_VGRAM_LEXER和CHINESE_LEXER

Oracle全文索引的BASIC属性主要是针对西方英语语系，英语语系的单词是通过空格、标点和回车来分隔的。而中文则需要索引来自动切词。具体示例如下

CREATE TABLE T (ID NUMBER, DOCS VARCHAR2(1000));

 INSERT INTO T VALUES (1, '一个中文例子，测试BASIC_LEXER语法属性是否可以正常识别中文。');

Commit;

 CREATE INDEX IND_T_DOCS ON T (DOCS) INDEXTYPE IS CTXSYS.CONTEXT;

SQL> SELECT * FROM highgo.T WHERE CONTAINS(DOCS, '一个中文例子') > 0;

        ID DOCS

\----------
--------------------------------------------------------------------------------

         1 一个中文例子，测试BASIC_LEXER语法属性是否可以正常识别中文。

         1 一个中文例子，测试BASIC_LEXER语法属性是否可以正常识别中文。

SELECT * FROM highgo.T WHERE CONTAINS(DOCS, '中文') > 0;

No rows selected

通过BASIC_LEXER来索引中文，Oracle只识别被空格、标点和回车符分隔出来的部分。需要对中文内容进行索引的话，就必须使用中文的LEXER。

CHINESE_LEXER相对应CHINESE_VGRAM_LEXER属性有如下的优点：

产生的索引更小；

更好的查询响应时间；

产生更接近真实的索引切词，使得查询精度更高；

支持停用词。

  但是，经过试验，建议使用CHINESE_VGRAM_LEXER，切词更准确。

具体示例如下

insert into highgo.t values(1,'山东大学');

insert into highgo.t values(2,'山东农业大学');

insert into highgo.t values(3,'山东');

insert into highgo.t values(4,'山东科技大学');

commit;

BEGIN

CTX_DDL.CREATE_PREFERENCE('TEST_CHINESE_VGRAM_LEXER', 'CHINESE_VGRAM_LEXER');

CTX_DDL.CREATE_PREFERENCE('TEST_CHINESE_LEXER', 'CHINESE_LEXER');

END;

/

CREATE INDEX IND_T_DOCS ON T(DOCS) INDEXTYPE IS CTXSYS.CONTEXT PARAMETERS
('LEXER CTXSYS.TEST_CHINESE_VGRAM_LEXER')

SQL> select * from highgo.t where contains(docs ,'山东')>0;

        ID DOCS

\----------
--------------------------------------------------------------------------------

         1 山东大学

         2 山东农业大学

         3 山东

         4 山东科技大学

            5 山东省

DROP INDEX IND_T_DOCS;

CREATE INDEX IND_T_DOCS ON T(DOCS) INDEXTYPE IS CTXSYS.CONTEXT PARAMETERS
('LEXER CTXSYS.TEST_CHINESE_LEXER');

SQL> select * from highgo.t where contains(docs ,'山东')>0;

        ID DOCS

\----------
--------------------------------------------------------------------------------

         1 山东大学

         2 山东农业大学

         3 山东

         4 山东科技大学

SQL> select * from highgo.t;

        ID DOCS

\----------
--------------------------------------------------------------------------------

         1 山东大学

         2 山东农业大学

         3 山东

         4 山东科技大学

         5 山东省

#### 4.3、多语言全文索引MULTI_LEXER

如果在Oracle中存储多种语言，那么在建立全文索引的时候就不能只是简单的指定一个LEXER，而是要通过LANGUAGE
COLUMN设置MULTI_LEXER。

SQL> CREATE TABLE T (ID NUMBER, LANGUAGE VARCHAR2(7), DOCS VARCHAR2(1000));

表已创建。

SQL> INSERT INTO T VALUES (1, 'english', 'This is a mixed language example.');

已创建 1 行。

SQL> INSERT INTO T VALUES (2, 'chinese',
'中文信息应该使用中文语言属性CHINESE_VGRAM_LEXER进行索引');

已创建 1 行。

SQL> INSERT INTO T VALUES (3, 'chinese',
'英文记录虽然可以通过中文语言属性CHINESE_VGRAM_LEXER继续索引');

已创建 1 行。

SQL> INSERT INTO T VALUES (4, '', 'But all the words is indexed by UPPER
FORMAT.');

已创建 1 行。

SQL> COMMIT;

提交完成。

SQL> CREATE INDEX IND_T_DOCS ON T(DOCS) INDEXTYPE IS CTXSYS.CONTEXT

2 PARAMETERS ('LEXER CTXSYS.BASIC_LEXER');

索引已创建。

SQL> SELECT * FROM T WHERE CONTAINS(DOCS, '中文') > 0;

未选定行

如果使用BASIC_LEXER作为LEXER属性的选项，那么就无法对中文使用索引。

SQL> DROP INDEX IND_T_DOCS;

索引已丢弃。

SQL> CONN CTXSYS/CTXSYS@YANGTK

已连接。

SQL> BEGIN

2 CTX_DDL.CREATE_PREFERENCE('TEST_CHINESE_LEXER', 'CHINESE_VGRAM_LEXER');

3 END;

4 /

PL/SQL 过程已成功完成。

SQL> CONN YANGTK/YANGTK@YANGTK

已连接。

SQL> CREATE INDEX IND_T_DOCS ON T(DOCS) INDEXTYPE IS CTXSYS.CONTEXT

2 PARAMETERS ('LEXER CTXSYS.TEST_CHINESE_LEXER');

索引已创建。

SQL> SELECT * FROM T WHERE CONTAINS(DOCS, '中文') > 0;

ID LANGUAG DOCS

\---------- ------- ----------------------------------------------------------

3 chinese 英文记录虽然可以通过中文语言属性CHINESE_VGRAM_LEXER继续索引

2 chinese 中文信息应该使用中文语言属性CHINESE_VGRAM_LEXER进行索引

SQL> SELECT * FROM T WHERE CONTAINS(DOCS, 'INDEXED') > 0;

ID LANGUAG DOCS

\---------- ------- ---------------------------------------------------------

4 But all the words is indexed by UPPER FORMAT.

如果使用CHINESE_VGRAM_LEXER属性的话，虽然可以对英文进行索引，但是中文LEXER无法进行属性的设置，如果想要对英文进行大小写敏感的查询，使用CHINESE_VGRAM_LEXER属性是不行的，必须使用BASIC_LEXER，并进行MIXED_CASE属性设置。

SQL> DROP INDEX IND_T_DOCS;

索引已丢弃。

SQL> CONN CTXSYS/CTXSYS

已连接。

BEGIN

CTX_DDL.CREATE_PREFERENCE('TEST_ENGLISH', 'BASIC_LEXER');

CTX_DDL.SET_ATTRIBUTE('TEST_ENGLISH', 'MIXED_CASE', 'YES');

CTX_DDL.CREATE_PREFERENCE('TEST_CHINESE', 'CHINESE_LEXER');

CTX_DDL.CREATE_PREFERENCE('TEST_MULTI_LEXER', 'MULTI_LEXER');

CTX_DDL.ADD_SUB_LEXER('TEST_MULTI_LEXER', 'DEFAULT', 'TEST_ENGLISH');

CTX_DDL.ADD_SUB_LEXER('TEST_MULTI_LEXER', 'SIMPLIFIED CHINESE',
'TEST_CHINESE', 'CHINESE');

END;

/

PL/SQL 过程已成功完成。

SQL> CONN highgo/highgo

已连接。

CREATE INDEX IND_T_DOCS ON T(DOCS) INDEXTYPE IS CTXSYS.CONTEXT PARAMETERS
('LEXER CTXSYS.TEST_MULTI_LEXER LANGUAGE COLUMN LANGUAGE');

参考 https://docs.oracle.com/cd/E11882_01/text.112/e24436/csql.htm#CCREF0105

建立一个MULTI_LEXER属性的索引，并通过LANGUAGE列设置需要索引的语言。

Oracle会根据LANGUAGE列的内容去匹配ADD_SUB_LEXER过程中指定的语言标识符。如果匹配的上，就使用该SUB_LEXER作为索引的LEXER，如果没有找到匹配的，就使用DEFAULT语言作为索引的LEXER列。

上面虽然建立了MULTI_LEXER索引，但是对多语言索引的查询却还存在一些额外的问题：

SQL> SELECT * FROM T WHERE CONTAINS(DOCS, '中文') > 0;

ID LANGUAG DOCS

\---------- ------- ----------------------------------------------------------

3 chinese 英文记录虽然可以通过中文语言属性CHINESE_VGRAM_LEXER继续索引

2 chinese 中文信息应该使用中文语言属性CHINESE_VGRAM_LEXER进行索引

SQL> SELECT * FROM T WHERE CONTAINS(DOCS, 'INDEXED') > 0;

未选定行

SQL> SELECT * FROM T WHERE CONTAINS(DOCS, 'indexed') > 0;

未选定行

SQL> SELECT * FROM T WHERE CONTAINS(DOCS, 'FORMAT') > 0;

ID LANGUAG DOCS

\---------- ------- ------------------------------------------------

4 But all the words is indexed by UPPER FORMAT.

通过上面的查询结果可以推测出，BASIC_LEXER并没有起作用。对于中文的查询可以生效，但是对于字符大小写敏感的查询都不会生效。可以生效的查询只是原文中就使用大写的单词。

这是由于当前客户端的语言设置是简体中文，这和索引中的一个SUB_LEXER相匹配，因此Oracle选择了该LEXER的索引结果作为查询的返回结果。下面将NLS_LANGUAGE设置为英文：

SQL> SELECT * FROM V$NLS_PARAMETERS WHERE PARAMETER = 'NLS_LANGUAGE';

PARAMETER VALUE

\------------------------------ ----------------------------------------

NLS_LANGUAGE SIMPLIFIED CHINESE

SQL> ALTER SESSION SET NLS_LANGUAGE = 'AMERICAN';

Session altered.

SQL> SELECT * FROM T WHERE CONTAINS(DOCS, '中文') > 0;

ID LANGUAG DOCS

\---------- -------
-----------------------------------------------------------

3 chinese 英文记录虽然可以通过中文语言属性CHINESE_VGRAM_LEXER继续索引

2 chinese 中文信息应该使用中文语言属性CHINESE_VGRAM_LEXER进行索引

SQL> SELECT * FROM T WHERE CONTAINS(DOCS, 'INDEXED') > 0;

no rows selected

SQL> SELECT * FROM T WHERE CONTAINS(DOCS, 'indexed') > 0;

ID LANGUAG DOCS

\---------- ------- --------------------------------------------------------

4 But all the words is indexed by UPPER FORMAT.

SQL> SELECT * FROM T WHERE CONTAINS(DOCS, 'FORMAT') > 0;

ID LANGUAG DOCS

\---------- ------- --------------------------------------------------------

4 But all the words is indexed by UPPER FORMAT.

结果恢复了正常，如果将语言不设置为DEFAULT LEXER，而是设置索引包含的LEXER以外的语言，查询也是正常的。

SQL> ALTER SESSION SET NLS_LANGUAGE = 'TRADITIONAL CHINESE';

Session altered.

SQL> SELECT * FROM T WHERE CONTAINS(DOCS, '中文') > 0;

ID LANGUAG DOCS

\---------- -------
-----------------------------------------------------------

3 chinese 英文记录虽然可以通过中文语言属性CHINESE_VGRAM_LEXER继续索引

2 chinese 中文信息应该使用中文语言属性CHINESE_VGRAM_LEXER进行索引

SQL> SELECT * FROM T WHERE CONTAINS(DOCS, 'INDEXED') > 0;

no rows selected

SQL> SELECT * FROM T WHERE CONTAINS(DOCS, 'indexed') > 0;

ID LANGUAG DOCS

\---------- -------
-----------------------------------------------------------

4 But all the words is indexed by UPPER FORMAT.

SQL> SELECT * FROM T WHERE CONTAINS(DOCS, 'FORMAT') > 0;

ID LANGUAG DOCS

\---------- -------
-----------------------------------------------------------

4 But all the words is indexed by UPPER FORMAT.

这就是说，对于包含多种语言的全文索引需要额外的小心。尤其是客户端的语言设置与全文索引中的非DEFAULT属性的SUB_LEXER的语言一致的情况。这个时候查询语句会仅返回当前语言下的索引记录。

### 5、全文索引的wordlist属性

Oracle全文索引的WORDLIST属性用来设置模糊查询和同词根查询，另外WORDLIST属性还支持通配符查询。

CREATE TABLE highgo.T (ID NUMBER, DOCS VARCHAR2(1000));

INSERT INTO highgo.T VALUES (1, 'It is a basic wordlist example.');

 INSERT INTO highgo.T VALUES (2, 'Using the basic wordlist, the indexes
support stemmer query and fuzzy query.');

 INSERT INTO highgo.T VALUES (3, 'And support the wildcard query too.');

  INSERT INTO highgo.T VALUES (4, 'This example will show the query on the
wordlist preference indexes.');

  commit;

SQL> CONN CTXSYS/CTXSYS

BEGIN

CTX_DDL.CREATE_PREFERENCE('TEST_WORDLIST', 'BASIC_WORDLIST');

CTX_DDL.SET_ATTRIBUTE('TEST_WORDLIST', 'STEMMER', 'ENGLISH');

CTX_DDL.SET_ATTRIBUTE('TEST_WORDLIST', 'FUZZY_MATCH', 'ENGLISH');

CTX_DDL.SET_ATTRIBUTE('TEST_WORDLIST', 'SUBSTRING_INDEX', 'TRUE');

CTX_DDL.SET_ATTRIBUTE('TEST_WORDLIST', 'PREFIX_INDEX', 'TRUE');

END;

/  

CREATE INDEX IND_T_DOCS ON highgo.T(DOCS) INDEXTYPE IS CTXSYS.CONTEXT
PARAMETERS ('WORDLIST CTXSYS.TEST_WORDLIST');  

SQL> SELECT ID FROM T WHERE CONTAINS(DOCS, '$USE') > 0;

ID

\----------

2

SQL> SELECT ID FROM T WHERE CONTAINS(DOCS, 'STE%') > 0;

ID

\----------

2

SQL> SELECT ID FROM T WHERE CONTAINS(DOCS, '%ORD%') > 0;

ID

\----------

4

2

1

在为WORDLIST设置属性时，第一个属性STEMMER是设置同词根查询的语言，第二个属性FUZZY_MATCH是设置模糊查询的语言，SUBSTRING_INDEX是用来提高左通配符或双通配符查询的效率的，而PREFIX_INDEX是用来提高右通配符查询的效率的。

即使不设置SUBSTRING_INDEX和PREFIX_INDEX属性，全文索引的查询也是支持通配符的，但如果设置了上述两个属性，会提高包含通配符的查询的性能。

### 6、全文索引的storage属性

Oracle全文索引的STORAGE属性是为了给全文索引生成的辅助表设置存储参数的。

Oracle的全文索引会生成一张或多张辅助表，由于这些表是Oracle自动生成的，用户没有办法直接设置这些表和索引的物理参数，因此Oracle提供了STORAGE属性，专门设置这些辅助表和索引的物理参数。

SQL> SELECT * FROM TAB;

TNAME TABTYPE CLUSTERID

\------------------------------ ------- ----------

DR$IND_T_DOCS$I TABLE

DR$IND_T_DOCS$K TABLE

DR$IND_T_DOCS$N TABLE

DR$IND_T_DOCS$P TABLE

DR$IND_T_DOCS$R TABLE

DR$IND_T_DOCS$I存储的是索引数据表(Index data table)；

DR$IND_T_DOCS$K存储的是键值映射表(Keymap table)；

DR$IND_T_DOCS$R是ROWID表(Rowid table)；

DR$IND_T_DOCS$N是负键值链表(Negative list table)；

DR$IND_T_DOCS$P这个表只有在CONTEXT索引中设置BASIC_WORDLIST的SUBSTRING_INDEX属性后才会生成，用来保存单词的部分内容。

DR$IND_T_DOCS$X这个索引是DR$IND_T_DOCS$I表的索引。

如果不进行设置，那么Oracle会将这些对象存放到默认表空间中，并根据默认表空间的存储参数设置这些对象的存储参数。

下面通过设置STORAGE属性，设置自动生成的表和索引的表空间属性：

SQL> CREATE TABLE T (ID NUMBER, DOCS VARCHAR2(1000));

SQL> INSERT INTO T VALUES (1, 'A simple example for storage.');

SQL> CONN CTXSYS/CTXSYS

已连接。

 BEGIN

CTX_DDL.CREATE_PREFERENCE('TEST_WORDLIST_STORAGE', 'BASIC_WORDLIST');

CTX_DDL.SET_ATTRIBUTE('TEST_WORDLIST_STORAGE', 'SUBSTRING_INDEX', 'TRUE');

CTX_DDL.CREATE_PREFERENCE('TEST_STORAGE', 'BASIC_STORAGE');

CTX_DDL.SET_ATTRIBUTE('TEST_STORAGE', 'I_TABLE_CLAUSE', 'TABLESPACE USERS');

CTX_DDL.SET_ATTRIBUTE('TEST_STORAGE', 'K_TABLE_CLAUSE', 'TABLESPACE TOOLS');

CTX_DDL.SET_ATTRIBUTE('TEST_STORAGE', 'R_TABLE_CLAUSE', 'TABLESPACE EXAMPLE');

CTX_DDL.SET_ATTRIBUTE('TEST_STORAGE', 'N_TABLE_CLAUSE', 'TABLESPACE USERS');

CTX_DDL.SET_ATTRIBUTE('TEST_STORAGE', 'P_TABLE_CLAUSE', 'TABLESPACE TOOLS');

 CTX_DDL.SET_ATTRIBUTE('TEST_STORAGE', 'I_INDEX_CLAUSE', 'TABLESPACE INDX');

 END;

 /  

CREATE INDEX IND_T_DOCS ON T(DOCS) INDEXTYPE IS CTXSYS.CONTEXT PARAMETERS
('WORDLIST CTXSYS.TEST_WORDLIST_STORAGE STORAGE CTXSYS.TEST_STORAGE');

SELECT

TABLE_NAME NAME,

DECODE

(

IOT_TYPE,

'IOT',

(

SELECT TABLESPACE_NAME

FROM USER_INDEXES

 WHERE TABLE_NAME = A.TABLE_NAME

 AND INDEX_TYPE = 'IOT - TOP'

 ),

 TABLESPACE_NAME

 ) TABLESPACE_NAME

 FROM USER_TABLES A

 WHERE TABLE_NAME LIKE 'DR%'

 UNION ALL

 SELECT INDEX_NAME NAME, TABLESPACE_NAME

 FROM USER_INDEXES

 WHERE INDEX_NAME LIKE 'DR%';

NAME TABLESPACE_NAME

\------------------------------ ------------------------------

DR$IND_T_DOCS$I USERS

DR$IND_T_DOCS$K TOOLS

DR$IND_T_DOCS$N USERS

DR$IND_T_DOCS$P TOOLS

DR$IND_T_DOCS$R EXAMPLE

DR$IND_T_DOCS$X INDX

已选择6行

通过查询看到，STORAGE属性的设置已经生效了。

Measure

Measure



---
### TAGS
{Support20180830}

---
### NOTE ATTRIBUTES
>Created Date: 2018-08-30 01:28:49  
>Last Evernote Update Date: 2018-08-30 01:29:35  
>source: web.clip7  
>source-url: https://47.100.29.40/highgo_admin/#/index/docSearchDetail/0d8bf9af030fd7bb  
>source-application: WebClipper 7  