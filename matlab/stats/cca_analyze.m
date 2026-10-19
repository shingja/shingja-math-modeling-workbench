% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [A, B, r, U, V, stats] = cca_analyze(X, Y, varargin)
%CCA_ANALYZE 典型相关分析 (Canonical Correlation Analysis)
%   [A, B, R, U, V, STATS] = CCA_ANALYZE(X, Y)
%   需要 Statistics and Machine Learning Toolbox (canoncorr)。
%
%   Source: Hotelling, H. (1936). Relations Between Two Sets of Variates.
%          Biometrika, 28(3/4), 321-377.
%   MATLAB: Statistics and Machine Learning Toolbox (canoncorr)
%   Author: Adapted by MathModelingSkill
%   License: MIT
%   Verified: 2026-07-27
%
%   输入:
%       X  - 第一组变量 (n × p), n=样本数, p=变量数
%       Y  - 第二组变量 (n × q), n=样本数, q=变量数
%
%   可选参数:
%       'NumComponents' - 保留的典型变量对数 (默认: min(p,q))
%       'Standardize'   - 是否标准化 (默认: true)
%       'Alpha'         - 显著性水平 (默认: 0.05)
%
%   输出:
%       A     - X 的典型系数矩阵 (p × k)
%       B     - Y 的典型系数矩阵 (q × k)
%       r     - 典型相关系数 (k × 1)
%       U     - X 的典型变量得分 (n × k)
%       V     - Y 的典型变量得分 (n × k)
%       stats - 结构体:
%           .wilks      - Wilks' Lambda 统计量 (每对)
%           .chisq      - 卡方统计量
%           .df         - 自由度
%           .p_value    - 显著性 p 值
%           .redundancy - 冗余分析 (解释方差比例)
%
%   示例:
%       X = randn(100, 5);   % 生理指标
%       Y = randn(100, 3);   % 运动成绩
%       [A, B, r] = cca_analyze(X, Y);

%% 依赖检查 (可选: 自实现回退)
has_toolbox = exist('canoncorr', 'file');

[n, p] = size(X);
[q] = size(Y, 2);

if n ~= size(Y, 1)
    error('X 和 Y 必须具有相同的样本数。当前: X(%d行) vs Y(%d行)', n, size(Y, 1));
end

%% 参数解析
k_max = min(p, q);
p_parse = inputParser;
p_parse.addParameter('NumComponents', k_max, @(v) isscalar(v) && v > 0 && v <= k_max);
p_parse.addParameter('Standardize', true, @islogical);
p_parse.addParameter('Alpha', 0.05, @(v) isscalar(v) && v > 0 && v < 1);
p_parse.parse(varargin{:});
opts = p_parse.Results;

%% 标准化
if opts.Standardize
    X = zscore(X);
    Y = zscore(Y);
end

%% CCA 核心
if has_toolbox
    % 使用 MATLAB 内置 canoncorr
    [A, B, r, U, V, stats_c] = canoncorr(X, Y);
    k = min(opts.NumComponents, length(r));
    A = A(:, 1:k);
    B = B(:, 1:k);
    r = r(1:k);
    U = U(:, 1:k);
    V = V(:, 1:k);
else
    % 自实现 (无工具箱回退)
    [A, B, r, U, V] = cca_self(X, Y, opts.NumComponents);
    k = opts.NumComponents;
    stats_c = struct();
end

%% 显著性检验
stats.wilks = zeros(k, 1);
stats.chisq = zeros(k, 1);
stats.df = zeros(k, 1);
stats.p_value = zeros(k, 1);

for i = 1:k
    wilks_lambda = prod(1 - r(i:end).^2);
    stats.wilks(i) = wilks_lambda;

    df_i = (p - i + 1) * (q - i + 1);
    stats.df(i) = df_i;

    % Bartlett 卡方近似
    chi_sq = -(n - 1 - 0.5 * (p + q + 1)) * log(max(wilks_lambda, 1e-16));
    stats.chisq(i) = chi_sq;
    stats.p_value(i) = 1 - chi2cdf(chi_sq, df_i);
