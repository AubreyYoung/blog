# Linux命令总结

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

## mount

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

## rpm

```sh
rpm -ql tuned-profiles-oracle 
```

## tuned-adm

```sh
# tuned-adm list
Available profiles:
- balanced                    - General non-specialized tuned profile
- desktop                     - Optimize for the desktop use-case
- hpc-compute                 - Optimize for HPC compute workloads
- latency-performance         - Optimize for deterministic performance at the cost of increased power consumption
- network-latency             - Optimize for deterministic performance at the cost of increased power consumption, focused on low latency network performance
- network-throughput          - Optimize for streaming network throughput, generally only necessary on older CPUs or 40G+ networks
- oracle                      - Optimize for Oracle RDBMS
- powersave                   - Optimize for low power consumption
- throughput-performance      - Broadly applicable tuning that provides excellent performance across a variety of common server workloads
- virtual-guest               - Optimize for running inside a virtual guest
- virtual-host                - Optimize for running KVM guests

# tuned-adm profile oracle

# tuned-adm active
Current active profile: oracle

# tuned-adm verify
Verification succeeded, current system settings match the preset profile.
See tuned log file ('/var/log/tuned/tuned.log') for details.
```

## systemctl
```sh
systemctl list-unit-files
systemctl list-unit-files -a |grep enabled
```

