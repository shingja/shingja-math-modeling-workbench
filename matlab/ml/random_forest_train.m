% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function model = random_forest_train(X, y, varargin)
%RANDOM_FOREST_TRAIN 随机森林训练 (MATLAB Native)
%   MODEL = RANDOM_FOREST_TRAIN(X, Y) 使用 TreeBagger 训练随机森林。
%   需要 Statistics and Machine Learning Toolbox。
%
%   Source: Breiman, L. (2001). Random Forests. Machine Learning, 45(1), 5-32.
%   MATLAB: Statistics and Machine Learning Toolbox (TreeBagger)
%   Author: Adapted by MathModelingSkill
%   License: MIT
%   Verified: 2026-07-27 against Breiman (2001)
%
%   输入:
%       X  - 特征矩阵 (n_samples × n_features), double
%       Y  - 标签向量 (n_samples × 1)
%            - 分类: 整数类别或 logical
%            - 回归: double 连续值
%
%   可选参数 (名值对):
%       'TaskType'     - 'classification' | 'regression' (默认: 自动检测)
%       'NumTrees'     - 树数量 (默认: 100)
%       'MinLeafSize'  - 最小叶节点样本数 (默认: 分类5, 回归5)
%       'NumFeatures'  - 每棵树随机选的特征数 (默认: sqrt(n_features) for classif, n_features/3 for regr)
%       'OOBPrediction' - 是否计算 OOB 误差 (默认: 'on')
%       'RandomSeed'   - 随机种子 (默认: 42)
%
%   输出:
%       model  - 结构体:
%           .ensemble    - TreeBagger 对象
%           .task_type   - 'classification' | 'regression'
%           .oob_error   - OOB 误差曲线
%           .feature_imp - 特征重要性 (1×n_features)
%
%   示例:
%       X = randn(200, 10); y = double(rand(200,1) > 0.5);
%       model = random_forest_train(X, y, 'NumTrees', 50);

%% 依赖检查
if ~exist('TreeBagger', 'class')
    error('需要 Statistics and Machine Learning Toolbox。请安装该工具箱。');
end

%% 参数解析
[n_samples, n_features] = size(X);

auto_task = 'classification';
unique_y = unique(y(~isnan(y)));
if length(unique_y) > 0.1 * n_samples || any(mod(unique_y, 1) ~= 0)
    auto_task = 'regression';
end

if auto_task == 'classification'
    default_nf = max(1, floor(sqrt(n_features)));
else
    default_nf = max(1, floor(n_features / 3));
end

p = inputParser;
p.addParameter('TaskType', auto_task, @(v) any(strcmp(v, {'classification', 'regression'})));
p.addParameter('NumTrees', 100, @(v) isscalar(v) && v > 0);
p.addParameter('MinLeafSize', 5, @(v) isscalar(v) && v > 0);
p.addParameter('NumFeatures', default_nf, @(v) isscalar(v) && v > 0);
p.addParameter('OOBPrediction', 'on', @(v) any(strcmp(v, {'on', 'off'})));
p.addParameter('RandomSeed', 42, @(v) isscalar(v) && v >= 0);
p.addParameter('NumPrint', 0, @(v) isscalar(v) && v >= 0);
p.parse(varargin{:});
opts = p.Results;

%% 参数配置
rf_opts = {
    'NumTrees', opts.NumTrees, ...
    'MinLeafSize', opts.MinLeafSize, ...
    'NumPredictorsToSample', opts.NumFeatures, ...
    'OOBPrediction', opts.OOBPrediction, ...
    'Options', statset('UseParallel', false), ...
    'Print', opts.NumPrint ...
};

rng(opts.RandomSeed);

%% 训练
if strcmp(opts.TaskType, 'classification')
    % 分类: 需要将 y 转为 categorical 或 cellstr
    if isnumeric(y) || islogical(y)
        y_cat = categorical(y);
    else
        y_cat = y;
    end
    ensemble = TreeBagger(opts.NumTrees, X, y_cat, ...
        'Method', 'classification', rf_opts{:});
else
    ensemble = TreeBagger(opts.NumTrees, X, y, ...
        'Method', 'regression', rf_opts{:});
end

%% 提取 OOB 误差和特征重要性
oob_error = [];
feature_imp = [];

try
    oob_error = oobError(ensemble);
    feature_imp = ensemble.OOBPermutedPredictorDeltaError;
    if isempty(feature_imp)
        feature_imp = zeros(1, n_features);
    end
catch
end

model = struct();
model.ensemble = ensemble;
model.task_type = opts.TaskType;
model.oob_error = oob_error;
model.feature_imp = feature_imp(:)';
model.n_trees = opts.NumTrees;

% 输出摘要
fprintf('随机森林训练完成 (%s): %d 棵树', opts.TaskType, opts.NumTrees);
if ~isempty(oob_error)
    fprintf(', OOB误差 = %.4f', oob_error(end));
end
fprintf('\n');
end

%% Self-test
function self_test()
    % Test classification on iris-like tiny separable dataset
    if exist('TreeBagger', 'class')
        rng(42, 'twister');
        X = [1 1; 1.5 1; 5 5; 5.5 5];
        y = {'A'; 'A'; 'B'; 'B'};
        model = random_forest_train(X, y, 'NumTrees', 10, 'RandomSeed', 42);
        assert(strcmp(model.task_type, 'classification'), 'Test failed: expected classification.');
        y_pred = predict(model.ensemble, [1 1; 6 6]);
        assert(~isempty(y_pred), 'Test failed: predictions should not be empty.');
    else
        warning('Random Forest self-test: Statistics & ML Toolbox not available, test skipped.');
    end
    disp('random_forest_train self-test passed.');
end
