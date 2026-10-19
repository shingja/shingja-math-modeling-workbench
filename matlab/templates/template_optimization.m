% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [results, figs, exitflag] = template_optimization(seed, cfg)
% TEMPLATE_OPTIMIZATION Optimization model template - Rosenbrock 2D. v3.0.0.
%   Minimize f(x1,x2) = (1-x1)^2 + 100*(x2 - x1^2)^2.
%   Output: results(struct), figs(struct), exitflag(0=OK).
arguments
    seed (1,1) double {mustBeFinite} = 42
    cfg.data_path (1,:) char = fullfile(pwd, 'data')
    cfg.output_path (1,:) char = fullfile(pwd, 'results')
    cfg.figure_path (1,:) char = fullfile(pwd, 'figures')
    cfg.verbose (1,1) logical = true
    cfg.x0 (:,1) double = [-1.2; 1.0]
end
rng(seed, 'twister');
t0 = tic;
exitflag = 0;
results = struct();
figs = struct();

if ~isfolder(cfg.output_path), mkdir(cfg.output_path); end
if ~isfolder(cfg.figure_path), mkdir(cfg.figure_path); end

run_log = struct('seed', seed, 'start_time', datetime, 'steps', {{}});

try
    %% 1. Problem definition
    if cfg.verbose
        fprintf('[%s] Step 1: Defining optimization problem (Rosenbrock 2D)...\n', ...
            datestr(now, 'HH:MM:SS'));
    end
    objective = @(x) (1 - x(1))^2 + 100 * (x(2) - x(1)^2)^2;
    run_log.steps{end+1} = 'problem_defined';

    %% 2. Setup solver options
    if cfg.verbose
        fprintf('[%s] Step 2: Setting up fmincon options...\n', ...
            datestr(now, 'HH:MM:SS'));
    end
    opts = optimoptions('fmincon', 'Display', 'off', ...
        'Algorithm', 'sqp', 'SpecifyObjectiveGradient', false);
    run_log.steps{end+1} = 'solver_setup';

    %% 3. Solve
    if cfg.verbose
        fprintf('[%s] Step 3: Running fmincon...\n', datestr(now, 'HH:MM:SS'));
    end
    [x_opt, fval, exitflag_solver, output] = fmincon(objective, cfg.x0, ...
        [], [], [], [], [], [], [], opts);
    results.x_opt = x_opt;
    results.fval = fval;
    results.solver_output = output;
    results.solver_exitflag = exitflag_solver;
    run_log.steps{end+1} = 'solved';

    %% 4. Post-validation
    if cfg.verbose
        fprintf('[%s] Step 4: Post-validation...\n', datestr(now, 'HH:MM:SS'));
    end
    dist_to_opt = norm(x_opt(:) - [1; 1]);
    results.dist_to_optimum = dist_to_opt;
    results.is_converged = dist_to_opt < 1e-3;
    results.residual = abs(fval);
    if exitflag_solver <= 0
        exitflag = -2;
        warning('Solver did not converge. Exitflag=%d', exitflag_solver);
    end
    run_log.steps{end+1} = 'post_validated';

    %% 5. Export results
    results_file = fullfile(cfg.output_path, 'results_optimization.mat');
    save(results_file, 'results');
    json_file = fullfile(cfg.output_path, 'results_optimization.json');
    fid = fopen(json_file, 'w');
    if fid > 0
        safe_results = results;
        safe_results.solver_output = rmfield(safe_results.solver_output, 'algorithm');
        fprintf(fid, '%s', jsonencode(safe_results));
        fclose(fid);
    end
    run_log.steps{end+1} = 'results_exported';

    %% 6. Visualization
    if cfg.verbose
        fprintf('[%s] Step 6: Visualization...\n', datestr(now, 'HH:MM:SS'));
    end
    fig = figure('Visible', 'off');
    [X1, X2] = meshgrid(-2:0.05:2, -1:0.05:3);
    Z = (1 - X1).^2 + 100 * (X2 - X1.^2).^2;
    contour(X1, X2, log10(Z + 1), 30); hold on;
    plot(x_opt(1), x_opt(2), 'r*', 'MarkerSize', 12, 'LineWidth', 2);
    plot(cfg.x0(1), cfg.x0(2), 'bo', 'MarkerSize', 8, 'LineWidth', 1.5);
    xlabel('x_1'); ylabel('x_2');
    title(sprintf('Rosenbrock Opt: (%.4f, %.4f), f=%.4e', x_opt(1), x_opt(2), fval));
    legend({'log_{10}(f+1)', 'Optimum', 'Start'}, 'Location', 'best');
    colorbar; hold off;
    fig_file = fullfile(cfg.figure_path, 'optimization_contour.png');
    print(fig, fig_file, '-dpng', '-r300');
    figs.contour = fig;
    run_log.steps{end+1} = 'viz_done';

catch ME
    exitflag = -1;
    run_log.error = ME.message;
end

run_log.end_time = datetime;
run_log.elapsed_sec = toc(t0);
run_log.exitflag = exitflag;
log_mat = fullfile(cfg.output_path, 'run_log.mat');
save(log_mat, 'run_log');
log_json = fullfile(cfg.output_path, 'run_log.json');
fid = fopen(log_json, 'w');
if fid > 0, fprintf(fid, '%s', jsonencode(run_log)); fclose(fid); end

%% Self-test
function self_test()
    fprintf('=== template_optimization self-test ===\n');
    [r, ~, ef] = template_optimization(42, struct('verbose', false));
    assert(ef == 0, 'Should exit cleanly, got exitflag=%d', ef);
    assert(isfield(r, 'x_opt'), 'Results should contain x_opt');
    assert(norm(r.x_opt(:) - [1; 1]) < 1e-2, ...
        'Optimum should be near [1,1], got [%.4f, %.4f]', r.x_opt(1), r.x_opt(2));
    assert(r.fval < 1e-6, 'Function value should be near zero, got %.4e', r.fval);
    assert(r.is_converged, 'Solver should converge');
    disp('template_optimization self-test passed.');
end
end
