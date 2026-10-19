% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
%% plot_surface_3d — 3D surface mesh/surf visualization
% MATH-MODELING v3.0.0 S6 Phase 3
% Paradigm: visualization/spatial — three-dimensional function representation
%
% Creates a publication-quality 3D surface plot with configurable lighting,
% colormap, and viewpoint.
%
% Usage:
%   [fig, ax, exitflag] = plot_surface_3d(X, Y, Z)
%   [fig, ax, exitflag] = plot_surface_3d(..., Name, Value)

function [fig, ax, exitflag] = plot_surface_3d(X, Y, Z, opts)
arguments
    X (:,:) double
    Y (:,:) double
    Z (:,:) double
    opts.title_text (1,:) char = ''
    opts.xlabel_text (1,:) char = 'X'
    opts.ylabel_text (1,:) char = 'Y'
    opts.zlabel_text (1,:) char = 'Z'
    opts.colormap_name (1,:) char = 'parula'
    opts.face_alpha (1,1) double = 0.9
    opts.edge_alpha (1,1) double = 0.3
    opts.view_angle (1,2) double = [-37.5, 30]
    opts.lighting_mode (1,:) char {mustBeMember(opts.lighting_mode, {'none','flat','gouraud','phong'})} = 'phong'
end

[m, n] = size(Z);
if ~isequal(size(X), [m, n]) || ~isequal(size(Y), [m, n])
    fig = gobjects(0); ax = gobjects(0); exitflag = int8(-1);
    warning('plot_surface_3d: X, Y, Z must have same dimensions');
    return;
end

fig = figure('Visible', 'off', 'Color', 'w');
ax = axes('Parent', fig);

% Surface plot
surf(ax, X, Y, Z, ...
    'FaceAlpha', opts.face_alpha, ...
    'EdgeAlpha', opts.edge_alpha);

% Colormap
colormap(ax, opts.colormap_name);
colorbar(ax);

% Lighting for depth
if ~strcmp(opts.lighting_mode, 'none')
    camlight('headlight');
    lighting(opts.lighting_mode);
    material('dull');
end

% View angle
view(ax, opts.view_angle);

% Labels
apply_publication_style(ax, 'font_size', 9);
if ~isempty(opts.title_text); title(ax, opts.title_text); end
xlabel(ax, opts.xlabel_text);
ylabel(ax, opts.ylabel_text);
zlabel(ax, opts.zlabel_text);

% Make axis equal-ish if data range allows
ax.DataAspectRatioMode = 'manual';
ranges = [range(X(:)), range(Y(:)), range(Z(:))];
if max(ranges)/min(ranges) < 5
    ax.DataAspectRatio = [1 1 1];
end

grid(ax, 'off');

exitflag = int8(0);
end

%% Self-test
function self_test()
    [X, Y] = meshgrid(linspace(-3, 3, 50), linspace(-3, 3, 50));
    Z = 3*(1-X).^2.*exp(-(X.^2) - (Y+1).^2) ...
      - 10*(X/5 - X.^3 - Y.^5).*exp(-X.^2 - Y.^2) ...
      - 1/3*exp(-(X+1).^2 - Y.^2);

    [fig, ax, exitflag] = plot_surface_3d(X, Y, Z, ...
        'title_text', 'Self-test: Peaks Surface');

    assert(exitflag == 0, 'plot_surface_3d: exitflag not zero');
    assert(~isempty(fig), 'plot_surface_3d: fig empty');
    assert(~isempty(ax), 'plot_surface_3d: ax empty');
    close(fig);
    disp('plot_surface_3d: self-test PASSED');
end
