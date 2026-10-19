% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function result = prop_leslie_nonnegative(n_trials)
%% PROP_LESLIE_NONNEGATIVE Property test: Leslie matrix model all population >= 0.
%  Invariant: For nonnegative initial vector and Leslie matrix entries,
%             all population counts remain nonnegative for all time steps.

arguments
    n_trials (1,1) double {mustBePositive} = 100
end

rng(42, 'twister');
result.pass = true;
result.violations = [];
result.n_trials = n_trials;

for i = 1:n_trials
    % Generate random Leslie matrix (nonnegative entries, biologically valid)
    n_ages = randi([2, 6]);
    L = zeros(n_ages, n_ages);
    % Fertility rates (first row)
    L(1, :) = rand(1, n_ages) * 3;
    % Survival rates (sub-diagonal)
    for j = 1:n_ages-1
        L(j+1, j) = 0.1 + rand() * 0.8;  % survival in (0.1, 0.9)
    end

    % Random initial population (nonnegative)
    N0 = randi([10, 500], n_ages, 1);
    n_years = randi([3, 30]);

    try
        [years, pop, age_dist] = leslie_model(N0, L, n_years, 'Display', 'off');
    catch ME
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', ['Leslie solve failed: ' ME.message]);
        continue;
    end

    % Invariant: all population counts >= 0
    violation_idx = find(age_dist < -1e-10, 1);
    if ~isempty(violation_idx)
        [row, col] = ind2sub(size(age_dist), violation_idx);
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', sprintf('Negative pop at year %d, age %d: %.4e', ...
            row-1, col, age_dist(row, col)));
    end

    % Also check total population is nonnegative
    if any(pop < -1e-10)
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', 'Total population became negative.');
    end
end
end

%% Self-test
function self_test()
    result = prop_leslie_nonnegative(5);
    assert(result.pass, 'Self-test failed: Leslie nonnegativity violated.');
    fprintf('prop_leslie_nonnegative self-test PASSED (%d trials).\n', result.n_trials);
end
