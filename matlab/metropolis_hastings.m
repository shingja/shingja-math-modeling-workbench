% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [samples, accept_rate, diagnostics] = metropolis_hastings( ...
    target_logpdf, proposal_sampler, proposal_logpdf, x0, n_samples, burn_in)
% METROPOLIS_HASTINGS Metropolis-Hastings 采样算法
%
%   算法来源：Metropolis et al. (1953), Hastings (1970)
%   算法复杂度：O(T * C)，T=迭代次数(含burn-in)，C=每步计算代价
%
%   输入参数:
%       target_logpdf    - 目标分布的对数概率密度函数句柄 @(x)
%       proposal_sampler - 提议分布采样函数句柄 @(x_current)
%       proposal_logpdf  - 提议分布对数概率密度函数句柄 @(x_new, x_old)
%       x0               - 初始值（向量）
%       n_samples        - 采样数量 (默认 10000)
%       burn_in          - 预热期样本数 (默认 1000)
%
%   输出参数:
%       samples      - 采样样本矩阵 [n_samples, d]
%       accept_rate  - 接受率
%       diagnostics  - 诊断结构体
%         .R_hat        - Gelman-Rubin 收敛统计量（多链时）
%         .ESS          - 有效样本量
%         .acceptances  - 每步接受状态 [n_samples, 1]
%
%   示例:
%       % 从标准正态分布采样
%       target = @(x) -0.5 * sum(x.^2);  % log N(0,I)
%       proposal_samp = @(x) x + 0.1 * randn(size(x));
%       proposal_pdf = @(x_new, x_old) 0;  % 对称提议，可忽略
%       samples = metropolis_hastings(target, proposal_samp, ...
%                                     proposal_pdf, zeros(2,1), 5000, 500);
%
%   参考文献:
%       Hastings, W.K. (1970). Monte Carlo Sampling Methods Using Markov
%       Chains and Their Applications. Biometrika.

%% 参数默认值
if nargin < 5 || isempty(n_samples), n_samples = 10000; end
if nargin < 6 || isempty(burn_in), burn_in = 1000; end

d = length(x0);
total_samples = n_samples + burn_in;

%% 初始化
samples_all = zeros(total_samples, d);
samples_all(1, :) = x0(:)';
x_current = x0(:);

logp_current = target_logpdf(x_current);
acceptances = zeros(total_samples, 1);
n_accepted = 0;

%% MH 采样
for t = 2:total_samples
    % 1. 从提议分布采样候选点
    x_proposed = proposal_sampler(x_current);
    x_proposed = x_proposed(:);

    % 2. 计算接受概率
    logp_proposed = target_logpdf(x_proposed);

    if isfinite(logp_proposed)
        log_alpha = logp_proposed - logp_current + ...
                    proposal_logpdf(x_current, x_proposed) - ...
                    proposal_logpdf(x_proposed, x_current);
    else
        log_alpha = -inf;
    end

    % 3. 接受/拒绝
    if log(rand) < log_alpha
        x_current = x_proposed;
        logp_current = logp_proposed;
        n_accepted = n_accepted + 1;
        acceptances(t) = 1;
    end

    samples_all(t, :) = x_current';
end

%% 去除预热期
samples = samples_all(burn_in+1:end, :);
accept_rate = n_accepted / total_samples;

%% 诊断
diagnostics.acceptances = acceptances;
diagnostics.accept_rate = accept_rate;
diagnostics.ESS = compute_ess(samples);

end


function [samples] = gibbs_sampler(conditional_samplers, x0, n_samples, burn_in)
% GIBBS_SAMPLER Gibbs 采样（Metropolis-Hastings 的特例）
%
%   算法复杂度：O(T * D * C)，T=迭代次数，D=维度，C=每条件分布采样代价
%
%   输入:
%       conditional_samplers - 条件分布采样函数的 cell 数组
%           conditional_samplers{j} = @(x_other) 从 P(x_j | x_{-j}) 采样
%       x0           - 初始值向量 [d, 1]
%       n_samples    - 采样数量 (默认 10000)
%       burn_in      - 预热期 (默认 1000)
%
%   示例:
%       % 从二元正态分布 Gibbs 采样
%       rho = 0.7;
%       sampler1 = @(x2) rho * x2 + sqrt(1-rho^2) * randn();
%       sampler2 = @(x1) rho * x1 + sqrt(1-rho^2) * randn();
%       samples = gibbs_sampler({sampler1, sampler2}, [0;0], 5000, 500);

if nargin < 3 || isempty(n_samples), n_samples = 10000; end
if nargin < 4 || isempty(burn_in), burn_in = 1000; end

d = length(x0);
total_samples = n_samples + burn_in;

samples_all = zeros(total_samples, d);
x = x0(:);
samples_all(1, :) = x';

for t = 2:total_samples
    for j = 1:d
        % 从条件分布 P(x_j | x_{-j}) 采样
        x_other = x([1:j-1, j+1:end]);
        x(j) = conditional_samplers{j}(x_other);
    end
    samples_all(t, :) = x';
end

samples = samples_all(burn_in+1:end, :);

end


function [samples, adapt_info] = adaptive_mh(target_logpdf, x0, n_samples, burn_in, adapt_interval)
% ADAPTIVE_MH 自适应 Metropolis-Hastings（自动调整提议分布协方差）
%
%   自适应调整协方差矩阵以匹配目标分布的形状，使接受率接近最优 0.234。

if nargin < 5 || isempty(adapt_interval), adapt_interval = 100; end

d = length(x0);
total_samples = n_samples + burn_in;

% 初始协方差
C = 2.38^2 / d * eye(d);
epsilon = 1e-6;

