conn / as sysdba
set serveroutput on;
DECLARE
   resource_busy               EXCEPTION;
   PRAGMA EXCEPTION_INIT (resource_busy, -54);
   c_max_trial        CONSTANT PLS_INTEGER := 10;
   c_trial_interval   CONSTANT PLS_INTEGER := 1;
   pmaxheight         CONSTANT INTEGER := 3;
   pmaxleafsdeleted   CONSTANT INTEGER := 20;
 
   CURSOR csrindexstats
   IS
      SELECT NAME,
             height,
             lf_rows AS leafrows,
             del_lf_rows AS leafrowsdeleted
        FROM index_stats;
 
   vindexstats                 csrindexstats%ROWTYPE;
 
   CURSOR csrglobalindexes
   IS
      SELECT owner,index_name, tablespace_name
        FROM dba_indexes
       WHERE partitioned = 'NO' AND owner NOT IN ('ORDDATA','ORDSYS','DMSYS','APEX_030200','OUTLN','DBSNMP','SYSTEM','SYSMAN','SYS','CTXSYS','MDSYS','OLAPSYS','WMSYS','EXFSYS','LBACSYS','WKSYS','XDB','SQLTXPLAIN','OWBSYS','FLOWS_FILES');
 
   CURSOR csrlocalindexes
   IS
      SELECT index_owner,index_name, partition_name, tablespace_name
        FROM dba_ind_partitions
       WHERE index_owner NOT IN ('ORDDATA','ORDSYS','DMSYS','APEX_030200','OUTLN','DBSNMP','SYSTEM','SYSMAN','SYS','CTXSYS','MDSYS','OLAPSYS','WMSYS','EXFSYS','LBACSYS','WKSYS','XDB','SQLTXPLAIN','OWBSYS','FLOWS_FILES');
 
   trial                       PLS_INTEGER;
   vcount                      INTEGER := 0;
BEGIN
   trial := 0;
 
   /* Global indexes */
   FOR vindexrec IN csrglobalindexes
   LOOP
      EXECUTE IMMEDIATE
         'analyze index ' || vindexrec.owner ||'.'|| vindexrec.index_name || ' validate structure';
 
      OPEN csrindexstats;
 
      FETCH csrindexstats INTO vindexstats;
 
      IF csrindexstats%FOUND
      THEN
         IF    (vindexstats.height > pmaxheight)
            OR (    vindexstats.leafrows > 0
                AND vindexstats.leafrowsdeleted > 0
                AND (vindexstats.leafrowsdeleted * 100 / vindexstats.leafrows) >
                       pmaxleafsdeleted)
         THEN
            vcount := vcount + 1;
            DBMS_OUTPUT.PUT_LINE (
               'Rebuilding index ' || vindexrec.owner ||'.'|| vindexrec.index_name || '...');
 
           <<alter_index>>
            BEGIN
               EXECUTE IMMEDIATE
                     'alter index '
                  || vindexrec.owner ||'.'
                  || vindexrec.index_name
                  || ' rebuild'
                  || ' parallel nologging compute statistics'
                  || ' tablespace '
                  || vindexrec.tablespace_name;
            EXCEPTION
               WHEN resource_busy OR TIMEOUT_ON_RESOURCE
               THEN
                  DBMS_OUTPUT.PUT_LINE (
                     'alter index - busy and wait for 1 sec');
                  DBMS_LOCK.sleep (c_trial_interval);
                  IF trial <= c_max_trial
                  THEN
                     GOTO alter_index;
                  ELSE
                     DBMS_OUTPUT.PUT_LINE (
                           'alter index busy and waited - quit after '
                        || TO_CHAR (c_max_trial)
                        || ' trials');
                     RAISE;
                  END IF;
               WHEN OTHERS
               THEN
                  DBMS_OUTPUT.PUT_LINE ('alter index err ' || SQLERRM);
                  RAISE;
            END;
         END IF;
      END IF;
      CLOSE csrindexstats;
   END LOOP;
   DBMS_OUTPUT.PUT_LINE ('Global indexes rebuilt: ' || TO_CHAR (vcount));
   vcount := 0;
   trial := 0;
   /* Local indexes */
   FOR vindexrec IN csrlocalindexes
   LOOP
      EXECUTE IMMEDIATE
            'analyze index '
         || vindexrec.index_owner||'.'
         || vindexrec.index_name
         || ' partition ('
         || vindexrec.partition_name
         || ') validate structure';
      OPEN csrindexstats;
      FETCH csrindexstats INTO vindexstats;
      IF csrindexstats%FOUND
      THEN
         IF    (vindexstats.height > pmaxheight)
            OR (    vindexstats.leafrows > 0
                AND vindexstats.leafrowsdeleted > 0
                AND (vindexstats.leafrowsdeleted * 100 / vindexstats.leafrows) >
                       pmaxleafsdeleted)
         THEN
            vcount := vcount + 1;
            DBMS_OUTPUT.PUT_LINE (
               'Rebuilding index ' || vindexrec.index_owner||'.'|| vindexrec.index_name || '...');
           <<alter_partitioned_index>>
            BEGIN
               EXECUTE IMMEDIATE
                     'alter index '
                  || vindexrec.index_owner||'.'
                  || vindexrec.index_name
                  || ' rebuild'
                  || ' partition '
                  || vindexrec.partition_name
                  || ' parallel nologging compute statistics'
                  || ' tablespace '
                  || vindexrec.tablespace_name;
            EXCEPTION
               WHEN resource_busy OR TIMEOUT_ON_RESOURCE
               THEN
                  DBMS_OUTPUT.PUT_LINE (
                     'alter partitioned index - busy and wait for 1 sec');
                  DBMS_LOCK.sleep (c_trial_interval);
                  IF trial <= c_max_trial
                  THEN
                     GOTO alter_partitioned_index;
                  ELSE
                     DBMS_OUTPUT.PUT_LINE (
                           'alter partitioned index busy and waited - quit after '
                        || TO_CHAR (c_max_trial)
                        || ' trials');
                     RAISE;
                  END IF;
               WHEN OTHERS
               THEN
                  DBMS_OUTPUT.PUT_LINE (
                     'alter partitioned index err ' || SQLERRM);
                  RAISE;
            END;
         END IF;
      END IF;
      CLOSE csrindexstats;
   END LOOP;
   DBMS_OUTPUT.PUT_LINE ('Local indexes rebuilt: ' || TO_CHAR (vcount));
END;
/
exit;
