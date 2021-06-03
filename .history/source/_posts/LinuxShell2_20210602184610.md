---
title: LinuxShell2 - cat, find, xargs and tr 
date: 2018-04-17 10:53:39
tags: Shell
categories: Linux
---

## cat
cat通常用于读取、显示或者拼接文件内容，也可以用将来自标准输入和文件的数据进行组合。

```shell
# 读取文件内容的一般写法：
cat file1 file2 ...
```

将标准输出和文件中的内容拼接在一起

```shell
> echo 'a' > test.txt
> echo 'b' | cat - test.txt # - 作为stdin文件的文件名
b
a
```
<!--more-->

* 使用参数 '-s' 压缩相邻的空白行，另外，对于这个任务也可以使用 'tr' 命令实现
* 使用参数 '-T' 使用'\^I'显示Tab。
* 使用参数 '-n' 在显示过程中添加行号。使用 '-b' 忽略对空行的标号。
* 其他参数，请查看man手册。

## find
find是Unix/Linux上最棒的工具之一，也是很复杂的命令之一，但是许多人并没有真正掌握它。
find命令的工作原理是沿着文件的层次结构向下遍历，匹配符合匹配条件的文件，并且执行相应的操作。下面是find指令的基本的应用场景和使用方法。
1. 开始
    列出某一个目录下的所有文件和文件夹。
    ``` shell
    > find base_path
    # for example
    > find /home/somebody/Musics
    output dirs and files
    # 使用参数 -print 打印
    # 如果不用该参数会将所有文件打印出来
    # 此时使用'\n'分隔
    > find . -print
    # 使用参数 -print0 打印
    # 此时使用'\0'分隔
    ```
2. 使用正则搜索
    使用'-name'参数指明文件名必须要匹配的字符串。同时，也可以使用通配符，如'*.txt'表明所有以txt结尾的文件。然后使用'-print'打印目标。
    ```shell
    # 在某目录下寻找所有的以txt结尾的文件并且打印出来
    > find /home/me/ -name '*.txt' -print
    ...
    ```
    使用参数'-iname'忽略字母大小写，其作用与'-name'类似，只不过该参数忽略大小写。
    ```shell
    > ls
    A.txt B.TXT
    > find . -name '*.txt' -print
    A.txt
    B.TXT
    ```
    匹配多种文件，使用or操作。
    ```shell
    > ls
    a.txt b.pdf c.md
    > find . \( -name '*.txt' -o -name '*.pdf' \) -print
    a.txt
    b.pdf
    ```
    选项'-path'来匹配文件路径。'-name'参数总是对给定的文件名进行匹配，而'-path'则将文件路径作为一个整体进行匹配。
    ```shell
    > find . -path '*/linux/*' -print
    ```
    选项'-regex'的参数和'-path'类似，但是前者是基于正则表达式进行的。正则表达式是通配符的高级形式。下面是几个例子：
    ```shell
    # 匹配所有的py文件和sh文件
    > find . -regex ".*\(\.py\|\.sh\)$"
    # 匹配过程忽略大小写
    > find . -iregex ".*\(\.py\|\.sh\)$"
    ```
    > 后续会有另外的博文介绍正则表达式!

3. 否定参数
    find命令可以使用'!'否定命令参数，表示寻找不匹配某种模式的文件
    ```shell
    # 寻找不以txt为结尾的文件
    > find . ! -name "*.txt" -print
    ```
4. 基于目录深度的搜索
    在find指令运行过程中，可以采用深度选项来限制find遍历目录的深度。
    可以设置'-maxzdepth'指定最大深度，使用'-mindepth'设置最小的深度。
    ```shell
    # 在当前目录下寻找以f开头的文件或者目录
    > find . -maxdepth 1 -name "f*" -print
    # 打印距离当前目录最少有两个目录的文件（f开头）
    > find . -mindepth 2 -name "f*" -print
    ```
    > 注：-maxdepth和-mindepth两个参数应该作为find的第三个参数出现，否则将会影响到find的效率。因为find就不得不做一些不必要的检查。例如，当-type是第三个参数，-maxdepth是第四个参数，则会首先寻找符合type的文件，然后检查目录层次。反过来，会先检查目录层次，到达指定层次以后就不会继续深入了。
5. 根据文件类型搜索
    Unix类操作系统将一切视为文件，文件类型包括普通文件，目录，符号链接，硬链接，字符设别，块设备，套接字，FIFO等。
    可以使用'-type'按照文件类型进行过滤。
    ```shell
    # 列出目录
    > find . -type d -print
    # 普通文件
    > find . -type f -print
    # 符号链接
    > find . -type l -print
    # 字符设备 -- c
    # 块设别   -- b
    # 套接字   -- s
    # FIFO     -- p
    ```
