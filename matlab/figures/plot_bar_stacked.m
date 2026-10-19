% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
%% plot_bar_stacked — Stacked bar chart for compositional data
% MATH-MODELING v3.0.0 S6 Phase 3
% Paradigm: evaluation/composition — proportional or additive decomposition
%
% Creates a stacked bar chart where each bar shows component composition.
% Uses colorblind-safe categorical palette.
%
% Usage:
%   [fig, ax, exitflag] = plot_bar_stacked(data, category_labels, component_labels)
%   [fig, ax, exitflag] = plot_bar_stacked(..., Name, Value)
%
% Inputs:
%   data              — (n_categories x n_components) double
%   category_labels   — (1 x n_categories) cell of char
%   component_labels  — (1 x n_components) cell of char

function [fig, ax, exitflag] = plot_bar_stacked(data, category_labels, component_labels, opts)
arguments
    data (:,:) double
    category_labels (1,:) cell
    component_labels (1,:) cell
    opts.title_text (1,:) char = ''
    opts.ylabel_text (1,:) char = 'Proportion'
    opts.bar_width (1,1) double = 0.6
end

[n_categories, n_components] = size(data);
if length(category_labels) ~= n_categories || length(component_labels) ~= n_components
    fig = gobjects(0); ax = gobjects(0); exitflag = int8(-1);
    warning('plot_bar_stacked: label count mismatch');
    return;
end

p = cb_palette();
colors = p.categorical(1:n_components);

fig = figure('Visible', 'off', 'Color', 'w');
ax = axes('Parent', fig);
hold(ax, 'on');

% Plot each component as a stacked layer
bottom_vals = zeros(n_categories, 1);
h = gobjects(1, n_components);
for k = 1:n_components
    h(k) = bar(ax, 1:n_categories, data(:, k), opts.bar_width, ...
        'FaceColor', colors{k}, ...
        'EdgeColor', 'w', ...
        'LineWidth', 0.5, ...
        'DisplayName', component_labels{k}, ...
        'BaseValue', 0);
    % Shift to stack on top (bar auto-stacks if called sequentially with 'stacked')
    % Actually, need to use the bottom offset ourselves
end

% Overwrite: use MATLAB's built-in stacked bar for correctness
delete(h);
cla(ax);
b = bar(ax, data, opts.bar_width, 'stacked');
for k = 1:n_components
    b(k).FaceColor = colors{k};
    b(k).EdgeColor = 'w';
    b(k).LineWidth = 0.5;
    b(k).DisplayName = component_labels{k};
end

apply_publication_style(ax);
ax.XTick = 1:n_categories;
ax.XTickLabel = category_labels;

if ~isempty(opts.title_text); title(ax, opts.title_text); end
ylabel(ax, opts.ylabel_text);

leg = legend(ax, component_labels, 'Location', 'best');
set(leg, 'Box', 'off');

hold(ax, 'off');
exitflag = int8(0);
end

%% Self-test
function self_test()
    data = [30 20 15; 25 18 12; 28 22 18; 20 25 10];
    categories = {'Q1', 'Q2', 'Q3', 'Q4'};
    components = {'Product A', 'Product B', 'Product C'};

    [fig, ax, exitflag] = plot_bar_stacked(data, categories, components, ...
        'title_text', 'Self-test: Stacked Bar');

    assert(exitflag == 0, 'plot_bar_stacked: exitflag not zero');
    assert(~isempty(fig), 'plot_bar_stacked: fig empty');
    assert(~isempty(ax), 'plot_bar_stacked: ax empty');
    close(fig);
    disp('plot_bar_stacked: self-test PASSED');
end
