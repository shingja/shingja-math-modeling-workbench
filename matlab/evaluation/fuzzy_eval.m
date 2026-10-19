% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [B, scores, ranking, membership, exitflag] = fuzzy_eval(R, W, options)
%% FUZZYEVAL Fuzzy comprehensive evaluation with membership functions.
%  Constructs trapezoidal/triangular membership functions for multi-level
%  evaluation, performs fuzzy composition (max-min or max-product), and
%  defuzzifies to obtain crisp scores and ranking.
%  Paradigm: PARADIGM-0301
%  Category: Evaluation
%  Version: v3.0.0
%  Reference: Zadeh, L.A. (1965) Fuzzy sets. Information and Control,
%             8(3), 338-353. DOI: 10.1016/S0019-9958(65)90241-X.
%             Chen, S.J. & Hwang, C.L. (1992) Fuzzy Multiple Attribute
%             Decision Making. Springer. ISBN: 978-3540549983.
%
%  Input:
%      R - Evaluation matrix (m alternatives x n criteria), raw scores
%      W - Weight vector (1 x n), must sum to 1, or cell of fuzzy weights
%
%  Options:
%      options.levels      - Number of evaluation levels (default: 4)
%      options.level_names - Cell array of level names (default: {'Poor','Fair','Good','Excellent'})
%      options.mf_type     - 'trapezoidal' (default) | 'triangular'
%      options.composition - 'max-min' (default) | 'max-product'
%      options.defuzzify   - 'centroid' (default) | 'bisec' | 'lom' | 'som' | 'mom'
%      options.normalize   - Normalize R to [0,1] first (default: true)
%      options.seed        - RNG seed (default: 42)
%
%  Output:
%      B          - Fuzzy evaluation result (m x levels), each row sums ~1
%      scores     - Crisp scores after defuzzification (m x 1)
%      ranking    - Rank indices (m x 1), 1 = best
%      membership - Membership degree matrix (m x n x levels)
%      exitflag   - 1 = success, 0 = warning, -1 = error

arguments
    R (:, :) double
    W (:, :) double = []
    options.levels (1,1) double {mustBeInteger, mustBePositive} = 4
    options.level_names (1,:) cell = {'Poor','Fair','Good','Excellent'}
    options.mf_type char {mustBeMember(options.mf_type, {'trapezoidal','triangular'})} = 'trapezoidal'
    options.composition char {mustBeMember(options.composition, {'max-min','max-product'})} = 'max-min'
    options.defuzzify char {mustBeMember(options.defuzzify, {'centroid','bisec','lom','som','mom'})} = 'centroid'
    options.normalize (1,1) logical = true
    options.seed (1,1) double = 42
end

rng(options.seed, 'twister');
exitflag = 1;

[m_alt, n_crit] = size(R);
L = options.levels;
assert(m_alt >= 1 && n_crit >= 1, 'R must have at least 1 row and 1 column.');

%% Handle weights
if isempty(W)
    W = ones(1, n_crit) / n_crit;
else
    W = W(:)' / sum(W(:));
end
assert(abs(sum(W) - 1) < 1e-10, 'Weights must sum to 1.');
assert(all(W >= 0), 'Weights must be non-negative.');

%% Step 1: Normalize raw evaluation matrix to [0,1]
if options.normalize
    R_min = min(R, [], 1);
    R_max = max(R, [], 1);
    range_r = R_max - R_min;
    range_r(range_r < 1e-12) = 1;
    R_norm = (R - R_min) ./ range_r;
else
    R_norm = R;
end
R_norm = max(0, min(1, R_norm));  % clamp to [0,1]

%% Step 2: Build membership functions for each evaluation level
% L equally-spaced levels covering [0,1]
centers = linspace(0, 1, L);
half_width = 1 / (L - 1);