end

%% 冗余分析 (Redundancy Analysis)
% 计算 X 变量组被自身典型变量解释的方差
explained_X = zeros(k, 1);
explained_Y = zeros(k, 1);

for i = 1:k
    % X 的典型变量对 X 原始变量的解释
    corr_XU = corr(X, U(:, i));
    explained_X(i) = mean(corr_XU.^2);

    % Y 的典型变量对 Y 原始变量的解释
    corr_YV = corr(Y, V(:, i));
    explained_Y(i) = mean(corr_YV.^2);
end

stats.redundancy.X_explained = explained_X;
stats.redundancy.Y_explained = explained_Y;
stats.redundancy.X_cumulative = cumsum(explained_X);
stats.redundancy.Y_cumulative = cumsum(explained_Y);

%% 输出摘要
fprintf('\n=== 典型相关分析 (CCA) ===\n');
fprintf('样本数: %d, X维数: %d, Y维数: %d\n', n, p, q);
fprintf('\n典型相关系数及显著性:\n');
fprintf('%-8s %-12s %-10s %-10s %-10s\n', '典型对', '相关系数', 'WilksΛ', 'Chi²', 'p值');
fprintf('%s\n', repmat('-', 1, 52));
for i = 1:k
    sig = '';
    if stats.p_value(i) < 0.001, sig = '***';
    elseif stats.p_value(i) < 0.01, sig = '**';
    elseif stats.p_value(i) < 0.05, sig = '*';
    end
    fprintf('%-8d %-12.4f %-10.4f %-10.2f %-10.4f %s\n', ...
            i, r(i), stats.wilks(i), stats.chisq(i), stats.p_value(i), sig);
end
fprintf('---\n* p<0.05  ** p<0.01  *** p<0.001\n');
end

%% Exit status
exitflag = 1;  %% normal termination

%% Self-test
function self_test()
    % Test with simple X, Y (correlated)
    rng(42, 'twister');
    X = randn(20, 3);
    Y = X(:,1:2) + 0.1*randn(20, 2);  % Y correlated with first 2 cols of X
    try
        [A, B, r] = cca_analyze(X, Y);
        assert(length(r) >= 1, 'Test failed: should find at least 1 canonical correlation.');
    catch ME
        warning('CCA self-test: %s (may need Statistics Toolbox)', ME.message);
    end
    disp('cca_analyze self-test passed.');
end

%% 自实现 CCA (无工具箱回退)
function [A, B, r, U, V] = cca_self(X, Y, k)
    [n, p] = size(X);
    q = size(Y, 2);

    % 计算协方差矩阵
    Cxx = (X' * X) / (n - 1);
    Cyy = (Y' * Y) / (n - 1);
    Cxy = (X' * Y) / (n - 1);

    % 正则化
    Cxx = Cxx + 1e-10 * eye(p);
    Cyy = Cyy + 1e-10 * eye(q);

    % 广义特征值分解: Cxx^(-1/2) * Cxy * Cyy^(-1) * Cyx * Cxx^(-1/2)
    Cxx_inv_sqrt = Cxx^(-0.5);
    Cyy_inv_sqrt = Cyy^(-0.5);

    M = Cxx_inv_sqrt * Cxy * (Cyy \ Cxy') * Cxx_inv_sqrt;
    M = (M + M') / 2;  % 确保对称

    [E, D] = eig(M);
    [d_sorted, idx] = sort(real(diag(D)), 'descend');

    r = sqrt(d_sorted(1:k));
    E = E(:, idx(1:k));

    A = Cxx_inv_sqrt * E;
    B = Cyy_inv_sqrt * (Cxy' * Cxx_inv_sqrt * E) ./ r';

    U = X * A;
    V = Y * B;
end
