% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [x_robust, obj_robust, x_nominal, obj_nominal, exitflag] = robust_counterpart(A_nom, A_hat, b_vec, c_vec, options)
%% ROBUST_COUNTERPART  Bertsimas-Sim robust counterpart for LP
%  Paradigm: ROBUST-004 | Category: ⑪ | Version: v3.0.0
%  Reference: Bertsimas & Sim (2004) "The Price of Robustness." Operations
%             Research 52(1):35-53.
%
%  Solves: min c'x s.t.
%    a_i'x + max_{S⊆J_i,|S|≤⌊Γ⌋} Σ_{j∈S} â_ij |x_j| + (Γ-⌊Γ⌋) â_it |x_t| ≤ b_i
%
%  Reformulated as LP with auxiliary variables p_i, q_ij.

arguments
    A_nom (:, :) double               % nominal constraint matrix [m x n]
    A_hat (:, :) double               % deviation magnitudes [m x n]
    b_vec (:, 1) double               % RHS [m x 1]
    c_vec (:, 1) double               % objective coefficients [n x 1]
    options.seed (1,1) double = 42
    options.Gamma (1,1) double = 0    % budget of uncertainty (0=nominal, n=Soyster)
    options.solve_nominal (1,1) logical = true
    options.x_lb (:, 1) double = []
end

rng(options.seed, 'twister');

%% --- Validate ---
[m, n] = size(A_nom);
assert(all(size(A_hat) == [m, n]), 'ROBUST:DimMismatch', ...
    'A_hat must be [m x n] same as A_nom.');
assert(length(b_vec) == m, 'ROBUST:DimMismatch', 'b_vec length mismatch.');
assert(length(c_vec) == n, 'ROBUST:DimMismatch', 'c_vec length mismatch.');
assert(options.Gamma >= 0, 'ROBUST:BadGamma', 'Gamma must be >= 0.');

%% --- Solve nominal problem (Gamma = 0) ---
opts = optimoptions('linprog', 'Display', 'off', 'Algorithm', 'dual-simplex');
lb = -inf(n, 1);
if ~isempty(options.x_lb)
    lb = options.x_lb;
end

if options.solve_nominal
    [x_nominal, obj_nominal, ef_nom] = linprog(c_vec, A_nom, b_vec, ...
        [], [], lb, [], opts);
else
    x_nominal = [];
    obj_nominal = NaN;
    ef_nom = 1;
end
exitflag = ef_nom;

%% --- Solve robust counterpart ---
Gamma = options.Gamma;
if Gamma <= 0 || Gamma > n
    % Gamma=0 => nominal; Gamma>n => use Soyster (worst-case all deviations)
    Gamma_floor = min(floor(Gamma), n);
    Gamma_frac  = max(0, Gamma - Gamma_floor);
else
    Gamma_floor = floor(Gamma);
    Gamma_frac  = Gamma - Gamma_floor;
end

if Gamma_floor == 0 && Gamma_frac < 1e-10
    % Essentially nominal
    x_robust = x_nominal;
    obj_robust = obj_nominal;
    if ~options.solve_nominal
        [x_robust, obj_robust, exitflag] = linprog(c_vec, A_nom, b_vec, ...
            [], [], lb, [], opts);
    end
    return;
end

% Robust LP variables: [x (n); p_i (m); q_ij (m*n)]
% For each constraint i:
%   a_nom_i'*x + Gamma_floor*p_i + Σ_j q_ij <= b_i
%   p_i + q_ij >= a_hat_ij * y_j,  y_j >= x_j, y_j >= -x_j
%
% Using linearized version: introduce y_j = |x_j|
% Variables: [x (n); y (n); p (m); q (m*n)]
%   a_nom'*x + Gamma_floor*p + Σ_j q_ij <= b_i    (m constraints)
%   y_j >= x_j, y_j >= -x_j                         (2n constraints)
%   p_i + q_ij >= a_hat_ij * y_j                    (m*n constraints)
%   x free, y >= 0, p >= 0, q >= 0

n_vars = n + n + m + m*n;  % x, y, p, q
idx_x = 1:n;
idx_y = n+1 : 2*n;
idx_p = 2*n+1 : 2*n+m;
idx_q_start = 2*n+m+1;

% Objective
f_obj = [c_vec; zeros(n + m + m*n, 1)];

% Constraints
A_ineq_rows = [];
b_ineq_rows = [];

