% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function result = prop_ahp_weights_sum(n_trials)
%% PROP_AHP_WEIGHTS_SUM Property test: AHP weights sum to 1.
%  Invariant: For any valid positive reciprocal matrix,
%             the eigenvector-normalized weights must sum to 1.

arguments
    n_trials (1,1) double {mustBePositive} = 100
end

rng(42, 'twister');
result.pass = true;
result.violations = [];
result.n_trials = n_trials;

% Saaty scale values
saaty_scale = [1/9, 1/8, 1/7, 1/6, 1/5, 1/4, 1/3, 1/2, ...
               1, 2, 3, 4, 5, 6, 7, 8, 9];

for i = 1:n_trials
    n_crit = randi([2, 8]);

    % Build random reciprocal matrix
    A = ones(n_crit, n_crit);
    for r = 1:n_crit
        for c = (r+1):n_crit
            val = saaty_scale(randi(length(saaty_scale)));
            A(r, c) = val;
            A(c, r) = 1 / val;
        end
    end

    try
        [w, ~, ~, ~, ~] = ahp_evaluate(A, 'verbose', false, 'seed', 42+i);
    catch ME
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', ['AHP evaluate failed: ' ME.message]);
        continue;
    end

    % Invariant: weights sum to 1
    if abs(sum(w) - 1) > 1e-8
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', sprintf('AHP weights sum = %.10f != 1', sum(w)));
    end

    % Invariant: all weights positive
    if any(w <= 0)
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', 'AHP produced non-positive weight.');
    end
end
end

%% Self-test
function self_test()
    result = prop_ahp_weights_sum(5);
    assert(result.pass, 'Self-test failed: AHP weights sum violated.');
    fprintf('prop_ahp_weights_sum self-test PASSED (%d trials).\n', result.n_trials);
end
