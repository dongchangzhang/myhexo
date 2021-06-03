---
title: LinuxShell3 - more commands
date: 2018-04-28 13:31:28
tags: Linux Shell
categories: System 
toc: true
---

## 终端录制
使用 script 和 scriptreplay 可以实现终端命令的录制播放。通常，录制视频需要大量的空间，而使用此命令得到的仅仅是文本文件，大小一般是KB级别的。 

<!--more-->
```shell
# 录制
> script -t 2> timing.log -a output.session
> Input Your Commands
> exit
# 播放
> scriptreplay timing.log output.session
```


## 校验和

checksum用来从文件中生成校验和秘钥，然后利用这个校验和秘钥核实文件的完整性。使用校验和可以确保文件在传输过程中没有损坏。
最知名和最广泛使用的校验和技术是md5sum和SHA-1。它们对文件内容使用相应的算法来生成校验和。
1. md5sum
    使用md5sum直接计算文件的md5sum
    ```shell
    > md5sum filename
    3234234... filename
    ```
    输出的md5序列是一个16进制的字符串。我们可以将生成的md5重定向到一个文件md5sum.md5，然后用这个文件来核实数据的完整性

    ```shell
    md5sum file > md5sum.md5
    ```
    当对多个文件求checksum时，输出的每一行为每个文件的checksum
    ```shell
    > md5sum file1 file2 file3
    [checksum1] file1
    [checksum2] file2
    [checksum3] file3
    ```
    进行校验使用如下的命令参数
    ```shell
    > md5sum -c file.md5
    ```
2. SHA-1
    sha-1与md5sum使用方法类似，只需要将md5sum替换为sha1sum即可。

3. 补充内容
    对于多个文件和文件夹，可以使用md5deep或sha1deep，你可能需要安装这些命令。

    ```shell
    > md5deep -rl path > dir.md5
    # -r 表示使用递归，-l表示使用相对路径
    ```

    当然，你也可以使用find命令来完成这个任务

    ```shell
    find path -type f -print0 | xargs -0 md5sum >> dir.md5
    ```



## 加密和散列

加密技术可以防止数据遭到未被授权的访问。常见的加密和散列的工具包括：crypt、gpg、base64、md5sum、sha1sum以及openssl
1. crypt

    crypt是一个简单的加密工具，它从stdin接受一个文件以及口令作为输入，然后将加密后的数据输出到stdout。
    ```shell
    > crypt <input-file> output-file
    Enter passphrase:
    ```
    该命令需要输入一个口令。同样，我们也可以通过命令行参数提供口令：

    ```shell
    > crypt PASSPHRASE -d <encrypted-file> output-file
    ```

2. gpg
    gpg(GNU隐私保护)是一种使用广泛的工具，它使用加密技术保护文件，确保数据到达目的地之前不会被读取。gpg签名同样用于电子邮件签名，从而证明发送方的真实性。
    gpg加密
    ```shell
    > gpg -c filename
    ```

    通过交互方式读取口令，生成filename.gpg，使用下面命令解密：

    ```shell
    gpg filename.gpg
    ```
    此外，base64、md5sum 和 sha1sum使用方法类似。

3. shadow-like散列(salt散列)

    例如存储在'/etc/shadow'下的用户密码，我们可以利用openssl生成shadow密码。shadow密码通常都是salt密码。所谓SALT就是额外的一个字符串，用来起混淆的作用，使密码难以破解。

    ```shell
    > openssl passwd -1 -salt SALT PASSWD
    ```

    其中，SALT和PASSWD分别是你的字符串和密码。


## 排序、唯一、重复

使用sort对文本和stdin排序，利用uniq去重。

1. 基础内容

    对一组文件排序

    ```shell
    > sort file1 file2 file3 > result.txt
    # 或
    > sort file1 file2 file3 -o result.txt
    ```

    也可以改变排序的顺序和确定顺序的依据

    ```shell
    # 逆序
    > sort -r file
    # 按照数字顺序
    > sort -n file
    # 按照月份
    > sort -M monthes.txt
    ```

    合并两个有序的文件

    ```shell
    >sort -m file1 file2
    ```

    找出有序文件中的不重复的行

    ```shell
    > sort file1 file2 | unique
    ```

    > 执行'sort -C filename'命令的返回值和文件是否有序有关系。如果文件有序，则返回0，否则返回非0。

