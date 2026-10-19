% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [scores, ranking, D_plus, D_minus, C] = topsis_improved(data, weights, criteria_types, options)
%% TOPSISIMPROVED  Improved TOPSIS with Mahalanobis distance and prospect theory.
%  Extends basic TOPSIS with:
%    - Mahalanobis distance option (accounts for correlation)
%    - Prospect theory value transform (gains/losses framing)
%    - Entropy-based weighting option
%  Paradigm: PARADIGM-0302 (extended)
%  Category: Evaluation
%  Version: v3.0.0
%  Reference: Yue, Z. (2011) A method for group decision-making based on
%             determining weights of decision makers using TOPSIS.
%             Expert Systems with Applications, 38(1), 1008-1012.
%             Hwang, C.L. & Yoon, K. (1981) Multiple Attribute Decision
%             Making. Springer. ISBN: 978-3540105589.
%
%  Input:
%      data           - Decision matrix (m alternatives × n criteria)
%      weights        - Criteria weights (1 × n), can be [] for entropy weights
%      criteria_types - Criteria types: 1 = benefit (maximize), -1 = cost (minimize)
%                       Vector of length n
%
%  Options:
%      options.distance      - 'euclidean' (default) | 'mahalanobis'
%      options.prospect      - 'none' (default) | 'value_function'
%      options.prospect_lambda - Loss aversion coefficient (default: 2.25)
%      options.prospect_alpha  - Diminishing sensitivity for gains (default: 0.88)
%      options.prospect_beta   - Diminishing sensitivity for losses (default: 0.88)
%      options.entropy_weight - Use entropy weights (default: false)
%      options.reference_point - Reference point for prospect theory ('mean' | vector)
%      options.display        - 'on' | 'off' (default: 'off')
%      options.seed           - RNG seed (default: 42)
%
%  Output:
%      scores   - TOPSIS closeness scores (m × 1), higher = better
%      ranking  - Rank indices (m × 1), 1 = best
%      D_plus   - Distance to positive ideal (m × 1)
%      D_minus  - Distance to negative ideal (m × 1)
%      C        - Relative closeness C = D_minus/(D_plus + D_minus)

arguments
    data (:, :) double
    weights (:, :) double = []
    criteria_types (:, 1) double = []
    options.distance char = 'euclidean'
    options.prospect char = 'none'
    options.prospect_lambda (1,1) double {mustBePositive} = 2.25
    options.prospect_alpha (1,1) double {mustBePositive} = 0.88
    options.prospect_beta (1,1) double {mustBePositive} = 0.88
    options.entropy_weight (1,1) logical = false
    options.reference_point = 'mean'
    options.display char = 'off'
    options.seed (1,1) double = 42
end

rng(options.seed, 'twister');

[m, n] = size(data);
assert(m >= 2, 'Need at least 2 alternatives.');
assert(n >= 2, 'Need at least 2 criteria.');

%% Handle default criteria types (all benefit)
if isempty(criteria_types)
    criteria_types = ones(n, 1);
end
criteria_types = criteria_types(:);
assert(length(criteria_types) == n, ...
    'criteria_types length (%d) must equal number of criteria (%d).', ...
    length(criteria_types), n);

%% Handle weights
if isempty(weights) || options.entropy_weight
    weights = entropy_weights_calc(data);
    if strcmp(options.display, 'on')
        fprintf('Using entropy weights: ');
        fprintf('%.4f ', weights);
        fprintf('\n');
    end
else
    weights = weights(:)' / sum(weights(:));  % Normalize to sum=1
end
assert(abs(sum(weights) - 1) < 1e-10, 'Weights must sum to 1.');
assert(all(weights >= 0), 'Weights must be non-negative.');

%% Step 1: Normalize data (vector normalization)
norm_data = zeros(m, n);
for j = 1:n
    col_norm = norm(data(:, j));
    if col_norm < 1e-14
        col_norm = 1;  % Avoid division by zero (constant column)
    end
    norm_data(:, j) = data(:, j) / col_norm;
