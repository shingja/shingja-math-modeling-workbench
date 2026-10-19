% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [pareto_x, pareto_f, swept, exitflag] = epsilon_constraint(f_primary, f_secondary, bounds, options)
%% EPSILONCONSTRAINT Epsilon-constraint method for multi-objective optimization.
%  Converts a multi-objective problem into a series of single-objective
%  subproblems: optimize f_primary(x) subject to f_secondary_k(x) <= eps_k.
%  Sweeps epsilon to generate a Pareto front approximation.
%  Paradigm: PARADIGM-0602
%  Category: MCDM
%  Version: v3.0.0
%  Reference: Haimes, Y.Y., Lasdon, L.S. & Wismer, D.A. (1971) On a
%             bicriterion formulation of the problems of integrated
%             system identification and system optimization. IEEE
%             Transactions on Systems, Man, and Cybernetics, 1(3), 296-297.
%             Mavrotas, G. (2009) Effective implementation of the
%             epsilon-constraint method in multi-objective mathematical
%             programming problems. Applied Mathematics and Computation,
%             213(2), 455-465. DOI: 10.1016/j.amc.2009.03.037.
%
%  Input:
%      f_primary   - Function handle f(x) -> scalar (objective to optimize)
%      f_secondary - Function handle g(x) -> [1 x k] vector (k constraints)
%      bounds      - [lb, ub] per variable (n_vars x 2)
%
%  Options:
%      options.n_eps    - Number of epsilon grid points (default: 20)
%      options.eps_min  - Lower bound for epsilon grid (auto if empty)
%      options.eps_max  - Upper bound for epsilon grid (auto if empty)
%      options.eps_grid - Manually specify epsilon grid points (overrides auto)
%      options.solver    - 'fmincon' (default) | 'direct_search' | 'grid_search'
%      options.seed      - RNG seed (default: 42)
%
%  Output:
%      pareto_x  - Pareto-optimal design points (n_pareto x n_vars)
%      pareto_f  - Pareto-optimal objective values (n_pareto x 1+k)
%      swept     - Structure with eps_grid, primary_vals, secondary_vals
%      exitflag  - 1 = success, -1 = no feasible solutions found

arguments
    f_primary (1,1) function_handle
    f_secondary (1,1) function_handle
    bounds (:, 2) double
    options.n_eps (1,1) double {mustBeInteger, mustBePositive} = 20
    options.eps_min (1,:) double = []
    options.eps_max (1,:) double = []
    options.eps_grid (:, :) double = []
    options.solver char {mustBeMember(options.solver, {'fmincon','direct_search','grid_search'})} = 'fmincon'
    options.seed (1,1) double = 42
end

rng(options.seed, 'twister');
exitflag = 1;

nvars = size(bounds, 1);
lb = bounds(:, 1)';
ub = bounds(:, 2)';
x0 = (lb + ub) / 2;  % initial guess at midpoint

%% Step 1: Determine epsilon bounds if not provided
if isempty(options.eps_grid)
    % Compute payoff table: optimize each objective individually
    % First, optimize f_primary alone (ignore secondary)
    obj_primary_only = @(x) f_primary(x);
    [~, f_prim_min] = optimize_single(obj_primary_only, x0, lb, ub);

    % Optimize each secondary objective individually
    n_sec = length(f_secondary(x0));
    f_sec_utopia = zeros(1, n_sec);
    f_sec_nadir = zeros(1, n_sec);

    for k = 1:n_sec
        % k-th secondary as sole objective (minimize)
        f_sec_k = @(x) f_secondary_wrapper(x, k, f_secondary);
        [~, fk_min] = optimize_single(f_sec_k, x0, lb, ub);
        f_sec_utopia(k) = fk_min;

        % To estimate nadir: maximize by minimizing negative
        f_neg = @(x) -f_secondary_wrapper(x, k, f_secondary);
        [~, neg_fk] = optimize_single(f_neg, x0, lb, ub);
        f_sec_nadir(k) = -neg_fk;
    end

    if isempty(options.eps_min)
        eps_min = f_sec_utopia;
    else
        eps_min = options.eps_min;
    end

    if isempty(options.eps_max)
        eps_max = f_sec_nadir;
    else
        eps_max = options.eps_max;
    end

    % Generate epsilon grid
    n_eps = options.n_eps;
    eps_grid = zeros(n_eps, n_sec);
    for k = 1:n_sec
        eps_grid(:, k) = linspace(eps_min(k), eps_max(k), n_eps)';
    end
else
    eps_grid = options.eps_grid;
    n_eps = size(eps_grid, 1);
    n_sec = size(eps_grid, 2);
end

%% Step 2: Sweep epsilon values
pareto_x = [];
pareto_f = [];
primary_vals = zeros(n_eps, 1);
secondary_vals = zeros(n_eps, n_sec);
feasible_mask = false(n_eps, 1);

