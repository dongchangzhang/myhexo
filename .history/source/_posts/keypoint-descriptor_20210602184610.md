---
title: 特征提取过程中的keypoints和descriptors
date: 2018-04-09 17:39:12
tags: opencv
---

在使用SIFT、SURF、ORB等方法对图片进行特征提取和匹配的过程中，基本的工作过程大致如下：

1. 从图片中提取keypoints；
2. 根据keypoints获取特征描述符descriptors；
3. 依据获取的特征描述符对待匹配的两张或多张图片进行特征匹配；
4. 对匹配结果进行筛选，得到匹配效果比较好的特征点；
5. 开始后续的工作...

<!--more-->

那么，什么是keypoints和descriptors，以及keypoints和descriptors有什么关系和区别，在特征匹配过程为什么要使用descriptors呢？

首先，在特征提取之后，我们所获得的是特征的位置信息，或者是近似圆形、椭圆形的区域，这也就是我们所得到的keypoints，但是其仅仅包含了位置信息，这些位置信息不足以描述特征，也没有足够的信息用来对特征进行匹配；

而对于这些常见的特征提取算法，如SIFT、SURF、ORB等，其提取后获得的keypoints通常位于突出的角点、斑点、边，仅仅利用位置信息并不能完整描述特征。

我们可以看这样两个例子：

1. 已有图片1，图片的内容是一只熊，其背景是纯白色。而另一只图片2是仅仅对图片1的少部分像素做了处理后得到的图片，那么对这两张图片中的熊提取了特征以后，得到的keypoints应该是相同的，这两张图片应该被认为是相同或者相似的。但是如果我们得到的仅仅是位置信息，那么当两张图片中的像素位置改变以后，我们就无法继续对这两张图片进行比较了。
2. 同样有图片1，图片1里现在是一只鸭子，而图片2中的内容则是图片1中的鸭子放大两倍以后的鸭子。此时提从两张图片取出来的keypoints相对于两张图片中的鸭子来说是相同的，因此这两张图片仍然是相同或者说是相似的。但是所不同的是图片2中的keypoints的size是图片1中的2倍，而仅仅使用这些位置信息来完成这次比较仍然很困难。

因此，在特征比较过程中我们就需要使用另外一种特征表示方式descriptors。它使用vector表示keypoints中的每一个特征点的特征，它包含了每个特征的强度、方向等信息。而descriptor包含如下的特性：

1. descriptor与位置信息是相互独立的，对于不同位置的同一个特征，二者的descriptor是相同的。
2. descriptor具有健壮性，图片变换（亮度、旋转、平移等）不会影响到特征的识别。但是需要注意的是，没有绝对的健壮性。对于不同的图像变换，可能需要不同设计的descriptor来抵抗图片变换所造成的影响。
3. descriptor不受图像缩放的影响。两个不同尺寸的同样的特征，应该视为相同的。


现在我们就可以使用计算得到的descriptors来比较keypoints，当然匹配方法有很多种。而descriptor是数字的向量,你可以用一些比较简单的欧式距离，或者也可以使用一些更复杂的距离作为相似性度量的方法。




> reference:
>
> 1. [Meaning of keypoints and Descriptors](http://answers.opencv.org/question/37985/meaning-of-keypoints-and-descriptors/)
> 2. [stackexchange.com](https://dsp.stackexchange.com/questions/10423/why-do-we-use-keypoint-descriptors)