% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [results, exitflag] = solver_fallback_chain(obj_fun, x0, lb, ub, Aineq, bineq, opts)
% SOLVER_FALLBACK_CHAIN Fallback chain: fmincon -> ga -> particleswarm -> simulannealbnd. v3.0.0.
%   Each step: if exitflag<0 or constraint violation>tol, try next.
%   Output: results(struct with x_opt/fval/solver_used/history), exitflag.
arguments
    obj_fun function_handle
    x0 (:,1) double
    lb (:,1) double = []
    ub (:,1) double = []
    Aineq (:,:) double = []
    bineq (:,1) double = []
    opts.verbose (1,1) logical = true
    opts.tol_constraint (1,1) double = 1e-6
    opts.ga_generations (1,1) double = 50
    opts.ga_population (1,1) double = 30
    opts.swarm_size (1,1) double = 30
    opts.sa_max_iter (1,1) double = 200
    opts.seed (1,1) double = 42
end

rng(opts.seed, 'twister');
t0 = tic;
exitflag = 0;
results = struct();
results.history = {};

n_var = length(x0);
if isempty(lb), lb = -10 * ones(n_var, 1); end
if isempty(ub), ub = 10 * ones(n_var, 1); end

%% 1. fmincon (SQP)
if opts.verbose
    fprintf('[%s] Solver 1/4: fmincon (SQP)...\n', datestr(now, 'HH:MM:SS'));
end
try
    fmincon_opts = optimoptions('fmincon', 'Display', 'off', ...
        'Algorithm', 'sqp', 'MaxIterations', 200);
    [x_sol, f_sol, ef_sol, out_sol] = fmincon(obj_fun, x0, ...
        Aineq, bineq, [], [], lb, ub, [], fmincon_opts);
    constraint_violation = check_constraints(x_sol, lb, ub, Aineq, bineq);
    results.history{end+1} = struct('solver', 'fmincon', 'exitflag', ef_sol, ...
        'fval', f_sol, 'constraint_violation', constraint_violation);
    if ef_sol >= 0 && constraint_violation <= opts.tol_constraint
        results.x_opt = x_sol;
        results.fval = f_sol;
        results.solver_used = 'fmincon';
        results.solver_output = out_sol;
        results.fallback_count = 0;
        if opts.verbose
            fprintf('[%s] fmincon succeeded: f=%.4e, ef=%d\n', ...
                datestr(now, 'HH:MM:SS'), f_sol, ef_sol);
        end
    else
        if opts.verbose
            fprintf('[%s] fmincon failed: ef=%d, cv=%.2e. Falling back...\n', ...
                datestr(now, 'HH:MM:SS'), ef_sol, constraint_violation);
        end
        results.fallback_count = 1;
        try_fallback = true;
    end
catch ME_fmc
    results.history{end+1} = struct('solver', 'fmincon', 'exitflag', -99, ...
        'fval', Inf, 'constraint_violation', Inf, 'error', ME_fmc.message);
    try_fallback = true;
    if opts.verbose
        fprintf('[%s] fmincon error: %s. Falling back...\n', ...
            datestr(now, 'HH:MM:SS'), ME_fmc.message);
    end
end

%% 2. GA
if ~exist('try_fallback', 'var') || ~try_fallback
    try_fallback = false;
end
if try_fallback
    if opts.verbose
        fprintf('[%s] Solver 2/4: ga...\n', datestr(now, 'HH:MM:SS'));
    end
    try
        ga_opts = optimoptions('ga', 'Display', 'off', ...
            'MaxGenerations', opts.ga_generations, ...
            'PopulationSize', opts.ga_population);
        [x_sol2, f_sol2, ef_sol2, out_sol2] = ga(obj_fun, n_var, ...
            Aineq, bineq, [], [], lb, ub, [], ga_opts);
        cv2 = check_constraints(x_sol2, lb, ub, Aineq, bineq);
        results.history{end+1} = struct('solver', 'ga', 'exitflag', ef_sol2, ...
            'fval', f_sol2, 'constraint_violation', cv2);
        if ef_sol2 >= 0 && cv2 <= opts.tol_constraint
            results.x_opt = x_sol2;
            results.fval = f_sol2;
            results.solver_used = 'ga';
            results.solver_output = out_sol2;
            if opts.verbose
                fprintf('[%s] ga succeeded: f=%.4e, ef=%d\n', ...
                    datestr(now, 'HH:MM:SS'), f_sol2, ef_sol2);
            end
            try_fallback = false;
        else
            if opts.verbose
                fprintf('[%s] ga failed: ef=%d, cv=%.2e. Falling back...\n', ...
                    datestr(now, 'HH:MM:SS'), ef_sol2, cv2);
            end
            results.fallback_count = results.fallback_count + 1;
        end
    catch ME_ga
        results.history{end+1} = struct('solver', 'ga', 'exitflag', -99, ...
            'fval', Inf, 'constraint_violation', Inf, 'error', ME_ga.message);
        results.fallback_count = results.fallback_count + 1;
    end
