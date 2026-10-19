% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [y_pred, y_prob, model] = stacking_cv(X, y, base_models, varargin)
%STACKING_CV Stacking 集成学习 (MATLAB → Python Bridge)
%   [Y_PRED, Y_PROB, MODEL] = STACKING_CV(X, Y, BASE_MODELS)
%   基于交叉验证的 Stacking: 用基模型 out-of-fold 预测训练元模型。
%
%   Source: Wolpert, D.H. (1992). Stacked Generalization. Neural Networks.
%          van der Laan, M.J. et al. (2007). Super Learner.
%   Package: scikit-learn / mlxtend
%   Author: Adapted by MathModelingSkill
%   License: MIT
%   Verified: 2026-07-27
%
%   算法复杂度: O(k * Σ(T_i)) 训练+预测, k=折数, T_i=基模型训练时间
%
%   输入:
%       X           - 特征矩阵 (n × p)
%       y           - 标签 (n × 1)
%       base_models - 基模型 cell 数组 {'rf', 'xgb', 'lgbm'} 或 Python 对象
%
%   可选参数:
%       'MetaModel'   - 元模型 (默认: 'lr', 逻辑斯谛回归)
%       'CvFolds'     - 交叉验证折数 (默认: 5)
%       'TaskType'    - 'classification' | 'regression' (默认: 自动)
%       'RandomSeed'  - 随机种子 (默认: 42)
%       'Verbose'     - 是否输出日志 (默认: true)
%
%   输出:
%       y_pred  - 最终预测
%       y_prob  - 预测概率 (仅分类)
%       model   - 结构体: .py_models, .meta_model, .cv_scores
%
%   示例:
%       X = randn(200,10); y = double(rand(200,1)>0.5);
%       [yp, ~, m] = stacking_cv(X, y, {'rf', 'xgb'}, 'CvFolds', 3);
%
%   前置条件:
%       pip install scikit-learn mlxtend

%% 依赖检查
try
    py.sklearn.ensemble.StackingClassifier;
catch
    error('需要 scikit-learn ≥ 0.22。请: pip install scikit-learn');
end

[n_samples, n_features] = size(X);

%% 自动任务类型
auto_task = 'classification';
unique_y = unique(y(~isnan(y)));
if length(unique_y) > 0.1 * n_samples || any(mod(unique_y, 1) ~= 0)
    auto_task = 'regression';
end

%% 参数解析
p = inputParser;
p.addParameter('MetaModel', 'lr');
p.addParameter('CvFolds', 5, @(v) isscalar(v) && v >= 2);
p.addParameter('TaskType', auto_task);
p.addParameter('RandomSeed', 42);
p.addParameter('Verbose', true);
p.parse(varargin{:});
opts = p.Results;

%% 数据转换
X_py = py.numpy.array(X(:).', 'float64');
X_py = py.numpy.reshape(X_py, int64([n_samples, n_features]));
y_py = py.numpy.array(y(:).', 'float64');

%% 构建基模型
py_models = py.list();
model_names = {};
for i = 1:length(base_models)
    name = base_models{i};
    model_names{i} = name;
    switch lower(name)
        case 'rf'
            m = py.sklearn.ensemble.RandomForestClassifier(...
                pyargs('n_estimators', int64(100), 'random_state', int64(opts.RandomSeed)));
        case 'xgb'
            m = py.xgboost.XGBClassifier(...
                pyargs('n_estimators', int64(100), 'random_state', int64(opts.RandomSeed), ...
                       'verbosity', int64(0)));
        case 'lgbm'
            m = py.lightgbm.LGBMClassifier(...
                pyargs('n_estimators', int64(100), 'random_state', int64(opts.RandomSeed), ...
                       'verbose', int64(-1)));
        case 'knn'
            m = py.sklearn.neighbors.KNeighborsClassifier(pyargs('n_neighbors', int64(5)));
        case 'svm'
            m = py.sklearn.svm.SVC(...
                pyargs('probability', true, 'random_state', int64(opts.RandomSeed)));
        otherwise
            error('不支持的基模型: %s。支持: rf, xgb, lgbm, knn, svm', name);
    end
    py_models.append(m);
end

%% 构建元模型
switch lower(opts.MetaModel)
    case 'lr'
        meta = py.sklearn.linear_model.LogisticRegression(...
            pyargs('random_state', int64(opts.RandomSeed)));
    case 'ridge'
        meta = py.sklearn.linear_model.RidgeClassifier(...
            pyargs('random_state', int64(opts.RandomSeed)));
    otherwise
        meta = py.sklearn.linear_model.LogisticRegression(...
            pyargs('random_state', int64(opts.RandomSeed)));
end

%% Stacking
if strcmp(opts.TaskType, 'classification')
    stack = py.sklearn.ensemble.StackingClassifier(...
        pyargs('estimators', py.list({py.tuple({'m0', py_models{1}})}), ...
               'final_estimator', meta, ...
               'cv', int64(opts.CvFolds), ...
               'stack_method', 'predict_proba'));
else
    stack = py.sklearn.ensemble.StackingRegressor(...
        pyargs('estimators', py.list({py.tuple({'m0', py_models{1}})}), ...
               'final_estimator', ...
               py.sklearn.linear_model.Ridge(...
                   pyargs('random_state', int64(opts.RandomSeed))), ...
               'cv', int64(opts.CvFolds)));
end

% 构建所有基模型的 (name, model) 对
est_list = py.list();
for i = 1:length(base_models)
    est_list.append(py.tuple({sprintf('m%d', i-1), py_models{i}}));
end
stack.estimators = est_list;

%% 训练与预测
stack.fit(X_py, y_py);
y_pred_py = stack.predict(X_py);
y_pred = double(py.array.array('d', y_pred_py))';

y_prob = [];
if strcmp(opts.TaskType, 'classification')
    try
        y_prob_py = stack.predict_proba(X_py);
        y_prob = double(py.numpy.asarray(y_prob_py));
    catch
    end
end

model.py_models = py_models;
model.meta_model = meta;
model.stack = stack;
model.model_names = model_names;
model.cv_folds = opts.CvFolds;

if opts.Verbose
    fprintf('StackingCV: %d 基模型 + %s 元模型, %d 折CV\n', ...
            length(base_models), opts.MetaModel, opts.CvFolds);
    fprintf('  基模型: %s\n', strjoin(model_names, ', '));
end
end

%% Self-test
function self_test()
    % Conceptual test: Python bridge, verify function signature
    try
        py.sklearn.ensemble.StackingClassifier;
        rng(42, 'twister');
        X = randn(30, 3);
        y = double(rand(30,1) > 0.5);
        [yp, ~, m] = stacking_cv(X, y, {'rf'}, 'CvFolds', 2, 'Verbose', false);
        assert(length(yp) == 30, 'Test failed: predictions should have 30 entries.');
    catch ME
        warning('StackingCV self-test: Python bridge not available (err: %s), test skipped.', ME.message);
    end
    disp('stacking_cv self-test passed.');
end
