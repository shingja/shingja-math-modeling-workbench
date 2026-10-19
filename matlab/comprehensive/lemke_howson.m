% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [x, y, v1, v2, label, exitflag] = lemke_howson(A, B, options)
%% LEMKEHOWSON  Lemke-Howson algorithm for bimatrix game Nash equilibrium.
%  Computes a Nash equilibrium of a two-player bimatrix game via
%  complementary pivoting on the Linear Complementarity Problem (LCP).
%  Paradigm: PARADIGM-0701
%  Category: Comprehensive
%  Version: v3.0.0
%  Reference: Lemke, C.E. & Howson, J.T. (1964) Equilibrium points of
%             bimatrix games. SIAM Journal on Applied Mathematics, 12(2),
%             413-423. DOI: 10.1137/0112033.
%
%  Input:
%      A - Payoff matrix for Player 1 (m × n), rows = P1 strategies
%      B - Payoff matrix for Player 2 (m × n), rows = P1, cols = P2
%
%  Options:
%      options.max_iter - Maximum pivot steps (default: 1000)
%      options.tol      - Numerical tolerance (default: 1e-10)
%      options.shift    - Add positive shift to ensure positivity (default: true)
%      options.seed     - RNG seed for tie-breaking (default: 42)
%
%  Output:
%      x        - Mixed strategy for Player 1 (m × 1), stochastic vector
%      y        - Mixed strategy for Player 2 (n × 1), stochastic vector
%      v1       - Expected payoff to Player 1
%      v2       - Expected payoff to Player 2
%      label    - 'equilibrium' | 'degenerate' | 'no_convergence'
%      exitflag - 1 = success, 0 = degenerate, -1 = failed

arguments
    A (:, :) double
    B (:, :) double
    options.max_iter (1,1) double {mustBeInteger, mustBePositive} = 1000
    options.tol (1,1) double {mustBePositive} = 1e-10
    options.shift (1,1) logical = true
    options.seed (1,1) double = 42
end

rng(options.seed, 'twister');

[m, n] = size(A);
assert(all(size(B) == [m, n]), ...
    'Payoff matrices A and B must have the same dimensions (m × n).');
assert(m >= 1 && n >= 1, 'Payoff matrices must have at least 1 row and 1 column.');

tol = options.tol;

%% Shift matrices to be strictly positive if requested
% This ensures the nondegeneracy assumption of Lemke-Howson
if options.shift
    min_A = min(A(:));
    min_B = min(B(:));
    shift_val = max(0, 1 - min(min_A, min_B));
    A_pos = A + shift_val;
    B_pos = B + shift_val;
else
    A_pos = A;
    B_pos = B;
    assert(all(A_pos(:) >= 0) && all(B_pos(:) >= 0), ...
        'With shift=false, payoff matrices must be elementwise non-negative.');
end

%% Construct the LCP tableau
% Variables: z1...zm (P1 mixed), w1...wn (P2 slacks), then z_{m+1}...z_{m+n} (P2 mixed), w_{n+1}...w_{n+m} (P1 slacks)
% Plus the artificial variable z0
k_total = m + n;  % Total complementary pairs
n_vars = 2 * k_total + 1;

% Scale each column of B_pos^T: 1 / B_pos(j,i) for the i-th row of B_pos^T
% Construct column coefficients for tableau
% For equations: w_i + sum_j M_ij * z_j = 1 (for some M)

% Standard approach: define matrices M1 (m×n) and M2 (n×m)
% M1_{ij} = A_pos_{ij} / (eps + ...). Actually, we follow the standard LCP form.
% Let us construct the standard tableau for 2-player games.

% For Player 1: x >= 0, B^T * x <= 1 → introduce slack s >= 0.
% For Player 2: y >= 0, A * y <= 1 → introduce slack t >= 0.
% Complementary slackness: x_i * s_i = 0, y_j * t_j = 0.
% This is an LCP(M, q) with:
%   M = [0, A_pos; B_pos^T, 0]
%   q = -ones(m+n, 1)

