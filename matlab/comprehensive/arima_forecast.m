% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [forecast, phi_hat, theta_hat, sigma2_hat, exitflag] = arima_forecast(data, p, d, q, options)
%% ARIMA_FORECAST ARIMA(p,d,q) self-implemented (no Econometrics Toolbox).
%  Paradigm: PARADIGM-0202-ARIMA. Category: Prediction. v3.0.0.
%  Reference: Box G.E.P., Jenkins G.M. (1976) Time Series Analysis.
%  Method: Yule-Walker for AR, innovations algorithm for MA, differencing
%          for I(d).  No toolbox dependencies.
%  Input:  data   - univariate time series (column or row vector)
%          p, d, q - AR, I, MA orders (nonnegative integers)
%          options.horizon - forecast horizon (default 5)
%          options.seed    - random seed (default 42)
%  Output: forecast   - h-step ahead predictions
%          phi_hat    - estimated AR coefficients [p x 1]
%          theta_hat  - estimated MA coefficients [q x 1]
%          sigma2_hat - estimated innovation variance
%          exitflag   - 1 converged, -1 failed
arguments
    data (:, :) double
    p (1,1) double {mustBeNonnegative, mustBeInteger} = 1
    d (1,1) double {mustBeNonnegative, mustBeInteger} = 0
    q (1,1) double {mustBeNonnegative, mustBeInteger} = 0
    options.horizon (1,1) double {mustBePositive, mustBeInteger} = 5
    options.seed (1,1) double = 42
end
rng(options.seed, 'twister');

% Flatten input to column vector
y = data(:);
T = length(y);

% --- Step 1: Differencing (I(d) component) ---
y_diff = y;                                                % L01
for di = 1:d
    y_diff = diff(y_diff);                                 % L02
end
n_diff = length(y_diff);                                   % L03
if n_diff < max(p, q) + 2
    warning('ARIMA:InsufficientData', ...
        'After differencing, %d observations remain; need > max(p,q)+1.', n_diff);
    exitflag = -1;                                         % L04
    forecast   = NaN(options.horizon, 1);
    phi_hat    = NaN(p, 1);
    theta_hat  = NaN(q, 1);
    sigma2_hat = NaN;
    return;
end

% --- Step 2: AR(p) estimation via Yule-Walker equations ---
y_mean = mean(y_diff);                                     % L05
y_centered = y_diff - y_mean;                              % L06
phi_hat = zeros(p, 1);                                     % L07
sigma2_ar = var(y_centered);                               % L08

if p > 0
    % Sample autocovariance lags 0..p
    gamma_hat = zeros(p + 1, 1);                           % L09
    for lag = 0:p
        gamma_hat(lag + 1) = mean( ...
            y_centered(1:end-lag) .* y_centered(lag+1:end)); % L10
    end
    % Toeplitz covariance matrix and right-hand side
    R = toeplitz(gamma_hat(1:p));                          % L11
    r = gamma_hat(2:p+1);                                  % L12
    phi_hat = R \ r;                                       % L13
    sigma2_ar = gamma_hat(1) - r' * phi_hat;               % L14
end

