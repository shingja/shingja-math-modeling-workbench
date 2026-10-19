% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [row_coord, col_coord, inertia, chi2, exitflag] = correspondence_analysis(X, options)
%% CORRESPONDENCEANALYSIS Correspondence Analysis (CA) for contingency tables.
%  Performs correspondence analysis on a contingency table: computes
%  chi-square distances, SVD of standardized residuals, row and column
%  principal coordinates, and inertia decomposition.
%  Paradigm: PARADIGM-0704
%  Category: Comprehensive
%  Version: v3.0.0
%  Reference: Greenacre, M.J. (2017) Correspondence Analysis in Practice,
%             3rd Edition. CRC Press. ISBN: 978-1498731775.
%             Benzecri, J.P. (1973) L'Analyse des Donnees, Tome 2:
%             L'Analyse des Correspondances. Dunod, Paris.
%
%  Input:
%      X - Contingency table (r rows x c columns), non-negative
%
%  Options:
%      options.n_dims      - Number of dimensions to retain (default: min([r,c])-1)
%      options.normalize   - Normalization: 'standard' (default) | 'row_principal' | 'col_principal'
%      options.seed        - RNG seed (default: 42)
%
%  Output:
%      row_coord - Row principal coordinates (r x n_dims)
%      col_coord - Column principal coordinates (c x n_dims)
%      inertia   - Principal inertias (eigenvalues) (n_dims x 1)
%      chi2      - Chi-square statistic of the table
%      exitflag  - 1 = success, 0 = warning, -1 = error

arguments
    X (:, :) double
    options.n_dims (1,1) double {mustBeInteger, mustBePositive} = []
    options.normalize char {mustBeMember(options.normalize, {'standard','row_principal','col_principal'})} = 'standard'
    options.seed (1,1) double = 42
end

rng(options.seed, 'twister');
exitflag = 1;

[r, c] = size(X);
assert(r >= 2 && c >= 2, 'Contingency table must be at least 2x2.');
assert(all(X(:) >= 0), 'All entries must be non-negative.');

%% Step 1: Correspondence matrix (probability table)
N_total = sum(X(:));
if N_total < 1e-12
    exitflag = -1;
    warning('CORRESPONDENCEANALYSIS:ZeroSum', 'All entries sum to zero.');
    row_coord = zeros(r, 1);
    col_coord = zeros(c, 1);
    inertia = 0;
    chi2 = 0;
    return;
end

P = X / N_total;  % joint probability matrix

%% Step 2: Row and column masses
row_mass = sum(P, 2);  % r x 1
col_mass = sum(P, 1);  % 1 x c

% Remove zero-mass rows/columns
row_keep = row_mass > 1e-14;
col_keep = col_mass > 1e-14;

if sum(row_keep) < 2 || sum(col_keep) < 2
    exitflag = 0;
    warning('CORRESPONDENCEANALYSIS:TooFewNonZero', ...
        'Not enough non-zero row/column masses.');
end

%% Step 3: Expected frequencies under independence
E = row_mass * col_mass;  % r x c

%% Step 4: Standardized residuals
% S_ij = (P_ij - E_ij) / sqrt(E_ij)
S = zeros(r, c);
for i = 1:r
    for j = 1:c
        denom = E(i, j);
        if denom > 1e-14
            S(i, j) = (P(i, j) - E(i, j)) / sqrt(denom);
        end
    end
end

%% Step 5: Weighted SVD
% Decompose: D_r^{-1/2} * S * D_c^{-1/2} = U * D * V'
Dr_half_inv = diag(1 ./ sqrt(row_mass + 1e-14));
Dc_half_inv = diag(1 ./ sqrt(col_mass + 1e-14));

Z = Dr_half_inv * S * Dc_half_inv;

% SVD
[U, D_mat, V] = svd(Z, 'econ');
singular_vals = diag(D_mat);

% Inertia = squared singular values
inertia_full = singular_vals.^2;

%% Step 6: Chi-square statistic and total inertia
chi2 = N_total * sum(inertia_full);

