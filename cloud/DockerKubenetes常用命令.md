# Docker&Kubenetes常用命令

# 一、Docker常用命令 

## 1. 常用命令

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
docker rm $(docker ps -f "status=exited"  -aq)
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
# 查看镜像分层
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

### commit

```shell
docker commit container images-
```



## 2. dockerfile

![img](D:\Github\blog\cloud\DockerKubenetes常用命令.assets\20210328000023147.png)

### FROM

scratch -- 从头开始

尽量来使用官方提供的image。

![img](D:\Github\blog\cloud\DockerKubenetes常用命令.assets\20201104153354658.png)

### LABLE

metadata信息，类似于代码的注释。

![img](D:\Github\blog\cloud\DockerKubenetes常用命令.assets\20201104153612559.png)

### RUN

没run一次image上会有新的一层。因此有必要使用&&合并执行，避免layer 过多看起来很混乱

![img](D:\Github\blog\cloud\DockerKubenetes常用命令.assets\2020110415370059.png)

### WORKDIR

使用workdir不要使用run cd来替代

workdir尽量使用绝对路径。增强dockerfile的可移植性。

![img](D:\Github\blog\cloud\DockerKubenetes常用命令.assets\20201104153852668.png)

### ADD和COPY 

- 区别：add 还具有解压缩的功能，例如add test.tat.gz / 
- workdir 和add的结合
- 添加远程文件/目录使用curl 或者 wget

![img](D:\Github\blog\cloud\DockerKubenetes常用命令.assets\20201104154103438.png)

### ENV

定义常量，增加可维护性，和shell中定义变量一个意思。

![img](D:\Github\blog\cloud\DockerKubenetes常用命令.assets\20201104154401439.png)

### volume 和expose 

 

### run、cmd 和entrypoint

<img src="D:\Github\blog\cloud\DockerKubenetes常用命令.assets\20201104155911109.png" alt="img" style="zoom:67%;" />

<img src="D:\Github\blog\cloud\DockerKubenetes常用命令.assets\20201105215535370.png" alt="img" style="zoom: 50%;" />

<img src="D:\Github\blog\cloud\DockerKubenetes常用命令.assets\20201105221447574.png" alt="img" style="zoom: 50%;" />

### SHELL和EXEC

<img src="D:\Github\blog\cloud\DockerKubenetes常用命令.assets\20201104155945657.png" alt="img" style="zoom: 80%;" />



# 二、k8s常用命令 

## 2.1  命令

