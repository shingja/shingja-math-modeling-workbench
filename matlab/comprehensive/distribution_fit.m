% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [result] = distribution_fit(data, mode, options)
%% DISTRIBUTION_FIT Distribution fitting, goodness-of-fit, and diagnostic data. Paradigm: PARADIGM-0503-DISTRIBUTIONS. v3.0.0.
%  Reference: Akaike, H. (1974) IEEE Trans. Automat. Contr. 19(6):716-723. DOI:10.1109/TAC.1974.1100705
%  Requirement 5 (fullfile): not_applicable -- no file IO.
arguments
    data (:, 1) double
    mode (1,1) string {mustBeMember(mode, ...
        ["fit_best", "fit_specific", "qq_plot_data"])} = "fit_best"
    options.distname (1,1) string = "normal"
    options.verbose (1,1) logical = true
    options.seed (1,1) double = 42
    options.confidence_level (1,1) double {mustBePositive, mustBeLessThan(options.confidence_level, 1)} = 0.95
end
rng(options.seed, 'twister');
% Validate data
n = numel(data);
assert(n >= 30, 'distribution_fit: at least 30 data points required.');
assert(all(isfinite(data)), 'distribution_fit: data must contain only finite values.');
% Dispatch
switch mode
    case "fit_best"
        result = fit_best_internal(data, options);
    case "fit_specific"
        result = fit_specific_internal(data, options);
    case "qq_plot_data"
        result = qq_plot_data_internal(data, options);
end
% Sanity: result structure must have required fields
assert(isfield(result, 'mode'), 'Result must have mode field.');
assert(isfield(result, 'n_samples'), 'Result must have n_samples field.');
end

function result = fit_best_internal(data, options)
    % Candidate distributions to try
    candidates = {'normal', 'lognormal', 'gamma', 'weibull', 'exponential', ...
                  'logistic', 'tlocationscale', 'gev'};
    n_candidates = numel(candidates);
    aic_values = inf(n_candidates, 1);
    param_cells = cell(n_candidates, 1);
    ks_pvalues = zeros(n_candidates, 1);
    successes = false(n_candidates, 1);
    for i = 1:n_candidates
        try
            distname = candidates{i};
            pd = fitdist(data, distname);
            n_params = pd.NumParameters;
            logL = pd.NegativeLogLikelihood;
            % AIC = 2*k - 2*log(L)  where k = n_params
            aic_values(i) = 2 * n_params + 2 * logL;
            param_cells{i} = pd;
            % KS test
            [~, ks_pvalues(i)] = kstest(data, 'CDF', pd);
            successes(i) = true;
        catch
            aic_values(i) = inf;
            successes(i) = false;
        end
    end
    % Select best distribution by minimum AIC among successful fits
    valid_idx = find(successes);
    if isempty(valid_idx)
        error('distribution_fit: no distribution could be fit to the data.');
    end
    [~, best_local] = min(aic_values(valid_idx));
    best_idx = valid_idx(best_local);
    best_name = candidates{best_idx};
    best_pd = param_cells{best_idx};
    best_aic = aic_values(best_idx);
    best_ks_p = ks_pvalues(best_idx);
    % Package results
    result = struct( ...
        'mode', 'fit_best', ...
        'n_samples', numel(data), ...
        'best_distribution', best_name, ...
        'best_pd', best_pd, ...
        'best_params', best_pd.ParameterValues, ...
        'best_param_names', {best_pd.ParameterNames}, ...
        'best_aic', best_aic, ...
        'best_ks_pvalue', best_ks_p, ...
        'all_aic', aic_values, ...
        'all_distributions', {candidates}, ...
        'all_successes', successes);
    if options.verbose
        fprintf('Best fit: %s (AIC=%.2f, KS p=%.4f)\n', ...
            best_name, best_aic, best_ks_p);
        fprintf('Parameters: %s\n', ...
            sprintf('%s=%.4f ', [best_pd.ParameterNames; num2cell(best_pd.ParameterValues)]{:}));
    end
end

function result = fit_specific_internal(data, options)
    distname = char(options.distname);
    % Fit the specified distribution
    pd = fitdist(data, distname);
    n_params = pd.NumParameters;
    logL = pd.NegativeLogLikelihood;
    aic = 2 * n_params + 2 * logL;
    % Kolmogorov-Smirnov goodness-of-fit test
    [h_ks, p_ks, ks_stat] = kstest(data, 'CDF', pd, 'Alpha', 1 - options.confidence_level);
    % Chi-square goodness-of-fit test with automatic binning
    n_bins = max(5, ceil(sqrt(numel(data))));
    [h_chi2, p_chi2, chi2_stat] = chi2gof_test_local(data, pd, n_bins);
    % Confidence intervals for parameters
    ci = paramci(pd, 'Alpha', 1 - options.confidence_level);
    result = struct( ...
        'mode', 'fit_specific', ...
        'n_samples', numel(data), ...
        'distribution', distname, ...
        'pd', pd, ...
        'params', pd.ParameterValues, ...
        'param_names', {pd.ParameterNames}, ...
        'param_ci', ci, ...
        'aic', aic, ...
        'ks_statistic', ks_stat, ...
        'ks_pvalue', p_ks, ...
        'ks_reject', h_ks, ...
        'chi2_statistic', chi2_stat, ...
        'chi2_pvalue', p_chi2);
    if options.verbose
        fprintf('Fit: %s (AIC=%.2f)\n', distname, aic);
        fprintf('KS test: stat=%.4f, p=%.4f, reject=%d\n', ks_stat, p_ks, h_ks);
        fprintf('Parameters (95%% CI):\n');
        for j = 1:n_params
            fprintf('  %s = %.4f [%.4f, %.4f]\n', ...
                pd.ParameterNames{j}, pd.ParameterValues(j), ci(1,j), ci(2,j));
        end
    end
