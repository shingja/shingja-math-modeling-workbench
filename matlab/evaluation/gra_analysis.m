% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [grade, ranking, xi, exitflag] = gra_analysis(data, criteria_types, options)
%% GRAANALYSIS Grey Relational Analysis (Deng's GRA).
%  Normalizes data (benefit/cost), computes grey relational coefficients
%  with specified distinguishing coefficient rho, then ranks alternatives
%  by grey relational grade.
%  Paradigm: PARADIGM-0303
%  Category: Evaluation
%  Version: v3.0.0
%  Reference: Deng, J.L. (1989) Introduction to Grey System Theory.
%             Journal of Grey System, 1(1), 1-24.
%             Liu, S.F. & Lin, Y. (2010) Grey Systems: Theory and
%             Applications. Springer. ISBN: 978-3642161575.
%
%  Input:
%      data           - Decision matrix (m alternatives x n criteria)
%      criteria_types - 1 = benefit (larger better), -1 = cost (smaller better)
%                       Can be empty (default: all benefit)
%
%  Options:
%      options.rho         - Distinguishing coefficient (default: 0.5)
%      options.normalize   - 'minmax' (default) | 'vector' | 'none'
%      options.weights     - Custom weights (1 x n), empty = equal weights
%      options.seed        - RNG seed (default: 42)
%
%  Output:
%      grade    - Grey relational grade (m x 1), higher = better
%      ranking  - Rank indices (m x 1), 1 = best
%      xi       - Grey relational coefficient matrix (m x n)
%      exitflag - 1 = success, -1 = error

arguments
    data (:, :) double
    criteria_types (:, 1) double = []
    options.rho (1,1) double {mustBeInRange(options.rho, 0, 1)} = 0.5
    options.normalize char {mustBeMember(options.normalize, {'minmax','vector','none'})} = 'minmax'
    options.weights (:, :) double = []
    options.seed (1,1) double = 42
end

rng(options.seed, 'twister');
exitflag = 1;

[m_alt, n_crit] = size(data);
assert(m_alt >= 2, 'Need at least 2 alternatives for GRA.');
assert(n_crit >= 1, 'Need at least 1 criterion.');

%% Handle criteria types
if isempty(criteria_types)
    criteria_types = ones(n_crit, 1);
end
criteria_types = criteria_types(:);
assert(length(criteria_types) == n_crit, ...
    'criteria_types length must match number of criteria.');

%% Handle weights
if isempty(options.weights)
    w = ones(1, n_crit) / n_crit;
else
    w = options.weights(:)' / sum(options.weights(:));
end
assert(abs(sum(w) - 1) < 1e-10, 'Weights must sum to 1.');

%% Step 1: Normalize data
switch options.normalize
    case 'minmax'
        % Min-max normalization per column
        norm_data = zeros(m_alt, n_crit);
        for j = 1:n_crit
            col_min = min(data(:, j));
            col_max = max(data(:, j));
            denom = col_max - col_min;
            if denom < 1e-12
                denom = 1;
            end
            if criteria_types(j) == 1  % benefit: larger is better
                norm_data(:, j) = (data(:, j) - col_min) / denom;
            else  % cost: smaller is better
                norm_data(:, j) = (col_max - data(:, j)) / denom;
            end
        end
    case 'vector'
        % Vector normalization
        norm_data = zeros(m_alt, n_crit);
        for j = 1:n_crit
            col_norm_val = norm(data(:, j));
            if col_norm_val < 1e-12, col_norm_val = 1; end
            if criteria_types(j) == 1
                norm_data(:, j) = data(:, j) / col_norm_val;
            else
                norm_data(:, j) = 1 - data(:, j) / col_norm_val;
            end
        end
    case 'none'
        norm_data = data;
    otherwise
        error('Unknown normalization method: %s.', options.normalize);
end

%% Step 2: Determine reference sequence (ideal solution)
% For normalized data, the reference is all ones (best possible)
ref_seq = ones(1, n_crit);

%% Step 3: Compute absolute difference matrix
% Delta_ij = |x0(j) - xij|
delta = abs(ref_seq - norm_data);

%% Step 4: Compute grey relational coefficients
% xi_ij = (delta_min + rho*delta_max) / (delta_ij + rho*delta_max)
delta_min = min(delta(:));
delta_max = max(delta(:));

xi = zeros(m_alt, n_crit);
rho = options.rho;
for i = 1:m_alt
    for j = 1:n_crit
        xi(i, j) = (delta_min + rho * delta_max) / (delta(i, j) + rho * delta_max);
    end
end

%% Step 5: Compute grey relational grade
% grade_i = sum_j w_j * xi_ij
grade = xi * w(:);

%% Step 6: Ranking
[~, rank_order] = sort(grade, 'descend');
ranking = zeros(m_alt, 1);
for i = 1:m_alt
    ranking(rank_order(i)) = i;
end

%% Validation
if any(isnan(grade)) || any(isinf(grade))
    exitflag = -1;
    warning('GRAANALYSIS:NonFinite', 'Non-finite values in grey relational grade.');
end
% All grades should be in [0, 1]
if any(grade < -1e-10) || any(grade > 1 + 1e-10)
    exitflag = 0;
    warning('GRAANALYSIS:OutOfRange', 'Grey grades outside [0,1] range.');
end
assert(all(isfinite(xi(:))), 'Grey relational coefficients contain non-finite values.');

%% Self-test
function self_test()
    % Test data: 4 alternatives x 3 criteria
    data_test = [0.8, 90, 12;
                 0.6, 70, 8;
                 0.9, 85, 15;
                 0.7, 75, 10];
    % C1=benefit, C2=benefit, C3=cost
    ctype_test = [1; 1; -1];

    % Test 1: Standard GRA with rho=0.5
    [g1, rk1, xi1, ef1] = gra_analysis(data_test, ctype_test, ...
        'rho', 0.5, 'normalize', 'minmax', 'seed', 42);

    assert(ef1 == 1, 'Self-test 1: exitflag should be 1, got %d.', ef1);
    assert(length(g1) == 4, 'Self-test 1: expected 4 grades, got %d.', length(g1));
    assert(all(g1 >= 0 & g1 <= 1), ...
        'Self-test 1: grades must be in [0,1], got [%.4f %.4f %.4f %.4f].', g1);
    assert(length(unique(rk1)) == 4, ...
        'Self-test 1: ranking should have 4 unique values.');

    % Test 2: Verify ranking consistent (best grade gets rank 1)
    [~, best_idx] = max(g1);
    assert(rk1(best_idx) == 1, ...
        'Self-test 2: best alternative (idx %d, grade=%.4f) should be rank 1, got rank %d.', ...
        best_idx, g1(best_idx), rk1(best_idx));

    % Test 3: All coefficients in [0,1]
    assert(all(xi1(:) >= 0 & xi1(:) <= 1), ...
        'Self-test 3: grey coefficients must be in [0,1].');

    % Test 4: Different rho produces different grades
    [g_rho_low, ~, ~, ef4] = gra_analysis(data_test, ctype_test, ...
        'rho', 0.2, 'seed', 42);
    assert(ef4 == 1, 'Self-test 4: exitflag should be 1.');
    assert(any(abs(g1 - g_rho_low) > 1e-6), ...
        'Self-test 4: different rho values should produce different grades.');

    % Test 5: With custom weights
    w_custom = [0.5, 0.3, 0.2];
    [g_w, ~, ~, ef5] = gra_analysis(data_test, ctype_test, ...
        'weights', w_custom, 'seed', 42);
    assert(ef5 == 1, 'Self-test 5: exitflag should be 1.');
    assert(all(g_w >= 0 & g_w <= 1), ...
        'Self-test 5: custom-weight grades must be in [0,1].');
    assert(any(abs(g1 - g_w) > 1e-6), ...
        'Self-test 5: custom weights should yield different grades from equal weights.');

    % Test 6: Vector normalization
    [g_vec, ~, ~, ef6] = gra_analysis(data_test, ctype_test, ...
        'normalize', 'vector', 'seed', 42);
    assert(ef6 == 1, 'Self-test 6: exitflag should be 1.');
    assert(all(g_vec >= 0 & g_vec <= 1), ...
        'Self-test 6: vector-normalized grades in [0,1].');

    fprintf('GRAANALYSIS self-test PASSED (6 tests, all assertions passed).\n');
end
end
