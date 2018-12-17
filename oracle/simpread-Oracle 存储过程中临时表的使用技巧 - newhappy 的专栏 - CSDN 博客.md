> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 https://blog.csdn.net/newhappy2008/article/details/9115675 版权声明：本文为博主原创文章，未经博主允许不得转载。 https://blog.csdn.net/newhappy2008/article/details/9115675 <link rel="stylesheet" href="https://csdnimg.cn/release/phoenix/template/css/ck_htmledit_views-d7e2a68c7c.css">

**一、Oracle 临时表知识　** 　

在 Oracle 中，临时表分为 SESSION、TRANSACTION 两种，SESSION 级的临时表数据在整个 SESSION 都存在，直到结束此次 SESSION；而 TRANSACTION 级的临时表数据在 TRANACTION 结束后消失，即 COMMIT/ROLLBACK 或结束 SESSION 都会清除 TRANACTION 临时表数据。 
**1) 会话级临时表 示例** 
1 创建

1.  create global temporary table temp_tbl(col_a varchar2(30))  
2.  on commit preserve rows  

 2 插入数据

1.  insert into temp_tbl values('test session table')  

 3 提交

1.  commit;  

 4 查询

1.  select *from temp_tbl  

 可以看到数据'test session table'记录还在。
结束 SESSION，重新登录，再查询数据 select *from temp_tbl，这时候记录已不存在，因为系统在结束 SESSION 时自动清除记录 。

**2) 事务级临时表 示例** 
1 创建

1.  create global temporary table temp_tbl(col_a varchar2(30))  
2.  on commit delete rows  

2 插入数据

1.  insert into temp_tbl values('test transaction table')  

3 提交

1.  commit ;  

4 查询

1.  select *from temp_tbl  

 这时候可以看到刚才插入的记录'test transaction table'已不存在了, 因为提交时已经晴空了数据库；同样，如果不提交而直接结束 SESSION，重新登录记录也不存在 。

**二、在 Oracle 存储中使用临时表的一个例子**

描述：档案册借阅时，需要把册拆分成详细的单据，拆分依据是册表中的 BILLCODES（若干个用逗号分割的单据号）字段，临时表用于保存拆分出来的单据信息。拆分结束后直接返回临时表的数据。

1.  create or replace package AMS_PKG as  
2.  type REFCURSORTYPE is REF CURSOR;  
3.  procedure SPLIT_VOLUMES (P_CORP_NAME IN varchar2,P_YEAR IN varchar2,P_MONTH IN varchar2,P_VOL_TYPE_CODE IN varchar2,P_BILL_NUM IN varchar2,P_VOLUME_NUM IN varchar2,P_AREA_CODES IN varchar2,P_QUERY_SQL out varchar2,P_OUTCURSOR out refCursorType);  
4.  end AMS_PKG;  
5.  /  
6.  CREATE OR REPLACE PACKAGE BODY "AMS_PKG" as  
7.  procedure SPLIT_VOLUMES(p_CORP_NAME      IN   varchar2,         -- 查询条件, 公司名称  
8.  p_YEAR           IN   varchar2,         -- 查询条件, 会计年度  
9.  p_MONTH          IN   varchar2,         -- 查询条件, 期间  
10.  p_VOL_TYPE_CODE  IN   varchar2,         -- 查询条件, 凭证类别编码  
11.  p_BILL_NUM       IN   varchar2,         -- 查询条件, 信息单号  
12.  p_VOLUME_NUM     IN   varchar2,         -- 查询条件, 册号  
13.  p_AREA_CODES     IN   varchar2,         -- 查询条件, 所在区域编码（产生册的区域），逗号分割。  
14.  -- 形式如 '12C01','12201','12D01','12E01','12601'，存储过程中将使用 in 的方式进行过滤  
15.  p_QUERY_SQL     out   varchar2,         -- 返回查询字符串  
16.  p_OutCursor      out  refCursorType -- 返回值  
17.  ) is  

19.  v_sql   varchar2(3000);  
20.  v_sql_WHERE   varchar2(3000);  
21.  v_temp1   varchar2(300);  
22.  v_temp2   varchar2(300);  
23.  v_tempBILLCODES varchar2(3000);  
24.  V_CNT NUMBER(10,0);  
25.  V_VOLUME_ID NUMBER(10,0);  
26.  mycur refCursorType;  
27.  --CURSOR mycur(v varchar2) is  
28.  --               SELECT VOUCHTYPE,BILLCODES FROM PUB_VOLUMES where volumeid=v;  
29.  CURSOR mycur_split(val varchar2,splitMark varchar2) is  
30.  select * from table(myutil_split(val,splitMark));  
31.  begin  
32.  v_temp1    :='';  
33.  v_temp2    :='';  
34.  v_sql_WHERE := '';  
35.  v_tempBILLCODES  := '';  
36.  V_CNT            := 0;  
37.  V_VOLUME_ID            := 0;-- 册表的系统编号  
38.  v_sql := 'SELECT VOLUMEID,VOUCHTYPE,BILLCODES FROM PUB_VOLUMES WHERE 1=1';  
39.  --dbms_output.put_line('p_BILL_NUM='||p_BILL_NUM);  

