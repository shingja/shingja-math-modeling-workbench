% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
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
    log_prior = log(model.priors(c) + eps);

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

log_posterior = log_posterior - max(log_posterior, [], 2);
proba = exp(log_posterior);
proba = proba ./ sum(proba, 2);

[~, max_idx] = max(log_posterior, [], 2);
predictions = model.classes(max_idx);

end

%% Self-test
function self_test()
    % Test on known model with simple data
    rng(42, 'twister');
    X = [0 0; 0.5 0; 5 5; 5.5 5];
    y = [1; 1; 2; 2];
    model = naive_bayes_train(X, y, 'gaussian');
    pred = naive_bayes_predict(model, X);
    assert(all(pred == y), 'Test failed: should perfectly classify separable data.');
    disp('naive_bayes_predict self-test passed.');
end
