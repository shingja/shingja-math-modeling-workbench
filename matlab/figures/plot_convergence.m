% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
%% plot_convergence — Optimization convergence curve
% MATH-MODELING v3.0.0 S6 Phase 3
% Paradigm: optimization/analysis — iterative algorithm performance tracking
%
% Plots convergence behavior: objective value vs. iteration, with optional
% best-so-far trace and log-scale toggle.
%
% Usage:
%   [fig, ax, exitflag] = plot_convergence(objective_history)
%   [fig, ax, exitflag] = plot_convergence(..., Name, Value)

function [fig, ax, exitflag] = plot_convergence(objective_history, opts)
arguments
    objective_history (:,1) double  % objective value at each iteration
    opts.title_text (1,:) char = ''
    opts.xlabel_text (1,:) char = 'Iteration'
    opts.ylabel_text (1,:) char = 'Objective Value'
    opts.log_scale (1,1) logical = false
    opts.show_best_sofar (1,1) logical = true
    opts.color (1,:) char = '#0F4D92'
    opts.best_color (1,:) char = '#B64342'
    opts.line_width (1,1) double = 1.5
    opts.marker_size (1,1) double = 10
end

n = length(objective_history);
if n < 2
    fig = gobjects(0); ax = gobjects(0); exitflag = int8(-1);
    warning('plot_convergence: need at least 2 iterations');
    return;
end

fig = figure('Visible', 'off', 'Color', 'w');
ax = axes('Parent', fig);
hold(ax, 'on');

% Iteration numbers
iters = (1:n)';

% Main convergence trace
if opts.log_scale
    % For log scale, filter out non-positive values
    pos_mask = objective_history > 0;
    plot(ax, iters(pos_mask), objective_history(pos_mask), 'o-', ...
        'Color', opts.color, 'LineWidth', opts.line_width, ...
        'MarkerSize', opts.marker_size, ...
        'DisplayName', 'Objective');
    set(ax, 'YScale', 'log');
else
    plot(ax, iters, objective_history, 'o-', ...
        'Color', opts.color, 'LineWidth', opts.line_width, ...
        'MarkerSize', opts.marker_size, ...
        'DisplayName', 'Objective');
end

% Best-so-far trace
if opts.show_best_sofar
    if strcmp(opts.log_scale, 'on') || opts.log_scale
        best_sofar = cummin(objective_history);
        best_sofar(best_sofar <= 0) = NaN;
        stairs(ax, iters, best_sofar, '--', ...
            'Color', opts.best_color, 'LineWidth', opts.line_width, ...
            'DisplayName', 'Best So Far');
    else
        best_sofar = cummin(objective_history);
        stairs(ax, iters, best_sofar, '--', ...
            'Color', opts.best_color, 'LineWidth', opts.line_width, ...
            'DisplayName', 'Best So Far');
    end
end

% Mark final value
plot(ax, iters(end), objective_history(end), 'o', ...
    'MarkerSize', opts.marker_size + 4, ...
    'Color', opts.best_color, 'LineWidth', 2, ...
    'DisplayName', 'Final');

% Annotation
if n > 0
    text(ax, iters(end)*0.5, max(objective_history)*0.95, ...
        sprintf('Final: %.4e', objective_history(end)), ...
        'FontSize', 9, 'BackgroundColor', 'w', 'EdgeColor', [0.7 0.7 0.7]);
end

apply_publication_style(ax);
if ~isempty(opts.title_text); title(ax, opts.title_text); end
xlabel(ax, opts.xlabel_text); ylabel(ax, opts.ylabel_text);

legend(ax, 'Location', 'best', 'Box', 'off');

hold(ax, 'off');
exitflag = int8(0);
end

%% Self-test
function self_test()
    rng(42);
    % Simulate decreasing objective with noise
    n_iter = 80;
    obj = 100 * exp(-(1:n_iter)'/20) + 0.5*randn(n_iter,1) + 5*(1:n_iter)'.^(-1.5);

    [fig, ax, exitflag] = plot_convergence(obj, ...
        'title_text', 'Self-test: Convergence', 'log_scale', false);

    assert(exitflag == 0, 'plot_convergence: exitflag not zero');
    assert(~isempty(fig), 'plot_convergence: fig empty');
    assert(~isempty(ax), 'plot_convergence: ax empty');
    close(fig);
    disp('plot_convergence: self-test PASSED');
end
