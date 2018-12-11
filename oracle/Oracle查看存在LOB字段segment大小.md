## Oracle查看存在LOB字段segment大小

```plsql
col "TOTAL TABLE SIZE" format 99999999999999  
SELECT  
 (SELECT NVL(SUM(S.BYTES),0)                                                                                               -- The Table Segment size  
   FROM DBA_SEGMENTS S  
   WHERE S.OWNER = UPPER('LM3') AND  
        (S.SEGMENT_NAME = UPPER('AC96'))) +  
  (SELECT NVL(SUM(S.BYTES),0)                                                                                               -- The Lob Segment Size  
   FROM DBA_SEGMENTS S, DBA_LOBS L  
   WHERE S.OWNER = UPPER('LM3') AND  
        (L.SEGMENT_NAME = S.SEGMENT_NAME AND L.TABLE_NAME = UPPER('AC96') AND L.OWNER = UPPER('LM3'))) +  
  (SELECT NVL(SUM(S.BYTES),0)                                                                                               -- The Lob Index size  
   FROM DBA_SEGMENTS S, DBA_INDEXES I  
   WHERE S.OWNER = UPPER('LM3') AND  
        (I.INDEX_NAME = S.SEGMENT_NAME AND I.TABLE_NAME = UPPER('AC96') AND INDEX_TYPE = 'LOB' AND I.OWNER = UPPER('LM3')))  
   "TOTAL TABLE SIZE"  
 FROM DUAL; 
```