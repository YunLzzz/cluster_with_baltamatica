clear; clc
% 读取数据
data = readmatrix('D:/baltamatica/examples/多元统计/Rice_MSC_Dataset.xlsx', 'Range', '2:1000'); 
X = data(:, 1:end-1);
true_labels = data(:, end); 
% 聚类目标类别数（超参数）
class_num = 5;
% 数据预处理
X = rmmissing(X);
X_normalized = (X - mean(X)) ./ std(X);

% 聚类（在这里修改聚类方法）
T = clusterdata(X_normalized, 'Linkage', 'ward', 'Maxclust', class_num);

% 降维：主成分分析
[coeff, score, latent, ~, explained] = pca(X_normalized);
disp('每个主成分的贡献度（方差解释比例）：');
disp(explained);

% 验证聚类效果
total_max_count = 0;
total_length = 0;
cluster_stats = zeros(class_num, 3);
for i = 1:class_num
    idx = T == i;
    cluster_true_labels = true_labels(idx);
    unique_labels = 1:class_num;
    label_counts = zeros(size(unique_labels));
    for j = 1:length(unique_labels)
        label_counts(j) = sum(cluster_true_labels == unique_labels(j));
    end
    [max_count, max_index] = max(label_counts);
    proportion = max_count / length(cluster_true_labels);
    most_frequent_label = unique_labels(max_index);
    cluster_stats(i, :) = [most_frequent_label, max_count, proportion];% 记录统计结果：最多的标签，出现次数，占比 
    %total_max_count = total_max_count + max_count;
    %total_length = total_length + length(cluster_true_labels);
    % 输出统计结果（调试用）
    %disp(['聚类类别 ' num2str(i) ' 的真实标签分布：']);
    %disp(['标签出现次数：' num2str(label_counts)]);
    %disp(['最多的标签：' num2str(most_frequent_label)]);
    %disp(['出现次数：' num2str(max_count)]);
    %disp(['占比：' num2str(proportion)]);
end
%score = total_max_count / total_length % 计算加权平均后的占比

% 绘制三维散点图
figure;
hold on;
colors = lines(class_num);
for i = 1:class_num
    idx = T == i;
    scatter3(score(idx, 1), score(idx, 2), score(idx, 3), 50, 'MarkerFaceColor', colors(i,:), 'MarkerEdgeColor', 'k');
    most_frequent_label = cluster_stats(i, 1);
    max_count = cluster_stats(i, 2);
    proportion = cluster_stats(i, 3);
    text(mean(score(idx, 1)), mean(score(idx, 2)), mean(score(idx, 3)), ...
        sprintf('类 %d: 标签 %d, 占比 %.2f', i, most_frequent_label, proportion), ...
        'FontSize', 10, 'Color', 'black');
end
hold off; 
title('层次聚类的分类结果');
xlabel('第一主成分');
ylabel('第二主成分');
zlabel('第三主成分');
