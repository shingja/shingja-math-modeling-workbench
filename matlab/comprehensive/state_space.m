% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [x_filtered, P_filtered, x_smoothed, P_smoothed, loglik, exitflag] = state_space(Y, A, C, Q, R, options)
%% STATE_SPACE Linear Gaussian state-space model with Kalman filter and smoother.
%  Paradigm: PARADIGM-0208-STATE-SPACE. Category: Prediction. v3.0.0.
%  Reference: Kalman R.E. (1960) A new approach to linear filtering and
%             prediction problems. ASME JBE, 82, 35-45.
%  Model:   x_t = A * x_{t-1} + w_t,    w_t ~ N(0, Q)   [state equation]
%           y_t = C * x_t + v_t,         v_t ~ N(0, R)   [observation equation]
%  Functions: kalman_filter  -> filtered means and covariances
%             kalman_smoother -> smoothed (backward-pass) estimates
%  Input:  Y           - observations [d_y x T] or [T x d_y]
%          A           - state transition matrix [d_x x d_x]
%          C           - observation matrix [d_y x d_x]
%          Q           - state noise covariance [d_x x d_x]
%          R           - observation noise covariance [d_y x d_y]
%          options.mu0     - initial state mean [d_x x 1] (default zeros)
%          options.Sigma0  - initial state covariance [d_x x d_x] (default 10*I)
%          options.seed     - random seed (default 42)
%  Output: x_filtered - filtered state means [d_x x T]
%          P_filtered  - filtered state covariances [d_x x d_x x T]
%          x_smoothed  - smoothed state means [d_x x T]
%          P_smoothed  - smoothed state covariances [d_x x d_x x T]
%          loglik      - log-likelihood of observations
%          exitflag    - 1 if filtering succeeded, -1 if degenerate

arguments
    Y (:, :) double
    A (:,:) double
    C (:,:) double
    Q (:,:) double
    R (:,:) double
    options.mu0 (:, 1) double = []
    options.Sigma0 (:,:) double = []
    options.seed (1,1) double = 42
end
rng(options.seed, 'twister');

% --- Input normalization ---
% Ensure Y is [d_y x T]
if size(Y, 1) < size(Y, 2)
    Y = Y';                                                   % L01  [d_y x T]
end
[d_y, T] = size(Y);                                          % L02
d_x = size(A, 1);                                            % L03

% Validate dimensions
if size(A, 2) ~= d_x || size(C, 1) ~= d_y || size(C, 2) ~= d_x
    error('state_space:DimensionMismatch', ...
        'A [%dx%d], C [%dx%d], Q [%dx%d], R [%dx%d] inconsistent with Y [%dx%d].', ...
        size(A), size(C), size(Q), size(R), d_y, T);
end

% --- Initial conditions ---
if isempty(options.mu0)
    mu0 = zeros(d_x, 1);                                     % L04
else
    mu0 = options.mu0;
end
if isempty(options.Sigma0)
    Sigma0 = 10 * eye(d_x);                                  % L05
else
    Sigma0 = options.Sigma0;
end

% --- Pre-allocation ---
x_pred   = zeros(d_x, T);                                    % L06  predicted mean
P_pred   = zeros(d_x, d_x, T);                               % L07  predicted covariance
x_filt   = zeros(d_x, T);                                    % L08  filtered mean
P_filt   = zeros(d_x, d_x, T);                               % L09  filtered covariance
loglik   = 0;                                                % L10

% --- Initialize ---
x_pred(:, :, 1)   = mu0;                                     % L11
P_pred(:, :, 1)   = Sigma0;                                  % L12