% Membership matrix: n_crit x L x n_points (grid for defuzzification)
n_grid = 201;
x_grid = linspace(0, 1, n_grid);
mf_grid = zeros(n_crit, L, n_grid);

for j = 1:n_crit
    for k = 1:L
        c = centers(k);
        if strcmp(options.mf_type, 'triangular')
            % Triangular MF centered at c, span = 2 * half_width
            a = max(0, c - half_width);
            b = c;
            d = min(1, c + half_width);
            for g = 1:n_grid
                xg = x_grid(g);
                if xg <= a || xg >= d
                    mf_grid(j, k, g) = 0;
                elseif xg <= b
                    mf_grid(j, k, g) = (xg - a) / (b - a + 1e-12);
                else
                    mf_grid(j, k, g) = (d - xg) / (d - b + 1e-12);
                end
            end
        else  % trapezoidal
            a = max(0, c - 1.2 * half_width);
            b = max(0, c - 0.3 * half_width);
            d_val = min(1, c + 0.3 * half_width);
            e_val = min(1, c + 1.2 * half_width);
            for g = 1:n_grid
                xg = x_grid(g);
                if xg <= a || xg >= e_val
                    mf_grid(j, k, g) = 0;
                elseif xg < b
                    mf_grid(j, k, g) = (xg - a) / (b - a + 1e-12);
                elseif xg <= d_val
                    mf_grid(j, k, g) = 1;
                else
                    mf_grid(j, k, g) = (e_val - xg) / (e_val - d_val + 1e-12);
                end
            end
        end
    end
end

%% Step 3: Evaluate membership for each alternative-criterion pair
% membership(i, j, k) = degree of alternative i on criterion j belonging to level k
membership = zeros(m_alt, n_crit, L);
for i = 1:m_alt
    for j = 1:n_crit
        val = R_norm(i, j);
        [~, g_idx] = min(abs(x_grid - val));
        for k = 1:L
            membership(i, j, k) = mf_grid(j, k, g_idx);
        end
    end
end

%% Step 4: Fuzzy composition (aggregate criteria -> evaluation result)
% B(i, k) = composition of membership(i, :, k) with weight W
B = zeros(m_alt, L);
if strcmp(options.composition, 'max-min')
    for i = 1:m_alt
        for k = 1:L
            vals = zeros(1, n_crit);
            for j = 1:n_crit
                vals(j) = min(W(j), membership(i, j, k));
            end
            B(i, k) = max(vals);
        end
    end
else  % max-product
    for i = 1:m_alt
        for k = 1:L
            vals = zeros(1, n_crit);
            for j = 1:n_crit
                vals(j) = W(j) * membership(i, j, k);
            end
            B(i, k) = max(vals);
        end
    end
end

% Normalize each row to sum to 1
row_sums = sum(B, 2);
for i = 1:m_alt
    if row_sums(i) > 1e-12
        B(i, :) = B(i, :) / row_sums(i);
    end
end

%% Step 5: Defuzzification
scores = zeros(m_alt, 1);
for i = 1:m_alt
    switch options.defuzzify
        case 'centroid'
            numerator = sum(B(i, :) .* centers);
            denominator = sum(B(i, :));
            scores(i) = numerator / max(denominator, 1e-12);
        case 'bisec'
            cum_B = cumsum(B(i, :));
            total = cum_B(end);
            mid = total / 2;
            idx_bisect = find(cum_B >= mid, 1, 'first');
            if ~isempty(idx_bisect)
                scores(i) = centers(idx_bisect);
            else
                scores(i) = centers(end);
            end
        case 'som'
            [~, idx] = max(B(i, :));
            scores(i) = centers(min(idx));  % smallest of max
        case 'lom'
            [~, idx] = max(B(i, :));
            scores(i) = centers(max(idx));  % largest of max
        case 'mom'
            [max_val, ~] = max(B(i, :));
            idx_max = find(abs(B(i, :) - max_val) < 1e-10);
            scores(i) = mean(centers(idx_max));
        otherwise
            scores(i) = sum(B(i, :) .* centers) / max(sum(B(i, :)), 1e-12);
    end
