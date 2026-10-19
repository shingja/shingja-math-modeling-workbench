% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function model = logistic_regression_train(X, y, varargin)
% LOGISTIC_REGRESSION_TRAIN 逻辑斯谛回归训练（二分类 + 多分类 Softmax）
%
%   算法来源：李航《统计学习方法》第6章
%   算法复杂度：SGD 训练 O(n * d * k)，预测 O(d)，n=样本数，d=特征数，k=迭代次数
%
%   输入参数（键值对）:
%       X           - 训练数据矩阵 [n_samples, n_features]
%       y           - 标签向量 [n_samples, 1]，类别值从 1 开始编号
%       'learning_rate' - 学习率 (默认 0.01)
%       'max_iter'      - 最大迭代次数 (默认 1000)
%       'tol'           - 收敛容差 (默认 1e-4)
%       'regularization' - 正则化类型: 'none'(默认), 'l1', 'l2', 'elasticnet'
%       'lambda'         - 正则化强度 (默认 0.01)
%       'l1_ratio'       - ElasticNet 中 L1 比例 (默认 0.5)
%       'batch_size'     - Mini-batch 大小，1=SGD，n_samples=GD (默认 32)
%       'verbose'        - 是否打印进度 (默认 false)
%       'multi_class'    - 多分类策略: 'ovr'(默认), 'softmax'
%
%   输出:
%       model - 训练好的模型结构体
%         .W        - 权重矩阵 [n_features, n_classes] 或 [n_features, 1]（二分类）
%         .b        - 偏置向量 [1, n_classes] 或 标量（二分类）
%         .classes  - 类别标签列表
%         .loss_history - 损失函数历史
%
%   示例:
%       X = randn(200, 5); y = [ones(100,1); 2*ones(100,1)];
%       model = logistic_regression_train(X, y, 'regularization', 'l2', 'lambda', 0.1);
%       [pred, prob] = logistic_regression_predict(model, X(1:10,:));
%
%   参考文献:
%       李航.《统计学习方法》第6章. 清华大学出版社, 2012.
%       Bishop, C.M. (2006). PRML, §4.3. Springer.

%% 解析参数
p = inputParser;
p.addRequired('X', @isnumeric);
p.addRequired('y', @isnumeric);
p.addParameter('learning_rate', 0.01, @isnumeric);
p.addParameter('max_iter', 1000, @isnumeric);
p.addParameter('tol', 1e-4, @isnumeric);
p.addParameter('regularization', 'none', @ischar);
p.addParameter('lambda', 0.01, @isnumeric);
p.addParameter('l1_ratio', 0.5, @isnumeric);
p.addParameter('batch_size', 32, @isnumeric);
p.addParameter('verbose', false, @islogical);
p.addParameter('multi_class', 'ovr', @ischar);
p.parse(X, y, varargin{:});

opts = p.Results;
[n_samples, n_features] = size(X);
classes = unique(y);
n_classes = length(classes);

%% 数据标准化（零均值，单位方差）
X_mean = mean(X, 1);
X_std = std(X, 0, 1);
X_std(X_std == 0) = 1;  % 防止除零
X_norm = (X - X_mean) ./ X_std;

%% 二分类或使用 OvR 策略
if n_classes == 2 || strcmp(opts.multi_class, 'ovr')
    if n_classes == 2
        % 二分类: 标签映射为 {0,1}
        y_bin = double(y == classes(2));
        [W, b, loss_hist] = fit_binary(X_norm, y_bin, opts, n_features);
        model.W = W;
        model.b = b;
    else
        % 一对多 (One-vs-Rest): 为每个类别训练一个二分类器
        model.W = zeros(n_features, n_classes);
        model.b = zeros(1, n_classes);
        loss_hist = cell(n_classes, 1);
        for c = 1:n_classes
            y_bin = double(y == classes(c));
            [model.W(:,c), model.b(c), loss_hist{c}] = ...
                fit_binary(X_norm, y_bin, opts, n_features);
        end
    end
else
    % Softmax 多分类
    [model.W, model.b, loss_hist] = fit_softmax(X_norm, y, classes, opts, n_features, n_classes);
end

model.classes = classes;
model.n_classes = n_classes;
model.X_mean = X_mean;
model.X_std = X_std;
model.loss_history = loss_hist;
model.multi_class = opts.multi_class;

end


function [W, b, loss_history] = fit_binary(X, y, opts, n_features)
% 二分类逻辑斯谛回归（SGD / Mini-batch GD）

n_samples = size(X, 1);
W = zeros(n_features, 1);
b = 0;
loss_history = zeros(opts.max_iter, 1);
prev_loss = inf;

batch_size = min(opts.batch_size, n_samples);

