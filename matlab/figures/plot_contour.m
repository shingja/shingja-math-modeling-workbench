% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
%% plot_contour — 2D contour plot with labeled contour levels
% MATH-MODELING v3.0.0 S6 Phase 3
% Paradigm: visualization/spatial — level set / isocontour representation
%
% Creates a publication-quality filled contour plot with labeled contour lines.
% Suitable for objective function landscapes, potential fields, etc.
%
% Usage:
%   [fig, ax, exitflag] = plot_contour(X, Y, Z)
%   [fig, ax, exitflag] = plot_contour(..., Name, Value)

function [fig, ax, exitflag] = plot_contour(X, Y, Z, opts)
arguments
    X (:,:) double
    Y (:,:) double
    Z (:,:) double
    opts.title_text (1,:) char = ''
    opts.xlabel_text (1,:) char = 'X'
    opts.ylabel_text (1,:) char = 'Y'
    opts.n_levels (1,1) double {mustBeInteger, mustBePositive} = 15
    opts.show_labels (1,1) logical = true
    opts.filled (1,1) logical = true
    opts.colormap_name (1,:) char = 'parula'
    opts.line_color (1,:) char = 'k'
    opts.line_width (1,1) double = 0.5
end

[m, n] = size(Z);
if ~isequal(size(X), [m, n]) || ~isequal(size(Y), [m, n])
    fig = gobjects(0); ax = gobjects(0); exitflag = int8(-1);
    warning('plot_contour: X, Y, Z must have same dimensions');
    return;
end

fig = figure('Visible', 'off', 'Color', 'w');
ax = axes('Parent', fig);
hold(ax, 'on');

% Compute contour levels
z_range = [min(Z(:)), max(Z(:))];
levels = linspace(z_range(1), z_range(2), opts.n_levels);

% Filled contour
if opts.filled
    contourf(ax, X, Y, Z, levels, 'LineStyle', 'none');
    colormap(ax, opts.colormap_name);
    colorbar(ax);
end

% Contour lines with labels
[~, h_contour] = contour(ax, X, Y, Z, levels, ...
    'Color', opts.line_color, ...
    'LineWidth', opts.line_width);

if opts.show_labels
    clabel(h_contour, 'FontSize', 8, 'Color', opts.line_color);
end

% Labels and style
apply_publication_style(ax);
if ~isempty(opts.title_text); title(ax, opts.title_text); end
xlabel(ax, opts.xlabel_text);
ylabel(ax, opts.ylabel_text);
axis(ax, 'equal', 'tight');

hold(ax, 'off');
exitflag = int8(0);
end

%% Self-test
function self_test()
    [X, Y] = meshgrid(linspace(-3, 3, 80), linspace(-3, 3, 80));
    Z = 3*(1-X).^2.*exp(-(X.^2) - (Y+1).^2) ...
      - 10*(X/5 - X.^3 - Y.^5).*exp(-X.^2 - Y.^2) ...
      - 1/3*exp(-(X+1).^2 - Y.^2);

    [fig, ax, exitflag] = plot_contour(X, Y, Z, ...
        'title_text', 'Self-test: Contour (Peaks)', 'n_levels', 12);

    assert(exitflag == 0, 'plot_contour: exitflag not zero');
    assert(~isempty(fig), 'plot_contour: fig empty');
    assert(~isempty(ax), 'plot_contour: ax empty');
    close(fig);
    disp('plot_contour: self-test PASSED');
end
