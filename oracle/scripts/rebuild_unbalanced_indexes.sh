# +--------------------------------------------------------------------------+
# +    Rebulid unbalanced indexes                                              |
# +    Author : Aubrey                                                      | 
# +    Parameter : No                                                        |
# +    Copyright (c) 2019-2020. Inspur All rights reserved.                  | 
# +--------------------------------------------------------------------------+
 
#!/bin/bash 
# --------------------
# Define variable
# --------------------
 
if [ -f ~/.bash_profile ]; then
. ~/.bash_profile
fi
 
DT=`date +%Y%m%d`;             export DT
RETENTION=7
LOG_DIR=/tmp
LOG=${LOG_DIR}/rebuild_unbalanced_indexes_${DT}.log
DBA=sr@inspur.com
 
# ------------------------------------
# Loop all instance in current server
# -------------------------------------
echo "Current date and time is : `/bin/date`">>${LOG}
 
for db in `ps -ef | grep pmon | grep -v grep |grep -v asm |awk '{print $8}'|cut -c 10-`
do
    echo "$db"
    export ORACLE_SID=$db
    echo "Current DB is $db" >>${LOG}
    echo "===============================================">>${LOG}
    $ORACLE_HOME/bin/sqlplus -S /nolog @/home/oracle/rebuild_unbalanced_indexes.sql>>${LOG}
done;
 
echo "End of rebuilding index for all instance at : `/bin/date`">>${LOG}
# -------------------------------------
# Check log file 
# -------------------------------------
status=`grep "ORA-" ${LOG}`
if [ -z $status ];then
    mail -s "Succeeded rebuilding indexes on `hostname`  !!!" ${DBA} <${LOG}
else
    mail -s "Failed rebuilding indexes on `hostname`  !!!" ${DBA} <${LOG}
fi
 
# ------------------------------------------------
# Removing files older than $RETENTION parameter 
# ------------------------------------------------
 
find ${LOG_DIR} -name "rebuild_unbalanced_indexes*" -mtime +$RETENTION -exec rm {} \;
 
exit
 
