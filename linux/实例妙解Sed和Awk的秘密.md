##  实例妙解Sed和Awk的秘密

## 一、课程介绍

```
sed -n '/Error/p' /var/log/syslog | awk '{print $1,$2,$3}'
```

### linux三大神器

- grep/egrep : 查找

- sed : 行编辑器

- awk : 文本处理工具 

  -->一行指令,轻松搞定

三个学习阶段

- 正则表达式
- sed基本处理
- awk更为复杂的处理

## 二、正则表达式

字符、字符串;表达式

**正则表达式的目标**：查找、取出、匹配-->符合某个条件的字符或字符串

**正则表达式的学习方法**:组合(单个字符的表示-->字符串-->表达式)

```
$ grep ubuntu passwd 
ubuntu18:x:1000:1000:ubuntu18,,,:/home/ubuntu18:/bin/bash
$ grep 'ubuntu' passwd 
ubuntu18:x:1000:1000:ubuntu18,,,:/home/ubuntu18:/bin/bash
```

### 1. 正则单字符的表示

**字符**:

- 特定字符:某个具体的字符  '1' 'a'

- 范围内字符
  - 单个字符[]
    - 数字字符:[0-9]   [259]
    - 小写字符:[a-z]
    - 大写字符:[A-Z]

  - 反向字符\^ 

    ```
    [^0-9] [^0]
    ```

- 任意字符

  - 代表任意个字符 : '.'

  [^注]: '[.]'与'\\.'的区别:'[.]'    代表一个字符'.' 

### 2. 正则其他符号

- 边界字符:头尾字符:

  - ^ : ^root 

  ```
  $ grep '^root' passwd    
  root:x:0:0:root:/root:/bin/bash
  ```

  [^注]: 注意与'[^]'的区别

  - $ : false\$ 

  ```
  $ grep 'false$' passwd       
  speech-dispatcher:x:111:29:Speech Dispatcher,,,:/var/run/speech-dispatcher:/bin/false
  whoopsie:x:112:117::/nonexistent:/bin/false
  hplip:x:118:7:HPLIP system user,,,:/var/run/hplip:/bin/false
  gnome-initial-setup:x:120:65534::/run/gnome-initial-setup/:/bin/false
  gdm:x:121:125:Gnome Display Manager:/var/lib/gdm3:/bin/false
  ```

  - 空行 : ^\$

  ```
  $ grep '.' /etc/hosts   //非空行
  127.0.0.1       localhost
  127.0.1.1       ubuntu18
  # The following lines are desirable for IPv6 capable hosts
  ::1     ip6-localhost ip6-loopback
  fe00::0 ip6-localnet
  ff00::0 ip6-mcastprefix
  ff02::1 ip6-allnodes
  ff02::2 ip6-allrouters
  ```

- 其他符号

  - 元字符(代表普通字符或特殊字符)
    - \\w:匹配任何字类字符,包括斜划线 [A-Za-z0-9_]
    - \\W:匹配任何非字类字符,包括斜划线 [\^A-Za-z0-9_]
    - \\b:代表单词的间隔

  ```
  $ grep '\bx\b' passwd 
  ```

### 3. 正则字符组合--重复字符表示

- 字符串

  'root' 'ubuntu' 'r..t'

  '\[A-Z\]\[a-z\]' '\[0-9\][0-9]'

**字符串重复**

\*  :零次或多次匹配前面的字符或子表达式

\+ : 一次或多次匹配前面的字符或子表达式

grep 'se\\+' passwd

grep '\\(se\\)\\+' passwd

? : 零次或一次匹配前面的字符或子表达式

**重复特定次数**:{n,m} {n}

\* :  {0,}

\+ : {1,}

? : {0,1}

```
$ grep '\b[0-9]\{2,3\}\b' passwd  
```

### 4. 字符串逻辑符合表达式

