% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function result = prop_bwm_weights_sum(n_trials)
%% PROP_BWM_WEIGHTS_SUM Property test: BWM weights sum to 1.
%  Invariant: Best-Worst Method LP solution must yield weights summing to 1.

arguments
    n_trials (1,1) double {mustBePositive} = 100
end

rng(42, 'twister');
result.pass = true;
result.violations = [];
result.n_trials = n_trials;

for i = 1:n_trials
    n_crit = randi([2, 8]);

    % Generate random consistent BWM comparisons
    % Best-to-others: random integer scores 1..9
    best_to_others = randi([1, 9], 1, n_crit);
    best_to_others(randi(n_crit)) = 1;  % best criterion gets score 1

    % Others-to-worst: random integer scores 1..9
    others_to_worst = randi([1, 9], 1, n_crit);
    others_to_worst(randi(n_crit)) = 1;  % worst criterion gets score 1

    try
        [w, cr, ef] = bwm(struct('best_to_others', best_to_others, ...
            'others_to_worst', others_to_worst));
    catch ME
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', ['BWM failed: ' ME.message]);
        continue;
    end

    % Invariant 1: weights sum to 1
    if abs(sum(w) - 1) > 1e-6
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', sprintf('BWM weights sum = %.10f != 1', sum(w)));
    end

    % Invariant 2: all weights non-negative
    if any(w < -1e-10)
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', 'BWM weights negative.');
    end
end
end

%% Self-test
function self_test()
    result = prop_bwm_weights_sum(5);
    assert(result.pass, 'Self-test failed: BWM weights sum violated.');
    fprintf('prop_bwm_weights_sum self-test PASSED (%d trials).\n', result.n_trials);
end
