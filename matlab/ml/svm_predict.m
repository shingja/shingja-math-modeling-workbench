% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [y_pred, y_score] = svm_predict(model, X)
%SVM_PREDICT  支持向量机预测 (MATLAB Native)
%   [Y_PRED, Y_SCORE] = SVM_PREDICT(MODEL, X)
%
%   Source: Cortes & Vapnik (1995). Machine Learning.
%   Author: Adapted by MathModelingSkill
%   License: MIT
%   Verified: 2026-07-27
%
%   输入:
%       model  - svm_train 返回的模型结构体
%       X      - 特征矩阵 (n_samples × n_features)
%
%   输出:
%       y_pred  - 预测标签 (分类) 或 预测值 (回归)
%       y_score - 决策函数值 (分类) / 空 [] (回归)

if ~isfield(model, 'svm_model')
    error('无效的 model 结构体。请使用 svm_train 生成。');
end

svm = model.svm_model;

if strcmp(model.task_type, 'classification')
    [y_pred, y_score] = predict(svm, X);
else
    y_pred = predict(svm, X);
    y_score = [];
end
end
