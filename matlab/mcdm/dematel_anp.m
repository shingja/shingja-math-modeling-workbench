% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [weights, total_relation, prominence, relation, supermatrix] = dematel_anp(direct_influence, options)
%% DEMATEL_ANP  DEMATEL-ANP integrated analysis
%  Paradigm: MCDM-006 | Category: ⑫ | Version: v3.0.0
%  Reference: Yang, Shieh, Leu & Tzeng (2008) "A novel hybrid MCDM model
%             combined with DEMATEL and ANP." In: Cutting-Edge Research Topics
%             on MCDM. Springer.
%
%  DEMATEL: direct-influence → normalized → total-relation → prominence/relation
%  ANP: supermatrix from DEMATEL total-relation → limit supermatrix → weights

arguments
    direct_influence (:, :) double     % [n x n] direct-influence matrix
    options.seed (1,1) double = 42
    options.tol (1,1) double = 1e-8    % convergence tolerance for limit supermatrix
    options.max_iter (1,1) double = 1000
    options.clusters (:, 1) double = [] % cluster assignments [n x 1] for ANP
end

rng(options.seed, 'twister');

%% --- Validate ---
[n, n2] = size(direct_influence);
assert(n == n2, 'DEMATEL:NonSquare', 'Influence matrix must be square.');
assert(n >= 2, 'DEMATEL:TooSmall', 'Need at least 2 factors.');
assert(all(direct_influence(:) >= 0), 'DEMATEL:NegativeInfluence', ...
    'Direct influence values must be nonnegative.');
assert(any(direct_influence(:) > 0), 'DEMATEL:AllZero', ...
    'Direct influence matrix must have some positive entries.');

%% --- Step 1: Normalize direct-influence matrix ---
% X = k * A, where k = 1 / max(max_i Σ_j a_ij, max_j Σ_i a_ij)
row_sums = sum(direct_influence, 2);
col_sums = sum(direct_influence, 1);
lambda = 1 / max(max(row_sums), max(col_sums));
X = lambda * direct_influence;

assert(lambda > 0, 'DEMATEL:ZeroLambda', 'Normalization factor is zero.');

%% --- Step 2: Total-relation matrix ---
% T = X + X^2 + X^3 + ... = X * (I - X)^{-1}
I_mat = eye(n);
total_relation = X / (I_mat - X);   % equivalent to X * inv(I - X)

% Check convergence: spectral radius of X must be < 1
eig_vals = abs(eig(X));
spectral_radius = max(eig_vals);
assert(spectral_radius < 1 - 1e-10, 'DEMATEL:NoConvergence', ...
    'Spectral radius = %.6f >= 1. Total-relation diverges.', spectral_radius);

% Numerical sanity
assert(all(total_relation(:) >= -1e-10), 'DEMATEL:NegativeTotalRelation', ...
    'Total-relation matrix has negative entries.');

%% --- Step 3: Prominence and Relation ---
% r_i = Σ_j T_ij (sum of rows = influence given)
% c_j = Σ_i T_ij (sum of columns = influence received)
r_vec = sum(total_relation, 2);   % row sums
c_vec = sum(total_relation, 1)';  % column sums

prominence = r_vec + c_vec;  % (r+c): importance of factor
relation   = r_vec - c_vec;  % (r-c): net influence (positive = net causer, negative = net receiver)

assert(all(prominence >= -1e-10), 'DEMATEL:BadProminence', 'Prominence must be nonnegative.');

% Threshold for significant relations
T_mean = mean(total_relation(:));
T_std  = std(total_relation(:));
threshold = T_mean + T_std;

%% --- Step 4: Build ANP supermatrix from DEMATEL total-relation ---
% Unweighted supermatrix: normalize each column of total-relation
supermatrix_unweighted = zeros(n, n);
for j = 1:n
    col_sum = sum(total_relation(:, j));
    if col_sum > 0
        supermatrix_unweighted(:, j) = total_relation(:, j) / col_sum;
    end
end