% (a) a_nom_i'*x + Gamma_floor*p_i + Σ_j q_ij <= b_i   for each i
for i = 1:m
    row = zeros(1, n_vars);
    row(idx_x) = A_nom(i, :);
    row(idx_p(i)) = Gamma_floor;
    for j = 1:n
        q_idx = idx_q_start + (i-1)*n + (j-1);
        row(q_idx) = 1;
    end
    % Handle fractional part: additional protection
    if Gamma_frac > 0
        % Add (Gamma - floor(Gamma)) * a_hat_it * y_t
        % Find the most impactful deviation for fractional part
        [~, t_idx] = max(A_hat(i, :));
        row(idx_y(t_idx)) = Gamma_frac * A_hat(i, t_idx);
    end
    A_ineq_rows = [A_ineq_rows; row];
    b_ineq_rows = [b_ineq_rows; b_vec(i)];
end

% (b) y_j >= x_j  =>  x_j - y_j <= 0
for j = 1:n
    row = zeros(1, n_vars);
    row(j) = 1;
    row(n + j) = -1;
    A_ineq_rows = [A_ineq_rows; row];
    b_ineq_rows = [b_ineq_rows; 0];
end

% (c) y_j >= -x_j  =>  -x_j - y_j <= 0
for j = 1:n
    row = zeros(1, n_vars);
    row(j) = -1;
    row(n + j) = -1;
    A_ineq_rows = [A_ineq_rows; row];
    b_ineq_rows = [b_ineq_rows; 0];
end

% (d) p_i + q_ij >= a_hat_ij * y_j  =>  a_hat_ij*y_j - p_i - q_ij <= 0
for i = 1:m
    for j = 1:n
        row = zeros(1, n_vars);
        row(idx_y(j)) = A_hat(i, j);
        row(idx_p(i)) = -1;
        q_idx = idx_q_start + (i-1)*n + (j-1);
        row(q_idx) = -1;
        A_ineq_rows = [A_ineq_rows; row];
        b_ineq_rows = [b_ineq_rows; 0];
    end
end

% Bounds
lb_robust = [-inf(n, 1); zeros(n + m + m*n, 1)];   % x_free, y>=0, p>=0, q>=0
if ~isempty(options.x_lb)
    lb_robust(idx_x) = options.x_lb;
end

% Solve
[x_sol, obj_robust, ef_rob, ~] = linprog(f_obj, A_ineq_rows, b_ineq_rows, ...
    [], [], lb_robust, [], opts);

x_robust = x_sol(idx_x);
exitflag = ef_rob;

% Robust objective should be >= nominal objective (price of robustness)
if options.solve_nominal && ef_rob > 0
    if obj_robust < obj_nominal - 1e-6
        warning('ROBUST:ObjOrderViolation', ...
            'Robust obj (%.4f) < nominal obj (%.4f). Solution may be wrong.', ...
            obj_robust, obj_nominal);
    end
    assert(obj_robust >= obj_nominal - 1e-6, ...
        'ROBUST:ObjOrder', 'Robust objective must be >= nominal.');
end

% Convergence
if ef_rob <= 0
    warning('ROBUST:SolverIssue', 'Robust LP exitflag = %d.', ef_rob);
end

%% Self-test
function self_test()
    fprintf('  Running robust_counterpart self-test...\n');
    rng(42);
    % Simple production problem:
    % max 3*x1 + 5*x2  (profit)
    % s.t. x1           <= 4   (resource 1)
    %            x2     <= 6   (resource 2)
    %      3*x1 + 2*x2  <= 18  (resource 3, uncertain)
    % Nominal: A = [1 0; 0 1; 3 2], b = [4;6;18], c = [-3;-5]

    A_nom_test  = [1, 0; 0, 1; 3, 2];
    A_hat_test  = [0, 0; 0, 0; 0.5, 0.5];  % uncertainty in resource 3 coefficients
    b_test = [4; 6; 18];
    c_test = [-3; -5];    % minimize negative profit

    [x_r, obj_r, x_n, obj_n] = robust_counterpart(A_nom_test, A_hat_test, b_test, c_test, ...
        'Gamma', 1.0);

    % Nominal optimal: x1=2, x2=6, profit=3*2+5*6=36, obj=-36
    % Robust optimal should be more conservative: profit <= 36
    assert(abs(obj_n + 36) < 1e-4, 'Self-test: nominal objective mismatch.');
    assert(obj_r >= obj_n - 1e-6, 'Self-test: robust must be >= nominal obj.');
    assert(all(x_r >= -1e-10), 'Self-test: negative production amounts.');

    % Gamma=0 should equal nominal
    [x_r0, obj_r0] = robust_counterpart(A_nom_test, A_hat_test, b_test, c_test, ...
        'Gamma', 0.0);
    assert(abs(obj_r0 - obj_n) < 1e-6, 'Self-test: Gamma=0 should match nominal.');

    fprintf('  robust_counterpart self-test PASSED (nominal obj=%.4f, robust obj=%.4f).\n', ...
        obj_n, obj_r);
end
end
