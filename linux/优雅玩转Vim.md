# 优雅玩转Vim

## Vim常用命令

```
:version
:h或 :help
:e filename
:set number?
```

## Vimrc配置

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

