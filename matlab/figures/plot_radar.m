% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
%% plot_radar — Radar/spider chart for multi-criteria comparison
% MATH-MODELING v3.0.0 S6 Phase 3
% Paradigm: evaluation/multi-criteria — holistic alternative comparison
%
% Creates a radar/spider chart overlaying multiple alternatives across
% several criteria axes. Suitable for MCDM results visualization.
%
% Usage:
%   [fig, ax, exitflag] = plot_radar(data, criteria_labels, alternative_labels)
%   [fig, ax, exitflag] = plot_radar(..., Name, Value)

function [fig, ax, exitflag] = plot_radar(data, criteria_labels, alternative_labels, opts)
arguments
    data (:,:) double   % n_alternatives x n_criteria
    criteria_labels (1,:) cell
    alternative_labels (1,:) cell
    opts.title_text (1,:) char = ''
    opts.fill_alpha (1,1) double = 0.2
    opts.line_width (1,1) double = 1.5
    opts.max_scale (1,1) double = 0  % 0=auto from data
end

[n_alt, n_crit] = size(data);
if length(criteria_labels) ~= n_crit || length(alternative_labels) ~= n_alt
    fig = gobjects(0); ax = gobjects(0); exitflag = int8(-1);
    warning('plot_radar: label count mismatch with data dimensions');
    return;
end

if opts.max_scale == 0
    opts.max_scale = max(data(:)) * 1.1;
end

% Compute angle for each axis
angles = linspace(0, 2*pi, n_crit + 1);
angles = angles(1:end-1);

p = cb_palette();
colors = p.categorical(1:n_alt);

fig = figure('Visible', 'off', 'Color', 'w');
ax = axes('Parent', fig);
hold(ax, 'on');

% Draw axis lines and labels
for i = 1:n_crit
    x_end = opts.max_scale * cos(angles(i));
    y_end = opts.max_scale * sin(angles(i));
    plot(ax, [0, x_end], [0, y_end], '-', ...
        'Color', [0.7 0.7 0.7], 'LineWidth', 0.5);
    % Label
    text(ax, x_end * 1.12, y_end * 1.12, criteria_labels{i}, ...
        'FontSize', 9, 'HorizontalAlignment', 'center');
end

% Draw grid circles
n_grid = 4;
for g = 1:n_grid
    r = opts.max_scale * g / n_grid;
    theta_grid = linspace(0, 2*pi, 100);
    plot(ax, r*cos(theta_grid), r*sin(theta_grid), ':', ...
        'Color', [0.8 0.8 0.8], 'LineWidth', 0.3);
end

% Plot each alternative
h_leg = gobjects(1, n_alt);
for j = 1:n_alt
    vals = [data(j, :), data(j, 1)];  % close the polygon
    ang_closed = [angles, angles(1)];
    x_vals = vals .* cos(ang_closed);
    y_vals = vals .* sin(ang_closed);

    h_leg(j) = plot(ax, x_vals, y_vals, 'o-', ...
        'Color', colors{j}, 'LineWidth', opts.line_width, ...
        'MarkerFaceColor', colors{j}, 'MarkerSize', 6);

    % Fill
    patch(ax, x_vals, y_vals, colors{j}, ...
        'FaceAlpha', opts.fill_alpha, 'EdgeColor', 'none');
end

% Legend
legend(ax, h_leg, alternative_labels, 'Location', 'bestoutside', 'Box', 'off');

apply_publication_style(ax);
axis(ax, 'equal');
set(ax, 'Visible', 'off');
if ~isempty(opts.title_text); title(ax, opts.title_text, 'Visible', 'on'); end

hold(ax, 'off');
exitflag = int8(0);
end

%% Self-test
function self_test()
    data = [0.85 0.72 0.91 0.68 0.79;
            0.78 0.88 0.65 0.82 0.91;
            0.62 0.94 0.83 0.75 0.66];
    criteria = {'Accuracy', 'Speed', 'Robust.', 'Scalab.', 'Cost-Eff.'};
    alternatives = {'Method X', 'Method Y', 'Method Z'};

    [fig, ax, exitflag] = plot_radar(data, criteria, alternatives, ...
        'title_text', 'Self-test: Radar Chart');

    assert(exitflag == 0, 'plot_radar: exitflag not zero');
    assert(~isempty(fig), 'plot_radar: fig empty');
    assert(~isempty(ax), 'plot_radar: ax empty');
    close(fig);
    disp('plot_radar: self-test PASSED');
end
