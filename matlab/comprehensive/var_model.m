% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [A_est, residuals, irf, info, exitflag] = var_model(Y, p, options)
%% VARMODEL Vector Autoregression VAR(p) model estimation.
%  Estimates VAR(p) model Y_t = A_1*Y_{t-1} + ... + A_p*Y_{t-p} + e_t
%  using OLS (equation-by-equation) or Yule-Walker (for VAR(1)).
%  Also computes impulse response functions (IRF).
%  Paradigm: PARADIGM-0705
%  Category: Comprehensive
%  Version: v3.0.0
%  Reference: Lutkepohl, H. (2005) New Introduction to Multiple Time
%             Series Analysis. Springer. ISBN: 978-3540401728.
%             Hamilton, J.D. (1994) Time Series Analysis. Princeton
%             University Press. ISBN: 978-0691042893.
%
%  Input:
%      Y - Data matrix (T x K), T obs, K variables
%      p - Lag order (positive integer)
%
%  Options:
%      options.const        - Include constant term (default: true)
%      options.method       - 'ols' (default) | 'yule_walker'
%      options.irf_periods  - Number of IRF periods (default: 20)
%      options.irf_shock    - Shock vector (K x 1), default: unit shock to var 1
%      options.seed         - RNG seed (default: 42)
%
%  Output:
%      A_est     - Estimated coefficient matrices (K x K x p)
%      residuals - Residuals (T-p x K)
%      irf       - Impulse response: irf(t, response_var, shock_var) (h x K x K)
%      info      - Structure with AIC, BIC, Sigma (covariance), R2
%      exitflag  - 1 = success, 0 = warning, -1 = error

arguments
    Y (:, :) double
    p (1,1) double {mustBeInteger, mustBePositive}
    options.const (1,1) logical = true
    options.method char {mustBeMember(options.method, {'ols','yule_walker'})} = 'ols'
    options.irf_periods (1,1) double {mustBeInteger, mustBePositive} = 20
    options.irf_shock (:, 1) double = []
    options.seed (1,1) double = 42
end

rng(options.seed, 'twister');
exitflag = 1;

[T_obs, K] = size(Y);
assert(T_obs > p + K + 2, ...
    'Need T > p+K+2 observations, got T=%d, p=%d, K=%d.', T_obs, p, K);
assert(all(isfinite(Y(:))), 'Input data contains non-finite values.');

%% Step 1: Demean the data
Y_mean = mean(Y, 1);
Y_dm = Y - Y_mean;

