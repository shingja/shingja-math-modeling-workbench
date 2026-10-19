% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [ax_out, exitflag] = apply_publication_style(ax, opts)
% APPLY_PUBLICATION_STYLE Apply publication-quality formatting to axes. v3.0.0.
%   Sets font, line width, box off, tick direction, and optional colorblind-safe.
%   Output: ax_out (same handle), exitflag(0=OK).
arguments
    ax (1,1) matlab.graphics.axis.Axes
    opts.font_name (1,:) char = 'Arial'
    opts.font_size (1,1) double = 10
    opts.line_width (1,1) double = 1.5
    opts.colorblind (1,1) logical = true
    opts.tick_length (1,1) double = 0.015
    opts.verbose (1,1) logical = true
end

rng(42, 'twister');
exitflag = 0;
ax_out = ax;

try
    %% 1. Validate axes is valid
    if ~isvalid(ax)
        exitflag = -1;
        if opts.verbose
            fprintf('[apply_publication_style] Error: invalid axes handle.\n');
        end
        return;
    end

    %% 2. Font settings
    set(ax, 'FontName', opts.font_name);
    set(ax, 'FontSize', opts.font_size);
    ax.Title.FontName = opts.font_name;
    ax.Title.FontSize = opts.font_size + 1;
    ax.Title.FontWeight = 'bold';
    ax.XLabel.FontName = opts.font_name;
    ax.XLabel.FontSize = opts.font_size;
    ax.YLabel.FontName = opts.font_name;
    ax.YLabel.FontSize = opts.font_size;
    if ~isempty(ax.ZLabel.String)
        ax.ZLabel.FontName = opts.font_name;
        ax.ZLabel.FontSize = opts.font_size;
    end

    %% 3. Line width
    set(ax, 'LineWidth', opts.line_width);
    % Apply to all children lines
    children = ax.Children;
    for i = 1:length(children)
        if isprop(children(i), 'LineWidth') && ...
                isa(children(i), 'matlab.graphics.chart.primitive.Line')
            children(i).LineWidth = opts.line_width;
        end
    end

    %% 4. Box and tick direction
    set(ax, 'Box', 'off');
    set(ax, 'TickDir', 'out');
    set(ax, 'TickLength', [opts.tick_length, opts.tick_length * 1.5]);

    %% 5. Grid off (publication style typically has no grid)
    ax.XGrid = 'off';
    ax.YGrid = 'off';
    ax.ZGrid = 'off';
    ax.XMinorGrid = 'off';
    ax.YMinorGrid = 'off';

    %% 6. Colorblind-safe color order
    if opts.colorblind
        % Wong (2011) Nature Methods colorblind-safe palette
        cb_colors = [
            0.0000, 0.4470, 0.7410;  % blue
            0.8500, 0.3250, 0.0980;  % orange
            0.9290, 0.6940, 0.1250;  % yellow
            0.4940, 0.1840, 0.5560;  % purple
            0.4660, 0.6740, 0.1880;  % green
            0.3010, 0.7450, 0.9330;  % cyan
            0.6350, 0.0780, 0.1840;  % dark red
        ];
        ax.ColorOrder = cb_colors;
    end

    %% 7. Legend formatting
    if ~isempty(ax.Legend)
        leg = ax.Legend;
        leg.FontName = opts.font_name;
        leg.FontSize = opts.font_size - 1;
        leg.Box = 'off';
        leg.Location = 'best';
    end

    %% 8. Axis label cleanup
    % Remove unnecessary trailing zeros from tick labels
    try
        ax.XAxis.Exponent = 0;
        ax.YAxis.Exponent = 0;
    catch
        % Compatible with older MATLAB versions
    end

    %% 9. Tighten layout
    try
        ax.XAxis.TickLabelFormat = '%.4g';
        ax.YAxis.TickLabelFormat = '%.4g';
    catch
        % Older MATLAB compatibility
    end

    %% 10. Validate settings were applied
    actual_font = get(ax, 'FontName');
    actual_lw = get(ax, 'LineWidth');
    if ~strcmpi(actual_font, opts.font_name)
        exitflag = -3;
        if opts.verbose
            fprintf('[apply_publication_style] Warning: Font not set. ' + ...
                'Requested="%s", got="%s"\n', opts.font_name, actual_font);
        end
    end
    if abs(actual_lw - opts.line_width) > 1e-10
        exitflag = -3;
        if opts.verbose
            fprintf('[apply_publication_style] Warning: LineWidth mismatch.\n');
        end
    end

catch ME
    exitflag = -1;
    if opts.verbose
        fprintf('[apply_publication_style] Error: %s\n', ME.message);
    end
end

if opts.verbose && exitflag == 0
    fprintf('[apply_publication_style] Style applied successfully.\n');
end

%% Self-test
function self_test()
    fprintf('=== apply_publication_style self-test ===\n');
    fig = figure('Visible', 'off');
    ax_st = axes('Parent', fig);
    plot(ax_st, 1:10, rand(1,10), 'o-', 'DisplayName', 'Data');
    xlabel(ax_st, 'X Label');
    ylabel(ax_st, 'Y Label');
    title(ax_st, 'Test Plot');
    legend(ax_st, 'show');

    [ax_ret, ef] = apply_publication_style(ax_st, struct('verbose', false));
    assert(ef == 0, 'Should succeed, got exitflag=%d', ef);
    assert(ax_ret == ax_st, 'Should return same axes handle');

    % Verify FontName
    actual_fn = get(ax_st, 'FontName');
    assert(strcmpi(actual_fn, 'Arial'), ...
        'FontName should be Arial, got "%s"', actual_fn);

    % Verify FontSize
    actual_fs = get(ax_st, 'FontSize');
    assert(actual_fs == 10, 'FontSize should be 10, got %d', actual_fs);

    % Verify LineWidth
    actual_lw = get(ax_st, 'LineWidth');
    assert(abs(actual_lw - 1.5) < 1e-10, ...
        'LineWidth should be 1.5, got %.4f', actual_lw);

    % Verify Box is off
    actual_box = get(ax_st, 'Box');
    assert(strcmp(actual_box, 'off'), 'Box should be off');

    % Verify TickDir
    actual_td = get(ax_st, 'TickDir');
    assert(strcmp(actual_td, 'out'), 'TickDir should be out');

    % Verify Grid is off
    assert(strcmp(ax_st.XGrid, 'off'), 'XGrid should be off');
    assert(strcmp(ax_st.YGrid, 'off'), 'YGrid should be off');

    close(fig);
    disp('apply_publication_style self-test passed.');
end
end