- 任意字符串表达式:   .*    ^r.*  m.*c   **贪婪匹配**
- 逻辑的表示:

  - |    '/bin/\\(false\\|true\\)'

  ```
  $ grep '/bin/\(false\|true\)' passwd     
  speech-dispatcher:x:111:29:Speech Dispatcher,,,:/var/run/speech-dispatcher:/bin/false
  whoopsie:x:112:117::/nonexistent:/bin/false
  hplip:x:118:7:HPLIP system user,,,:/var/run/hplip:/bin/false
  gnome-initial-setup:x:120:65534::/run/gnome-initial-setup/:/bin/false
  gdm:x:121:125:Gnome Display Manager:/var/lib/gdm3:/bin/false
  ```

```
//4-10位QQ号
grep '^[0-9]\{4,10\}$' passwd
//15或18位身份证号(支持X)
grep '^[1-9]\([0-9]\{13\}\|[0-9]\{16\}\)[0-9xX]$' passwd
//匹配密码(数字\下划线\26位字母)
grep '^\w\+$' passwd

```

### 5. 总结

![正则](.\pictures\正则总结01.png)

![正则](.\pictures\正则总结02.png)

## 三、巧妙破解SED

**功能**:自动处理文件,分析日志文件,修改配置文件

![sed](.\pictures\sed01.png)

- sed依次处理一行内容
- sed不改变文件内容(除非重定向)
![sed](.\pictures\sed02.png)

### 1. sed格式

![sed](.\pictures\sed03.png)

options: -e -n(打印模式空间)

command: 行定位(正则)+sed命令操作

```
sed -e '10,15d' -e 's/false/true/g' passwd 
sed -n '/root/p' passwd 
```

### 2. sed基本操作命令

- -p 打印相关的行

```
sed  -n  'p' passwd 
```

- 行定位 x; /pattern/

```
sed -n '10p' passwd 
$ nl passwd  |sed -n '10p' 
    10  news:x:9:9:news:/var/spool/news:/usr/sbin/nologin
$ nl passwd  |sed -n '/ubuntu/p'        
    41  ubuntu18:x:1000:1000:ubuntu18,,,:/home/ubuntu18:/bin/bash
```

- 定位几行 x,y  /pattern/,x;    x,y!   x! 取反  first~step 间隔  first~step! 间隔取反

```
$ nl passwd  |sed -n '10,15p'            
    10  news:x:9:9:news:/var/spool/news:/usr/sbin/nologin
    11  uucp:x:10:10:uucp:/var/spool/uucp:/usr/sbin/nologin
    12  proxy:x:13:13:proxy:/bin:/usr/sbin/nologin
    13  www-data:x:33:33:www-data:/var/www:/usr/sbin/nologin
    14  backup:x:34:34:backup:/var/backups:/usr/sbin/nologin
    15  list:x:38:38:Mailing List Manager:/var/list:/usr/sbin/nologin

$ nl passwd  |sed -n '/root/,/sys/p'    
     1  root:x:0:0:root:/root:/bin/bash
     2  daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
     3  bin:x:2:2:bin:/bin:/usr/sbin/nologin
     4  sys:x:3:3:sys:/dev:/usr/sbin/nologin

$ nl passwd  |sed -n '10,45!p'         
     1  root:x:0:0:root:/root:/bin/bash
     2  daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
     3  bin:x:2:2:bin:/bin:/usr/sbin/nologin
     4  sys:x:3:3:sys:/dev:/usr/sbin/nologin
     5  sync:x:4:65534:sync:/bin:/bin/sync
     6  games:x:5:60:games:/usr/games:/usr/sbin/nologin
     7  man:x:6:12:man:/var/cache/man:/usr/sbin/nologin
     8  lp:x:7:7:lp:/var/spool/lpd:/usr/sbin/nologin
     9  mail:x:8:8:mail:/var/mail:/usr/sbin/nologin
     
$ nl passwd  |sed -n '0~2p'  
     2  daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
     4  sys:x:3:3:sys:/dev:/usr/sbin/nologin
     6  games:x:5:60:games:/usr/games:/usr/sbin/nologin
     8  lp:x:7:7:lp:/var/spool/lpd:/usr/sbin/nologin
    10  news:x:9:9:news:/var/spool/news:/usr/sbin/nologin
    
$ nl passwd  |sed -n '0~2!p' 
     1  root:x:0:0:root:/root:/bin/bash
     3  bin:x:2:2:bin:/bin:/usr/sbin/nologin
     5  sync:x:4:65534:sync:/bin:/bin/sync
     7  man:x:6:12:man:/var/cache/man:/usr/sbin/nologin
     9  mail:x:8:8:mail:/var/mail:/usr/sbin/nologin
```

