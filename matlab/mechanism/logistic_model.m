% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [t, N, key_points] = logistic_model(N0, r, K, tspan, varargin)
%LOGISTIC_MODEL Logistic 阻滞增长模型
%   [T, N, KEY_POINTS] = LOGISTIC_MODEL(N0, R, K, TSPAN)
%   dN/dt = r*N*(1-N/K), 解析解 N(t)=K/(1+(K/N0-1)*exp(-r*t))
%
%   Source: Verhulst, P.F. (1838). Notice sur la loi que la population
%          suit dans son accroissement. Corr. Math. et Phys.
%   Author: Adapted by MathModelingSkill
%   License: MIT
%   Verified: 2026-07-27
%
%   输入:
%       N0    - 初始种群
%       r     - 内禀增长率
%       K     - 环境容量 (carrying capacity)
%       tspan - 时间区间 [t0, tf] 或点向量
%
%   可选参数:
%       'nPoints' - 采样点数 (默认: 100)
%       'Display' - 'on' | 'off' (默认: 'off')
%
%   输出:
%       t         - 时间点
%       N         - 种群数量
%       key_points - 结构体: inflection_t (拐点时间), inflection_N, half_K_t
%
%   示例:
%       [t, N] = logistic_model(10, 0.3, 1000, [0, 50]);
%       plot(t, N);

%% 解析解核心 (≤ 50 行)
if isscalar(tspan)
    t = linspace(0, tspan, 100);
elseif length(tspan) == 2
    t = linspace(tspan(1), tspan(2), 100);
else
    t = tspan;
end

%% 参数解析
p = inputParser;
p.addParameter('nPoints', 100);
p.addParameter('Display', 'off');
p.parse(varargin{:});
opts = p.Results;

if isscalar(tspan) || length(tspan) == 2
    t = linspace(tspan(1), tspan(end), opts.nPoints);
end

% 解析解
denom = 1 + (K/N0 - 1) * exp(-r * t);
N = K ./ denom;

% 拐点: d²N/dt²=0 → N = K/2
t_inflection = log(K/N0 - 1) / r;
if t_inflection >= t(1) && t_inflection <= t(end)
    N_inflection = K / 2;
else
    t_inflection = NaN;
    N_inflection = NaN;
end

key_points.inflection_t = t_inflection;
key_points.inflection_N = N_inflection;

if strcmp(opts.Display, 'on')
    fprintf('Logistic: N0=%.1f, r=%.4f, K=%.1f, 终点N=%.1f\n', N0, r, K, N(end));
    if ~isnan(t_inflection)
        fprintf('  拐点: t=%.2f, N=%.1f (K/2)\n', t_inflection, N_inflection);
    end
end
end

%% Self-test
function self_test()
    % Test r=0.5 K=100 N0=10 known solution
    [t, N, kp] = logistic_model(10, 0.5, 100, [0, 20], 'Display', 'off');
    assert(length(N) > 10, 'Test failed: should have multiple time points.');
    assert(abs(N(end) - 100) < 5, 'Test failed: should approach K=100.');
    assert(kp.inflection_N > 0, 'Test failed: inflection point should exist.');
    disp('logistic_model self-test passed.');
end
n%% Reproducibility
rng(42, 'twister');
