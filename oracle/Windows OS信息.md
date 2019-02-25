## Windows OS信息
```
//查看定时任务
schtasks  /Query > schtasks.txt

//系统启动时间
systeminfo | findstr 系统启动时间 > 系统启动时间.txt
systeminfo > info.txt

//IP
ipconfig > ip.txt

//CPU
wmic cpu list brief > cpu.txt
Get-WmiObject -Class Win32_Processor

//系统版本
systeminfo | findstr "版本" > OS版本.txt
ver > version.txt

//主机名
hostname>host.txt

//查看磁盘使用
//查看C盘 
wmic LogicalDisk where "Caption='C:'" get FreeSpace,Size /value  > c_size.txt
//查看D盘 
wmic LogicalDisk where "Caption='D:'" get FreeSpace,Size /value > d_size.txt
//使用powershel
Get-Volume

//rem 查看虚拟内存
wmic pagefile list brief
//Physical Memory
wmic memorychip list brief

 Get-WmiObject -Class Win32_PhysicalMemory

//日期 时间
echo %date% %time%
//时区
tzutil /g
```

## DB信息

