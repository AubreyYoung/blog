# Network Protocols and Real Application Clusters (文档 ID 278132.1)

  

|

|

    
    
    PURPOSE
    -------
    
    Purpose of this document is to give DBAs and Systems Administrators interested
    in Real Application Clusters an overview and a comparison of network protocols
    available.
    
     
    SCOPE & APPLICATION
    -------------------
    
    DBAs and IT professionals may use this note for their physical cluster layout 
    and the options they have available on their platform.
    
    
    NETWORK PROTOCOLS AND REAL APPLICATION CLUSTERS
    -----------------------------------------------
     
    With Real Application Clusters, there are many different interconnect protocols
    available to use with the high speed interconnect.  
    
    On Unix platforms, Oracle typically recommends Infiniband (RDS) where it is certified.  See 
    [Note: 751343.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=278132.1&id=751343.1) for more information on the RDS protocol.  Here are the hardware and RAC protocol 
    alternatives for each platform (not including RDS):
    
    Operating System	Clusterware		Network Hardware	RAC Protocol
    ----------------	-----------		----------------	--------
    HP OpenVMS		HP OpenVMS		Gigabit Ethernet	TCP (UDP for 10gR1 and above)
    HP Tru64		HP TruCluster		Memory Channel	 	RDG
    HP Tru64		HP TruCluster		Memory Channel	 	UDP
    HP Tru64		HP TruCluster		Gigabit Ethernet 	RDG		
    HP Tru64		HP TruCluster		Gigabit Ethernet 	UDP
    HP-UX			Oracle Clusterware	Hyperfabric		UDP
    HP-UX			Oracle Clusterware	Gigabit Ethernet 	UDP		
    HP-UX			HP ServiceGuard		Hyperfabric		UDP
    HP-UX			HP ServiceGuard		Gigabit Ethernet 	UDP
    HP-UX			Veritas Cluster		Gigabit Ethernet 	LLT
    HP-UX			Veritas Cluster		Gigabit Ethernet 	UDP
    IBM AIX			Oracle Clusterware	Gigabit Ethernet (FDDI)	UDP
    IBM AIX			HACMP			Gigabit Ethernet (FDDI)	UDP
    Linux			Oracle Clusterware	Gigabit Ethernet 	UDP
    Microsoft Windows	Oracle Clusterware	Gigabit Ethernet 	TCP			
    Sun Solaris		Oracle Clusterware	Gigabit Ethernet 	UDP		
    Sun Solaris		Fujitsu Primecluster	Gigabit Ethernet	ICF		
    Sun Solaris		Sun Cluster		SCI Interconnect	RSM		
    Sun Solaris		Sun Cluster		Firelink interconnect	RSM		
    Sun Solaris		Sun Cluster		Gigabit Ethernet 	UDP		
    Sun Solaris		Veritas Cluster		Gigabit Ethernet 	LLT
    Sun Solaris		Veritas Cluster		Gigabit Ethernet 	UDP
    
    Oracle Corporation primarily tests and supports the RDS and UDP network libraries (and 
    TCP for Windows).  For other proprietary protocols (RDG, ICF, and LLT), the 
    cluster vendor writes and supports the network libraries.  
    
    Oracle Corporation has done extensive testing on the Oracle provided RDS and UDP 
    libraries (and TCP for Windows).  Based on this testing and extensive experience 
    with production customer deployments, at this time Oracle Support strongly recommends
    the use of RDS or UDP (or TCP on Windows) for RAC environments.
    
    
    
    
    RE-LINKING TO CHANGE PROTCOLS
    -----------------------------
    
    To switch to the udp protocol, shut down the instances and re-link on each node
    with:
    
            cd $ORACLE_HOME/rdbms/lib
            make -f ins_rdbms.mk ipc_g ioracle
    
            9i command:
    
    	cd $ORACLE_HOME/rdbms/lib
    	make -f ins_rdbms.mk ipc_udp ioracle
    
    To confirm that the UDP protcol is being used, run the 'oradebug ipc' command
    as described in Note 181489.1 .  Note 181489.1 also contains some tuning 
    recommendations for various protocols.
    
    
    BEST PRACTICES FOR UDP
    ----------------------
    
    - Have at least a gigabit ethernet for optimal performance
    - Do not use crossover cables (use a switch)
    - Increase the udp buffer sizes to the OS maximum
    - Turn on udp checksumming
    
    
    RELATED DOCUMENTS
    -----------------
    
    [Note 181489.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=278132.1&id=181489.1) - Tuning Inter-Instance Performance in RAC and OPS 
    [Note 751343.1](https://support.oracle.com/epmos/faces/DocumentDisplay?parent=DOCUMENT&sourceId=278132.1&id=751343.1) - RAC Support for RDS Over Infiniband
    Oracle Real Application Clusters Installation and Configuration Guide 
    
      
  
---  
  
  


---
### NOTE ATTRIBUTES
>Created Date: 2018-01-23 05:21:46  
>Last Evernote Update Date: 2018-10-01 15:40:46  
>author: YangKwong  
>source: web.clip  
>source-url: https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=248448776401682  
>source-url: &  
>source-url: id=278132.1  
>source-url: &  
>source-url: _adf.ctrl-state=136elf5fqo_197  