% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function result = prop_seirs_conservation(n_trials)
%% PROP_SEIRS_CONSERVATION Property test: S+E+I+R = N for SEIRS+vaccine model.
%  Invariant: total population N must be conserved throughout the simulation.

arguments
    n_trials (1,1) double {mustBePositive} = 100
end

rng(42, 'twister');
result.pass = true;
result.violations = [];
result.n_trials = n_trials;

for i = 1:n_trials
    % Generate random valid parameters
    N_pop = 500 + randi([100, 20000]);
    I0_val = randi([1, max(1, floor(N_pop * 0.05))]);
    E0_val = randi([0, max(0, floor(N_pop * 0.03))]);
    R0_val = randi([0, max(0, floor(N_pop * 0.02))]);

    beta = 0.1 + rand() * 0.8;
    sigma = 0.05 + rand() * 0.4;
    gamma = 0.02 + rand() * 0.3;
    omega = 0.001 + rand() * 0.05;
    v = rand() * 0.1;
    tspan = [0, 30 + randi([0, 200])];

    try
        res = seirs_vaccine(struct('N', N_pop, 'beta', beta, 'sigma', sigma, ...
            'gamma', gamma, 'omega', omega, 'v', v, ...
            'I0', I0_val, 'E0', E0_val, 'R0_init', R0_val, ...
            'tspan', tspan, 'seed', 42+i));
    catch ME
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', ['SEIRS solve failed: ' ME.message]);
        continue;
    end

    % Verify conservation
    total_pop = res.S + res.E + res.I + res.R;
    violation_idx = find(abs(total_pop - N_pop) > 1e-5 * N_pop, 1);

    if ~isempty(violation_idx)
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', sprintf('S+E+I+R != N at t=%.2f: sum=%.6f, N=%d', ...
            res.t(violation_idx), total_pop(violation_idx), N_pop));
    end
end
end

%% Self-test
function self_test()
    result = prop_seirs_conservation(5);
    assert(result.pass, 'Self-test failed: SEIRS conservation violated.');
    fprintf('prop_seirs_conservation self-test PASSED (%d trials).\n', result.n_trials);
end
