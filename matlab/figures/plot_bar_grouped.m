% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
%% plot_bar_grouped — Grouped bar chart for multi-method comparison
% MATH-MODELING v3.0.0 S6 Phase 3
% Paradigm: evaluation/comparison — categorical method benchmarking
%
% Creates a grouped bar chart comparing multiple methods across metrics.
% Uses colorblind-safe palette for method differentiation.
%
% Usage:
%   [fig, ax, exitflag] = plot_bar_grouped(data, method_labels, metric_labels)
%   [fig, ax, exitflag] = plot_bar_grouped(..., Name, Value)
%
% Inputs:
%   data          — (n_metrics x n_methods) double, each row=metric, col=method
%   method_labels — (1 x n_methods) cell of char
%   metric_labels — (1 x n_metrics) cell of char
%   Name-Value pairs: title_text, ylabel_text, bar_width

function [fig, ax, exitflag] = plot_bar_grouped(data, method_labels, metric_labels, opts)
arguments
    data (:,:) double
    method_labels (1,:) cell
    metric_labels (1,:) cell
    opts.title_text (1,:) char = ''
    opts.ylabel_text (1,:) char = 'Value'
    opts.bar_width (1,1) double = 0.7
end

[n_metrics, n_methods] = size(data);
if length(method_labels) ~= n_methods || length(metric_labels) ~= n_metrics
    fig = gobjects(0); ax = gobjects(0); exitflag = int8(-1);
    warning('plot_bar_grouped: label count mismatch with data dimensions');
    return;
end

% Get color palette
p = cb_palette();
colors = p.categorical(1:n_methods);

% Create figure
fig = figure('Visible', 'off', 'Color', 'w');
ax = axes('Parent', fig);
hold(ax, 'on');

% Compute group positions
group_centers = 1:n_metrics;
bar_width_total = opts.bar_width;
bar_width_each = bar_width_total / n_methods;

% Plot each method's bars
h = gobjects(1, n_methods);
for j = 1:n_methods
    x_pos = group_centers - bar_width_total/2 + (j - 0.5) * bar_width_each;
    h(j) = bar(ax, x_pos, data(:, j), bar_width_each, ...
        'FaceColor', colors{j}, ...
        'EdgeColor', 'none', ...
        'DisplayName', method_labels{j});
end

% Apply publication style
apply_publication_style(ax);

% Set x-axis tick labels
ax.XTick = group_centers;
ax.XTickLabel = metric_labels;
ax.XLim = [0.3, n_metrics + 0.7];

% Labels
if ~isempty(opts.title_text); title(ax, opts.title_text); end
ylabel(ax, opts.ylabel_text);

% Legend
leg = legend(ax, method_labels, 'Location', 'best');
set(leg, 'Box', 'off');

hold(ax, 'off');
exitflag = int8(0);
end

%% Self-test
function self_test()
    data = [0.85 0.72 0.68; 0.91 0.78 0.65; 0.88 0.81 0.73; 0.79 0.69 0.71];
    methods = {'Method A', 'Method B', 'Method C'};
    metrics = {'Accuracy', 'Precision', 'Recall', 'F1'};

    [fig, ax, exitflag] = plot_bar_grouped(data, methods, metrics, ...
        'title_text', 'Self-test: Grouped Bar', 'ylabel_text', 'Score');

    assert(exitflag == 0, 'plot_bar_grouped: exitflag not zero');
    assert(~isempty(fig), 'plot_bar_grouped: fig empty');
    assert(~isempty(ax), 'plot_bar_grouped: ax empty');
    close(fig);
    disp('plot_bar_grouped: self-test PASSED');
end