```shell
# kubectl
kubectl controls the Kubernetes cluster manager.
 Find more information at: https://kubernetes.io/docs/reference/kubectl/overview/

Basic Commands (Beginner):
  create         Create a resource from a file or from stdin.
  expose         Take a replication controller, service, deployment or pod and expose it as a new Kubernetes Service
  run            Run a particular image on the cluster
  set            Set specific features on objects

Basic Commands (Intermediate):
  explain        Documentation of resources
  get            Display one or many resources
  edit           Edit a resource on the server
  delete         Delete resources by filenames, stdin, resources and names, or by resources and label selector

Deploy Commands:
  rollout        Manage the rollout of a resource
  scale          Set a new size for a Deployment, ReplicaSet or Replication Controller
  autoscale      Auto-scale a Deployment, ReplicaSet, or ReplicationController

Cluster Management Commands:
  certificate    Modify certificate resources.
  cluster-info   Display cluster info
  top            Display Resource (CPU/Memory/Storage) usage.
  cordon         Mark node as unschedulable
  uncordon       Mark node as schedulable
  drain          Drain node in preparation for maintenance
  taint          Update the taints on one or more nodes

Troubleshooting and Debugging Commands:
  describe       Show details of a specific resource or group of resources
  logs           Print the logs for a container in a pod
  attach         Attach to a running container
  exec           Execute a command in a container
  port-forward   Forward one or more local ports to a pod
  proxy          Run a proxy to the Kubernetes API server
  cp             Copy files and directories to and from containers.
  auth           Inspect authorization

Advanced Commands:
  diff           Diff live version against would-be applied version
  apply          Apply a configuration to a resource by filename or stdin
  patch          Update field(s) of a resource using strategic merge patch
  replace        Replace a resource by filename or stdin
  wait           Experimental: Wait for a specific condition on one or many resources.
  convert        Convert config files between different API versions
  kustomize      Build a kustomization target from a directory or a remote url.

Settings Commands:
  label          Update the labels on a resource
  annotate       Update the annotations on a resource
  completion     Output shell completion code for the specified shell (bash or zsh)

Other Commands:
  api-resources  Print the supported API resources on the server
  api-versions   Print the supported API versions on the server, in the form of "group/version"
  config         Modify kubeconfig files
  plugin         Provides utilities for interacting with plugins.
  version        Print the client and server version information

Usage:
  kubectl [flags] [options]

Use "kubectl <command> --help" for more information about a given command.
Use "kubectl options" for a list of global command-line options (applies to all commands).
2.1	Kubectl get
kubectl get -h
Display one or many resources
 Prints a table of the most important information about the specified resources. You can filter the list using a label
selector and the --selector flag. If the desired resource type is namespaced you will only see results in your current
namespace unless you pass --all-namespaces.
 Uninitialized objects are not shown unless --include-uninitialized is passed.
 By specifying the output as 'template' and providing a Go template as the value of the --template flag, you can filter
the attributes of the fetched resources.
Use "kubectl api-resources" for a complete list of supported resources.
Examples:
  # List all pods in ps output format.
  kubectl get pods
  # List all pods in ps output format with more information (such as node name).
  kubectl get pods -o wide
  # List a single replication controller with specified NAME in ps output format.
  kubectl get replicationcontroller web
  # List deployments in JSON output format, in the "v1" version of the "apps" API group:
  kubectl get deployments.v1.apps -o json
  # List a single pod in JSON output format.
  kubectl get -o json pod web-pod-13je7
  # List a pod identified by type and name specified in "pod.yaml" in JSON output format.
  kubectl get -f pod.yaml -o json
  # List resources from a directory with kustomization.yaml - e.g. dir/kustomization.yaml.
  kubectl get -k dir/
  # Return only the phase value of the specified pod.
  kubectl get -o template pod/web-pod-13je7 --template={{.status.phase}}
  # List resource information in custom columns.
  kubectl get pod test-pod -o custom-columns=CONTAINER:.spec.containers[0].name,IMAGE:.spec.containers[0].image
  # List all replication controllers and services together in ps output format.
  kubectl get rc,services
  # List one or more resources by their type and names.
  kubectl get rc/web service/frontend pods/web-pod-13je7
Options:
  -A, --all-namespaces=false: If present, list the requested object(s) across all namespaces. Namespace in current
context is ignored even if specified with --namespace.
      --allow-missing-template-keys=true: If true, ignore any errors in templates when a field or map key is missing in
the template. Only applies to golang and jsonpath output formats.
      --chunk-size=500: Return large lists in chunks rather than all at once. Pass 0 to disable. This flag is beta and
may change in the future.
      --field-selector='': Selector (field query) to filter on, supports '=', '==', and '!='.(e.g. --field-selector
key1=value1,key2=value2). The server only supports a limited number of field queries per type.
  -f, --filename=[]: Filename, directory, or URL to files identifying the resource to get from a server.
      --ignore-not-found=false: If the requested object does not exist the command will return exit code 0.
  -k, --kustomize='': Process the kustomization directory. This flag can't be used together with -f or -R.
  -L, --label-columns=[]: Accepts a comma separated list of labels that are going to be presented as columns. Names are
case-sensitive. You can also use multiple flag options like -L label1 -L label2...
      --no-headers=false: When using the default or custom-column output format, don't print headers (default print
headers).
  -o, --output='': Output format. One of:
json|yaml|wide|name|custom-columns=...|custom-columns-file=...|go-template=...|go-template-file=...|jsonpath=...|jsonpath-file=...
See custom columns [http://kubernetes.io/docs/user-guide/kubectl-overview/#custom-columns], golang template
[http://golang.org/pkg/text/template/#pkg-overview] and jsonpath template
[http://kubernetes.io/docs/user-guide/jsonpath].
      --output-watch-events=false: Output watch event objects when --watch or --watch-only is used. Existing objects are
output as initial ADDED events.
      --raw='': Raw URI to request from the server.  Uses the transport specified by the kubeconfig file.
  -R, --recursive=false: Process the directory used in -f, --filename recursively. Useful when you want to manage
related manifests organized within the same directory.
  -l, --selector='': Selector (label query) to filter on, supports '=', '==', and '!='.(e.g. -l key1=value1,key2=value2)
      --server-print=true: If true, have the server return the appropriate table output. Supports extension APIs and
CRDs.
      --show-kind=false: If present, list the resource type for the requested object(s).
      --show-labels=false: When printing, show all labels as the last column (default hide labels column)
      --sort-by='': If non-empty, sort list types using this field specification.  The field specification is expressed
as a JSONPath expression (e.g. '{.metadata.name}'). The field in the API resource specified by this JSONPath expression
must be an integer or a string.
      --template='': Template string or path to template file to use when -o=go-template, -o=go-template-file. The
template format is golang templates [http://golang.org/pkg/text/template/#pkg-overview].
  -w, --watch=false: After listing/getting the requested object, watch for changes. Uninitialized objects are excluded
if no object name is provided.
      --watch-only=false: Watch for changes to the requested object(s), without listing/getting first.
Usage:
  kubectl get
[(-o|--output=)json|yaml|wide|custom-columns=...|custom-columns-file=...|go-template=...|go-template-file=...|jsonpath=...|jsonpath-file=...]
(TYPE[.VERSION][.GROUP] [NAME | -l label] | TYPE[.VERSION][.GROUP]/NAME ...) [flags] [options]
Use "kubectl options" for a list of global command-line options (applies to all commands).
```

