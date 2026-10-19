% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [yi, coeffs] = interp_lagrange(x, y, xi)
% Input validation
arguments
    data (:,:) double
end
% INTERP_LAGRANGE  Lagrange polynomial interpolation.
%
%   [YI, COEFFS] = INTERP_LAGRANGE(X, Y, XI)
%   X:   n×1 vector of known x-coordinates (must be distinct).
%   Y:   n×1 vector of known y-values at X.
%   XI:  m×1 vector of x-coordinates to interpolate.
%
%   YI:     m×1 vector, interpolated values at XI.
%   COEFFS: n×1 vector of Lagrange basis coefficient weights.
%
%   Note: For n > 15-20, prefer spline or piecewise methods due to
%         Runge's phenomenon (oscillation at edges).
%
%   Example:
%       x  = [1 2 4 5]';
%       y  = [1 3 7 11]';
%       xi = 3;
%       yi = interp_lagrange(x, y, xi);  % yi ≈ 5
%
%   References:
%       《各类常用数学模型》第09章 插值与拟合

x  = x(:);
y  = y(:);
xi = xi(:);

n = length(x);
if length(y) ~= n
    error('interp_lagrange:SizeMismatch', 'X and Y must be same length.');
end
if length(unique(x)) ~= n
    error('interp_lagrange:DuplicateX', 'X values must be distinct.');
end

m = length(xi);
yi = zeros(m, 1);

% Barycentric form (stable for moderate n):
% Compute barycentric weights
w = zeros(n, 1);
for j = 1:n
    w(j) = 1 / prod(x(j) - x([1:j-1, j+1:n]));
end

for k = 1:m
    % Check if XI equals a known node
    [~, idx] = min(abs(xi(k) - x));
    if abs(xi(k) - x(idx)) < eps
        yi(k) = y(idx);
        continue;
    end

    num = sum(w .* y ./ (xi(k) - x));
    den = sum(w ./ (xi(k) - x));
    yi(k) = num / den;
end

coeffs = w;  % Lagrange weights
end

%% Self-test
function self_test()
% Input validation
arguments
    data (:,:) double
end
    % Test interpolate y = x^2 at 3 points
    x = [1; 2; 3];
    y = [1; 4; 9];  % y = x^2
    xi = [1.5; 2.5];
    yi = interp_lagrange(x, y, xi);
    assert(abs(yi(1) - 2.25) < 1e-6, 'Test failed: y(1.5) should be 2.25.');
    assert(abs(yi(2) - 6.25) < 1e-6, 'Test failed: y(2.5) should be 6.25.');
    disp('interp_lagrange self-test passed.');
end
