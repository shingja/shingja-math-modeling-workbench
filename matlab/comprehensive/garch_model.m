% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [omega_hat, alpha_hat, beta_hat, sigma2_path, exitflag] = garch_model(returns, options)
%% GARCH_MODEL GARCH(1,1) volatility model with MLE via fmincon.
%  Paradigm: PARADIGM-0209-GARCH. Category: Prediction. v3.0.0.
%  Reference: Bollerslev T. (1986) Generalized autoregressive conditional
%             heteroskedasticity. Journal of Econometrics, 31, 307-327.
%  Model:   sigma_t^2 = omega + alpha * r_{t-1}^2 + beta * sigma_{t-1}^2
%           r_t = sigma_t * epsilon_t,  epsilon_t ~ N(0,1)
%  Estimation: maximum likelihood via fmincon with stationarity constraint.
%  Input:  returns  - demeaned return series (vector)
%          options.seed      - random seed (default 42)
%          options.simulate  - if true, simulate GARCH data from params
%          options.omega0    - true omega for simulation
%          options.alpha0    - true alpha for simulation
%          options.beta0     - true beta  for simulation
%          options.T         - simulation length
%  Output: omega_hat, alpha_hat, beta_hat - estimated GARCH(1,1) parameters
%          sigma2_path  - estimated conditional variance series
%          exitflag     - 1 converged, 0 max-iter, -1 failed

arguments
    returns (:, :) double = []
    options.seed (1,1) double = 42
    options.simulate (1,1) logical = false
    options.omega0 (1,1) double = 0.10
    options.alpha0 (1,1) double = 0.30
    options.beta0  (1,1) double = 0.60
    options.T (1,1) double {mustBePositive, mustBeInteger} = 500
end
rng(options.seed, 'twister');

% --- Simulation mode: generate data from known GARCH(1,1) parameters ---
if options.simulate || isempty(returns)
    omega0 = options.omega0;                                % L01
    alpha0 = options.alpha0;                                % L02
    beta0  = options.beta0;                                 % L03
    if alpha0 + beta0 >= 1
        warning('GARCH:NonStationary', ...
            'True alpha+beta=%.3f >= 1; process may be nonstationary.', alpha0+beta0);
    end
    T_sim = options.T;                                      % L04
    sigma2_sim = zeros(T_sim, 1);                           % L05
    sigma2_sim(1) = omega0 / (1 - alpha0 - beta0);         % L06
    r_sim = zeros(T_sim, 1);                                % L07
    r_sim(1) = sqrt(sigma2_sim(1)) * randn();               % L08
    for t = 2:T_sim
        sigma2_sim(t) = omega0 + alpha0 * r_sim(t-1)^2 + ...
            beta0 * sigma2_sim(t-1);                        % L09
        r_sim(t) = sqrt(sigma2_sim(t)) * randn();           % L10
    end
    returns = r_sim - mean(r_sim);                          % L11
end

returns = returns(:);
T = length(returns);

% --- MLE objective: negative log-likelihood ---
function nll = neg_loglik(params)
    om = params(1);                                        % L12 inner
    al = params(2);
    be = params(3);
    sig2 = zeros(T, 1);
    sig2(1) = var(returns);                                % L13 inner
    nll = 0.5 * log(2 * pi) + 0.5 * log(sig2(1)) + ...
        0.5 * returns(1)^2 / sig2(1);                      % L14 inner
    for t = 2:T
        sig2(t) = om + al * returns(t-1)^2 + be * sig2(t-1); % L15 inner
        if sig2(t) <= 1e-12
            sig2(t) = 1e-12;                               % L16 inner
        end
        nll = nll + 0.5 * log(2 * pi) + 0.5 * log(sig2(t)) + ...
            0.5 * returns(t)^2 / sig2(t);                  % L17 inner
    end
end

% --- Constraints for fmincon ---
% Stationarity: alpha + beta < 1;  positivity: omega > 0, alpha >= 0, beta >= 0
lb = [1e-8; 0; 0];                                         % L12
ub = [5; 0.999; 0.999];                                    % L13
% Nonlinear inequality constraint: alpha + beta <= 0.9999
% fmincon expects [c, ceq] with c <= 0, ceq == 0
nonlcon = @(p) deal(p(2) + p(3) - 0.9999, []);             % L14
x0 = [var(returns)*0.1; 0.1; 0.7];                         % L15

opts = optimoptions('fmincon', 'Display', 'off', ...
    'Algorithm', 'sqp', 'MaxIterations', 1000, ...
    'OptimalityTolerance', 1e-8, 'StepTolerance', 1e-12);  % L16

[params_opt, ~, ef_fmin, output] = fmincon(@neg_loglik, x0, ...
    [], [], [], [], lb, ub, nonlcon, opts);                % L17

omega_hat = params_opt(1);                                 % L18
alpha_hat = params_opt(2);                                 % L19
beta_hat  = params_opt(3);                                 % L20

% Map fmincon exitflag to our convention
if ef_fmin > 0
    exitflag = 1;                                          % L21
elseif ef_fmin == 0
    exitflag = 0;                                          % L22
else
    exitflag = -1;                                         % L23
    warning('GARCH:NotConverged', ...
        'fmincon exitflag=%d; estimates may be unreliable.', ef_fmin);
end

% --- Reconstruct fitted volatility path ---
sigma2_path = zeros(T, 1);                                 % L24
sigma2_path(1) = var(returns);                             % L25
for t = 2:T
    sigma2_path(t) = omega_hat + alpha_hat * returns(t-1)^2 + ...
        beta_hat * sigma2_path(t-1);                       % L26
end

end

%% Self-test ================================================================
function self_test()
% Simulate GARCH(1,1) with known omega=0.1, alpha=0.3, beta=0.6
% then verify estimates within 0.15 of true values (seed=42)
    [om_h, al_h, be_h, ~, ef] = garch_model([], ...
        'simulate', true, 'omega0', 0.10, 'alpha0', 0.30, ...
        'beta0', 0.60, 'T', 500, 'seed', 42);

    % Assert 1: model must converge
    assert(ef == 1, 'GARCH MLE failed to converge (exitflag ~= 1).');

    % Assert 2: omega estimate within 0.15 of true 0.10
    assert(abs(om_h - 0.10) < 0.15, ...
        sprintf('omega_hat=%.4f differs from 0.10 by >0.15.', om_h));

    % Assert 3: alpha estimate within 0.15 of true 0.30
    assert(abs(al_h - 0.30) < 0.15, ...
        sprintf('alpha_hat=%.4f differs from 0.30 by >0.15.', al_h));

    % Assert 4: beta estimate within 0.15 of true 0.60
    assert(abs(be_h - 0.60) < 0.15, ...
        sprintf('beta_hat=%.4f differs from 0.60 by >0.15.', be_h));

    fprintf('garch_model self-test passed. (omega=%.4f, alpha=%.4f, beta=%.4f)\n', ...
        om_h, al_h, be_h);
end
