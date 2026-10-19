% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [predictions, neighbors, distances] = knn_predict(X_train, y_train, X_test, k, distance_type)
% KNN_PREDICT k近邻法分类预测
%
%   算法来源：李航《统计学习方法》第3章
%   算法复杂度：暴力搜索 O(n_train * d) / 次查询；kd树 O(log n_train) / 次查询
%
%   输入参数:
%       X_train      - 训练数据矩阵 [n_train, d]
%       y_train      - 训练标签向量 [n_train, 1] 或 [n_train, n_classes]
%       X_test       - 测试数据矩阵 [n_test, d]
%       k            - 近邻数 (默认 3)
%       distance_type - 距离类型: 'euclidean'(默认), 'manhattan', 'minkowski', 'cosine'
%
%   输出参数:
%       predictions  - 预测标签 [n_test, 1]
%       neighbors    - 近邻索引矩阵 [n_test, k]
%       distances    - 近邻距离矩阵 [n_test, k]
%
%   示例:
%       X_train = [1 1; 1 2; 3 3; 4 4]; y_train = [1; 1; 2; 2];
%       X_test = [2 2; 3 1];
%       pred = knn_predict(X_train, y_train, X_test, 3);
%
%   参考文献:
%       Cover, T. & Hart, P. (1967). Nearest Neighbor Pattern Classification.
%       李航.《统计学习方法》第3章. 清华大学出版社, 2012.

%% 参数默认值
if nargin < 4 || isempty(k), k = 3; end
if nargin < 5 || isempty(distance_type), distance_type = 'euclidean'; end

%% 输入验证
[n_train, d_train] = size(X_train);
[n_test, d_test] = size(X_test);
assert(d_train == d_test, '训练集和测试集的特征维度必须一致');
assert(k <= n_train, 'k 不能超过训练样本数');

%% 计算距离矩阵 (n_test × n_train)
D = compute_distance_matrix(X_test, X_train, distance_type);

%% 找出 k 个最近邻
predictions = zeros(n_test, 1);
neighbors = zeros(n_test, k);
distances = zeros(n_test, k);

for i = 1:n_test
    [sorted_dist, idx] = sort(D(i,:));
    neighbors(i,:) = idx(1:k);
    distances(i,:) = sorted_dist(1:k);

    % 多数投票
    neighbor_labels = y_train(neighbors(i,:));
    predictions(i) = mode(neighbor_labels);
end

end


function D = compute_distance_matrix(X1, X2, distance_type)
% 计算两组样本间的距离矩阵
%
%   D(i,j) = distance(X1(i,:), X2(j,:))
%
%   支持的距离度量：
%     'euclidean' - 欧氏距离 (默认)
%     'manhattan'  - 曼哈顿距离
%     'minkowski'  - 闵可夫斯基距离 (p=3)
%     'cosine'     - 余弦距离 = 1 - 余弦相似度

[n1, d] = size(X1);
n2 = size(X2, 1);

switch lower(distance_type)
    case 'euclidean'
        % ||x1 - x2||_2，使用向量化展开公式
        sum1 = sum(X1.^2, 2);
        sum2 = sum(X2.^2, 2);
        D = sqrt(max(0, sum1 * ones(1,n2) + ones(n1,1) * sum2' - 2 * X1 * X2'));

    case 'manhattan'
        % ||x1 - x2||_1
        D = zeros(n1, n2);
        for j = 1:d
            D = D + abs(X1(:,j) - X2(:,j)');
        end

    case 'minkowski'
        % ||x1 - x2||_p, p=3
        p = 3;
        D = zeros(n1, n2);
        for j = 1:d
            D = D + abs(X1(:,j) - X2(:,j)').^p;
        end
        D = D.^(1/p);

    case 'cosine'
        % 1 - cosine_similarity
        X1_norm = sqrt(sum(X1.^2, 2));
        X2_norm = sqrt(sum(X2.^2, 2));
        cosine_sim = (X1 * X2') ./ (X1_norm * X2_norm' + eps);
        D = 1 - cosine_sim;

    otherwise
        error('不支持的距离类型: %s', distance_type);
end

end


function best_k = knn_crossval_k(X, y, k_list, n_folds)
% KNN_CROSSVAL_K 交叉验证选择最优 k 值
%
%   输入:
%       k_list  - 候选 k 值列表 (默认 [1,3,5,7,9,11,15])
%       n_folds - 折数 (默认 5)
%
%   输出:
%       best_k - 最优 k 值

if nargin < 3 || isempty(k_list), k_list = [1,3,5,7,9,11,15]; end
if nargin < 4 || isempty(n_folds), n_folds = 5; end

[n_samples, ~] = size(X);
indices = crossvalind('Kfold', n_samples, n_folds);
accuracies = zeros(length(k_list), 1);

for kidx = 1:length(k_list)
    k = k_list(kidx);
    fold_acc = zeros(n_folds, 1);

    for fold = 1:n_folds
        test_idx = (indices == fold);
        train_idx = ~test_idx;

        pred = knn_predict(X(train_idx,:), y(train_idx), X(test_idx,:), k);
        fold_acc(fold) = mean(pred == y(test_idx));
    end

    accuracies(kidx) = mean(fold_acc);
end

[~, best_idx] = max(accuracies);
best_k = k_list(best_idx);

end


%% Exit status
exitflag = 1;  %% normal termination

%% Self-test
function self_test()
    % Test with 4-point 2-class problem
    X_train = [0 0; 0 1; 3 3; 4 4];
    y_train = [1; 1; 2; 2];
    X_test = [0.5 0.5; 3.5 3.5];
    pred = knn_predict(X_train, y_train, X_test, 3);
    assert(pred(1) == 1, 'Test failed: point near [0,0]-[0,1] should be class 1.');
    assert(pred(2) == 2, 'Test failed: point near [3,3]-[4,4] should be class 2.');
    disp('knn_predict self-test passed.');
end

function [predictions] = knn_regress(X_train, y_train, X_test, k, distance_type)
% KNN_REGRESS k近邻法回归预测
%
%   预测值为 k 个最近邻目标值的加权平均
%   权重 = 1 / (距离 + eps)

if nargin < 4 || isempty(k), k = 3; end
if nargin < 5 || isempty(distance_type), distance_type = 'euclidean'; end

[n_test, ~] = size(X_test);
D = compute_distance_matrix(X_test, X_train, distance_type);
predictions = zeros(n_test, 1);

for i = 1:n_test
    [sorted_dist, idx] = sort(D(i,:));
    neighbor_idx = idx(1:k);
    neighbor_dist = sorted_dist(1:k);

    % 距离加权平均
    weights = 1 ./ (neighbor_dist + eps);
    weights = weights / sum(weights);
    predictions(i) = sum(weights .* y_train(neighbor_idx));
end

end
