% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
%% export_publication_figure — Export figure to publication formats (SVG+PNG)
% MATH-MODELING v3.0.0 S6 Phase 3
% Paradigm: visualization/infrastructure — reproducible figure export
%
% Exports a MATLAB figure to SVG and/or PNG at specified DPI.
% Uses exportgraphics (R2020a+) for reliable vector/raster output.
%
% Usage:
%   export_publication_figure(fig, 'output/fig1')
%   export_publication_figure(fig, 'output/fig1', 'formats', ["svg","png"], 'dpi', 600)
%
% Inputs:
%   fig       — (1,1) matlab.ui.Figure handle
%   base_path — (1,:) char, file path without extension
%   Name-Value pairs:
%     formats  — (1,:) string, default ["svg","png"]
%     dpi      — (1,1) double, default 300

function export_publication_figure(fig, base_path, opts)
arguments
    fig (1,1) matlab.ui.Figure
    base_path (1,:) char
    opts.formats (1,:) string = ["svg", "png"]
    opts.dpi (1,1) double {mustBePositive, mustBeInteger} = 300
end

% Ensure output directory exists
[fdir, ~, ~] = fileparts(base_path);
if ~isempty(fdir) && ~isfolder(fdir)
    mkdir(fdir);
end

% Export in each requested format
for i = 1:length(opts.formats)
    fmt = lower(strtrim(opts.formats(i)));
    switch fmt
        case "png"
            fname = strcat(base_path, '.png');
            exportgraphics(fig, fname, 'Resolution', opts.dpi);
        case "svg"
            fname = strcat(base_path, '.svg');
            exportgraphics(fig, fname, 'ContentType', 'vector');
        case "pdf"
            fname = strcat(base_path, '.pdf');
            exportgraphics(fig, fname, 'ContentType', 'vector');
        case "eps"
            fname = strcat(base_path, '.eps');
            exportgraphics(fig, fname, 'ContentType', 'vector');
        otherwise
            warning('export_publication_figure: unknown format "%s", skipping', fmt);
    end
end
end

%% Self-test
function self_test()
    f = figure('Visible', 'off');
    plot(1:10, rand(1,10), 'o-');
    title('Test Export');
    xlabel('x'); ylabel('y');
    apply_publication_style(gca);
    % Export to a temporary location
    tmpdir = tempname;
    mkdir(tmpdir);
    base = fullfile(tmpdir, 'test_export');
    export_publication_figure(f, base, 'formats', ["png"], 'dpi', 150);
    % Verify file was created
    expected_file = strcat(base, '.png');
    assert(isfile(expected_file), 'export_publication_figure: PNG not created');
    % Clean up
    delete(expected_file);
    rmdir(tmpdir);
    close(f);
    disp('export_publication_figure: self-test PASSED');
end
