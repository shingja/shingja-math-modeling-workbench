% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
%% plot_gantt — Simple Gantt chart for project scheduling
% MATH-MODELING v3.0.0 S6 Phase 3
% Paradigm: operations/scheduling — timeline visualization
%
% Creates a horizontal Gantt chart showing task start times and durations.
% Suitable for project planning, scheduling results, and timeline display.
%
% Usage:
%   [fig, ax, exitflag] = plot_gantt(task_names, start_times, durations)
%   [fig, ax, exitflag] = plot_gantt(..., Name, Value)

function [fig, ax, exitflag] = plot_gantt(task_names, start_times, durations, opts)
arguments
    task_names (:,1) cell
    start_times (:,1) double
    durations (:,1) double
    opts.title_text (1,:) char = 'Project Schedule'
    opts.xlabel_text (1,:) char = 'Time'
    opts.colors (1,:) cell = {}
    opts.bar_height (1,1) double = 0.5
    opts.show_milestones (1,1) logical = false
end

n = length(task_names);
if length(start_times) ~= n || length(durations) ~= n
    fig = gobjects(0); ax = gobjects(0); exitflag = int8(-1);
    warning('plot_gantt: input length mismatch');
    return;
end

% Default colors
if isempty(opts.colors)
    p = cb_palette();
    opts.colors = p.categorical(1:n);
end

fig = figure('Visible', 'off', 'Color', 'w');
ax = axes('Parent', fig);
hold(ax, 'on');

% Plot each task as a horizontal bar
y_positions = (n:-1:1)';
for i = 1:n
    % Draw the task bar
    rectangle(ax, 'Position', [start_times(i), y_positions(i) - opts.bar_height/2, ...
        durations(i), opts.bar_height], ...
        'FaceColor', opts.colors{mod(i-1, length(opts.colors)) + 1}, ...
        'EdgeColor', 'k', 'LineWidth', 0.5);

    % Task label on the bar
    mid_time = start_times(i) + durations(i) / 2;
    text(ax, mid_time, y_positions(i), task_names{i}, ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle', ...
        'FontSize', 8);

    % End time annotation
    end_time = start_times(i) + durations(i);
    text(ax, end_time + 0.02 * (max(start_times + durations) - min(start_times)), ...
        y_positions(i), sprintf('%.1f', end_time), ...
        'FontSize', 7, 'VerticalAlignment', 'middle');
end

% Add milestone markers (diamond) if requested
if opts.show_milestones
    for i = 1:n
        plot(ax, start_times(i) + durations(i), y_positions(i), ...
            'rd', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
    end
end

% Style
apply_publication_style(ax);
ax.YTick = y_positions;
ax.YTickLabel = [];  % Labels already on bars
ax.YLim = [0.2, n + 0.8];
ax.XLim = [min(start_times) - 0.05*range([start_times; start_times+durations]), ...
           max(start_times + durations) + 0.1*range([start_times; start_times+durations])];

if ~isempty(opts.title_text); title(ax, opts.title_text); end
xlabel(ax, opts.xlabel_text);

% Remove y-axis elements for cleanliness
ax.YColor = 'none';

hold(ax, 'off');
exitflag = int8(0);
end

%% Self-test
function self_test()
    tasks = {'Literature Review'; 'Data Collection'; 'Model Design'; ...
             'Implementation'; 'Testing'};
    starts = [0; 3; 6; 9; 14];
    durs   = [3; 3; 4; 5; 3];

    [fig, ax, exitflag] = plot_gantt(tasks, starts, durs, ...
        'title_text', 'Self-test: Gantt Chart');

    assert(exitflag == 0, 'plot_gantt: exitflag not zero');
    assert(~isempty(fig), 'plot_gantt: fig empty');
    assert(~isempty(ax), 'plot_gantt: ax empty');
    close(fig);
    disp('plot_gantt: self-test PASSED');
end