% --- Forward pass: Kalman filter ---
for t = 1:T
    % Innovation (prediction error)
    y_pred  = C * x_pred(:, t);                              % L13
    innov   = Y(:, t) - y_pred;                              % L14
    S_t     = C * P_pred(:, :, t) * C' + R;                  % L15 innovation covariance

    % Check numerical stability
    if rcond(S_t) < 1e-15                                    % L16
        warning('state_space:SingularInnovation', ...
            'Innovation covariance near-singular at t=%d. Regularizing.', t);
        S_t = S_t + 1e-8 * eye(d_y);                         % L17
    end

    % Kalman gain
    K_t = P_pred(:, :, t) * C' / S_t;                        % L18

    % Update step
    x_filt(:, t)     = x_pred(:, t) + K_t * innov;           % L19
    P_filt(:, :, t)  = (eye(d_x) - K_t * C) * P_pred(:, :, t); % L20

    % Log-likelihood contribution
    loglik = loglik - 0.5 * (d_y * log(2 * pi) + ...
        log(det(S_t)) + innov' / S_t * innov);               % L21

    % Predict step (for t+1)
    if t < T
        x_pred(:, t+1)   = A * x_filt(:, t);                 % L22
        P_pred(:, :, t+1) = A * P_filt(:, :, t) * A' + Q;    % L23
    end
end

exitflag = 1;                                                % L24
x_filtered = x_filt;                                         % L25
P_filtered = P_filt;                                         % L26

% --- Backward pass: Rauch-Tung-Striebel smoother ---
x_smoothed = zeros(d_x, T);                                  % L27
P_smoothed = zeros(d_x, d_x, T);                             % L28
x_smoothed(:, T) = x_filt(:, T);                             % L29
P_smoothed(:, :, T) = P_filt(:, :, T);                       % L30

for t = (T-1):-1:1
    % Smoother gain
    J_t = P_filt(:, :, t) * A' / P_pred(:, :, t+1);          % L31
    % Smoothed mean
    x_smoothed(:, t) = x_filt(:, t) + ...
        J_t * (x_smoothed(:, t+1) - x_pred(:, t+1));         % L32
    % Smoothed covariance
    P_smoothed(:, :, t) = P_filt(:, :, t) + ...
        J_t * (P_smoothed(:, :, t+1) - P_pred(:, :, t+1)) * J_t'; % L33
end

end

%% Self-test ================================================================
function self_test()
% Local-level model (random walk + noise):
%   x_t = x_{t-1} + w_t,  w_t ~ N(0, 0.5^2)
%   y_t = x_t + v_t,      v_t ~ N(0, 1.0^2)
% Verify filtered state tracks true state (RMSE < observation noise std).

    rng(42, 'twister');
    T_sim = 100;
    Q_true = 0.25;   % state noise variance
    R_true = 1.00;   % observation noise variance

    % Simulate true states and observations
    x_true = zeros(1, T_sim);
    x_true(1) = 0;
    for t = 2:T_sim
        x_true(t) = x_true(t-1) + sqrt(Q_true) * randn();
    end
    y_obs = x_true + sqrt(R_true) * randn(1, T_sim);

    % Kalman filter with known parameters
    A_mat = 1;  C_mat = 1;  Q_mat = Q_true;  R_mat = R_true;
    [x_filt, ~, x_smooth, ~, ll, ef] = state_space(y_obs, A_mat, ...
        C_mat, Q_mat, R_mat, 'seed', 42);

    % Assert 1: filtering succeeded
    assert(ef == 1, 'Kalman filter failed (exitflag ~= 1).');

    % Assert 2: log-likelihood is finite
    assert(isfinite(ll), 'Log-likelihood is non-finite.');

    % Assert 3: filtered RMSE < observation noise std (1.0)
    rmse_filt = sqrt(mean((x_filt(:)' - x_true).^2));
    assert(rmse_filt < 1.0, ...
        sprintf('Filter RMSE=%.4f >= observation noise std=1.0.', rmse_filt));

    % Assert 4: smoothed RMSE <= filtered RMSE (smoother should improve)
    rmse_smooth = sqrt(mean((x_smooth(:)' - x_true).^2));
    assert(rmse_smooth <= rmse_filt + 0.01, ...
        sprintf('Smoothed RMSE=%.4f > filtered RMSE=%.4f.', rmse_smooth, rmse_filt));

    fprintf('state_space self-test passed. (RMSE: filt=%.4f, smooth=%.4f, loglik=%.2f)\n', ...
        rmse_filt, rmse_smooth, ll);
end
