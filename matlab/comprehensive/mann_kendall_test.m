% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [tau, p_value, Z, S_stat, slope, exitflag] = mann_kendall_test(series, options)
%% MANNKENDALLTEST Mann-Kendall trend test with Sen's slope estimator.
%  Non-parametric test for monotonic trend in a time series. Computes
%  the S statistic, Kendall's tau, Z-score, two-sided p-value, and
%  Sen's slope (Theil-Sen estimator).
%  Paradigm: PARADIGM-0702
%  Category: Comprehensive
%  Version: v3.0.0
%  Reference: Mann, H.B. (1945) Nonparametric tests against trend.
%             Econometrica, 13(3), 245-259. DOI: 10.2307/1907187.
%             Kendall, M.G. (1975) Rank Correlation Methods. Griffin.
%             Sen, P.K. (1968) Estimates of the regression coefficient
%             based on Kendall's tau. JASA, 63(324), 1379-1389.
%
%  Input:
%      series - Time series vector (n x 1), values over time
%
%  Options:
%      options.alpha      - Significance level (default: 0.05)
%      options.continuity - Apply continuity correction (default: true)
%      options.seed       - RNG seed (default: 42)
%
%  Output:
%      tau      - Kendall rank correlation coefficient
%      p_value  - Two-sided p-value for trend significance
%      Z        - Standard normal Z-statistic
%      S_stat   - Mann-Kendall S statistic
%      slope    - Sen's slope estimate (median of pairwise slopes)
%      exitflag - 1 = success, 0 = tied values present, -1 = error

arguments
    series (:, 1) double
    options.alpha (1,1) double {mustBeInRange(options.alpha, 0, 1)} = 0.05
    options.continuity (1,1) logical = true
    options.seed (1,1) double = 42
end

rng(options.seed, 'twister');
exitflag = 1;

n = length(series);
assert(n >= 4, 'Need at least 4 observations for trend test, got %d.', n);
assert(all(isfinite(series)), 'Input series contains non-finite values.');

%% Step 1: Compute S statistic
% S = sum_{i<j} sign(x_j - x_i)
S = 0;
for i = 1:(n-1)
    for j = (i+1):n
        diff_val = series(j) - series(i);
        if diff_val > 0
            S = S + 1;
        elseif diff_val < 0
            S = S - 1;
        end
        % ties contribute 0 (no adjustment needed here)
    end
end

S_stat = S;

%% Step 2: Variance of S accounting for ties
% Var(S) = [n(n-1)(2n+5) - sum_{g} t_g(t_g-1)(2t_g+5)] / 18
[unique_vals, ~, ic] = unique(series);
t_g = histcounts(ic, 'BinMethod', 'integers');
t_g = t_g(t_g > 1);
tie_correction = sum(t_g .* (t_g - 1) .* (2 * t_g + 5));

n_choose = n * (n - 1) * (2 * n + 5);
var_S = (n_choose - tie_correction) / 18;

if var_S < 1e-12
    exitflag = 0;
    warning('MANNKENDALL:AllTies', 'All values are tied. Trend indeterminate.');
    tau = 0;
    p_value = 1;
    Z = 0;
    slope = 0;
    return;
end

%% Step 3: Z-statistic with continuity correction
if options.continuity
    if S > 0
        Z = (S - 1) / sqrt(var_S);
    elseif S < 0
        Z = (S + 1) / sqrt(var_S);
    else
        Z = 0;
    end
else
    Z = S / sqrt(var_S);
end

%% Step 4: Kendall's tau
% tau = 2*S / [n*(n-1)]
tau = 2 * S / (n * (n - 1));

%% Step 5: Two-sided p-value
p_value = 2 * (1 - normcdf(abs(Z)));

