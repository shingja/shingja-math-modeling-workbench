% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [centroids, labels, inertia] = kmeans_cluster(X, k, varargin)
% KMEANS_CLUSTER  K-Means clustering with k-means++ initialization.
%
%   [CENTROIDS, LABELS, INERTIA] = KMEANS_CLUSTER(X, K)
%   X:           n×p data matrix (n observations, p features).
%   K:           number of clusters (positive integer).
%
%   Optional name-value pairs:
%   'MaxIter', M:     maximum iterations (default 100).
%   'Tol', T:         convergence tolerance on centroid shift (default 1e-4).
%   'Replicates', R:  number of random restarts (default 1).
%   'Seed', S:        random seed for reproducibility (default: no seed).
%
%   CENTROIDS: k×p matrix, final cluster centers.
%   LABELS:    n×1 vector, cluster assignments (1..k).
%   INERTIA:   scalar, sum of squared distances to centroids.
%
%   Example:
%       X = [randn(50,2)+2; randn(50,2)-2];
%       [c, lbl, inertia] = kmeans_cluster(X, 2);
%       gscatter(X(:,1), X(:,2), lbl);
%
%   References:
%       Lloyd, S.P. (1982). IEEE Trans. Info. Theory 28(2):129-137.
%       Arthur, D. & Vassilvitskii, S. (2007). SODA pp.1027-1035.
%       《各类常用数学模型》第29章 多元分析

p = inputParser;
p.addRequired('X', @isnumeric);
p.addRequired('k', @(x) isnumeric(x) && x > 0 && mod(x, 1) == 0);
p.addParameter('MaxIter', 100, @isnumeric);
p.addParameter('Tol', 1e-4, @isnumeric);
p.addParameter('Replicates', 1, @isnumeric);
p.addParameter('Seed', [], @isnumeric);
p.parse(X, k, varargin{:});

opts = p.Results;
[n, dim] = size(X);

if k > n
    error('kmeans_cluster:TooManyClusters', ...
        'Number of clusters (%d) exceeds number of observations (%d).', k, n);
end

if ~isempty(opts.Seed)
    rng(opts.Seed);
end

best_inertia = inf;
best_centroids = [];
best_labels    = [];

for rep = 1:opts.Replicates
    % --- k-means++ initialization ---
    centroids = zeros(k, dim);
    % First centroid: random data point
    centroids(1, :) = X(randi(n), :);

    for c = 2:k
        % Compute min squared distance to existing centroids
        D = zeros(n, 1);
        for i = 1:n
            dists = sum((X(i, :) - centroids(1:c-1, :)).^2, 2);
            D(i) = min(dists);
        end
        % Probability proportional to D
        cumprob = cumsum(D) / sum(D);
        r = rand();
        centroids(c, :) = X(find(cumprob >= r, 1), :);
    end

    % --- Lloyd iteration ---
    prev_centroids = zeros(k, dim);
    for iter = 1:opts.MaxIter
        % Assignment step
        labels = assign_labels(X, centroids);

        % Update step
        prev_centroids = centroids;
        for c = 1:k
            members = X(labels == c, :);
            if ~isempty(members)
                centroids(c, :) = mean(members, 1);
            end
            % Empty cluster: re-initialize at random point
            if isempty(members)
                centroids(c, :) = X(randi(n), :);
            end
        end

        % Convergence check
        if max(vecnorm(centroids - prev_centroids, 2, 2)) < opts.Tol
            break;
        end
    end

    % --- Compute inertia ---
    inertia = 0;
    for i = 1:n
        inertia = inertia + sum((X(i, :) - centroids(labels(i), :)).^2);
    end

    if inertia < best_inertia
        best_inertia   = inertia;
        best_centroids = centroids;
        best_labels    = labels;
    end
end

centroids = best_centroids;
labels    = best_labels;
inertia   = best_inertia;
end

function labels = assign_labels(X, centroids)
    n = size(X, 1);
    k = size(centroids, 1);
    labels = zeros(n, 1);
    for i = 1:n
        dists = sum((X(i, :) - centroids).^2, 2);
        [~, labels(i)] = min(dists);
    end
end

%% Self-test
function self_test()
    % Test with 3-point dataset → 2 clusters with known centers
    rng(42, 'twister');
    X = [0 0; 0 1; 10 10];
    [centroids, labels, inertia] = kmeans_cluster(X, 2, 'Seed', 42);
    assert(size(centroids, 1) == 2, 'Test failed: expected 2 clusters.');
    assert(size(labels, 1) == 3, 'Test failed: expected 3 labels.');
    assert(inertia >= 0, 'Test failed: inertia should be non-negative.');
    disp('kmeans_cluster self-test passed.');
end
