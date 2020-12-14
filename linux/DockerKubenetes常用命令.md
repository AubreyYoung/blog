# Docker&Kubenetes常用命令

# 一、Docker常用命令 

[TOC]

### image

```
docker images
docker image ls
## 重命名镜像
docker tag IMAGEID(镜像id) REPOSITORY:TAG（仓库：标签）
#例子
docker tag ca1b6b825289 registry.cn-hangzhou.aliyuncs.com/xxxxxxx:v1.0
```

### ps

```
#docker ps
#docker ps -a
 //-q, --quiet           Only display numeric IDs
#docker ps -q                                                                       bc9abe3c9543                                                                         ce4894d8bb2c 

C:\Users\galaxy>docker ps -a -f status=exited -f status=created
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
```

### run

```
docker run --name mysql -v L:\DockerVM\mysql\data:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw  -itd mysql:5.7.23 --character-set-server=utf8mb4
//仅运行当前命令即关闭
docker run busybox echo hellworld 
//退出交互界面，容器即关闭
docker run -it ubuntu bash 
//-m内存限制
docker run -dd -p1234:1234 python:2.7 python -m SimpleHTTPServer 1234 
```

### exec

```
docker exec -it proxysql bash
docker exec -it oracle11g su - oracle -c "sqlplus / as sysdba"
docker exec -it python3 python

//windows异常处理
$ docker exec -it oracle11g bash
the input device is not a TTY.  If you are using mintty, try prefixing the command with 'winpty'
$ winpty docker  exec -it oracle11g bash
[root@c4a469a9a784 /]# 

## oracle官方镜像切换root用户
 docker exec --interactive --tty --user root --workdir / oracle12 bash
```

### create

```
//-P, --publish-all                Publish all exposed ports to random ports         
//--expose list                    Expose a port or a range of ports        
docker create -P --expose 1234  python:2.7 python -m SimpleHTTPServer 1234 
```



### start/stop/restart/kill

```
docker start mysql
docker stop mysql
docker restart 3f75ad16e76c
docker kill 3f75ad16e76c 
//注意启动、关闭顺序的重要性，容器之间存在依赖关系
L:\Docker_VM\Test>docker stop bc9abe3c9543 ce4894d8bb2c
bc9abe3c9543
ce4894d8bb2c
L:\Docker_VM\Test>docker start ce4894d8bb2c bc9abe3c9543
ce4894d8bb2c
bc9abe3c9543
L:\Docker_VM\Test>docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                 NAMES
bc9abe3c9543        wordpress           "docker-entrypoint.s"   24 minutes ago      Up 5 seconds        0.0.0.0:80->80/tcp    wordpress
ce4894d8bb2c        mysql               "docker-entrypoint.s"   26 minutes ago      Up 8 seconds        3306/tcp, 33060/tcp   mysqlwp
```

### rm

```
docker rm db1
// -v, --volumes   Remove the volumes associated with the container
docker rm -v db1
docker rm  bc9abe3c9543 ce4894d8bb2c 
//停用全部运行中的容器:
docker stop $(docker ps -q)
//删除全部容器：
docker rm $(docker ps -aq)
//一条命令实现停用并删除容器
docker stop $(docker ps -q) & docker rm $(docker ps -aq)
```

### rmi

```
docker rmi sath89/oracle-xe-11g 
```

### search

```
docker search oracle 
```

###  net

```
docker run --rm=true --net=host --name=mytest -dit centos

docker inspect --format '{{.NetworkSettings.IPAddress}}' nginx
'172.17.0.2'

docker exec -it centos ip addr|grep global
inet 172.17.0.3/16 brd 172.17.255.255 scope global eth0

docker inspect --format '{{.NetworkSettings.IPAddress}}  centos
'172.17.0.3'

docker run -d --name foobar -h foobar busybox sleep 300

docker exec -ti foobar cat /etc/hosts|grep foobar
172.17.0.4      foobar
C:\Users\galaxy>docker exec -ti nginx bash
root@85aacffd0fe0:/# cat /etc/hosts
127.0.0.1       localhost
::1     localhost ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
172.17.0.2      85aacffd0fe0
```