- a新增行
-  i 插入行
- c替代行
- d删除行

```
$ nl passwd  |sed '5a==========' 
相等
$ nl passwd  |sed '5a =========='
     1  root:x:0:0:root:/root:/bin/bash
     2  daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
     3  bin:x:2:2:bin:/bin:/usr/sbin/nologin
     4  sys:x:3:3:sys:/dev:/usr/sbin/nologin
     5  sync:x:4:65534:sync:/bin:/bin/sync
==========
     6  games:x:5:60:games:/usr/games:/usr/sbin/nologin

$ nl passwd  |sed '1,5a =========='
     1  root:x:0:0:root:/root:/bin/bash
==========
     2  daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
==========
     3  bin:x:2:2:bin:/bin:/usr/sbin/nologin
==========
     4  sys:x:3:3:sys:/dev:/usr/sbin/nologin
==========
     5  sync:x:4:65534:sync:/bin:/bin/sync
==========
     6  games:x:5:60:games:/usr/games:/usr/sbin/nologin
     
$ nl passwd  |sed '5i =========='  
     1  root:x:0:0:root:/root:/bin/bash
     2  daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
     3  bin:x:2:2:bin:/bin:/usr/sbin/nologin
     4  sys:x:3:3:sys:/dev:/usr/sbin/nologin
==========
     5  sync:x:4:65534:sync:/bin:/bin/sync
     6  games:x:5:60:games:/usr/games:/usr/sbin/nologin

$ nl passwd  |sed '1,5i =========='
==========
     1  root:x:0:0:root:/root:/bin/bash
==========
     2  daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
==========
     3  bin:x:2:2:bin:/bin:/usr/sbin/nologin
==========
     4  sys:x:3:3:sys:/dev:/usr/sbin/nologin
==========
     5  sync:x:4:65534:sync:/bin:/bin/sync
     6  games:x:5:60:games:/usr/games:/usr/sbin/nologin

$ nl passwd  |sed '1~2i =========='    
==========
     1  root:x:0:0:root:/root:/bin/bash
     2  daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
==========
     3  bin:x:2:2:bin:/bin:/usr/sbin/nologin
     4  sys:x:3:3:sys:/dev:/usr/sbin/nologin
==========
     5  sync:x:4:65534:sync:/bin:/bin/sync
     6  games:x:5:60:games:/usr/games:/usr/sbin/nologin
==========
     7  man:x:6:12:man:/var/cache/man:/usr/sbin/nologin
     8  lp:x:7:7:lp:/var/spool/lpd:/usr/sbin/nologin
==========
     9  mail:x:8:8:mail:/var/mail:/usr/sbin/nologin
    10  news:x:9:9:news:/var/spool/news:/usr/sbin/nologin
==========

$ nl passwd  |sed '2c =========='   
     1  root:x:0:0:root:/root:/bin/bash
==========
     3  bin:x:2:2:bin:/bin:/usr/sbin/nologin
     4  sys:x:3:3:sys:/dev:/usr/sbin/nologin
     5  sync:x:4:65534:sync:/bin:/bin/sync
     6  games:x:5:60:games:/usr/games:/usr/sbin/nologin

 nl passwd  |sed '1,5c ==========' 
==========
     6  games:x:5:60:games:/usr/games:/usr/sbin/nologin

$ nl passwd  |sed '5d'               
     1  root:x:0:0:root:/root:/bin/bash
     2  daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
     3  bin:x:2:2:bin:/bin:/usr/sbin/nologin
     4  sys:x:3:3:sys:/dev:/usr/sbin/nologin
     6  games:x:5:60:games:/usr/games:/usr/sbin/nologin
     7  man:x:6:12:man:/var/cache/man:/usr/sbin/nologin

$ sed  -i '$a root\nroot'  passwd
$ sed  -i '$a \    root\n    root'  passwd   //添加空格

$ nl passwd|sed '/^$/d' 删除空行,含有空格行不是空行
```

