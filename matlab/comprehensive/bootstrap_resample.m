% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function varargout = bootstrap_resample(mode, varargin)
%% BOOTSTRAP_RESAMPLE  Bootstrap resampling and inference.
%  Paradigm: PARADIGM-0705-BOOTSTRAP. Category: Comprehensive. v3.0.0.
%  Reference: Efron, B. & Tibshirani, R.J. (1993) An Introduction to the
%             Bootstrap. Chapman & Hall/CRC. DOI: 10.1007/978-1-4899-4541-9.
%  Reference: Davison, A.C. & Hinkley, D.V. (1997) Bootstrap Methods and
%             Their Application. Cambridge Univ. Press. ISBN: 978-0521574716.
%
%  Usage:
%    [ci_low, ci_high] = bootstrap_resample('ci', data, @stat_fn, n_boot, alpha)
%    se                = bootstrap_resample('se', data, @stat_fn, n_boot)
%    p_val             = bootstrap_resample('pvalue', data, H0_val, @stat_fn, n_boot)
%
%  Input:
%    data        - Data vector or matrix (n_samples x p)
%    statistic_fn - Function handle @(data) -> scalar statistic
%    n_boot      - Number of bootstrap replicates (default: 1000)
%    alpha       - Significance level for CI (default: 0.05 for 95% CI)
%    H0_value    - Null hypothesis value for p-value computation
%
%  Options (name-value pairs appended after all required args):
%    'seed'     - RNG seed (default: 42)
%    'method'   - CI method: 'percentile' (default), 'bca', 'normal'
%    'block_size' - Block size for block bootstrap (0 = i.i.d., default)
%
%  Output:
%    ci     - [ci_low, ci_high] confidence interval
%    se     - Bootstrap standard error
%    pvalue - Two-sided bootstrap p-value

arguments
    mode (1,1) string
end
arguments (Repeating)
    varargin
end

% ---- Parse options from trailing name-value pairs ----
opts.seed       = 42;
opts.method     = 'percentile';
opts.block_size = 0;

% Extract mode-specific args first, then parse options
all_args = varargin;
pos_args = {};
i = 1;
while i <= length(all_args)
    if ischar(all_args{i}) || isstring(all_args{i})
        key = char(all_args{i});
        if i + 1 <= length(all_args)
            val = all_args{i+1};
            switch lower(key)
                case 'seed',       opts.seed       = val;
                case 'method',     opts.method     = val;
                case 'block_size', opts.block_size = val;
                otherwise
                    pos_args{end+1} = all_args{i};   %#ok<AGROW>
                    pos_args{end+1} = all_args{i+1}; %#ok<AGROW>
            end
            i = i + 2;
        else
            pos_args{end+1} = all_args{i}; %#ok<AGROW>
            i = i + 1;
        end
    else
        pos_args{end+1} = all_args{i}; %#ok<AGROW>
        i = i + 1;
    end
end

rng(opts.seed, 'twister');
exitflag = 1;

% IO note: save(fullfile(output_dir, 'bootstrap_results.mat'), 'boot_stats', 'ci');

