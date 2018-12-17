## Linux命令总结

## yum

```
//查看命令需安装的包
# yum  whatprovides netstat                                          
# yum provides  netstat 
//只下载
yumdownloader rlwrap
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
```

