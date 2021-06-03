---
title: 11 Linear Models for Classification
date: 2018-10-13 18:06:14
tags: ML
categories: ML
---

《机器学习基石》系列课程（十一）

 本章将从我们学过的Binary Classification出发，来看一看我们学过的Model怎样完成如Multiclass Classification等更复杂的任务。

<!-- more -->

## Linear Models for Binary Classification
我们已经学习了3个Linear Model，他们的共同点是都计算了一个分数：向量wT和向量x的乘积。

对于Linear Classification问题，计算的分数需要经过一个sign函数，从而得到{-1， +1}内的结果，它的Error Function是0/1的。我们之前也学习过，在这个问题中我们要找一个最佳的分类结果是很难的，它是一个NP Hard的问题。
对于Linear Regression问题，算出的分数没有经过任何处理，直接输出作为我们的结果，它的Error Function是一个平方误差函数，对于这一种问题我们有非常简单完美的解决方案来寻找一个很好的解。

对于Logistic Regression问题，我们计算的分数通过了一个sigmoid函数，也就是一个S形曲线，从而得到一个0和1之间的结果，也就是需要的概率数值。我们使用cross-entropy error作为误差函数，并且通过梯度下降（Gradient Descent）的方法找到最优解。

那既然Linear Classification问题解决起来是一个NP问题，我们能不能使用Linear Regression或者Logistic Regression来解决线性分类问题呢？

也就是说，不论对我们的Linear Regression还是Logistic Regression来说，我们都将其输出限制为{-1， +1}。当然对于Logistic来说，它本来就是用来分类的，这是一件容易办到的事。而{-1，+1}只是两个特别的实数，那么直观看起来Linear Regression也是可以做到的。

在我们想办法解决这件事之前，我们首先将这三者的Error Function先整合统一起来：
<div align=center> ![error](1.png) </div>

下面我们就来看看这些Error Function和ys的关系是怎样的。我们先看看ys的物理意义是什么：y代表正确性， s代表分数。我们希望其值越大越好，越大表示越好，y是正数表示是正确的，否则表示是不正确的。我们想办法把Error Function画在平面上，我们令横轴是ys纵轴是error：

<div align=center> ![error image](2.png) </div>

对于线性分类算法，其表现为蓝色的线，而线性回归则表现为红色的线。我们可以看到在ys小的时候（小于2），其表现很好，但是在比较大的时候，比如ys=3时，它会认为err很大，但实际上在分类任务上是一个较好的情况。对于逻辑回归问题，我们一般将其进行一个换底的操作将其error曲线进行缩放，即把ln换成log2，从而能够得到如图那样的结果：一个恰好在0/1error上方的error。

实际上也就是说通过缩放的Logistic Error和Linear Regression Error是0/1Error的一个上界：

<div align=center> ![upper bound](3.png) </div>

从而，如果我们能把logistic中的error求的很好，对于0/1问题我们也能做的不错！当然我们用平方误差也符合，只不过linear regression的error是一个更宽松的上界。

现在做一个总结：
1. 使用PLA进行线性分类是一件有效的事，但是前提是数据必须线性可分，否则我们就需要使用Pocket算法。
2. 使用linear regression也能实现分类，而且是最容易得出结果的，但是由于它的error的上界比0/1error的上界高很多，所以它的精确度没那么高。
3. 对于logistic regression，它是比较容易求解的，不过它的error同样是0/1error的一个上界，只不过比linear regression要好一些。

所以linear regression有时候可以作为PLA、Pocket、Logistic Regression的出事向量求解的方法。此外Logistic Regression一般要比Pocket表现的要好。

## Stochastic Gradient Descent
我们学习过两种通过一次次迭代来进行优化的方案：一种是PLA方法，每次都通过更新来寻找一个更好的向量w；另一种是在Logistic Regression中使用的梯度下降的方法。
然而，我们知道在数据是现行可分的情况下PLA算法的迭代过程是非常快的，由于每次使用一个错误的点，每一次迭代的时间复杂度是O(1)的，但是逻辑回归则需要检查所有的数据才能进行一轮迭代，即为O(n)的时间复杂度。那么该怎样提高逻辑回归中Gradient Descent的效率呢？

<div align=center> ![gd](4.png) </div>

我们一个方法就是去掉求和，随机选取一个点来进行Gradient Descent，即Stochastic Gradient Descent(SGD)。

<div align=center> ![sgd](5.png) </div>

我们把真是的梯度换为随机的梯度，那么在足够多的迭代次数之后，平均的随机梯度和平均的真是梯度是大致相等的。SGD很简单而且计算量少，在大数据和在线学习上有很大的用处，缺点是不太稳定。

实际在PLA上我们就用了类似的方法：每次选一个错误点来更新w。我们的SGD Logistic Regression更像是一个‘soft’ PLA。

但是我们使用SGD还需要考虑两个问题：
1. 算法何时能够停止？
Gradient Descent在求得梯度为0时可以停止，但是SGD很难得到梯度为0的位置。一般都认为如果运行的时间足够长就可以停止了。
2. 学习率η取什么数值？
这个问题后续还有讨论，但是如果没有什么想法，0.1可能是合适的。

## Multiclass via Logistic Regression
接下来我们着重关注多分类（Multiclass）问题。
假设我们现在有一些数据，它们属于不同的类别（类别不止2两个），此时该如何分类呢？
我们一直学习的都是二分类问题，现在我们把我们学习过的方法延伸到多分类上。

我们可以一次只分一个类别：只将一个类别当成是正类，其他都当成负类。这样重复多次，就能实现多分类问题，其中每个子问题都是一个二分类问题。

但是此时就会有一个问题，如果在不同的分类中都说某一部分是属于其类别的，即分类结果会产生某些属于多个类别的该怎么办呢？

我们可以“softly”产生每一个类别，看每个数据属于每一个类别的概率是多少，最后根据概率来决定类别。我们可以使用Logistic regression来实现。

我们将这种方法成为One-Versus-All（OVA），这是有效的方法，但是如果某种类别数码较小但是总数很大的时候，往往会造成不均衡，此时可能就会导致Logistic regression都选择占比较大的类别，当然这里没有强调各种概率的加和得1这个问题，如果通过了处理可能能够得到更好的结果。


## Multiclass via Binary Classification
在上面我们提到了如果数据是不均衡的，那么 OVA将会导致坏的结果。所以，我们想在尝试one versus one，即一对一的来求解：
现在我们尝试只对其中的两个类别分类，忽略其他类别，比如，我们现在需要最圈圈、叉叉、正方形、星星来进行分类。我们先对圈圈和叉叉分类，求得一根直线，直线的一侧是叉叉，另一侧是圈圈。同理通过6次分类，我们就能得到所有的分类结果。根据上述的分类结果综合起来，就能判定属于各类别的区域了。这类似于循环赛，通过多次比赛来决定最优的预测。
这种方法称为one versus one（OVO）。这种方法效率很高，资料数量需要少，可以和binary classification搭配使用。但是坏处是需要花费更多的时间和空间。

> 文章内容和图片均来自“国立台湾大学林轩田老师”的《机器学习基石》课程！


--- END ---