for iter = 1:opts.max_iter
    % Mini-batch 采样
    idx = randperm(n_samples, batch_size);
    X_batch = X(idx, :);
    y_batch = y(idx);

    % 计算梯度
    z = X_batch * W + b;
    p_batch = sigmoid(z);
    error = p_batch - y_batch;

    dW = (X_batch' * error) / batch_size;
    db = mean(error);

    % 正则化梯度
    switch opts.regularization
        case 'l1'
            dW = dW + opts.lambda * sign(W);
        case 'l2'
            dW = dW + 2 * opts.lambda * W;
        case 'elasticnet'
            dW = dW + opts.lambda * (opts.l1_ratio * sign(W) + ...
                 2 * (1 - opts.l1_ratio) * W);
    end

    % 参数更新
    W = W - opts.learning_rate * dW;
    b = b - opts.learning_rate * db;

    % 损失计算
    z_full = X * W + b;
    p_full = sigmoid(z_full);
    log_loss = -mean(y .* log(max(p_full, 1e-15)) + ...
                     (1 - y) .* log(max(1 - p_full, 1e-15)));

    % 正则化损失项
    switch opts.regularization
        case 'l1'
            reg_term = opts.lambda * sum(abs(W));
        case 'l2'
            reg_term = opts.lambda * sum(W.^2);
        case 'elasticnet'
            reg_term = opts.lambda * (opts.l1_ratio * sum(abs(W)) + ...
                      (1 - opts.l1_ratio) * sum(W.^2));
        otherwise
            reg_term = 0;
    end

    loss_history(iter) = log_loss + reg_term;

    % 收敛检查
    if abs(prev_loss - loss_history(iter)) < opts.tol
        loss_history = loss_history(1:iter);
        break;
    end
    prev_loss = loss_history(iter);

    if opts.verbose && mod(iter, 100) == 0
        fprintf('迭代 %d/%d, loss = %.6f\n', iter, opts.max_iter, loss_history(iter));
    end
end

end


function [W, b, loss_history] = fit_softmax(X, y, classes, opts, n_features, n_classes)
% Softmax 多分类（交叉熵损失）

n_samples = size(X, 1);
W = zeros(n_features, n_classes);
b = zeros(1, n_classes);
loss_history = zeros(opts.max_iter, 1);

% One-hot 编码
Y_onehot = full(sparse(1:n_samples, y, 1, n_samples, n_classes));
if size(Y_onehot, 2) < n_classes
    Y_onehot(:, n_classes) = 0;
end

batch_size = min(opts.batch_size, n_samples);
prev_loss = inf;

for iter = 1:opts.max_iter
    idx = randperm(n_samples, batch_size);
    X_batch = X(idx, :);
    y_batch = Y_onehot(idx, :);

    % Softmax 前向传播
    scores = X_batch * W + b;
    scores = scores - max(scores, [], 2);  % 数值稳定
    exp_scores = exp(scores);
    probs = exp_scores ./ sum(exp_scores, 2);
    error = probs - y_batch;

    % 梯度
    dW = (X_batch' * error) / batch_size;
    db = mean(error, 1);

    if strcmp(opts.regularization, 'l2')
        dW = dW + 2 * opts.lambda * W;
    end

    W = W - opts.learning_rate * dW;
    b = b - opts.learning_rate * db;

    % 交叉熵损失
    scores_full = X * W + b;
    scores_full = scores_full - max(scores_full, [], 2);
    exp_full = exp(scores_full);
    probs_full = exp_full ./ sum(exp_full, 2);
    ce_loss = -mean(sum(Y_onehot .* log(max(probs_full, 1e-15)), 2));
    loss_history(iter) = ce_loss;

    if abs(prev_loss - ce_loss) < opts.tol
        loss_history = loss_history(1:iter);
        break;
    end
    prev_loss = ce_loss;
end

end


function [predictions, proba] = logistic_regression_predict(model, X_test)
% LOGISTIC_REGRESSION_PREDICT 逻辑斯谛回归预测
%
%   输出:
%       predictions - 预测类别 [n_test, 1]
%       proba       - 后验概率矩阵 [n_test, n_classes]

% 标准化
X_norm = (X_test - model.X_mean) ./ model.X_std;

if model.n_classes == 2 && ~strcmp(model.multi_class, 'softmax')
    % 二分类
    z = X_norm * model.W + model.b;
    p1 = sigmoid(z);
    proba = [1 - p1, p1];
    [~, max_idx] = max(proba, [], 2);
else
    % 多分类 (OvR 或 Softmax)
    scores = X_norm * model.W + model.b;
    scores = scores - max(scores, [], 2);
    proba = exp(scores) ./ sum(exp(scores), 2);
    [~, max_idx] = max(proba, [], 2);
end

predictions = model.classes(max_idx);

end


function s = sigmoid(z)
% Sigmoid 函数（数值稳定版本）
s = 1 ./ (1 + exp(-min(max(z, -50), 50)));  % 防止溢出
end

%% Self-test
function self_test()
    % Test AND logic gate
    rng(42, 'twister');
    X = [0 0; 0 1; 1 0; 1 1];
    y = [1; 1; 1; 2];  % (1,1) is class 2
    model = logistic_regression_train(X, y, 'max_iter', 500, 'learning_rate', 0.1, 'verbose', false);
    [pred, prob] = logistic_regression_predict(model, X);
    assert(all(pred == y), 'Test failed: should classify all 4 points correctly.');
    disp('logistic_regression_train self-test passed.');
end
