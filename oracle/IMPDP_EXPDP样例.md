# IMPDP_EXPDP样例

exclude=index,STATISTICS,constraint,grant,job,SCHEDULE,TABLE:\" IN ('T1703_HISDATA_1M','T1705_HISDATA_1H')\" 

**AIX平台样例**

```plsql
expdp  sys/**** directory=DIR_EXP dumpfile=expdplm3_20180813_%U.dmp logfile=expdplm3_20180813.log schemas=lm3 exclude=statistics,table:\"IN \(\'AC96\'\)\"  parallel=4 cluster=N
```



```plsql
expdp  sys/ directory=DIR_EXP dumpfile=expdpac96_20180813_%U.dmp logfile=expdpac96_20180813.log tables=lm3.ac96 exclude=statistics parallel=4 cluster=N
```



```
expdp  sys/ directory=DIR_EXP dumpfile=expdpac96_20180813_%U.dmp logfile=expdpac96_20180813.log tables=lm3.ac96 exclude=statistics query='WHERE deptno=20' parallel=4 cluster=N
```



buffer=2000000  compress=YES FILE=u01/app/oracle/export/expdat.dmp LOG=u01/app/oracle/export/expdat.log Statistics=NONE triggers=N tables=CUSTOMER query="WHERE TO_DATE(LastUpdtTm,'ddmmyy') BETWEEN TO_DATE('040515','ddmmyy') AND TO_DATE('310815','ddmmyy')" 