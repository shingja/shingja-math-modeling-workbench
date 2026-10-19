% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
%% plot_bubble — Bubble/scatter chart with 3rd variable encoded in marker size
% MATH-MODELING v3.0.0 S6 Phase 3
% Paradigm: evaluation/multivariate — three-dimensional data in 2D plane
%
% Creates a bubble chart where x,y position shows two variables and
% marker size/color encodes a third variable.
%
% Usage:
%   [fig, ax, exitflag] = plot_bubble(x, y, z)
%   [fig, ax, exitflag] = plot_bubble(..., Name, Value)

function [fig, ax, exitflag] = plot_bubble(x, y, z, opts)
arguments
    x (:,1) double
    y (:,1) double
    z (:,1) double
    opts.title_text (1,:) char = ''
    opts.xlabel_text (1,:) char = 'X'
    opts.ylabel_text (1,:) char = 'Y'
    opts.zlabel_text (1,:) char = 'Size'
    opts.base_size (1,1) double = 100
    opts.scale_factor (1,1) double = 5
    opts.color (1,:) char = '#0F4D92'
    opts.alpha (1,1) double = 0.6
end

n = length(x);
if length(y) ~= n || length(z) ~= n
    fig = gobjects(0); ax = gobjects(0); exitflag = int8(-1);
    warning('plot_bubble: x, y, z must have same length');
    return;
end

% Normalize z to marker sizes
z_norm = (z - min(z)) / (max(z) - min(z) + eps);
marker_sizes = opts.base_size + opts.scale_factor * opts.base_size * z_norm;

fig = figure('Visible', 'off', 'Color', 'w');
ax = axes('Parent', fig);
hold(ax, 'on');

% Sort by z for layering (largest on bottom)
[~, sort_idx] = sort(z, 'descend');
x_sorted = x(sort_idx);
y_sorted = y(sort_idx);
sz_sorted = marker_sizes(sort_idx);

scatter(ax, x_sorted, y_sorted, sz_sorted, ...
    'MarkerEdgeColor', opts.color, ...
    'MarkerFaceColor', opts.color, ...
    'MarkerFaceAlpha', opts.alpha, ...
    'MarkerEdgeAlpha', opts.alpha);

% Add a legend-like annotation for size reference
z_min_ref = min(z);
z_med_ref = median(z);
z_max_ref = max(z);
leg_x = max(x) + 0.08 * range(x);
leg_y = min(y) + 0.3 * range(y);
leg_text = {sprintf('%.1f', z_max_ref), sprintf('%.1f', z_med_ref), sprintf('%.1f', z_min_ref)};

% Plot reference bubbles
for ri = 1:3
    ref_z_norm = (1 - (ri-1)/2);  % 1, 0.5, 0
    ref_sz = opts.base_size + opts.scale_factor * opts.base_size * ref_z_norm;
    scatter(ax, leg_x, leg_y + (ri-2)*0.15*range(y), ref_sz, ...
        'MarkerEdgeColor', [0.5 0.5 0.5], ...
        'MarkerFaceColor', [0.7 0.7 0.7], ...
        'MarkerFaceAlpha', 0.4);
    text(ax, leg_x + 0.06*range(x), leg_y + (ri-2)*0.15*range(y), ...
        leg_text{ri}, 'FontSize', 8, 'VerticalAlignment', 'middle');
end

apply_publication_style(ax);
if ~isempty(opts.title_text); title(ax, opts.title_text); end
xlabel(ax, opts.xlabel_text); ylabel(ax, opts.ylabel_text);
text(ax, leg_x, leg_y + 0.5*range(y), opts.zlabel_text, ...
    'FontSize', 9, 'FontWeight', 'bold');

hold(ax, 'off');
exitflag = int8(0);
end

%% Self-test
function self_test()
    rng(42);
    x = randn(20,1) * 5 + 10;
    y = randn(20,1) * 3 + 5;
    z = rand(20,1) * 100;

    [fig, ax, exitflag] = plot_bubble(x, y, z, ...
        'title_text', 'Self-test: Bubble Chart');

    assert(exitflag == 0, 'plot_bubble: exitflag not zero');
    assert(~isempty(fig), 'plot_bubble: fig empty');
    assert(~isempty(ax), 'plot_bubble: ax empty');
    close(fig);
    disp('plot_bubble: self-test PASSED');
end
