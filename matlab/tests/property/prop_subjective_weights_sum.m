% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function result = prop_subjective_weights_sum(n_trials)
%% PROP_SUBJECTIVE_WEIGHTS_SUM Property test: Subjective weighting weights sum to 1.
%  Invariant: For any valid expert score input, weights must normalize to sum 1.

arguments
    n_trials (1,1) double {mustBePositive} = 100
end

rng(42, 'twister');
result.pass = true;
result.violations = [];
result.n_trials = n_trials;

for i = 1:n_trials
    method_idx = randi([1, 3]);
    methods = ["direct", "expert_aggregate", "delphi_simulate"];
    method_str = methods(method_idx);

    try
        switch method_str
            case "direct"
                scores_vec = rand(randi([2, 10]), 1) * 100;
                [w, ~] = subjective_weight(scores_vec, "direct", 'verbose', false, 'seed', 42+i);

            case "expert_aggregate"
                n_experts = randi([2, 8]);
                n_criteria = randi([2, 8]);
                scores_mat = rand(n_experts, n_criteria) * 100;
                [w, ~] = subjective_weight(scores_mat, "expert_aggregate", 'verbose', false, 'seed', 42+i);

            case "delphi_simulate"
                n_experts = randi([2, 6]);
                n_criteria = randi([2, 8]);
                scores_mat = rand(n_experts, n_criteria) * 100;
                [w, ~] = subjective_weight(scores_mat, "delphi_simulate", ...
                    'verbose', false, 'delphi_rounds', 3, 'seed', 42+i);
        end
    catch ME
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', ['Subjective weight failed (', char(method_str), '): ' ME.message]);
        continue;
    end

    % Invariant 1: weights sum to 1
    if abs(sum(w) - 1) > 1e-8
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', sprintf('Subjective weights sum = %.10f != 1 (method=%s)', ...
            sum(w), method_str));
    end

    % Invariant 2: weights in [0, 1]
    if any(w < -1e-10 | w > 1 + 1e-10)
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', sprintf('Subjective weights outside [0,1] (method=%s)', method_str));
    end
end
end

%% Self-test
function self_test()
    result = prop_subjective_weights_sum(5);
    assert(result.pass, 'Self-test failed: subjective weights sum violated.');
    fprintf('prop_subjective_weights_sum self-test PASSED (%d trials).\n', result.n_trials);
end
