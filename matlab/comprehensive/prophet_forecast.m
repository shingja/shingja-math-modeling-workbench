% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [result] = prophet_forecast(data, options)
%% PROPHET_FORECAST Simplified Prophet: piecewise linear trend + Fourier seasonality. Paradigm: PARADIGM-0207-PROPHET. v3.0.0.
%   trend(t) = (k + a(t)*delta)*t + (m + a(t)*gamma)
%   seasonality via sin/cos Fourier terms.
%   Fit via L-BFGS-style gradient descent with line search.
%
%   Inputs:
%       data      - Nx2 matrix [t, y] of time series observations
%       options.trend_changepoints - vector of changepoint indices (default: [])
%       options.fourier_order      - number of Fourier pairs (default: 5)
%       options.period             - seasonality period (default: 365.25)
%       options.learning_rate      - initial learning rate (default: 0.01)
%       options.max_iter           - max iterations (default: 200)
%       options.tol                - convergence tolerance (default: 1e-6)
%       options.seed               - random seed (default: 42)
%
%   Outputs:
%       result.trend_params    - [k, m] base trend parameters
%       result.delta           - changepoint slope adjustments
%       result.gamma           - changepoint offset adjustments
%       result.fourier_coeffs   - [a1,b1, a2,b2, ...] Fourier coefficients
%       result.y_hat           - fitted values
%       result.exitflag        - convergence flag (1=converged, -1=not converged)
%       result.loss_history    - loss values per iteration

arguments
    data (:, 2) double
    options.trend_changepoints (1, :) double = []
    options.fourier_order (1,1) double {mustBePositive, mustBeInteger} = 5
    options.period (1,1) double {mustBePositive} = 365.25
    options.learning_rate (1,1) double {mustBePositive} = 0.01
    options.max_iter (1,1) double {mustBePositive, mustBeInteger} = 200
    options.tol (1,1) double {mustBePositive} = 1e-6
    options.seed (1,1) double = 42
end

rng(options.seed, 'twister');

% Extract time and observations
t = data(:, 1);
y = data(:, 2);
N_data = length(t);

% Normalize time to [0, 1] for numerical stability
t_min = min(t);
t_max = max(t);
t_norm = (t - t_min) / (t_max - t_min);

% Setup changepoints
s = options.trend_changepoints;
if isempty(s)
    n_cp = 0;
else
    n_cp = length(s);
    s_norm = (s - t_min) / (t_max - t_min);
end

% Setup Fourier seasonality
K = options.fourier_order;
P = options.period;
n_fourier = 2 * K;

% Build Fourier design matrix
X_fourier = zeros(N_data, n_fourier);
for k_idx = 1:K
    X_fourier(:, 2*k_idx-1) = sin(2 * pi * k_idx * t / P);
    X_fourier(:, 2*k_idx)   = cos(2 * pi * k_idx * t / P);
end

% Total number of parameters: k, m, delta(1:n_cp), gamma(1:n_cp), fourier(1:n_fourier)
n_params = 2 + 2 * n_cp + n_fourier;

% Initialize parameters
k_init = (y(end) - y(1)) / (t_norm(end) - t_norm(1));
m_init = y(1);
params = zeros(n_params, 1);
params(1) = k_init;
params(2) = m_init;

% Precompute A(t) indicator matrix for changepoints
A_mat = zeros(N_data, n_cp);
if n_cp > 0
    for j = 1:n_cp
        A_mat(:, j) = double(t >= s(j));
    end
end

% Objective function: compute predictions and MSE loss
    function [loss, grad] = compute_loss_grad(p)
        k_val = p(1);
        m_val = p(2);

        % Trend component
        trend = k_val * t_norm + m_val;

        if n_cp > 0
            delta_vec = p(3:(2+n_cp));
            gamma_vec = p((3+n_cp):(2+2*n_cp));

            % trend(t) = (k + a(t)*delta)*t + (m + a(t)*gamma)
            for j_cp = 1:n_cp
                trend = trend + delta_vec(j_cp) * A_mat(:, j_cp) .* t_norm + ...
                                gamma_vec(j_cp) * A_mat(:, j_cp);
            end
        end

        % Fourier seasonality
        fourier_coeffs = p((2+2*n_cp+1):end);
        seasonal = X_fourier * fourier_coeffs;

        % Predicted values
        y_pred = trend + seasonal;

        % Residuals
        residuals = y_pred - y;
        loss = 0.5 * mean(residuals .^ 2);

        % --- Gradient computation ---
        grad = zeros(n_params, 1);
        grad(1) = mean(residuals .* t_norm);              % dL/dk
        grad(2) = mean(residuals);                         % dL/dm

        if n_cp > 0
            for j_cp = 1:n_cp
                grad(2 + j_cp) = mean(residuals .* A_mat(:, j_cp) .* t_norm);  % dL/d(delta_j)
                grad(2 + n_cp + j_cp) = mean(residuals .* A_mat(:, j_cp));     % dL/d(gamma_j)
            end
        end

        for f_idx = 1:n_fourier
            grad(2 + 2*n_cp + f_idx) = mean(residuals .* X_fourier(:, f_idx));
        end
    end