## 2.2 示例

```shell
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

## 2.3 kubectl get node

```shell
kubectl get node
kubectl get no
kubectl get nodes

# 结果示例:
NAME                  STATUS   ROLES    AGE   VERSION
host-10-64-20-158     Ready    <none>   16d   v1.17.9
host-10-64-20-174     Ready    <none>   16d   v1.17.9
host-10-64-21-144     Ready    <none>   16d   v1.17.9
host-10-64-21-220     Ready    <none>   16d   v1.17.9
host-10-64-21-55      Ready    <none>   16d   v1.17.9
host-10-64-21-76      Ready    <none>   16d   v1.17.9
host-100-100-98-163   Ready    master   17d   v1.17.9
```
## 2.3 kubectl get ns

```shell
kubectl get ns
kubectl get namespace
kubectl get namespaces

# 结果示例:
NAME              STATUS   AGE
bes4              Active   16d
bom               Active   16d
default           Active   17d
kube-node-lease   Active   17d
kube-public       Active   17d
kube-system       Active   17d
```
## 2.4	kubectl get pod

```shell
kubectl get pod -n bom
kubectl get pod -nbom

# 结果示例:
NAME                        READY   STATUS    RESTARTS   AGE
bomportal-bd66f4fb7-495t7   1/1     Running   1          16d

kubectl get pods -A
kubectl get pods --all-namespaces
kubectl get pods -o wide
kubectl get pod -n bes4 -o wide

# 结果示例:
NAME                                   READY   STATUS    RESTARTS   AGE    IP             NODE                NOMINATED NODE   READINESS GATES
apiaccess-in-85c5ff6f5b-nd667            1/1     Running   1          16d    172.169.3.5    host-10-64-21-144   <none>           <none>

kubectl get pod -n bom -o yaml
kubectl get pod -n bom -o json
kubectl get pods --include-uninitialized   # 列出该namespace中的所有pod包括未初始化的

# 查看集群状态是否正常
kubectl get node,cs
NAME                     STATUS    ROLES     AGE       VERSION
no/host-100-100-50-208   Ready     master    2h        v1.9.6
no/host-100-100-51-100   Ready     <none>    23m       v1.9.6

NAME                    STATUS    MESSAGE              ERROR
cs/controller-manager   Healthy   ok
cs/scheduler            Healthy   ok
cs/etcd-0               Healthy   {"health": "true"}
```
## 2.5	kubectl get pv

```shell
kubectl get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                                STORAGECLASS                  REASON   AGE
package-pv                                 5Gi        RWX            Retain           Bound    bom/package-pvc                      package                                16d
pvc-16844bee-352d-4516-8797-355ce93297a9   5Gi        RWX            Delete           Bound    bes4/dds-data-ddsbackend-0           managed-nfs-storage-dds                16d
pvc-19a6a140-055e-4fe9-b96b-f1a2e5d2594e   30Gi       RWX            Delete           Bound    bes4/vs-storage-vsearch-0            managed-nfs-storage-vs                 16d
pvc-36f5be0d-2eb7-4906-a52b-dc43c0765c85   30Gi       RWX            Delete           Bound    bes4/jetmq-storage-jetmqapp-0        managed-nfs-storage-jetmq              16d

kubectl get pvc -n bom
NAME          STATUS   VOLUME       CAPACITY   ACCESS MODES   STORAGECLASS   AGE
package-pvc   Bound    package-pv   5Gi        RWX            package        16d
```
## 2.6	kubectl describe

```shell
kubectl describe nodes my-node
kubectl describe pod lss-0 -n bes4
Name:         lss-0
Namespace:    bes4
Priority:     0
Node:         host-10-64-20-158/10.64.20.158
Start Time:   Mon, 23 Nov 2020 20:01:43 +0800
Labels:       controller-revision-hash=lss-6b697499ff
              hostLogRootPath=start__var__log__applogs__bes4__LSS
              hwsApplicationName=LSS
              hwsApplicationNetype=com.huawei.itpaas.platformservice.ncss
              hwsApplicationVersion=V600R001C51
              hwsAppunitCount=2
              hwsAppunitName.0=soe
              hwsAppunitName.1=sme
              hwsAppunitNetype.0=com.huawei.itpaas.platformservice.ncss.soe
              hwsAppunitNetype.1=com.huawei.itpaas.platformservice.ncss.sme
              hwsInstanceNetype=com.huawei.itpaas.platformservice.ncss.ncssInstance
              hwsapp=lss
              statefulset.kubernetes.io/pod-name=lss-0
