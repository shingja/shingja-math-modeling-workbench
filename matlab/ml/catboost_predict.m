% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [y_pred, y_prob] = catboost_predict(model, X)
%CATBOOST_PREDICT  CatBoost 预测 (MATLAB → Python Bridge)
%   [Y_PRED, Y_PROB] = CATBOOST_PREDICT(MODEL, X)
%
%   Source: Prokhorenkova, L. et al. (2018). CatBoost. NeurIPS.
%   Author: Adapted by MathModelingSkill
%   License: MIT
%   Verified: 2026-07-27
%
%   输入:
%       model  - catboost_train 返回的模型结构体
%       X      - 特征矩阵 (n_samples × n_features)
%
%   输出:
%       y_pred - 预测标签 (分类) 或 预测值 (回归), (n_samples × 1)
%       y_prob - 预测概率 (仅分类), (n_samples × n_classes)
%                回归时返回空矩阵 []
%
%   示例:
%       model = catboost_train(X_train, y_train, 'Iterations', 100);
%       [y_pred, y_prob] = catboost_predict(model, X_test);

%% 依赖检查
if ~isfield(model, 'py_model')
    error('无效的 model 结构体。请使用 catboost_train 生成。');
end

[n_samples, n_features] = size(X);

X_py = py.numpy.array(X(:).', 'float64');
X_py = py.numpy.reshape(X_py, int64([n_samples, n_features]));

%% 预测
cb = model.py_model;
y_pred_py = cb.predict(X_py);
y_pred = double(py.array.array('d', y_pred_py))';

% 概率输出 (仅分类)
y_prob = [];
if strcmp(model.task_type, 'classification')
    try
        y_prob_py = cb.predict_proba(X_py);
        % 转换为 MATLAB 矩阵
        n_classes = double(py.len(y_prob_py{1}));
        y_prob = zeros(n_samples, n_classes);
        for i = 1:n_samples
            row_py = y_prob_py{int64(i-1)};
            for c = 1:n_classes
                y_prob(i, c) = double(row_py{int64(c-1)});
            end
        end
    catch
        y_prob = [];
    end
end
end
