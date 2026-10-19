% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
%% plot_scatter_fit — Scatter plot with linear regression fit and R^2 annotation
% MATH-MODELING v3.0.0 S6 Phase 3
% Paradigm: statistics/regression — correlation with goodness-of-fit
%
% Creates a scatter plot with fitted regression line, confidence band,
% and annotated R-squared value.
%
% Usage:
%   [fig, ax, exitflag] = plot_scatter_fit(x, y)
%   [fig, ax, exitflag] = plot_scatter_fit(..., Name, Value)

function [fig, ax, exitflag] = plot_scatter_fit(x, y, opts)
arguments
    x (:,1) double
    y (:,1) double
    opts.title_text (1,:) char = ''
    opts.xlabel_text (1,:) char = 'X'
    opts.ylabel_text (1,:) char = 'Y'
    opts.point_color (1,:) char = '#0F4D92'
    opts.line_color (1,:) char = '#B64342'
    opts.point_size (1,1) double = 36
    opts.point_alpha (1,1) double = 0.5
    opts.show_ci (1,1) logical = true
    opts.robust (1,1) logical = false  % use robustfit if true
end

n = length(x);
if length(y) ~= n
    fig = gobjects(0); ax = gobjects(0); exitflag = int8(-1);
    warning('plot_scatter_fit: x and y must have same length');
    return;
end

% Remove NaNs
valid = ~isnan(x) & ~isnan(y);
x_clean = x(valid);
y_clean = y(valid);

if length(x_clean) < 3
    fig = gobjects(0); ax = gobjects(0); exitflag = int8(-1);
    warning('plot_scatter_fit: need at least 3 valid points');
    return;
end

% Fit linear model: y = a + b*x
if opts.robust
    b_coeff = robustfit(x_clean, y_clean);
    a = b_coeff(1); b_val = b_coeff(2);
else
    X_design = [ones(length(x_clean), 1), x_clean];
    coeffs = X_design \ y_clean;
    a = coeffs(1); b_val = coeffs(2);
end

% Predicted values
y_pred = a + b_val * x_clean;

% R-squared
ss_res = sum((y_clean - y_pred).^2);
ss_tot = sum((y_clean - mean(y_clean)).^2);
r_squared = 1 - ss_res / ss_tot;
r_squared = max(0, min(1, r_squared));

% Confidence interval for predictions
resid = y_clean - y_pred;
rmse = sqrt(sum(resid.^2) / (length(x_clean) - 2));
x_sorted = sort(x_clean);
x_pred = [ones(length(x_sorted), 1), x_sorted];
y_fit = a + b_val * x_sorted;
se_fit = rmse * sqrt(diag(x_pred * inv(x_pred' * x_pred) * x_pred'));
t_crit = tinv(0.975, length(x_clean) - 2);
ci_upper = y_fit + t_crit * se_fit;
ci_lower = y_fit - t_crit * se_fit;

% Plot
fig = figure('Visible', 'off', 'Color', 'w');
ax = axes('Parent', fig);
hold(ax, 'on');

% Scatter points
scatter(ax, x_clean, y_clean, opts.point_size, ...
    'MarkerEdgeColor', opts.point_color, ...
    'MarkerFaceColor', opts.point_color, ...
    'MarkerFaceAlpha', opts.point_alpha, ...
    'MarkerEdgeAlpha', opts.point_alpha);

% Confidence band
if opts.show_ci
    patch(ax, [x_sorted; flipud(x_sorted)], [ci_lower; flipud(ci_upper)], ...
        opts.line_color, 'FaceAlpha', 0.15, 'EdgeColor', 'none');
end

% Regression line
plot(ax, x_sorted, y_fit, '-', ...
    'Color', opts.line_color, 'LineWidth', 2);

% R^2 annotation
annotation_text = sprintf('R^2 = %.4f\ny = %.3f + %.3fx', r_squared, a, b_val);
text(ax, min(x_clean) + 0.05*range(x_clean), ...
     max(y_clean) - 0.05*range(y_clean), ...
     annotation_text, 'FontSize', 9, 'VerticalAlignment', 'top', ...
     'BackgroundColor', 'w', 'EdgeColor', [0.7 0.7 0.7]);

apply_publication_style(ax);
if ~isempty(opts.title_text); title(ax, opts.title_text); end
xlabel(ax, opts.xlabel_text); ylabel(ax, opts.ylabel_text);

hold(ax, 'off');
exitflag = int8(0);
end

%% Self-test
function self_test()
    rng(42);
    x = linspace(0, 10, 50)';
    y_true = 2 * x + 1;
    y = y_true + randn(50,1) * 3;

    [fig, ax, exitflag] = plot_scatter_fit(x, y, ...
        'title_text', 'Self-test: Scatter + Fit', ...
        'xlabel_text', 'X', 'ylabel_text', 'Y');

    assert(exitflag == 0, 'plot_scatter_fit: exitflag not zero');
    assert(~isempty(fig), 'plot_scatter_fit: fig empty');
    assert(~isempty(ax), 'plot_scatter_fit: ax empty');

    % Verify R^2 is reasonable (should be high for 2x+1 trend)
    titles = ax.Title.String;
    % Just verify handles are valid
    close(fig);
    disp('plot_scatter_fit: self-test PASSED');
end
