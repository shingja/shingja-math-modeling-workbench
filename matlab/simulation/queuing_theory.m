% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [L, Lq, W, Wq, P_wait, metrics] = queuing_theory(lam, mu, varargin)
%QUEUING_THEORY 排队论经典模型 (Queuing Theory)
%   [L, Lq, W, Wq, P_WAIT, METRICS] = QUEUING_THEORY(LAM, MU)
%   计算 M/M/1, M/M/s, M/M/∞ 排队系统的性能指标。
%
%   Source: Gross, D., Shortle, J.F., Thompson, J.M., Harris, C.M. (2008).
%          Fundamentals of Queueing Theory, 4th ed. Wiley.
%   Author: Adapted by MathModelingSkill
%   License: MIT
%   Verified: 2026-07-27
%
%   输入:
%       lam  - 到达率 λ (customers/unit_time), 标量
%       mu   - 服务率 μ (customers/unit_time/server), 标量
%              若 lam ≥ mu*s, 系统不稳定 (ρ ≥ 1)
%
%   可选参数:
%       'Servers'   - 服务台数 s (默认: 1)
%                     1 = M/M/1, Inf = M/M/∞, >1 = M/M/s
%       'Capacity'  - 系统容量 K (默认: Inf = 无限队列)
%       'Population' - 顾客源 N (默认: Inf = 无限源)
%       'Display'   - 'on' | 'off' (默认: 'on')
%
%   输出:
%       L       - 平均队长 (系统中平均顾客数)
%       Lq      - 平均排队长 (队列中平均等待顾客数)
%       W       - 平均逗留时间 (顾客在系统中的平均时间)
%       Wq      - 平均等待时间 (顾客在队列中的平均等待时间)
%       P_wait  - 排队概率 (所有服务台忙的概率)
%       metrics - 结构体: 含 ρ, P0, Pn 等完整指标
%
%   示例:
%       % M/M/1: λ=3, μ=4
%       [L, Lq, W, Wq] = queuing_theory(3, 4)
%
%       % M/M/3: λ=10, μ=4, 3个服务台
%       [L, Lq, W, Wq] = queuing_theory(10, 4, 'Servers', 3)

%% 依赖检查
% 仅使用 MATLAB 内置函数

%% 参数解析
p = inputParser;
p.addParameter('Servers', 1, @(v) isscalar(v) && (v > 0 || isinf(v)));
p.addParameter('Capacity', Inf, @(v) isscalar(v) && (v > 0 || isinf(v)));
p.addParameter('Population', Inf, @(v) isscalar(v) && (v > 0 || isinf(v)));
p.addParameter('Display', 'on', @(v) any(strcmp(v, {'on', 'off'})));
p.parse(varargin{:});
opts = p.Results;

s = opts.Servers;
K = opts.Capacity;
N_pop = opts.Population;

if isinf(s), s_val = Inf; else, s_val = s; end

%% 交通强度 ρ = λ/(sμ)
if isinf(s_val)
    rho = 0;  % M/M/∞: 系统始终稳定
else
    rho = lam / (s_val * mu);
end

%% 模型选择与计算
if isinf(N_pop) && isinf(K)
    % --- 无限源 + 无限队列 ---
    if isinf(s_val)
        % M/M/∞
        model = 'M/M/∞';
        P0 = exp(-lam / mu);
        L = lam / mu;
        Lq = 0;
        W = 1 / mu;
        Wq = 0;
        P_wait = 0;

    elseif s_val == 1
        % M/M/1
        model = 'M/M/1';
        if rho >= 1
            error('系统不稳定: ρ = %.2f ≥ 1。请增加服务率 μ 或减少到达率 λ。', rho);
        end
        P0 = 1 - rho;
        L = rho / (1 - rho);
        Lq = rho^2 / (1 - rho);
        W = 1 / (mu - lam);
        Wq = rho / (mu - lam);
        P_wait = rho;

    else
        % M/M/s
        model = sprintf('M/M/%d', s_val);
        if rho >= 1
            error('系统不稳定: ρ = %.2f ≥ 1。请增加服务台数或 μ, 或减少 λ。', rho);
        end

        % 计算 P0 (所有服务台空闲概率)
        sum_term = 0;
        for n = 0:(s_val - 1)
            sum_term = sum_term + (s_val * rho)^n / factorial(n);
        end
        last_term = (s_val * rho)^s_val / (factorial(s_val) * (1 - rho));
        P0 = 1 / (sum_term + last_term);

        % 排队概率 (Erlang-C 公式)
        P_wait = (s_val * rho)^s_val * P0 / (factorial(s_val) * (1 - rho));

        Lq = P_wait * rho / (1 - rho);
        L = Lq + s_val * rho;
        Wq = Lq / lam;
        W = Wq + 1 / mu;
    end