% If clusters are provided, build cluster-weighted supermatrix
if ~isempty(options.clusters)
    clusters = options.clusters;
    n_clusters = max(clusters);
    % Build cluster influence matrix by summing block-wise
    cluster_influence = zeros(n_clusters, n_clusters);
    for p = 1:n_clusters
        for q = 1:n_clusters
            idx_p = find(clusters == p);
            idx_q = find(clusters == q);
            cluster_influence(p, q) = sum(sum(total_relation(idx_p, idx_q)));
        end
    end
    % Normalize cluster influence
    for q = 1:n_clusters
        col_sum = sum(cluster_influence(:, q));
        if col_sum > 0
            cluster_influence(:, q) = cluster_influence(:, q) / col_sum;
        end
    end
    % Weight supermatrix blocks
    supermatrix_weighted = zeros(n, n);
    for p = 1:n_clusters
        for q = 1:n_clusters
            idx_p = find(clusters == p);
            idx_q = find(clusters == q);
            supermatrix_weighted(idx_p, idx_q) = ...
                cluster_influence(p, q) * supermatrix_unweighted(idx_p, idx_q);
        end
    end
    supermatrix = supermatrix_weighted;
else
    supermatrix = supermatrix_unweighted;
end

% Stochastic check: columns should sum to 1 (or 1-ish)
col_sums_sm = sum(supermatrix, 1);
assert(all(abs(col_sums_sm - 1) < 1e-8 | col_sums_sm < 1e-12), ...
    'DEMATEL:NonStochastic', 'Supermatrix columns must sum to 1.');

%% --- Step 5: Limit supermatrix → weights ---
W_prev = supermatrix;
W_curr = supermatrix;
converged = false;
exitflag = 1;

for iter = 1:options.max_iter
    W_curr = W_curr * supermatrix;   % or raise to power
    % Check if columns converge
    col_diff = max(max(abs(W_curr - W_prev)));
    if col_diff < options.tol
        converged = true;
        break;
    end
    W_prev = W_curr;
end

if ~converged
    exitflag = 0;
    warning('DEMATEL:ANPNotConverged', ...
        'Limit supermatrix did not converge in %d iterations.', options.max_iter);
end

% Weights from converged columns (all columns should be identical)
weights = W_curr(:, 1);
weights = weights / sum(weights);  % normalize

% Numerical sanity
assert(all(weights >= -1e-10), 'DEMATEL:NegativeWeights', 'Weights must be nonnegative.');
assert(abs(sum(weights) - 1) < 1e-8, 'DEMATEL:WeightSum', 'Weights sum != 1.');

%% Self-test
function self_test()
    fprintf('  Running dematel_anp self-test...\n');
    rng(42);
    % 4-factor known DEMATEL matrix from literature
    % Factors: F1, F2, F3, F4 with known influence relationships
    A_test = [0, 3, 2, 1;
              2, 0, 3, 1;
              1, 2, 0, 2;
              1, 1, 3, 0];

    [w, T, prom, rel, sm] = dematel_anp(A_test);

    % Total-relation matrix should be positive
    assert(all(T(:) >= -1e-10), 'Self-test: negative total-relation entries.');

    % Prominence should rank factors
    assert(length(unique(prom)) >= 2, 'Self-test: all factors have equal prominence.');

    % Relation: some net causers (r-c > 0) and some net receivers (r-c < 0)
    assert(any(rel > 0) && any(rel < 0), ...
        'Self-test: expected both causers and receivers.');

    % Weights should sum to 1
    assert(abs(sum(w) - 1) < 1e-8, 'Self-test: weights sum != 1.');

    % All weights positive
    assert(all(w > 0), 'Self-test: some zero/negative weights.');

    % Supermatrix should be column-stochastic
    assert(all(abs(sum(sm, 1) - 1) < 1e-6), 'Self-test: supermatrix not column-stochastic.');

    fprintf('  dematel_anp self-test PASSED (prominence=[%.2f, %.2f, %.2f, %.2f]).\n', prom);
end
end
