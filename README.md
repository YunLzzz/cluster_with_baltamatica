# cluster_with_baltamatica
## 关于数据集

### 来源与处理

使用的是https://www.muratkoklu.com/datasets/中的Rice MSC Dataset.

| **Name** | **Data Types** | **Default Task** | **Attribute Types** | **Instances** | **Attributes** | **Year** |
| --- | --- | --- | --- | --- | --- | --- |
| **Rice MSC Dataset** | 5 Class | Classification Clustering | Integer, Real | 75.000 | 106 | 2021 |

由于北太天元的readmatrix功能无法读取同时带有数字和字母类型的数据，这里对最后一列的Class样本类别标签改为数值：

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
- 为了更快地得到聚类结果，这里使用'Range', '2:1000'选取数据集的前999个样本用于输入（第一行为表头），可以根据设备性能修改这一参数，

> 由于Rice MSC Dataset数据量较大，代码中聚类和主成分分析的计算量会随样本数的增加而骤增（容易得到，对于一个$m×n$维的样本，层次聚类的计算量是$O(m^2n)$，主成分分析的计算量是$O(mn^2 + n^3)$）。
>
