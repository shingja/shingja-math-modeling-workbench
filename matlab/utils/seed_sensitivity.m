% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [results, exitflag] = seed_sensitivity(solver_func, cfg)
% SEED_SENSITIVITY Run solver with multiple seeds, compute stability metrics. v3.0.0.
%   Output: struct with median/IQR/CV of objective values.
%   is_stable = (cv < 0.05).
arguments
    solver_func function_handle
    cfg.seeds (1,:) double = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
    cfg.n_runs (1,1) double = 10
    cfg.verbose (1,1) logical = true
    cfg.output_path (1,:) char = fullfile(pwd, 'results')
end

rng(42, 'twister');
t0 = tic;
exitflag = 0;
results = struct();

if ~isfolder(cfg.output_path), mkdir(cfg.output_path); end

%% Validate seeds
if isempty(cfg.seeds) && cfg.n_runs > 0
    cfg.seeds = 1:cfg.n_runs;
elseif length(cfg.seeds) < cfg.n_runs
    cfg.seeds = cfg.seeds(1:min(length(cfg.seeds), cfg.n_runs));
end
n_runs = min(cfg.n_runs, length(cfg.seeds));

try
    %% 1. Run solver for each seed
    if cfg.verbose
        fprintf('[%s] Running %d seeds...\n', datestr(now, 'HH:MM:SS'), n_runs);
    end
    obj_values = zeros(n_runs, 1);
    seed_list = zeros(n_runs, 1);
    solver_names = cell(n_runs, 1);
    success_flags = false(n_runs, 1);
    for i = 1:n_runs
        s = cfg.seeds(i);
        seed_list(i) = s;
        try
            rng(s, 'twister');
            [val, solver] = solver_func();
            obj_values(i) = val;
            solver_names{i} = solver;
            success_flags(i) = true;
        catch ME
            obj_values(i) = NaN;
            solver_names{i} = 'FAILED';
            if cfg.verbose
                fprintf('[%s] Seed %d failed: %s\n', ...
                    datestr(now, 'HH:MM:SS'), s, ME.message);
            end
        end
    end
    results.seed_list = seed_list;
    results.obj_values = obj_values;
    results.solver_names = solver_names;
    results.success_flags = success_flags;
    results.n_success = sum(success_flags);
    results.n_total = n_runs;

    %% 2. Compute statistics on successful runs
    if results.n_success < 2
        exitflag = -2;
        results.median = NaN;
        results.iqr_val = NaN;
        results.cv = NaN;
        results.is_stable = false;
        results.error = sprintf('Insufficient successful runs: %d/%d', ...
            results.n_success, n_runs);
    else
        ok_vals = obj_values(success_flags);
        results.median = median(ok_vals);
        results.iqr_val = iqr(ok_vals);
        results.mean_val = mean(ok_vals);
        results.std_val = std(ok_vals);
        results.cv = results.std_val / (abs(results.mean_val) + eps);
        results.min_val = min(ok_vals);
        results.max_val = max(ok_vals);
        results.range_val = results.max_val - results.min_val;
        results.is_stable = (results.cv < 0.05);

        %% 3. Robustness check
        if results.cv >= 0.05
            exitflag = 1;
            if cfg.verbose
                fprintf('[%s] Warning: CV=%.4f >= 0.05, solution not seed-stable.\n', ...
                    datestr(now, 'HH:MM:SS'), results.cv);
            end
        else
            if cfg.verbose
                fprintf('[%s] OK: CV=%.4f, solution is seed-stable.\n', ...
                    datestr(now, 'HH:MM:SS'), results.cv);
            end
        end

        %% 4. Outlier detection (Grubbs-like: beyond 2*IQR from median)
        q1 = prctile(ok_vals, 25);
        q3 = prctile(ok_vals, 75);
        iqr_v = q3 - q1;
        lower_fence = q1 - 2 * iqr_v;
        upper_fence = q3 + 2 * iqr_v;
        results.outliers = ok_vals < lower_fence | ok_vals > upper_fence;
        results.n_outliers = sum(results.outliers);
    end

    %% 5. Export
    results_file = fullfile(cfg.output_path, 'seed_sensitivity.mat');
    save(results_file, 'results');
    json_file = fullfile(cfg.output_path, 'seed_sensitivity.json');
    fid = fopen(json_file, 'w');
    if fid > 0, fprintf(fid, '%s', jsonencode(results)); fclose(fid); end

catch ME
    exitflag = -1;
    results.error = ME.message;
end

results.elapsed_sec = toc(t0);

%% Self-test
function self_test()
    fprintf('=== seed_sensitivity self-test ===\n');
    % Solver that returns value with known seed-to-seed variance (Rosenbrock)
    sf = @() seed_solver_rosenbrock();
    [r, ef] = seed_sensitivity(sf, struct('verbose', false, 'n_runs', 10));
    assert(ef == 0 || ef == 1, 'Should succeed or warn, got ef=%d', ef);
    assert(isfield(r, 'median'), 'Should have median');
    assert(r.n_success >= 8, 'Most runs should succeed, got %d/%d', ...
        r.n_success, r.n_total);
    assert(~isnan(r.median), 'Median should not be NaN');
    assert(r.median >= 0, 'Median should be non-negative');
    fprintf('  Median=%.4e, IQR=%.4e, CV=%.4e, stable=%d\n', ...
        r.median, r.iqr_val, r.cv, r.is_stable);
    disp('seed_sensitivity self-test passed.');
end
end

function [val, solver_name] = seed_solver_rosenbrock()
    % Helper: optimize Rosenbrock with random start near [-1.2, 1.0]
    obj = @(x) (1 - x(1))^2 + 100 * (x(2) - x(1)^2)^2;
    x0 = [-1.2; 1.0] + 0.3 * randn(2, 1);
    opts = optimoptions('fmincon', 'Display', 'off', 'Algorithm', 'sqp');
    [~, fval, ef] = fmincon(obj, x0, [], [], [], [], [], [], [], opts);
    if ef <= 0
        val = NaN;
    else
        val = fval;
    end
    solver_name = 'fmincon-sqp';
end
