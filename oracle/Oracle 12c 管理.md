# Oracle 12c 管理

## 1 PDB拔出/插入

```plsql
-- 拔出
alter pluggable database HCM unplug into '/u01/app/oracle/oradata/.../hcm.xml';
-- 插入
create pluggable database HCM using '/u01/app/oracle/oradata/.../hcm.xml';
```

## 2 CDB的文件

每个PDB有自己的一组表空间,包括SYSTEM和SYSAUX,UNDO(12.2可选),TEMP(可选).

PDB 共享UNDO,REDO以及控制文件和参数文件.

CDB有SYSTEM,SYSAUX,UNDO,TEMP,REDO.