%% Step 6: Sen's slope (Theil-Sen estimator)
% slope_ij = (x_j - x_i) / (j - i) for all i < j
% slope = median(slope_ij)
n_pairs = n * (n - 1) / 2;
slopes = zeros(n_pairs, 1);
idx = 0;
for i = 1:(n-1)
    for j = (i+1):n
        idx = idx + 1;
        slopes(idx) = (series(j) - series(i)) / (j - i);
    end
end
slope = median(slopes);

%% Validation
if any(isnan([tau, p_value, Z, slope]))
    exitflag = -1;
    warning('MANNKENDALL:BadResult', 'Output contains NaN values.');
end

%% Self-test
function self_test()
    rng(42);
    n_pts = 30;

    % Test 1: Monotonic increasing series -> p < 0.05
    t = (1:n_pts)';
    x_inc = 2.0 * t + randn(n_pts, 1) * 0.5;  % clear upward trend
    [tau1, p1, Z1, S1, sl1, ef1] = mann_kendall_test(x_inc);
    assert(ef1 >= 0, 'Self-test 1: exitflag should be >= 0, got %d.', ef1);
    assert(p1 < 0.05, 'Self-test 1: increasing trend should have p < 0.05, got p=%.6f.', p1);
    assert(tau1 > 0.5, 'Self-test 1: increasing trend should have tau > 0.5, got tau=%.4f.', tau1);
    assert(Z1 > 2.0, 'Self-test 1: Z should be > 2 for strong trend, got Z=%.4f.', Z1);
    assert(sl1 > 1.5, 'Self-test 1: Sen slope should be positive, got %.4f.', sl1);

    % Test 2: Random noise (no trend) -> p > 0.05
    x_rand = randn(n_pts, 1);
    [tau2, p2, Z2, S2, ~, ef2] = mann_kendall_test(x_rand);
    assert(ef2 >= 0, 'Self-test 2: exitflag should be >= 0, got %d.', ef2);
    % p > 0.1 most of the time for random noise (probabilistic)
    if p2 <= 0.05
        warning('Self-test 2: random noise gave p=%.4f (may happen ~5%% of time).', p2);
    end
    assert(abs(tau2) < 0.5, ...
        'Self-test 2: random noise should have |tau| < 0.5, got |tau|=%.4f.', abs(tau2));

    % Test 3: Decreasing trend
    x_dec = -1.5 * t + randn(n_pts, 1) * 0.5;
    [tau3, p3, Z3, ~, sl3, ef3] = mann_kendall_test(x_dec);
    assert(ef3 >= 0, 'Self-test 3: exitflag should be >= 0, got %d.', ef3);
    assert(p3 < 0.05, 'Self-test 3: decreasing trend should have p < 0.05, got p=%.6f.', p3);
    assert(tau3 < -0.3, 'Self-test 3: decreasing trend should have tau < -0.3, got tau=%.4f.', tau3);
    assert(Z3 < -2.0, 'Self-test 3: Z should be < -2, got Z=%.4f.', Z3);
    assert(sl3 < -1.0, 'Self-test 3: Sen slope should be negative, got %.4f.', sl3);

    % Test 4: tau is in [-1, 1]
    assert(abs(tau1) <= 1, 'Self-test 4: tau must be in [-1,1], got %.4f.', tau1);
    assert(abs(tau2) <= 1, 'Self-test 4: tau must be in [-1,1], got %.4f.', tau2);
    assert(abs(tau3) <= 1, 'Self-test 4: tau must be in [-1,1], got %.4f.', tau3);

    % Test 5: p-value is in [0, 1]
    assert(p1 >= 0 && p1 <= 1, 'Self-test 5: p-value must be in [0,1], got %.6f.', p1);

    % Test 6: S statistic sign matches tau
    assert(sign(S1) == sign(tau1) || tau1 == 0, ...
        'Self-test 6: sign(S)=%d should match sign(tau)=%d.', sign(S1), sign(tau1));

    fprintf('MANNKENDALLTEST self-test PASSED (6 tests, all assertions passed).\n');
end
end
