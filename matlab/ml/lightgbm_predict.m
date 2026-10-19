% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [y_pred, y_prob] = lightgbm_predict(model, X)
%LIGHTGBM_PREDICT  LightGBM 预测 (MATLAB → Python Bridge)
%   [Y_PRED, Y_PROB] = LIGHTGBM_PREDICT(MODEL, X)
%
%   Source: Ke et al. (2017). LightGBM. NeurIPS.
%   Author: Adapted by MathModelingSkill
%   License: MIT
%   Verified: 2026-07-27

if ~isfield(model, 'py_model')
    error('无效的 model 结构体。请使用 lightgbm_train 生成。');
end

[n_samples, n_features] = size(X);
X_py = py.numpy.array(X(:).', 'float64');
X_py = py.numpy.reshape(X_py, int64([n_samples, n_features]));

lgb = model.py_model;
y_pred_py = lgb.predict(X_py);
y_pred = double(py.array.array('d', y_pred_py))';

y_prob = [];
if strcmp(model.task_type, 'classification')
    try
        y_prob_py = lgb.predict_proba(X_py);
        y_prob = double(py.numpy.asarray(y_prob_py));
    catch
    end
end
end
