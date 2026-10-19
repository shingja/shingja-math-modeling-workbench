% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [x_first, x_second, obj_val, exitflag] = two_stage_stochastic(c, q, T, W, h, scenarios, options)
%% TWO_STAGE_STOCHASTIC  Two-stage stochastic programming with SAA
%  Paradigm: ROBUST-001 | Category: ⑪ | Version: v3.0.0
%  Reference: Shapiro, Dentcheva & Ruszczynski (2009) Lectures on Stochastic
%             Programming: Modeling and Theory. SIAM.
%
%  Formulation:
%    min  c'*x + E[Q(x,ξ)]
%    s.t. A*x = b, x >= 0
%    where Q(x,ξ) = min{q'*y : W*y = h - T*x, y >= 0}
%
%  SAA: replace expectation by sample average over N scenarios.
%
%  Usage for newsvendor: two_stage_stochastic(c, q, T, W, h, demand_scenarios)

arguments
    c (:, 1) double                   % first-stage cost
    q (:, 1) double                   % second-stage cost (per scenario)
    T (:, :) double                   % technology matrix
    W (:, :) double                   % recourse matrix
    h (:, :) double                   % RHS matrix [n2 x n_scenarios] or [n2 x 1]
    scenarios (:, :) double = []      % scenario data; if h is [n2 x N] then optional
    options.seed (1,1) double = 42
    options.A (:, :) double = []      % first-stage equality constraint A*x = b
    options.b (:, 1) double = []
    options.x_lb (:, 1) double = []   % lower bounds on x
    options.x_ub (:, 1) double = []   % upper bounds on x
end

rng(options.seed, 'twister');

%% --- Validate inputs ---
n1 = length(c);
n2 = size(W, 1);
m2 = size(W, 2);
assert(size(T,1) == n2 && size(T,2) == n1, 'TWOSTAGE:DimMismatch', ...
    'T must be [n2 x n1] where n2=size(W,1), n1=length(c).');
assert(length(q) == m2, 'TWOSTAGE:DimMismatch', ...
    'q must have length equal to number of second-stage vars.');

% Build scenarios: if h is [n2 x N], each column is a scenario
if size(h, 2) > 1
    N_scenarios = size(h, 2);
    h_scenarios = h;
else
    N_scenarios = size(scenarios, 2);
    assert(N_scenarios > 0, 'TWOSTAGE:NoScenarios', ...
        'Must provide scenarios (multi-column h or scenarios matrix).');
    h_scenarios = repmat(h, 1, N_scenarios) + scenarios;
end

%% --- Build deterministic equivalent LP ---
% Variables: [x; y1; y2; ...; yN]
% Total vars: n1 + N_scenarios * m2

n_total = n1 + N_scenarios * m2;
f_obj = [c; repmat(q, N_scenarios, 1) / N_scenarios];

% Constraints:
% 1. First-stage constraints: A_eq * x = b_eq
% 2. For each scenario s: T*x + W*y_s = h_s

% Build equality constraints
A_eq_rows = [];

% First-stage equality
if ~isempty(options.A)
    n_eq1 = size(options.A, 1);
    A_row1 = [options.A, zeros(n_eq1, N_scenarios * m2)];
    A_eq_rows = [A_eq_rows; A_row1];
else
    n_eq1 = 0;
end

% Second-stage equality per scenario
for s = 1:N_scenarios
    A_row_s = zeros(n2, n_total);
    A_row_s(:, 1:n1) = T;                          % T * x
    col_start = n1 + (s-1)*m2 + 1;
    col_end   = n1 + s*m2;
    A_row_s(:, col_start:col_end) = W;              % W * y_s
    A_eq_rows = [A_eq_rows; A_row_s];
end

% RHS
if ~isempty(options.b)
    b_eq = [options.b; h_scenarios(:)];
else
    b_eq = h_scenarios(:);
end

% Bounds
lb = zeros(n_total, 1);
ub = inf(n_total, 1);
if ~isempty(options.x_lb)
    lb(1:n1) = options.x_lb;
end
if ~isempty(options.x_ub)
    ub(1:n1) = options.x_ub;
end

%% --- Solve LP ---
opts = optimoptions('linprog', 'Display', 'off', 'Algorithm', 'dual-simplex');
[x_sol, obj_val, exitflag, ~] = linprog(f_obj, [], [], A_eq_rows, b_eq, lb, ub, opts);

% Extract solutions
x_first  = x_sol(1:n1);
x_second = zeros(m2, N_scenarios);
for s = 1:N_scenarios
    col_start = n1 + (s-1)*m2 + 1;
    col_end   = n1 + s*m2;
    x_second(:, s) = x_sol(col_start:col_end);
end

% Convergence / feasibility check
if exitflag <= 0
    warning('TWOSTAGE:SolverIssue', ...
        'linprog exitflag = %d. Solution may be infeasible or unbounded.', exitflag);
end
assert(all(isfinite(x_sol)) || exitflag > 0, 'TWOSTAGE:BadSolution', ...
    'Solution contains non-finite values.');

% Numerical sanity: first-stage cost should be nonnegative for typical problems
if all(c >= 0) && ~isempty(c)
    assert(obj_val >= -1e-8, 'TWOSTAGE:NegativeObjective', ...
        'Objective value negative with nonnegative costs.');
end

%% Self-test
function self_test()
    fprintf('  Running two_stage_stochastic self-test...\n');
    rng(42);
    % Newsvendor: order x units at cost c=2, demand d ~ U[20,80]
    % If d > x: shortage cost q_short=5 per unit, sell at price p=8
    % If d <= x: surplus cost q_surplus=1 per unit
    % Recourse: y_short >= 0, y_surplus >= 0
    %   min  2*x + (1/N)*sum(5*y_short_s - 1*y_surplus_s)
    %   s.t. x + y_short_s - y_surplus_s = d_s   for each s
    c_first  = 3;         % order cost (minus salvage)
    q_recourse = [8; -1];  % [shortage_penalty; surplus_salvage] (net)
    T_mat  = 1;
    W_mat  = [1, -1];      % y_short - y_surplus
    N_s    = 100;
    demand = 20 + 60 * rand(N_s, 1);  % U[20,80]

    [x1, x2, obj] = two_stage_stochastic(c_first, q_recourse, T_mat, W_mat, demand', ...
        'x_lb', 0, 'x_ub', 80);

    % Newsvendor critical ratio: (p-c)/(p+h) = (8-3)/(8+1) ≈ 0.556
    % Optimal order ≈ 20 + 0.556*60 ≈ 53.3
    assert(x1 > 30 && x1 < 70, ...
        'Self-test: x1 = %.2f outside expected range [30, 70].', x1);

    % Objective should be reasonable
    assert(obj > -100 && obj < 100, ...
        'Self-test: objective = %.2f out of expected range.', obj);

    % Check feasibility: for each scenario, x + y_short - y_surplus ≈ demand
    max_violation = max(abs(x1 + x2(1,:)' - x2(2,:)' - demand));
    assert(max_violation < 1e-6, ...
        'Self-test: constraint violation = %.2e.', max_violation);

    fprintf('  two_stage_stochastic self-test PASSED (x*=%6.2f, obj=%8.4f).\n', x1, obj);
end
end
