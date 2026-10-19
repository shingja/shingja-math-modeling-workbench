% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [results, figs, exitflag] = template_clustering(seed, cfg)
% TEMPLATE_CLUSTERING Clustering model template - 2-blob K-means. v3.0.0.
%   Generate 2 Gaussian blobs, cluster with K-means (K=2).
%   Output: results(struct), figs(struct), exitflag(0=OK).
arguments
    seed (1,1) double {mustBeFinite} = 42
    cfg.data_path (1,:) char = fullfile(pwd, 'data')
    cfg.output_path (1,:) char = fullfile(pwd, 'results')
    cfg.figure_path (1,:) char = fullfile(pwd, 'figures')
    cfg.verbose (1,1) logical = true
    cfg.n_samples (1,1) double {mustBePositive} = 200
    cfg.k_clusters (1,1) double {mustBePositive} = 2
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
    %% 1. Generate 2 Gaussian blobs
    if cfg.verbose
        fprintf('[%s] Step 1: Generating 2-blob data...\n', ...
            datestr(now, 'HH:MM:SS'));
    end
    n_per_blob = floor(cfg.n_samples / 2);
    mu1 = [2, 2];
    mu2 = [-2, -2];
    sigma = [0.8, 0; 0, 0.8];
    blob1 = mvnrnd(mu1, sigma, n_per_blob);
    blob2 = mvnrnd(mu2, sigma, n_per_blob);
    X_data = [blob1; blob2];
    y_true = [ones(n_per_blob, 1); 2 * ones(n_per_blob, 1)];
    results.X = X_data;
    results.y_true = y_true;
    run_log.steps{end+1} = 'data_generated';

    %% 2. Run K-means clustering
    if cfg.verbose
        fprintf('[%s] Step 2: Running K-means (K=%d)...\n', ...
            datestr(now, 'HH:MM:SS'), cfg.k_clusters);
    end
    [y_pred, centroids] = kmeans(X_data, cfg.k_clusters, ...
        'Replicates', 5, 'MaxIter', 300);
    results.y_pred = y_pred;
    results.centroids = centroids;
    run_log.steps{end+1} = 'kmeans_run';

    %% 3. Compute clustering quality metrics
    if cfg.verbose
        fprintf('[%s] Step 3: Computing clustering metrics...\n', ...
            datestr(now, 'HH:MM:SS'));
    end
    sil_vals = silhouette(X_data, y_pred);
    results.silhouette_avg = mean(sil_vals);
    results.silhouette_all = sil_vals;
    % Within-cluster sum of squares
    wcss = 0;
    for k = 1:cfg.k_clusters
        cluster_pts = X_data(y_pred == k, :);
        wcss = wcss + sum(sum((cluster_pts - centroids(k, :)).^2, 2));
    end
    results.wcss = wcss;
    % Adjusted Rand Index (approximate match to true labels)
    n_correct = max(sum((y_pred == 1 & y_true == 1) | (y_pred == 2 & y_true == 2)), ...
        sum((y_pred == 1 & y_true == 2) | (y_pred == 2 & y_true == 1)));
    results.accuracy = n_correct / length(y_true);
    run_log.steps{end+1} = 'metrics_computed';

    %% 4. Separation check
    if cfg.verbose
        fprintf('[%s] Step 4: Checking cluster separation...\n', ...
            datestr(now, 'HH:MM:SS'));
    end
    centroid_dist = norm(centroids(1,:) - centroids(2,:));
    results.centroid_distance = centroid_dist;
    cluster_sizes = [sum(y_pred == 1), sum(y_pred == 2)];
    results.cluster_sizes = cluster_sizes;
    run_log.steps{end+1} = 'separation_checked';

    %% 5. Validation
    if cfg.verbose
        fprintf('[%s] Step 5: Validation...\n', datestr(now, 'HH:MM:SS'));
    end
    n_unique = length(unique(y_pred));
    results.n_clusters_found = n_unique;
    if n_unique ~= cfg.k_clusters
        exitflag = -2;
        warning('Expected %d clusters, found %d', cfg.k_clusters, n_unique);
    end
    if results.silhouette_avg < 0.3
        exitflag = -3;
        warning('Poor cluster separation: silhouette=%.4f', results.silhouette_avg);
    end
    if centroid_dist < 1.0
        exitflag = -3;
        warning('Cluster centroids too close: dist=%.4f', centroid_dist);
    end
    run_log.steps{end+1} = 'validated';

    %% 6. Export
    results_file = fullfile(cfg.output_path, 'results_clustering.mat');
    save(results_file, 'results');
    json_file = fullfile(cfg.output_path, 'results_clustering.json');
    fid = fopen(json_file, 'w');
    if fid > 0
        safe_r = results;
        safe_r.X = [];
        safe_r.silhouette_all = safe_r.silhouette_all(1:10:end);
        fprintf(fid, '%s', jsonencode(safe_r));
        fclose(fid);
    end
    run_log.steps{end+1} = 'exported';

    %% 7. Visualization
    if cfg.verbose
        fprintf('[%s] Step 6: Visualization...\n', datestr(now, 'HH:MM:SS'));
    end
    fig = figure('Visible', 'off');
    subplot(1,2,1);
    gscatter(X_data(:,1), X_data(:,2), y_pred, 'rb', 'xo', 8);
    hold on;
    plot(centroids(:,1), centroids(:,2), 'k+', 'MarkerSize', 15, 'LineWidth', 3);
    xlabel('Feature 1'); ylabel('Feature 2');
    title(sprintf('K-means (K=%d)', cfg.k_clusters)); hold off;
    subplot(1,2,2);
    bar(sil_vals);
    xlabel('Sample'); ylabel('Silhouette Value');
    title(sprintf('Silhouette (avg=%.3f)', results.silhouette_avg));
    fig_file = fullfile(cfg.figure_path, 'clustering_kmeans.png');
    print(fig, fig_file, '-dpng', '-r300');
    figs.cluster = fig;
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
    fprintf('=== template_clustering self-test ===\n');
    [r, ~, ef] = template_clustering(42, struct('verbose', false));
    assert(ef == 0, 'Should exit cleanly, got exitflag=%d', ef);
    assert(r.n_clusters_found == 2, 'Should find 2 clusters, got %d', ...
        r.n_clusters_found);
    assert(r.silhouette_avg > 0.5, 'Silhouette should be >0.5, got %.4f', ...
        r.silhouette_avg);
    assert(r.accuracy > 0.9, 'Clustering accuracy should be >0.9, got %.4f', ...
        r.accuracy);
    assert(size(r.centroids, 1) == 2, 'Should have 2 centroids');
    disp('template_clustering self-test passed.');
end
end
