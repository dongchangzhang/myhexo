---
title: 从一道简单的题反思自己的思维定式
date: 2018-04-12 21:55:34
tags: algorithm
categories: 思考
---

今天在Project Euler上做了一道题，题目是这样的：

> If we list all the natural numbers below 10 that are multiples of 3 or 5, we get 3, 5, 6 and 9. The sum of these multiples is 23.
>
> Find the sum of all the multiples of 3 or 5 below 1000.


其实这是一道很简单的题，基本属于a+b类型的那一种。对于我，很直观的想法就是从1遍历到1000，对于每一个数判断这个数字是否是3或5的倍数。在O(n)的时间内完成计算。

<!--more-->

```cpp
int MultiplesOf3And5(int limit) {
    int sum = 0;
    for (int i = 0; i < limit; ++i) {
        if (i % 3 == 0 || i % 5 == 0) {
            sum += i;
        }
    }
    return sum;
}
```

虽然题目给出的是数据范围仅仅是1000，然而对于一个更大的数据范围呢，比如说10亿，一个O(n)实现的算法是否是适合呢？

我其实没有深入考虑到这一步，当我写完上面的代码就打算做下一道题目了。然而在阅读题目解析的时候发现才发现自己思维的不足。

对于这个题目来说，其实还可以这样分析：

> 计算1到1000中3和5倍数的加和等于3的倍数的加和和5的倍数的加和，然后减去多加的部分
>
> sum_3 = 3 + 6 + 9 + ... + 999 = 3 * (1 + 2 + 3 + ... + 333)
>
> sum_5 = 5 + 10 + 15 + ... + 199 = 5 * (1 + 2 + 3 + ... + 199)
>
> 多加的部分是15的倍数
>
> sum_15 = 15 + 30 + ... = 15 * (1 + 2 + ...)
>
> 因此
>
> sum = sum_3 + sum_5 - sum_15

```cpp
int bestSolution(int limit) {
    return sumDivisibleBy(3, limit) + sumDivisibleBy(5, limit) - sumDivisibleBy(15, limit);
}
int sumDivisibleBy(int n, int limit) {
    return n * (1 + (limit) / n) * (limit / n) / 2;
}

```

这样，对于任意范围的数据，只需要选择合适的数据类型，就能在O(1)的时间完成计算了。

我在做这道题的时候，想的过于简单，看完题习惯性的遍历一遍就得到了结果，相反进一步的思考这一个过程却被我忽略掉了。所以说，刷题也不能盲目的刷题，刷题不是目的，提高熟练程度、巩固算法基础、培养思维方式才是刷题过程中着重提高的（教科书版说教×_×）。