% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
%% plot_map_scatter — Geographic scatter plot for spatial data
% MATH-MODELING v3.0.0 S6 Phase 3
% Paradigm: visualization/spatial — geographic point distribution
%
% Creates a scatter plot on geographic coordinates. If the Mapping Toolbox
% is available, uses geoscatter; otherwise falls back to a plain lat/lon
% scatter with a note.
%
% Usage:
%   [fig, ax, exitflag] = plot_map_scatter(lat, lon, values)
%   [fig, ax, exitflag] = plot_map_scatter(..., Name, Value)

function [fig, ax, exitflag] = plot_map_scatter(lat, lon, values, opts)
arguments
    lat (:,1) double
    lon (:,1) double
    values (:,1) double = []
    opts.title_text (1,:) char = ''
    opts.point_labels (:,1) cell = {}
    opts.marker_size (1,1) double = 80
    opts.color (1,:) char = '#0F4D92'
    opts.colormap_name (1,:) char = 'parula'
end

n = length(lat);
if length(lon) ~= n
    fig = gobjects(0); ax = gobjects(0); exitflag = int8(-1);
    warning('plot_map_scatter: lat and lon must have same length');
    return;
end

% Check for Mapping Toolbox
has_mapping = license('test', 'Mapping_Toolbox');

fig = figure('Visible', 'off', 'Color', 'w');

if has_mapping
    % Use geoscatter if available
    if isempty(values)
        gx = geoaxes('Parent', fig);
        geoscatter(gx, lat, lon, opts.marker_size, 'filled', ...
            'MarkerFaceColor', opts.color);
    else
        gx = geoaxes('Parent', fig);
        geoscatter(gx, lat, lon, opts.marker_size, values, 'filled');
        colormap(gx, opts.colormap_name);
        colorbar(gx);
    end
    ax = gx;
    if ~isempty(opts.title_text); title(ax, opts.title_text); end

    % Add point labels if provided
    if ~isempty(opts.point_labels)
        for i = 1:min(n, length(opts.point_labels))
            text(gx, lat(i), lon(i), opts.point_labels{i}, ...
                'FontSize', 8, 'VerticalAlignment', 'bottom');
        end
    end

else
    % Fallback: plain scatter with note
    ax = axes('Parent', fig);
    hold(ax, 'on');

    if isempty(values)
        scatter(ax, lon, lat, opts.marker_size, opts.color, 'filled', ...
            'MarkerEdgeColor', 'k', 'LineWidth', 0.5);
    else
        scatter(ax, lon, lat, opts.marker_size, values, 'filled', ...
            'MarkerEdgeColor', 'k', 'LineWidth', 0.5);
        colorbar(ax);
    end

    % Point labels
    if ~isempty(opts.point_labels)
        for i = 1:min(n, length(opts.point_labels))
            text(ax, lon(i), lat(i), ['  ', opts.point_labels{i}], ...
                'FontSize', 8);
        end
    end

    % Note about Mapping Toolbox
    text(ax, mean(lon), max(lat) + 0.02*range(lat), ...
        '[Mapping Toolbox unavailable — plain scatter]', ...
        'FontSize', 8, 'Color', [0.5 0.5 0.5], ...
        'HorizontalAlignment', 'center');

    apply_publication_style(ax);
    if ~isempty(opts.title_text); title(ax, opts.title_text); end
    xlabel(ax, 'Longitude');
    ylabel(ax, 'Latitude');
    axis(ax, 'equal');
    hold(ax, 'off');
end

exitflag = int8(0);
end

%% Self-test
function self_test()
    % 5 city coordinates (approximate) in China
    lat = [39.91, 31.23, 23.13, 30.57, 22.55]';
    lon = [116.40, 121.47, 113.26, 104.07, 114.06]';
    names = {'Beijing', 'Shanghai', 'Guangzhou', 'Chengdu', 'Shenzhen'};

    [fig, ax, exitflag] = plot_map_scatter(lat, lon, [], ...
        'title_text', 'Self-test: China Cities', ...
        'point_labels', names);

    assert(exitflag == 0, 'plot_map_scatter: exitflag not zero');
    assert(~isempty(fig), 'plot_map_scatter: fig empty');
    assert(~isempty(ax), 'plot_map_scatter: ax empty');
    close(fig);
    disp('plot_map_scatter: self-test PASSED');
end
