% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
%% plot_bar_horizontal — Horizontal bar chart for ranking visualization
% MATH-MODELING v3.0.0 S6 Phase 3
% Paradigm: evaluation/ranking — ordered comparison with emphasis
%
% Creates a horizontal bar chart suitable for ranking items.
% Items are displayed top-to-bottom in descending (or specified) order.
%
% Usage:
%   [fig, ax, exitflag] = plot_bar_horizontal(values, item_labels)
%   [fig, ax, exitflag] = plot_bar_horizontal(..., Name, Value)
%
% Inputs:
%   values      — (:,1) double, bar lengths
%   item_labels — (:,1) cell of char, labels for each bar

function [fig, ax, exitflag] = plot_bar_horizontal(values, item_labels, opts)
arguments
    values (:,1) double
    item_labels (:,1) cell
    opts.title_text (1,:) char = ''
    opts.xlabel_text (1,:) char = 'Value'
    opts.bar_color (1,:) char = '#0F4D92'
    opts.sort_order (1,:) char {mustBeMember(opts.sort_order, {'ascend','descend','none'})} = 'descend'
    opts.bar_height (1,1) double = 0.6
end

n = length(values);
if length(item_labels) ~= n
    fig = gobjects(0); ax = gobjects(0); exitflag = int8(-1);
    warning('plot_bar_horizontal: values and item_labels length mismatch');
    return;
end

% Sort if requested
[sort_vals, sort_idx] = sort(values, opts.sort_order);
if strcmp(opts.sort_order, 'none')
    sort_vals = values;
    sort_idx = 1:n;
end
sort_labels = item_labels(sort_idx);

% Create figure
fig = figure('Visible', 'off', 'Color', 'w');
ax = axes('Parent', fig);
hold(ax, 'on');

% Plot horizontal bars (top-to-bottom corresponds to high-to-low)
y_pos = n:-1:1;
h = barh(ax, sort_vals, opts.bar_height, ...
    'FaceColor', opts.bar_color, ...
    'EdgeColor', 'none');

% Apply publication style
apply_publication_style(ax);

% Set y-tick labels
ax.YTick = y_pos;
ax.YTickLabel = sort_labels;
ax.YLim = [0.2, n + 0.8];

% Labels
if ~isempty(opts.title_text); title(ax, opts.title_text); end
xlabel(ax, opts.xlabel_text);

% Add value labels at bar tips
for i = 1:n
    text(ax, sort_vals(i) + max(sort_vals)*0.02, y_pos(i), ...
        num2str(sort_vals(i), '%.2f'), ...
        'FontSize', 9, 'VerticalAlignment', 'middle');
end

hold(ax, 'off');
exitflag = int8(0);
end

%% Self-test
function self_test()
    values = [95.2; 88.7; 82.1; 76.5; 71.3; 65.8; 60.4; 55.9];
    labels = {'Method A'; 'Method B'; 'Method C'; 'Method D'; ...
              'Method E'; 'Method F'; 'Method G'; 'Method H'};

    [fig, ax, exitflag] = plot_bar_horizontal(values, labels, ...
        'title_text', 'Self-test: Ranking', 'xlabel_text', 'Score');

    assert(exitflag == 0, 'plot_bar_horizontal: exitflag not zero');
    assert(~isempty(fig), 'plot_bar_horizontal: fig empty');
    assert(~isempty(ax), 'plot_bar_horizontal: ax empty');
    close(fig);
    disp('plot_bar_horizontal: self-test PASSED');
end
