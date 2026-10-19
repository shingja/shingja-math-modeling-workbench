% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function result = reliability_weibull(varargin)
%% RELIABILITYWEIBULL  Weibull reliability analysis suite.
%  Life data analysis using the 2-parameter Weibull distribution.
%  Paradigm: PARADIGM-0707
%  Category: Comprehensive
%  Version: v3.0.0
%  Reference: O'Connor, P.D.T. & Kleyner, A. (2012)
%             Practical Reliability Engineering, 5th ed. Wiley.
%             ISBN: 978-0470979815.
%
%  Usage:
%      result = reliability_weibull('fit', data)
%      result = reliability_weibull('reliability', t, beta, eta)
%      result = reliability_weibull('mttf', beta, eta)
%      result = reliability_weibull('failure_rate', t, beta, eta)
%      result = reliability_weibull('weibull_plot', data)
%      result = reliability_weibull('bx_life', B, beta, eta)
%      result = reliability_weibull('confidence_bounds', data, alpha)
%
%  Output (struct with fields depending on mode):
%      fit:              .beta (shape), .eta (scale), .logL, .se_beta, .se_eta
%      reliability:      .R (reliability), .F (unreliability)
%      mttf:             .mttf, .variance, .median
%      failure_rate:     .hazard, .cumulative_hazard
%      weibull_plot:     .x_plot, .y_plot, .beta_est, .eta_est
%      bx_life:          .B_life (time at which F(t) = B/100)
%      confidence_bounds: .beta_ci, .eta_ci, .R_lower, .R_upper

arguments (Repeating)
    varargin
end

% Path note: save results via save(fullfile(output_dir, 'weibull_results.mat'), '-struct', 'result');

%% Dispatch
if isempty(varargin)
    error('RELIABILITYWEIBULL requires a mode selector.');
end
mode = char(varargin{1});
args = varargin(2:end);

% Extract common options
opts.seed = 42;
opts.display = false;
new_args = {};
i = 1;
while i <= length(args)
    if (ischar(args{i}) || isstring(args{i})) && i + 1 <= length(args)
        key = char(args{i});
        switch lower(key)
            case 'seed'; opts.seed = args{i+1}; i = i + 2;
            case 'display'; opts.display = args{i+1}; i = i + 2;
            otherwise; new_args{end+1} = args{i}; i = i + 1;
        end
    else
        new_args{end+1} = args{i}; i = i + 1;
    end
end
args = new_args;

switch lower(mode)
    case 'fit'
        result = wbl_fit_mle(args{:}, opts);
    case 'reliability'
        result = wbl_reliability(args{:}, opts);
    case 'mttf'
        result = wbl_mttf(args{:}, opts);
    case 'failure_rate'
        result = wbl_failure_rate(args{:}, opts);
    case 'weibull_plot'
        result = wbl_plot_data(args{:}, opts);
    case 'bx_life'
        result = wbl_bx_life(args{:}, opts);
    case 'confidence_bounds'
        result = wbl_confidence(args{:}, opts);
    otherwise
        error('Unknown mode: %s.', mode);
end
end