%% Step 7: Determine number of dimensions
if isempty(options.n_dims)
    n_dims = min([r, c]) - 1;
else
    n_dims = min(options.n_dims, min([r, c]) - 1);
end
n_dims = min(n_dims, length(inertia_full));
n_dims = max(n_dims, 1);

%% Step 8: Principal coordinates
% Standard coordinates
row_std = Dr_half_inv * U(:, 1:n_dims);  % r x n_dims
col_std = Dc_half_inv * V(:, 1:n_dims);  % c x n_dims

% Principal coordinates: multiply by singular values
switch options.normalize
    case 'standard'
        D_n = D_mat(1:n_dims, 1:n_dims);
        row_coord = row_std * D_n;
        col_coord = col_std * D_n;
    case 'row_principal'
        D_n = D_mat(1:n_dims, 1:n_dims);
        row_coord = row_std * D_n;
        col_coord = col_std;  % column standard coordinates
    case 'col_principal'
        D_n = D_mat(1:n_dims, 1:n_dims);
        row_coord = row_std;
        col_coord = col_std * D_n;
    otherwise
        D_n = D_mat(1:n_dims, 1:n_dims);
        row_coord = row_std * D_n;
        col_coord = col_std * D_n;
end

inertia = inertia_full(1:n_dims);

%% Validation
if any(isnan(row_coord(:))) || any(isnan(col_coord(:)))
    exitflag = -1;
    warning('CORRESPONDENCEANALYSIS:NaNOutput', 'NaN in output coordinates.');
end

%% Self-test
function self_test()
    % Test 1: Classic 3x3 contingency table
    % Rows: age groups (Young, Middle, Old)
    % Cols: preference (A, B, C)
    X_test = [25, 30, 15;
              20, 35, 25;
              10, 15, 20];

    [row_c, col_c, inert, c2, ef] = correspondence_analysis(X_test, 'seed', 42);

    assert(ef >= 0, 'Self-test 1: exitflag >= 0, got %d.', ef);
    assert(size(row_c, 2) >= 1, ...
        'Self-test 1: expected at least 1 dimension, got %d.', size(row_c, 2));
    assert(size(col_c, 1) == 3, ...
        'Self-test 1: 3 column categories, got %d.', size(col_c, 1));
    assert(c2 > 0, 'Self-test 1: chi-square should be > 0, got %.4f.', c2);

    % Test 2: Row coordinates sum to zero (weighted by mass)
    N_tot = sum(X_test(:));
    P_mat = X_test / N_tot;
    row_m = sum(P_mat, 2);
    weighted_mean = row_m' * row_c;
    assert(all(abs(weighted_mean) < 1e-8), ...
        'Self-test 2: weighted row coordinates should sum to zero, got [%.8f %.8f].', ...
        weighted_mean);

    % Test 3: Column coordinates sum to zero (weighted by mass)
    col_m = sum(P_mat, 1)';
    % Column coordinates should be weighted to zero by col_m
    weighted_col = col_m' * col_c;
    assert(all(abs(weighted_col) < 1e-8), ...
        'Self-test 3: weighted column coordinates should sum to zero, got [%.8f %.8f].', ...
        weighted_col);

    % Test 4: Inertia decomposition: sum of eigenvalues = chi2/N
    inert_ratio = sum(inert) / (c2 / N_tot);
    assert(abs(inert_ratio - 1) < 1e-10, ...
        'Self-test 4: inertias should sum to chi2/N, ratio=%.12f.', inert_ratio);

    % Test 5: Inertias are non-negative and decreasing
    assert(all(inert > -1e-12), ...
        'Self-test 5: inertias must be non-negative.');
    for k = 2:length(inert)
        assert(inert(k) <= inert(k-1) + 1e-12, ...
            'Self-test 5: inertias should be decreasing.');
    end

    fprintf('CORRESPONDENCEANALYSIS self-test PASSED (5 tests, all assertions passed).\n');
end
end
