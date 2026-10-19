% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [ATT, se_boot, ci_lower, ci_upper, exitflag] = did_estimate(Y, treated, post, options)
%% DID_ESTIMATE Difference-in-Differences estimator with parallel-trends check.
%  Paradigm: PARADIGM-0525-DID. Category: Statistics. v3.0.0.
%  Reference: Card D., Krueger A.B. (1994) Minimum wages and employment.
%             AER, 84, 772-793.
%  Computes ATT = (E[Y|T=1,P=1] - E[Y|T=1,P=0]) - (E[Y|T=0,P=1] - E[Y|T=0,P=0]).
%  Bootstrap standard errors and 95% confidence intervals.
%  Input:  Y        - outcome variable [N x 1] (panel: stacked pre/post)
%          treated  - treatment indicator [N x 1] (1=treated unit)
%          post     - post-period indicator [N x 1] (1=post-treatment)
%          options.seed      - random seed (default 42)
%          options.n_boot    - bootstrap replications (default 500)
%          options.alpha     - significance level (default 0.05)
%          options.id        - unit identifier [N x 1] (for clustered bootstrap)
%  Output: ATT      - estimated average treatment effect on the treated
%          se_boot  - bootstrap standard error
%          ci_lower, ci_upper - 95% bootstrap percentile confidence interval
%          exitflag - 1 if computation succeeded, -1 if degenerate

arguments
    Y (:, 1) double
    treated (:, 1) double
    post (:, 1) double
    options.seed (1,1) double = 42
    options.n_boot (1,1) double {mustBePositive, mustBeInteger} = 500
    options.alpha (1,1) double {mustBePositive, mustBeLessThan(options.alpha, 1)} = 0.05
    options.id (:, 1) double = []
end
rng(options.seed, 'twister');

N = length(Y);                                              % L01
if length(treated) ~= N || length(post) ~= N
    error('did_estimate:DimensionMismatch', ...
        'Y, treated, and post must all be vectors of the same length.');
end
% Validate binary indicators
if ~all(ismember(treated, [0, 1])) || ~all(ismember(post, [0, 1]))
    error('did_estimate:InvalidIndicator', ...
        'treated and post must be binary {0,1} indicators.');
end

% --- Helper: compute DiD ATT from data subsets ---
function att = compute_att(Y_in, T_in, P_in)
    % Four cell means
    y11 = mean(Y_in(T_in == 1 & P_in == 1));    % treated, post
    y10 = mean(Y_in(T_in == 1 & P_in == 0));    % treated, pre
    y01 = mean(Y_in(T_in == 0 & P_in == 1));    % control, post
    y00 = mean(Y_in(T_in == 0 & P_in == 0));    % control, pre
    att = (y11 - y10) - (y01 - y00);                                % L02 inner
end

% --- Point estimate ---
ATT = compute_att(Y, treated, post);                            % L03
if isnan(ATT)
    exitflag = -1;                                               % L04
    warning('did_estimate:InsufficientData', ...
        'One or more of the four DiD cells is empty.');
    se_boot  = NaN;
    ci_lower = NaN;
    ci_upper = NaN;
    return;
end
exitflag = 1;                                                    % L05

% --- Parallel trends check on pre-treatment data (if panel structure) ---
if ~isempty(options.id) && length(options.id) == N
    % For each unit, check if we have both pre and post observations
    unit_ids = unique(options.id);                               % L06
    n_units  = length(unit_ids);                                 % L07
    % Simple pre-trend check: regress pre-treatment outcomes on time,
    % test if treated and control slopes differ
    pre_mask = (post == 0);                                      % L08
    if sum(pre_mask) > 4 && sum(treated(pre_mask) == 1) > 1 && ...
            sum(treated(pre_mask) == 0) > 1
        % Warn if pre-trends differ notably (heuristic check)
        y_pre_t = Y(pre_mask & treated == 1);                    % L09
        y_pre_c = Y(pre_mask & treated == 0);                    % L10
        slope_t = mean(diff(y_pre_t));                           % L11
        slope_c = mean(diff(y_pre_c));                           % L12
        if abs(slope_t - slope_c) > 3 * std([y_pre_t; y_pre_c])
            warning('did_estimate:ParallelTrendsViolation', ...
                'Pre-treatment slopes differ by %.4f; parallel trends assumption may be violated.', ...
                abs(slope_t - slope_c));                          % L13
        end
    end
