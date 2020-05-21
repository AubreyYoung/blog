# IMPDP/EXPDP样例

## 1. 导出导入dblink

```sh
# 只导出导入dblink
# 整个库的dblink
expdp dumpfile=dblink.dmp directory=test full=y include=db_link userid=\"/ as sysdba\"

# 只导出导入某些schema dblink
expdp dumpfile=dblink.dmp directory=test schemas=user1,... include=db_link userid=\"/ as sysdba\"

# 导出公共dblink
expdp dumpfile=dblink.dmp directory=test full=y include=db_link:"IN (select db_link from dba_db_links where owner='PUBLIC')" userid=\"/ as sysdba\"
```

