> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 https://harttle.land/2015/11/14/vim-window.html


# Vim 多文件编辑：窗口 

[TOC]

**标签页 (tab)**、**窗口 (window)**、**缓冲区 (buffer)** 是 Vim 多文件编辑的三种方式，它们可以单独使用，也可以同时使用。 它们的关系是这样的：

> A buffer is the in-memory text of a file. A window is a viewport on a buffer. A tab page is a collection of windows. –[vimdoc](http://vimdoc.sourceforge.net/htmldoc/windows.html)

本文主要介绍 Vim 窗口的创建与维护，另外两种编辑方式的使用可以参考： [Vim 多文件编辑：缓冲区](/2015/11/17/vim-buffer.html)和 [Vim 多文件编辑：标签页](/2015/11/12/vim-tabpage.html)。

## 分屏打开多个文件

使用`-O`参数可以让 Vim 以分屏的方式打开多个文件：

```
vim -O main.cpp my-oj-toolkit.h
```

> 使用小写的`-o`可以水平分屏。

## 打开关闭命令

在进入 Vim 后，可以使用这些命令来打开 / 关闭窗口：

```
:sp[lit] {file}     水平分屏
:new {file}         水平分屏
:sv[iew] {file}     水平分屏，以只读方式打开
:vs[plit] {file}    垂直分屏
:clo[se]            关闭当前窗口
```

> 上述命令中，如未指定 file 则打开当前文件。

## 打开关闭快捷键

上述命令都有相应的快捷键，它们有共同的前缀：`Ctrl+w`。

```
Ctrl+w s        水平分割当前窗口
Ctrl+w v        垂直分割当前窗口
Ctrl+w q        关闭当前窗口
Ctrl+w n        打开一个新窗口（空文件）
Ctrl+w o        关闭出当前窗口之外的所有窗口
Ctrl+w T        当前窗口移动到新标签页
```

## 切换窗口

切换窗口的快捷键就是`Ctrl+w`前缀 + `hjkl`：

```
Ctrl+w h        切换到左边窗口
Ctrl+w j        切换到下边窗口
Ctrl+w k        切换到上边窗口
Ctrl+w l        切换到右边窗口
Ctrl+w w        遍历切换窗口
```

> 还有`t`切换到最上方的窗口，`b`切换到最下方的窗口。

## 移动窗口

分屏后还可以把当前窗口向任何方向移动，只需要将上述快捷键中的`hjkl`大写：

```
Ctrl+w H        向左移动当前窗口
Ctrl+w J        向下移动当前窗口
Ctrl+w K        向上移动当前窗口
Ctrl+w L        向右移动当前窗口
```

## 调整大小

调整窗口大小的快捷键仍然有`Ctrl+W`前缀：

```
Ctrl+w +        增加窗口高度
Ctrl+w -        减小窗口高度
Ctrl+w =        统一窗口高度
```

## 文件浏览
```
:Ex 			//开启目录浏览器，可以浏览当前目录下的所有文件，并可以选择
:Sex		   	//水平分割当前窗口，并在一个窗口中开启目录浏览器
:ls 			//显示当前buffer情况
```
## vi与shell切换

```
:shell 			//可以在不关闭vi的情况下切换到shell命令行
:exit		    //从shell回到vi
:!执行外部命令	//在正常模式下输入该命令
:q:				//显示命令行命令历史的窗口	
```

## 关闭多窗口
```
:q!			    //关闭当前窗口
:close			//最后一个窗口不能使用close关闭.
				//使用close只是暂时关闭窗口，其内容还在缓存中，只有使用q!、w!或x才能真能退出。
:only			//保留当前窗口，关闭其它所有窗口
:qall(qa)		//退出所有窗口
:wall			//保存所有窗口
:tabc 关闭当前窗口
:tabo 关闭所有窗口
有4种关闭窗口的方式，分别是：离开（quit）、关闭（close）、隐藏（hide）、关闭其他窗口
Ctrl+W q		//离开当前窗口
Ctrl+W c		//关闭当前的窗口
Ctrl+W o		//关闭当前窗口以外的所有窗口
```