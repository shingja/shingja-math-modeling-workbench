% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [w_opt, cvar_val, var_val, exitflag] = cvar_opt(returns, options)
%% CVAR_OPT  CVaR portfolio optimization via Rockafellar-Uryasev formulation
%  Paradigm: ROBUST-002 | Category: ⑪ | Version: v3.0.0
%  Reference: Rockafellar & Uryasev (2000) "Optimization of Conditional
%             Value-at-Risk." Journal of Risk 2:21-41.
%
%  Formulation (LP):
%    min  γ + (1/(N*(1-α))) * Σ z_k
%    s.t. z_k >= -r_k'*w - γ,  z_k >= 0  ∀k
%         Σ w_i = 1,  w_i >= 0
%         μ'*w >= target_return

arguments
    returns (:, :) double             % [n_assets x n_scenarios] return matrix
    options.seed (1,1) double = 42
    options.alpha (1,1) double {mustBeInRange(options.alpha, 0, 1)} = 0.95
    options.target_return (1,1) double = -Inf  % min required return; -Inf = no target
    options.w_lb (:, 1) double = []   % per-asset lower bounds
    options.w_ub (:, 1) double = []   % per-asset upper bounds
end

rng(options.seed, 'twister');

%% --- Setup ---
[n_assets, n_scenarios] = size(returns);
assert(n_assets >= 2, 'CVAR:TooFewAssets', 'Need at least 2 assets.');
assert(n_scenarios >= 10, 'CVAR:TooFewScenarios', 'Need at least 10 scenarios.');

% Variables: [w (n_assets); γ (1); z (n_scenarios)]
n_vars = n_assets + 1 + n_scenarios;

% Objective: γ + (1/(N*(1-α))) * Σ z_k
c_obj = zeros(n_vars, 1);
c_obj(n_assets + 1) = 1.0;                       % coefficient for γ
c_obj(n_assets + 2 : end) = 1.0 / (n_scenarios * (1 - options.alpha));

% Inequality constraints: z_k + r_k'*w + γ >= 0  →  -r_k'*w - γ - z_k <= 0
% For linprog: A_ineq * x <= b_ineq
A_ineq = zeros(n_scenarios, n_vars);
for k = 1:n_scenarios
    A_ineq(k, 1:n_assets) = -returns(:, k)';       % -r_k' * w
    A_ineq(k, n_assets + 1) = -1;                   % -γ
    A_ineq(k, n_assets + 1 + k) = -1;               % -z_k
end
b_ineq = zeros(n_scenarios, 1);

% Equality: Σ w_i = 1
A_eq = zeros(1, n_vars);
A_eq(1, 1:n_assets) = 1;
b_eq = 1;

% Bounds
lb = zeros(n_vars, 1);
lb(1:n_assets) = 0;     % w >= 0 (no short selling default)
lb(n_assets + 1) = -inf; % γ free
lb(n_assets + 2 : end) = 0; % z >= 0

ub = inf(n_vars, 1);
ub(1:n_assets) = 1;

if ~isempty(options.w_lb)
    assert(length(options.w_lb) == n_assets, 'CVAR:LBDimMismatch', ...
        'w_lb must have length n_assets.');
    lb(1:n_assets) = options.w_lb;
end
if ~isempty(options.w_ub)
    assert(length(options.w_ub) == n_assets, 'CVAR:UBDimMismatch', ...
        'w_ub must have length n_assets.');
    ub(1:n_assets) = options.w_ub;
end

% Target return constraint (if specified)
if options.target_return > -Inf
    mu_returns = mean(returns, 2);
    A_ineq = [A_ineq; -mu_returns', zeros(1, 1 + n_scenarios)];
    b_ineq = [b_ineq; -options.target_return];
end

%% --- Solve LP ---
opts = optimoptions('linprog', 'Display', 'off', 'Algorithm', 'dual-simplex');
[x_sol, f_val, exitflag, ~] = linprog(c_obj, A_ineq, b_ineq, A_eq, b_eq, lb, ub, opts);

w_opt  = x_sol(1:n_assets);
gamma_opt = x_sol(n_assets + 1);
z_opt  = x_sol(n_assets + 2 : end);

% CVaR = optimal objective value
cvar_val = f_val;

% Compute VaR = -γ at optimal (for loss distribution, VaR ≈ -γ)
portfolio_returns = returns' * w_opt;
var_val = -gamma_opt;

% Sanity: CVaR >= VaR (by definition, for upper-tail CVaR on losses, CVaR ≥ VaR)
% For the minimization formulation, CVaR >= VaR holds
assert(cvar_val >= var_val - 1e-8, 'CVAR:OrderViolation', ...
    'CVaR (%.6f) should be >= VaR (%.6f).', cvar_val, var_val);

% Weights sum to 1
assert(abs(sum(w_opt) - 1) < 1e-8, 'CVAR:WeightSum', ...
    'Portfolio weights sum to %.10f, not 1.', sum(w_opt));

% Weights nonnegative
assert(all(w_opt >= -1e-10), 'CVAR:NegativeWeights', ...
    'Portfolio contains negative weights.');

% Convergence check
if exitflag <= 0
    warning('CVAR:SolverIssue', 'linprog exitflag = %d.', exitflag);
end

%% Self-test
function self_test()
    fprintf('  Running cvar_opt self-test...\n');
    rng(42);
    % 3-asset portfolio, 200 scenarios
    n_assets = 3;
    n_scen = 200;
    % Generate correlated returns
    mu = [0.001; 0.002; 0.0005];     % daily mean returns
    Sigma = [0.04, 0.02, 0.01;
             0.02, 0.06, 0.015;
             0.01, 0.015, 0.05] / 100;  % daily cov
    returns_mat = mvnrnd(mu, Sigma, n_scen)' * 100;  % percentage returns

    [w, cvar, var_val] = cvar_opt(returns_mat, 'alpha', 0.95);

    % CVaR >= VaR
    assert(cvar >= var_val - 1e-8, 'Self-test: CVaR < VaR.');

    % Weights sum to 1, nonnegative
    assert(abs(sum(w) - 1) < 1e-6, 'Self-test: weights do not sum to 1.');
    assert(all(w >= -1e-10), 'Self-test: negative weights.');

    % Portfolio CVaR should be finite and reasonable
    assert(isfinite(cvar), 'Self-test: CVaR is not finite.');
    assert(cvar < 20, 'Self-test: CVaR = %.4f unreasonably large.', cvar);

    fprintf('  cvar_opt self-test PASSED (CVaR=%6.4f%%, VaR=%6.4f%%, sum(w)=%.4f).\n', ...
        cvar, var_val, sum(w));
end
end
