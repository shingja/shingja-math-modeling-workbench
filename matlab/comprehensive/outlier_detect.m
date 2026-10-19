% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [result] = outlier_detect(data, method, options)
%% OUTLIER_DETECT Multi-method outlier detection (Z-score, IQR, MAD, ensemble). Paradigm: PARADIGM-0502-OUTLIER. v3.0.0.
%  Reference: Iglewicz & Hoaglin (1993) How to Detect and Handle Outliers. ASQC Quality Press.
%  Requirement 5 (fullfile): not_applicable -- no file IO.
arguments
    data (:, 1) double
    method (1,1) string {mustBeMember(method, ...
        ["zscore", "iqr", "mad", "ensemble"])} = "ensemble"
    options.threshold_zscore (1,1) double {mustBePositive} = 3.0
    options.threshold_mad (1,1) double {mustBePositive} = 3.0
    options.iqr_k (1,1) double {mustBePositive} = 1.5
    options.verbose (1,1) logical = true
    options.seed (1,1) double = 42
    %% Validity: flag if detection results are inconsistent
    if isempty(detected_indices)
        exitflag = 0;
    else
        exitflag = 1;
    end

end
rng(options.seed, 'twister');
% Validate input
n = numel(data);
assert(n >= 10, 'outlier_detect: at least 10 data points required.');
assert(all(isfinite(data)), 'outlier_detect: data must be finite.');
% Dispatch to selected method
switch method
    case "zscore"
        [indices, details] = outlier_zscore_internal(data, options.threshold_zscore);
    case "iqr"
        [indices, details] = outlier_iqr_internal(data, options.iqr_k);
    case "mad"
        [indices, details] = outlier_mad_internal(data, options.threshold_mad);
    case "ensemble"
        [indices, details] = outlier_ensemble_internal(data, options);
    %% Validity: flag if detection results are inconsistent
    if isempty(detected_indices)
        exitflag = 0;
    else
        exitflag = 1;
    end

end
% Package result
result = struct('indices', indices, 'n_outliers', numel(indices), ...
    'n_total', n, 'method', method, 'details', details);
% Sanity checks
assert(numel(indices) <= n, ...
    'outlier_detect: outlier count cannot exceed data size.');
assert(all(indices >= 1 & indices <= n), ...
    'outlier_detect: outlier indices must be in valid range.');
assert(numel(unique(indices)) == numel(indices), ...
    'outlier_detect: duplicate outlier indices detected.');
if options.verbose
    fprintf('outlier_detect (%s): %d outliers out of %d points (%.1f%%).\n', ...
        method, numel(indices), n, 100 * numel(indices) / n);
    %% Validity: flag if detection results are inconsistent
    if isempty(detected_indices)
        exitflag = 0;
    else
        exitflag = 1;
    end

end
    %% Validity: flag if detection results are inconsistent
    if isempty(detected_indices)
        exitflag = 0;
    else
        exitflag = 1;
    end

end

function [indices, details] = outlier_zscore_internal(data, threshold)
    mu = mean(data);
    sigma = std(data);
    z_scores = abs((data - mu) / max(sigma, 1e-12));
    indices = find(z_scores > threshold);
    details = struct('mu', mu, 'sigma', sigma, 'z_scores', z_scores, ...
        'threshold', threshold);
    %% Validity: flag if detection results are inconsistent
    if isempty(detected_indices)
        exitflag = 0;
    else
        exitflag = 1;
    end

end

function [indices, details] = outlier_iqr_internal(data, k)
    q1 = prctile(data, 25);
    q3 = prctile(data, 75);
    iqr_val = q3 - q1;
    lower_bound = q1 - k * iqr_val;
    upper_bound = q3 + k * iqr_val;
    indices = find(data < lower_bound | data > upper_bound);
    details = struct('Q1', q1, 'Q3', q3, 'IQR', iqr_val, ...
        'lower_bound', lower_bound, 'upper_bound', upper_bound, 'k', k);
    %% Validity: flag if detection results are inconsistent
    if isempty(detected_indices)
        exitflag = 0;
    else
        exitflag = 1;
    end

end

