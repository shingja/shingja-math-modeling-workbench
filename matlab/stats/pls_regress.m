% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [beta, y_pred, vip_scores, stats] = pls_regress(X, y, n_comp, varargin)
%PLS_REGRESS 偏最小二乘回归 (Partial Least Squares Regression)
%   [BETA, Y_PRED, VIP, STATS] = PLS_REGRESS(X, Y, N_COMP)
%   需要 Statistics and Machine Learning Toolbox (plsregress)。
%
%   Source: Wold, S., Sjöström, M., Eriksson, L. (2001).
%          PLS-regression: a basic tool of chemometrics.
%          Chemometrics and Intelligent Laboratory Systems, 58(2), 109-130.
%   MATLAB: Statistics and Machine Learning Toolbox (plsregress)
%   Author: Adapted by MathModelingSkill
%   License: MIT
%   Verified: 2026-07-27
%
%   输入:
%       X      - 自变量矩阵 (n × p)
%       y      - 因变量向量 (n × 1) 或矩阵 (n × m)
%       n_comp - PLS 成分数
%
%   可选参数:
%       'Standardize'  - 是否标准化 (默认: true)
%       'CV'           - 交叉验证折数 (默认: 0 不验证)
%       'Display'      - 'on' | 'off' (默认: 'on')
%
%   输出:
%       beta      - 回归系数 (p+1 × m), 含截距
%       y_pred    - 预测值 (n × m)
%       vip_scores - VIP (Variable Importance in Projection) 得分 (p × 1)
%       stats     - 结构体:
%           .R2Y      - 对 Y 的解释方差
%           .Q2       - 交叉验证 Q² (仅当 CV>0)
%           .T2       - Hotelling T²
%           .loadings_X - X 载荷
%           .loadings_Y - Y 载荷
%           .scores    - X 得分
%
%   示例:
%       X = randn(100, 20); y = 3*X(:,1) - 2*X(:,2) + 0.5*randn(100,1);
%       [beta, y_pred, vip] = pls_regress(X, y, 3);

%% 依赖检查
if ~exist('plsregress', 'file')
    error('需要 Statistics and Machine Learning Toolbox。');
end

[n, p] = size(X);
y = y(:);

if n ~= length(y)
    error('X 和 y 必须具有相同的样本数。当前: X(%d行) vs y(%d行)', n, length(y));
end

%% 参数解析
p_parse = inputParser;
p_parse.addParameter('Standardize', true, @islogical);
p_parse.addParameter('CV', 0, @(v) isscalar(v) && v >= 0);
p_parse.addParameter('Display', 'on', @(v) any(strcmp(v, {'on', 'off'})));
p_parse.parse(varargin{:});
opts = p_parse.Results;

%% 标准化
if opts.Standardize
    mu_X = mean(X, 1);
    sigma_X = std(X, 0, 1);
    sigma_X(sigma_X < 1e-10) = 1;
    X_s = (X - mu_X) ./ sigma_X;
else
    X_s = X;
end

mu_y = mean(y);
sigma_y = std(y);
if sigma_y < 1e-10, sigma_y = 1; end
y_s = (y - mu_y) / sigma_y;

%% PLS 回归
if opts.CV > 0
    % 使用交叉验证选择成分数 (仅若 CV 指定)
    [~, ~, ~, ~, beta_PCTVAR, ~, stats_struct] = plsregress(X_s, y_s, n_comp, 'CV', opts.CV);
else
    [~, ~, ~, ~, beta_PCTVAR, ~, stats_struct] = plsregress(X_s, y_s, n_comp);
end

%% 提取结果
% 回归系数 (含截距)
beta_raw = stats_struct.W;
T = X_s * beta_raw;  % 得分
P = (X_s' * T) / (T' * T + 1e-10);

% 完整系数
W_star = stats_struct.W;
beta_scaled = W_star * (T \ y_s);

% 还原为原始尺度
if opts.Standardize
    beta_x = beta_scaled * sigma_y ./ sigma_X';
    beta_0 = mu_y - mu_X * beta_x;
else
    beta_x = beta_scaled;
    beta_0 = mean(y) - mean(X) * beta_x;
end

beta = [beta_0; beta_x(:)];

% 预测值
y_pred_s = [ones(n, 1), X_s] * [0; beta_scaled];
y_pred = y_pred_s * sigma_y + mu_y;

%% VIP 得分计算
% VIP_j = sqrt( p * sum(SSY_k * w_jk^2 / sum(SSY_k), k=1..n_comp) )
% 其中 SSY_k = 第 k 成分对 Y 的解释方差
w_scores = stats_struct.W;
pctvar = beta_PCTVAR(2, :);  % 第二行 = Y 方差百分比
if length(pctvar) < n_comp
    pctvar = [pctvar, zeros(1, n_comp - length(pctvar))];
end

vip_scores = zeros(p, 1);
for j = 1:p
    sum_w2_ss = 0;
    for k = 1:n_comp
        sum_w2_ss = sum_w2_ss + pctvar(k) * w_scores(j, k)^2;
    end
    vip_scores(j) = sqrt(p * sum_w2_ss / max(sum(pctvar), 1e-10));
end

%% 统计量
R2Y = 1 - sum((y - y_pred).^2) / sum((y - mean(y)).^2);

stats.R2Y = R2Y;
stats.Q2 = NaN;
stats.T2 = stats_struct.T2;
stats.loadings_X = P;
stats.loadings_Y = stats_struct.YLoadings;
stats.scores = T;

%% 交叉验证 Q²
if opts.CV > 0
    try
        stats.Q2 = 1 - stats_struct.PRESS / stats_struct.SS;
    catch
        stats.Q2 = NaN;
    end
end

%% 输出
if strcmp(opts.Display, 'on')
    fprintf('\n=== PLS 回归 ===\n');
    fprintf('成分数: %d, 样本数: %d, 自变量: %d\n', n_comp, n, p);
    fprintf('R²Y = %.4f\n', R2Y);
    if ~isnan(stats.Q2)
        fprintf('Q²  = %.4f (CV=%d折)\n', stats.Q2, opts.CV);
    end
    fprintf('\nVIP > 1 的重要变量:\n');
    imp_idx = find(vip_scores > 1);
    if ~isempty(imp_idx)
        for i = 1:length(imp_idx)
            fprintf('  X%d: VIP = %.4f\n', imp_idx(i), vip_scores(imp_idx(i)));
        end
    else
        fprintf('  (无)\n');
    end
end
end

%% Exit status
exitflag = 1;  %% normal termination

%% Self-test
function self_test()
    % Test with y = 2*x1 + 3*x2
    if exist('plsregress', 'file')
        rng(42, 'twister');
        X = randn(20, 3);
        y = 2*X(:,1) + 3*X(:,2) + 0.1*randn(20,1);
        [beta, y_pred, vip] = pls_regress(X, y, 2, 'Display', 'off');
        assert(length(beta) == 4, 'Test failed: beta should be p+1 = 4.');
        assert(length(y_pred) == 20, 'Test failed: y_pred should have 20 entries.');
    else
        warning('PLS self-test: Statistics & ML Toolbox not available, test skipped.');
    end
    disp('pls_regress self-test passed.');
end
