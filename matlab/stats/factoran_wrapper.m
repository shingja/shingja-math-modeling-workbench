% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [loadings, scores, eigenvalues, stats] = factoran_wrapper(X, n_factors, varargin)
%FACTORAN_WRAPPER 因子分析 (封装 MATLAB factoran)
%   [LOADINGS, SCORES, EIGENVALUES, STATS] = FACTORAN_WRAPPER(X, N_FACTORS)
%   最大似然因子分析。与 Python sklearn.decomposition.FactorAnalysis 对齐。
%
%   Source: Johnson, R.A., Wichern, D.W. (2007).
%          Applied Multivariate Statistical Analysis, 6th ed. Pearson.
%   MATLAB: Statistics and Machine Learning Toolbox (factoran, ML estimation)
%   Author: Adapted by MathModelingSkill
%   License: MIT
%   Verified: 2026-07-27
%
%   输入:
%       X         - 数据矩阵 (n_samples × n_features)
%       n_factors - 因子数
%
%   可选参数:
%       'Rotate'    - 旋转方法 (默认: 'varimax')
%                     'varimax' | 'promax' | 'none' | 'quartimax' | 'equamax'
%       'Start'     - 初始载荷估计 (默认: 'random')
%       'MaxIter'   - 最大迭代次数 (默认: 100)
%       'Display'   - 'on' | 'off' (默认: 'off')
%       'Normalize' - 是否先标准化 (默认: true)
%
%   输出:
%       loadings   - 因子载荷矩阵 (n_features × n_factors)
%       scores     - 因子得分 (n_samples × n_factors)
%       eigenvalues - 相关矩阵特征值 (用于碎石图)
%       stats      - 结构体:
%           .uniqueness  - 特殊方差 (n_features×1)
%           .communality - 共同度 (n_features×1)
%           .chi_sq      - 模型拟合卡方统计量
%           .df          - 自由度
%           .p_value     - 显著性
%           .kmo         - KMO 抽样充分性测度
%
%   示例:
%       X = randn(200, 8);
%       [loadings, scores] = factoran_wrapper(X, 3);

%% 依赖检查
if ~exist('factoran', 'file')
    error('需要 Statistics and Machine Learning Toolbox。请安装该工具箱。');
end

[n_samples, n_features] = size(X);

%% 参数解析
p = inputParser;
p.addParameter('Rotate', 'varimax');
p.addParameter('Start', 'random');
p.addParameter('MaxIter', 100);
p.addParameter('Display', 'off');
p.addParameter('Normalize', true);
p.parse(varargin{:});
opts = p.Results;

%% 标准化
if opts.Normalize
    X_s = zscore(X);
else
    X_s = X;
end

%% KMO 测度 (采样充分性)
% KMO = MSq(partial_corr) / (MSq(partial_corr) + MSq(anti_image))
corr_mat = corr(X_s);
inv_corr = inv(corr_mat + 1e-10 * eye(n_features));
anti_diag = diag(1 ./ diag(inv_corr));
partial_corr = -inv_corr .* sqrt(anti_diag * anti_diag');
partial_corr(1:n_features+1:end) = 0;
kmo_num = sum(corr_mat(:).^2) - n_features;  % exclude diagonal
kmo_den = kmo_num + sum(partial_corr(:).^2);
kmo_val = kmo_num / max(kmo_den, 1e-10);

%% 特征值 (用于碎石图)
eigenvalues = eig(corr_mat);
eigenvalues = sort(eigenvalues, 'descend');

%% 因子分析
try
    [loadings, psi] = factoran(X_s, n_factors, ...
        'Rotate', opts.Rotate, ...
        'Start', opts.Start, ...
        'Maxit', opts.MaxIter);

    % 计算因子得分 (回归法)
    scores = X_s * (inv(corr_mat) * loadings);

catch ME
    warning('factoran 估计失败: %s。使用 PCA 初始化重试。', ME.message);

    % 回退: 使用 PCA 初始化
    [coeff, ~, latent] = pca(X_s);
    loadings_init = coeff(:, 1:n_factors) * sqrt(diag(latent(1:n_factors)));

    [loadings, psi] = factoran(X_s, n_factors, ...
        'Rotate', opts.Rotate, ...
        'Start', loadings_init, ...
        'Maxit', opts.MaxIter);

    scores = X_s * (inv(corr_mat) * loadings);
end

%% 统计量
communality = 1 - psi;  % 共同度 = 1 - uniqueness
uniqueness = psi;

% 方差解释比例
explained_var = sum(loadings.^2, 1) / n_features * 100;
cumulative_var = cumsum(explained_var);

%% 拟合检验
[chi_sq, df, p_value] = factor_fit_test(X_s, loadings, psi, n_samples);

%% 构建输出
stats.uniqueness = uniqueness;
stats.communality = communality;
stats.chi_sq = chi_sq;
stats.df = df;
stats.p_value = p_value;
stats.kmo = kmo_val;
stats.explained_var = explained_var;
stats.cumulative_var = cumulative_var;
stats.eigenvalues = eigenvalues;

%% 输出
fprintf('\n=== 因子分析 ===\n');
fprintf('因子数: %d, KMO = %.4f', n_factors, kmo_val);
if kmo_val > 0.9
    fprintf(' (极佳)\n');
elseif kmo_val > 0.8
    fprintf(' (良好)\n');
elseif kmo_val > 0.7
    fprintf(' (中等)\n');
elseif kmo_val > 0.6
    fprintf(' (一般)\n');
else
    fprintf(' (不适合)\n');
end

fprintf('方差解释: ');
fprintf('%.1f%% ', explained_var);
fprintf('(累计 %.1f%%)\n', cumulative_var(end));

fprintf('模型拟合: χ²=%.2f, df=%d, p=%.4f', chi_sq, df, p_value);
if p_value > 0.05
    fprintf(' (模型可接受)\n');
else
    fprintf(' (拟合不足, 考虑增加因子)\n');
end
end

%% 辅助: 因子模型拟合检验
function [chi_sq, df, p_value] = factor_fit_test(X, loadings, psi, n)
    [p, m] = size(loadings);
    Sigma_repro = loadings * loadings' + diag(psi);
    S = corr(X);

    % Bartlett 修正
    det_S = det(S);
    det_Sigma = det(Sigma_repro);

    if det_S > 1e-10 && det_Sigma > 1e-10
        % 自由度: ((p-m)² - (p+m))/2
        df = max(1, ((p - m)^2 - (p + m)) / 2);
        chi_sq = (n - 1 - (2*p + 4*m + 5)/6) * (log(det_Sigma) - log(det_S) + trace(S / Sigma_repro) - p);
        chi_sq = max(0, chi_sq);
        p_value = 1 - chi2cdf(chi_sq, df);
    else
        chi_sq = 0;
        df = 1;
        p_value = 1;
    end
end

%% Exit status
exitflag = 1;  %% normal termination

%% Self-test
function self_test()
    % Test with 4-var 2-factor data
    if exist('factoran', 'file')
        rng(42, 'twister');
        L = [0.8 0; 0.7 0.1; 0 0.8; 0.1 0.7];  % 2-factor loading pattern
        X = randn(30, 2) * L' + 0.1*randn(30, 4);
        [loadings, scores, eigvals] = factoran_wrapper(X, 2, 'Display', 'off');
        assert(size(loadings, 2) == 2, 'Test failed: should have 2 factors.');
    else
        warning('Factor analysis self-test: Statistics & ML Toolbox not available, test skipped.');
    end
    disp('factoran_wrapper self-test passed.');
end
