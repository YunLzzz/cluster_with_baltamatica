clear; clc

% 使用readmatrix读取xlsx文件，参考https://www.baltamatica.com/community/sposts/detail/331dda9a-a2b2-ee65-d526-a685c9a22475.html
data = readmatrix('D:/baltamatica/examples/多元统计/Rice_MSC_Dataset.xlsx', 'Range', '2:200');

% 提取特征数据（假设最后一列是类别）
X = data(:, 1:end-1);

% 检查并处理缺失数据
X = rmmissing(X);  % 删除包含NaN的行

% 进行数据标准化
X_normalized = (X - mean(X)) ./ std(X);

% 计算距离矩阵 (欧氏距离)
n = size(X_normalized, 1);  % 样本数
D = zeros(n);  % 初始化距离矩阵

% 手动计算欧氏距离
for i = 1:n
    for j = i+1:n
        D(i,j) = sqrt(sum((X_normalized(i,:) - X_normalized(j,:)).^2));  % 计算两点之间的欧氏距离
        D(j,i) = D(i,j);  % 距离矩阵是对称的
    end
end

% 初始每个样本是一个独立的簇
clusters = num2cell(1:n);  % 每个簇是一个元素，初始时每个簇只有一个样本
distances = D;  % 存储距离矩阵

% 定义最大簇数
max_clusters = 7;

% 进行层次聚类直到簇的数量达到目标
while length(clusters) > max_clusters
    % 找到距离矩阵中最小的距离
    [min_dist, idx] = min(distances(:));
    
    % 计算两个簇的合并
    [row, col] = ind2sub(size(distances), idx);
    
    % 合并这两个簇
    new_cluster = [clusters{row}, clusters{col}];  % 合并簇
    
    % 删除已合并的两个簇
    clusters(row) = [];
    if col > 1  % 确保列索引大于 1 才可以进行 col - 1
        clusters(col - 1) = [];  % 删除时需要调整列索引
    else
        clusters(col) = [];  % 如果 col 为 1，则直接删除 col
    end
    
    % 计算新的簇与其他簇的距离（最小距离）
    new_distances = min(D(row, :), D(col, :));
    
    % 更新距离矩阵
    distances(row, :) = new_distances;
    distances(:, row) = new_distances';
    
    % 删除已经合并的两行和两列
    distances(row, col) = Inf;  % 防止重新合并已经合并过的簇
    distances(col, row) = Inf;
    
    % 更新合并后的新簇
    clusters{row} = new_cluster;
end

% 最终每个簇的类别分配
final_clusters = zeros(n, 1);
for i = 1:length(clusters)
    final_clusters(clusters{i}) = i;  % 每个簇的样本标记为该簇的编号
end

% 使用主成分分析(PCA)进行降维
[coeff, score] = pca(X_normalized);

% 绘制二维散点图
figure;
scatter(score(:,1), score(:,2), 50, final_clusters, 'filled');
title('基于层次聚类的分类结果');
xlabel('第一主成分');
ylabel('第二主成分');
colorbar;
