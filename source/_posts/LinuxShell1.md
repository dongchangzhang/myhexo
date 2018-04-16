---
title: Linux Shell 基础内容
date: 2018-04-16 21:55:18
tags: Shell
categories: Linux
---

## 终端打印

1. echo

   ```shell
   # 使用没有引号的echo，不能输出';'
   > echo Hello World！
   # 变量替换在''中无效
   # ""中不能直接打印！，需要转义，''中忽略不会识别转义字符
   [Y]: echo "Hello, World\!"
   [N]: echo "Hello, World!"
   [Y]: echo 'Hello, World!'
   # echo在""中引用变量
   > var1=1; var2=2
   > echo "hello $(var1), $var2"
   hello 1, 2
   # ''中变量不会被扩展
   > echo '$var1'
   $var1
   ```

   <!--more-->

   使用选项-e使用转义字符

   ```
   颜色输出：
   echo -e "\e[1;32m hello, world\!\e[0m"
   ```

   字体颜色码：

   重置=0,黑色=30,红色=31,绿色=32,黄色=33,蓝色=34,洋红=35,青色=36,白色=37。

   背景颜色码：

   重置=0,黑色=40,红色=41,绿色=42,黄色=43,蓝色=44,洋红=45,青色=46,白色=47。

2. printf

   类似于C语言的格式化输出

   ```shell
   > printf "hello %s" world!
   hello world!
   # 引用变量
   > printf "$var1, $(var2)"
   ```

需要注意，echo和prinf使用选项时需要出现在所有的字符串之前。

## 环境变量

使用pgrep查看进程的pid，然后可以据此查看该应用依赖的环境变量

```shell
> pgrep vim
15371
> cat /proc/15371/environ
....
```

变量赋值

```shell
# 可以直接赋值，需要注意'='两边没有空格
> var=value
> echo $var
value
> echo $(var)
value
```

使用export设置环境变量

```shell
HTTP_PROXY=192.168.1.23:3128
export HTTP_PROXY
```

默认情况下，Linux中包含很多环境变量

```shell
> echo $PATH， $HOME, $PWD
....
# 在环境变量中添加一条新的变量，注意使用':'分割
> export PATH="$PATH:/home/user/bin"
```

其他技巧

```shell
# 变量长度
> length=${#var}
# 当前使用的shell
> echo $0, $SHELL
zsh, /bin/zsh
# 当前用户是否为超级用户, root用户的uid为0
> echo $UID
0
```



## 算数计算

在bash shell中可以使用let，(( ))，[ ] 来执行基本的算数运算，而高级操作也可以使用expr和bc。

1. 整数运算

   当使用普通的赋值方法定义数值时，它会存储为字符串，我们可以使用let直接执行基本的算数运算

   ```shell
   > a=1
   > b=2
   # 使用let，变量名前无需添加$
   > let result=a+b
   > echo $result
   3
   # 自加、减
   > let a++
   > let b--
   # 简写
   > let a+=5
   ```

   [ ]和let的作用类似

   ````shell
   > result=$[ a + b ]
   # 当然，[ ]中也可以是使用$
   > result=$[ $a + b ]
   ````

   也可以使用(( ))，但是必须加上$

   ```shell
   > result=$(( a + 50))
   ```

   expr也可以运用在基本运算上

   ```shell
   > r1=`expr 3 + 4`
   > r2=$(expr $a + 5)
   ```



2. 浮点数运算以及其他

   bc是一个数学运算的高级工具，使用它可以进行浮点运算。

   ```shell
   > echo "4 * 0.56" | bc
   2.24
   ```

   设置精度

   ```shell
   > echo "scale=2;1/3" | bc
   0.33
   ```

   进制转换

   ```shell
   # 输入10进制，输出2进制
   > echo "obase=2;ibase=10;100" | bc
   1100100
   ```

   平方和平方根

   ```shell
   > echo "sqrt(100)" | bc
   > echo "10^10" | bc
   ```

## 文件描述符和重定向

文件描述符是和文件输入和输出相关联的整数，用来追踪已打开的文件。
    
* 0: stdin
* 1: stdout
* 2: stderr

1. 使用'>'对输入和输出进行重定向操作。

    ```shell
    > echo "hello world!" > a.txt
    > cat a.txt
    hello world!
    ```

2. 使用'>>'将内容追加到文本。

    ```shell
    > echo 'fuck x' >> a.txt
    > cat a.txt
    hello world!
    fuck x
    ```

    > 命令成功执行后，会返回0；执行失败则会返回非0的错误码。使用 'echo $?'可以查看上一个命令执行情况。

