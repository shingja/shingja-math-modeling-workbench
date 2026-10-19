% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function yi = interp_cubic_spline(x, y, xi, varargin)
% INTERP_CUBIC_SPLINE  Cubic spline interpolation (natural boundary).
%
%   YI = INTERP_CUBIC_SPLINE(X, Y, XI)
%   X:   n×1 vector of knot positions (strictly increasing).
%   Y:   n×1 vector of knot values.
%   XI:  m×1 vector of query points.
%
%   Optional:
%   'Clamped', [dy0, dyn]: clamped boundary with given endpoint slopes.
%
%   YI:  m×1 vector, interpolated values at XI.
%
%   Example:
%       x  = 0:0.5:3;
%       y  = sin(x);
%       xi = 0:0.1:3;
%       yi = interp_cubic_spline(x, y, xi);
%       plot(x, y, 'o', xi, yi, '-');
%
%   References:
%       de Boor, C. (2001). A Practical Guide to Splines, rev. ed. Springer.
%       《各类常用数学模型》第09章 插值与拟合

p = inputParser;
p.addRequired('x', @isnumeric);
p.addRequired('y', @isnumeric);
p.addRequired('xi', @isnumeric);
p.addParameter('Clamped', [], @isnumeric);
p.parse(x, y, xi, varargin{:});

opts = p.Results;
x  = x(:);
y  = y(:);
xi = xi(:);

n = length(x);
if length(y) ~= n
    error('interp_cubic_spline:SizeMismatch', 'X and Y must be same length.');
end
if any(diff(x) <= 0)
    error('interp_cubic_spline:NonIncreasing', 'X must be strictly increasing.');
end
if n < 3
    error('interp_cubic_spline:TooFewKnots', 'At least 3 knots required.');
end

h = diff(x);  % h(i) = x(i+1) - x(i)

% Build tridiagonal system for second derivatives M
A = zeros(n);
b = zeros(n, 1);

for i = 2:n-1
    A(i, i-1) = h(i-1);
    A(i, i)   = 2 * (h(i-1) + h(i));
    A(i, i+1) = h(i);
    b(i) = 6 * ((y(i+1) - y(i)) / h(i) - (y(i) - y(i-1)) / h(i-1));
end

% Boundary conditions
if ~isempty(opts.Clamped)
    % Clamped: given first derivative at endpoints
    dy0 = opts.Clamped(1);
    dyn = opts.Clamped(2);
    A(1, 1)   = 2 * h(1);
    A(1, 2)   = h(1);
    b(1)      = 6 * ((y(2) - y(1)) / h(1) - dy0);
    A(n, n-1) = h(n-1);
    A(n, n)   = 2 * h(n-1);
    b(n)      = 6 * (dyn - (y(n) - y(n-1)) / h(n-1));
else
    % Natural: M(1) = M(n) = 0
    A(1, 1) = 1;
    A(n, n) = 1;
end

M = A \ b;  % second derivatives at knots

% Evaluate at query points
yi = zeros(size(xi));
for k = 1:length(xi)
    xk = xi(k);
    % Find interval [x_i, x_{i+1}] containing xk
    if xk <= x(1)
        i = 1;
    elseif xk >= x(n)
        i = n - 1;
    else
        i = find(xk >= x, 1, 'last');
    end

    dx = x(i+1) - x(i);
    t  = (xk - x(i)) / dx;

    % Cubic Hermite formula in terms of M
    yi(k) = (1-t) * y(i) + t * y(i+1) ...
          + (dx^2 / 6) * ((1-t)^3 - (1-t)) * M(i) ...
          + (dx^2 / 6) * (t^3 - t) * M(i+1);
end
end

%% Self-test
function self_test()
    % Test with 4-point dataset: sin(x) interpolation
    x = [0; 1; 2; 3];
    y = [0; 1; 4; 9];  % y = x^2
    xi = [0.5; 1.5; 2.5];
    yi = interp_cubic_spline(x, y, xi);
    assert(abs(yi(1) - 0.25) < 0.5, 'Test failed: spline approx for x^2 at 0.5 ~ 0.25.');
    assert(abs(yi(2) - 2.25) < 0.5, 'Test failed: spline approx for x^2 at 1.5 ~ 2.25.');
    disp('interp_cubic_spline self-test passed.');
end
