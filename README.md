# cluster_with_baltamatica

简单介绍一下，这是一个面向本科生多元统计课程的结课作业的开源程序库，使用北太天元编写（当然在Matlab上也可以跑通），用来复现结课论文中的数据结果，并展示我们的工作量hhh

库中的`cluster_using_toolbox.m`是用来复现的简洁版程序，`cluster_for_debug.m`是用来调试的程序，相对于前者注释和测试用的代码更多，但效果是一样的。还有一个`cluster_raw.m`是不使用北太天元工具箱的版本，直接用最基础的代码通过基本计算实现聚类过程。程序用到的数据集需要按照下面的攻略自行下载并修改，Github网页版有上传文件的大小限制所以没有传上来...除此之外后续还会上传更多markdown格式的笔记，有关结果分析、使用北太天元的体验等。

这也是笔者上传的第一个Github文件，如有不妥之处多多见谅哈！

## 关于数据集

### 来源与处理

使用的是https://www.muratkoklu.com/datasets/ 中的Rice MSC Dataset.

| **Name** | **Data Types** | **Default Task** | **Attribute Types** | **Instances** | **Attributes** | **Year** |
| --- | --- | --- | --- | --- | --- | --- |
| **Rice MSC Dataset** | 5 Class | Classification Clustering | Integer, Real | 75.000 | 106 | 2021 |

这里是下载链接：https://www.muratkoklu.com/datasets/vtdhnd08.php

由于北太天元的`readmatrix`功能无法读取同时带有数字和字母类型的数据，**这里需要先将最后一列的`Class`样本类别标签改为数值：**

```matlab
Basmati→1
Arborio→2
Jasmine→3
Ipsala→4
Karacadag→5
```

### 数据集的输入

```matlab
data = readmatrix('D:/baltamatica/examples/多元统计/Rice_MSC_Dataset.xlsx', 'Range', '2:1000');
```

- 修改'Rice_MSC_Dataset.xlsx'为你的数据集存储路径
- 为了更快地得到聚类结果，这里使用`'Range', '2:1000'`选取数据集的前999个样本用于输入（第一行为表头），可以根据设备性能修改这一参数

>由于Rice MSC Dataset数据量较大，代码中聚类和主成分分析的计算量会随样本数的增加而骤增（容易得到，对于一个 $m×n$ 维的样本, 层次聚类的计算量是 $O(m^2n)$ ，主成分分析的计算量是 $O(mn^2 + n^3)$ ）

**完成上述的两步修改以后`cluster_using_toolbox.m`就可以跑通啦**，想要调整聚类后得到的类别数量和更改类间距离的度量方法可以参考下面：

## 系统聚类法中的参数

### 目标类别数

```matlab
class_num = 5;
```

### 类间距离

```matlab
T = clusterdata(X_normalized, 'Linkage', 'ward', 'Maxclust', class_num);
```
在 `clusterdata` 函数中，可通过修改第三项参数来实现不同的类间距离测量方法

- `'ward'`：离差平方和法
- `'single'`：最短距离法
- `'complete'`：最远距离法
- `'average'`：类平均法
- `'centroid'`：重心法
- `'median'`：中位数法
