# innodb打开文件数设置

[root@localhost ~]# vim /etc/security/limits.conf   <==最后增加

* soft nofile 65536

* hard nofile 65536

  

[root@localhost ~]# vim /etc/security/limits.d/20-nproc.conf（centos7.x版本）
<==最后增加

*          soft       nofile    65536

*          hard    nofile    65536

  

[root@localhost ~]# ulimit -n

65536

  

重启生效：init 6或者reboot

或者不重启

###################################

vim /etc/pam.d/login 添加 session required /usr/lib64/security/pam_limits.so
#centos7

  

确保

cat /etc/ssh/sshd_config

有UsePAM yes

#centos7默认设置

#######################################

  

  

  

vi /etc/my.cnf

open_files_limit=65536    #5.7默认值5000

innodb_open_files=65536    #5.7默认值300

  

service mysqld restart

  

#############################

ubuntu有个bug，root用户必须注明用户

  

root soft nofile 65534

root hard nofile 65534

  

##############################

  


---
### NOTE ATTRIBUTES
>Created Date: 2018-04-04 02:48:30  
>Last Evernote Update Date: 2018-04-04 02:49:07  
>author: YangKwong  
>source: desktop.win  
>source-application: evernote.win32  