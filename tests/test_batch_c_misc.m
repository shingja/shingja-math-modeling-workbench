% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
% test_batch_c_misc.m — Batch C: 5 Algorithm Unit Tests
clear; clc;

PASS = 0; FAIL = 0;
TOL = 1e-6;
fprintf('╔══════════════════════════════════════╗\n');
fprintf('║  v2.2.1 Batch C — Misc Unit Tests     ║\n');
fprintf('╚══════════════════════════════════════╝\n\n');

%% Test 1: Dynamic Programming — 0/1 Knapsack (analytical verif.)
% v=[60,100,120], w=[10,20,30], W=50 → opt=220 (items 2&3)
fprintf('--- Test 1: dynamic_programming ---\n');
try
    v = [60; 100; 120]; w = [10; 20; 30]; W = 50;
    [val, sol] = dynamic_programming(v, w, W);
    expected_val = 220;
    expected_items = [0; 1; 1];
    assert(abs(val - expected_val) < TOL, sprintf('get %.0f ≠ %d', val, expected_val));
    assert(all(sol == expected_items), 'wrong items selected');
    fprintf('  ✅ PASS: opt=%.0f, items=[%.0f,%.0f,%.0f]\n', val, sol);
    PASS = PASS + 1;
catch ME
    fprintf('  ❌ FAIL: %s\n', ME.message);
    FAIL = FAIL + 1;
end

%% Test 2: DEA — Known-efficient DMU
% DMU1 uses (4,3)→(2,4), DMU2 uses (2,3)→(3,6) ← dominant, DMU3=(5,2)→(2,3)
fprintf('--- Test 2: dea_analyze ---\n');
try
    inputs  = [4 3; 2 3; 5 2];
    outputs = [2 4; 3 6; 2 3];
    eff = dea_analyze(inputs, outputs, 'Display', 'off');
    % DMU2 is dominant → should be efficient (eff≈1)
    assert(eff(2) >= 0.999, sprintf('DMU2 eff=%.4f ≠ 1', eff(2)));
    % At least one inefficient
    assert(any(eff < 0.95), 'all DMUs efficient — unexpected');
    fprintf('  ✅ PASS: eff=[%.4f, %.4f, %.4f]\n', eff);
    PASS = PASS + 1;
catch ME
    fprintf('  ❌ FAIL: %s\n', ME.message);
    FAIL = FAIL + 1;
end

%% Test 3: Euler/Hamilton — K5 完全图
% K5: all degrees=4 (even) → Euler circuit exists
fprintf('--- Test 3a: euler_hamilton (Euler circuit) ---\n');
try
    A = ones(5) - eye(5);  % K5
    [ok, path] = euler_hamilton(A, 'Problem', 'euler_circuit');
    assert(ok, 'Euler circuit should exist in K5');
    assert(path(1) == path(end), 'circuit not closed');
    assert(length(path) == 11, sprintf('expected 10 edges+start=11 nodes, got %d', length(path)));
    fprintf('  ✅ PASS: Euler circuit found, length=%d\n', length(path));
    PASS = PASS + 1;
catch ME
    fprintf('  ❌ FAIL: %s\n', ME.message);
    FAIL = FAIL + 1;
end

fprintf('--- Test 3b: euler_hamilton (Hamilton path, K5) ---\n');
try
    [ok, path] = euler_hamilton(A, 'Problem', 'hamilton');
    assert(ok, 'Hamilton path should exist in K5');
    assert(length(unique(path)) == 5, 'should visit all 5 vertices');
    fprintf('  ✅ PASS: Hamilton path found: %s\n', mat2str(path));
    PASS = PASS + 1;
catch ME
    fprintf('  ❌ FAIL: %s\n', ME.message);
    FAIL = FAIL + 1;
end

%% Test 4: Isolation Forest — Outlier detection
% Generate clean data + few outliers
fprintf('--- Test 4: isolation_forest ---\n');
try
    rng(42);
    X_clean = randn(200, 5);
    X_outliers = randn(10, 5) + 4;  % shifted mean
    X = [X_clean; X_outliers];
    [~, labels] = isolation_forest(X, 'Contamination', 0.05);
    % Outliers should be detected near the end
    outlier_rate = mean(labels(end-9:end) == -1);
    assert(outlier_rate >= 0.5, 'too few outliers flagged in shifted group');
    fprintf('  ✅ PASS: outlier detection rate=%.0f%% in shifted group\n', outlier_rate*100);
    PASS = PASS + 1;
catch ME
    fprintf('  ❌ FAIL: %s\n', ME.message);
    FAIL = FAIL + 1;
end

%% Test 5: StackingCV — Structure validation
% Verify model builds without error (single-model stacking as minimal test)
fprintf('--- Test 5: stacking_cv ---\n');
try
    X = randn(80, 6);
    y = double(rand(80, 1) > 0.5);
    try
        [yp, ~, m] = stacking_cv(X, y, {'rf'}, 'CvFolds', 3);
        assert(length(yp) == 80, 'predict length mismatch');
        assert(~isempty(m.stack), 'model not created');
        fprintf('  ✅ PASS: prediction length=%d, models=%d\n', length(yp), length(m.model_names));
        PASS = PASS + 1;
    catch ME_stack
        if contains(ME_stack.message, 'scikit-learn') || contains(ME_stack.message, 'Python')
            fprintf('  ⏭️  SKIP: Python/scikit-learn not available — %s\n', ME_stack.message);
        else
            rethrow(ME_stack);
        end
    end
catch ME
    fprintf('  ❌ FAIL: %s\n', ME.message);
    FAIL = FAIL + 1;
end

%% Summary
fprintf('\n═══════════════════════════\n');
fprintf('Batch C Results: %d PASS, %d FAIL\n', PASS, FAIL);
if FAIL == 0
    fprintf('✅ ALL TESTS PASSED\n');
else
    fprintf('❌ SOME TESTS FAILED\n');
end
