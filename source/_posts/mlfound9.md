---
title: 机器学习基石（九）
date: 2018-10-11 22:06:54
tags: machine learning
categories: ML
---

## 09 Linear Regression
我们一直在讨论分类问题，并利用分类问题推导了VC Bound以及Learning的可行性问题。Learning任务中也存在很多输出空间是连续的情形，实际上VC Bound同样使用在这些问题上，这一节讨论线性回归问题。
<!-- more -->
### Linear Regression Problem
在我们讨论信用卡发放问题时，我们一直以来的输出都是是或者否的输出空间，如果我们在解决这个问题时，要求输出是一个人的信用程度，我们将根据这个信用程度来决定是否发放信用卡的时候，我们将要解决的问题就是回归问题。
那么我们的Hypothesis Set应该是什么样的，才能输出连续的内容呢？我们可以考虑为每一个维度的输入属性乘以权重，最终我们找到一个合适的权重向量来实现对信用的预测：
```
# 设输入x为
x = (x1, x2, x3, ..., xd)
# 权重向量w为
wT = (w1, w2, w3, ..., wd)
# 那么
y about= sum(wi * xi) (i from 0 to d)
# 转换为向量运算：
h(x) = wT * x
```
上面的h(x)和Perceptron是很类似的，区别是后者有sign函数，将每个数值取为了正负1。
那么Linear Regression在空间中是什么样子的呢？在二维空间中，它是一条直线，而在三维（或高维）空间中，则是一个超平面。我们的Learning任务，实际就是在寻找这条（个）直线（超平面）。

在回归问题中，一般使用平方误差（Squared error）作为Error的衡量方法，即数据在Learning后输出的结果和实际结果差值的平方。这个方法可以同时用在Ein和Eout上。Learning的过程就是最小化这个Squared Error的过程。
### Linear Regression Algorithm

### Generalization Issue

### Linear Regression for Binary Classification


> 文章内容和图片均来自“国立台湾大学林轩田老师”的《机器学习基石》课程！

--- END --- 