###  pull

```
docker pull python:2.7 
docker pull python
docker pull python name python3.6
```

### build

```
#cat Dockerfile                                          
FROM busybox                                                             
ENV foo=bar  

#docker build -t busybox_test .      
Sending build context to Docker daemon  2.048kB
Step 1/2 : FROM busybox  
latest: Pulling from library/busybox  
8c5a7da1afbc: Pull complete 
Digest: sha256:cb63aa0641a885f54de20f61d152187419e8f6b159ed11a251a09d115fdff9bd    Status: Downloaded newer image for busybox:latest
 ---> e1ddd7948a1c  
Step 2/2 : ENV foo=bar 
 ---> Running in ddedbf4c5fe0    
Removing intermediate container ddedbf4c5fe0  
 ---> ff237b663e17 
Successfully built ff237b663e17   
Successfully tagged busybox_test:latest                                 
SECURITY WARNING: You are building a Docker image from Windows against a non-Windows Docker host. All files and directories added to build context will ha
ve '-rwxr-xr-x' permissions. It is recommended to double check and reset permissions for sensitive files and directories.

#docker images                                                                   
REPOSITORY           TAG         IMAGE ID            CREATED             SIZE     
busybox_test         latest      ff237b663e17        3 minutes ago       1.16MB     
busybox              latest      e1ddd7948a1c        7 weeks ago         1.16MB 
```

### link

```
#docker run --name mysqlwp -e MYSQL_ROOT_PASSWORD=wordpressdocker -d mysql         
#docker run --name wordpress --link mysqlwp:mysql -p 80:80 -d wordpress 


#docker run --name mysqlwp -e MYSQL_ROOT_PASSWORD=wordpressdocker -e MYSQL_DATABASE=wordpress -e MYSQL_USER=wordpress -e MYSQL_PASSWORD=wordpress -d mysql

#docker run --name wordpress --link mysqlwp:mysql -p 80:80 -e WORDPRESS_DB_NAME=wordpress -e WORDPRESS_DB_USER=wordpress -e  WORDPRESS_DB_PASSWORD=wordpress -d wordpress
```

### logs

```
docker logs 22921f896c95  
docker logs  -f  eager_stallman
```

### inspect

```
docker inspect -f {{.Created}} c7bc4f9c8b31 

PS C:\Users\galaxy> docker inspect -f '{{.GraphDriver.Data.WorkDir}}' python3
/var/lib/docker/overlay2/821d72221ca4af217729d04603b44182d47a1b24c059fda1b8cf475982ec74e6/work

PS C:\Users\galaxy> docker inspect -f '{{.GraphDriver.Data.WorkDir}} {{.NetworkSettings.IPAddress}}' python3
/var/lib/docker/overlay2/821d72221ca4af217729d04603b44182d47a1b24c059fda1b8cf475982ec74e6/work 172.17.0.3
```

### stats

```
# docker stats --help
Usage:  docker stats [OPTIONS] [CONTAINER...]
Display a live stream of container(s) resource usage statistics
Options:
-a, --all             Show all containers (default shows just running)
--format string   Pretty-print images using a Go template
--no-stream       Disable streaming stats and only pull the first result
--no-trunc        Do not truncate output

# docker stats -a --no-stream c7bc4f9c8b31
CONTAINER ID  NAME                CPU %   MEM USAGE / LIMIT     MEM %  NET I/O             BLOCK I/O           PIDS
c7bc4f9c8b31  fervent_mahavira    0.00%   5.102MiB / 1.934GiB   0.26%  24.1MB / 562kB      64.4MB / 31.9MB     1
```

### events

