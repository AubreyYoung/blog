## Docker常用命令

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