2. sort的复杂用法

    sort可以对包含键值对结构的数据根据键或者列来进行排序，例如，我们有如下数据：

    ```shell
    > cat data.txt
    1 mac 2000
    2 win 4000
    3 bsd 1000
    4 linux 1000
    ```

    上述数据目前使用第一列的序号进行排序，我们也可以自行指定第二或者第三列进行排序。

    ```shell
    > sort -nrk 1
    4 linux 1000
    3 bsd 1000
    2 win 4000
    1 mac 2000
    > sort -k 2
    3 bsd 1000
    4 linux 1000
    1 max 2000
    2 win 4000
    ```

    > 要注意的是参数'-n'指的是使用数字顺序进行排序。如果需要以数字顺序排序，必须显示指出该参数。

    此外，可以使用参宿'-b'忽略空格等多余字符，使用'-d'以字典序进行排序。也可以明确指明行内某些字符作为排序键，只需要指明起始位置：

    ```shell
    > sort -nk 1,4 data.txt
    ```

3. uniq

    > uniq的输入必须是有序的数据

    该命令通过消除重复的内容，从给定的数据中找到唯一的行，也可以用来寻找重复的行。

    ```shell
    > cat sorted.txt
    bash
    foss
    hack
    hack
    # 去除重复
    > uniq sorted.txt
    bash
    foss
    hack
    # 或
    > sort unsorted.txt | uniq
    # 唯一
    > uniq -u sorted.txt
    bash
    foss
    ```

    统计每一行的数目

    ```shell
    > sort unsorted.txt | uniq -c
        1 bash
        1 foss
        2 hack
    ```

    列出重复的行

    ```shell
    > sort unsorted.txt | uniq -d
    hack
    ```

    结合'-s'和'-w'参数可以指定键。其中s参数表示跳过前n个字符，w参数指定用于比较的最大的字符数目。

    ```shell
    > cat data.txt
    u:01:gnu
    d:04:linux
    u:01:bash
    u:01:hack
    ```

    对于上述文件，我们希望仅仅对其中的数字进行比较

    ```shell
    > sort data.txt | uniq -s 2 -w 2
    d:04:linux
    u:01:bash
    ```


## 临时文件

Linux 的临时文件的存储目录为'/tmp'。其中的内容在每一次系统重启以后都会被清空。我们在创建临时文件时，可以采用不同的方法来为临时数据生成标准的文件名。

使用mktemp在'/tmp'目录中生成一个临时文件。

```shell
> filename=`mktemp`
> echo $filename
/tmp/tmp.Adsijidi
```

使用'-d'参数生成目录

```shell
> dirname=`mktemp -d`
```

如果仅仅需要名字，不需要在磁盘中创建相应文件：

```shell
> tempfile= `mktemp -u`
```

根据模板创建

```shell
> mktemp test.XXX
test.ase
```

> 使模板正常工作，至少需要3个'X'

## 文件分割

当需要将一个大文件分割成多个小文件时，我们需要使用'split'命令。下面是几种不同的文件分割方法。

按照大小分割。例如将一个大小为100KB的文件分割为每一个为10KB的文件。

```shell
> split -b 10k input.data
> ls
input.data xaa xab ...
```

切分以后，文件名以xaa、xab命名。如果以数字为后缀，可以使用参数'-d'，使用'-a'来限制后缀的长度

```shell
> split -b 10k input.data -d -a 4
> ls
input.data x0009 x0019 ...
```

此外，除了k以外，还可以使用M、G、c（byte）、w（word）等后缀。

制定文件前缀名：在命令后添加前缀名即可。

```shell
> split -b 10k data.file d -a 4 split_file
> ls
split_file0000    split_file0001 ...
```

使用参数"-l nu_of_lines"按照数据的行数来进行切分

```
 > split -l 10 data.txt
 # 得到各是10行的文件
```

