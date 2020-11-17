# Java JVM监控及参数配置

# 一、Java JVM监控

## 1. jps

```java
jps 指令格式：jps [options] [hostid]
    
# jps
19204 ActivationGroupInit
29701 ActivationGroupInit
1926 jboss-modules.jar
27915 XmlConfiguration
19467 Bootstrap
29197 Bootstrap
18957 ActivationGroupInit
17806 Main
24592 Activation
    
# 输出应用程序主类完整package名称或jar完整名称
    
# jps  -l
19204 sun.rmi.server.ActivationGroupInit
29701 sun.rmi.server.ActivationGroupInit
1926 /opt/netwatcher/pm4h2/app/opt/jboss-as-7.1.1.Final/jboss-modules.jar
27915 org.eclipse.jetty.xml.XmlConfiguration
19467 org.apache.catalina.startup.Bootstrap
29197 org.apache.catalina.startup.Bootstrap
18957 sun.rmi.server.ActivationGroupInit
17806 com.esri.arcgis.discovery.nodeagent.impl.Main
24592 sun.rmi.server.Activation
    
# 列出jvm的启动参数
# jps -v
19204 ActivationGroupInit -XX:-CreateMinidumpOnCrash -Xmx64M -Dservice=DawiyatOsp.poi.MapServer -Djava.security.policy=file:////home/arcgis/arcgis/server/framework/etc/arcgis.policy -Djava.rmi.server.codebase=file:////home/arcgis/arcgis/server/framework/lib/server/arcgis-servicelib.jar file:////home/arcgis/arcgis/server/framework/lib/server/arcgis-common.jar 
29701 ActivationGroupInit -XX:-CreateMinidumpOnCrash -Xmx64M -Dservice=OSP_GEO.wx_hlight.MapServer -Djava.security.policy=file:////home/arcgis/arcgis/server/framework/etc/arcgis.policy -Djava.rmi.server.codebase=file:////home/arcgis/arcgis/server/framework/lib/server/arcgis-servicelib.jar file:////home/arcgis/arcgis/server/framework/lib/server/arcgis-common.jar 
1926 jboss-modules.jar -D[Standalone] -XX:HeapDumpPath=/opt/netwatcher/pm4h2/work/log/ext/jvm/jvm_oom_auth_%p.log -XX:+HeapDumpOnOutOfMemoryError -XX:ErrorFile=/opt/netwatcher/pm4h2/work/log/ext/jvm/jvm_crash_auth_%p.log -XX:+UseCompressedOops -XX:+TieredCompilation -Xms128m -Xmx2048m -XX:MaxPermSize=256m -Djava.net.preferIPv4Stack=true -Dorg.jboss.resolver.warning=true -Dsun.rmi.dgc.client.gcInterval=3600000 -Dsun.rmi.dgc.server.gcInterval=3600000 -Dorg.apache.coyote.http11.Http11Protocol.SERVER=unknownServer -Djboss.modules.system.pkgs=org.jboss.byteman -Djava.awt.headless=true -Djboss.server.base.dir=/opt/netwatcher/pm4h2/app/opt/jboss-as-7.1.1.Final/standalone-auth -Djboss.server.data.dir=/opt/netwatcher/pm4h2/work/data/jboss-auth -Djboss.server.log.dir=/opt/netwatcher/pm4h2/work/log/ext/jboss-auth -Djboss.server.temp.dir=/opt/netwatcher/pm4h2/work/tmp/jboss-auth -DORACLE_IP=10.110.2.19, -DORACLE_SID=acrosspm -DORACLE_PORT=1522, -DADDRESS_LIST=(ADDRESS=(HOST=10.110.2.19)(PROTOCOL=TCP)(PORT=1522)) -DNETWATCHER_HOME=/opt/netwatch
27915 XmlConfiguration -Xmx2048m -Xmn1024m -XX:PermSize=512m -XX:MaxPermSize=1024m -XX:ParallelGCThreads=23 -XX:+UseConcMarkSweepGC -XX:+DisableExplicitGC -XX:+UseCMSCompactAtFullCollection -XX:+CMSClassUnloadingEnabled -XX:CMSInitiatingOccupancyFraction=80 -XX:ErrorFile=$PM4H_WORK/log/ext/jvm/jvm_crash_jetty.log -Djetty.home=/opt/netwatcher/pm4h2/app/opt/jetty-distribution-7.6.16.v20140903 -Dorg.apache.jasper.compiler.disablejsr199=true
19467 Bootstrap -Dnop -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager -Xmx2048m -Xms2048m -Dfile.encoding=UTF-8 -XX:MaxNewSize=256m -XX:PermSize=68M -XX:MaxPermSize=256m -Djdk.tls.ephemeralDHKeySize=2048 -Djava.endorsed.dirs=/opt/ossalg/app/opt/im_tomcat_7.0.77_10207-model/endorsed -Dcatalina.base=/opt/ossalg/app/opt/im_tomcat_7.0.77_10207-model -Dcatalina.home=/opt/ossalg/app/opt/im_tomcat_7.0.77_10207-model -Djava.io.tmpdir=/opt/ossalg/app/opt/im_tomcat_7.0.77_10207-model/temp
29197 Bootstrap -Dnop -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager -Xmx2048m -Xms2048m -Dfile.encoding=UTF-8 -XX:MaxNewSize=256m -XX:PermSize=68M -XX:MaxPermSize=256m -Djdk.tls.ephemeralDHKeySize=2048 -Djava.endorsed.dirs=/opt/ossdawiyat/app/opt/im_tomcat_7.0.77_10201-resmaintain/endorsed -Dcatalina.base=/opt/ossdawiyat/app/opt/im_tomcat_7.0.77_10201-resmaintain -Dcatalina.home=/opt/ossdawiyat/app/opt/im_tomcat_7.0.77_10201-resmaintain -Djava.io.tmpdir=/opt/ossdawiyat/app/opt/im_tomcat_7.0.77_10201-resmaintain/temp
18957 ActivationGroupInit -XX:-CreateMinidumpOnCrash -Xmx64M -Dservice=obdosp.query.MapServer -Djava.security.policy=file:////home/arcgis/arcgis/server/framework/etc/arcgis.policy -Djava.rmi.server.codebase=file:////home/arcgis/arcgis/server/framework/lib/server/arcgis-servicelib.jar file:////home/arcgis/arcgis/server/framework/lib/server/arcgis-common.jar 
17806 Main -Darcgis.nodeagent.pidfile=/home/arcgis/arcgis/server/framework/etc/arcgis-nodeagent.pid -Djava.rmi.server.codebase=file:///home/arcgis/arcgis/server/framework/lib/server/arcgis-servicelib.jar file:///home/arcgis/arcgis/server/framework/lib/server/arcgis-common.jar -Detc.dir=/home/arcgis/arcgis/server/framework/etc -Dpkill.dir=/home/arcgis/arcgis/server/bin -Dproducthome.dir=/home/arcgis/arcgis/server -Dobserverslib.dir=/home/arcgis/arcgis/server/framework/lib/server/observers
24592 Activation -Denv.class.path=/home/arcgis/arcgis/server/framework/lib/arcobjects.jar:/home/arcgis/arcgis/server/framework/lib/arcobjects.jar:/home/arcgis/arcgis/server/framework/lib/arcobjects.jar:/home/arcgis/arcgis/server/framework/lib/arcobjects.jar:.:/opt/oss/app/opt/jdk1.8.0_181/li
```