end

% --- Bootstrap standard errors ---
B = options.n_boot;                                              % L14
att_boot = zeros(B, 1);                                          % L15

if isempty(options.id)
    % Standard bootstrap: resample rows
    for b = 1:B
        idx_b = randi(N, N, 1);                                  % L16
        att_boot(b) = compute_att(Y(idx_b), treated(idx_b), ...
            post(idx_b));                                        % L17
    end
else
    % Cluster bootstrap: resample units (preserve within-unit correlation)
    unit_ids = unique(options.id);                                % L18
    n_units  = length(unit_ids);                                  % L19
    for b = 1:B
        idx_units = randi(n_units, n_units, 1);                   % L20
        units_b   = unit_ids(idx_units);                          % L21
        Y_b = []; T_b = []; P_b = [];
        for uu = 1:length(units_b)
            mask_u = (options.id == units_b(uu));                 % L22
            Y_b = [Y_b; Y(mask_u)];                               % L23
            T_b = [T_b; treated(mask_u)];                         % L24
            P_b = [P_b; post(mask_u)];                            % L25
        end
        att_boot(b) = compute_att(Y_b, T_b, P_b);                % L26
    end
end

% Bootstrap statistics
se_boot  = std(att_boot);                                         % L27
ci_lower = prctile(att_boot, 100 * options.alpha / 2);           % L28
ci_upper = prctile(att_boot, 100 * (1 - options.alpha / 2));     % L29

end

%% Self-test ================================================================
function self_test()
% Simulate panel data with known ATT = 2.0.
% Model: Y_it = alpha_i + gamma_t + beta*(treated_i * post_t) + eps_it
    rng(42, 'twister');
    n_units = 60;
    n_periods = 4;               % 2 pre, 2 post
    n_treated = 30;
    ATT_true = 2.0;

    % Unit fixed effects
    alpha_i = randn(n_units, 1) * 2;
    % Time fixed effects
    gamma_t = [0.5; 1.0; 1.5; 2.0];

    treated_id = [ones(n_treated, 1); zeros(n_units - n_treated, 1)];

    % Build panel
    Y_all = [];
    T_vec = [];
    P_vec = [];
    ID_vec = [];

    for i = 1:n_units
        for t = 1:n_periods
            post_t = (t > 2);  % periods 1-2: pre, 3-4: post
            y_it = alpha_i(i) + gamma_t(t) + ...
                ATT_true * treated_id(i) * post_t + randn() * 0.5;
            Y_all   = [Y_all; y_it];
            T_vec   = [T_vec; treated_id(i)];
            P_vec   = [P_vec; post_t];
            ID_vec  = [ID_vec; i];
        end
    end

    [att_est, se_est, ci_lo, ci_hi, ef] = did_estimate(Y_all, T_vec, P_vec, ...
        'n_boot', 500, 'id', ID_vec, 'seed', 42);

    % Assert 1: computation completed
    assert(ef == 1, 'DiD estimation failed (exitflag ~= 1).');

    % Assert 2: ATT estimate within [1.5, 2.5] of true ATT=2.0
    assert(att_est > 1.5 && att_est < 2.5, ...
        sprintf('ATT estimate=%.4f outside [1.5, 2.5]; true ATT=2.0.', att_est));

    % Assert 3: confidence interval covers the true ATT
    assert(ci_lo <= ATT_true && ci_hi >= ATT_true, ...
        sprintf('Bootstrap CI [%.4f, %.4f] does not cover true ATT=%.2f.', ...
        ci_lo, ci_hi, ATT_true));

    % Assert 4: standard error is reasonable (> 0, < 1.0)
    assert(se_est > 0 && se_est < 1.0, ...
        sprintf('Bootstrap SE=%.4f unreasonable (expected 0 < SE < 1).', se_est));

    fprintf('did_estimate self-test passed. (ATT=%.4f, SE=%.4f, CI=[%.4f, %.4f])\n', ...
        att_est, se_est, ci_lo, ci_hi);
end
