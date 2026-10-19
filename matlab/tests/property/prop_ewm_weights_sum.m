% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function result = prop_ewm_weights_sum(n_trials)
%% PROP_EWM_WEIGHTS_SUM Property test: Entropy Weight Method weights sum to 1.
%  Invariant: For any data matrix with >= 2 samples and >= 2 indicators,
%             the computed EWM weights must sum to 1 and be non-negative.

arguments
    n_trials (1,1) double {mustBePositive} = 100
end

rng(42, 'twister');
result.pass = true;
result.violations = [];
result.n_trials = n_trials;

for i = 1:n_trials
    n_samples = randi([3, 50]);
    n_ind = randi([2, 10]);
    % Random data matrix
    data = randn(n_samples, n_ind) * 3 + randi([2, 20], 1, n_ind);
    % Random directions (+1 benefit, -1 cost)
    dirs = (randi([0, 1], n_ind, 1) * 2 - 1);

    try
        [w, e, u] = ewm_weight(data, 'directions', dirs, 'verbose', false);
    catch ME
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', ['EWM failed: ' ME.message]);
        continue;
    end

    % Invariant 1: weights sum to 1
    if abs(sum(w) - 1) > 1e-8
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', sprintf('EWM weights sum = %.10f != 1', sum(w)));
    end

    % Invariant 2: all weights in (0, 1)
    if any(w <= -1e-10) || any(w > 1 + 1e-10)
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', 'EWM weights outside [0,1].');
    end

    % Invariant 3: entropy in [0, 1]
    if any(e < -1e-10 | e > 1 + 1e-10)
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', 'Entropy values outside [0,1].');
    end
end
end

%% Self-test
function self_test()
    result = prop_ewm_weights_sum(5);
    assert(result.pass, 'Self-test failed: EWM weights sum violated.');
    fprintf('prop_ewm_weights_sum self-test PASSED (%d trials).\n', result.n_trials);
end