```
docker events --help
Usage:  docker events [OPTIONS]
Get real time events from the server
Options:
-f, --filter filter   Filter output based on conditions provided
--format string   Format the output using the given Go template
--since string    Show all events created since timestamp
--until string    Stream events until this timestamp

# docker events                                                                                                                             
2018-09-20T10:19:43.535423300+08:00 container kill c7bc4f9c8b31f05f95e6bfb1d31c5aa986ead91f7ed3cc2fcc760f6646e1eff8 (image=centos, name=fervent_mahavira, 
org.label-schema.build-date=20180804, org.label-schema.license=GPLv2, org.label-schema.name=CentOS Base Image, org.label-schema.schema-version=1.0, org.la
bel-schema.vendor=CentOS, signal=15)                                                                                                                      
2018-09-20T10:19:53.559821500+08:00 container kill c7bc4f9c8b31f05f95e6bfb1d31c5aa986ead91f7ed3cc2fcc760f6646e1eff8 (image=centos, name=fervent_mahavira, 
org.label-schema.build-date=20180804, org.label-schema.license=GPLv2, org.label-schema.name=CentOS Base Image, org.label-schema.schema-version=1.0, org.la
bel-schema.vendor=CentOS, signal=9)                                                                                                                       
2018-09-20T10:19:53.724605000+08:00 container die c7bc4f9c8b31f05f95e6bfb1d31c5aa986ead91f7ed3cc2fcc760f6646e1eff8 (exitCode=137, image=centos, name=ferve
nt_mahavira, org.label-schema.build-date=20180804, org.label-schema.license=GPLv2, org.label-schema.name=CentOS Base Image, org.label-schema.schema-versio
n=1.0, org.label-schema.vendor=CentOS)                                                                                                                    
2018-09-20T10:19:54.745127900+08:00 network disconnect 9220bdf562588d161bc7f27e86be15643959b2d802cf47a35181399978894beb (container=c7bc4f9c8b31f05f95e6bfb
1d31c5aa986ead91f7ed3cc2fcc760f6646e1eff8, name=bridge, type=bridge)                                                                                      
2018-09-20T10:19:55.133677200+08:00 container stop c7bc4f9c8b31f05f95e6bfb1d31c5aa986ead91f7ed3cc2fcc760f6646e1eff8 (image=centos, name=fervent_mahavira, 
org.label-schema.build-date=20180804, org.label-schema.license=GPLv2, org.label-schema.name=CentOS Base Image, org.label-schema.schema-version=1.0, org.la
bel-schema.vendor=CentOS) 
```

### volume

```
# docker run -ti -v /coolbook ubuntu bash
root@fb88b83dec89:/# ls
bin  boot  coolbook  dev  etc  home  lib  lib64  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
root@fb88b83dec89:/# touch  /coolbook/foobar
root@fb88b83dec89:/# ls
bin  boot  coolbook  dev  etc  home  lib  lib64  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
root@fb88b83dec89:/# ls /coolbook/
foobar

# docker inspect -f {{.Mounts}} fb88b83dec89
[{volume 27b2e1c8554ac8bb809de28d0c3608c5e06b307ff23d6071a06acafe322b66d2 /var/lib/docker/volumes/27b2e1c8554ac8bb809de28d0c3608c5e06b307ff23d6071a06acafe
322b66d2/_data /coolbook local  true }]

#docker  volume ls
DRIVER           VOLUME NAME
local            27b2e1c8554ac8bb809de28d0c3608c5e06b307ff23d6071a06acafe322b66d2

C:\Users\galaxy>docker run -v /data --name data ubuntu

C:\Users\galaxy>docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES

C:\Users\galaxy>docker inspect -f {{.Mounts}} data
[{volume 9088cccf4ef69ecc11f2168b1c97d88e0ae92555101e2fca994b2f17b4f24420 /var/lib/docker/volumes/9088cccf4ef69ecc11f2168b1c97d88e0ae92555101e2fca994b2f17
b4f24420/_data /data local  true }]

C:\Users\galaxy>docker run -ti --volumes-from data --name ubuntu_test ubuntu bash
root@9834b6f84636:/# df -h
Filesystem      Size  Used Avail Use% Mounted on
overlay          59G   15G   41G  27% /
tmpfs            64M     0   64M   0% /dev
tmpfs           991M     0  991M   0% /sys/fs/cgroup
/dev/sda1        59G   15G   41G  27% /data
shm              64M     0   64M   0% /dev/shm
tmpfs           991M     0  991M   0% /proc/acpi
tmpfs           991M     0  991M   0% /sys/firmware

# docker volume rm f6cb6cec6d38733d88709dc1835da41640e90008370fc6ddf37a189691c35016 
```

