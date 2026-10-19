% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [dist, next] = floyd_warshall(adj)
% Input validation
arguments
    data (:,:) double
end
% FLOYD_WARSHALL  All-pairs shortest paths (supports negative edges, no neg-cycles).
%
%   [DIST, NEXT] = FLOYD_WARSHALL(ADJ)
%   ADJ:  n×n adjacency matrix. ADJ(i,j) = edge weight i→j (+Inf = no edge).
%         Diagonal ADJ(i,i) should be 0.
%
%   DIST: n×n matrix of shortest distances. DIST(i,j) = shortest i→j.
%   NEXT: n×n matrix for path reconstruction. NEXT(i,j) = next node on
%         the path from i to j.
%
%   Path reconstruction:
%       path = i;
%       while path(end) ~= j
%           path(end+1) = next(path(end), j);
%       end
%
%   Example:
%       adj = [0 3 8 inf; inf 0 inf 1; inf 4 0 inf; 2 inf 5 0];
%       [dist, next] = floyd_warshall(adj);
%       % dist(1,4) = 4  (path: 1→2→4)
%
%   References:
%       Floyd, R.W. (1962). CACM 5(6):345.
%       Warshall, S. (1962). JACM 9(1):11-12.
%       《各类常用数学模型》第05章 图与网络分析

n = size(adj, 1);
if size(adj, 2) ~= n
    error('floyd_warshall:NonSquare', 'Adjacency matrix must be square.');
end

dist = adj;
% Next-hop matrix: next(i,j) = j initially (direct edge assumed)
next = repmat((1:n), n, 1);
next(isinf(adj)) = 0;

for k = 1:n
    for i = 1:n
        if isinf(dist(i, k)), continue; end
        for j = 1:n
            if isinf(dist(k, j)), continue; end
            if dist(i, k) + dist(k, j) < dist(i, j)
                dist(i, j) = dist(i, k) + dist(k, j);
                next(i, j) = next(i, k);
            end
        end
    end
end

% Detect negative cycles (diagonal < 0)
if any(diag(dist) < 0)
    warning('floyd_warshall:NegativeCycle', ...
        'Graph contains negative cycle(s). Distances may be invalid.');
end
end

%% Self-test
function self_test()
% Input validation
arguments
    data (:,:) double
end
    % Test with 3-node graph: 1→2:3, 1→3:8, 2→3:1, 3→1:2
    adj = [0 3 8; inf 0 1; 2 inf 0];
    [dist, next] = floyd_warshall(adj);
    assert(abs(dist(1,3) - 4) < 1e-6, 'Test failed: 1→3 should be 4 via 1→2→3.');
    assert(abs(dist(3,2) - 5) < 1e-6, 'Test failed: 3→2 should be 5 via 3→1→2.');
    disp('floyd_warshall self-test passed.');
end
