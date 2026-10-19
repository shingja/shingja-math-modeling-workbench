% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
%% plot_boxplot — Box plot with individual data point overlay
% MATH-MODELING v3.0.0 S6 Phase 3
% Paradigm: statistics/distribution — group comparison with full data visibility
%
% Creates box plots for multiple groups with individual data points
% overlaid as jittered scatter for full transparency.
%
% Usage:
%   [fig, ax, exitflag] = plot_boxplot(data, group_labels)
%   [fig, ax, exitflag] = plot_boxplot(..., Name, Value)
%
% Inputs:
%   data         — cell array of (:,1) double vectors, one per group
%   group_labels — (1,:) or (:,1) cell of char, one label per group

function [fig, ax, exitflag] = plot_boxplot(data, group_labels, opts)
arguments
    data (1,:) cell
    group_labels (1,:) cell
    opts.title_text (1,:) char = ''
    opts.ylabel_text (1,:) char = 'Value'
    opts.colors (1,:) cell = {}
    opts.jitter_width (1,1) double = 0.3
    opts.point_size (1,1) double = 36
    opts.point_alpha (1,1) double = 0.6
end

n_groups = length(data);
if length(group_labels) ~= n_groups
    fig = gobjects(0); ax = gobjects(0); exitflag = int8(-1);
    warning('plot_boxplot: data and group_labels length mismatch');
    return;
end

% Default colors if not provided
if isempty(opts.colors)
    p = cb_palette();
    opts.colors = p.categorical(1:n_groups);
end

% Create figure
fig = figure('Visible', 'off', 'Color', 'w');
ax = axes('Parent', fig);
hold(ax, 'on');

% Draw boxplots
bp = boxplot_manual(ax, data, group_labels, opts.colors);

% Overlay individual points with jitter
for i = 1:n_groups
    vals = data{i}(:);
    n_pts = length(vals);
    jitter = opts.jitter_width * (rand(n_pts, 1) - 0.5);
    x_jittered = i * ones(n_pts, 1) + jitter;
    scatter(ax, x_jittered, vals, opts.point_size, ...
        'MarkerEdgeColor', opts.colors{i}, ...
        'MarkerFaceColor', opts.colors{i}, ...
        'MarkerFaceAlpha', opts.point_alpha * 0.3, ...
        'MarkerEdgeAlpha', opts.point_alpha);
end

% Apply style
apply_publication_style(ax);
ax.XTick = 1:n_groups;
ax.XTickLabel = group_labels;
ax.XLim = [0.3, n_groups + 0.7];

if ~isempty(opts.title_text); title(ax, opts.title_text); end
ylabel(ax, opts.ylabel_text);

hold(ax, 'off');
exitflag = int8(0);
end

function bp = boxplot_manual(ax, data, labels, colors)
    % Manual boxplot using patch + line for publication-quality control
    n_groups = length(data);
    width = 0.4;
    bp = gobjects(n_groups, 1);

    for i = 1:n_groups
        d = data{i}(:);
        d = d(~isnan(d));
        q1 = prctile(d, 25);
        q2 = prctile(d, 50);
        q3 = prctile(d, 75);
        iqr_val = q3 - q1;
        whisker_low = max(min(d), q1 - 1.5 * iqr_val);
        whisker_high = min(max(d), q3 + 1.5 * iqr_val);

        % Median line
        plot(ax, [i-width/2, i+width/2], [q2, q2], '-', ...
            'Color', colors{i}, 'LineWidth', 2);

        % Box patch
        x_box = [i-width/2, i+width/2, i+width/2, i-width/2];
        y_box = [q1, q1, q3, q3];
        patch(ax, x_box, y_box, colors{i}, ...
            'FaceAlpha', 0.3, 'EdgeColor', colors{i}, 'LineWidth', 1.5);

        % Whiskers
        plot(ax, [i, i], [q3, whisker_high], '-', ...
            'Color', colors{i}, 'LineWidth', 1.2);
        plot(ax, [i, i], [whisker_low, q1], '-', ...
            'Color', colors{i}, 'LineWidth', 1.2);
        plot(ax, [i-width/4, i+width/4], [whisker_high, whisker_high], '-', ...
            'Color', colors{i}, 'LineWidth', 1.2);
        plot(ax, [i-width/4, i+width/4], [whisker_low, whisker_low], '-', ...
            'Color', colors{i}, 'LineWidth', 1.2);
    end
end

%% Self-test
function self_test()
    rng(42);
    data = {randn(50,1)*0.8+3, randn(50,1)*1.2+5, randn(50,1)*1.0+4.5};
    labels = {'Group A', 'Group B', 'Group C'};

    [fig, ax, exitflag] = plot_boxplot(data, labels, ...
        'title_text', 'Self-test: Box Plot with Points');

    assert(exitflag == 0, 'plot_boxplot: exitflag not zero');
    assert(~isempty(fig), 'plot_boxplot: fig empty');
    assert(~isempty(ax), 'plot_boxplot: ax empty');
    close(fig);
    disp('plot_boxplot: self-test PASSED');
end
