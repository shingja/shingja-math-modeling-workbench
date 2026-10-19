% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
%% plot_confusion_matrix — Confusion matrix heatmap with counts and percentages
% MATH-MODELING v3.0.0 S6 Phase 3
% Paradigm: evaluation/classification — classifier performance diagnosis
%
% Creates a confusion matrix visualization with both raw counts and
% row-normalized percentages, color-coded for easy interpretation.
%
% Usage:
%   [fig, ax, exitflag] = plot_confusion_matrix(conf_mat, class_labels)
%   [fig, ax, exitflag] = plot_confusion_matrix(..., Name, Value)

function [fig, ax, exitflag] = plot_confusion_matrix(conf_mat, class_labels, opts)
arguments
    conf_mat (:,:) double        % n_class x n_class confusion matrix
    class_labels (1,:) cell      % class names
    opts.title_text (1,:) char = 'Confusion Matrix'
    opts.normalize (1,1) logical = true  % show row percentages
    opts.font_size (1,1) double = 9
end

[n_rows, n_cols] = size(conf_mat);
if n_rows ~= n_cols
    fig = gobjects(0); ax = gobjects(0); exitflag = int8(-1);
    warning('plot_confusion_matrix: confusion matrix must be square');
    return;
end
if length(class_labels) ~= n_rows
    fig = gobjects(0); ax = gobjects(0); exitflag = int8(-1);
    warning('plot_confusion_matrix: label count mismatch');
    return;
end

n = n_rows;

% Row-normalized percentages
if opts.normalize
    row_sums = sum(conf_mat, 2);
    row_sums(row_sums == 0) = 1;  % avoid division by zero
    conf_norm = conf_mat ./ row_sums * 100;
else
    conf_norm = conf_mat;
end

% Create figure
fig = figure('Visible', 'off', 'Color', 'w');
ax = axes('Parent', fig);

% Heatmap
imagesc(ax, conf_norm);
colormap(ax, hot(256));
caxis(ax, [0, max(conf_norm(:))]);
cb = colorbar(ax);

% Apply style
apply_publication_style(ax);

% Tick labels
ax.XTick = 1:n;
ax.XTickLabel = class_labels;
ax.YTick = 1:n;
ax.YTickLabel = class_labels;
ax.XTickLabelRotation = 45;

% Axis labels
xlabel(ax, 'Predicted Class');
ylabel(ax, 'True Class');

% Overlay text: count + percentage
for i = 1:n
    for j = 1:n
        count = conf_mat(i, j);
        if opts.normalize
            pct = conf_norm(i, j);
            txt = sprintf('%d\n%.1f%%', count, pct);
        else
            txt = sprintf('%d', count);
        end
        % White text on dark cells, black on light
        if conf_norm(i, j) > max(conf_norm(:)) * 0.5
            tc = 'w';
        else
            tc = 'k';
        end
        text(ax, j, i, txt, ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle', ...
            'FontSize', opts.font_size, ...
            'Color', tc);
    end
end

% Compute and display overall accuracy
accuracy = sum(diag(conf_mat)) / sum(conf_mat(:)) * 100;
title_str = sprintf('%s (Acc: %.1f%%)', opts.title_text, accuracy);
title(ax, title_str);

% Style colorbar
try
    cb.FontName = 'Arial';
    cb.FontSize = 9;
end

exitflag = int8(0);
end

%% Self-test
function self_test()
    % 3-class confusion matrix
    conf_mat = [45, 3, 2; 5, 38, 7; 2, 4, 44];
    classes = {'Cat', 'Dog', 'Bird'};

    [fig, ax, exitflag] = plot_confusion_matrix(conf_mat, classes);

    assert(exitflag == 0, 'plot_confusion_matrix: exitflag not zero');
    assert(~isempty(fig), 'plot_confusion_matrix: fig empty');
    assert(~isempty(ax), 'plot_confusion_matrix: ax empty');
    close(fig);
    disp('plot_confusion_matrix: self-test PASSED');
end