### cp

```
C:\Users\galaxy>docker cp 9834b6f84636:/home/test.txt .
C:\Users\galaxy>cat test.txt
127.0.0.1       localhost
::1     localhost ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
172.17.0.2      9834b6f84636

#docker cp .\TSINFO.sql oracle11g:/home/oracle

//windows git bash下
docker cp oracle12c://rlwrap-0.43-1.el7.x86_64.rpm .
```

```
C:\Users\galaxy>docker
Usage:  docker [OPTIONS] COMMAND
A self-sufficient runtime for containers
Options:
--config string      Location of client config files (default
"C:\\Users\\galaxy\\.docker")
-D, --debug              Enable debug mode
-H, --host list          Daemon socket(s) to connect to
-l, --log-level string   Set the logging level
("debug"|"info"|"warn"|"error"|"fatal")
(default "info")
--tls                Use TLS; implied by --tlsverify
--tlscacert string   Trust certs signed only by this CA (default
"C:\\Users\\galaxy\\.docker\\ca.pem")
--tlscert string     Path to TLS certificate file (default
"C:\\Users\\galaxy\\.docker\\cert.pem")
--tlskey string      Path to TLS key file (default
"C:\\Users\\galaxy\\.docker\\key.pem")
--tlsverify          Use TLS and verify the remote
-v, --version            Print version information and quit
Management Commands:
config      Manage Docker configs
container   Manage containers
image       Manage images
network     Manage networks
node        Manage Swarm nodes
plugin      Manage plugins
secret      Manage Docker secrets
service     Manage services
stack       Manage Docker stacks
swarm       Manage Swarm
system      Manage Docker
trust       Manage trust on Docker images
volume      Manage volumes
Commands:
attach      Attach local standard input, output, and error streams to a running container
build       Build an image from a Dockerfile
commit      Create a new image from a container's changes
cp          Copy files/folders between a container and the local filesystem
create      Create a new container
diff        Inspect changes to files or directories on a container's filesystem
events      Get real time events from the server
exec        Run a command in a running container
export      Export a container's filesystem as a tar archive
history     Show the history of an image
images      List images
import      Import the contents from a tarball to create a filesystem image
info        Display system-wide information
inspect     Return low-level information on Docker objects
kill        Kill one or more running containers
load        Load an image from a tar archive or STDIN
login       Log in to a Docker registry
logout      Log out from a Docker registry
logs        Fetch the logs of a container
pause       Pause all processes within one or more containers
port        List port mappings or a specific mapping for the container
ps          List containers
pull        Pull an image or a repository from a registry
push        Push an image or a repository to a registry
rename      Rename a container
restart     Restart one or more containers
rm          Remove one or more containers
rmi         Remove one or more images
run         Run a command in a new container
save        Save one or more images to a tar archive (streamed to STDOUT by default)
search      Search the Docker Hub for images
start       Start one or more stopped containers
stats       Display a live stream of container(s) resource usage statistics
stop        Stop one or more running containers
tag         Create a tag TARGET_IMAGE that refers to SOURCE_IMAGE
top         Display the running processes of a container
unpause     Unpause all processes within one or more containers
update      Update configuration of one or more containers
version     Show the Docker version information
wait        Block until one or more containers stop, then print their exit codes
Run 'docker COMMAND --help' for more information on a command.
```

### history

