---
title: 22 Support Vector Regression
date: 2018-10-26 19:19:58
tags: 
    - 林轩田
    - video-note
categories: Machine Learning
toc: true
---

《机器学习技法》系列课程（六）

<!-- more -->

## Kernel Ridge Regression
我们在上一次的课程中已经证明了，任何一个带有L2正则化的线性模型，它的权重向量w都可以表示为原始数据经过特征转换后所在的Z空间的向量的线性组合，这也就意味着，任何一个带有L2正则化的线性模型都可以使用核函数（kernel function）来解决。

现在我们考虑我们常见的Regression问题，它使用平方误差函数作为loss，我们求解该问题往往直接求解其梯度为0时的方程就能直接获得结果。现在的问题是，我们该怎么做来将Kernel引入到这些回归问题中。

我们的Kernel ridge regression问题如下：

![krrp](1.png) 

我们可以直接将表达式中的w用βzn来替代，并改写为矩阵的表达形式：

![krrp-β](2.png) 

我们发现，现在的未知数只有β，我们的原始回归问题就转换为求解上述表达式最小化时β的取值，我们只需要对β求梯度即可：

![gradient](3.png) 

我们如果要最小化，那么则上述梯度为0，此时我们能够得到的一种可能的解：

![r](4.png) 

根据我们所学过的Mercer条件，我们可以知道上述表达式中的逆矩阵是一定存在的(K是半正定的)。此时计算该逆矩阵需要的时间复杂度是O(n ^ 3)，而且此时的矩阵是稠密的。下面是在相同资料中linear ridge regression和kernel ridge regression的表现：

![lrr and krr](5.png) 

其中左图是linear ridge regression的分类结果，右图是kernel ridge regression的结果。对于前者，它是线性模型，只能拟合直线，而且它的训练的复杂度是O(d ^ 3 + d ^ 2 \* N)，在预测时的复杂度只有O(d)，如果我们的数据量很大时（比模型复杂度更高）那么此时该模型的效率就会很高。对于后者，它是一个更灵活的模型，对于可能比前者的拟合效果更好，然而它的训练复杂度是O(N ^ 3)，预测的复杂度是O(N)，也就是说，数据量越多，无论训练还是预测，它都会更慢。因此对于大量的数据来说，该模型可能难以使用。

因此这两种方法相比，前者更高效，但是后者灵活性更高，学习能力更强！

## Support Vector Regression Primal
我们上面提到的kernel ridge regression也可以用来做分类，我们将这种方法叫做LSSVM。（least-squares SVM）。

我们现在比较使用soft-margin gaussian svm和lssvm两种方法用于分类时的区别：

![svm vs lssvm](6.png) 

这两种方法的分类边界是相似的，所不同的是svm中的支撑向量是有限的，而lssvm中几乎所有的点都是支撑向量（因为我们求解kernel ridge regression问题时，其参数β总是稠密的，所对应的都是支撑向量，而在计算svm时，其参数α是稀疏的，所以支撑向量的数码也是有限的），也正因为如此，计算lssvm将会带来巨大的代价。

我们现在需要考虑的是能不能寻找一种方法，lssvm中稠密的β变为稀疏的β，从而减少支撑向量的数目，降低计算的复杂度。

我们现在考虑一种新的方案：Tube Regression：

![tube regression](7.png) 

在这种方案中，它允许一个中立的缓冲区存在：在这个区间的点，我们认为它是对的，只有不在这缓冲区的点，我们才会考虑它所带来的错误。我们令这个缓冲区的宽度为2e，那么现在的err function就变成了如下形式，我们将其称为e-insensitive error：

![tube regression](8.png) 

现在我们需要做的就是根据svm的方法，来让l2-regularized tube regression的β参数变得稀疏。在做这件事之前，我们先对比我们现在的tube err和常用的平方误差的区别：

![tube and squared](9.png) 

我们可以将这两种err画在一张图上作比较：

![tube and squared](10.png) 

tube的成长更加缓慢，更不容易受到outliers的影响，由此我们可以推断tube err可能更好！

我们现在要解决的问题变为：

![q](11.png) 

它没有约束条件，但是难以微分，所以也很难用梯度下降的方法来寻找最优解。此外，尽管我们能够使用核函数来替代w，但是这也并不能保证参数β的稀疏性。我们回顾SVM问题：它的最优化问题是不能微分的，但是它可以使用二次规划（QP）来求解，可以使用对偶和核函数，通过KTT条件，最终保证了参数的稀疏性。现在我们将仿照标准的SVM的方法来解决这个tube regression问题，如下：

![q](12.png) 

通过变换，变形为QP问题：

![q](13.png) 

其中参数C表示的是regularization和tube violation之间的权重比，C越大，则tube violation更重要，否则则是正则化更重要。e是中立区间的宽度，是该svr问题中独有的参数。此外svr中的参数有d~ + 1 + 2N，而限制条件有4N个。

## Support Vector Regression Dual


## Summary of Kernel Models

> 文章内容和图片均来自“国立台湾大学林轩田老师”的《机器学习技法》课程！

--- END --- 
