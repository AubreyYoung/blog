# How to Drop a Datafile From a Tablespace (文档 ID 111316.1)

  

    
    
    
    
    PURPOSE
      This note explains how a datafile can be removed from a database.  
    
      Since there can be confusion as to how a datafile can be dropped because of 
      the ALTER DATABASE DATAFILE OFFLINE DROP command, this note explains the 
      steps needed to delete a datafile and, in contrast, when the OFFLINE DROP 
      command is used.
     
    
    SCOPE & APPLICATION
      There are two situations where people may want to 'remove' a datafile from a 
      tablespace:
    
      1.  You have just mistakenly added a file to a tablespace, or perhaps you 
          made the file much larger than intended and now want to remove it.
    
      2.  You are involved in a recovery scenario and the database will not start 
          because a datafile is missing.
    
      This article is meant to discuss situation 1 above.  There are other 
      articles that discuss recovery scenarios where a database cannot be brought 
      online due to missing datafiles.  Please see the 'Related Documents' section 
      at the bottom of this article.
    
    Restrictions on Dropping Datafiles:
    
     - Datafile Must be empty.
     - Cannot be the first file in the tablespace. In such cases, drop the tablespace instead.
     - Cannot be a datafile that is part of the system tablespace, even if it is not the first datafile of the system tablespace.
     - Cannot be in a read-only tablespace.
     - The datafile cannot be offline.
    
    
    
    
    How to 'DROP' a Datafile from a Tablespace:
    ===========================================
    
    Version 9.2 and earlier
    
    Before we start with detailed explanations of the process involved, please note
    that Oracle does not provide an interface for dropping datafiles in the same 
    way that you could drop a schema object such as a table, a view, a user, etc.  
    Once you make a datafile part of a tablespace, the datafile CANNOT be removed, 
    although we can use some workarounds.
     
    Before performing certain operations such as taking tablespaces/datafiles 
    offline, and trying to drop them, ensure you have a full backup.
    
    If the datafile you wish to remove is the only datafile in that tablespace, 
    simply drop the entire tablespace using:
    
        DROP TABLESPACE  INCLUDING CONTENTS;
    
    You can confirm how many datafiles make up a tablespace by running the 
    following query:
    
        select file_name, tablespace_name 
        from dba_data_files 
        where tablespace_name ='';
    
    The DROP TABLESPACE command removes the tablespace, the datafile, and the 
    tablespace's contents from the data dictionary.  Oracle will no longer have 
    access to ANY object that was contained in this tablespace.  The physical 
    datafile must then be removed using an operating system command (Oracle NEVER 
    physically removes any datafiles).  Depending on which platform you try this 
    on, you may not be able to physically delete the datafile until Oracle is 
    completely shut down. (For example, on Windows NT, you may have to shutdown 
    Oracle AND stop the associated service before the operating system will allow 
    you to delete the file - in some cases, file locks are still held by Oracle.) 
    
    If you have more than one datafile in the tablespace, and you do NOT need the 
    information contained in that tablespace, or if you can easily recreate the 
    information in this tablespace, then use the same command as above:
    
        DROP TABLESPACE  INCLUDING CONTENTS;
    
    Again, this will remove the tablespace, the datafiles, and the tablespace's 
    contents from the data dictionary.  Oracle will no longer have access to ANY 
    object that was contained in this tablespace.  You can then use CREATE 
    TABLESPACE and re-import the appropriate objects back into the tablespace.
    
    If you have more than one datafile in the tablespace and you wish to keep the 
    objects that reside in the other datafile(s) which are part of this tablespace,
    then you must export all the objects  inside the affected tablespace.  Gather 
    information on the current datafiles within the tablespace by running this 
    query:
    
        select file_name, tablespace_name 
        from dba_data_files 
        where tablespace_name ='';
    
    Make sure you specify the tablespace name in capital letters.
    
    In order to allow you to identify which objects are inside the affected 
    tablespace for the purposes of running your export, use the following query:
    
        select owner,segment_name,segment_type 
        from dba_segments 
        where tablespace_name=''
    
    Now, export all the objects that you wish to keep.
    
    Once the export is done, issue the DROP TABLESPACE tablespace INCLUDING 
    CONTENTS.  
    
    Note that this PERMANENTLY removes all objects in this tablespace. Delete the 
    datafiles belonging to this tablespace using the operating system. (See the 
    comment above about possible problems in doing this.) Recreate the tablespace 
    with the datafile(s) desired, then import the objects into that tablespace.  
    (This may have to be done at the table level, depending on how the tablespace 
    was organized.)  
    
    NOTE:
    The ALTER DATABASE DATAFILE  OFFLINE DROP command, is not meant 
    to allow you to remove a datafile. What the command really means is that you 
    are offlining the datafile with the intention of dropping the tablespace.
    
    If you are running in archivelog mode, you can also use:
    
        ALTER DATABASE DATAFILE  OFFLINE; 
    
    instead of OFFLINE DROP.  Once the datafile is offline, Oracle no longer 
    attempts to access it, but it is still considered part of that tablespace. This
    datafile is marked only as offline in the controlfile and there is no SCN 
    comparison done between the controlfile and the datafile during startup (This 
    also allows you to startup a database with a non-critical datafile missing).  
    The entry for that datafile is not deleted from the controlfile to give us the
    opportunity to recover that datafile.
    
    New functionality was added with the release of version 10.1 and higher
    
    You can now specify drop tablespace inlcluding contents AND DATAFILES
    Refer to Oracle® Database Administrator's Guide 10g Release 1 (10.1) Part Number B10739-01
    Chapter 8 managing tablespaces for more detailed explination
    
    
    Starting with version 10.2 and higher 
    
    You can now alter tablespace drop datafile (except first datafile
    of a tablespace)
    
    Refer to the following Oracle Documentation for more details regarding this operation:
    
    For Oracle 10g Release 2:
         Oracle® Database Administrator's Guide 10g Release 2 (10.2)Part Number B14231-02 Chapter 9: Dropping Datafiles.
    
    For Oracle 11g:
         Oracle® Database Administrator's Guide 11g Release 1 (11.1) Part Number B28310-04 Chapter 12:  Dropping Datafiles.
    
    If you do not wish to follow any of these procedures, there are other things 
    that can be done besides dropping the tablespace.
    
    - If the reason you wanted to drop the file is because you mistakenly created 
      the file of the wrong size, then consider using the RESIZE command.  
      See 'Related Documents' below.
    
    - If you really added the datafile by mistake, and Oracle has not yet allocated
      any space within this datafile, then you can use ALTER DATABASE DATAFILE 
       RESIZE; command to make the file smaller than 5 Oracle blocks. If 
      the datafile is resized to smaller than 5 oracle blocks, then it will never 
      be considered for extent allocation. At some later date, the tablespace can 
      be rebuilt to exclude the incorrect datafile.
    
    
    RELATED DOCUMENTS
    -----------------
    
    [Note 30910.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=111316.1&id=30910.1) -  Recreating database objects
    [Note 1013221.6](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=111316.1&id=1013221.6) - Recovering from a lost datafile in a ROLLBACK tablespace
    [Note 198640.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=111316.1&id=198640.1) - How to Recover from a Lost Datafile with Different Scenarios
    [Note 1060605.6](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=111316.1&id=1060605.6) - Recover A Lost Datafile With No Backup
    [Note 1029252.6](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=111316.1&id=1029252.6) - How to resize a datafile
    
    
      
  
---  
  
  



---
### TAGS
{tablespace}  {datafile}

---
### NOTE ATTRIBUTES
>Created Date: 2017-06-27 08:57:06  
>Last Evernote Update Date: 2018-10-01 15:59:05  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/SearchDocDisplay?_adf.ctrl-state=1aujci0hbj_9  
>source-url: &  
>source-url: _afrLoop=85910198025291  