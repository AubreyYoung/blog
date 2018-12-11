### RAC VIP relocate

<!--vip name--> vip name既不是ora.node2.vip也不是hosts解析名

```
[grid@node1 ~]$ srvctl relocate vip -i node2 -n node2    
[grid@node1 ~]$ crsctl stat res -t                              
--------------------------------------------------------------------------------
NAME           TARGET  STATE        SERVER                   STATE_DETAILS       
--------------------------------------------------------------------------------
Local Resources
--------------------------------------------------------------------------------
ora.DATA.dg
               ONLINE  ONLINE       node1                                        
               ONLINE  ONLINE       node2                                        
ora.FRA.dg
               ONLINE  ONLINE       node1                                        
               ONLINE  ONLINE       node2                                        
ora.LISTENER.lsnr
               ONLINE  ONLINE       node1                                        
               ONLINE  ONLINE       node2                                        
ora.OCR.dg
               ONLINE  ONLINE       node1                                        
               ONLINE  ONLINE       node2                                        
ora.asm
               ONLINE  ONLINE       node1                    Started             
               ONLINE  ONLINE       node2                    Started             
ora.gsd
               OFFLINE OFFLINE      node1                                        
               OFFLINE OFFLINE      node2                                        
ora.net1.network
               ONLINE  ONLINE       node1                                        
               ONLINE  ONLINE       node2                                        
ora.ons
               ONLINE  ONLINE       node1                                        
               ONLINE  ONLINE       node2                                        
ora.registry.acfs
               ONLINE  ONLINE       node1                                        
               ONLINE  ONLINE       node2                                        
--------------------------------------------------------------------------------
Cluster Resources
--------------------------------------------------------------------------------
ora.LISTENER_SCAN1.lsnr
      1        ONLINE  ONLINE       node1                                        
ora.cvu
      1        OFFLINE OFFLINE                                                   
ora.node1.vip
      1        ONLINE  ONLINE       node1                                        
ora.node2.vip
      1        ONLINE  ONLINE       node2                                        
ora.oc4j
      1        OFFLINE OFFLINE                                                   
ora.orcl.db
      1        ONLINE  ONLINE       node1                    Open                
      2        ONLINE  ONLINE       node2                    Open                
ora.scan1.vip
      1        ONLINE  ONLINE       node1                                        
[grid@node1 ~]$ srvctl config vip -n node1
VIP exists: /node1-vip/192.168.45.143/192.168.45.0/255.255.255.0/eth0, hosting node node1
[grid@node1 ~]$ srvctl config vip -n node2
VIP exists: /node2-vip/192.168.45.144/192.168.45.0/255.255.255.0/eth0, hosting node node2
```

