% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function result = prop_topsis_symmetry(n_trials)
%% PROP_TOPSIS_SYMMETRY Property test: Swapping rows doesn't change individual closeness.
%  Invariant: Permuting the rows of the decision matrix must produce
%             correspondingly permuted closeness scores.

arguments
    n_trials (1,1) double {mustBePositive} = 100
end

rng(42, 'twister');
result.pass = true;
result.violations = [];
result.n_trials = n_trials;

for i = 1:n_trials
    m = randi([4, 12]);
    n = randi([3, 7]);
    data = randn(m, n) * 8 + randi([20, 80], 1, n);
    data = abs(data);
    w = rand(1, n); w = w / sum(w);
    ctype = (randi([0, 1], n, 1) * 2 - 1);

    % Create a random permutation
    perm = randperm(m);

    try
        [~, ~, ~, ~, C_orig] = topsis_improved(data, w, ctype, ...
            'distance', 'euclidean', 'display', 'off', 'seed', 42+i);

        [~, ~, ~, ~, C_perm] = topsis_improved(data(perm, :), w, ctype, ...
            'distance', 'euclidean', 'display', 'off', 'seed', 42+i);
    catch ME
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', ['TOPSIS symmetry failed: ' ME.message]);
        continue;
    end

    % Invariant: C_perm should be the same permutation of C_orig
    diff_vals = abs(C_orig - C_perm(inv_perm(perm)));
    if max(diff_vals) > 1e-10
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', sprintf('TOPSIS symmetry violated: max|diff| = %.2e', max(diff_vals)));
    end
end
end

%% Nested: inverse permutation
function inv_p = inv_perm(p)
    inv_p = zeros(size(p));
    for k = 1:length(p)
        inv_p(p(k)) = k;
    end
end

%% Self-test
function self_test()
    result = prop_topsis_symmetry(5);
    assert(result.pass, 'Self-test failed: TOPSIS symmetry violated.');
    fprintf('prop_topsis_symmetry self-test PASSED (%d trials).\n', result.n_trials);
end
