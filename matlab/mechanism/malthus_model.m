% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [t, N] = malthus_model(N0, r, tspan, varargin)
%MALTHUS_MODEL Malthus 指数增长模型
%   [T, N] = MALTHUS_MODEL(N0, R, TSPAN)
%   dN/dt = r*N, 解析解 N(t)=N0*exp(r*t)
%
%   Source: Malthus, T.R. (1798). An Essay on the Principle of Population.
%   Author: Adapted by MathModelingSkill
%   License: MIT
%   Verified: 2026-07-27
%
%   输入:
%       N0    - 初始种群
%       r     - 净增长率 (正=增长, 负=衰减)
%       tspan - [t_start, t_end] 或时间向量
%
%   可选参数:
%       'nPoints' - 输出采样点数 (默认: 100)
%       'Display' - 'on' | 'off' (默认: 'off')
%
%   输出:
%       t  - 时间点
%       N  - 种群数量 N(t)
%
%   示例:
%       [t, N] = malthus_model(100, 0.02, [0, 50]);
%       plot(t, N);

%% 解析解 (核心 ≤ 50 行)
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

N = N0 * exp(r * t);

if strcmp(opts.Display, 'on')
    fprintf('Malthus: N0=%.2f, r=%.4f, N(end)=%.2f\n', N0, r, N(end));
end
end

%% Self-test
function self_test()
    % Test r=0.1 N0=100 known exponential
    [t, N] = malthus_model(100, 0.1, [0, 10], 'Display', 'off');
    assert(length(N) > 10, 'Test failed: should have multiple time points.');
    assert(abs(N(end) - 100*exp(1)) < 1e-6, 'Test failed: N(10) should be 100*exp(1).');
    assert(N(1) == 100, 'Test failed: initial value should be 100.');
    disp('malthus_model self-test passed.');
end
n%% Reproducibility
rng(42, 'twister');
