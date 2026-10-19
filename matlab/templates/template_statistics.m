% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [results, figs, exitflag] = template_statistics(seed, cfg)
% TEMPLATE_STATISTICS Statistics model template - 2-group t-test. v3.0.0.
%   Generate two separated normal groups, test H0: mu1 = mu2.
%   Output: results(struct), figs(struct), exitflag(0=OK).
arguments
    seed (1,1) double {mustBeFinite} = 42
    cfg.data_path (1,:) char = fullfile(pwd, 'data')
    cfg.output_path (1,:) char = fullfile(pwd, 'results')
    cfg.figure_path (1,:) char = fullfile(pwd, 'figures')
    cfg.verbose (1,1) logical = true
    cfg.n1 (1,1) double {mustBePositive} = 50
    cfg.n2 (1,1) double {mustBePositive} = 50
    cfg.mu1 (1,1) double = 10.0
    cfg.mu2 (1,1) double = 11.5
    cfg.sigma1 (1,1) double {mustBePositive} = 2.0
    cfg.sigma2 (1,1) double {mustBePositive} = 2.0
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
    %% 1. Generate data: two groups with known separation
    if cfg.verbose
        fprintf('[%s] Step 1: Generating data...\n', datestr(now, 'HH:MM:SS'));
    end
    group1 = cfg.mu1 + cfg.sigma1 * randn(cfg.n1, 1);
    group2 = cfg.mu2 + cfg.sigma2 * randn(cfg.n2, 1);
    run_log.steps{end+1} = 'data_generated';

    %% 2. Descriptive statistics
    if cfg.verbose
        fprintf('[%s] Step 2: Computing descriptive statistics...\n', ...
            datestr(now, 'HH:MM:SS'));
    end
    results.desc = struct(...
        'mean1', mean(group1), 'std1', std(group1), ...
        'mean2', mean(group2), 'std2', std(group2), ...
        'n1', cfg.n1, 'n2', cfg.n2);
    run_log.steps{end+1} = 'descriptive_computed';

    %% 3. Two-sample t-test (unequal variance - Welch)
    if cfg.verbose
        fprintf('[%s] Step 3: Running Welch t-test...\n', ...
            datestr(now, 'HH:MM:SS'));
    end
    [h, p, ci, stats] = ttest2(group1, group2, 'Vartype', 'unequal');
    results.h_reject = h;
    results.p_value = p;
    results.ci = ci;
    results.t_stat = stats.tstat;
    results.df = stats.df;
    run_log.steps{end+1} = 'ttest_computed';

    %% 4. Effect size (Cohen's d)
    if cfg.verbose
        fprintf('[%s] Step 4: Computing effect size...\n', ...
            datestr(now, 'HH:MM:SS'));
    end
    pooled_sd = sqrt(((cfg.n1-1)*var(group1) + (cfg.n2-1)*var(group2)) / ...
        (cfg.n1 + cfg.n2 - 2));
    results.cohens_d = (results.desc.mean1 - results.desc.mean2) / pooled_sd;
    run_log.steps{end+1} = 'effect_size_computed';

    %% 5. Normality check (Shapiro-Wilk via Lilliefors)
    if cfg.verbose
        fprintf('[%s] Step 5: Checking normality...\n', ...
            datestr(now, 'HH:MM:SS'));
    end
    [~, p_norm1] = lillietest(group1);
    [~, p_norm2] = lillietest(group2);
    results.normality_p1 = p_norm1;
    results.normality_p2 = p_norm2;
    results.both_normal = (p_norm1 > 0.05) && (p_norm2 > 0.05);
    run_log.steps{end+1} = 'normality_checked';

    %% 6. Validation
    if cfg.verbose
        fprintf('[%s] Step 6: Validation...\n', datestr(now, 'HH:MM:SS'));
    end
    if results.h_reject ~= 1
        exitflag = -2;
        warning('t-test did not reject H0 despite known separation');
    end
    if results.p_value >= 0.05
        exitflag = -2;
    end
    if isnan(stats.tstat) || isinf(stats.tstat)
        exitflag = -3;
    end
    run_log.steps{end+1} = 'validated';

    %% 7. Export
    results_file = fullfile(cfg.output_path, 'results_statistics.mat');
    save(results_file, 'results');
    json_file = fullfile(cfg.output_path, 'results_statistics.json');
    fid = fopen(json_file, 'w');
    if fid > 0, fprintf(fid, '%s', jsonencode(results)); fclose(fid); end
    run_log.steps{end+1} = 'exported';

    %% 8. Visualization
    if cfg.verbose
        fprintf('[%s] Step 7: Visualization...\n', datestr(now, 'HH:MM:SS'));
    end
    fig = figure('Visible', 'off');
    subplot(1,2,1);
    boxplot([group1; group2], [ones(cfg.n1,1); 2*ones(cfg.n2,1)], ...
        'Labels', {'Group 1', 'Group 2'});
    ylabel('Value'); title('Boxplot Comparison');
    subplot(1,2,2);
    histogram(group1, 'FaceAlpha', 0.5, 'EdgeColor', 'none'); hold on;
    histogram(group2, 'FaceAlpha', 0.5, 'EdgeColor', 'none');
    xlabel('Value'); ylabel('Frequency');
    legend({'Group 1', 'Group 2'}, 'Location', 'best');
    title(sprintf('Distributions (p=%.4f)', results.p_value)); hold off;
    fig_file = fullfile(cfg.figure_path, 'statistics_ttest.png');
    print(fig, fig_file, '-dpng', '-r300');
    figs.ttest = fig;
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
    fprintf('=== template_statistics self-test ===\n');
    [r, ~, ef] = template_statistics(42, struct('verbose', false));
    assert(ef == 0, 'Should exit cleanly, got exitflag=%d', ef);
    assert(r.h_reject == 1, 'Should reject H0 for separated groups');
    assert(r.p_value < 0.05, 'p-value should be < 0.05, got %.4f', r.p_value);
    assert(isfield(r.desc, 'mean1'), 'Results should contain descriptive stats');
    assert(abs(r.cohens_d) > 0.3, 'Effect size should be non-trivial');
    disp('template_statistics self-test passed.');
end
end
