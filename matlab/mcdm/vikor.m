% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [Q, S, R, ranking, compromise_solution] = vikor(DM, weights, criteria_types, options)
%% VIKOR  VIKOR compromise ranking method
%  Paradigm: MCDM-004 | Category: ⑫ | Version: v3.0.0
%  Reference: Opricovic & Tzeng (2004) "Compromise solution by MCDM methods:
%             A comparative analysis of VIKOR and TOPSIS." EJOR 156(2):445-455.
%
%  Computes:
%    S_i = Σ w_j * (f_j* - f_ij) / (f_j* - f_j^-)   (utility measure)
%    R_i = max_j w_j * (f_j* - f_ij) / (f_j* - f_j^-) (regret measure)
%    Q_i = v*(S_i - S*)/(S^- - S*) + (1-v)*(R_i - R*)/(R^- - R*)
%  where * = best, - = worst

arguments
    DM (:, :) double                  % decision matrix [n_alt x n_criteria]
    weights (:, 1) double             % criterion weights [n_criteria x 1]
    criteria_types (:, 1) double      % 1=maximize (benefit), -1=minimize (cost)
    options.seed (1,1) double = 42
    options.v (1,1) double {mustBeInRange(options.v, 0, 1)} = 0.5  % weight of S vs R
end

rng(options.seed, 'twister');

%% --- Validate ---
[n_alt, n_crit] = size(DM);
assert(length(weights) == n_crit, 'VIKOR:DimMismatch', ...
    'Weights must match number of criteria.');
assert(length(criteria_types) == n_crit, 'VIKOR:DimMismatch', ...
    'criteria_types must match number of criteria.');
assert(all(abs(weights) > 0) && all(isfinite(weights)), ...
    'VIKOR:BadWeights', 'Weights must be positive and finite.');
weights = weights(:) / sum(weights);  % normalize

%% --- Determine best and worst values ---
f_star = zeros(1, n_crit);  % best (ideal)
f_minus = zeros(1, n_crit); % worst (anti-ideal)

for j = 1:n_crit
    if criteria_types(j) == 1
        % Maximize: best = max, worst = min
        f_star(j)  = max(DM(:, j));
        f_minus(j) = min(DM(:, j));
    else
        % Minimize: best = min, worst = max
        f_star(j)  = min(DM(:, j));
        f_minus(j) = max(DM(:, j));
    end
end

%% --- Compute S_i and R_i ---
S = zeros(n_alt, 1);
R = zeros(n_alt, 1);

for i = 1:n_alt
    weighted_norm = zeros(1, n_crit);
    for j = 1:n_crit
        range_j = f_star(j) - f_minus(j);
        if range_j == 0
            range_j = 1;  % avoid division by zero
        end
        weighted_norm(j) = weights(j) * (f_star(j) - DM(i, j)) / range_j;
    end
    S(i) = sum(weighted_norm);
    R(i) = max(weighted_norm);
end

% Best and worst utility / regret
S_star = min(S);  S_minus = max(S);
R_star = min(R);  R_minus = max(R);

%% --- Compute Q_i (compromise measure) ---
v = options.v;
Q = zeros(n_alt, 1);

denom_S = S_minus - S_star;
denom_R = R_minus - R_star;
if denom_S == 0, denom_S = 1; end
if denom_R == 0, denom_R = 1; end

for i = 1:n_alt
    Q(i) = v * (S(i) - S_star) / denom_S + (1 - v) * (S(i) - S_star) / denom_S;
    % Correction: Q uses (S(i)-S*)/(S^- - S*) AND (R(i)-R*)/(R^- - R*)
    Q(i) = v * (S(i) - S_star) / denom_S + (1 - v) * (R(i) - R_star) / denom_R;
end

% Numerical sanity: Q should be in [0, 1]
assert(all(Q >= -1e-10 & Q <= 1 + 1e-10), 'VIKOR:QOutOfRange', ...
    'Q values outside [0,1].');

%% --- Ranking ---
[~, rank_order] = sort(Q);
ranking = zeros(n_alt, 1);
for i = 1:n_alt
    ranking(rank_order(i)) = i;
end

% Compromise solution check (conditions from Opricovic & Tzeng)
% Condition 1: Acceptable advantage
%   Q(a'') - Q(a') >= DQ where DQ = 1/(n_alt-1)
DQ = 1 / (n_alt - 1);
best_idx = rank_order(1);
second_idx = rank_order(2);

cond1 = (Q(best_idx) - Q(second_idx) >= DQ);

% Condition 2: Acceptable stability in decision making
%   a' must also be best ranked by S or R
cond2_S = (S(best_idx) == S_star);
cond2_R = (R(best_idx) == R_star);

compromise_solution = struct();
compromise_solution.best_alternative = best_idx;
compromise_solution.condition1_met = cond1;
compromise_solution.condition2_met = (cond2_S || cond2_R);
compromise_solution.compromise_set = [];
if ~cond1
    % Multiple alternatives are in compromise set
    compromise_set = rank_order(1:find(Q(rank_order) - Q(best_idx) < DQ, 1, 'last'));
    compromise_solution.compromise_set = compromise_set(:)';
end

assert(best_idx >= 1 && best_idx <= n_alt, 'VIKOR:BadRanking', ...
    'Best alternative index out of bounds.');

%% Self-test
function self_test()
    fprintf('  Running vikor self-test...\n');
    rng(42);
    % Known dataset: 3 alternatives, 3 criteria (from Opricovic & Tzeng 2004 example)
    % C1: cost (min), C2: benefit (max), C3: benefit (max)
    DM_test = [5.0, 3.0, 2.0;    % A1
               4.0, 4.0, 4.0;    % A2
               1.0, 5.0, 5.0];   % A3
    w_test = [0.3; 0.4; 0.3];
    ctype  = [-1; 1; 1];  % C1=minimize, C2,C3=maximize

    [Q_vals, S_vals, R_vals, rank_order, cs] = vikor(DM_test, w_test, ctype, 'v', 0.5);

    % Q should rank alternatives
    assert(length(unique(Q_vals)) >= 2, 'Self-test: Q values all identical.');

    % Best alternative should have Q close to 0
    assert(min(Q_vals) < 0.1, 'Self-test: best Q should be near 0.');

    % Ranking should be a permutation of 1:n
    assert(all(sort(rank_order) == (1:3)'), 'Self-test: ranking not a permutation.');

    % S and R should be nonnegative
    assert(all(S_vals >= -1e-10), 'Self-test: negative S values.');
    assert(all(R_vals >= -1e-10), 'Self-test: negative R values.');

    fprintf('  vikor self-test PASSED (best=%d, Q=[%.4f, %.4f, %.4f]).\n', ...
        cs.best_alternative, Q_vals);
end
end
