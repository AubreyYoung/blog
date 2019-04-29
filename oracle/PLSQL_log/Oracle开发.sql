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

SELECT EMPNO AS 编码, ENAME AS 姓名, SAL AS 工资
  FROM EMP
 WHERE DEPTNO = 30
 ORDER BY CASE
            WHEN SAL >= 1000 AND SAL <= 2000 THEN
             1
            ELSE
             2
          END,
          3;

SELECT EMPNO AS 编码, ENAME AS 名称, NVL(MGR, DEPTNO) AS 上级编码
  FROM EMP
 WHERE EMPNO = 7788
UNION ALL
SELECT DEPTNO AS 编码, DNAME AS 名称, NULL AS 上级编码
  FROM DEPT
 WHERE DEPTNO = 10;

SELECT '' AS C1 FROM DUAL;

CREATE INDEX IDX_EMP_EMPNO ON EMP(EMPNO);
CREATE INDEX IDX_EMP_ENAME ON EMP(ENAME);

SELECT EMPNO, ENAME
  FROM EMP
 WHERE EMPNO = 7788
    OR ENAME = 'SCOTT';

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
EXPLAIN PLAN FOR
  SELECT EMPNO, ENAME
    FROM EMP
   WHERE EMPNO = 7788
      OR ENAME = 'SCOTT';

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

SELECT EMPNO, DEPTNO FROM EMP WHERE MGR = 7698 ORDER BY 1;
SELECT EMPNO, DEPTNO FROM EMP WHERE JOB = 'SALESMAN' ORDER BY 1;

SELECT DEPTNO
  FROM EMP
 WHERE MGR = 7698
    OR JOB = 'SALESMAN';

SELECT EMPNO, DEPTNO
  FROM EMP
 WHERE MGR = 7698
UNION
SELECT EMPNO, DEPTNO
  FROM EMP
 WHERE JOB = 'SALESMAN';

SELECT E.EMPNO, E.ENAME, D.DNAME, D.LOC
  FROM EMP E
 INNER JOIN DEPT D
    ON (E.DEPTNO = D.DEPTNO)
 WHERE E.DEPTNO = 10;

SELECT E.EMPNO, E.ENAME, D.DNAME, D.LOC
  FROM EMP E, DEPT D
 WHERE E.DEPTNO = D.DEPTNO
   AND E.DEPTNO = 10;

CREATE TABLE EMP2 AS
  SELECT ENAME, JOB, SAL, COMM FROM EMP WHERE JOB = 'CLERK';

EXPLAIN PLAN FOR
  SELECT EMPNO, ENAME, JOB, SAL, DEPTNO
    FROM EMP
   WHERE (EMPNO, JOB, SAL) IN (SELECT EMPNO, JOB, SAL FROM EMP2);

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY());

CREATE TABLE EMP3 AS
  SELECT ENAME, JOB, SAL, COMM FROM EMP WHERE JOB = 'CLERK';

SELECT * FROM EMP3;

SELECT EMPNO, ENAME, JOB, SAL, DEPTNO
  FROM EMP
 WHERE (ENAME, JOB, SAL) IN (SELECT ENAME, JOB, SAL FROM EMP3);

EXPLAIN PLAN FOR
  SELECT EMPNO, ENAME, JOB, SAL, DEPTNO
    FROM EMP
   WHERE (ENAME, JOB, SAL) IN (SELECT ENAME, JOB, SAL FROM EMP3);

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

SELECT EMPNO, ENAME, JOB, SAL, DEPTNO
  FROM EMP A
 WHERE EXISTS (SELECT NULL
          FROM EMP3 B
         WHERE B.ENAME = A.ENAME
           AND B.JOB = A.JOB
           AND B.SAL = A.SAL);
EXPLAIN PLAN FOR
  SELECT A.EMPNO, A.ENAME, A.JOB, A.SAL, A.DEPTNO
    FROM EMP A
   WHERE INNER JOIN EMP3 B
      ON (B.ENAME = A.ENAME AND B.JOB = A.JOB AND B.SAL = A.SAL);

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

EXPLAIN PLAN FOR
  SELECT EMPNO, ENAME, JOB, SAL, DEPTNO
    FROM EMP A
   WHERE EXISTS (SELECT NULL
            FROM EMP3 B
           WHERE B.ENAME = A.ENAME
             AND B.JOB = A.JOB
             AND B.SAL = A.SAL);

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

EXPLAIN PLAN FOR
  SELECT A.EMPNO, A.ENAME, A.JOB, A.SAL, A.DEPTNO
    FROM EMP A
   INNER JOIN EMP3 B
      ON (B.ENAME = A.ENAME AND B.JOB = A.JOB AND B.SAL = A.SAL);

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

