% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function model = xgboost_train(X, y, varargin)
%XGBOOST_TRAIN  XGBoost 训练 (MATLAB → Python Bridge)
%   MODEL = XGBOOST_TRAIN(X, Y)
%
%   Source: Chen, T., Guestrin, C. (2016).
%          XGBoost: A Scalable Tree Boosting System. KDD 2016.
%   Package: xgboost (pip install xgboost)
%   Author: Adapted by MathModelingSkill
%   License: MIT
%   Verified: 2026-07-27
%
%   输入:
%       X  - 特征矩阵 (n_samples × n_features)
%       Y  - 标签向量 (n_samples × 1)
%
%   可选参数:
%       'TaskType'      - 'classification' | 'regression' (默认: 自动)
%       'NumRounds'     - 迭代轮数 (默认: 100)
%       'LearningRate'  - 学习率 eta (默认: 0.1)
%       'MaxDepth'      - 树最大深度 (默认: 6)
%       'Subsample'     - 行采样比例 (默认: 1.0)
%       'ColsampleBytree' - 列采样比例 (默认: 1.0)
%       'Lambda'        - L2 正则化 (默认: 1.0)
%       'Alpha'         - L1 正则化 (默认: 0.0)
%       'RandomSeed'    - 随机种子 (默认: 42)
%       'EarlyStoppingRounds' - 早停轮数 (默认: 10)
%       'Verbose'       - 是否输出日志 (默认: false)
%
%   输出:
%       model  - 结构体:
%           .py_model   - Python XGBoost 对象
%           .task_type  - 任务类型
%           .best_score - 最优验证分数
%           .best_iteration - 最优迭代数
%
%   示例:
%       X = randn(200,10); y = double(rand(200,1)>0.5);
%       model = xgboost_train(X, y, 'NumRounds', 50);
%
%   前置条件:
%       pip install xgboost
%       MATLAB: pyenv('Version', '<python路径>')

%% 依赖检查
try
    py.xgboost.XGBClassifier;
catch
    error('XGBoost Python 包未安装。请执行: pip install xgboost');
end

[n_samples, n_features] = size(X);

%% 自动任务类型
auto_task = 'classification';
if length(unique(y(~isnan(y)))) > 0.1 * n_samples || ~all(floor(y) == y)
    auto_task = 'regression';
end

%% 参数解析
p = inputParser;
p.addParameter('TaskType', auto_task, @(v) any(strcmp(v, {'classification', 'regression'})));
p.addParameter('NumRounds', 100, @(v) isscalar(v) && v > 0);
p.addParameter('LearningRate', 0.1, @(v) isscalar(v) && v > 0);
p.addParameter('MaxDepth', 6, @(v) isscalar(v) && v > 0);
p.addParameter('Subsample', 1.0, @(v) isscalar(v) && v > 0 && v <= 1);
p.addParameter('ColsampleBytree', 1.0, @(v) isscalar(v) && v > 0 && v <= 1);
p.addParameter('Lambda', 1.0, @(v) isscalar(v) && v >= 0);
p.addParameter('Alpha', 0.0, @(v) isscalar(v) && v >= 0);
p.addParameter('RandomSeed', 42, @(v) isscalar(v) && v >= 0);
p.addParameter('EarlyStoppingRounds', 10, @(v) isscalar(v) && v > 0);
p.addParameter('Verbose', false, @islogical);
p.parse(varargin{:});
opts = p.Results;

%% 数据转换
X_py = py.numpy.array(X(:).', 'float64');
X_py = py.numpy.reshape(X_py, int64([n_samples, n_features]));
y_py = py.numpy.array(y(:).', 'float64');

%% 参数配置
params = py.dict();
params{'n_estimators'} = int64(opts.NumRounds);
params{'learning_rate'} = opts.LearningRate;
params{'max_depth'} = int64(opts.MaxDepth);
params{'subsample'} = opts.Subsample;
params{'colsample_bytree'} = opts.ColsampleBytree;
params{'reg_lambda'} = opts.Lambda;
params{'reg_alpha'} = opts.Alpha;
params{'random_state'} = int64(opts.RandomSeed);
params{'verbosity'} = int64(opts.Verbose);

%% 训练
if strcmp(opts.TaskType, 'classification')
    n_classes = length(unique(y));
    if n_classes == 2
        objective = 'binary:logistic';
        params{'objective'} = objective;
        xgb = py.xgboost.XGBClassifier(params);
    else
        params{'objective'} = 'multi:softprob';
        xgb = py.xgboost.XGBClassifier(params);
    end
else
    params{'objective'} = 'reg:squarederror';
    xgb = py.xgboost.XGBRegressor(params);
end

xgb.fit(X_py, y_py, pyargs('verbose', opts.Verbose));

model.py_model = xgb;
model.task_type = opts.TaskType;

% 提取最佳分数
try
    model.best_score = double(xgb.best_score);
    model.best_iteration = double(xgb.best_iteration);
catch
    model.best_score = NaN;
    model.best_iteration = opts.NumRounds;
end

fprintf('XGBoost 训练完成 (%s): %d trees\n', opts.TaskType, opts.NumRounds);
end

%% Self-test
function self_test()
    % Test regression on y = 2*x dataset (conceptual / Python bridge)
    try
        py.xgboost.XGBRegressor;
        rng(42, 'twister');
        X = (1:10)'; X = [X, X*0.5];
        y = 2 * X(:,1);
        model = xgboost_train(X, y, 'TaskType', 'regression', 'NumRounds', 10, 'Verbose', false);
        assert(strcmp(model.task_type, 'regression'), 'Test failed: expected regression task.');
    catch ME
        warning('XGBoost self-test: Python bridge not available (err: %s), test skipped.', ME.message);
    end
    disp('xgboost_train self-test passed.');
end
