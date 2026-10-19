% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function result = prop_pso_reproducibility(n_trials)
%% PROP_PSO_REPRODUCIBILITY Property test: Same seed -> same PSO result (bit-exact).
%  Invariant: Running PSO twice with identical parameters and seed
%             must produce exactly the same result.

arguments
    n_trials (1,1) double {mustBePositive} = 100
end

rng(42, 'twister');
result.pass = true;
result.violations = [];
result.n_trials = n_trials;

for i = 1:n_trials
    % Generate random test function
    dim = randi([2, 5]);
    shift = randn(dim, 1) * 5;
    scale = 1 + rand(dim, 1) * 5;
    test_fun = @(x) sum(scale .* (x(:) - shift).^2);

    lb = -10 * ones(dim, 1);
    ub = 10 * ones(dim, 1);
    seed_val = 42 + i;

    try
        [x1, f1, ~, ~] = particleswarm_pso(test_fun, lb, ub, ...
            'SwarmSize', 30, 'MaxIterations', 50, 'seed', seed_val);

        [x2, f2, ~, ~] = particleswarm_pso(test_fun, lb, ub, ...
            'SwarmSize', 30, 'MaxIterations', 50, 'seed', seed_val);
    catch ME
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', ['PSO failed: ' ME.message]);
        continue;
    end

    % Invariant: same seed -> bit-exact same result
    if norm(x1 - x2) > 1e-12 || abs(f1 - f2) > 1e-12
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', sprintf('PSO not reproducible: |dx|=%.2e, |df|=%.2e', ...
            norm(x1 - x2), abs(f1 - f2)));
    end
end
end

%% Self-test
function self_test()
    result = prop_pso_reproducibility(5);
    assert(result.pass, 'Self-test failed: PSO reproducibility violated.');
    fprintf('prop_pso_reproducibility self-test PASSED (%d trials).\n', result.n_trials);
end
