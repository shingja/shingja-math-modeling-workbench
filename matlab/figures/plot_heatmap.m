% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
%% plot_heatmap — Heatmap visualization with colorbar
% MATH-MODELING v3.0.0 S6 Phase 3
% Paradigm: evaluation/matrix — 2D correlation or confusion visualization
%
% Creates a publication-quality heatmap with labeled rows/columns and colorbar.
% Supports symmetric diverging colormap for correlation matrices.
%
% Usage:
%   [fig, ax, exitflag] = plot_heatmap(data, row_labels, col_labels)
%   [fig, ax, exitflag] = plot_heatmap(..., Name, Value)

function [fig, ax, exitflag] = plot_heatmap(data, row_labels, col_labels, opts)
arguments
    data (:,:) double
    row_labels (1,:) cell
    col_labels (1,:) cell
    opts.title_text (1,:) char = ''
    opts.colormap_name (1,:) char = 'cb_diverging'
    opts.show_values (1,1) logical = true
    opts.value_format (1,:) char = '%.2f'
    opts.caxis_limits (1,2) double = [0 0]  % [0 0] = auto
    opts.font_size (1,1) double = 9
end

[n_rows, n_cols] = size(data);
if length(row_labels) ~= n_rows || length(col_labels) ~= n_cols
    fig = gobjects(0); ax = gobjects(0); exitflag = int8(-1);
    warning('plot_heatmap: label count mismatch with data dimensions');
    return;
end

% Colormap
switch opts.colormap_name
    case 'cb_diverging'
        p = cb_palette();
        n_levels = 256;
        cmap = interp_colors(p.diverging, n_levels);
    case 'cb_sequential'
        p = cb_palette();
        n_levels = 256;
        cmap = interp_colors(p.sequential, n_levels);
    otherwise
        cmap = opts.colormap_name; % pass through
end

fig = figure('Visible', 'off', 'Color', 'w');
ax = axes('Parent', fig);

% Create heatmap using imagesc
imagesc(ax, data);
colormap(ax, cmap);
cb = colorbar(ax);
apply_publication_style(ax);

% Color axis limits
if all(opts.caxis_limits == 0)
    caxis(ax, [min(data(:)), max(data(:))]);
else
    caxis(ax, opts.caxis_limits);
end

% Apply style to colorbar too
apply_publication_style_axes(cb);

% Set tick labels
ax.XTick = 1:n_cols;
ax.XTickLabel = col_labels;
ax.YTick = 1:n_rows;
ax.YTickLabel = row_labels;
ax.XTickLabelRotation = 45;

% Overlay text values
if opts.show_values
    for i = 1:n_rows
        for j = 1:n_cols
            val = data(i, j);
            text(ax, j, i, sprintf(opts.value_format, val), ...
                'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'middle', ...
                'FontSize', opts.font_size, ...
                'Color', select_text_color(val, data));
        end
    end
end

if ~isempty(opts.title_text); title(ax, opts.title_text); end

exitflag = int8(0);
end

function cmap = interp_colors(colors, n)
    % Interpolate a cell array of hex colors into an n-level colormap
    n_colors = length(colors);
    rgb = zeros(n_colors, 3);
    for c = 1:n_colors
        rgb(c, :) = hex2rgb(colors{c});
    end
    cmap = interp1(1:n_colors, rgb, linspace(1, n_colors, n));
    cmap = max(0, min(1, cmap));
end

function rgb = hex2rgb(hex)
    hex = char(hex);
    if hex(1) == '#', hex = hex(2:end); end
    rgb = [hex2dec(hex(1:2)), hex2dec(hex(3:4)), hex2dec(hex(5:6))] / 255;
end

function c = select_text_color(val, data)
    mid = (max(data(:)) + min(data(:))) / 2;
    if val > mid, c = 'w'; else, c = 'k'; end
end

function apply_publication_style_axes(h)
    try
        h.FontName = 'Arial';
        h.FontSize = 10;
    catch
    end
end

%% Self-test
function self_test()
    rng(42);
    % Generate a correlation-style matrix
    base = randn(5, 10);
    corr_mat = corr(base');
    rows = {'V1','V2','V3','V4','V5'};
    cols = {'V1','V2','V3','V4','V5'};

    [fig, ax, exitflag] = plot_heatmap(corr_mat, rows, cols, ...
        'title_text', 'Self-test: Heatmap', 'caxis_limits', [-1, 1]);

    assert(exitflag == 0, 'plot_heatmap: exitflag not zero');
    assert(~isempty(fig), 'plot_heatmap: fig empty');
    assert(~isempty(ax), 'plot_heatmap: ax empty');
    close(fig);
    disp('plot_heatmap: self-test PASSED');
end