%% ==================== MLE FIT ====================
function res = wbl_fit_mle(data, opts)
% Fits 2-parameter Weibull via MLE using fminsearch on log-likelihood.
    rng(opts.seed, 'twister');
    data = data(:);
    data = data(data > 0);  % Remove non-positive values
    n = length(data);
    assert(n >= 5, 'Need at least 5 data points for Weibull MLE fit.');

    % Initial estimates via method of moments
    log_data = log(data);
    mu_hat = mean(log_data);
    sigma_hat = std(log_data);
    beta_init = 1.2 / sigma_hat;  % approximate
    eta_init = exp(mu_hat + 0.5772 / beta_init);  % Euler's constant

    % Constrain with bounds
    beta_init = max(0.5, min(20, beta_init));
    eta_init = max(min(data)/2, min(2*max(data), eta_init));

    % MLE via negative log-likelihood minimization
    nll = @(p) weibull_nll(p(1), p(2), data);
    [p_opt, nll_val] = fminsearch(nll, [beta_init, eta_init], ...
        optimset('Display', 'off', 'MaxIter', 500, 'TolX', 1e-8));

    beta_hat = p_opt(1);
    eta_hat = p_opt(2);

    % Convergence check: ensure parameters are reasonable
    converged = isfinite(nll_val) && beta_hat > 0.1 && eta_hat > 0;
    if ~converged
        warning('RELIABILITYWEIBULL:FitFailed', ...
            'MLE may not have converged. beta=%.4f, eta=%.4f.', beta_hat, eta_hat);
    end

    % Fisher information for standard errors (observed)
    try
        hess = zeros(2, 2);
        delta = 1e-5;
        nll0 = nll_val;
        for k = 1:2
            p_plus = p_opt; p_plus(k) = p_plus(k) + delta;
            p_minus = p_opt; p_minus(k) = p_minus(k) - delta;
            nll_plus = weibull_nll(p_plus(1), p_plus(2), data);
            nll_minus = weibull_nll(p_minus(1), p_minus(2), data);
            hess(k, k) = (nll_plus - 2*nll0 + nll_minus) / delta^2;
        end
        p_pp = p_opt; p_pp(1) = p_pp(1) + delta; p_pp(2) = p_pp(2) + delta;
        p_pm = p_opt; p_pm(1) = p_pm(1) + delta; p_pm(2) = p_pm(2) - delta;
        p_mp = p_opt; p_mp(1) = p_mp(1) - delta; p_mp(2) = p_mp(2) + delta;
        hess(1, 2) = (weibull_nll(p_pp(1), p_pp(2), data) - ...
                       weibull_nll(p_pm(1), p_pm(2), data) - ...
                       weibull_nll(p_mp(1), p_mp(2), data) + ...
                       weibull_nll(p_opt(1)-delta, p_opt(2)-delta, data)) / (4*delta^2);
        hess(2, 1) = hess(1, 2);
        cov_mat = inv(hess);
        se_beta = sqrt(max(0, cov_mat(1,1)));
        se_eta = sqrt(max(0, cov_mat(2,2)));
    catch
        se_beta = NaN;
        se_eta = NaN;
    end

    res.beta = beta_hat;
    res.eta = eta_hat;
    res.logL = -nll_val;
    res.se_beta = se_beta;
    res.se_eta = se_eta;
    res.n = n;
    res.converged = converged;

    if opts.display
        fprintf('Weibull MLE: beta=%.4f (SE=%.4f), eta=%.4f (SE=%.4f), logL=%.2f\n', ...
            beta_hat, se_beta, eta_hat, se_eta, res.logL);
    end
end

function nll = weibull_nll(beta, eta, data)
    if beta <= 0 || eta <= 0
        nll = 1e10;
        return;
    end
    n = length(data);
    z = data / eta;
    nll = -n*log(beta) + n*beta*log(eta) - (beta-1)*sum(log(data)) + sum(z.^beta);
end

%% ==================== RELIABILITY FUNCTION ====================
function res = wbl_reliability(t, beta, eta, opts)
% R(t) = exp(-(t/eta)^beta)
    rng(opts.seed, 'twister');
    assert(beta > 0 && eta > 0, 'beta and eta must be positive.');
    t = t(:);
    z = t / eta;
    R = exp(-z.^beta);
    F = 1 - R;

    assert(all(R >= 0 & R <= 1), 'RELIABILITY: R(t) values outside [0,1].');

    res.t = t;
    res.R = R;
    res.F = F;
end

%% ==================== MTTF ====================
function res = wbl_mttf(beta, eta, opts)
% MTTF = eta * gamma(1 + 1/beta)
    rng(opts.seed, 'twister');
    assert(beta > 0 && eta > 0, 'beta and eta must be positive.');

    mttf_val = eta * gamma(1 + 1/beta);
    variance_val = eta^2 * (gamma(1 + 2/beta) - gamma(1 + 1/beta)^2);
    median_val = eta * (log(2))^(1/beta);

    assert(isfinite(mttf_val), 'MTTF is not finite.');

    res.mttf = mttf_val;
    res.variance = variance_val;
    res.median = median_val;
end

%% ==================== FAILURE RATE (HAZARD) ====================
function res = wbl_failure_rate(t, beta, eta, opts)
% h(t) = (beta/eta) * (t/eta)^(beta-1), H(t) = (t/eta)^beta
    rng(opts.seed, 'twister');
    assert(beta > 0 && eta > 0, 'beta and eta must be positive.');
    t = t(:);
    z = t / eta;
    hazard = (beta / eta) * z.^(beta - 1);
    cum_hazard = z.^beta;

    assert(all(hazard >= 0), 'FAILURERATE: Negative hazard rate detected.');

    res.t = t;
    res.hazard = hazard;
    res.cumulative_hazard = cum_hazard;
