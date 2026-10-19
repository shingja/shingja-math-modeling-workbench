% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [y_pred, y_prob] = random_forest_predict(model, X)
%RANDOM_FOREST_PREDICT 随机森林预测 (MATLAB Native)
%   [Y_PRED, Y_PROB] = RANDOM_FOREST_PREDICT(MODEL, X)
%
%   Source: Breiman, L. (2001). Random Forests. Machine Learning.
%   Author: Adapted by MathModelingSkill
%   License: MIT
%   Verified: 2026-07-27
%
%   输入:
%       model  - random_forest_train 返回的模型结构体
%       X      - 特征矩阵 (n_samples × n_features)
%
%   输出:
%       y_pred - 预测标签 (分类) 或 预测值 (回归)
%       y_prob - 预测概率 (仅分类), (n_samples × n_classes)
%                回归时返回 []
%
%   示例:
%       model = random_forest_train(X_train, y_train);
%       [y_pred, y_prob] = random_forest_predict(model, X_test);

if ~isfield(model, 'ensemble')
    error('无效的 model 结构体。请使用 random_forest_train 生成。');
end

ensemble = model.ensemble;

if strcmp(model.task_type, 'classification')
    [y_pred_cell, y_scores] = predict(ensemble, X);
    % 转换为 double
    y_pred = str2double(y_pred_cell);
    if isnan(y_pred(1))
        y_pred = double(string(y_pred_cell));
    end
    y_prob = y_scores;
else
    y_pred = predict(ensemble, X);
    y_prob = [];
end
end
