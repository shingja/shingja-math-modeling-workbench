% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
% S11_SMOKE_TEST_RUNNER  Run all three Q solvers and validate results.
% Smoke test v3.0.0 for math-modeling Skill.

fprintf('========== S11 SMOKE TEST v3.0.0 ==========\n');
fprintf('2024 CUMCM Problem C: Crop Planting Strategy\n\n');

root = fileparts(mfilename('fullpath'));
addpath(fullfile(root, 'code'));
addpath(fullfile(root, '..', '..', 'matlab', 'optim'));

results_dir = fullfile(root, 'results');
if ~isfolder(results_dir), mkdir(results_dir); end

%% Q1: LP Optimization
fprintf('--- Q1: LP Optimization ---\n');
[r1, ef1] = solve_q1(42, fullfile(root, 'data'), results_dir);
assert(ef1 >= 0, 'Q1 LP should solve');
assert(r1.optimal_profit > 0, 'Q1 profit positive');
assert(r1.total_land_used > 0 && r1.total_land_used <= 860, 'Q1 land in bounds');
assert(all(r1.land_allocation(:) >= 0), 'Q1 allocations >= 0');
fprintf('  PASS: profit=%.0f, land=%.1f, ef=%d\n', r1.optimal_profit, r1.total_land_used, ef1);

%% Q2: TOPSIS+EWM
fprintf('--- Q2: TOPSIS+EWM ---\n');
[r2, ~] = solve_q2(42, fullfile(root, 'data'), results_dir);
assert(abs(sum(r2.weights) - 1.0) < 1e-10, 'Q2 weights sum to 1');
assert(all(r2.closeness >= 0 & r2.closeness <= 1+1e-10), 'Q2 closeness in [0,1]');
assert(length(r2.ranking) == 5, 'Q2 5 scenarios ranked');
assert(r2.best_closeness > 0.5, 'Q2 best closeness > 0.5');
fprintf('  PASS: best=%s, closeness=%.4f\n', r2.best_scenario, r2.best_closeness);

%% Q3: Sensitivity
fprintf('--- Q3: Sensitivity ---\n');
[r3, ~] = solve_q3(42, fullfile(root, 'data'), results_dir);
assert(r3.base_case_profit > 100000, 'Q3 base profit > 100k');
assert(r3.wheat_monotonic, 'Q3 wheat monotonic');
assert(r3.corn_monotonic, 'Q3 corn monotonic');
assert(r3.profit_matrix(5,5) > r3.base_case_profit, 'Q3 max > base');
assert(r3.profit_matrix(1,1) < r3.base_case_profit, 'Q3 min < base');
fprintf('  PASS: base=%.0f, monotonicity=%d\n', r3.base_case_profit, r3.monotonicity_passed);

fprintf('\n========== ALL SMOKE TESTS PASSED ==========\n');