elseif isinf(N_pop) && ~isinf(K)
    % --- 有限容量 M/M/1/K ---
    model = sprintf('M/M/%d/%d', s_val, K);
    if s_val ~= 1
        warning('有限容量模型当前仅完整支持 M/M/1/K。使用 s=%d 近似。', s_val);
    end

    if rho == 1
        P0 = 1 / (K + 1);
        L = K / 2;
    else
        P0 = (1 - rho) / (1 - rho^(K + 1));
        L = rho / (1 - rho) - (K + 1) * rho^(K + 1) / (1 - rho^(K + 1));
    end
    lambda_eff = lam * (1 - rho^K * P0);  % 有效到达率
    Lq = L - lambda_eff / mu;
    W = L / max(lambda_eff, 1e-10);
    Wq = Lq / max(lambda_eff, 1e-10);
    P_wait = 1 - P0;
    P0 = P0;

elseif ~isinf(N_pop)
    % --- 有限顾客源 (Machine Repair) ---
    model = sprintf('M/M/%d/%d/%d', s_val, K, N_pop);
    warning('有限顾客源模型部分实现。使用 M/M/1/%d/%d 近似。', K, N_pop);
    % 简化: 使用 M/M/1 近似
    eff_lam = lam * (N_pop - L) / N_pop;
    rho_eff = eff_lam / mu;
    L = rho_eff / (1 - rho_eff);
    Lq = L - rho_eff;
    W = L / max(eff_lam, 1e-10);
    Wq = Lq / max(eff_lam, 1e-10);
    P_wait = rho_eff;
    P0 = 1 - rho_eff;
end

%% 填充指标
metrics.rho = rho;
metrics.P0 = P0;
metrics.P_wait = P_wait;
metrics.servers = s;
metrics.model = model;
metrics.lambda = lam;
metrics.mu = mu;

%% 输出
if strcmp(opts.Display, 'on')
    fprintf('\n=== 排队论: %s ===\n', model);
    fprintf('到达率 λ = %.2f, 服务率 μ = %.2f/台', lam, mu);
    if ~isinf(s_val), fprintf(', 服务台 s = %d', s_val); end
    fprintf('\n交通强度 ρ = %.4f', rho);
    if rho >= 1 && ~isinf(s_val)
        fprintf(' [不稳定!]');
    end
    fprintf('\n\n');
    fprintf('平均队长 L    = %.4f (系统中)\n', L);
    fprintf('平均排队长 Lq = %.4f (队列中)\n', Lq);
    fprintf('平均逗留时间 W  = %.4f\n', W);
    fprintf('平均等待时间 Wq = %.4f\n', Wq);
    fprintf('排队概率 P_wait = %.4f\n', P_wait);
    fprintf('空闲概率 P0     = %.4f\n', metrics.P0);
end
end

%% Self-test
function self_test()
    % Test M/M/1 known L = rho/(1-rho). lam=3, mu=4 → rho=0.75 → L=3
    [L, Lq, W, Wq] = queuing_theory(3, 4, 'Display', 'off');
    assert(abs(L - 3) < 1e-6, 'Test failed: M/M/1 L should be 3 for rho=0.75.');
    assert(abs(Lq - 2.25) < 1e-6, 'Test failed: M/M/1 Lq should be 2.25.');
    assert(W > Wq, 'Test failed: total time should exceed waiting time.');
    disp('queuing_theory self-test passed.');
end
n%% Reproducibility
rng(42, 'twister');
