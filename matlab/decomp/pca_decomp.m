% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [coeff, score, latent, explained] = pca_decomp(X, varargin)
% PCA_DECOMP  Principal Component Analysis by SVD of centered data.
%
%   [COEFF, SCORE, LATENT, EXPLAINED] = PCA_DECOMP(X)
%   X: n×p data matrix (n observations, p variables).
%
%   Optional name-value pairs:
%   'Center',  true|false: mean-center data (default true).
%   'Scale',   true|false: standardize to unit variance (default false).
%   'NumComponents', k: retain top k PCs only (default: all).
%
%   COEFF:     p×p matrix of eigenvectors (loadings). COEFF(:,j) = j-th PC.
%   SCORE:     n×p matrix. SCORE(i,j) = projection of observation i onto PC j.
%   LATENT:    p×1 vector of eigenvalues (variances).
%   EXPLAINED: p×1 vector, percentage of variance explained by each PC.
%
%   Example:
%       X = randn(100, 5);
%       [coeff, score, latent, explained] = pca_decomp(X);
%       bar(explained);  % scree plot
%
%   References:
%       Jolliffe, I.T. (2002). Principal Component Analysis, 2nd ed. Springer.
%       《各类常用数学模型》第29章 多元分析

p = inputParser;
p.addRequired('X', @isnumeric);
p.addParameter('Center', true, @islogical);
p.addParameter('Scale', false, @islogical);
p.addParameter('NumComponents', [], @isnumeric);
p.parse(X, varargin{:});

opts = p.Results;
[n, p_dim] = size(X);

% Center and scale
mu = zeros(1, p_dim);
sigma = ones(1, p_dim);
X_work = X;

if opts.Center
    mu = mean(X_work, 1);
    X_work = X_work - mu;
end

if opts.Scale
    sigma = std(X_work, 0, 1);
    sigma(sigma == 0) = 1;  % avoid division by zero
    X_work = X_work ./ sigma;
end

% SVD of centered/scaled data
[~, S, V] = svd(X_work, 'econ');

% Eigenvalues
eigvals = (diag(S).^2) / (n - 1);  % unbiased variance estimate

% Retain requested number of components
if isempty(opts.NumComponents)
    k = min(n, p_dim);
else
    k = min(opts.NumComponents, min(n, p_dim));
end

coeff   = V(:, 1:k);
score   = X_work * coeff;
latent  = eigvals(1:k);
explained = 100 * latent / sum(eigvals);
end

%% Self-test
function self_test()
    % Test with 3x2 data
    X = [1 2; 3 4; 5 6];
    [coeff, score, latent, explained] = pca_decomp(X);
    assert(size(coeff, 2) == 2, 'Test failed: coeff should have 2 columns.');
    assert(size(score, 1) == 3, 'Test failed: score should have 3 rows.');
    assert(abs(sum(explained) - 100) < 1e-6, 'Test failed: explained should sum to 100.');
    disp('pca_decomp self-test passed.');
end
n%% Reproducibility
rng(42, 'twister');