6. 按照时间搜索
    Unix/Linux文件系统的三种时间戳如下：
    (1) 访问时间 -atime: 用户最近一次访问文件的时间。
    (2) 修改时间 -mtime: 文件内容最后被修改的时间。
    (3) 变化时间 -ctime: 文件元数据（权限、所有者）信息最后修改时间。
    > Unix中没有文件创建时间的概念！

    结合以上时间戳和find指令，可以按照时间搜索文件，同时还会带有'+'、'-'符号，前者表示大于，后者表示小于。
    ```shell
    # 打印最近7天内被访问的所有文件
    > find -type f -atime -7 -print
    # 刚好7天访问的文件
    > find -type f -atime 7 -print
    # 7天以前访问的所有文件
    > find -type f -atime +7 -print
    # 修改时间和变化时间也同理
    ```
    需要注意的是-xtime的单位都是天，基于分钟计算的如下：
    (1) -amin
    (2) -mmin
    (3) -cmin
    ```shell
    # 7min以内访问的文件
    > find . -type f -amin -7 -print
    ```
    使用-newer参数通过与指定文件的时间戳相比较得到目的文件。
    ```shell
    > find . -type f -newer file.txt -print
    ```
7. 基于文件大小的搜索
    ```shell
    # 大2kB的文件
    > find . -type f -size +2k
    # 小于2kB的文件
    > find . -type f -size -2k
    # 等于2kB
    > find . -type f -size 2k
    # 其它单位
    # b 块（512B）
    # c 字节
    # w 字 （2字节）
    # k
    # M
    # G
    ```
8. 删除匹配文件
    使用 '-delete' 参数删除find得到的结果。
    ```shell
    # 删除当前目录下所有的.swp文件
    > find . -type f -name "*.swp" -delete
    ```
9. 权限匹配
    根据文件的权限进行查找，列出具备特定权限的文件。
    ```shell
    # 查找权限为644的文件
    > find . -type f -perm 644 -print
    # 没有设置好权限的文件
    > find . -type f ! -perm 644 -print
    ```
    查找某一个用户的文件
    ```shell
    # user参数可为用户名或者uid
    > find . -type f -user dongchangzhang -print
    ```
10. 执行命令
    find借助 '-exec' 选项与其他命令配合，使find命令具备强大的功能。
    例如，我们找到了所有没有设定好权限的文件，并对其设定权限，只需要一条指令即可：
    ```shell
    > find . -type f !-perm 644 -exec chmod 644 {} \;
    ```
    在以上的命令中 {} 会被替换为每一个匹配的文件名。'-exec'后面可以跟任何指令，{}依次替换为匹配后的文件名。每个文件执行一次指令。如果希望一次性执行命令，则在'-exec'中使用'+'替换。另外，虽然对每个文件单独执行命令，但是其全部的输出流是一个完整的。
    需要注意的是，'-exec'命令不能跟多个命令，但是我们可以这样做：
    ```shell
    > .... -exec ./cmds.sh {} \;
    ```
11. 跳过目录
    在查找过程中有一些目录是不需要搜索的，我们可以跳过以节约时间。该技巧也被成为修剪。
    ```shell
    > find . \( -name ".git" -prune \) -o \( -type f -print \)
    ```
    前者表示忽略.git文件夹，后者为具体查找命令。

## xargs
xargs擅长将标准输入数据转换成命令行参数。xargs也能将单行或者多行数据转换为其他的数据格式。例如将单行变为多行或者多行变为单行。
xargs应该紧跟在管道操作符之后，以标准输入作为主要的源数据流。它使用stdin并通过提供命令行参数来执行其他的命令。例如：
```shell
> cmd | xargs
```
1. 单行转为多行
    以空格替换'\n'。
    ```shell
    > cat a.txt
    1
    2
    3

    4
    > cat a.txt | xargs
    1 2 3 4
    ```
2. 单行输入替换为多行输出
    指定每行的最大参数数量-n，可以将stdin中的文本划分为多行，每行n个参数。每个参数都是由" "分隔开的字符串。空格是默认的定界符。
    当然也可以自定义分界符：
    ```shell
    > echo "splitXsplitXsplitXsplit" | xargs -d X
    split split split split
    ```
    结合'-n'我们可以将输出换为多行
    ```shell
    > echo "splitXsplitXsplitXsplit" | xargs -d X -n 2
    split split
    split split
    ```
3. 读取stdin并且格式化参数传递给命令
    为了方便理解，我们有以下的脚本，脚本的作用是打印传递给脚本的参数，并且在参数后添加'#'。
    ```shell
    #!/bin/bash
    # file name a.sh
    echo $* '#'
    ```
    当运行该脚本，我们会看到这样的结果：
    ```shell
    > ./a.sh arg1 arg2
    arg1 arg2 #
    ```
    此时我们遇到这样一个问题将一个含有参数列表的文件中的所有参数传递给上述脚本时，我们可以：
    ```shell
    > cat args.txt
    arg1
    arg2
    arg2
    > cat args.txt | xargs -n 1 ./a.sh
    arg1 #
    arg2 #
    arg3 #
    ```
    多么神奇的事情啊！如果你一次需要传递多个参数呢？
    ```shell
    > cat args.txt | xargs -n 2 ./a.out
    arg1 arg2 #
    arg3 #
    ```
    当一次性传递所有的参数呢？
    ```shell
    > cat args.txt | xargs ./a.out
    arg1 arg2 arg3 #
    ```
    除此之外，如果你的参数的一部分是固定的，而另一部分是需要从参数列表中变化的呢？
    可以使用'-I'指定需要替换的参数，{}将最终被参数替换。在与xargs命令结合使用时，对于每一个参数，命令都会执行一次。
    ```shell
    > cat args.txt | xargs -I {} ./a.sh -p {} -l 
    -p arg1 -l #
    -p arg2 -l #
    -p arg3 -l #
    ```
