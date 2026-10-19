% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function result = prop_gra_monotonic(n_trials)
%% PROP_GRA_MONOTONIC Property test: GRA monotonicity.
%  Invariant: If alternative A dominates B on all criteria,
%             then grade(A) >= grade(B).

arguments
    n_trials (1,1) double {mustBePositive} = 100
end

rng(42, 'twister');
result.pass = true;
result.violations = [];
result.n_trials = n_trials;

for i = 1:n_trials
    m = randi([4, 15]);
    n = randi([2, 6]);

    % Generate base data
    base = randn(m-1, n) * 10 + randi([20, 80], 1, n);
    base = abs(base);

    % Create dominant alternative: better on all criteria
    dom_row = max(base, [], 1) + rand(1, n) * 10 + 1;  % strictly better
    data = [dom_row; base];

    ctype = ones(n, 1);  % all benefit

    try
        [grade, ranking, ~, ~] = gra_analysis(data, ctype, 'seed', 42+i);
    catch ME
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', ['GRA failed: ' ME.message]);
        continue;
    end

    % Invariant: dominant alternative must have highest grade (rank 1)
    if ranking(1) ~= 1
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', sprintf('GRA monotonicity violated: dominant alt ranked %d', ...
            ranking(1)));
    end

    % Also verify grade of dominant >= grade of any other
    if grade(1) < max(grade) - 1e-10
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', sprintf('GRA grade(A_dom)=%.6f < max(grade)=%.6f', ...
            grade(1), max(grade)));
    end
end
end

%% Self-test
function self_test()
    result = prop_gra_monotonic(5);
    assert(result.pass, 'Self-test failed: GRA monotonicity violated.');
    fprintf('prop_gra_monotonic self-test PASSED (%d trials).\n', result.n_trials);
end