```shell
$ docker history c48059c55c17
IMAGE               CREATED              CREATED BY                                      SIZE                COMMENT
c48059c55c17        About a minute ago   /bin/sh -c #(nop)  CMD ["/hello"]               0B
4b3ea33fcb22        About a minute ago   /bin/sh -c #(nop) ADD file:8838a0c049bbba3a0…   861kB
```

### ls

```shell
$ docker container ls -a
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                         PORTS               NAMES
556e69a8ef49        aubrey/hello        "/hello"            31 minutes ago      Exited (13) 31 minutes ago                         optimistic_driscoll
a4982dea46df        hello-world         "/hello"            About an hour ago   Exited (0) About an hour ago                       optimistic_heyrovsky

$ docker container ls -aq
556e69a8ef49
a4982dea46df

$ docker container ls -f "STATUS=exited"
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                         PORTS               NAMES
556e69a8ef49        aubrey/hello        "/hello"            32 minutes ago      Exited (13) 32 minutes ago                         optimistic_driscoll
a4982dea46df        hello-world         "/hello"            About an hour ago   Exited (0) About an hour ago                       optimistic_heyrovsky

$ docker container ls -f "STATUS=exited" -aq
556e69a8ef49
a4982dea46df
```

commit

```shell
docker commit container images-
```



# 二、k8s常用命令 

## 2.1 常用命令

