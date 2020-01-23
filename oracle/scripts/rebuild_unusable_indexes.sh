#Enviroment define.

if [ -f ~/.bash_profile ]; then
. ~/.bash_profile
fi

#following is excution part
sqlplus / as sysdba <<eof
declare
begin
  for i in (select index_name,owner from dba_indexes where status ='UNUSABLE' and owner not in ('ORDDATA','ORDSYS','DMSYS','APEX_030200','OUTLN','DBSNMP','SYSTEM','SYSMAN','SYS','CTXSYS','MDSYS','OLAPSYS','WMSYS','EXFSYS','LBACSYS','WKSYS','XDB','OWBSYS','FLOWS_FILES') and owner in (select username from dba_users where account_status='OPEN')and rownum <=500) loop
    execute immediate 'alter index '||i.owner||'.'||i.index_name||' rebuild online';
  end loop;
  for j in (select index_name,partition_name,index_owner from dba_ind_partitions where status ='UNUSABLE' and INDEX_OWNER  IN (select username from dba_users where account_status='OPEN') and index_owner not in ('ORDDATA','ORDSYS','DMSYS','APEX_030200','OUTLN','DBSNMP','SYSTEM','SYSMAN','SYS','CTXSYS','MDSYS','OLAPSYS','WMSYS','EXFSYS','LBACSYS','WKSYS','XDB','OWBSYS','FLOWS_FILES')  and rownum <=500) loop
    execute immediate 'alter index '||j.index_owner||'.'||j.index_name|| ' rebuild partition '||j.partition_name||' online';
  end loop;
end;
/
exit
eof