Annotations:  <none>
Status:       Running
IP:           10.64.20.158
IPs:
  IP:           10.64.20.158
Controlled By:  StatefulSet/lss
Containers:
  lss:
    Container ID:   docker://d7918dd10a83b2d7c1af4d6d4f0e702deb7261aefde3e603a27c8c57a9abfae4
    Image:          sz-docker-public.szxy1.artifactory.cd-cloud-artifact.tools.huawei.com/bes-commerce/dw_lss_euleros2sp5_x86:3.300.3.1013
    Image ID:       docker-pullable://sz-docker-public.szxy1.artifactory.cd-cloud-artifact.tools.huawei.com/bes-commerce/dw_lss_euleros2sp5_x86@sha256:b8988389596ff82efd56397890d99dc25712d5dab487c7a5d3c9fcb296e16c15
    Port:           7001/TCP
    Host Port:      7001/TCP
    State:          Running
      Started:      Tue, 24 Nov 2020 11:17:59 +0800
    Last State:     Terminated
      Reason:       Error
      Exit Code:    137
      Started:      Tue, 24 Nov 2020 11:16:44 +0800
      Finished:     Tue, 24 Nov 2020 11:17:58 +0800
    Ready:          True
    Restart Count:  4
    Limits:
      cpu:     4
      memory:  8Gi
    Requests:
      cpu:      1
      memory:   6Gi
    Liveness:   exec [/bin/bash /home/lss/netrixDeploy/liveness_probe.sh] delay=30s timeout=1s period=5s #success=1 #failure=3
    Readiness:  exec [bash /home/lss/netrixDeploy/readiness_probe.sh] delay=30s timeout=1s period=5s #success=1 #failure=3
    Environment:
      POD_NAMESPACE:               bes4 (v1:metadata.namespace)
      POD_UID:                      (v1:metadata.uid)
      POD_LABEL_hwsAppunitName_0:   (v1:metadata.labels['hwsAppunitName.0'])
      POD_LABEL_hwsAppunitName_1:   (v1:metadata.labels['hwsAppunitName.1'])
      DV_ZK_HOSTS:                 127.0.0.1:15522,127.0.0.2:15522,127.0.0.3:15522
      LSS_SERVICE_NAME:            lss
      INSTANCE_NUM:                1
      ZOOKEEPER_URL:               zookeeper:2181
      LSS_LOG_STORAGE_PATH:        /home/log
      LSS_STORAGE_PATH:            /home/lss/volume/phyfile
      LSS_HTTP_PORT:               7001
      CLIENT_JKS_URL:              null
      datacenterID:                0
      ZK_AUTH_FLAG:                ITPaaSAcl
      ZK_INTER_USER:               paasinter
      lss-outauth-way:             none
      volume_phyfilevol_size:      20
      TIME_ZONE:                   GMT-8
      soe_loadbalance_addr:        ip
      MY_POD_NAME:                 lss-0 (v1:metadata.name)
    Mounts:
      /home/agentlib/uniagentconf from uniagentconfdir (rw)
      /home/log from lss-log (rw)
      /home/lss/configmap from lss-configmap (rw)
      /home/lss/secret from lss-secret (rw)
      /home/lss/volume from lss-data (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-4nrv5 (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
Volumes:
  lss-data:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  lss-data-lss-0
    ReadOnly:   false
  lss-log:
    Type:          HostPath (bare host directory volume)
    Path:          /var/log/applogs/bes4/LSS
    HostPathType:
  lss-configmap:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      lss-configmap
    Optional:  false
  lss-secret:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  lss-secret
    Optional:    false
  uniagentconfdir:
    Type:          HostPath (bare host directory volume)
    Path:          /home/agentlib/uniagentconf
    HostPathType:
  default-token-4nrv5:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  default-token-4nrv5
    Optional:    false
QoS Class:       Burstable
Node-Selectors:  <none>
Tolerations:     node.kubernetes.io/not-ready:NoExecute for 300s
                 node.kubernetes.io/unreachable:NoExecute for 300s
Events:          <none>


kubectl describe pvc zk-storage-zookeeper-0 -nbes4
Name:          zk-storage-zookeeper-0
Namespace:     bes4
StorageClass:  managed-nfs-storage-zk
Status:        Bound
Volume:        pvc-c3a4d431-6e7a-4d94-8de3-6178d7bf6158
Labels:        hwsapp=zookeeper
Annotations:   pv.kubernetes.io/bind-completed: yes
               pv.kubernetes.io/bound-by-controller: yes
               volume.beta.kubernetes.io/storage-class: managed-nfs-storage-zk
               volume.beta.kubernetes.io/storage-provisioner: fuseim.pri/ifs-zk
Finalizers:    [kubernetes.io/pvc-protection]
Capacity:      10Gi
Access Modes:  RWX
VolumeMode:    Filesystem
Mounted By:    zookeeper-0
Events:        <none>

kubectl describe pv tenant-pv
Name:            tenant-pv
Labels:          type=NFS
Annotations:     pv.kubernetes.io/bound-by-controller: yes
Finalizers:      [kubernetes.io/pv-protection]
StorageClass:    tenant
Status:          Bound
Claim:           bes4/tenant-pvc
Reclaim Policy:  Retain
Access Modes:    RWX
VolumeMode:      Filesystem
Capacity:        1Gi
Node Affinity:   <none>
Message:
Source:
    Type:      NFS (an NFS mount that lasts the lifetime of a pod)
    Server:    10.64.21.76
    Path:      /home/tenant
    ReadOnly:  false
Events:        <none>
```
## 2.7	kubectl exec

```shell
kubectl exec  -it lss-0  -n bes4  bash
[lss@host-10-64-20-158 ~]$ exit
exit
kubectl exec  -it lss-0  -n bes4  ls /home
agentlib  configagent  log  lss  uniagent

容器化部署场景下，对应有程序的启停、查看日志等操作均需要先进入容器，本章介绍如何进入到容器中。
方法一：在Master节点或执行机通过kubectl命令进入容器内
登录Master节点或执行机。查询部署的pod。
kubectl get pod -n namespace -o wide
通过pod name进入容器内。
kubectl exec -it podname -n namespace bash
方法二：在Pod所在节点通过docker 命令进入容器内
登录Master节点或执行机。查询部署的pod及其宿主机。
kubectl get pod -n namespace -o wide
登录pod所在宿主机。查询容器。
docker ps
通过容器ID进入容器内。
docker exec -it container_id bash
```
## 2.8	BES目录

```shell
car包路径：/home/app/opt/container/webapps
网元配置信息：/home/app/opt/container/webapps/bes/WEB-INF/classes
```
## 2.9	kubectl cp

```shell
kubectl cp bes4/bhf-687865dfc5-l9w4v: /home/app/opt/container/webapps/bes/WEB-INF/classes/certs/CommerceAll.jks /home/infra/yangguang/CommerceAll.jks
kubectl cp a.txt bes4/bhf-687865dfc5-l9w4v:/home/app/opt/container/webapps/bes/WEB-INF/classes/

OPTIONS说明：
-a：拷贝所有uid/gid信息
-L：保持源目标中的链接
```
## 2.10	登录MySQL

```shell
/mysql -S /home/mysql/mysql-files/mysql.sock -uroot -p

SELECT 	* FROM 	bescust.inf_customer;  
```
## 2.11	Docker 配置文件

```shell
Docker 配置文件：/etc/sysconfig/docker
```
## 2.12	kubectl create

```shell
kubectl create namespace bom
kubectl create namespace bes
kubectl create namespace bssp
kubectl create namespace echannel
```
## 2.13	NFS配置文件

```shell
NFS配置文件：/etc/exports
showmount -e 10.21.244.145
```
## 2.14	登录云龙仓库

```shell
docker login sz-docker-public.szxy1.artifactory.cd-cloud-artifact.tools.huawei.com
```
## 2.15	K8s 集群架构

**K8s 集群API: kube-apiserve**r
		与Kubernetes 集群进行交互，通过 REST 调用、kubectl 命令行界面或其他命令行工具（例如 kubeadm）来访问 API

**K8s 调度程序：kube-scheduler**
		考虑容器集的资源需求（例如 CPU 或内存）以及集群的运行状况。将容器集安排到适当的计算节点

**K8s 控制器：kube-controller-manager**
		控制器用于查询调度程序，并确保有正确数量的容器集在运行

**键值存储数据库 etcd**
		配置数据以及有关集群状态的信息位于 etcd（一个键值存储数据库）中

**kubelet**
		每个计算节点中都包含一个 kubelet一个与控制平面通信的微型应用。当控制平面需要在节点中执行某个操作时，kubelet 就会执行该操作。

**kube-proxy**
每个计算节点中还包含 kube-proxy，这是一个用于优化 Kubernetes 网络服务的网络代理。kube-proxy 负责处理集群内部或外部的网络通信——靠操作系统的数据包过滤层，或者自行转发流量

​		持久存储
​		容器镜像仓库
​		底层基础架构

## 2.16	安装Helm

Helm是Kubernetes的一个包管理工具，用来简化Kubernetes应用的部署和管理。获取Helm安装需要安装包和文件，并上传到Master节点或执行机

```shell
helm uninstall bom
```
## 2.17 kubectl get deployment

```shell
# 列出指定 deployment
kubectl get deployment my-dep
```
## 2.18 kubectl get services 

```shell
# 列出所有 namespace 中的所有 service
kubectl get services
kubectl describe service servicename -n namespace
```
## 2.19 创建对象

```shell
$ kubectl create -f ./my-manifest.yaml # 创建资源
$ kubectl create -f ./my1.yaml -f ./my2.yaml # 使用多个文件创建资源
$ kubectl create -f ./dir # 使用目录下的所有清单文件来创建资源
$ kubectl create -f https://git.io/vPieo # 使用 url 来创建资源
$ kubectl run nginx --image=nginx # 启动一个 nginx 实例
$ kubectl explain pods,svc # 获取 pod 和 svc 的文档
```
## 2.20 删除资源

```shell
$ kubectl delete -f ./pod.json # 删除 pod.json 文件中定义的类型和名称的 pod
$ kubectl delete pod,service baz foo # 删除名为“baz”的 pod 和名为“foo”的 service
$ kubectl delete pods,services -l name=myLabel # 删除具有 name=myLabel 标签的 pod 和 serivce
$ kubectl delete pods,services -l name=myLabel --include-uninitialized # 删除具有 name=myLabel 标签的 pod 和 service，包括尚未初始化的
$ kubectl -n my-ns delete po,svc --all # 删除 my-ns namespace 下的所有 pod 和 serivce，包括尚未初始化
```
## 2.21 与运行中的 Pod 交互

```shell
$ kubectl logs my-pod # dump 输出 pod 的日志（stdout）
$ kubectl logs my-pod -c my-container # dump 输出 pod 中容器的日志（stdout，pod 中有多个容器的情况下使用）
$ kubectl logs -f my-pod # 流式输出 pod 的日志（stdout）
$ kubectl logs -f my-pod -c my-container # 流式输出 pod 中容器的日志（stdout，pod 中有多个容器的情况下使用）
$ kubectl run -i --tty busybox --image=busybox -- sh # 交互式 shell 的方式运行 pod
$ kubectl attach my-pod -i # 连接到运行中的容器
$ kubectl exec my-pod -- ls / # 在已存在的容器中执行命令（只有一个容器的情况下）
$ kubectl exec my-pod -c my-container -- ls / # 在已存在的容器中执行命令（pod 中有多个容器的情况下）
$ kubectl top pod POD_NAME --containers # 显示指定 pod 和容器的指标度量
```
## 2.22 节点标签常用管理命令

```shell
查询节点标签
kubectl get nodes --show-labels
添加节点标签，示例：给宿主机名称为host-100-100-50-208的节点，打上hwpurpose=besapp的标签;
kubectl label node host-100-100-50-208 hwpurpose=besapp
修改节点标签，如果命令中带了--overwrite ，则可以覆盖修改已有的 label。
kubectl label node host-100-100-50-208 hwpurpose=besapp –overwrite
在标签值后面使用“ - ”减号相连，则标签删除该标签，示例：删除host-100-100-50-208节点的hwpurpose标签
kubectl label node host-100-100-50-208 hwpurpose-
```
## 2.23 修改应用的部署参数

​		目前Commerce部署的应用中分为平台应用和业务应用，平台应用的配置参数记录在statefulSet中，业务应用的配置参数记录在deployment中。当您不确定应用是属于平台还是应用时，可分别执行kubectl get sts -n namespace和kubectl get deploy -n namespace命令，查看该应用在哪条命令的结果中。
平台应用（statefulSet）
平台服务的部署参数记录在statefulSet，可通过修改statefulSet来更新配置。查询statefulSet

```shell
kubectl get sts -n namespace
NAME             DESIRED   CURRENT   AGE
apigovernance    1         1         1d
执行编辑命令。
kubectl edit sts lss -n namespace
修改方式与vi命令类似。修改成功后，请保存退出。修改后的配置参数，在保存后立即生效。

Commerce应用（deployment）
业务应用的部署参数记录在deployment中，可通过修改deployment来更新实例数配置。查询deploy
kubectl get deploy -n namespace
NAME                     DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
apiaccess-in             1         1         1            1           1d
执行编辑命令。
kubectl edit deploy ce -n namespace
```
## 2.24 Configmap

```shell
ConfigMap 允许你将配置文件与镜像文件分离，以使容器化的应用程序具有可移植性
kubectl get configmap -n namespace
kubectl describe configmap configmapname -n namespace
kubectl edit configmap configmapname -n namespace
```
## 2.25 Pod别名环境变量

```shell
$ alias
alias app='cd /home/app/app'
alias bin='cd /home/app/opt/container/bin'
alias class='cd /home/app/opt/container/webapps/BOMPortal/WEB-INF/classes'
alias clog='cd /home/log/app/bomportal-5b8864448-w5hht/container'
alias conf='cd /home/app/opt/container/conf'
alias dlog='cd /home/log/app/bomportal-5b8864448-w5hht/debug'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias grep='grep --color=auto'
alias l.='ls -d .* --color=auto'
alias lib='cd /home/app/opt/container/webapps/BOMPortal/WEB-INF/lib'
alias ll='ls -l'
alias log='cd /home/log/app/bomportal-5b8864448-w5hht'
alias ls='ls --color=auto'
alias startbom='/home/app/app/bin/startportal.sh'
alias status='/home/app/app/bin/monitor.sh'
alias stopbom='/home/app/app/bin/stopportal.sh'
alias tlog='cd /home/log/app/bomportal-5b8864448-w5hht/container;tail -f catalina.out'
alias which='alias | /usr/bin/which --tty-only --read-alias --show-dot --show-tilde'
```
## 2.26 PV和PVC

### 2.26.1	PV

​		PVC和PV是一一对应的

- **PV生命周期:** 
  Provisioning ——-> Binding ——–>Using——>Releasing——>Recycling

- **PV类型**

  GCEPersistentDisk
   AWSElasticBlockStore
   AzureFile
   AzureDisk
   FC (Fibre Channel)
   Flexvolume
   Flocker
   NFS
   iSCSI
   RBD (Ceph Block Device)
   CephFS
   Cinder (OpenStack block storage)
   Glusterfs
   VsphereVolume
   Quobyte Volumes
   HostPath (Single node testing only – local storage is not supported in any way and WILL NOT WORK in a multi-node cluster)
   Portworx Volumes
   ScaleIO Volumes
   StorageOS

- **PV卷阶段状态**
  Available – 资源尚未被claim使用
  Bound – 卷已经被绑定到claim了
  Released – claim被删除，卷处于释放状态，但未被集群回收。
  Failed – 卷自动回收失败

### 2.26.2	实例

```shell
kubectl  get pvc --all-namespaces
NAMESPACE   NAME                            STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS                  AGE
beslc1      dbagent-log-storage-dbagent-0   Bound    pvc-29e55e35-3d3b-11eb-820e-286ed4892931   8Gi        RWX            managed-nfs-storage-dbagent   44h
beslc1      dds-data-ddsbackend-0           Bound    pvc-7c8120be-3d3b-11eb-820e-286ed4892931   5Gi        RWX            managed-nfs-storage-dds       44h
beslc1      dds-data-ddsfrontend-0          Bound    pvc-7ceea012-3d3b-11eb-820e-286ed4892931   5Gi        RWX            managed-nfs-storage-dds       44h
beslc1      jetmq-storage-jetmqapp-0        Bound    pvc-cdb74514-3d3b-11eb-820e-286ed4892931   30Gi       RWX            managed-nfs-storage-jetmq     44h
beslc1      lss-data-lss-0                  Bound    pvc-c7074513-3d3b-11eb-820e-286ed4892931   30Gi       RWX            managed-nfs-storage-lss       44h
beslc1      tenant-pvc                      Bound    tenant-pv                                  1Gi        RWX            tenant                        45h
beslc1      vs-storage-vsearch-0            Bound    pvc-c4b4665b-3d3b-11eb-820e-286ed4892931   30Gi       RWX            managed-nfs-storage-vs        44h
beslc1      zk-storage-zookeeper-0          Bound    pvc-36037ccf-3d3b-11eb-820e-286ed4892931   10Gi       RWX            managed-nfs-storage-zk        44h
bom         package-pvc                     Bound    package-pv                                 5Gi        RWX            package                       46h

kubectl  get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                                  STORAGECLASS                  REASON   AGE
package-pv                                 5Gi        RWX            Retain           Bound    bom/package-pvc                        package                                46h
pvc-29e55e35-3d3b-11eb-820e-286ed4892931   8Gi        RWX            Delete           Bound    beslc1/dbagent-log-storage-dbagent-0   managed-nfs-storage-dbagent            44h
pvc-36037ccf-3d3b-11eb-820e-286ed4892931   10Gi       RWX            Delete           Bound    beslc1/zk-storage-zookeeper-0          managed-nfs-storage-zk                 44h
pvc-7c8120be-3d3b-11eb-820e-286ed4892931   5Gi        RWX            Delete           Bound    beslc1/dds-data-ddsbackend-0           managed-nfs-storage-dds                44h
pvc-7ceea012-3d3b-11eb-820e-286ed4892931   5Gi        RWX            Delete           Bound    beslc1/dds-data-ddsfrontend-0          managed-nfs-storage-dds                44h
pvc-c4b4665b-3d3b-11eb-820e-286ed4892931   30Gi       RWX            Delete           Bound    beslc1/vs-storage-vsearch-0            managed-nfs-storage-vs                 44h
pvc-c7074513-3d3b-11eb-820e-286ed4892931   30Gi       RWX            Delete           Bound    beslc1/lss-data-lss-0                  managed-nfs-storage-lss                44h
pvc-cdb74514-3d3b-11eb-820e-286ed4892931   30Gi       RWX            Delete           Bound    beslc1/jetmq-storage-jetmqapp-0        managed-nfs-storage-jetmq              44h
tenant-pv                                  1Gi        RWX            Retain           Bound    beslc1/tenant-pvc                      tenant                                 45h
```
## 2.27 etcdctl常用命令

```sh
# 检查网络集群
etcdctl cluster-health

# 带有安全认证检查网络
etcdctl --endpoints=https://192.168.110.100:2379 cluster-health

etcdctl member  list

etcdctl  set  /k8s/network/config'{"Network":"10.1.0.0/16"}'

etcdctl  get  /k8s/network/config
```

## 2.28 其他技巧

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

## 2.29 配置文件路径（kubeadm）

- kubeectl 读取集群配置文件路径：`~/.kube/config`
- 静态 pod 工作目录：`/etc/kubernetes/manifests/`
- kubelet 配置文件路径：`/var/lib/kubelet/config.yaml`
- docker 日志文件路径：`/var/lib/docker/containers/<container-id>/<container-id>-json.log`
- emptyDir 路径：`/var/lib/kubelet/pods/<pod-id>/volumes/kubernetes.io~empty-dir/`
- 证书路径：`/etc/kubernetes/pki`

## 2.30 配置文件路径（二进制）

- 证书路径：`/opt/kubernetes/ssl`
- token 文件路径：`/opt/kubernetes/cfg/token.csv`
- 配置文件路径：`/opt/kubernetes/cfg/kube-apiserver.conf`
```shell
kubectl describe secrets -n kube-system $(kubectl -n kube-system get secret | awk '/dashboard-admin/{print $1}')
```
## 	2.31 NFS常用命令

```shell
（1）在nfs服务器上先建立存储卷对应的目录
[root@nfs ~]# cd /data/volumes/
[root@nfs volumes]# mkdir v{1,2,3,4,5}
[root@nfs volumes]# ls
index.html  v1  v2  v3  v4  v5
[root@nfs volumes]# echo "<h1>NFS stor 01</h1>" > v1/index.html 
[root@nfs volumes]# echo "<h1>NFS stor 02</h1>" > v2/index.html 
[root@nfs volumes]# echo "<h1>NFS stor 03</h1>" > v3/index.html 
[root@nfs volumes]# echo "<h1>NFS stor 04</h1>" > v4/index.html 
[root@nfs volumes]# echo "<h1>NFS stor 05</h1>" > v5/index.html
（2）修改nfs的配置
# vim /etc/exports
/data/volumes/v1        192.168.130.0/24(rw,no_root_squash)
/data/volumes/v2        192.168.130.0/24(rw,no_root_squash)
/data/volumes/v3        192.168.130.0/24(rw,no_root_squash)
/data/volumes/v4        192.168.130.0/24(rw,no_root_squash)
/data/volumes/v5        192.168.130.0/24(rw,no_root_squash)
（3）查看nfs的配置
# exportfs -arv
exporting 192.168.130.0/24:/data/volumes/v5
exporting 192.168.130.0/24:/data/volumes/v4
exporting 192.168.130.0/24:/data/volumes/v3
exporting 192.168.130.0/24:/data/volumes/v2
exporting 192.168.130.0/24:/data/volumes/v1
（4）是配置生效
[root@nfs volumes]# showmount -e
Export list for nfs:
/data/volumes/v5 192.168.130.0/24
/data/volumes/v4 192.168.130.0/24
/data/volumes/v3 192.168.130.0/24
/data/volumes/v2 192.168.130.0/24
/data/volumes/v1 192.168.130.0/24
```

## 2.32 参考文档

https://www.cnblogs.com/along21/p/10342788.html     pvc、pv创建
https://www.cnblogs.com/rexcheny/p/10925464.html   pvc、pv如何关联
https://blog.csdn.net/qianggezhishen/article/details/80764378  pvc、pv 通过label关联    查看其它blog文章