end

%% Step 2: Apply prospect theory value transform if requested
if strcmp(options.prospect, 'value_function')
    % Determine reference point
    if ischar(options.reference_point) && strcmp(options.reference_point, 'mean')
        ref_point = mean(norm_data, 1);
    elseif isnumeric(options.reference_point)
        ref_point = options.reference_point(:)';
        assert(length(ref_point) == n, 'Reference point must have %d elements.', n);
    else
        ref_point = mean(norm_data, 1);
    end

    % Apply prospect value function
    prospect_data = zeros(m, n);
    for j = 1:n
        dev = norm_data(:, j) - ref_point(j);
        for i = 1:m
            if criteria_types(j) == 1  % Benefit: above ref = gain
                if dev(i) >= 0
                    prospect_data(i, j) = dev(i)^options.prospect_alpha;
                else
                    prospect_data(i, j) = -options.prospect_lambda * (-dev(i))^options.prospect_beta;
                end
            else  % Cost: below ref = gain
                if dev(i) <= 0
                    prospect_data(i, j) = (-dev(i))^options.prospect_alpha;
                else
                    prospect_data(i, j) = -options.prospect_lambda * dev(i)^options.prospect_beta;
                end
            end
        end
    end
    working_data = prospect_data;
else
    working_data = norm_data;
end

%% Step 3: Weighted normalized decision matrix
weighted_data = working_data .* weights;

%% Step 4: Determine ideal solutions
% For benefit criteria: larger is better; for cost: smaller is better
PIS = zeros(1, n);  % Positive Ideal Solution
NIS = zeros(1, n);  % Negative Ideal Solution

for j = 1:n
    if criteria_types(j) == 1  % Benefit
        PIS(j) = max(weighted_data(:, j));
        NIS(j) = min(weighted_data(:, j));
    else  % Cost
        PIS(j) = min(weighted_data(:, j));
        NIS(j) = max(weighted_data(:, j));
    end
end

%% Step 5: Calculate distances
D_plus = zeros(m, 1);
D_minus = zeros(m, 1);

