% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function result = prop_seir_conservation(n_trials)
%% PROP_SEIR_CONSERVATION Property test: S+E+I+R = N at all times for SEIR model.
%  Invariant: total population N must be conserved throughout the simulation.
%  Tests random parameter sets to verify the conservation law holds.

arguments
    n_trials (1,1) double {mustBePositive} = 100
end

rng(42, 'twister');
result.pass = true;
result.violations = [];
result.n_trials = n_trials;

for i = 1:n_trials
    % Generate random valid parameters
    N_pop = 1000 + randi([100, 50000]);  % total population
    I0 = randi([1, max(1, floor(N_pop * 0.05))]);
    E0 = randi([0, max(0, floor(N_pop * 0.03))]);
    R0_init = randi([0, max(0, floor(N_pop * 0.02))]);
    S0 = N_pop - E0 - I0 - R0_init;
    if S0 <= 0, continue; end

    beta = 0.1 + rand() * 1.0;   % transmission rate
    sigma = 0.05 + rand() * 0.5; % 1/incubation
    gamma = 0.02 + rand() * 0.3; % recovery rate
    t_span = [0, 50 + randi([0, 150])];

    % Call SEIR model
    try
        [t, S, E, I, R] = seir_model('solve', S0, E0, I0, R0_init, ...
            beta, sigma, gamma, t_span, 'seed', 42+i);
    catch ME
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', ['SEIR solve failed: ' ME.message]);
        continue;
    end

    % Invariant: S+E+I+R should equal N at all times
    total_pop = S + E + I + R;
    N_actual = S0 + E0 + I0 + R0_init;
    violation_idx = find(abs(total_pop - N_actual) > 1e-6 * N_actual, 1);

    if ~isempty(violation_idx)
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', sprintf('S+E+I+R != N at t=%.2f: sum=%.6f, N=%d, diff=%.2e', ...
            t(violation_idx), total_pop(violation_idx), N_actual, ...
            total_pop(violation_idx) - N_actual));
    end
end
end

%% Self-test
function self_test()
    result = prop_seir_conservation(5);
    assert(result.pass, 'Self-test failed: conservation law violated.');
    assert(isempty(result.violations), 'Self-test failed: unexpected violations.');
    fprintf('prop_seir_conservation self-test PASSED (%d trials).\n', result.n_trials);
end