3. 当执行一个命令时，使用重定向仅仅是针对stdout，因此，当命令执行失败，其错误信息仍然会显示在终端。如果希望将stderr重定向：

    ```shell
    > ls no-such-file-in-this-dir >out.txt
    No such file balabala...
    > ls no-such-file-in-this-dir 2>out.txt
    > cat out.txt
    No such file balabala...
    ```

    可以同时将stdin和stderr绑定

    ```shell
    > cmd 2>stderr.txt 1>stdout.txt
    ```

    也可以将stderr绑定到stdout

    ```shell
    > cmd 2>&1 output.txt
    # 或者
    > cmd &> output.txxt
    ```

    如果不希望看到stderr，可以将其绑定到/dev/null

    ```shell
    > cmd 2>/dev/null
    # null 设备通常被称作黑洞
    ```

    > 需要注意的是，如果已经将stdout或者stderr进行重定向，那么就导致没有什么内容可以通过管道输出了

4. 数据重定向到文件同时提供副本作为后续命令的输入

    使用tee命令实现

    ```shell
    command | tee file1 file2
    # 例如：
    > cat a.txt | tee out.txt | cat -n
    # stderr 中的内容不会输出到out.txt中
    ```

    > tee命令在默认情况下，会将已存在的文件覆盖，使用参数 -a 可以进行追加

5. 使用stdin作为命令参数

    ```shell
    cmd1 | cmd2 | cmd -
    > echo who is this | tee -
    ```

6. stdin重定向

    ```shell
    cmd < file
    ```

7. 脚本内部的文本块重定向

    在cat \<\< EOF \> log.txt到EOF之间的内容都会作为stdin。 

    ```shell
    #!/bin/bash
    cat<<EOF>log.txt
    LOG FILE HEADER
    This is a test log file
    Function: System statistics
    EOF
    ```

8. 自定义文件描述符

    使用exec命令创建自己的文件描述符。

    ```shell
    # 创建一个文件描述符用于写入（截断）
    > exec 4 > out.txt
    > echo new-things >&4
    > cat out.txt
    new_things
    # 追加模式
    > exec 5 >> out.txt
    > echo haha >&5
    > cat out.txt
    new_things
    haha
    ```


## 数组与关联数组

1. 定义数组

   ```shell
   # 1
   array_var=(1 2 3 4 5)
   # 2
   array_var[0]="a"
   array_var[1]="b"
   ...
   ```

2. 数组访问

   ```shell
   # 所有的内容
   > echo ${array_var[*]}
   a b 3 4 5
   > echo ${array_var[@]}
   a b 3 4 5
   # 指定索引
   > echo ${array[1]}
   b
   > index=2
   > echo${array[$index]}
   2

   ```


3. 数组长度

   ```shell
   > echo ${#array_var[*]}
   5
   ```

4. 关联数组（bash 4.0+）

   实现原理为散列技术。

   ```shell
   # 首先声明
   > declare -A ass_array
   # 添加元素1
   > ass_array=([index1]=val1 [index2]=val2)
   # 添加元素2
   > ass_array[index1]=val1
   > ass_array[index2]=val2
   # indexn可以为apple也可以为123
   # 显示
   > echo ${ass_array[index1]}
   val1
   ```

5. 列出数组的索引

   ```shell
   > echo ${!array_var[*]}
   ```

6. 使用alias定义别名

   > 注意alias可能会导致安全问题，可以利用转义字符忽略可能存在的别名




## 获取终端信息

当前终端的相关信息，包括行数，列数、光标位置、密码等信息。有tput和stty两种终端处理工具。

1. 终端行数和列数

   ```shell
   tput cols
   tput lines
   ```

2. 终端名

   ```shell
   tput longname
   ```

3. 光标移动到目的位置

   ```shell
   tput cup x y
   ```

4. 设置终端背景颜色

   ```shell
   tputsetb n
   # 0 <= n <= 7
   ```

5. 设置文本粗体

   ```shell
   tput bold
   ```

6. 密码

   设置-echo禁止将输出发送到终端，echo允许；

   ```shell
   #!/bin/sh
   #Filename: password.sh
   echo -e "Enter password: "
   stty -echo
   read password
   stty echo
   echo
   echo Password read.

   ```

## 时间和日期



> 未完待续。。。

字符替换：

tr oldChar newChar

```shell
> echo ababab | tr 'a' 'b'
bbbbbb
```