for i_eps = 1:n_eps
    eps_i = eps_grid(i_eps, :);

    % Build constrained problem: min f_primary s.t. f_secondary <= eps_i
    obj_fun = @(x) f_primary(x);

    nonlcon = @(x) secondary_constraint(x, f_secondary, eps_i);

    % Initial guess: random restart within bounds
    x0_i = lb + (ub - lb) .* rand(1, nvars);

    [x_opt, f_opt, feasible] = optimize_constrained(obj_fun, nonlcon, x0_i, lb, ub);

    if feasible
        f_sec_opt = f_secondary(x_opt);
        primary_vals(i_eps) = f_opt;
        secondary_vals(i_eps, :) = f_sec_opt;
        feasible_mask(i_eps) = true;

        % Check for duplicates / dominance
        Pareto_candidate_f = [f_opt, f_sec_opt];
        if isempty(pareto_f)
            pareto_x = [pareto_x; x_opt];
            pareto_f = [pareto_f; Pareto_candidate_f];
        else
            % Only keep non-dominated points
            all_f = [pareto_f; Pareto_candidate_f];
            all_x = [pareto_x; x_opt];
            [all_f, all_x] = filter_pareto(all_f, all_x);
            pareto_f = all_f;
            pareto_x = all_x;
        end
    end
end

%% Step 3: Package results
swept = struct();
swept.eps_grid = eps_grid;
swept.primary_vals = primary_vals;
swept.secondary_vals = secondary_vals;
swept.n_feasible = sum(feasible_mask);
swept.feasible_mask = feasible_mask;

if isempty(pareto_f)
    exitflag = -1;
    warning('EPSILONCONSTRAINT:NoFeasible', ...
        'No feasible solutions found across all epsilon values.');
else
    % Sort Pareto front by first objective
    [~, sort_idx] = sort(pareto_f(:, 1));
    pareto_f = pareto_f(sort_idx, :);
    pareto_x = pareto_x(sort_idx, :);
end

%% Nested: Filter to non-dominated set
function [f_nd, x_nd] = filter_pareto(F, X)
    n_pts = size(F, 1);
    dominated = false(n_pts, 1);
    for i = 1:n_pts
        for j = 1:n_pts
            if i ~= j
                if all(F(j, :) <= F(i, :)) && any(F(j, :) < F(i, :))
                    dominated(i) = true;
                    break;
                end
            end
        end
    end
    f_nd = F(~dominated, :);
    x_nd = X(~dominated, :);
end

%% Nested: Secondary objective wrapper
function val = f_secondary_wrapper(x, k, f_sec)
    all_vals = f_sec(x);
    val = all_vals(k);
end

%% Nested: Single-objective optimization
function [x_opt, f_opt] = optimize_single(fun, x0, lb, ub)
    opts = optimoptions('fmincon', 'Display', 'off', 'Algorithm', 'sqp');
    [x_opt, f_opt] = fmincon(fun, x0, [], [], [], [], lb, ub, [], opts);
end

%% Nested: Constrained optimization
function [x_opt, f_opt, feasible] = optimize_constrained(fun, nonlcon, x0, lb, ub)
    opts = optimoptions('fmincon', 'Display', 'off', 'Algorithm', 'sqp', ...
        'ConstraintTolerance', 1e-6);
    [x_opt, f_opt, flag] = fmincon(fun, x0, [], [], [], [], lb, ub, nonlcon, opts);
    feasible = (flag > 0);
end

%% Nested: Nonlinear constraint for secondary objectives
function [c, ceq] = secondary_constraint(x, f_sec, eps_val)
    g = f_sec(x);
    c = g(:) - eps_val(:);  % g(x) <= eps
    ceq = [];
end

%% Self-test
function self_test()
    % 2-objective problem: min f1 = x1^2 + x2^2, min f2 = (x1-2)^2 + (x2-2)^2
    f1 = @(x) x(1)^2 + x(2)^2;
    f2 = @(x) [(x(1)-2)^2 + (x(2)-2)^2];
    bnds = [-5, 5; -5, 5];

    [px, pf, swept_info, ef] = epsilon_constraint(f1, f2, bnds, ...
        'n_eps', 15, 'seed', 42);

    assert(ef == 1, 'Self-test 1: exitflag should be 1, got %d.', ef);
    assert(size(pf, 1) >= 2, ...
        'Self-test 1: expected at least 2 Pareto points, got %d.', size(pf, 1));
    assert(swept_info.n_feasible >= 2, ...
        'Self-test 1: expected at least 2 feasible solutions, got %d.', swept_info.n_feasible);

    % Pareto front should span a range
    f1_range = max(pf(:, 1)) - min(pf(:, 1));
    assert(f1_range > 1e-4, ...
        'Self-test 2: Pareto front should have non-zero range in f1, got %.6f.', f1_range);

    % All f1 and f2 values should be non-negative (by problem structure)
    assert(all(pf(:, 1) >= -1e-10), ...
        'Self-test 3: f1 should be non-negative (squared distance).');
    assert(all(pf(:, 2) >= -1e-10), ...
        'Self-test 3: f2 should be non-negative (squared distance).');

    % Pareto front should be sorted by f1
    for kk = 2:size(pf, 1)
        assert(pf(kk, 1) >= pf(kk-1, 1) - 1e-10, ...
            'Self-test 4: Pareto front not sorted by f1.');
    end

    % Test 2-objective without secondary handle
    f2_direct = @(x) [(x(1)-2)^2 + (x(2)-2)^2];
    [px2, pf2, ~, ef2] = epsilon_constraint(f1, f2_direct, bnds, ...
        'n_eps', 10, 'seed', 123);

    assert(ef2 == 1, 'Self-test 5: second test should succeed.');
    assert(size(pf2, 1) >= 1, 'Self-test 5: should have at least 1 point.');

    fprintf('EPSILONCONSTRAINT self-test PASSED (5 tests, all assertions passed).\n');
end
end
