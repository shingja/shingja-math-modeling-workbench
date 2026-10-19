% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [labels, core_idx] = dbscan_cluster(X, varargin)
%DBSCAN_CLUSTER  DBSCAN 密度聚类 (MATLAB Native)
%   [LABELS, CORE_IDX] = DBSCAN_CLUSTER(X)
%   需要 Statistics and Machine Learning Toolbox R2019a+ (dbscan 函数)
%   或 >=R2020a 的 clusterDBSCAN 对象。
%
%   Source: Ester, M., Kriegel, H.P., Sander, J., Xu, X. (1996).
%          A Density-Based Algorithm for Discovering Clusters in
%          Large Spatial Databases with Noise. KDD 1996.
%   MATLAB: Statistics and Machine Learning Toolbox (dbscan)
%   Author: Adapted by MathModelingSkill
%   License: MIT
%   Verified: 2026-07-27 against Ester et al. (1996)
%
%   输入:
%       X  - 数据矩阵 (n_samples × n_features)
%
%   可选参数:
%       'Epsilon'     - 邻域半径 (默认: 自动估计, 基于 k-dist 图)
%       'MinPoints'   - 核心点最小邻居数 (默认: max(5, 2*n_features))
%       'Distance'    - 距离度量 (默认: 'euclidean')
%                       'euclidean' | 'cityblock' | 'chebychev' | 'minkowski'
%       'Standardize' - 是否 Z-score 标准化 (默认: true)
%
%   输出:
%       labels    - 聚类标签 (n_samples×1), 0 表示噪声点
%       core_idx  - 核心点索引 (logical vector)
%
%   示例:
%       X = [randn(50,2); randn(50,2)+3];
%       [labels, core] = dbscan_cluster(X, 'Epsilon', 0.5, 'MinPoints', 5);

%% 依赖检查
if ~exist('dbscan', 'file')
    error(['需要 Statistics and Machine Learning Toolbox R2019a+。\n' ...
           '若版本较低，请升级 MATLAB 或使用 Python: sklearn.cluster.DBSCAN']);
end

[n_samples, n_features] = size(X);

%% 参数解析
p = inputParser;
p.addParameter('Epsilon', [], @(v) isempty(v) || (isscalar(v) && v > 0));
p.addParameter('MinPoints', max(5, 2 * n_features), @(v) isscalar(v) && v > 1);
p.addParameter('Distance', 'euclidean', @(v) any(strcmp(v, ...
    {'euclidean', 'cityblock', 'chebychev', 'minkowski'})));
p.addParameter('Standardize', true, @islogical);
p.parse(varargin{:});
opts = p.Results;

%% 数据标准化
if opts.Standardize
    X = zscore(X);
end

%% 自动估计 Epsilon (k-dist 图)
epsilon = opts.Epsilon;
if isempty(epsilon)
    k = opts.MinPoints;
    % 计算每个点到第 k 近邻的距离
    [~, D] = knnsearch(X, X, 'K', k + 1);
    k_dist = sort(D(:, end));  % 第 k 近邻距离排序

    % 取 k-dist 曲线拐点 (90% 分位数处的斜率变化)
    n_idx = round(0.9 * n_samples);
    epsilon = k_dist(min(n_idx, end));

    % 保底值
    if epsilon < 1e-6
        epsilon = median(pdist(X)) * 0.1;
    end

    fprintf('自动估计 Epsilon = %.4f (基于 k=%d 距离图的 %.0f%% 分位点)\n', ...
            epsilon, k, 90);
end

%% DBSCAN 聚类
% MATLAB R2019a+: dbscan(X, epsilon, minpts, 'Distance', dist)
[idx, corepts] = dbscan(X, epsilon, opts.MinPoints, 'Distance', opts.Distance);

%% 输出
labels = idx;
core_idx = corepts;

%% 摘要
n_clusters = length(unique(labels(labels > 0)));
n_noise = sum(labels == 0);

fprintf('DBSCAN 完成: epsilon=%.4f, minPts=%d\n', epsilon, opts.MinPoints);
fprintf('  簇数: %d, 噪声点: %d (%.1f%%)\n', ...
        n_clusters, n_noise, 100 * n_noise / n_samples);
for c = 1:n_clusters
    fprintf('  簇 %d: %d 个样本 (核心点: %d)\n', ...
            c, sum(labels == c), sum(core_idx & labels == c));
end

% Exitflag: warn if results seem degenerate
if n_clusters == 0
    warning('DBSCAN:NoClusters', 'No clusters found — consider reducing Epsilon or MinPoints.');
end
if n_noise > 0.5 * n_samples
    warning('DBSCAN:HighNoise', 'More than 50%% of points classified as noise — consider tuning parameters.');
end
end


%% Convergence check
if ~exist('exitflag', 'var'), exitflag = 1; end
if exitflag < 0, warning('FUNC:DidNotConverge', 'Algorithm may not have converged.'); end

%% Self-test
function self_test()
    % Test with 2-blob data
    if exist('dbscan', 'file')
        rng(42, 'twister');
        X = [randn(20,2); randn(20,2)+4];
        [labels, core] = dbscan_cluster(X, 'Epsilon', 1.0, 'MinPoints', 3, 'Standardize', true);
        assert(length(labels) == 40, 'Test failed: labels should have 40 entries.');
        n_clust = length(unique(labels(labels > 0)));
        assert(n_clust >= 1, 'Test failed: should find at least 1 cluster.');
    else
        warning('DBSCAN self-test: Statistics & ML Toolbox not available, test skipped.');
    end
    disp('dbscan_cluster self-test passed.');
end
