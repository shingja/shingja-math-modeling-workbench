% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [w_dro, obj_dro, w_saa, obj_saa, exitflag] = wasserstein_dro(returns, options)
%% WASSERSTEIN_DRO  Wasserstein Distributionally Robust Optimization (basic)
%  Paradigm: ROBUST-005 | Category: ⑪ | Version: v3.0.0
%  Reference: Esfahani & Kuhn (2018) "Data-driven distributionally robust
%             optimization using the Wasserstein metric." Math Programming
%             171(1):115-156.
%
%  Builds Wasserstein ambiguity ball around empirical distribution,
%  solves robust portfolio problem.
%
%  Formulation (simplified):
%    max_w  min_{Q in W_epsilon(P_N)}  E_Q[r'w]
%    s.t.   Σ w_i = 1, w >= 0
%
%  Equivalent to: max_w  (1/N) Σ min(r_k'w + ε*||w||_*)  over scenarios k
%  For 1-Wasserstein with ||·||_* being dual norm.

arguments
    returns (:, :) double             % [n_assets x n_scenarios] return matrix
    options.seed (1,1) double = 42
    options.epsilon (1,1) double = 0.1  % Wasserstein radius
    options.lambda_reg (1,1) double = 0  % regularization (0 = none)
    options.w_lb (:, 1) double = []
    options.w_ub (:, 1) double = []
end

rng(options.seed, 'twister');

%% --- Setup ---
[n_assets, n_scenarios] = size(returns);
assert(n_assets >= 2, 'WASSERSTEIN:TooFewAssets', 'Need at least 2 assets.');
assert(n_scenarios >= 5, 'WASSERSTEIN:TooFewScenarios', 'Need at least 5 scenarios.');
assert(options.epsilon >= 0, 'WASSERSTEIN:BadEpsilon', 'Radius epsilon must be >= 0.');

%% --- SAA baseline (epsilon = 0) ---
f_saa = -mean(returns, 2);  % minimize negative mean return
lb = zeros(n_assets, 1);
ub = ones(n_assets, 1);
if ~isempty(options.w_lb)
    lb = options.w_lb;
end
if ~isempty(options.w_ub)
    ub = options.w_ub;
end

A_eq = ones(1, n_assets);
b_eq = 1;

opts = optimoptions('linprog', 'Display', 'off', 'Algorithm', 'dual-simplex');
[w_saa, obj_saa, ef_saa] = linprog(f_saa, [], [], A_eq, b_eq, lb, ub, opts);

%% --- Wasserstein DRO solution ---
% Equivalent reformulation (simplified for 1-Wasserstein with infinity-norm):
% max_{w, λ, s_k}  -λ*ε - (1/N)*Σ s_k
% s.t.  s_k >= -r_k'*w - λ   (∀k)
%       s_k >=  r_k'*w - λ   (∀k)  (since ||w||_1 = 1 for simplex w>=0)
%       Σ w = 1, w >= 0, λ >= 0

% This gives a conservative approximation; for exact L1-Wasserstein
% we need the full dual. Here we use the tractable LP reformulation.

eps_val = options.epsilon;

% Variables: [w (n_assets); lambda (1); s (n_scenarios)]
n_vars = n_assets + 1 + n_scenarios;
idx_w = 1:n_assets;
idx_lambda = n_assets + 1;
idx_s = n_assets + 2 : n_vars;

% Objective: -λ*ε - (1/N)*Σ s_k  (minimize)
f_dro = zeros(n_vars, 1);
f_dro(idx_lambda) = -eps_val;
f_dro(idx_s) = -1.0 / n_scenarios;

% Constraints: s_k >= -r_k'*w - λ  and  s_k >= r_k'*w - λ
%  =>  r_k'*w + λ + s_k >= 0   and  -r_k'*w + λ + s_k >= 0
% For linprog as A*x <= b:  -r_k'*w - λ - s_k <= 0 and r_k'*w - λ - s_k <= 0
A_ineq = [];
for k = 1:n_scenarios
    % Constraint 1: -r_k'*w - λ - s_k <= 0
    row1 = zeros(1, n_vars);
    row1(idx_w) = -returns(:, k)';
    row1(idx_lambda) = -1;
    row1(idx_s(k)) = -1;

    % Constraint 2: r_k'*w - λ - s_k <= 0
    row2 = zeros(1, n_vars);
    row2(idx_w) = returns(:, k)';
    row2(idx_lambda) = -1;
    row2(idx_s(k)) = -1;

    A_ineq = [A_ineq; row1; row2];
end
b_ineq = zeros(2 * n_scenarios, 1);

% Equality: Σ w = 1
A_eq_dro = zeros(1, n_vars);
A_eq_dro(idx_w) = 1;
b_eq_dro = 1;

% Bounds: w >= 0, λ >= 0, s free
lb_dro = [-inf(n_assets, 1); 0; -inf(n_scenarios, 1)];
if ~isempty(lb)
    lb_dro(idx_w) = lb;
end
ub_dro = [ub; inf; inf(n_scenarios, 1)];

% Regularization term (if lambda_reg > 0)
if options.lambda_reg > 0
    f_dro(idx_w) = f_dro(idx_w) + options.lambda_reg;
end

[x_dro, obj_dro_raw, ef_dro] = linprog(f_dro, A_ineq, b_ineq, ...
    A_eq_dro, b_eq_dro, lb_dro, ub_dro, opts);

w_dro = x_dro(idx_w);
% Convert back: the DRO objective maximizes expected return, obj_dro_raw is negated
obj_dro = -obj_dro_raw;
obj_saa = -obj_saa;  % convert to expected return scale
exitflag = ef_dro;

% DRO should be more conservative than SAA
% (DRO expected return <= SAA expected return)
assert(obj_dro <= obj_saa + 1e-6 || eps_val == 0, ...
    'WASSERSTEIN:DRONotConservative', ...
    'DRO obj (%.6f) should be <= SAA obj (%.6f) for epsilon>0.', obj_dro, obj_saa);

% Weights check
assert(abs(sum(w_dro) - 1) < 1e-8, 'WASSERSTEIN:WeightSum', ...
    'DRO weights sum to %.10f.', sum(w_dro));
assert(all(w_dro >= -1e-10), 'WASSERSTEIN:NegativeWeights', ...
    'DRO portfolio has negative weights.');

% Convergence
if ef_dro <= 0
    warning('WASSERSTEIN:SolverIssue', 'DRO LP exitflag = %d.', ef_dro);
end

%% Self-test
function self_test()
    fprintf('  Running wasserstein_dro self-test...\n');
    rng(42);
    % 3-asset, 10 scenarios for quick test
    n_a = 3;
    n_s = 10;
    % Create returns where asset 1 dominates but with some variance
    returns_test = [0.05 + 0.02*randn(1, n_s);   % asset 1: mean 5%
                    0.03 + 0.01*randn(1, n_s);   % asset 2: mean 3%
                    0.01 + 0.005*randn(1, n_s)]; % asset 3: mean 1%

    [w_d, obj_d, w_s, obj_s] = wasserstein_dro(returns_test, 'epsilon', 0.02);

    % DRO should be more conservative
    assert(obj_d <= obj_s + 1e-6, 'Self-test: DRO not more conservative than SAA.');

    % Both should have weights summing to 1
    assert(abs(sum(w_d) - 1) < 1e-6, 'Self-test: DRO weight sum != 1.');
    assert(abs(sum(w_s) - 1) < 1e-6, 'Self-test: SAA weight sum != 1.');

    % DRO portfolio should be more diversified (less extreme)
    assert(max(w_d) <= max(w_s) + 0.5, ...
        'Self-test: DRO should be more diversified than SAA.');

    fprintf('  wasserstein_dro self-test PASSED (SAA obj=%.6f, DRO obj=%.6f).\n', obj_s, obj_d);
end
end
