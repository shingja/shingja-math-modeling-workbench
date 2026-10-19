% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [results, figs, exitflag] = template_prediction(seed, cfg)
% TEMPLATE_PREDICTION Prediction model template - AR(1) series forecast. v3.0.0.
%   Generate AR(1) series, fit AR(1), forecast 10 steps ahead.
%   Output: results(struct), figs(struct), exitflag(0=OK).
arguments
    seed (1,1) double {mustBeFinite} = 42
    cfg.data_path (1,:) char = fullfile(pwd, 'data')
    cfg.output_path (1,:) char = fullfile(pwd, 'results')
    cfg.figure_path (1,:) char = fullfile(pwd, 'figures')
    cfg.verbose (1,1) logical = true
    cfg.n_obs (1,1) double {mustBePositive} = 100
    cfg.n_forecast (1,1) double {mustBePositive} = 10
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
    %% 1. Generate dummy AR(1) series: y_t = phi*y_{t-1} + eps
    if cfg.verbose
        fprintf('[%s] Step 1: Generating AR(1) series...\n', ...
            datestr(now, 'HH:MM:SS'));
    end
    phi_true = 0.7;
    sigma_eps = 0.5;
    y = zeros(cfg.n_obs, 1);
    y(1) = randn() * sigma_eps / sqrt(1 - phi_true^2);
    for t = 2:cfg.n_obs
        y(t) = phi_true * y(t-1) + sigma_eps * randn();
    end
    run_log.steps{end+1} = 'data_generated';

    %% 2. Fit AR(1) model using OLS
    if cfg.verbose
        fprintf('[%s] Step 2: Fitting AR(1) via OLS...\n', ...
            datestr(now, 'HH:MM:SS'));
    end
    Y_lag = y(1:end-1);
    Y_curr = y(2:end);
    X_design = [ones(length(Y_lag), 1), Y_lag];
    beta = X_design \ Y_curr;
    results.phi_hat = beta(2);
    results.const_hat = beta(1);
    run_log.steps{end+1} = 'model_fitted';

    %% 3. Compute in-sample residuals
    if cfg.verbose
        fprintf('[%s] Step 3: Computing residuals...\n', ...
            datestr(now, 'HH:MM:SS'));
    end
    y_pred_in = X_design * beta;
    residuals = Y_curr - y_pred_in;
    results.sigma_hat = std(residuals);
    results.R2 = 1 - sum(residuals.^2) / sum((Y_curr - mean(Y_curr)).^2);
    run_log.steps{end+1} = 'residuals_computed';

    %% 4. Forecast
    if cfg.verbose
        fprintf('[%s] Step 4: Forecasting %d steps ahead...\n', ...
            datestr(now, 'HH:MM:SS'), cfg.n_forecast);
    end
    y_forecast = zeros(cfg.n_forecast, 1);
    y_prev = y(end);
    for h = 1:cfg.n_forecast
        mu = results.const_hat + results.phi_hat * y_prev;
        y_forecast(h) = mu + results.sigma_hat * randn();
        y_prev = y_forecast(h);
    end
    results.y_forecast = y_forecast;
    results.y_historical = y;
    run_log.steps{end+1} = 'forecast_computed';

    %% 5. Validation
    if cfg.verbose
        fprintf('[%s] Step 5: Validation...\n', datestr(now, 'HH:MM:SS'));
    end
    assert(~isempty(y_forecast), 'Forecast must be non-empty');
    assert(abs(results.phi_hat - phi_true) < 0.3, ...
        'Estimated phi far from true value');
    if abs(results.phi_hat) >= 1
        exitflag = -2;
        warning('Estimated AR(1) may be non-stationary');
    end
    run_log.steps{end+1} = 'validated';

    %% 6. Export
    results_file = fullfile(cfg.output_path, 'results_prediction.mat');
    save(results_file, 'results');
    json_file = fullfile(cfg.output_path, 'results_prediction.json');
    fid = fopen(json_file, 'w');
    if fid > 0
        safe_r = results;
        safe_r.y_historical = safe_r.y_historical(1:min(10, end));
        safe_r.y_forecast = safe_r.y_forecast;
        fprintf(fid, '%s', jsonencode(safe_r));
        fclose(fid);
    end
    run_log.steps{end+1} = 'exported';

    %% 7. Visualization
    if cfg.verbose
        fprintf('[%s] Step 6: Visualization...\n', datestr(now, 'HH:MM:SS'));
    end
    fig = figure('Visible', 'off');
    t_hist = (1:cfg.n_obs)';
    t_fore = (cfg.n_obs+1:cfg.n_obs+cfg.n_forecast)';
    plot(t_hist, y, 'b-', 'LineWidth', 1.5); hold on;
    plot(t_fore, y_forecast, 'r--', 'LineWidth', 1.5);
    xlabel('Time'); ylabel('y_t');
    title(sprintf('AR(1) Forecast: \\phi_{true}=%.2f, \\phi_{hat}=%.3f', ...
        phi_true, results.phi_hat));
    legend({'Historical', 'Forecast'}, 'Location', 'best'); hold off;
    fig_file = fullfile(cfg.figure_path, 'prediction_forecast.png');
    print(fig, fig_file, '-dpng', '-r300');
    figs.forecast = fig;
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
    fprintf('=== template_prediction self-test ===\n');
    [r, ~, ef] = template_prediction(42, struct('verbose', false));
    assert(ef == 0, 'Should exit cleanly, got exitflag=%d', ef);
    assert(isfield(r, 'y_forecast'), 'Results should contain y_forecast');
    assert(~isempty(r.y_forecast), 'Forecast should not be empty');
    assert(length(r.y_forecast) == 10, 'Forecast length should be 10');
    assert(abs(r.phi_hat) < 2, 'Estimated phi should be reasonable');
    disp('template_prediction self-test passed.');
end
end
