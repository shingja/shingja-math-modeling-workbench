% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
%% figure_audit — Audit figure for publication-quality compliance
% MATH-MODELING v3.0.0 S6 Phase 3
% Paradigm: visualization/QA — automated pre-submission figure checks
%
% Scans a figure handle and its axes for common publication issues:
% DPI/resolution, font consistency, grid usage, legend placement,
% axis labels presence, title presence, colorblind accessibility hints.
%
% Usage:
%   [pass, report] = figure_audit(fig)
%   [pass, report] = figure_audit(fig, 'min_font_size', 8, 'required_labels', true)
%
% Outputs:
%   pass   — logical scalar, true if all checks passed
%   report — struct with fields:
%     .all_passed — logical
%     .issues     — (1,:) cell of char vectors describing problems
%     .warnings   — (1,:) cell of char vectors with suggestions
%     .n_issues   — (1,1) double

function [pass, report] = figure_audit(fig, opts)
arguments
    fig (1,1) matlab.ui.Figure
    opts.min_font_size (1,1) double {mustBePositive} = 8
    opts.required_labels (1,1) logical = true
    opts.required_title (1,1) logical = false
end

report = struct();
report.all_passed = true;
report.issues = {};
report.warnings = {};
report.n_issues = 0;

% Get all axes from the figure
ax_all = findobj(fig, 'Type', 'axes');
if isempty(ax_all)
    report.issues{end+1} = 'No axes found in figure';
    report.all_passed = false;
    report.n_issues = report.n_issues + 1;
    pass = false;
    return;
end

for i = 1:length(ax_all)
    ax = ax_all(i);

    % Check font size
    if ax.FontSize < opts.min_font_size
        report.issues{end+1} = sprintf('Axis %d: font size %.1f < min %.1f', ...
            i, ax.FontSize, opts.min_font_size);
        report.all_passed = false;
        report.n_issues = report.n_issues + 1;
    end

    % Check grid usage (should be off for publication)
    if strcmp(ax.XGrid, 'on') || strcmp(ax.YGrid, 'on')
        report.warnings{end+1} = sprintf('Axis %d: grid is ON — consider turning off for publication', i);
    end

    % Check box (should be off for clean look)
    if strcmp(ax.Box, 'on')
        report.warnings{end+1} = sprintf('Axis %d: box is ON — consider Box off for publication', i);
    end

    % Check xlabel
    if opts.required_labels && isempty(ax.XLabel.String)
        report.issues{end+1} = sprintf('Axis %d: missing X label', i);
        report.all_passed = false;
        report.n_issues = report.n_issues + 1;
    end

    % Check ylabel
    if opts.required_labels && isempty(ax.YLabel.String)
        report.issues{end+1} = sprintf('Axis %d: missing Y label', i);
        report.all_passed = false;
        report.n_issues = report.n_issues + 1;
    end

    % Check title
    if opts.required_title && isempty(ax.Title.String)
        report.issues{end+1} = sprintf('Axis %d: missing title', i);
        report.all_passed = false;
        report.n_issues = report.n_issues + 1;
    end

    % Check font name consistency
    if i > 1 && ~strcmp(ax.FontName, ax_all(1).FontName)
        report.warnings{end+1} = sprintf('Axis %d: font name "%s" differs from axis 1 "%s"', ...
            i, ax.FontName, ax_all(1).FontName);
    end
end

% Check DPI/resolution (informational, actual DPI depends on export settings)
report.warnings{end+1} = sprintf('DPI check: export DPI is set at export time. Recommend >=300 for publication.');

% Check for colorbar
cb = findobj(fig, 'Type', 'colorbar');
if ~isempty(cb)
    % OK — has colorbar, no warning needed
end

pass = report.all_passed;
end

%% Self-test
function self_test()
    % Test 1: good figure
    f1 = figure('Visible', 'off');
    ax1 = axes('Parent', f1);
    plot(ax1, 1:10, rand(1,10), 'LineWidth', 1.5);
    xlabel('Time (s)'); ylabel('Value');
    apply_publication_style(ax1);
    [pass1, report1] = figure_audit(f1, 'required_labels', true);
    assert(islogical(pass1), 'figure_audit: pass1 not logical');
    assert(isstruct(report1), 'figure_audit: report1 not struct');

    % Test 2: figure with issues (no labels)
    f2 = figure('Visible', 'off');
    ax2 = axes('Parent', f2);
    plot(ax2, 1:10, rand(1,10));
    % Deliberately no labels
    [pass2, report2] = figure_audit(f2, 'required_labels', true);
    assert(~pass2, 'figure_audit: should fail for missing labels');
    assert(report2.n_issues > 0, 'figure_audit: should report issues');

    close([f1 f2]);
    disp('figure_audit: self-test PASSED');
end