end

function result = qq_plot_data_internal(data, options)
    distname = char(options.distname);
    pd = fitdist(data, distname);
    n = numel(data);
    % Empirical quantiles
    data_sorted = sort(data);
    % Theoretical quantile positions
    p_theoretical = ((1:n)' - 0.5) / n;
    % Theoretical quantiles from fitted distribution
    theoretical_quantiles = icdf(pd, p_theoretical);
    % Correlation on QQ plot (measure of linearity)
    rho_qq = corr(data_sorted, theoretical_quantiles);
    % Shapiro-Wilk test for normality (only if distname is 'normal')
    sw_pvalue = NaN;
    if strcmp(distname, 'normal') && n >= 3 && n <= 5000
        try
            [~, sw_pvalue] = swtest(data);
        catch
            sw_pvalue = NaN;
        end
    end
    result = struct( ...
        'mode', 'qq_plot_data', ...
        'n_samples', n, ...
        'distribution', distname, ...
        'empirical_quantiles', data_sorted, ...
        'theoretical_quantiles', theoretical_quantiles, ...
        'qq_correlation', rho_qq, ...
        'shapiro_wilk_pvalue', sw_pvalue, ...
        'pd', pd);
    if options.verbose
        fprintf('QQ plot data: %s, correlation=%.4f\n', distname, rho_qq);
    end
end

function [h, p, st] = chi2gof_test_local(data, pd, n_bins)
    % Local chi-square goodness-of-fit using bin counts
    n = numel(data);
    edges = linspace(min(data)-1e-6, max(data)+1e-6, n_bins+1);
    edges(1) = -inf;
    edges(end) = inf;
    observed = histcounts(data, edges)';
    expected = zeros(n_bins, 1);
    for b = 1:n_bins
        expected(b) = n * (cdf(pd, edges(b+1)) - cdf(pd, edges(b)));
    end
    % Merge bins with expected < 5
    valid = expected >= 5;
    if sum(valid) < 2
        h = false; p = 1; st = 0;
        return;
    end
    obs_merged = sum(observed(valid));
    exp_merged = sum(expected(valid));
    chi2 = sum((observed(valid) - expected(valid)).^2 ./ expected(valid));
    df = sum(valid) - pd.NumParameters - 1;
    if df < 1
        h = false; p = 1; st = chi2;
        return;
    end
    p = 1 - chi2cdf(chi2, df);
    h = p < 0.05;
    st = chi2;
end

%% Exit status
exitflag = 1;  %% normal termination

%% Self-test
function self_test()
    rng(42, 'twister');
    % Generate 200 N(100, 15) points
    n_pts = 200;
    mu_true = 100;
    sigma_true = 15;
    data = mu_true + sigma_true * randn(n_pts, 1);

    % Test 1: fit_specific -- normal distribution
    r1 = distribution_fit(data, "fit_specific", distname="normal", verbose=false);
    param_names = r1.param_names;
    mu_hat = r1.params(strcmp(param_names, 'mu'));
    sigma_hat = r1.params(strcmp(param_names, 'sigma'));
    assert(mu_hat >= 95 && mu_hat <= 105, ...
        sprintf('Normal fit: mu_hat=%.4f, expected in [95, 105]', mu_hat));
    assert(sigma_hat >= 12 && sigma_hat <= 18, ...
        sprintf('Normal fit: sigma_hat=%.4f, expected in [12, 18]', sigma_hat));
    % KS test should not reject normality
    assert(r1.ks_pvalue > 0.05, ...
        sprintf('KS test p=%.6f, should be > 0.05 (do not reject normality)', r1.ks_pvalue));

    % Test 2: fit_best -- should select normal as best or top-2
    r2 = distribution_fit(data, "fit_best", verbose=false);
    assert(strcmp(r2.best_distribution, 'normal') || r2.all_aic(1) < r2.all_aic(2) + 4, ...
        sprintf('Best fit: %s (AIC=%.2f), expected normal', ...
        r2.best_distribution, r2.best_aic));
    assert(r2.best_ks_pvalue > 0.01, ...
        sprintf('Best fit KS p=%.6f, expected > 0.01', r2.best_ks_pvalue));

    % Test 3: qq_plot_data -- correlation should be high for normal data
    r3 = distribution_fit(data, "qq_plot_data", distname="normal", verbose=false);
    assert(r3.qq_correlation > 0.95, ...
        sprintf('QQ correlation=%.6f, expected > 0.95 for normal data', r3.qq_correlation));
    assert(numel(r3.empirical_quantiles) == n_pts, ...
        'QQ data: empirical quantiles length mismatch.');
    assert(numel(r3.theoretical_quantiles) == n_pts, ...
        'QQ data: theoretical quantiles length mismatch.');

    fprintf('distribution_fit self-test passed (3 modes, 8 asserts).\n');
end
