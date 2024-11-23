clear; clc
tic
% 使用readmatrix读取xlsx文件
data = readmatrix('D:/baltamatica/examples/多元统计/Rice_MSC_Dataset.xlsx', 'Range', '2:1000');
toc
% 提取特征数据和真实类别标签（假设最后一列是类别）
X = data(:, 1:end-1);  % 特征数据
true_labels = data(:, end);  % 真实类别标签

% 检查并处理缺失数据
X = rmmissing(X);  % 删除包含NaN的行，如果你希望保留这些行，可以考虑使用插值方法填补缺失值

% 进行数据标准化
X_normalized = (X - mean(X)) ./ std(X);

% 检查标准化后是否存在NaN
if any(isnan(X_normalized(:)))
    disp('标准化后的数据中存在NaN，请检查数据是否正确');
    return;
end

tic
% 使用Ward连接法进行层次聚类，分5类
T = clusterdata(X_normalized, 'Linkage', 'ward', 'Maxclust', 5);
toc

tic
% 使用主成分分析(PCA)进行降维
[coeff, score, latent, ~, explained] = pca(X_normalized);
toc

% 输出每个主成分的贡献度
disp('每个主成分的贡献度（方差解释比例）：');
disp(explained);
toc

% 为每个聚类统计真实类别标签的分布
cluster_stats = zeros(5, 3);  % 存储每个聚类的统计信息：[最多的真实类别标签, 出现次数, 占比]

% 初始化用于存储每次循环的累积值
total_max_count = 0;
total_length = 0;

for i = 1:5
    % 获取属于第i类的样本索引
    idx = T == i;
    
    % 获取属于第i类的真实标签
    cluster_true_labels = true_labels(idx);
    
    % 获取真实标签的唯一值和对应的出现次数
    unique_labels = 1:5;  % 假设真实标签范围为1到5
    label_counts = zeros(size(unique_labels));  % 初始化计数数组
    
    % 遍历每个标签，计算出现次数
    for j = 1:length(unique_labels)
        label_counts(j) = sum(cluster_true_labels == unique_labels(j));
    end
    
    % 找到出现最多的标签及其出现次数
    [max_count, max_index] = max(label_counts);
    
    % 计算该标签的占比
    proportion = max_count / length(cluster_true_labels);
    
    % 记录统计结果：最多的标签，出现次数，占比
    most_frequent_label = unique_labels(max_index);  % 使用真实标签来确定最多的标签
    cluster_stats(i, :) = [most_frequent_label, max_count, proportion];
    
    % 累加max_count和length(cluster_true_labels)
    total_max_count = total_max_count + max_count;
    total_length = total_length + length(cluster_true_labels);
    
    % 输出统计信息（调试用）
    %disp(['聚类类别 ' num2str(i) ' 的真实标签分布：']);
    %disp(['标签出现次数：' num2str(label_counts)]);
    %disp(['最多的标签：' num2str(most_frequent_label)]);
    %disp(['出现次数：' num2str(max_count)]);
    %disp(['占比：' num2str(proportion)]);
end

score = total_max_count / total_length

% 绘制三维散点图
figure;
hold on;  % 保持图形，以便绘制所有类别
colors = lines(5);  % 获取5种颜色

% 绘制所有聚类
for i = 1:5
    % 获取属于第i类的样本索引
    idx = T == i;
    
    % 使用scatter3绘制第i类的点，使用分配的颜色
    scatter3(score(idx, 1), score(idx, 2), score(idx, 3), 50, 'MarkerFaceColor', colors(i,:), 'MarkerEdgeColor', 'k');
    
    % 提取统计信息
    most_frequent_label = cluster_stats(i, 1);  % 最多的真实标签
    max_count = cluster_stats(i, 2);  % 该标签的出现次数
    proportion = cluster_stats(i, 3);  % 该标签的占比
    
    % 在图中标注该信息
    text(mean(score(idx, 1)), mean(score(idx, 2)), mean(score(idx, 3)), ...
        sprintf('类 %d: 标签 %d, 占比 %.2f', i, most_frequent_label, proportion), ...
        'FontSize', 10, 'Color', 'black');
end

hold off;  % 结束保持图形
title('层次聚类的分类结果');
xlabel('第一主成分');
ylabel('第二主成分');
zlabel('第三主成分');
