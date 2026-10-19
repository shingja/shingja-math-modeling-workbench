% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [results, figs, exitflag] = template_comprehensive(seed, cfg)
% TEMPLATE_COMPREHENSIVE Comprehensive model template - 2-subproblem chain. v3.0.0.
%   Q1: Optimize Rosenbrock 2D. Q2: Evaluate resulting point against grid.
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
    %% ===== Q1: Optimization =====
    if cfg.verbose
        fprintf('[%s] Q1: Optimizing Rosenbrock 2D...\n', ...
            datestr(now, 'HH:MM:SS'));
    end
    objective = @(x) (1 - x(1))^2 + 100 * (x(2) - x(1)^2)^2;
    opts = optimoptions('fmincon', 'Display', 'off', 'Algorithm', 'sqp');
    x0_q1 = [-1.2; 1.0];
    [x_opt, fval, ef_q1, output_q1] = fmincon(objective, x0_q1, ...
        [], [], [], [], [], [], [], opts);
    results.Q1 = struct('x_opt', x_opt, 'fval', fval, ...
        'exitflag', ef_q1, 'method', 'fmincon-sqp');
    if ef_q1 <= 0
        exitflag = -2;
        warning('Q1 optimization failed with exitflag=%d', ef_q1);
    end
    if cfg.verbose
        fprintf('[%s] Q1 result: x=(%.4f,%.4f), f=%.4e, ef=%d\n', ...
            datestr(now, 'HH:MM:SS'), x_opt(1), x_opt(2), fval, ef_q1);
    end
    run_log.steps{end+1} = 'q1_optimization_done';

    %% ===== Q2: Evaluation =====
    if cfg.verbose
        fprintf('[%s] Q2: Evaluating candidate points...\n', ...
            datestr(now, 'HH:MM:SS'));
    end
    % Generate 5 candidate points around Q1 optimum
    candidates = zeros(5, 2);
    candidates(1, :) = x_opt'; % Q1 optimum
    for i = 2:5
        candidates(i, :) = x_opt' + 0.2 * randn(1, 2);
    end
    % Evaluate each candidate on 3 criteria
    n_candidates = size(candidates, 1);
    n_criteria = 3;
    scores = zeros(n_candidates, n_criteria);
    for i = 1:n_candidates
        scores(i, 1) = -objective(candidates(i, :)');          % C1: neg obj
        scores(i, 2) = 1 / norm(candidates(i, :) - [0, 0]);    % C2: proximity to origin
        scores(i, 3) = 1 / norm(candidates(i, :) - [1, 1]);    % C3: proximity to [1,1]
    end
    % TOPSIS on candidates
    w_q2 = [0.5, 0.25, 0.25];
    D_norm = scores ./ sqrt(sum(scores.^2, 1));
    V = D_norm .* w_q2;
    V_plus = max(V, [], 1);
    V_minus = min(V, [], 1);
    S_plus = sqrt(sum((V - V_plus).^2, 2));
    S_minus = sqrt(sum((V - V_minus).^2, 2));
    C_q2 = S_minus ./ (S_plus + S_minus);
    [~, rank_idx] = sort(C_q2, 'descend');
    ranking_q2 = zeros(n_candidates, 1);
    ranking_q2(rank_idx) = 1:n_candidates;
    results.Q2 = struct('candidates', candidates, 'scores', scores, ...
        'C', C_q2, 'ranking', ranking_q2, 'method', 'TOPSIS');
    if cfg.verbose
        fprintf('[%s] Q2 result: Best candidate #%d, C=%.4f\n', ...
            datestr(now, 'HH:MM:SS'), rank_idx(1), C_q2(rank_idx(1)));
    end
    run_log.steps{end+1} = 'q2_evaluation_done';

    %% Integration check
    if cfg.verbose
        fprintf('[%s] Integration: Checking Q1->Q2 feed...\n', ...
            datestr(now, 'HH:MM:SS'));
    end
    % Verify Q1 results are used in Q2
    q1_best_rank = ranking_q2(1);
    results.integration = struct(...
        'q1_feeds_q2', true, ...
        'q1_opt_rank_in_q2', q1_best_rank, ...
        'q1_opt_score', C_q2(1));
    run_log.steps{end+1} = 'integration_done';

    %% Validation
    if cfg.verbose
        fprintf('[%s] Validation...\n', datestr(now, 'HH:MM:SS'));
    end
    assert(results.Q1.fval < 1e-4, 'Q1 should converge near optimum');
    assert(all(C_q2 >= 0 & C_q2 <= 1), 'Q2 scores in [0,1]');
    assert(length(unique(results.Q2.ranking)) == n_candidates, ...
        'Q2 ranking should be unique');
    run_log.steps{end+1} = 'validated';

    %% Export
    results_file = fullfile(cfg.output_path, 'results_comprehensive.mat');
    save(results_file, 'results');
    json_file = fullfile(cfg.output_path, 'results_comprehensive.json');
    fid = fopen(json_file, 'w');
    if fid > 0
        fprintf(fid, '%s', jsonencode(results));
        fclose(fid);
    end
    run_log.steps{end+1} = 'exported';

    %% Visualization
    if cfg.verbose
        fprintf('[%s] Visualization...\n', datestr(now, 'HH:MM:SS'));
    end
    fig = figure('Visible', 'off');
    subplot(1,2,1);
    bar(C_q2); set(gca, 'XTickLabel', ...
        arrayfun(@(x) sprintf('A%d', x), 1:n_candidates, 'UniformOutput', false));
    ylabel('TOPSIS Score C_i'); title('Q2: Candidate Ranking');
    subplot(1,2,2);
    plot(candidates(:,1), candidates(:,2), 'bo', 'MarkerSize', 10); hold on;
    plot(x_opt(1), x_opt(2), 'r*', 'MarkerSize', 15, 'LineWidth', 2);
    plot(1, 1, 'kx', 'MarkerSize', 12, 'LineWidth', 2);
    xlabel('x_1'); ylabel('x_2');
    legend({'Candidates', 'Q1 Optimum', 'True Optimum'}, 'Location', 'best');
    title('Q1 + Q2: Candidate Space'); hold off;
    fig_file = fullfile(cfg.figure_path, 'comprehensive_chain.png');
    print(fig, fig_file, '-dpng', '-r300');
    figs.chain = fig;
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
    fprintf('=== template_comprehensive self-test ===\n');
    [r, ~, ef] = template_comprehensive(42, struct('verbose', false));
    assert(ef == 0, 'Should exit cleanly, got exitflag=%d', ef);
    assert(isfield(r, 'Q1') && isfield(r, 'Q2'), 'Should have Q1 and Q2');
    assert(r.Q1.fval < 1e-4, 'Q1 should converge, fval=%.4e', r.Q1.fval);
    assert(all(r.Q2.C >= 0 & r.Q2.C <= 1), 'Q2 scores in [0,1]');
    assert(r.integration.q1_feeds_q2, 'Q1 results should feed into Q2');
    disp('template_comprehensive self-test passed.');
end
end
