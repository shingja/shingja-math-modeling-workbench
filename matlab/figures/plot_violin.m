% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
%% plot_violin — Violin plot for distribution density comparison
% MATH-MODELING v3.0.0 S6 Phase 3
% Paradigm: statistics/distribution — kernel density visualization
%
% Creates violin plots using kernel density estimation for multiple groups.
% More informative than box plots for multimodal or non-normal distributions.
%
% Usage:
%   [fig, ax, exitflag] = plot_violin(data, group_labels)
%   [fig, ax, exitflag] = plot_violin(..., Name, Value)

function [fig, ax, exitflag] = plot_violin(data, group_labels, opts)
arguments
    data (1,:) cell          % each cell = (:,1) double vector
    group_labels (1,:) cell  % one label per group
    opts.title_text (1,:) char = ''
    opts.ylabel_text (1,:) char = 'Value'
    opts.colors (1,:) cell = {}
    opts.bandwidth (1,1) double = 0  % 0 = auto-silverman
    opts.violin_width (1,1) double = 0.7
end

n_groups = length(data);
if length(group_labels) ~= n_groups
    fig = gobjects(0); ax = gobjects(0); exitflag = int8(-1);
    warning('plot_violin: data and group_labels length mismatch');
    return;
end

if isempty(opts.colors)
    p = cb_palette();
    opts.colors = p.categorical(1:n_groups);
end

fig = figure('Visible', 'off', 'Color', 'w');
ax = axes('Parent', fig);
hold(ax, 'on');

for i = 1:n_groups
    d = data{i}(:);
    d = d(~isnan(d) & ~isinf(d));
    if isempty(d), continue; end

    % Kernel density estimation
    [f, xi] = ksdensity(d);
    if opts.bandwidth > 0
        [f, xi] = ksdensity(d, 'Bandwidth', opts.bandwidth);
    end

    % Scale density to violin width
    f_scaled = f / max(f) * (opts.violin_width / 2);

    % Left half
    x_left = i - f_scaled;
    % Right half
    x_right = i + fliplr(f_scaled);

    % Build closed patch: left side (low to high), right side reversed (high to low)
    x_patch = [x_left, fliplr(x_right)];
    y_patch = [xi, fliplr(xi)];

    patch(ax, x_patch, y_patch, opts.colors{i}, ...
        'FaceAlpha', 0.5, 'EdgeColor', opts.colors{i}, 'LineWidth', 1);

    % Median marker
    med = median(d);
    plot(ax, [i - opts.violin_width/3, i + opts.violin_width/3], [med, med], ...
        '-', 'Color', 'k', 'LineWidth', 1.5);

    % Interquartile range indicator
    q1 = prctile(d, 25);
    q3 = prctile(d, 75);
    plot(ax, [i, i], [q1, q3], 'k-', 'LineWidth', 2);
end

apply_publication_style(ax);
ax.XTick = 1:n_groups;
ax.XTickLabel = group_labels;
ax.XLim = [0.3, n_groups + 0.7];

if ~isempty(opts.title_text); title(ax, opts.title_text); end
ylabel(ax, opts.ylabel_text);

hold(ax, 'off');
exitflag = int8(0);
end

%% Self-test
function self_test()
    rng(42);
    % Group 1: normal, Group 2: bimodal
    g1 = randn(200,1)*0.8 + 3;
    g2 = [randn(100,1)*0.5 + 2; randn(100,1)*0.5 + 5];
    data = {g1, g2};
    labels = {'Normal', 'Bimodal'};

    [fig, ax, exitflag] = plot_violin(data, labels, ...
        'title_text', 'Self-test: Violin Plot');

    assert(exitflag == 0, 'plot_violin: exitflag not zero');
    assert(~isempty(fig), 'plot_violin: fig empty');
    assert(~isempty(ax), 'plot_violin: ax empty');
    close(fig);
    disp('plot_violin: self-test PASSED');
end
