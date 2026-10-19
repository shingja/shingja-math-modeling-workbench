% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [dist, path, pred] = bellman_ford(adj_matrix, source)
% Input validation
arguments
    data (:,:) double
end
%BELLMAN_FORD  Bellman-Ford 最短路径算法 (支持负权边)
%   [DIST, PATH, PRED] = BELLMAN_FORD(ADJ_MATRIX, SOURCE)
%
%   Source: Bellman, R. (1958). On a routing problem.
%          Quarterly of Applied Mathematics, 16(1), 87-90.
%          Ford, L.R. (1956). Network Flow Theory. RAND Corporation.
%   Author: Adapted by MathModelingSkill
%   License: MIT
%   Verified: 2026-07-27
%
%   输入:
%       adj_matrix - 邻接矩阵 (n×n)
%                    adj_matrix(i,j) = 边权重 (Inf 表示无边)
%                    adj_matrix(i,i) = 0
%       source     - 源点编号 (1-based)
%
%   输出:
%       dist   - 源点到各点的最短距离 (1×n), Inf 表示不可达
%       path   - 最短路径 cell 数组, path{i} = 从 source 到 i 的节点序列
%       pred   - 前驱节点数组 (1×n), 0 表示无前驱
%
%   示例:
%       A = [0 4 Inf Inf Inf;
%            Inf 0 -2 Inf Inf;
%            Inf Inf 0 3 Inf;
%            Inf Inf Inf 0 1;
%            Inf Inf Inf Inf 0];
%       [dist, path] = bellman_ford(A, 1);

%% 依赖检查
% 仅使用 MATLAB 内置函数

n = size(adj_matrix, 1);

%% 初始化
dist = inf(1, n);
dist(source) = 0;
pred = zeros(1, n);

%% 主循环: 松弛所有边 |V|-1 次
for iter = 1:(n - 1)
    updated = false;
    for u = 1:n
        if dist(u) == inf
            continue;
        end
        for v = 1:n
            w = adj_matrix(u, v);
            if w == inf || u == v
                continue;
            end
            % 松弛操作
            if dist(u) + w < dist(v)
                dist(v) = dist(u) + w;
                pred(v) = u;
                updated = true;
            end
        end
    end
    if ~updated
        break;  % 早期停止: 无更新则已收敛
    end
end

%% 负权回路检测
has_negative_cycle = false;
for u = 1:n
    if dist(u) == inf, continue; end
    for v = 1:n
        w = adj_matrix(u, v);
        if w == inf || u == v, continue; end
        if dist(u) + w < dist(v)
            has_negative_cycle = true;
            break;
        end
    end
    if has_negative_cycle, break; end
end

if has_negative_cycle
    warning('Bellman-Ford: 检测到负权回路! 最短路径无定义。');
end

%% 路径回溯
path = cell(1, n);
for v = 1:n
    if dist(v) == inf || v == source
        if v == source
            path{v} = source;
        else
            path{v} = [];
        end
        continue;
    end
    % 回溯前驱链
    p = v;
    path_v = [];
    visited = false(1, n);
    while p ~= 0
        if visited(p)
            % 回路检测 (负权回路路径)
            path_v = [];
            break;
        end
        visited(p) = true;
        path_v = [p, path_v]; %#ok<AGROW>
        p = pred(p);
    end
    path{v} = path_v;
end

%% 输出摘要
reachable = sum(isfinite(dist));
fprintf('Bellman-Ford: 源点=%d, 可达 %d/%d 个节点', source, reachable, n);
if has_negative_cycle
    fprintf('  [警告: 负权回路]');
end
fprintf('\n');
end

%% Self-test
function self_test()
% Input validation
arguments
    data (:,:) double
end
    % Test same graph as Dijkstra: 4-node graph
    adj = [0 4 2 inf; inf 0 1 5; inf inf 0 3; inf inf inf 0];
    [dist, path] = bellman_ford(adj, 1);
    assert(abs(dist(4) - 5) < 1e-6, 'Test failed: distance 1→4 should be 5.');
    assert(dist(1) == 0, 'Test failed: distance to self should be 0.');
    disp('bellman_ford self-test passed.');
end