```sh
# 查看namespace
kubectl get ns

# 查看节点服务信息
kubectl get no
kubectl get nodes
kubectl get nodes -lzone

# 查看pod 
# -A 或--all-namespaces 所有的namespace 
# -n 指定namespace
kubectl get pod -A
kubectl get pod --all-namespaces
kubectl get pod -n kube-system
kubectl get pod --selector name=redis
kubectl --kubeconfig=/opt/k8s/conf/admin.conf get pods
kubectl  get pods -n kube-system|grep  dashboard
# 查看service
kubectl get svc -A

# 服务访问方式
# Cluster IP 
curl  ClusterIP:ClusterPort
# Node IP 
curl  NodeIP:NodePort
# 域名访问
curl 域名:9090

# 登录容器
kubectl  exec  -it npsm-0 /bin/bash

kubectl apply -f nps-config.yaml

kubectl describe pod XXX
kubectl describe service/kubenetes-dashboard --namespace="kube-system"
kubectl describe pods/kubenetes-dashboardXXX --namespace="kube-system"

# 查看PV
kubectl get pv

# 查看PVC
kubectl get pvc

# 查看集群
kubectl cluster-info
kubectl get cs

# 查看组件信息
kubectl -s http://localhost:8080 get componentstatuses

# 查看pods所在的节点/IP
kubectl get pods -o wide
kubectl get pods -o wide --all-namespaces
获取已经部署的pod完整的信息
kubectl get pods ${podName} -o yaml 		# (yaml可改为 json\wide)

# 查看pods定义信息
kubectl get pods -o yaml

# 查看pod环境变量
kubectl exec pod名 env

# 查看pod日志
kubectl logs  -f pod名 -n namespace名
# 查看pod前一个容器的日志 (当容器崩溃时，k8s会启动一个新的，看上个崩溃的日志)
kubectl logs ${podName} --previous
# 在创建或启动某些资源的时候没有达到预期结果，可以使用如下命令先简单进行故障定位
kubectl describe deployment/nginx_app
kubectl logs nginx_pods
kubectl exec nginx_pod -c nginx-app <command>

# 创建资源 -f后面跟yaml文件或者json文件
kubectl  create -f xxx.yaml
或者cat xxx.yaml | kubectl create -f -

# 重建资源
kubectl  replace -f 文件.yaml [--force]

# 修改资源
kubectl edit [deploy | svc | pvc | cm] resource_name

kubectl apply -f xxx.yaml

# 删除资源  kubectl delete [deployment | service | pvc | configmaps] resource_name 其中，resource_name表示具体的资源名；
kubectl  delete  -f 文件
kubectl  delete pod  pod名
kubectl  delete rc  rc名
kubectl  delete service service名
kubectl  delete pod  --all

# 查看资源名称 kubectl get [all | deployment | service | pvc | configmaps]
# 查看网络策略
kubectl get networkpolicy
# 查看资源的信息 kubectl get xxx -o [yaml | json | wide | name]
# 描述资源信息 kubectl describe [deployment | service | pvc | configmaps] resource_name 其中，resource_name表示具体的资源名；
# 还可以对输出结果进行自定义，比如对pod只输出容器名称和镜像名称
kubectl get pod httpd-app-5bc589d9f7-rnhj7 -o custom-columns=CONTAINER:.spec.containers[0].name,IMAGE:.spec.containers[0].image
# 获取某个特定key的值还可以输入如下命令得到，此目录参照go template的用法，且命令结尾'\n'是为了输出结果换行
kubectl get pod httpd-app-5bc589d9f7-rnhj7 -o template --template='{{(index spec.containers 0).name}}{{"\n"}}'
# 还有一些可选项可以对结果进行过滤，这儿就不一一列举了，如有兴趣，可参照kubectl get --help说明

# 查看所有service
kubectl get  service  kubenetes-dashboard -n kube-system

# 查看所有发布
kubectl get  deployment  kubenetes-dashboard -n kube-system


# 列出所有的RC
kubectl get rc
kubectl get replicationcontrollers

# 扩容复本
kubectl scale rc rc_name --replicas=3  						# 其中rc_name为RC名称

# 查看标签
kubectl get pods --show-label
# 列出某个标签的所有pod
kubectl get pods -l env
# 列出没有某个标签的pod
kubectl get pods -l '!env'

# 查看某个标签
kubectl get pods -L label_name								# 其中label_name为需要查询的标签名

# 查看有该标签的特定资源
kubectl get pods -l label_name								# 其中label_name为需要查询的标签名

# 添加标签  其中resource_name表示资源名，label_name表示标签名，label_value表示标签值
kubectl label po resource_name label_name=label_value		

# 修改标签 resource_name表示资源名 label_name表示标签名，label_new_value表示标签需要更新的值
kubectl label po resource_name label_name=label_new_value --overwrite		

# 显示kubectl命令行及kube服务端的版本
kubectl version

# 显示支持的API版本集合
kubectl api-versions
# 查看K8s支持的完整资源列表
kubectl api-resources

# 显示当前kubectl配置
kubectl config view

# 使用某种镜像创建Deployment
kubectl run <name> --imageimage>

# 映射端口允许外部访问
kubectl expose deployment/nginx_app --type='NodePort' --port=80
# 然后通过kubectl get services -o wide来查看被随机映射的端口
# 如此就可以通过node的外部IP和端口来访问nginx服务了

# 转发本地端口访问Pod的应用服务程序
kubectl port-forward nginx_app_pod_0 8090:80
# 如此，本地可以访问：curl -i localhost:8090

# 集群内部调用接口(比如用curl命令)，可以采用代理的方式，根据返回的ip及端口作为baseurl
kubectl proxy &

# 实现水平扩展或收缩
kubectl scale
kubectl autoscale rc rc-nginx-3 —min=1 —max=4 
kubectl autoscale deployment/nginx_app --min=3 --max=10 --cpu_percent=80

# 部署状态变更状态检查
kubectl set image deployment/nginx_app nginx=nginx:1.9.1
kubectl rollout status deployment/nginx_app

# 暂停
kubectl rollout pause deployment/nginx_app
# 完成所有的更新操作命令后进行恢复
kubectl rollout resume deployment/nginx_app

# 部署的历史
kubectl rollout history
# 回滚之前先查看历史版本信息
kubectl rollout history deployment/nginx_app

# 回滚部署到最近或者某个版本
kubectl rollout undo
# 不指定版本
kubectl rollout undo deploy deploy_name      # 不指定版本，则默认回滚到上一个版本。等价于--to-revision=0
kubectl rollout undo deployment/nginx_app
# 指定版本：
kubectl rollout undo deploy deploy_name --to-revision=2			# 回滚到revision为2的deployment
kubectl rollout undo deployment/nginx_app --to-revision=<version_index>

# kubectl patch：使用补丁修改、更新某个资源的字段，比如更新某个node
kubectl patch node/node-0 -p '{"spec":{"unschedulable":true}}'
kubectl patch -f node-0.json -p '{"spec": {"unschedulable": "true"}}'
kubectl patch pod rc-nginx-2-kpiqt -p '{"metadata":{"labels":{"app":"nginx-3"}}}' 

# rolling-update需要确保新的版本有不同的name，Version和label，否则会报错 。
kubectl rolling-update rc-nginx-2 -f rc-nginx.yaml 
# 如果在升级过程中，发现有问题还可以中途停止update，并回滚到前面版本 
kubectl rolling-update rc-nginx-2 —rollback 

kubectl attach kube-dns-v9-rcfuk -c skydns —namespace=kube-system 

# cordon & uncordon命令 设置是否能够将pod调度到该节点上。
# 不可调度
kubectl cordon node-0
# 当某个节点需要维护时，可以驱逐该节点上的所有pods(会删除节点上的pod，并且自动通过上面命令设置
# 该节点不可调度，然后在其他可用节点重新启动pods)
kubectl drain node-0
# 待其维护完成后，可再设置该节点为可调度
kubectl uncordon node-0

# 设置taint
kubecl taint nodes node-0 key1=value1:NoSchedule
# 移除taint
kubecl taint nodes node-0 key1:NoSchedule-
# 如果pod想要被调度到上述设置了taint的节点node-0上，则需要在该pod的spec的tolerations字段设置：
tolerations:
- key: "key1"
  operator: "Equal"
  value: "value1"
  effect: "NoSchedule"
# 或者
tolerations:
- key: "key1"
  operator: "Exists"
  effect: "NoSchedule"
```



