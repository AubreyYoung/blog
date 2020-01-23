## dLinux命令总结

## yum

```
//查看命令需安装的包
# yum  whatprovides netstat                                          
# yum provides  netstat 
//只下载
yumdownloader rlwrap
yum install --downloadonly 

//配置epel安裝來源
//RHEL六版用戶
# wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
# rpm -Uvh epel-release-latest-6.noarch.rpm 
//RHEL七版用戶
# wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
# rpm -Uvh epel-release-latest-7.noarch.rpm
```

### mount

```
//强制卸载
umount -lf /mnt
```

## rsync

```
//断点续传
rsync -avzP file root@172.20.7.219:/root/tmp
//指定ssh端口
rsync -aP "-e ssh -p 99922" $LOCALDIR $REMOTE
```

