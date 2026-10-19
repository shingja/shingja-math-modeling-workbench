% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function result = prop_sir_conservation(n_trials)
%% PROP_SIR_CONSERVATION Property test: S+I+R = N for SIS/SIR extended models.
%  Tests SIS model conservation: S + I = N (constant).

arguments
    n_trials (1,1) double {mustBePositive} = 100
end

rng(42, 'twister');
result.pass = true;
result.violations = [];
result.n_trials = n_trials;

for i = 1:n_trials
    % Generate random SIS parameters
    S0 = 500 + randi([100, 10000]);
    I0_val = randi([1, max(1, floor(S0 * 0.1))]);
    N_pop = S0 + I0_val;
    beta = 0.0001 + rand() * 0.01;
    gamma = 0.01 + rand() * 0.5;
    tspan = [0, 20 + randi([0, 100])];

    try
        [t, S, I, ~] = sis_model(S0, I0_val, beta, gamma, tspan, 'Display', 'off');
    catch ME
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', ['SIS solve failed: ' ME.message]);
        continue;
    end

    % Invariant: S + I = N
    total_pop = S + I;
    violation_idx = find(abs(total_pop - N_pop) > 1e-4 * N_pop, 1);

    if ~isempty(violation_idx)
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', sprintf('S+I != N at t=%.2f: sum=%.6f, N=%d', ...
            t(violation_idx), total_pop(violation_idx), N_pop));
    end
end
end

%% Self-test
function self_test()
    result = prop_sir_conservation(5);
    assert(result.pass, 'Self-test failed: SIS conservation violated.');
    fprintf('prop_sir_conservation self-test PASSED (%d trials).\n', result.n_trials);
end
