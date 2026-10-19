% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [mu, sigma, pi_k, loglik, exitflag] = em_algorithm(X, K, varargin)
%EM_ALGORITHM 期望最大化算法 (Expectation-Maximization) — 高斯混合模型参数估计
%   [MU, SIGMA, PI_K, LOGLIK, EXITFLAG] = EM_ALGORITHM(X, K)
%   用 EM 算法对 n×d 数据矩阵 X 拟合 K 个高斯分量, 估计混合分布参数。
%   E 步计算各样本属于各分量的后验责任度, M 步按责任度加权更新参数,
%   反复迭代直至对数似然收敛 (EM 保证似然单调不减, 收敛到局部极大)。
%
%   Source: Dempster, A.P., Laird, N.M., Rubin, D.B. (1977).
%          Maximum likelihood from incomplete data via the EM algorithm.
%          J. Royal Statistical Society: Series B, 39(1), 1-38.
%          DOI: 10.1111/j.2517-6161.1977.tb01600.x
%          李航《统计学习方法》(第2版) 第9章 EM算法及其推广 (三硬币模型/GMM)
%          教材: 数模加油站《参数估计》matlab/em.m (1-D 双分量 GMM)
%   Author: Adapted by MathModelingSkill (S6, 2026-08)
%   License: MIT
%   Verified: 2026-08-16, self-test 双分量 GMM 均值/方差/权重恢复
%
%   输入:
%       X   - 观测数据 n×d 矩阵 (n 个样本, d 维)
%       K   - 高斯分量个数 (正整数)
%
%   可选参数 (名值对):
%       'MaxIter'  - 最大迭代次数 (默认: 200)
%       'Tol'      - 对数似然收敛阈值 (默认: 1e-6)
%       'Seed'     - 随机种子, 用于均值初始化 (默认: 42)
%       'RegVar'   - 方差下界正则, 防分量坍缩 (默认: 1e-8)
%       'InitMu'   - 初始均值 K×d 矩阵 (默认: 从数据中随机抽取 K 个样本)
%       'Display'  - 'iter' | 'off' (默认: 'off')
%
%   输出:
%       mu       - 各分量均值 K×d (按混合权重降序排列)
%       sigma    - 各分量标准差 K×d (对角协方差: 各维独立)
%       pi_k     - 混合权重 K×1 (和为 1)
%       loglik   - 每次迭代的对数似然 1×T (应单调不减)
%       exitflag - 1: 似然收敛; 0: 达到最大迭代次数; -1: 似然下降(异常)
%
%   示例:
%       rng(42, 'twister');
%       X = [randn(150, 1) * 0.5 + 2; randn(150, 1) + 5];
%       [mu, sigma, pi_k] = em_algorithm(X, 2, 'Display', 'iter');
%
%   注意:
%       - 本实现用对角协方差 (各维独立), 适合数模中等规模数据;
%         全协方差请用内置 fitgmdist (Statistics Toolbox) 或 Python sklearn。
%       - EM 只保证局部极大, 建议多组 Seed 重启后取对数似然最大者。

%% 无参调用入口 (matlab -batch 自测用)
if nargin == 0
    self_test();
    return;
end

%% 参数解析
p = inputParser;
p.addRequired('X', @(x) isnumeric(x) && ismatrix(x));
p.addRequired('K', @(x) isscalar(x) && x > 0 && mod(x, 1) == 0);
p.addParameter('MaxIter', 200, @(x) isscalar(x) && x > 0);
p.addParameter('Tol', 1e-6, @(x) isscalar(x) && x > 0);
p.addParameter('Seed', 42, @(x) isscalar(x) && x >= 0);
p.addParameter('RegVar', 1e-8, @(x) isscalar(x) && x > 0);
p.addParameter('InitMu', [], @(x) isempty(x) || isnumeric(x));
p.addParameter('Display', 'off', @(x) any(strcmp(x, {'iter', 'off'})));
p.parse(X, K, varargin{:});
opts = p.Results;

[n, d] = size(X);
if K > n
    error('em_algorithm:TooManyComponents', ...
        '分量数 K=%d 超过样本数 n=%d。', K, n);
end
if any(~isfinite(X(:)))
    error('em_algorithm:NonFiniteData', '数据含 NaN 或 Inf, 请先清洗。');
end
rng(opts.Seed, 'twister');

%% 初始化
% 均值: 从数据中随机抽取 K 个不重复样本作为初始中心
idx = randperm(n, K);
mu = X(idx, :);
if ~isempty(opts.InitMu)
    if ~isequal(size(opts.InitMu), [K, d])
        error('em_algorithm:BadInitMu', 'InitMu 必须是 K×d 矩阵。');
    end
    mu = opts.InitMu;
