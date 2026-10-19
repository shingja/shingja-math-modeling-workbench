% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [results, figs, exitflag] = template_evaluation(seed, cfg)
% TEMPLATE_EVALUATION Evaluation model template - TOPSIS 3x4. v3.0.0.
%   3 alternatives x 4 criteria TOPSIS evaluation.
%   Output: results(struct), figs(struct), exitflag(0=OK).
arguments
    seed (1,1) double {mustBeFinite} = 42
    cfg.data_path (1,:) char = fullfile(pwd, 'data')
    cfg.output_path (1,:) char = fullfile(pwd, 'results')
    cfg.figure_path (1,:) char = fullfile(pwd, 'figures')
    cfg.verbose (1,1) logical = true
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
    %% 1. Data: 3 alternatives x 4 criteria (all benefit-type)
    if cfg.verbose
        fprintf('[%s] Step 1: Building evaluation matrix...\n', ...
            datestr(now, 'HH:MM:SS'));
    end
    D = [8.5, 92, 0.85, 7.2;
         7.0, 88, 0.92, 6.8;
         9.0, 85, 0.78, 8.1];
    alt_names = {'A1', 'A2', 'A3'};
    crit_names = {'C1_Quality', 'C2_Score', 'C3_Ratio', 'C4_Delivery'};
    crit_types = [1, 1, 1, 1]; % 1=benefit
    weights = [0.3, 0.3, 0.2, 0.2];
    [m, n] = size(D);
    run_log.steps{end+1} = 'data_loaded';

    %% 2. Normalize (vector normalization)
    if cfg.verbose
        fprintf('[%s] Step 2: Normalizing decision matrix...\n', ...
            datestr(now, 'HH:MM:SS'));
    end
    D_norm = D ./ sqrt(sum(D.^2, 1));
    run_log.steps{end+1} = 'normalized';

    %% 3. Weighted normalized matrix
    if cfg.verbose
        fprintf('[%s] Step 3: Computing weighted normalized matrix...\n', ...
            datestr(now, 'HH:MM:SS'));
    end
    V = D_norm .* weights;
    run_log.steps{end+1} = 'weighted';

    %% 4. Positive/negative ideal solutions
    V_plus = max(V, [], 1);
    V_minus = min(V, [], 1);
    run_log.steps{end+1} = 'ideal_solutions';

    %% 5. Distances
    if cfg.verbose
        fprintf('[%s] Step 4: Computing distances...\n', datestr(now, 'HH:MM:SS'));
    end
    S_plus = sqrt(sum((V - V_plus).^2, 2));
    S_minus = sqrt(sum((V - V_minus).^2, 2));
    run_log.steps{end+1} = 'distances';

    %% 6. Closeness coefficients & ranking
    if cfg.verbose
        fprintf('[%s] Step 5: Computing closeness coefficients...\n', ...
            datestr(now, 'HH:MM:SS'));
    end
    C = S_minus ./ (S_plus + S_minus);
    [C_sorted, idx] = sort(C, 'descend');
    ranking = zeros(m, 1);
    ranking(idx) = 1:m;
    results.D = D;
    results.C = C;
    results.ranking = ranking;
    results.alt_names = alt_names;
    results.crit_names = crit_names;
    run_log.steps{end+1} = 'computed';

    %% 7. Validation
    if cfg.verbose
        fprintf('[%s] Step 6: Validation...\n', datestr(now, 'HH:MM:SS'));
    end
    assert(all(C >= 0 & C <= 1), 'Closeness coefficients out of [0,1]');
    assert(length(unique(ranking)) == m, 'Ranking should be unique');
    if sum(abs(diff(C_sorted))) < 1e-10
        exitflag = -3;
        warning('Rankings may not be well-separated');
    else
        exitflag = 0;
    end
    run_log.steps{end+1} = 'validated';

    %% 8. Export
    results_file = fullfile(cfg.output_path, 'results_evaluation.mat');
    save(results_file, 'results');
    json_file = fullfile(cfg.output_path, 'results_evaluation.json');
    fid = fopen(json_file, 'w');
    if fid > 0, fprintf(fid, '%s', jsonencode(results)); fclose(fid); end
    run_log.steps{end+1} = 'exported';

    %% 9. Visualization
    if cfg.verbose
        fprintf('[%s] Step 7: Visualization...\n', datestr(now, 'HH:MM:SS'));
    end
    fig = figure('Visible', 'off');
    subplot(1,2,1);
    bar(C); set(gca, 'XTickLabel', alt_names);
    ylabel('Closeness Coefficient C_i'); title('TOPSIS Scores');
    subplot(1,2,2);
    heatmap(crit_names, alt_names, D, 'Title', 'Decision Matrix');
    fig_file = fullfile(cfg.figure_path, 'evaluation_topsis.png');
    print(fig, fig_file, '-dpng', '-r300');
    figs.topsis = fig;
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
    fprintf('=== template_evaluation self-test ===\n');
    [r, ~, ef] = template_evaluation(42, struct('verbose', false));
    assert(ef == 0, 'Should exit cleanly, got exitflag=%d', ef);
    assert(isfield(r, 'C'), 'Results should contain closeness coefficients');
    assert(all(r.C >= 0 & r.C <= 1), 'C values in [0,1]');
    assert(length(unique(r.ranking)) == length(r.ranking), 'Ranking should be unique');
    assert(r.ranking(r.C == max(r.C)) == 1, 'Best alternative should rank #1');
    disp('template_evaluation self-test passed.');
end
end