## 2. jinfo

```java
jinfo 指令格式：jinfo [ option ] pid
# 输出全部参数和系统属性
jinfo pid
#只输出参数
jinfo -flags pid
```

## 3. jstat

```java
jstat 指令格式：jstat [options] [pid] [间隔时间/毫秒] [查询次数]

# 1000毫秒统计一次gc情况，统计100次
jstat -gcutil pid 1000 100

# 类加载统计，输出加载和未加载class的数量及其所占空间的大小
jstat -class pid

# 编译统计，输出编译和编译失败数量及失败类型与失败方法
jstat -compiler pid
```

## 4. jstack

```java
jstack 指令格式：jstack [options] [pid]

# 查看jvm线程的运行状态，是否有死锁等信息
jstack -l pid
```

## 5. jmap

```java
指令格式：jmap [ option ] pid
jmap [ option ] executable core
产生核心dump的Java可执行文件，dump就是堆的快照，内存镜像
jmap [ option ] [server-id@]remote-hostname-or-IP
通过可选的唯一id与调试的远程服务器主机名进行操作

jmap -histo:live pid
输出堆中活动的对象以及大小
jmap -heap pid
查看堆的使用状况信息
jmap -permstat pid
打印进程的类加载器和类加载器加载的持久代对象信息
```

## 6. Jconsole

bin目录下的工具，支持远程连接，可以查看JVM的概述，内存，线程等详细情况。



# 二、Java 参数配置