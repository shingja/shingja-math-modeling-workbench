% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
%% plot_sensitivity — Tornado chart for sensitivity analysis
% MATH-MODELING v3.0.0 S6 Phase 3
% Paradigm: evaluation/sensitivity — one-at-a-time parameter impact ranking
%
% Creates a tornado (butterfly) chart showing parameter sensitivity:
% how much the output varies when each parameter deviates from baseline.
%
% Usage:
%   [fig, ax, exitflag] = plot_sensitivity(param_names, base_values, lower_values, upper_values)
%   [fig, ax, exitflag] = plot_sensitivity(..., Name, Value)

function [fig, ax, exitflag] = plot_sensitivity(param_names, base_values, lower_values, upper_values, opts)
arguments
    param_names (1,:) cell
    base_values (:,1) double
    lower_values (:,1) double
    upper_values (:,1) double
    opts.title_text (1,:) char = 'Sensitivity Analysis'
    opts.xlabel_text (1,:) char = 'Output Value'
    opts.low_color (1,:) char = '#B64342'
    opts.high_color (1,:) char = '#0F4D92'
    opts.bar_height (1,1) double = 0.5
    opts.sort_by_range (1,1) logical = true
end

n = length(param_names);
if length(base_values) ~= n || length(lower_values) ~= n || length(upper_values) ~= n
    fig = gobjects(0); ax = gobjects(0); exitflag = int8(-1);
    warning('plot_sensitivity: input length mismatch');
    return;
end

% Compute ranges
ranges = abs(upper_values - lower_values);

% Sort by range (largest at top)
if opts.sort_by_range
    [ranges, sort_idx] = sort(ranges, 'descend');
    param_names = param_names(sort_idx);
    base_values = base_values(sort_idx);
    lower_values = lower_values(sort_idx);
    upper_values = upper_values(sort_idx);
end

fig = figure('Visible', 'off', 'Color', 'w');
ax = axes('Parent', fig);
hold(ax, 'on');

% y positions (top to bottom)
y_pos = n:-1:1;

% Plot lower deviation bar
low_dev = base_values - lower_values;
barh(ax, y_pos, low_dev, opts.bar_height, ...
    'FaceColor', opts.low_color, 'EdgeColor', 'none', ...
    'DisplayName', 'Lower Deviation');

% Plot upper deviation bar
high_dev = upper_values - base_values;
barh(ax, y_pos, high_dev, opts.bar_height, ...
    'FaceColor', opts.high_color, 'EdgeColor', 'none', ...
    'DisplayName', 'Upper Deviation');

% Baseline markers
plot(ax, base_values, y_pos, 'k.', 'MarkerSize', 15, ...
    'DisplayName', 'Baseline');

% Labels
for i = 1:n
    text(ax, base_values(i), y_pos(i) + 0.3, ...
        sprintf('%.2f', base_values(i)), ...
        'FontSize', 8, 'VerticalAlignment', 'bottom');
end

apply_publication_style(ax);
ax.YTick = y_pos;
ax.YTickLabel = param_names;
ax.YLim = [0.2, n + 0.8];

if ~isempty(opts.title_text); title(ax, opts.title_text); end
xlabel(ax, opts.xlabel_text);

legend(ax, 'Location', 'best', 'Box', 'off');

hold(ax, 'off');
exitflag = int8(0);
end

%% Self-test
function self_test()
    params = {'Param A', 'Param B', 'Param C', 'Param D', 'Param E', 'Param F'};
    base = [50; 30; 75; 20; 40; 60];
    low =  [40; 22; 60; 15; 32; 50];
    high = [62; 38; 85; 28; 48; 68];

    [fig, ax, exitflag] = plot_sensitivity(params, base, low, high, ...
        'title_text', 'Self-test: Tornado Chart');

    assert(exitflag == 0, 'plot_sensitivity: exitflag not zero');
    assert(~isempty(fig), 'plot_sensitivity: fig empty');
    assert(~isempty(ax), 'plot_sensitivity: ax empty');
    close(fig);
    disp('plot_sensitivity: self-test PASSED');
end
