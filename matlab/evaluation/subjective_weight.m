% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [weights, stats] = subjective_weight(scores, method, options)
%% SUBJECTIVE_WEIGHT Subjective weighting: expert scoring, Delphi aggregation. Paradigm: PARADIGM-0309-SUBJECTIVE-WEIGHT. v3.0.0.
%  Reference: Dalkey, N. & Helmer, O. (1963) Management Science 9(3):458-467. DOI:10.1287/mnsc.9.3.458
%  Requirement 5 (fullfile): not_applicable -- no file IO.
arguments
    scores (:, :) double          % experts x criteria, or criteria x 1 for direct
    method (1,1) string {mustBeMember(method, ...
        ["direct", "expert_aggregate", "delphi_simulate"])} = "direct"
    options.verbose (1,1) logical = true
    options.delphi_rounds (1,1) double {mustBePositive} = 5
    options.delphi_convergence_rate (1,1) double {mustBePositive} = 0.3
    options.seed (1,1) double = 42
end
rng(options.seed, 'twister');
% Dispatch to the appropriate method
switch method
    case "direct"
        [weights, stats] = direct_score_internal(scores);
    case "expert_aggregate"
        [weights, stats] = expert_aggregate_internal(scores);
    case "delphi_simulate"
        [weights, stats] = delphi_simulate_internal(scores, options);
end
% Sanity checks common to all methods
assert(abs(sum(weights) - 1) < 1e-10, ...
    'subjective_weight: weights must sum to 1.');
assert(all(weights >= -1e-12), ...
    'subjective_weight: weights must be non-negative.');
assert(all(weights <= 1 + 1e-12), ...
    'subjective_weight: weights must not exceed 1.');
if options.verbose
    fprintf('Subjective weighting (%s): weights = %s\n', ...
        method, sprintf('%.4f ', weights));
    if isfield(stats, 'std_weights')
        fprintf('Std (inter-expert): %s\n', sprintf('%.4f ', stats.std_weights));
    end
end
end

function [weights, stats] = direct_score_internal(scores)
    % DIRECT_SCORE: Normalize expert scores to sum-to-1 weights
    assert(isvector(scores), 'direct_score: input must be a vector of scores.');
    scores = scores(:);
    assert(all(scores >= 0), 'direct_score: scores must be non-negative.');
    assert(any(scores > 0), 'direct_score: at least one score must be positive.');
    total = sum(scores);
    weights = scores / total;
    stats = struct('raw_scores', scores, 'total', total, 'method', 'direct');
end

function [weights, stats] = expert_aggregate_internal(scores)
    % EXPERT_AGGREGATE: Aggregate multiple experts' weight vectors
    assert(size(scores, 1) >= 2, ...
        'expert_aggregate: at least 2 experts required.');
    assert(size(scores, 2) >= 2, ...
        'expert_aggregate: at least 2 criteria required.');
    % Normalize each expert's scores to sum to 1
    n_experts = size(scores, 1);
    n_criteria = size(scores, 2);
    expert_weights = zeros(n_experts, n_criteria);
    for i = 1:n_experts
        expert_weights(i, :) = scores(i, :) / sum(scores(i, :));
    end
    % Mean and standard deviation across experts
    weights = mean(expert_weights, 1)';
    std_weights = std(expert_weights, 0, 1)';
    % Coefficient of variation
    cv_weights = std_weights ./ max(weights, 1e-12);
    stats = struct('expert_weights', expert_weights, ...
        'mean_weights', weights, ...
        'std_weights', std_weights, ...
        'cv_weights', cv_weights, ...
        'n_experts', n_experts, ...
        'method', 'expert_aggregate');
end