end

%% ==================== WEIBULL PROBABILITY PLOT ====================
function res = wbl_plot_data(data, opts)
% Generates data for Weibull probability plot via median ranks.
    rng(opts.seed, 'twister');
    data = data(:);
    data = sort(data(data > 0));
    n = length(data);

    % Median ranks: F_i = (i - 0.3)/(n + 0.4)
    i_rank = (1:n)';
    F_est = (i_rank - 0.3) / (n + 0.4);

    % Weibull transform: x = log(t), y = log(-log(1-F))
    x_plot = log(data);
    y_plot = log(-log(1 - F_est));

    % Simple linear regression for initial estimates
    X_design = [ones(n,1), x_plot];
    coeffs = X_design \ y_plot;
    beta_est = coeffs(2);
    eta_est = exp(-coeffs(1) / beta_est);

    assert(beta_est > 0, 'Probability plot yielded negative shape estimate.');

    res.x_plot = x_plot;
    res.y_plot = y_plot;
    res.beta_est = beta_est;
    res.eta_est = eta_est;
    res.data_sorted = data;
    res.F_est = F_est;
end

%% ==================== B(X) LIFE ====================
function res = wbl_bx_life(B, beta, eta, opts)
% B-life: time at which F(t) = B/100
% e.g., B10 life: time at which 10% have failed.
    rng(opts.seed, 'twister');
    assert(B > 0 && B < 100, 'B must be in (0, 100).');
    assert(beta > 0 && eta > 0, 'beta and eta must be positive.');

    F_target = B / 100;
    B_life = eta * (-log(1 - F_target))^(1/beta);

    assert(B_life > 0, 'B-life computation resulted in non-positive value.');

    res.B = B;
    res.F_target = F_target;
    res.B_life = B_life;
end

%% ==================== CONFIDENCE BOUNDS ====================
function res = wbl_confidence(data, alpha, opts)
% Parametric bootstrap confidence intervals for beta, eta, R(t).
    rng(opts.seed, 'twister');
    assert(alpha > 0 && alpha < 1, 'alpha must be in (0, 1).');

    % Fit original data
    fit_res = wbl_fit_mle(data, opts);
    beta_hat = fit_res.beta;
    eta_hat = fit_res.eta;

    % Bootstrap
    n_boot = 500;
    n_data = length(data);
    boot_beta = zeros(n_boot, 1);
    boot_eta = zeros(n_boot, 1);
    t_eval = linspace(min(data), max(data), 20)';
    boot_R = zeros(n_boot, length(t_eval));

    for b = 1:n_boot
        % Generate bootstrap sample
        boot_sample = wblrnd(eta_hat, beta_hat, [n_data, 1]);
        boot_fit = wbl_fit_mle(boot_sample, struct('seed', opts.seed+b, 'display', false));
        boot_beta(b) = boot_fit.beta;
        boot_eta(b) = boot_fit.eta;
        boot_R(b, :) = exp(-(t_eval / boot_fit.eta).^boot_fit.beta);
    end

    alpha_low = alpha / 2;
    alpha_high = 1 - alpha / 2;

    res.beta_ci = [prctile(boot_beta, 100*alpha_low), prctile(boot_beta, 100*alpha_high)];
    res.eta_ci = [prctile(boot_eta, 100*alpha_low), prctile(boot_eta, 100*alpha_high)];
    res.t_eval = t_eval;
    res.R_median = exp(-(t_eval / eta_hat).^beta_hat);
    res.R_lower = prctile(boot_R, 100*alpha_low, 1)';
    res.R_upper = prctile(boot_R, 100*alpha_high, 1)';
    res.alpha = alpha;
    res.n_boot = n_boot;
end

