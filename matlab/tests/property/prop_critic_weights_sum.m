% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function result = prop_critic_weights_sum(n_trials)
%% PROP_CRITIC_WEIGHTS_SUM Property test: CRITIC weights sum to 1.
%  Invariant: CRITIC objective weights must sum to 1 and be non-negative.

arguments
    n_trials (1,1) double {mustBePositive} = 100
end

rng(42, 'twister');
result.pass = true;
result.violations = [];
result.n_trials = n_trials;

for i = 1:n_trials
    m = randi([4, 40]);
    n = randi([2, 8]);
    data = randn(m, n) * 5 + randi([5, 50], 1, n);

    try
        [w, info, ef] = critic_weight(data, 'seed', 42+i);
    catch ME
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', ['CRITIC failed: ' ME.message]);
        continue;
    end

    % Invariant 1: weights sum to 1
    if abs(sum(w) - 1) > 1e-8
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', sprintf('CRITIC weights sum = %.10f != 1', sum(w)));
    end

    % Invariant 2: all weights >= 0
    if any(w < -1e-10)
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', 'CRITIC weights negative.');
    end

    % Invariant 3: exitflag should be 1 or 0
    if ~ismember(ef, [0, 1])
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', sprintf('CRITIC exitflag = %d (expected 0 or 1)', ef));
    end
end
end

%% Self-test
function self_test()
    result = prop_critic_weights_sum(5);
    assert(result.pass, 'Self-test failed: CRITIC weights sum violated.');
    fprintf('prop_critic_weights_sum self-test PASSED (%d trials).\n', result.n_trials);
end