## 2.2 etcdctl常用命令

```sh
# 检查网络集群
etcdctl cluster-health

# 带有安全认证检查网络
etcdctl --endpoints=https://192.168.110.100:2379 cluster-health

etcdctl member  list

etcdctl  set  /k8s/network/config'{"Network":"10.1.0.0/16"}'

etcdctl  get  /k8s/network/config
```





## 2.3 其他技巧

```sh
# k8s命令补全
yum install  bash-completions
source /usr/share/bash-completion/bash-completion

# k8s里kube-proxy支持三种模式，在v1.8之前我们使用的是iptables以及userspace两种模式，在k8s1.8之后引入了ipvs模式
yum install ipvsadm -y
ipvsadm -L -n
```

**命令行中的资源缩写**

| 资源全名称             | 缩写                |
| ---------------------- | ------------------- |
| namespace              | ns                  |
| pods                   | pod 、po            |
| deploymentes           | deployment 、deploy |
| replicaset             | rs                  |
| replicationcontroller  | rc                  |
| persistentVolumes      | pv                  |
| persistentVolumesClaim | pvc                 |
| service                | svc                 |

## 2.4 配置文件路径（kubeadm）

- kubeectl 读取集群配置文件路径：`~/.kube/config`
- 静态 pod 工作目录：`/etc/kubernetes/manifests/`
- kubelet 配置文件路径：`/var/lib/kubelet/config.yaml`
- docker 日志文件路径：`/var/lib/docker/containers/<container-id>/<container-id>-json.log`
- emptyDir 路径：`/var/lib/kubelet/pods/<pod-id>/volumes/kubernetes.io~empty-dir/`
- 证书路径：`/etc/kubernetes/pki`

## 配置文件路径（二进制）

- 证书路径：`/opt/kubernetes/ssl`
- token 文件路径：`/opt/kubernetes/cfg/token.csv`
- 配置文件路径：`/opt/kubernetes/cfg/kube-apiserver.conf`



kubectl describe secrets -n kube-system $(kubectl -n kube-system get secret | awk '/dashboard-admin/{print $1}')

