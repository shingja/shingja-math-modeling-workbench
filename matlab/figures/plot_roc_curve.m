% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
%% plot_roc_curve — ROC curve with AUC annotation for binary classification
% MATH-MODELING v3.0.0 S6 Phase 3
% Paradigm: evaluation/classification — discrimination performance
%
% Plots the Receiver Operating Characteristic curve with the area
% under curve (AUC) annotated. Supports multiple classifier comparison.
%
% Usage:
%   [fig, ax, exitflag] = plot_roc_curve(scores, labels)
%   [fig, ax, exitflag] = plot_roc_curve(..., Name, Value)
%
% Inputs:
%   scores — (:,1) double or (:,N) double, classifier scores (higher = more positive)
%   labels — (:,1) double, binary true labels (0=negative, 1=positive)

function [fig, ax, exitflag] = plot_roc_curve(scores, labels, opts)
arguments
    scores (:,:) double        % n_samples x n_classifiers
    labels (:,1) double        % binary labels {0,1}
    opts.title_text (1,:) char = 'ROC Curve'
    opts.classifier_names (1,:) cell = {}
    opts.colors (1,:) cell = {}
    opts.line_width (1,1) double = 1.5
    opts.show_diagonal (1,1) logical = true
    opts.show_auc (1,1) logical = true
end

[n_samples, n_clf] = size(scores);
if length(labels) ~= n_samples
    fig = gobjects(0); ax = gobjects(0); exitflag = int8(-1);
    warning('plot_roc_curve: scores and labels row count mismatch');
    return;
end

% Validate binary labels
unique_labels = unique(labels);
if length(unique_labels) ~= 2
    fig = gobjects(0); ax = gobjects(0); exitflag = int8(-1);
    warning('plot_roc_curve: labels must be binary');
    return;
end

% Default names and colors
if isempty(opts.classifier_names)
    opts.classifier_names = arrayfun(@(i) sprintf('Classifier %d', i), 1:n_clf, 'UniformOutput', false);
end
if isempty(opts.colors)
    p = cb_palette();
    opts.colors = p.categorical(1:n_clf);
end

fig = figure('Visible', 'off', 'Color', 'w');
ax = axes('Parent', fig);
hold(ax, 'on');

auc_values = zeros(n_clf, 1);

for c = 1:n_clf
    s = scores(:, c);

    % Remove NaN
    valid = ~isnan(s) & ~isnan(labels);
    s = s(valid);
    y_true = labels(valid);

    if isempty(s), continue; end

    % Sort by descending score
    [s_sorted, sort_idx] = sort(s, 'descend');
    y_sorted = y_true(sort_idx);

    % Compute TPR and FPR at each threshold
    n_pos = sum(y_sorted);
    n_neg = length(y_sorted) - n_pos;

    if n_pos == 0 || n_neg == 0
        warning('plot_roc_curve: only one class present for %s', opts.classifier_names{c});
        continue;
    end

    tpr = cumsum(y_sorted) / n_pos;
    fpr = cumsum(1 - y_sorted) / n_neg;

    % Add endpoints
    tpr = [0; tpr];
    fpr = [0; fpr];

    % Compute AUC via trapezoidal rule
    auc_values(c) = trapz(fpr, tpr);
    auc_values(c) = max(0, min(1, auc_values(c)));

    % Plot ROC curve
    plot(ax, fpr, tpr, '-', 'Color', opts.colors{c}, ...
        'LineWidth', opts.line_width, ...
        'DisplayName', sprintf('%s (AUC=%.3f)', opts.classifier_names{c}, auc_values(c)));
end

% Diagonal reference line
if opts.show_diagonal
    plot(ax, [0, 1], [0, 1], '--', 'Color', opts.colors{end}, ...
        'LineWidth', 1, 'DisplayName', 'Chance (AUC=0.500)');
end

apply_publication_style(ax);
axis(ax, 'equal');
xlim(ax, [0, 1]); ylim(ax, [0, 1]);
if ~isempty(opts.title_text); title(ax, opts.title_text); end
xlabel(ax, 'False Positive Rate (1 - Specificity)');
ylabel(ax, 'True Positive Rate (Sensitivity)');

legend(ax, 'Location', 'southeast', 'Box', 'off');

hold(ax, 'off');
exitflag = int8(0);
end

%% Self-test
function self_test()
    rng(42);
    n = 200;
    true_labels = [zeros(n/2, 1); ones(n/2, 1)];
    % Simulated scores: higher for positive class
    scores = randn(n, 1) + 0.8 * true_labels + 0.5;

    [fig, ax, exitflag] = plot_roc_curve(scores, true_labels, ...
        'title_text', 'Self-test: ROC Curve');

    assert(exitflag == 0, 'plot_roc_curve: exitflag not zero');
    assert(~isempty(fig), 'plot_roc_curve: fig empty');
    assert(~isempty(ax), 'plot_roc_curve: ax empty');

    % Check AUC is in valid range
    % Find AUC from legend text
    leg = findobj(fig, 'Type', 'legend');
    if ~isempty(leg)
        leg_str = leg.String{1};
        auc_match = regexp(leg_str, 'AUC=([\d.]+)', 'tokens');
        if ~isempty(auc_match)
            auc_val = str2double(auc_match{1}{1});
            assert(auc_val >= 0 && auc_val <= 1, 'plot_roc_curve: AUC out of range');
        end
    end

    close(fig);
    disp('plot_roc_curve: self-test PASSED');
end
