select ename||' 的薪水是 '||sal||' 提成是 '||coalesce(comm,0) from emp;
select 'truncate table '||owner||'.'||table_name||';' as 清空表 from all_tables where owner ='SCOTT';

select 'select table_name from all_tables where owner =''SCOTT'';' from dual;

select ename as 姓名,
       case  when sal <= 2000 then '薪资低'
       when  sal >= 5000 then '薪资高'
       else '薪资中等'  end as 薪资水平
  from emp
 where deptno = 10;

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


SELECT * FROM emp  WHERE ROWNUM <= 2;
SELECT * FROM (SELECT ROWNUM AS SN, EMP.* FROM EMP) WHERE SN = 2;

SELECT empno,ename FROM (SELECT empno,ename FROM emp ORDER BY dbms_random.value()) WHERE ROWNUM <= 3;

CREATE OR REPLACE VIEW v2 AS
SELECT 'ABCDEF' AS vname FROM dual
UNION ALL
SELECT '_BCEFG' AS vname FROM dual
UNION ALL
SELECT '_BCDEF' AS vname FROM dual
UNION ALL
SELECT '_\BCDEF' AS vname FROM dual
UNION ALL
SELECT 'XYCEG' AS vname FROM dual;

SELECT * FROM v2 WHERE vname LIKE '%CDE%';
SELECT * FROM v2 WHERE vname LIKE '_BCD%';
SELECT * FROM v2 WHERE vname LIKE '\_BCD%' ESCAPE '\';

SELECT * FROM v2 WHERE vname LIKE '_\\BCD%' ESCAPE '\';

SELECT empno,ename,hiredate FROM emp WHERE deptno=10 ORDER BY hiredate ASC;
SELECT empno,ename,hiredate FROM emp WHERE deptno=10 ORDER BY 3 ASC;

SELECT empno,deptno,sal,ename,job FROM emp ORDER BY 2 ASC,3 DESC;


