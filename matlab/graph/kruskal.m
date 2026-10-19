% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [mst_edges, total_weight] = kruskal(adj)
% Input validation
arguments
    data (:,:) double
end
% KRUSKAL  Minimum spanning tree by Kruskal's algorithm (Union-Find).
%
%   [MST_EDGES, TOTAL_WEIGHT] = KRUSKAL(ADJ)
%   ADJ:  n×n symmetric adjacency matrix (undirected graph).
%         +Inf or 0 on diagonal. Upper triangle used for edge list.
%
%   MST_EDGES:    m×2 matrix, each row = [from_node, to_node] in MST.
%   TOTAL_WEIGHT: sum of edge weights in MST.
%
%   Example:
%       adj = [0 2 0 6; 2 0 3 8; 0 3 0 0; 6 8 0 0];
%       [edges, w] = kruskal(adj);  % edges=[1 2; 2 3; 1 4], w=11
%
%   References:
%       Kruskal, J.B. (1956). Proc. AMS 7(1):48-50.
%       《各类常用数学模型》第05章 图与网络分析

n = size(adj, 1);

% Build edge list from upper triangle
[rows, cols] = find(triu(adj, 1));
edges = [rows, cols];
weights = arrayfun(@(r, c) adj(r, c), rows, cols);

% Sort edges by weight ascending
[weights, order] = sort(weights);
edges = edges(order, :);

% Union-Find parent array
parent = 1:n;

mst_edges    = zeros(n-1, 2);
mst_count    = 0;
total_weight = 0;

for k = 1:length(weights)
    u = edges(k, 1);
    v = edges(k, 2);
    if find_root(parent, u) ~= find_root(parent, v)
        mst_count = mst_count + 1;
        mst_edges(mst_count, :) = [u, v];
        total_weight = total_weight + weights(k);
        parent = union_sets(parent, u, v);
        if mst_count == n - 1
            break;
        end
    end
end

if mst_count < n - 1
    warning('kruskal:Disconnected', 'Graph is disconnected. MST incomplete.');
    mst_edges = mst_edges(1:mst_count, :);
end
end

function r = find_root(parent, x)
% Input validation
arguments
    data (:,:) double
end
    while parent(x) ~= x
        parent(x) = parent(parent(x));  % path compression
        x = parent(x);
    end
    r = x;
end

function parent = union_sets(parent, a, b)
% Input validation
arguments
    data (:,:) double
end
    ra = find_root(parent, a);
    rb = find_root(parent, b);
    parent(rb) = ra;  % simple union (no rank heuristic — sufficient for MST)
end

%% Self-test
function self_test()
% Input validation
arguments
    data (:,:) double
end
    % Test with 4-node 5-edge graph
    adj = [0 2 0 6; 2 0 3 8; 0 3 0 0; 6 8 0 0];
    [edges, w] = kruskal(adj);
    assert(abs(w - 11) < 1e-6, 'Test failed: MST weight should be 11 (2+3+6).');
    assert(size(edges, 1) == 3, 'Test failed: MST should have 3 edges for 4 nodes.');
    disp('kruskal self-test passed.');
end
