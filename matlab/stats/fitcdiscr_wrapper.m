% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [model, y_pred, accuracy, stats] = fitcdiscr_wrapper(X, y, varargin)
%FITCDISCR_WRAPPER 判别分析 (封装 MATLAB fitcdiscr)
%   [MODEL, Y_PRED, ACCURACY, STATS] = FITCDISCR_WRAPPER(X, Y)
%   线性/二次判别分析。与 Python sklearn LinearDiscriminantAnalysis 对齐。
%
%   Source: Fisher, R.A. (1936). The Use of Multiple Measurements
%          in Taxonomic Problems. Annals of Eugenics.
%   MATLAB: Statistics and Machine Learning Toolbox (fitcdiscr)
%   Author: Adapted by MathModelingSkill
%   License: MIT
%   Verified: 2026-07-27
%
%   输入:
%       X  - 特征矩阵 (n_samples × n_features)
%       y  - 类别标签 (n_samples × 1), categorical / double
%
%   可选参数:
%       'DiscrimType'  - 判别类型 (默认: 'linear')
%                        'linear' | 'quadratic' | 'diagLinear' | 'pseudoLinear'
%       'Prior'        - 先验概率 (默认: 'empirical')
%       'Standardize'  - 是否标准化 (默认: true)
%       'CrossVal'     - 交叉验证折数 (默认: 0=不交叉验证)
%       'Display'      - 'on' | 'off' (默认: 'on')
%
%   输出:
%       model    - fitcdiscr 对象
%       y_pred   - 预测标签 (训练集重代入)
%       accuracy - 准确率
%       stats    - 结构体:
%           .confusion_mat - 混淆矩阵
%           .coeffs        - 判别系数
%           .class_means   - 各类别均值
%           .explained_var - 各判别轴解释方差比例
%
%   示例:
%       X = [randn(50,3); randn(50,3)+2];
%       y = [ones(50,1); 2*ones(50,1)];
%       [model, yp, acc] = fitcdiscr_wrapper(X, y);

%% 依赖检查
if ~exist('fitcdiscr', 'file')
    error('需要 Statistics and Machine Learning Toolbox。请安装该工具箱。');
end

[n_samples, n_features] = size(X);

%% 参数解析
p = inputParser;
p.addParameter('DiscrimType', 'linear');
p.addParameter('Prior', 'empirical');
p.addParameter('Standardize', true);
p.addParameter('CrossVal', 0, @(v) isscalar(v) && v >= 0);
p.addParameter('Display', 'on');
p.parse(varargin{:});
opts = p.Results;

%% 标准化
if opts.Standardize
    X_s = zscore(X);
else
    X_s = X;
end

%% 确保 y 为 categorical
if ~iscategorical(y)
    y_cat = categorical(y);
else
    y_cat = y;
end

classes = categories(y_cat);
n_classes = length(classes);

%% 训练判别模型
try
    if opts.CrossVal > 0
        model = fitcdiscr(X_s, y_cat, ...
            'DiscrimType', opts.DiscrimType, ...
            'Prior', opts.Prior, ...
            'CrossVal', 'on', ...
            'KFold', opts.CrossVal);

        % 交叉验证预测
        y_pred = kfoldPredict(model);
        accuracy = mean(y_pred == y_cat);
    else
        model = fitcdiscr(X_s, y_cat, ...
            'DiscrimType', opts.DiscrimType, ...
            'Prior', opts.Prior);

        % 重代入预测
        y_pred = predict(model, X_s);
        accuracy = mean(y_pred == y_cat);
    end
catch ME
    error('判别分析训练失败: %s', ME.message);
end

%% 混淆矩阵
confusion_mat = confusionmat(y_cat, y_pred);

%% 判别系数与类均值
try
    coeffs = model.Coeffs;
    stats.coeffs = coeffs;
catch
    stats.coeffs = [];
end

try
    stats.class_means = model.Mu;
catch
    stats.class_means = [];
end

%% 判别轴方差解释 (仅线性判别)
stats.explained_var = [];
if strcmp(opts.DiscrimType, 'linear') && n_classes > 2
    try
        eig_vals = model.BetweenSigma;
        if isnumeric(eig_vals)
            stats.explained_var = diag(eig_vals) / sum(diag(eig_vals)) * 100;
        end
    catch
    end
end

%% 输出
stats.confusion_mat = confusion_mat;
stats.n_classes = n_classes;
stats.classes = classes;

if strcmp(opts.Display, 'on')
    fprintf('\n=== 判别分析 ===\n');
    fprintf('类型: %s, 样本数: %d, 特征数: %d, 类别数: %d\n', ...
            opts.DiscrimType, n_samples, n_features, n_classes);
    fprintf('准确率: %.2f%%\n', accuracy * 100);

    if opts.CrossVal > 0
        fprintf('  (%d折交叉验证)\n', opts.CrossVal);
    end

    fprintf('\n混淆矩阵:\n');
    fprintf('        ');
    for c = 1:n_classes
        fprintf('  %6s', classes{c});
    end
    fprintf('\n');
    for i = 1:n_classes
        fprintf('  %6s', classes{i});
        for j = 1:n_classes
            fprintf('  %6d', confusion_mat(i, j));
        end
        fprintf('\n');
    end
end
end

%% Self-test
function self_test()
    % Test 2-class separable data
    if exist('fitcdiscr', 'file')
        rng(42, 'twister');
        X = [randn(10,2); randn(10,2)+3];
        y = [ones(10,1); 2*ones(10,1)];
        [model, y_pred, acc] = fitcdiscr_wrapper(X, y, 'Display', 'off');
        assert(acc > 0.8, 'Test failed: accuracy should be high for separable data.');
    else
        warning('Discriminant analysis self-test: Statistics & ML Toolbox not available, test skipped.');
    end
    disp('fitcdiscr_wrapper self-test passed.');
end