- -s 替换 分隔符可以是 /,#等
- -g 替换标志 全局

```
sed  's/false/true/g' passwd

$ ip addr|sed -n   '/inet.*brd/p'|sed  -e 's/inet\b//g' -e 's#/24.*$##g'
     192.168.45.13
     10.0.0.10
$ ip addr|sed -n   '/inet.*brd/p'|sed  -e 's/inet //g' -e 's#/24.*$##g' -e 's# ##g'
192.168.45.13
10.0.0.10

$ nl passwd|sed '1,5s/.*/=====/g'
=====
=====
=====
=====
=====
     6  games:x:5:60:games:/usr/games:/usr/sbin/nologin

$ nl passwd|sed '1,5c ====='     
=====
     6  games:x:5:60:games:/usr/games:/usr/sbin/nologin
```

- 高级命令
  - -{} 多个sed命令用;分开  {}可以不加
  - -n 读取下一行

```
$ nl passwd|sed '{1,5d;20,$s/false/true/g}'

$ nl passwd |sed -n '{n;p}'
     2  daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
     4  sys:x:3:3:sys:/dev:/usr/sbin/nologin
     6  games:x:5:60:games:/usr/games:/usr/sbin/nologin
     8  lp:x:7:7:lp:/var/spool/lpd:/usr/sbin/nologin
    10  news:x:9:9:news:/var/spool/news:/usr/sbin/nologin
    12  proxy:x:13:13:proxy:/bin:/usr/sbin/nologin
    14  backup:x:34:34:backup:/var/backups:/usr/sbin/nologin
    16  irc:x:39:39:ircd:/var/run/ircd:/usr/sbin/nologin
 
 $ nl passwd |sed -n '{p;n}'
  $ nl passwd |sed -n 'p;n'
     1  root:x:0:0:root:/root:/bin/bash
     3  bin:x:2:2:bin:/bin:/usr/sbin/nologin
     5  sync:x:4:65534:sync:/bin:/bin/sync
     7  man:x:6:12:man:/var/cache/man:/usr/sbin/nologin
     9  mail:x:8:8:mail:/var/mail:/usr/sbin/nologin
    11  uucp:x:10:10:uucp:/var/spool/uucp:/usr/sbin/nologin
    
$ nl passwd |sed -n '{n;n;p}'
     3  bin:x:2:2:bin:/bin:/usr/sbin/nologin
     6  games:x:5:60:games:/usr/games:/usr/sbin/nologin
     9  mail:x:8:8:mail:/var/mail:/usr/sbin/nologin
    12  proxy:x:13:13:proxy:/bin:/usr/sbin/nologin
```

- & :替换固定字符串

```
//'用户名'替换为'用户名 '
$ sed 's/^[a-zA-Z-]\+\b/& /g' passwd 
root :x:0:0:root:/root:/bin/bash
daemon :x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
bin :x:2:2:bin:/bin:/usr/sbin/nologin
sys :x:3:3:sys:/dev:/usr/sbin/nologin
sync :x:4:65534:sync:/bin:/bin/sync
```

- 大小写转换 \u \l  首字母大小写转换 \U \L 字符串大小写转换

```
$ sed 's/^[a-zA-Z-]\+\b/\U&/g' passwd  
ROOT:x:0:0:root:/root:/bin/bash
DAEMON:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
BIN:x:2:2:bin:/bin:/usr/sbin/nologin
SYS:x:3:3:sys:/dev:/usr/sbin/nologin

ls
Desktop  Documents  Downloads  examples.desktop  Music  Pictures  Public  scripts  Templates  Videos
ubuntu18@ubuntu18:~$ ls |sed 's/^\w\+/\U&/g'
DESKTOP
DOCUMENTS
DOWNLOADS
EXAMPLES.desktop
MUSIC
PICTURES
PUBLIC
SCRIPTS
TEMPLATES
VIDEOS
```

- \\(  \\) :  替换某种(部分)字符串 (\1 \2)