> Another One: csplit

csplit 是split的一个变体。后者仅仅能根据文件的大小和行数进行切分，但是前者可以根据文本自身的特点进行分割。是否存在某个单词或者文本内容都可以作为分割文件的条件。

有如下的日志文件：

```txt
$ cat server.log 
SERVER-1
[connection] 192.168.0.1 success 
[connection] 192.168.0.2 failed 
[disconnect] 192.168.0.3 pending 
[connection] 192.168.0.4 success 
SERVER-2 
[connection] 192.168.0.1 failed 
[connection] 192.168.0.2 failed 
[disconnect] 192.168.0.3 success 
[connection] 192.168.0.4 failed 
SERVER-3 
[connection] 192.168.0.1 
pending [connection] 192.168.0.2 
pending [disconnect] 192.168.0.3 
pending [connection] 192.168.0.4 failed
```

任务是将上述的文件分割为server1.log、server2.log和server3.log。可以使用如下的命令：

```shell
csplit server.log /SERVER/ -n 2 -s {*} -f server -b "%02d.log" ; rm server00.log
```

其中/SERVER/用来匹配一行，{\*}表示重复执行分割，直至文件结尾。\*可以替换为数字表示执行分割的次数。-s表示静默方式，不打印其他信息，-n表示分割文件后的文件名后缀的数字的个数。-f表示分割文件的前缀，-b表示后缀的格式。在这里文件名即前缀加后缀。

> 根据扩展名切分文件名

借助"%"符号可以方便将“名称.扩展名"这种名称提取出来。对于sample.jpg，下面是一个例子，将名称提取出来

```shell
file="sample.jpg"
name=${file%.*}
echo name is $name

output: name is sample
```

对于${VAR%.\*}的含义如下：首先删除位于%右侧的通配符，上述例子为".\*"，通配符由右侧向左侧进行匹配。然后为VAR赋值。对于sample.jpg，首先通配符匹配到.jpg，删除通配符对VAR进行赋值，得到sample。

注意"%"是非贪婪模式，仅仅匹配从右到左的最短的结果。还有一个是"%%"，但是该模式是从右到左贪婪的，即匹配最长结果。

```shell
$ VAR=hack.fun.book.txt
$ echo ${VAR%.*}
hack.fun.book
$ echo ${VAR%%.*}
hack
```

> 删除前缀

使用#和##可以删除前缀。其用法与%类似，不同的是其是从左向右匹配的

```shell
$ VAR=hack.fun.book.txt
$ echo ${VAR#*.}
fun.book.txt
$ echo ${VAR##*.}
txt
```






## 并行加速

如果需要你的程序需要进行大量的计算，属于cpu密集的应用，为了提高运行效率，就应该充分利用多核。

举个栗子：对多个文件进行md5sum计算：

```shell
#!/bin/bash
# file name is md5.sh

PIDARRAY=()
for file in F1.iso F2.iso
do
    md5sum $file &
    PIDARRAY+=("$!")
done
wait ${PIDARRAY[@]}
```

当执行上述脚本时，获得的结果与下面的运行结果相同。

```shell
md5sum F1.iso F2.iso
```

但是由于多个命令是并行执行的，可以更快得到结果。其工作原理就是使用'&'操作符将shell命令置于后台执行。为了避免循环结束时脚本退出，使用$!获取最后一个进程的PID，使用wait来等待这些进程。

## 批量操作

利用rename、mv结合find，命令可以实现批量操作

```shell
#!/bin/bash 
#文件名: rename.sh 
#用途: 重命名 .jpg 和 .png 文件 
count=1; 
for img in `find . -iname '*.png' -o -iname '*.jpg' -type f -maxdepth 1` 
do 
	new=image-$count.${img##*.} 
	echo "Renaming $img to $new" 
	mv "$img" "$new" 
	let count++ 
done
# 输出如下： 
$ ./rename.sh 
Renaming hack.jpg to image-1.jpg 
Renaming new.jpg to image-2.jpg 
Renaming next.png to image-3.png
```
> 参考：Linux Shell 脚本攻略