DROP TABLE L PURGE;
DROP TABLE R PURGE;
/*左表*/
CREATE TABLE L AS
  SELECT 'left_1' AS STR, '1' AS VIEW
    FROM DUAL
  UNION ALL
  SELECT 'left_2' AS STR, '2' AS V
    FROM DUAL
  UNION ALL
  SELECT 'left_3' AS STR, '3' AS V
    FROM DUAL
  UNION ALL
  SELECT 'left_4' AS STR, '4' AS V
    FROM DUAL;
/*右表*/
CREATE TABLE R AS
  SELECT 'right_3' AS STR, '3' AS V
    FROM DUAL
  UNION ALL
  SELECT 'right_4' AS STR, '4' AS V
    FROM DUAL
  UNION ALL
  SELECT 'right_5' AS STR, '5' AS V
    FROM DUAL
  UNION ALL
  SELECT 'right_6' AS STR, '6' AS V
    FROM DUAL;
/*INNER JOIN*/
SELECT L.STR AS LIFT_STR, R.STR AS RIGHT_STR
  FROM L
 INNER JOIN R
    ON L.V = R.V
 ORDER BY 1, 2;
/*WHERE*/
SELECT L.STR AS LIFT_STR, R.STR AS RIGHT_STR
  FROM L, R
 WHERE L.V = R.V
 ORDER BY 1, 2;
/*LEFT JOIN*/
SELECT L.STR AS LIFT_STR, R.STR AS RIGHT_STR
  FROM L
  LEFT JOIN R
    ON L.V = R.V
 ORDER BY 1, 2;
/*+*/
SELECT L.STR AS LIFT_STR, R.STR AS RIGHT_STR
  FROM L, R
 WHERE L.V = R.V(+)
 ORDER BY 1, 2;

/*RIGHT JOIN*/
SELECT L.STR AS LIFT_STR, R.STR AS RIGHT_STR
  FROM L
 RIGHT JOIN R
    ON L.V = R.V
 ORDER BY 1, 2;
/*+*/
SELECT L.STR AS LIFT_STR, R.STR AS RIGHT_STR
  FROM L, R
 WHERE L.V(+) = R.V
 ORDER BY 1, 2;
/*FULL JOIN*/
SELECT L.STR AS LIFT_STR, R.STR AS RIGHT_STR
  FROM L
  FULL JOIN R
    ON L.V = R.V
 ORDER BY 1, 2;

/*自关联*/
SELECT 员工.EMPNO AS 职工编码,
       员工.ENAME AS 职工姓名,
       员工.JOB   AS 工作,
       员工.MGR   AS 员工表_主管编码,
       主管.EMPNO AS 主管表_主管编码,
       主管.ENAME AS 主管姓名
  FROM EMP 员工
  LEFT JOIN EMP 主管
    ON (员工.MGR = 主管.EMPNO)
 ORDER BY 1;
/*视图*/
CREATE OR REPLACE VIEW 员工 AS
  SELECT * FROM EMP;
CREATE OR REPLACE VIEW 主管 AS
  SELECT * FROM EMP;
SELECT 员工.EMPNO AS 职工编码,
       员工.ENAME AS 职工姓名,
       员工.JOB   AS 工作,
       员工.MGR   AS 员工表_主管编码,
       主管.EMPNO AS 主管表_主管编码,
       主管.ENAME AS 主管姓名
  FROM 员工
  LEFT JOIN 主管
    ON (员工.MGR = 主管.EMPNO)
 ORDER BY 1;

SELECT COUNT(*) FROM EMP GROUP BY DEPTNO;
SELECT COUNT(*) FROM EMP WHERE DEPTNO = 40;

ALTER TABLE DEPT ADD CONSTRAINTS PK_DEPT PRIMARY KEY(DEPTNO);

/*NOT IN*/
SELECT *
  FROM DEPT
 WHERE DEPTNO NOT IN
       (SELECT EMP.DEPTNO FROM EMP WHERE EMP.DEPTNO IS NOT NULL);

EXPLAIN PLAN FOR
  SELECT *
    FROM DEPT
   WHERE DEPTNO NOT IN
         (SELECT EMP.DEPTNO FROM EMP WHERE EMP.DEPTNO IS NOT NULL);
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

/*NOT EXISTS*/
EXPLAIN PLAN FOR
  SELECT *
    FROM DEPT
   WHERE NOT EXISTS (SELECT NULL FROM EMP WHERE EMP.DEPTNO = DEPT.DEPTNO);
   
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

/*LEFT JOIN*/
EXPLAIN PLAN FOR
  SELECT DEPT.*
    FROM DEPT
    LEFT JOIN EMP
      ON EMP.DEPTNO = DEPT.DEPTNO
   WHERE EMP.EMPNO IS NULL;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
