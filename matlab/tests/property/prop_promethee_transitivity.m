% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function result = prop_promethee_transitivity(n_trials)
%% PROP_PROMETHEE_TRANSITIVITY Property test: PROMETHEE flow consistency.
%  Invariant: PROMETHEE II complete ranking by net flow phi_net
%             must be well-ordered: if phi(A) > phi(B), then rank(A) < rank(B).

arguments
    n_trials (1,1) double {mustBePositive} = 100
end

rng(42, 'twister');
result.pass = true;
result.violations = [];
result.n_trials = n_trials;

for i = 1:n_trials
    m = randi([4, 15]);
    n = randi([2, 6]);
    DM = randn(m, n) * 10 + randi([20, 80], 1, n);
    DM = abs(DM);
    w = rand(n, 1); w = w / sum(w);
    ctype = ones(n, 1);

    try
        [phi_p, phi_m, phi_n, rI, rII] = promethee(DM, w, ctype, 'seed', 42+i);
    catch ME
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', ['PROMETHEE failed: ' ME.message]);
        continue;
    end

    % Invariant 1: ranking by net flow must be consistent
    [sorted_phi, sort_idx] = sort(phi_n, 'descend');
    for r = 1:m
        if rII(sort_idx(r)) ~= r
            result.pass = false;
            result.violations(end+1) = struct('trial', i, ...
                'violation', sprintf('PROMETHEE ranking inconsistent with phi_net at rank %d', r));
            break;
        end
    end

    % Invariant 2: phi+ and phi- in [0, 1]
    if any(phi_p < -1e-10 | phi_p > 1 + 1e-10)
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', 'phi+ outside [0,1].');
    end

    % Invariant 3: phi_net = phi+ - phi-
    if max(abs(phi_n - (phi_p - phi_m))) > 1e-10
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', 'phi_net != phi+ - phi-.');
    end
end
end

%% Self-test
function self_test()
    result = prop_promethee_transitivity(5);
    assert(result.pass, 'Self-test failed: PROMETHEE transitivity violated.');
    fprintf('prop_promethee_transitivity self-test PASSED (%d trials).\n', result.n_trials);
end
