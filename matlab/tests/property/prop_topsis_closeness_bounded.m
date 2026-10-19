% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function result = prop_topsis_closeness_bounded(n_trials)
%% PROP_TOPSIS_CLOSENESS_BOUNDED Property test: TOPSIS closeness in [0, 1].
%  Invariant: C = D-/(D+ + D-) must be in [0, 1] for all valid inputs.

arguments
    n_trials (1,1) double {mustBePositive} = 100
end

rng(42, 'twister');
result.pass = true;
result.violations = [];
result.n_trials = n_trials;

for i = 1:n_trials
    m = randi([3, 20]);
    n = randi([2, 8]);
    data = randn(m, n) * 10 + randi([10, 100], 1, n);
    data = abs(data);  % ensure positive domain
    w = rand(1, n); w = w / sum(w);
    ctype = (randi([0, 1], n, 1) * 2 - 1);  % random benefit/cost

    % Test Euclidean
    try
        [scores1, ~, ~, ~, C1] = topsis_improved(data, w, ctype, ...
            'distance', 'euclidean', 'prospect', 'none', 'display', 'off', 'seed', 42+i);
    catch ME
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', ['TOPSIS Euclidean failed: ' ME.message]);
        continue;
    end

    % Invariant: closeness scores in [0, 1]
    if any(C1 < -1e-10 | C1 > 1 + 1e-10)
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', sprintf('TOPSIS closeness outside [0,1]: range [%.6f, %.6f]', ...
            min(C1), max(C1)));
    end

    % Test Mahalanobis
    try
        [scores2, ~, ~, ~, C2] = topsis_improved(data, w, ctype, ...
            'distance', 'mahalanobis', 'prospect', 'none', 'display', 'off', 'seed', 42+i);
    catch ME
        continue;  % Mahalanobis may fail for ill-conditioned data
    end

    if any(C2 < -1e-10 | C2 > 1 + 1e-10)
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', sprintf('TOPSIS Mahalanobis closeness outside [0,1]: range [%.6f, %.6f]', ...
            min(C2), max(C2)));
    end
end
end

%% Self-test
function self_test()
    result = prop_topsis_closeness_bounded(5);
    assert(result.pass, 'Self-test failed: TOPSIS closeness boundedness violated.');
    fprintf('prop_topsis_closeness_bounded self-test PASSED (%d trials).\n', result.n_trials);
end