42.  IF (p_CORP_NAME IS NOT NULL AND LENGTH(p_CORP_NAME) >0) THEN -- 公司名称  
43.  BEGIN  
44.  v_sql_WHERE := v_sql_WHERE || 'AND CORPNAME LIKE''%';  
45.  v_sql_WHERE := v_sql_WHERE || p_CORP_NAME;  
46.  v_sql_WHERE := v_sql_WHERE || '%''';  
47.  --dbms_output.put_line(p_BILL_NUM);  
48.  END;  
49.  END IF;  
50.  IF (p_YEAR IS NOT NULL AND LENGTH(p_YEAR) >0)  THEN -- 会计年度  
51.  BEGIN  
52.  v_sql_WHERE := v_sql_WHERE || 'AND YEAR =''';  
53.  v_sql_WHERE := v_sql_WHERE || p_YEAR;  
54.  v_sql_WHERE := v_sql_WHERE || '''';  
55.  --dbms_output.put_line(p_BILL_NUM);  
56.  END;  
57.  END IF;  
58.  IF (p_MONTH IS NOT NULL AND LENGTH(p_MONTH) >0)  THEN -- 期间  
59.  BEGIN  
60.  v_sql_WHERE := v_sql_WHERE || 'AND MONTH =''';  
61.  v_sql_WHERE := v_sql_WHERE || p_MONTH;  
62.  v_sql_WHERE := v_sql_WHERE || '''';  
63.  --dbms_output.put_line(p_BILL_NUM);  
64.  END;  
65.  END IF;  
66.  IF (p_VOL_TYPE_CODE IS NOT NULL AND LENGTH(p_VOL_TYPE_CODE) >0) THEN -- 凭证类别编码  
67.  BEGIN  
68.  v_sql_WHERE := v_sql_WHERE || 'AND VOUCHTYPE =''';  
69.  v_sql_WHERE := v_sql_WHERE || p_VOL_TYPE_CODE;  
70.  v_sql_WHERE := v_sql_WHERE || '''';  
71.  --dbms_output.put_line(p_BILL_NUM);  
72.  END;  
73.  END IF;  
74.  IF (p_BILL_NUM IS NOT NULL AND LENGTH(p_BILL_NUM) >0) THEN -- 信息单号  
75.  BEGIN  
76.  v_sql_WHERE := v_sql_WHERE || 'AND BILLCODES LIKE''%';  
77.  v_sql_WHERE := v_sql_WHERE || p_BILL_NUM;  
78.  v_sql_WHERE := v_sql_WHERE || '%''';  
79.  --dbms_output.put_line(p_BILL_NUM);  
80.  END;  
81.  END IF;  
82.  IF (p_VOLUME_NUM IS NOT NULL AND LENGTH(p_VOLUME_NUM) >0) THEN -- 册号  
83.  BEGIN  
84.  v_sql_WHERE := v_sql_WHERE || 'AND VOLUMENUM =''';  
85.  v_sql_WHERE := v_sql_WHERE || p_VOLUME_NUM;  
86.  v_sql_WHERE := v_sql_WHERE || '''';  
87.  --dbms_output.put_line(p_BILL_NUM);  
88.  END;  
89.  END IF;  
90.  p_QUERY_SQL := 'SQL4WHERE:' || v_sql_WHERE;  

92.  --dbms_output.put_line(v_sql || v_sql_WHERE || p_BILL_NUM);  
93.  --OPEN mycur(v_WHERE);  
94.  OPEN mycur FOR v_sql || v_sql_WHERE;  

96.  LOOP-- 循环册记录  
97.  fetch mycur INTO V_VOLUME_ID,v_temp1,v_tempBILLCODES ;  
98.  EXIT WHEN mycur%NOTFOUND;  
99.  V_CNT := V_CNT + 1 ;  
100.  --DBMS_OUTPUT.PUT_LINE(V_CNT || ':BILLCODES =' || v_tempBILLCODES);  
101.  OPEN mycur_split(v_tempBILLCODES,',');  
102.  LOOP-- 循环生成每一个册的单据记录  
103.  fetch mycur_split INTO v_temp2 ;  
104.  EXIT WHEN mycur_split%NOTFOUND;  
105.  --DBMS_OUTPUT.PUT_LINE(' ' || v_temp2);  
106.  --DBMS_OUTPUT.PUT_LINE('p_BILL_NUM=' || p_BILL_NUM||',v_temp2='||v_temp2);  
107.  IF (p_BILL_NUM IS NULL OR p_BILL_NUM = TO_NUMBER(v_temp2)) THEN   
108.  v_temp1 := 'INSERT INTO TEMP_VOLUMES_QUERY (SELECT'''|| v_temp2 || ''',A.* FROM PUB_VOLUMES A WHERE volumeid =' || V_VOLUME_ID || ')';-- 写入到临时表  
109.  --dbms_output.put_line('v_temp1=' || v_temp1);  
110.  execute immediate v_temp1;  
111.  END IF;  
112.  END LOOP;  
113.  CLOSE mycur_split;  

115.  END LOOP;  

117.  CLOSE mycur;  

121.  -- 开始输出结果  
122.  v_sql := 'SELECT CE.DCODE,CE.VOLUMEID,CE.CORPCODE,CE.CORPNAME,QU.AREANAME,CE.YEAR,CE.MONTH,CE.BILLCODES,CE.VOUCHTYPE,SHI.ROOMNAME,';  
123.  v_sql := v_sql || 'CE.VOLUMENUM,GUI.CABINETNUM,CE.CABINETLAYER  FROM TEMP_VOLUMES_QUERY CE';  
124.  v_sql := v_sql || 'LEFT OUTER JOIN PUB_CORPS NAME ON CE.CORPCODE = NAME.CORPCODE';-- 册所属公司（产生单据的公司）  
125.  v_sql := v_sql || 'LEFT OUTER JOIN PUB_AREAS QU ON NAME.AREACODE=QU.AREACODE';-- 册所属区域（产生单据的公司所在区域）  
126.  v_sql := v_sql || 'LEFT OUTER JOIN PUB_CABINETS GUI ON CE.CABINETCODE=GUI.CABINETCODE';-- 册所在档案柜（保存的位置）  
127.  v_sql := v_sql || 'LEFT OUTER JOIN PUB_ARCHIVESROOMS SHI ON GUI.ROOMCODE = SHI.ROOMID';-- 册（柜）所在档案室（保存的位置）  
128.  v_sql := v_sql || 'WHERE (GUI.ISMAIL = 0 OR GUI.ISSIGN = 1)';-- 尚未邮寄的或者已签收的  
129.  v_sql := v_sql || 'AND CE.ISBORROW =''0'' ';-- 尚未借出去的  
130.  IF (p_AREA_CODES IS NOT NULL AND LENGTH(p_AREA_CODES) >0) THEN -- 如果需要限制册的所属区域  
131.  BEGIN  
132.  v_sql := v_sql || 'AND QU.AREACODE IN ('|| p_AREA_CODES || ')';  
133.  END;  
134.  END IF;  

136.  p_QUERY_SQL := p_QUERY_SQL || 'SQL4RESULT:' || v_sql;-- 返回  

138.  OPEN p_OutCursor FOR v_sql;  
139.  SELECT COUNT(1) INTO V_CNT FROM TEMP_VOLUMES_QUERY;  
140.  dbms_output.put_line(v_sql || ',V_CNT=' || V_CNT);  
141.  dbms_output.put_line(V_CNT);  
142.  delete from TEMP_VOLUMES_QUERY;  
143.  COMMIT;  

145.  end SPLIT_VOLUMES;  

147.  end;  
148.  /  

**三、结论** 1、ON COMMIT DELETE ROWS 说明临时表是事务指定，每次提交后 ORACLE 将截断表（删除全部行）
2、ON COMMIT PRESERVE ROWS 说明临时表是会话指定，当中断会话时 ORACLE 将截断表。
3、临时表（无论会话级还是事务级）中的数据都是会话隔离的，不同 session 之间不会共享数据。

4、在存储中使用事务级临时表时，注意 commit 前删除掉本事务的数据，否则可能会出现数据不断增加的情况（原因尚未搞明白）。

5、 两种临时表的语法：
    create global temporary table 临时表名 on commit preserve|delete rows;

用 preserve 时就是 SESSION 级的临时表，

用 delete 就是 TRANSACTION 级的临时表。

6、特性和性能 (与普通表和视图的比较)
临时表只在当前连接内有效;
临时表不建立索引, 所以如果数据量比较大或进行多次查询时, 不推荐使用;
数据处理比较复杂的时候时表快, 反之视图快点;
在仅仅查询数据的时候建议用游标: open cursor for 'sql clause';