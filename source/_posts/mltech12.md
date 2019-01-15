---
title: 28 Neural Network
date: 2018-11-22 13:23:55
tags: ML
---

《机器学习技法》系列课程（十二）
<!-- more -->

## Motivation
我们已经了解了Perceptron，将多个Perceptron进行线性组合，其数学表示为：

<div align=center> ![](1.png) </div>

其包含两层权重:wt和αt。此时它能够实现更复杂的边界划分，比如，它能够实现AND、OR、NOT等边界的划分。

实际上，如果我们使用更多数量的Perceptron，它的能力会更强，这也是Aggregation的特性之一，同样，模型的复杂度也会变大，会更容易overfitting。如果我们想要使用Perceptron去构造一个圆形边界的分类器，当使用了足够多的Perceptrons，其将会逼近一个平滑的边界。

然而，局限在于，简单的Perceptron的融合无法实现XOR，因为XOR的数据并不是线性可分的，这就导致我们根本不能使用Linear Aggregation Models。

那么该怎么做呢？可以使用多层感知机（MLP）——既然单层的Perceptron不能区分，那就继续做特征转换。MLP的能力要比简单地把Perceptron融合（Aggregation）在一起的能力更强大。这从生物学的角度类似与神经网络的信号处理。


## Neural Network Hypothesis
我们首先来看神经网络的输出部分。它的最后一层运算只是一个线性的运算，任何一种线性模型都可以运用到这个地方：线性分类、线性回归、逻辑回归等。

为了简单起见，接下来我们仅仅讨论最后一层使用线性回归（Regression）的神经网络（使用平方误差函数）。

然后我们看神经网络中间部分。此时它并不能使用任意的激活函数。首先，我们不能使用线性的激活函数，如果我们使用了，我们又何必将模型搞得这么复杂但是最后能力却很差。同样，也很少使用sign函数，因为这个函数的输出是离散的，它的值域为{-1， 1}，所以它是不可导的，从而导致很难最佳化。很多情况，我们使用tanh：

<div align=center> ![](2.png) </div>

它与逻辑回归中的函数θ（sigmoid）很像，tanh(x) = 2θ(2x) - 1，即相当于对sigmoid进行放缩。

神经网络实际上就是输入向量x，经过多个隐含层，其中每一个隐含层的输出都作为下一个层的输入，最终预测得到结果y。在这个过程中，我们可以将每一个层都看作是在做特征转换，它从数据中学习到这个转换。而转换的关键在于每一层的权重weight。神经网络可以看作是每一层都在做Pattern extraction。


## Neural Network Learning
那么该如果学习权重weight呢？我们的目标是学习到合适的权重最小化最终的Ein，如果我们的神经网络只有一个隐含层，实际上它就是一个对Perceptron进行简单的Aggregation，那么我们可以使用Gradient Boosting来决定每一个神经元。如果是MLP呢，就不这么简单了。我们一般采用链导法则来计算梯度，从而使用梯度下降的方法完成这个任务。

神经网络的Error可以表示如下：

<div align=center> ![](3.png) </div>

对于最后一层的输出，其error关于对应weight的偏导数，以及任意一个神经元的偏导数可以表示为如下：

<div align=center> ![](4.png) </div>

其中sn代表当前神经元的输入。对于任意神经元，其中我们用δj来表示当前神经元的偏导数。很容易知道：

<div align=center> ![](5.png) </div>

那么对于其他任意神经元的δj该怎样表示呢？首先我们看相邻的输入si的关系：

<div align=center> ![](6.png) </div>

由此，我们可以推导相邻层的导数关系如下：

<div align=center> ![](7.png) </div>

这也就说明了当前层相对于误差的导数可以从后一层的传播（误差反向传播）。

最后，我们总结误差反向传播算法：

<div aling=center> ![](8.png) </div>

值得注意的是，1到3是可以并行执行很多次然后计算一个平均来执行4——这也就是mini-batch。


## Optimization and Regularization

在神经网络中最小化Ein可以使用梯度下降方法。然而多层神经网络可能存在很多个极小值，这也就是说，在最优化时获得的解可能只是局部最优解而非全局最优解。通过初始化不同的weight，我们可能会到达不同的local minimum。所以为了能够获得更好的结果，一个建议是尽可能随机选取weight，而且使用较小的初始权重(如果开始的权重很大，由于tanh的存在，梯度可能会很小，每一次只能走很小的步子)。

此外，我们从VC维度的角度来看神经网络，使用tanh的Neural Network，其vc dimension等于O(VD)，其中V=神经元的数目，D=权重的数目。我们使用多层神经网络，一方面能够拟合”anything“，另一方面，如果神经元数目过多也会造成过拟合。解决过拟合我们就需要weght-decay regularizer。

但是如果使用L2 regularizer，会把所有的权重变小，但是所有权重都不会为0。我们需要更稀疏的权重来更有效地降低模型复杂度。但是由于L1 regularizer在部分点上不可导，所以也不能使用。

解决这个问题一般有两个选择：1是在L2的基础上添加缩放；2是早一点结束训练过程，优化过程不要持续那么久。

<div align=center> ![](9.png) </div>

> 文章内容和图片均来自“国立台湾大学林轩田老师”的《机器学习技法》课程！

— END —