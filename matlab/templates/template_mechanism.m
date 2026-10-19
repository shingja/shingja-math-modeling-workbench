% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [results, figs, exitflag] = template_mechanism(seed, cfg)
% TEMPLATE_MECHANISM Mechanism model template - Lotka-Volterra ODE. v3.0.0.
%   dx/dt = alpha*x - beta*x*y, dy/dt = delta*x*y - gamma*y.
%   Output: results(struct), figs(struct), exitflag(0=OK).
arguments
    seed (1,1) double {mustBeFinite} = 42
    cfg.data_path (1,:) char = fullfile(pwd, 'data')
    cfg.output_path (1,:) char = fullfile(pwd, 'results')
    cfg.figure_path (1,:) char = fullfile(pwd, 'figures')
    cfg.verbose (1,1) logical = true
    cfg.tspan (1,2) double = [0, 30]
    cfg.init_cond (1,2) double = [10, 2]
    cfg.alpha (1,1) double = 1.0
    cfg.beta (1,1) double = 0.1
    cfg.delta (1,1) double = 0.02
    cfg.gamma (1,1) double = 0.5
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
    %% 1. Define ODE system
    if cfg.verbose
        fprintf('[%s] Step 1: Defining Lotka-Volterra ODE...\n', ...
            datestr(now, 'HH:MM:SS'));
    end
    lv_ode = @(t, z) [
        cfg.alpha * z(1) - cfg.beta * z(1) * z(2);
        cfg.delta * z(1) * z(2) - cfg.gamma * z(2)
    ];
    run_log.steps{end+1} = 'ode_defined';

    %% 2. Solve ODE
    if cfg.verbose
        fprintf('[%s] Step 2: Solving ODE via ode45...\n', ...
            datestr(now, 'HH:MM:SS'));
    end
    odeset_opts = odeset('RelTol', 1e-6, 'AbsTol', 1e-8);
    [T_sol, Z_sol] = ode45(lv_ode, cfg.tspan, cfg.init_cond, odeset_opts);
    results.T = T_sol;
    results.X = Z_sol(:, 1);
    results.Y = Z_sol(:, 2);
    run_log.steps{end+1} = 'ode_solved';

    %% 3. Compute derived quantities
    if cfg.verbose
        fprintf('[%s] Step 3: Computing derived quantities...\n', ...
            datestr(now, 'HH:MM:SS'));
    end
    [~, idx_max] = max(Z_sol(:, 1));
    results.prey_peak_time = T_sol(idx_max);
    results.prey_peak_value = Z_sol(idx_max, 1);
    results.predator_peak_value = max(Z_sol(:, 2));
    [~, idx_min] = min(Z_sol(100:end, 1));
    results.oscillation_amplitude = max(Z_sol(100:end, 1)) - min(Z_sol(100:end, 1));
    results.period_estimate = estimate_period(T_sol, Z_sol(:, 1));
    % Verify oscillation: predator and prey should both vary
    range_prey = max(Z_sol(:, 1)) - min(Z_sol(:, 1));
    range_pred = max(Z_sol(:, 2)) - min(Z_sol(:, 2));
    run_log.steps{end+1} = 'derived_computed';

    %% 4. Validation
    if cfg.verbose
        fprintf('[%s] Step 4: Validation...\n', datestr(now, 'HH:MM:SS'));
    end
    has_oscillation = (range_prey > 1) && (range_pred > 1);
    results.has_oscillation = has_oscillation;
    if ~has_oscillation
        exitflag = -2;
        warning('No clear predator-prey oscillation detected');
    end
    % Conservation-ish check: neither population should go negative
    assert(all(Z_sol(:, 1) >= 0) && all(Z_sol(:, 2) >= 0), ...
        'Populations must be non-negative');
    run_log.steps{end+1} = 'validated';

    %% 5. Export
    results_file = fullfile(cfg.output_path, 'results_mechanism.mat');
    save(results_file, 'results');
    json_file = fullfile(cfg.output_path, 'results_mechanism.json');
    fid = fopen(json_file, 'w');
    if fid > 0
        safe_r = results;
        safe_r.T = safe_r.T(1:10:end);
        safe_r.X = safe_r.X(1:10:end);
        safe_r.Y = safe_r.Y(1:10:end);
        fprintf(fid, '%s', jsonencode(safe_r));
        fclose(fid);
    end
    run_log.steps{end+1} = 'exported';

    %% 6. Visualization
    if cfg.verbose
        fprintf('[%s] Step 5: Visualization...\n', datestr(now, 'HH:MM:SS'));
    end
    fig = figure('Visible', 'off');
    subplot(1,2,1);
    plot(T_sol, Z_sol(:, 1), 'b-', 'LineWidth', 2); hold on;
    plot(T_sol, Z_sol(:, 2), 'r-', 'LineWidth', 2);
    xlabel('Time'); ylabel('Population');
    legend({'Prey', 'Predator'}, 'Location', 'best');
    title('Lotka-Volterra Dynamics');
    subplot(1,2,2);
    plot(Z_sol(:, 1), Z_sol(:, 2), 'k-', 'LineWidth', 1.5);
    xlabel('Prey'); ylabel('Predator');
    title('Phase Portrait'); hold off;
    fig_file = fullfile(cfg.figure_path, 'mechanism_lotka_volterra.png');
    print(fig, fig_file, '-dpng', '-r300');
    figs.lv = fig;
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
    fprintf('=== template_mechanism self-test ===\n');
    [r, ~, ef] = template_mechanism(42, struct('verbose', false));
    assert(ef == 0, 'Should exit cleanly, got exitflag=%d', ef);
    assert(r.has_oscillation, 'Should detect predator-prey oscillation');
    assert(isfield(r, 'X') && isfield(r, 'Y'), 'Results should contain X, Y');
    assert(r.prey_peak_value > 0, 'Prey peak should be positive');
    assert(r.predator_peak_value > 0, 'Predator peak should be positive');
    disp('template_mechanism self-test passed.');
end
end

function per = estimate_period(T, X)
    % Simple period estimation via zero-crossings of detrended signal
    X_dt = X - mean(X);
    crossings = find(diff(sign(X_dt)) > 0);
    if length(crossings) >= 2
        per = mean(diff(T(crossings)));
    else
        per = NaN;
    end
end
