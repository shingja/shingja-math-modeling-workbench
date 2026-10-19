% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [dist, path] = dijkstra(adj, start_node, target_node)
% DIJKSTRA  Dijkstra shortest path algorithm for non-negative edge weights.
%
%   [DIST, PATH] = DIJKSTRA(ADJ, START, TARGET)
%   ADJ:    n×n adjacency matrix (sparse or full). ADJ(i,j) = edge weight i→j.
%           +Inf or 0 on diagonal means no self-loop. Use +Inf for no edge.
%   START:  source node index (scalar, 1..n).
%   TARGET: destination node index (scalar, 1..n) or [] for all nodes.
%           When [], DIST is 1×n vector of distances to all nodes and PATH
%           is a cell array of paths.
%
%   DIST:   shortest distance from START to TARGET (scalar) or to all nodes
%           (1×n vector when TARGET is []).
%   PATH:   node sequence [START ... TARGET] (row vector), or cell array
%           when TARGET is [].
%
%   Example:
%       adj = [0 4 2 inf; inf 0 1 5; inf inf 0 3; inf inf inf 0];
%       [d, p] = dijkstra(adj, 1, 4);  % d=5, p=[1 2 4]
%
%   References:
%       Dijkstra, E.W. (1959). Numerische Mathematik 1:269-271.
%       《各类常用数学模型》第05章 图与网络分析

n = size(adj, 1);
if start_node < 1 || start_node > n || round(start_node) ~= start_node
    error('dijkstra:InvalidStart', 'start_node must be integer in [1, %d].', n);
end
if nargin < 3, target_node = []; end

% Initialization
visited = false(1, n);
dist    = inf(1, n);
prev    = zeros(1, n);
dist(start_node) = 0;

for iter = 1:n
    % Pick unvisited node with smallest tentative distance
    unvisited = find(~visited);
    [~, idx]  = min(dist(unvisited));
    u = unvisited(idx);
    if isinf(dist(u))
        break;  % Remaining nodes unreachable
    end
    visited(u) = true;

    % Relax edges from u
    neighbors = find(adj(u, :) > 0 & adj(u, :) < inf);
    for v = neighbors
        alt = dist(u) + adj(u, v);
        if alt < dist(v)
            dist(v) = alt;
            prev(v) = u;
        end
    end
end

% Reconstruct path(s)
if isempty(target_node)
    % All-pairs: return cell array of paths
    path = cell(1, n);
    for k = 1:n
        if isfinite(dist(k))
            path{k} = reconstruct_path(prev, k);
        else
            path{k} = [];
        end
    end
    return;
end

if ~isfinite(dist(target_node))
    path = [];
else
    path = reconstruct_path(prev, target_node);
end
dist = dist(target_node);
end

function p = reconstruct_path(prev, target)
    p = target;
    while prev(p(1)) ~= 0
        p = [prev(p(1)), p]; %#ok<AGROW>
    end
end

%% Self-test
function self_test()
    % Test with 4-node graph: 1→2:4, 1→3:2, 2→3:1, 2→4:5, 3→4:3
    adj = [0 4 2 inf; inf 0 1 5; inf inf 0 3; inf inf inf 0];
    [d, p] = dijkstra(adj, 1, 4);
    assert(abs(d - 5) < 1e-6, 'Test failed: shortest path 1→4 should be 5.');
    assert(isequal(p, [1 2 4]), 'Test failed: path should be 1→2→4.');
    disp('dijkstra self-test passed.');
end
