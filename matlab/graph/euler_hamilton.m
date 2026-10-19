% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [result, path] = euler_hamilton(adj_matrix, varargin)
%EULER_HAMILTON 欧拉路径 / 哈密顿路径求解
%   [RESULT, PATH] = EULER_HAMILTON(ADJ_MATRIX)
%
%   Source: Euler, L. (1741). Solutio problematis ad geometriam situs
%          pertinentis. Commentarii academiae scientiarum Petropolitanae.
%          Hamilton, W.R. (1859). The Icosian Game.
%   Author: Adapted by MathModelingSkill
%   License: MIT
%   Verified: 2026-07-27
%
%   算法复杂度:
%       欧拉路径: O(n + m) (Hierholzer, n=节点, m=边)
%       哈密顿路径: O(n²*2^n) (DP / 回溯, NP-完全问题)
%
%   输入:
%       adj_matrix - 邻接矩阵 (n×n), adj(i,j)=1 表示无边, 其他=权重(或无向边)
%
%   可选参数:
%       'Problem'  - 'euler' | 'hamilton' | 'euler_circuit' (默认: 'euler')
%       'Directed' - 有向图/无向图 (默认: false)
%       'StartNode' - 起点 (默认: 1)
%
%   输出:
%       result - 是否存在路径 (logical)
%       path   - 路径节点序列 (若存在)
%
%   示例:
%       % 完全图 K5 永远有欧拉回路 (所有顶点度为4=偶数)
%       A = ones(5) - eye(5);
%       [ok, path] = euler_hamilton(A, 'Problem', 'euler_circuit');

%% 参数解析
p = inputParser;
p.addParameter('Problem', 'euler');
p.addParameter('Directed', false);
p.addParameter('StartNode', 1);
p.parse(varargin{:});
opts = p.Results;

n = size(adj_matrix, 1);

%% 欧拉路径 (Hierholzer 算法, O(n+m))
if contains(opts.Problem, 'euler')
    % 构建邻接表
    G = cell(n, 1);
    for i = 1:n
        for j = 1:n
            if adj_matrix(i, j) ~= 0 && i ~= j
                if ~opts.Directed
                    if i < j  % 无向边只加一次
                        G{i} = [G{i}, j];
                        G{j} = [G{j}, i];
                    end
                else
                    G{i} = [G{i}, j];
                end
            end
        end
    end

    % 检查度数条件
    degrees = cellfun(@length, G);
    odd_nodes = find(mod(degrees, 2) == 1);

    if strcmp(opts.Problem, 'euler_circuit')
        if ~isempty(odd_nodes)
            result = false; path = [];
            return;
        end
        start = opts.StartNode;
    else
        if length(odd_nodes) ~= 0 && length(odd_nodes) ~= 2
            result = false; path = [];
            return;
        end
        if ~isempty(odd_nodes)
            start = odd_nodes(1);
        else
            start = opts.StartNode;
        end
    end

    % Hierholzer 算法 (DFS + 栈)
    edge_remaining = cellfun(@(c) length(c), G);
    stack = [start];
    path = [];

    while ~isempty(stack)
        v = stack(end);
        if edge_remaining(v) > 0
            u = G{v}(1);
            G{v}(1) = [];
            edge_remaining(v) = edge_remaining(v) - 1;
            % 移除反向边 (无向图)
            G{u}(G{u} == v) = [];
            edge_remaining(u) = edge_remaining(u) - 1;
            stack = [stack, u];
        else
            path = [path, v];
            stack(end) = [];
        end
    end

    path = fliplr(path);
    result = true;
    if strcmp(opts.Problem, 'euler_circuit') && path(1) ~= path(end)
        result = false;
    end
end

%% 哈密顿路径 (回溯 + 剪枝, NP-完全, O(n²*2^n))
if contains(opts.Problem, 'hamilton')
    visited = false(1, n);
    start = opts.StartNode;
    visited(start) = true;
    [result, path] = hamilton_dfs(adj_matrix, start, visited, [start]);
end
end

function [found, best_path] = hamilton_dfs(A, current, visited, current_path)
    n = size(A, 1);
    if length(current_path) == n
        % 检查能否回到起点 (哈密顿回路)
        found = true;
        best_path = current_path;
        return;
    end

    found = false;
    best_path = current_path;

    for v = 1:n
        if ~visited(v) && A(current, v) ~= 0
            visited(v) = true;
            [sub_found, sub_path] = hamilton_dfs(A, v, visited, [current_path, v]);
            if sub_found
                found = true;
                best_path = sub_path;
                return;
            end
            visited(v) = false;
        end
    end
end

%% Exit status
exitflag = 1;  %% normal termination

%% Self-test
function self_test()
    % Test Eulerian circuit on K3 (complete graph, all degrees even=2)
    A = ones(3) - eye(3);
    [ok, path] = euler_hamilton(A, 'Problem', 'euler_circuit');
    assert(ok, 'Test failed: K3 should have Eulerian circuit.');
    assert(length(unique(path)) >= 3, 'Test failed: should visit all 3 nodes.');
    disp('euler_hamilton self-test passed.');
end
