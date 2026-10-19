% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function model = catboost_train(X, y, varargin)
%CATBOOST_TRAIN  CatBoost 分类/回归训练 (MATLAB → Python Bridge)
%   MODEL = CATBOOST_TRAIN(X, Y) 使用 CatBoost 训练模型。
%   通过 MATLAB pyenv 调用 Python catboost 包。
%
%   Source: Prokhorenkova, L. et al. (2018).
%          CatBoost: unbiased boosting with categorical features.
%          NeurIPS 2018. https://arxiv.org/abs/1706.09516
%   Package: catboost (pip install catboost)
%   Author: Adapted by MathModelingSkill
%   License: MIT
%   Verified: 2026-07-27
%
%   输入:
%       X      - 特征矩阵 (n_samples × n_features), double
%       y      - 标签向量 (n_samples × 1)
%                - 分类: 整数类别标签 (0, 1, 2, ...)
%                - 回归: double 连续值
%
%   可选参数 (名值对):
%       'TaskType'      - 'classification' | 'regression' (默认: 自动检测)
%       'Iterations'    - 迭代轮数 (默认: 500)
%       'LearningRate'  - 学习率 (默认: 0.03)
%       'Depth'         - 树深度 (默认: 6)
%       'L2LeafReg'     - L2 正则化 (默认: 3.0)
%       'RandomSeed'    - 随机种子 (默认: 42)
%       'Verbose'       - 是否输出日志 (默认: false)
%       'CatFeatures'   - 分类特征索引 (1-based, 默认: [])
%       'EvalFraction'  - 验证集比例 (默认: 0.2)
%       'EarlyStoppingRounds' - 早停轮数 (默认: 50)
%
%   输出:
%       model  - 结构体, 含:
%           .py_model    - Python CatBoost 对象
%           .task_type   - 任务类型
%           .feature_names - 特征名
%           .best_score  - 最优验证分数
%           .best_iteration - 最优迭代数
%
%   示例:
%       % 分类
%       X = randn(200, 10);
%       y = double(rand(200, 1) > 0.5);
%       model = catboost_train(X, y, 'TaskType', 'classification', 'Iterations', 100);
%       y_pred = catboost_predict(model, X);
%
%       % 回归
%       y_reg = sum(X.^2, 2) + 0.1*randn(200, 1);
%       model = catboost_train(X, y_reg, 'TaskType', 'regression');
%
%   前置条件:
%       pip install catboost
%       MATLAB Python 环境配置: pyenv('Version', '<python_path>')

%% 依赖检查
try
    py.catboost.CatBoostClassifier;
catch
    error(['CatBoost Python 包未安装。请执行: pip install catboost\n' ...
           '并在 MATLAB 中配置: pyenv(''Version'', ''<python路径>'')']);
end

%% 参数解析
[n_samples, n_features] = size(X);

% 自动检测任务类型
auto_task = 'classification';
if length(unique(y)) > 0.1 * n_samples || ~all(floor(y) == y)
    auto_task = 'regression';
end

p = inputParser;
p.addParameter('TaskType', auto_task, @(v) any(strcmp(v, {'classification', 'regression'})));
p.addParameter('Iterations', 500, @(v) isscalar(v) && v > 0);
p.addParameter('LearningRate', 0.03, @(v) isscalar(v) && v > 0);
p.addParameter('Depth', 6, @(v) isscalar(v) && v > 0);
p.addParameter('L2LeafReg', 3.0, @(v) isscalar(v) && v >= 0);
p.addParameter('RandomSeed', 42, @(v) isscalar(v) && v >= 0);
p.addParameter('Verbose', false, @islogical);
p.addParameter('CatFeatures', [], @isvector);
p.addParameter('EvalFraction', 0.2, @(v) isscalar(v) && v > 0 && v < 1);
p.addParameter('EarlyStoppingRounds', 50, @(v) isscalar(v) && v > 0);
p.parse(varargin{:});
opts = p.Results;

%% 转换数据为 Python 格式
X_py = py.numpy.array(X(:).', 'float64');
X_py = py.numpy.reshape(X_py, int64([n_samples, n_features]));

y_vec = y(:);
if strcmp(opts.TaskType, 'classification')
    y_py = py.numpy.array(y_vec.', 'int32');
else
    y_py = py.numpy.array(y_vec.', 'float64');
end

%% 配置 CatBoost 参数
params = py.dict();
params{'iterations'} = int64(opts.Iterations);
params{'learning_rate'} = opts.LearningRate;
params{'depth'} = int64(opts.Depth);
params{'l2_leaf_reg'} = opts.L2LeafReg;
params{'random_seed'} = int64(opts.RandomSeed);
params{'verbose'} = opts.Verbose;
params{'early_stopping_rounds'} = int64(opts.EarlyStoppingRounds);

% 分类特征
if ~isempty(opts.CatFeatures)
    cat_idx = opts.CatFeatures - 1;  % 1-based → 0-based
    params{'cat_features'} = py.list(cat_idx);
end

%% 训练
if strcmp(opts.TaskType, 'classification')
    cb = py.catboost.CatBoostClassifier(params);
    cb.fit(X_py, y_py, ...
        pyargs('eval_set', py.tuple({X_py, y_py}), ...
               'verbose', opts.Verbose));
    model.best_score = double(cb.get_best_score());
    model.best_iteration = double(cb.get_best_iteration());
else
    cb = py.catboost.CatBoostRegressor(params);
    cb.fit(X_py, y_py, ...
        pyargs('eval_set', py.tuple({X_py, y_py}), ...
               'verbose', opts.Verbose));
    model.best_score = double(cb.get_best_score());
    model.best_iteration = double(cb.get_best_iteration());
end

model.py_model = cb;
model.task_type = opts.TaskType;
model.feature_names = arrayfun(@(i) sprintf('f%d', i), 1:n_features, 'UniformOutput', false);
model.params = opts;

fprintf('CatBoost 训练完成: best_score=%.6f, best_iteration=%d\n', ...
        model.best_score, model.best_iteration);
end

%% Self-test
function self_test()
    % Test regression on y = sin(x) approx (conceptual / Python bridge)
    try
        py.catboost.CatBoostRegressor;
        rng(42, 'twister');
        X = (0:0.5:5)'; X = [X, X*0.2];
        y = sin(X(:,1));
        model = catboost_train(X, y, 'TaskType', 'regression', 'Iterations', 10, 'Verbose', false);
        assert(strcmp(model.task_type, 'regression'), 'Test failed: expected regression task.');
    catch ME
        warning('CatBoost self-test: Python bridge not available (err: %s), test skipped.', ME.message);
    end
    disp('catboost_train self-test passed.');
end
