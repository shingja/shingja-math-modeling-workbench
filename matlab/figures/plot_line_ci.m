% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
%% plot_line_ci — Line plot with confidence band
% MATH-MODELING v3.0.0 S6 Phase 3
% Paradigm: statistics/visualization — uncertainty & error propagation display
%
% Plots a line with a shaded confidence interval band.
% Ideal for time series, convergence curves, or any estimate with uncertainty.
%
% Usage:
%   [fig, ax, exitflag] = plot_line_ci(x, y, lower_ci, upper_ci)
%   [fig, ax, exitflag] = plot_line_ci(..., Name, Value)
%
% Inputs:
%   x         — (:,1) double, x-axis values
%   y         — (:,1) double, mean/estimate
%   lower_ci  — (:,1) double, lower bound (must be <= y)
%   upper_ci  — (:,1) double, upper bound (must be >= y)
%   Name-Value pairs:
%     title_text, xlabel_text, ylabel_text, color, line_width, alpha
%
% Outputs:
%   fig      — matlab.ui.Figure handle
%   ax       — matlab.graphics.axis.Axes handle
%   exitflag — int8, 0=success, -1=validation error

function [fig, ax, exitflag] = plot_line_ci(x, y, lower_ci, upper_ci, opts)
arguments
    x (:,1) double
    y (:,1) double
    lower_ci (:,1) double
    upper_ci (:,1) double
    opts.title_text (1,:) char = ''
    opts.xlabel_text (1,:) char = ''
    opts.ylabel_text (1,:) char = ''
    opts.color (1,:) char = '#0F4D92'
    opts.line_width (1,1) double = 1.5
    opts.alpha (1,1) double {mustBeInRange(opts.alpha, 0, 1)} = 0.2
    opts.display_name (1,:) char = 'Estimate'
end

% Validate input dimensions match
n = length(x);
if length(y) ~= n || length(lower_ci) ~= n || length(upper_ci) ~= n
    fig = gobjects(0); ax = gobjects(0); exitflag = int8(-1);
    warning('plot_line_ci: dimension mismatch — x,y,lower_ci,upper_ci must have same length');
    return;
end

% Validate CI ordering
if any(lower_ci > y) || any(upper_ci < y)
    warning('plot_line_ci: CI bounds inconsistent with y — lower_ci should <= y <= upper_ci');
end

% Create figure
fig = figure('Visible', 'off', 'Color', 'w');
ax = axes('Parent', fig);
hold(ax, 'on');

% Build the CI patch: x forward, then x reversed
x_patch = [x; flipud(x)];
y_patch = [upper_ci; flipud(lower_ci)];

% Plot CI band as shaded patch
patch(ax, x_patch, y_patch, opts.color, ...
    'FaceAlpha', opts.alpha, ...
    'EdgeColor', 'none', ...
    'DisplayName', '95% CI', ...
    'HandleVisibility', 'on');

% Plot main line
plot(ax, x, y, '-', ...
    'Color', opts.color, ...
    'LineWidth', opts.line_width, ...
    'DisplayName', opts.display_name);

% Apply publication style
apply_publication_style(ax, 'line_width', opts.line_width);

% Labels
if ~isempty(opts.title_text); title(ax, opts.title_text); end
if ~isempty(opts.xlabel_text); xlabel(ax, opts.xlabel_text); end
if ~isempty(opts.ylabel_text); ylabel(ax, opts.ylabel_text); end

% Legend (only if display_name provided)
if ~isempty(opts.display_name)
    leg = legend(ax, 'Location', 'best');
    set(leg, 'Box', 'off');
end

hold(ax, 'off');
exitflag = int8(0);
end

%% Self-test
function self_test()
    rng(42);
    x = linspace(0, 4*pi, 100)';
    y_true = sin(x);
    noise = 0.15 * randn(size(x));
    y = y_true + noise;
    se = 0.15 * ones(size(x));
    lower_ci = y - 1.96 * se;
    upper_ci = y + 1.96 * se;

    [fig, ax, exitflag] = plot_line_ci(x, y, lower_ci, upper_ci, ...
        'title_text', 'Self-test: sin(x) with 95% CI', ...
        'xlabel_text', 'x', 'ylabel_text', 'sin(x)');

    assert(exitflag == 0, 'plot_line_ci: exitflag not zero');
    assert(~isempty(fig), 'plot_line_ci: fig handle empty');
    assert(~isempty(ax), 'plot_line_ci: ax handle empty');
    assert(isa(fig, 'matlab.ui.Figure'), 'plot_line_ci: fig not a Figure');
    assert(isa(ax, 'matlab.graphics.axis.Axes'), 'plot_line_ci: ax not Axes');
    close(fig);
    disp('plot_line_ci: self-test PASSED');
end
