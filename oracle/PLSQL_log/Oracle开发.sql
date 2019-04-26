SELECT ENAME || ' 的薪水是 ' || SAL || ' 提成是 ' || COALESCE(COMM, 0)
  FROM EMP;
SELECT 'truncate table ' || OWNER || '.' || TABLE_NAME || ';' AS 清空表
  FROM ALL_TABLES
 WHERE OWNER = 'SCOTT';

SELECT 'select table_name from all_tables where owner =''SCOTT'';'
  FROM DUAL;

SELECT ENAME AS 姓名,
       CASE
         WHEN SAL <= 2000 THEN
          '薪资低'
         WHEN SAL >= 5000 THEN
          '薪资高'
         ELSE
          '薪资中等'
       END AS 薪资水平
  FROM EMP
 WHERE DEPTNO = 10;

SELECT 档次, COUNT(*)
  FROM (SELECT (CASE
                 WHEN SAL <= 1000 THEN
                  '0000-1000'
                 WHEN SAL <= 2000 THEN
                  '1000-2000'
                 WHEN SAL <= 3000 THEN
                  '2000-3000'
                 WHEN SAL <= 4000 THEN
                  '3000-4000'
                 WHEN SAL <= 5000 THEN
                  '4000-5000'
                 ELSE
                  'high salary'
               END) AS 档次,
               ENAME,
               SAL
          FROM EMP) X
 GROUP BY 档次
 ORDER BY 2 DESC;

SELECT * FROM EMP WHERE ROWNUM <= 2;
SELECT * FROM (SELECT ROWNUM AS SN, EMP.* FROM EMP) WHERE SN = 2;

SELECT EMPNO, ENAME
  FROM (SELECT EMPNO, ENAME FROM EMP ORDER BY DBMS_RANDOM.VALUE())
 WHERE ROWNUM <= 3;

CREATE OR REPLACE VIEW V2 AS
  SELECT 'ABCDEF' AS VNAME
    FROM DUAL
  UNION ALL
  SELECT '_BCEFG' AS VNAME
    FROM DUAL
  UNION ALL
  SELECT '_BCDEF' AS VNAME
    FROM DUAL
  UNION ALL
  SELECT '_\BCDEF' AS VNAME
    FROM DUAL
  UNION ALL
  SELECT 'XYCEG' AS VNAME
    FROM DUAL;

SELECT * FROM V2 WHERE VNAME LIKE '%CDE%';
SELECT * FROM V2 WHERE VNAME LIKE '_BCD%';
SELECT * FROM V2 WHERE VNAME LIKE '\_BCD%' ESCAPE '\';

SELECT * FROM V2 WHERE VNAME LIKE '_\\BCD%' ESCAPE '\';

SELECT EMPNO, ENAME, HIREDATE
  FROM EMP
 WHERE DEPTNO = 10
 ORDER BY HIREDATE ASC;
SELECT EMPNO, ENAME, HIREDATE FROM EMP WHERE DEPTNO = 10 ORDER BY 3 ASC;

SELECT EMPNO, DEPTNO, SAL, ENAME, JOB FROM EMP ORDER BY 2 ASC, 3 DESC;

SELECT LAST_NAME AS 名称,
       PHONE_NUMBER AS 号码,
       SALARY AS 工资,
       SUBSTR(PHONE_NUMBER, -4) AS 尾号
  FROM HR.EMPLOYEES
 WHERE ROWNUM <= 5
 ORDER BY 4;

SELECT TRANSLATE('ab 您好 bcadefg', 'abcdefg', '1234567') AS NEW_STR
  FROM DUAL;

CREATE OR REPLACE VIEW V3 AS
  SELECT EMPNO || ' ' || ENAME AS DATA FROM EMP;

SELECT * FROM V3;

SELECT DATA, TRANSLATE(DATA, '- 0123456789', '-') AS ENAME
  FROM V3
 ORDER BY 2;

SELECT ENAME, SAL, COMM, NVL(COMM, -1) ORDER_COL FROM EMP ORDER BY 4;

SELECT ENAME, SAL, COMM ORDER_COL FROM EMP ORDER BY 3 NULLS FIRST;
SELECT ENAME, SAL, COMM ORDER_COL FROM EMP ORDER BY 3 NULLS LAST;

SELECT EMPNO AS 编码,
       ENAME AS 姓名,
       CASE
         WHEN SAL >= 1000 AND SAL <= 2000 THEN
          1
         ELSE
          2
       END AS 级别,
       SAL AS 工资
  FROM EMP
 WHERE DEPTNO = 30
 ORDER BY 3, 4;


SELECT EMPNO AS 编码,
       ENAME AS 姓名,
       SAL AS 工资
  FROM EMP
 WHERE DEPTNO = 30
 ORDER BY CASE
         WHEN SAL >= 1000 AND SAL <= 2000 THEN
          1
         ELSE
          2
       END,3;
       
SELECT EMPNO AS 编码, ENAME AS 名称, NVL(MGR, DEPTNO) AS 上级编码
  FROM EMP
 WHERE EMPNO = 7788
UNION ALL
SELECT DEPTNO AS 编码, DNAME AS 名称, NULL AS 上级编码
  FROM DEPT
 WHERE DEPTNO = 10;

SELECT '' AS c1 FROM dual;

CREATE INDEX idx_emp_empno ON emp(empno);
CREATE INDEX idx_emp_ename ON emp(ename);

SELECT empno,ename FROM emp WHERE empno = 7788 OR ename = 'SCOTT';

SELECT EMPNO, ENAME
  FROM EMP
 WHERE EMPNO = 7788
UNION ALL
SELECT EMPNO, ENAME
  FROM EMP
 WHERE ENAME = 'SCOTT';


SELECT EMPNO, ENAME
  FROM EMP
 WHERE EMPNO = 7788
UNION
SELECT EMPNO, ENAME
  FROM EMP
 WHERE ENAME = 'SCOTT';
 
 
 ALTER SESSION SET "_b_tree_bitmap_plans" = FALSE;
 EXPLAIN PLAN FOR SELECT empno,ename FROM emp WHERE empno = 7788 OR ename = 'SCOTT';
 
 SELECT * FROM TABLE(dbms_xplan.display);
 
 
 SELECT empno,deptno FROM emp WHERE mgr = 7698 ORDER BY 1;
 SELECT empno,deptno FROM emp WHERE job = 'SALESMAN' ORDER BY 1;
 
 SELECT  deptno FROM emp WHERE  mgr = 7698  OR  job = 'SALESMAN';
 
SELECT empno,deptno FROM emp WHERE mgr = 7698
UNION
SELECT empno,deptno FROM emp WHERE job = 'SALESMAN'
