% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function model = naive_bayes_train(X, y, dist_type, alpha)
% NAIVE_BAYES_TRAIN 训练朴素贝叶斯分类器
%
%   算法来源：李航《统计学习方法》第4章
%   算法复杂度：训练 O(n * d)，预测 O(d * k)，n=样本数，d=特征数，k=类别数
%
%   输入参数:
%       X         - 训练数据矩阵 [n_samples, n_features]
%       y         - 标签向量 [n_samples, 1]，类别值从 1 开始编号
%       dist_type - 分布类型: 'gaussian'(默认), 'multinomial', 'bernoulli'
%       alpha     - 拉普拉斯平滑系数 (默认 1.0)
%
%   输出参数:
%       model     - 结构体，训练好的模型参数
%         .classes    - 类别标签列表
%         .priors     - 先验概率 P(Y=c_k)
%         .dist_type  - 分布类型
%         .params     - 分布参数（结构因 dist_type 而异）
%         .alpha      - 平滑系数
%         .n_features - 特征维数
%         .n_classes  - 类别数
%
%   示例:
%       X = randn(100, 5); y = [ones(50,1); 2*ones(50,1)];
%       model = naive_bayes_train(X, y, 'gaussian');
%       pred = naive_bayes_predict(model, X(1:10,:));
%
%   参考文献:
%       李航.《统计学习方法》第4章. 清华大学出版社, 2012.

%% 参数默认值
if nargin < 3 || isempty(dist_type), dist_type = 'gaussian'; end
if nargin < 4 || isempty(alpha), alpha = 1.0; end

%% 初始化
[n_samples, n_features] = size(X);
classes = unique(y);
n_classes = length(classes);

model.classes = classes;
model.dist_type = dist_type;
model.alpha = alpha;
model.n_features = n_features;
model.n_classes = n_classes;

%% 计算先验概率 P(Y = c_k)
priors = zeros(n_classes, 1);
for i = 1:n_classes
    priors(i) = sum(y == classes(i)) / n_samples;
end
model.priors = priors;

%% 估计条件概率参数 P(X_j | Y = c_k)
switch lower(dist_type)
    case 'gaussian'
        model.params = train_gaussian(X, y, classes, n_classes, n_features);

    case 'multinomial'
        model.params = train_multinomial(X, y, classes, n_classes, n_features, alpha);

    case 'bernoulli'
        model.params = train_bernoulli(X, y, classes, n_classes, n_features, alpha);

    otherwise
        error('不支持的分布类型: %s', dist_type);
end

end


function params = train_gaussian(X, y, classes, n_classes, n_features)
% 高斯朴素贝叶斯：P(x_j | y=c) ~ N(mu_{cj}, sigma^2_{cj})

params.mu = zeros(n_classes, n_features);
params.sigma = zeros(n_classes, n_features);

for c = 1:n_classes
    X_c = X(y == classes(c), :);
    params.mu(c, :) = mean(X_c, 1);
    params.sigma(c, :) = std(X_c, 0, 1);  % 无偏标准差
end

end


function params = train_multinomial(X, y, classes, n_classes, n_features, alpha)
% 多项式朴素贝叶斯（适用于词频等计数特征）
%   P(x_j | y=c) = (N_{cj} + alpha) / (N_c + alpha * n_features)

params.log_prob = zeros(n_classes, n_features);

for c = 1:n_classes
    X_c = X(y == classes(c), :);
    % 每个特征的总计数 + 平滑
    feature_counts = sum(X_c, 1) + alpha;
    % 归一化 → log 概率
    params.log_prob(c, :) = log(feature_counts / sum(feature_counts));
end

end


function params = train_bernoulli(X, y, classes, n_classes, n_features, alpha)
% 伯努利朴素贝叶斯（适用于二元特征）
%   P(x_j=1 | y=c) = (count_{cj} + alpha) / (N_c + 2*alpha)

params.p = zeros(n_classes, n_features);

for c = 1:n_classes
    X_c = X(y == classes(c), :);
    n_c = size(X_c, 1);
    params.p(c, :) = (sum(X_c > 0, 1) + alpha) / (n_c + 2 * alpha);
end

end


function [predictions, proba] = naive_bayes_predict(model, X_test)
% NAIVE_BAYES_PREDICT 朴素贝叶斯预测
%
%   输出:
%       predictions - 预测类别 [n_test, 1]
%       proba       - 后验概率矩阵 [n_test, n_classes]

[n_test, n_features] = size(X_test);
assert(n_features == model.n_features, '特征维数不匹配');

n_classes = model.n_classes;
log_posterior = zeros(n_test, n_classes);

for c = 1:n_classes
    % log P(Y=c)
    log_prior = log(model.priors(c) + eps);

    % log P(X | Y=c)
    switch lower(model.dist_type)
        case 'gaussian'
            log_likelihood = gaussian_log_likelihood( ...
                X_test, model.params.mu(c,:), model.params.sigma(c,:));
        case 'multinomial'
            log_likelihood = X_test * model.params.log_prob(c,:)';
        case 'bernoulli'
            p = model.params.p(c,:);
            log_likelihood = sum( ...
                X_test .* log(p + eps) + (1 - X_test) .* log(1 - p + eps), 2);
    end

    log_posterior(:, c) = log_prior + log_likelihood;
end

% 数值稳定：减去每行最大值
log_posterior = log_posterior - max(log_posterior, [], 2);

% 转换为概率
proba = exp(log_posterior);
proba = proba ./ sum(proba, 2);

% 预测：最大后验概率
[~, max_idx] = max(log_posterior, [], 2);
predictions = model.classes(max_idx);

end


function ll = gaussian_log_likelihood(X, mu, sigma)
% 高斯分布对数似然
%   log P(x_i | mu, sigma) = -0.5 * sum( ((x-mu)/sigma)^2 + log(2*pi*sigma^2) )

n = size(X, 1);
sigma_safe = max(sigma, 1e-9);  % 防止除零

diff_sq = ((X - mu) ./ sigma_safe).^2;
ll = -0.5 * sum(diff_sq + log(2 * pi * sigma_safe.^2), 2);

end

%% Self-test
function self_test()
    % Test 2-class separable data
    rng(42, 'twister');
    X = [randn(10,2); randn(10,2)+3];
    y = [ones(10,1); 2*ones(10,1)];
    model = naive_bayes_train(X, y, 'gaussian');
    pred = naive_bayes_predict(model, X);
    acc = mean(pred == y);
    assert(acc > 0.8, 'Test failed: accuracy should be high for separable Gaussian data.');
    disp('naive_bayes_train self-test passed.');
end