```
$ sed 's/\(^[a-z0-9_-]\+\):.*:\([0-9]\+\):\([0-9]\+\):.*$/\1 UID:\2 GID:\3/' passwd   
root UID:0 GID:0
daemon UID:1 GID:1
bin UID:2 GID:2
sys UID:3 GID:3
sync UID:4 GID:65534

$ ip add |sed -n '/inet /p'|sed 's#inet \([0-9.]\+\)/.*$#\1#g' 
    127.0.0.1
    192.168.45.13
    10.0.0.10
```

- -r :复制指定文件插入到匹配行
- -w:复制匹配行拷贝到指定文件里

```
//echo -e

$ echo  -e '12321\n2113213\n3232' > 123.txt
$ cat 123.txt                              
12321
2113213
3232

$ sed '1r 123.txt' abc.txt 
fdggjjkhkjk
12321
2113213
3232
weeretrdf
adadad

$ sed '1w abc.txt' 123.txt        
12321
2113213
3232
$ cat abc.txt 
12321
```

- -q 退出sed

```
s$ nl passwd |sed '/bin/q'      
     1  root:x:0:0:root:/root:/bin/bash
$ nl passwd |sed '/sys/q'    
     1  root:x:0:0:root:/root:/bin/bash
     2  daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
     3  bin:x:2:2:bin:/bin:/usr/sbin/nologin
     4  sys:x:3:3:sys:/dev:/usr/sbin/nologin
$ nl passwd |sed '3q'       
     1  root:x:0:0:root:/root:/bin/bash
     2  daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
     3  bin:x:2:2:bin:/bin:/usr/sbin/nologin
```

### 3. 总结

![总结](.\pictures\sed04.png)

## 四、轻松玩转AWK

可编程-->处理灵活,功能强大

**应用**:

- 统计
- 制表
- else

### 1. awk处理方式与格式

**处理方式**

​	一次处理一行内容

​	对每行进行切片处理

**格式**

![格式](.\pictures\awk01.png)
![格式](.\pictures\awk02.png)
![格式](.\pictures\awk03.png)

### 2. awk内置参数

**awk内置变量1**

​	$0 : 表示整个当前行

​	$1 : 表示第一个字段

​	$2 : 表示第二个字段

**awk内置参数**

​	**分隔符**

![格式](.\pictures\awk04.png)

```
$ awk -F ':' '{print $1}' passwd 
root
daemon
bin
sys
sync
games

$ awk -F ':' '{print $1,$3}' passwd 
root 0
daemon 1
bin 2
sys 3
sync 4
games 5

$ awk -F ':' '{print $1" "$3}' passwd  
root 0
daemon 1
bin 2
sys 3
sync 4
games 5


ubuntu18@ubuntu18:~/scripts$ awk -F ':' '{print $1"\t"$3}' passwd  
root    0
daemon  1
bin     2
sys     3
sync    4
games   5

$ awk -F ':' '{print "UserName:"$1"\tUID:"$3}' passwd   
UserName:root   UID:0
UserName:daemon UID:1
UserName:bin    UID:2
UserName:sys    UID:3
UserName:sync   UID:4
UserName:games  UID:5
```

**awk内置变量1**

​	NR : 每行的记录号

​	NF : 字段数量变量

​	FILENAME : 正在处理的文件名

