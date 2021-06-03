---
title: LinuxShell1 - 基础内容
date: 2018-04-16 21:55:18
tags: Shell
categories: Linux
toc: true
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

1. 获取日期

   ```shell
   > date
   Tue Apr 17 08:48:40 CST 2018
   ```

2. 纪元时

   UTC，又称为世界标准时间或者世界协调时间。unix人文UTC1970年1月1日0点是纪元时间，也被成为posix时间

   ```shel
   # 获取纪元时
   > date +%s
   # 将日期字符串转换为纪元时
   > date --date "Thu Nov 18 08:07:21 IST 2010" +%s
   1290047841
   ```

3. 格式输出

   ```shell
   # 结合 '+' 
   > date "+%d %B %Y"
   20 May 2010
   # 星期 %a (Sat) %A (Saturday)
   # 月 %b (Nov) %B (November)
   # 日 %d
   # mm/dd/yy  %D
   # 小时 、、、、、、、、、、%I  %H
   # 分钟 %M
   # 秒 %S
   # 纳秒 %N
   # Unix纪元时  %s
   ```

4. 设置时间

   ```shell
   > date -s "格式化的时间日期"
   ```

5. 时间间隔

   ```shell
   start=$(date +%s)
   ...
   end=$(date +%s)
   difference=$(( end - start ))
   ```

6. 延时

   ```shell
   sleep n
   ```

## 脚本调试

1. 使用-x对脚本跟踪调试，此时会打印出每一条指令以及其输出结果

   ```shell
   > bash -x x.sh
   ```

2. 利用set -x 和 set +x 局部调试

   * set -x：执行时显示参数和命令
   * set +x：禁止调试
   * set -v：命令进行读取时显示输入
   * set +v：禁止打印输入

   ```shell
   #!/bin/bash
   # test debug
   for i in {1..6}
   do
   	set -x
   	echo $i
   	set +x
   done
   ```

3. 通过传递环境变量

   ```shell
   #!/bin/bash
   function DEBUG()
   {
   # $1 $2... 访问第n个参数
   # $@ 一次性访问所有参数 = "$1" "$2" ...
   # $* 类似$@ 但是参数被当做单独的个体 = "$1$2..."
   [ "$_DEBUG" == "on" ] && $@ || :
   }
   for i in {1..10}
   do
   DEBUG echo $i
   done
   ```

   设置_DEBUG来运行脚本

   ```shell
   > _DEBUG=on ./x.sh
   ```

4. 使用shebang

   将#!/bin/bash替换为#!/bin/bash -xv


## 函数

1. 定义函数

   ```shell
   # 方式1
   function fname()
   {
       statements;
   }
   # 方式2
   fname()
   {
       statements;
       # 可以包含返回值
       return 0;
   }
   ```

2. 函数调用

   ```shell
   # 直接使用函数名
   > fname; # 执行fname
   ```

3. 参数传递

   ```shell
   # 参数以空格分割，跟在函数名后面
   > fname arg1 arg2 ...
   ```

4. 参数获取

   * $n：访问第n个参数
   * $@：以列表的方式一次性打印所有的参数
   * $*：访问所有的参数，被当做一个整体

5. 递归函数

   ```shell
   F() { echo $1; F hello; sleep 1; }
   ```

   > fork炸弹：
   >
   > ```shell
   > :() { :|:& }; :
   > ```
   >
   > 该函数不断递归自身，不断生成新的进程，最终造成拒绝服务攻击。

6. 导出函数

   函数像环境变量一样用export导出，扩大作用域到子进程中

   ```shell
   export -f filename
   ```

7. 获取函数返回值

   $?返回上一条命令的返回值

## 比较与判断

基本格式

```shell
if condition;
then
	commands
else if condition;
then
	commands
else
	commands
fi
```

1. 判断简化

   ```shell
   [ condition ] && action; # condition为真，执行action
   [ condition ] || action; # condition为假，执行action
   ```

2. 算数比较

   条件放在中括号中，注意空格

   ```shell
   [ $var -eq 0 ] # 两边一定有空格， 当var=0， return 1； else return 0
   ```

   * 大于：-gt
   * 小于：-lt
   * 大于等于：-ge
   * 小于等于：-le
   * 逻辑与：-a
   * 逻辑或：-o

3. 文件系统测试

   ```shell
   [ -f $file ]: file 是文件
   [ -x $file ]: file 可执行
   [ -d $file ]: file 是目录
   [ -e $var ]: var 包含文件
   [ -c $var ]: 是一个字符设备文件
   [ -b $var ]: 是一个块设备
   [ -w $var ]: 可以写
   [ -r $var ]: 可以读
   [ -L $var ]: 是一个符号链接
   ```

4. 字符串比较

   字符串比较最好使用 [[ ]]

   ```shell
   [[ $str1 op $str2 ]] # op : ==; !=; >; <
   [[ -z $str ]] # str 空吗？
   [[ -n $str ]] # str 非空吗？
   ```

5. 逻辑运算

   使用 && 或 || 可以组合条件；

   test命令可以避免括号

   ```shell
   if test $var -eq 0; then echo yes; fi;
   # 等价于
   if [ $var -eq 0 ]; then echo yes; fi;
   ```

   ​

## 循环

1. while

   ```shell
   while 条件
   do
   	statements
   done
   ```

2. for

   ````shell
   # type1
   for var in list # list是字符串或者序列
   do
   	commands
   done
   # type2
   for ((i=0; i<10;++i)) { echo $i; }
   ````

   生成序列的方法

   ```shell
   #1
   > echo ${1..50} 
    1 2 3 4 .. 50
   #2 
   > echo {a..z}
    a b c .. z
   ```

3. until

   ```shell
   x=0
   until [$x -eq 9 ];
   do
   	let x++; echo $x
   done
   ```

   ​
## 向脚本传递命令行参数
我们希望向下面这个脚本中传递参数
```shell
#!/bin/bash

# script name is a.sh

for x in $*
do
    echo $x
done
```
 参数传递方法如下：
```shell
> ./a.sh a b c d e
a
b
c
d
e
```
## 小技巧

1. 利用()定义一个子shell

    ```shell
    > pwd
    dir1
    > (cd /bin; ls)
    somethings in /bin
    > pwd
    dir1
    ```

2. read命令

    read可以实现不按回车读取数据

    read  参数 var

    * -n : 读取n个字符存入var
    * -s： 无回显方式读取密码
    * -p：显示提示信息
    * -t：特定时间内读取
    * -d：特殊符号作为输入结束

3. 执行直至成功

    ```shell
    repeat() { while true; do $@ && return; done }
    # 更快
    repeat() { while :; do $@ && return; done }
    ```

4. 字段分隔符

    内部字段分隔符IFS

    ```shell
    #!/bin/bash
    a="1:2:3"
    oldIFS=$IFS
    IFS=":"
    for i in $a
    do echo $i
    done

    # 输出
    1
    2
    3
    ```

5. 字符替换：
    tr oldChar newChar
    
    ```shell
    > echo ababab | tr 'a' 'b'
    bbbbbb
    ```


> 参考：Linux Shell脚本攻略　第一章