% Gradient descent with Armijo line search
lr = options.learning_rate;
loss_history = zeros(options.max_iter, 1);
prev_loss = inf;
exitflag = -1;

for iter = 1:options.max_iter
    [current_loss, grad] = compute_loss_grad(params);
    loss_history(iter) = current_loss;

    % Armijo backtracking line search
    step = lr;
    alpha_armijo = 0.5;
    beta_armijo = 0.8;
    grad_norm_sq = grad' * grad;

    for backtrack = 1:20
        params_trial = params - step * grad;
        loss_trial = compute_loss_grad(params_trial);
        if loss_trial <= current_loss - alpha_armijo * step * grad_norm_sq
            break;
        end
        step = step * beta_armijo;
    end

    % Update parameters
    params = params - step * grad;

    % Convergence check
    rel_change = abs(current_loss - prev_loss) / (abs(prev_loss) + 1e-10);
    if rel_change < options.tol
        exitflag = 1;
        loss_history = loss_history(1:iter);
        break;
    end
    prev_loss = current_loss;
end

if exitflag < 0
    warning('PROPHET:NotConverged', ...
        'Prophet fitting did not converge within %d iterations. Final loss: %.6e', ...
        options.max_iter, loss_history(end));
end

% --- Package results ---
result.trend_params = [params(1), params(2)];  % [k, m]
result.delta = [];
result.gamma = [];
if n_cp > 0
    result.delta = params(3:(2+n_cp));
    result.gamma = params((3+n_cp):(2+2*n_cp));
end
result.fourier_coeffs = params((2+2*n_cp+1):end);

% Final predictions
k_val = params(1);
m_val = params(2);
trend_final = k_val * t_norm + m_val;
if n_cp > 0
    for j_cp = 1:n_cp
        trend_final = trend_final + result.delta(j_cp) * A_mat(:, j_cp) .* t_norm + ...
                                   result.gamma(j_cp) * A_mat(:, j_cp);
    end
end
seasonal_final = X_fourier * result.fourier_coeffs;
result.y_hat = trend_final + seasonal_final;
result.exitflag = exitflag;
result.loss_history = loss_history;
result.t_trend = result.trend_params(1);

% Denormalize trend slope to original time scale
result.trend_slope_original = result.trend_params(1) / (t_max - t_min);

%% Self-test
    function self_test()
        fprintf('Running prophet_forecast self-test...\n');

        % Generate synthetic data: y = 2*t + 5*sin(2*pi*t/12) + noise
        t_test = (1:120)';
        rng(42, 'twister');
        y_true = 2 * t_test + 5 * sin(2 * pi * t_test / 12) + 0.3 * randn(120, 1);
        data_test = [t_test, y_true];

        opts_test.period = 12;
        opts_test.fourier_order = 3;
        opts_test.max_iter = 300;
        opts_test.learning_rate = 0.1;
        opts_test.tol = 1e-8;
        opts_test.seed = 42;

        r = prophet_forecast(data_test, opts_test);

        % Assert 1: trend slope near 2.0
        slope = r.trend_slope_original;
        assert(abs(slope - 2.0) < 0.5, ...
            'Prophet self-test FAIL: trend slope %.3f not near 2.0', slope);

        % Assert 2: seasonal amplitude near 5.0
        % Reconstruct seasonal component
        t_norm_test = (t_test - min(t_test)) / (max(t_test) - min(t_test));
        K_test = opts_test.fourier_order;
        P_test = opts_test.period;
        Xf_test = zeros(120, 2*K_test);
        for kk = 1:K_test
            Xf_test(:, 2*kk-1) = sin(2*pi*kk*t_test/P_test);
            Xf_test(:, 2*kk)   = cos(2*pi*kk*t_test/P_test);
        end
        seasonal_recon = Xf_test * r.fourier_coeffs(:);
        seasonal_amplitude = (max(seasonal_recon) - min(seasonal_recon)) / 2;
        assert(abs(seasonal_amplitude - 5.0) < 2.0, ...
            'Prophet self-test FAIL: seasonal amplitude %.3f not near 5.0', seasonal_amplitude);

        % Assert 3: convergence achieved
        assert(r.exitflag == 1, ...
            'Prophet self-test FAIL: exitflag ~= 1 (not converged)');

        % Assert 4: loss decreased monotonically at macro level
        assert(r.loss_history(1) > r.loss_history(end), ...
            'Prophet self-test FAIL: loss did not decrease');

        disp('prophet_forecast self-test passed.');
    end

self_test();
end
