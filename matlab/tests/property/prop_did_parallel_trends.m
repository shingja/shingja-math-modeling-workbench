% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function result = prop_did_parallel_trends(n_trials)
%% PROP_DID_PARALLEL_TRENDS Property test: DiD estimator produces valid test statistic.
%  Invariant: DiD ATT estimate should be finite, with valid bootstrap SE and CI ordering.

arguments
    n_trials (1,1) double {mustBePositive} = 100
end

rng(42, 'twister');
result.pass = true;
result.violations = [];
result.n_trials = n_trials;

for i = 1:n_trials
    N_units = randi([20, 100]);
    % Create panel data: each unit appears twice (pre and post)
    N_total = N_units * 2;

    % Random treatment assignment
    treated = repmat(randi([0, 1], N_units, 1), 2, 1);
    post = [zeros(N_units, 1); ones(N_units, 1)];

    % Generate outcome with true ATT = 2.0
    unit_fe = randn(N_units, 1) * 5;        % unit fixed effects
    time_fe = [zeros(N_units, 1); ones(N_units, 1) * 3];  % time trend
    treat_fe = repmat(randi([0, 1], N_units, 1), 2, 1) * 2; % ATT = 2 for treated in post
    time_fe = time_fe + treat_fe .* post;  % ATT only manifests in post period
    Y = repmat(unit_fe, 2, 1) + time_fe + randn(N_total, 1) * 2;

    try
        [ATT, se_boot, ci_low, ci_high, ef] = did_estimate(Y, treated, post, ...
            'seed', 42+i, 'n_boot', 100);
    catch ME
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', ['DiD failed: ' ME.message]);
        continue;
    end

    % Invariant 1: ATT is finite
    if ~isfinite(ATT)
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', 'DiD ATT is non-finite.');
    end

    % Invariant 2: SE is positive
    if ~isnan(se_boot) && se_boot < 0
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', sprintf('DiD SE negative: %.4f', se_boot));
    end

    % Invariant 3: CI lower <= upper (when both finite)
    if ~isnan(ci_low) && ~isnan(ci_high) && ci_low > ci_high
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', sprintf('DiD CI reversed: [%.4f, %.4f]', ci_low, ci_high));
    end

    % Invariant 4: ATT should be within CI (if both finite)
    if ~isnan(ci_low) && ~isnan(ci_high)
        if ATT < ci_low - 0.1 || ATT > ci_high + 0.1
            result.pass = false;
            result.violations(end+1) = struct('trial', i, ...
                'violation', sprintf('DiD ATT=%.4f outside CI [%.4f, %.4f]', ...
                ATT, ci_low, ci_high));
        end
    end
end
end

%% Self-test
function self_test()
    result = prop_did_parallel_trends(5);
    assert(result.pass, 'Self-test failed: DiD parallel trends violated.');
    fprintf('prop_did_parallel_trends self-test PASSED (%d trials).\n', result.n_trials);
end
