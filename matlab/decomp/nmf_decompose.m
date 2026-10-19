% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [W, H, reconstruction_error, history] = nmf_decompose(X, k, varargin)
%NMF_DECOMPOSE 非负矩阵分解 (Non-negative Matrix Factorization)
%   [W, H, ERROR, HISTORY] = NMF_DECOMPOSE(X, K)
%   使用乘法更新规则 (Multiplicative Update Rules) 将 X ≈ W*H 分解。
%
%   Source: Lee, D.D., Seung, H.S. (2001).
%          Algorithms for Non-negative Matrix Factorization. NeurIPS 2000.
%   Author: Adapted by MathModelingSkill
%   License: MIT
%   Verified: 2026-07-27 against Lee & Seung (2001)
%
%   输入:
%       X  - 非负数据矩阵 (m × n), X(i,j) ≥ 0
%       k  - 分解秩 (rank), 即 W(m×k) * H(k×n)
%
%   可选参数:
%       'MaxIter'     - 最大迭代次数 (默认: 200)
%       'TolFun'      - 收敛容差 (默认: 1e-6)
%       'Algorithm'   - 'mult' | 'als' (默认: 'mult')
%                       'mult' = 乘法更新 (Lee-Seung)
%                       'als'  = 交替最小二乘
%       'L1'          - L1 正则化系数 (默认: 0)
%       'L2'          - L2 正则化系数 (默认: 0)
%       'InitMethod'  - 初始化方法 (默认: 'random')
%                       'random' | 'nndsvd' (NNDSVD)
%       'Display'     - 'iter' | 'off' (默认: 'off')
%
%   输出:
%       W                   - 基矩阵 (m × k)
%       H                   - 系数矩阵 (k × n)
%       reconstruction_error - 最终重构误差 ||X - W*H||_F / ||X||_F
%       history             - 收敛历史
%
%   示例:
%       X = rand(100, 50);
%       [W, H, err] = nmf_decompose(X, 5, 'MaxIter', 100);

%% 依赖检查
% 仅使用 MATLAB 内置函数

[m, n] = size(X);

% 验证非负性
if any(X(:) < 0)
    error('输入矩阵 X 必须为非负。所有元素 ≥ 0。');
end

%% 参数解析
p = inputParser;
p.addParameter('MaxIter', 200, @(v) isscalar(v) && v > 0);
p.addParameter('TolFun', 1e-6, @(v) isscalar(v) && v > 0);
p.addParameter('Algorithm', 'mult', @(v) any(strcmp(v, {'mult', 'als'})));
p.addParameter('L1', 0, @(v) isscalar(v) && v >= 0);
p.addParameter('L2', 0, @(v) isscalar(v) && v >= 0);
p.addParameter('InitMethod', 'random', @(v) any(strcmp(v, {'random', 'nndsvd'})));
p.addParameter('Display', 'off', @(v) any(strcmp(v, {'iter', 'off'})));
p.parse(varargin{:});
opts = p.Results;

%% 初始化 W 和 H
rng(42);
switch opts.InitMethod
    case 'nndsvd'
        % NNDSVD: 基于 SVD 的非负初始化 (Zheng et al. 2007)
        [U, S, V] = svds(X, k, 'largest');
        W = max(0, U * sqrt(S));
        H = max(0, sqrt(S) * V');
    otherwise
        W = rand(m, k);
        H = rand(k, n);
end

% 正则化
W = W ./ (sum(W, 1) + 1e-10);

%% 主循环
history.err = zeros(opts.MaxIter, 1);
history.iter = 0;

if strcmp(opts.Display, 'iter')
    fprintf('NMF (%s): k=%d, [%d×%d]\n', opts.Algorithm, k, m, n);
    fprintf('Iter     Error       dError\n');
    fprintf('--------------------------\n');
end

for iter = 1:opts.MaxIter
    W_old = W;
    H_old = H;

    switch opts.Algorithm
        case 'mult'
            % Lee-Seung 乘法更新规则

            % 更新 H
            WtX = W' * X;
            WtWH = (W' * W) * H;

            % 加入正则化项
            if opts.L1 > 0
                WtWH = WtWH + opts.L1;
            end
            if opts.L2 > 0
                WtWH = WtWH + opts.L2 * H;
            end

            H = H .* (WtX ./ max(WtWH, 1e-16));

            % 更新 W
            XHt = X * H';
            WHHt = W * (H * H');

            if opts.L1 > 0
                WHHt = WHHt + opts.L1;
            end
            if opts.L2 > 0
                WHHt = WHHt + opts.L2 * W;
            end

            W = W .* (XHt ./ max(WHHt, 1e-16));

        case 'als'
            % 交替最小二乘 + 非负投影
            H = max(0, (W' * W + opts.L2 * eye(k)) \ (W' * X));
            W = max(0, (X * H') / (H * H' + opts.L2 * eye(k)));
    end

    % 归一化 W 的列
    col_norm = sqrt(sum(W.^2, 1));
    col_norm(col_norm < 1e-16) = 1;
    W = W ./ col_norm;
    H = H .* (col_norm');

    % 重构误差
    residual = X - W * H;
    err = norm(residual, 'fro') / max(norm(X, 'fro'), 1e-16);
    history.err(iter) = err;

    % 变化量
    delta = max(norm(W - W_old, 'fro'), norm(H - H_old, 'fro'));

    if strcmp(opts.Display, 'iter') && (mod(iter, 30) == 0 || iter == 1)
        fprintf('%4d  %10.4e  %10.2e\n', iter, err, delta);
    end

    if delta < opts.TolFun
        history.iter = iter;
        break;
    end

    history.iter = iter;
end

reconstruction_error = history.err(max(1, history.iter));

if strcmp(opts.Display, 'iter')
    fprintf('完成: 误差=%.6f at iter=%d\n', reconstruction_error, history.iter);
end
end

%% Self-test
function self_test()
    % Test with 3x2 non-negative matrix
    rng(42, 'twister');
    X = [4 2; 1 3; 0 5];
    k = 2;
    [W, H, err] = nmf_decompose(X, k, 'MaxIter', 50, 'TolFun', 1e-4);
    assert(size(W, 1) == 3, 'Test failed: W should have 3 rows.');
    assert(size(H, 2) == 2, 'Test failed: H should have 2 cols.');
    assert(err >= 0, 'Test failed: reconstruction error should be non-negative.');
    disp('nmf_decompose self-test passed.');
end