end

%% 3. particleswarm
if try_fallback
    if opts.verbose
        fprintf('[%s] Solver 3/4: particleswarm...\n', ...
            datestr(now, 'HH:MM:SS'));
    end
    try
        ps_opts = optimoptions('particleswarm', 'Display', 'off', ...
            'SwarmSize', opts.swarm_size);
        [x_sol3, f_sol3, ef_sol3, out_sol3] = particleswarm(obj_fun, ...
            n_var, lb, ub, ps_opts);
        cv3 = check_constraints(x_sol3, lb, ub, Aineq, bineq);
        results.history{end+1} = struct('solver', 'particleswarm', ...
            'exitflag', ef_sol3, 'fval', f_sol3, 'constraint_violation', cv3);
        if ef_sol3 >= 0 && cv3 <= opts.tol_constraint
            results.x_opt = x_sol3;
            results.fval = f_sol3;
            results.solver_used = 'particleswarm';
            results.solver_output = out_sol3;
            if opts.verbose
                fprintf('[%s] particleswarm succeeded: f=%.4e, ef=%d\n', ...
                    datestr(now, 'HH:MM:SS'), f_sol3, ef_sol3);
            end
            try_fallback = false;
        else
            if opts.verbose
                fprintf('[%s] particleswarm failed: ef=%d, cv=%.2e. ...\n', ...
                    datestr(now, 'HH:MM:SS'), ef_sol3, cv3);
            end
            results.fallback_count = results.fallback_count + 1;
        end
    catch ME_ps
        results.history{end+1} = struct('solver', 'particleswarm', ...
            'exitflag', -99, 'fval', Inf, 'constraint_violation', Inf, ...
            'error', ME_ps.message);
        results.fallback_count = results.fallback_count + 1;
    end
end

%% 4. simulannealbnd
if try_fallback
    if opts.verbose
        fprintf('[%s] Solver 4/4: simulannealbnd...\n', ...
            datestr(now, 'HH:MM:SS'));
    end
    try
        sa_opts = optimoptions('simulannealbnd', 'Display', 'off', ...
            'MaxIterations', opts.sa_max_iter);
        [x_sol4, f_sol4, ef_sol4, out_sol4] = simulannealbnd(obj_fun, ...
            x0, lb, ub, sa_opts);
        cv4 = check_constraints(x_sol4, lb, ub, Aineq, bineq);
        results.history{end+1} = struct('solver', 'simulannealbnd', ...
            'exitflag', ef_sol4, 'fval', f_sol4, 'constraint_violation', cv4);
        results.x_opt = x_sol4;
        results.fval = f_sol4;
        results.solver_used = 'simulannealbnd';
        results.solver_output = out_sol4;
        if opts.verbose
            fprintf('[%s] simulannealbnd finished: f=%.4e, ef=%d\n', ...
                datestr(now, 'HH:MM:SS'), f_sol4, ef_sol4);
        end
        try_fallback = false;
    catch ME_sa
        results.history{end+1} = struct('solver', 'simulannealbnd', ...
            'exitflag', -99, 'fval', Inf, 'constraint_violation', Inf, ...
            'error', ME_sa.message);
        results.fallback_count = results.fallback_count + 1;
        exitflag = -1;
        results.error = 'All solvers failed.';
    end
end

if try_fallback && exitflag == 0
    exitflag = -2;
    results.error = 'All solvers exhausted without acceptable result.';
end

results.elapsed_sec = toc(t0);

%% Self-test
function self_test()
    fprintf('=== solver_fallback_chain self-test ===\n');
    obj = @(x) (1-x(1))^2 + 100*(x(2)-x(1)^2)^2;
    x0_st = [-1.2; 1.0];
    [r, ef] = solver_fallback_chain(obj, x0_st, [], [], [], [], ...
        struct('verbose', false, 'seed', 42));
    assert(ef == 0, 'Should succeed, got exitflag=%d', ef);
    assert(isfield(r, 'solver_used'), 'Should record solver_used');
    assert(~isempty(r.solver_used), 'Solver name should not be empty');
    assert(isfield(r, 'x_opt'), 'Should have optimal point');
    assert(isfield(r, 'fval'), 'Should have optimal value');
    assert(r.fval < 1e-2, 'Rosenbrock optimum should be near zero');
    fprintf('  Solver used: %s, fval=%.4e\n', r.solver_used, r.fval);
    disp('solver_fallback_chain self-test passed.');
end
end

function cv = check_constraints(x, lb, ub, Aineq, bineq)
    cv = 0;
    if ~isempty(lb)
        cv = cv + sum(max(lb - x(:), 0));
    end
    if ~isempty(ub)
        cv = cv + sum(max(x(:) - ub, 0));
    end
    if ~isempty(Aineq) && ~isempty(bineq)
        cv = cv + sum(max(Aineq * x(:) - bineq(:), 0));
    end
end
