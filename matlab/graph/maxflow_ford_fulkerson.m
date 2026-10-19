% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [max_flow, flow_matrix] = maxflow_ford_fulkerson(capacity, source, sink)
%% Input validation
arguments
    capacity (:,:) double
    source (1,1) double {mustBePositive, mustBeInteger}
    sink (1,1) double {mustBePositive, mustBeInteger}
end
% MAXFLOW_FORD_FULKERSON  Max flow by Ford-Fulkerson (DFS augmenting paths).
%
%   [MAX_FLOW, FLOW_MATRIX] = MAXFLOW_FORD_FULKERSON(CAPACITY, S, T)
%   CAPACITY: n×n capacity matrix. CAPACITY(i,j) ≥ 0. 0 = no edge.
%   S:        source node index (1..n).
%   T:        sink node index (1..n).
%
%   MAX_FLOW:    total flow value (scalar).
%   FLOW_MATRIX: n×n matrix of flow on each edge.
%
%   Example:
%       cap = [0 16 13 0 0 0; 0 0 10 12 0 0; 0 4 0 0 14 0;
%              0 0 9 0 0 20; 0 0 0 7 0 4; 0 0 0 0 0 0];
%       [mf, flow] = maxflow_ford_fulkerson(cap, 1, 6);  % mf = 23
%
%   Note: For dense/large graphs, consider edmonds_karp (BFS variant) for
%         O(VE^2) worst-case vs this O(E·maxflow).
%
%   References:
%       Ford, L.R. & Fulkerson, D.R. (1956). Canadian J. Math. 8:399-404.
%       《各类常用数学模型》第05章 图与网络分析

n = size(capacity, 1);

% Edge list from non-zero capacities
[row, col] = find(capacity > 0);
num_edges = length(row);

% Initialize flow
flow_matrix = zeros(n);

max_flow = 0;

while true
    % Find augmenting path via DFS
    visited = false(1, n);
    parent  = zeros(1, n);
    stack   = source;
    visited(source) = true;
    found   = false;

    while ~isempty(stack) && ~found
        u = stack(end);
        stack(end) = [];
        for v = 1:n
            if ~visited(v)
                residual = capacity(u, v) - flow_matrix(u, v) ...
                         + flow_matrix(v, u);  % allow reverse flow
                if capacity(u, v) > flow_matrix(u, v) && ~visited(v)
                    visited(v) = true;
                    parent(v) = u;
                    stack(end+1) = v; %#ok<AGROW>
                    if v == sink
                        found = true;
                        break;
                    end
                end
            end
        end
    end

    if ~found, break; end

    % Find bottleneck capacity along path
    v = sink;
    path_flow = inf;
    while v ~= source
        u = parent(v);
        path_flow = min(path_flow, capacity(u, v) - flow_matrix(u, v));
        v = u;
    end

    % Augment flow
    v = sink;
    while v ~= source
        u = parent(v);
        flow_matrix(u, v) = flow_matrix(u, v) + path_flow;
        flow_matrix(v, u) = flow_matrix(v, u) - path_flow;  % residual back-edge
        v = u;
    end

    max_flow = max_flow + path_flow;
end
end

%% Exit status
exitflag = 1;  %% normal termination

%% Self-test
function self_test()
%% Input validation
arguments
    capacity (:,:) double
    source (1,1) double {mustBePositive, mustBeInteger}
    sink (1,1) double {mustBePositive, mustBeInteger}
end
    % Test with simple 4-node flow network
    cap = [0 10 10 0; 0 0 5 10; 0 0 0 10; 0 0 0 0];
    [mf, flow] = maxflow_ford_fulkerson(cap, 1, 4);
    assert(mf == 20, 'Test failed: max flow should be 20.');
    disp('maxflow_ford_fulkerson self-test passed.');
end
