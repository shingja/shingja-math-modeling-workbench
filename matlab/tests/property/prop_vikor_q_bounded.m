% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function result = prop_vikor_q_bounded(n_trials)
%% PROP_VIKOR_Q_BOUNDED Property test: VIKOR Q value in [0, 1].
%  Invariant: The compromise measure Q_i must be bounded in [0, 1].

arguments
    n_trials (1,1) double {mustBePositive} = 100
end

rng(42, 'twister');
result.pass = true;
result.violations = [];
result.n_trials = n_trials;

for i = 1:n_trials
    m = randi([3, 15]);
    n = randi([2, 7]);
    DM = randn(m, n) * 10 + randi([20, 100], 1, n);
    DM = abs(DM);
    w = rand(n, 1); w = w / sum(w);
    ctype = (randi([0, 1], n, 1) * 2 - 1);
    v_val = rand();

    try
        [Q, S, R, ranking, cs] = vikor(DM, w, ctype, 'v', v_val, 'seed', 42+i);
    catch ME
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', ['VIKOR failed: ' ME.message]);
        continue;
    end

    % Invariant 1: Q in [0, 1]
    if any(Q < -1e-8 | Q > 1 + 1e-8)
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', sprintf('VIKOR Q outside [0,1]: range [%.6f, %.6f]', ...
            min(Q), max(Q)));
    end

    % Invariant 2: S and R non-negative
    if any(S < -1e-8) || any(R < -1e-8)
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', 'VIKOR S or R values negative.');
    end

    % Invariant 3: ranking is a permutation
    if ~isequal(sort(ranking), (1:m)')
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', 'VIKOR ranking not a permutation.');
    end
end
end

%% Self-test
function self_test()
    result = prop_vikor_q_bounded(5);
    assert(result.pass, 'Self-test failed: VIKOR Q boundedness violated.');
    fprintf('prop_vikor_q_bounded self-test PASSED (%d trials).\n', result.n_trials);
end