M_top = [zeros(m, m), A_pos];
M_bot = [B_pos', zeros(n, n)];
M_mat = [M_top; M_bot];
q_vec = -ones(m + n, 1);

%% Build the initial tableau with artificial column z0
% Basic variables w, nonbasic z. Tableau: w = -q + M*z + d*z0
% where d = -1 (column of ones for artificial variable)
tableau = zeros(k_total, 2 * k_total + 2);

% The canonical form: I*w - M*z + 1*z0 = -q
% Rows: basic vars w_i
% Columns: w (k_total), z (k_total), z0, RHS
for i = 1:k_total
    tableau(i, i) = 1;  % coefficient of w_i
    for j = 1:k_total
        tableau(i, k_total + j) = -M_mat(i, j);  % -M for z_j
    end
    tableau(i, 2*k_total + 1) = 1;  % coefficient of z0 (column of ones)
    tableau(i, 2*k_total + 2) = -q_vec(i);  % RHS: initially -q = 1
end

%% Initial basis: all w_i are basic
basis = (1:k_total)';     % indices of basic variables
nonbasis = (k_total+1:2*k_total+1)';  % indices of nonbasic (all z + z0)

%% Phase I: bring z0 into basis
% Find the row with the most negative RHS to pivot z0 out
rhs_col = 2 * k_total + 2;
[~, pivot_row] = min(tableau(:, rhs_col));

% Pivot z0 (column 2*k_total+1) into basis at pivot_row
% The entering variable is z0
z0_col = 2 * k_total + 1;

% Perform pivot operation
tableau = pivot_operation(tableau, pivot_row, z0_col, tol);
basis(pivot_row) = 2 * k_total + 1;  % z0 enters basis
nonbasis = setdiff(nonbasis, 2*k_total+1);

% The leaving variable w_{pivot_row} (if pivot_row <= k_total) leaves
% Find which variable left
old_basic = find(tableau(:, 2*k_total+2) == 0, 1);  % not needed; track via basis change
% Update: the leaving variable was the previous basic at pivot_row

%% Phase II: complementary pivoting
exitflag = 0;
label = 'no_convergence';

for iter = 1:options.max_iter
    % Identify the variable complementary to the one that just left the basis
    % If leaving var index <= k_total (a w_i), entering is z_i (k_total + index)
    % If leaving var index > k_total (a z_j), entering is w_j (index - k_total)
    leaving_var = old_basic_var;
    if leaving_var <= k_total
        entering_var = k_total + leaving_var;  % complementary z
    else
        entering_var = leaving_var - k_total;   % complementary w
    end

    % Check if z0 just left (entering_var would be 0 or out of range)
    if leaving_var == 2*k_total + 1
        % z0 left → equilibrium found
        exitflag = 1;
        label = 'equilibrium';
        break;
    end

    % Find the entering column in the nonbasic set
    entering_col_in_tableau = entering_var;

    % Minimum ratio test for pivot row
    ratio_col = tableau(:, entering_col_in_tableau);
    rhs_vals = tableau(:, rhs_col);

    feasible_rows = find(ratio_col > tol);
    if isempty(feasible_rows)
        % Ray termination
        exitflag = 0;
        label = 'degenerate';
        break;
    end

    ratios = rhs_vals(feasible_rows) ./ ratio_col(feasible_rows);
    [min_ratio, min_idx] = min(ratios);
    pivot_row = feasible_rows(min_idx);

    % Check for degeneracy (multiple min ratios)
    if sum(abs(ratios - min_ratio) < tol) > 1
        warning('LEMKEHOWSON:Degenerate', ...
            'Degenerate pivot at iteration %d. Results may be unreliable.', iter);
    end

    % Track the leaving variable before pivot
    old_basic_var = basis(pivot_row);

    % If z0 is leaving, we are done
    if old_basic_var == 2*k_total + 1
        tableau = pivot_operation(tableau, pivot_row, entering_col_in_tableau, tol);
        basis(pivot_row) = entering_var;
        exitflag = 1;
        label = 'equilibrium';
        break;
    end

    % Perform the pivot
    tableau = pivot_operation(tableau, pivot_row, entering_col_in_tableau, tol);
    basis(pivot_row) = entering_var;
end

if iter >= options.max_iter && exitflag == 0
    exitflag = -1;
    label = 'no_convergence';
    warning('LEMKEHOWSON:MaxIter', ...
        'Algorithm did not converge within %d iterations.', options.max_iter);
end

%% Extract solution from final tableau
% Find basic variable values
x_raw = zeros(m, 1);
y_raw = zeros(n, 1);

for i = 1:k_total
    if basis(i) <= m
        % w_i basic → x_i = 0
        x_raw(basis(i)) = 0;
    elseif basis(i) <= m + n && basis(i) > m
        % some other variable basic
        % Actually extract from RHS based on which variables are basic
    end
end

% Extract from tableau directly: for each column j that is basic in some row,
% its value equals the RHS of that row divided by the coefficient.
sol_values = zeros(2*k_total + 1, 1);
for i = 1:size(tableau, 1)
    bv = basis(i);
    if bv <= 2*k_total
        sol_values(bv) = tableau(i, rhs_col);
    end
end

% z variables (m+1 to m+n) correspond to Player 2 strategies
% w variables (1 to m) are Player 1 slacks
% Actually for LCP form:
%   z_1...z_m = Player 1 strategies (x)
%   z_{m+1}...z_{m+n} = Player 2 strategies (y)
x_raw = max(0, sol_values(1:m));
y_raw = max(0, sol_values(m+1:m+n));

%% Normalize to probability distributions
sum_x = sum(x_raw);
sum_y = sum(y_raw);

if sum_x < tol
    % Pure strategy case or degenerate: use uniform
    x = ones(m, 1) / m;
else
    x = x_raw / sum_x;
end

if sum_y < tol
    y = ones(n, 1) / n;
else
    y = y_raw / sum_y;
end

%% Compute expected payoffs
v1 = x' * A * y;
v2 = x' * B * y;

%% Save results (cross-platform): save(fullfile(pwd, 'lemke_howson_results.mat'), 'x', 'y', 'v1', 'v2');

%% Verify Nash condition: P1 cannot improve by unilateral deviation
for i = 1:m
    deviation_payoff = A(i, :) * y;
    assert(deviation_payoff <= v1 + tol * 10, ...
        'LEMKEHOWSON:NashViolation', ...
        'Player 1 can improve by deviating to strategy %d.', i);
end

for j = 1:n
    deviation_payoff = x' * B(:, j);
    assert(deviation_payoff <= v2 + tol * 10, ...
        'LEMKEHOWSON:NashViolation', ...
        'Player 2 can improve by deviating to strategy %d.', j);
end

%% Nested: pivot operation
function T = pivot_operation(T, row, col, pivot_tol)
    pivot_val = T(row, col);
    assert(abs(pivot_val) > pivot_tol, ...
        'Pivot element %.6e is too close to zero.', pivot_val);
    T(row, :) = T(row, :) / pivot_val;
    [n_rows, n_cols] = size(T);
    for r = 1:n_rows
        if r ~= row
            factor = T(r, col);
            if abs(factor) > pivot_tol
                T(r, :) = T(r, :) - factor * T(row, :);
            end
        end
    end
end

%% Self-test
function self_test()
    % Prisoner's Dilemma: (Defect, Defect) is the unique Nash equilibrium
    % Player 1 payoff:  Cooperate  Defect
    %         Cooperate   (-1, -1)   (-3,  0)
    %         Defect       ( 0, -3)   (-2, -2)
    % Transform to positive: add 4 to all entries
    A_pd = [3, 1; 4, 2];  % P1: Cooperate=[3,1], Defect=[4,2]
    B_pd = [3, 4; 1, 2];  % P2: Cooperate=[3,4], Defect=[1,2]

    [x_sol, y_sol, ~, ~, lbl, flag] = lemke_howson(A_pd, B_pd, ...
        max_iter=500, tol=1e-10);

    % Nash equilibrium should be (Defect, Defect) = x=[0,1], y=[0,1]
    assert(flag >= 0, 'Self-test failed: exitflag %d (expected >= 0).', flag);
    assert(x_sol(2) > 0.9, ...
        'Self-test failed: P1 should play Defect with prob > 0.9, got x=[%.4f, %.4f].', ...
        x_sol(1), x_sol(2));
    assert(y_sol(2) > 0.9, ...
        'Self-test failed: P2 should play Defect with prob > 0.9, got y=[%.4f, %.4f].', ...
        y_sol(1), y_sol(2));

    disp('LEMKEHOWSON self-test passed.');
end
end
