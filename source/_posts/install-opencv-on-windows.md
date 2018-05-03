---
title: 在windows上编译opencv
date: 2018-05-03 09:22:03
tags: opencv
categories: install
---
一直习惯了使用manjaro的aur搭建编程环境，对于opencv的搭建过程基本就是几条命令就可以完成。这几天使用windows搭建opencv开发环境，竟然用了一天半才编译成功。虽然opencv 的编译过程基本差别不大，但是编译过程中会存在一些小的问题致使编译失败。下面有几个需要注意的事情。
<!--more-->
我的基本环境是windows10，version-1803，python-3.65，opencv-3.41，opencv-contrib-3.41，Mingw-w64（not visual studio），cmake-3.11.1。

网上已有的教程基本大同小异，如下面的编译过程：

> https://www.cnblogs.com/xinxue/p/5766756.html

下面是几点需要注意的地方：

1. 注意opencv和opencv-contrib的版本需要一致。
2. 我使用Mingw-w64生成Makefile，然后使用make和make install完成编译过程。因此在使用cmake时，第一次点选configure需要选择MingW Makefile。
3. 上述过程同样可以使用visual studio，但是需要注意vs的版本和位数（32 or 64）。选择中不带64的就是32位的，否则就是64的。很多教程都使用了vs，这里就不再赘述了。
4. 注意python版本，如果系统是64位的，前面也用到了64位的（mingw 或vs），必须安装64位python。

几个问题：

1. "'::hypot' has not been declared"

   确认你是否使用了32位python，如果是，请卸载并安装64位python。

2. "error invalid register for .seh_savexmm "

   3.41版本会出现这个问题，[github上已经解决了这个问题](https://github.com/opencv/opencv/pull/10936)，这里[修改了两个文件](https://github.com/opencv/opencv/pull/10936/files)，照着改一下就可以。

