## 查看MySQL编译参数

```
path="你安装MySQL的绝对路径"

# 设置你系统中存在的编辑器，没有vim的用vi
> VISUAL=vim; export VISUAL

# 执行mysqlbug命令
> $path/bin/mysqlbug
test -x /usr/bin/vim
Using editor /usr/bin/vim
You can change editor by setting the environment variable VISUAL.
If your shell is a bourne shell (sh) do
VISUAL=your_editors_name; export VISUAL
If your shell is a C shell (csh) do
setenv VISUAL your_editors_name
SEND-PR: -*- send-pr -*-
SEND-PR: Lines starting with `SEND-PR' will be removed automatically, as
SEND-PR: will all comments (text enclosed in `<' and `>').
SEND-PR:
From: root
To: mysql@lists.mysql.com
Subject: [50 character or so descriptive subject here (for reference)]

......

# 在打开的文件中，最后部分会有编译的参数
Configured with: ../configure --prefix=/usr --mandir=/usr/share/man --infodir=/usr/share/info --with-bugurl=http://bugzilla.redhat.com/bugzilla --enable-bootstrap --enable-shared --enable-threads=posix --enable-checking=release --with-system-zlib
--enable-__cxa_atexit --disable-libunwind-exceptions --enable-gnu-unique-object --enable-languages=c,c++,objc,obj-c++,java,fortran,ada --enable-java-awt=gtk --disable-dssi --with-java-home=/usr/lib/jvm/java-1.5.0-gcj-1.5.0.0/jre --enable-libgcj-mu
ltifile --enable-java-maintainer-mode --with-ecj-jar=/usr/share/java/eclipse-ecj.jar --disable-libjava-multilib --with-ppl --with-cloog --with-tune=generic --with-arch_32=i686 --build=x86_64-redhat-linux
```