4. xargs和find
    xargs和find可以结合在一起使用，并且可以大大提升工作效率。在简要了解find和xargs的使用方法之前，一种常犯的错误需要注意：
    ```shell
    > find . -type f -name "*.txt" -print | xargs rm -f
    ```
    上面的操作很危险，可能会删除不必要的文件！因为我们无法预测find输出的结果的定界符是什么，并且很多文件名包含空格，从而误删文件。
    > 因此，只要我们把find的输出作为xargs的输入使用，就必须使用-print0和find结合使用，使用字符'\0'来分割每一个查找到的文件

    ```shell
    # xargs -0 使用'\0'作为输入定界符
    > find . -type f -name "*.txt" -print0 | xargs -0 rm -f
    ```
    举栗子：统计所有c文件的行数
    ```shell
    > find path -type f -name "*.c" -print0 | xargs -0 wc -l
    ```

5. 运用while和子shell
    xargs只能以有限的几种方式提供参数，而且不能为多组命令传递参数，要执行包含来自标准输入的多个参数的命令，有一种灵活的方法。包含while循环的子shell可以用来读取参数，然后通过一种巧妙的方式执行命令。

    ```shell
    > cat files.txt | (while read arg; do cat $args; done)
    # 和 cat files.txt | xargs -I {} cat {}
    ```

    以上cat $args可以替换为多个命令。

## tr
tr可以用于对来自标准输入的内容进行字符的替换、删除以及重复字符的压缩。其也被称为转换命令。需要注意的是，tr命令只接受stdin，不能通过命令行参数来接受输入。它的一般的调用格式如下：
```shell
> tr [options] set1 set2
```
上述的指令，将来自stdin的输入字符从set1映射到set2，然后输出到stdout。其中set1和set2均为字符类或者字符集。如果两个字符集和的长度不同，那么set2将会不断重复其最后一个字符，直到长度与set1相同。如果set2长度大于set1，那么超出的部分将会被忽略。
1. 大小写转换
    ```shell
    > echo "HELLO, WORLD!" | tr 'A-Z' 'a-z'
    hello, world!
    ```
    上述'a-z'等都是集合。那么如何定义一个集合呢？
    我们可以按需追加字符或者字符类构造自己的集合。对于'a-z-}'、'a-ce-x'、'a-c0-9'、'aA.,'等都是合法的结合。定义字符无需写一连串字符，只需要定义'开始字符-终止字符'即可，但是如果上述的开始和终止字符没有顺序关系，那么就将其看为3个独立的字符了。
    当然，tr也可以用于其他字符的替换。
2. 加密和解密
    tr将一个字符集映射到另外一个字符集的原理，我们可以用来进行对文本加密。
    ```shell
    > echo 1234 | tr '0-9' '9876543210'
    8765
    > echo 'tr came, tr saw, tr conquered.' | tr 'a-zA-Z' 'n-za-mN-ZA-M'
    ge pnzr, ge fnj, ge pbadhrerq.
    ```
3. 字符删除和求补
    'tr'命令使用参数'-d'可以删除stdin中的特定字符集：
    ```shell
    > echo "Hello 123 world 456" | tr -d '0-9'
    Hello world
    ```
    可以使用'-c'参数来求set1的补集
    如下面的例子，从输入文本中删除所有不在补集中的字符：
    ```shell
    > echo hello 1 char 2 next 4 | tr -d -c '0-9'
    1 2 4
    ```
    在上述例子中，补集包括除了数字、空格、换行符之外的所有字符。由于指定了参数'-d'，因此这些字符被删除了。
4. 压缩字符
    在文本处理中的一个任务是压缩多个连续的空格为一个，或者其他类似的任务。使用tr可轻松实现这一个任务。
    ```shell
    > echo "hello     world    my   love" | tr -s ' '
    hello world my love
    ```
    对该用法我们可以举出这样的一个例子：将文件中的所有数字相加
    ```shell
    > cat nums.txt
    1
    2
    3
    4
    5
    > cat nums.txt | echo $[ $(tr '\n' '+') 0 ]
    15
    ```
    在上述指令中的最后的0不可缺少。tr命令将stdin变为'1+2+3+4+5+'，最后填一个0使表达式完整。
5. 字符类
    tr可以使用不同的字符类：
    使用字符类的方法如下：
    ```shell
    > tr [:lower:] [:upper:]
    ```
| type | 描述 |
| ---- | ----- |
| alnum | 字母和数字 |
| alpha | 字母 |
| cntrl | 控制字符 |
| digit | 数字 |
| graph | 图形字符 |
| lower | 小写字符 |
| print | 可打印字符 |
| punct | 标点符号 |
| space | 空白字符 |
| xdigit | 16进制字符 |


> 参考：Linux Shell脚本攻略第二章
