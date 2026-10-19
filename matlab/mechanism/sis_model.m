% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [t, S, I, key_points] = sis_model(S0, I0, beta, gamma, tspan, varargin)
rng(42, 'twister');
%SIS_MODEL SIS 传染病模型 (无免疫, 可反复感染)
%   [T, S, I, KEY_POINTS] = SIS_MODEL(S0, I0, BETA, GAMMA, TSPAN)
%   dS/dt = -βSI + γI, dI/dt = βSI - γI, S+I=N (常数)
%
%   Source: Hethcote, H.W. (2000). The Mathematics of Infectious
%          Diseases. SIAM Review, 42(4), 599-653.
%   Author: Adapted by MathModelingSkill
%   License: MIT
%   Verified: 2026-07-27
%
%   输入:
%       S0     - 初始易感者数量
%       I0     - 初始感染者数量
%       beta   - 传播率 (β)
%       gamma  - 恢复率 (γ)
%       tspan  - 时间区间 [t0, tf]
%
%   可选参数:
%       'nPoints' - 采样点数 (默认: 200)
%       'Display' - 'on' | 'off' (默认: 'on')
%
%   输出:
%       t          - 时间点
%       S          - 易感者数量 S(t)
%       I          - 感染者数量 I(t)
%       key_points  - 结构体:
%           .R0          - 基本再生数 β/γ
%           .I_steady     - 稳态感染数 max(0, N*(1-1/R0))
%           .I_peak       - 感染峰值 (若 R0>1)
%           .t_peak       - 峰值时间
%
%   示例:
%       [t, S, I] = sis_model(950, 50, 0.002, 0.1, [0, 100]);

%% 解析稳态 + ODE 数值解 (核心 ≤ 50 行)

N = S0 + I0;
R0 = beta * N / gamma;

%% 参数解析
p = inputParser;
p.addParameter('nPoints', 200);
p.addParameter('Display', 'on');
p.parse(varargin{:});
opts = p.Results;

%% 解析稳态
if R0 > 1
    I_steady = N * (1 - 1/R0);
else
    I_steady = 0;
end

%% ODE 数值解
sis_ode = @(t, y) [-beta*y(1)*y(2) + gamma*y(2);
                    beta*y(1)*y(2) - gamma*y(2)];

try
    [t, Y] = ode45(sis_ode, tspan, [S0; I0], ...
                   odeset('RelTol', 1e-6));
    S = Y(:, 1);
    I = Y(:, 2);
catch
    t = linspace(tspan(1), tspan(2), opts.nPoints)';
    dt = t(2) - t(1);
    S = zeros(length(t), 1); S(1) = S0;
    I = zeros(length(t), 1); I(1) = I0;
    for k = 1:(length(t)-1)
        dS = -beta*S(k)*I(k) + gamma*I(k);
        dI =  beta*S(k)*I(k) - gamma*I(k);
        S(k+1) = S(k) + dt*dS;
        I(k+1) = I(k) + dt*dI;
    end
end

%% 峰值
[I_peak, idx] = max(I);
t_peak = t(idx);

key_points.R0 = R0;
key_points.I_steady = I_steady;
key_points.I_peak = I_peak;
key_points.t_peak = t_peak;

if strcmp(opts.Display, 'on')
    fprintf('SIS: R0=%.2f, 稳态I*=%.1f, 峰值I=%.1f (t=%.1f)\n', ...
            R0, I_steady, I_peak, t_peak);
end
end

%% Self-test
function self_test()
rng(42, 'twister');
    % Test with known steady state: R0 > 1 case
    [t, S, I, kp] = sis_model(950, 50, 0.002, 0.1, [0, 100], 'Display', 'off');
    assert(kp.R0 > 0, 'Test failed: R0 should be positive.');
    assert(kp.I_steady >= 0, 'Test failed: steady-state I should be non-negative.');
    assert(length(I) > 10, 'Test failed: should have multiple time points.');
    disp('sis_model self-test passed.');
end
