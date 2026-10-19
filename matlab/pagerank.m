% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [PR, n_iter] = pagerank(A, d, tol, max_iter)
% PAGERANK 基于图结构的节点重要性排序
%
%   算法来源：Brin & Page (1998), "The Anatomy of a Large-Scale
%             Hypertextual Web Search Engine", WWW7
%   算法复杂度：O(k * |E|)，k=迭代次数，|E|=边数
%
%   输入参数:
%       A        - 邻接矩阵 [n, n]，A(i,j)=1 表示节点 j 指向节点 i
%                  或出边矩阵 [n, n]，A(i,j)=出链权重
%       d        - 阻尼因子 (默认 0.85)
%       tol      - 收敛容差 (默认 1e-6)
%       max_iter - 最大迭代次数 (默认 100)
%
%   输出参数:
%       PR     - PageRank 向量 [n, 1]，已归一化（和为1）
%       n_iter - 实际迭代次数
%
%   示例:
%       % 4节点有向图: 1→2, 2→3, 3→1, 3→4, 4→1
%       A = [0 0 1 1; 1 0 0 0; 0 1 0 0; 0 0 1 0];
%       [PR, iter] = pagerank(A, 0.85);
%
%   参考文献:
%       Page, L., Brin, S., Motwani, R. & Winograd, T. (1999).
%       The PageRank Citation Ranking: Bringing Order to the Web.

%% 参数默认值
if nargin < 2 || isempty(d), d = 0.85; end
if nargin < 3 || isempty(tol), tol = 1e-6; end
if nargin < 4 || isempty(max_iter), max_iter = 100; end

%% 初始化
n = size(A, 1);
assert(n == size(A, 2), '邻接矩阵必须是方阵');

% 构造转移矩阵 M
% M(i,j) = 从节点 j 转移到节点 i 的概率
out_degree = sum(A, 2);  % 每个节点的出度

% 处理悬垂节点（出度为 0），假设等概率跳转到所有节点
dangling = (out_degree == 0);
M = zeros(n, n);

for j = 1:n
    if out_degree(j) > 0
        % 节点 j 的出边，等概率分配给目标节点
        targets = find(A(j,:));
        M(targets, j) = 1 / out_degree(j);
    end
end

% Google 矩阵: G = d * M + (1-d)/n * ones(n)
% PR = G * PR  →  PR = d * M * PR + (1-d)/n * e
% 加上悬垂节点修正

% 初始化 PR（均匀分布）
PR = ones(n, 1) / n;
e = ones(n, 1);

%% 幂迭代
for n_iter = 1:max_iter
    PR_old = PR;

    % PR_new = d * M * PR_old + (1-d)/n * e
    % 悬垂节点贡献额外均匀项
    dangling_factor = d * sum(PR_old(dangling)) / n;
    PR = d * (M * PR_old) + (1 - d + dangling_factor) / n * e;

    % 收敛检查
    delta = norm(PR - PR_old, 1);
    if delta < tol
        break;
    end
end

% 归一化
PR = PR / sum(PR);

end


function [PR] = personalized_pagerank(A, S, d, tol, max_iter)
% PERSONALIZED_PAGERANK 个性化 PageRank
%
%   输入:
%       S - 偏好向量 [n, 1]（和为1），表示随机跳转时各节点的偏好概率
%           若 S 未归一化会自动归一化
%
%   示例:
%       A = rand(10) > 0.7;  % 随机有向图
%       S = [1; zeros(9,1)];  % 偏好节点1
%       PR = personalized_pagerank(A, S);

%% 参数默认值
if nargin < 3 || isempty(d), d = 0.85; end
if nargin < 4 || isempty(tol), tol = 1e-6; end
if nargin < 5 || isempty(max_iter), max_iter = 100; end

%% 初始化
n = size(A, 1);
S = S / sum(S);  % 归一化偏好向量

out_degree = sum(A, 2);
dangling = (out_degree == 0);

M = zeros(n, n);
for j = 1:n
    if out_degree(j) > 0
        targets = find(A(j,:));
        M(targets, j) = 1 / out_degree(j);
    end
end

PR = ones(n, 1) / n;
e = ones(n, 1);

%% 幂迭代
for n_iter = 1:max_iter
    PR_old = PR;
    dangling_factor = d * sum(PR_old(dangling));
    PR = d * (M * PR_old) + (1 - d) * S + dangling_factor * S;
    % 注：个性化版本中，随机跳转项 (1-d)*S 替代了均匀项 (1-d)/n*e

    if norm(PR - PR_old, 1) < tol
        break;
    end
end

PR = PR / sum(PR);

end


function [scores] = textrank(similarity_matrix, d, tol, max_iter)
% TEXTRANK 基于图的文本关键词/句子排序（PageRank 变体）
%
%   TextRank 是 PageRank 的无监督变体，用于关键词提取和文本摘要。
%
%   输入:
%       similarity_matrix - 相似度矩阵 [n, n]（对称，对角线为0）
%       d                 - 阻尼因子 (默认 0.85)
%
%   示例:
%       % 4句子的余弦相似度矩阵
%       S = [0 0.5 0.2 0; 0.5 0 0.6 0.3; 0.2 0.6 0 0.1; 0 0.3 0.1 0];
%       scores = textrank(S);

if nargin < 2 || isempty(d), d = 0.85; end
if nargin < 3 || isempty(tol), tol = 1e-6; end
if nargin < 4 || isempty(max_iter), max_iter = 100; end

n = size(similarity_matrix, 1);

% 构造加权转移矩阵（行归一化）
M = similarity_matrix;
for i = 1:n
    row_sum = sum(M(i,:));
    if row_sum > 0
        M(i,:) = M(i,:) / row_sum;
    end
end
M = M';  % PageRank 使用列随机矩阵

scores = ones(n, 1) / n;
e = ones(n, 1);

for iter = 1:max_iter
    scores_old = scores;
    scores = d * M * scores_old + (1 - d) / n * e;

    if norm(scores - scores_old, 1) < tol
        break;
    end
end

scores = scores / sum(scores);

end

%% Self-test
function self_test()
    % Test with 3-node graph, known PR values
    % Graph: 1->2, 2->1, 2->3, 3->1
    A = [0 1 1; 1 0 0; 0 1 0];  % A(i,j)=1 means edge j->i
    [PR, n_iter] = pagerank(A, 0.85, 1e-8, 200);
    assert(length(PR) == 3, 'Test failed: PR should have 3 entries.');
    assert(abs(sum(PR) - 1.0) < 1e-6, 'Test failed: PR should sum to 1.');
    assert(all(PR > 0), 'Test failed: all PR values should be positive.');
    % Node 1 has 2 incoming edges, should have highest PR
    assert(PR(1) > PR(3), 'Test failed: node 1 should have higher PR than node 3.');
    disp('pagerank self-test passed.');
end
n%% Reproducibility
rng(42, 'twister');
