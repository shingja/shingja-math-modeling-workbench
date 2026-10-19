% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
%% plot_pareto_front — Pareto front visualization for multi-objective optimization
% MATH-MODELING v3.0.0 S6 Phase 3
% Paradigm: optimization/multi-objective — trade-off analysis
%
% Visualizes a 2D Pareto front with non-dominated solutions highlighted.
% Handles both minimization and maximization objectives.
%
% Usage:
%   [fig, ax, exitflag] = plot_pareto_front(obj1, obj2)
%   [fig, ax, exitflag] = plot_pareto_front(..., Name, Value)

function [fig, ax, exitflag] = plot_pareto_front(obj1, obj2, opts)
arguments
    obj1 (:,1) double  % objective 1 values
    obj2 (:,1) double  % objective 2 values
    opts.title_text (1,:) char = ''
    opts.xlabel_text (1,:) char = 'Objective 1'
    opts.ylabel_text (1,:) char = 'Objective 2'
    opts.obj1_dir (1,:) char {mustBeMember(opts.obj1_dir, {'min','max'})} = 'min'
    opts.obj2_dir (1,:) char {mustBeMember(opts.obj2_dir, {'min','max'})} = 'min'
    opts.dominated_color (1,:) char = '#767676'
    opts.pareto_color (1,:) char = '#0F4D92'
    opts.marker_size (1,1) double = 60
    opts.pareto_marker_size (1,1) double = 100
end

n = length(obj1);
if length(obj2) ~= n
    fig = gobjects(0); ax = gobjects(0); exitflag = int8(-1);
    warning('plot_pareto_front: obj1 and obj2 must have same length');
    return;
end

% Normalize direction: make both "lower is better" for comparison
o1 = obj1; o2 = obj2;
if strcmp(opts.obj1_dir, 'max'), o1 = -o1; end
if strcmp(opts.obj2_dir, 'max'), o2 = -o2; end

% Find Pareto frontier (non-dominated sorting)
pareto_idx = false(n, 1);
for i = 1:n
    dominated = false;
    for j = 1:n
        if i == j, continue; end
        if o1(j) <= o1(i) && o2(j) <= o2(i) && (o1(j) < o1(i) || o2(j) < o2(i))
            dominated = true;
            break;
        end
    end
    pareto_idx(i) = ~dominated;
end

% Sort Pareto front by obj1 for a connected line
pf_idx = find(pareto_idx);
[~, sort_order] = sort(obj1(pf_idx));
pf_idx = pf_idx(sort_order);

fig = figure('Visible', 'off', 'Color', 'w');
ax = axes('Parent', fig);
hold(ax, 'on');

% Plot all points (dominated in gray)
dom_mask = ~pareto_idx;
if any(dom_mask)
    scatter(ax, obj1(dom_mask), obj2(dom_mask), opts.marker_size, ...
        'MarkerEdgeColor', opts.dominated_color, ...
        'MarkerFaceColor', opts.dominated_color, ...
        'MarkerFaceAlpha', 0.3, 'DisplayName', 'Dominated');
end

% Plot Pareto front points
scatter(ax, obj1(pareto_idx), obj2(pareto_idx), opts.pareto_marker_size, ...
    'MarkerEdgeColor', opts.pareto_color, ...
    'MarkerFaceColor', opts.pareto_color, ...
    'MarkerFaceAlpha', 0.8, 'DisplayName', 'Pareto Optimal');

% Connect Pareto front with line
if length(pf_idx) > 1
    plot(ax, obj1(pf_idx), obj2(pf_idx), '-', ...
        'Color', opts.pareto_color, 'LineWidth', 1.5, ...
        'DisplayName', 'Pareto Frontier');
end

% Annotation
text(ax, mean(obj1)*0.95, max(obj2)*0.95, ...
    sprintf('Pareto: %d/%d solutions', sum(pareto_idx), n), ...
    'FontSize', 9, 'BackgroundColor', 'w', 'EdgeColor', [0.7 0.7 0.7]);

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
    n_pts = 50;
    obj1 = rand(n_pts, 1) * 10;
    obj2 = rand(n_pts, 1) * 10;

    [fig, ax, exitflag] = plot_pareto_front(obj1, obj2, ...
        'title_text', 'Self-test: Pareto Front');

    assert(exitflag == 0, 'plot_pareto_front: exitflag not zero');
    assert(~isempty(fig), 'plot_pareto_front: fig empty');
    assert(~isempty(ax), 'plot_pareto_front: ax empty');
    close(fig);
    disp('plot_pareto_front: self-test PASSED');
end
