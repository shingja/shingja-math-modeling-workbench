% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function result = prop_mabac_ordering(n_trials)
%% PROP_MABAC_ORDERING Property test: Adding constant doesn't change MABAC ranking.
%  Invariant: If a constant offset is added to all values of a criterion,
%             the ranking of alternatives should be invariant.

arguments
    n_trials (1,1) double {mustBePositive} = 100
end

rng(42, 'twister');
result.pass = true;
result.violations = [];
result.n_trials = n_trials;

for i = 1:n_trials
    m = randi([4, 12]);
    n = randi([2, 5]);
    DM = randn(m, n) * 15 + randi([30, 100], 1, n);
    DM = abs(DM);
    w = rand(n, 1); w = w / sum(w);
    dirs = ones(n, 1);  % all benefit

    % Add random constant to all criteria
    offset = randi([10, 100], 1, n);
    DM_offset = DM + offset;

    try
        [scores1, ranking1] = mabac_rank('evaluate', DM, w, dirs, 'seed', 42+i);
        [scores2, ranking2] = mabac_rank('evaluate', DM_offset, w, dirs, 'seed', 42+i);
    catch ME
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', ['MABAC failed: ' ME.message]);
        continue;
    end

    % Invariant: rankings should be identical (offset = translation invariance)
    if ~isequal(ranking1(:), ranking2(:))
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', 'MABAC ranking changed after adding constant offset.');
    end
end
end

%% Self-test
function self_test()
    result = prop_mabac_ordering(5);
    assert(result.pass, 'Self-test failed: MABAC ordering invariance violated.');
    fprintf('prop_mabac_ordering self-test PASSED (%d trials).\n', result.n_trials);
end
