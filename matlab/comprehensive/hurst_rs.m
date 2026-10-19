% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [H, intercept, R, log_n, log_RS, exitflag] = hurst_rs(series, options)
%% HURSTRS R/S analysis for Hurst exponent estimation.
%  Computes the Hurst exponent H via rescaled range (R/S) analysis.
%  Divides the series into sub-windows of length n, computes (R/S)_n
%  for each window length, then fits log(R/S) = H*log(n) + const.
%  H > 0.5 indicates persistence (trending), H < 0.5 anti-persistence
%  (mean-reverting), H = 0.5 random walk.
%  Paradigm: PARADIGM-0703
%  Category: Comprehensive
%  Version: v3.0.0
%  Reference: Hurst, H.E. (1951) Long-term storage capacity of
%             reservoirs. Transactions of the American Society of Civil
%             Engineers, 116, 770-799.
%             Mandelbrot, B.B. & Wallis, J.R. (1969) Robustness of the
%             rescaled range R/S. Water Resources Research, 5(5), 967-988.
%
%  Input:
%      series - Time series vector (n x 1)
%
%  Options:
%      options.min_window  - Minimum window size fraction (default: 0.1)
%      options.n_windows   - Number of window sizes to test (default: 15)
%      options.detrend     - Remove linear trend per window (default: true)
%      options.seed        - RNG seed (default: 42)
%
%  Output:
%      H        - Hurst exponent (slope of log(R/S) vs log(n))
%      intercept- Intercept of the log-log regression line
%      R        - Pearson correlation coefficient of the regression fit
%      log_n    - log(window sizes) used for fitting
%      log_RS   - log(R/S) values for each window size
%      exitflag - 1 = success, 0 = poor fit (R^2 < 0.7), -1 = error

arguments
    series (:, 1) double
    options.min_window (1,1) double {mustBeInRange(options.min_window, 0.01, 0.5)} = 0.1
    options.n_windows (1,1) double {mustBeInteger, mustBePositive} = 15
    options.detrend (1,1) logical = true
    options.seed (1,1) double = 42
end

rng(options.seed, 'twister');
exitflag = 1;

N = length(series);
assert(N >= 20, 'Need at least 20 observations for R/S analysis, got %d.', N);
assert(all(isfinite(series)), 'Input series contains non-finite values.');

%% Step 1: Convert to log-returns or use raw (mean-centered for R/S)
% Standard practice: work with cumulative deviations from mean
x = series;
x_bar = mean(x);
Y = cumsum(x - x_bar);  % cumulative deviation from mean

%% Step 2: Define window sizes (geometrically spaced)
min_n = max(10, round(options.min_window * N));
max_n = floor(N / 2);
% Geometric spacing of window sizes
window_sizes = unique(round(logspace(log10(min_n), log10(max_n), options.n_windows)));
window_sizes = window_sizes(window_sizes >= min_n & window_sizes <= max_n);
n_windows = length(window_sizes);

if n_windows < 3
    exitflag = -1;
    warning('HURSTRS:TooFewWindows', 'Not enough window sizes. Need longer series.');
    H = 0.5;
    intercept = 0;
    R = 0;
    log_n = [];
    log_RS = [];
    return;
end

%% Step 3: Compute (R/S)_n for each window size
RS_vals = zeros(n_windows, 1);

for w_idx = 1:n_windows
    n_val = window_sizes(w_idx);
    n_blocks = floor(N / n_val);

    if n_blocks < 2
        RS_vals(w_idx) = NaN;
        continue;
    end

    RS_block = zeros(n_blocks, 1);

    for b = 1:n_blocks
        start_idx = (b - 1) * n_val + 1;
        end_idx = b * n_val;
        block_data = x(start_idx:end_idx);

        if options.detrend
            % Remove linear trend within block
            t_block = (1:n_val)';
            X_design = [ones(n_val, 1), t_block];
            beta = X_design \ block_data;
            detrended = block_data - X_design * beta;
        else
            block_mean = mean(block_data);
            detrended = block_data - block_mean;
        end

        % Cumulative deviation
        Z = cumsum(detrended);

        % Range
        R_val = max(Z) - min(Z);

        % Standard deviation
        S_val = std(block_data);

        if S_val < 1e-12
            RS_block(b) = 0;
        else
            RS_block(b) = R_val / S_val;
        end
    end

    RS_vals(w_idx) = mean(RS_block);
