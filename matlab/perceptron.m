% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [w, b, n_iter] = perceptron(X, y, eta, max_iter)
% PERCEPTRON 感知机二类分类算法（原始形式）
%
%   算法来源：李航《统计学习方法》第2章
%   算法复杂度：O(n * d * k)，n=样本数，d=特征维数，k=实际迭代次数
%
%   输入参数:
%       X        - 训练数据矩阵，大小为 [n_samples, n_features]
%       y        - 标签向量，大小为 [n_samples, 1]，取值 +1 或 -1
%       eta      - 学习率 (默认 1.0)
%       max_iter - 最大迭代次数 (默认 1000)
%
%   输出参数:
%       w      - 权重向量 [n_features, 1]
%       b      - 偏置标量
%       n_iter - 实际迭代次数
%
%   示例:
%       X = [3 3; 4 3; 1 1];
%       y = [1; 1; -1];
%       [w, b, iter] = perceptron(X, y, 1.0, 1000);
%       pred = sign(X * w + b);
%
%   参考文献:
%       Rosenblatt, F. (1958). The Perceptron: A Probabilistic Model
%       for Information Storage and Organization in the Brain.
%       李航.《统计学习方法》第2章. 清华大学出版社, 2012.

%% 参数默认值设置
if nargin < 3 || isempty(eta)
    eta = 1.0;
end
if nargin < 4 || isempty(max_iter)
    max_iter = 1000;
end

%% 初始化
[n_samples, n_features] = size(X);
w = zeros(n_features, 1);   % 权重向量初始化为零
b = 0;                       % 偏置初始化为零
n_iter = 0;                  % 迭代计数器

%% 随机梯度下降（原始形式）
while n_iter < max_iter
    n_misclass = 0;           % 本轮误分类点数

    for i = 1:n_samples
        % 判断样本是否误分类: y_i * (w·x_i + b) <= 0
        margin = y(i) * (X(i,:) * w + b);

        if margin <= 0
            % 梯度下降更新: w <- w + eta * y_i * x_i
            w = w + eta * y(i) * X(i,:)';
            b = b + eta * y(i);
            n_misclass = n_misclass + 1;
        end
    end

    n_iter = n_iter + 1;

    % 没有误分类点，算法收敛
    if n_misclass == 0
        break;
    end
end

end


function [w, b, n_iter] = perceptron_dual(X, y, eta, max_iter)
% PERCEPTRON_DUAL 感知机对偶形式
%
%   对偶形式中，w 和 b 表示为训练样本的线性组合：
%       w = sum(alpha_i * y_i * x_i)
%       b = sum(alpha_i * y_i)
%   其中 alpha_i = n_i * eta，n_i 为样本 i 被误分类次数。
%
%   输入/输出参数同 perceptron()，额外输出:
%       alpha - 对偶系数向量 [n_samples, 1]

%% 参数默认值
if nargin < 3 || isempty(eta), eta = 1.0; end
if nargin < 4 || isempty(max_iter), max_iter = 1000; end

%% 初始化
[n_samples, n_features] = size(X);
alpha = zeros(n_samples, 1);  % 对偶系数
b = 0;
n_iter = 0;

%% 预计算 Gram 矩阵 G(i,j) = x_i · x_j
G = X * X';

%% 对偶形式迭代
while n_iter < max_iter
    n_misclass = 0;

    for i = 1:n_samples
        % 计算判别值: y_i * (sum(alpha_j * y_j * x_j·x_i) + b)
        margin = y(i) * (sum(alpha .* y .* G(:,i)) + b);

        if margin <= 0
            alpha(i) = alpha(i) + eta;     % n_i += 1
            b = b + eta * y(i);
            n_misclass = n_misclass + 1;
        end
    end

    n_iter = n_iter + 1;
    if n_misclass == 0, break; end
end

% 恢复原始参数: w = sum(alpha_i * y_i * x_i)
w = X' * (alpha .* y);

end

%% Exit status
exitflag = 1;  %% normal termination

%% Self-test
function self_test()
    % Test perceptron on AND logic gate (linearly separable)
    rng(42, 'twister');
    X = [0 0; 0 1; 1 0; 1 1];
    y = [-1; -1; -1; 1];  % AND gate: only (1,1) is positive
    [w, b, iter] = perceptron(X, y, 1.0, 1000);
    pred = sign(X * w + b);
    assert(all(pred == y), 'Test failed: perceptron should perfectly classify AND gate.');
    assert(iter > 0, 'Test failed: should require at least 1 iteration.');
    disp('perceptron self-test passed.');
end
