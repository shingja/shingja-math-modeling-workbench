% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [estimate, ci95, samples, std_err] = monte_carlo(f, a, b, varargin)
%MONTE_CARLO 蒙特卡洛方法 (Monte Carlo) — 通用积分估计与期望采样
%   [ESTIMATE, CI95, SAMPLES, STD_ERR] = MONTE_CARLO(F, A, B)
%   两种模式:
%   (1) 'integral' (默认): 估计 d 维盒子上的积分 I = ∫_a^b f(x) dx,
%       由 I ≈ V·mean(f(U)), U ~ Uniform(a,b), V = prod(b-a) (含 hit-or-miss)。
%   (2) 'expectation': 估计 E[f(X)], X 由采样器 a 生成 (a = @(n) 返回 n×d)。
%   按中心极限定理给出 95% 置信区间 (1.96 分位数), 收敛速率 O(1/sqrt(N))。
%
%   Source: Metropolis, N., Ulam, S. (1949). The Monte Carlo method.
%          J. American Statistical Association, 44(247), 335-341.
%          DOI: 10.1080/01621459.1949.10483310
%          教材: 数模加油站《蒙特卡洛算法》蒙特卡洛方法实践练习.mlx/.py
%   Author: Adapted by MathModelingSkill (S6, 2026-08)
%   License: MIT
%   Verified: 2026-08-16, self-test 积分 1/3、π 估计、正态期望、误差收敛
%
%   输入:
%       f - 被积函数/统计量句柄 f(x), x 为 n×d 矩阵, 返回 n×1 (integral);
%           x 为 n×d 样本矩阵, 返回 n×1 (expectation)
%       a - integral: 积分下限 1×d 行向量 (标量=1 维);
%           expectation: 采样器句柄 @(n) 返回 n×d 样本矩阵
%       b - integral: 积分上限 1×d 行向量; expectation: 传 [] 忽略
%
%   可选参数 (名值对):
%       'N'       - 样本数 (默认: 100000)
%       'Method'  - 'integral' | 'expectation' (默认: 'integral')
%       'Seed'    - 随机种子 (默认: 42)
%       'Display' - 'iter' | 'off' (默认: 'off')
%
%   输出:
%       estimate - 积分/期望的点估计
%       ci95     - 95% 置信区间 [下界, 上界] (CLT 近似)
%       samples  - f 的 N 个样本值 n×1 (可作分布/收敛诊断)
%       std_err  - 标准误 std(samples)/sqrt(N) (收敛性指标)
%
%   示例:
%       [I, ci] = monte_carlo(@(x) x.^2, 0, 1, 'N', 1e5);        % I ≈ 1/3
%       pi_hat = 4 * monte_carlo(@(x) sum(x.^2, 2) <= 1, [0 0], [1 1]); % π
%       E = monte_carlo(@(x) x.^2, @(n) randn(n, 1), [], ...
%           'Method', 'expectation');                           % E[X²]=1
%
%   注意:
%       - 收敛速率仅 O(1/sqrt(N)): 精度每提高 1 位需样本量 ×100,
%         高精度需求应改用拟蒙特卡洛 (Sobol/拉丁超立方) 或数值积分。
%       - 置信区间基于 CLT 正态近似, N < 100 时偏乐观。
%       - 随机算法: 结果依赖 Seed, 报告结果时固定 Seed 保证可复现。

%% 无参调用入口 (matlab -batch 自测用)
if nargin == 0
    self_test();
    return;
end

%% 参数解析
p = inputParser;
p.addRequired('f', @(x) isa(x, 'function_handle'));
p.addRequired('a', @(x) isnumeric(x) || isa(x, 'function_handle'));
p.addRequired('b', @(x) isnumeric(x) || isempty(x));
p.addParameter('N', 100000, @(x) isscalar(x) && x > 0 && mod(x, 1) == 0);
p.addParameter('Method', 'integral', @(x) any(strcmp(x, {'integral', 'expectation'})));
p.addParameter('Seed', 42, @(x) isscalar(x) && x >= 0);
p.addParameter('Display', 'off', @(x) any(strcmp(x, {'iter', 'off'})));
p.parse(f, a, b, varargin{:});
opts = p.Results;

rng(opts.Seed, 'twister');
N = opts.N;

%% 采样
if strcmp(opts.Method, 'expectation')
    % E[f(X)], X ~ 采样器 a
    X = a(N);
    vals = f(X);
    estimate = mean(vals);
else
    % ∫_a^b f(x) dx, 均匀采样于 d 维盒子
    a = a(:)'; b = b(:)';
    dim = length(a);
    if length(b) ~= dim
        error('monte_carlo:DimMismatch', '积分上下限维度不一致。');
    end
    if any(b <= a)
        error('monte_carlo:BadBounds', '积分上限必须严格大于下限。');
    end
    U = a + rand(N, dim) .* (b - a);       % N×d 均匀样本
    vals = f(U);
    if numel(vals) ~= N
        error('monte_carlo:BadF', '被积函数 f 必须对 n×d 输入返回 n×1 向量。');
    end
    estimate = prod(b - a) * mean(vals);   % V·mean(f(U))
end

%% 统计量与置信区间
samples = vals(:);
std_err = std(samples) / sqrt(N);
ci95 = estimate + 1.96 * std_err * [-1, 1];   % CLT 正态近似 95% CI

if strcmp(opts.Display, 'iter')
    fprintf('MC estimate = %.6f, 95%% CI = [%.6f, %.6f], std_err = %.3e\n', ...
        estimate, ci95(1), ci95(2), std_err);
end
end

%% Self-test
function self_test()
    % (1) 积分 ∫_0^1 x² dx = 1/3
    [I, ci] = monte_carlo(@(x) x.^2, 0, 1, 'N', 100000, 'Seed', 42);
    assert(abs(I - 1/3) < 0.01, sprintf('Test failed: I=%.4f should be ~1/3.', I));
    assert(ci(1) <= 1/3 && 1/3 <= ci(2), 'Test failed: CI should cover 1/3.');

    % (2) π 估计 (第一象限 hit-or-miss): P(x²+y²≤1) = π/4
    pi_hat = 4 * monte_carlo(@(x) sum(x.^2, 2) <= 1, [0 0], [1 1], ...
        'N', 100000, 'Seed', 7);
    assert(abs(pi_hat - pi) < 0.02, sprintf('Test failed: pi_hat=%.4f.', pi_hat));

    % (3) 期望 E[X²] = 1, X ~ N(0,1)
    E = monte_carlo(@(x) x.^2, @(n) randn(n, 1), [], ...
        'Method', 'expectation', 'N', 100000, 'Seed', 3);
    assert(abs(E - 1) < 0.02, sprintf('Test failed: E=%.4f should be ~1.', E));

    % (4) 收敛性: 标准误应随 sqrt(N) 下降, N×100 应使 std_err 缩小约 10 倍
    [~, ~, ~, se_small] = monte_carlo(@(x) x.^2, 0, 1, 'N', 1000, 'Seed', 42);
    [~, ~, ~, se_large] = monte_carlo(@(x) x.^2, 0, 1, 'N', 100000, 'Seed', 42);
    assert(se_small > 2 * se_large, ...
        sprintf('Test failed: std_err should shrink with N (%.3e vs %.3e).', ...
        se_small, se_large));
    disp('monte_carlo self-test passed.');
end