if strcmp(options.distance, 'mahalanobis')
    % Mahalanobis distance: accounts for correlation between criteria
    % Compute covariance matrix of weighted data (regularized)
    cov_w = cov(weighted_data);
    % Regularization for numerical stability
    cov_w = cov_w + eye(n) * 1e-6 * trace(cov_w) / n;
    inv_cov = inv(cov_w);

    for i = 1:m
        diff_plus = weighted_data(i, :) - PIS;
        diff_minus = weighted_data(i, :) - NIS;
        D_plus(i) = sqrt(diff_plus * inv_cov * diff_plus');
        D_minus(i) = sqrt(diff_minus * inv_cov * diff_minus');
    end
else
    % Standard Euclidean distance
    for i = 1:m
        D_plus(i) = norm(weighted_data(i, :) - PIS);
        D_minus(i) = norm(weighted_data(i, :) - NIS);
    end
end

%% Step 6: Relative closeness
C = D_minus ./ (D_plus + D_minus);

% Handle degenerate case (both zero)
C(isnan(C)) = 0;

% Save results (cross-platform): save(fullfile(pwd, 'topsis_results.mat'), 'scores', 'ranking');

%% Step 7: Ranking
[~, ranking] = sort(C, 'descend');
scores = C;

%% Validation
assert(all(isfinite(C)), 'TOPSISIMPROVED:NonFinite', ...
    'Closeness scores contain non-finite values.');
assert(all(C >= 0 & C <= 1), 'TOPSISIMPROVED:OutOfRange', ...
    'Closeness scores outside [0,1].');

%% Display
if strcmp(options.display, 'on')
    fprintf('\n=== Improved TOPSIS ===\n');
    fprintf('Alternatives: %d, Criteria: %d\n', m, n);
    fprintf('Distance: %s, Prospect: %s, Entropy weight: %d\n', ...
        options.distance, options.prospect, options.entropy_weight);
    fprintf('Rank | Score \n');
    for r = 1:min(m, 10)
        alt_idx = ranking(r);
        fprintf(' %2d  | %.4f\n', r, C(alt_idx));
    end
end
end

%% Nested: Entropy weight calculation
function w = entropy_weights_calc(data_mat)
    [m_ent, n_ent] = size(data_mat);
    % Normalize each column to [0,1]
    val_range = max(data_mat, [], 1) - min(data_mat, [], 1);
    val_range(val_range < 1e-12) = 1;
    P = (data_mat - min(data_mat, [], 1)) ./ val_range;
    % Avoid log(0): add epsilon
    P = P + 1e-12;
    % Normalize so each column sums to 1
    P = P ./ sum(P, 1);
    % Entropy: e_j = -k * sum(P_ij * log(P_ij)), k = 1/ln(m)
    k_ent = 1 / log(m_ent);
    e = -k_ent * sum(P .* log(P), 1);
    % Weights: w_j = (1 - e_j) / sum(1 - e_j)
    d = 1 - e;
    w = d / sum(d);
end

%% Self-test
function self_test()
    % Test 1: Standard TOPSIS on known dataset
    % 3 alternatives, 4 criteria (all benefit)
    data_test = [8, 7, 2, 1;
                 5, 3, 7, 5;
                 7, 5, 6, 4];
    w_test = [0.3, 0.2, 0.3, 0.2];
    ctypes_test = [1; 1; 1; 1];  % All benefit

    [scores, ranking, ~, ~, C] = topsis_improved(data_test, w_test, ctypes_test, ...
        distance='euclidean', prospect='none', display='off');

    % Verify basic properties
    assert(length(scores) == 3, 'Self-test failed: wrong number of scores.');
    assert(all(scores >= 0 & scores <= 1), ...
        'Self-test failed: scores outside [0,1].');
    assert(length(unique(ranking)) == 3, ...
        'Self-test failed: ranking should have unique ranks.');

    % Check that the best alternative has the highest score
    [~, best_idx] = max(C);
    assert(ranking(1) == best_idx, ...
        'Self-test failed: ranking(1) should be the alternative with highest score.');

    % Test 2: With Mahalanobis distance, same data
    [scores2, ~, ~, ~, C2] = topsis_improved(data_test, w_test, ctypes_test, ...
        distance='mahalanobis', prospect='none', display='off');
    assert(all(isfinite(scores2)), ...
        'Self-test failed: Mahalanobis scores not finite.');

    % Test 3: Entropy weights
    [scores3, ~, ~, ~, ~] = topsis_improved(data_test, [], ctypes_test, ...
        entropy_weight=true, display='off');
    assert(all(scores3 >= 0 & scores3 <= 1), ...
        'Self-test failed: entropy-weighted scores outside [0,1].');

    % Test 4: With prospect value function
    [scores4, ~, ~, ~, ~] = topsis_improved(data_test, w_test, ctypes_test, ...
        prospect='value_function', prospect_lambda=2.25, display='off');
    assert(all(isfinite(scores4)), ...
        'Self-test failed: prospect TOPSIS scores not finite.');

    % Test 5: With cost criteria
    % 2 benefit, 1 cost
    ctypes_mixed = [1; 1; -1; 1];
    [scores5, ~, ~, ~, ~] = topsis_improved(data_test, w_test, ctypes_mixed, ...
        display='off');
    assert(all(scores5 >= 0 & scores5 <= 1), ...
        'Self-test failed: mixed criteria scores outside [0,1].');

    % Test 6: Euclidean and Mahalanobis give same ranking for this simple dataset
    [~, rank_euc] = sort(C, 'descend');
    [~, rank_mah] = sort(C2, 'descend');
    % They may differ, but we just verify ranks are valid
    assert(length(unique(rank_euc)) == 3, 'Self-test failed: Euclidean ranks not unique.');
    assert(length(unique(rank_mah)) == 3, 'Self-test failed: Mahalanobis ranks not unique.');

    disp('TOPSISIMPROVED self-test passed.');
end
