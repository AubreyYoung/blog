## Oracle将数据导出到CSV文件

工作中有需要将线上数据导出到excel给客户分析/查看的情况，如下是方法介绍情况：
- utl_file读写文件包 ，1分钟导出的数据量 大概是300万 适用于大量导出时;

- spool 循环打印 ，适用小型数据量时。

利用utl_file导出.csv文件.  --.csv逗号分隔值格式文件，可用excel工具打开，显示格式和excel一样..

### 建立sql_to_csv存储过程,

代码如下:

```
CREATE OR REPLACE PROCEDURE SQL_TO_CSV
(
 P_QUERY IN VARCHAR2, -- PLSQL文
 P_DIR IN VARCHAR2, -- 导出的文件放置目录
 P_FILENAME IN VARCHAR2 -- CSV名
 )
 IS
  L_OUTPUT UTL_FILE.FILE_TYPE;
  L_THECURSOR INTEGER DEFAULT DBMS_SQL.OPEN_CURSOR;
  L_COLUMNVALUE VARCHAR2(4000);
  L_STATUS INTEGER;
  L_COLCNT NUMBER := 0;
  L_SEPARATOR VARCHAR2(1);
  L_DESCTBL DBMS_SQL.DESC_TAB;
  P_MAX_LINESIZE NUMBER := 32000;
BEGIN
  --OPEN FILE
  L_OUTPUT := UTL_FILE.FOPEN(P_DIR, P_FILENAME, 'W', P_MAX_LINESIZE);
  --DEFINE DATE FORMAT
  EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT=''YYYY-MM-DD HH24:MI:SS''';
  --OPEN CURSOR
  DBMS_SQL.PARSE(L_THECURSOR, P_QUERY, DBMS_SQL.NATIVE);
  DBMS_SQL.DESCRIBE_COLUMNS(L_THECURSOR, L_COLCNT, L_DESCTBL);
  --DUMP TABLE COLUMN NAME
  FOR I IN 1 .. L_COLCNT LOOP
    UTL_FILE.PUT(L_OUTPUT,L_SEPARATOR || '"' || L_DESCTBL(I).COL_NAME || '"'); --输出表字段
    DBMS_SQL.DEFINE_COLUMN(L_THECURSOR, I, L_COLUMNVALUE, 4000);
    L_SEPARATOR := ',';
  END LOOP;
  UTL_FILE.NEW_LINE(L_OUTPUT); --输出表字段
  --EXECUTE THE QUERY STATEMENT
  L_STATUS := DBMS_SQL.EXECUTE(L_THECURSOR);
 
  --DUMP TABLE COLUMN VALUE
  WHILE (DBMS_SQL.FETCH_ROWS(L_THECURSOR) > 0) LOOP
    L_SEPARATOR := '';
    FOR I IN 1 .. L_COLCNT LOOP
      DBMS_SQL.COLUMN_VALUE(L_THECURSOR, I, L_COLUMNVALUE);
      UTL_FILE.PUT(L_OUTPUT,
                  L_SEPARATOR || '"' ||
                  TRIM(BOTH ' ' FROM REPLACE(L_COLUMNVALUE, '"', '""')) || '"');
      L_SEPARATOR := ',';
    END LOOP;
    UTL_FILE.NEW_LINE(L_OUTPUT);
  END LOOP;
  --CLOSE CURSOR
  DBMS_SQL.CLOSE_CURSOR(L_THECURSOR);
  --CLOSE FILE
  UTL_FILE.FCLOSE(L_OUTPUT);
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END;
 
/
```
### 执行：

```
sql>create or replace directory OUT_PATH as 'D:\';
```
其中OUT_PATH为指定的目标文件存放路径。

### 测试验证

然后在需要做导出的用户下执行如下查询sql，将拼出数据库表导出语句：

