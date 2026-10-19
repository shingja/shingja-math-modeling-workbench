% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [wilks_lambda, pillai_trace, hotelling_trace, p_value, exitflag] = manova_test(data, group, options)
%% MANOVA_TEST One-way MANOVA with Wilks Lambda, Pillai, Hotelling-Lawley.
%  Paradigm: PARADIGM-0513-MANOVA. Category: Statistics. v3.0.0.
%  Reference: Wilks S.S. (1932) Certain generalizations in the analysis
%             of variance. Biometrika, 24, 471-494.
%  Computes between-group and within-group SSCP matrices, then derives
%  Wilks Lambda, Pillai's trace, and Hotelling-Lawley trace statistics.
%  Approximate F-test and p-value via Rao's F-approximation.
%  Input:  data  - observations [N x p] matrix
%          group - group labels [N x 1] integer vector (1..k)
%          options.seed   - random seed (default 42)
%  Output: wilks_lambda, pillai_trace, hotelling_trace - test statistics
%          p_value  - approximate p-value for Wilks Lambda
%          exitflag - 1 if computation completed, -1 if degenerate

arguments
    data (:, :) double
    group (:, 1) double
    options.seed (1,1) double = 42
end
rng(options.seed, 'twister');

[N, p] = size(data);                                        % L01
if length(group) ~= N
    error('manova_test:DimensionMismatch', ...
        'Number of rows in data (%d) must match length of group (%d).', N, length(group));
end

% Unique groups and counts
grp_ids = unique(group);                                    % L02
k = length(grp_ids);                                        % L03
if k < 2
    error('manova_test:InsufficientGroups', ...
        'At least 2 groups required; got %d.', k);
end

% --- Compute group means and grand mean ---
grand_mean   = mean(data, 1)';                              % L04, [p x 1]
group_means  = zeros(p, k);                                 % L05
group_counts = zeros(k, 1);                                 % L06
for g = 1:k
    idx_g          = (group == grp_ids(g));                 % L07
    group_counts(g) = sum(idx_g);                           % L08
    group_means(:, g) = mean(data(idx_g, :), 1)';           % L09
end

% --- SSCP matrices ---
SS_within  = zeros(p, p);                                   % L10
SS_between = zeros(p, p);                                   % L11

for g = 1:k
    idx_g = (group == grp_ids(g));                          % L12
    n_g   = group_counts(g);                                % L13
    % Centered data within group g
    Dg = data(idx_g, :) - group_means(:, g)';               % L14
    SS_within = SS_within + Dg' * Dg;                       % L15
    % Between-group contribution
    diff_b = group_means(:, g) - grand_mean;                % L16
    SS_between = SS_between + n_g * (diff_b * diff_b');     % L17
end

SS_total = SS_within + SS_between;                          % L18

% --- Check for degeneracy ---
if rcond(SS_within) < 1e-14                                 % L19
    warning('MANOVA:SingularWithin', ...
        'SS_within is near-singular; results may be unreliable.');
    exitflag = -1;                                          % L20
    wilks_lambda   = NaN;
    pillai_trace   = NaN;
    hotelling_trace = NaN;
    p_value        = NaN;
    return;
end
exitflag = 1;                                               % L21

% --- Test statistics ---
E = SS_within;                                              % L22
H = SS_between;                                             % L23
T_mat = E + H;                                              % L24

% Wilks Lambda = det(E) / det(E+H) = prod of 1/(1+lambda_i)
wilks_lambda = det(E) / det(T_mat);                         % L25

% Pillai's trace = trace(H * (E+H)^{-1}) = sum lambda_i/(1+lambda_i)
pillai_trace = trace(H / T_mat);                            % L26

% Hotelling-Lawley trace = trace(H * E^{-1}) = sum lambda_i
hotelling_trace = trace(H / E);                             % L27

% --- Rao's F-approximation for Wilks Lambda (p-value) ---
s = min(p, k - 1);                                          % L28  (s = rank(H))
nu_e = N - k;                                               % L29  (error df)
nu_h = k - 1;                                               % L30  (hypothesis df)
% Rao's F approximation (Bartlett's formula)
m_num = nu_e + nu_h - (p + nu_h + 1) / 2;                  % L31
lambda_root = wilks_lambda ^ (1 / s);                       % L32
if abs(1 - lambda_root) < 1e-15
    F_approx = Inf;                                         % L33
else
    F_approx = ((1 - lambda_root) / lambda_root) * ...
        (m_num * s - p * nu_h / 2 + 1) / (p * nu_h);       % L34
end
df1 = p * nu_h;                                             % L35
df2 = m_num * s - p * nu_h / 2 + 1;                         % L36
% Approximate p-value from F-distribution
if isfinite(F_approx) && df2 > 0
    p_value = 1 - fcdf(F_approx, df1, df2);                 % L37
else
    p_value = 0;                                            % L38
end

end

%% Self-test ================================================================
function self_test()
% Generate 3 groups x 2 variables with known separation.
% Groups 1 and 3 are well separated; Group 2 sits in between.
    rng(42, 'twister');
    N_per_group = 20;

    % Group 1: centered at (0, 0)
    X1 = randn(N_per_group, 2) + [0, 0];
    % Group 2: centered at (1.5, 1.5)
    X2 = randn(N_per_group, 2) + [1.5, 1.5];
    % Group 3: centered at (3.0, 0.0)
    X3 = randn(N_per_group, 2) + [3.0, 0.0];

    data_all = [X1; X2; X3];
    grp_all  = [ones(N_per_group,1); 2*ones(N_per_group,1); 3*ones(N_per_group,1)];

    [wl_sep, pt_sep, ht_sep, pv_sep, ef_sep] = manova_test(data_all, grp_all);

    % Assert 1: computation completed
    assert(ef_sep == 1, 'MANOVA failed on separated-groups test.');

    % Assert 2: Wilks Lambda p-value < 0.05 for well-separated groups
    assert(pv_sep < 0.05, ...
        sprintf('MANOVA separated-groups p=%.6f; expected <0.05.', pv_sep));

    % Assert 3: Wilks Lambda should be small (< 0.5) for separated groups
    assert(wl_sep < 0.5, ...
        sprintf('Wilks Lambda=%.4f for separated groups; expected <0.5.', wl_sep));

    % Now test with mixed (null) groups — all from same distribution
    X_mixed = randn(3 * N_per_group, 2);
    grp_mixed = [ones(N_per_group,1); 2*ones(N_per_group,1); 3*ones(N_per_group,1)];
    [wl_mixed, ~, ~, pv_mixed, ef_mixed] = manova_test(X_mixed, grp_mixed);

    % Assert 4: p-value > 0.05 for mixed groups (null hypothesis unlikely to be rejected)
    assert(pv_mixed > 0.05, ...
        sprintf('MANOVA mixed-groups p=%.6f unexpectedly <0.05.', pv_mixed));

    fprintf('manova_test self-test passed. (sep: WL=%.4f p=%.6f | mix: WL=%.4f p=%.6f)\n', ...
        wl_sep, pv_sep, wl_mixed, pv_mixed);
end
