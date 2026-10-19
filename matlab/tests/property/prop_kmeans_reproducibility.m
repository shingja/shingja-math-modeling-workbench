% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function result = prop_kmeans_reproducibility(n_trials)
%% PROP_KMEANS_REPRODUCIBILITY Property test: Same seed -> same cluster assignment.
%  Invariant: Running k-means twice with identical data and seed
%             must produce the same cluster labels.

arguments
    n_trials (1,1) double {mustBePositive} = 100
end

rng(42, 'twister');
result.pass = true;
result.violations = [];
result.n_trials = n_trials;

for i = 1:n_trials
    n_pts = randi([20, 200]);
    dim = randi([2, 5]);
    k = randi([2, 5]);
    seed_val = 42 + i;

    % Generate clustered data
    X = [];
    for c = 1:k
        center = randn(1, dim) * 5;
        cluster_data = center + randn(ceil(n_pts/k), dim);
        X = [X; cluster_data];
    end

    try
        [~, labels1, ~] = kmeans_cluster(X, k, 'Seed', seed_val);
        [~, labels2, ~] = kmeans_cluster(X, k, 'Seed', seed_val);
    catch ME
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', ['K-means failed: ' ME.message]);
        continue;
    end

    % Invariant: same seed -> same labels
    if ~isequal(labels1, labels2)
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', sprintf('K-means not reproducible: %d/%d labels differ', ...
            sum(labels1 ~= labels2), length(labels1)));
    end
end
end

%% Self-test
function self_test()
    result = prop_kmeans_reproducibility(5);
    assert(result.pass, 'Self-test failed: K-means reproducibility violated.');
    fprintf('prop_kmeans_reproducibility self-test PASSED (%d trials).\n', result.n_trials);
end