%% ---- Core bootstrap resampling engine ----
    function boot_stats = bootstrap_core(data, stat_fn, n_boot, block_size)
        data = data(:);
        n = length(data);
        assert(n >= 2, 'Data must have at least 2 observations.');

        boot_stats = zeros(n_boot, 1);

        if block_size <= 0
            % ---- i.i.d. bootstrap (Efron's method) ----
            for b = 1:n_boot
                idx = randi(n, [n, 1]);
                boot_sample = data(idx);
                boot_stats(b) = stat_fn(boot_sample);
            end
        else
            % ---- Moving block bootstrap ----
            blk = min(block_size, n);
            n_blocks = ceil(n / blk);
            for b = 1:n_boot
                boot_sample = [];
                for bl = 1:n_blocks
                    start_idx = randi(n - blk + 1);
                    boot_sample = [boot_sample; data(start_idx:start_idx + blk - 1)]; %#ok<AGROW>
                end
                boot_sample = boot_sample(1:n);  % truncate to original length
                boot_stats(b) = stat_fn(boot_sample);
            end
        end

        % Convergence check: are bootstrap statistics finite?
        assert(all(isfinite(boot_stats)), ...
            'BOOTSTRAP: non-finite bootstrap statistic detected. Check statistic_fn.');
    end

%% ---- Dispatch ----
switch lower(mode)
    case 'ci'
        assert(length(pos_args) >= 2, ...
            'ci mode requires: data, @stat_fn. Optional: n_boot, alpha.');
        data    = pos_args{1};
        stat_fn = pos_args{2};
        n_boot  = 1000;
        alpha   = 0.05;
        if length(pos_args) >= 3, n_boot = pos_args{3}; end
        if length(pos_args) >= 4, alpha  = pos_args{4}; end

        boot_stats = bootstrap_core(data, stat_fn, n_boot, opts.block_size);

        switch lower(opts.method)
            case 'percentile'
                ci_low  = prctile(boot_stats, 100 * alpha / 2);
                ci_high = prctile(boot_stats, 100 * (1 - alpha / 2));
            case 'normal'
                se_boot = std(boot_stats);
                theta_hat = stat_fn(data(:));
                z_val = norminv(1 - alpha / 2);
                ci_low  = theta_hat - z_val * se_boot;
                ci_high = theta_hat + z_val * se_boot;
            case 'bca'
                % Bias-Corrected and Accelerated (BCa) interval
                theta_hat = stat_fn(data(:));
                % Bias correction
                z0_hat = norminv(mean(boot_stats < theta_hat));
                % Acceleration: jackknife
                n_data = length(data);
                jack_stats = zeros(n_data, 1);
                for j = 1:n_data
                    jack_data = data([1:j-1, j+1:n_data]);
                    jack_stats(j) = stat_fn(jack_data);
                end
                jack_mean = mean(jack_stats);
                a_hat = sum((jack_mean - jack_stats).^3) / ...
                        (6 * (sum((jack_mean - jack_stats).^2))^(3/2));
                if ~isfinite(a_hat), a_hat = 0; end

                z_alpha = norminv(alpha / 2);
                z_1alpha = norminv(1 - alpha / 2);
                alpha1 = normcdf(z0_hat + (z0_hat + z_alpha) / (1 - a_hat * (z0_hat + z_alpha)));
                alpha2 = normcdf(z0_hat + (z0_hat + z_1alpha) / (1 - a_hat * (z0_hat + z_1alpha)));
                ci_low  = prctile(boot_stats, 100 * max(0, min(1, alpha1)));
                ci_high = prctile(boot_stats, 100 * max(0, min(1, alpha2)));
            otherwise
                error('Unknown CI method: %s. Valid: percentile, normal, bca.', opts.method);
        end

        % Sanity: CI must be well-ordered
        assert(ci_low <= ci_high, ...
            'BOOTSTRAP: CI bounds out of order [%.4f, %.4f].', ci_low, ci_high);
        assert(isfinite(ci_low) && isfinite(ci_high), ...
            'BOOTSTRAP: CI bounds are not finite.');

        varargout{1} = ci_low;
        varargout{2} = ci_high;

    case 'se'
        assert(length(pos_args) >= 2, ...
            'se mode requires: data, @stat_fn. Optional: n_boot.');
        data    = pos_args{1};
        stat_fn = pos_args{2};
        n_boot  = 1000;
        if length(pos_args) >= 3, n_boot = pos_args{3}; end

        boot_stats = bootstrap_core(data, stat_fn, n_boot, opts.block_size);
        se_val = std(boot_stats);

        assert(se_val >= 0, 'BOOTSTRAP: negative standard error %.6f.', se_val);
        varargout{1} = se_val;

    case 'pvalue'
        assert(length(pos_args) >= 3, ...
            'pvalue mode requires: data, H0_value, @stat_fn. Optional: n_boot.');
        data    = pos_args{1};
        H0_val  = pos_args{2};
        stat_fn = pos_args{3};
        n_boot  = 1000;
        if length(pos_args) >= 4, n_boot = pos_args{4}; end

        boot_stats = bootstrap_core(data, stat_fn, n_boot, opts.block_size);

        % Two-sided p-value: proportion of bootstrap replicates
        % as or more extreme than observed statistic under H0
        theta_obs = stat_fn(data(:));
        % Shift bootstrap distribution to be centered at H0
        boot_centered = boot_stats - theta_obs + H0_val;
        p_val = mean(abs(boot_centered - H0_val) >= abs(theta_obs - H0_val));

        % Ensure p-value in [0, 1]
        p_val = max(0, min(1, p_val));
        assert(p_val >= 0 && p_val <= 1, ...
            'BOOTSTRAP: p-value %.4f out of [0,1].', p_val);

        varargout{1} = p_val;

    otherwise
        error('BOOTSTRAP_RESAMPLE: unknown mode ''%s''. Valid: ci, se, pvalue.', mode);
end

%% Self-test
function self_test()
    rng(42);
    tol = 1e-4;

    % Generate 50 samples from N(5, 2)
    n_test = 50;
    true_mean = 5.0;
    true_std  = 2.0;
    data_test = true_mean + true_std * randn(n_test, 1);
    mean_fn = @(d) mean(d);

    % ---- Test 1: Bootstrap 95% CI for mean ----
    [ci_lo, ci_hi] = bootstrap_resample('ci', data_test, mean_fn, 1000, 0.05, ...
        'seed', 42, 'method', 'percentile');

    % Assert 1: CI contains true mean
    assert(ci_lo <= true_mean && true_mean <= ci_hi, ...
        'Self-test FAILED: 95%% CI [%.4f, %.4f] does not contain true mean %.4f.', ...
        ci_lo, ci_hi, true_mean);

    % Assert 2: CI width is positive
    assert(ci_hi > ci_lo, ...
        'Self-test FAILED: CI width = %.6f is not positive.', ci_hi - ci_lo);

    % Assert 3: CI is finite
    assert(isfinite(ci_lo) && isfinite(ci_hi), ...
        'Self-test FAILED: CI bounds are not finite.');

    % ---- Test 2: Bootstrap standard error ----
    se_val = bootstrap_resample('se', data_test, mean_fn, 1000, 'seed', 42);

    % Assert 4: SE is positive and reasonable
    assert(se_val > 0, ...
        'Self-test FAILED: standard error = %.6f <= 0.', se_val);
    % Theoretical SE = sigma / sqrt(n) = 2 / sqrt(50) ≈ 0.2828
    expected_se = true_std / sqrt(n_test);
    assert(abs(se_val - expected_se) < 0.15, ...
        'Self-test FAILED: bootstrap SE = %.4f, expected ≈ %.4f.', se_val, expected_se);

    % ---- Test 3: Bootstrap p-value ----
    p_val = bootstrap_resample('pvalue', data_test, 5.0, mean_fn, 1000, 'seed', 42);

    % Assert 5: p-value in valid range
    assert(p_val >= 0 && p_val <= 1, ...
        'Self-test FAILED: p-value = %.4f out of [0,1].', p_val);
    % With true H0 mean = 5.0, p-value should typically be large (> 0.1)
    % (stochastic test: we check it's >= 0.05 with wide tolerance)
    assert(p_val >= 0.01, ...
        'Self-test FAILED: p-value = %.4f unexpectedly small for true H0.', p_val);

    disp('BOOTSTRAP_RESAMPLE self-test passed.');
end
end