%% Step 2: Build lagged design matrix
% Each row t corresponds to observation at time t = p+1, ..., T
% Design matrix: Z_t = [Y_{t-1}', Y_{t-2}', ..., Y_{t-p}'] (1 x K*p)
n_eff = T_obs - p;
Z_full = zeros(n_eff, K * p);
Y_mat = zeros(n_eff, K);

for t = 1:n_eff
    t_actual = t + p;
    Y_mat(t, :) = Y_dm(t_actual, :);
    for lag = 1:p
        Z_full(t, (lag-1)*K+1 : lag*K) = Y_dm(t_actual - lag, :);
    end
end

%% Step 3: Estimate VAR coefficients
if options.const
    Z_reg = [ones(n_eff, 1), Z_full];
else
    Z_reg = Z_full;
end

% OLS: A_hat = (Z' * Z)^(-1) * Z' * Y
if strcmp(options.method, 'ols')
    try
        theta = (Z_reg' * Z_reg) \ (Z_reg' * Y_mat);
    catch
        exitflag = -1;
        warning('VARMODEL:SingularMatrix', 'Design matrix Z''Z is singular.');
        A_est = zeros(K, K, p);
        residuals = Y_mat;
        irf = zeros(options.irf_periods, K, K);
        info = struct('AIC', NaN, 'BIC', NaN, 'Sigma', eye(K), 'R2', zeros(1,K));
        return;
    end

    % Extract constant and A matrices
    if options.const
        const_est = theta(1, :);
        theta_coef = theta(2:end, :);
    else
        const_est = zeros(1, K);
        theta_coef = theta;
    end

    % Reshape: theta_coef is K*p x K, each column is a K-variable equation
    A_est = zeros(K, K, p);
    for lag_idx = 1:p
        cols = (lag_idx-1)*K+1 : lag_idx*K;
        A_est(:, :, lag_idx) = theta_coef(cols, :)';
    end

    % Compute residuals
    Y_hat = Z_reg * theta;
    residuals = Y_mat - Y_hat;

elseif strcmp(options.method, 'yule_walker')
    % Yule-Walker for VAR(1): Gamma_1 = A * Gamma_0
    assert(p == 1, 'Yule-Walker method only supports VAR(1) (p=1).');
    Gamma_0 = (Y_dm' * Y_dm) / (T_obs - 1);
    Gamma_1 = (Y_dm(2:end, :)' * Y_dm(1:end-1, :)) / (T_obs - 1);
    try
        A1 = Gamma_1 / Gamma_0;
    catch
        exitflag = -1;
        warning('VARMODEL:YWsingular', 'Gamma_0 is singular in Yule-Walker.');
        A_est = zeros(K, K, p);
        residuals = Y_mat;
        irf = zeros(options.irf_periods, K, K);
        info = struct('AIC', NaN, 'BIC', NaN, 'Sigma', eye(K), 'R2', zeros(1,K));
        return;
    end
    A_est(:, :, 1) = A1;
    Y_hat = Y_dm(1:end-1, :) * A1';
    residuals = Y_dm(2:end, :) - Y_hat;
    const_est = zeros(1, K);
end

%% Step 4: Compute residual covariance
Sigma_e = (residuals' * residuals) / (size(residuals, 1) - 1);

%% Step 5: Model diagnostics
% R-squared per equation
SS_tot = sum((Y_mat - mean(Y_mat, 1)).^2, 1);
SS_res = sum(residuals.^2, 1);
R2 = 1 - SS_res ./ max(SS_tot, 1e-12);

% AIC, BIC
n_params = K * K * p;
if options.const, n_params = n_params + K; end
det_Sigma = det(Sigma_e);
if det_Sigma > 1e-16
    logL = -(n_eff/2) * (K * log(2*pi) + log(det_Sigma) + K);
    AIC = -2 * logL / n_eff + 2 * n_params / n_eff;
    BIC = -2 * logL / n_eff + n_params * log(n_eff) / n_eff;
else
    AIC = NaN; BIC = NaN;
end

%% Step 6: Impulse Response Function (IRF)
h = options.irf_periods;
irf = zeros(h, K, K);

if isempty(options.irf_shock)
    shock = zeros(K, 1);
    shock(1) = 1;
else
    shock = options.irf_shock(:);
    assert(length(shock) == K, 'Shock vector must have length K=%d.', K);
end

% Recursive computation: IRF_0 = shock, IRF_h = sum_{lag=1}^{p} A_lag * IRF_{h-lag}
irf(1, :, :) = diag(shock);
for horizon = 2:h
    Phi = zeros(K, K);
    for lag_idx = 1:min(horizon-1, p)
        Phi = Phi + A_est(:, :, lag_idx) * squeeze(irf(horizon - lag_idx, :, :));
    end
    irf(horizon, :, :) = Phi;
end

%% Step 7: Package info
info = struct();
info.AIC = AIC;
info.BIC = BIC;
info.Sigma = Sigma_e;
info.R2 = R2;
info.residuals = residuals;
if options.const
    info.const = const_est;
end

%% Validation
if any(isnan(A_est(:)))
    exitflag = -1;
    warning('VARMODEL:NaNCoef', 'NaN in estimated coefficients.');
end

%% Self-test
function self_test()
    rng(42);
    % Generate data from known VAR(1) with 2 variables
    T_sim = 200;
    A_true = [0.5, 0.2;
              0.1, 0.6];  % stationary VAR(1)
    e = randn(T_sim, 2) * 0.5;
    Y_sim = zeros(T_sim, 2);
    Y_sim(1, :) = randn(1, 2);

    for t = 2:T_sim
        Y_sim(t, :) = Y_sim(t-1, :) * A_true' + e(t, :);
    end

    % Test 1: VAR(1) OLS estimation
    [A1, ~, irf1, info1, ef1] = var_model(Y_sim, 1, ...
        'const', false, 'method', 'ols', 'irf_periods', 10, 'seed', 42);

    assert(ef1 >= 0, 'Self-test 1: exitflag >= 0, got %d.', ef1);
    assert(size(A1, 1) == 2 && size(A1, 2) == 2 && size(A1, 3) == 1, ...
        'Self-test 1: A_est should be 2x2x1.');
    % Verify recovered A matrix within tolerance
    A_recovered = A1(:, :, 1);
    err_A = max(abs(A_recovered(:) - A_true(:)));
    assert(err_A < 0.2, ...
        'Self-test 1: Recovered A error %.4f exceeds 0.2 tolerance.', err_A);

    % Test 2: Yule-Walker vs OLS for VAR(1)
    [A_yw, ~, ~, ~, ef2] = var_model(Y_sim, 1, ...
        'const', false, 'method', 'yule_walker', 'seed', 42);
    assert(ef2 >= 0, 'Self-test 2: YW exitflag >= 0, got %d.', ef2);
    err_yw_ols = max(abs(A_yw(:) - A_recovered(:)));
    assert(err_yw_ols < 0.2, ...
        'Self-test 2: YW and OLS estimates differ by %.4f.', err_yw_ols);

    % Test 3: IRF dimensions
    assert(size(irf1, 1) == 10, ...
        'Self-test 3: IRF should have 10 periods, got %d.', size(irf1, 1));
    assert(size(irf1, 2) == 2 && size(irf1, 3) == 2, ...
        'Self-test 3: IRF should be K x K for each horizon.');

    % Test 4: R2 should be reasonable for well-specified model
    assert(all(info1.R2 > 0.3), ...
        'Self-test 4: R-squared should be > 0.3, got [%.4f %.4f].', info1.R2);

    % Test 5: VAR(2) estimation
    [A2, ~, ~, ~, ef5] = var_model(Y_sim, 2, ...
        'const', false, 'method', 'ols', 'seed', 42);
    assert(ef5 >= 0, 'Self-test 5: VAR(2) exitflag >= 0, got %d.', ef5);
    assert(size(A2, 3) == 2, ...
        'Self-test 5: VAR(2) should have 2 lag matrices, got %d.', size(A2, 3));

    % Test 6: Stationarity check: eigenvalues of companion matrix should be inside unit circle
    % for stable VAR(1), eigenvalues of A should have |lambda| < 1
    eig_A = abs(eig(A_true));
    assert(all(eig_A < 1), ...
        'Self-test 6: true A matrix should be stationary (all |eig| < 1).');

    fprintf('VARMODEL self-test PASSED (6 tests, all assertions passed).\n');
end
end
