# 优雅玩转Vim

[TOC]

## Vim简介、命令

### 1. vim介绍及vimrc

#### 1.1 vi与vim区别

vim是vi的增强版

```
$ vim --version
VIM - Vi IMproved 8.1 (2018 May 17, compiled May 31 2018 11:16:13)
包含补丁: 1-22
编译者 <alexpux@gmail.com>
巨型版本 无图形界面。  可使用(+)与不可使用(-)的功能:
+acl               +farsi             +mouse_sgr         -tag_any_white
+arabic            +file_in_path      -mouse_sysmouse    -tcl
+autocmd           +find_in_path      +mouse_urxvt       +termguicolors
-autoservername    +float             +mouse_xterm       +terminal
-balloon_eval      +folding           +multi_byte        +terminfo
+balloon_eval_term -footer            +multi_lang        +termresponse
-browse            +fork()            -mzscheme          +textobjects
++builtin_terms    +gettext           +netbeans_intg     +timers
+byte_offset       -hangul_input      +num64             +title
+channel           +iconv             +packages          -toolbar
+cindent           +insert_expand     +path_extra        +user_commands
-clientserver      +job               +perl/dyn          +vertsplit
+clipboard         +jumplist          +persistent_undo   +virtualedit
+cmdline_compl     +keymap            +postscript        +visual
+cmdline_hist      +lambda            +printer           +visualextra
+cmdline_info      +langmap           +profile           +viminfo
+comments          +libcall           +python/dyn        +vreplace
+conceal           +linebreak         +python3/dyn       +wildignore
+cryptv            +lispindent        +quickfix          +wildmenu
+cscope            +listcmds          +reltime           +windows
+cursorbind        +localmap          +rightleft         +writebackup
+cursorshape       -lua               +ruby/dyn          -X11
+dialog_con        +menu              +scrollbind        -xfontset
+diff              +mksession         +signs             -xim
+digraphs          +modify_fname      +smartindent       -xpm
-dnd               +mouse             +startuptime       -xsmp
-ebcdic            -mouseshape        +statusline        -xterm_clipboard
+emacs_tags        +mouse_dec         -sun_workshop      -xterm_save
+eval              -mouse_gpm         +syntax
+ex_extra          -mouse_jsbterm     +tag_binary
+extra_search      +mouse_netterm     +tag_old_static
     系统 vimrc 文件: "/etc/vimrc"
     用户 vimrc 文件: "$HOME/.vimrc"
 第二用户 vimrc 文件: "~/.vim/vimrc"
      用户 exrc 文件: "$HOME/.exrc"
       defaults file: "$VIMRUNTIME/defaults.vim"
         $VIM 预设值: "/etc"
  $VIMRUNTIME 预设值: "/usr/share/vim/vim81"
编译方式: gcc -c -I. -Iproto -DHAVE_CONFIG_H   -I/usr/include/ncursesw  -march=x86-64 -mtune=generic -O2 -pipe -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=1
链接方式: gcc   -L. -pipe -fstack-protector -pipe -Wl,--as-needed -o vim.exe        -lm    -lncursesw -liconv -lacl -lintl   -Wl,--enable-auto-import -Wl,--export-all-symbols -Wl,--enable-auto-image-base -fstack-protector-strong  -L/usr/lib/perl5/core_perl/CORE -lperl -lpthread -ldl -lcrypt
```

#### 1.2 vim信息查看

```
:version
:h或 :help
:e filename
:set number?
```

#### 1.3 vimrc配置

rc = run command

系统级vimrc（/etc/vimrc）和用户级vimrc（家目录）



```
## /etc/vimrc

''							//注释
set number
set history=1000
set ruler					//状态信息
set hlsearch				//查找高亮
set incsearch
set autoindent				//自动缩进
set smartindent
set expandtab				//空格代替tab

##map映射
map <F3> i<ul><CR><Space><Space><li><li><CR><Esc>I</ul><Esc>kcit
map <F4> <Esc>i<li></li><Esc>cit
```

### 2. vim的四种模式

- 普通模式
- 可视模式（v）
- 插入模式
- 



## 二、Vim基础入门

### [1. Vim移动、跳转与缩进](\Git\blog\linux\vim移动、跳转与缩进.md)

### 2. Vim删除、复制与粘贴

### 3. Vim修改、查找与替换



## 三、Vim高级功能

### 1. 缓冲区与多文件编辑

### [2.多窗口操作与标签分组](\Git\blog\linux\Vim多文件编辑_窗口.md)

### 3. 文本对象与宏

### 4. Visual模式



## Vim总结