end

%% Step 6: Ranking (higher score = better)
[~, rank_order] = sort(scores, 'descend');
ranking = zeros(m_alt, 1);
for i = 1:m_alt
    ranking(rank_order(i)) = i;
end

%% Validation
if any(isnan(scores)) || any(isinf(scores))
    exitflag = -1;
    warning('FUZZYEVAL:NonFinite', 'Non-finite values in defuzzified scores.');
elseif max(abs(sum(B, 2) - 1)) > 1e-8
    exitflag = 0;
    warning('FUZZYEVAL:NotNormalized', 'Fuzzy evaluation rows may not sum to 1.');
end

%% Self-test
function self_test()
    % Test data: 3 alternatives x 3 criteria
    R_test = [85, 90, 78;
              70, 65, 88;
              92, 80, 72];
    W_test = [0.3, 0.4, 0.3];

    % Test 1: Basic fuzzy evaluation with max-min and centroid
    [B1, sc1, rk1, ~, ef1] = fuzzy_eval(R_test, W_test, ...
        'levels', 4, 'mf_type', 'trapezoidal', 'composition', 'max-min', ...
        'defuzzify', 'centroid', 'seed', 42);

    assert(ef1 == 1, 'Self-test 1: exitflag should be 1, got %d.', ef1);
    assert(length(sc1) == 3, 'Self-test 1: expected 3 scores, got %d.', length(sc1));
    assert(all(sc1 >= 0 & sc1 <= 1), ...
        'Self-test 1: scores should be in [0,1], got [%.4f %.4f %.4f].', sc1);
    assert(length(unique(rk1)) == 3, ...
        'Self-test 1: ranking should be unique permutation.');

    % Test 2: max-product composition, triangular MF
    [B2, sc2, rk2, ~, ef2] = fuzzy_eval(R_test, W_test, ...
        'levels', 4, 'mf_type', 'triangular', 'composition', 'max-product', ...
        'defuzzify', 'centroid', 'seed', 42);

    assert(ef2 >= 0, 'Self-test 2: exitflag should be >= 0, got %d.', ef2);
    assert(all(sc2 >= 0 & sc2 <= 1), ...
        'Self-test 2: max-product scores in [0,1], got [%.4f %.4f %.4f].', sc2);
    % Max-product should produce somewhat different results than max-min
    diff_exists = any(abs(sc1 - sc2) > 1e-6);
    assert(diff_exists, ...
        'Self-test 2: max-min and max-product should yield different scores.');

    % Test 3: Different defuzzification methods
    [~, sc_c, ~, ~, ef3] = fuzzy_eval(R_test, W_test, ...
        'defuzzify', 'centroid', 'seed', 42);
    [~, sc_b, ~, ~, ~] = fuzzy_eval(R_test, W_test, ...
        'defuzzify', 'bisec', 'seed', 42);
    [~, sc_m, ~, ~, ~] = fuzzy_eval(R_test, W_test, ...
        'defuzzify', 'mom', 'seed', 42);

    assert(all(isfinite(sc_c)) && all(isfinite(sc_b)) && all(isfinite(sc_m)), ...
        'Self-test 3: non-finite scores from defuzzification.');
    assert(all(sc_c >= 0 & sc_c <= 1), 'Self-test 3: centroid out of range.');
    assert(all(sc_b >= 0 & sc_b <= 1), 'Self-test 3: bisector out of range.');

    % Test 4: Verify ranking: highest score == rank 1
    [~, best_idx] = max(sc1);
    assert(rk1(best_idx) == 1, ...
        'Self-test 4: best alternative should have rank 1, got rank %d.', rk1(best_idx));

    fprintf('FUZZYEVAL self-test PASSED (4 tests, all assertions passed).\n');
end
end
