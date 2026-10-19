% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [U, S, V, explained_var] = svd_decompose(A, k, method)
% SVD_DECOMPOSE 奇异值分解及其应用
%
%   算法来源：Golub & Van Loan, Matrix Computations, 4th ed.
%   算法复杂度：完整 O(m*n*min(m,n))，截断（随机化）O(m*n*k)
%
%   输入参数:
%       A      - 输入矩阵 [m, n]
%       k      - 保留的奇异值个数 (默认 min(m,n))
%       method - 算法: 'full'(默认), 'randomized', 'power'
%
%   输出参数:
%       U      - 左奇异向量矩阵 [m, k]
%       S      - 奇异值对角矩阵 [k, k]
%       V      - 右奇异向量矩阵 [n, k]
%       explained_var - 方差解释率向量 [k, 1]
%
%   示例:
%       A = randn(100, 50);
%       [U, S, V, ev] = svd_decompose(A, 10, 'randomized');
%       A_approx = U * S * V';  % k阶近似
%
%   参考文献:
%       Halko, Martinsson & Tropp (2011). Finding Structure with
%       Randomness: Probabilistic Algorithms for Approximate Matrix
%       Decomposition. SIAM Review.

%% 参数默认值
[m, n] = size(A);
if nargin < 2 || isempty(k), k = min(m, n); end
if nargin < 3 || isempty(method), method = 'full'; end

k = min(k, min(m, n));

switch lower(method)
    case 'full'
        [U_full, S_full, V_full] = svd(full(A), 'econ');
        U = U_full(:, 1:k);
        S = S_full(1:k, 1:k);
        V = V_full(:, 1:k);

    case 'randomized'
        [U, S, V] = randomized_svd(A, k);

    case 'power'
        [U, S, V] = power_svd(A, k);

    otherwise
        error('不支持的方法: %s', method);
end

% 方差解释率
singular_values = diag(S);
explained_var = singular_values.^2 / sum(singular_values.^2);

end


function [U, S, V] = randomized_svd(A, k)
% 随机化 SVD（大规模矩阵的高效近似）
%   参考：Halko et al. (2011)

[m, n] = size(A);
p = min(k + 10, n);  % 过采样

% Step 1: 随机投影
Omega = randn(n, p);
Y = A * Omega;

% Step 2: 幂迭代增强精度 (2 次)
Y = A * (A' * Y);
Y = A * (A' * Y);

% Step 3: QR 分解求正交基
[Q, ~] = qr(Y, 0);

% Step 4: 投影到低维空间
B = Q' * A;

% Step 5: 小规模 SVD
[U_B, S, V] = svd(B, 'econ');
U = Q * U_B;

% 截断到 k
U = U(:, 1:k);
S = S(1:k, 1:k);
V = V(:, 1:k);

end


function [U, S, V] = power_svd(A, k)
% 幂迭代 SVD（求前k个最大奇异值/向量）

[m, n] = size(A);
U = zeros(m, k);
S = zeros(k, k);
V = zeros(n, k);

A_residual = A;

for i = 1:k
    % 随机初始化
    v = randn(n, 1);
    v = v / norm(v);

    % 幂迭代（交替应用 A'A）
    n_power_iter = 5;
    for p = 1:n_power_iter
        u = A_residual * v;
        u = u / norm(u);
        v = A_residual' * u;
        v = v / norm(v);
    end

    % 奇异值
    sigma = norm(A_residual * v);
    S(i, i) = sigma;

    u = A_residual * v / sigma;
    U(:, i) = u;
    V(:, i) = v;

    % 收缩：移除已提取的分量
    A_residual = A_residual - sigma * (u * v');
end

end


function [B] = svd_compress(A, energy_ratio)
% SVD_COMPRESS 基于能量保留比的 SVD 压缩
%
%   保留足够多的奇异值以解释 energy_ratio (0~1) 的方差
%
%   示例:
%       A = randn(200, 100);
%       B = svd_compress(A, 0.95);  % 保留 95% 能量

[U, S, V] = svd(full(A), 'econ');
sing_vals = diag(S);
cum_energy = cumsum(sing_vals.^2) / sum(sing_vals.^2);
k = find(cum_energy >= energy_ratio, 1, 'first');

B = U(:, 1:k) * S(1:k, 1:k) * V(:, 1:k)';

end


function [recommendations] = svd_collaborative_filter(R, k, n_recs)
% SVD_COLLABORATIVE_FILTER 基于 SVD 的协同过滤推荐
%
%   输入:
%       R      - 评分矩阵 [n_users, n_items]，缺失值为 0 或 NaN
%       k      - 潜在因子数 (默认 20)
%       n_recs - 返回的推荐数 (默认 10)
%
%   输出:
%       recommendations - 推荐结果结构体
%         .user_factors  - 用户潜在因子 [n_users, k]
%         .item_factors  - 物品潜在因子 [n_items, k]
%         .predicted_R   - 预测评分矩阵

if nargin < 2 || isempty(k), k = 20; end
if nargin < 3 || isempty(n_recs), n_recs = 10; end

% NaN → 0（缺失值处理）
R_filled = R;
R_filled(isnan(R_filled)) = 0;

% SVD 分解
[U, S, V] = svds(R_filled, k);

user_factors = U * sqrt(S);
item_factors = V * sqrt(S);

% 预测评分
predicted_R = user_factors * item_factors';

recommendations.user_factors = user_factors;
recommendations.item_factors = item_factors;
recommendations.predicted_R = predicted_R;

end

%% Self-test
function self_test()
    % Test SVD with known rank-2 matrix
    rng(42, 'twister');
    A = [1 2 3; 4 5 6; 7 8 9];  % approximately rank-2
    [U, S, V, ev] = svd_decompose(A, 2, 'full');
    assert(size(U, 2) == 2, 'Test failed: U should have 2 cols.');
    assert(size(S, 1) == 2, 'Test failed: S should be 2x2.');
    A_approx = U * S * V';
    assert(size(A_approx, 1) == 3, 'Test failed: approx should be 3x3.');
    assert(abs(sum(ev) - 1.0) < 1e-6, 'Test failed: explained var should sum to 1.');
    disp('svd_decompose self-test passed.');
end
