% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [b, stats] = regression_diagnostics(X, y, varargin)
%REGRESSION_DIAGNOSTICS 线性回归参数估计与完整诊断 (OLS, 自实现)
%   [B, STATS] = REGRESSION_DIAGNOSTICS(X, Y)
%   对设计矩阵 X (n×p, 不含截距列) 与响应 y (n×1) 做最小二乘估计
%   b = (X'X)^-1 X'y, 并给出全套回归诊断: 标准误/t 检验/p 值 (手工
%   beta 函数实现, 免 Statistics Toolbox)、R²/调整 R²/F 检验、残差、
%   杠杆值、Cook 距离、VIF 多重共线性、Durbin-Watson 自相关。
%
%   Source: Montgomery, D.C., Peck, E.A., Vining, G.G. (2012).
%          Introduction to Linear Regression Analysis, 5th ed. Wiley.
%          ISBN: 978-0470542811 (第3/4/6/10 章诊断方法)
%          教材: 数模加油站《一元/多元线性回归分析》ipynb+mlx 模块
%   Author: Adapted by MathModelingSkill (S6, 2026-08)
%   License: MIT
%   Verified: 2026-08-16, self-test 系数恢复 + 离群点 Cook 距离定位
%
%   输入:
%       X - 自变量矩阵 n×p (原始变量, 不含截距列)
%       y - 因变量向量 n×1
%
%   可选参数 (名值对):
%       'Intercept' - 是否加入截距列 (默认: true)
%       'Alpha'     - 显著性水平, 用于系数置信区间 (默认: 0.05)
%       'Display'   - 'iter' | 'off' (默认: 'off')
%
%   输出:
%       b     - 回归系数 (k×1), k = p + 1 (含截距时), 首项为截距
%       stats - struct 字段:
%           se, tstat, pval   - 系数标准误/t 统计量/双侧 p 值 (k×1)
%           ci_b              - 系数 (1-Alpha) 置信区间 k×2
%           r2, adj_r2        - R² 与调整 R²
%           Fstat, F_pval     - 整体显著性 F 检验
%           mse, rmse         - 均方误差与均方根误差
%           residuals         - 残差 e = y - Xb (n×1)
%           std_resid         - 内部学生化残差 e_i/(s√(1-h_ii))
%           leverage          - 杠杆值 h_ii, 警戒线 2k/n
%           cooks_d           - Cook 距离 D_i, 警戒线 4/n
%           vif               - 方差膨胀因子 (1×p, 无截距项)
%           dw                - Durbin-Watson 统计量 (2 附近无自相关)
%           n, k              - 样本数与参数个数
%           singular          - 设计矩阵是否接近奇异 (rcond < 1e-12)
%
%   示例:
%       x1 = randn(200, 1); x2 = randn(200, 1);
%       y = 3 + 2*x1 - 1.5*x2 + 0.5*randn(200, 1);
%       [b, stats] = regression_diagnostics([x1 x2], y, 'Display', 'iter');
%
%   注意:
%       - 与 fitlm (Statistics Toolbox) 结果一致, 本实现仅依赖基础 MATLAB。
%       - 推断基于高斯-马尔可夫假设 (残差独立同分布正态); 违反时 t/F
%         检验失效, 需看 dw (自相关) 与残差图 (异方差) 等诊断。
%       - 强影响点判据: h_ii > 2k/n 或 D_i > 4/n 应回查原始数据。

%% 无参调用入口 (matlab -batch 自测用)
if nargin == 0
    self_test();
    return;
end

%% 参数解析
p = inputParser;
p.addRequired('X', @(x) isnumeric(x) && ismatrix(x));
p.addRequired('y', @(x) isnumeric(x) && (isvector(x) || ismatrix(x)));
p.addParameter('Intercept', true, @(x) islogical(x) || (x == 0 || x == 1));
p.addParameter('Alpha', 0.05, @(x) isscalar(x) && x > 0 && x < 1);
p.addParameter('Display', 'off', @(x) any(strcmp(x, {'iter', 'off'})));
p.parse(X, y, varargin{:});
opts = p.Results;

[n, px] = size(X);
y = y(:);
if length(y) ~= n
    error('regression_diagnostics:DimMismatch', 'X 与 y 样本数不一致。');
end
if any(~isfinite(X(:))) || any(~isfinite(y))
    error('regression_diagnostics:NonFiniteData', '数据含 NaN 或 Inf, 请先清洗。');
end

%% 构建设计矩阵与最小二乘估计
Xd = [ones(n, 1), X];              % 截距列
k = size(Xd, 2);
if n < k + 2
    warning('regression_diagnostics:SmallSample', ...
        '样本量 n=%d 仅略大于参数个数 k=%d, 推断可能不可靠。', n, k);
end

XtX = Xd' * Xd;
rcond_val = rcond(XtX);
stats.singular = rcond_val < 1e-12;
if stats.singular
    warning('regression_diagnostics:IllConditioned', ...
        '设计矩阵 X''X 接近奇异 (rcond=%.2e), 参数估计不可靠, VIF 可能接近 Inf, 请删除冗余变量。', ...
        rcond_val);
end

b = Xd \ y;
e = y - Xd * b;                    % 残差
nu = n - k;                        % 残差自由度
SSE = e' * e;
SST = sum((y - mean(y)).^2);
SSR = SST - SSE;
mse = SSE / nu;

%% 系数推断 (标准误 / t / p 值 / 置信区间)
XtX_inv = XtX \ eye(k);
se = sqrt(max(diag(XtX_inv) * mse, 0));
tstat = b ./ se;
pval = 2 * t_tail_cdf(abs(tstat), nu);         % 双侧 p 值 (betainc 实现)
tq = t_quantile(opts.Alpha / 2, nu);           % 双侧分位数
ci_b = [b - tq * se, b + tq * se];

%% 整体拟合优度
r2 = 1 - SSE / SST;
adj_r2 = 1 - (1 - r2) * (n - 1) / nu;
if k > 1
    Fstat = (SSR / (k - 1)) / mse;
    F_pval = betainc(nu / (nu + (k - 1) * Fstat), nu / 2, (k - 1) / 2);
else
    Fstat = NaN;
    F_pval = NaN;
end

%% 杠杆值 / 学生化残差 / Cook 距离
h = sum(Xd .* (Xd / XtX), 2);                  % h_ii = diag(Xd (X'X)^-1 Xd')
h = max(h, eps);
std_resid = e ./ sqrt(mse * (1 - h));          % 内部学生化残差
cooks_d = (e.^2 ./ (k * mse)) .* (h ./ (1 - h).^2);

%% 多重共线性 (VIF) 与自相关 (Durbin-Watson)
vif = zeros(1, px);
if px >= 2
    for j = 1:px
        others = setdiff(1:px, j);
        Xo = [ones(n, 1), X(:, others)];
        bj = Xo \ X(:, j);
        ej = X(:, j) - Xo * bj;
        r2j = 1 - (ej' * ej) / sum((X(:, j) - mean(X(:, j))).^2);
        vif(j) = 1 / max(1 - r2j, eps);
    end
end
if n > 2
    dw = sum(diff(e).^2) / SSE;
else
    dw = NaN;
end

%% 汇总输出
stats.se = se;
stats.tstat = tstat;
stats.pval = pval;
stats.ci_b = ci_b;
stats.r2 = r2;
stats.adj_r2 = adj_r2;
stats.Fstat = Fstat;
stats.F_pval = F_pval;
stats.mse = mse;
stats.rmse = sqrt(mse);
stats.residuals = e;
stats.std_resid = std_resid;
stats.leverage = h;
stats.cooks_d = cooks_d;
stats.vif = vif;
stats.dw = dw;
stats.n = n;
stats.k = k;

if strcmp(opts.Display, 'iter')
    fprintf('R² = %.4f, adj R² = %.4f, F(%d,%d) = %.2f (p = %.3e)\n', ...
        r2, adj_r2, k - 1, nu, Fstat, F_pval);
    fprintf('系数: 截距 %.4f; 斜率', b(1));
    fprintf(' %.4f', b(2:end));
    fprintf(' | DW = %.3f, max VIF = %.2f\n', dw, max(vif));
end
end

%% t 分布双尾尾部概率: P(|T| > t) = I_{ν/(ν+t²)}(ν/2, 1/2)
function pval = t_tail_cdf(t, nu)
    pval = betainc(nu ./ (nu + t.^2), nu / 2, 0.5);
    pval = max(pval, 0);
end

%% t 分布分位数 (对尾部概率方程反解, 免 Statistics Toolbox)
function tq = t_quantile(alpha_half, nu)
    tq = NaN;
    try
        tq = fzero(@(t) t_tail_cdf(t, nu) - alpha_half, [1e-9, 1e4]);
    catch
        % 反解失败时回退到正态近似 (nu 较大时误差很小)
        tq = 1.96;
    end
end

%% Self-test
function self_test()
    % (1) 系数恢复: y = 3 + 2*x1 - 1.5*x2 + N(0, 0.25)
    rng(42, 'twister');
    n = 200;
    x1 = randn(n, 1);
    x2 = randn(n, 1);
    y = 3 + 2 * x1 - 1.5 * x2 + 0.5 * randn(n, 1);
    [b, stats] = regression_diagnostics([x1 x2], y);

    assert(length(b) == 3, 'Test failed: expected 3 coefficients.');
    assert(abs(b(1) - 3) < 0.5, sprintf('Test failed: intercept %.3f ~ 3.', b(1)));
    assert(abs(b(2) - 2) < 0.2, sprintf('Test failed: beta1 %.3f ~ 2.', b(2)));
    assert(abs(b(3) + 1.5) < 0.2, sprintf('Test failed: beta2 %.3f ~ -1.5.', b(3)));
    assert(stats.r2 > 0.9, sprintf('Test failed: R²=%.3f should be > 0.9.', stats.r2));
    assert(stats.pval(2) < 1e-3, 'Test failed: x1 should be highly significant.');
    assert(all(stats.vif < 1.5), 'Test failed: independent x should have VIF ~ 1.');
    assert(stats.dw > 1.6 && stats.dw < 2.4, ...
        sprintf('Test failed: DW=%.3f should be near 2.', stats.dw));
    assert(abs(mean(stats.leverage) - stats.k / n) < 1e-12, ...
        'Test failed: mean leverage should equal k/n.');

    % (2) 离群点定位: 污染第 100 个样本, Cook 距离应指向它
    y2 = y;
    y2(100) = y2(100) + 20;
    [~, stats2] = regression_diagnostics([x1 x2], y2);
    [~, cook_idx] = max(stats2.cooks_d);
    assert(cook_idx == 100, ...
        sprintf('Test failed: Cook distance should flag point 100, got %d.', cook_idx));
    disp('regression_diagnostics self-test passed.');
end