end
sigma = repmat(std(X, 0, 1), K, 1) + 1e-6;   % 以全局标准差作初始
pi_k = ones(K, 1) / K;

loglik = zeros(1, opts.MaxIter);
exitflag = 0;
gamma_sum = zeros(n, 1);

%% EM 主循环
for iter = 1:opts.MaxIter
    % ---- E 步: 计算责任度 gamma(i,k) = P(z_i=k | x_i, theta) ----
    gamma = zeros(n, K);
    for k = 1:K
        sig_k = max(sigma(k, :), opts.RegVar);            % 方差下界
        z = (X - mu(k, :)) ./ sig_k;                      % 标准化
        % 对角高斯密度 (手写, 免 Statistics Toolbox)
        gamma(:, k) = pi_k(k) * prod(exp(-0.5 * z.^2) ./ (sqrt(2*pi) * sig_k), 2);
    end
    gamma_sum = sum(gamma, 2);                            % 边际密度 P(x_i)
    if any(gamma_sum < eps)
        warning('em_algorithm:NearZeroDensity', ...
            '存在样本密度近零, 可能由分量坍缩或初始值不当引起。');
    end
    gamma = gamma ./ max(gamma_sum, eps);                 % 归一化责任度

    % ---- M 步: 按责任度加权更新参数 ----
    Nk = sum(gamma, 1)';                                  % K×1 分量有效样本数
    mu_new = (gamma' * X) ./ max(Nk, eps);                % K×d
    sigma_new = zeros(K, d);
    for k = 1:K
        dev = X - mu_new(k, :);
        sigma_new(k, :) = sqrt(sum(gamma(:, k) .* (dev.^2), 1) ./ max(Nk(k), eps));
    end
    pi_new = Nk / n;

    % ---- 对数似然 log P(X|theta) = sum_i log P(x_i) ----
    loglik(iter) = sum(log(gamma_sum), 1);

    % ---- 收敛判断 ----
    if iter > 1
        delta = loglik(iter) - loglik(iter - 1);
        if delta < 0 && abs(delta) > 1e-6
            warning('em_algorithm:LikelihoodDecreased', ...
                '第 %d 次迭代对数似然下降 %.3e, 检查初始化与数值稳定性。', iter, delta);
            exitflag = -1;
        end
        if abs(delta) < opts.Tol
            mu = mu_new; sigma = sigma_new; pi_k = pi_new;
            loglik = loglik(1:iter);
            exitflag = 1;
            break;
        end
    end

    mu = mu_new; sigma = sigma_new; pi_k = pi_new;

    if strcmp(opts.Display, 'iter') && (iter == 1 || mod(iter, 20) == 0)
        fprintf('Iter %4d: loglik = %12.6f\n', iter, loglik(iter));
    end
end

% 按混合权重降序排列输出 (保证标签可解释性; EM 标签本身可交换)
[pi_k, order] = sort(pi_k, 'descend');
mu = mu(order, :);
sigma = sigma(order, :);

%% 收敛语义检查
if exitflag < 0
    warning('em_algorithm:DidNotConverge', ...
        'EM 未单调收敛 (exitflag=-1), 建议更换 Seed 重启并对比对数似然。');
end
end

%% Self-test
function self_test()
    % 1-D 双分量 GMM: 真值 mu=[2,5], sigma=[0.5,1], pi=[0.5,0.5]
    rng(42, 'twister');
    X = [randn(150, 1) * 0.5 + 2; randn(150, 1) * 1.0 + 5];
    [mu, sigma, pi_k, loglik, exitflag] = em_algorithm(X, 2, 'Seed', 42, 'MaxIter', 300);
    [mu, order] = sort(mu);                    % 按均值升序对齐真值
    sigma = sigma(order);
    assert(exitflag >= 0, 'Test failed: EM should converge (exitflag >= 0).');
    assert(abs(mu(1) - 2) < 0.3, sprintf('Test failed: mu1=%.3f should be ~2.', mu(1)));
    assert(abs(mu(2) - 5) < 0.5, sprintf('Test failed: mu2=%.3f should be ~5.', mu(2)));
    assert(abs(sigma(1) - 0.5) < 0.5, 'Test failed: sigma1 should be ~0.5.');
    assert(abs(sigma(2) - 1.0) < 0.6, 'Test failed: sigma2 should be ~1.0.');
    assert(abs(pi_k(1) - 0.5) < 0.1, 'Test failed: mixture weight should be ~0.5.');
    assert(loglik(end) >= loglik(1), 'Test failed: loglik should be non-decreasing.');
    disp('em_algorithm self-test passed.');
end
