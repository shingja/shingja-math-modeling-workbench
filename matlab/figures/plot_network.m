% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
%% plot_network — Network/graph visualization
% MATH-MODELING v3.0.0 S6 Phase 3
% Paradigm: graph theory/visualization — relational structure display
%
% Visualizes a weighted or unweighted graph using MATLAB's graph object.
% Node size proportional to degree, edge thickness proportional to weight.
%
% Usage:
%   [fig, ax, exitflag] = plot_network(G)
%   [fig, ax, exitflag] = plot_network(..., Name, Value)
%
% Inputs:
%   G — graph or digraph object, or adjacency matrix

function [fig, ax, exitflag] = plot_network(G, opts)
arguments
    G
    opts.title_text (1,:) char = ''
    opts.node_labels (:,1) cell = {}
    opts.node_color (1,:) char = '#0F4D92'
    opts.node_size_base (1,1) double = 4
    opts.edge_color (1,:) char = '#767676'
    opts.edge_alpha (1,1) double = 0.4
    opts.layout_method (1,:) char {mustBeMember(opts.layout_method, ...
        {'force','circle','subspace','layered','auto'})} = 'force'
    opts.show_weights (1,1) logical = false
end

% Convert adjacency matrix to graph if needed
if isnumeric(G)
    G = graph(G);
elseif ~isa(G, 'graph') && ~isa(G, 'digraph')
    fig = gobjects(0); ax = gobjects(0); exitflag = int8(-1);
    warning('plot_network: G must be graph, digraph, or adjacency matrix');
    return;
end

fig = figure('Visible', 'off', 'Color', 'w');
ax = axes('Parent', fig);

% Node sizes based on degree
degrees = degree(G);
if all(degrees == 0)
    node_sizes = opts.node_size_base * ones(numnodes(G), 1);
else
    node_sizes = opts.node_size_base + 20 * (degrees / max(degrees));
end

% Edge weights
if numedges(G) > 0 && ~isempty(G.Edges)
    if any(strcmp(G.Edges.Properties.VariableNames, 'Weight'))
        edge_weights = G.Edges.Weight;
    else
        edge_weights = ones(numedges(G), 1);
    end
else
    edge_weights = [];
end

% Plot the graph
h = plot(ax, G, 'Layout', opts.layout_method, ...
    'NodeColor', hex2rgb_net(opts.node_color), ...
    'MarkerSize', node_sizes, ...
    'EdgeColor', [hex2rgb_net(opts.edge_color), opts.edge_alpha], ...
    'LineWidth', 1 + 2 * edge_weights / max(edge_weights), ...
    'EdgeAlpha', opts.edge_alpha);

% Node labels
if ~isempty(opts.node_labels)
    if length(opts.node_labels) == numnodes(G)
        labelnode(h, 1:numnodes(G), opts.node_labels);
    end
end

% Edge weight labels
if opts.show_weights && ~isempty(edge_weights)
    labeledge(h, 1:numedges(G), edge_weights);
end

apply_publication_style(ax);
if ~isempty(opts.title_text); title(ax, opts.title_text); end

% Remove axis ticks for cleaner network display
ax.XTick = [];
ax.YTick = [];
ax.Box = 'off';

exitflag = int8(0);
end

function rgb = hex2rgb_net(hex)
    hex = char(hex);
    if hex(1) == '#', hex = hex(2:end); end
    rgb = [hex2dec(hex(1:2)), hex2dec(hex(3:4)), hex2dec(hex(5:6))] / 255;
end

%% Self-test
function self_test()
    rng(42);
    % 6-node weighted graph
    s = [1 1 2 2 3 3 4 4 5];
    t = [2 3 3 4 4 5 5 6 6];
    w = [3 2 5 1 4 2 3 6 2];
    G = graph(s, t, w);
    node_names = {'A', 'B', 'C', 'D', 'E', 'F'};

    [fig, ax, exitflag] = plot_network(G, ...
        'title_text', 'Self-test: Network Graph', ...
        'node_labels', node_names);

    assert(exitflag == 0, 'plot_network: exitflag not zero');
    assert(~isempty(fig), 'plot_network: fig empty');
    assert(~isempty(ax), 'plot_network: ax empty');
    close(fig);
    disp('plot_network: self-test PASSED');
end
