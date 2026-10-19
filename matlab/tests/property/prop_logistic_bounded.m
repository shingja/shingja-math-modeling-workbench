% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function result = prop_logistic_bounded(n_trials)
%% PROP_LOGISTIC_BOUNDED Property test: Logistic model population <= K for all t.
%  Invariant: N(t) = K/(1+(K/N0-1)*exp(-r*t)) <= K for N0 <= K.

arguments
    n_trials (1,1) double {mustBePositive} = 100
end

rng(42, 'twister');
result.pass = true;
result.violations = [];
result.n_trials = n_trials;

for i = 1:n_trials
    K = 500 + rand() * 5000;          % carrying capacity
    N0 = 1 + rand() * (K * 0.9);      % start below K
    r = 0.05 + rand() * 1.5;          % intrinsic growth rate
    t_end = 5 + rand() * 50;
    tspan = [0, t_end];

    try
        [t, N, ~] = logistic_model(N0, r, K, tspan, 'Display', 'off');
    catch ME
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', ['Logistic solve failed: ' ME.message]);
        continue;
    end

    % Invariant 1: N(t) <= K (with small tolerance)
    violation_idx = find(N > K * 1.001, 1);
    if ~isempty(violation_idx)
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', sprintf('N(t)=%.4f > K=%.4f at t=%.2f', ...
            N(violation_idx), K, t(violation_idx)));
    end

    % Invariant 2: N(t) > 0 for all t
    violation_idx2 = find(N <= 0, 1);
    if ~isempty(violation_idx2)
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', sprintf('N(t)=%.6e <= 0 at t=%.2f', ...
            N(violation_idx2), t(violation_idx2)));
    end
end
end

%% Self-test
function self_test()
    result = prop_logistic_bounded(5);
    assert(result.pass, 'Self-test failed: Logistic boundedness violated.');
    fprintf('prop_logistic_bounded self-test PASSED (%d trials).\n', result.n_trials);
end
