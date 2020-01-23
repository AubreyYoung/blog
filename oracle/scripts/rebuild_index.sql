-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/miscellaneous/rebuild_index.sql
-- Author       : Tim Hall
-- Description  : Rebuilds the specified index, or all indexes.
-- Call Syntax  : @rebuild_index (index-name or all) (schema-name)
-- Last Modified: 28/01/2001
-- -----------------------------------------------------------------------------------
SET PAGESIZE 0
SET FEEDBACK OFF
SET VERIFY OFF

SPOOL temp.sql

SELECT 'ALTER INDEX ' || a.index_name || ' REBUILD;'
FROM   all_indexes a
WHERE  status = 'UNUSABLE'
AND table_owner NOT IN ('ORDDATA','ORDSYS','DMSYS','APEX_030200','OUTLN','DBSNMP','SYSTEM','SYSMAN','SYS','CTXSYS','MDSYS','OLAPSYS','WMSYS','EXFSYS','LBACSYS','WKSYS','XDB','SQLTXPLAIN','OWBSYS','FLOWS_FILES')
AND owner IN (SELECT username FROM dba_users WHERE account_status='OPEN')
ORDER BY 1
/

SPOOL OFF

-- Comment out following line to prevent immediate run
@temp.sql

SET PAGESIZE 14
SET FEEDBACK ON
SET VERIFY ON
