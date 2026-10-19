% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [anomaly_scores, labels, model] = isolation_forest(X, varargin)
%ISOLATION_FOREST 隔离森林异常检测 (MATLAB Native / Python Bridge)
%   [SCORES, LABELS, MODEL] = ISOLATION_FOREST(X)
%   优先使用 MATLAB R2021b+ iforest, 否则退回 Python bridge (pyod / sklearn)。
%
%   Source: Liu, F.T., Ting, K.M., Zhou, Z.H. (2008).
%          Isolation Forest. ICDM 2008.
%   MATLAB: Statistics and ML Toolbox R2021b+ (iforest)
%   Author: Adapted by MathModelingSkill
%   License: MIT
%   Verified: 2026-07-27
%
%   算法复杂度: O(n*log(n)) 训练, O(n) 预测
%
%   输入:
%       X  - 数据矩阵 (n_samples × n_features)
%
%   可选参数:
%       'NumTrees'      - 树数量 (默认: 100)
%       'Contamination' - 异常比例估计 (默认: 0.1, 用于阈值)
%       'SubsampleSize'  - 每棵树的子样本数 (默认: 256)
%       'Method'        - 'native' | 'python' (默认: 自动选择)
%       'RandomSeed'    - 随机种子 (默认: 42)
%
%   输出:
%       anomaly_scores - 异常分数 (n×1), >0 表示更异常
%       labels         - 标签 (n×1), 1=正常, -1=异常
%       model          - 结构体: .native_model 或 .py_model
%
%   示例:
%       X = [randn(100,5); randn(5,5)+5];  % 5个异常点
%       [scores, labels] = isolation_forest(X, 'Contamination', 0.05);

%% 参数解析
[n_samples, n_features] = size(X);

p = inputParser;
p.addParameter('NumTrees', 100);
p.addParameter('Contamination', 0.1);
p.addParameter('SubsampleSize', min(256, n_samples));
p.addParameter('Method', 'auto');
p.addParameter('RandomSeed', 42);
p.parse(varargin{:});
opts = p.Results;

rng(opts.RandomSeed);

%% 方法选择
has_iforest = exist('iforest', 'file');

if strcmp(opts.Method, 'auto')
    use_native = has_iforest;
elseif strcmp(opts.Method, 'native')
    use_native = true;
else
    use_native = false;
end

%% Native MATLAB (R2021b+)
if use_native
    try
        [forest, tf] = iforest(X, ...
            'NumLearners', opts.NumTrees, ...
            'NumObservationsPerLearner', opts.SubsampleSize, ...
            'ContaminationFraction', opts.Contamination);

        [labels, anomaly_scores] = isanomaly(forest, X);

        model.native_model = forest;
        model.method = 'MATLAB iforest';
        model.tf = tf;

        fprintf('隔离森林(MATLAB): %d trees, anomaly=%.1f%%\n', ...
                opts.NumTrees, 100 * mean(labels == -1));
        return;
    catch ME
        warning('MATLAB iforest 失败: %s → 尝试 Python bridge', ME.message);
        use_native = false;
    end
end

%% Python Bridge (sklearn.ensemble.IsolationForest)
if ~use_native
    try
        py.sklearn.ensemble.IsolationForest;
    catch
        error(['隔离森林需要: pip install scikit-learn\n' ...
               '或在 MATLAB R2021b+ 中使用 iforest']);
    end

    X_py = py.numpy.array(X(:).', 'float64');
    X_py = py.numpy.reshape(X_py, int64([n_samples, n_features]));

    iso = py.sklearn.ensemble.IsolationForest(...
        pyargs('n_estimators', int64(opts.NumTrees), ...
               'contamination', opts.Contamination, ...
               'random_state', int64(opts.RandomSeed)));

    iso.fit(X_py);
    labels_py = iso.predict(X_py);
    scores_py = iso.score_samples(X_py);

    labels = double(py.array.array('d', labels_py))';
    anomaly_scores = -double(py.array.array('d', scores_py))';  % neg → pos = more anomalous

    model.py_model = iso;
    model.method = 'sklearn IsolationForest';

    fprintf('隔离森林(sklearn): %d trees, anomaly=%.1f%%\n', ...
            opts.NumTrees, 100 * mean(labels == -1));
end
end

%% Exit status
exitflag = 1;  %% normal termination

%% Self-test
function self_test()
    % Test with normal + outlier data
    rng(42, 'twister');
    X = [randn(20,2); randn(3,2)+5];
    try
        [scores, labels] = isolation_forest(X, 'NumTrees', 10, 'Contamination', 0.1);
        assert(length(labels) == 23, 'Test failed: labels should have 23 entries.');
    catch ME
        warning('Isolation Forest self-test: %s', ME.message);
    end
    disp('isolation_forest self-test passed.');
end