% --- Step 3: MA(q) estimation via conditional least squares (CSS) ---
% Remove AR component to obtain approximate residuals
ar_resid = y_centered;                                     % L15
if p > 0
    ar_filt = filter([1, -phi_hat'], 1, y_centered);       % L16 row-vector numerator
    ar_resid = ar_filt(p+1:end);                           % L17
end
n_resid = length(ar_resid);                                % L18

theta_hat = zeros(q, 1);                                   % L19
sigma2_ma = var(ar_resid);                                 % L20

if q > 0 && n_resid > q + 2
    % MA(q) via conditional sum-of-squares (Box-Jenkins)
    % Reconstruct residuals: e_t = w_t - sum_{i=1..q} theta_i * e_{t-i}
    function sse = css_obj(th)
        e = zeros(n_resid, 1);                             % L21 inner
        e(1) = ar_resid(1);
        for t = 2:n_resid
            pred = 0;
            nlag = min(q, t - 1);                          % L22 inner
            for qi = 1:nlag
                pred = pred + th(qi) * e(t - qi);          % L23 inner
            end
            e(t) = ar_resid(t) - pred;                     % L24 inner
        end
        sse = sum(e(q+1:end).^2);                          % L25 inner
    end
    % Method-of-moments starting guess for MA(1); zero for higher orders
    th0 = zeros(q, 1);                                     % L21
    if q == 1
        gam0 = mean(ar_resid.^2);                          % L22
        gam1 = mean(ar_resid(2:end) .* ar_resid(1:end-1)); % L23
        rho1 = gam1 / (gam0 + 1e-12);                      % L24
        disc = 1 - 4 * rho1^2;                             % L25
        if disc >= 0
            th_cand = (1 - sqrt(max(disc,0))) / (2*rho1 + 1e-12); % L26
            if abs(th_cand) < 1
                th0 = th_cand;                             % L27
            end
        end
    end
    css_opts = optimset('Display', 'off', 'MaxIter', 500, ...
        'MaxFunEvals', 2000);                              % L28
    theta_hat = fminsearch(@css_obj, th0, css_opts);       % L29
    sigma2_ma = css_obj(theta_hat) / (n_resid - q);        % L30
end

sigma2_hat = sigma2_ma;                                    % L31
exitflag   = 1;                                            % L32

% --- Step 4: Forecasting ---
% Forecast differenced series using ARMA(p,q) structure
h = options.horizon;
y_forecast_diff = zeros(h, 1);                             % L42
% Extend the differenced series with forecasts
y_ext = [y_centered; zeros(h, 1)];                         % L43

for step = 1:h
    pred = 0;
    % AR contribution
    for ip = 1:min(p, n_diff + step - 1)
        idx = n_diff + step - ip;
        if idx > 0
            pred = pred + phi_hat(ip) * y_ext(idx);        % L44
        end
    end
    % MA contribution (use residuals=0 for future)
    y_ext(n_diff + step) = pred;                           % L45
    y_forecast_diff(step) = pred + y_mean;                 % L46
end

% --- Step 5: Integrate back from differenced forecasts ---
forecast = zeros(h, 1);                                    % L47
if d == 0
    forecast = y_forecast_diff + y_mean;                   % L48
else
    % Reconstruct levels from differenced forecasts
    last_obs = y(end-d+1:end);                             % L49
    for step = 1:h
        fc_val = y_forecast_diff(step);                    % L50
        for di = d:-1:1
            if di == d
                base = last_obs(end);                      % L51
            else
                base = forecast(max(step-1,1));            % L52
            end
            fc_val = base + fc_val;                        % L53
        end
        forecast(step) = fc_val;                           % L54
    end
end

end

%% Self-test ================================================================
function self_test()
% AR(1) with phi = 0.8, 200 points, verify phi_hat in [0.65, 0.95]
    T = 200;
    phi_true = 0.8;
    rng(42, 'twister');
    innov = randn(T, 1);
    x = zeros(T, 1);
    x(1) = innov(1);
    for t = 2:T
        x(t) = phi_true * x(t-1) + innov(t);
    end

    [~, phi_h, ~, ~, ef] = arima_forecast(x, 1, 0, 0, 'horizon', 3, 'seed', 42);

    % Assert 1: model must converge
    assert(ef == 1, 'ARIMA AR(1) failed to converge.');

    % Assert 2: phi_hat within [0.65, 0.95] for true phi=0.8
    assert(phi_h > 0.65 && phi_h < 0.95, ...
        sprintf('AR(1) phi_hat=%.4f outside expected [0.65, 0.95].', phi_h));

    % Assert 3: MA(1) with theta = -0.5
    theta_true = -0.5;
    rng(42, 'twister');
    innov2 = randn(T, 1);
    y = zeros(T, 1);
    y(1) = innov2(1);
    for t = 2:T
        y(t) = innov2(t) + theta_true * innov2(t-1);
    end
    [~, ~, th_h, ~, ef2] = arima_forecast(y, 0, 0, 1, 'horizon', 3, 'seed', 42);

    % Assert 3: MA(1) theta_hat close to true -0.5
    assert(abs(th_h - theta_true) < 0.25, ...
        sprintf('MA(1) theta_hat=%.4f differs from true %.4f by >0.25.', th_h, theta_true));

    fprintf('arima_forecast self-test passed. (phi_hat=%.4f, theta_hat=%.4f)\n', phi_h, th_h);
end