function [weights, stats] = delphi_simulate_internal(scores, options)
    % DELPHI_SIMULATE: Iterative Delphi method with consensus convergence
    n_experts = size(scores, 1);
    n_criteria = size(scores, 2);
    assert(n_experts >= 2, 'delphi_simulate: at least 2 experts required.');
    assert(n_criteria >= 2, 'delphi_simulate: at least 2 criteria required.');
    assert(options.delphi_convergence_rate > 0 && options.delphi_convergence_rate < 1, ...
        'delphi_simulate: convergence_rate must be in (0, 1).');
    % Normalize initial expert scores
    current = zeros(n_experts, n_criteria);
    for i = 1:n_experts
        current(i, :) = scores(i, :) / sum(scores(i, :));
    end
    history = zeros(options.delphi_rounds, n_criteria);
    convergence_measure = zeros(options.delphi_rounds, 1);
    rate = options.delphi_convergence_rate;
    for r = 1:options.delphi_rounds
        group_mean = mean(current, 1);
        history(r, :) = group_mean;
        % Measure consensus as 1 - mean pairwise Euclidean distance
        dist_sum = 0;
        count = 0;
        for i = 1:(n_experts-1)
            for j = (i+1):n_experts
                dist_sum = dist_sum + norm(current(i, :) - current(j, :));
                count = count + 1;
            end
        end
        convergence_measure(r) = 1 - (dist_sum / count) / sqrt(n_criteria);
        % Each expert adjusts toward group mean
        if r < options.delphi_rounds
            noise = randn(n_experts, n_criteria) * 0.02;
            current = current + rate * (repmat(group_mean, n_experts, 1) - current) + noise;
            % Re-normalize rows
            for i = 1:n_experts
                current(i, :) = max(current(i, :), 1e-12);
                current(i, :) = current(i, :) / sum(current(i, :));
            end
        end
    end
    weights = history(end, :)';
    stats = struct('history', history, ...
        'convergence_measure', convergence_measure, ...
        'final_consensus', convergence_measure(end), ...
        'n_rounds', options.delphi_rounds, ...
        'method', 'delphi_simulate');
end

%% Self-test
function self_test()
    rng(42, 'twister');
    n_criteria = 4;
    n_experts = 3;

    % Test 1: direct_score method
    raw_scores = [3; 7; 2; 5];  % expert scores for 4 criteria
    [w1, s1] = subjective_weight(raw_scores, "direct", verbose=false);
    assert(abs(sum(w1) - 1) < 1e-10, 'Direct: weights must sum to 1.');
    % Highest score (7) should get highest weight
    [~, idx_max] = max(raw_scores);
    [~, w_idx_max] = max(w1);
    assert(idx_max == w_idx_max, ...
        'Direct: highest-scored criterion should have highest weight.');

    % Test 2: expert_aggregate method
    expert_scores = [3, 7, 2, 5;
                     4, 6, 3, 4;
                     2, 8, 2, 4];
    [w2, s2] = subjective_weight(expert_scores, "expert_aggregate", verbose=false);
    assert(abs(sum(w2) - 1) < 1e-10, 'Aggregate: weights must sum to 1.');
    assert(all(w2 >= 0), 'Aggregate: all weights must be non-negative.');
    % Criterion 2 (highest across experts) should have highest weight
    [~, w2_max_idx] = max(w2);
    assert(w2_max_idx == 2, ...
        sprintf('Aggregate: criterion 2 should have highest weight, got idx=%d', w2_max_idx));

    % Test 3: delphi_simulate method
    [w3, s3] = subjective_weight(expert_scores, "delphi_simulate", ...
        delphi_rounds=6, delphi_convergence_rate=0.3, verbose=false);
    assert(abs(sum(w3) - 1) < 1e-10, 'Delphi: weights must sum to 1.');
    % Final consensus should be high (>= 0.5 means reasonable agreement)
    assert(s3.final_consensus >= 0.5, ...
        sprintf('Delphi: final consensus=%.4f, expected >= 0.5', s3.final_consensus));

    % Test 4: Spearman correlation between expert mean and Delphi result
    expert_mean_raw = mean(expert_scores, 1)';
    rho = corr(expert_mean_raw, w3, 'Type', 'Spearman');
    assert(rho > 0.8, ...
        sprintf('Spearman rho(mean_expert, delphi)=%.4f, expected > 0.8', rho));

    fprintf('subjective_weight self-test passed (3 methods, 8 asserts).\n');
end
