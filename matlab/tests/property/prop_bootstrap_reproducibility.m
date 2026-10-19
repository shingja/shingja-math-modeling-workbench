% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function result = prop_bootstrap_reproducibility(n_trials)
%% PROP_BOOTSTRAP_REPRODUCIBILITY Property test: Same seed -> same CI.
%  Invariant: Running bootstrap with identical data and seed
%             must produce exactly the same confidence interval.

arguments
    n_trials (1,1) double {mustBePositive} = 100
end

rng(42, 'twister');
result.pass = true;
result.violations = [];
result.n_trials = n_trials;

for i = 1:n_trials
    n_samples = randi([10, 100]);
    data = randn(n_samples, 1) * 3 + 10;
    seed_val = 42 + i;
    stat_fn = @mean;
    n_boot = 200;

    try
        [ci1_l, ci1_h] = bootstrap_resample('ci', data, stat_fn, n_boot, 0.05, ...
            'seed', seed_val);

        [ci2_l, ci2_h] = bootstrap_resample('ci', data, stat_fn, n_boot, 0.05, ...
            'seed', seed_val);
    catch ME
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', ['Bootstrap failed: ' ME.message]);
        continue;
    end

    % Invariant: same seed -> same CI
    if abs(ci1_l - ci2_l) > 1e-12 || abs(ci1_h - ci2_h) > 1e-12
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', sprintf('Bootstrap not reproducible: CI1=[%.6f,%.6f] vs CI2=[%.6f,%.6f]', ...
            ci1_l, ci1_h, ci2_l, ci2_h));
    end
end
end

%% Self-test
function self_test()
    result = prop_bootstrap_reproducibility(5);
    assert(result.pass, 'Self-test failed: bootstrap reproducibility violated.');
    fprintf('prop_bootstrap_reproducibility self-test PASSED (%d trials).\n', result.n_trials);
end