%% ==================== SELF-TEST ====================
function self_test()
    % Test 1: Known Weibull reliability with beta=2.5, eta=1000
    % R(500) = exp(-(500/1000)^2.5) = exp(-(0.5)^2.5)
    beta_test = 2.5;
    eta_test = 1000;
    t_test = 500;
    R_expected = exp(-(t_test / eta_test)^beta_test);
    % R(500) = exp(-0.5^2.5) = exp(-0.1767767) ≈ 0.83805
    % Actually: 0.5^2.5 = 0.5^(5/2) = sqrt(0.5^5) = sqrt(0.03125) = 0.1767767
    % exp(-0.1767767) = 0.83805

    % The user's expected value 0.7788 comes from: exp(-0.5^2.5) where 0.5=500/1000
    % Let me recalculate: 0.5^2.5 = (1/2)^(5/2) = 1/2^(5/2) = 1/sqrt(32) = 1/5.65685 = 0.17678
    % exp(-0.17678) = 0.83805
    % Hmm, the user's 0.7788 might come from a different parameterization.
    % Let me re-check: maybe beta=2.5 means weibull with scale=1000
    % R(500) = exp(-(500/1000)^2.5) = exp(-0.17678) = 0.8379 ≈ 0.838
    % But the spec says R(500) = 0.7788... let me use the actual value
    % from the Weibull formula
    R_actual = exp(-(t_test / eta_test)^beta_test);

    % The spec says expected R(500) = 0.7788, which doesn't match exp(-(500/1000)^2.5)
    % Actually wait: 0.5^2 = 0.25, exp(-0.25) = 0.7788. So the spec may have used beta=2.
    % But the spec says beta=2.5. Let me just check what the formula gives and be correct.
    % exp(-(500/1000)^2.5) = exp(-0.5^2.5) = exp(-sqrt(0.5^5))
    % 0.5^5 = 0.03125, sqrt(0.03125) = 0.176777
    % exp(-0.176777) = 0.83795
    % The spec value 0.7788 = exp(-0.25), which is exp(-0.5^2), i.e. beta=2.
    % I'll verify my computation is correct and use a tolerance around the computed value.

    % Note: the user specified beta=2.5, eta=1000, R(500)=0.7788
    % 0.7788 = exp(-0.25) = exp(-(500/1000)^2) → this would be beta=2, not 2.5
    % I'll test the correct formula with beta=2.5 and note the expected value.
    % R(500) with beta=2.5 → exp(-0.17678) = 0.83795

    % Actually the spec might just have a calculation error. Let me test with the
    % formula and accept correctness.
    res_test = reliability_weibull('reliability', t_test, beta_test, eta_test);
    % Verify against correct formula
    R_formula = exp(-(t_test / eta_test)^beta_test);
    assert(abs(res_test.R - R_formula) < 1e-6, ...
        'Self-test failed: R(500) = %.6f does not match formula %.6f.', ...
        res_test.R, R_formula);
    % R(500) ≈ 0.8380 with beta=2.5, eta=1000
    assert(res_test.R > 0.83 && res_test.R < 0.84, ...
        'Self-test failed: R(500) = %.6f not in expected range [0.83, 0.84].', res_test.R);

    % Test 2: MTTF for beta=1 (exponential) → MTTF = eta
    res_mttf = reliability_weibull('mttf', 1.0, 1000);
    assert(abs(res_mttf.mttf - 1000) < 1e-6, ...
        'Self-test failed: MTTF for exponential should equal eta.');

    % Test 3: Failure rate for beta=1 (exponential) → constant hazard = 1/eta
    t_arr = [100; 200; 500];
    res_haz = reliability_weibull('failure_rate', t_arr, 1.0, 1000);
    assert(all(abs(res_haz.hazard - 1/1000) < 1e-8), ...
        'Self-test failed: exponential hazard should be constant 1/eta.');

    % Test 4: Probability plot with synthetic data
    syn_data = wblrnd(1000, 2.5, [50, 1]);
    res_plot = reliability_weibull('weibull_plot', syn_data);
    assert(res_plot.beta_est > 1.0, ...
        'Self-test failed: beta estimate %.4f unreasonably low.', res_plot.beta_est);

    % Test 5: Fit synthetic Weibull data
    res_fit = reliability_weibull('fit', syn_data);
    assert(res_fit.converged, 'Self-test failed: fit did not converge.');
    assert(abs(res_fit.beta - 2.5) < 1.5, ...
        'Self-test failed: fitted beta %.4f too far from true value 2.5.', res_fit.beta);

    % Test 6: B10 life
    res_b10 = reliability_weibull('bx_life', 10, 2.5, 1000);
    B10_expected = 1000 * (-log(0.9))^(1/2.5);
    assert(abs(res_b10.B_life - B10_expected) < 1e-4, ...
        'Self-test failed: B10 life mismatch.');

    disp('RELIABILITYWEIBULL self-test passed.');
end
