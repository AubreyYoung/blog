#!/bin/bash
export LOG_FILE=orcl_`date +%Y%m%d`.log
export ORACLE_SID=orcl1
export ORACLE_HOME=/u01/app/oracle/product/11.2.0.4/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
expdp 'userid="/ as sysdba"' directory=expdp_bak  dumpfile=orcl_`date +%Y%m%d`_%U.dmp full=y cluster=no EXCLUDE=STATISTICS   logfile=$LOG_FILE parallel=4
find /rmanbak/odaracdata/expdp_bak/orcl/ -name "*.dmp" -mtime +3 -exec rm {} \;