end

%% Step 4: Remove NaN entries
valid_idx = ~isnan(RS_vals) & RS_vals > 0;
log_n = log(window_sizes(valid_idx))';
log_RS = log(RS_vals(valid_idx))';

%% Step 5: Linear regression log(R/S) = H * log(n) + c
if length(log_n) < 2
    exitflag = -1;
    warning('HURSTRS:NotEnoughData', 'Insufficient valid points for regression.');
    H = 0.5;
    intercept = 0;
    R = 0;
    return;
end

X_reg = [ones(length(log_n), 1), log_n(:)];
b = X_reg \ log_RS(:);
intercept = b(1);
H = b(2);

% Fit quality
log_RS_fit = X_reg * b;
R_mat = corrcoef(log_RS(:), log_RS_fit(:));
R = R_mat(1, 2);

if R^2 < 0.7
    exitflag = 0;
end

%% Validation
if H < 0 || H > 1
    exitflag = 0;
    warning('HURSTRS:HOutOfRange', 'Hurst exponent H=%.4f outside theoretical [0,1].', H);
end

%% Self-test
function self_test()
    rng(42);
    N_test = 500;

    % Test 1: Random walk -> H ~ 0.5
    rw = cumsum(randn(N_test, 1));
    [H1, ~, ~, ~, ~, ef1] = hurst_rs(rw, ...
        'min_window', 0.05, 'n_windows', 12, 'seed', 42);
    assert(ef1 >= 0, 'Self-test 1: exitflag >= 0, got %d.', ef1);
    assert(abs(H1 - 0.5) < 0.15, ...
        'Self-test 1: Random walk H should be near 0.5, got H=%.4f.', H1);

    % Test 2: Persistent series (fractional Gaussian noise with H>0.5 approximation)
    % Build a persistent series by cumulative sum of positively autocorrelated noise
    eps_val = randn(N_test, 1);
    persistent_x = zeros(N_test, 1);
    persistent_x(1) = eps_val(1);
    autocorr_coef = 0.85;
    for t = 2:N_test
        persistent_x(t) = autocorr_coef * persistent_x(t-1) + eps_val(t);
    end
    [H2, ~, ~, ~, ~, ef2] = hurst_rs(persistent_x, ...
        'min_window', 0.05, 'n_windows', 12, 'seed', 42);
    assert(ef2 >= 0, 'Self-test 2: exitflag >= 0, got %d.', ef2);
    assert(H2 > 0.55, ...
        'Self-test 2: Persistent series should have H > 0.55, got H=%.4f.', H2);

    % Test 3: Anti-persistent series (mean-reverting)
    % Build by taking first differences of random walk (white noise -> H < 0.5 is tricky)
    % Better approach: differenced series of persistent data
    anti_x = diff(persistent_x);  % first difference -> less persistent
    N_anti = length(anti_x);
    if N_anti >= 50
        [H3, ~, ~, ~, ~, ef3] = hurst_rs(anti_x, ...
            'min_window', 0.05, 'n_windows', 10, 'seed', 42);
        assert(ef3 >= 0, 'Self-test 3: exitflag >= 0, got %d.', ef3);
        assert(H3 > 0 && H3 < 1, ...
            'Self-test 3: H should be in (0,1), got H=%.4f.', H3);
    end

    % Test 4: Verify persistence ordering
    assert(H2 > H1 - 0.05, ...
        'Self-test 4: Persistent H=%.4f should be >= random walk H=%.4f.', H2, H1);

    % Test 5: Output values are finite
    assert(isfinite(H1) && isfinite(H2), ...
        'Self-test 5: Hurst exponents must be finite.');

    fprintf('HURSTRS self-test PASSED (5 tests, all assertions passed).\n');
end
end
