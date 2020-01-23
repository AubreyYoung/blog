if [ "$LOGNAME" = "oracle" ]; then
   SQLPLUS_CMD="/ as sysdba";
else
   SQLPLUS_CMD="/ as sysdba";
fi

case $1 in
   racstat)
     if [ "$LOGNAME" = "oracle" ]; then
        /opt/oracrs/product/11gR2/grid/bin/crsctl stat res -t
     else
        /opt/oracrs/product/11gR2/grid/bin/crsctl stat res -t
     fi
     ;;
   listenerstat)
        srvctl status listener -l LISTENER
     ;;
   diskgroup)
        sqlplus -s "$SQLPLUS_CMD" << EOF
	        set pagesize 100
		set linesize 180
		col name format a15
		select GROUP_NUMBER,NAME,STATE,TYPE,TOTAL_MB,FREE_MB,USABLE_FILE_MB from v\$asm_diskgroup;
        	exit
EOF
     ;;
	tablespace)
     sqlplus -s "$SQLPLUS_CMD" << EOF
		set linesize 150 pagesize 500
		select f.tablespace_name tablespace_name,
		round((d.sumbytes/1024/1024/1024),2) total_without_extend_GB,
		round(((d.sumbytes+d.extend_bytes)/1024/1024/1024),2) total_with_extend_GB,
		round((f.sumbytes+d.Extend_bytes)/1024/1024/1024,2) free_with_extend_GB,
		round((d.sumbytes-f.sumbytes)/1024/1024/1024,2) used_GB,
		round((d.sumbytes-f.sumbytes)*100/(d.sumbytes+d.extend_bytes),2) used_percent_with_extend
		from (select tablespace_name,sum(bytes) sumbytes from dba_free_space group by tablespace_name) f,
		(select tablespace_name,sum(aa.bytes) sumbytes,sum(aa.extend_bytes) extend_bytes from
		(select  nvl(case  when autoextensible ='YES' then (case when (maxbytes-bytes)>=0 then (maxbytes-bytes) end) end,0) Extend_bytes
		,tablespace_name,bytes  from dba_data_files) aa group by tablespace_name) d
		where  (regexp_substr(f.TABLESPACE_NAME,'\d{6}')>to_char(trunc(sysdate-30),'yymmdd') or  (instr(f.TABLESPACE_NAME,'_DAT_')<= 0 and  instr(f.TABLESPACE_NAME,'_IDX_')<=0))
		and round((d.sumbytes-f.sumbytes)*100/(d.sumbytes+d.extend_bytes),2)>80
		and f.tablespace_name= d.tablespace_name
		order by  used_percent_with_extend desc;
        exit
EOF
     ;;
	session)
		sqlplus -s "$SQLPLUS_CMD" << EOF
			set linesize 150
			col name format a10
			col value format a10
			select inst_id, sessions_current,sessions_highwater from  gv\$license;
			exit
EOF
     ;;
   process)
		sqlplus -s "$SQLPLUS_CMD" << EOF
			set linesize 150
			col name format a10
			col value format a10
			select name,value from v\$parameter where name='processes';
			exit
EOF
     ;;
   db_files)
		sqlplus -s "$SQLPLUS_CMD" << EOF
			set echo on
			Set pagesize 300
			Set linesize 300
			col file_name format a60
			show parameter db_files
			select (select count(*) from dba_data_files)+(select count(*) from dba_temp_files)+(select count(*) from v\$logfile) datafiles from dual;
			exit
EOF
     ;;
   sequence)
         sqlplus -s "$SQLPLUS_CMD" << EOF
			set line 500
			col sequence_owner for a30
			set numw 20
			col sequence_name for a30
			select t.sequence_owner,
			t.sequence_name,
			t.min_value,
			t.max_value,
			t.last_number,
			t.increment_by,
			t.cycle_flag,
			t.order_flag,
			t.cache_size
			from dba_sequences t
			where t.sequence_owner in ('PM4H_MO', 'PM4H_AD', 'PM4H_DB', 'PM4H_HW');
			exit
EOF
;;

   *)
     echo
     echo "Usage:";
     echo "  ora keyword ";
     echo "  -----------------------------------------------------------------";
     echo "  racstat                     -- List RAC Status";
     echo "  listenerstat                -- List listener status";
     echo "  diskgroup                   -- Get diskgroup status";
     echo "  tablespace                  -- Tablespace Information";
     echo "  session                     -- List session Information";
     echo "  process                     -- Get process of value";
     echo "  db_files                    -- Get data files Information";
     echo "  sequence                    -- Get sequenceInformation";
     echo "  ----------------------------------------------------------------";
     echo
     ;;
esac

