% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
%% apply_publication_style — Apply consistent publication-quality style to axes
% MATH-MODELING v3.0.0 S6 Phase 3
% Paradigm: visualization/infrastructure — unified figure aesthetics
%
% Applies consistent font, linewidth, no-grid, box-off, tick-out style.
%
% Usage:
%   apply_publication_style(ax)
%   apply_publication_style(ax, 'font_name', 'Times New Roman', 'font_size', 11)
%
% Inputs:
%   ax — (1,1) matlab.graphics.axis.Axes handle
%   Name-Value pairs:
%     font_name  — (1,:) char, default 'Arial'
%     font_size  — (1,1) double, default 10
%     line_width — (1,1) double, default 1.5
%
% Output: none (modifies ax in place)

function apply_publication_style(ax, opts)
arguments
    ax (1,1) matlab.graphics.axis.Axes
    opts.font_name (1,:) char = 'Arial'
    opts.font_size (1,1) double = 10
    opts.line_width (1,1) double = 1.5
end

% Core style: font, linewidth, box, tick direction
set(ax, 'FontName', opts.font_name, ...
        'FontSize', opts.font_size, ...
        'LineWidth', opts.line_width);

% Box off for cleaner look
set(ax, 'Box', 'off');

% Ticks pointing outward
set(ax, 'TickDir', 'out');

% No grid lines for publication cleanliness
ax.XGrid = 'off';
ax.YGrid = 'off';

% Ensure minor grid is also off
ax.XMinorGrid = 'off';
ax.YMinorGrid = 'off';

% Set tick length
set(ax, 'TickLength', [0.01, 0.025]);

% Ensure axis is tight where appropriate (but don't override user)
% ax.XLimMode and ax.YLimMode remain 'auto' unless previously set
end

%% Self-test
function self_test()
    f = figure('Visible', 'off', 'Position', [100 100 400 300]);
    ax = axes('Parent', f);
    plot(ax, 1:10, rand(1,10), 'o-');
    apply_publication_style(ax);
    assert(~isempty(ax), 'apply_publication_style: ax handle is empty');
    assert(strcmp(ax.FontName, 'Arial'), 'apply_publication_style: font name mismatch');
    assert(ax.FontSize == 10, 'apply_publication_style: font size mismatch');
    assert(strcmp(ax.Box, 'off'), 'apply_publication_style: box not off');
    assert(strcmp(ax.XGrid, 'off'), 'apply_publication_style: xgrid not off');
    assert(strcmp(ax.YGrid, 'off'), 'apply_publication_style: ygrid not off');
    close(f);
    disp('apply_publication_style: self-test PASSED');
end
