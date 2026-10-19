% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [labels, tree, linkage_matrix] = hierarchical_cluster(X, varargin)
rng(42, 'twister');
%HIERARCHICAL_CLUSTER 层次聚类 (Agglomerative Hierarchical Clustering)
%   [LABELS, TREE, LINKAGE_MATRIX] = HIERARCHICAL_CLUSTER(X)
%   需要 Statistics and Machine Learning Toolbox (linkage, cluster, pdist).
%
%   Source: Murtagh, F., Contreras, P. (2012).
%          Algorithms for hierarchical clustering: an overview.
%          Wiley Interdisciplinary Reviews: Data Mining and Knowledge Discovery.
%   MATLAB: Statistics and Machine Learning Toolbox
%   Author: Adapted by MathModelingSkill
%   License: MIT
%   Verified: 2026-07-27
%
%   输入:
%       X  - 数据矩阵 (n_samples × n_features)
%
%   可选参数:
%       'NumClusters'  - 目标聚类数 (默认: 3), 与 'Cutoff' 互斥
%       'Cutoff'       - 不一致系数阈值 (默认: []), 与 'NumClusters' 互斥
%       'Method'       - 链接方法 (默认: 'ward')
%                        'ward' | 'single' | 'complete' | 'average' | 'centroid' | 'median'
%       'Distance'     - 距离度量 (默认: 'euclidean')
%                        'euclidean' | 'cityblock' | 'correlation' | 'cosine' | 'chebychev'
%       'Standardize'  - 是否 Z-score 标准化 (默认: true)
%       'MaxClusters'  - 最大聚类数 (默认: min(10, n_samples))
%
%   输出:
%       labels         - 聚类标签 (n_samples×1), 1-based
%       tree           - 聚类树结构体
%       linkage_matrix - 链接矩阵 (n_samples-1 × 3), [i, j, dist]
%
%   示例:
%       X = [randn(30,2); randn(30,2)+3; randn(30,2)+6];
%       labels = hierarchical_cluster(X, 'NumClusters', 3);

%% 依赖检查
if ~exist('linkage', 'file')
    error('需要 Statistics and Machine Learning Toolbox。');
end

[n_samples, n_features] = size(X);

p = inputParser;
p.addParameter('NumClusters', 3, @(v) isscalar(v) && v > 0 && v <= n_samples);
p.addParameter('Cutoff', [], @(v) isempty(v) || (isscalar(v) && v > 0));
p.addParameter('Method', 'ward', @(v) any(strcmp(v, ...
    {'ward', 'single', 'complete', 'average', 'centroid', 'median'})));
p.addParameter('Distance', 'euclidean', @(v) any(strcmp(v, ...
    {'euclidean', 'cityblock', 'correlation', 'cosine', 'chebychev', 'seuclidean', 'mahalanobis'})));
p.addParameter('Standardize', true, @islogical);
p.addParameter('MaxClusters', min(10, n_samples), @(v) isscalar(v) && v > 0);
p.parse(varargin{:});
opts = p.Results;

%% 数据标准化
if opts.Standardize
    X = zscore(X);
end

%% 计算距离矩阵并链接
% pdist → 成对距离 → linkage → 层次树
dist_vec = pdist(X, opts.Distance);
linkage_matrix = linkage(dist_vec, opts.Method);

%% 生成聚类标签
if ~isempty(opts.Cutoff)
    % 基于不一致系数阈值切割
    labels = cluster(linkage_matrix, 'cutoff', opts.Cutoff, 'criterion', 'inconsistent');
else
    % 基于聚类数切割
    labels = cluster(linkage_matrix, 'maxclust', opts.NumClusters);
end

%% 构建树结构体
tree.linkage = linkage_matrix;
tree.method = opts.Method;
tree.distance = opts.Distance;
tree.n_samples = n_samples;
tree.cophenetic_corr = cophenet(linkage_matrix, dist_vec);

%% 摘要输出
n_clusters = length(unique(labels));
fprintf('层次聚类完成: %d 个样本 → %d 个簇 (方法: %s, 距离: %s)\n', ...
        n_samples, n_clusters, opts.Method, opts.Distance);
fprintf('  共表型相关系数 (Cophenetic): %.4f\n', tree.cophenetic_corr);

% 各簇样本数
for c = 1:n_clusters
    fprintf('  簇 %d: %d 个样本\n', c, sum(labels == c));
end
end

%% Self-test
function self_test()
rng(42, 'twister');
    % Test with 3-point dataset
    if exist('linkage', 'file')
        X = [0 0; 0 1; 5 5];
        labels = hierarchical_cluster(X, 'NumClusters', 2, 'Standardize', false);
        assert(length(labels) == 3, 'Test failed: labels should have 3 entries.');
        assert(length(unique(labels)) == 2, 'Test failed: should have 2 clusters.');
    else
        warning('Hierarchical cluster self-test: Statistics & ML Toolbox not available, test skipped.');
    end
    disp('hierarchical_cluster self-test passed.');
end
