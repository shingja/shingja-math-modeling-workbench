% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [results, figs, exitflag] = template_graph(seed, cfg)
% TEMPLATE_GRAPH Graph model template - 4-node shortest path. v3.0.0.
%   Compute shortest path on weighted directed graph with 4 nodes.
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
    %% 1. Define graph adjacency matrix (4 nodes)
    if cfg.verbose
        fprintf('[%s] Step 1: Building 4-node graph...\n', ...
            datestr(now, 'HH:MM:SS'));
    end
    % Node 1: start, Node 4: target
    % Weights: w12=2, w13=5, w23=1, w24=4, w34=1
    s = [1, 1, 2, 2, 3];
    t = [2, 3, 3, 4, 4];
    w = [2, 5, 1, 4, 1];
    n_nodes = 4;
    run_log.steps{end+1} = 'graph_defined';

    %% 2. Build digraph object
    if cfg.verbose
        fprintf('[%s] Step 2: Building digraph...\n', datestr(now, 'HH:MM:SS'));
    end
    G = digraph(s, t, w);
    results.G = G;
    run_log.steps{end+1} = 'digraph_built';

    %% 3. Compute shortest path from 1 to 4
    if cfg.verbose
        fprintf('[%s] Step 3: Computing shortest path...\n', ...
            datestr(now, 'HH:MM:SS'));
    end
    [path_nodes, path_length] = shortestpath(G, 1, 4);
    results.shortest_path = path_nodes;
    results.shortest_distance = path_length;
    run_log.steps{end+1} = 'shortest_path_computed';

    %% 4. Compute all-pairs shortest paths
    if cfg.verbose
        fprintf('[%s] Step 4: Computing all-pairs distances...\n', ...
            datestr(now, 'HH:MM:SS'));
    end
    D_all = distances(G);
    results.all_pairs_dist = D_all;
    results.graph_diameter = max(D_all(D_all < Inf));
    results.avg_path_length = mean(D_all(D_all > 0 & D_all < Inf), 'all');
    run_log.steps{end+1} = 'all_pairs_computed';

    %% 5. Centrality measures
    if cfg.verbose
        fprintf('[%s] Step 5: Computing centrality...\n', ...
            datestr(now, 'HH:MM:SS'));
    end
    results.degree_centrality = indegree(G) + outdegree(G);
    results.betweenness = centrality(G, 'betweenness');
    results.closeness = centrality(G, 'closeness');
    run_log.steps{end+1} = 'centrality_computed';

    %% 6. Validation
    if cfg.verbose
        fprintf('[%s] Step 6: Validation...\n', datestr(now, 'HH:MM:SS'));
    end
    assert(path_length > 0, 'Shortest path length must be positive');
    assert(length(path_nodes) >= 2, 'Path must have at least 2 nodes');
    % Known shortest path 1->2->3->4 = 2+1+1 = 4
    expected_length = 4;
    if abs(path_length - expected_length) > 1e-10
        exitflag = -3;
        warning('Shortest path length mismatch: got %.4f, expected %.4f', ...
            path_length, expected_length);
    end
    results.is_valid = (exitflag == 0);
    run_log.steps{end+1} = 'validated';

    %% 7. Export
    results_file = fullfile(cfg.output_path, 'results_graph.mat');
    save(results_file, 'results');
    json_file = fullfile(cfg.output_path, 'results_graph.json');
    fid = fopen(json_file, 'w');
    if fid > 0
        safe_r = rmfield(results, 'G');
        fprintf(fid, '%s', jsonencode(safe_r));
        fclose(fid);
    end
    run_log.steps{end+1} = 'exported';

    %% 8. Visualization
    if cfg.verbose
        fprintf('[%s] Step 7: Visualization...\n', datestr(now, 'HH:MM:SS'));
    end
    fig = figure('Visible', 'off');
    h = plot(G, 'Layout', 'force', 'EdgeLabel', G.Edges.Weight, ...
        'NodeColor', 'cyan', 'MarkerSize', 10);
    highlight(h, path_nodes, 'EdgeColor', 'r', 'LineWidth', 2);
    highlight(h, path_nodes, 'NodeColor', 'r');
    title(sprintf('Shortest Path 1->4: dist=%.1f', path_length));
    fig_file = fullfile(cfg.figure_path, 'graph_shortest_path.png');
    print(fig, fig_file, '-dpng', '-r300');
    figs.graph = fig;
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
    fprintf('=== template_graph self-test ===\n');
    [r, ~, ef] = template_graph(42, struct('verbose', false));
    assert(ef == 0, 'Should exit cleanly, got exitflag=%d', ef);
    assert(r.shortest_distance > 0, 'Shortest distance should be positive');
    assert(length(r.shortest_path) >= 2, 'Path should have >=2 nodes');
    assert(r.shortest_path(1) == 1, 'Path should start at node 1');
    assert(r.shortest_path(end) == 4, 'Path should end at node 4');
    disp('template_graph self-test passed.');
end
end
