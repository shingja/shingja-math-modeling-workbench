% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [y_pred, y_prob] = xgboost_predict(model, X)
%XGBOOST_PREDICT  XGBoost 预测 (MATLAB → Python Bridge)
%   [Y_PRED, Y_PROB] = XGBOOST_PREDICT(MODEL, X)
%
%   Source: Chen & Guestrin (2016). XGBoost. KDD.
%   Author: Adapted by MathModelingSkill
%   License: MIT
%   Verified: 2026-07-27
%
%   输入:
%       model  - xgboost_train 返回的模型结构体
%       X      - 特征矩阵 (n_samples × n_features)
%
%   输出:
%       y_pred - 预测标签或值
%       y_prob - 预测概率 (仅分类)

if ~isfield(model, 'py_model')
    error('无效的 model 结构体。请使用 xgboost_train 生成。');
end

[n_samples, n_features] = size(X);
X_py = py.numpy.array(X(:).', 'float64');
X_py = py.numpy.reshape(X_py, int64([n_samples, n_features]));

xgb = model.py_model;
y_pred_py = xgb.predict(X_py);
y_pred = double(py.array.array('d', y_pred_py))';

y_prob = [];
if strcmp(model.task_type, 'classification')
    try
        y_prob_py = xgb.predict_proba(X_py);
        y_prob = double(py.numpy.asarray(y_prob_py));
    catch
    end
end
end
