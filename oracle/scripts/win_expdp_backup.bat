expdp bes/ec0801#SD@10.225.11.110/orcl directory=BES_BACKUP dumpfile=bes_%date:~0,4%-%date:~5,2%-%date:~8,2%.dmp logfile=bes_%date:~0,4%-%date:~5,2%-%date:~8,2%.txt
cd E:\bes_backup
E:
zip bes_%date:~0,4%-%date:~5,2%-%date:~8,2%.zip BES_%date:~0,4%-%date:~5,2%-%date:~8,2%.dmp
zip bes_%date:~0,4%-%date:~5,2%-%date:~8,2%.zip bes_%date:~0,4%-%date:~5,2%-%date:~8,2%.txt
del BES_%date:~0,4%-%date:~5,2%-%date:~8,2%.dmp
del bes_%date:~0,4%-%date:~5,2%-%date:~8,2%.txt