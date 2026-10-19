% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [results, figs, exitflag] = template_simulation(seed, cfg)
% TEMPLATE_SIMULATION Simulation model template - Monte Carlo pi estimation. v3.0.0.
%   Estimate pi using Monte Carlo: points in unit circle / total points in square.
%   Output: results(struct), figs(struct), exitflag(0=OK).
arguments
    seed (1,1) double {mustBeFinite} = 42
    cfg.data_path (1,:) char = fullfile(pwd, 'data')
    cfg.output_path (1,:) char = fullfile(pwd, 'results')
    cfg.figure_path (1,:) char = fullfile(pwd, 'figures')
    cfg.verbose (1,1) logical = true
    cfg.n_samples (1,1) double {mustBePositive} = 100000
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
    %% 1. Generate random points in [-1,1]^2
    if cfg.verbose
        fprintf('[%s] Step 1: Generating %d random points...\n', ...
            datestr(now, 'HH:MM:SS'), cfg.n_samples);
    end
    x = 2 * rand(cfg.n_samples, 1) - 1;
    y = 2 * rand(cfg.n_samples, 1) - 1;
    run_log.steps{end+1} = 'points_generated';

    %% 2. Check if inside unit circle
    if cfg.verbose
        fprintf('[%s] Step 2: Computing inside-circle count...\n', ...
            datestr(now, 'HH:MM:SS'));
    end
    inside = (x.^2 + y.^2 <= 1);
    n_inside = sum(inside);
    results.n_inside = n_inside;
    results.n_total = cfg.n_samples;
    run_log.steps{end+1} = 'circle_count_computed';

    %% 3. Estimate pi
    if cfg.verbose
        fprintf('[%s] Step 3: Estimating pi...\n', datestr(now, 'HH:MM:SS'));
    end
    pi_est = 4 * n_inside / cfg.n_samples;
    results.pi_estimate = pi_est;
    results.pi_error = abs(pi_est - pi);
    run_log.steps{end+1} = 'pi_estimated';

    %% 4. Confidence interval using binomial proportion
    if cfg.verbose
        fprintf('[%s] Step 4: Computing confidence interval...\n', ...
            datestr(now, 'HH:MM:SS'));
    end
    p_hat = n_inside / cfg.n_samples;
    se_p = sqrt(p_hat * (1 - p_hat) / cfg.n_samples);
    z_alpha = 1.96;
    ci_low = 4 * (p_hat - z_alpha * se_p);
    ci_high = 4 * (p_hat + z_alpha * se_p);
    results.pi_ci = [ci_low, ci_high];
    results.pi_se = 4 * se_p;
    run_log.steps{end+1} = 'ci_computed';

    %% 5. Convergence analysis (sub-sample)
    if cfg.verbose
        fprintf('[%s] Step 5: Convergence analysis...\n', ...
            datestr(now, 'HH:MM:SS'));
    end
    batch_size = max(1000, floor(cfg.n_samples / 20));
    n_batches = floor(cfg.n_samples / batch_size);
    pi_batches = zeros(n_batches, 1);
    for b = 1:n_batches
        idx = 1:(b * batch_size);
        pi_batches(b) = 4 * sum(inside(idx)) / length(idx);
    end
    results.pi_convergence = pi_batches;
    results.is_converged = abs(pi_batches(end) - pi_batches(max(1, end-2))) < 0.01;
    run_log.steps{end+1} = 'convergence_analyzed';

    %% 6. Validation
    if cfg.verbose
        fprintf('[%s] Step 6: Validation...\n', datestr(now, 'HH:MM:SS'));
    end
    if pi_est < 3.0 || pi_est > 3.2
        exitflag = -3;
        warning('Pi estimate %.4f out of expected range [3.0, 3.2]', pi_est);
    end
    if ~results.is_converged
        exitflag = -2;
        warning('Pi estimate may not have converged');
    end
    run_log.steps{end+1} = 'validated';

    %% 7. Export
    results_file = fullfile(cfg.output_path, 'results_simulation.mat');
    save(results_file, 'results');
    json_file = fullfile(cfg.output_path, 'results_simulation.json');
    fid = fopen(json_file, 'w');
    if fid > 0
        safe_r = results;
        safe_r.pi_convergence = safe_r.pi_convergence(1:5:end);
        fprintf(fid, '%s', jsonencode(safe_r));
        fclose(fid);
    end
    run_log.steps{end+1} = 'exported';

    %% 8. Visualization
    if cfg.verbose
        fprintf('[%s] Step 7: Visualization...\n', datestr(now, 'HH:MM:SS'));
    end
    fig = figure('Visible', 'off');
    subplot(1,2,1);
    idx_plot = randperm(cfg.n_samples, min(5000, cfg.n_samples));
    plot(x(idx_plot(~inside(idx_plot))), y(idx_plot(~inside(idx_plot))), ...
        'b.', 'MarkerSize', 2); hold on;
    plot(x(idx_plot(inside(idx_plot))), y(idx_plot(inside(idx_plot))), ...
        'r.', 'MarkerSize', 2);
    theta = linspace(0, 2*pi, 200);
    plot(cos(theta), sin(theta), 'k-', 'LineWidth', 1);
    axis equal; xlabel('x'); ylabel('y');
    title(sprintf('MC: \\pi_{est}=%.4f', pi_est));
    legend({'Outside', 'Inside', 'Circle'}, 'Location', 'best'); hold off;
    subplot(1,2,2);
    plot(batch_size * (1:n_batches), pi_batches, 'b-', 'LineWidth', 1.5);
    hold on; yline(pi, 'r--', 'LineWidth', 1);
    xlabel('Samples'); ylabel('\pi estimate');
    title('Convergence'); hold off;
    fig_file = fullfile(cfg.figure_path, 'simulation_monte_carlo.png');
    print(fig, fig_file, '-dpng', '-r300');
    figs.mc = fig;
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
    fprintf('=== template_simulation self-test ===\n');
    cfg_st = struct('verbose', false, 'n_samples', 50000);
    [r, ~, ef] = template_simulation(42, cfg_st);
    assert(ef == 0, 'Should exit cleanly, got exitflag=%d', ef);
    assert(r.pi_estimate >= 3.0 && r.pi_estimate <= 3.2, ...
        'Pi estimate %.4f should be in [3.0, 3.2]', r.pi_estimate);
    assert(abs(r.pi_error) < 0.05, 'Pi error should be small, got %.4f', ...
        r.pi_error);
    assert(r.n_inside > 0 && r.n_inside < r.n_total, ...
        'Inside count should be between 0 and total');
    disp('template_simulation self-test passed.');
end
end