```
SQL> SELECT 'EXEC sql_to_csv(''select * from ' ||T.TABLE_NAME ||''',''OUT_PATH''' || ',''ODS_MDS.' || T.TABLE_NAME ||'.csv'');' FROM user_TABLES T where t.TABLE_NAME='表名'；

EXEC sql_to_csv('select * from TD_DIS_BATCH_CHECK','OUT_PATH','ODS_MDS.TD_DIS_BATCH_CHECK.csv');
EXEC sql_to_csv('select * from TD_DIS_CONTROLL','OUT_PATH','ODS_MDS.TD_DIS_CONTROLL.csv');
EXEC sql_to_csv('select * from TD_DIS_TASK_DATASOURCE','OUT_PATH','ODS_MDS.TD_DIS_TASK_DATASOURCE.csv');
EXEC sql_to_csv('select * from TD_DIS_TASK_DEPENDENT','OUT_PATH','ODS_MDS.TD_DIS_TASK_DEPENDENT.csv');
EXEC sql_to_csv('select * from TD_DIS_TASK_GROUP','OUT_PATH','ODS_MDS.TD_DIS_TASK_GROUP.csv');
EXEC sql_to_csv('select * from TD_DIS_TASK_GROUP_DEPENDENT','OUT_PATH','ODS_MDS.TD_DIS_TASK_GROUP_DEPENDENT.csv');
EXEC sql_to_csv('select * from TD_DIS_TASK_INFO','OUT_PATH','ODS_MDS.TD_DIS_TASK_INFO.csv');
EXEC sql_to_csv('select * from TD_DIS_TASK_PARAMS','OUT_PATH','ODS_MDS.TD_DIS_TASK_PARAMS.csv');
EXEC sql_to_csv('select * from TD_DIS_TASK_TRACK','OUT_PATH','ODS_MDS.TD_DIS_TASK_TRACK.csv');
EXEC sql_to_csv('select * from TD_DIS_TASK_TYPE','OUT_PATH','ODS_MDS.TD_DIS_TASK_TYPE.csv');
EXEC sql_to_csv('select * from TD_OPER','OUT_PATH','ODS_MDS.TD_OPER.csv');
EXEC sql_to_csv('select * from TD_ORGAN','OUT_PATH','ODS_MDS.TD_ORGAN.csv');
EXEC sql_to_csv('select * from TD_PUB_DIC','OUT_PATH','ODS_MDS.TD_PUB_DIC.csv');
EXEC sql_to_csv('select * from TD_PUB_DIC_SUBSU','OUT_PATH','ODS_MDS.TD_PUB_DIC_SUBSU.csv');
EXEC sql_to_csv('select * from TD_SYS_MENUS','OUT_PATH','ODS_MDS.TD_SYS_MENUS.csv');
EXEC sql_to_csv('select * from TD_SYS_ONLINE_USERS','OUT_PATH','ODS_MDS.TD_SYS_ONLINE_USERS.csv');
EXEC sql_to_csv('select * from TD_SYS_POSITION','OUT_PATH','ODS_MDS.TD_SYS_POSITION.csv');
EXEC sql_to_csv('select * from TD_SYS_ROLE_POS','OUT_PATH','ODS_MDS.TD_SYS_ROLE_POS.csv');
EXEC sql_to_csv('select * from TD_SYS_SECURITY_EMP_ROLE_RES','OUT_PATH','ODS_MDS.TD_SYS_SECURITY_EMP_ROLE_RES.csv');
EXEC sql_to_csv('select * from TD_SYS_SECURITY_REL_ROLE_RES','OUT_PATH','ODS_MDS.TD_SYS_SECURITY_REL_ROLE_RES.csv');
EXEC sql_to_csv('select * from TD_SYS_SECURITY_REL_USER_POS','OUT_PATH','ODS_MDS.TD_SYS_SECURITY_REL_USER_POS.csv');
EXEC sql_to_csv('select * from TD_SYS_SECURITY_RESOURCES','OUT_PATH','ODS_MDS.TD_SYS_SECURITY_RESOURCES.csv');
EXEC sql_to_csv('select * from TD_DIS_APP_OPER','OUT_PATH','ODS_MDS.TD_DIS_APP_OPER.csv');
EXEC sql_to_csv('select * from GF_PROD_SELLFEE_MONTH','OUT_PATH','ODS_MDS.GF_PROD_SELLFEE_MONTH.csv');
EXEC sql_to_csv('select * from GF_PROD_TRUSTEEFEE_DAILY','OUT_PATH','ODS_MDS.GF_PROD_TRUSTEEFEE_DAILY.csv');
EXEC sql_to_csv('select * from GF_PROD_TRUSTEEFEE_MONTH','OUT_PATH','ODS_MDS.GF_PROD_TRUSTEEFEE_MONTH.csv');
EXEC sql_to_csv('select * from GF_RETAILER_DAILY_TRADE_NOTE','OUT_PATH','ODS_MDS.GF_RETAILER_DAILY_TRADE_NOTE.csv');
EXEC sql_to_csv('select * from TA_ENDDAY_CTL','OUT_PATH','ODS_MDS.TA_ENDDAY_CTL.csv');
EXEC sql_to_csv('select * from TA_DISPOSABLE_TASK_CTL','OUT_PATH','ODS_MDS.TA_DISPOSABLE_TASK_CTL.csv');
EXEC sql_to_csv('select * from TD_DIS_TASK_INFO_A','OUT_PATH','ODS_MDS.TD_DIS_TASK_INFO_A.csv');
EXEC sql_to_csv('select * from GF_PROD_SELLFEE_DAILY','OUT_PATH','ODS_MDS.GF_PROD_SELLFEE_DAILY.csv');
```
将上面生成的语句在命令行中执行，即可生成对应表的csv文件：
```
SQL> EXEC sql_to_csv('select * from TD_DIS_TASK_INFO','OUT_PATH','ODS_MDS.TD_DIS_TASK_INFO.csv');
PL/SQL procedure successfully completed

SQL> EXEC sql_to_csv('select * from TD_DIS_TASK_INFO','OUT_PATH','ODS_MDS.TD_DIS_TASK_INFO.csv');
PL/SQL procedure successfully completed

SQL> EXEC sql_to_csv('select * from TD_DIS_TASK_INFO','OUT_PATH','ODS_MDS.TD_DIS_TASK_INFO.csv');
PL/SQL procedure successfully completed

SQL> EXEC sql_to_csv('select * from TD_DIS_TASK_INFO_a','OUT_PATH','ODS_MDS.TD_DIS_TASK_INFO_a.csv');
PL/SQL procedure successfully completed
```