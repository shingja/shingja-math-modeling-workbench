% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [report, all_pass] = run_property_tests(n_trials)
%% RUN_PROPERTY_TESTS Run all property tests and produce report.
%  Executes every prop_*.m file in the property test directory,
%  aggregates results, and writes a JSON report.
%
%  Usage:
%    [report, all_pass] = run_property_tests()        % default 20 trials
%    [report, all_pass] = run_property_tests(50)      % 50 trials per test
%
%  Output:
%    report   - Struct array with results per test
%    all_pass - Logical: true if all tests passed

arguments
    n_trials (1,1) double {mustBePositive} = 20
end

test_dir = fileparts(mfilename('fullpath'));
prop_files = dir(fullfile(test_dir, 'prop_*.m'));

fprintf('=== Property-Based Test Suite ===\n');
fprintf('Directory: %s\n', test_dir);
fprintf('Tests found: %d\n', numel(prop_files));
fprintf('Trials per test: %d\n\n', n_trials);

n_passed = 0;
n_failed = 0;
n_error = 0;
report = struct();
results_list = {};

for idx = 1:numel(prop_files)
    func_name = strrep(prop_files(idx).name, '.m', '');
    fprintf('[%2d/%2d] %-45s ... ', idx, numel(prop_files), func_name);

    try
        t_start = tic;
        result = feval(func_name, n_trials);
        elapsed = toc(t_start);

        if result.pass
            n_passed = n_passed + 1;
            fprintf('PASS (%.2fs)\n', elapsed);
        else
            n_failed = n_failed + 1;
            fprintf('FAIL (%.2fs) - %d violation(s)\n', elapsed, numel(result.violations));
            for v = 1:min(3, numel(result.violations))
                fprintf('    Violation %d: %s\n', v, result.violations(v).violation);
            end
            if numel(result.violations) > 3
                fprintf('    ... and %d more violation(s)\n', numel(result.violations) - 3);
            end
        end

        report.(func_name) = result;
        results_list{end+1} = struct('name', func_name, 'pass', result.pass, ...
            'n_violations', numel(result.violations), 'elapsed_s', elapsed);

    catch ME
        n_error = n_error + 1;
        fprintf('ERROR - %s\n', ME.message);
        report.(func_name) = struct('pass', false, 'error', ME.message, ...
            'stack', getReport(ME, 'extended', 'hyperlinks', 'off'));
        results_list{end+1} = struct('name', func_name, 'pass', false, ...
            'n_violations', 0, 'elapsed_s', NaN, 'error', ME.message);
    end
end

n_total = n_passed + n_failed + n_error;
all_pass = (n_passed == n_total);

%% Summary
fprintf('\n=== Summary ===\n');
fprintf('Passed:  %d / %d\n', n_passed, n_total);
fprintf('Failed:  %d\n', n_failed);
fprintf('Errors:  %d\n', n_error);
fprintf('Result:  %s\n', ternary(all_pass, 'ALL PASSED', 'SOME FAILED'));

%% Write JSON report
report_struct = struct();
report_struct.all_pass = all_pass;
report_struct.n_passed = n_passed;
report_struct.n_failed = n_failed;
report_struct.n_error = n_error;
report_struct.n_total = n_total;
report_struct.n_trials = n_trials;
report_struct.timestamp = datestr(now, 'yyyy-mm-dd HH:MM:SS');
report_struct.results = results_list;
report_struct.details = report;

json_str = jsonencode(report_struct);
json_path = fullfile(test_dir, 'property_test_report.json');
fid = fopen(json_path, 'w');
if fid < 0
    warning('run_property_tests:CannotWrite', ...
        'Cannot write report to: %s', json_path);
else
    fprintf(fid, '%s', json_str);
    fclose(fid);
    fprintf('\nReport written to: %s\n', json_path);
end

%% Display category breakdown
fprintf('\n=== Category Breakdown ===\n');
categories = {'Conservation Laws', 'Normalization/Sum', 'Reproducibility', ...
              'Monotonicity/Symmetry', 'Boundedness/Feasibility'};
cat_patterns = {'conser|positivity|bounded|nonnegative|mass_con|monotonic', ...
                'weights_sum|closeness|q_bounded', ...
                'reproducibility', ...
                'monotonic|symmetry|consistency|ordering|transitivity', ...
                'interpolation|stability|stationarity|steady_state|R0_threshold|parallel_trends'};

for c = 1:numel(cat_patterns)
    matched = false(size(results_list));
    for r = 1:numel(results_list)
        matched(r) = ~isempty(regexp(results_list{r}.name, cat_patterns{c}, 'once'));
    end
    if any(matched)
        cat_results = results_list(matched);
        cat_pass = sum([cat_results{:}] == true);
        cat_total = numel(cat_results);
        fprintf('  %-30s %d/%d passed\n', categories{c}, cat_pass, cat_total);
    end
end

fprintf('\n=== Done ===\n');
end

%% Helper
function s = ternary(cond, t_val, f_val)
    if cond, s = t_val; else, s = f_val; end
end

%% Self-test
function self_test()
    % Run a quick test with very few trials
    [report, all_pass] = run_property_tests(3);
    assert(isstruct(report), 'Self-test: report should be a struct.');
    assert(islogical(all_pass), 'Self-test: all_pass should be logical.');
    % Check that report JSON was written
    test_dir = fileparts(mfilename('fullpath'));
    json_path = fullfile(test_dir, 'property_test_report.json');
    assert(isfile(json_path), 'Self-test: JSON report file not created.');
    fprintf('run_property_tests self-test PASSED.\n');
end