```
$ awk -F ':' '{print NR,NF,FILENAME}' passwd   
1 7 passwd
2 7 passwd
3 7 passwd
4 7 passwd
5 7 passwd

$ awk -F ':' '{print $1}' passwd  
root
daemon
bin
sys

$ awk -F ':' '{printf("LineNum: %s ColumeNUM: %s UserName: %s\n",NR,NF,$1)}' passwd  
LineNum: 1 ColumeNUM: 7 UserName: root
LineNum: 2 ColumeNUM: 7 UserName: daemon
LineNum: 3 ColumeNUM: 7 UserName: bin
LineNum: 4 ColumeNUM: 7 UserName: sys
LineNum: 5 ColumeNUM: 7 UserName: sync
LineNum: 6 ColumeNUM: 7 UserName: games
LineNum: 7 ColumeNUM: 7 UserName: man
LineNum: 8 ColumeNUM: 7 UserName: lp
LineNum: 9 ColumeNUM: 7 UserName: mail
LineNum: 10 ColumeNUM: 7 UserName: news


$ awk -F ':' '{printf("LineNum: %3s ColumeNUM: %s UserName: %s\n",NR,NF,$1)}' passwd 
LineNum:   1 ColumeNUM: 7 UserName: root
LineNum:   2 ColumeNUM: 7 UserName: daemon
LineNum:   3 ColumeNUM: 7 UserName: bin
LineNum:   4 ColumeNUM: 7 UserName: sys
LineNum:   5 ColumeNUM: 7 UserName: sync
LineNum:   6 ColumeNUM: 7 UserName: games
LineNum:   7 ColumeNUM: 7 UserName: man
LineNum:   8 ColumeNUM: 7 UserName: lp
LineNum:   9 ColumeNUM: 7 UserName: mail
LineNum:  10 ColumeNUM: 7 UserName: news

$ awk -F ':' '{if ($3>100) printf("LineNum: %s UserID: %s UserName: %s\n",NR,$3,$1)}' passwd            
LineNum: 18 UserID: 65534 UserName: nobody
LineNum: 20 UserID: 101 UserName: systemd-resolve
LineNum: 21 UserID: 102 UserName: syslog
LineNum: 22 UserID: 103 UserName: messagebus
LineNum: 23 UserID: 104 UserName: _apt
LineNum: 24 UserID: 105 UserName: uuidd

$ awk '/Error/{print $1,$2,$3 }' syslog 
Mar 15 13:01:38
Mar 15 13:10:36
Mar 15 13:10:37
Mar 15 13:10:37
Mar 15 13:10:40
```

### awk逻辑判断式

**逻辑**

\~,!\~ : 匹配正则表达式

==,!=,<,> : 判断逻辑表达式

```
$ awk -F ':' '$1~/^m.*/{print $1}' passwd 
man
mail
messagebus

ubuntu18@ubuntu18:~/scripts$ awk -F ':' '$1!~/^m.*/{print $1}' passwd 
root
daemon
bin
sys
sync
games
lp

$ awk -F ':' '$3>100{print $1,$3}' passwd  
nobody 65534
systemd-resolve 101
syslog 102
messagebus 103
_apt 104
```

### awk扩展格式

![格式](.\pictures\awk05.png)

```
$ awk -F ':' 'BEGIN{print "LineNum ColumnNum UserName"}{if (NR<6) print NR,NF,$1}END{print "--------"FILENAME"--------"}' passwd 
LineNum ColumnNum UserName
1 7 root
2 7 daemon
3 7 bin
4 7 sys
5 7 sync
--------passwd--------

$ ls -l|awk 'BEGIN{SIZE=0}{SIZE=SIZE+$5}END{print SIZE}'
412027

$ awk 'BEGIN{COUNT=0}$0!~/^$/{COUNT=COUNT+1}END{print COUNT}' passwd   
42

awk -F ':' 'BEGIN{count=0}{if ($3>100) name[count++]=$1}END{for(i=0;i<count;i++) print i,name[i]}' passwd   
0 nobody
1 systemd-resolve
2 syslog
3 messagebus
4 _apt
5 uuidd
6 avahi-autoipd
7 usbmux
8 dnsmasq
9 rtkit
10 cups-pk-helper
11 speech-dispatcher
12 whoopsie
13 kernoops
14 saned

$ netstat -anp |awk '$6~/CONNECTED|LISTENING/{sum[$6]++}END{if (i in sum) print i,sum[i]}'
```

### sed与awk比较

- sed与awk都可以进行文本处理
- awk侧重于复杂逻辑处理
- sed侧重于正则处理
- sed与awk共同使用

### 总结

![总结](.\pictures\awk06.png)

## 五、总结

### 正则

如何表示字符-->如何组成表达式

正则表达式可不是一次就能写好的,要多次试错~

### sed

原理

格式

基本处理命令

替换

高级命令

### awk

内嵌参数

格式

逻辑与函数