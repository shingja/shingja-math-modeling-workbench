% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [beta_hat, hr_hat, baseline_cumhaz, surv_pred, exitflag] = survival_cox(time, event, X, options)
%% SURVIVAL_COX Cox proportional hazards model with Breslow baseline.
%  Paradigm: PARADIGM-0524-SURVIVAL-COX. Category: Statistics. v3.0.0.
%  Reference: Cox D.R. (1972) Regression models and life-tables.
%             JRSS(B), 34, 187-220.
%  Maximizes partial likelihood via fmincon. Baseline cumulative hazard
%  via Breslow estimator.  Returns survival curve predictions.
%  Input:  time  - observed times [N x 1]
%          event - censoring indicator (1=event, 0=censored) [N x 1]
%          X     - covariate matrix [N x p]
%          options.seed     - random seed (default 42)
%          options.t_eval   - time points to evaluate survival (optional)
%  Output: beta_hat    - estimated coefficients [p x 1]
%          hr_hat      - hazard ratios exp(beta_hat)
%          baseline_cumhaz - Breslow baseline cumulative hazard [unique times]
%          surv_pred   - predicted survival probabilities [N x length(t_eval)]
%          exitflag    - 1 converged, 0 max-iter, -1 failed

arguments
    time (:, 1) double {mustBePositive}
    event (:, 1) double
    X (:, :) double
    options.seed (1,1) double = 42
    options.t_eval (:, 1) double = []
end
rng(options.seed, 'twister');

[N, p] = size(X);                                           % L01
if length(time) ~= N || length(event) ~= N
    error('survival_cox:DimensionMismatch', ...
        'time, event, and rows of X must all have length N.');
end
% Validate that event is binary {0, 1}
if ~all(ismember(event, [0, 1]))
    error('survival_cox:InvalidEvent', ...
        'event must be binary (0=censored, 1=event).');
end

% --- Sort data by observed time (ascending) ---
[time_sorted, idx_sort] = sort(time);                       % L02
event_sorted = event(idx_sort);                             % L03
X_sorted     = X(idx_sort, :);                              % L04

% --- Negative log partial likelihood ---
function nll = neg_log_pl(b)
    eb = exp(X_sorted * b);                                 % L05 inner, [N x 1]
    cum_eb = flipud(cumsum(flipud(eb)));                    % L06 inner, sum over risk set
    log_risk = log(cum_eb);                                 % L07 inner
    nll = -sum(event_sorted .* (X_sorted * b - log_risk));  % L08 inner
end

% --- Initial guess and optimization ---
beta_init = zeros(p, 1);                                    % L05
opts = optimoptions('fmincon', 'Display', 'off', ...
    'Algorithm', 'sqp', 'MaxIterations', 2000, ...
    'SpecifyObjectiveGradient', false);                     % L06

[beta_hat, nll_val, ef_fmin] = fmincon(@neg_log_pl, beta_init, ...
    [], [], [], [], [], [], [], opts);                      % L07

if ef_fmin <= 0
    exitflag = -1;                                          % L08
    warning('survival_cox:NotConverged', ...
        'fmincon exitflag=%d; partial likelihood may not have converged.', ef_fmin);
else
    exitflag = 1;                                           % L09
end
hr_hat = exp(beta_hat);                                     % L10

% --- Breslow baseline cumulative hazard ---
unique_times = unique(time_sorted(event_sorted == 1));      % L11 event times only
n_unique = length(unique_times);                            % L12
baseline_cumhaz = zeros(n_unique, 1);                       % L13
eb_full = exp(X_sorted * beta_hat);                         % L14

for u = 1:n_unique
    t_u = unique_times(u);                                  % L15
    at_risk = (time_sorted >= t_u);                         % L16
    denom = sum(eb_full(at_risk));                          % L17
    events_at_t = (time_sorted == t_u) & (event_sorted == 1); % L18
    d_t = sum(events_at_t);                                 % L19
    if denom > 0 && d_t > 0
        baseline_cumhaz(u) = d_t / denom;                   % L20
    end
end
baseline_cumhaz = cumsum(baseline_cumhaz);                  % L21

% --- Predict survival curves ---
if isempty(options.t_eval)
    t_eval = unique_times;                                  % L22
else
    t_eval = options.t_eval;                                % L23
end
n_eval = length(t_eval);                                    % L24
surv_pred = zeros(N, n_eval);                               % L25

for i_eval = 1:n_eval
    t_star = t_eval(i_eval);                                % L26
    % Baseline cumulative hazard at t_star (interpolate)
    if t_star < unique_times(1)
        H0_t = 0;                                           % L27
    else
        idx_t = find(unique_times <= t_star, 1, 'last');    % L28
        H0_t = baseline_cumhaz(idx_t);                      % L29
    end
    surv_pred(:, i_eval) = exp(-H0_t * eb_full);            % L30
end

end

%% Self-test ================================================================
function self_test()
% Simulate 2-group dataset (treatment vs control).
% Control:   hazard = 1.0 (baseline)
% Treatment: hazard = 0.4  (HR = 0.4, beta = log(0.4) ≈ -0.9163)
    rng(42, 'twister');
    N_subj = 100;
    group   = [zeros(N_subj/2, 1); ones(N_subj/2, 1)];     % 0=control, 1=treatment
    hazard  = ones(N_subj, 1);
    hazard(group == 1) = 0.4;                               % treatment hazard reduced

    % Generate exponential survival times
    surv_time = exprnd(1 ./ hazard);
    % Uniform censoring at 3.0 (approx)
    censor_time = 3.0 * rand(N_subj, 1);
    obs_time = min(surv_time, censor_time);
    evt = (surv_time <= censor_time);

    [b_hat, hr_hat, ~, ~, ef] = survival_cox(obs_time, evt, group);

    % Assert 1: model must converge
    assert(ef == 1, 'Cox PH model failed to converge.');

    % Assert 2: hazard ratio significantly different from 1.0
    assert(abs(hr_hat - 1.0) > 0.15, ...
        sprintf('Hazard ratio=%.4f too close to 1.0; expected ~0.4.', hr_hat));

    % Assert 3: beta_hat should be negative (treatment reduces hazard)
    assert(b_hat < -0.3, ...
        sprintf('beta_hat=%.4f; expected negative (treatment protective).', b_hat));

    % Compute Wald-type p-value via numerical Hessian
    h = 1e-4;
    f0 = partial_nll(b_hat, obs_time, evt, group);
    f_right = partial_nll(b_hat + h, obs_time, evt, group);
    f_left  = partial_nll(b_hat - h, obs_time, evt, group);
    hess_approx = (f_right - 2*f0 + f_left) / h^2;
    se_beta = 1 / sqrt(abs(hess_approx) + 1e-8);
    wald_z = b_hat / se_beta;
    wald_p = 2 * (1 - normcdf(abs(wald_z)));

    % Assert 4: Wald p-value < 0.05 (log-rank equivalent)
    assert(wald_p < 0.05, ...
        sprintf('Wald p=%.6f >= 0.05; treatment effect not significant.', wald_p));

    fprintf('survival_cox self-test passed. (beta=%.4f, HR=%.4f, Wald-p=%.6f)\n', ...
        b_hat, hr_hat, wald_p);
end

function nll = partial_nll(b, t, e, X)
% Helper: negative log partial likelihood for numerical Hessian
    [t_s, idx] = sort(t);
    e_s = e(idx);
    X_s = X(idx);
    eb = exp(X_s * b);
    cum_eb = flipud(cumsum(flipud(eb)));
    nll = -sum(e_s .* (X_s * b - log(cum_eb)));
end
