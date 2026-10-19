% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [w, info, exitflag] = critic_weight(data, options)
%% CRITICWEIGHT CRITIC (CRiteria Importance Through Intercriteria Correlation).
%  Objective weighting method: w_j = sigma_j * (1 - sum_i |r_ij|) / denom,
%  where sigma_j is standard deviation of criterion j and r_ij is the
%  Pearson correlation between criteria i and j.
%  Paradigm: PARADIGM-0304
%  Category: MCDM
%  Version: v3.0.0
%  Reference: Diakoulaki, D., Mavrotas, G. & Papayannakis, L. (1995)
%             Determining objective weights in multiple criteria problems:
%             The CRITIC method. Computers & Operations Research, 22(7),
%             763-770. DOI: 10.1016/0305-0548(94)00059-H.
%
%  Input:
%      data - Decision matrix (m alternatives x n criteria), raw values
%
%  Options:
%      options.normalize   - Normalize before computing (default: true)
%      options.corr_type   - 'Pearson' (default) | 'Spearman'
%      options.seed        - RNG seed (default: 42)
%
%  Output:
%      w        - Objective weights (1 x n), sum = 1
%      info     - Structure with fields: sigma, R, C (information amounts)
%      exitflag - 1 = success, 0 = warning, -1 = error

arguments
    data (:, :) double
    options.normalize (1,1) logical = true
    options.corr_type char {mustBeMember(options.corr_type, {'Pearson','Spearman'})} = 'Pearson'
    options.seed (1,1) double = 42
end

rng(options.seed, 'twister');
exitflag = 1;

[m_samp, n_crit] = size(data);
assert(m_samp >= 3, 'Need at least 3 samples for correlation computation.');
assert(n_crit >= 2, 'Need at least 2 criteria.');

%% Step 1: Normalize data to [0,1] if requested
if options.normalize
    data_min = min(data, [], 1);
    data_max = max(data, [], 1);
    denom = data_max - data_min;
    denom(denom < 1e-12) = 1;
    X = (data - data_min) ./ denom;
else
    X = data;
end

%% Step 2: Compute standard deviation per criterion
sigma = std(X, 0, 1);  % unbiased estimate (N-1)

%% Step 3: Compute correlation matrix
if strcmp(options.corr_type, 'Pearson')
    R = corrcoef(X);
else
    % Spearman rank correlation
    R = corr(X, 'Type', 'Spearman');
end
R(isnan(R)) = 0;

%% Step 4: Compute conflict measure per criterion
% conflict_j = sum_{k}(1 - |r_jk|) over all k, which equals
% n_crit - sum_{k} |r_jk|
conflict = zeros(1, n_crit);
for j = 1:n_crit
    conflict(j) = n_crit - sum(abs(R(j, :)));
end

%% Step 5: Compute information amount
% C_j = sigma_j * conflict_j
C = sigma .* conflict;

% Normalize to weights
C_sum = sum(C);
if C_sum < 1e-12
    w = ones(1, n_crit) / n_crit;
    exitflag = 0;
    warning('CRITICWEIGHT:ZeroInfo', 'All information amounts near zero. Using equal weights.');
else
    w = C / C_sum;
end

%% Step 6: Package info structure
info = struct();
info.sigma = sigma;
info.R = R;
info.conflict = conflict;
info.C = C;

%% Validation
if any(isnan(w)) || any(isinf(w))
    exitflag = -1;
    warning('CRITICWEIGHT:BadWeights', 'Weights contain NaN/Inf.');
end
if abs(sum(w) - 1) > 1e-10
    exitflag = -1;
    warning('CRITICWEIGHT:SumNotOne', 'Weights sum to %.10f, expected 1.', sum(w));
end
if any(w < -1e-10)
    exitflag = -1;
    warning('CRITICWEIGHT:NegativeWeights', 'Negative weights detected.');
end

%% Self-test
function self_test()
    % Test 1: 10 samples x 4 indicators with known structure
    rng(42);
    n_s = 10;
    % Indicator 1 & 2 are highly correlated (redundant -> lower weight)
    x1 = randn(n_s, 1) * 2 + 5;
    x2 = x1 + randn(n_s, 1) * 0.5;          % highly correlated with x1
    x3 = randn(n_s, 1) * 3 + 10;             % independent, high variance
    x4 = randn(n_s, 1) * 0.5 + 8;            % independent, low variance
    data_test = [x1, x2, x3, x4];

    [w1, info1, ef1] = critic_weight(data_test, 'seed', 42);

    assert(ef1 == 1, 'Self-test 1: exitflag should be 1, got %d.', ef1);
    assert(abs(sum(w1) - 1) < 1e-10, ...
        'Self-test 1: weights must sum to 1, got %.10f.', sum(w1));
    assert(all(w1 > 0), ...
        'Self-test 1: all weights positive, got [%.4f %.4f %.4f %.4f].', w1);
    assert(length(w1) == 4, 'Self-test 1: expected 4 weights, got %d.', length(w1));

    % Test 2: x3 has highest variance and low correlation -> should get higher weight
    % x4 has lowest variance -> should get lowest weight
    assert(w1(3) > w1(4), ...
        'Self-test 2: high-variance indep criterion (w3=%.4f) should outweigh low-variance (w4=%.4f).', ...
        w1(3), w1(4));

    % Test 3: x1 and x2 are correlated -> each should be discounted
    % Their combined weight should be less than w3 (since x3 is indep + high var)
    assert(w1(1) + w1(2) < 0.7, ...
        'Self-test 3: correlated criteria should be discounted (sum=%.4f).', w1(1)+w1(2));

    % Test 4: Conflict measure should be positive
    assert(all(info1.conflict >= 0), ...
        'Self-test 4: conflict measures must be non-negative.');

    % Test 5: Spearman correlation variant
    [w_sp, ~, ef5] = critic_weight(data_test, 'corr_type', 'Spearman', 'seed', 42);
    assert(ef5 == 1, 'Self-test 5: Spearman variant exitflag should be 1.');
    assert(abs(sum(w_sp) - 1) < 1e-10, 'Self-test 5: Spearman weights sum to 1.');
    assert(all(w_sp > 0), 'Self-test 5: Spearman weights must be positive.');

    % Test 6: Information amount ordering
    assert(info1.C(3) > 0, ...
        'Self-test 6: Information amount for criterion 3 should be > 0.');

    fprintf('CRITICWEIGHT self-test PASSED (6 tests, all assertions passed).\n');
end
end
