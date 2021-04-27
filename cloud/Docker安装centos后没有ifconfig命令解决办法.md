## docker安装centos后没有ifconfig命令解决办法

使用docker pull centos命令下载下来的centos镜像是centos7的最小安装包，里面并没有携带ifconfig命令，导致我想查看容器内的ip时不知道该怎么办，google了一下发现了一下命令

```
yum provides ifconfig
yum whatprovides ifconfig
```

```
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: centos.aol.in
 * extras: centos.aol.in
 * updates: centos.aol.in
net-tools-2.0-0.17.20131004git.el7.x86_64 : Basic networking tools
Repo        : @base
Matched from:
Filename    : /usr/sbin/ifconfig
```
因此，再输入
```
yum install net-tools
```
参考资料：http://www.unixmen.com/ifconfig-command-found-centos-7-minimal-installation-quick-tip-fix/