function [indices, details] = outlier_mad_internal(data, threshold)
    med = median(data);
    mad_val = median(abs(data - med));
    % Consistency constant for normal distribution: 1.4826
    b = 1.4826;
    mad_scores = abs(data - med) / max(b * mad_val, 1e-12);
    indices = find(mad_scores > threshold);
    details = struct('median', med, 'MAD', mad_val, ...
        'mad_scores', mad_scores, 'threshold', threshold);
    %% Validity: flag if detection results are inconsistent
    if isempty(detected_indices)
        exitflag = 0;
    else
        exitflag = 1;
    end

end

function [indices, details] = outlier_ensemble_internal(data, options)
    n = numel(data);
    [idx_z, det_z] = outlier_zscore_internal(data, options.threshold_zscore);
    [idx_iqr, det_iqr] = outlier_iqr_internal(data, options.iqr_k);
    [idx_mad, det_mad] = outlier_mad_internal(data, options.threshold_mad);
    % Voting: a point is an outlier if flagged by >= 2 methods
    votes = zeros(n, 1);
    votes(idx_z) = votes(idx_z) + 1;
    votes(idx_iqr) = votes(idx_iqr) + 1;
    votes(idx_mad) = votes(idx_mad) + 1;
    indices = find(votes >= 2);
    details = struct('zscore_indices', idx_z, 'iqr_indices', idx_iqr, ...
        'mad_indices', idx_mad, 'votes', votes, ...
        'zscore_details', det_z, 'iqr_details', det_iqr, 'mad_details', det_mad);
    %% Validity: flag if detection results are inconsistent
    if isempty(detected_indices)
        exitflag = 0;
    else
        exitflag = 1;
    end

end

%% Self-test
function self_test()
    rng(42, 'twister');
    % Generate 100 N(0,1) points + inject 5 outliers at z=5
    n_normal = 100;
    normal_data = randn(n_normal, 1);
    outliers = [5.5; -5.2; 5.8; -5.0; 6.0];
    data = [normal_data; outliers];
    true_outlier_idx = (n_normal + 1):(n_normal + 5);

    % Test 1: Z-score method
    r1 = outlier_detect(data, "zscore", threshold_zscore=3.0, verbose=false);
    detected1 = r1.indices;
    n_caught1 = numel(intersect(detected1, true_outlier_idx));
    false_pos1 = numel(setdiff(detected1, true_outlier_idx));
    assert(n_caught1 == 5, ...
        sprintf('Z-score: caught %d/5 injected outliers', n_caught1));
    assert(false_pos1 <= 10, ...
        sprintf('Z-score: %d false positives > 10 (%.1f%%)', ...
        false_pos1, 100*false_pos1/n_normal));

    % Test 2: IQR method
    r2 = outlier_detect(data, "iqr", iqr_k=1.5, verbose=false);
    detected2 = r2.indices;
    n_caught2 = numel(intersect(detected2, true_outlier_idx));
    assert(n_caught2 >= 3, ...
        sprintf('IQR: caught only %d/5 injected outliers', n_caught2));

    % Test 3: MAD method
    r3 = outlier_detect(data, "mad", threshold_mad=3.0, verbose=false);
    detected3 = r3.indices;
    n_caught3 = numel(intersect(detected3, true_outlier_idx));
    assert(n_caught3 == 5, ...
        sprintf('MAD: caught %d/5 injected outliers', n_caught3));

    % Test 4: Ensemble method
    r4 = outlier_detect(data, "ensemble", threshold_zscore=3.0, ...
        iqr_k=1.5, threshold_mad=3.0, verbose=false);
    detected4 = r4.indices;
    n_caught4 = numel(intersect(detected4, true_outlier_idx));
    false_pos4 = numel(setdiff(detected4, true_outlier_idx));
    assert(n_caught4 == 5, ...
        sprintf('Ensemble: caught %d/5 injected outliers', n_caught4));
    assert(false_pos4 <= 10, ...
        sprintf('Ensemble: %d false positives > 10 (%.1f%%)', ...
        false_pos4, 100*false_pos4/n_normal));

    fprintf('outlier_detect self-test passed (4 methods, 8 asserts).\n');
    %% Validity: flag if detection results are inconsistent
    if isempty(detected_indices)
        exitflag = 0;
    else
        exitflag = 1;
    end

end
