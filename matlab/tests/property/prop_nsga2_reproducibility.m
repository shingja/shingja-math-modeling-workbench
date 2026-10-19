% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function result = prop_nsga2_reproducibility(n_trials)
%% PROP_NSGA2_REPRODUCIBILITY Property test: Same seed -> same Pareto front.
%  Invariant: Running NSGA-II twice with identical parameters and seed
%             must produce the same Pareto front.

arguments
    n_trials (1,1) double {mustBePositive} = 100
end

rng(42, 'twister');
result.pass = true;
result.violations = [];
result.n_trials = n_trials;

for i = 1:n_trials
    nvars = randi([2, 4]);
    % Simple bi-objective test problem (ZDT1-like)
    test_funs = @(x) [x(1), ...
        (1 + 9/(nvars-1)*sum(x(2:end))) * (1 - sqrt(x(1)/(1 + 9/(nvars-1)*sum(x(2:end)))))];
    bounds = [zeros(nvars, 1), ones(nvars, 1)];
    seed_val = 42 + i;

    try
        [pf1, ps1, ~] = nsga2_optimize(test_funs, nvars, bounds, ...
            'seed', seed_val, 'pop_size', 40, 'n_gen', 30);

        [pf2, ps2, ~] = nsga2_optimize(test_funs, nvars, bounds, ...
            'seed', seed_val, 'pop_size', 40, 'n_gen', 30);
    catch ME
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', ['NSGA2 failed: ' ME.message]);
        continue;
    end

    % Invariant: same seed -> same Pareto front
    if ~isequal(size(pf1), size(pf2))
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', sprintf('NSGA2 front size mismatch: %d vs %d', ...
            size(pf1, 1), size(pf2, 1)));
    elseif norm(pf1(:) - pf2(:)) > 1e-10
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', sprintf('NSGA2 not reproducible: |dpf|=%.2e', ...
            norm(pf1(:) - pf2(:))));
    end
end
end

%% Self-test
function self_test()
    result = prop_nsga2_reproducibility(5);
    assert(result.pass, 'Self-test failed: NSGA2 reproducibility violated.');
    fprintf('prop_nsga2_reproducibility self-test PASSED (%d trials).\n', result.n_trials);
end
