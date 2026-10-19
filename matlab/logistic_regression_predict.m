% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [predictions, proba] = logistic_regression_predict(model, X_test)
% LOGISTIC_REGRESSION_PREDICT 逻辑斯谛回归预测
%
%   输出:
%       predictions - 预测类别 [n_test, 1]
%       proba       - 后验概率矩阵 [n_test, n_classes]

X_norm = (X_test - model.X_mean) ./ model.X_std;

if model.n_classes == 2 && ~strcmp(model.multi_class, 'softmax')
    z = X_norm * model.W + model.b;
    p1 = sigmoid(z);
    proba = [1 - p1, p1];
    [~, max_idx] = max(proba, [], 2);
else
    scores = X_norm * model.W + model.b;
    scores = scores - max(scores, [], 2);
    proba = exp(scores) ./ sum(exp(scores), 2);
    [~, max_idx] = max(proba, [], 2);
end

predictions = model.classes(max_idx);

end

%% Self-test
function self_test()
    % Test on AND logic with trained model
    rng(42, 'twister');
    X = [0 0; 0 1; 1 0; 1 1];
    y = [1; 1; 1; 2];  % AND-like: (1,1) is class 2
    model = logistic_regression_train(X, y, 'max_iter', 200, 'verbose', false);
    [pred, prob] = logistic_regression_predict(model, X);
    assert(all(pred == y), 'Test failed: logistic regression should fit 4-point dataset.');
    disp('logistic_regression_predict self-test passed.');
end
