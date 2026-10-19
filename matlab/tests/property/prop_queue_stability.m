% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function result = prop_queue_stability(n_trials)
%% PROP_QUEUE_STABILITY Property test: rho < 1 -> finite queue length (no NaN/Inf).
%  Invariant: For stable queues (rho < 1), all metrics must be finite and non-negative.

arguments
    n_trials (1,1) double {mustBePositive} = 100
end

rng(42, 'twister');
result.pass = true;
result.violations = [];
result.n_trials = n_trials;

for i = 1:n_trials
    mu = 0.5 + rand() * 10;
    rho_target = 0.1 + rand() * 0.85;  % ensure rho < 1
    s_val = randi([1, 5]);
    lam = rho_target * mu * s_val;  % stable: lam < mu*s

    try
        [L, Lq, W, Wq, P_wait, metrics] = queuing_theory(lam, mu, ...
            'Servers', s_val, 'Display', 'off');
    catch ME
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', ['Queue theory failed: ' ME.message]);
        continue;
    end

    % Invariant 1: all metrics finite
    if any(isnan([L, Lq, W, Wq])) || any(isinf([L, Lq, W, Wq]))
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', sprintf('Queue metrics NaN/Inf: L=%.4f, Lq=%.4f', L, Lq));
    end

    % Invariant 2: L >= Lq (system >= queue)
    if L < Lq - 1e-10
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', sprintf('L=%.4f < Lq=%.4f', L, Lq));
    end

    % Invariant 3: W >= Wq (system time >= waiting time)
    if W < Wq - 1e-10
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', sprintf('W=%.4f < Wq=%.4f', W, Wq));
    end

    % Invariant 4: rho in (0, 1) for stable systems
    if ~isfield(metrics, 'rho'), continue; end
    if metrics.rho >= 1 || metrics.rho < 0
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', sprintf('rho=%.4f not in (0,1) for stable system', metrics.rho));
    end
end
end

%% Self-test
function self_test()
    result = prop_queue_stability(5);
    assert(result.pass, 'Self-test failed: queue stability violated.');
    fprintf('prop_queue_stability self-test PASSED (%d trials).\n', result.n_trials);
end
