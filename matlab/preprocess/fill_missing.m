% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function X_filled = fill_missing(X, method)
% FILL_MISSING  Impute missing values (NaN) in a numeric matrix.
%
%   X_FILLED = FILL_MISSING(X, METHOD)
%   X:      n×p numeric matrix with NaN for missing entries.
%   METHOD: 'mean'     = column mean       (default)
%           'median'   = column median
%           'interp'   = linear interpolation along rows (time-series)
%           'nearest'  = nearest-neighbor interpolation
%           'constant' = zero-fill
%
%   Example:
%       X = [1 NaN 3; 4 5 NaN; NaN 8 9];
%       Xf = fill_missing(X, 'mean');  % fills col-wise means
%
%   References:
%       Little, R.J.A. & Rubin, D.B. (2019). Statistical Analysis with
%       Missing Data, 3rd ed. Wiley.
%       《各类常用数学模型》第10章 数据的统计描述和分析

if nargin < 2, method = 'mean'; end
[n, p] = size(X);
X_filled = X;

switch lower(method)
    case 'mean'
        for j = 1:p
            col = X(:, j);
            col_mean = mean(col, 'omitnan');
            X_filled(isnan(col), j) = col_mean;
        end

    case 'median'
        for j = 1:p
            col = X(:, j);
            col_med = median(col, 'omitnan');
            X_filled(isnan(col), j) = col_med;
        end

    case 'interp'
        for j = 1:p
            col = X(:, j);
            nan_idx = isnan(col);
            if all(nan_idx), continue; end
            x = (1:n)';
            valid = ~nan_idx;
            X_filled(nan_idx, j) = interp1(x(valid), col(valid), ...
                x(nan_idx), 'linear', 'extrap');
        end

    case 'nearest'
        for i = 1:n
            for j = 1:p
                if isnan(X(i, j))
                    % Find nearest non-NaN in same column
                    col = X(:, j);
                    valid = find(~isnan(col));
                    if ~isempty(valid)
                        [~, idx] = min(abs(valid - i));
                        X_filled(i, j) = col(valid(idx));
                    end
                end
            end
        end

    case 'constant'
        X_filled(isnan(X_filled)) = 0;

    otherwise
        error('fill_missing:UnknownMethod', ...
            'Unknown method "%s". Use: mean, median, interp, nearest, constant.', method);
end
end

%% Self-test
function self_test()
    % Test fill mean on [1, NaN, 3]
    X = [1 NaN 3; 4 5 NaN]';
    Xf = fill_missing(X, 'mean');
    assert(~any(isnan(Xf), 'all'), 'Test failed: no NaN should remain after fill.');
    assert(abs(Xf(2,1) - 2) < 1e-6, 'Test failed: mean of [1,3] should be 2.');
    disp('fill_missing self-test passed.');
end
