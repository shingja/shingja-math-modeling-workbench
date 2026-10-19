% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function result = prop_malthus_positivity(n_trials)
%% PROP_MALTHUS_POSITIVITY Property test: Malthus model population > 0 for all t.
%  Invariant: N(t) = N0 * exp(r*t) must be strictly positive for N0 > 0.

arguments
    n_trials (1,1) double {mustBePositive} = 100
end

rng(42, 'twister');
result.pass = true;
result.violations = [];
result.n_trials = n_trials;

for i = 1:n_trials
    N0 = 1 + rand() * 1000;     % positive initial population
    r = -0.5 + rand() * 1.0;    % can be negative (decay) or positive (growth)
    t_end = 1 + rand() * 50;
    tspan = [0, t_end];

    try
        [t, N] = malthus_model(N0, r, tspan, 'Display', 'off');
    catch ME
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', ['Malthus solve failed: ' ME.message]);
        continue;
    end

    % Invariant: population must be strictly positive
    violation_idx = find(N <= 0, 1);
    if ~isempty(violation_idx)
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', sprintf('N(t) <= 0 at t=%.2f: N=%.6e (N0=%.2f, r=%.4f)', ...
            t(violation_idx), N(violation_idx), N0, r));
    end

    % Also verify N(0) = N0
    if abs(N(1) - N0) > 1e-10
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', sprintf('N(0)=%.6f != N0=%.6f', N(1), N0));
    end
end
end

%% Self-test
function self_test()
    result = prop_malthus_positivity(5);
    assert(result.pass, 'Self-test failed: Malthus positivity violated.');
    fprintf('prop_malthus_positivity self-test PASSED (%d trials).\n', result.n_trials);
end
