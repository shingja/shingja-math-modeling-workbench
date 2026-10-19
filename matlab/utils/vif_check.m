% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [results, exitflag] = vif_check(X, opts)
% VIF_CHECK Variance Inflation Factor for multicollinearity diagnosis. v3.0.0.
%   VIF_j = 1 / (1 - R_j^2), where R_j^2 is from regressing X_j on other X.
%   VIF > 10 = serious multicollinearity; VIF > 5 = concerning.
%   Input: X (n x p matrix, no intercept column).
%   Output: results(struct with vif/high_vif_mask/warnings), exitflag.
arguments
    X (:,:) double
    opts.verbose (1,1) logical = true
    opts.high_threshold (1,1) double = 10
    opts.warn_threshold (1,1) double = 5
    opts.output_path (1,:) char = fullfile(pwd, 'results')
end

rng(42, 'twister');
exitflag = 0;
results = struct();
warnings_list = {};

if ~isfolder(opts.output_path), mkdir(opts.output_path); end

try
    %% 1. Validate input
    [n_obs, p_var] = size(X);
    results.n_obs = n_obs;
    results.p_var = p_var;
    if p_var < 2
        exitflag = -1;
        results.error = sprintf('Need >=2 variables for VIF, got %d', p_var);
        results.vif = [];
        return;
    end
    if n_obs <= p_var
        exitflag = -1;
        results.error = sprintf('n=%d <= p=%d, VIF undefined', n_obs, p_var);
        results.vif = [];
        return;
    end

    %% 2. Compute VIF for each variable
    if opts.verbose
        fprintf('[%s] Computing VIF for %d variables...\n', ...
            datestr(now, 'HH:MM:SS'), p_var);
    end
    vif_vals = zeros(p_var, 1);
    r_squared = zeros(p_var, 1);
    condition_indices = zeros(p_var, 1);
    for j = 1:p_var
        y_j = X(:, j);
        X_others = X(:, [1:j-1, j+1:p_var]);
        % Include intercept
        X_design = [ones(n_obs, 1), X_others];
        beta_j = X_design \ y_j;
        y_hat = X_design * beta_j;
        ss_res = sum((y_j - y_hat).^2);
        ss_tot = sum((y_j - mean(y_j)).^2);
        if ss_tot < eps
            r_squared(j) = 1;
            vif_vals(j) = Inf;
        else
            r_squared(j) = 1 - ss_res / ss_tot;
            if r_squared(j) >= 1 - eps
                vif_vals(j) = Inf;
            else
                vif_vals(j) = 1 / (1 - r_squared(j));
            end
        end
        % Condition index for this variable's regression
        if ss_tot > eps && r_squared(j) < 1
            s_vals = svd(X_design, 'econ');
            condition_indices(j) = s_vals(1) / (s_vals(end) + eps);
        else
            condition_indices(j) = Inf;
        end
    end
    results.vif = vif_vals;
    results.r_squared = r_squared;
    results.condition_indices = condition_indices;

    %% 3. Flag problematic variables
    high_mask = vif_vals > opts.high_threshold | isinf(vif_vals);
    warn_mask = vif_vals > opts.warn_threshold;
    results.high_vif = high_mask;
    results.warn_vif = warn_mask;
    results.n_high = sum(high_mask);
    results.n_warn = sum(warn_mask);
    results.max_vif = max(vif_vals(~isinf(vif_vals)));
    if isempty(results.max_vif)
        results.max_vif = Inf;
    end
    results.mean_vif = mean(vif_vals(~isinf(vif_vals)));
    if isnan(results.mean_vif)
        results.mean_vif = Inf;
    end

    %% 4. Generate warnings
    if results.n_high > 0
        high_vars = find(high_mask);
        for k = 1:length(high_vars)
            j = high_vars(k);
            warnings_list{end+1} = sprintf(...
                'Variable %d: VIF=%.2e (>%d) - serious multicollinearity', ...
                j, vif_vals(j), opts.high_threshold); %#ok<AGROW>
        end
        exitflag = 1;
    elseif results.n_warn > 0
        warn_vars = find(warn_mask);
        for k = 1:min(3, length(warn_vars))
            j = warn_vars(k);
            warnings_list{end+1} = sprintf(...
                'Variable %d: VIF=%.2e (>%d) - concerning multicollinearity', ...
                j, vif_vals(j), opts.warn_threshold); %#ok<AGROW>
        end
        exitflag = 1;
    end
    results.warnings = warnings_list;

    %% 5. Overall diagnosis
    if results.n_high == 0 && results.n_warn == 0
        results.diagnosis = 'No significant multicollinearity detected.';
    elseif results.n_high > 0
        results.diagnosis = sprintf(...
            'Serious multicollinearity in %d/%d variable(s). Consider removal or regularization.', ...
            results.n_high, p_var);
    else
        results.diagnosis = sprintf(...
            'Moderate multicollinearity in %d/%d variable(s). Monitor with caution.', ...
            results.n_warn, p_var);
    end

    %% 6. Correlation matrix for context
    results.corr_matrix = corrcoef(X);
    results.max_pairwise_corr = max(max(triu(abs(results.corr_matrix) - eye(p_var))));

    %% 7. Export
    results_file = fullfile(opts.output_path, 'vif_check.mat');
    save(results_file, 'results');
    json_file = fullfile(opts.output_path, 'vif_check.json');
    fid = fopen(json_file, 'w');
    if fid > 0, fprintf(fid, '%s', jsonencode(results)); fclose(fid); end

catch ME
    exitflag = -1;
    results.error = ME.message;
end

if opts.verbose
    for i = 1:length(warnings_list)
        fprintf('[vif_check] Warning: %s\n', warnings_list{i});
    end
    if exitflag == 0
        fprintf('[vif_check] All VIF < %d. No multicollinearity issues.\n', ...
            opts.warn_threshold);
    end
end

%% Self-test
function self_test()
    fprintf('=== vif_check self-test ===\n');
    % Test 1: orthogonal data (VIF ~ 1)
    X1 = [randn(100, 1), randn(100, 1), randn(100, 1)];
    [r1, ef1] = vif_check(X1, struct('verbose', false));
    assert(ef1 == 0, 'Orthogonal data: exitflag should be 0, got %d', ef1);
    assert(all(r1.vif < 2), 'Orthogonal VIF should be near 1, max=%.2f', ...
        max(r1.vif));
    assert(r1.n_high == 0, 'Should have no high VIF for orthogonal data');
    fprintf('  Test 1 (orthogonal) passed: max VIF=%.3f\n', max(r1.vif));

    % Test 2: collinear data (VIF >> 10)
    x1 = randn(100, 1);
    x2 = x1 + 0.01 * randn(100, 1);
    x3 = x1 * 0.5 + randn(100, 1);
    X2 = [x1, x2, x3];
    [r2, ef2] = vif_check(X2, struct('verbose', false));
    assert(ef2 == 1, 'Collinear data: exitflag should be 1, got %d', ef2);
    assert(r2.n_high >= 1, 'Should have at least 1 high VIF, got %d', ...
        r2.n_high);
    assert(max(r2.vif) > 10, 'Max VIF should be > 10, got %.2f', max(r2.vif));
    fprintf('  Test 2 (collinear) passed: max VIF=%.2f, n_high=%d\n', ...
        max(r2.vif), r2.n_high);

    disp('vif_check self-test passed.');
end
end
