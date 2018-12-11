# How to use OS Commands to Diagnose Database Performance Issues? (文档 ID
224176.1)

  

|

|

    
    
    
    
    
     
    
    NOTE: This document is provided as legacy information from the Oracle 8i-9i Timeframe. 
    Although commands in this document may still function, you are recommended to use articles designed specifically for later versions (if available). 
    
     
    
    
    PURPOSE
    -------
    
     The purpose of this document is to provide a few OS commands for UNIX
     operating systems to gather information about Physical Memory (RAM), 
     swap memory,CPU usage and idle percentage, whether lots of processes
     are in the process run queue and whether too much paging and swapping 
     going on in the server or not so that we can use the information along
     with Statspack report to help diagnose the Database Performance issues.
    
     Sometimes, the information gathered using these commands will be helpful
     in finding the most OS resource consuming database or non-database 
     processes and will help in identifying the processes to further 
     investigations about why the processes are consuming so much resources and
     whether the corresponding query or application needs to be tuned. 
     
    SCOPE & APPLICATION
    -------------------
    
     This document can be used by anyone with moderate expertise to run UNIX
     OS commands in various operating systems like Solaris, HP-UX, AIX, TRU64,
     Linux, etc. The commands will help us collect OS related information
     to verify whether overuse of any of the OS resources can be affecting 
     the database performance or not. This document does not deal with OS 
     Kernel tuning.
    
    How to use OS commands to diagnose Database Performance issues?
    ----------------------------------------------------------------
    
     You want to gather data for Physical memory, Swap space, CPU % usage
     and idle, IO usage in the server in general and also to find a few most
     OS resouce consuming processes to get better understanding about 
     how the UNIX server is performing and whether any of these resources
     are causing a bottleck in the database performance or not.
    
     Since the popular UNIX systems do not support the same commands or even
     same options for a command, we are proving different commands for different
     OS in the following section. Please refer to the corresponding OS man pages
     for detailed information about each UNIX command mentioned in this document.
    
     Solaris:
     =========
    
     $ /usr/sbin/prtconf |grep -i "Memory size"
     $ swap -s
     $ df -k
     $ /usr/local/bin/top
     $ vmstat 5 100
     $ sar -u 2 100
     $ iostat -D 2 100
     $ mpstat 5 100
    
     Out of these commands, top command  may not be installed in your server by default.
     In that case,you can get it for free from www.sunfreeware.com and install it preferably
     under /usr/local/bin directory and then use it. Please take a few snpshots of the 
     top command output and store it in a file.It refreshes the output screen every 5 sec.
     
     Prtconf command will show how much Physical Memory (RAM) the Solaris server has.
     
     Swap command will provide us with the usage of swap space including the RAM.
     
     Df command will indicate how much space is free in each mount point and also
     provides information about swap space(s).
    
     Top command wil provide the above information plus information about top CPU
     consuming processes, CPU usage in the system, etc.
     
     Vmstat will provide information about process run queue, memory usage,
     paging and swapping and CPU % usage in the server. Different options in vmstat
     can provide more specific information, if required.
    
     Iostat provides IO usage by Disk, CPU % usage, etc. depending on the options
     used. Sar command with "-u" option also provides CPU usage and idle time
     information.
    
     Mpstat will provide CPU usage stats for a Solaris server with  1 or more CPUs.
     This command is very useful for multi-processor system to provide details about
     the CPU usage by every CPU in the server.
    
     For example: 
    
     $ man vmstat
    
     Here is some sample output from these commands:
    
     $ prtconf |grep -i "Memory size"
    
       Memory size: 4096 Megabytes
    
     $ swap -s
     total: 7443040k bytes allocated + 997240k reserved = 8440280k used, 2777096k available
     
     $  df -k
     Filesystem            kbytes    used   avail capacity  Mounted on
     /dev/dsk/c0t0d0s0    4034392 2171569 1822480    55%    /
     /proc                      0       0       0     0%    /proc
     fd                         0       0       0     0%    /dev/fd
     mnttab                     0       0       0     0%    /etc/mnttab
     /dev/dsk/c0t0d0s3     493688  231339  212981    53%    /var
     swap                 2798624      24 2798600     1%    /var/run
     swap                 6164848 3366248 2798600    55%    /tmp
     /dev/vx/dsk/dcdg01/vol01
                         25165824 23188748 1970032    93%    /u01
     /dev/vx/dsk/dcdg01/vol02
                         33554432 30988976 2565456    93%    /u02
     ...
    
     $ top
    
     last pid: 29570;  load averages:  1.00,  0.99,  0.95 10:19:19
     514 processes: 503 sleeping, 4 zombie, 6 stopped, 1 on cpu
     CPU states: 16.5% idle, 17.9% user,  9.8% kernel, 55.8% iowait,  0.0% swap
     Memory: 4096M real, 46M free, 4632M swap in use, 3563M swap free
    
       PID USERNAME THR PRI NICE  SIZE   RES STATE   TIME    CPU COMMAND
     29543 usupport   1  35    0 2240K 1480K cpu2    0:00  0.64% top-3.5b8-sun4u
     13638 usupport  11  48    0  346M  291M sleep  14:00  0.28% oracle
     13432 usupport   1  58    0  387M 9352K sleep   3:56  0.17% oracle
     29285 usupport  10  59    0  144M 5088K sleep   0:04  0.15% java
     13422 usupport  11  58    0  391M 3968K sleep   1:10  0.07% oracle
     6532 usupport   1  58    0  105M 4600K sleep   0:33  0.06% oracle
     ...
    
     $ vmstat 5 100
     procs     memory            page            disk          faults     cpu
     r b w   swap  free  re  mf pi po fr de sr f0 s1 s1 s1   in   sy   cs us sy id
     0 1 72 5746176 222400 0  0  0  0  0  0  0  0 11  9  9 4294967196 0 0 -19 -6 -103
     0 0 58 2750504 55120 346 1391 491 1171 3137 0 36770 0 37 39 5 1485 4150 2061 18 8 74
     0 0 58 2765520 61208 170 272 827 523 1283 0 3904 0 36 40 2 1445 2132 1880 1 3 96
     0 0 58 2751440 58232 450 1576 424 1027 3073 0 12989 0 22 26 3 1458 4372 2035 17 7 76
     0 3 58 2752312 51272 770 1842 1248 1566 4556 0 19121 0 67 66 12 2390 4408 2533 13 11 75
     ...
    
     $ iostat -c 2 100
         cpu
     us sy wt id
     15  5 13 67
     19 11 52 18
     19  8 44 29
     12 10 48 30
     19  7 40 34
     ...
    
     $ iostat -D 2 100
         sd15          sd16          sd17          sd18
     rps wps util  rps wps util  rps wps util  rps wps util
       7   4  9.0    6   3  8.6    5   3  8.1    0   0  0.0
       4  22 16.5    8  41 37.9    0   0  0.7    0   0  0.0
      19  34 37.0   20  24 37.0   12   2 10.8    0   0  0.0
      20  20 29.4   24  37 51.3    3   2  5.3    0   0  0.0
      28  20 40.8   24  20 42.3    1   0  1.7    0   0  0.0
     ...
    
     $  mpstat 2 100
     CPU minf mjf xcal  intr ithr  csw icsw migr smtx  srw syscl  usr sys  wt idl
       0  115   3  255   310  182  403   38   72   82    0   632   16   6  12  66
       1  135   4  687   132  100  569   40  102   68    0   677   14   5  13  68
       2  130   4   34   320  283  552   43   94   63    0    34   15   5  13  67
       3  129   4   64   137  101  582   44  103   66    0    51   15   5  13  67
     ...
    
     HP-UX 11.0:
     ============
    
     $ grep Physical /var/adm/syslog/syslog.log
     $ df -k
     $ sar -w 2 100  
     $ sar -u 2 100
     $ /bin/top
     $ vmstat -n 5 100
     $ iostat 2 100
     $ top
    
    
     For example:
    
     $ grep Physical /var/adm/syslog/syslog.log
     Nov 13 17:43:28 rmtdchp5 vmunix:     Physical: 16777216 Kbytes, lockable: 13405388 Kbytes, available: 15381944 Kbytes
    
     $ sar -w 1 100
    
     HP-UX rmtdchp5 B.11.00 A 9000/800    12/20/02
    
     14:47:20 swpin/s bswin/s swpot/s bswot/s pswch/s
     14:47:21    0.00     0.0    0.00     0.0    1724
     14:47:22    0.00     0.0    0.00     0.0    1458
     14:47:23    0.00     0.0    0.00     0.0    1999
     14:47:24    0.00     0.0    0.00     0.0    1846
     ...
    
     $ sar -u 2 100  # This command generates CPU % usage information.
    
     HP-UX rmtdchp5 B.11.00 A 9000/800    12/20/02
    
     14:48:02    %usr    %sys    %wio   %idle
     14:48:04      20       2       1      77
     14:48:06       1       1       0      98
     ...
    
    
     $ iostat 2 100
    
      device    bps     sps    msps  
    
      c1t2d0     36     7.4     1.0  
      c2t2d0     32     5.6     1.0  
      c1t0d0      0     0.0     1.0  
      c2t0d0      0     0.0     1.0   
      ...
    
     AIX:
     =======
    
     $ /usr/sbin/lsattr -E -l sys0 -a realmem
     $ /usr/sbin/lsps -s
     $ vmstat 5 100
     $ iostat 2 100
     $ /usr/local/bin/top  # May not be installed by default in the server
    
     For example: 
    
     $ /usr/sbin/lsattr -E -l sys0 -a realmem
    
     realmem 33554432 Amount of usable physical memory in Kbytes False
    
     NOTE: This is the total Physical + Swap memory in the system.
           Use top or monitor command to get better breakup of the memory.
    
     $ /usr/sbin/lsps -s
    
     Total Paging Space   Percent Used
           30528MB               1%
    
    
     Linux [RedHat 7.1 and RedHat AS 2.1]:
     =======================================
    
     $ dmesg | grep Memory
     $ vmstat 5 100
     $ /usr/bin/top
    
     For example:
    
     $ dmesg | grep Memory
     Memory: 1027812k/1048568k available (1500k kernel code, 20372k reserved, 103k d)$ /sbin/swapon -s
    
    
     Tru64: 
     ========
     $ vmstat -P| grep -i "Total Physical Memory ="
     $ /sbin/swapon -s
     $ vmstat 5 100
    
    
     For example:
    
     $ vmstat -P| grep -i "Total Physical Memory ="
      
     Total Physical Memory =  8192.00 M
    
     $ /sbin/swapon -s
    
     Swap partition /dev/disk/dsk1g (default swap):
        Allocated space:      2072049 pages (15.81GB)
        In-use space:               1 pages (  0%)
        Free space:           2072048 pages ( 99%)
     Total swap allocation:
        Allocated space:      2072049 pages (15.81GB)
        Reserved space:        864624 pages ( 41%)
        In-use space:               1 pages (  0%)
        Available space:      1207425 pages ( 58%)
    
     Please take at least 10 snapshots of the "top" command to get an idea 
     aboud most OS resource comsuming processes in the server and the different
     snapshot might contain a few different other processes and that will indicate
     that the use of resouces are varying pretty quickly amound many processes.
    
    RELATED DOCUMENTS
    -----------------
    
    
    [Note:1016233.6](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=224176.1&id=1016233.6) : How to Display the Amount of Physical Memory and Swap Space on UNIX Systems
    
    Man pages on vmstat, iostat, mpstat, sar, df, dmesg, perfstat, lsps, lsattr, swapon, etc.
        from relevant OS manuals.
    
    
    
     @NOTE to reviewer: This note has been created as part of PAA Perf. action ID:   21175.
     @This note will complete this PAA action.
      
  
---  
  
  



---
### TAGS
{command}

---
### NOTE ATTRIBUTES
>Created Date: 2017-05-02 01:14:10  
>Last Evernote Update Date: 2018-10-01 15:44:52  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=226608616898263  
>source-url: &  
>source-url: id=224176.1  
>source-url: &  
>source-url: _afrWindowMode=0  
>source-url: &  
>source-url: _adf.ctrl-state=skp2xkoig_92  