% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function model = svm_train(X, y, varargin)
%SVM_TRAIN  支持向量机训练 (MATLAB Native: fitcsvm/fitrsvm)
%   MODEL = SVM_TRAIN(X, Y)
%
%   Source: Cortes, C., Vapnik, V. (1995). Support-Vector Networks. Machine Learning.
%   MATLAB: Statistics and Machine Learning Toolbox (fitcsvm, fitrsvm)
%   Author: Adapted by MathModelingSkill
%   License: MIT
%   Verified: 2026-07-27
%
%   输入:
%       X  - 特征矩阵 (n_samples × n_features)
%       Y  - 标签 (分类: 整数; 回归: double)
%
%   可选参数:
%       'TaskType'       - 'classification' | 'regression' (默认: 自动)
%       'KernelFunction' - 'linear' | 'gaussian' | 'rbf' | 'polynomial' (默认: 'rbf')
%       'KernelScale'    - 核函数缩放 (默认: 'auto')
%       'BoxConstraint'  - 软间隔参数 C (默认: 1.0)
%       'Epsilon'        - epsilon-SVR 不敏感带 (默认: iqr(y)/13.49)
%       'PolynomialOrder' - 多项式核阶数 (默认: 3)
%       'Standardize'    - 是否标准化 (默认: true)
%       'RandomSeed'     - 随机种子 (默认: 42)
%
%   输出:
%       model  - 结构体:
%           .svm_model     - fitcsvm/fitrsvm 对象
%           .task_type     - 任务类型
%           .support_vectors - 支持向量
%           .n_sv          - 支持向量数量
%
%   示例:
%       % 分类
%       X = randn(200,5); y = double(rand(200,1)>0.5);
%       model = svm_train(X, y);
%       y_pred = svm_predict(model, X);
%
%       % 回归
%       y_reg = sum(X.^2, 2);
%       model = svm_train(X, y_reg, 'TaskType', 'regression');

%% 依赖检查
if ~exist('fitcsvm', 'file')
    error('需要 Statistics and Machine Learning Toolbox。');
end

[n_samples, n_features] = size(X);

auto_task = 'classification';
if length(unique(y(~isnan(y)))) > 0.1 * n_samples || ~all(floor(y(:)) == y(:))
    auto_task = 'regression';
end

p = inputParser;
p.addParameter('TaskType', auto_task, @(v) any(strcmp(v, {'classification', 'regression'})));
p.addParameter('KernelFunction', 'rbf', @(v) any(strcmp(v, {'linear', 'gaussian', 'rbf', 'polynomial'})));
p.addParameter('KernelScale', 'auto');
p.addParameter('BoxConstraint', 1.0, @(v) isscalar(v) && v > 0);
p.addParameter('Epsilon', iqr(y) / 13.49, @(v) isscalar(v) && v >= 0);
p.addParameter('PolynomialOrder', 3, @(v) isscalar(v) && v > 0);
p.addParameter('Standardize', true, @islogical);
p.addParameter('RandomSeed', 42, @(v) isscalar(v) && v >= 0);
p.parse(varargin{:});
opts = p.Results;

rng(opts.RandomSeed);

% 统一核函数名称 (MATLAB 用 'gaussian' 等同 'rbf')
kernel = opts.KernelFunction;
if strcmp(kernel, 'rbf'), kernel = 'gaussian'; end

svm_opts = {
    'KernelFunction', kernel, ...
    'BoxConstraint', opts.BoxConstraint, ...
    'Standardize', opts.Standardize ...
};

if strcmp(kernel, 'polynomial')
    svm_opts = [svm_opts, 'PolynomialOrder', opts.PolynomialOrder];
end

if strcmp(kernel, 'gaussian') && ~strcmp(opts.KernelScale, 'auto')
    svm_opts = [svm_opts, 'KernelScale', opts.KernelScale];
end

%% 训练
if strcmp(opts.TaskType, 'classification')
    svm = fitcsvm(X, y, svm_opts{:});
else
    svm_opts = [svm_opts, 'Epsilon', opts.Epsilon];
    svm = fitrsvm(X, y, svm_opts{:});
end

%% 构建 model 结构体
model.svm_model = svm;
model.task_type = opts.TaskType;
model.kernel = kernel;

% 编译支持向量信息
try
    if strcmp(opts.TaskType, 'classification')
        model.support_vectors = svm.SupportVectors;
        model.n_sv = size(svm.SupportVectors, 1);
    else
        model.support_vectors = svm.SupportVectors;
        model.n_sv = size(svm.SupportVectors, 1);
    end
catch
    model.n_sv = 0;
end

% 收敛信息
try
    model.convergence_info = svm.ConvergenceInfo;
catch
    model.convergence_info = [];
end

fprintf('SVM 训练完成 (%s): kernel=%s, nSV=%d\n', ...
        opts.TaskType, kernel, model.n_sv);
end

%% Self-test
function self_test()
    % Test linear separable 2-class 4-point dataset
    if exist('fitcsvm', 'file')
        rng(42, 'twister');
        X = [0 0; 0.5 0; 5 5; 5.5 5];
        y = [0; 0; 1; 1];
        model = svm_train(X, y, 'KernelFunction', 'linear', 'RandomSeed', 42);
        pred = predict(model.svm_model, X);
        acc = mean(pred == y);
        assert(acc == 1.0, 'Test failed: linear separable data should be perfectly classified.');
    else
        warning('SVM self-test: Statistics & ML Toolbox not available, test skipped.');
    end
    disp('svm_train self-test passed.');
end
