% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function X_norm = normalize_data(X, method)
% NORMALIZE_DATA  Normalize/standardize data columns.
%
%   X_NORM = NORMALIZE_DATA(X, METHOD)
%   X:      n×p numeric matrix.
%   METHOD: 'zscore'   = (x - mean)/std       (default)
%           'minmax'   = (x - min)/(max - min) → [0, 1]
%           'range'    = (x - min)/(max - min) → [-1, 1]
%           'l2'       = x / ||x||_2           (column-wise)
%           'robust'   = (x - median)/iqr
%
%   Example:
%       X = [1 100; 2 200; 3 300];
%       Xn = normalize_data(X, 'minmax');
%       % Xn = [0 0; 0.5 0.5; 1 1]
%
%   References:
%       《各类常用数学模型》第10章 数据的统计描述和分析

if nargin < 2, method = 'zscore'; end
[n, p] = size(X);
X_norm = zeros(n, p);

switch lower(method)
    case 'zscore'
        mu = mean(X, 1);
        sd = std(X, 0, 1);
        sd(sd == 0) = 1;
        X_norm = (X - mu) ./ sd;

    case 'minmax'
        xmin = min(X, [], 1);
        xmax = max(X, [], 1);
        rng_val = xmax - xmin;
        rng_val(rng_val == 0) = 1;
        X_norm = (X - xmin) ./ rng_val;

    case 'range'
        xmin = min(X, [], 1);
        xmax = max(X, [], 1);
        rng_val = xmax - xmin;
        rng_val(rng_val == 0) = 1;
        X_norm = 2 * (X - xmin) ./ rng_val - 1;

    case 'l2'
        for j = 1:p
            col_norm = norm(X(:, j), 2);
            if col_norm == 0, col_norm = 1; end
            X_norm(:, j) = X(:, j) / col_norm;
        end

    case 'robust'
        med = median(X, 1);
        iqr_val = iqr(X);
        iqr_val(iqr_val == 0) = 1;
        X_norm = (X - med) ./ iqr_val;

    otherwise
        error('normalize_data:UnknownMethod', ...
            'Unknown method "%s". Use: zscore, minmax, range, l2, robust.', method);
end
end

%% Self-test
function self_test()
    % Test z-score on [1,2,3]
    X = [1 10; 2 20; 3 30];
    Xn = normalize_data(X, 'zscore');
    assert(size(Xn, 1) == 3, 'Test failed: should have 3 rows.');
    assert(abs(mean(Xn(:,1))) < 1e-10, 'Test failed: z-score mean should be ~0.');
    assert(abs(std(Xn(:,1)) - 1.0) < 1e-6, 'Test failed: z-score std should be ~1.');
    disp('normalize_data self-test passed.');
end