samples_all = zeros(total_samples, d);
samples_all(1, :) = x0(:)';
x_current = x0(:);
logp_current = target_logpdf(x_current);
n_accepted = 0;

for t = 2:total_samples
    % 从自适应协方差提议
    if t <= 2 * d
        L = chol(C + epsilon * eye(d), 'lower');
    else
        % 根据已采样点更新协方差（仅在预热期内自适应）
        if t <= burn_in && mod(t, adapt_interval) == 0
            recent_samples = samples_all(max(1,t-500):t-1, :);
            C = 2.38^2 / d * cov(recent_samples);
            C = C + epsilon * eye(d);
            [L, p] = chol(C, 'lower');
            if p > 0
                L = eye(d);  % 回退到单位协方差
            end
        elseif ~exist('L','var')
            L = eye(d);
        end
    end

    x_proposed = x_current + L * randn(d, 1);
    logp_proposed = target_logpdf(x_proposed);

    if isfinite(logp_proposed)
        log_alpha = logp_proposed - logp_current;
    else
        log_alpha = -inf;
    end

    if log(rand) < log_alpha
        x_current = x_proposed;
        logp_current = logp_proposed;
        n_accepted = n_accepted + 1;
    end

    samples_all(t, :) = x_current';
end

samples = samples_all(burn_in+1:end, :);
adapt_info.accept_rate = n_accepted / total_samples;
adapt_info.final_covariance = C;

end


%% Self-test
function self_test()
    % Test sample from N(0,1)
    rng(42, 'twister');
    target = @(x) -0.5 * sum(x.^2);  % log N(0,I)
    prop_samp = @(x) x + 0.5 * randn(size(x));
    prop_pdf = @(x_new, x_old) 0;  % symmetric
    samples = metropolis_hastings(target, prop_samp, prop_pdf, 0, 500, 100);
    assert(size(samples, 1) == 500, 'Test failed: should have 500 samples.');
    mu_est = mean(samples);
    assert(abs(mu_est) < 0.5, 'Test failed: sample mean should be near 0 for N(0,1).');
    disp('metropolis_hastings self-test passed.');
end

function ess = compute_ess(samples)
% COMPUTE_ESS 计算有效样本量 (Effective Sample Size)
%
%   ESS = N / (1 + 2 * sum_{k=1}^\infty rho_k)
%   其中 rho_k 是滞后 k 的自相关。

[n, d] = size(samples);
ess = zeros(d, 1);

for j = 1:d
    x = samples(:, j) - mean(samples(:, j));
    max_lag = min(floor(n / 4), 100);

    % 自相关
    acf = zeros(max_lag, 1);
    var_x = x' * x;
    for k = 1:max_lag
        acf(k) = (x(1:end-k)' * x(k+1:end)) / var_x;
    end

    % 截断：直到自相关之和为负
    sum_acf = 1;
    for k = 1:max_lag
        if acf(k) < 0, break; end
        sum_acf = sum_acf + 2 * acf(k);
    end

    ess(j) = n / sum_acf;
end

ess = min(ess);  % 返回最坏维度的 ESS

end


function [R_hat] = gelman_rubin(chains)
% GELMAN_RUBIN Gelman-Rubin 收敛诊断统计量 (\hat{R})
%
%   多链对比：R_hat < 1.1 通常认为收敛
%
%   输入:
%       chains - cell 数组，每个元胞为一条链的样本矩阵 [n_samples, d]
%
%   输出:
%       R_hat - [d, 1] 每维度的 R_hat 统计量

n_chains = length(chains);
[n_samples, d] = size(chains{1});

chain_means = zeros(n_chains, d);
chain_vars = zeros(n_chains, d);

for c = 1:n_chains
    chain_means(c, :) = mean(chains{c}, 1);
    chain_vars(c, :) = var(chains{c}, 0, 1);
end

% 链间方差 B
B = n_samples * var(chain_means, 0, 1);

% 链内方差 W
W = mean(chain_vars, 1);

% 边际后验方差估计
var_hat = (n_samples - 1) / n_samples * W + B / n_samples;

% R_hat
R_hat = sqrt(var_hat ./ max(W, 1e-10));

end


function [] = mcmc_diagnostics(samples, chain_name)
% MCMC_DIAGNOSTICS MCMC 采样诊断可视化
%
%   生成迹图、自相关图和直方图，辅助判断收敛性。

[n, d] = size(samples);
if nargin < 2, chain_name = 'MCMC Chain'; end

for j = 1:d
    figure('Name', sprintf('%s - 维度 %d', chain_name, j));

    % 迹图 (Trace Plot)
    subplot(2, 2, 1);
    plot(samples(:, j), 'Color', [0.2 0.4 0.7]);
    xlabel('迭代'); ylabel(sprintf('x_%d', j));
    title('迹图 (Trace Plot)');
    grid on;

    % 直方图 (Marginal Density)
    subplot(2, 2, 2);
    histogram(samples(:, j), 50, 'FaceColor', [0.2 0.4 0.7], ...
              'EdgeColor', 'none');
    xlabel(sprintf('x_%d', j)); ylabel('频数');
    title('边际分布');

    % 自相关图 (ACF)
    subplot(2, 2, 3);
    max_lag = min(50, floor(n/4));
    autocorr(samples(:, j), max_lag);
    title('自相关函数 (ACF)');

    % 累积均值 (Running Mean)
    subplot(2, 2, 4);
    running_mean = cumsum(samples(:, j)) ./ (1:n)';
    plot(running_mean, 'Color', [0.2 0.4 0.7]);
    xlabel('迭代'); ylabel('累积均值');
    title('累积均值 (Running Mean)');
    grid on;
end

end
